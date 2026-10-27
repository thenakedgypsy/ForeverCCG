--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
local L = TTS.L
TTS.Engine = TTS.Engine or {}
local E = TTS.Engine

-- =========================================================================
-- SOLO AI
-- The AI plays its turn one step at a time with a pause between each:
--   begin turn -> play a prayer -> main phase casts -> activated abilities -> attack
--   -> (the player blocks, combat resolves) -> second main phase casts -> end turn.
-- Each step scores the options it has and takes the best one.
-- =========================================================================

-- Seconds the AI pauses after each action on its turn
local STEP_DELAY = 0.8
-- Seconds the AI pauses after casting a spell (the spell is shown for about 1.25 s)
local SPELL_DELAY = 1.3
-- Seconds between each prayer it taps for mana
local TAP_DELAY = 0.4

-- How each profile plays (set per encounter with ai = "...")
--   spells       casts spells at all; spellChance: how often it takes a spell it wants
--   attack       "all" (dummy), "safe" (only attackers that survive any block),
--                "even" (accepts even trades), "aggressive" (trades down when ahead on board)
--   chumpAtLife  besides lethal damage, chump blocks when it would otherwise drop to this life or lower
--   holdRemoval  single-target removal waits for a target worth it
--   abilities    uses activated abilities
local PROFILES = {
    dummy    = { spells = false, attack = "all",        blocks = "greedy", chumpAtLife = nil, abilities = false, smartPrayer = false },
    basic    = { spells = true,  spellChance = 0.6, attack = "safe",       chumpAtLife = nil, abilities = true, smartPrayer = true },
    tactical = { spells = true,  spellChance = 1.0, attack = "even",       chumpAtLife = 4,   abilities = true, smartPrayer = true },
    expert   = { spells = true,  spellChance = 1.0, attack = "aggressive", chumpAtLife = 6,   abilities = true, smartPrayer = true, holdRemoval = true },
}
E.AI_PROFILES = PROFILES

function E:AIProfile()
    local name = self.encounter and self.encounter.ai or "dummy"
    return PROFILES[name] or PROFILES.dummy, name
end

local COLORS = { "W", "U", "B", "R", "G" }

local function Card(id) return TTS.Cards[id] end
local function IsCreature(perm) local c = perm and Card(perm.id); return c and c.type == "Creature" end
local function Name(perm) local c = Card(perm.id); return c and TTS:CardName(c) or perm.id end

-- =========================================================================
-- VALUES
-- =========================================================================
local KEYWORD_VALUE = {
    flying = 1.5, unblockable = 1.5, deathtouch = 1.5, firstStrike = 1, lifelink = 1, hexproof = 1,
    trample = 0.5, vigilance = 0.5, haste = 0.5, reach = 0.5, bulwark = 1, support = 0.5, shielded = 1,
}

-- How much a creature is worth to its controller, as it stands on the battlefield
function E:AIPermValue(perm, isRemote)
    local c = Card(perm.id)
    if not c or c.type ~= "Creature" then return 0 end
    local p, t = self:GetCreatureStats(perm, isRemote)
    local v = p + t - (perm.damage or 0) * 0.5
    for kw, kv in pairs(KEYWORD_VALUE) do
        if self:HasKeyword(perm, isRemote, kw) then v = v + kv end
    end
    if c.defender then v = v - p * 0.5 end
    if c.anthem then v = v + 1 end
    if self:GetAbility(perm.id) then v = v + 2 end
    if c.isBoss and perm.id:match("^BOSS") then v = v + 2 end
    return v
end

-- How much a creature card would add if it entered the battlefield on this side
local function CreatureCardValue(self, c, isRemote)
    local v = (c.power or 0) + (c.toughness or 0)
    for kw, kv in pairs(KEYWORD_VALUE) do
        if c[kw] then v = v + kv end
    end
    if c.defender then v = v - (c.power or 0) * 0.5 end
    local field = isRemote and self.remoteState.field or self.localState.field
    for _, other in ipairs(field) do
        local oc = Card(other.id)
        if oc and oc.type == "Creature" then
            -- Its anthem lifts creatures already here; its rally grows with them
            if c.anthem and self:CardHasTag(oc, c.anthem.tag, c.anthem.value) then
                v = v + (c.anthem.p or 0) + (c.anthem.t or 0) + (c.anthem.kw and 0.5 or 0)
            end
            if c.rally and self:CardHasTag(oc, c.rally.tag, c.rally.value) then
                v = v + (c.rally.p or 0) + (c.rally.t or 0)
            end
        end
    end
    if c.etb then v = v + 1.5 end
    if c.onDeath then v = v + 1 end
    if self:GetAbility(c.id) then v = v + 2 end
    return v
end

-- The creature card option ({ cardId }) the AI would most like on its battlefield
function E:AIChooseCreatureCard(options)
    local best, bestV
    for _, o in ipairs(options) do
        local c = Card(o.cardId)
        local v = c and CreatureCardValue(self, c, true) or 0
        if not bestV or v > bestV then best, bestV = o, v end
    end
    return best
end

-- How much the AI wants to keep a card in hand (higher = keep); used to pick discards
function E:AICardValue(cardId)
    local c = Card(cardId)
    if not c then return 0 end
    if c.type == "Land" then
        local lands = 0
        for _, p in ipairs(self.remoteState.field) do
            local pc = Card(p.id)
            if pc and pc.type == "Land" then lands = lands + 1 end
        end
        return lands < 6 and 8 or 1
    end
    if c.type == "Creature" then return CreatureCardValue(self, c, true) end
    return 4 + (c.cmc or 0) * 0.5
end

-- Total value of one side's creatures
local function BoardValue(self, isRemote)
    local v = 0
    for _, p in ipairs(isRemote and self.remoteState.field or self.localState.field) do
        v = v + self:AIPermValue(p, isRemote)
    end
    return v
end

-- =========================================================================
-- MANA: the AI counts its untapped prayers as mana it could make and taps just
-- the ones an action needs at the moment it takes it.
-- =========================================================================
-- (shared with the player's auto-pay: CoreEngine.lua)
function E:AICanAfford(costString)
    return self:CanAffordWithLands(costString, true)
end

-- What casting a card from hand costs the AI: nothing when an encounter rule makes it free
-- (Free Boss, SoloEncounters.lua)
function E:AICardCost(card)
    if self.EncounterFreeCast and self:EncounterFreeCast(card.id) then return "" end
    return card.cost
end

function E:AIPlanLandTaps(costString)
    return self:PlanLandTaps(costString, true)
end

-- Taps one of the AI's prayers and adds its mana to the AI's pool
-- (col: the colour a dual prayer makes, from E:AIPlanLandTaps; partner: the prayer a
-- double prayer is tapped with, or the colour of pool mana spent on it instead)
function E:AITapLand(perm, col, partner)
    local card = Card(perm.id)
    if perm.tapped then return end
    perm.tapped = true
    if TTS.Sound then TTS.Sound:PlayUI("tap") end
    if card and card.makesBoth then
        if type(partner) == "string" then
            self.remoteState.mana[partner] = math.max(0, (self.remoteState.mana[partner] or 0) - 1)
        elseif partner then
            partner.tapped = true
        end
        for _, c in ipairs(card.colors) do
            self.remoteState.mana[c] = (self.remoteState.mana[c] or 0) + 1
        end
        return
    end
    col = col or (card and self:ManaColorsOf(card)[1])
    if col then
        self.remoteState.mana[col] = (self.remoteState.mana[col] or 0) + 1
    end
end

-- =========================================================================
-- PRAYERS
-- Play the colour whose shortfall blocks the most expensive card in hand; otherwise
-- the colour least represented on the battlefield. Of the prayers that make a colour, one
-- that arrives Exhausted (entersTapped) is only picked when there's no other, and one that
-- returns a prayer to hand (bouncesPrayer) only once there's a basic prayer to return.
-- =========================================================================
local function LandCounts(self)
    local n = { W = 0, U = 0, B = 0, R = 0, G = 0 }
    for _, p in ipairs(self.remoteState.field) do
        local c = Card(p.id)
        if c and c.type == "Land" then
            for _, col in ipairs(self:ManaColorsOf(c)) do
                if n[col] then n[col] = n[col] + 1 end
            end
        end
    end
    return n
end

function E:AIChoosePrayer(profile)
    local hand = self.remoteState.hand
    local canBounce = self:AIBounceTarget() ~= nil
    local function Playable(c)
        return c and c.type == "Land" and (canBounce or not c.bouncesPrayer)
    end
    local landIdx = {}
    for i, id in ipairs(hand) do
        local c = Card(id)
        if Playable(c) then
            for _, col in ipairs(self:ManaColorsOf(c)) do
                if not landIdx[col] or (Card(hand[landIdx[col]]).entersTapped and not c.entersTapped) then
                    landIdx[col] = i
                end
            end
        end
    end
    if not next(landIdx) then return nil end
    if not profile.smartPrayer then
        for i, id in ipairs(hand) do
            if Playable(Card(id)) then return i end
        end
    end

    local have = LandCounts(self)
    local spells = {}
    for _, id in ipairs(hand) do
        local c = Card(id)
        if c and c.type ~= "Land" then table.insert(spells, c) end
    end
    table.sort(spells, function(a, b) return (a.cmc or 0) > (b.cmc or 0) end)
    for _, c in ipairs(spells) do
        local req = self:ParseCost(c.cost)
        for _, col in ipairs(COLORS) do
            if req[col] > have[col] and landIdx[col] then return landIdx[col] end
        end
    end

    local best, bestN
    for col, i in pairs(landIdx) do
        if not bestN or have[col] < bestN or (have[col] == bestN and col < best) then best, bestN = col, have[col] end
    end
    return landIdx[best]
end

-- The field index of the prayer the AI would return to hand for a bouncesPrayer prayer, or
-- nil: only basics can go back; an Exhausted one first, then the colour it has most of
function E:AIBounceTarget()
    local have = LandCounts(self)
    local best, bestScore
    for i, p in ipairs(self.remoteState.field) do
        local c = Card(p.id)
        if c and c.type == "Land" and not c.colors then
            local score = (p.tapped and 100 or 0) + (have[c.color] or 0)
            if not bestScore or score > bestScore then best, bestScore = i, score end
        end
    end
    return best
end

function E:AIPlayLand(handIdx)
    local cardId = table.remove(self.remoteState.hand, handIdx)
    local card = Card(cardId)
    local field = self.remoteState.field
    local bounceIdx = card and card.bouncesPrayer and self:AIBounceTarget()
    local bounced = bounceIdx and table.remove(field, bounceIdx)
    if bounced then self:PutInZone(self.remoteState.hand, bounced.id) end
    table.insert(field, { id = cardId, tapped = card and card.entersTapped and true or false, uid = self:NewUid() })
    self.remoteState.handCount = #self.remoteState.hand
    self.remoteLandPlayed = true
    self:Log(L("log.aiPlayedPrayer", self.opponent, TTS:CardName(card)), "ACTION")
    if bounced then self:Log(L("log.oppBouncedPrayer", self.opponent, TTS:CardName(bounced.id)), "ACTION") end
    self:PlayNonCreatureCardSound()
end

-- =========================================================================
-- COMBAT SIMULATION
-- =========================================================================
-- Outcome of one creature fighting another: attackerDies, blockerDies.
-- extra = { p, t, kw = { ... } } adds a pending buff to the attacker.
local function HasKw(self, perm, isRemote, kw, extra)
    if extra and extra.kw then
        for _, k in ipairs(extra.kw) do if k == kw then return true end end
    end
    return self:HasKeyword(perm, isRemote, kw) and true or false
end

function E:AISimFight(atk, atkRemote, blk, blkRemote, extra)
    local ap, at = self:GetCreatureStats(atk, atkRemote)
    local bp, bt = self:GetCreatureStats(blk, blkRemote)
    if extra then ap, at = ap + (extra.p or 0), at + (extra.t or 0) end
    at = at - (atk.damage or 0)
    bt = bt - (blk.damage or 0)
    if self.preventCombatDamage then return false, false end
    local aFirst, bFirst = HasKw(self, atk, atkRemote, "firstStrike", extra), HasKw(self, blk, blkRemote, "firstStrike")
    local aDT, bDT = HasKw(self, atk, atkRemote, "deathtouch", extra), HasKw(self, blk, blkRemote, "deathtouch")
    local toBlk = (aDT and ap > 0) and 999 or ap
    local toAtk = (bDT and bp > 0) and 999 or bp
    -- Shielded negates the one hit it takes in this fight
    if HasKw(self, blk, blkRemote, "shielded") then toBlk = 0 end
    if HasKw(self, atk, atkRemote, "shielded", extra) then toAtk = 0 end
    local atkDies, blkDies
    if aFirst and not bFirst then
        blkDies = toBlk >= bt
        atkDies = not blkDies and toAtk >= at
    elseif bFirst and not aFirst then
        atkDies = toAtk >= at
        blkDies = not atkDies and toBlk >= bt
    else
        atkDies = toAtk >= at
        blkDies = toBlk >= bt
    end
    if atkDies and atk.regenerateShield then atkDies = false end
    if blkDies and blk.regenerateShield then blkDies = false end
    return atkDies, blkDies
end

-- Can this blocker legally block this attacker?
function E:AICanBlock(atk, atkRemote, blk, blkRemote, extra)
    if not IsCreature(blk) or blk.tapped then return false end
    if HasKw(self, atk, atkRemote, "unblockable", extra) then return false end
    if HasKw(self, atk, atkRemote, "flying", extra)
        and not (self:HasKeyword(blk, blkRemote, "flying") or self:HasKeyword(blk, blkRemote, "reach")) then
        return false
    end
    return true
end

-- The opponent's creatures that could block next combat (they untap first when it is their turn)
local function PotentialBlockers(self, defenderIsRemote, assumeUntap)
    local list = {}
    for _, p in ipairs(defenderIsRemote and self.remoteState.field or self.localState.field) do
        if IsCreature(p) and (assumeUntap or not p.tapped) then table.insert(list, p) end
    end
    return list
end

-- Worst case for the attacker (the defender picks the block that is best for them):
-- value to the attacker, survives (true if it lives through every possible block)
function E:AIAttackOutcome(atk, atkRemote, blockers, extra)
    local p = self:GetCreatureStats(atk, atkRemote) + (extra and extra.p or 0)
    local atkV = self:AIPermValue(atk, atkRemote)
    local worst, survives, blockable = p, true, false
    for _, b in ipairs(blockers) do
        if self:AICanBlock(atk, atkRemote, b, not atkRemote, extra) then
            blockable = true
            local aDies, bDies = self:AISimFight(atk, atkRemote, b, not atkRemote, extra)
            local v = (bDies and self:AIPermValue(b, not atkRemote) or 0) - (aDies and atkV or 0)
            if aDies then survives = false end
            if v < worst then worst = v end
        end
    end
    return worst, survives, blockable
end

local function CanAttackNow(self, perm)
    local c = Card(perm.id)
    if not c or c.type ~= "Creature" or c.defender or perm.tapped then return false end
    if perm.sick and not self:HasKeyword(perm, true, "haste") then return false end
    return true
end

-- Whether an attacker clears the profile's bar, given the worst-case outcome
local function WorthAttacking(self, profile, worst, survives, blockable, ahead)
    if not blockable then return true end
    if profile.attack == "all" then return true end
    if profile.attack == "safe" then return survives end
    if profile.attack == "even" then return survives or worst >= 0 end
    -- aggressive: even trades always, and trading down a little while ahead on board
    return survives or worst >= 0 or (ahead and worst >= -2)
end

-- Picks the AI's attackers: list of field indices
function E:AIChooseAttackers(profile)
    local field = self.remoteState.field
    local candidates = {}
    for i, perm in ipairs(field) do
        if CanAttackNow(self, perm) then table.insert(candidates, i) end
    end
    if #candidates == 0 then return {} end
    if profile.attack == "all" then return candidates end

    local blockers = PotentialBlockers(self, false, false)
    local playerLife = self.localState.life + (self.localState.damageShield or 0)

    -- Lethal: what gets through if the player blocks the biggest attackers one each
    local powers = {}
    local total = 0
    for _, i in ipairs(candidates) do
        local p = self:GetCreatureStats(field[i], true)
        total = total + p
        local _, _, blockable = self:AIAttackOutcome(field[i], true, blockers)
        table.insert(powers, { p = p, blockable = blockable })
    end
    table.sort(powers, function(a, b) return a.p > b.p end)
    local through, blocksLeft = 0, #blockers
    for _, e in ipairs(powers) do
        if e.blockable and blocksLeft > 0 then blocksLeft = blocksLeft - 1 else through = through + e.p end
    end
    if through >= playerLife then return candidates end

    local ahead = BoardValue(self, true) > BoardValue(self, false) * 1.3
    local chosen = {}
    for _, i in ipairs(candidates) do
        local perm = field[i]
        local worst, survives, blockable = self:AIAttackOutcome(perm, true, blockers)
        if perm.id == "BOSS11" or WorthAttacking(self, profile, worst, survives, blockable, ahead) then
            table.insert(chosen, i)
        end
    end

    -- Hold back enough to survive the player's next swing
    local theirPower = {}
    for _, p in ipairs(PotentialBlockers(self, false, true)) do
        table.insert(theirPower, (self:GetCreatureStats(p, false)))
    end
    table.sort(theirPower, function(a, b) return a > b end)
    local function Incoming(defenders)
        local dmg = 0
        for k, pw in ipairs(theirPower) do
            if k > defenders then dmg = dmg + pw end
        end
        return dmg
    end
    local myLife = self.remoteState.life + (self.remoteState.damageShield or 0)
    local stayHome = 0
    local isChosen = {}
    for _, i in ipairs(chosen) do isChosen[i] = true end
    for i, perm in ipairs(field) do
        if IsCreature(perm) and (not isChosen[i] or self:HasKeyword(perm, true, "vigilance")) and not perm.tapped then
            stayHome = stayHome + 1
        end
    end
    if Incoming(stayHome) >= myLife then
        -- Keep back the attackers that defend best (most toughness), never a must-attack creature
        table.sort(chosen, function(a, b)
            local _, ta = self:GetCreatureStats(field[a], true)
            local _, tb = self:GetCreatureStats(field[b], true)
            return ta > tb
        end)
        while #chosen > 0 and Incoming(stayHome) >= myLife do
            local i = chosen[1]
            if field[i].id == "BOSS11" or self:HasKeyword(field[i], true, "vigilance") then break end
            table.remove(chosen, 1)
            stayHome = stayHome + 1
        end
    end
    table.sort(chosen)
    return chosen
end

-- Declares the chosen attackers. Returns true if combat started.
function E:AIDeclareAttack(indices)
    local attackerIndices = {}
    for _, i in ipairs(indices) do
        local perm = self.remoteState.field[i]
        local card = perm and Card(perm.id)
        if card and CanAttackNow(self, perm) then
            if not self:HasKeyword(perm, true, "vigilance") then perm.tapped = true end
            perm.isAttacking = true
            perm.hasAttackedThisTurn = true
            table.insert(attackerIndices, i)
            self:Log(L("log.aiAttacks", self.opponent, TTS:CardName(card)), "COMBAT")
            if TTS.Sound then TTS.Sound:QueueCreature("aggro", perm.id) end
            self:OnCreatureAttack(perm, true)
            if not self.inMatch then return true end
        end
    end

    if #attackerIndices == 0 then return false end
    self.blockingState = {
        attackers = attackerIndices,
        blocks = {},
        isRemoteAttacking = true,
        selectedBlocker = nil
    }
    self:SetPhase("COMBAT_BLOCK")
    self:Log(L("log.aiDeclaredAttackers"), "SYSTEM")
    self:RefreshUI()
    self:AutoPassBlocksSoon()
    return true
end

-- Our attackers blocked by several creatures (Support): the most valuable blocker the
-- damage left can still kill goes first, until none can be killed (then the rest, best first)
function E:AIOrderDamage(bs)
    bs.damageOrder = bs.damageOrder or {}
    for _, atkIdx in ipairs(bs.attackers or {}) do
        local atk = self.remoteState.field[atkIdx]
        local rest = {}
        for _, b in ipairs(self:BlockersOf(bs, atkIdx)) do
            if self.localState.field[b] then table.insert(rest, b) end
        end
        if atk and #rest > 1 then
            local left = self:GetCreatureStats(atk, true)
            local fatal = self:HasKeyword(atk, true, "deathtouch")
            local function Lethal(b)
                local perm = self.localState.field[b]
                local _, t = self:GetCreatureStats(perm, false)
                local n = math.max(0, t - (perm.damage or 0))
                return (fatal and n > 0) and 1 or n
            end
            table.sort(rest, function(a, b)
                return self:AIPermValue(self.localState.field[a], false) > self:AIPermValue(self.localState.field[b], false)
            end)
            local order = {}
            while #rest > 0 do
                local pick = 1
                for i, b in ipairs(rest) do
                    if Lethal(b) <= left then pick = i; break end
                end
                local b = table.remove(rest, pick)
                left = math.max(0, left - Lethal(b))
                table.insert(order, b)
            end
            bs.damageOrder[atkIdx] = order
        end
    end
end

-- =========================================================================
-- BLOCKING
-- For each attacker, in order: a block that kills it and survives, a trade when the
-- attacker is worth more, and a chump block only when the damage would be lethal.
-- =========================================================================
function E:AIAssignBlocks()
    if not self.blockingState or self.blockingState.isRemoteAttacking then return end
    if self.cantBlockThisTurn then return end
    local profile = self:AIProfile()
    local bs = self.blockingState

    local free = {}
    for i, perm in ipairs(self.remoteState.field) do
        if IsCreature(perm) and not perm.tapped then table.insert(free, i) end
    end

    -- A Bulwark stays free while it has room for another block
    local function Assign(blockerIdx, atkIdx)
        local b = self.remoteState.field[blockerIdx]
        self:AssignBlock(bs, blockerIdx, atkIdx, b, true)
        if not self:CanBlockMore(bs, blockerIdx, b, true) then
            for k, i in ipairs(free) do
                if i == blockerIdx then table.remove(free, k); break end
            end
        end
        local b = self.remoteState.field[blockerIdx]
        local a = self.localState.field[atkIdx]
        self:Log(L("log.oppAssignedBlock", self.opponent, Name(b), Name(a)), "COMBAT")
    end

    if profile.blocks == "greedy" then
        for _, atkIdx in ipairs(bs.attackers) do
            local atk = self.localState.field[atkIdx]
            for _, bi in ipairs(free) do
                if atk and self:AICanBlock(atk, false, self.remoteState.field[bi], true) then
                    Assign(bi, atkIdx)
                    break
                end
            end
        end
        return
    end

    -- Biggest threats first
    local attackers = {}
    for _, atkIdx in ipairs(bs.attackers) do
        if self.localState.field[atkIdx] then table.insert(attackers, atkIdx) end
    end
    table.sort(attackers, function(a, b)
        return self:AIPermValue(self.localState.field[a], false) > self:AIPermValue(self.localState.field[b], false)
    end)

    local function Damage(atkIdx)
        local atk = self.localState.field[atkIdx]
        return (self:GetCreatureStats(atk, false))
    end

    -- 1 and 2: good blocks and favourable trades
    for _, atkIdx in ipairs(attackers) do
        local atk = self.localState.field[atkIdx]
        local atkV = self:AIPermValue(atk, false)
        local bestIdx, bestScore
        for _, bi in ipairs(free) do
            local b = self.remoteState.field[bi]
            if self:AICanBlock(atk, false, b, true) then
                local aDies, bDies = self:AISimFight(atk, false, b, true)
                -- A Bulwark taking on another attacker also takes the ones it already blocks
                local incoming = 0
                for _, p in ipairs(self:BlockPairs(bs)) do
                    if p[1] == bi then incoming = incoming + Damage(p[2]) end
                end
                if incoming > 0 then
                    local _, bt = self:GetCreatureStats(b, true)
                    if (b.damage or 0) + incoming + Damage(atkIdx) >= bt then bDies = true end
                end
                local bV = self:AIPermValue(b, true)
                local score
                if aDies and not bDies then
                    score = 100 - bV               -- kill it and survive: cheapest such blocker
                elseif aDies and bDies and atkV > bV then
                    score = 50 + atkV - bV         -- a trade that comes out ahead
                elseif not aDies and not bDies and not self:HasKeyword(atk, false, "trample") then
                    score = 10 + Damage(atkIdx) * 0.1 -- a wall: soaks the damage at no cost
                end
                if score and (not bestScore or score > bestScore) then bestIdx, bestScore = bi, score end
            end
        end
        if bestIdx then Assign(bestIdx, atkIdx) end
    end

    -- 2b: Support creatures gang up on an attacker nothing kills on its own, as long as
    -- each of them lives through the fight even when the attacker deals its damage to it first
    local function Dies(plan, perm)
        local t = plan.taken[perm]
        return t and not perm.regenerateShield and (perm.damage or 0) + t >= plan.info[perm].t
    end
    for _, atkIdx in ipairs(attackers) do
        local atk = self.localState.field[atkIdx]
        if not Dies(self:PlanCombatDamage(bs), atk) then
            local helpers = {}
            for _, bi in ipairs(free) do
                local b = self.remoteState.field[bi]
                if self:HasKeyword(b, true, "support") and self:BlockCount(bs, bi) == 0
                    and self:AICanBlock(atk, false, b, true) then
                    table.insert(helpers, bi)
                end
            end
            -- Hardest hitters first, so as few as possible are needed
            table.sort(helpers, function(a, b)
                return self:GetCreatureStats(self.remoteState.field[a], true) > self:GetCreatureStats(self.remoteState.field[b], true)
            end)
            local joined, kills = {}, false
            for _, bi in ipairs(helpers) do
                self:AssignBlock(bs, bi, atkIdx, self.remoteState.field[bi], true)
                bs.damageOrder = { [atkIdx] = { bi } }
                local plan = self:PlanCombatDamage(bs)
                bs.damageOrder = nil
                if Dies(plan, self.remoteState.field[bi]) then
                    self:ClearBlock(bs, bi, atkIdx)
                else
                    table.insert(joined, bi)
                    if Dies(plan, atk) then kills = true; break end
                end
            end
            for _, bi in ipairs(joined) do
                self:ClearBlock(bs, bi, atkIdx)
                if kills then Assign(bi, atkIdx) end
            end
        end
    end

    -- 3: chump blocks while the unblocked damage would be lethal (or too much for this profile)
    local function Unblocked()
        local blocked = {}
        for _, p in ipairs(self:BlockPairs(bs)) do blocked[p[2]] = true end
        local dmg, list = 0, {}
        for _, atkIdx in ipairs(attackers) do
            if not blocked[atkIdx] then
                dmg = dmg + Damage(atkIdx)
                table.insert(list, atkIdx)
            end
        end
        return dmg, list
    end
    local life = self.remoteState.life + (self.remoteState.damageShield or 0)
    local floor = profile.chumpAtLife or 0
    local dmg, open = Unblocked()
    while #free > 0 and #open > 0 and (dmg >= life or life - dmg <= floor) do
        -- Block the biggest unblocked hit with the least valuable creature that can
        table.sort(open, function(a, b) return Damage(a) > Damage(b) end)
        local assigned = false
        for _, atkIdx in ipairs(open) do
            local atk = self.localState.field[atkIdx]
            local cheapest, cheapV
            for _, bi in ipairs(free) do
                local b = self.remoteState.field[bi]
                if self:AICanBlock(atk, false, b, true) then
                    local v = self:AIPermValue(b, true)
                    if not cheapV or v < cheapV then cheapest, cheapV = bi, v end
                end
            end
            if cheapest then
                Assign(cheapest, atkIdx)
                assigned = true
                break
            end
        end
        if not assigned then break end
        dmg, open = Unblocked()
    end
end

-- =========================================================================
-- TARGETING & EFFECT SCORING
-- An effect is scored by what it would actually do from the AI's side: killing or
-- neutralising the best enemy creature, lethal damage to the player, and so on.
-- =========================================================================
local function RemainingToughness(self, perm, isRemote)
    local _, t = self:GetCreatureStats(perm, isRemote)
    return t - (perm.damage or 0)
end

-- Score of one op on one target descriptor d = { kind, isRemote, perm }
local function ScoreOpOn(self, op, d, card, profile)
    local enemy = not d.isRemote          -- the AI is the remote side
    local life = self.remoteState.life
    if d.kind == "PLAYER" then
        local st = d.isRemote and self.remoteState or self.localState
        if op.op == "damage" then
            -- Paying life (Bloodrage, Life Tap): never with life it can't spare
            if not enemy then return (op.n >= life - 2) and -1000 or -op.n end
            local hp = st.life + (st.damageShield or 0)
            if op.n >= hp then return 1000 end
            return op.n * 0.6
        elseif op.op == "dot" then
            return enemy and op.n * op.turns * 0.4 or -op.n
        elseif op.op == "heal" or op.op == "hot" or op.op == "shield" then
            if enemy then return -1 end
            if life > 8 then return 0 end
            return (op.n * (op.turns or 1)) * 0.8
        end
        return 0
    end

    local perm = d.perm
    local v = self:AIPermValue(perm, d.isRemote)
    if op.op == "damage" then
        local n = op.n + ((op.bonusIfTapped and perm.tapped) and op.bonusIfTapped or 0)
        local kills = n >= RemainingToughness(self, perm, d.isRemote) and not perm.regenerateShield
            and not perm.shielded
        if perm.shielded then
            -- Only strips Shielded
            if enemy then return 0.5 end
            return -0.5
        end
        if enemy then return kills and v or n * 0.15 end
        return kills and -v or -n * 0.2
    elseif op.op == "destroy" then
        local c = Card(perm.id)
        if op.damaged and (perm.damage or 0) <= 0 then
            -- Execute deals its own damage first; a Shielded target soaks it and survives
            local hitsFirst = false
            for _, o in ipairs(card and card.effect and card.effect.ops or {}) do
                if o == op then break end
                if o.op == "damage" and o.to == "target" and (o.n or 0) > 0 then hitsFirst = true end
            end
            if not hitsFirst or perm.shielded then return 0 end
        end
        if op.nonColor and c and c.color == op.nonColor then return 0 end
        return enemy and v or -v
    elseif op.op == "tuck" then
        return enemy and v * 0.9 or -v
    elseif op.op == "dot" then
        -- On a creature: a lasting -0/-1 each turn
        local _, t = self:GetCreatureStats(perm, d.isRemote)
        local kills = op.turns >= t
        if enemy then return kills and v * 0.6 or op.turns * 0.4 end
        return -1
    elseif op.op == "freeze" or op.op == "tap" then
        if perm.tapped then return 0 end
        local f = (op.op == "freeze") and 0.45 or 0.3
        return enemy and v * f or -v * f
    elseif op.op == "buff" then
        local gain = (op.p or 0) + (op.t or 0)
        for _, k in ipairs(op.kw or {}) do
            -- A keyword it already has adds nothing
            if not self:HasKeyword(perm, d.isRemote, k) then gain = gain + (KEYWORD_VALUE[k] or 0.5) end
        end
        if op.perm then
            if enemy then return -gain end
            -- Lasting (Gear): on the creature worth most, as it stays as long as that one does
            return gain + v * 0.05
        end
        -- Temporary buffs are judged separately (only worth it before a fight)
        return 0
    elseif op.op == "hot" then
        -- On a creature: a lasting +0/+1 each turn
        return enemy and -(op.turns or 1) or (op.turns or 1) * 0.6
    elseif op.op == "heal" then
        if enemy then return 0 end
        return math.min(perm.damage or 0, op.n) * 0.3
    elseif op.op == "shield" then
        if op.playerOnly then return 0 end
        return enemy and 0 or op.n * 0.2
    elseif op.op == "shielded" then
        if perm.shielded then return 0 end
        return enemy and -1 or 0.4 + v * 0.15
    elseif op.op == "regen" then
        -- Soulstone: it comes back the next time it would die
        if perm.regenerateShield then return 0 end
        return enemy and -1 or 0.5 + v * 0.2
    elseif op.op == "steal" then
        if not enemy then return 0 end
        if op.maxPower and self:GetCreatureStats(perm, d.isRemote) > op.maxPower then return 0 end
        -- Until end of turn (cast before combat only, see ScoreSpell): one blocker fewer for
        -- them and one more attacker for us. For good: removal that also adds to our side.
        if op.untilEnd then return v * 0.5 + (self:GetCreatureStats(perm, d.isRemote)) * 0.5 end
        return v * 1.6
    elseif op.op == "dispel" then
        if enemy then
            -- Its lasting bonuses (Gear, Mark of the Wild...), keywords and protections
            local s = math.max(0, perm.permPower or 0) + math.max(0, perm.permToughness or 0)
            for _ in pairs(perm.permKw or {}) do s = s + 1 end
            if perm.shielded then s = s + 1 end
            if perm.regenerateShield then s = s + 1.5 end
            if perm.hots and #perm.hots > 0 then s = s + 0.5 end
            return s
        end
        -- Our own denizen: the harm it cleanses
        local s = -math.min(0, perm.permPower or 0) - math.min(0, perm.permToughness or 0)
        if perm.dots and #perm.dots > 0 then s = s + #perm.dots end
        if perm.freezeUntap then s = s + 1.5 end
        return s
    end
    return 0
end

-- What a ritual (op mana) lets the AI cast this turn that it otherwise couldn't: the value
-- of the best such denizen in hand, paying for the ritual as well (0 if none)
local function RitualValue(self, op, card)
    local pool = self.remoteState.mana
    local best = 0
    for _, id in ipairs(self.remoteState.hand) do
        local c = Card(id)
        if c and c.type == "Creature" then
            local cost = self:AICardCost(c)
            if cost ~= "" and not self:AICanAfford(cost) then
                pool[op.color] = (pool[op.color] or 0) + op.n
                local ok = self:AICanAfford(cost .. (card and card.cost or ""))
                pool[op.color] = pool[op.color] - op.n
                if ok then best = math.max(best, CreatureCardValue(self, c, true)) end
            end
        end
    end
    return best
end

-- Score of a whole effect from the AI's side with a chosen target (tgt may be nil)
function E:AIScoreEffect(eff, tgt, card, profile)
    local total = 0
    for _, op in ipairs(eff.ops or {}) do
        if op.op == "draw" then
            total = total + ((#self.remoteState.hand < 8) and 2 * op.n or 0)
        elseif op.op == "raise" then
            local best = 0
            local sources = { self.remoteState.graveyard }
            if op.src == "any" then table.insert(sources, self.localState.graveyard) end
            for _, gy in ipairs(sources) do
                for idx = #gy, 1, -1 do
                    local c = Card(gy[idx])
                    if c and c.type == "Creature" then
                        best = CreatureCardValue(self, c, true)
                        break
                    end
                end
                if best > 0 then break end
            end
            total = total + best
        elseif op.op == "mana" then
            total = total + RitualValue(self, op, card)
        elseif op.op == "token" then
            local tok = Card(op.id)
            if tok then total = total + (op.n or 1) * CreatureCardValue(self, tok, true) end
        else
            for _, d in ipairs(self:CollectSpellTargets(op.to, tgt, true, op.filter)) do
                total = total + ScoreOpOn(self, op, d, card, profile)
            end
        end
    end
    return total
end

-- Every legal target for an effect's target spec, from the AI's side
function E:AIEnumerateTargets(spec, filterFn)
    local list = {}
    if not spec then return { false } end
    for _, side in ipairs({ false, true }) do
        if self:IsValidSpellTarget(spec, "PLAYER", side, true) then
            table.insert(list, { kind = "PLAYER", isRemote = side })
        end
        local field = side and self.remoteState.field or self.localState.field
        for i, perm in ipairs(field) do
            if IsCreature(perm) and self:IsValidSpellTarget(spec, "CREATURE", side, true)
                and not self:IsHexproofAgainst(perm, side, true)
                and (not filterFn or filterFn(perm, side)) then
                table.insert(list, { kind = "CREATURE", isRemote = side, perm = perm, idx = i })
            end
        end
    end
    return list
end

-- Best target for an effect: target (false for untargeted), score
function E:AIChooseTarget(eff, card, profile)
    local bestT, bestS
    for _, tgt in ipairs(self:AIEnumerateTargets(eff.target)) do
        local s = self:AIScoreEffect(eff, tgt or nil, card, profile)
        if not bestS or s > bestS then bestT, bestS = tgt, s end
    end
    return bestT, bestS or 0
end

-- Value of a temporary buff on one of the AI's creatures: only counts if it lets that
-- creature attack (or attack safely) this turn
local function BuffAttackGain(self, perm, op, profile)
    if not CanAttackNow(self, perm) then
        -- Haste can wake up a creature that just arrived
        local grantsHaste = false
        for _, k in ipairs(op.kw or {}) do if k == "haste" then grantsHaste = true end end
        if not (grantsHaste and perm.sick and not perm.tapped) then return 0 end
    end
    local extra = { p = op.p or 0, t = op.t or 0, kw = op.kw }
    local blockers = PotentialBlockers(self, false, false)
    local ahead = BoardValue(self, true) > BoardValue(self, false) * 1.3
    local w0, s0, b0 = self:AIAttackOutcome(perm, true, blockers)
    local w1, s1, b1 = self:AIAttackOutcome(perm, true, blockers, extra)
    local before = CanAttackNow(self, perm) and WorthAttacking(self, profile, w0, s0, b0, ahead)
    local after = WorthAttacking(self, profile, w1, s1, b1, ahead)
    if after and not before then return 2 + math.max(0, w1) + (extra.p or 0) end
    if after and before and not b1 then return (op.p or 0) * 0.8 end -- more unblockable damage
    return 0
end

-- =========================================================================
-- ACTIONS
-- An action is { kind = "creature" | "spell" | "ability", handIdx | perm, card, tgt, cost, score }
-- =========================================================================
local function IsSingleTargetRemoval(card)
    if not (card.effect and card.effect.target) then return false end
    for _, op in ipairs(card.effect.ops) do
        if (op.op == "damage" or op.op == "destroy" or op.op == "tuck") and op.to == "target" then return true end
    end
    return false
end

-- The best enemy creature value on the board (for holding removal)
local function BestEnemyValue(self)
    local best = 0
    for _, p in ipairs(self.localState.field) do
        local v = self:AIPermValue(p, false)
        if v > best then best = v end
    end
    return best
end

local function ScoreSpell(self, card, profile, phase)
    local eff = card.effect
    if not eff then return nil end
    -- Temporary buffs on a friendly creature: only before combat, only if they win a fight
    local tempBuff
    for _, op in ipairs(eff.ops) do
        if op.op == "buff" and not op.perm and op.to == "target" then tempBuff = op end
        -- A denizen borrowed until end of turn is only worth it with combat still to come
        if op.op == "steal" and op.untilEnd and phase ~= 1 then return nil end
    end
    if tempBuff then
        if phase ~= 1 then return nil end
        local bestT, bestS
        for _, tgt in ipairs(self:AIEnumerateTargets(eff.target)) do
            if tgt and tgt.kind == "CREATURE" and tgt.isRemote then
                local s = BuffAttackGain(self, tgt.perm, tempBuff, profile) + self:AIScoreEffect(eff, tgt, card, profile)
                if not bestS or s > bestS then bestT, bestS = tgt, s end
            end
        end
        return bestT, bestS
    end
    -- Mass buffs for the AI's own creatures until end of turn: worth it before attacking with several
    for _, op in ipairs(eff.ops) do
        if op.op == "buff" and not op.perm and op.to == "friendly_creatures" then
            if phase ~= 1 then return nil end
            local s = 0
            for _, p in ipairs(self.remoteState.field) do
                s = s + BuffAttackGain(self, p, op, profile)
            end
            return false, s
        end
    end

    local tgt, score = self:AIChooseTarget(eff, card, profile)
    if profile.holdRemoval and IsSingleTargetRemoval(card) and tgt and tgt.kind == "CREATURE" then
        -- Expert AI keeps removal for a target close to the best the player has
        if self:AIPermValue(tgt.perm, tgt.isRemote) < BestEnemyValue(self) * 0.7 and score < 1000 then
            return nil
        end
    end
    return tgt, score
end

local ABILITY_EFFECTS = {
    BOSS01 = { target = "enemy_player", ops = { { op = "damage", to = "target", n = 2 } } },
    BOSS04 = { target = "creature", ops = { { op = "tuck", to = "target" } } },
    BOSS07 = { ops = { { op = "damage", to = "enemy_creatures", n = 1 } } },
    BOSS08 = { target = "creature", ops = { { op = "freeze", to = "target" } } },
    BOSS10 = { ops = { { op = "damage", to = "enemy_creatures", n = 1 } } },
}

local function ScoreAbility(self, perm, profile, phase)
    local ab = self:GetAbility(perm.id)
    if not ab or not self:CanActivateAbility(perm, true) then return nil end
    if ab.cost and not self:AICanAfford(ab.cost) then return nil end
    local card = Card(perm.id)

    -- A {T} ability costs this creature its attack (unless it has Vigilance): it is only
    -- used when it is worth more than the attack would be
    local attackValue = 0
    if ab.tap and phase == 1 and CanAttackNow(self, perm) and not self:HasKeyword(perm, true, "vigilance") then
        local worst, survives, blockable = self:AIAttackOutcome(perm, true, PotentialBlockers(self, false, false))
        local ahead = BoardValue(self, true) > BoardValue(self, false) * 1.3
        if WorthAttacking(self, profile, worst, survives, blockable, ahead) then
            attackValue = math.max(worst, 1)
        end
    end

    if perm.id == "BOSS21" then
        return false, ((self.remoteState.life < (self.encounter and self.encounter.life or 20)) and 3 or 0) - attackValue
    elseif perm.id == "BOSS22" then
        return false, (#self.remoteState.hand > 0) and 1.5 or 0
    end
    local eff = ABILITY_EFFECTS[perm.id]
    if not eff then return nil end
    local bestT, bestS
    for _, tgt in ipairs(self:AIEnumerateTargets(eff.target, function(p) return not ab.tapped or p.tapped end)) do
        local t = tgt or nil
        if self:IsValidAbilityTarget(perm, true, t) then
            local s = self:AIScoreEffect(eff, t, card, profile)
            if perm.id == "BOSS01" then s = s + 2 end   -- the drain also heals
            if not bestS or s > bestS then bestT, bestS = tgt, s end
        end
    end
    return bestT, bestS and (bestS - attackValue)
end

-- The best thing the AI can do with its mana right now (nil = nothing worth doing)
function E:AIChooseAction(profile, phase, skip)
    local best
    local function Consider(a)
        if a.score and a.score > 0.5 and (not best or a.score > best.score) then best = a end
    end

    for i, id in ipairs(self.remoteState.hand) do
        local c = Card(id)
        local cost = c and self:AICardCost(c)
        if c and c.type ~= "Land" and not (skip and skip[id]) and self:AICanAfford(cost) then
            if c.type == "Creature" then
                -- Haste creatures go out before combat; others whenever there is mana for them
                Consider({ kind = "creature", handIdx = i, card = c, cost = cost,
                    score = CreatureCardValue(self, c, true) + (c.haste and phase == 1 and 1 or 0) })
            elseif c.effect and profile.spells then
                local tgt, s = ScoreSpell(self, c, profile, phase)
                if s and s > 0.5 then
                    Consider({ kind = "spell", handIdx = i, card = c, cost = cost, tgt = tgt or nil, score = s + 1 })
                end
            end
        end
    end

    if profile.abilities then
        for _, perm in ipairs(self.remoteState.field) do
            local tgt, s = ScoreAbility(self, perm, profile, phase)
            if s then
                local ab = self:GetAbility(perm.id)
                Consider({ kind = "ability", perm = perm, card = Card(perm.id), cost = ab.cost, tgt = tgt or nil, score = s })
            end
        end
    end

    -- Dummy: the most expensive creature, like it always did
    if not profile.spells and best and best.kind == "creature" then
        for i, id in ipairs(self.remoteState.hand) do
            local c = Card(id)
            local cost = c and self:AICardCost(c)
            if c and c.type == "Creature" and self:AICanAfford(cost) and (c.cmc or 0) > (best.card.cmc or 0) then
                best = { kind = "creature", handIdx = i, card = c, cost = cost, score = best.score }
            end
        end
    end
    return best
end

local function TargetText(self, tgt)
    if not tgt then return "" end
    if tgt.kind == "PLAYER" then return L("log.aiTargeting", self:SideName(tgt.isRemote)) end
    return L("log.aiTargeting", "|cFFFFD200" .. Name(tgt.perm) .. "|r")
end

-- Carries out an action (its prayers are already tapped). Returns true if it happened.
function E:AIExecute(a)
    if a.kind == "creature" then
        if self.remoteState.hand[a.handIdx] ~= a.card.id or not self:PayMana(a.cost, true) then return false end
        local cardId = table.remove(self.remoteState.hand, a.handIdx)
        self.remoteState.handCount = #self.remoteState.hand
        if a.cost == "" and (a.card.cost or "") ~= "" then
            self:Log("|cFFFF4444" .. L("log.aiCastFree", self.opponent, TTS:CardName(a.card)) .. "|r", "ACTION")
        else
            self:Log(L("log.aiCastCost", self.opponent, TTS:CardName(a.card), a.card.cost or "0"), "ACTION")
        end
        self:PutCreatureOntoBattlefield(cardId, true)
        return true
    elseif a.kind == "spell" then
        if self.remoteState.hand[a.handIdx] ~= a.card.id then return false end
        -- The target may have gone while prayers were tapped
        if a.tgt and a.tgt.kind == "CREATURE" and not select(2, self:FindPerm(a.tgt.perm)) then return false end
        if not self:PayMana(a.cost, true) then return false end
        local cardId = table.remove(self.remoteState.hand, a.handIdx)
        self.remoteState.handCount = #self.remoteState.hand
        table.insert(self.remoteState.graveyard, cardId)
        self:Log(L("log.aiCast", self.opponent, TTS:CardName(a.card), TargetText(self, a.tgt)), "ACTION")
        self:PlaySpellCastSound(a.card)
        self:ResolveSpell(a.card, a.tgt, true)
        return true
    elseif a.kind == "ability" then
        if a.tgt and a.tgt.kind == "CREATURE" and not select(2, self:FindPerm(a.tgt.perm)) then return false end
        self:Log(L("log.aiActivated", self.opponent, TTS:CardName(a.card), TargetText(self, a.tgt)), "ACTION")
        return self:ActivateAbility(a.perm, true, a.tgt)
    end
    return false
end

-- =========================================================================
-- TURN
-- =========================================================================
function E:AITakeTurn()
    if not self:BeginTurn(true) then return end
    self:RefreshUI()

    local profile = self:AIProfile()

    -- The rest of the turn plays out one action at a time with a pause between each.
    -- A token stops a turn from carrying on after the match ends or a new one starts.
    local token = (self.aiTurnToken or 0) + 1
    self.aiTurnToken = token
    local function Next(step, delay)
        TTS:SafeAfter(delay or STEP_DELAY, function()
            if E.inMatch and E.isSolo and E.aiTurnToken == token then step() end
        end)
    end

    local function EndStep()
        E.aiAfterCombat = nil
        E:Log(L("log.aiPassed", E.opponent), "SYSTEM")
        E:OnRemoteEndTurn()
    end

    -- Casts (and abilities) for one main phase, best first, until nothing is worth it
    local function MainStep(phase, after, skip)
        skip = skip or {}
        local action = E:AIChooseAction(profile, phase, skip)
        -- A basic AI sometimes holds a spell it could have cast; it won't try that card again this phase
        while action and profile.spellChance and action.kind == "spell" and math.random() > profile.spellChance do
            skip[action.card.id] = true
            action = E:AIChooseAction(profile, phase, skip)
        end
        if not action then
            after()
            return
        end
        local taps, tapColor, tapPays, tapPartner = {}, {}, nil, {}
        if action.cost then taps, tapColor, tapPays, tapPartner = E:AIPlanLandTaps(action.cost) end
        local function TapNext(i)
            if i > #taps then
                if not E:AIExecute(action) then
                    after()
                    return
                end
                E:RefreshUI()
                if not E.inMatch then return end
                -- A cast spell is shown on the board for a moment: wait until it has gone
                Next(function() MainStep(phase, after, skip) end, action.kind == "spell" and SPELL_DELAY or nil)
                return
            end
            E:AITapLand(taps[i], tapColor[taps[i]], tapPartner[taps[i]])
            E:RefreshUI()
            Next(function() TapNext(i + 1) end, TAP_DELAY)
        end
        TapNext(1)
    end

    local function SecondMain()
        MainStep(2, function() Next(EndStep) end)
    end

    local function AttackStep()
        local attackers = E:AIChooseAttackers(profile)
        E.aiAfterCombat = SecondMain
        if not E:AIDeclareAttack(attackers) and E.inMatch then
            E.aiAfterCombat = nil
            Next(SecondMain)
        end
    end

    local function PrayerStep()
        local idx = E:AIChoosePrayer(profile)
        if idx then
            E:AIPlayLand(idx)
            E:RefreshUI()
            Next(function() MainStep(1, function() Next(AttackStep) end) end)
        else
            MainStep(1, function() Next(AttackStep) end)
        end
    end

    -- Store this turn's continuation so combat resolution can resume it
    self.aiResume = function(fn) Next(fn) end
    Next(PrayerStep)
end

-- Combat against the player has resolved: the AI carries on with its second main phase
function E:AIAfterCombat()
    local cont = self.aiAfterCombat
    self.aiAfterCombat = nil
    if cont and self.aiResume then
        self.aiResume(cont)
        return
    end
    TTS:SafeAfter(STEP_DELAY, function()
        if E.inMatch and E.isSolo then
            E:Log(L("log.aiPassed", E.opponent), "SYSTEM")
            E:OnRemoteEndTurn()
        end
    end)
end
