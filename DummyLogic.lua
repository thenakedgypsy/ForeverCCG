--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
TTS.Engine = TTS.Engine or {}
local E = TTS.Engine

-- =========================================================================
-- SOLO DUMMY AI LOGIC
-- =========================================================================
function E:DummyCanPayMana(costString)
    if not costString or costString == "" then return true end
    local req = { W = 0, U = 0, B = 0, R = 0, G = 0, Generic = 0 }
    for pip in string.gmatch(costString, "{(%w+)}") do
        if tonumber(pip) then req.Generic = req.Generic + tonumber(pip)
        elseif pip ~= "X" and req[pip] then req[pip] = req[pip] + 1 end
    end
    for _, p in ipairs(self.localState.field) do
        if p.id == "U15" then req.Generic = req.Generic + 1; break end
    end
    for col in pairs({ W = true, U = true, B = true, R = true, G = true }) do
        if (self.remoteState.mana[col] or 0) < req[col] then return false end
    end
    local rem = 0
    for col in pairs({ W = true, U = true, B = true, R = true, G = true }) do
        rem = rem + ((self.remoteState.mana[col] or 0) - req[col])
    end
    return rem >= req.Generic
end

function E:DummyPayMana(costString)
    if not self:DummyCanPayMana(costString) then return false end
    if not costString or costString == "" then return true end
    local req = { W = 0, U = 0, B = 0, R = 0, G = 0, Generic = 0 }
    for pip in string.gmatch(costString, "{(%w+)}") do
        if tonumber(pip) then req.Generic = req.Generic + tonumber(pip)
        elseif pip ~= "X" and req[pip] then req[pip] = req[pip] + 1 end
    end
    for _, p in ipairs(self.localState.field) do
        if p.id == "U15" then req.Generic = req.Generic + 1; break end
    end
    for col in pairs({ W = true, U = true, B = true, R = true, G = true }) do
        self.remoteState.mana[col] = (self.remoteState.mana[col] or 0) - req[col]
    end
    local gen = req.Generic
    for col in pairs({ W = true, U = true, B = true, R = true, G = true }) do
        while gen > 0 and (self.remoteState.mana[col] or 0) > 0 do
            self.remoteState.mana[col] = self.remoteState.mana[col] - 1
            gen = gen - 1
        end
    end
    return true
end

function E:DummyPlayLand()
    for i, cardId in ipairs(self.remoteState.hand) do
        local card = TTS.Cards[cardId]
        if card and card.type == "Land" then
            table.remove(self.remoteState.hand, i)
            table.insert(self.remoteState.field, { id = cardId, tapped = false, uid = time() + i })
            self.remoteState.handCount = #self.remoteState.hand
            self:Log(string.format("Target Dummy played land: |cFFFFD200%s|r.", card.name), "ACTION")
            return true
        end
    end
    return false
end

function E:DummyTapLandsForMana()
    for _, perm in ipairs(self.remoteState.field) do
        local card = TTS.Cards[perm.id]
        if card and card.type == "Land" and not perm.tapped then
            perm.tapped = true
            local col = card.color or "C"
            self.remoteState.mana[col] = (self.remoteState.mana[col] or 0) + 1
        end
    end
end

function E:DummyPlayCreatures()
    local canCastMore = true
    while canCastMore do
        local bestIdx, bestCard = nil, nil
        for i, cardId in ipairs(self.remoteState.hand) do
            local card = TTS.Cards[cardId]
            if card and card.type == "Creature" and self:DummyCanPayMana(card.cost) then
                if not bestCard or (card.cmc or 0) > (bestCard.cmc or 0) then
                    bestIdx = i
                    bestCard = card
                end
            end
        end

        if bestIdx and bestCard then
            self:DummyPayMana(bestCard.cost)
            local cardId = table.remove(self.remoteState.hand, bestIdx)
            local perm = {
                id = cardId,
                tapped = (cardId == "B10" or cardId == "G09"),
                sick = not self:HasKeyword({ id = cardId }, true, "haste"),
                damage = 0,
                tempPower = 0,
                tempToughness = 0,
                uid = time() + bestIdx
            }
            table.insert(self.remoteState.field, perm)
            self.remoteState.handCount = #self.remoteState.hand
            self:Log(string.format("Target Dummy cast |cFFFFD200%s|r (%s).", bestCard.name, bestCard.cost or "0"), "ACTION")
            if TTS.Sound then TTS.Sound:QueueCreature("aggro", cardId) end
        else
            canCastMore = false
        end
    end
end

function E:DummyAttack()
    local attackerIndices = {}

    for i, perm in ipairs(self.remoteState.field) do
        local card = TTS.Cards[perm.id]
        if card and card.type == "Creature" and not perm.tapped and not perm.sick and not card.defender then
            local pacified = false
            if perm.attachments then
                for _, att in ipairs(perm.attachments) do
                    local attId = type(att) == "table" and att.id or att
                    if attId == "W03" then pacified = true; break end
                end
            end

            if not pacified then
                if not self:HasKeyword(perm, true, "vigilance") then perm.tapped = true end
                perm.isAttacking = true
                table.insert(attackerIndices, i)
                self:Log(string.format("Target Dummy attacks with |cFFFF2222%s|r!", card.name), "COMBAT")
                if TTS.Sound then TTS.Sound:QueueCreature("aggro", perm.id) end

                if perm.id == "W09" then self.remoteState.life = self.remoteState.life + 2
                elseif perm.id == "R20" then self:DamagePlayer(false, 2, "Firemaw") end
            end
        end
    end

    if #attackerIndices > 0 then
        self.blockingState = {
            attackers = attackerIndices,
            blocks = {},
            isRemoteAttacking = true,
            selectedBlocker = nil
        }
        self:SetPhase("COMBAT_BLOCK")
        self:Log("Opponent declared attackers! Click your untapped creatures to block, then click 'End Block Step'.", "SYSTEM")
        self:RefreshUI()
        return true
    end

    return false
end

function E:DummyTakeTurn()
    for _, perm in ipairs(self.remoteState.field) do
        perm.blockedThisCombat = nil
        if perm.freezeUntap then perm.freezeUntap = false
        else perm.tapped = false end
        perm.sick = false
    end

    for _, perm in ipairs(self.remoteState.field) do
        if perm.attachments then
            for _, att in ipairs(perm.attachments) do
                local attId = type(att) == "table" and att.id or att
                if attId == "B06" then self:DamagePlayer(true, 1, "Curse of Agony") end
            end
        end
    end

    if self.remoteState.deck and #self.remoteState.deck > 0 then
        local drawnCard = table.remove(self.remoteState.deck, 1)
        table.insert(self.remoteState.hand, drawnCard)
        self.remoteState.handCount = #self.remoteState.hand
    end

    self:DummyPlayLand()
    self:DummyTapLandsForMana()
    self:DummyPlayCreatures()
    self.remoteState.mana = { W = 0, U = 0, B = 0, R = 0, G = 0, C = 0 }

    local hasAttackers = self:DummyAttack()
    if not hasAttackers then
        TTS:SafeAfter(1.0, function()
            if E.inMatch and E.isSolo then
                E:Log("Target Dummy passed turn.", "SYSTEM")
                E:OnRemoteEndTurn()
            end
        end)
    end
end

function E:DummyAssignBlocksAgainstPlayer()
    if not self.blockingState or self.blockingState.isRemoteAttacking then return end
    if self.cantBlockThisTurn then return end

    local unassignedBlockers = {}
    for i, perm in ipairs(self.remoteState.field) do
        local card = TTS.Cards[perm.id]
        if card and card.type == "Creature" and not perm.tapped and card.id ~= "R11" then
            local pacified = false
            if perm.attachments then
                for _, att in ipairs(perm.attachments) do
                    local attId = type(att) == "table" and att.id or att
                    if attId == "W03" then pacified = true; break end
                end
            end
            if not pacified then table.insert(unassignedBlockers, i) end
        end
    end

    for _, atkIdx in ipairs(self.blockingState.attackers) do
        local atkPerm = self.localState.field[atkIdx]
        local atkCard = atkPerm and TTS.Cards[atkPerm.id]

        if #unassignedBlockers > 0 and atkCard and not atkCard.unblockable then
            for bListIdx, blockerIdx in ipairs(unassignedBlockers) do
                local blockerPerm = self.remoteState.field[blockerIdx]
                local blockerCard = TTS.Cards[blockerPerm.id]

                local canBlock = true
                if self:HasKeyword(atkPerm, false, "flying") and not (self:HasKeyword(blockerPerm, true, "flying") or self:HasKeyword(blockerPerm, true, "reach")) then
                    canBlock = false
                end

                if canBlock then
                    self.blockingState.blocks[blockerIdx] = atkIdx
                    self:Log(string.format("Target Dummy assigned %s to block %s.", blockerCard.name, atkCard.name), "COMBAT")
                    table.remove(unassignedBlockers, bListIdx)
                    break
                end
            end
        end
    end
end