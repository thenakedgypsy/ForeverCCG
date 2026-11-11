--[[
    ForeverCCG Events
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.
]]
local _, ns = ...

-- =========================================================================
-- TOURNAMENT
-- The rules of an event: players, rounds, matches, results and standings. Only plain Lua
-- here (no WoW API, the clock is passed in), so ForeverCCG_Tests can run it outside the game.
-- The organizer's client holds the one official copy of an event, in its saved variables.
--
-- An event goes  open -> checkin -> running -> finished.
-- A player is    registered -> checkedin -> active, or dropped / noshow.
--
-- HOW A GAME IS SETTLED. Each player's client reports the game under the id ForeverCCG gave
-- it, so the two reports pair up:
--   both agree               the game counts
--   both say cancelled       the game is void
--   they differ              disputed: the organizer decides
--   only one, after a grace  disputed, except for a concede to an opponent who had gone
--                            quiet (a disconnect: settings.disconnect decides) and a cancel
-- =========================================================================
local T = {}
ns.Tournament = T

T.FORMATS = {}
T.POINTS_WIN = 3
T.POINTS_DRAW = 1
T.GRACE_SECONDS = 120     -- how long the second report of a game may take
T.MIN_PLAYERS = 2

local LOG_MAX = 300
local MIN_PERCENT = 1 / 3  -- the usual floor on match and game win percentages

T.DEFAULTS = {
    format = "swiss",
    bestOf = 1,
    rounds = 0,             -- Swiss: 0 = worked out from the player count
    roundMinutes = 30,      -- 0 = no limit
    maxPlayers = 32,
    minRating = 0,          -- 0 = no limit, the same for the two below
    maxRating = 0,
    maxScore = 0,           -- highest collection score allowed
    deckLock = false,
    noShowMinutes = 10,     -- 0 = never forfeit a no-show
    disconnect = "rematch", -- or "award": the connected player wins the game
    disconnectMinutes = 5,  -- "award" waits this long
    prizes = false,         -- the champion wins a prize card; everyone who plays starts the prize cooldown
}

local function Log(ev, now, text)
    local log = ev.log
    log[#log + 1] = { at = now, text = text }
    while #log > LOG_MAX do table.remove(log, 1) end
end
T.Log = Log

local function NameOf(ev, key)
    local p = key and ev.players[key]
    return p and p.name or "?"
end
T.NameOf = NameOf

-- The smallest number of rounds in which n players can be told apart: 8 gives 3, 9 gives 4
function T.Log2Ceil(n)
    local rounds, size = 0, 1
    while size < n do
        size = size * 2
        rounds = rounds + 1
    end
    return math.max(1, rounds)
end

function T.New(name, organizer, settings, id, code, now)
    local s = {}
    for k, v in pairs(T.DEFAULTS) do s[k] = v end
    for k, v in pairs(settings or {}) do s[k] = v end
    s.banned = s.banned or {}
    local ev = {
        id = id, code = code, name = name, organizer = organizer,
        status = "open", rev = 1, createdAt = now,
        settings = s, players = {}, order = {}, rounds = {}, log = {}, totalRounds = 0,
    }
    Log(ev, now, "Event created by " .. organizer)
    return ev
end

function T.Format(ev)
    return T.FORMATS[ev.settings.format]
end

function T.CurrentRound(ev)
    return ev.rounds[#ev.rounds]
end

function T.Active(ev)
    local out = {}
    for _, key in ipairs(ev.order) do
        if ev.players[key].status == "active" then out[#out + 1] = ev.players[key] end
    end
    return out
end

local function EnteredCount(ev)
    local n = 0
    for _, key in ipairs(ev.order) do
        local st = ev.players[key].status
        if st == "registered" or st == "checkedin" then n = n + 1 end
    end
    return n
end

-- =========================================================================
-- ENTRY
-- =========================================================================
-- info: rating, wins, losses, score, version, manual. Returns the player, or nil and why.
-- Asking again changes nothing, so a repeated message is harmless.
function T.AddPlayer(ev, name, info, now)
    local key = name:lower()
    local p = ev.players[key]
    if p and p.status ~= "dropped" then return p end

    local open = ev.status == "open" or ev.status == "checkin"
    if not open then return nil, "closed" end
    if EnteredCount(ev) >= ev.settings.maxPlayers then return nil, "full" end

    info = info or {}
    local rating = info.rating or 1000
    if not info.manual then
        local s = ev.settings
        if s.minRating > 0 and rating < s.minRating then return nil, "rating" end
        if s.maxRating > 0 and rating > s.maxRating then return nil, "rating" end
        if s.maxScore > 0 and (info.score or 0) > s.maxScore then return nil, "score" end
    end

    if not p then
        p = { key = key, name = name }
        ev.players[key] = p
        ev.order[#ev.order + 1] = key
    end
    p.rating, p.manual, p.version = rating, info.manual and true or nil, info.version
    -- Seconds until they can win a prize again, as their client reported it (nil = unknown)
    p.prizeWait, p.prizeHeard = info.prizeWait, now
    p.status = info.manual and "checkedin" or "registered"
    Log(ev, now, name .. " joined" .. (info.manual and " (entered by the organizer)" or ""))
    return p
end

function T.OpenCheckIn(ev, now)
    if ev.status ~= "open" then return nil, "state" end
    ev.status = "checkin"
    Log(ev, now, "Check-in opened")
    return true
end

-- prizeWait (optional): the player's prize cooldown, reported again as they check in
function T.CheckIn(ev, key, deckFp, now, prizeWait)
    local p = ev.players[key]
    if not p then return nil, "unknown" end
    if ev.status ~= "checkin" then return nil, "state" end
    if p.status ~= "registered" and p.status ~= "checkedin" then return nil, "state" end
    if p.status == "registered" then Log(ev, now, p.name .. " checked in") end
    p.status, p.deckFp = "checkedin", deckFp
    if prizeWait then p.prizeWait, p.prizeHeard = prizeWait, now end
    return p
end

-- =========================================================================
-- MATCHES
-- =========================================================================
local function NewMatch(roundNo, tableNo, a, b)
    return { round = roundNo, table = tableNo, a = a, b = b, status = "pending",
        wins = { a = 0, b = 0 }, games = {}, reports = {}, settled = {}, online = {}, flags = {} }
end

local function SideOf(m, key)
    if m.a == key then return "a" end
    if m.b == key then return "b" end
    return nil
end
T.SideOf = SideOf

local function OtherSide(side)
    return side == "a" and "b" or "a"
end
T.OtherSide = OtherSide

local function WinsNeeded(ev)
    return math.ceil(ev.settings.bestOf / 2)
end
T.WinsNeeded = WinsNeeded

local function RefreshStatus(m)
    if m.result then
        m.status = "done"
        return
    end
    for _, entry in pairs(m.reports) do
        if entry.state == "disputed" then
            m.status = "disputed"
            return
        end
    end
    m.status = m.playing and "playing" or "pending"
end

local function MatchName(ev, m)
    return "Table " .. m.table .. " (" .. NameOf(ev, m.a) .. " vs " .. NameOf(ev, m.b) .. ")"
end

-- result: "a", "b" or "draw"
local function Decide(ev, m, result, now, why)
    m.result, m.decidedAt, m.reason = result, now, why
    m.reports, m.playing, m.overtime, m.noShow = {}, nil, nil, nil
    RefreshStatus(m)
    local text = result == "draw" and "a draw" or (NameOf(ev, m[result]) .. " wins")
    Log(ev, now, MatchName(ev, m) .. ": " .. text .. (why and (" [" .. why .. "]") or ""))
end

local function AddGame(ev, m, side, gameId, now, why)
    m.settled[gameId] = true
    m.reports[gameId] = nil
    m.playing = nil
    m.games[#m.games + 1] = { id = gameId, winner = side, at = now, why = why }
    m.wins[side] = m.wins[side] + 1
    Log(ev, now, MatchName(ev, m) .. ": game to " .. NameOf(ev, m[side])
        .. " (" .. m.wins.a .. "-" .. m.wins.b .. ")" .. (why and (" [" .. why .. "]") or ""))
    if m.wins[side] >= WinsNeeded(ev) then
        Decide(ev, m, side, now)
    else
        RefreshStatus(m)
    end
end

local function VoidGame(ev, m, gameId, now, note)
    m.settled[gameId] = true
    m.reports[gameId] = nil
    m.playing = nil
    m.note = note
    RefreshStatus(m)
    Log(ev, now, MatchName(ev, m) .. ": game void" .. (note and (" [" .. note .. "]") or ""))
end

local LOST = { lost = true, conceded = true }

-- Both reports of a game are in
local function Settle(ev, m, gameId, entry, now)
    local a, b = entry.a, entry.b
    if not (a and b) then return end
    if a.outcome == "cancelled" and b.outcome == "cancelled" then
        VoidGame(ev, m, gameId, now, "cancelled")
    elseif a.outcome == "won" and LOST[b.outcome] then
        AddGame(ev, m, "a", gameId, now)
    elseif b.outcome == "won" and LOST[a.outcome] then
        AddGame(ev, m, "b", gameId, now)
    elseif entry.state ~= "disputed" then
        entry.state = "disputed"
        RefreshStatus(m)
        Log(ev, now, MatchName(ev, m) .. ": the reports disagree (" .. a.outcome .. " / " .. b.outcome .. ")")
    end
end

-- The match a player's message is about: only their own, only in the current round
local function FindMatch(ev, key, roundNo, tableNo)
    if ev.status ~= "running" then return nil, "state" end
    local round = T.CurrentRound(ev)
    if not round or round.number ~= roundNo then return nil, "round" end
    local m = round.matches[tableNo]
    if not m or m.bye or m.empty then return nil, "match" end
    local side = SideOf(m, key)
    if not side then return nil, "match" end
    return m, side
end

local function CheckDeck(ev, m, side, deck, legal, now)
    local p = ev.players[m[side]]
    if legal == false and not m.flags["illegal" .. side] then
        m.flags["illegal" .. side] = true
        Log(ev, now, p.name .. " played a deck containing a banned card")
    end
    if ev.settings.deckLock and deck and p.deckFp and deck ~= p.deckFp and not m.flags["deck" .. side] then
        m.flags["deck" .. side] = true
        Log(ev, now, p.name .. " played a different deck from the one they checked in with")
    end
end

function T.MarkOnline(ev, key, now)
    local round = T.CurrentRound(ev)
    if ev.status ~= "running" or not round then return end
    for _, m in ipairs(round.matches) do
        local side = SideOf(m, key)
        if side then m.online[side] = now end
    end
end

-- r: round, table, gameId, deck, legal
function T.GameStarted(ev, key, r, now)
    local m, side = FindMatch(ev, key, r.round, r.table)
    if not m then return nil, side end
    m.online[side] = now
    CheckDeck(ev, m, side, r.deck, r.legal, now)
    if not m.result and not m.settled[r.gameId] then
        m.playing = r.gameId
        RefreshStatus(m)
    end
    return m
end

-- r: round, table, gameId, outcome, quiet, turns, deck, legal
function T.ApplyReport(ev, key, r, now)
    local m, side = FindMatch(ev, key, r.round, r.table)
    if not m then return nil, side end
    m.online[side] = now
    CheckDeck(ev, m, side, r.deck, r.legal, now)
    if m.result or m.settled[r.gameId] then return m end
    local entry = m.reports[r.gameId]
    if not entry then
        entry = {}
        m.reports[r.gameId] = entry
    end
    entry[side] = { outcome = r.outcome, quiet = r.quiet, turns = r.turns, at = now }
    Settle(ev, m, r.gameId, entry, now)
    RefreshStatus(m)
    return m
end

-- =========================================================================
-- THE CLOCK
-- Called every few seconds on the organizer's client. Returns the set of player keys whose
-- match changed, or nil.
-- =========================================================================
local function SingleReport(ev, m, gameId, entry, now)
    local side = (entry.a and not entry.b) and "a" or (entry.b and not entry.a) and "b" or nil
    if not side or entry.state == "disputed" then return false end
    local report = entry[side]
    local age = now - report.at
    if report.outcome == "cancelled" then
        if age < T.GRACE_SECONDS then return false end
        VoidGame(ev, m, gameId, now, "cancelled")
    elseif report.outcome == "conceded" and report.quiet then
        if ev.settings.disconnect == "award" then
            if age < ev.settings.disconnectMinutes * 60 then return false end
            AddGame(ev, m, side, gameId, now, "opponent disconnected")
        else
            if age < T.GRACE_SECONDS then return false end
            VoidGame(ev, m, gameId, now, "disconnect: replay the game")
        end
    else
        if age < T.GRACE_SECONDS then return false end
        entry.state = "disputed"
        RefreshStatus(m)
        Log(ev, now, MatchName(ev, m) .. ": only one player reported a game")
    end
    return true
end

local function CheckNoShow(ev, round, m, now)
    local minutes = ev.settings.noShowMinutes
    if minutes <= 0 or m.noShowChecked or now < round.startedAt + minutes * 60 then return false end
    m.noShowChecked = true
    if m.playing or #m.games > 0 or next(m.reports) then return false end
    if ev.players[m.a].manual or ev.players[m.b].manual then return false end
    local a, b = m.online.a, m.online.b
    if a and b then return false end
    if a or b then
        m.forfeit = true
        Decide(ev, m, a and "a" or "b", now, "no-show")
    else
        m.noShow = true
        Log(ev, now, MatchName(ev, m) .. ": neither player has answered")
    end
    return true
end

function T.Tick(ev, now)
    if ev.status ~= "running" then return nil end
    local round = T.CurrentRound(ev)
    if not round then return nil end
    local touched
    local function Touch(m)
        touched = touched or {}
        touched[m.a] = true
        touched[m.b] = true
    end
    for _, m in ipairs(round.matches) do
        if not m.result and m.b then
            local ids = {}
            for id in pairs(m.reports) do ids[#ids + 1] = id end
            for _, id in ipairs(ids) do
                local entry = m.reports[id]
                if entry and not m.result and SingleReport(ev, m, id, entry, now) then Touch(m) end
            end
            if not m.result and CheckNoShow(ev, round, m, now) then Touch(m) end
            if not m.result and round.endsAt and now >= round.endsAt and not m.overtime then
                m.overtime = true
                Touch(m)
                Log(ev, now, MatchName(ev, m) .. ": out of time, the organizer decides")
            end
        end
    end
    return touched
end

-- =========================================================================
-- THE ORGANIZER'S DECISIONS (current round only)
-- =========================================================================
local function CurrentMatch(ev, tableNo)
    if ev.status ~= "running" then return nil, "state" end
    local round = T.CurrentRound(ev)
    local m = round and round.matches[tableNo]
    if not m or m.bye or m.empty then return nil, "match" end
    return m
end

local function ClearDisputes(m)
    for id, entry in pairs(m.reports) do
        if entry.state == "disputed" then
            m.settled[id] = true
            m.reports[id] = nil
        end
    end
end

function T.AwardGame(ev, tableNo, side, now)
    local m, err = CurrentMatch(ev, tableNo)
    if not m then return nil, err end
    if m.result then return nil, "decided" end
    ClearDisputes(m)
    m.manualGames = (m.manualGames or 0) + 1
    AddGame(ev, m, side, "manual" .. m.manualGames, now, "organizer")
    return m
end

function T.SetResult(ev, tableNo, result, now)
    local m, err = CurrentMatch(ev, tableNo)
    if not m then return nil, err end
    if result == "draw" and not T.Format(ev).allowDraw then return nil, "nodraw" end
    Decide(ev, m, result, now, "organizer")
    return m
end

function T.VoidDisputes(ev, tableNo, now)
    local m, err = CurrentMatch(ev, tableNo)
    if not m then return nil, err end
    ClearDisputes(m)
    m.note = "replay the game"
    RefreshStatus(m)
    Log(ev, now, MatchName(ev, m) .. ": disputed games voided by the organizer")
    return m
end

-- Back to 0-0. Reports of games already counted stay ignored.
function T.ResetMatch(ev, tableNo, now)
    local m, err = CurrentMatch(ev, tableNo)
    if not m then return nil, err end
    m.result, m.reason, m.decidedAt, m.forfeit, m.playing, m.overtime, m.noShow, m.note =
        nil, nil, nil, nil, nil, nil, nil, nil
    m.reports, m.games, m.wins = {}, {}, { a = 0, b = 0 }
    RefreshStatus(m)
    Log(ev, now, MatchName(ev, m) .. ": reset by the organizer")
    return m
end

-- A drop in the middle of a match forfeits it. Returns the match that changed, if any.
function T.Drop(ev, key, now)
    local p = ev.players[key]
    if not p or p.status == "dropped" then return nil end
    p.status = "dropped"
    Log(ev, now, p.name .. " dropped")
    if ev.status ~= "running" then return nil end
    local round = T.CurrentRound(ev)
    for _, m in ipairs(round and round.matches or {}) do
        local side = SideOf(m, key)
        if side and m.b and not m.result then
            m.forfeit = true
            Decide(ev, m, OtherSide(side), now, "opponent dropped")
            return m
        end
    end
    return nil
end

-- 0 = worked out from the player count. Never fewer than the rounds already played.
function T.SetRounds(ev, rounds, now)
    if ev.settings.format ~= "swiss" or ev.status == "finished" then return nil, "state" end
    ev.settings.rounds = rounds
    if ev.status == "running" then
        ev.totalRounds = math.max(#ev.rounds, T.Format(ev).TotalRounds(ev, ev.playerCount))
        Log(ev, now, "The event will run for " .. ev.totalRounds .. " rounds")
    end
    return true
end

-- =========================================================================
-- ROUNDS
-- =========================================================================
function T.RoundComplete(round)
    if not round then return false end
    for _, m in ipairs(round.matches) do
        if not m.result then return false end
    end
    return true
end

function T.IsLastRound(ev)
    return T.Format(ev).IsOver(ev)
end

function T.Finish(ev, now)
    ev.status = "finished"
    ev.finishedAt = now
    local top = T.Standings(ev)[1]
    ev.champion = top and top.key or nil
    Log(ev, now, "Event finished" .. (top and (": " .. top.name .. " wins") or ""))
    return true
end

function T.NextRound(ev, now)
    if ev.status ~= "running" then return nil, "state" end
    local current = T.CurrentRound(ev)
    if current and not T.RoundComplete(current) then return nil, "incomplete" end
    local format = T.Format(ev)
    if format.IsOver(ev) then return T.Finish(ev, now) end

    local number = #ev.rounds + 1
    local minutes = ev.settings.roundMinutes
    local round = { number = number, startedAt = now, matches = {},
        endsAt = minutes > 0 and (now + minutes * 60) or nil }
    for i, pairing in ipairs(format.Pair(ev, number)) do
        local m = NewMatch(number, i, pairing.a, pairing.b)
        if pairing.empty then
            m.empty, m.result, m.status = true, "none", "done"
        elseif not pairing.b then
            m.bye, m.result, m.status = true, "a", "done"
            Log(ev, now, NameOf(ev, pairing.a) .. " has a bye")
        end
        round.matches[i] = m
    end
    ev.rounds[number] = round
    Log(ev, now, "Round " .. number .. " of " .. ev.totalRounds .. " started")
    return round
end

-- Swiss only: everything undecided becomes a draw. An elimination match needs a winner.
function T.ForceEndRound(ev, now)
    if ev.status ~= "running" then return nil, "state" end
    if not T.Format(ev).allowDraw then return nil, "nodraw" end
    local round = T.CurrentRound(ev)
    for _, m in ipairs(round and round.matches or {}) do
        if not m.result then Decide(ev, m, "draw", now, "round ended by the organizer") end
    end
    return true
end

-- Whoever has not checked in is out. Seeds go by rating, highest first.
function T.Start(ev, now)
    if ev.status ~= "checkin" then return nil, "state" end
    local entrants = {}
    for _, key in ipairs(ev.order) do
        if ev.players[key].status == "checkedin" then entrants[#entrants + 1] = ev.players[key] end
    end
    if #entrants < T.MIN_PLAYERS then return nil, "players" end

    for _, key in ipairs(ev.order) do
        local p = ev.players[key]
        if p.status == "registered" then
            p.status = "noshow"
            Log(ev, now, p.name .. " did not check in")
        end
    end
    table.sort(entrants, function(a, b)
        if a.rating ~= b.rating then return a.rating > b.rating end
        return a.key < b.key
    end)
    for i, p in ipairs(entrants) do
        p.seed, p.status = i, "active"
    end
    ev.status = "running"
    ev.startedAt = now
    ev.playerCount = #entrants
    ev.totalRounds = T.Format(ev).TotalRounds(ev, #entrants)
    return T.NextRound(ev, now)
end

-- =========================================================================
-- STANDINGS
-- =========================================================================
-- Per player: points, wins (byes included), losses, draws, byes, games, opponents faced
function T.Stats(ev)
    local stats = {}
    for key in pairs(ev.players) do
        stats[key] = { key = key, points = 0, wins = 0, losses = 0, draws = 0, byes = 0,
            gameWins = 0, gameLosses = 0, opponents = {}, played = {} }
    end
    for _, round in ipairs(ev.rounds) do
        for _, m in ipairs(round.matches) do
            local a, b = stats[m.a or ""], stats[m.b or ""]
            if a and m.bye then
                a.byes = a.byes + 1
                a.wins = a.wins + 1
                a.points = a.points + T.POINTS_WIN
            elseif a and b then
                a.played[m.b], b.played[m.a] = true, true
                if m.result then
                    a.opponents[#a.opponents + 1] = m.b
                    b.opponents[#b.opponents + 1] = m.a
                    a.gameWins, a.gameLosses = a.gameWins + m.wins.a, a.gameLosses + m.wins.b
                    b.gameWins, b.gameLosses = b.gameWins + m.wins.b, b.gameLosses + m.wins.a
                    if m.result == "draw" then
                        a.draws, b.draws = a.draws + 1, b.draws + 1
                        a.points, b.points = a.points + T.POINTS_DRAW, b.points + T.POINTS_DRAW
                    else
                        local winner = m.result == "a" and a or b
                        local loser = m.result == "a" and b or a
                        winner.wins = winner.wins + 1
                        winner.points = winner.points + T.POINTS_WIN
                        loser.losses = loser.losses + 1
                    end
                end
            end
        end
    end
    return stats
end

-- Match win percentage, byes left out
local function MatchPercent(s)
    local played = s.wins - s.byes + s.losses + s.draws
    if played == 0 then return MIN_PERCENT end
    return math.max(MIN_PERCENT, (T.POINTS_WIN * (s.wins - s.byes) + T.POINTS_DRAW * s.draws) / (T.POINTS_WIN * played))
end

local function GamePercent(s)
    local games = s.gameWins + s.gameLosses
    if games == 0 then return MIN_PERCENT end
    return math.max(MIN_PERCENT, s.gameWins / games)
end

-- One row for everyone who took part, unsorted, with both tiebreakers worked out
function T.BaseRows(ev, stats)
    local rows = {}
    for _, key in ipairs(ev.order) do
        local p = ev.players[key]
        if p.status ~= "noshow" and not (p.status == "dropped" and ev.status ~= "running" and ev.status ~= "finished") then
            local s = stats[key]
            local total = 0
            for _, opp in ipairs(s.opponents) do total = total + MatchPercent(stats[opp]) end
            rows[#rows + 1] = { key = key, name = p.name, status = p.status, seed = p.seed or 9999,
                points = s.points, wins = s.wins, losses = s.losses, draws = s.draws, byes = s.byes,
                omw = #s.opponents > 0 and (total / #s.opponents) or 0, gwp = GamePercent(s) }
        end
    end
    return rows
end

-- Sorted rows, each with its rank
function T.Standings(ev)
    local rows = T.Format(ev).Standings(ev, T.Stats(ev))
    for i, row in ipairs(rows) do row.rank = i end
    return rows
end
