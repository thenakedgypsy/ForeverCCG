--[[
    ForeverCCG Events
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.
]]
local _, ns = ...
local T, B, Comm = ns.Tournament, ns.Bridge, ns.Comm
local Print = ns.Print

-- =========================================================================
-- HOST
-- The organizer's side: holds the event, answers players, and tells each player what changed
-- for them. Whatever arrives is checked against the sender the server gave it.
-- =========================================================================
local H = {}
ns.Host = H

local TICK = 5                 -- seconds between looks at the clock
local CODE_LETTERS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"   -- none that are easily confused
local CODE_LENGTH = 5
local STAND_CHUNK = 200
local STAND_COOLDOWN = 15      -- seconds between sending one player the standings
local ARCHIVE_MAX = 5
local NOTE_MAX = 60

local REASONS = {
    state = "The event isn't at that stage.",
    players = "At least two players must be checked in.",
    incomplete = "Every match in the round needs a result first.",
    match = "That table has no match to change.",
    decided = "That match already has a result. Reset it to change the games.",
    nodraw = "An elimination match needs a winner.",
}

local function Say(err)
    Print(REASONS[err] or err or "That didn't work.")
end

function H:Event()
    return ns.DB().hosted
end

local function NewCode()
    local out = {}
    for i = 1, CODE_LENGTH do
        local n = math.random(#CODE_LETTERS)
        out[i] = CODE_LETTERS:sub(n, n)
    end
    return table.concat(out)
end

-- =========================================================================
-- TELLING PLAYERS
-- =========================================================================
local function MatchFor(ev, key)
    local round = T.CurrentRound(ev)
    for _, m in ipairs(round and round.matches or {}) do
        local side = T.SideOf(m, key)
        if side then return m, side end
    end
    return nil
end

local function YouMessage(ev, p)
    local round = T.CurrentRound(ev)
    local m, side = MatchFor(ev, p.key)
    local tableNo, opponent, status, mine, theirs, result = 0, "", "none", 0, 0, ""
    if m then
        tableNo = m.table
        status = m.bye and "bye" or m.status
        mine, theirs = m.wins[side], m.wins[T.OtherSide(side)]
        if m.b then opponent = T.NameOf(ev, m[T.OtherSide(side)]) end
        if m.result == "draw" then
            result = "draw"
        elseif m.result == side then
            result = "win"
        elseif m.result == "a" or m.result == "b" then
            result = "loss"
        end
    end
    local secondsLeft = (round and round.endsAt and ev.status == "running")
        and math.max(0, round.endsAt - ns.Now()) or -1
    local note = Comm.Clean(m and m.note or ""):sub(1, NOTE_MAX)
    local champion = ev.champion and T.NameOf(ev, ev.champion) or ""
    return table.concat({ "YOU", ev.id, ev.rev, ev.status, #ev.rounds, ev.totalRounds or 0, p.status,
        tableNo, Comm.Clean(opponent), status, mine, theirs, secondsLeft, result, Comm.Clean(champion), note }, ":")
end

function H:OnPlayerHeard(key)
    local ev = self:Event()
    if not ev then return end
    local p = ev.players[key]
    if p then p.lastSeen = ns.Now() end
    T.MarkOnline(ev, key, ns.Now())
end

function H:Push(ev, p)
    if p.manual then return end
    Comm:SendReliable(p.name, YouMessage(ev, p), { key = "you", max = 4,
        onAck = function() H:OnPlayerHeard(p.key) end })
end

-- keys: a set of player keys to tell, or nil for everyone
function H:Changed(keys)
    local ev = self:Event()
    if not ev then return end
    ev.rev = ev.rev + 1
    if keys then
        for key in pairs(keys) do
            if ev.players[key] then self:Push(ev, ev.players[key]) end
        end
    else
        for _, key in ipairs(ev.order) do self:Push(ev, ev.players[key]) end
    end
    ns.RefreshUI()
end

local function KeysOf(m)
    local keys = {}
    if m.a then keys[m.a] = true end
    if m.b then keys[m.b] = true end
    return keys
end

local function SendInfo(ev, p)
    local s = ev.settings
    Comm:Send(p.name, table.concat({ "INFO", ev.id, s.format, s.bestOf, s.deckLock and 1 or 0, s.roundMinutes,
        #s.banned, Comm.Clean(ev.name), s.prizes and 1 or 0 }, ":"))
    -- Split so that no message runs over the limit on addon message length
    local chunks, current = {}, ""
    for _, id in ipairs(s.banned) do
        if #current + #id + 1 > STAND_CHUNK then
            chunks[#chunks + 1] = current
            current = ""
        end
        current = current == "" and id or (current .. "," .. id)
    end
    if current ~= "" then chunks[#chunks + 1] = current end
    for i, chunk in ipairs(chunks) do
        Comm:Send(p.name, table.concat({ "BAN", ev.id, i, #chunks, chunk }, ":"))
    end
end

local function SendStandings(ev, p)
    local chunks, current = {}, ""
    for _, row in ipairs(T.Standings(ev)) do
        local text = table.concat({ (Comm.Clean(row.name):gsub("[,;]", " ")), row.points, row.wins, row.losses,
            row.draws, row.status == "dropped" and 1 or 0 }, ",") .. ";"
        if #current + #text > STAND_CHUNK then
            chunks[#chunks + 1] = current
            current = ""
        end
        current = current .. text
    end
    if current ~= "" then chunks[#chunks + 1] = current end
    for i, chunk in ipairs(chunks) do
        Comm:Send(p.name, table.concat({ "STAND", ev.id, ev.rev, i, #chunks, chunk }, ":"))
    end
end

-- =========================================================================
-- FROM PLAYERS
-- =========================================================================
-- A reported prize wait (seconds) as a number; nil when the player's client couldn't say
function H.PrizeWait(field)
    local n = tonumber(field)
    if not n or n < 0 then return nil end
    return n
end

local function Reject(to, reason, detail)
    Comm:Send(to, "REJECT:" .. reason .. ":" .. Comm.Clean(detail or ""))
end

Comm:On("JOIN", function(parts, from)
    local ev = H:Event()
    local code = (parts[2] or ""):upper()
    if not ev or ev.status == "finished" or code ~= ev.code then return Reject(from, "code") end
    if tonumber(parts[3]) ~= Comm.PROTOCOL then return Reject(from, "protocol") end
    if not B.CompatibleVersions(parts[4], B.Version()) then return Reject(from, "version", B.Version()) end
    local p, err = T.AddPlayer(ev, from, { rating = tonumber(parts[5]) or 1000, score = tonumber(parts[8]) or 0,
        version = parts[4], prizeWait = H.PrizeWait(parts[9]) }, ns.Now())
    if not p then return Reject(from, err) end
    SendInfo(ev, p)
    H:Changed({ [p.key] = true })
end)

Comm:On("CHECKIN", function(parts, from)
    local ev = H:Event()
    if not ev or parts[2] ~= ev.id then return end
    local p, err = T.CheckIn(ev, from:lower(), parts[3], ns.Now(), H.PrizeWait(parts[4]))
    if not p then
        Comm:Send(from, "NOTE:" .. ev.id .. ":Check-in isn't open (" .. tostring(err) .. ").")
        return
    end
    H:Changed({ [p.key] = true })
end)

Comm:On("DROP", function(parts, from)
    local ev = H:Event()
    if not ev or parts[2] ~= ev.id then return end
    local key = from:lower()
    local m = T.Drop(ev, key, ns.Now())
    local keys = m and KeysOf(m) or {}
    keys[key] = true
    H:Changed(keys)
end)

Comm:On("STATUS", function(parts, from)
    local ev = H:Event()
    if not ev or parts[2] ~= ev.id then
        Comm:Send(from, "GONE:" .. tostring(parts[2]))
        return
    end
    local p = ev.players[from:lower()]
    if not p then
        Comm:Send(from, "GONE:" .. ev.id)
        return
    end
    H:OnPlayerHeard(p.key)
    Comm:Send(p.name, YouMessage(ev, p))
    if parts[3] == "1" and ns.Now() - (p.lastPull or 0) >= STAND_COOLDOWN then
        p.lastPull = ns.Now()
        SendStandings(ev, p)
    end
end)

Comm:On("GAME", function(parts, from)
    local ev = H:Event()
    if not ev or parts[2] ~= ev.id then return end
    local m = T.GameStarted(ev, from:lower(), { round = tonumber(parts[3]), table = tonumber(parts[4]),
        gameId = parts[5], deck = parts[6], legal = parts[7] ~= "0" }, ns.Now())
    if m then ns.RefreshUI() end
end)

Comm:On("RESULT", function(parts, from)
    local ev = H:Event()
    if not ev or parts[2] ~= ev.id then return end
    local m = T.ApplyReport(ev, from:lower(), { round = tonumber(parts[3]), table = tonumber(parts[4]),
        gameId = parts[5], outcome = parts[6], quiet = parts[7] == "1", turns = tonumber(parts[8]),
        deck = parts[9], legal = parts[10] ~= "0" }, ns.Now())
    if m then H:Changed(KeysOf(m)) end
end)

-- =========================================================================
-- THE ORGANIZER'S ACTIONS
-- =========================================================================
-- settings as in T.DEFAULTS. Returns the event, or nil.
function H:Create(name, settings)
    local db = ns.DB()
    if db.hosted then
        Print("Close your current event first.")
        return nil
    end
    local me = B.MyName()
    name = Comm.Clean(name):trim()
    if name == "" then name = me .. "'s Tournament" end
    local id = string.format("%06x", math.random(0, 0xFFFFFF))
    db.hosted = T.New(name, me, settings, id, NewCode(), ns.Now())
    Print("Event created. Join code: |cFFFFFFFF" .. db.hosted.code .. "|r")
    ns.RefreshUI()
    return db.hosted
end

function H:Close()
    local db = ns.DB()
    if not db.hosted then return end
    db.archive = db.archive or {}
    table.insert(db.archive, 1, db.hosted)
    while #db.archive > ARCHIVE_MAX do table.remove(db.archive) end
    local ev = db.hosted
    db.hosted = nil
    for _, key in ipairs(ev.order) do
        local p = ev.players[key]
        if not p.manual then Comm:Send(p.name, "GONE:" .. ev.id) end
    end
    ns.RefreshUI()
end

function H:OpenCheckIn()
    local ev = self:Event()
    if not ev then return end
    local ok, err = T.OpenCheckIn(ev, ns.Now())
    if not ok then return Say(err) end
    self:Changed()
end

function H:Start()
    local ev = self:Event()
    if not ev then return end
    local ok, err = T.Start(ev, ns.Now())
    if not ok then return Say(err) end
    self:Changed()
end

-- The next round, or the end of the event after the last one
function H:Advance()
    local ev = self:Event()
    if not ev then return end
    local ok, err = T.NextRound(ev, ns.Now())
    if not ok then return Say(err) end
    self:Changed()
end

function H:EndRound()
    local ev = self:Event()
    if not ev then return end
    local ok, err = T.ForceEndRound(ev, ns.Now())
    if not ok then return Say(err) end
    self:Changed()
end

local function MatchAction(fn, ...)
    local ev = H:Event()
    if not ev then return end
    local args = { ev, ... }
    args[#args + 1] = ns.Now()
    local m, err = fn(unpack(args))
    if not m then return Say(err) end
    H:Changed(KeysOf(m))
end

function H:AwardGame(tableNo, side) MatchAction(T.AwardGame, tableNo, side) end
function H:SetResult(tableNo, result) MatchAction(T.SetResult, tableNo, result) end
function H:VoidDisputes(tableNo) MatchAction(T.VoidDisputes, tableNo) end
function H:ResetMatch(tableNo) MatchAction(T.ResetMatch, tableNo) end

function H:SetRounds(rounds)
    local ev = self:Event()
    if not ev then
        return
    end
    local ok, err = T.SetRounds(ev, rounds, ns.Now())
    if not ok then return Say(err) end
    self:Changed()
end

-- A player without the addon: the organizer enters their results
function H:AddManual(name, rating)
    local ev = self:Event()
    if not ev then return end
    name = B.NormalizeName(name)
    if name == "" then return end
    local p, err = T.AddPlayer(ev, name, { manual = true, rating = rating or 1000 }, ns.Now())
    if not p then return Print("Couldn't add " .. name .. " (" .. tostring(err) .. ").") end
    self:Changed({})
end

function H:DropPlayer(key)
    local ev = self:Event()
    if not ev then return end
    local m = T.Drop(ev, key, ns.Now())
    local keys = m and KeysOf(m) or {}
    keys[key] = true
    self:Changed(keys)
end

-- From a button click: addons may only type in chat during one
function H:Announce(chatType)
    local ev = self:Event()
    if not ev then return end
    local text
    if ev.status == "open" or ev.status == "checkin" then
        text = "ForeverCCG tournament: " .. ev.name .. (ev.settings.prizes and " (a prize card for the champion!)" or "") .. ". Join with /fccgevents join " .. ev.code .. " " .. ev.organizer
    elseif ev.status == "running" then
        text = ev.name .. ": round " .. #ev.rounds .. " of " .. ev.totalRounds .. " is under way."
    else
        local champion = ev.champion and T.NameOf(ev, ev.champion)
        text = ev.name .. " has finished." .. (champion and (" Champion: " .. champion .. "!") or "")
    end
    local send = SendChatMessage or (C_ChatInfo and C_ChatInfo.SendChatMessage)
    if send then pcall(send, text, chatType) end
end

-- How many matches of the round are waiting on the organizer
function H:AttentionCount()
    local ev = self:Event()
    local round = ev and ev.status == "running" and T.CurrentRound(ev)
    local n = 0
    for _, m in ipairs(round and round.matches or {}) do
        if not m.result and (m.status == "disputed" or m.overtime or m.noShow) then n = n + 1 end
    end
    return n
end

local lastAttention = 0

local function Tick()
    local ev = H:Event()
    if not ev then return end
    local touched = T.Tick(ev, ns.Now())
    if touched then H:Changed(touched) end
    local attention = H:AttentionCount()
    if attention > lastAttention then
        Print(attention .. " match(es) need your decision. /fccgevents host")
    end
    lastAttention = attention
end

-- At login: anyone who missed something while the organizer was away hears it now
function H:OnLogin()
    C_Timer.NewTicker(TICK, Tick)
    if self:Event() then
        C_Timer.After(6, function() H:Changed() end)
    end
end
