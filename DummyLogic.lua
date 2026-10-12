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

-- Seconds the dummy pauses after each action on its turn
local DUMMY_STEP_DELAY = 0.8
-- Seconds between each prayer it taps for mana
local DUMMY_TAP_DELAY = 0.4

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
            self:PlayNonCreatureCardSound()
            return true
        end
    end
    return false
end

-- =========================================================================
-- TAPPING PRAYERS ONLY WHEN NEEDED
-- The dummy counts its untapped prayers as mana it could make, and taps just
-- the ones a spell needs at the moment it casts it.
-- =========================================================================
local COLORS = { "W", "U", "B", "R", "G" }

-- What a cost asks of the dummy (U15 on the player's side taxes it {1}, as in DummyPayMana)
local function DummyCostReq(self, costString)
    local req = { W = 0, U = 0, B = 0, R = 0, G = 0, Generic = 0 }
    for pip in string.gmatch(costString or "", "{(%w+)}") do
        if tonumber(pip) then req.Generic = req.Generic + tonumber(pip)
        elseif pip ~= "X" and req[pip] then req[pip] = req[pip] + 1 end
    end
    for _, p in ipairs(self.localState.field) do
        if p.id == "U15" then req.Generic = req.Generic + 1; break end
    end
    return req
end

-- The dummy's untapped prayers, grouped by color
local function DummyUntappedLands(self)
    local lands = { W = {}, U = {}, B = {}, R = {}, G = {} }
    for _, perm in ipairs(self.remoteState.field) do
        local card = TTS.Cards[perm.id]
        if card and card.type == "Land" and not perm.tapped and lands[card.color] then
            table.insert(lands[card.color], perm)
        end
    end
    return lands
end

-- True if the mana pool plus untapped prayers could pay costString
function E:DummyCanAfford(costString)
    local req = DummyCostReq(self, costString)
    local lands = DummyUntappedLands(self)
    local spare = 0
    for _, col in ipairs(COLORS) do
        local have = (self.remoteState.mana[col] or 0) + #lands[col]
        if have < req[col] then return false end
        spare = spare + have - req[col]
    end
    return spare >= req.Generic
end

-- Works out which prayers to tap to pay costString, using mana already in the pool
-- first. Returns them in tap order; nothing is tapped yet.
function E:DummyPlanLandTaps(costString)
    local req = DummyCostReq(self, costString)
    local lands = DummyUntappedLands(self)
    local pool = {}
    for _, col in ipairs(COLORS) do pool[col] = self.remoteState.mana[col] or 0 end
    local plan = {}

    local function Tap(col)
        table.insert(plan, table.remove(lands[col]))
        pool[col] = pool[col] + 1
    end

    -- Colored pips first
    for _, col in ipairs(COLORS) do
        while (pool[col] or 0) < req[col] and #lands[col] > 0 do Tap(col) end
    end

    -- Then generic: spare pool mana first, then prayers of the color the dummy has most of
    local spare = 0
    for _, col in ipairs(COLORS) do
        spare = spare + math.max(0, (pool[col] or 0) - req[col])
    end
    local need = req.Generic - spare
    while need > 0 do
        local best
        for _, col in ipairs(COLORS) do
            if #lands[col] > 0 and (not best or #lands[col] > #lands[best]) then best = col end
        end
        if not best then break end
        Tap(best)
        need = need - 1
    end
    return plan
end

-- Taps one of the dummy's prayers and adds its mana to the dummy's pool
function E:DummyTapLand(perm)
    local card = TTS.Cards[perm.id]
    perm.tapped = true
    if TTS.Sound then TTS.Sound:PlayUI("tap") end
    if card and card.color then
        self.remoteState.mana[card.color] = (self.remoteState.mana[card.color] or 0) + 1
    end
end

-- The most expensive creature in the dummy's hand it can afford: hand index, card (nil if none)
function E:DummyFindBestCreature()
    local bestIdx, bestCard = nil, nil
    for i, cardId in ipairs(self.remoteState.hand) do
        local card = TTS.Cards[cardId]
        if card and card.type == "Creature" and self:DummyCanAfford(card.cost) then
            if not bestCard or (card.cmc or 0) > (bestCard.cmc or 0) then
                bestIdx = i
                bestCard = card
            end
        end
    end
    return bestIdx, bestCard
end

-- Pays for and casts the creature at hand index bestIdx (its prayers are already tapped)
function E:DummyCastCreature(bestIdx, bestCard)
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
    return true
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
    self:RefreshUI()

    -- The rest of the turn plays out one action at a time with a pause between each.
    -- A token stops a turn from carrying on after the match ends or a new one starts.
    local token = (self.dummyTurnToken or 0) + 1
    self.dummyTurnToken = token
    local function Next(step, delay)
        TTS:SafeAfter(delay or DUMMY_STEP_DELAY, function()
            if E.inMatch and E.isSolo and E.dummyTurnToken == token then step() end
        end)
    end

    local function AttackStep()
        E.remoteState.mana = { W = 0, U = 0, B = 0, R = 0, G = 0, C = 0 }
        if not E:DummyAttack() then
            Next(function()
                E:Log("Target Dummy passed turn.", "SYSTEM")
                E:OnRemoteEndTurn()
            end)
        end
    end

    -- Each creature: tap its prayers one at a time (short pause between taps), then cast it
    local function CreatureStep()
        local idx, card = E:DummyFindBestCreature()
        if not idx then
            AttackStep()
            return
        end

        local taps = E:DummyPlanLandTaps(card.cost)
        local function TapNext(i)
            if i > #taps then
                E:DummyCastCreature(idx, card)
                E:RefreshUI()
                Next(CreatureStep)
                return
            end
            E:DummyTapLand(taps[i])
            E:RefreshUI()
            Next(function() TapNext(i + 1) end, DUMMY_TAP_DELAY)
        end
        TapNext(1)
    end

    Next(function()
        if E:DummyPlayLand() then
            E:RefreshUI()
            Next(CreatureStep)
        else
            CreatureStep()
        end
    end)
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