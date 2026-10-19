--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
local E = TTS.Engine
local L = TTS.L

-- =========================================================================
-- UNDO
-- On your turn you may take back the last card you played (one card, never more).
-- The whole board is saved just before each card is played and put back on undo,
-- so every effect the card had is reverted with it.
--   - Only in the phase the card was played in: you cannot go back phases.
--   - Not once the play drew you a card (that would let you peek at your deck).
--   - Activating an ability after the play locks it in.
-- In PvP both clients save their own copy of the board for the same play: the
-- player asks with ACTION:UNDO_REQUEST:<seq>:<cardId> and the opponent answers
-- ACTION:UNDO_ACCEPT:<seq> or ACTION:UNDO_DENY:<seq>. Their answer is final.
-- <seq> counts the cards played this turn, so both sides know which play is meant.
-- =========================================================================

-- Seconds the opponent has to answer the undo popup (no answer = denied)
local UNDO_POPUP_TIMEOUT = 30
-- Seconds the asking player waits before giving up on an answer that never comes
local UNDO_REPLY_TIMEOUT = 60

-- Engine fields that a card play can change, saved along with both sides' state
local ENGINE_KEYS = { "landPlayedThisTurn", "preventCombatDamage", "cantBlockThisTurn",
    "remoteLandPlayed", "bossIndex", "opponent" }

-- Copies tables all the way down. One `seen` table per snapshot keeps shared
-- references shared (a stolen creature is in both stolenCreatures and a field).
local function DeepCopy(v, seen)
    if type(v) ~= "table" then return v end
    if seen[v] then return seen[v] end
    local copy = {}
    seen[v] = copy
    for k, val in pairs(v) do
        copy[DeepCopy(k, seen)] = DeepCopy(val, seen)
    end
    return copy
end

local function TakeSnapshot(self)
    local seen = {}
    local snap = {
        localState     = DeepCopy(self.localState, seen),
        remoteState    = DeepCopy(self.remoteState, seen),
        stolenCreatures = DeepCopy(self.stolenCreatures, seen),
        engine         = {},
    }
    for _, k in ipairs(ENGINE_KEYS) do snap.engine[k] = self[k] end
    return snap
end

-- State tables are refilled in place, since other code may hold on to them
local function Refill(target, source)
    wipe(target)
    for k, v in pairs(source) do target[k] = v end
end

local function RestoreSnapshot(self, snap)
    local seen = {}
    Refill(self.localState, DeepCopy(snap.localState, seen))
    Refill(self.remoteState, DeepCopy(snap.remoteState, seen))
    self.stolenCreatures = DeepCopy(snap.stolenCreatures, seen)
    for _, k in ipairs(ENGINE_KEYS) do self[k] = snap.engine[k] end
    self.targeting = nil
    self.blockingState = nil
end

local function CardName(cardId)
    local card = TTS.Cards[cardId]
    return card and TTS:CardName(card) or cardId or L("side.card")
end

-- Called by every new match
function E:ResetUndo()
    self.undo = nil
    self.remoteUndo = nil
    self.playsThisTurn = 0
    self.remotePlaysThisTurn = 0
end

-- =========================================================================
-- LOCAL PLAYS
-- PlayCard / ResolveTarget call BeginUndoablePlay before the card touches the
-- board and CommitUndoablePlay once it has resolved.
-- =========================================================================
function E:BeginUndoablePlay()
    self:CloseMulligan()   -- the opening hand is kept once a card is played
    return TakeSnapshot(self)
end

function E:CommitUndoablePlay(snap, cardId)
    self.playsThisTurn = (self.playsThisTurn or 0) + 1
    self.undo = {
        snap = snap,
        cardId = cardId,
        phase = self.phase,
        seq = self.playsThisTurn,
        -- Drawing a card shows you the top of your deck: no taking that back
        revealed = (#self.localState.deck ~= #snap.localState.deck) or (self.pendingDiscard ~= nil),
    }
end

-- Anything that cannot be taken back (abilities, a new phase, the end of the turn)
function E:LockInPlays()
    self:CloseMulligan()
    if self.undo and not self.undo.pending then self.undo = nil end
end

-- =========================================================================
-- TAKING BACK COMBAT
-- Combat that has started (To Combat, or a denizen dragged at the opponent) but whose
-- attacks aren't committed yet: Undo goes back to Main 1 and takes back any attackers
-- picked. Nothing has reached the opponent yet (ATTACK messages go out on Commit to
-- Attacks), so it needs no agreement. Back in Main 1, a card played there can be taken
-- back again as usual.
-- =========================================================================
function E:CanUndoCombat()
    local bs = self.blockingState
    return self.inMatch and self.isMyTurn and self.phase == "COMBAT_ATTACK" and bs ~= nil
        and not bs.isRemoteAttacking and not self.targeting and not self.pendingDiscard
        and not self:HasPendingChoice() and not (self.undo and self.undo.pending)
end

function E:UndoCombat()
    if not self:CanUndoCombat() then return end
    local bs = self.blockingState
    for _, idx in ipairs(bs.attackers or {}) do
        local perm = self.localState.field[idx]
        if perm and perm.isAttacking then
            local undo = perm.attackUndo or {}
            perm.isAttacking = nil
            perm.tapped = undo.tapped
            perm.hasAttackedThisTurn = undo.hasAttacked
            perm.attackUndo = nil
        end
    end
    self.blockingState = nil
    self.endAfterCombat = nil
    self:SetPhase("MAIN1")
    self:Log(L("undo.combatDone"), "SYSTEM")
    self:RefreshUI()
end

-- Whether the undo button can be used now. Returns ok, reason (reason when not ok).
function E:CanUndo()
    local u = self.undo
    if self:CanUndoCombat() then return true end
    if not self.inMatch then return false, L("undo.noMatch") end
    if not self.isMyTurn then return false, L("undo.notYourTurn") end
    if not u then return false, L("undo.nothing") end
    if u.pending then return false, L("undo.waiting", self.opponent or L("undo.yourOpponent")) end
    if u.denied then return false, L("undo.denied", self.opponent or L("undo.yourOpponentCap"), CardName(u.cardId)) end
    if u.revealed then return false, L("undo.revealed", CardName(u.cardId)) end
    if self.phase ~= u.phase then return false, L("undo.phase") end
    if self.targeting then return false, L("undo.targeting") end
    if self.pendingDiscard then return false, L("undo.discard") end
    if self:HasPendingChoice() then return false, L("undo.choice") end
    if self.blockingState then return false, L("undo.combat") end
    return true
end

-- Name of the card the undo button would take back
function E:UndoCardName()
    return self.undo and CardName(self.undo.cardId)
end

-- True (and says so) while our undo request waits for the opponent: the board is frozen
function E:UndoBlocksAction()
    if self.undo and self.undo.pending then
        self:Log(L("undo.waitingAnswer", self.opponent or L("undo.yourOpponent")), "ERROR")
        return true
    end
    return false
end

local function ApplyLocalUndo(self)
    local u = self.undo
    self.undo = nil
    RestoreSnapshot(self, u.snap)
    self:Log(L("undo.done", CardName(u.cardId)), "SYSTEM")
    self:SyncEffects()
    self:RefreshUI()
end

function E:RequestUndo()
    if self:CanUndoCombat() then
        self:UndoCombat()
        return
    end
    local ok, reason = self:CanUndo()
    if not ok then
        if reason then self:Log(reason, "ERROR") end
        return
    end
    local u = self.undo

    if self.isSolo then
        ApplyLocalUndo(self)
        return
    end

    u.pending = true
    TTS.Net:Send(self.opponent, string.format("ACTION:UNDO_REQUEST:%d:%s", u.seq, u.cardId))
    self:Log(L("undo.asked", self.opponent, CardName(u.cardId)), "SYSTEM")
    self:RefreshUI()

    -- No answer at all (e.g. the opponent went offline): count it as denied
    TTS:SafeAfter(UNDO_REPLY_TIMEOUT, function()
        if E.undo == u and u.pending then
            u.pending = false
            u.denied = true
            E:Log(L("undo.noAnswer", E.opponent or L("undo.yourOpponentCap")), "SYSTEM")
            E:RefreshUI()
        end
    end)
end

-- The opponent's answer to our request
function E:OnUndoAnswer(seq, accepted)
    local u = self.undo
    if not (u and u.pending and u.seq == seq) then return end
    u.pending = false
    if accepted and self.inMatch then
        self:Log(L("undo.accepted", self.opponent), "SYSTEM")
        ApplyLocalUndo(self)
    else
        u.denied = true
        self:Log(L("undo.deniedYours", self.opponent, CardName(u.cardId)), "SYSTEM")
        self:RefreshUI()
    end
end

-- =========================================================================
-- OPPONENT PLAYS (PvP)
-- Network.lua calls OnRemotePlay as a PLAY_LAND / PLAY_PERM / CAST_SPELL arrives,
-- before applying it, so this client can put its board back the same way.
-- =========================================================================
function E:OnRemotePlay()
    self.remotePlaysThisTurn = (self.remotePlaysThisTurn or 0) + 1
    self.remoteUndo = { snap = TakeSnapshot(self), seq = self.remotePlaysThisTurn }
end

-- A new turn for us: the opponent's last play is final
function E:OnLocalTurnStart()
    self.remoteUndo = nil
    self.remotePlaysThisTurn = 0
    self.playsThisTurn = 0
    self.undo = nil
end

local function AnswerUndo(seq, accepted)
    local self = E
    local ru = self.remoteUndo
    local valid = self.inMatch and not self.isSolo and not self.isMyTurn and ru and ru.seq == seq
    if accepted and valid then
        self.remoteUndo = nil
        RestoreSnapshot(self, ru.snap)
        TTS.Net:Send(self.opponent, "ACTION:UNDO_ACCEPT:" .. seq)
        self:Log(L("undo.allowed", self.opponent), "SYSTEM")
        self:RefreshUI()
    else
        if self.inMatch and self.opponent then
            TTS.Net:Send(self.opponent, "ACTION:UNDO_DENY:" .. seq)
        end
        if valid then
            self:Log(L("undo.youDenied", self.opponent), "SYSTEM")
        end
    end
end

StaticPopupDialogs["TTS_UNDO_REQUEST"] = {
    text = L("undo.popup"),
    button1 = L("undo.allow"),
    button2 = L("undo.deny"),
    OnAccept = function(self, data)
        if data.answered then return end
        data.answered = true
        AnswerUndo(data.seq, true)
    end,
    OnCancel = function(self, data)
        if data.answered then return end
        data.answered = true
        AnswerUndo(data.seq, false)
    end,
    -- Closed any other way (another popup took its place): that is a no
    OnHide = function(self)
        local data = self.data
        if data and not data.answered then
            data.answered = true
            AnswerUndo(data.seq, false)
        end
    end,
    timeout = UNDO_POPUP_TIMEOUT,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
-- The popup reads these when it shows: set them again once the chosen language has loaded
TTS.Locale:OnReady(function()
    local d = StaticPopupDialogs["TTS_UNDO_REQUEST"]
    d.text, d.button1, d.button2 = L("undo.popup"), L("undo.allow"), L("undo.deny")
end)

function E:OnUndoRequest(seq, cardId)
    local ru = self.remoteUndo
    if not (self.inMatch and not self.isMyTurn and ru and ru.seq == seq) then
        -- Not a play we can take back on our side: refuse so they are not left waiting
        TTS.Net:Send(self.opponent, "ACTION:UNDO_DENY:" .. tostring(seq))
        return
    end
    self:Log(L("undo.asks", self.opponent, CardName(cardId)), "SYSTEM")
    StaticPopup_Show("TTS_UNDO_REQUEST", self.opponent, CardName(cardId), { seq = seq })
end

-- =========================================================================
-- DECK SIZE (PvP)
-- Each client tells the other how many cards are left in its deck whenever the
-- number changes: ACTION:DECK:<count>:<1 = please send me yours>.
-- =========================================================================
function E:SyncDeckCount(force)
    if self.isSolo or not self.inMatch or self.startingMatch or not self.opponent then return end
    local n = #self.localState.deck
    if not force and self.sentDeckCount == n then return end
    self.sentDeckCount = n
    TTS.Net:Send(self.opponent, string.format("ACTION:DECK:%d:%d", n, self.remoteState.deckCount and 0 or 1))
end

function E:OnRemoteDeckCount(n, wantsOurs)
    self.remoteState.deckCount = n
    if wantsOurs then self:SyncDeckCount(true) end
    self:RefreshUI()
end

-- Cards left in the opponent's deck, or nil while it is not known yet
function E:RemoteDeckCount()
    if self.isSolo then return #self.remoteState.deck end
    return self.remoteState.deckCount
end
