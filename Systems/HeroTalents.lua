--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
TTS.Hero = TTS.Hero or {}
local H = TTS.Hero

-- =========================================================================
-- HERO TALENTS
-- Every 10 character levels (six milestones, 10 to 60) the hero card takes one talent from
-- three, one for each of the class's specs (Systems\Hero.lua adds them up). A talent is:
--   id    "<class><tier><spec>", e.g. WAR3A: its saved name, and its text's locale keys
--         (hero.talent.<id>.name / .text; the English below is the fallback)
--   n     its name, text: what it does in rules text (keywords are listed from kw instead)
--   c     the mana it adds to the card's cost, p / t its power and toughness
--   kw    keywords it gives, { haste = true, bulwark = 3 } (a number: the larger one wins)
--   etb   an Arrival effect, atk one when it attacks (card.onAttack), ab a {T} ability
--         (card.ability, as a Settlement's: { tap, cost, target, ops })
-- Rules the data keeps to, so any six picks make one working card:
--   * one tier per class has targeted Arrivals (etb.target): the card has a single target
--   * abilities only at tier 6 (the signature): a card has one
--   * untargeted Arrivals and attack effects from different tiers just add up
-- Tier costs 1, 1, 1, 1, 0, 1: a hero at 60 costs 6 with around 6/6 stats, four or five
-- keywords and a signature ability, as strong as any card in the game.
-- =========================================================================
local function FriendlyBuff(p, t, kw)
    return { ops = { { op = "buff", to = "friendly_creatures", p = p, t = t, kw = kw } } }
end

H.TALENTS = {
    -- =====================================================================
    -- WARRIOR (Quick, 2/2): Arms, Fury, Protection
    -- =====================================================================
    WARRIOR = {
        {
            { id = "WAR1A", n = "Weapon Mastery", c = 1, p = 2, t = 0 },
            { id = "WAR1B", n = "Bloodthirst",    c = 1, p = 1, t = 0, kw = { enrage = true } },
            { id = "WAR1C", n = "Toughness",      c = 1, p = 0, t = 2 },
        },
        {
            { id = "WAR2A", n = "Sweeping Strikes", c = 1, p = 1, t = 0, kw = { trample = true } },
            { id = "WAR2B", n = "Flurry",           c = 1, p = 1, t = 1 },
            { id = "WAR2C", n = "Shield Wall",      c = 1, p = 0, t = 1, kw = { shielded = true } },
        },
        {
            { id = "WAR3A", n = "Mortal Strike", c = 1, p = 1, t = 1, kw = { firstStrike = true } },
            { id = "WAR3B", n = "Rampage",       c = 1, p = 1, t = 1, kw = { trample = true } },
            { id = "WAR3C", n = "Last Stand",    c = 1, p = 0, t = 2, kw = { bulwark = 2 } },
        },
        {
            { id = "WAR4A", n = "Impale",      c = 1, p = 1, t = 1 },
            { id = "WAR4B", n = "Battle Shout", c = 1, p = 1, t = 0, atk = FriendlyBuff(1, 0),
              text = "Aggro: Your denizens get +1/+0 this turn." },
            { id = "WAR4C", n = "Defiance",    c = 1, p = 1, t = 1, kw = { reach = true } },
        },
        {
            { id = "WAR5A", n = "Overpower",    c = 0, p = 0, t = 0, kw = { vigilance = true } },
            { id = "WAR5B", n = "Death Wish",   c = 0, p = 0, t = 0, kw = { deathtouch = true } },
            { id = "WAR5C", n = "Shield Block", c = 0, p = 0, t = 0, kw = { support = true } },
        },
        {
            { id = "WAR6A", n = "Execute", c = 1, p = 1, t = 1,
              etb = { target = "enemy_creature", ops = { { op = "destroy", to = "target", only = { maxPower = 4 } } } },
              text = "Arrival: Destroy target enemy denizen with power 4 or less." },
            { id = "WAR6B", n = "Recklessness", c = 1, p = 1, t = 0, atk = FriendlyBuff(2, 0),
              text = "Aggro: Your denizens get +2/+0 this turn." },
            { id = "WAR6C", n = "Shockwave", c = 1, p = 0, t = 2,
              etb = { ops = { { op = "freeze", to = "enemy_creatures", only = { maxPower = 3 } } } },
              text = "Arrival: Freeze every enemy denizen with power 3 or less." },
        },
    },

    -- =====================================================================
    -- PALADIN (Bulwark 2, 1/3): Holy, Protection, Retribution
    -- =====================================================================
    PALADIN = {
        {
            { id = "PAL1A", n = "Holy Light", c = 1, p = 0, t = 1,
              etb = { ops = { { op = "heal", to = "self_player", n = 3 } } }, text = "Arrival: You restore 3 life." },
            { id = "PAL1B", n = "Toughness",         c = 1, p = 0, t = 2 },
            { id = "PAL1C", n = "Seal of Command",   c = 1, p = 2, t = 0 },
        },
        {
            { id = "PAL2A", n = "Blessing of Kings", c = 1, p = 0, t = 1,
              etb = { target = "friendly_creature", ops = { { op = "buff", to = "target", p = 1, t = 1, perm = true } } },
              text = "Arrival: Target friendly denizen gets +1/+1." },
            { id = "PAL2B", n = "Divine Shield",    c = 1, p = 0, t = 1, kw = { shielded = true } },
            { id = "PAL2C", n = "Crusader Strike",  c = 1, p = 1, t = 0, kw = { firstStrike = true } },
        },
        {
            { id = "PAL3A", n = "Redemption", c = 1, p = 1, t = 1,
              etb = { ops = { { op = "raise", src = "own" } } }, text = "Arrival: Return a denizen card from your graveyard to the battlefield." },
            { id = "PAL3B", n = "Holy Shield",          c = 1, p = 1, t = 1, kw = { bulwark = 3 } },
            { id = "PAL3C", n = "Seal of Righteousness", c = 1, p = 1, t = 1, kw = { lifelink = true } },
        },
        {
            { id = "PAL4A", n = "Blessing of Light",  c = 1, p = 1, t = 1, kw = { support = true } },
            { id = "PAL4B", n = "Righteous Fury",     c = 1, p = 1, t = 1, kw = { vigilance = true } },
            { id = "PAL4C", n = "Vengeance",          c = 1, p = 1, t = 0, kw = { enrage = true } },
        },
        {
            { id = "PAL5A", n = "Lay on Hands", c = 0, p = 0, t = 0,
              etb = { ops = { { op = "heal", to = "self_player", n = 5 } } }, text = "Arrival: You restore 5 life." },
            { id = "PAL5B", n = "Avenger's Shield", c = 0, p = 0, t = 0,
              etb = { ops = { { op = "freeze", to = "strongest_enemy" } } }, text = "Arrival: Freeze the strongest enemy denizen." },
            { id = "PAL5C", n = "Art of War", c = 0, p = 0, t = 0, kw = { haste = true } },
        },
        {
            { id = "PAL6A", n = "Divine Intervention", c = 1, p = 1, t = 1,
              etb = { ops = { { op = "shielded", to = "friendly_creatures" }, { op = "heal", to = "self_player", n = 4 } } },
              text = "Arrival: Your denizens gain Absorb, and you restore 4 life." },
            { id = "PAL6B", n = "Consecration", c = 1, p = 1, t = 1,
              ab = { tap = true, ops = { { op = "damage", to = "enemy_creatures", n = 1 } } },
              text = "{T}: Deal 1 damage to each enemy denizen." },
            { id = "PAL6C", n = "Divine Storm", c = 1, p = 2, t = 0,
              atk = { ops = { { op = "damage", to = "enemy_creatures", n = 1 }, { op = "heal", to = "self_player", n = 2 } } },
              text = "Aggro: Deal 1 damage to each enemy denizen, and you restore 2 life." },
        },
    },

    -- =====================================================================
    -- SHAMAN (Support, 1/3): Elemental, Enhancement, Restoration
    -- =====================================================================
    SHAMAN = {
        {
            { id = "SHA1A", n = "Elemental Fury", c = 1, p = 1, t = 0,
              etb = { ops = { { op = "damage", to = "enemy_player", n = 2 } } }, text = "Arrival: Deal 2 damage to the opponent." },
            { id = "SHA1B", n = "Flurry",       c = 1, p = 2, t = 0 },
            { id = "SHA1C", n = "Healing Wave", c = 1, p = 0, t = 1,
              etb = { ops = { { op = "heal", to = "self_player", n = 3 } } }, text = "Arrival: You restore 3 life." },
        },
        {
            { id = "SHA2A", n = "Lightning Shield",  c = 1, p = 0, t = 1, kw = { shielded = true } },
            { id = "SHA2B", n = "Stormstrike",       c = 1, p = 1, t = 0, kw = { trample = true } },
            { id = "SHA2C", n = "Ancestral Healing", c = 1, p = 0, t = 2 },
        },
        {
            { id = "SHA3A", n = "Chain Lightning", c = 1, p = 1, t = 1,
              etb = { target = "creature_or_enemy", ops = { { op = "damage", to = "target", n = 3 } } },
              text = "Arrival: Deal 3 damage to target denizen or the opponent." },
            { id = "SHA3B", n = "Windfury Weapon", c = 1, p = 1, t = 1, atk = FriendlyBuff(1, 0),
              text = "Aggro: Your denizens get +1/+0 this turn." },
            { id = "SHA3C", n = "Mana Tide", c = 1, p = 1, t = 1,
              etb = { ops = { { op = "draw", n = 1 } } }, text = "Arrival: Draw a card." },
        },
        {
            { id = "SHA4A", n = "Elemental Focus", c = 1, p = 1, t = 1, kw = { hexproof = true } },
            { id = "SHA4B", n = "Dual Wield",      c = 1, p = 1, t = 1, kw = { vigilance = true } },
            { id = "SHA4C", n = "Purification",    c = 1, p = 1, t = 1, kw = { lifelink = true } },
        },
        {
            { id = "SHA5A", n = "Elemental Mastery",   c = 0, p = 0, t = 0, kw = { haste = true } },
            { id = "SHA5B", n = "Unleashed Rage",      c = 0, p = 0, t = 0, kw = { enrage = true } },
            { id = "SHA5C", n = "Nature's Swiftness",  c = 0, p = 0, t = 0, kw = { haste = true } },
        },
        {
            { id = "SHA6A", n = "Thunderstorm", c = 1, p = 1, t = 1,
              ab = { tap = true, cost = "{2}", ops = { { op = "damage", to = "enemy_creatures", n = 2 } } },
              text = "{T}, {2}: Deal 2 damage to each enemy denizen." },
            { id = "SHA6B", n = "Spirit Wolves", c = 1, p = 1, t = 1, atk = FriendlyBuff(2, 0, { "trample" }),
              text = "Aggro: Your denizens get +2/+0 and Cleave this turn." },
            { id = "SHA6C", n = "Chain Heal", c = 1, p = 1, t = 1,
              ab = { tap = true, ops = { { op = "heal", to = "friendly_creatures", n = 3 }, { op = "heal", to = "self_player", n = 3 } } },
              text = "{T}: Heal 3 damage from each of your denizens, and you restore 3 life." },
        },
    },

    -- =====================================================================
    -- HUNTER (Anti-Air, 2/2): Beast Mastery, Marksmanship, Survival
    -- =====================================================================
    HUNTER = {
        {
            { id = "HUN1A", n = "Endurance Training", c = 1, p = 0, t = 2 },
            { id = "HUN1B", n = "Lethal Shots",       c = 1, p = 2, t = 0 },
            { id = "HUN1C", n = "Deflection",         c = 1, p = 1, t = 1 },
        },
        {
            { id = "HUN2A", n = "Bestial Swiftness", c = 1, p = 1, t = 0, kw = { haste = true } },
            { id = "HUN2B", n = "Aimed Shot", c = 1, p = 1, t = 0,
              etb = { ops = { { op = "damage", to = "strongest_enemy", n = 2 } } },
              text = "Arrival: Deal 2 damage to the strongest enemy denizen." },
            { id = "HUN2C", n = "Entrapment", c = 1, p = 0, t = 1,
              etb = { ops = { { op = "freeze", to = "strongest_enemy" } } }, text = "Arrival: Freeze the strongest enemy denizen." },
        },
        {
            { id = "HUN3A", n = "Call Pet", c = 1, p = 1, t = 1,
              etb = { ops = { { op = "token", id = "TOK12", n = 1 } } }, text = "Arrival: Summon a 3/3 Sawtooth Crocolisk Add." },
            { id = "HUN3B", n = "Trueshot Aura", c = 1, p = 1, t = 1, kw = { firstStrike = true } },
            { id = "HUN3C", n = "Wyvern Sting", c = 1, p = 1, t = 1,
              etb = { target = "enemy_creature", ops = { { op = "freeze", to = "target" } } },
              text = "Arrival: Freeze target enemy denizen." },
        },
        {
            { id = "HUN4A", n = "Ferocity",    c = 1, p = 1, t = 1, kw = { trample = true } },
            { id = "HUN4B", n = "Barrage",     c = 1, p = 2, t = 0 },
            { id = "HUN4C", n = "Survivalist", c = 1, p = 1, t = 1, kw = { vigilance = true } },
        },
        {
            { id = "HUN5A", n = "Spirit Bond",  c = 0, p = 0, t = 0, kw = { lifelink = true } },
            { id = "HUN5B", n = "Hawk Eye",     c = 0, p = 0, t = 0, kw = { flying = true } },
            { id = "HUN5C", n = "Feign Death",  c = 0, p = 0, t = 0, kw = { shielded = true } },
        },
        {
            { id = "HUN6A", n = "Kill Command", c = 1, p = 1, t = 1, atk = FriendlyBuff(1, 1),
              text = "Aggro: Your denizens get +1/+1 this turn." },
            { id = "HUN6B", n = "Volley", c = 1, p = 1, t = 1,
              ab = { tap = true, cost = "{1}", ops = { { op = "damage", to = "enemy_creatures", n = 1 }, { op = "damage", to = "enemy_player", n = 1 } } },
              text = "{T}, {1}: Deal 1 damage to each enemy denizen and to the opponent." },
            { id = "HUN6C", n = "Explosive Trap", c = 1, p = 1, t = 1,
              ab = { tap = true, target = "enemy_creature", ops = { { op = "damage", to = "target", n = 3 } } },
              text = "{T}: Deal 3 damage to target enemy denizen." },
        },
    },

    -- =====================================================================
    -- ROGUE (Invisible, 2/2): Assassination, Combat, Subtlety
    -- =====================================================================
    ROGUE = {
        {
            { id = "ROG1A", n = "Malice",     c = 1, p = 2, t = 0 },
            { id = "ROG1B", n = "Precision",  c = 1, p = 1, t = 1 },
            { id = "ROG1C", n = "Camouflage", c = 1, p = 0, t = 2 },
        },
        {
            { id = "ROG2A", n = "Lethality",   c = 1, p = 1, t = 0, kw = { firstStrike = true } },
            { id = "ROG2B", n = "Blade Flurry", c = 1, p = 1, t = 1 },
            { id = "ROG2C", n = "Elusiveness", c = 1, p = 0, t = 1, kw = { hexproof = true } },
        },
        {
            { id = "ROG3A", n = "Cold Blood", c = 1, p = 1, t = 1, kw = { deathtouch = true } },
            { id = "ROG3B", n = "Adrenaline Rush", c = 1, p = 1, t = 1, kw = { haste = true } },
            { id = "ROG3C", n = "Ambush", c = 1, p = 1, t = 0,
              etb = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 3 } } },
              text = "Arrival: Deal 3 damage to target enemy denizen." },
        },
        {
            { id = "ROG4A", n = "Seal Fate",           c = 1, p = 2, t = 0 },
            { id = "ROG4B", n = "Riposte",             c = 1, p = 1, t = 1, kw = { firstStrike = true } },
            { id = "ROG4C", n = "Master of Deception", c = 1, p = 1, t = 1, kw = { vigilance = true } },
        },
        {
            { id = "ROG5A", n = "Find Weakness",     c = 0, p = 0, t = 0, kw = { trample = true } },
            { id = "ROG5B", n = "Weapon Expertise",  c = 0, p = 0, t = 0, kw = { enrage = true } },
            { id = "ROG5C", n = "Preparation",       c = 0, p = 0, t = 0, kw = { shielded = true } },
        },
        {
            { id = "ROG6A", n = "Envenom", c = 1, p = 1, t = 1,
              atk = { ops = { { op = "destroy", to = "strongest_enemy", only = { maxPower = 3 } } } },
              text = "Aggro: Destroy the strongest enemy denizen with power 3 or less." },
            { id = "ROG6B", n = "Killing Spree", c = 1, p = 1, t = 1,
              atk = { ops = { { op = "damage", to = "enemy_creatures", n = 1 } } },
              text = "Aggro: Deal 1 damage to each enemy denizen." },
            { id = "ROG6C", n = "Vanish", c = 1, p = 1, t = 1,
              ab = { tap = true, target = "enemy_creature", ops = { { op = "bounce", to = "target" } } },
              text = "{T}: Return target enemy denizen to its owner's hand." },
        },
    },

    -- =====================================================================
    -- PRIEST (Shielded, 0/4): Discipline, Holy, Shadow
    -- =====================================================================
    PRIEST = {
        {
            { id = "PRI1A", n = "Power Word: Fortitude", c = 1, p = 0, t = 1,
              etb = { ops = { { op = "buff", to = "friendly_creatures", t = 1, perm = true } } },
              text = "Arrival: Your denizens get +0/+1." },
            { id = "PRI1B", n = "Holy Specialization", c = 1, p = 1, t = 1 },
            { id = "PRI1C", n = "Shadow Weaving",      c = 1, p = 2, t = 0 },
        },
        {
            { id = "PRI2A", n = "Inner Fire", c = 1, p = 1, t = 1 },
            { id = "PRI2B", n = "Renew", c = 1, p = 0, t = 1,
              etb = { ops = { { op = "heal", to = "self_player", n = 3 } } }, text = "Arrival: You restore 3 life." },
            { id = "PRI2C", n = "Shadow Word: Pain", c = 1, p = 1, t = 0,
              etb = { ops = { { op = "damage", to = "enemy_player", n = 2 } } }, text = "Arrival: Deal 2 damage to the opponent." },
        },
        {
            { id = "PRI3A", n = "Power Word: Shield", c = 1, p = 1, t = 1,
              etb = { target = "friendly_creature", ops = { { op = "shielded", to = "target" } } },
              text = "Arrival: Target friendly denizen gains Absorb." },
            { id = "PRI3B", n = "Resurrection", c = 1, p = 1, t = 1,
              etb = { ops = { { op = "raise", src = "own" } } }, text = "Arrival: Return a denizen card from your graveyard to the battlefield." },
            { id = "PRI3C", n = "Mind Flay", c = 1, p = 1, t = 1,
              etb = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 2 }, { op = "freeze", to = "target" } } },
              text = "Arrival: Deal 2 damage to target enemy denizen and Freeze it." },
        },
        {
            { id = "PRI4A", n = "Divine Spirit",         c = 1, p = 1, t = 1, kw = { support = true } },
            { id = "PRI4B", n = "Spirit of Redemption",  c = 1, p = 1, t = 1, kw = { vigilance = true } },
            { id = "PRI4C", n = "Vampiric Embrace",      c = 1, p = 1, t = 1, kw = { lifelink = true } },
        },
        {
            { id = "PRI5A", n = "Pain Suppression", c = 0, p = 0, t = 0, kw = { bulwark = 2 } },
            { id = "PRI5B", n = "Holy Nova", c = 0, p = 0, t = 0,
              etb = { ops = { { op = "damage", to = "enemy_creatures", n = 1 }, { op = "heal", to = "self_player", n = 2 } } },
              text = "Arrival: Deal 1 damage to each enemy denizen, and you restore 2 life." },
            { id = "PRI5C", n = "Shadowform", c = 0, p = 0, t = 0, kw = { hexproof = true } },
        },
        {
            { id = "PRI6A", n = "Power Infusion", c = 1, p = 1, t = 1,
              ab = { tap = true, target = "friendly_creature", ops = { { op = "buff", to = "target", p = 2, t = 2, perm = true } } },
              text = "{T}: Target friendly denizen gets +2/+2." },
            { id = "PRI6B", n = "Prayer of Healing", c = 1, p = 1, t = 1,
              ab = { tap = true, ops = { { op = "heal", to = "friendly_creatures", n = 99 }, { op = "heal", to = "self_player", n = 3 } } },
              text = "{T}: Fully heal your denizens, and you restore 3 life." },
            { id = "PRI6C", n = "Mind Control", c = 1, p = 1, t = 1,
              ab = { tap = true, cost = "{3}", target = "enemy_creature", ops = { { op = "steal", to = "target", maxPower = 3 } } },
              text = "{T}, {3}: Gain control of target enemy denizen with power 3 or less." },
        },
    },

    -- =====================================================================
    -- MAGE (Warded, 0/4): Arcane, Fire, Frost
    -- =====================================================================
    MAGE = {
        {
            { id = "MAG1A", n = "Arcane Intellect", c = 1, p = 0, t = 1,
              etb = { ops = { { op = "draw", n = 1 } } }, text = "Arrival: Draw a card." },
            { id = "MAG1B", n = "Ignite",      c = 1, p = 2, t = 0 },
            { id = "MAG1C", n = "Frost Armor", c = 1, p = 0, t = 2 },
        },
        {
            { id = "MAG2A", n = "Arcane Focus", c = 1, p = 1, t = 1 },
            { id = "MAG2B", n = "Fire Blast", c = 1, p = 1, t = 0,
              etb = { ops = { { op = "damage", to = "enemy_player", n = 2 } } }, text = "Arrival: Deal 2 damage to the opponent." },
            { id = "MAG2C", n = "Frostbolt", c = 1, p = 0, t = 1,
              etb = { ops = { { op = "freeze", to = "strongest_enemy" } } }, text = "Arrival: Freeze the strongest enemy denizen." },
        },
        {
            { id = "MAG3A", n = "Presence of Mind", c = 1, p = 1, t = 1, kw = { haste = true } },
            { id = "MAG3B", n = "Fireball", c = 1, p = 1, t = 1,
              etb = { target = "creature_or_enemy", ops = { { op = "damage", to = "target", n = 3 } } },
              text = "Arrival: Deal 3 damage to target denizen or the opponent." },
            { id = "MAG3C", n = "Ice Lance", c = 1, p = 1, t = 1,
              etb = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 2 }, { op = "freeze", to = "target" } } },
              text = "Arrival: Deal 2 damage to target enemy denizen and Freeze it." },
        },
        {
            { id = "MAG4A", n = "Arcane Power", c = 1, p = 2, t = 0 },
            { id = "MAG4B", n = "Combustion",   c = 1, p = 1, t = 1, kw = { trample = true } },
            { id = "MAG4C", n = "Ice Barrier",  c = 1, p = 0, t = 1, kw = { shielded = true } },
        },
        {
            { id = "MAG5A", n = "Arcane Mind", c = 0, p = 0, t = 0, kw = { vigilance = true } },
            { id = "MAG5B", n = "Blast Wave", c = 0, p = 0, t = 0,
              etb = { ops = { { op = "damage", to = "enemy_creatures", n = 1 } } }, text = "Arrival: Deal 1 damage to each enemy denizen." },
            { id = "MAG5C", n = "Cold Snap", c = 0, p = 0, t = 0, kw = { reach = true } },
        },
        {
            { id = "MAG6A", n = "Evocation", c = 1, p = 1, t = 1,
              ab = { tap = true, ops = { { op = "draw", n = 1 } } }, text = "{T}: Draw a card." },
            { id = "MAG6B", n = "Pyroblast", c = 1, p = 1, t = 1,
              ab = { tap = true, cost = "{2}", target = "creature_or_enemy", ops = { { op = "damage", to = "target", n = 4 } } },
              text = "{T}, {2}: Deal 4 damage to target denizen or the opponent." },
            { id = "MAG6C", n = "Blizzard", c = 1, p = 1, t = 1,
              ab = { tap = true, ops = { { op = "damage", to = "enemy_creatures", n = 1 }, { op = "freeze", to = "strongest_enemy" } } },
              text = "{T}: Deal 1 damage to each enemy denizen, then Freeze the strongest." },
        },
    },

    -- =====================================================================
    -- WARLOCK (Drain, 1/3): Affliction, Demonology, Destruction
    -- =====================================================================
    WARLOCK = {
        {
            { id = "WLK1A", n = "Corruption", c = 1, p = 1, t = 0,
              etb = { ops = { { op = "damage", to = "enemy_player", n = 2 } } }, text = "Arrival: Deal 2 damage to the opponent." },
            { id = "WLK1B", n = "Demonic Embrace", c = 1, p = 0, t = 2 },
            { id = "WLK1C", n = "Bane",            c = 1, p = 2, t = 0 },
        },
        {
            { id = "WLK2A", n = "Siphon Life", c = 1, p = 1, t = 1 },
            { id = "WLK2B", n = "Summon Voidwalker", c = 1, p = 0, t = 1,
              etb = { ops = { { op = "token", id = "TOK06", n = 1 } } }, text = "Arrival: Summon a 1/5 Voidwalker Add." },
            { id = "WLK2C", n = "Searing Pain", c = 1, p = 1, t = 0,
              etb = { ops = { { op = "damage", to = "strongest_enemy", n = 2 } } },
              text = "Arrival: Deal 2 damage to the strongest enemy denizen." },
        },
        {
            { id = "WLK3A", n = "Drain Life", c = 1, p = 1, t = 1,
              etb = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 3 }, { op = "heal", to = "self_player", n = 3 } } },
              text = "Arrival: Deal 3 damage to target enemy denizen, and you restore 3 life." },
            { id = "WLK3B", n = "Soul Link", c = 1, p = 1, t = 1, kw = { shielded = true } },
            { id = "WLK3C", n = "Shadowburn", c = 1, p = 1, t = 1,
              etb = { target = "creature_or_enemy", ops = { { op = "damage", to = "target", n = 3 } } },
              text = "Arrival: Deal 3 damage to target denizen or the opponent." },
        },
        {
            { id = "WLK4A", n = "Fel Concentration",   c = 1, p = 1, t = 1, kw = { hexproof = true } },
            { id = "WLK4B", n = "Master Demonologist", c = 1, p = 1, t = 1, kw = { bulwark = 2 } },
            { id = "WLK4C", n = "Ruin",                c = 1, p = 2, t = 0 },
        },
        {
            { id = "WLK5A", n = "Dark Pact",          c = 0, p = 0, t = 0, kw = { deathtouch = true } },
            { id = "WLK5B", n = "Demonic Sacrifice",  c = 0, p = 0, t = 0, kw = { trample = true } },
            { id = "WLK5C", n = "Backlash",           c = 0, p = 0, t = 0, kw = { firstStrike = true } },
        },
        {
            { id = "WLK6A", n = "Death Coil", c = 1, p = 1, t = 1,
              ab = { tap = true, ops = { { op = "damage", to = "enemy_player", n = 3 }, { op = "heal", to = "self_player", n = 3 } } },
              text = "{T}: Deal 3 damage to the opponent, and you restore 3 life." },
            { id = "WLK6B", n = "Summon Felguard", c = 1, p = 1, t = 1,
              ab = { tap = true, cost = "{2}", ops = { { op = "token", id = "TOK06", n = 1 } } },
              text = "{T}, {2}: Summon a 1/5 Voidwalker Add." },
            { id = "WLK6C", n = "Rain of Fire", c = 1, p = 1, t = 1,
              ab = { tap = true, cost = "{1}", ops = { { op = "damage", to = "enemy_creatures", n = 2 } } },
              text = "{T}, {1}: Deal 2 damage to each enemy denizen." },
        },
    },

    -- =====================================================================
    -- DRUID (Vigilant, 1/3): Balance, Feral, Restoration
    -- =====================================================================
    DRUID = {
        {
            { id = "DRU1A", n = "Nature's Grace", c = 1, p = 1, t = 1 },
            { id = "DRU1B", n = "Feral Instinct", c = 1, p = 2, t = 0 },
            { id = "DRU1C", n = "Regrowth", c = 1, p = 0, t = 1,
              etb = { ops = { { op = "heal", to = "self_player", n = 3 } } }, text = "Arrival: You restore 3 life." },
        },
        {
            { id = "DRU2A", n = "Entangling Roots", c = 1, p = 0, t = 1,
              etb = { ops = { { op = "freeze", to = "strongest_enemy" } } }, text = "Arrival: Freeze the strongest enemy denizen." },
            { id = "DRU2B", n = "Thick Hide", c = 1, p = 0, t = 2 },
            { id = "DRU2C", n = "Nature's Swiftness", c = 1, p = 1, t = 0, kw = { haste = true } },
        },
        {
            { id = "DRU3A", n = "Starfire", c = 1, p = 1, t = 1,
              etb = { target = "creature_or_enemy", ops = { { op = "damage", to = "target", n = 3 } } },
              text = "Arrival: Deal 3 damage to target denizen or the opponent." },
            { id = "DRU3B", n = "Cat Form", c = 1, p = 1, t = 1, kw = { trample = true } },
            { id = "DRU3C", n = "Swiftmend", c = 1, p = 1, t = 1,
              etb = { target = "friendly_creature", ops = { { op = "buff", to = "target", p = 2, t = 2, perm = true } } },
              text = "Arrival: Target friendly denizen gets +2/+2." },
        },
        {
            { id = "DRU4A", n = "Moonkin Form",    c = 1, p = 1, t = 0, kw = { flying = true } },
            { id = "DRU4B", n = "Savage Fury",     c = 1, p = 1, t = 1, kw = { firstStrike = true } },
            { id = "DRU4C", n = "Tranquil Spirit", c = 1, p = 1, t = 1, kw = { support = true } },
        },
        {
            { id = "DRU5A", n = "Hurricane", c = 0, p = 0, t = 0,
              etb = { ops = { { op = "damage", to = "enemy_creatures", n = 1 } } }, text = "Arrival: Deal 1 damage to each enemy denizen." },
            { id = "DRU5B", n = "Feral Swiftness", c = 0, p = 0, t = 0, kw = { haste = true } },
            { id = "DRU5C", n = "Barkskin",        c = 0, p = 0, t = 0, kw = { shielded = true } },
        },
        {
            { id = "DRU6A", n = "Starfall", c = 1, p = 1, t = 1,
              ab = { tap = true, cost = "{2}", ops = { { op = "damage", to = "enemy_creatures", n = 2 } } },
              text = "{T}, {2}: Deal 2 damage to each enemy denizen." },
            { id = "DRU6B", n = "Leader of the Pack", c = 1, p = 1, t = 1, atk = FriendlyBuff(1, 1),
              text = "Aggro: Your denizens get +1/+1 this turn." },
            { id = "DRU6C", n = "Tranquility", c = 1, p = 1, t = 1,
              ab = { tap = true, ops = { { op = "heal", to = "friendly_creatures", n = 99 }, { op = "heal", to = "self_player", n = 4 } } },
              text = "{T}: Fully heal your denizens, and you restore 4 life." },
        },
    },
}

-- Each class's specs, in the order of every tier's three options (A, B, C); shown over them
-- (locale keys hero.spec.<class>.<n>)
H.SPECS = {
    WARRIOR = { "Arms", "Fury", "Protection" },
    PALADIN = { "Holy", "Protection", "Retribution" },
    SHAMAN  = { "Elemental", "Enhancement", "Restoration" },
    HUNTER  = { "Beast Mastery", "Marksmanship", "Survival" },
    ROGUE   = { "Assassination", "Combat", "Subtlety" },
    PRIEST  = { "Discipline", "Holy", "Shadow" },
    MAGE    = { "Arcane", "Fire", "Frost" },
    WARLOCK = { "Affliction", "Demonology", "Destruction" },
    DRUID   = { "Balance", "Feral", "Restoration" },
}

function H:SpecName(classFile, n)
    local list = self.SPECS[classFile]
    local name = list and list[n] or "?"
    local Loc = TTS.Locale
    return Loc and Loc:Data("hero.spec." .. classFile .. "." .. n, name) or name
end

-- id -> { talent, class, tier }
H.TALENT_BY_ID = {}
for classFile, tiers in pairs(H.TALENTS) do
    for tier, options in ipairs(tiers) do
        for _, talent in ipairs(options) do
            H.TALENT_BY_ID[talent.id] = { talent = talent, class = classFile, tier = tier }
        end
    end
end

-- Its name and rules text in the chosen language (English from the data above as fallback)
function H:TalentName(talent)
    local Loc = TTS.Locale
    return Loc and Loc:Data("hero.talent." .. talent.id .. ".name", talent.n) or talent.n
end
function H:TalentText(talent)
    if not talent.text then return nil end
    local Loc = TTS.Locale
    return Loc and Loc:Data("hero.talent." .. talent.id .. ".text", talent.text) or talent.text
end
