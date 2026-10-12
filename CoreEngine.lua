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
        if data then E:PlayMatchEmote(data.outcome, data.opponent) end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
}

function E:EndMatch(outcome, reason)
    if not self.inMatch then return end
    local opponentName = self.opponent or "Target Dummy"
    self.inMatch = false

    if outcome and opponentName ~= "" then
        local headline = RESULT_HEADLINES[outcome]
        if headline then
            StaticPopup_Show("TTS_MATCH_RESULT", headline, opponentName .. " " .. OPPONENT_RESULT[outcome], { outcome = outcome, opponent = opponentName })
        else
            self:PlayMatchEmote(outcome, opponentName)
        end
    end

    self:Log(string.format("Match ended (%s): %s", outcome:upper(), reason or ""), "SYSTEM")

    if TTS.BoardFrame then TTS.BoardFrame:Hide() end
    if TTS.BoardRestoreFrame then TTS.BoardRestoreFrame:Hide() end
    if TTS.MainFrame then
        TTS.MainFrame:Show()
        if TTS.MainFrame.UpdatePlayState then
            TTS.MainFrame:UpdatePlayState()
        end
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
-- =========================================================================
function E:CanPayMana(costString)
    if not costString or costString == "" then return true end
    local req = { W = 0, U = 0, B = 0, R = 0, G = 0, Generic = 0 }
    for pip in string.gmatch(costString, "{(%w+)}") do
        if tonumber(pip) then
            req.Generic = req.Generic + tonumber(pip)
        elseif pip ~= "X" and req[pip] then
            req[pip] = req[pip] + 1
        end
    end

    for col in pairs({ W = true, U = true, B = true, R = true, G = true }) do
        if (self.localState.mana[col] or 0) < req[col] then return false end
    end

    local totalRemaining = 0
    for col in pairs({ W = true, U = true, B = true, R = true, G = true }) do
        totalRemaining = totalRemaining + ((self.localState.mana[col] or 0) - req[col])
    end
    return totalRemaining >= req.Generic
end

function E:PayMana(costString)
    if not self:CanPayMana(costString) then return false end
    if not costString or costString == "" then return true end

    local req = { W = 0, U = 0, B = 0, R = 0, G = 0, Generic = 0 }
    for pip in string.gmatch(costString, "{(%w+)}") do
        if tonumber(pip) then
            req.Generic = req.Generic + tonumber(pip)
        elseif pip ~= "X" and req[pip] then
            req[pip] = req[pip] + 1
        end
    end

    for col in pairs({ W = true, U = true, B = true, R = true, G = true }) do
        self.localState.mana[col] = self.localState.mana[col] - req[col]
    end
    local genToPay = req.Generic
    for col in pairs({ W = true, U = true, B = true, R = true, G = true }) do
        while (self.localState.mana[col] or 0) > 0 and genToPay > 0 do
            self.localState.mana[col] = self.localState.mana[col] - 1
            genToPay = genToPay - 1
        end
    end
    return true
end

-- =========================================================================
-- TURN & PHASE MANAGEMENT
-- =========================================================================

-- "Your turn" alert. Uses the ready-check chime on the Master channel so it is
-- heard even with effects turned down; respects the board's Sounds checkbox.
local function PlayTurnSound()
    if not (TTS.Sound and TTS.Sound.enabled) then return end
    if SOUNDKIT then
        pcall(PlaySound, 31584, "Master")
    else
        pcall(PlaySound, 31584)
    end
end

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
                -- The Target Dummy has no button to click: resolve right away
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
                self:DummyAssignBlocksAgainstPlayer()
                if next(self.blockingState.blocks) == nil then
                    -- Nothing blocked, so there are no blocks to review: resolve right away
                    self:Log("Target Dummy declared no blockers.", "SYSTEM")
                    self:ResolveCombatDamage()
                    return
                end
                self.blockingState.blocksDeclared = true
                self:Log("Target Dummy declared blockers. Review the blocks, then click Resolve Combat.", "SYSTEM")
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
    self.preventCombatDamage = false
    self.cantBlockThisTurn = false
    self.blockingState = nil
    self.localState.mana = { W = 0, U = 0, B = 0, R = 0, G = 0, C = 0 }

    for i = #self.stolenCreatures, 1, -1 do
        local entry = table.remove(self.stolenCreatures, i)
        for fIdx, perm in ipairs(self.localState.field) do
            if perm == entry.perm then
                table.remove(self.localState.field, fIdx)
                perm.sick = true
                if entry.isRemoteOwner then table.insert(self.remoteState.field, perm)
                else table.insert(self.localState.field, perm) end
                self:Log("Control effect expired: returned creature to owner.", "ACTION")
                break
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

    self:Log("Ended turn. Mana pool emptied and damage on creatures removed.", "SYSTEM")

    if self.isSolo then
        self:SetPhase("WAITING (Dummy Turn)")
        self:RefreshUI()
        TTS:SafeAfter(1.0, function()
            if not E.inMatch or not E.isSolo then return end
            E:DummyTakeTurn()
        end)
    else
        self:SetPhase("WAITING")
        TTS.Net:Send(self.opponent, "ACTION:END_TURN")
        self:RefreshUI()
    end
end

function E:OnRemoteEndTurn()
    self.isMyTurn = true
    self.turn = self.turn + 1
    self.landPlayedThisTurn = false
    self.blockingState = nil
    self.cantBlockThisTurn = false
    self.preventCombatDamage = false
    self:CancelTargeting()

    -- The opponent's turn just ended: damage on creatures wears off
    self:ClearCreatureDamage()

    for _, perm in ipairs(self.localState.field) do
        perm.sick = false
        perm.isAttacking = nil
        perm.hasAttackedThisTurn = nil
        local canUntap = true
        if perm.freezeUntap then
            canUntap = false
            perm.freezeUntap = false
        end
        if canUntap then perm.tapped = false end
    end
    self.localState.mana = { W = 0, U = 0, B = 0, R = 0, G = 0, C = 0 }

    self:Log(string.format("=== Turn %d === Untapped permanents.", self.turn), "SYSTEM")
    self:TickOverTime()
    if not self.inMatch then return end
    self:DrawCard()
    self:SetPhase("MAIN1")
    PlayTurnSound()
    self:RefreshUI()
end

function E:StartMatch(opponentName, isHost, isSolo)
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
    self.opponent = opponentName or "Target Dummy"
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
    self.remoteState.mana = { W = 0, U = 0, B = 0, R = 0, G = 0, C = 0 }
    self.remoteState.field = {}
    self.remoteState.graveyard = {}
    self.remoteState.damageShield = 0
    self.remoteState.dots = {}
    self.remoteState.hots = {}
    self.remoteState.mirror = nil

    if self.isSolo then
        local dummyLands = {
            "W01", "W01", "W01", "W01",
            "U01", "U01", "U01", "U01",
            "B01", "B01", "B01", "B01",
            "R01", "R01", "R01", "R01",
            "G01", "G01"
        }
        local dummyCreatures = {
            "ELW02", "RED04", "TEL06", "TEL07",
            "DAR01", "DUN04", "LOC03", "DUN06",
            "TIR01", "ELW03", "TIR03", "TIR05", "WES07",
            "ELW01", "ELW04", "RED03", "ELW05",
            "DUN01", "DUN03", "WES04", "ELW06", "LOC07"
        }
        for _, id in ipairs(dummyLands) do table.insert(self.remoteState.deck, id) end
        for _, id in ipairs(dummyCreatures) do table.insert(self.remoteState.deck, id) end

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

    if self.isMyTurn then
        self:SetPhase("MAIN1")
    else
        self:SetPhase("WAITING")
    end
    -- Ready check at the start of every game, whoever goes first
    PlayTurnSound()
    self:RefreshUI()
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
    if TTS.BoardFrame and TTS.BoardFrame:IsShown() then
        TTS.BoardFrame:UpdateDisplay()
    end
end