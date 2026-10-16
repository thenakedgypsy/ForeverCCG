--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- CLASS SPELLS (10 per playable class)
-- Resolved generically by TTS.Engine:ResolveSpell (see CardLogic.lua).
-- effect.target: enemy_creature | friendly_creature | creature | enemy_any | friendly_any | any | enemy_player | player | nil (no target)
-- =========================================================================
TTS:AddCards({
    -- SHAMAN
    ["SHA01"] = {
        id = "SHA01", name = "Lightning Bolt", cost = "{1}{G}", cmc = 2, color = "G", type = "Sorcery", class = "Shaman",
        text = "Deal 3 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Spell_Nature_Lightning",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 } } }
    },
    ["SHA02"] = {
        id = "SHA02", name = "Earth Shock", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Shaman",
        text = "Deal 2 damage to target enemy creature.",
        art = "Interface\\Icons\\Spell_Nature_EarthShock",
        effect = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 2 } } }
    },
    ["SHA03"] = {
        id = "SHA03", name = "Flame Shock", cost = "{1}{R}", cmc = 2, color = "R", type = "Sorcery", class = "Shaman",
        text = "Deal 1 damage to target enemy creature or the opponent. Then, at the start of each of your turns for 3 turns, the opponent takes 1 more damage, or the creature permanently gets -0/-1.",
        art = "Interface\\Icons\\Spell_Fire_FlameShock",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 1 }, { op = "dot", to = "target", n = 1, turns = 3 } } }
    },
    ["SHA04"] = {
        id = "SHA04", name = "Frost Shock", cost = "{1}{U}", cmc = 2, color = "U", type = "Sorcery", class = "Shaman",
        text = "Deal 1 damage to target enemy creature and tap it. It does not untap during its controller's next untap step.",
        art = "Interface\\Icons\\Spell_Frost_FrostShock",
        effect = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 1 }, { op = "freeze", to = "target" } } }
    },
    ["SHA05"] = {
        id = "SHA05", name = "Chain Lightning", cost = "{3}{G}", cmc = 4, color = "G", type = "Sorcery", class = "Shaman",
        text = "Deal 2 damage to each enemy creature and to the opponent.",
        art = "Interface\\Icons\\Spell_Nature_ChainLightning",
        effect = { ops = { { op = "damage", to = "enemy_creatures", n = 2 }, { op = "damage", to = "enemy_player", n = 2 } } }
    },
    ["SHA06"] = {
        id = "SHA06", name = "Healing Wave", cost = "{2}{W}", cmc = 3, color = "W", type = "Sorcery", class = "Shaman",
        text = "You or target creature you control regains 7 health.",
        art = "Interface\\Icons\\Spell_Nature_MagicImmunity",
        effect = { target = "friendly_any", ops = { { op = "heal", to = "target", n = 7 } } }
    },
    ["SHA07"] = {
        id = "SHA07", name = "Rockbiter Weapon", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Shaman",
        text = "Target creature you control gets +2/+0 until end of turn.",
        art = "Interface\\Icons\\Spell_Nature_RockBiter",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", p = 2 } } }
    },
    ["SHA08"] = {
        id = "SHA08", name = "Stoneskin Totem", cost = "{1}{G}", cmc = 2, color = "G", type = "Sorcery", class = "Shaman",
        text = "Creatures you control get +0/+2 until end of turn.",
        art = "Interface\\Icons\\Spell_Nature_StoneSkinTotem",
        effect = { ops = { { op = "buff", to = "friendly_creatures", t = 2 } } }
    },
    ["SHA09"] = {
        id = "SHA09", name = "Purge", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Shaman",
        text = "Remove beneficial effects from target enemy creature, or harmful effects from target creature you control.",
        art = "Interface\\Icons\\Spell_Holy_Dizzy",
        effect = { target = "creature", ops = { { op = "dispel", to = "target" } } }
    },
    ["SHA10"] = {
        id = "SHA10", name = "Ancestral Spirit", cost = "{4}{W}", cmc = 5, color = "W", type = "Sorcery", class = "Shaman",
        text = "Return a creature card from any graveyard to the battlefield under your control.",
        art = "Interface\\Icons\\Spell_Nature_Regenerate",
        effect = { ops = { { op = "raise", src = "any" } } }
    },
})
