--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
local E = TTS.Engine

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
    return card and card.name or cardId or "card"
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
    if self.undo and not self.undo.pending then self.undo = nil end
end

-- Whether the undo button can be used now. Returns ok, reason (reason when not ok).
function E:CanUndo()
    local u = self.undo
    if not self.inMatch then return false, "No match in progress." end
    if not self.isMyTurn then return false, "Only on your turn." end
    if not u then return false, "No card to take back. Undo takes back the last card you played this phase." end
    if u.pending then return false, string.format("Waiting for %s to answer...", self.opponent or "your opponent") end
    if u.denied then return false, string.format("%s denied undoing %s.", self.opponent or "Your opponent", CardName(u.cardId)) end
    if u.revealed then return false, string.format("%s drew a card, so it cannot be undone.", CardName(u.cardId)) end
    if self.phase ~= u.phase then return false, "You cannot go back phases." end
    if self.targeting then return false, "Finish or cancel targeting first." end
    if self.pendingDiscard then return false, "Discard a card first." end
    if self.blockingState then return false, "Not during combat." end
    return true
end

-- Name of the card the undo button would take back
function E:UndoCardName()
    return self.undo and CardName(self.undo.cardId)
end

-- True (and says so) while our undo request waits for the opponent: the board is frozen
function E:UndoBlocksAction()
    if self.undo and self.undo.pending then
        self:Log(string.format("Waiting for %s to answer your undo request.", self.opponent or "your opponent"), "ERROR")
        return true
    end
    return false
end

local function ApplyLocalUndo(self)
    local u = self.undo
    self.undo = nil
    RestoreSnapshot(self, u.snap)
    self:Log(string.format("Undid |cFFFFD200%s|r: it is back in your hand.", CardName(u.cardId)), "SYSTEM")
    self:SyncEffects()
    self:RefreshUI()
end

function E:RequestUndo()
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
    self:Log(string.format("Asked %s to let you undo |cFFFFD200%s|r...", self.opponent, CardName(u.cardId)), "SYSTEM")
    self:RefreshUI()

    -- No answer at all (e.g. the opponent went offline): count it as denied
    TTS:SafeAfter(UNDO_REPLY_TIMEOUT, function()
        if E.undo == u and u.pending then
            u.pending = false
            u.denied = true
            E:Log(string.format("%s did not answer the undo request.", E.opponent or "Your opponent"), "SYSTEM")
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
        self:Log(string.format("%s accepted your undo.", self.opponent), "SYSTEM")
        ApplyLocalUndo(self)
    else
        u.denied = true
        self:Log(string.format("%s denied your undo of |cFFFFD200%s|r.", self.opponent, CardName(u.cardId)), "SYSTEM")
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
        self:Log(string.format("You allowed %s to undo their last card.", self.opponent), "SYSTEM")
        self:RefreshUI()
    else
        if self.inMatch and self.opponent then
            TTS.Net:Send(self.opponent, "ACTION:UNDO_DENY:" .. seq)
        end
        if valid then
            self:Log(string.format("You denied %s's undo request.", self.opponent), "SYSTEM")
        end
    end
end

StaticPopupDialogs["TTS_UNDO_REQUEST"] = {
    text = "%s wants to undo playing |cFFFFD200%s|r.\n\nAllow it? Your answer is final.",
    button1 = "Allow",
    button2 = "Deny",
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

function E:OnUndoRequest(seq, cardId)
    local ru = self.remoteUndo
    if not (self.inMatch and not self.isMyTurn and ru and ru.seq == seq) then
        -- Not a play we can take back on our side: refuse so they are not left waiting
        TTS.Net:Send(self.opponent, "ACTION:UNDO_DENY:" .. tostring(seq))
        return
    end
    self:Log(string.format("%s asks to undo |cFFFFD200%s|r.", self.opponent, CardName(cardId)), "SYSTEM")
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
