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
local L = TTS.L

-- =========================================================================
-- SMALL HELPERS
-- =========================================================================
local function IsCreaturePerm(perm)
    local c = perm and TTS.Cards[perm.id]
    return (c and c.type == "Creature") and true or false
end

-- Returns isRemote, index for a permanent on either battlefield (nil if it is gone).
function E:FindPerm(perm)
    for i, p in ipairs(self.localState.field) do
        if p == perm then return false, i end
    end
    for i, p in ipairs(self.remoteState.field) do
        if p == perm then return true, i end
    end
    return nil, nil
end

-- =========================================================================
-- ATTACHMENTS & MODIFIERS
-- =========================================================================
function E:DetachAttachments(perm, isRemotePermanent)
    if not perm or not perm.attachments or #perm.attachments == 0 then return end

    for _, att in ipairs(perm.attachments) do
        local attId = type(att) == "table" and att.id or att
        local attCard = TTS.Cards[attId]
        local isEquip = type(att) == "table" and att.isEquipment or (attCard and (attCard.type == "Equipment" or attCard.isEquipment or attCard.subType == "Equipment"))

        local isAttRemote = isRemotePermanent
        if type(att) == "table" and att.controllerIsRemote ~= nil then
            isAttRemote = att.controllerIsRemote
        end

        local controllerState = isAttRemote and self.remoteState or self.localState
        
        if isEquip then
            table.insert(controllerState.field, {
                id = attId,
                tapped = false,
                sick = false,
                damage = 0,
                tempPower = 0,
                tempToughness = 0,
                uid = time() + math.random(1000)
            })
            self:Log(L(isAttRemote and "log.equipReturnedOpp" or "log.equipReturnedYou", attCard and TTS:CardName(attCard) or attId, self.opponent or L("side.opponentCap")), "ACTION")
        else
            table.insert(controllerState.graveyard, attId)
            self:Log(L("log.enchantDestroyed", attCard and TTS:CardName(attCard) or attId, TTS.Cards[perm.id] and TTS:CardName(perm.id) or L("side.creature")), "ACTION")
        end
    end

    perm.attachments = nil
end

-- =========================================================================
-- TAGS (faction / zone / creature type) & TRIBAL EFFECTS
-- the Cards files creature fields used as tags:
--   faction = "Defias"           -> tag "faction"
--   zone = "Westfall"            -> tag "zone"
--   creatureType = "Beast"       -> tag "type"
-- Tribal abilities on a creature card:
--   anthem = { tag, value, p, t, kw } : other creatures you control with the tag get +p/+t (and keywords)
--   rally  = { tag, value, p, t }     : this creature gets +p/+t for each other creature you control with the tag
-- tag = "any" matches every creature ("other creatures you control get ...").
-- Spell ops accept filter = { tag, value } to hit only matching creatures ("each enemy Undead").
-- =========================================================================
local TAG_FIELDS = { faction = "faction", zone = "zone", type = "creatureType" }

function E:CardHasTag(card, tag, value)
    if not card then return false end
    if tag == "any" then return true end
    local field = TAG_FIELDS[tag]
    return field ~= nil and card[field] == value
end

-- Calls fn(otherCard) for every other creature on the given side of the board
local function ForEachOtherCreature(field, perm, fn)
    for _, other in ipairs(field) do
        if other ~= perm then
            local oc = TTS.Cards[other.id]
            if oc and oc.type == "Creature" then fn(oc) end
        end
    end
end

function E:HasKeyword(perm, isRemote, keyword)
    local card = TTS.Cards[perm.id]
    if not card then return end

    if keyword == "haste" then
        local allPerms = {}
        for _, p in ipairs(self.localState.field) do table.insert(allPerms, p) end
        for _, p in ipairs(self.remoteState.field) do table.insert(allPerms, p) end
        for _, p in ipairs(allPerms) do
            if p.id == "BOSS20" and p ~= perm then
                return false
            end
        end
    end

    if keyword == "vigilance" then
        local teamField = isRemote and self.remoteState.field or self.localState.field
        for _, other in ipairs(teamField) do
            if other ~= perm and other.id == "BOSS18" then
                return true
            end
        end
    end

    -- Keywords granted by tribal anthems on other creatures you control
    local granted = false
    ForEachOtherCreature(isRemote and self.remoteState.field or self.localState.field, perm, function(oc)
        local a = oc.anthem
        if a and a.kw and self:CardHasTag(card, a.tag, a.value) then
            for _, kw in ipairs(a.kw) do
                if kw == keyword then granted = true end
            end
        end
    end)
    if granted then return true end

    -- Keywords granted by spells until end of turn
    if perm.tempKw and perm.tempKw[keyword] then return true end

    return card[keyword] or false
end

function E:GetCreatureStats(perm, isRemote)
    local card = TTS.Cards[perm.id]
    if not card or card.type ~= "Creature" then return 0, 0 end

    local p = (card.power or 0) + (perm.tempPower or 0) + (perm.permPower or 0)
    local t = (card.toughness or 0) + (perm.tempToughness or 0) + (perm.permToughness or 0)

    local checkField = isRemote and self.remoteState.field or self.localState.field
    local myLife = isRemote and self.remoteState.life or self.localState.life

    for _, other in ipairs(checkField) do
        if other ~= perm then
            if other.id == "BOSS06" then
                p = p + 1
                t = t + 1
            elseif other.id == "BOSS18" then
                p = p + 1
                t = t + 1
            end
        end
    end

    if perm.id == "BOSS15" and myLife <= 10 then
        p = p + 3
    end

    -- Tribal anthems from other creatures, and this creature's own rally bonus
    local rally = card.rally
    ForEachOtherCreature(checkField, perm, function(oc)
        local a = oc.anthem
        if a and self:CardHasTag(card, a.tag, a.value) then
            p = p + (a.p or 0)
            t = t + (a.t or 0)
        end
        if rally and self:CardHasTag(oc, rally.tag, rally.value) then
            p = p + (rally.p or 0)
            t = t + (rally.t or 0)
        end
    end)

    -- Solo encounter rules (Enrage)
    if self.encounter and self.EncounterStatBonus then
        local bp, bt = self:EncounterStatBonus(perm, isRemote)
        p, t = p + bp, t + bt
    end

    return math.max(0, p), t
end

-- =========================================================================
-- SPELL EFFECTS ON CREATURES
-- Lingering spell effects remember the card that caused them (perm.spellEffects)
-- so the board can tuck that card under the creature while the effect lasts.
-- An entry stays only while the state it created is still on the creature.
-- =========================================================================
local LINGERING_OPS = { buff = true, shield = true, freeze = true, regen = true }

local function RecordSpellEffect(perm, op, card)
    local kind
    if op.op == "buff" then
        kind = op.perm and "perm" or "temp"
    elseif op.op == "shield" then
        kind = "temp"
    else
        kind = op.op
    end
    local harmful = (op.op == "freeze") or (op.op == "buff" and ((op.p or 0) < 0 or (op.t or 0) < 0))
    perm.spellEffects = perm.spellEffects or {}
    table.insert(perm.spellEffects, { id = card.id, kind = kind, harmful = harmful })
end

local function SpellEffectActive(perm, e)
    if e.kind == "freeze" then return perm.freezeUntap and true or false end
    if e.kind == "regen" then return perm.regenerateShield and true or false end
    local p, t = perm.tempPower or 0, perm.tempToughness or 0
    if e.kind == "perm" then p, t = perm.permPower or 0, perm.permToughness or 0 end
    if e.harmful then return p < 0 or t < 0 end
    return p > 0 or t > 0 or (e.kind == "temp" and perm.tempKw ~= nil)
end

-- Ids of the cards whose effects are currently on this creature (oldest first, no duplicates)
function E:GetPermEffectCards(perm)
    local ids, seen = {}, {}
    if not perm then return ids end
    local function add(id)
        if id and TTS.Cards[id] and not seen[id] then
            seen[id] = true
            table.insert(ids, id)
        end
    end
    if perm.spellEffects then
        for i = #perm.spellEffects, 1, -1 do
            if not SpellEffectActive(perm, perm.spellEffects[i]) then
                table.remove(perm.spellEffects, i)
            end
        end
        for _, e in ipairs(perm.spellEffects) do add(e.id) end
    end
    for _, e in ipairs(perm.dots or {}) do add(e.srcId) end
    for _, e in ipairs(perm.hots or {}) do add(e.srcId) end
    return ids
end

-- =========================================================================
-- STATE-BASED ACTIONS & DEATH TRIGGERS
-- =========================================================================
function E:HandleCreatureDeath(perm, isRemote)
    -- Both clients see every death and handle it by its own rules, even when the
    -- opponent's (mirrored) spell caused it
    if self.mirroring then
        self:RunMirrored(function() self:HandleCreatureDeath(perm, isRemote) end, false)
        return
    end
    local card = TTS.Cards[perm.id]
    if not card then return end

    if TTS.Sound then TTS.Sound:QueueCreature("death", perm.id) end

    self:DetachAttachments(perm, isRemote)

    if perm.id == "BOSS09" then
        self:DrawCardFor(isRemote)
        self:Log(L("log.diedDrew", TTS:CardName(card)), "ACTION")
    end

    if perm.id == "BOSS12" then
        local gy = isRemote and self.remoteState.graveyard or self.localState.graveyard
        for idx = #gy, 1, -1 do
            local resCardId = gy[idx]
            local resCard = TTS.Cards[resCardId]
            if resCard and resCard.type == "Creature" and resCardId ~= "BOSS12" then
                table.remove(gy, idx)
                self:PutCreatureOntoBattlefield(resCardId, isRemote)
                self:Log(L("log.resurrected", TTS:CardName("BOSS12"), TTS:CardName(resCard)), "ACTION")
                break
            end
        end
    end

    for _, other in ipairs(isRemote and self.localState.field or self.remoteState.field) do
        -- PvP: both clients see the death; the Baron's controller sends the damage to us
        if other.id == "BOSS25" and (isRemote or self.isSolo) then
            self:DamagePlayer(isRemote, 2, "BOSS25")
        end
    end

    for _, other in ipairs(isRemote and self.remoteState.field or self.localState.field) do
        if other.id == "BOSS24" and other ~= perm then
            self:DrawCardFor(isRemote)
            self:Log(L("log.siphonDrew", TTS:CardName("BOSS24")), "ACTION")
        end
    end

    -- Data-driven death trigger, resolved by the creature's controller
    if card.onDeath and self.inMatch then
        self:ResolveEffect(card.onDeath, card, isRemote)
    end

    if self.inMatch then
        self:RunEncounterRules("onCreatureDeath", perm, isRemote)
    end
end

-- Puts a card that left the battlefield into a graveyard, hand or library (front = on top).
-- Tokens only exist on the battlefield, so one that would go anywhere else vanishes.
function E:PutInZone(zone, cardId, front)
    local c = TTS.Cards[cardId]
    if c and c.isToken then return false end
    if front then table.insert(zone, 1, cardId) else table.insert(zone, cardId) end
    return true
end

-- Returns the first creature (isRemote, index, perm) with lethal damage, or nil
local function FindLethalCreature(self)
    for _, isRemote in ipairs({ false, true }) do
        local field = isRemote and self.remoteState.field or self.localState.field
        for i = #field, 1, -1 do
            local perm = field[i]
            if IsCreaturePerm(perm) then
                local _, effT = self:GetCreatureStats(perm, isRemote)
                if (perm.damage or 0) >= effT or effT <= 0 then
                    return isRemote, i, perm
                end
            end
        end
    end
end

-- Puts every creature with lethal damage into its graveyard, one at a time, until none are
-- left. Death triggers can kill more creatures; a call made while a check is already running
-- is picked up by the running loop instead of re-entering it.
function E:CheckStateBasedActions()
    if self.checkingSBA then return end
    self.checkingSBA = true
    while self.inMatch do
        local isRemote, i, perm = FindLethalCreature(self)
        if not perm then break end
        local card = TTS.Cards[perm.id]
        local st = isRemote and self.remoteState or self.localState
        if perm.regenerateShield then
            perm.damage = 0
            perm.tapped = true
            perm.regenerateShield = false
            if isRemote then
                self:Log(L("log.regeneratedOpp", self.opponent, TTS:CardName(card)), "ACTION")
            else
                self:Log(L("log.regenerated", TTS:CardName(card)), "ACTION")
            end
        else
            table.remove(st.field, i)
            self:PutInZone(st.graveyard, perm.id)
            if isRemote then
                self:Log(L("log.destroyedOpp", self.opponent, TTS:CardName(card)), "COMBAT")
            else
                self:Log(L("log.died", TTS:CardName(card)), "COMBAT")
            end
            self:HandleCreatureDeath(perm, isRemote)
        end
    end
    self.checkingSBA = false

    self:RefreshUI()
end

-- Destroys a creature wherever it is (used by spell effects).
function E:DestroyCreature(perm)
    local isRemote, idx = self:FindPerm(perm)
    if not idx then return end
    local st = isRemote and self.remoteState or self.localState
    table.remove(st.field, idx)
    self:PutInZone(st.graveyard, perm.id)
    local card = TTS.Cards[perm.id]
    self:Log(L("log.destroyed", card and TTS:CardName(card) or perm.id), "COMBAT")
    self:HandleCreatureDeath(perm, isRemote)
end

-- =========================================================================
-- SPELL EFFECT ENGINE
-- Every class spell carries an `effect = { target = <spec>, ops = { ... } }` table, and creature
-- cards may carry `etb`, `onAttack` and `onDeath` tables of the same shape.
-- Everything resolves from the caster's point of view (casterIsRemote): "enemy" and "friendly"
-- are relative to the caster, so the same card works for the player and for the AI.
-- =========================================================================
local SPELL_TARGET_UI = {
    enemy_creature    = "CREATURE",
    friendly_creature = "CREATURE",
    creature          = "CREATURE",
    enemy_any         = "ANY",
    friendly_any      = "ANY",
    any               = "ANY",
    enemy_player      = "PLAYER",
    player            = "PLAYER",
}

function E:GetSpellTargetType(card)
    local eff = card and card.effect
    if eff and eff.target then
        return SPELL_TARGET_UI[eff.target]
    end
    return nil
end

-- isRemote is the side the target is on; casterIsRemote the side casting
function E:IsValidSpellTarget(spec, kind, isRemote, casterIsRemote)
    local isEnemy = (isRemote and true or false) ~= (casterIsRemote and true or false)
    if spec == "enemy_creature" then return kind == "CREATURE" and isEnemy end
    if spec == "friendly_creature" then return kind == "CREATURE" and not isEnemy end
    if spec == "creature" then return kind == "CREATURE" end
    if spec == "enemy_any" then return isEnemy end
    if spec == "friendly_any" then return not isEnemy end
    if spec == "any" then return true end
    if spec == "enemy_player" then return kind == "PLAYER" and isEnemy end
    if spec == "player" then return kind == "PLAYER" end
    return false
end

-- True if the caster may not target this creature (an opponent's Hexproof creature)
function E:IsHexproofAgainst(perm, isRemote, casterIsRemote)
    if (isRemote and true or false) == (casterIsRemote and true or false) then return false end
    return self:HasKeyword(perm, isRemote, "hexproof") and true or false
end

-- Whether the player's current targeting (or the one given) would accept this target.
-- kind "PLAYER" or "CREATURE"; perm for creatures. Used to highlight what can be chosen.
function E:IsValidTargetNow(kind, isRemote, perm, targeting)
    local t = targeting or self.targeting
    if not t then return false end
    isRemote = isRemote and true or false
    if kind == "CREATURE" and not IsCreaturePerm(perm) then return false end
    if t.targetMode == "ABILITY" then
        local source = t.sourcePerm or self.localState.field[t.sourceIndex]
        if not source then return false end
        return self:IsValidAbilityTarget(source, false, { kind = kind, isRemote = isRemote, perm = perm })
    end
    local card = TTS.Cards[t.cardId]
    local spec = card and card.effect and card.effect.target
    if not spec or not self:IsValidSpellTarget(spec, kind, isRemote, false) then return false end
    if kind == "CREATURE" and self:IsHexproofAgainst(perm, isRemote, false) then return false end
    return true
end

-- Builds the list of things an op applies to: {kind="PLAYER"|"CREATURE", isRemote=bool, perm=perm}
-- filter = { tag, value } keeps only creatures with that tag.
function E:CollectSpellTargets(to, tgt, casterIsRemote, filter)
    local cr = casterIsRemote and true or false
    local list = {}
    if to == "target" then
        if tgt then list[1] = tgt end
    elseif to == "self_player" then
        list[1] = { kind = "PLAYER", isRemote = cr }
    elseif to == "enemy_player" then
        list[1] = { kind = "PLAYER", isRemote = not cr }
    else
        local function add(isRemote)
            local field = isRemote and self.remoteState.field or self.localState.field
            for _, perm in ipairs(field) do
                if IsCreaturePerm(perm) and (not filter or self:CardHasTag(TTS.Cards[perm.id], filter.tag, filter.value)) then
                    table.insert(list, { kind = "CREATURE", isRemote = isRemote, perm = perm })
                end
            end
        end
        if to == "enemy_creatures" or to == "all_creatures" then add(not cr) end
        if to == "friendly_creatures" or to == "all_creatures" then add(cr) end
    end
    return list
end

local function CreatureName(perm)
    local c = TTS.Cards[perm.id]
    return c and TTS:CardName(c) or perm.id
end

-- "you" for the player, the opponent's name for the other side
function E:SideName(isRemote)
    return isRemote and (self.opponent or L("side.opponent")) or L("side.you")
end

-- Display name for the target of an over-time effect
local function TargetName(self, d)
    if d.kind == "PLAYER" then
        return self:SideName(d.isRemote)
    end
    return "|cFFFFD200" .. CreatureName(d.perm) .. "|r"
end

local SPELL_OPS = {}

SPELL_OPS.damage = function(self, op, d, card, cr)
    local n = op.n
    if d.kind == "PLAYER" then
        self:DamagePlayer(d.isRemote, n, card.id)
    else
        if op.bonusIfTapped and d.perm.tapped then n = n + op.bonusIfTapped end
        d.perm.damage = (d.perm.damage or 0) + n
        self:Log(L("log.dealtDamage", TTS:CardName(card), n, CreatureName(d.perm)), "COMBAT")
    end
end

SPELL_OPS.heal = function(self, op, d, card, cr)
    if d.kind == "PLAYER" then
        local st = d.isRemote and self.remoteState or self.localState
        st.life = st.life + op.n
        self:Log(L("log.restoredLife", TTS:CardName(card), op.n, self:SideName(d.isRemote)), "ACTION")
    else
        d.perm.damage = math.max(0, (d.perm.damage or 0) - op.n)
        self:Log(L("log.healed", TTS:CardName(card), CreatureName(d.perm), op.n), "ACTION")
    end
end

SPELL_OPS.buff = function(self, op, d, card, cr)
    if d.kind ~= "CREATURE" then return end
    local perm = d.perm
    if op.perm then
        perm.permPower = (perm.permPower or 0) + (op.p or 0)
        perm.permToughness = (perm.permToughness or 0) + (op.t or 0)
    else
        perm.tempPower = (perm.tempPower or 0) + (op.p or 0)
        perm.tempToughness = (perm.tempToughness or 0) + (op.t or 0)
    end
    if op.kw then
        perm.tempKw = perm.tempKw or {}
        for _, kw in ipairs(op.kw) do perm.tempKw[kw] = true end
    end
    self:Log(L("log.affected", TTS:CardName(card), CreatureName(d.perm)), "ACTION")
end

SPELL_OPS.tap = function(self, op, d, card, cr)
    if d.kind ~= "CREATURE" then return end
    d.perm.tapped = true
    self:Log(L("log.wasTapped", CreatureName(d.perm)), "ACTION")
end

SPELL_OPS.freeze = function(self, op, d, card, cr)
    if d.kind ~= "CREATURE" then return end
    d.perm.tapped = true
    d.perm.freezeUntap = true
    self:Log(L("log.frozen", CreatureName(d.perm)), "ACTION")
end

SPELL_OPS.destroy = function(self, op, d, card, cr)
    if d.kind ~= "CREATURE" then return end
    local c = TTS.Cards[d.perm.id]
    if op.damaged and (d.perm.damage or 0) <= 0 then
        self:Log(L("log.fizzleUndamaged", TTS:CardName(card), CreatureName(d.perm)), "ERROR")
        return
    end
    if op.nonColor and c and c.color == op.nonColor then
        self:Log(L("log.fizzleImmune", TTS:CardName(card), CreatureName(d.perm)), "ERROR")
        return
    end
    self:DestroyCreature(d.perm)
end

SPELL_OPS.tuck = function(self, op, d, card, cr)
    if d.kind ~= "CREATURE" then return end
    local isRemote, idx = self:FindPerm(d.perm)
    if not idx then return end
    local st = isRemote and self.remoteState or self.localState
    self:DetachAttachments(d.perm, isRemote)
    table.remove(st.field, idx)
    self:PutInZone(st.deck, d.perm.id, true)
    self:Log(L("log.tucked", TTS:CardName(card), CreatureName(d.perm)), "ACTION")
end

-- Takes an enemy creature for the caster (until end of turn with untilEnd)
SPELL_OPS.steal = function(self, op, d, card, cr)
    if d.kind ~= "CREATURE" then return end
    local isRemote, idx = self:FindPerm(d.perm)
    if not idx or isRemote == cr then return end
    if op.maxPower then
        local effP = self:GetCreatureStats(d.perm, isRemote)
        if effP > op.maxPower then
            self:Log(L("log.fizzlePowerful", TTS:CardName(card), CreatureName(d.perm)), "ERROR")
            return
        end
    end
    self:GainControl(d.perm, cr, op.untilEnd)
    if op.untilEnd then
        self:Log(L("log.controlTemp", TTS:CardName(card), self:SideName(cr), CreatureName(d.perm)), "ACTION")
    else
        self:Log(L("log.control", TTS:CardName(card), self:SideName(cr), CreatureName(d.perm)), "ACTION")
    end
end

-- Mirroring an over-time effect or shield the opponent put on a player: their client ticks
-- it and sends its effects (ACTION:EFFECTS), which replace st.mirror. Shown here straight
-- away, so the tracker doesn't depend on that message arriving.
local function MirrorPlayerEffects(self, d)
    local st = d.isRemote and self.remoteState or self.localState
    st.mirror = st.mirror or { shield = 0, dots = {}, hots = {} }
    return st.mirror
end

SPELL_OPS.dot = function(self, op, d, card, cr)
    local holder = d.perm
    if d.kind == "PLAYER" then
        if self.mirroring then   -- the caster's client ticks it
            table.insert(MirrorPlayerEffects(self, d).dots, { n = op.n, turns = op.turns, src = card.id, srcId = card.id })
            return
        end
        holder = d.isRemote and self.remoteState or self.localState
    end
    holder.dots = holder.dots or {}
    table.insert(holder.dots, { n = op.n, turns = op.turns, src = card.id, srcId = card.id, byRemote = cr })
    if d.kind == "PLAYER" then
        self:Log(L("log.dot", TTS:CardName(card), TargetName(self, d), op.n, op.turns), "ACTION")
    else
        self:Log(L("log.dotCreature", TTS:CardName(card), TargetName(self, d), op.turns), "ACTION")
    end
end

SPELL_OPS.hot = function(self, op, d, card, cr)
    local holder = d.perm
    if d.kind == "PLAYER" then
        if self.mirroring then   -- the caster's client ticks it
            table.insert(MirrorPlayerEffects(self, d).hots, { n = op.n, turns = op.turns, src = card.id, srcId = card.id })
            return
        end
        holder = d.isRemote and self.remoteState or self.localState
    end
    holder.hots = holder.hots or {}
    table.insert(holder.hots, { n = op.n, turns = op.turns, src = card.id, srcId = card.id, byRemote = cr })
    if d.kind == "PLAYER" then
        self:Log(L("log.hot", TTS:CardName(card), TargetName(self, d), op.n, op.turns), "ACTION")
    else
        self:Log(L("log.hotCreature", TTS:CardName(card), TargetName(self, d), op.turns), "ACTION")
    end
end

SPELL_OPS.shield = function(self, op, d, card, cr)
    if d.kind == "PLAYER" then
        if self.mirroring then   -- the caster's client tracks it
            local m = MirrorPlayerEffects(self, d)
            m.shield = (m.shield or 0) + op.n
            return
        end
        local st = d.isRemote and self.remoteState or self.localState
        st.damageShield = (st.damageShield or 0) + op.n
        self:Log(L("log.shieldPlayer", TTS:CardName(card), op.n, self:SideName(d.isRemote)), "ACTION")
    else
        d.perm.tempToughness = (d.perm.tempToughness or 0) + op.n
        self:Log(L("log.shieldCreature", TTS:CardName(card), CreatureName(d.perm), op.n), "ACTION")
    end
end

SPELL_OPS.regen = function(self, op, d, card, cr)
    if d.kind ~= "CREATURE" then return end
    d.perm.regenerateShield = true
end

SPELL_OPS.dispel = function(self, op, d, card, cr)
    if d.kind ~= "CREATURE" then return end
    local perm = d.perm
    if d.isRemote ~= cr then
        -- strip beneficial effects from an enemy
        if (perm.tempPower or 0) > 0 then perm.tempPower = 0 end
        if (perm.tempToughness or 0) > 0 then perm.tempToughness = 0 end
        if (perm.permPower or 0) > 0 then perm.permPower = 0 end
        if (perm.permToughness or 0) > 0 then perm.permToughness = 0 end
        perm.tempKw = nil
        perm.regenerateShield = nil
        perm.hots = nil
    else
        -- cleanse harmful effects from our own creature
        if (perm.tempPower or 0) < 0 then perm.tempPower = 0 end
        if (perm.tempToughness or 0) < 0 then perm.tempToughness = 0 end
        if (perm.permPower or 0) < 0 then perm.permPower = 0 end
        if (perm.permToughness or 0) < 0 then perm.permToughness = 0 end
        perm.dots = nil
        perm.freezeUntap = nil
    end
    self:Log(L("log.dispelled", TTS:CardName(card), CreatureName(perm)), "ACTION")
end

-- Effects that do not iterate over targets; they act for the caster
local SPELL_GLOBAL_OPS = {}

SPELL_GLOBAL_OPS.draw = function(self, op, card, cr)
    for _ = 1, op.n do
        if not self.inMatch then break end
        self:DrawCardFor(cr)
    end
end

SPELL_GLOBAL_OPS.mana = function(self, op, card, cr)
    local pool = (cr and self.remoteState or self.localState).mana
    pool[op.color] = (pool[op.color] or 0) + op.n
    self:Log(L(cr and "log.manaAddedOpp" or "log.manaAddedYou", TTS:CardName(card), op.n, op.color, self.opponent or L("side.opponent")), "MANA")
end

SPELL_GLOBAL_OPS.raise = function(self, op, card, cr)
    local sources = { cr and self.remoteState.graveyard or self.localState.graveyard }
    if op.src == "any" then table.insert(sources, cr and self.localState.graveyard or self.remoteState.graveyard) end
    for _, gy in ipairs(sources) do
        for idx = #gy, 1, -1 do
            local c = TTS.Cards[gy[idx]]
            if c and c.type == "Creature" then
                local cId = table.remove(gy, idx)
                self:Log(L(cr and "log.reanimatedOpp" or "log.reanimatedYou", TTS:CardName(card), TTS:CardName(c), self.opponent or L("side.opponent")), "ACTION")
                self:PutCreatureOntoBattlefield(cId, cr)
                return
            end
        end
    end
    self:Log(L("log.reanimateNone", TTS:CardName(card)), "ERROR")
end

-- Creates op.n (default 1) copies of the token card op.id on the caster's battlefield
SPELL_GLOBAL_OPS.token = function(self, op, card, cr)
    local tok = TTS.Cards[op.id]
    if not tok then return end
    for _ = 1, op.n or 1 do
        if not self.inMatch then break end
        self:PutCreatureOntoBattlefield(op.id, cr)
    end
    self:Log(L(cr and "log.tokensOpp" or "log.tokensYou", TTS:CardName(card), op.n or 1, TTS:CardName(tok), self.opponent or L("side.opponent")), "ACTION")
end

function E:ApplySpellOp(op, tgt, card, casterIsRemote)
    local cr = casterIsRemote and true or false
    local global = SPELL_GLOBAL_OPS[op.op]
    if global then
        global(self, op, card, cr)
        return
    end
    local handler = SPELL_OPS[op.op]
    if not handler then return end
    for _, d in ipairs(self:CollectSpellTargets(op.to, tgt, cr, op.filter)) do
        if not self.inMatch then return end
        handler(self, op, d, card, cr)
        if d.kind == "CREATURE" and d.perm and LINGERING_OPS[op.op] then
            RecordSpellEffect(d.perm, op, card)
        end
    end
end

-- Runs fn while mirroring the PvP opponent's own play. Both clients resolve every effect, but
-- what the opponent's client already tells us about is skipped here: damage to us (it sends
-- ACTION:DAMAGE) and the over-time effects and shields on players (it sends ACTION:EFFECTS).
-- mirror = false runs fn as our own play (an effect of ours triggered inside a mirrored one).
function E:RunMirrored(fn, mirror)
    local was = self.mirroring
    self.mirroring = (mirror ~= false)
    local ok, err = pcall(fn)
    self.mirroring = was
    if not ok then geterrorhandler()(err) end
end

-- Resolves an effect table ({ target, ops }) for the caster, then checks for deaths
function E:ResolveEffect(eff, card, casterIsRemote, tgt)
    if eff and eff.ops then
        self:RunMirrored(function()
            for _, op in ipairs(eff.ops) do
                if not self.inMatch then break end
                self:ApplySpellOp(op, tgt, card, casterIsRemote)
            end
        end, (casterIsRemote and not self.isSolo) and true or false)
    end
    if not self.inMatch then return end
    self:SyncEffects()
    self:CheckStateBasedActions()
end

function E:ResolveSpell(card, tgt, casterIsRemote)
    if casterIsRemote then
        self:Log(L("log.resolvedOpp", self.opponent or L("side.opponentCap"), TTS.Locale:Term("type", card.type), TTS:CardName(card)), "ACTION")
    else
        self:Log(L("log.resolved", TTS.Locale:Term("type", card.type), TTS:CardName(card)), "ACTION")
    end
    self:ResolveEffect(card.effect, card, casterIsRemote, tgt)
end

-- Damage / healing over time. Each effect ticks at the start of its caster's turn
-- (byRemote = cast by the opponent / AI).
local function TickList(list, isRemoteTurn, apply)
    if not list then return end
    for i = #list, 1, -1 do
        local e = list[i]
        if (e.byRemote or false) == isRemoteTurn then
            apply(e)
            e.turns = e.turns - 1
            if e.turns <= 0 then table.remove(list, i) end
        end
    end
end

function E:TickOverTime(isRemoteTurn)
    isRemoteTurn = isRemoteTurn and true or false
    for _, isRemote in ipairs({ false, true }) do
        local st = isRemote and self.remoteState or self.localState
        TickList(st.hots, isRemoteTurn, function(e)
            st.life = st.life + e.n
            self:Log(L("log.restoredLife", TTS:ReasonText(e.src), e.n, self:SideName(isRemote)), "ACTION")
            -- PvP: only the client that cast it ticks it, so tell the other one
            if not self.isSolo then
                TTS.Net:Send(self.opponent, string.format("ACTION:HEAL:%d:%s:%s", e.n, isRemote and "THEIRS" or "MINE", e.src or ""))
            end
        end)
        TickList(st.dots, isRemoteTurn, function(e)
            if self.inMatch then self:DamagePlayer(isRemote, e.n, e.src) end
        end)
        for _, perm in ipairs(st.field) do
            if IsCreaturePerm(perm) then
                -- Damage on creatures wears off each turn, so on a creature each tick is a
                -- lasting +0/+1 (healing) or -0/-1 (damage) instead
                TickList(perm.hots, isRemoteTurn, function(e)
                    perm.permToughness = (perm.permToughness or 0) + 1
                    self:Log(L("log.hotToughness", TTS:ReasonText(e.src), CreatureName(perm)), "ACTION")
                end)
                TickList(perm.dots, isRemoteTurn, function(e)
                    perm.permToughness = (perm.permToughness or 0) - 1
                    self:Log(L("log.dotToughness", TTS:ReasonText(e.src), CreatureName(perm)), "COMBAT")
                end)
            end
        end
    end
    if self.inMatch then
        self:SyncEffects()
        self:CheckStateBasedActions()
    end
end

-- =========================================================================
-- CREATURES ENTERING, CHANGING CONTROL, ATTACKING
-- =========================================================================
function E:NewUid()
    self.uidCounter = (self.uidCounter or (time() * 100)) + 1
    return self.uidCounter
end

-- A fresh battlefield entry for a creature card
function E:NewCreaturePerm(cardId, isRemote)
    return {
        id = cardId,
        tapped = false,
        sick = not self:HasKeyword({ id = cardId }, isRemote, "haste"),
        damage = 0,
        tempPower = 0,
        tempToughness = 0,
        uid = self:NewUid()
    }
end

-- Puts a creature card onto a side's battlefield (not cast: no mana, no network message)
-- and fires its enter trigger. Returns the new permanent.
function E:PutCreatureOntoBattlefield(cardId, isRemote, opts)
    local perm = self:NewCreaturePerm(cardId, isRemote)
    if opts and opts.ready then perm.sick = false end
    table.insert((isRemote and self.remoteState or self.localState).field, perm)
    if TTS.Sound then TTS.Sound:QueueCreature("aggro", cardId) end
    self:OnCreatureEnter(perm, isRemote)
    return perm
end

-- Moves a creature to newControllerIsRemote's battlefield. untilEnd returns it at the end
-- of that controller's turn (see EndTurnCleanup).
function E:GainControl(perm, newControllerIsRemote, untilEnd)
    local fromRemote, idx = self:FindPerm(perm)
    if not idx then return end
    local from = fromRemote and self.remoteState.field or self.localState.field
    table.remove(from, idx)
    perm.tapped = false
    perm.isAttacking = nil
    if untilEnd then
        perm.sick = false
        table.insert(self.stolenCreatures, { perm = perm, isRemoteOwner = fromRemote, controllerIsRemote = newControllerIsRemote })
    else
        perm.sick = true
    end
    table.insert((newControllerIsRemote and self.remoteState or self.localState).field, perm)
end

-- The opposing creature an automatic trigger picks: the highest power one that passes `ok`
local function BestEnemyCreature(self, isRemote, ok)
    local best, bestP
    for _, p in ipairs(isRemote and self.localState.field or self.remoteState.field) do
        if IsCreaturePerm(p) and not self:IsHexproofAgainst(p, not isRemote, isRemote) and (not ok or ok(p)) then
            local pw = self:GetCreatureStats(p, not isRemote)
            if not bestP or pw > bestP then best, bestP = p, pw end
        end
    end
    return best
end

-- Enter-the-battlefield triggers for either side
function E:OnCreatureEnter(perm, isRemote)
    local card = TTS.Cards[perm.id]
    if not card then return end

    if perm.id == "BOSS19" then
        for _, oppPerm in ipairs(isRemote and self.localState.field or self.remoteState.field) do
            if IsCreaturePerm(oppPerm) then
                oppPerm.damage = (oppPerm.damage or 0) + 3
            end
        end
        self:Log(L("log.boss.wyrmthalak", TTS:CardName(perm.id)), "COMBAT")
        self:CheckStateBasedActions()
    elseif perm.id == "BOSS26" then
        local target = BestEnemyCreature(self, isRemote, function(p)
            return (self:GetCreatureStats(p, not isRemote)) <= 4
        end)
        if target then
            self:GainControl(target, isRemote, false)
            self:Log(L("log.boss.stole", TTS:CardName(perm.id), CreatureName(target)), "ACTION")
        end
    end

    if card.etb and self.inMatch then
        self:ResolveEffect(card.etb, card, isRemote)
    end
end

-- Attack triggers for either side (the creature has just been declared as an attacker)
function E:OnCreatureAttack(perm, isRemote)
    local card = TTS.Cards[perm.id]
    if not card then return end

    if perm.id == "BOSS03" then
        self:DiscardRandom(not isRemote)
        self:DamagePlayer(not isRemote, 1, "BOSS03")
        self:Log(L("log.boss.mutanus", TTS:CardName(perm.id)), "ACTION")
    elseif perm.id == "BOSS13" then
        local target = BestEnemyCreature(self, isRemote, function(p) return not p.tapped end)
        if target then
            target.tapped = true
            target.freezeUntap = true
            self:Log(L("log.boss.amnennar", TTS:CardName(perm.id), CreatureName(target)), "ACTION")
        end
    elseif perm.id == "BOSS23" then
        perm.tempPower = (perm.tempPower or 0) + 2
        self:Log(L("log.boss.gordok", TTS:CardName(perm.id)), "ACTION")
    end

    if card.onAttack and self.inMatch then
        self:ResolveEffect(card.onAttack, card, isRemote)
    end
end

-- =========================================================================
-- ACTIVATED ABILITIES
-- target: what the ability needs ("enemy_player", "creature"); tapped = target must be tapped;
-- tap = costs {T}; cost = mana paid from the controller's pool.
-- =========================================================================
local ABILITIES = {
    BOSS01 = { tap = true, target = "enemy_player" },
    BOSS04 = { tap = true, target = "creature", tapped = true },
    BOSS07 = { tap = true },
    BOSS08 = { tap = true, target = "creature" },
    BOSS10 = { tap = true },
    BOSS21 = { tap = true },
    BOSS22 = { cost = "{2}{U}" },
}

function E:GetAbility(cardId)
    return ABILITIES[cardId]
end

-- True if the permanent's controller may use its ability right now (ignores mana for cost abilities)
function E:CanActivateAbility(perm, isRemote)
    local ab = perm and ABILITIES[perm.id]
    if not ab then return false end
    if ab.tap then
        if perm.tapped then return false end
        if perm.sick and not self:HasKeyword(perm, isRemote, "haste") then return false end
    end
    return true
end

-- Whether tgt ({ kind, isRemote, perm }) is a legal target for the ability
function E:IsValidAbilityTarget(perm, isRemote, tgt)
    local ab = ABILITIES[perm.id]
    if not ab or not ab.target then return tgt == nil end
    if not tgt then return false end
    if not self:IsValidSpellTarget(ab.target, tgt.kind, tgt.isRemote, isRemote) then return false end
    if tgt.kind == "CREATURE" then
        if not IsCreaturePerm(tgt.perm) then return false end
        if self:IsHexproofAgainst(tgt.perm, tgt.isRemote, isRemote) then return false end
        if ab.tapped and not tgt.perm.tapped then return false end
    end
    return true
end

-- Uses a creature's activated ability for either side. Returns true if it resolved.
function E:ActivateAbility(perm, isRemote, tgt)
    local ab = ABILITIES[perm.id]
    if not ab or not self:CanActivateAbility(perm, isRemote) then return false end
    if not self:IsValidAbilityTarget(perm, isRemote, tgt) then return false end
    -- A mirrored PvP ability was paid for on their client (we don't track their mana pool)
    if ab.cost and not (isRemote and self.mirroring) and not self:PayMana(ab.cost, isRemote) then return false end
    if ab.tap then perm.tapped = true end
    -- An ability used after a card was played locks that play in (no undo past it)
    if not isRemote then self:LockInPlays() end

    -- PvP: sent before resolving, like a spell. ABILITY:<source field index>, then
    -- optionally <PLAYER|CREATURE>:<MINE|THEIRS from our side>:<target field index>
    if not isRemote and not self.isSolo then
        local _, srcIdx = self:FindPerm(perm)
        local msg = "ACTION:ABILITY:" .. (srcIdx or 0)
        if tgt then
            local tIdx
            if tgt.perm then _, tIdx = self:FindPerm(tgt.perm) end
            msg = msg .. string.format(":%s:%s:%d", tgt.kind, tgt.isRemote and "THEIRS" or "MINE", tIdx or 0)
        end
        TTS.Net:Send(self.opponent, msg)
    end

    local st = isRemote and self.remoteState or self.localState
    local id = perm.id
    if id == "BOSS01" then
        self:DamagePlayer(tgt.isRemote, 2, "BOSS01")
        st.life = st.life + 2
        self:Log(L("log.boss.drain", TTS:CardName(id)), "ACTION")

    elseif id == "BOSS04" then
        local targetRemote, idx = self:FindPerm(tgt.perm)
        if idx then
            self:DetachAttachments(tgt.perm, targetRemote)
            table.remove((targetRemote and self.remoteState or self.localState).field, idx)
            self:PutInZone((targetRemote and self.remoteState or self.localState).deck, tgt.perm.id, true)
            self:Log(L("log.boss.arugal", TTS:CardName(id)), "ACTION")
        end

    elseif id == "BOSS07" or id == "BOSS10" then
        for _, p in ipairs(isRemote and self.localState.field or self.remoteState.field) do
            if IsCreaturePerm(p) then
                p.damage = (p.damage or 0) + 2
            end
        end
        self:Log(L("log.boss.sweep", CreatureName(perm)), "COMBAT")
        self:CheckStateBasedActions()

    elseif id == "BOSS08" then
        tgt.perm.tapped = true
        tgt.perm.freezeUntap = true
        self:Log(L("log.boss.charlga", TTS:CardName(id)), "ACTION")

    elseif id == "BOSS21" then
        st.life = st.life + 4
        self:Log(L("log.boss.alzzin", TTS:CardName(id)), "ACTION")

    elseif id == "BOSS22" then
        self:DrawCardFor(isRemote)
        self:DiscardRandom(isRemote)
        perm.tempPower = (perm.tempPower or 0) + 1
        perm.tempToughness = (perm.tempToughness or 0) + 1
        self:Log(L("log.boss.tortheldrin", TTS:CardName(id)), "ACTION")
    end

    self:RefreshUI()
    return true
end

-- =========================================================================
-- PLAYER EFFECT TRACKING
-- Each client ticks the over-time effects it created (st.dots / st.hots / st.damageShield).
-- Those are sent to the opponent as a snapshot so both boards can display every effect;
-- the opponent's copy is kept in st.mirror and is display-only (never ticked).
-- Wire format: ACTION:EFFECTS:<sender's own side>:<sender's opponent side>
--   side = <shield>;<D|H>,<amount>,<turns>,<cardId>;...
-- =========================================================================
local function EncodeEffects(st)
    local parts = { tostring(st.damageShield or 0) }
    for _, e in ipairs(st.dots or {}) do
        table.insert(parts, string.format("D,%d,%d,%s", e.n, e.turns, e.srcId or "?"))
    end
    for _, e in ipairs(st.hots or {}) do
        table.insert(parts, string.format("H,%d,%d,%s", e.n, e.turns, e.srcId or "?"))
    end
    return table.concat(parts, ";")
end

local function DecodeEffects(str)
    local mirror = { shield = 0, dots = {}, hots = {} }
    if not str or str == "" then return mirror end
    local entries = { strsplit(";", str) }
    mirror.shield = tonumber(entries[1]) or 0
    for i = 2, #entries do
        local kind, n, turns, srcId = strsplit(",", entries[i])
        n, turns = tonumber(n), tonumber(turns)
        if n and turns then
            local c = srcId and TTS.Cards[srcId]
            local e = { n = n, turns = turns, srcId = srcId, src = c and srcId or L("log.unknown") }
            if kind == "D" then table.insert(mirror.dots, e)
            elseif kind == "H" then table.insert(mirror.hots, e) end
        end
    end
    return mirror
end

function E:SyncEffects()
    if self.isSolo or not self.inMatch or not self.opponent then return end
    local payload = EncodeEffects(self.localState) .. ":" .. EncodeEffects(self.remoteState)
    -- Only when something changed (StartMatch clears it), to save the addon-message budget
    if payload == self.sentEffects then return end
    self.sentEffects = payload
    TTS.Net:Send(self.opponent, "ACTION:EFFECTS:" .. payload)
end

-- theirSide = effects the opponent tracks on themselves, mySide = effects they track on us
function E:ReceiveEffects(theirSide, mySide)
    self.remoteState.mirror = DecodeEffects(theirSide)
    self.localState.mirror = DecodeEffects(mySide)
    self:RefreshUI()
end

-- Every effect currently on a player: { kind = "dot"|"hot"|"shield", n, turns, srcId, src }
function E:GetPlayerEffects(isRemote)
    local st = isRemote and self.remoteState or self.localState
    local list = {}
    local function addFrom(shield, dots, hots)
        if (shield or 0) > 0 then
            table.insert(list, { kind = "shield", n = shield })
        end
        for _, e in ipairs(dots or {}) do
            table.insert(list, { kind = "dot", n = e.n, turns = e.turns, srcId = e.srcId, src = e.src })
        end
        for _, e in ipairs(hots or {}) do
            table.insert(list, { kind = "hot", n = e.n, turns = e.turns, srcId = e.srcId, src = e.src })
        end
    end
    addFrom(st.damageShield, st.dots, st.hots)
    if st.mirror then
        addFrom(st.mirror.shield, st.mirror.dots, st.mirror.hots)
    end
    return list
end

-- =========================================================================
-- PLAYING CARDS
-- =========================================================================

-- Sound for a prayer or attachment being played by either side.
-- Creatures play their own aggro sound instead. Respects the board's Sounds checkbox.
function E:PlayNonCreatureCardSound()
    if TTS.Sound and TTS.Sound.enabled then
        pcall(PlaySound, 829, "SFX")
    end
end


function E:PlaySpellCastSound()
    if not (TTS.Sound and TTS.Sound.enabled) then return end
    pcall(PlaySound, 1430, "SFX")
end

function E:PlayCard(handIndex)
    -- Hand is full and a draw is waiting: clicking a card discards it instead
    if self.pendingDiscard then
        self:DiscardForDraw(handIndex)
        return
    end

    if not self.isMyTurn then
        self:Log(L("err.notYourTurnPlay"), "ERROR")
        return
    end
    if self:UndoBlocksAction() then return end

    local cardId = self.localState.hand[handIndex]
    local card = TTS.Cards and TTS.Cards[cardId]
    if not card then return end

    if card.type == "Land" then
        if self.landPlayedThisTurn then
            self:Log(L("err.onePrayer"), "ERROR")
            return
        end
        if self.phase ~= "MAIN1" and self.phase ~= "MAIN2" then
            self:Log(L("err.prayerMainPhase"), "ERROR")
            return
        end

        local undoSnap = self:BeginUndoablePlay()
        table.remove(self.localState.hand, handIndex)
        table.insert(self.localState.field, { id = cardId, tapped = false, uid = time() + handIndex })
        self.landPlayedThisTurn = true
        self:Log(L("log.playedPrayer", TTS:CardName(card)), "ACTION")
        self:PlayNonCreatureCardSound()

        if not self.isSolo then TTS.Net:Send(self.opponent, "ACTION:PLAY_LAND:" .. cardId) end
        self:CommitUndoablePlay(undoSnap, cardId)
        self:RefreshUI()
        return
    end

    local targetType = self:GetSpellTargetType(card)
    if targetType then
        if (self.phase ~= "MAIN1" and self.phase ~= "MAIN2") then
            self:Log(L("err.castMainPhase"), "ERROR")
            return
        end

        if not self:CanPayManaAuto(card.cost) then
            self:Log(L("err.manaCast", TTS:CardName(card), card.cost), "ERROR")
            return
        end

        self.targeting = {
            targetMode = "SPELL",
            cardId = cardId,
            handIndex = handIndex,
            targetType = targetType,
            cardName = TTS:CardName(card)
        }
        self:Log(L("log.selectTarget", TTS:CardName(card)) .. " " .. L("log.cancelHint"), "SYSTEM")
        self:RefreshUI()
        return
    end

    if card.type == "Creature" then
        if self.phase ~= "MAIN1" and self.phase ~= "MAIN2" then
            self:Log(L("err.permanentMainPhase"), "ERROR")
            return
        end
        self:AutoPayMana(card.cost)
        local undoSnap = self:BeginUndoablePlay()
        if not self:PayMana(card.cost) then
            self:Log(L("err.manaPool"), "ERROR")
            return
        end

        table.remove(self.localState.hand, handIndex)
        self:Log(L("log.cast", TTS.Locale:Term("type", card.type), TTS:CardName(card)), "ACTION")
        -- Tell the opponent before enter triggers run, so the creature is on their board first
        if not self.isSolo then TTS.Net:Send(self.opponent, "ACTION:PLAY_PERM:" .. cardId) end
        self:PutCreatureOntoBattlefield(cardId, false)
        self:CommitUndoablePlay(undoSnap, cardId)

    elseif card.type == "Sorcery" then
        if self.phase ~= "MAIN1" and self.phase ~= "MAIN2" then
            self:Log(L("err.sorceryMainPhase"), "ERROR")
            return
        end
        self:AutoPayMana(card.cost)
        local undoSnap = self:BeginUndoablePlay()
        if not self:PayMana(card.cost) then
            self:Log(L("err.manaPool"), "ERROR")
            return
        end

        table.remove(self.localState.hand, handIndex)
        table.insert(self.localState.graveyard, cardId)
        self:PlaySpellCastSound()
        -- Sent before resolving, so the opponent sees the card before the damage it causes
        if not self.isSolo then TTS.Net:Send(self.opponent, "ACTION:CAST_SPELL:" .. cardId) end
        self:ResolveSpell(card, nil)
        self:CommitUndoablePlay(undoSnap, cardId)
    end

    self:RefreshUI()
end

function E:ResolveAbilityTarget(targetKind, isRemote, fieldIndex)
    if not self.targeting or self.targeting.targetMode ~= "ABILITY" then return end
    local sourceIdx = self.targeting.sourceIndex
    local sourcePerm = self.localState.field[sourceIdx]
    if not sourcePerm then
        self.targeting = nil
        self:RefreshUI()
        return
    end

    isRemote = isRemote and true or false
    local tgt
    if targetKind == "PLAYER" then
        tgt = { kind = "PLAYER", isRemote = isRemote }
    else
        local perm = fieldIndex and (isRemote and self.remoteState.field or self.localState.field)[fieldIndex]
        if not perm or not IsCreaturePerm(perm) then
            self:Log(L("err.invalidTarget"), "ERROR")
            return
        end
        tgt = { kind = "CREATURE", isRemote = isRemote, perm = perm, idx = fieldIndex }
    end

    if tgt.kind == "CREATURE" and self:IsHexproofAgainst(tgt.perm, tgt.isRemote, false) then
        self:Log(L("err.warded", CreatureName(tgt.perm)), "ERROR")
        return
    end

    if not self:IsValidAbilityTarget(sourcePerm, false, tgt) then
        local ab = self:GetAbility(sourcePerm.id)
        if ab and ab.tapped then
            self:Log(L("err.onlyTapped", CreatureName(sourcePerm)), "ERROR")
        else
            self:Log(L("err.cannotTarget", CreatureName(sourcePerm)) .. " " .. L("log.cancelHint"), "ERROR")
        end
        return
    end

    self.targeting = nil
    local ab = self:GetAbility(sourcePerm.id)
    if ab and ab.cost then self:AutoPayMana(ab.cost) end
    self:ActivateAbility(sourcePerm, false, tgt)
    self:RefreshUI()
end

function E:ResolveTarget(targetKind, isRemote, fieldIndex)
    if not self.targeting then return end

    if self.targeting.targetMode == "ABILITY" then
        self:ResolveAbilityTarget(targetKind, isRemote, fieldIndex)
        return
    end

    local cardId = self.targeting.cardId
    local handIndex = self.targeting.handIndex
    local card = TTS.Cards[cardId]
    local eff = card and card.effect
    if not eff then
        self.targeting = nil
        self:RefreshUI()
        return
    end

    isRemote = isRemote and true or false

    -- Build the target descriptor
    local tgt
    if targetKind == "PLAYER" then
        tgt = { kind = "PLAYER", isRemote = isRemote }
    else
        local field = isRemote and self.remoteState.field or self.localState.field
        local perm = fieldIndex and field[fieldIndex]
        if not perm or not IsCreaturePerm(perm) then
            self:Log(L("err.invalidTarget"), "ERROR")
            return
        end
        tgt = { kind = "CREATURE", isRemote = isRemote, perm = perm, idx = fieldIndex }
    end

    if not self:IsValidSpellTarget(eff.target, tgt.kind, tgt.isRemote, false) then
        self:Log(L("err.cannotTarget", TTS:CardName(card)) .. " " .. L("log.cancelHint"), "ERROR")
        return
    end

    if tgt.kind == "CREATURE" and self:IsHexproofAgainst(tgt.perm, tgt.isRemote, false) then
        self:Log(L("err.warded", TTS:CardName(tgt.perm.id)), "ERROR")
        return
    end

    self:AutoPayMana(card.cost)
    local undoSnap = self:BeginUndoablePlay()
    if not self:PayMana(card.cost) then
        self:Log(L("err.payFailed"), "ERROR")
        self.targeting = nil
        self:RefreshUI()
        return
    end

    self.targeting = nil
    table.remove(self.localState.hand, handIndex)
    table.insert(self.localState.graveyard, cardId)
    self:PlaySpellCastSound()
    -- Sent before resolving, so the opponent sees the card and its target before the damage
    -- it causes. Target: PLAYER or CREATURE, MINE/THEIRS from our side, and its field index.
    if not self.isSolo then
        TTS.Net:Send(self.opponent, string.format("ACTION:CAST_SPELL:%s:%s:%s:%d", cardId, tgt.kind,
            tgt.isRemote and "THEIRS" or "MINE", tgt.idx or 0))
    end
    self:ResolveSpell(card, tgt)
    self:CommitUndoablePlay(undoSnap, cardId)
    self:RefreshUI()
end

-- =========================================================================
-- BATTLEFIELD ACTIVATIONS & ATTACKS
-- =========================================================================
-- =========================================================================
-- BLOCKS
-- bs.blocks[blockerIdx] = attackerIdx holds each blocker's (first) block. A Bulwark X
-- creature (bulwark = X) can block up to X attackers: the ones after the first are listed
-- in bs.moreBlocks[blockerIdx]. Each attacker is blocked by at most one creature.
-- =========================================================================

-- How many attackers a creature can block at once
function E:MaxBlocks(perm, isRemote)
    local v = perm and self:HasKeyword(perm, isRemote, "bulwark")
    if type(v) == "number" then return math.max(1, v) end
    return v and 2 or 1
end

-- Every block as { blocker, attacker } pairs, first blocks before the rest
function E:BlockPairs(bs)
    local list = {}
    if not bs then return list end
    for b, a in pairs(bs.blocks or {}) do table.insert(list, { b, a }) end
    for b, more in pairs(bs.moreBlocks or {}) do
        for _, a in ipairs(more) do table.insert(list, { b, a }) end
    end
    return list
end

-- How many attackers a creature is blocking
function E:BlockCount(bs, blockerIdx)
    if not bs.blocks[blockerIdx] then return 0 end
    return 1 + #((bs.moreBlocks and bs.moreBlocks[blockerIdx]) or {})
end

-- The creature blocking an attacker, or nil
function E:BlockerOf(bs, atkIdx)
    for _, p in ipairs(self:BlockPairs(bs)) do
        if p[2] == atkIdx then return p[1] end
    end
end

-- Takes back every block a creature has
function E:ClearBlocks(bs, blockerIdx)
    bs.blocks[blockerIdx] = nil
    if bs.moreBlocks then bs.moreBlocks[blockerIdx] = nil end
end

-- Takes back whatever block is on an attacker; a Bulwark's next block moves up to first
function E:ClearBlockOn(bs, atkIdx)
    local b = self:BlockerOf(bs, atkIdx)
    if not b then return end
    local more = bs.moreBlocks and bs.moreBlocks[b]
    if bs.blocks[b] == atkIdx then
        bs.blocks[b] = more and table.remove(more, 1)
    else
        for i, a in ipairs(more) do
            if a == atkIdx then table.remove(more, i); break end
        end
    end
    if more and #more == 0 then bs.moreBlocks[b] = nil end
    return b
end

-- Whether a creature that already blocks can take on another attacker
function E:CanBlockMore(bs, blockerIdx, perm, isRemote)
    local n = self:BlockCount(bs, blockerIdx)
    return n > 0 and n < self:MaxBlocks(perm, isRemote)
end

-- Assigns a block: a Bulwark with room left blocks this attacker as well, any other
-- creature moves its (last) block. Returns false if it was already blocking it.
function E:AssignBlock(bs, blockerIdx, atkIdx, perm, isRemote)
    for _, p in ipairs(self:BlockPairs(bs)) do
        if p[1] == blockerIdx and p[2] == atkIdx then return false end
    end
    local more = bs.moreBlocks and bs.moreBlocks[blockerIdx]
    if self:CanBlockMore(bs, blockerIdx, perm, isRemote) then
        bs.moreBlocks = bs.moreBlocks or {}
        bs.moreBlocks[blockerIdx] = more or {}
        table.insert(bs.moreBlocks[blockerIdx], atkIdx)
    elseif more and #more > 0 then
        more[#more] = atkIdx
    else
        bs.blocks[blockerIdx] = atkIdx
    end
    return true
end

function E:TapCard(fieldIndex)
    local perm = self.localState.field[fieldIndex]
    if not perm then return end
    local card = TTS.Cards and TTS.Cards[perm.id]
    if not card then return end

    if self.phase == "COMBAT_BLOCK" and self.blockingState and self.blockingState.isRemoteAttacking then
        -- Blocks are locked in once they have been declared to the attacker
        if self.blockingState.blocksDeclared then
            self:Log(L("err.blocksDeclared"), "ERROR")
            return
        end
        if card.type ~= "Creature" then
            self:Log(L("err.onlyCreaturesBlock"), "ERROR")
            return
        end
        if perm.tapped then
            self:Log(L("err.tappedCantBlock"), "ERROR")
            return
        end
        if self.cantBlockThisTurn then
            self:Log(L("err.cantBlockThisTurn"), "ERROR")
            return
        end

        local bs = self.blockingState
        if bs.selectedBlocker == fieldIndex then
            bs.selectedBlocker = nil
            if bs.blocks[fieldIndex] then
                -- A Bulwark picked for another block: a second click takes its blocks back
                self:ClearBlocks(bs, fieldIndex)
                self:Log(L("log.unblocked", TTS:CardName(card)), "COMBAT")
            else
                self:Log(L("log.deselectedBlocker"), "SYSTEM")
            end
            self:RefreshUI()
            return
        end

        -- A Bulwark with room for another block can be picked again
        if self:CanBlockMore(bs, fieldIndex, perm, false) then
            bs.selectedBlocker = fieldIndex
            self:Log(L("log.selectedSecondBlock", TTS:CardName(card)), "SYSTEM")
            self:RefreshUI()
            return
        end

        -- Clicking a creature that is already blocking takes the block back
        local blocking = bs.blocks[fieldIndex]
        if blocking and self:BlockCount(bs, fieldIndex) > 1 then
            self:ClearBlocks(bs, fieldIndex)
            bs.selectedBlocker = nil
            self:Log(L("log.unblocked", TTS:CardName(card)), "COMBAT")
            self:RefreshUI()
            return
        end
        if blocking then
            self.blockingState.blocks[fieldIndex] = nil
            self.blockingState.selectedBlocker = nil
            local attacker = self.remoteState.field[blocking]
            self:Log(L("log.noLongerBlocking", TTS:CardName(card),
                attacker and TTS.Cards[attacker.id] and TTS:CardName(attacker.id) or L("side.theAttacker")), "SYSTEM")
            self:RefreshUI()
            return
        end

        self.blockingState.selectedBlocker = fieldIndex
        self:Log(L("log.selectedBlocker", TTS:CardName(card)), "SYSTEM")
        self:RefreshUI()
        return
    end

    if not self.isMyTurn then
        self:Log(L("err.notYourTurnActivate"), "ERROR")
        return
    end
    if self:UndoBlocksAction() then return end

    if card.type == "Land" and not perm.tapped then
        perm.tapped = true
        self.localState.mana[card.color] = (self.localState.mana[card.color] or 0) + 1
        self:Log(L("log.tappedPrayer", TTS:CardName(card), card.color), "MANA")
        if not self.isSolo then TTS.Net:Send(self.opponent, "ACTION:TAP_PERM:" .. fieldIndex) end
        self:RefreshUI()
        return
    end
    if card.type == "Land" then
        self:Log(L("err.alreadyTapped", TTS:CardName(card)), "ERROR")
        return
    end

    local ability = self:GetAbility(perm.id)
    if ability and (self.phase == "MAIN1" or self.phase == "MAIN2") then
        if ability.tap then
            if perm.tapped then
                self:Log(L("err.alreadyTapped", TTS:CardName(card)), "ERROR")
                return
            end
            if perm.sick and not self:HasKeyword(perm, false, "haste") then
                self:Log(L("err.summoningSick", TTS:CardName(card)), "ERROR")
                return
            end
        elseif ability.cost and not self:CanPayManaAuto(ability.cost) then
            self:Log(L("err.manaActivate", TTS:CardName(card), ability.cost), "ERROR")
            return
        end

        if ability.target then
            local prompt = (ability.target == "enemy_player" and L("prompt.targetOpponent"))
                or (ability.tapped and L("prompt.targetTapped")) or L("prompt.targetCreature")
            self.targeting = {
                targetMode = "ABILITY",
                sourceIndex = fieldIndex,
                targetType = (ability.target == "enemy_player") and "PLAYER" or "CREATURE",
                cardName = TTS:CardName(card)
            }
            self:Log(L("log.selectFor", prompt, TTS:CardName(card)) .. " " .. L("log.cancelHint"), "SYSTEM")
            self:RefreshUI()
            return
        end

        if ability.cost then self:AutoPayMana(ability.cost) end
        self:ActivateAbility(perm, false, nil)
        return
    end

    if card.type == "Creature" and self.phase == "MAIN1" and self.Hint then
        self:Hint(L("hint.attackInCombat"))
        return
    end

    if card.type == "Creature" and self.phase == "COMBAT_ATTACK" then
        if perm.isAttacking then
            self:Log(L("err.alreadyAttacking", TTS:CardName(card)), "ERROR")
            return
        end
        if perm.tapped then
            self:Log(L("err.tappedCantAttack", TTS:CardName(card)), "ERROR")
            return
        end
        if perm.sick and not self:HasKeyword(perm, false, "haste") then
            self:Log(L("err.sickCantAttack", TTS:CardName(card)), "ERROR")
            return
        end
        if card.defender then
            self:Log(L("err.blockerCantAttack", TTS:CardName(card)), "ERROR")
            return
        end

        if not self:HasKeyword(perm, false, "vigilance") then
            perm.tapped = true
        end

        perm.isAttacking = true
        perm.hasAttackedThisTurn = true
        self.blockingState = self.blockingState or { attackers = {}, blocks = {}, isRemoteAttacking = false }
        table.insert(self.blockingState.attackers, fieldIndex)
        if TTS.Sound then TTS.Sound:QueueCreature("aggro", perm.id) end

        self:OnCreatureAttack(perm, false)

        self:Log(L("log.declaredAttacker", TTS:CardName(card)), "COMBAT")
        if not self.isSolo then TTS.Net:Send(self.opponent, "ACTION:ATTACK:" .. fieldIndex) end
        self:RefreshUI()
    end
end

function E:ClickOpponentCard(fieldIndex)
    if self.targeting then
        local tType = self.targeting.targetType
        if tType == "CREATURE" or tType == "ANY" then
            self:ResolveTarget("CREATURE", true, fieldIndex)
            return
        end
    end

    if self.phase == "COMBAT_BLOCK" and self.blockingState and self.blockingState.isRemoteAttacking
        and self.blockingState.blocksDeclared then
        self:Log(L("err.blocksDeclared"), "ERROR")
        return
    end

    if self.phase == "COMBAT_BLOCK" and self.blockingState and self.blockingState.isRemoteAttacking
        and not self.blockingState.blocksDeclared then
        local attackerPerm = self.remoteState.field[fieldIndex]
        if not attackerPerm or not attackerPerm.isAttacking then
            self:Log(L("err.clickAttacker"), "ERROR")
            return
        end

        local blockerIdx = self.blockingState.selectedBlocker
        if not blockerIdx then
            self:Log(L("log.pickBlockerFirst"), "SYSTEM")
            return
        end

        local blockerPerm = self.localState.field[blockerIdx]
        local blockerCard = blockerPerm and TTS.Cards[blockerPerm.id]
        local attackerCard = TTS.Cards[attackerPerm.id]

        if self:HasKeyword(attackerPerm, true, "unblockable") then
            self:Log(L("err.unblockable", TTS:CardName(attackerCard)), "ERROR")
            return
        end

        if self:HasKeyword(attackerPerm, true, "flying") and not (self:HasKeyword(blockerPerm, false, "flying") or self:HasKeyword(blockerPerm, false, "reach")) then
            self:Log(L("err.airborne", TTS:CardName(attackerCard)), "ERROR")
            return
        end

        -- One blocker per attacker: the new blocker replaces the one already there
        local bs = self.blockingState
        local otherBlocker = self:BlockerOf(bs, fieldIndex)
        if otherBlocker == blockerIdx then
            bs.selectedBlocker = nil
            self:RefreshUI()
            return
        end
        if otherBlocker then
            self:ClearBlockOn(bs, fieldIndex)
            local other = self.localState.field[otherBlocker]
            self:Log(L("log.noLongerBlocking",
                other and TTS.Cards[other.id] and TTS:CardName(other.id) or L("side.otherCreature"), TTS:CardName(attackerCard)), "SYSTEM")
        end

        self:AssignBlock(bs, blockerIdx, fieldIndex, blockerPerm, false)
        bs.selectedBlocker = nil
        self:Log(L("log.assignedBlock", TTS:CardName(blockerCard), TTS:CardName(attackerCard)), "COMBAT")
        self:RefreshUI()
        return
    end
end

-- =========================================================================
-- COMBAT RESOLUTION
-- =========================================================================
function E:ResolveCombatDamage()
    if not self.blockingState then return end
    local bs = self.blockingState
    local isRemoteAttacking = bs.isRemoteAttacking

    local atkField = isRemoteAttacking and self.remoteState.field or self.localState.field
    local defField = isRemoteAttacking and self.localState.field or self.remoteState.field

    -- In a 2-player match both clients resolve combat. Damage to the defending player is
    -- applied once: the attacker's client sends it (through the defender's damage shield).
    local function DamageDefender(amount, reason)
        if isRemoteAttacking and not self.isSolo then return end
        self:DamagePlayer(not isRemoteAttacking, amount, reason)
    end

    -- A Bulwark blocking several attackers deals its full damage to each
    local absorbed = {}   -- toughness of each blocker already soaked up this combat (Brutish)
    local strikesFirstKilled = {}

    for _, atkIdx in ipairs(bs.attackers) do
        local atkPerm = atkField[atkIdx]
        if atkPerm then
            local atkCard = TTS.Cards[atkPerm.id]
            local atkPower, atkToughness = self:GetCreatureStats(atkPerm, isRemoteAttacking)

            local assignedBlockerIdx = self:BlockerOf(bs, atkIdx)

            if assignedBlockerIdx and defField[assignedBlockerIdx] then
                local defPerm = defField[assignedBlockerIdx]
                local defCard = TTS.Cards[defPerm.id]
                local defPower, defToughness = self:GetCreatureStats(defPerm, not isRemoteAttacking)
                local defHit = defPower

                local function Stats(p, t)
                    return TTS.FormatStats and TTS.FormatStats(p, t, 0, "|cFFFFFFFF", 12) or string.format("%d/%d", p, t)
                end
                self:Log(L("log.clash",
                    TTS:CardName(atkCard), Stats(atkPower, atkToughness), TTS:CardName(defCard), Stats(defPower, defToughness)), "COMBAT")

                if not self.preventCombatDamage then
                    local atkFirst = self:HasKeyword(atkPerm, isRemoteAttacking, "firstStrike")
                    local defFirst = self:HasKeyword(defPerm, not isRemoteAttacking, "firstStrike")

                    local atkDT = self:HasKeyword(atkPerm, isRemoteAttacking, "deathtouch")
                    local defDT = self:HasKeyword(defPerm, not isRemoteAttacking, "deathtouch")
                    -- A Bulwark struck down first by its other attacker never strikes this one
                    if strikesFirstKilled[assignedBlockerIdx] and not defFirst then defHit = 0 end
                    local defDmg = (defDT and defHit > 0) and 999 or defHit

                    if atkFirst and not defFirst then
                        defPerm.damage = (defPerm.damage or 0) + (atkDT and 999 or atkPower)
                        if (defPerm.damage or 0) < defToughness then
                            atkPerm.damage = (atkPerm.damage or 0) + defDmg
                        else
                            strikesFirstKilled[assignedBlockerIdx] = true
                        end
                    elseif defFirst and not atkFirst then
                        atkPerm.damage = (atkPerm.damage or 0) + defDmg
                        if (atkPerm.damage or 0) < atkToughness then
                            defPerm.damage = (defPerm.damage or 0) + (atkDT and 999 or atkPower)
                        end
                    else
                        atkPerm.damage = (atkPerm.damage or 0) + defDmg
                        defPerm.damage = (defPerm.damage or 0) + (atkDT and 999 or atkPower)
                    end

                    if atkPerm.id == "BOSS17" and atkPower > 0 then
                        defPerm.tapped = true
                        defPerm.freezeUntap = true
                    end
                    if defPerm.id == "BOSS17" and defPower > 0 then
                        atkPerm.tapped = true
                        atkPerm.freezeUntap = true
                    end

                    -- Toughness another attacker already soaked up doesn't hold this one back
                    local left = math.max(0, defToughness - (absorbed[assignedBlockerIdx] or 0))
                    absorbed[assignedBlockerIdx] = (absorbed[assignedBlockerIdx] or 0) + math.min(atkPower, left)
                    if self:HasKeyword(atkPerm, isRemoteAttacking, "trample") then
                        local excess = math.max(0, atkPower - left)
                        if excess > 0 then
                            DamageDefender(excess, atkCard.id .. "/trample")
                        end
                    end

                    if self:HasKeyword(atkPerm, isRemoteAttacking, "lifelink") and atkPower > 0 then
                        if isRemoteAttacking then self.remoteState.life = self.remoteState.life + atkPower
                        else self.localState.life = self.localState.life + atkPower end
                    end
                    if self:HasKeyword(defPerm, not isRemoteAttacking, "lifelink") and defHit > 0 then
                        if not isRemoteAttacking then self.remoteState.life = self.remoteState.life + defHit
                        else self.localState.life = self.localState.life + defHit end
                    end
                end
            else
                if not self.preventCombatDamage then
                    DamageDefender(atkPower, atkCard.id .. "/attack")

                    if atkPerm.id == "BOSS16" and atkPower > 0 then
                        local pLands = isRemoteAttacking and self.localState.field or self.remoteState.field
                        for lIdx = #pLands, 1, -1 do
                            if TTS.Cards[pLands[lIdx].id].type == "Land" then
                                table.remove(pLands, lIdx)
                                self:Log(L("log.boss.theradras", TTS:CardName(atkPerm.id)), "ACTION")
                                break
                            end
                        end
                    end

                    if self:HasKeyword(atkPerm, isRemoteAttacking, "lifelink") and atkPower > 0 then
                        if isRemoteAttacking then self.remoteState.life = self.remoteState.life + atkPower
                        else self.localState.life = self.localState.life + atkPower end
                    end
                else
                    self:Log(L("log.combatPrevented", TTS:CardName(atkCard)), "COMBAT")
                end
            end

            atkPerm.isAttacking = nil
        end
    end

    self.blockingState = nil
    self:CheckStateBasedActions()

    if isRemoteAttacking then
        if self.isSolo then
            -- The AI's combat is over: it carries on with its second main phase
            self:SetPhase(self.AI_TURN_PHASE)
            self:AIAfterCombat()
        end
    else
        self:SetPhase("MAIN2")
        self:Log(L("log.main2"), "SYSTEM")
    end
    self:RefreshUI()
end