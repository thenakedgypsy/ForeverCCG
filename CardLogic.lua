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
        local controllerName  = isAttRemote and (self.opponent or "Opponent") or "You"

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
            self:Log(string.format("Equipment |cFFFFD200%s|r unequipped and returned to %s control.", attCard and attCard.name or attId, controllerName), "ACTION")
        else
            table.insert(controllerState.graveyard, attId)
            self:Log(string.format("Enchantment |cFFFFD200%s|r attached to %s was destroyed.", attCard and attCard.name or attId, TTS.Cards[perm.id] and TTS.Cards[perm.id].name or "creature"), "ACTION")
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
-- =========================================================================
local TAG_FIELDS = { faction = "faction", zone = "zone", type = "creatureType" }

function E:CardHasTag(card, tag, value)
    local field = card and TAG_FIELDS[tag]
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
    local card = TTS.Cards[perm.id]
    if not card then return end

    if TTS.Sound then TTS.Sound:QueueCreature("death", perm.id) end

    self:DetachAttachments(perm, isRemote)

    if perm.id == "BOSS09" then
        if isRemote then
            self.remoteState.handCount = self.remoteState.handCount + 1
        else
            self:DrawCard()
        end
        self:Log(card.name .. " died: controller drew a card.", "ACTION")
    end

    if perm.id == "BOSS12" then
        local gy = isRemote and self.remoteState.graveyard or self.localState.graveyard
        local field = isRemote and self.remoteState.field or self.localState.field
        for idx = #gy, 1, -1 do
            local resCardId = gy[idx]
            local resCard = TTS.Cards[resCardId]
            if resCard and resCard.type == "Creature" and resCardId ~= "BOSS12" then
                table.remove(gy, idx)
                table.insert(field, {
                    id = resCardId,
                    tapped = false,
                    sick = not resCard.haste,
                    damage = 0,
                    tempPower = 0,
                    tempToughness = 0,
                    uid = time() + idx
                })
                self:Log(string.format("Whitemane resurrected |cFFFFD200%s|r onto the battlefield!", resCard.name), "ACTION")
                break
            end
        end
    end

    for _, other in ipairs(isRemote and self.localState.field or self.remoteState.field) do
        if other.id == "BOSS25" then
            self:DamagePlayer(isRemote, 2, "Baron Rivendare")
        end
    end

    for _, other in ipairs(isRemote and self.remoteState.field or self.localState.field) do
        if other.id == "BOSS24" and other ~= perm then
            if isRemote then
                self.remoteState.handCount = self.remoteState.handCount + 1
            else
                self:DrawCard()
            end
            self:Log("Darkmaster Gandling siphon: drew a card from a creature's death.", "ACTION")
        end
    end
end

function E:CheckStateBasedActions()
    for i = #self.localState.field, 1, -1 do
        local perm = self.localState.field[i]
        local card = TTS.Cards[perm.id]
        if card and card.type == "Creature" then
            local _, effT = self:GetCreatureStats(perm, false)
            if (perm.damage or 0) >= effT or effT <= 0 then
                if perm.regenerateShield then
                    perm.damage = 0
                    perm.tapped = true
                    perm.regenerateShield = false
                    self:Log(string.format("|cFFFFD200%s|r regenerated from lethal damage!", card.name), "ACTION")
                else
                    table.remove(self.localState.field, i)
                    table.insert(self.localState.graveyard, perm.id)
                    self:Log(string.format("|cFFFFD200%s|r died and was put into the graveyard.", card.name), "COMBAT")
                    self:HandleCreatureDeath(perm, false)
                end
            end
        end
    end

    for i = #self.remoteState.field, 1, -1 do
        local perm = self.remoteState.field[i]
        local card = TTS.Cards[perm.id]
        if card and card.type == "Creature" then
            local _, effT = self:GetCreatureStats(perm, true)
            if (perm.damage or 0) >= effT or effT <= 0 then
                if perm.regenerateShield then
                    perm.damage = 0
                    perm.tapped = true
                    perm.regenerateShield = false
                    self:Log(string.format("%s's |cFFFFD200%s|r regenerated!", self.opponent, card.name), "ACTION")
                else
                    table.remove(self.remoteState.field, i)
                    table.insert(self.remoteState.graveyard, perm.id)
                    self:Log(string.format("%s's |cFFFFD200%s|r was destroyed.", self.opponent, card.name), "COMBAT")
                    self:HandleCreatureDeath(perm, true)
                end
            end
        end
    end

    self:RefreshUI()
end

-- Destroys a creature wherever it is (used by spell effects).
function E:DestroyCreature(perm)
    local isRemote, idx = self:FindPerm(perm)
    if not idx then return end
    local st = isRemote and self.remoteState or self.localState
    table.remove(st.field, idx)
    table.insert(st.graveyard, perm.id)
    local card = TTS.Cards[perm.id]
    self:Log(string.format("|cFFFFD200%s|r was destroyed.", card and card.name or perm.id), "COMBAT")
    self:HandleCreatureDeath(perm, isRemote)
end

-- =========================================================================
-- SPELL EFFECT ENGINE
-- Every class spell in the Cards files carries an `effect = { target = <spec>, ops = { ... } }` table.
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

function E:IsValidSpellTarget(spec, kind, isRemote)
    isRemote = isRemote and true or false
    if spec == "enemy_creature" then return kind == "CREATURE" and isRemote end
    if spec == "friendly_creature" then return kind == "CREATURE" and not isRemote end
    if spec == "creature" then return kind == "CREATURE" end
    if spec == "enemy_any" then return isRemote end
    if spec == "friendly_any" then return not isRemote end
    if spec == "any" then return true end
    if spec == "enemy_player" then return kind == "PLAYER" and isRemote end
    if spec == "player" then return kind == "PLAYER" end
    return false
end

-- Builds the list of things an op applies to: {kind="PLAYER"|"CREATURE", isRemote=bool, perm=perm}
function E:CollectSpellTargets(to, tgt)
    local list = {}
    if to == "target" then
        if tgt then list[1] = tgt end
    elseif to == "self_player" then
        list[1] = { kind = "PLAYER", isRemote = false }
    elseif to == "enemy_player" then
        list[1] = { kind = "PLAYER", isRemote = true }
    else
        local function add(field, isRemote)
            for _, perm in ipairs(field) do
                if IsCreaturePerm(perm) then
                    table.insert(list, { kind = "CREATURE", isRemote = isRemote, perm = perm })
                end
            end
        end
        if to == "enemy_creatures" or to == "all_creatures" then add(self.remoteState.field, true) end
        if to == "friendly_creatures" or to == "all_creatures" then add(self.localState.field, false) end
    end
    return list
end

local function CreatureName(perm)
    local c = TTS.Cards[perm.id]
    return c and c.name or perm.id
end

-- Display name for the target of an over-time effect
local function TargetName(self, d)
    if d.kind == "PLAYER" then
        return d.isRemote and (self.opponent or "the opponent") or "you"
    end
    return "|cFFFFD200" .. CreatureName(d.perm) .. "|r"
end

local SPELL_OPS = {}

SPELL_OPS.damage = function(self, op, d, card)
    local n = op.n
    if d.kind == "PLAYER" then
        self:DamagePlayer(d.isRemote, n, card.name)
    else
        if op.bonusIfTapped and d.perm.tapped then n = n + op.bonusIfTapped end
        d.perm.damage = (d.perm.damage or 0) + n
        self:Log(string.format("%s dealt %d damage to |cFFFFD200%s|r.", card.name, n, CreatureName(d.perm)), "COMBAT")
    end
end

SPELL_OPS.heal = function(self, op, d, card)
    if d.kind == "PLAYER" then
        local st = d.isRemote and self.remoteState or self.localState
        st.life = st.life + op.n
        self:Log(string.format("%s restored %d life to %s.", card.name, op.n, d.isRemote and (self.opponent or "the opponent") or "you"), "ACTION")
    else
        d.perm.damage = math.max(0, (d.perm.damage or 0) - op.n)
        self:Log(string.format("%s healed |cFFFFD200%s|r for %d.", card.name, CreatureName(d.perm), op.n), "ACTION")
    end
end

SPELL_OPS.buff = function(self, op, d, card)
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
    self:Log(string.format("%s affected |cFFFFD200%s|r.", card.name, CreatureName(d.perm)), "ACTION")
end

SPELL_OPS.tap = function(self, op, d, card)
    if d.kind ~= "CREATURE" then return end
    d.perm.tapped = true
    self:Log(string.format("|cFFFFD200%s|r was tapped.", CreatureName(d.perm)), "ACTION")
end

SPELL_OPS.freeze = function(self, op, d, card)
    if d.kind ~= "CREATURE" then return end
    d.perm.tapped = true
    d.perm.freezeUntap = true
    self:Log(string.format("|cFFFFD200%s|r was tapped and will not untap next untap step.", CreatureName(d.perm)), "ACTION")
end

SPELL_OPS.destroy = function(self, op, d, card)
    if d.kind ~= "CREATURE" then return end
    local c = TTS.Cards[d.perm.id]
    if op.damaged and (d.perm.damage or 0) <= 0 then
        self:Log(string.format("%s fizzled: %s has not been dealt damage.", card.name, CreatureName(d.perm)), "ERROR")
        return
    end
    if op.nonColor and c and c.color == op.nonColor then
        self:Log(string.format("%s fizzled: %s is immune.", card.name, CreatureName(d.perm)), "ERROR")
        return
    end
    self:DestroyCreature(d.perm)
end

SPELL_OPS.tuck = function(self, op, d, card)
    if d.kind ~= "CREATURE" then return end
    local isRemote, idx = self:FindPerm(d.perm)
    if not idx then return end
    local st = isRemote and self.remoteState or self.localState
    self:DetachAttachments(d.perm, isRemote)
    table.remove(st.field, idx)
    table.insert(st.deck, 1, d.perm.id)
    self:Log(string.format("%s put |cFFFFD200%s|r on top of its owner's library.", card.name, CreatureName(d.perm)), "ACTION")
end

SPELL_OPS.steal = function(self, op, d, card)
    if d.kind ~= "CREATURE" then return end
    local isRemote, idx = self:FindPerm(d.perm)
    if not idx or not isRemote then return end
    if op.maxPower then
        local effP = self:GetCreatureStats(d.perm, true)
        if effP > op.maxPower then
            self:Log(string.format("%s fizzled: %s is too powerful.", card.name, CreatureName(d.perm)), "ERROR")
            return
        end
    end
    table.remove(self.remoteState.field, idx)
    d.perm.tapped = false
    if op.untilEnd then
        d.perm.sick = false
        table.insert(self.stolenCreatures, { perm = d.perm, isRemoteOwner = true })
        self:Log(string.format("%s: gained control of |cFFFFD200%s|r until end of turn.", card.name, CreatureName(d.perm)), "ACTION")
    else
        d.perm.sick = true
        self:Log(string.format("%s: gained control of |cFFFFD200%s|r!", card.name, CreatureName(d.perm)), "ACTION")
    end
    table.insert(self.localState.field, d.perm)
end

SPELL_OPS.dot = function(self, op, d, card)
    local holder = d.perm
    if d.kind == "PLAYER" then holder = d.isRemote and self.remoteState or self.localState end
    holder.dots = holder.dots or {}
    table.insert(holder.dots, { n = op.n, turns = op.turns, src = card.name, srcId = card.id })
    self:Log(string.format("%s: %s will take %d damage each turn for %d turns.", card.name, TargetName(self, d), op.n, op.turns), "ACTION")
end

SPELL_OPS.hot = function(self, op, d, card)
    local holder = d.perm
    if d.kind == "PLAYER" then holder = d.isRemote and self.remoteState or self.localState end
    holder.hots = holder.hots or {}
    table.insert(holder.hots, { n = op.n, turns = op.turns, src = card.name, srcId = card.id })
    self:Log(string.format("%s: %s will restore %d each turn for %d turns.", card.name, TargetName(self, d), op.n, op.turns), "ACTION")
end

SPELL_OPS.shield = function(self, op, d, card)
    if d.kind == "PLAYER" then
        local st = d.isRemote and self.remoteState or self.localState
        st.damageShield = (st.damageShield or 0) + op.n
        self:Log(string.format("%s: the next %d damage to %s will be prevented.", card.name, op.n, d.isRemote and (self.opponent or "the opponent") or "you"), "ACTION")
    else
        d.perm.tempToughness = (d.perm.tempToughness or 0) + op.n
        self:Log(string.format("%s shielded |cFFFFD200%s|r (+0/+%d).", card.name, CreatureName(d.perm), op.n), "ACTION")
    end
end

SPELL_OPS.regen = function(self, op, d, card)
    if d.kind ~= "CREATURE" then return end
    d.perm.regenerateShield = true
end

SPELL_OPS.dispel = function(self, op, d, card)
    if d.kind ~= "CREATURE" then return end
    local perm = d.perm
    if d.isRemote then
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
    self:Log(string.format("%s dispelled |cFFFFD200%s|r.", card.name, CreatureName(perm)), "ACTION")
end

-- Effects that do not iterate over targets
local SPELL_GLOBAL_OPS = {}

SPELL_GLOBAL_OPS.draw = function(self, op, card)
    for _ = 1, op.n do
        if not self.inMatch then break end
        self:DrawCard()
    end
end

SPELL_GLOBAL_OPS.mana = function(self, op, card)
    self.localState.mana[op.color] = (self.localState.mana[op.color] or 0) + op.n
    self:Log(string.format("%s added %d {%s} to your mana pool.", card.name, op.n, op.color), "MANA")
end

SPELL_GLOBAL_OPS.raise = function(self, op, card)
    local sources = { self.localState.graveyard }
    if op.src == "any" then table.insert(sources, self.remoteState.graveyard) end
    for _, gy in ipairs(sources) do
        for idx = #gy, 1, -1 do
            local c = TTS.Cards[gy[idx]]
            if c and c.type == "Creature" then
                local cId = table.remove(gy, idx)
                table.insert(self.localState.field, {
                    id = cId,
                    tapped = false,
                    sick = not self:HasKeyword({ id = cId }, false, "haste"),
                    damage = 0,
                    tempPower = 0,
                    tempToughness = 0,
                    uid = time() + idx
                })
                self:Log(string.format("%s returned |cFFFFD200%s|r to the battlefield under your control!", card.name, c.name), "ACTION")
                return
            end
        end
    end
    self:Log(card.name .. " found no creature card to return.", "ERROR")
end

function E:ApplySpellOp(op, tgt, card)
    local global = SPELL_GLOBAL_OPS[op.op]
    if global then
        global(self, op, card)
        return
    end
    local handler = SPELL_OPS[op.op]
    if not handler then return end
    for _, d in ipairs(self:CollectSpellTargets(op.to, tgt)) do
        if not self.inMatch then return end
        handler(self, op, d, card)
        if d.kind == "CREATURE" and d.perm and LINGERING_OPS[op.op] then
            RecordSpellEffect(d.perm, op, card)
        end
    end
end

function E:ResolveSpell(card, tgt)
    local eff = card.effect
    self:Log(string.format("Resolved %s: |cFFFFD200%s|r.", card.type, card.name), "ACTION")
    if eff and eff.ops then
        for _, op in ipairs(eff.ops) do
            if not self.inMatch then break end
            self:ApplySpellOp(op, tgt, card)
        end
    end
    self:SyncEffects()
    self:CheckStateBasedActions()
end

-- Damage / healing over time. Runs at the start of the local player's turn for every effect on the board.
local function TickList(list, apply)
    if not list then return end
    for i = #list, 1, -1 do
        local e = list[i]
        apply(e)
        e.turns = e.turns - 1
        if e.turns <= 0 then table.remove(list, i) end
    end
end

function E:TickOverTime()
    for _, isRemote in ipairs({ false, true }) do
        local st = isRemote and self.remoteState or self.localState
        TickList(st.hots, function(e)
            st.life = st.life + e.n
            self:Log(string.format("%s restored %d life to %s.", e.src, e.n, isRemote and (self.opponent or "the opponent") or "you"), "ACTION")
        end)
        TickList(st.dots, function(e)
            if self.inMatch then self:DamagePlayer(isRemote, e.n, e.src) end
        end)
        for _, perm in ipairs(st.field) do
            if IsCreaturePerm(perm) then
                TickList(perm.hots, function(e)
                    perm.damage = math.max(0, (perm.damage or 0) - e.n)
                end)
                TickList(perm.dots, function(e)
                    perm.damage = (perm.damage or 0) + e.n
                    self:Log(string.format("%s dealt %d damage to |cFFFFD200%s|r.", e.src, e.n, CreatureName(perm)), "COMBAT")
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
            local e = { n = n, turns = turns, srcId = srcId, src = c and c.name or "Unknown" }
            if kind == "D" then table.insert(mirror.dots, e)
            elseif kind == "H" then table.insert(mirror.hots, e) end
        end
    end
    return mirror
end

function E:SyncEffects()
    if self.isSolo or not self.inMatch or not self.opponent then return end
    TTS.Net:Send(self.opponent, "ACTION:EFFECTS:" .. EncodeEffects(self.localState) .. ":" .. EncodeEffects(self.remoteState))
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
        self:Log("Cannot play cards outside of your turn.", "ERROR")
        return
    end

    local cardId = self.localState.hand[handIndex]
    local card = TTS.Cards and TTS.Cards[cardId]
    if not card then return end

    if card.type == "Land" then
        if self.landPlayedThisTurn then
            self:Log("You can only play one prayer per turn.", "ERROR")
            return
        end
        if self.phase ~= "MAIN1" and self.phase ~= "MAIN2" then
            self:Log("Prayers can only be played during Main Phases.", "ERROR")
            return
        end

        table.remove(self.localState.hand, handIndex)
        table.insert(self.localState.field, { id = cardId, tapped = false, uid = time() + handIndex })
        self.landPlayedThisTurn = true
        self:Log(string.format("Played prayer: |cFFFFD200%s|r.", card.name), "ACTION")
        self:PlayNonCreatureCardSound()

        if not self.isSolo then TTS.Net:Send(self.opponent, "ACTION:PLAY_LAND:" .. cardId) end
        self:RefreshUI()
        return
    end

    local targetType = self:GetSpellTargetType(card)
    if targetType then
        if (self.phase ~= "MAIN1" and self.phase ~= "MAIN2") then
            self:Log("Cards can only be cast during Main Phases.", "ERROR")
            return
        end

        if not self:CanPayMana(card.cost) then
            self:Log(string.format("Not enough mana to cast %s (%s).", card.name, card.cost), "ERROR")
            return
        end

        self.targeting = {
            targetMode = "SPELL",
            cardId = cardId,
            handIndex = handIndex,
            targetType = targetType,
            cardName = card.name
        }
        self:Log(string.format("Select target for |cFFFFD200%s|r (Right-click to cancel).", card.name), "SYSTEM")
        self:RefreshUI()
        return
    end

    if card.type == "Creature" then
        if self.phase ~= "MAIN1" and self.phase ~= "MAIN2" then
            self:Log("Permanents can only be cast during Main Phases.", "ERROR")
            return
        end
        if not self:PayMana(card.cost) then
            self:Log("Not enough mana in pool.", "ERROR")
            return
        end

        table.remove(self.localState.hand, handIndex)
        local perm = {
            id = cardId,
            tapped = false,
            sick = not self:HasKeyword({ id = cardId }, false, "haste"),
            damage = 0,
            tempPower = 0,
            tempToughness = 0,
            uid = time() + handIndex
        }
        table.insert(self.localState.field, perm)
        self:Log(string.format("Cast %s: |cFFFFD200%s|r.", card.type, card.name), "ACTION")
        if TTS.Sound then TTS.Sound:QueueCreature("aggro", cardId) end

        if cardId == "BOSS19" then
            for _, oppPerm in ipairs(self.remoteState.field) do
                oppPerm.damage = (oppPerm.damage or 0) + 3
            end
            self:Log("Wyrmthalak dealt 3 damage to all opposing creatures!", "COMBAT")
            self:CheckStateBasedActions()
        elseif cardId == "BOSS26" then
            for i, oppPerm in ipairs(self.remoteState.field) do
                local effP, _ = self:GetCreatureStats(oppPerm, true)
                if effP <= 4 then
                    table.remove(self.remoteState.field, i)
                    oppPerm.sick = true
                    table.insert(self.localState.field, oppPerm)
                    self:Log("Balnazzar stole control of " .. TTS.Cards[oppPerm.id].name .. "!", "ACTION")
                    break
                end
            end
        end

        if not self.isSolo then TTS.Net:Send(self.opponent, "ACTION:PLAY_PERM:" .. cardId) end

    elseif card.type == "Sorcery" then
        if self.phase ~= "MAIN1" and self.phase ~= "MAIN2" then
            self:Log("Sorceries can only be cast during Main Phases.", "ERROR")
            return
        end
        if not self:PayMana(card.cost) then
            self:Log("Not enough mana in pool.", "ERROR")
            return
        end

        table.remove(self.localState.hand, handIndex)
        table.insert(self.localState.graveyard, cardId)
        self:PlaySpellCastSound()
        self:ResolveSpell(card, nil)
        if not self.isSolo then TTS.Net:Send(self.opponent, "ACTION:CAST_SPELL:" .. cardId) end
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

    local cardId = sourcePerm.id

    if isRemote and fieldIndex and fieldIndex > 0 then
        local targetPerm = self.remoteState.field[fieldIndex]
        if targetPerm then
            local targetCard = TTS.Cards[targetPerm.id]
            if targetCard and self:HasKeyword(targetPerm, true, "hexproof") then
                self:Log(targetCard.name .. " has Hexproof and cannot be targeted!", "ERROR")
                self.targeting = nil
                self:RefreshUI()
                return
            end
        end
    end

    if cardId == "BOSS01" then
        sourcePerm.tapped = true
        self:DamagePlayer(isRemote, 2, "Bazzalan")
        self.localState.life = self.localState.life + 2
        self:Log("Bazzalan drained 2 life.", "ACTION")

    elseif cardId == "BOSS04" then
        local targetField = isRemote and self.remoteState.field or self.localState.field
        local targetPerm = targetField[fieldIndex]
        if targetPerm and targetPerm.tapped and TTS.Cards[targetPerm.id] and TTS.Cards[targetPerm.id].type == "Creature" then
            sourcePerm.tapped = true
            self:DetachAttachments(targetPerm, isRemote)
            table.remove(targetField, fieldIndex)
            local targetDeck = isRemote and self.remoteState.deck or self.localState.deck
            table.insert(targetDeck, 1, targetPerm.id)
            self:Log("Archmage Arugal placed tapped creature on top of library!", "ACTION")
        else
            self:Log("Archmage Arugal can only target tapped creatures.", "ERROR")
            return
        end

    elseif cardId == "BOSS08" then
        local targetPerm = (isRemote and self.remoteState.field or self.localState.field)[fieldIndex]
        if targetPerm and TTS.Cards[targetPerm.id] and TTS.Cards[targetPerm.id].type == "Creature" then
            sourcePerm.tapped = true
            targetPerm.tapped = true
            targetPerm.freezeUntap = true
            self:Log("Charlga Razorflank tapped and froze creature.", "ACTION")
        else
            self:Log("Charlga Razorflank can only target creatures.", "ERROR")
            return
        end
    end

    self.targeting = nil
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
            self:Log("That is not a valid target.", "ERROR")
            return
        end
        tgt = { kind = "CREATURE", isRemote = isRemote, perm = perm, idx = fieldIndex }
    end

    if not self:IsValidSpellTarget(eff.target, tgt.kind, tgt.isRemote) then
        self:Log(string.format("%s cannot target that. Choose another target (Right-click to cancel).", card.name), "ERROR")
        return
    end

    if tgt.kind == "CREATURE" and tgt.isRemote and self:HasKeyword(tgt.perm, true, "hexproof") then
        self:Log(TTS.Cards[tgt.perm.id].name .. " has Hexproof and cannot be targeted!", "ERROR")
        self.targeting = nil
        self:RefreshUI()
        return
    end

    if not self:PayMana(card.cost) then
        self:Log("Failed to pay mana.", "ERROR")
        self.targeting = nil
        self:RefreshUI()
        return
    end

    self.targeting = nil
    table.remove(self.localState.hand, handIndex)
    table.insert(self.localState.graveyard, cardId)
    self:PlaySpellCastSound()
    self:ResolveSpell(card, tgt)
    if not self.isSolo then TTS.Net:Send(self.opponent, "ACTION:CAST_SPELL:" .. cardId) end
    self:RefreshUI()
end

-- =========================================================================
-- BATTLEFIELD ACTIVATIONS & ATTACKS
-- =========================================================================
function E:TapCard(fieldIndex)
    local perm = self.localState.field[fieldIndex]
    if not perm then return end
    local card = TTS.Cards and TTS.Cards[perm.id]
    if not card then return end

    if self.phase == "COMBAT_BLOCK" and self.blockingState and self.blockingState.isRemoteAttacking then
        -- Blocks are locked in once they have been declared to the attacker
        if self.blockingState.blocksDeclared then return end
        if card.type ~= "Creature" then return end
        if perm.tapped then
            self:Log("Tapped creatures cannot block.", "ERROR")
            return
        end
        if self.cantBlockThisTurn then
            self:Log("Creatures cannot block this turn!", "ERROR")
            return
        end

        if self.blockingState.selectedBlocker == fieldIndex then
            self.blockingState.selectedBlocker = nil
            self:Log("Deselected blocker.", "SYSTEM")
            self:RefreshUI()
            return
        end

        self.blockingState.selectedBlocker = fieldIndex
        self:Log(string.format("Selected |cFFFFD200%s|r to block. Click an attacking creature to assign.", card.name), "SYSTEM")
        self:RefreshUI()
        return
    end

    if not self.isMyTurn then
        self:Log("Cannot activate cards outside of your turn.", "ERROR")
        return
    end

    if card.type == "Land" and not perm.tapped then
        perm.tapped = true
        self.localState.mana[card.color] = (self.localState.mana[card.color] or 0) + 1
        self:Log(string.format("Tapped |cFFFFD200%s|r for +1 {%s}.", card.name, card.color), "MANA")
        if not self.isSolo then TTS.Net:Send(self.opponent, "ACTION:TAP_PERM:" .. fieldIndex) end
        self:RefreshUI()
        return
    end

    if self.phase == "MAIN1" or self.phase == "MAIN2" then
        if perm.id == "BOSS22" then
            if self:PayMana("{2}{U}") then
                self:DrawCard()
                if #self.localState.hand > 0 then
                    local disc = table.remove(self.localState.hand, 1)
                    table.insert(self.localState.graveyard, disc)
                end
                perm.tempPower = (perm.tempPower or 0) + 1
                perm.tempToughness = (perm.tempToughness or 0) + 1
                self:Log("Tortheldrin activated: drew, discarded, gained +1/+1.", "ACTION")
                self:RefreshUI()
            end
            return
        end

        if perm.tapped then return end
        if card.type == "Creature" and perm.sick and not self:HasKeyword(perm, false, "haste") then
            self:Log(string.format("%s has summoning sickness.", card.name), "ERROR")
            return
        end

        -- Targeted tap abilities
        if perm.id == "BOSS01" then
            self.targeting = {
                targetMode = "ABILITY",
                sourceIndex = fieldIndex,
                targetType = "PLAYER",
                cardName = card.name
            }
            self:Log(string.format("Select target opponent for |cFFFFD200%s|r (Right-click to cancel).", card.name), "SYSTEM")
            self:RefreshUI()
            return
        elseif perm.id == "BOSS04" then
            self.targeting = {
                targetMode = "ABILITY",
                sourceIndex = fieldIndex,
                targetType = "CREATURE",
                cardName = card.name
            }
            self:Log(string.format("Select target tapped creature for |cFFFFD200%s|r (Right-click to cancel).", card.name), "SYSTEM")
            self:RefreshUI()
            return
        elseif perm.id == "BOSS08" then
            self.targeting = {
                targetMode = "ABILITY",
                sourceIndex = fieldIndex,
                targetType = "CREATURE",
                cardName = card.name
            }
            self:Log(string.format("Select target creature for |cFFFFD200%s|r (Right-click to cancel).", card.name), "SYSTEM")
            self:RefreshUI()
            return
        end

        -- Untargeted tap abilities
        if perm.id == "BOSS07" then
            perm.tapped = true
            for _, p in ipairs(self.remoteState.field) do
                if TTS.Cards[p.id].type == "Creature" then
                    p.damage = (p.damage or 0) + 2
                end
            end
            self:CheckStateBasedActions()
            return
        elseif perm.id == "BOSS10" then
            perm.tapped = true
            for _, p in ipairs(self.remoteState.field) do
                if TTS.Cards[p.id].type == "Creature" then
                    p.damage = (p.damage or 0) + 2
                end
            end
            self:CheckStateBasedActions()
            return
        elseif perm.id == "BOSS21" then
            perm.tapped = true
            self.localState.life = self.localState.life + 4
            self:Log("Alzzin the Wildshaper restored 4 life.", "ACTION")
            self:RefreshUI()
            return
        end
    end

    if card.type == "Creature" and self.phase == "COMBAT_ATTACK" then
        if perm.tapped then return end
        if perm.sick and not self:HasKeyword(perm, false, "haste") then
            self:Log(card.name .. " has summoning sickness and cannot attack.", "ERROR")
            return
        end
        if card.defender then
            self:Log(card.name .. " has Defender and cannot attack.", "ERROR")
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

        if perm.id == "BOSS03" then
            self.remoteState.handCount = math.max(0, self.remoteState.handCount - 1)
            self:DamagePlayer(true, 1, "Mutanus the Devourer")
            self:Log("Mutanus attacked: opponent discards a card and loses 1 life.", "ACTION")
        elseif perm.id == "BOSS13" then
            for _, oppPerm in ipairs(self.remoteState.field) do
                if not oppPerm.tapped then
                    oppPerm.tapped = true
                    oppPerm.freezeUntap = true
                    self:Log("Amnennar attacked and froze an enemy creature.", "ACTION")
                    break
                end
            end
        elseif perm.id == "BOSS23" then
            perm.tempPower = (perm.tempPower or 0) + 2
            self:Log("King Gordok gained +2/+0 upon attacking.", "ACTION")
        end

        self:Log(string.format("Declared attacker: |cFFFFD200%s|r.", card.name), "COMBAT")
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
        and not self.blockingState.blocksDeclared then
        local attackerPerm = self.remoteState.field[fieldIndex]
        if not attackerPerm or not attackerPerm.isAttacking then
            self:Log("Click an attacking creature to block it.", "ERROR")
            return
        end

        local blockerIdx = self.blockingState.selectedBlocker
        if not blockerIdx then
            self:Log("Click one of your untapped creatures first to assign as blocker.", "SYSTEM")
            return
        end

        local blockerPerm = self.localState.field[blockerIdx]
        local blockerCard = blockerPerm and TTS.Cards[blockerPerm.id]
        local attackerCard = TTS.Cards[attackerPerm.id]

        if self:HasKeyword(attackerPerm, true, "unblockable") then
            self:Log(attackerCard.name .. " is unblockable!", "ERROR")
            return
        end

        if self:HasKeyword(attackerPerm, true, "flying") and not (self:HasKeyword(blockerPerm, false, "flying") or self:HasKeyword(blockerPerm, false, "reach")) then
            self:Log(string.format("%s has Flying! Only creatures with Flying or Reach can block it.", attackerCard.name), "ERROR")
            return
        end

        self.blockingState.blocks[blockerIdx] = fieldIndex
        self.blockingState.selectedBlocker = nil
        self:Log(string.format("|cFF00FF00%s|r is assigned to block |cFFFF2222%s|r.", blockerCard.name, attackerCard.name), "COMBAT")
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

    for _, atkIdx in ipairs(bs.attackers) do
        local atkPerm = atkField[atkIdx]
        if atkPerm then
            local atkCard = TTS.Cards[atkPerm.id]
            local atkPower, atkToughness = self:GetCreatureStats(atkPerm, isRemoteAttacking)

            local assignedBlockerIdx = nil
            for bIdx, aIdx in pairs(bs.blocks) do
                if aIdx == atkIdx then
                    assignedBlockerIdx = bIdx
                    break
                end
            end

            if assignedBlockerIdx and defField[assignedBlockerIdx] then
                local defPerm = defField[assignedBlockerIdx]
                local defCard = TTS.Cards[defPerm.id]
                local defPower, defToughness = self:GetCreatureStats(defPerm, not isRemoteAttacking)

                self:Log(string.format("Combat clash: %s (%d/%d, Deals %d vs %d Toughness) vs %s (%d/%d, Deals %d vs %d Toughness).",
                    atkCard.name, atkPower, atkToughness, atkPower, defToughness,
                    defCard.name, defPower, defToughness, defPower, atkToughness), "COMBAT")

                if not self.preventCombatDamage then
                    local atkFirst = self:HasKeyword(atkPerm, isRemoteAttacking, "firstStrike")
                    local defFirst = self:HasKeyword(defPerm, not isRemoteAttacking, "firstStrike")

                    local atkDT = self:HasKeyword(atkPerm, isRemoteAttacking, "deathtouch")
                    local defDT = self:HasKeyword(defPerm, not isRemoteAttacking, "deathtouch")

                    if atkFirst and not defFirst then
                        defPerm.damage = (defPerm.damage or 0) + (atkDT and 999 or atkPower)
                        if (defPerm.damage or 0) < defToughness then
                            atkPerm.damage = (atkPerm.damage or 0) + (defDT and 999 or defPower)
                        end
                    elseif defFirst and not atkFirst then
                        atkPerm.damage = (atkPerm.damage or 0) + (defDT and 999 or defPower)
                        if (atkPerm.damage or 0) < atkToughness then
                            defPerm.damage = (defPerm.damage or 0) + (atkDT and 999 or atkPower)
                        end
                    else
                        atkPerm.damage = (atkPerm.damage or 0) + (defDT and 999 or defPower)
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

                    if self:HasKeyword(atkPerm, isRemoteAttacking, "trample") then
                        local excess = math.max(0, atkPower - defToughness)
                        if excess > 0 then
                            DamageDefender(excess, atkCard.name .. " Trample")
                        end
                    end

                    if self:HasKeyword(atkPerm, isRemoteAttacking, "lifelink") and atkPower > 0 then
                        if isRemoteAttacking then self.remoteState.life = self.remoteState.life + atkPower
                        else self.localState.life = self.localState.life + atkPower end
                    end
                    if self:HasKeyword(defPerm, not isRemoteAttacking, "lifelink") and defPower > 0 then
                        if not isRemoteAttacking then self.remoteState.life = self.remoteState.life + defPower
                        else self.localState.life = self.localState.life + defPower end
                    end
                end
            else
                if not self.preventCombatDamage then
                    DamageDefender(atkPower, atkCard.name .. " Attack")

                    if atkPerm.id == "BOSS16" and atkPower > 0 then
                        local pLands = isRemoteAttacking and self.localState.field or self.remoteState.field
                        for lIdx = #pLands, 1, -1 do
                            if TTS.Cards[pLands[lIdx].id].type == "Land" then
                                table.remove(pLands, lIdx)
                                self:Log("Princess Theradras shattered a prayer on impact!", "ACTION")
                                break
                            end
                        end
                    end

                    if self:HasKeyword(atkPerm, isRemoteAttacking, "lifelink") and atkPower > 0 then
                        if isRemoteAttacking then self.remoteState.life = self.remoteState.life + atkPower
                        else self.localState.life = self.localState.life + atkPower end
                    end
                else
                    self:Log(string.format("%s attacked, but combat damage was prevented!", atkCard.name), "COMBAT")
                end
            end

            atkPerm.isAttacking = nil
        end
    end

    self.blockingState = nil
    self:CheckStateBasedActions()

    if isRemoteAttacking then
        if self.isSolo then
            self:SetPhase("WAITING (Dummy Turn)")
            TTS:SafeAfter(0.8, function()
                if E.inMatch and E.isSolo then
                    E:Log("Target Dummy passed turn.", "SYSTEM")
                    E:OnRemoteEndTurn()
                end
            end)
        end
    else
        self:SetPhase("MAIN2")
        self:Log("--- Main Phase 2 ---", "SYSTEM")
    end
    self:RefreshUI()
end