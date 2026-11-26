--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
local L = TTS.L

-- =========================================================================
-- RESUMING A GAME AFTER A /RELOAD
-- A game lives in memory, so a /reload (or logging out) mid-game used to end it. Now, as
-- the UI goes away (PLAYER_LOGOUT, which a /reload fires too), the game in progress is
-- written to TTS_Resume (per character): both sides' state, the engine's match fields,
-- the seeded random's place, both hero cards, and for PvP the network's match numbering
-- (Core\Network.lua SEQUENCED MATCH MESSAGES: the match id, the numbers sent and received
-- so far, and the last messages sent, kept to be sent again).
-- At login a popup offers to resume it (or abandon it). Resuming puts it all back and shows
-- the board. PvP: an "are you still there?" goes to the opponent carrying our last number,
-- and their answer carries theirs, so whatever either side missed during the reload is
-- asked for again and played through in order; they're also told we're back
-- (ACTION:RESUMED, only logged). A solo game whose AI was mid-turn carries on with it.
-- Abandoning a PvP game settles it as a left game (Systems\PvPRecord.lua: a loss, and the
-- opponent is told); a solo one is just dropped.
-- A saved PvP game is only offered for PVP_MAX_AGE seconds (the opponent won't wait
-- longer), a solo one for SOLO_MAX_AGE. What can't be saved is left out: an open choice,
-- targeting, an undo in progress; the board carries on without them.
-- /tragic resume brings the popup back if it was closed.
-- =========================================================================
local R = {}
TTS.Resume = R

local VERSION = 1
local PVP_MAX_AGE = 10 * 60
local SOLO_MAX_AGE = 24 * 60 * 60

-- The engine's match fields that are saved (both sides' state is saved on its own)
local ENGINE_FIELDS = {
    "opponent", "opponentScore", "opponentPvP", "isSolo", "isMyTurn", "turn", "phase",
    "landPlayedThisTurn", "preventCombatDamage", "cantBlockThisTurn", "blockingState",
    "pendingDiscard", "endAfterCombat", "mulliganOpen", "stolenCreatures", "remoteTurns",
    "remoteLandPlayed", "matchReward", "bossIndex", "remoteStartLife", "lastPlayed",
    "lastCombat", "lastEffect", "localFoils", "remoteFoils", "playsThisTurn",
    "remotePlaysThisTurn", "uidCounter", "sentDeckCount", "attackDeclarationId",
    "lastAttackDeclaration",
}
-- The network's match numbering (PvP)
local NET_FIELDS = { "matchId", "theirVersion", "seqOn", "sendSeq", "sentLog", "recvSeq", "theirLastSeq" }

-- A copy that SavedVariables can hold: no functions, no frames (userdata)
local function Plain(v, seen)
    local t = type(v)
    if t == "function" or t == "userdata" or t == "thread" then return nil end
    if t ~= "table" then return v end
    if v[0] ~= nil and type(v[0]) == "userdata" then return nil end   -- a frame
    seen = seen or {}
    if seen[v] then return seen[v] end
    local copy = {}
    seen[v] = copy
    for k, val in pairs(v) do
        local ck = Plain(k, seen)
        if ck ~= nil then copy[ck] = Plain(val, seen) end
    end
    return copy
end

local function Saved()
    return type(TTS_Resume) == "table" and TTS_Resume.v == VERSION and TTS_Resume or nil
end

-- Whether the saved game is still worth offering (its age, and that it's this character's)
local function Fresh(s)
    if not s then return false end
    local age = time() - (tonumber(s.at) or 0)
    return age >= 0 and age <= (s.engine and s.engine.isSolo and SOLO_MAX_AGE or PVP_MAX_AGE)
end

-- A saved PvP game for this match id is waiting to be offered (Systems\PvPRecord.lua holds
-- off settling it as a loss meanwhile)
function R:HasPvPGame(matchId)
    local s = Saved()
    return Fresh(s) and not s.engine.isSolo and s.net and tostring(s.net.matchId) == tostring(matchId) or false
end

function R:Clear()
    TTS_Resume = nil
end

-- =========================================================================
-- SAVING (as the UI goes away)
-- =========================================================================
function R:Save()
    local E = TTS.Engine
    if not (E and E.inMatch) or E.viewing or E.awaitingDeckPick then return end
    local enc = E.encounter
    -- The tutorial is scripted step by step: it starts again rather than resuming
    if enc and (enc.id == "TUTORIAL" or enc.kind == "tutorial") then return end
    local seen = {}
    local s = {
        v = VERSION, at = time(), addon = TTS.VERSION,
        localState = Plain(E.localState, seen),
        remoteState = Plain(E.remoteState, seen),
        engine = {},
        rng = E.rng and E.rng("state") or nil,
    }
    for _, k in ipairs(ENGINE_FIELDS) do s.engine[k] = Plain(E[k], seen) end
    if enc then
        -- A fixed encounter by its id (its own table comes back from TTS.SoloEncounters); a
        -- built one (the Daily, an Endless fight) as itself
        s.encounterId = enc.id
        if not (TTS.SoloEncounters and TTS.SoloEncounters[enc.id] == enc) then s.encounter = Plain(enc) end
    end
    local H = TTS.Hero
    if H and TTS.Cards then
        s.hero = {
            mine = TTS.Cards[H.MY_ID] and Plain(TTS.Cards[H.MY_ID].heroInfo),
            opp = TTS.Cards[H.OPP_ID] and Plain(TTS.Cards[H.OPP_ID].heroInfo),
        }
    end
    if not E.isSolo and TTS.Net then
        s.net = {}
        for _, k in ipairs(NET_FIELDS) do s.net[k] = Plain(TTS.Net[k]) end
        -- Anything still waiting in their order goes again if they ask (it's in sentLog)
    end
    TTS_Resume = s
end

-- =========================================================================
-- RESTORING
-- =========================================================================
-- SavedVariables don't keep two references to one table: each saved copy is its own. A
-- permanent stays the same table wherever it's listed (stolenCreatures, the blocking state,
-- What Just Happened), so every copy with a perm's uid is swapped for the one on its field.
local function Relink(v, byUid, seen)
    if type(v) ~= "table" or seen[v] then return v end
    seen[v] = true
    for k, val in pairs(v) do
        if type(val) == "table" then
            if val.uid and byUid[val.uid] and val ~= byUid[val.uid] and val.id == byUid[val.uid].id then
                v[k] = byUid[val.uid]
            else
                Relink(val, byUid, seen)
            end
        end
    end
    return v
end

-- State tables are refilled in place, since other code holds on to them
local function Refill(target, source)
    if type(target) ~= "table" then return source end
    wipe(target)
    for k, v in pairs(source or {}) do target[k] = v end
    return target
end

function R:Resume()
    local s = Saved()
    local E = TTS.Engine
    if not (s and E) or E.inMatch then return false end
    TTS_Resume = nil
    local enc = (s.encounterId and TTS.SoloEncounters and TTS.SoloEncounters[s.encounterId]) or s.encounter

    -- Both sides first, so the perms the engine fields point at can be linked to them
    E.localState = Refill(E.localState, s.localState)
    E.remoteState = Refill(E.remoteState, s.remoteState)
    local byUid = {}
    for _, st in ipairs({ E.localState, E.remoteState }) do
        for _, perm in ipairs(st.field or {}) do if perm.uid then byUid[perm.uid] = perm end end
    end
    for _, k in ipairs(ENGINE_FIELDS) do E[k] = s.engine[k] end
    E.stolenCreatures = E.stolenCreatures or {}
    Relink(E.stolenCreatures, byUid, {})
    Relink(E.blockingState, byUid, {})
    Relink(E.lastCombat, byUid, {})

    -- What a save can't hold starts afresh
    E.inMatch = true
    E.encounter = E.isSolo and enc or nil
    E.rng = s.rng and TTS.NewRng(s.rng) or nil
    E.targeting, E.choiceQueue, E.effectCapture, E.mirroring = nil, nil, nil, false
    E.checkingSBA, E.startingMatch, E.awaitingDeckPick, E.soundHits = false, false, nil, nil
    E.opponentHeardAt = GetTime()
    E.handRedrawn = nil
    E:ResetUndo()

    local H = TTS.Hero
    if H and s.hero then
        if s.hero.mine then H:BuildCard(H.MY_ID, s.hero.mine) end
        if s.hero.opp then H:BuildCard(H.OPP_ID, s.hero.opp) end
    end
    if not E.isSolo and TTS.Net and s.net then
        for _, k in ipairs(NET_FIELDS) do TTS.Net[k] = s.net[k] end
        TTS.Net.sentLog = TTS.Net.sentLog or {}
        TTS.Net.recvBuffer, TTS.Net.resentAt, TTS.Net.seqGapFor = {}, {}, nil
    end

    -- The board
    local B = TTS.BoardFrame
    if B then
        if E.isSolo and enc and B.SetBackground then B:SetBackground(enc.background)
        elseif B.ClearBackground then B:ClearBackground() end
        B:Show()
    end
    if TTS.MainFrame then TTS.MainFrame:Hide() end
    E:Log(L("resume.log"), "SYSTEM")
    E:RefreshUI()

    if E.isSolo then
        -- The AI's turn carries on where it can (Engine\AI.lua)
        if not E.isMyTurn and E.phase == E.AI_TURN_PHASE or (E.blockingState and E.blockingState.isRemoteAttacking) then
            TTS:SafeAfter(1, function() if E.inMatch and E.isSolo then E:AITakeTurn(true) end end)
        end
    elseif TTS.Net then
        -- Tell them, and catch up both ways on anything sent while we were gone
        TTS.Net:Send(E.opponent, "ACTION:RESUMED")
        TTS.Net:SendPing(E.opponent, "ALIVE?")
        if E.SyncDeckCount then E:SyncDeckCount(true) end
    end
    return true
end

-- The player won't resume it: a PvP game is settled as left, a solo one dropped
function R:Abandon()
    local s = Saved()
    TTS_Resume = nil
    if s and not s.engine.isSolo and TTS.PvP and TTS.PvP.SettleLeftGame then TTS.PvP:SettleLeftGame() end
end

-- =========================================================================
-- THE OFFER (at login, and /tragic resume)
-- =========================================================================
TTS.Dialog:Register("TTS_RESUME_GAME", {
    text = "%s",
    button1 = L("resume.yes"),
    button2 = L("resume.no"),
    OnAccept = function()
        if not R:Resume() then DEFAULT_CHAT_FRAME:AddMessage(L("resume.failed")) end
    end,
    OnCancel = function(_, _, reason)
        if reason == "clicked" then R:Abandon() end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
})

function R:Offer()
    local s = Saved()
    if not Fresh(s) then
        if s then self:Abandon() end
        return false
    end
    local E = TTS.Engine
    if E and E.inMatch then return false end
    local who = s.engine.opponent or "?"
    local text = s.engine.isSolo and L("resume.askSolo", who) or L("resume.askPvP", who)
    TTS.Dialog:Popup("TTS_RESUME_GAME", text)
    return true
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_LOGOUT")
f:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGOUT" then
        local ok, err = pcall(R.Save, R)
        if not ok then TTS_Resume = nil end   -- (a broken save is worse than none)
        return
    end
    -- A moment after login, once the network and the rest of the UI are up
    C_Timer.After(3, function() R:Offer() end)
    local E = TTS.Engine
    -- A game that ends leaves nothing to resume; starting a new one abandons the saved one
    -- (before the new game marks itself live, Systems\PvPRecord.lua)
    if E and E.HookDisplay then
        E:HookDisplay("EndMatch", nil, function() R:Clear() end)
        E:HookDisplay("StartMatch", function() if Saved() then R:Abandon() end end)
    end
end)
