--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

-- =========================================================================
-- SPECTATING
-- A spectator sits in one player's seat: the real board, showing that player's side as
-- "mine" (hand included, never the deck order) and their opponent as "theirs".
--
-- FRAMES. Every CAPTURE_EVERY seconds of a game, the board is cut into chunks (the phase, each
-- side, the hand, one per permanent...), each a string. Whoever is following gets only the
-- chunks that changed, plus the events since (log lines, spells, deaths, swings). The same
-- deltas go to live spectators and into a recording of the last game (R.lastGame, in memory
-- only for now): saving replays later needs only to keep those strings once a game has ended
-- and play them through S:ApplyDelta.
--
-- NETWORK. Everything goes on the low send queue (Net:SendSpectator), behind every game
-- message and one message at a time per spectator, so a busy game makes the spectator lag
-- and never the game. A spectator always gets the latest board, not a backlog.
--   SPEC_GAME:<turn>:<opponent>       answer to a hello or contact ping: "I'm in a game"
--   SPEC_REQ:<format>                 I'm watching: answered SPEC_OK or SPEC_NO:<reason>
--   SPEC_F:<batch>:<i>:<n>:<data>     part i of n of a delta
--   SPEC_SYNC / SPEC_PING / SPEC_LEAVE     spectator to player: resend all / still here / gone
--   SPEC_MISS:<batch>:<i,j,...|*>     spectator to player: those parts of a delta never came
--                                     (the player keeps its last KEPT_BATCHES deltas' parts);
--                                     a player before this ignores it, and SPEC_SYNC follows
--   SPEC_END:<outcome>                the game finished
-- Nobody is asked: a game can be watched while its player's Spectatable box is ticked (the
-- Spectators tab). The box locks once someone is watching, so it can't be used to drop them.
--
-- THE VIEWER runs the board with E.inMatch and E.isSolo set: solo stops Net:Send and makes
-- Network.lua ignore game messages, so a viewer can't reach any real game. E.viewing turns
-- the engine's actions off (GATED).
-- =========================================================================
local E, B, Net = TTS.Engine, TTS.BoardFrame, TTS.Net
if not (E and B and Net) then return end
local L = TTS.L

TTS.Spectate = TTS.Spectate or {}
local S = TTS.Spectate
TTS.Replay = TTS.Replay or {}
local R = TTS.Replay

local FORMAT = 1
local CAPTURE_EVERY = 0.5     -- seconds between looks at the board
local MAX_SPECTATORS = 3
local MAX_RECORDED = 3000     -- deltas kept of a game
local MAX_QUEUED_EVENTS = 60  -- waiting for a slow spectator; the oldest go first
local RECENT_LOG = 12         -- log lines a new spectator starts with
local KEEPALIVE = 20          -- seconds of silence before an empty delta / a ping
local SPECTATOR_TIMEOUT = 75  -- unheard for this long: gone
local CHAIN_TIMEOUT = 45      -- no part of a delta has gone for this long: send everything again
local GAP_WAIT = 8            -- a later delta came but this one hasn't by then: ask for everything
local PART_STALL = 30         -- a delta's next part not here by then (it's low priority, so it can wait)
local SYNC_COOLDOWN = 15
local REQUEST_TIMEOUT = 30    -- seconds to wait for a player's client to answer
local GAME_EXPIRY = 120       -- a game on the waiting-room list not heard of for this long
local HELLO_COOLDOWN = 30     -- seconds between telling the same player about our game
local MAX_PARTS = 200
local KEPT_BATCHES = 8        -- deltas whose parts the player keeps, for SPEC_MISS
local MISS_WAIT = 3           -- a part known lost (a later one is here) is asked for this long after
local MISS_STALL = 15         -- the newest delta's last parts not here this long after its last: lost
local MISS_AGAIN = 6          -- seconds between asks for the same delta's parts
local MISS_TRIES = 3          -- asks for a delta's parts before asking for everything (SPEC_SYNC)

local function Print(msg) DEFAULT_CHAT_FRAME:AddMessage(msg) end
local function Key(name) return Net.CharName(name or ""):lower() end
local function MyName() return TTS.GetPlayerFullName() end

-- =========================================================================
-- CODEC
-- Plain values to a string and back. Decoding builds tables only, nothing is executed, as
-- this data comes from another player.
-- =========================================================================
local MAX_DEPTH = 10

local function KeyOrder(a, b)
    local ta, tb = type(a), type(b)
    if ta ~= tb then return ta < tb end
    return a < b
end

local function Put(v, out, depth)
    local t = type(v)
    if t == "number" then
        out[#out + 1] = "n" .. v .. ";"
    elseif t == "string" then
        out[#out + 1] = "s" .. #v .. ";" .. v
    elseif t == "boolean" then
        out[#out + 1] = v and "T" or "F"
    elseif t == "table" and depth < MAX_DEPTH then
        local keys = {}
        for k, val in pairs(v) do
            local tk, tv = type(k), type(val)
            if (tk == "number" or tk == "string")
                and (tv == "number" or tv == "string" or tv == "boolean" or tv == "table") then
                keys[#keys + 1] = k
            end
        end
        table.sort(keys, KeyOrder)   -- the same table always gives the same string
        out[#out + 1] = "{"
        for _, k in ipairs(keys) do
            Put(k, out, depth + 1)
            Put(v[k], out, depth + 1)
        end
        out[#out + 1] = "}"
    else
        out[#out + 1] = "N"
    end
end

local function Encode(v)
    local out = {}
    Put(v, out, 0)
    return table.concat(out)
end

local function Get(s, pos, depth)
    local c = s:sub(pos, pos)
    if c == "n" or c == "s" then
        local stop = s:find(";", pos, true)
        local n = stop and tonumber(s:sub(pos + 1, stop - 1))
        if not n then error("bad value") end
        if c == "n" then return n, stop + 1 end
        return s:sub(stop + 1, stop + n), stop + n + 1
    elseif c == "T" then return true, pos + 1
    elseif c == "F" then return false, pos + 1
    elseif c == "N" then return nil, pos + 1
    elseif c == "{" then
        if depth >= MAX_DEPTH then error("too deep") end
        local t, k, v = {}, nil, nil
        pos = pos + 1
        while s:sub(pos, pos) ~= "}" do
            if pos > #s then error("cut short") end
            k, pos = Get(s, pos, depth + 1)
            v, pos = Get(s, pos, depth + 1)
            if k ~= nil then t[k] = v end
        end
        return t, pos + 1
    end
    error("bad tag")
end

-- value, or nil if the string is damaged
local function Decode(s)
    local ok, v = pcall(Get, s, 1, 0)
    if ok then return v end
    return nil
end

R.Encode, R.Decode, R.FORMAT = Encode, Decode, FORMAT

-- =========================================================================
-- CAPTURE
-- =========================================================================
-- Short names for a permanent's usual fields (other fields travel under their own name)
local PERM_KEY = {
    id = "i", tapped = "t", sick = "k", damage = "d", tempPower = "a", tempToughness = "b",
    permPower = "A", permToughness = "B", tempKw = "w", permKw = "W", spellEffects = "e",
    dots = "o", hots = "h", attachments = "x", shielded = "s", regenerateShield = "r",
    freezeUntap = "z", isAttacking = "c", spawned = "n", tokenSource = "u", foil = "f",
}
local PERM_NAME = {}
for name, short in pairs(PERM_KEY) do PERM_NAME[short] = name end
local PERM_SKIP = { uid = true, attackUndo = true, spawnShown = true, hasAttackedThisTurn = true }

local cap               -- the game being captured: { rec, sids, byUid, holders, nextSid, startedAt }
local events = {}       -- since the last look
local recentLog = {}
local spectators = {}   -- [lowerName] = { name, sent, fresh, batch, events, heard, chain, lastSend }

local function OnBoard(perm)
    for _, st in ipairs({ E.localState, E.remoteState }) do
        for _, p in ipairs(st.field) do
            if p == perm then return true end
        end
    end
    return false
end

-- A permanent's id for as long as the game lasts. Undo puts copies back, which keep their uid
-- and take over the id of the permanent they replace. A uid isn't unique (several are just
-- time() plus a small number), so one whose holder is still on the board is a different
-- permanent and gets an id of its own.
local function SidOf(perm)
    local sid = cap.sids[perm]
    if sid then return sid end
    sid = perm.uid and cap.byUid[perm.uid]
    if sid and OnBoard(cap.holders[sid]) then sid = nil end
    if not sid then
        cap.nextSid = cap.nextSid + 1
        sid = cap.nextSid
        if perm.uid then cap.byUid[perm.uid] = sid end
    end
    cap.sids[perm] = sid
    cap.holders[sid] = perm
    return sid
end

local function Slim(mana)
    local out = {}
    for k, v in pairs(mana or {}) do
        if v ~= 0 then out[k] = v end
    end
    return out
end

local function SideChunk(st, isRemote)
    local deck
    if not isRemote or E.isSolo then deck = #st.deck else deck = st.deckCount or -1 end
    return Encode({
        l = st.life, m = Slim(st.mana), s = st.damageShield, d = st.dots, h = st.hots,
        g = st.graveyard, mi = st.mirror, dc = deck,
        hc = isRemote and (st.handCount or #(st.hand or {})) or #st.hand,
    })
end

local function PermChunk(perm)
    local out = {}
    for k, v in pairs(perm) do
        if not PERM_SKIP[k] and v ~= false and v ~= 0 then out[PERM_KEY[k] or k] = v end
    end
    return Encode(out)
end

local function SpectatorNames()
    local names = {}
    for _, s in pairs(spectators) do names[#names + 1] = s.name end
    table.sort(names)
    return names
end

local function HeroInfo(id)
    local card = TTS.Hero and TTS.Cards[id]
    return card and card.heroInfo or nil
end

-- The board as chunks
local function Chunks()
    local c = {}
    c.h = Encode({ ph = E.phase, my = E.isMyTurn and true or false, tn = E.turn, rt = E.remoteTurns,
        ea = E.endAfterCombat and true or nil, pd = E.pendingDiscard and true or nil })
    c.m = Encode({ op = E.opponent, me = MyName(),
        mh = TTS.Hero and HeroInfo(TTS.Hero.MY_ID), oh = TTS.Hero and HeroInfo(TTS.Hero.OPP_ID) })
    c.L, c.R = SideChunk(E.localState, false), SideChunk(E.remoteState, true)
    c.H = Encode(E.localState.hand)
    for _, side in ipairs({ "local", "remote" }) do
        local st = side == "local" and E.localState or E.remoteState
        local ids = {}
        for i, perm in ipairs(st.field) do
            local sid = SidOf(perm)
            ids[i] = sid
            c["p" .. sid] = PermChunk(perm)
        end
        c[side == "local" and "fl" or "fr"] = Encode(ids)
    end
    local bs = E.blockingState
    if bs then
        c.bs = Encode({ a = bs.attackers, b = bs.blocks, r = bs.isRemoteAttacking and true or nil,
            d = bs.blocksDeclared and true or nil, x = bs.attacksDone and true or nil })
    end
    local stolen = {}
    for _, s in ipairs(E.stolenCreatures or {}) do
        if s.perm then stolen[#stolen + 1] = SidOf(s.perm) end
    end
    if #stolen > 0 then c.st = Encode(stolen) end
    c.fo = Encode({ l = E.localFoils, r = E.remoteFoils })
    -- What Just Happened, without an effect's long text lines
    local eff = E.lastEffect
    c.wh = Encode({ p = E.lastPlayed, c = E.lastCombat, e = eff and { id = eff.id, isRemote = eff.isRemote,
        target = eff.target, targetPlayer = eff.targetPlayer } or nil })
    c.sp = Encode(SpectatorNames())
    return c
end

-- What changed since this follower's last delta, or nil
local function MakeDelta(who, chunks)
    local changed, removed, any = {}, {}, false
    for k, v in pairs(chunks) do
        if who.sent[k] ~= v then changed[k] = v; any = true end
    end
    for k in pairs(who.sent) do
        if chunks[k] == nil then removed[#removed + 1] = k; any = true end
    end
    who.sent = chunks
    local d = {}
    if any then d.c, d.r = changed, (#removed > 0) and removed or nil end
    if who.fresh then d.f = true; who.fresh = nil end
    return d, any or d.f
end

-- Log text without colours, links or icons ({W} mana symbols stay, they're short)
local function CleanLog(msg)
    msg = tostring(msg or "")
    msg = msg:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    msg = msg:gsub("|H.-|h(.-)|h", "%1"):gsub("|T.-|t", ""):gsub("|A.-|a", "")
    return (msg:gsub("\r?\n", " "))
end

local function Push(ev)
    events[#events + 1] = ev
end

-- UTF-8 is never cut inside a character
local function Split(payload, room)
    local parts, pos, n = {}, 1, #payload
    while pos <= n do
        local stop = math.min(pos + room - 1, n)
        while stop < n and stop > pos do
            local b = payload:byte(stop + 1)
            if b < 0x80 or b >= 0xC0 then break end
            stop = stop - 1
        end
        parts[#parts + 1] = payload:sub(pos, stop)
        pos = stop + 1
    end
    if #parts == 0 then parts[1] = "" end
    return parts
end

-- Sends a delta one part at a time, each queued when the last has gone
local function SendDelta(s, chunks, andThen)
    local d, any = MakeDelta(s, chunks)
    if #s.events > 0 then d.e = s.events; s.events = {} end
    if not any and not d.e and GetTime() - s.lastSend < KEEPALIVE then
        if andThen then andThen() end
        return
    end
    s.batch = s.batch + 1
    local batch = s.batch
    local room = 255 - #("T:" .. s.name .. ":" .. MyName() .. ":SPEC_F:99999:999:999:") - 4
    local parts = Split(Encode(d), room)
    if #parts > MAX_PARTS then
        -- Far too big to send: start again from the whole board on the next look
        s.sent, s.fresh = {}, true
        if andThen then andThen() end
        return
    end
    s.lastSend = GetTime()
    s.chain = GetTime()
    -- Kept a while, so parts lost on the way can be sent again (SPEC_MISS)
    s.kept = s.kept or {}
    s.kept[batch] = parts
    s.kept[batch - KEPT_BATCHES] = nil
    local function SendPart(i)
        local msg = string.format("SPEC_F:%d:%d:%d:%s", batch, i, #parts, parts[i])
        Net:SendSpectator(s.name, msg, function()
            -- CHAIN_TIMEOUT counts from the last part to leave: a big delta on spare
            -- bandwidth can take longer than that in all, and starting again alongside the
            -- one still going would only slow both
            if s.chain then s.chain = GetTime() end
            if i < #parts then
                SendPart(i + 1)
            else
                s.chain = nil
                if andThen then andThen() end
            end
        end)
    end
    SendPart(1)
end

local function Look(final, outcome)
    if not cap then return end
    local ok, chunks = pcall(Chunks)
    if not ok then return end
    local evs = events
    events = {}
    local now = GetTime()

    local rec = cap.rec
    if #rec.frames < MAX_RECORDED then
        local d, any = MakeDelta(rec, chunks)
        if any or #evs > 0 then
            d.t = math.floor((now - cap.startedAt) * 10)
            if #evs > 0 then d.e = evs end
            rec.frames[#rec.frames + 1] = Encode(d)
        end
    end

    for key, s in pairs(spectators) do
        for _, ev in ipairs(evs) do s.events[#s.events + 1] = ev end
        while #s.events > MAX_QUEUED_EVENTS do table.remove(s.events, 1) end
        if final then
            SendDelta(s, chunks, function() Net:SendSpectator(s.name, "SPEC_END:" .. tostring(outcome)) end)
        elseif now - s.heard > SPECTATOR_TIMEOUT then
            spectators[key] = nil
            Net:DropQueuedSpectatorParts(s.name)
            E:Log(L("spec.leftLog", s.name), "SYSTEM")
            S:UpdateTab()
        else
            if s.chain and now - s.chain > CHAIN_TIMEOUT then
                s.chain = nil              -- a part was dropped from the queue
                s.sent, s.fresh = {}, true
            end
            if not s.chain then SendDelta(s, chunks) end
        end
    end
end

local ticker = CreateFrame("Frame")
local since = 0
ticker:SetScript("OnUpdate", function(_, dt)
    since = since + dt
    if since < CAPTURE_EVERY then return end
    since = 0
    Look()
    S:ViewerTick()
end)

-- Everything here runs only in a real game: a viewer never calls StartMatch
E:HookDisplay("StartMatch", nil, function(_, self)
    if not self.inMatch or self.viewing then return end
    cap = { rec = { frames = {}, sent = {}, fresh = true, isSolo = self.isSolo, opponent = self.opponent },
        sids = setmetatable({}, { __mode = "k" }), byUid = {}, holders = {}, nextSid = 0, startedAt = GetTime() }
    events, recentLog = {}, {}
    wipe(spectators)
    S:UpdateTab()
end)

E:HookDisplay("EndMatch", nil, function(_, self, results, outcome)
    if not cap then return end
    Look(true, outcome)
    wipe(spectators)
    cap.rec.outcome = outcome
    R.lastGame = cap.rec
    cap = nil
    S:UpdateTab()
end)

E:HookDisplay("Log", function(self, msg, category)
    if not cap then return end
    local ev = { "L", CleanLog(msg), category }
    Push(ev)
    recentLog[#recentLog + 1] = ev
    if #recentLog > RECENT_LOG then table.remove(recentLog, 1) end
end)

E:HookDisplay("ResolveSpell", function(self, card, tgt, casterIsRemote)
    if cap and card then Push({ "S", card.id, casterIsRemote and true or false }) end
end)

E:HookDisplay("ResolveCombatDamage", function(self)
    local bs = self.blockingState
    if not (cap and bs) then return end
    local atkField = (bs.isRemoteAttacking and self.remoteState or self.localState).field
    local blkField = (bs.isRemoteAttacking and self.localState or self.remoteState).field
    local atk, blk = {}, {}
    for _, i in ipairs(bs.attackers or {}) do
        if atkField[i] then atk[#atk + 1] = SidOf(atkField[i]) end
    end
    for _, pair in ipairs(self:BlockPairs(bs)) do
        if blkField[pair[1]] then blk[#blk + 1] = SidOf(blkField[pair[1]]) end
    end
    Push({ "X", atk, blk, self.preventCombatDamage and true or false })
end)

E:HookDisplay("ActivateAbility", nil, function(_, self, results, perm)
    if cap and results[1] and perm then Push({ "A", SidOf(perm) }) end
end)

E:HookDisplay("HandleCreatureDeath", function(self, perm)
    if cap and perm then Push({ "D", SidOf(perm) }) end
end)

-- =========================================================================
-- THE PLAYER'S SIDE
-- =========================================================================
local function AllowingRequests()
    return not TTS.Options or TTS.Options:Get("allowSpectators") ~= false
end

local function InRealGame()
    return cap and E.inMatch and not E.isSolo and not E.viewing
end

local function CountSpectators()
    local n = 0
    for _ in pairs(spectators) do n = n + 1 end
    return n
end

local helloSent = {}

-- Someone looked for players: if we're in a game they can watch, say so
function S:OnHello(name)
    if not (InRealGame() and AllowingRequests()) then return end
    local key, now = Key(name), time()
    if key == "" or now - (helloSent[key] or 0) < HELLO_COOLDOWN then return end
    helloSent[key] = now
    local turn = (E.turn or 1) + (E.remoteTurns or 0)
    Net:SendSpectator(name, string.format("SPEC_GAME:%d:%s", turn, tostring(E.opponent)))
end

local function OnRequest(sender, format)
    local Refuse = function(why) Net:SendSpectator(sender, "SPEC_NO:" .. why) end
    if not InRealGame() or Key(sender) == Key(E.opponent) then return Refuse("over") end
    if tonumber(format) ~= FORMAT then return Refuse("version") end
    local key = Key(sender)
    local returning = spectators[key] ~= nil   -- (came back without saying they'd left)
    if not returning then
        -- (a tournament's organizer may always watch its games: Events\Player.lua)
        if not AllowingRequests() and not (S.EventAllows and S.EventAllows(sender)) then return Refuse("off") end
        if CountSpectators() >= MAX_SPECTATORS then return Refuse("full") end
    end
    local queued = {}
    for i, ev in ipairs(recentLog) do queued[i] = ev end
    -- A new session numbers its batches from 1: nothing of an old one may still go out
    Net:DropQueuedSpectatorParts(sender)
    spectators[key] = { name = sender, sent = {}, fresh = true, batch = 0, events = queued,
        heard = GetTime(), lastSend = 0 }
    Net:SendSpectator(sender, "SPEC_OK")
    if not returning then E:Log(L("spec.joinedLog", sender), "SYSTEM") end
    S:UpdateTab()
end

-- =========================================================================
-- THE VIEWER
-- =========================================================================
local V = { perms = {}, data = {}, parts = {}, ready = {} }
S._viewer, S._spectators = V, spectators   -- (read only, by the headless tests' reports)
local games = {}   -- [pair key] = { a, b, turn, seen, seats = { [name] = true } }

local bar = CreateFrame("Frame", nil, B, BackdropTemplateMixin and "BackdropTemplate" or nil)
bar:SetSize(440, 30)
bar:SetPoint("BOTTOM", B, "TOP", 0, 4)   -- above the board, clear of the health bar
bar:SetClampedToScreen(true)             -- a board filling the screen would push it off the top
bar:SetFrameLevel(B:GetFrameLevel() + 120)
if bar.SetBackdrop then
    bar:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    bar:SetBackdropColor(0, 0, 0, 0.75)
    bar:SetBackdropBorderColor(0.6, 0.5, 0.2, 0.9)
end
bar.text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
bar.text:SetPoint("LEFT", 12, 0)
bar.text:SetPoint("RIGHT", -84, 0)
bar.text:SetJustifyH("LEFT")
bar.text:SetWordWrap(false)
bar.leave = CreateFrame("Button", nil, bar, "UIPanelButtonTemplate")
bar.leave:SetSize(70, 20)
bar.leave:SetPoint("RIGHT", -6, 0)
bar.leave:SetScript("OnClick", function() S:StopViewing() end)
bar:Hide()

-- A viewer plays no part: nothing the board can call may touch its state
local GATED = { "PlayCard", "TapCard", "ResolveTarget", "CancelTargeting", "ClickOpponentCard", "ClearBlocks",
    "EndTurn", "NextPhase", "RequestUndo", "ConfirmMulligan", "Mulligan", "ConfirmConcede", "ConcedeMatch",
    "AutoPassBlocksSoon", "EndMatch", "WinMatch", "LoseMatch", "AITakeTurn", "OnRemoteEndTurn", "ActivateAbility",
    "CommitAttacksAndEndTurn", "ToggleEndAfterCombat" }
for _, name in ipairs(GATED) do
    local orig = E[name]
    if type(orig) == "function" then
        E[name] = function(self, ...)
            if self.viewing then return end
            return orig(self, ...)
        end
    end
end

do
    local orig = E.StartMatch
    E.StartMatch = function(self, ...)
        if self.viewing then S:StopViewing() end
        return orig(self, ...)
    end

    local origDisplay = B.UpdateDisplay
    B.UpdateDisplay = function(self, ...)
        origDisplay(self, ...)
        if not E.viewing then return end
        self.endTurnBtn:Disable()
        self.nextPhaseBtn:Disable()
        self.undoBtn:Disable()
        self.mulliganBtn:Hide()
    end

    -- Click-only controls: no card can be picked up
    local origControls = TTS.CardControls
    TTS.CardControls = function(...)
        if E.viewing then return "click" end
        return origControls(...)
    end
end

local function EmptySide(st)
    st.life = 20
    st.mana = { W = 0, U = 0, B = 0, R = 0, G = 0, C = 0 }
    st.deck, st.hand, st.field, st.graveyard, st.dots, st.hots = {}, {}, {}, {}, {}, {}
    st.damageShield, st.handCount, st.deckCount, st.mirror = 0, 0, nil, nil
end

local function ResetEngineSeat()
    E.opponent, E.encounter, E.turn, E.remoteTurns = nil, nil, 1, 0
    E.targeting, E.blockingState, E.pendingDiscard, E.choiceQueue, E.endAfterCombat = nil, nil, nil, nil, nil
    E.lastPlayed, E.lastCombat, E.lastEffect, E.effectCapture = nil, nil, nil, nil
    E.mulliganOpen, E.awaitingDeckPick, E.aiTurnToken = false, nil, nil
    E.stolenCreatures, E.localFoils, E.remoteFoils = {}, {}, {}
    EmptySide(E.localState)
    EmptySide(E.remoteState)
    E:ResetUndo()
end

local function Known(id) return id ~= nil and TTS.Cards[id] ~= nil end

local function FillIds(target, list)
    wipe(target)
    for _, id in ipairs(type(list) == "table" and list or {}) do
        if Known(id) then target[#target + 1] = id end
    end
end

local function FillCount(target, n)
    wipe(target)
    for i = 1, math.max(0, tonumber(n) or 0) do target[i] = true end
end

local function ApplySide(st, d)
    if type(d) ~= "table" then return end
    st.life = tonumber(d.l) or 0
    st.mana = { W = 0, U = 0, B = 0, R = 0, G = 0, C = 0 }
    for k, v in pairs(type(d.m) == "table" and d.m or {}) do st.mana[k] = tonumber(v) or 0 end
    st.damageShield = tonumber(d.s) or 0
    st.dots, st.hots = type(d.d) == "table" and d.d or {}, type(d.h) == "table" and d.h or {}
    st.mirror = type(d.mi) == "table" and d.mi or nil
    st.handCount = tonumber(d.hc) or 0
    FillCount(st.deck, d.dc)
    FillIds(st.graveyard, d.g)
end

local function BuildPerm(sid, raw, sounds)
    local p = V.perms[sid]
    local isNew = not p
    if isNew then p = {}; V.perms[sid] = p else wipe(p) end
    for k, v in pairs(raw) do p[PERM_NAME[k] or k] = v end
    p.damage, p.tempPower, p.tempToughness = tonumber(p.damage) or 0, tonumber(p.tempPower) or 0, tonumber(p.tempToughness) or 0
    p.tapped, p.sick = p.tapped and true or false, p.sick and true or false
    local card = TTS.Cards[p.id]
    if isNew and sounds and card and card.type == "Creature" and not card.isToken and not p.spawned then
        E:CallSound("QueueCreature", "enter", p.id)
    end
    return p
end

local function FillField(field, ids, sounds)
    wipe(field)
    for _, sid in ipairs(type(ids) == "table" and ids or {}) do
        local raw = V.data["p" .. sid]
        if type(raw) == "table" and Known(raw[PERM_KEY.id]) then
            field[#field + 1] = BuildPerm(sid, raw, sounds)
        end
    end
end

-- Puts the latest data on the engine's two sides
local function Render(sounds)
    local data, hero = V.data, TTS.Hero
    local h = data.h
    if type(h) == "table" then
        E.phase, E.isMyTurn = h.ph or "WAITING", h.my and true or false
        E.turn, E.remoteTurns = tonumber(h.tn) or 1, tonumber(h.rt) or 0
        E.endAfterCombat, E.pendingDiscard = h.ea, h.pd and 1 or nil
    end
    local m = data.m
    if type(m) == "table" and m ~= V.meta then
        V.meta = m
        E.opponent = tostring(m.op or "?")
        if hero and type(m.mh) == "table" then hero:BuildCard(hero.MY_ID, m.mh) end
        if hero and type(m.oh) == "table" then hero:BuildCard(hero.OPP_ID, m.oh) end
    end
    ApplySide(E.localState, data.L)
    ApplySide(E.remoteState, data.R)
    FillIds(E.localState.hand, data.H)
    if type(data.fo) == "table" then
        E.localFoils, E.remoteFoils = data.fo.l or {}, data.fo.r or {}
    end
    FillField(E.localState.field, data.fl, sounds)
    FillField(E.remoteState.field, data.fr, sounds)
    for sid in pairs(V.perms) do
        if data["p" .. sid] == nil then V.perms[sid] = nil end
    end

    local bs = data.bs
    if type(bs) ~= "table" then
        E.blockingState, V.bsFrom = nil, nil
    elseif bs ~= V.bsFrom then
        V.bsFrom = bs
        E.blockingState = { attackers = type(bs.a) == "table" and bs.a or {}, blocks = type(bs.b) == "table" and bs.b or {},
            isRemoteAttacking = bs.r, blocksDeclared = bs.d, attacksDone = bs.x }
    end

    E.stolenCreatures = {}
    for _, sid in ipairs(type(data.st) == "table" and data.st or {}) do
        if V.perms[sid] then table.insert(E.stolenCreatures, { perm = V.perms[sid] }) end
    end

    local wh = data.wh
    if type(wh) == "table" then
        E.lastPlayed, E.lastCombat = wh.p, wh.c
        E.lastEffect = wh.e
        if type(wh.e) == "table" then wh.e.lines = wh.e.lines or {} end
    end
end

local function RunEvent(ev)
    if type(ev) ~= "table" then return end
    local kind = ev[1]
    if kind == "L" then
        E:Log(CleanLog(ev[2]), ev[3])   -- (cleaned again: it came from another player)
    elseif kind == "S" then
        if B:IsShown() and Known(ev[2]) then
            E:ShowSpectatedSpell(ev[2], ev[3])
            E:CallDisplay("PlaySpellCastSound", TTS.Cards[ev[2]])
        end
    elseif kind == "D" then
        local p = V.perms[ev[2]]
        if p then
            B.MarkDied(p)
            E:CallSound("QueueCreature", "death", p.id, p)
        end
    elseif kind == "A" then
        if TTS.CardFX then TTS.CardFX:MarkCause(V.perms[ev[2]], "cast") end
    elseif kind == "X" and TTS.CardFX then
        for _, sid in ipairs(type(ev[2]) == "table" and ev[2] or {}) do
            TTS.CardFX:MarkCause(V.perms[sid], "strike")
            if not ev[4] then TTS.CardFX:MarkCause(V.perms[sid], "swing") end
        end
        for _, sid in ipairs(type(ev[3]) == "table" and ev[3] or {}) do
            TTS.CardFX:MarkCause(V.perms[sid], "strike")
        end
    end
end

local function SetBar(text)
    bar.text:SetText(text)
end

local function WatchingText()
    return L("spec.barWatching", V.host or "?", E.opponent or "?")
end

local function EnterBoard()
    if E.inMatch or (TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown()) then return false end
    E.viewing, E.inMatch, E.isSolo = true, true, true
    ResetEngineSeat()
    if TTS.MatchLog and TTS.MatchLog.Clear then TTS.MatchLog:Clear() end
    if B.ClearBackground then B:ClearBackground() end
    B.concedeBtn:Hide()
    bar.leave:SetText(L("spec.leave"))
    bar:Show()
    S:SelectTab(1)
    return true
end

function S:ApplyDelta(d)
    if type(d) ~= "table" then return end
    local first = false
    if d.f then
        wipe(V.data)
        wipe(V.perms)
        V.meta, V.bsFrom = nil, nil
        if not E.viewing then
            if not EnterBoard() then
                self:StopViewing()
                return
            end
            first = true
        else
            -- Everything again: a new board, so nothing animates as if it had just changed
            E.localState.field, E.remoteState.field = {}, {}
            E.localState.deck, E.remoteState.deck = {}, {}
        end
    elseif not E.viewing then
        return
    end
    for k, s in pairs(type(d.c) == "table" and d.c or {}) do
        V.data[k] = type(s) == "string" and Decode(s) or nil
    end
    for _, k in ipairs(type(d.r) == "table" and d.r or {}) do
        V.data[k] = nil
    end
    for _, ev in ipairs(type(d.e) == "table" and d.e or {}) do
        local ok, err = pcall(RunEvent, ev)
        if not ok and geterrorhandler then pcall(geterrorhandler(), err) end
    end
    local ok, err = pcall(Render, not d.f)
    if not ok and geterrorhandler then pcall(geterrorhandler(), err) end
    if not V.over then SetBar(WatchingText()) end
    if first then
        if TTS.MainFrame then TTS.MainFrame:Hide() end
        if TTS.WaitingRoom and TTS.WaitingRoom.frame then TTS.WaitingRoom.frame:Hide() end
        if B:IsShown() then E:RefreshUI() else B:Show() end
    else
        E:RefreshUI()
    end
    self:UpdateTab()
end

local function RequestSync(now)
    if now - (V.lastSync or 0) < SYNC_COOLDOWN or not V.host then return end
    V.lastSync, V.gapSince = now, nil
    Net:SendSpectator(V.host, "SPEC_SYNC")
end

-- Parts lost on the way, asked for again by number (SPEC_MISS). A spectator's parts come in
-- order, slowly (spare bandwidth only), so a part is lost once a later one is here: a hole
-- below the highest part of its delta, the rest of a delta once a later delta has begun, a
-- whole delta nothing of which came. Only the last parts of the newest delta need time to
-- tell (MISS_STALL without any). Returns true while an ask is still worth waiting on, so the
-- board isn't asked for whole (SPEC_SYNC) meanwhile.
local function AskMissing(now)
    if not (V.expected and V.newest and V.host) then return false end
    if V.newest - V.expected >= KEPT_BATCHES then return false end   -- too far behind: everything
    V.miss = V.miss or {}
    local waiting = false
    for batch = V.expected, V.newest do
        if not V.ready[batch] then
            local b = V.parts[batch]
            local later = batch < V.newest
            local list = {}
            if b then
                local upTo = (later or now - (b.last or now) >= MISS_STALL) and b.n or (b.top or 0)
                for i = 1, upTo do
                    if not b[i] then list[#list + 1] = i end
                    if #list >= 40 then break end   -- (the rest on the next ask)
                end
            end
            if (b and #list > 0) or (not b and later) then
                local m = V.miss[batch]
                if not m then m = { asked = 0, at = now - MISS_AGAIN + MISS_WAIT }; V.miss[batch] = m end
                if m.asked < MISS_TRIES then
                    waiting = true
                    if now - m.at >= MISS_AGAIN then
                        m.asked, m.at = m.asked + 1, now
                        Net:SendSpectator(V.host, "SPEC_MISS:" .. batch .. ":" .. (b and table.concat(list, ",") or "*"))
                    end
                end
            end
        end
    end
    for batch in pairs(V.miss) do
        if batch < V.expected then V.miss[batch] = nil end
    end
    return waiting
end

local function Drain()
    while V.expected and V.ready[V.expected] do
        local d = V.ready[V.expected]
        V.ready[V.expected] = nil
        V.expected = V.expected + 1
        V.gapSince = nil
        S:ApplyDelta(d)
    end
    if next(V.ready) then
        V.gapSince = V.gapSince or GetTime()
    else
        V.gapSince = nil
    end
end

local function OnPart(msg)
    local batch, i, n, data = msg:match("^SPEC_F:(%d+):(%d+):(%d+):(.*)$")
    batch, i, n = tonumber(batch), tonumber(i), tonumber(n)
    if not (batch and i and n) or n < 1 or n > MAX_PARTS or i < 1 or i > n then return end
    -- Not let in yet: these are left over from an earlier time watching this player (their
    -- SPEC_OK comes after them, in the same queue), numbered as the new parts will be
    if V.asking then return end
    V.heard = GetTime()
    if not V.newest or batch > V.newest then V.newest = batch end
    if V.expected and batch < V.expected then return end
    local b = V.parts[batch]
    if not b then b = { n = n, got = 0 }; V.parts[batch] = b end
    b.last = V.heard
    if i > (b.top or 0) then b.top = i end
    if not b[i] then b[i] = data; b.got = b.got + 1 end
    if b.got >= b.n then
        V.parts[batch] = nil
        local d = Decode(table.concat(b, "", 1, b.n))
        if type(d) ~= "table" then
            RequestSync(GetTime())
            return
        end
        if d.f then
            V.expected = batch
            wipe(V.ready)
            if V.miss then wipe(V.miss) end
            for other in pairs(V.parts) do
                if other < batch then V.parts[other] = nil end
            end
        end
        V.ready[batch] = d
        Drain()
    else
        Drain()
    end
end

-- The game finished: says how, in the middle of the board. Accepting leaves the board; until
-- then the final position stays up behind it.
StaticPopupDialogs["TTS_SPECTATE_OVER"] = {
    text = "%s\n\n%s",
    button1 = ACCEPT or "Accept",
    OnAccept = function() S:StopViewing() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
}

local END_OUTCOMES = { won = true, lost = true, conceded = true, cancelled = true }

local function ShowGameOver(outcome)
    if V.endShown then return end
    V.endShown = true
    local key = "spec.end." .. (END_OUTCOMES[outcome] and outcome or "cancelled")
    local dialog = StaticPopup_Show("TTS_SPECTATE_OVER", L("spec.end.title"), L(key, V.host or "?", E.opponent or "?"))
    if dialog and dialog.SetPoint then
        dialog:ClearAllPoints()
        dialog:SetPoint("CENTER", B:IsShown() and B or UIParent, "CENTER", 0, 0)
    end
end

function S:ViewerTick()
    local now = GetTime()
    if V.test then
        V.test.clock = V.test.clock + CAPTURE_EVERY
        local frames = V.test.frames
        local nextFrame = frames[V.test.i]
        -- Long thinking is cut short: a test should play straight through
        if nextFrame and (nextFrame.t or 0) * 0.1 - V.test.clock > 2 then V.test.clock = (nextFrame.t or 0) * 0.1 - 2 end
        while frames[V.test.i] and (frames[V.test.i].t or 0) * 0.1 <= V.test.clock do
            self:ApplyDelta(frames[V.test.i])
            V.test.i = V.test.i + 1
        end
        if not frames[V.test.i] and not V.over then
            V.over = true
            SetBar(L("spec.barOver", V.host or "?", "-"))
            ShowGameOver(V.test.outcome)
        end
        return
    end
    if not V.host then return end
    -- Asked and never answered, or let in and nothing ever came: give up and say so
    if (V.asking and now - V.asking > REQUEST_TIMEOUT)
        or (not V.asking and not E.viewing and now - (V.heard or now) > SPECTATOR_TIMEOUT) then
        Print(L("spec.noReply", V.host))
        Net:SendSpectator(V.host, "SPEC_LEAVE")
        V.host, V.asking, V.heard = nil, nil, nil
        wipe(V.parts); wipe(V.ready)
        if TTS.WaitingRoom and TTS.WaitingRoom.frame:IsShown() then TTS.WaitingRoom:UpdateUI() end
        return
    end
    if V.asking or V.over then return end
    if now - (V.lastPing or 0) >= KEEPALIVE then
        V.lastPing = now
        Net:SendSpectator(V.host, "SPEC_PING")
    end
    -- Lost parts asked for by number first; the whole board only if that doesn't work
    local mending = AskMissing(now)
    if not mending and ((V.gapSince and now - V.gapSince > GAP_WAIT)
        or (next(V.parts) and now - (V.heard or now) > PART_STALL)) then
        RequestSync(now)
    end
    if E.viewing and now - (V.heard or now) > SPECTATOR_TIMEOUT then
        V.over = true
        SetBar(L("spec.barLost", V.host))
    end
end

-- Asks to watch name's game
function S:Watch(name)
    if not name or V.host or E.inMatch or (TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown())
        or (TTS.DeckPicker and TTS.DeckPicker:IsPending()) then
        Print(L("spec.errBusy"))
        return
    end
    if TTS.WaitingRoom and TTS.WaitingRoom.isQueued then
        Print(L("spec.errQueued"))
        return
    end
    V.host, V.asking, V.over = name, GetTime(), nil
    Net:SendSpectator(name, "SPEC_REQ:" .. FORMAT)
    Print(L("spec.requestSent", name))
    if TTS.WaitingRoom and TTS.WaitingRoom.frame:IsShown() then TTS.WaitingRoom:UpdateUI() end
end

-- The name a request is waiting on, or nil
function S:IsAsking()
    return V.asking and V.host or nil
end

function S:GetGames()
    local now, list = time(), {}
    for key, g in pairs(games) do
        if now - g.seen > GAME_EXPIRY then
            games[key] = nil
        else
            local seats = {}
            for name in pairs(g.seats) do seats[#seats + 1] = name end
            table.sort(seats)
            g.host = seats[1]
            list[#list + 1] = g
        end
    end
    table.sort(list, function(a, b) return a.seen > b.seen end)
    return list
end

function S:StopViewing()
    local host, wasTest = V.host, V.test
    if host and not wasTest then Net:SendSpectator(host, "SPEC_LEAVE") end
    V.host, V.asking, V.test, V.over, V.expected, V.gapSince, V.heard, V.lastPing, V.lastSync = nil, nil, nil, nil, nil, nil, nil, nil, nil
    wipe(V.parts); wipe(V.ready); wipe(V.data); wipe(V.perms)
    V.meta, V.bsFrom, V.newest, V.miss = nil, nil, nil, nil
    if V.endShown then
        V.endShown = nil
        StaticPopup_Hide("TTS_SPECTATE_OVER")   -- (left with the bar's button instead)
    end
    if not E.viewing then return end
    E.viewing, E.inMatch, E.isSolo = nil, false, false
    ResetEngineSeat()
    if TTS.Hero then TTS.Hero:RebuildMine() end
    bar:Hide()
    B.concedeBtn:Show()
    E:CloseMatchBoard()
    self:UpdateTab()
end

function S:OnMessage(cmd, msg, parts, sender)
    local key = Key(sender)
    -- Asked of the player
    if cmd == "SPEC_REQ" then
        OnRequest(sender, parts[2])
    elseif cmd == "SPEC_LEAVE" then
        local s = spectators[key]
        if s then
            spectators[key] = nil
            Net:DropQueuedSpectatorParts(s.name)
            E:Log(L("spec.leftLog", s.name), "SYSTEM")
            self:UpdateTab()
        end
    elseif cmd == "SPEC_PING" then
        if spectators[key] then spectators[key].heard = GetTime() end
    elseif cmd == "SPEC_SYNC" then
        local s = spectators[key]
        if s then s.heard, s.sent, s.fresh = GetTime(), {}, true end
    elseif cmd == "SPEC_MISS" then
        -- SPEC_MISS:<batch>:<i,j,...|*>: those parts again, if we still have them (otherwise
        -- the spectator asks for everything soon after)
        local s = spectators[key]
        local batch, list = msg:match("^SPEC_MISS:(%d+):([%d,%*]+)$")
        local parts = s and s.kept and s.kept[tonumber(batch)]
        if parts then
            s.heard = GetTime()
            local want = {}
            if list == "*" then
                for i = 1, #parts do want[#want + 1] = i end
            else
                for i in list:gmatch("%d+") do
                    i = tonumber(i)
                    if i and parts[i] then want[#want + 1] = i end
                end
            end
            for _, i in ipairs(want) do
                Net:SendSpectator(s.name, string.format("SPEC_F:%d:%d:%d:%s", tonumber(batch), i, #parts, parts[i]))
            end
        end
    -- Anyone's game
    elseif cmd == "SPEC_GAME" then
        local turn, opp = msg:match("^SPEC_GAME:(%d+):(.+)$")
        if not turn then return end
        local a, b = sender, Net.CharName(opp)
        local pair = (Key(a) < Key(b)) and (Key(a) .. "|" .. Key(b)) or (Key(b) .. "|" .. Key(a))
        local g = games[pair]
        if not g then g = { a = a, b = b, seats = {} }; games[pair] = g end
        g.seats[a], g.turn, g.seen = true, tonumber(turn) or 1, time()
        local W = TTS.WaitingRoom
        if W and W.frame and W.frame:IsShown() then W:UpdateUI() end
    -- From the player we're watching (or asked to)
    elseif V.host and key == Key(V.host) then
        if cmd == "SPEC_OK" then
            if V.asking then
                V.asking, V.heard = nil, GetTime()
                Print(L("spec.accepted", V.host))
            end
        elseif cmd == "SPEC_NO" then
            local reason = (parts[2] or ""):match("^%a+$") or "over"
            Print(L("spec.no." .. reason, V.host))
            if E.viewing then
                self:StopViewing()
            else
                V.host, V.asking = nil, nil
                local W = TTS.WaitingRoom
                if W and W.frame and W.frame:IsShown() then W:UpdateUI() end
            end
        elseif cmd == "SPEC_F" then
            OnPart(msg)
        elseif cmd == "SPEC_END" then
            V.over = true
            local outcome = (parts[2] or ""):match("^%a+$") or "cancelled"
            SetBar(L("spec.barOver", V.host, L("outcome." .. outcome)))
            ShowGameOver(outcome)
        end
    end
end

-- /fccgspectest: the last game played on this client, through the spectator's board. Needs
-- no second player. (The start of what a replay will be.)
SLASH_FCCGSPECTEST1 = "/fccgspectest"
SlashCmdList["FCCGSPECTEST"] = function()
    local game = R.lastGame
    if not game or #game.frames == 0 then
        Print(L("spec.errNoTest"))
        return
    end
    if E.inMatch or V.host then
        Print(L("spec.errBusy"))
        return
    end
    local frames = {}
    for i, s in ipairs(game.frames) do frames[i] = Decode(s) or {} end
    V.host = MyName()
    V.test = { frames = frames, i = 1, clock = 0, outcome = game.outcome }
end

-- =========================================================================
-- THE SPECTATORS TAB (beside the game log)
-- =========================================================================
local ROWS = 10
local tab = 1
local sideLog, logPanel = B.sideLog, B.logPanel
local logMsg, clearBtn, bottomBtn = B.logParts[2], B.logParts[3], B.logParts[4]

local function NewTab(index, x)
    local t = CreateFrame("Button", nil, sideLog, "UIPanelButtonTemplate")
    t:SetSize(108, 20)
    t:SetPoint("BOTTOMLEFT", logPanel, "TOPLEFT", x, 1)
    t:SetScript("OnClick", function() S:SelectTab(index) end)
    table.insert(B.logParts, t)
    return t
end
local logTab = NewTab(1, 0)
local specTab = NewTab(2, 114)

local panel = CreateFrame("Frame", nil, sideLog)
panel:SetPoint("TOPLEFT", logPanel, "TOPLEFT", 8, -8)
panel:SetPoint("BOTTOMRIGHT", logPanel, "BOTTOMRIGHT", -8, 8)
panel:Hide()

local allow = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
allow:SetSize(22, 22)
allow:SetPoint("TOPLEFT", 0, 0)
allow.label = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
allow.label:SetPoint("LEFT", allow, "RIGHT", 2, 0)
allow:SetScript("OnClick", function(self)
    if TTS.Options then TTS.Options:Set("allowSpectators", self:GetChecked() and true or false) end
end)

local empty = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
empty:SetPoint("TOPLEFT", 4, -32)
empty:SetPoint("TOPRIGHT", -4, -32)
empty:SetJustifyH("LEFT")

local rows = {}
for i = 1, ROWS do
    local text = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT", 4, -30 - (i - 1) * 20)
    text:SetPoint("TOPRIGHT", -4, -30 - (i - 1) * 20)
    text:SetJustifyH("LEFT")
    text:SetWordWrap(false)
    text:Hide()
    rows[i] = text
end

function S:SelectTab(index)
    tab = index
    self:UpdateTab()
end

local function ApplyTabVisibility()
    local folded = TTS.Options and TTS.Options:Get("gameLogFolded")
    local onLog = tab == 1 and not folded
    logMsg:SetShown(onLog)
    clearBtn:SetShown(onLog)
    bottomBtn:SetShown(onLog)
    panel:SetShown(tab == 2 and not folded)
    logTab:SetEnabled(tab ~= 1)
    specTab:SetEnabled(tab ~= 2)
end

function S:UpdateTab()
    -- A spectator sees the list the player's client sent
    local names = E.viewing and type(V.data.sp) == "table" and V.data.sp or SpectatorNames()
    logTab:SetText(L("spec.tabLog"))
    specTab:SetText(L("spec.tabSpectators", #names))
    ApplyTabVisibility()

    -- Locked once someone is watching: it can't be used to drop them
    local locked = #names > 0
    allow:SetShown(not E.viewing)
    allow.label:SetShown(not E.viewing)
    allow.label:SetText(L("spec.spectatable"))
    allow.label:SetFontObject(locked and GameFontDisableSmall or GameFontHighlightSmall)
    allow:SetChecked(AllowingRequests())
    allow:SetEnabled(not locked)

    for i, text in ipairs(rows) do
        text:SetText(names[i] and tostring(names[i]) or "")
        text:SetShown(names[i] ~= nil)
    end
    empty:SetText(#names == 0 and L("spec.none") or "")
end

hooksecurefunc(sideLog, "SetFolded", ApplyTabVisibility)
-- (when the panel first shows: saved options don't exist yet while this file loads)
sideLog:HookScript("OnShow", function() S:UpdateTab() end)
