--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
TTS.Engine = TTS.Engine or {
    inMatch = false,
    isMyTurn = false,
    isSolo = false,
    turn = 0,
    phase = "PREGAME",
    opponent = nil,
    landPlayedThisTurn = false,
    preventCombatDamage = false,
    cantBlockThisTurn = false,
    targeting = nil,
    blockingState = nil,
    stolenCreatures = {},

    localState = {
        life = 20,
        mana = { W = 0, U = 0, B = 0, R = 0, G = 0, C = 0 },
        deck = {},
        hand = {},
        field = {},
        graveyard = {},
        damageShield = 0,
        dots = {},
        hots = {}
    },

    remoteState = {
        life = 20,
        handCount = 0,
        hand = {},
        deck = {},
        mana = { W = 0, U = 0, B = 0, R = 0, G = 0, C = 0 },
        field = {},
        graveyard = {},
        damageShield = 0,
        dots = {},
        hots = {}
    }
}

local E = TTS.Engine

function TTS:SafeAfter(seconds, callback)
    if C_Timer and C_Timer.After then
        C_Timer.After(seconds, callback)
    else
        local delayFrame = CreateFrame("Frame")
        local elapsed = 0
        delayFrame:SetScript("OnUpdate", function(self, delta)
            elapsed = elapsed + delta
            if elapsed >= seconds then
                self:SetScript("OnUpdate", nil)
                callback()
            end
        end)
    end
end

function E:Log(msg, category)
    local prefix = "|cFFFFFF00[TTSE]|r "
    if category == "ACTION" then
        prefix = "|cFF00FF00[TTSE]|r "
    elseif category == "COMBAT" then
        prefix = "|cFFFF4444[TTSE]|r "
    elseif category == "MANA" then
        prefix = "|cFF66BBFF[TTSE]|r "
    elseif category == "ERROR" then
        prefix = "|cFFFF2222[TTSE]|r "
    elseif category == "SYSTEM" then
        prefix = "|cFFFFA500[TTSE]|r "
    end

    local formattedMsg = TTS.FormatSymbols and TTS:FormatSymbols(msg, 14) or msg
    local fullText = prefix .. formattedMsg

    if TTS.MatchLog and TTS.MatchLog.AddMessage then
        TTS.MatchLog:AddMessage(fullText)
    else
        DEFAULT_CHAT_FRAME:AddMessage(fullText)
    end
end

-- In CoreEngine.lua -> E:ValidateDeck()
function E:ValidateDeck()
    local deck = TTS_SavedDecks and TTS_SavedDecks[TTS_ActiveDeckIndex]
    if not deck or not deck.cards then return false end
    local count = 0
    for _, qty in pairs(deck.cards) do count = count + qty end
    return count >= 40 and count <= 50
end

-- =========================================================================
-- ATTACK ABILITY CHECK
-- =========================================================================
function E:CanCreatureAttack(perm)
    if not perm then return false end
    local card = TTS.Cards and TTS.Cards[perm.id]
    if not card or card.type ~= "Creature" then return false end

    if perm.tapped then return false end
    if perm.sick and not self:HasKeyword(perm, false, "haste") then return false end
    if card.defender then return false end

    return true
end

-- =========================================================================
-- MATCH COMPLETION & EMOTES
-- =========================================================================
function E:PlayMatchEmote(outcome, opponentName)
    local emoteText = string.format("has %s a game of Forever: CCG against %s", outcome, opponentName)
    SendChatMessage(emoteText, "EMOTE")

    -- Play the built-in emote a moment later so it does not collide with the emote text above
    local followUp = nil
    if outcome == "won" then
        followUp = "CHEER"
    elseif outcome == "lost" or outcome == "conceded" then
        followUp = "CRY"
    end
    if followUp then
        TTS:SafeAfter(0.5, function() DoEmote(followUp) end)
    end
end

-- Post-game popup: your result, then the opponent's ("Thrall wins!" / "Thrall loses!").
-- The emote is sent from the Accept click: a win often arrives as an
-- addon message, and the chat emote is blocked when no click is behind it.
local RESULT_HEADLINES = {
    won      = "|cFF00FF00You have won!|r",
    lost     = "|cFFFF4444You have lost!|r",
    conceded = "|cFFFF4444You have conceded!|r",
}
local OPPONENT_RESULT = {
    won      = "loses!",
    lost     = "wins!",
    conceded = "wins!",
}

StaticPopupDialogs["TTS_MATCH_RESULT"] = {
    text = "%s\n\n%s",
    button1 = "Accept",
    OnAccept = function(self, data)
        -- No public emote for games against the AI
        if data and not data.isSolo then E:PlayMatchEmote(data.outcome, data.opponent) end
        -- Leave the final board (unless a new match has already started on it)
        if not E.inMatch then E:CloseMatchBoard() end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
}

-- Closes the post-match board and returns to the main window
function E:CloseMatchBoard()
    if TTS.BoardFrame and TTS.BoardFrame.CloseAfterMatch then
        TTS.BoardFrame:CloseAfterMatch()
        return
    end
    if TTS.BoardFrame then TTS.BoardFrame:Hide() end
    if TTS.BoardRestoreFrame then TTS.BoardRestoreFrame:Hide() end
    if TTS.MainFrame then
        TTS.MainFrame:Show()
        if TTS.MainFrame.UpdatePlayState then
            TTS.MainFrame:UpdatePlayState()
        end
    end
end

function E:EndMatch(outcome, reason)
    if not self.inMatch then return end
    local opponentName = self.opponent or "Opponent"

    -- Draw the final board state while still in the match (the board may be minimized),
    -- then freeze it there until the result popup is accepted
    local B = TTS.BoardFrame
    if B then
        if B:IsShown() then self:RefreshUI() else B:Show() end
    end
    self.inMatch = false

    -- A solo encounter win records progress and grants the encounter's reward card
    local rewardText, rewardCard
    if outcome == "won" and self.isSolo and self.encounter then
        local rewardId, copies, wasComplete = TTS:RecordEncounterWin(self.encounter)
        rewardCard = rewardId and TTS.Cards[rewardId]
        if rewardCard then
            rewardText = string.format("\n\nReward: |cFFFFD200%s|r (%d/4 copies%s)", rewardCard.name, copies,
                wasComplete and ", collection complete" or "")
            self:Log(string.format("Reward earned: |cFFFFD200%s|r (%d/4 copies).", rewardCard.name, copies), "SYSTEM")
        end
    end

    local headline = outcome and RESULT_HEADLINES[outcome]
    if outcome and opponentName ~= "" then
        if headline then
            StaticPopup_Show("TTS_MATCH_RESULT", headline, opponentName .. " " .. OPPONENT_RESULT[outcome] .. (rewardText or ""), { outcome = outcome, opponent = opponentName, isSolo = self.isSolo })
            if rewardCard and B and B.ShowRewardCard then B:ShowRewardCard(rewardCard) end
        else
            if not self.isSolo then self:PlayMatchEmote(outcome, opponentName) end
        end
    end

    self:Log(string.format("Match ended (%s): %s", outcome:upper(), reason or ""), "SYSTEM")

    if headline and opponentName ~= "" and B and B.ShowMatchResult then
        B:ShowMatchResult(headline)
    else
        -- No result popup to accept (e.g. a cancelled setup): leave the board straight away
        self:CloseMatchBoard()
    end
end

function E:WinMatch(reason)
    self:EndMatch("won", reason or "Victory!")
end

function E:LoseMatch(reason)
    if not self.isSolo and self.opponent then
        TTS.Net:Send(self.opponent, "ACTION:DEFEATED")
    end
    self:EndMatch("lost", reason or "Defeat.")
end

function E:ConcedeMatch()
    if not self.isSolo and self.opponent then
        TTS.Net:Send(self.opponent, "ACTION:CONCEDE")
    end
    self:EndMatch("conceded", "Conceded match.")
end

-- =========================================================================
-- DAMAGE & LIFE
-- =========================================================================
function E:DamagePlayer(isRemote, amount, reason)
    if amount <= 0 then return end
    local targetState = isRemote and self.remoteState or self.localState

    if (targetState.damageShield or 0) > 0 then
        local prevented = math.min(amount, targetState.damageShield)
        targetState.damageShield = targetState.damageShield - prevented
        amount = amount - prevented
        self:Log(string.format("Shield prevented %d damage to %s.", prevented, isRemote and self.opponent or "you"), "ACTION")
        self:SyncEffects()
        if amount <= 0 then
            self:RefreshUI()
            return
        end
    end

    if isRemote then
        self.remoteState.life = self.remoteState.life - amount
        self:Log(string.format("Dealt |cFFFF2222%d damage|r to %s (%s). (Opponent Life: %d)", amount, self.opponent, reason or "Effect", self.remoteState.life), "COMBAT")
        if not self.isSolo then
            TTS.Net:Send(self.opponent, string.format("ACTION:DAMAGE:%d:%s", amount, reason or "Damage"))
        end
        if self.remoteState.life <= 0 then
            self:WinMatch("Victory! " .. self.opponent .. " was defeated.")
        end
    else
        self.localState.life = self.localState.life - amount
        self:Log(string.format("Took |cFFFF2222%d damage|r (%s). (Current Life: %d)", amount, reason or "Damage", self.localState.life), "COMBAT")
        if self.localState.life <= 0 then
            self:LoseMatch("Reduced to 0 life.")
        end
    end
    self:RefreshUI()
end

-- Damage marked on creatures wears off at the end of every turn (both sides of the board)
function E:ClearCreatureDamage()
    for _, field in ipairs({ self.localState.field, self.remoteState.field }) do
        for _, perm in ipairs(field) do
            perm.damage = 0
        end
    end
end

-- =========================================================================
-- MANA SYSTEM
-- Both functions work for either side's pool (isRemote = the opponent / AI).
-- =========================================================================
local MANA_COLORS = { "W", "U", "B", "R", "G" }

-- What a cost string asks for: { W, U, B, R, G, Generic }
function E:ParseCost(costString)
    local req = { W = 0, U = 0, B = 0, R = 0, G = 0, Generic = 0 }
    for pip in string.gmatch(costString or "", "{(%w+)}") do
        if tonumber(pip) then
            req.Generic = req.Generic + tonumber(pip)
        elseif pip ~= "X" and req[pip] then
            req[pip] = req[pip] + 1
        end
    end
    return req
end

function E:CanPayMana(costString, isRemote)
    if not costString or costString == "" then return true end
    local pool = (isRemote and self.remoteState or self.localState).mana
    local req = self:ParseCost(costString)

    local totalRemaining = 0
    for _, col in ipairs(MANA_COLORS) do
        if (pool[col] or 0) < req[col] then return false end
        totalRemaining = totalRemaining + ((pool[col] or 0) - req[col])
    end
    return totalRemaining >= req.Generic
end

function E:PayMana(costString, isRemote)
    if not self:CanPayMana(costString, isRemote) then return false end
    if not costString or costString == "" then return true end
    local pool = (isRemote and self.remoteState or self.localState).mana
    local req = self:ParseCost(costString)

    for _, col in ipairs(MANA_COLORS) do
        pool[col] = (pool[col] or 0) - req[col]
    end
    local genToPay = req.Generic
    for _, col in ipairs(MANA_COLORS) do
        while (pool[col] or 0) > 0 and genToPay > 0 do
            pool[col] = pool[col] - 1
            genToPay = genToPay - 1
        end
    end
    return true
end

-- =========================================================================
-- TURN & PHASE MANAGEMENT
-- =========================================================================

-- "Your turn" alert. Uses the ready-check chime on the Master channel so it is
-- heard even with effects turned down; respects the Sounds checkbox and the
-- "Your-turn alert" option.
local function PlayTurnSound()
    if not (TTS.Sound and TTS.Sound:IsOn("turn")) then return end
    if SOUNDKIT then
        pcall(PlaySound, 31584, "Master")
    else
        pcall(PlaySound, 31584)
    end
end

-- Phase shown while the solo opponent takes its turn
local AI_TURN_PHASE = "WAITING (Opponent's Turn)"
E.AI_TURN_PHASE = AI_TURN_PHASE

function E:CancelTargeting()
    if self.targeting then
        self:Log("Targeting cancelled.", "SYSTEM")
        self.targeting = nil
        self:RefreshUI()
    end
end

function E:NextPhase()
    if self.phase == "COMBAT_BLOCK" and self.blockingState then
        local bs = self.blockingState
        if bs.isRemoteAttacking then
            if self.isSolo then
                -- The AI has no button to click: resolve right away
                self:ResolveCombatDamage()
            elseif not bs.blocksDeclared and next(bs.blocks) == nil then
                -- No blocks to show the attacker: resolve on both clients straight away
                bs.selectedBlocker = nil
                TTS.Net:Send(self.opponent, "ACTION:RESOLVE_COMBAT")
                self:ResolveCombatDamage()
            elseif not bs.blocksDeclared then
                -- Defending: send our blocks and hand control back to the attacker
                bs.selectedBlocker = nil
                for blockerIdx, attackerIdx in pairs(bs.blocks) do
                    TTS.Net:Send(self.opponent, string.format("ACTION:ASSIGN_BLOCK:%d:%d", blockerIdx, attackerIdx))
                end
                TTS.Net:Send(self.opponent, "ACTION:BLOCKS_DECLARED")
                bs.blocksDeclared = true
                self:Log("Blocks declared. Waiting for the attacker to resolve combat...", "SYSTEM")
                self:RefreshUI()
            end
        elseif bs.blocksDeclared then
            -- Attacking: blocks are in and reviewed, resolve combat on both clients
            if not self.isSolo then TTS.Net:Send(self.opponent, "ACTION:RESOLVE_COMBAT") end
            self:ResolveCombatDamage()
        end
        return
    end

    if not self.isMyTurn then return end
    if self:UndoBlocksAction() then return end
    self:CancelTargeting()

    if self.phase == "MAIN1" then
        self:SetPhase("COMBAT_ATTACK")
        self.blockingState = { attackers = {}, blocks = {}, isRemoteAttacking = false }
        self:Log("--- Combat Phase --- Click untapped creatures to declare attack.", "SYSTEM")

    elseif self.phase == "COMBAT_ATTACK" then
        for i, perm in ipairs(self.localState.field) do
            if not perm.tapped and not perm.sick and perm.id == "BOSS11" then
                self:TapCard(i)
            end
        end

        if self.blockingState and #self.blockingState.attackers > 0 then
            self:SetPhase("COMBAT_BLOCK")
            if self.isSolo then
                self:AIAssignBlocks()
                if next(self.blockingState.blocks) == nil then
                    -- Nothing blocked, so there are no blocks to review: resolve right away
                    self:Log(self.opponent .. " declared no blockers.", "SYSTEM")
                    self:ResolveCombatDamage()
                    return
                end
                self.blockingState.blocksDeclared = true
                self:Log(self.opponent .. " declared blockers. Review the blocks, then click Resolve Combat.", "SYSTEM")
            else
                self:Log("Waiting for opponent to declare blockers...", "SYSTEM")
            end
        else
            self.blockingState = nil
            self:SetPhase("MAIN2")
            self:Log("No attackers declared. --- Main Phase 2 ---", "SYSTEM")
        end

    elseif self.phase == "MAIN2" then
        self:EndTurn()
    end
    self:RefreshUI()
end

function E:EndTurn()
    if not self.isMyTurn then return end
    if self:UndoBlocksAction() then return end
    -- Declared attackers have to be resolved first
    if self.phase == "COMBAT_BLOCK" or (self.blockingState and #(self.blockingState.attackers or {}) > 0) then
        self:Log("Finish combat before ending your turn.", "ERROR")
        return
    end

    for _, perm in ipairs(self.localState.field) do
        local mustAttack = (perm.id == "BOSS11")
        if mustAttack and not perm.hasAttackedThisTurn and self:CanCreatureAttack(perm) then
            local card = TTS.Cards[perm.id]
            local cName = card and card.name or perm.id
            self:Log(string.format("|cFFFF2222%s|r must attack this turn if able! Enter combat and attack before ending turn.", cName), "ERROR")
            return
        end
    end

    self.isMyTurn = false
    self:CancelTargeting()
    self:EndTurnCleanup(false)

    self:Log("Ended turn. Mana pool emptied and damage on creatures removed.", "SYSTEM")

    if self.isSolo then
        self:SetPhase(AI_TURN_PHASE)
        self:RefreshUI()
        TTS:SafeAfter(1.0, function()
            if not E.inMatch or not E.isSolo then return end
            E:AITakeTurn()
        end)
    else
        self:SetPhase("WAITING")
        TTS.Net:Send(self.opponent, "ACTION:END_TURN")
        self:RefreshUI()
    end
end

-- Untaps one side's permanents (a frozen permanent stays tapped once) and clears summoning sickness
function E:UntapSide(isRemote)
    for _, perm in ipairs((isRemote and self.remoteState or self.localState).field) do
        perm.sick = false
        perm.isAttacking = nil
        perm.hasAttackedThisTurn = nil
        perm.blockedThisCombat = nil
        if perm.freezeUntap then
            perm.freezeUntap = false
        else
            perm.tapped = false
        end
    end
end

-- Start of a turn for either side: untap, tick that side's over-time effects, draw.
-- Returns false if the match ended along the way.
function E:BeginTurn(isRemote)
    local st = isRemote and self.remoteState or self.localState
    self.blockingState = nil
    self.cantBlockThisTurn = false
    self.preventCombatDamage = false
    if isRemote then
        self.remoteLandPlayed = false
        self.remoteTurns = (self.remoteTurns or 0) + 1
    else
        self.landPlayedThisTurn = false
    end

    self:UntapSide(isRemote)
    st.mana = { W = 0, U = 0, B = 0, R = 0, G = 0, C = 0 }

    self:TickOverTime(isRemote)
    if not self.inMatch then return false end
    self:RunEncounterRules(isRemote and "onAITurnStart" or "onPlayerTurnStart")
    if not self.inMatch then return false end
    self:DrawCardFor(isRemote)
    return self.inMatch
end

-- End of a turn for either side: the mana pool empties, "until end of turn" effects wear off,
-- creatures this side took control of go back, and damage on creatures is removed.
function E:EndTurnCleanup(isRemote)
    local st = isRemote and self.remoteState or self.localState
    self.preventCombatDamage = false
    self.cantBlockThisTurn = false
    self.blockingState = nil
    st.mana = { W = 0, U = 0, B = 0, R = 0, G = 0, C = 0 }

    for i = #self.stolenCreatures, 1, -1 do
        local entry = self.stolenCreatures[i]
        if (entry.controllerIsRemote or false) == isRemote then
            table.remove(self.stolenCreatures, i)
            local from = isRemote and self.remoteState.field or self.localState.field
            local to = entry.isRemoteOwner and self.remoteState.field or self.localState.field
            for fIdx, perm in ipairs(from) do
                if perm == entry.perm then
                    table.remove(from, fIdx)
                    perm.sick = true
                    perm.isAttacking = nil
                    table.insert(to, perm)
                    self:Log("Control effect expired: returned creature to owner.", "ACTION")
                    break
                end
            end
        end
    end

    -- "Until end of turn" effects wear off on both sides of the board
    for _, field in ipairs({ self.localState.field, self.remoteState.field }) do
        for _, perm in ipairs(field) do
            perm.tempPower = 0
            perm.tempToughness = 0
            perm.tempKw = nil
            perm.mustAttack = nil
            perm.isAttacking = nil
            perm.hasAttackedThisTurn = nil
        end
    end
    self:ClearCreatureDamage()
end

-- The opponent (or the AI) ended their turn: our turn begins
function E:OnRemoteEndTurn()
    self:CancelTargeting()
    self:OnLocalTurnStart()
    self:EndTurnCleanup(true)

    self.isMyTurn = true
    self.turn = self.turn + 1
    self:Log(string.format("=== Turn %d === Untapped permanents.", self.turn), "SYSTEM")
    if not self:BeginTurn(false) then return end
    self:SetPhase("MAIN1")
    PlayTurnSound()
    self:RefreshUI()
end

function E:StartMatch(opponentName, isHost, isSolo, encounter)
    if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() then
        self:Log("Cannot start a game while the Deckbuilder is open.", "ERROR")
        return
    end

    -- Starting a game takes the player out of the waiting room
    local WR = TTS.WaitingRoom
    if WR then
        if WR.isQueued then WR:ToggleQueue() end
        if WR.frame then WR.frame:Hide() end
    end

    if TTS.MatchLog and TTS.MatchLog.Clear then
        TTS.MatchLog:Clear()
    end

    self.inMatch = true
    self.opponent = opponentName or "Opponent"
    self.opponentScore = nil   -- PvP: set by Network.lua from the INVITE/ACCEPT, if their build sends it
    self.isSolo = isSolo or false
    self.isMyTurn = isHost
    self.turn = 1
    self.landPlayedThisTurn = false
    self.preventCombatDamage = false
    self.cantBlockThisTurn = false
    self.targeting = nil
    self.blockingState = nil
    self.pendingDiscard = nil
    self.stolenCreatures = {}
    self.remoteTurns = 0
    self.remoteLandPlayed = false
    self.checkingSBA = false
    self.encounter = nil
    self.matchReward = nil
    self.bossIndex = nil
    self:ResetUndo()
    self.sentDeckCount = nil
    self.remoteState.deckCount = nil
    -- Deck size goes to the opponent once setup is done, not once per opening draw
    self.startingMatch = true

    self.localState.life = 20
    self.localState.mana = { W = 0, U = 0, B = 0, R = 0, G = 0, C = 0 }
    self.localState.hand = {}
    self.localState.field = {}
    self.localState.graveyard = {}
    self.localState.deck = {}
    self.localState.damageShield = 0
    self.localState.dots = {}
    self.localState.hots = {}
    self.localState.mirror = nil

    local activeDeck = TTS_SavedDecks and TTS_SavedDecks[TTS_ActiveDeckIndex] and TTS_SavedDecks[TTS_ActiveDeckIndex].cards
    if activeDeck then
        for cardId, qty in pairs(activeDeck) do
            if TTS.Cards[cardId] then
                for _ = 1, qty do table.insert(self.localState.deck, cardId) end
            end
        end
    end

    for i = #self.localState.deck, 2, -1 do
        local j = math.random(i)
        self.localState.deck[i], self.localState.deck[j] = self.localState.deck[j], self.localState.deck[i]
    end

    for _ = 1, 7 do self:DrawCard(true) end

    self.remoteState.life = 20
    self.remoteState.handCount = 0
    self.remoteState.hand = {}
    self.remoteState.deck = {}
    self.remoteState.deckCount = nil
    self.remoteState.mana = { W = 0, U = 0, B = 0, R = 0, G = 0, C = 0 }
    self.remoteState.field = {}
    self.remoteState.graveyard = {}
    self.remoteState.damageShield = 0
    self.remoteState.dots = {}
    self.remoteState.hots = {}
    self.remoteState.mirror = nil

    if self.isSolo then
        -- Every solo game is an encounter; Practice vs Dummy is the PRACTICE entry
        local enc = encounter or (TTS.SoloEncounters and TTS.SoloEncounters.PRACTICE)
        self.encounter = enc
        self.remoteState.life = enc.life or 20
        if TTS.BoardFrame and TTS.BoardFrame.SetBackground then TTS.BoardFrame:SetBackground(enc.background) end
    elseif TTS.BoardFrame and TTS.BoardFrame.ClearBackground then
        TTS.BoardFrame:ClearBackground()
    end

    if self.isSolo then
        local enc = self.encounter

        self.remoteState.deck = self:BuildEncounterDeck(enc)
        for i = #self.remoteState.deck, 2, -1 do
            local j = math.random(i)
            self.remoteState.deck[i], self.remoteState.deck[j] = self.remoteState.deck[j], self.remoteState.deck[i]
        end

        for _ = 1, 7 do
            if #self.remoteState.deck > 0 then
                table.insert(self.remoteState.hand, table.remove(self.remoteState.deck, 1))
            end
        end
        self.remoteState.handCount = #self.remoteState.hand
    end

    if TTS.BoardFrame then TTS.BoardFrame:Show() end
    if TTS.MainFrame then TTS.MainFrame:Hide() end

    if self.isSolo then self:RunEncounterRules("onStart") end

    if self.isMyTurn then
        self:SetPhase("MAIN1")
    else
        self:SetPhase("WAITING")
    end
    self.startingMatch = false
    -- Ready check at the start of every game, whoever goes first
    PlayTurnSound()
    self:RefreshUI()
end

-- Calls one hook (onStart, onAITurnStart, onPlayerTurnStart, onCreatureDeath) of every
-- rule the current solo encounter lists. See TTS.EncounterRules in SoloEncounters.lua.
function E:RunEncounterRules(hook, ...)
    local enc = self.encounter
    if not (enc and enc.rules and TTS.EncounterRules) then return end
    for _, ruleId in ipairs(enc.rules) do
        local rule = TTS.EncounterRules[ruleId]
        if rule and rule[hook] then rule[hook](self, enc, ...) end
        if not self.inMatch then return end
    end
end

-- Most cards a hand can hold. Drawing with a full hand asks for a discard first.
local MAX_HAND_SIZE = 10

function E:DrawCard(silent)
    -- Already waiting on a discard: this draw waits its turn behind it
    if self.pendingDiscard then
        self.pendingDiscard = self.pendingDiscard + 1
        return
    end
    if #self.localState.deck == 0 then
        self:LoseMatch("Deck out: drawn from empty library.")
        return
    end
    if #self.localState.hand >= MAX_HAND_SIZE then
        self.pendingDiscard = 1
        self:CancelTargeting()
        self:Log(string.format("Your hand is full (%d cards). Click a card in your hand to discard before you draw.", MAX_HAND_SIZE), "SYSTEM")
        self:RefreshUI()
        return
    end
    local cardId = table.remove(self.localState.deck, 1)
    table.insert(self.localState.hand, cardId)
    local card = TTS.Cards[cardId]
    if not silent and card then
        self:Log("Drew " .. card.name .. ".", "ACTION")
    end
    self:RefreshUI()
end

-- Draws a card for either side.
--   Local:          the normal draw (hand limit asks the player to discard).
--   Remote in solo: the AI draws from its real deck; an empty deck loses it the match,
--                   and at the hand limit it discards its least useful card first.
--   Remote in PvP:  the other client draws for itself; we only track the hand size.
function E:DrawCardFor(isRemote)
    if not isRemote then
        self:DrawCard()
        return
    end
    local st = self.remoteState
    if not self.isSolo then
        st.handCount = (st.handCount or 0) + 1
        return
    end

    if #st.deck == 0 then
        self:WinMatch(string.format("Victory! %s drew from an empty library.", self.opponent))
        return
    end
    if #st.hand >= MAX_HAND_SIZE then
        local worstIdx, worstVal
        for i, id in ipairs(st.hand) do
            local v = self:AICardValue(id)
            if not worstVal or v < worstVal then worstIdx, worstVal = i, v end
        end
        local discarded = table.remove(st.hand, worstIdx)
        table.insert(st.graveyard, discarded)
        local dc = TTS.Cards[discarded]
        self:Log(string.format("%s discarded |cFFFFD200%s|r (hand full).", self.opponent, dc and dc.name or discarded), "ACTION")
    end
    table.insert(st.hand, table.remove(st.deck, 1))
    st.handCount = #st.hand
    self:RefreshUI()
end

-- Removes a random card from a side's hand to its graveyard (forced discards)
function E:DiscardRandom(isRemote)
    local st = isRemote and self.remoteState or self.localState
    if isRemote and not self.isSolo then
        st.handCount = math.max(0, (st.handCount or 0) - 1)
        return
    end
    if #st.hand == 0 then return end
    local cardId = table.remove(st.hand, math.random(#st.hand))
    table.insert(st.graveyard, cardId)
    if isRemote then st.handCount = #st.hand end
    local card = TTS.Cards[cardId]
    self:Log(string.format("%s discarded |cFFFFD200%s|r.", isRemote and self.opponent or "You", card and card.name or cardId), "ACTION")
    if not isRemote and not self.isSolo then TTS.Net:Send(self.opponent, "ACTION:DISCARD:" .. cardId) end
end

-- Discards the hand card the player clicked to make room, then makes the waiting draw(s)
function E:DiscardForDraw(handIndex)
    if not self.pendingDiscard then return end
    local cardId = table.remove(self.localState.hand, handIndex)
    if not cardId then return end

    table.insert(self.localState.graveyard, cardId)
    local card = TTS.Cards[cardId]
    self:Log(string.format("Discarded |cFFFFD200%s|r.", card and card.name or cardId), "ACTION")
    if not self.isSolo then TTS.Net:Send(self.opponent, "ACTION:DISCARD:" .. cardId) end

    local waiting = self.pendingDiscard
    self.pendingDiscard = nil
    for _ = 1, waiting do
        if not self.inMatch then break end
        self:DrawCard()
    end
    self:RefreshUI()
end

function E:SetPhase(newPhase)
    self.phase = newPhase
    if TTS.BoardFrame and TTS.BoardFrame.phaseText then
        if self.targeting then
            TTS.BoardFrame.phaseText:SetText("|cFFFFD200TARGETING: Select target (Right-click to cancel)|r")
        elseif self.phase == "COMBAT_BLOCK" then
            if self.blockingState and self.blockingState.isRemoteAttacking then
                TTS.BoardFrame.phaseText:SetText("|cFFFF4444COMBAT: Select Blockers or Pass|r")
            else
                TTS.BoardFrame.phaseText:SetText("|cFFFFD200COMBAT: Blockers Declared|r")
            end
        else
            TTS.BoardFrame.phaseText:SetText("Phase: " .. newPhase)
        end
    end
end

function E:RefreshUI()
    -- PvP: the opponent's board shows how many cards are left in our deck
    self:SyncDeckCount()
    if TTS.BoardFrame and TTS.BoardFrame:IsShown() then
        TTS.BoardFrame:UpdateDisplay()
    end
end