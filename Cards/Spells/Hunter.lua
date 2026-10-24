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
    -- HUNTER
    ["HUN01"] = {
        id = "HUN01", name = "Arcane Shot", cost = "{U}", cmc = 1, color = "U", type = "Sorcery", class = "Hunter",
        text = "Deal 2 damage to target enemy denizen or the opponent, then DoT 1 for 2 turns.",
        art = "Interface\\Icons\\Ability_ImpalingBolt",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 2 }, { op = "dot", to = "target", n = 1, turns = 2 } } }
    },
    ["HUN02"] = {
        id = "HUN02", name = "Serpent Sting", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Hunter",
        text = "Deal 2 damage to target enemy denizen or the opponent, then DoT 1 for 4 turns.",
        art = "Interface\\Icons\\Ability_Hunter_Quickshot",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 2 }, { op = "dot", to = "target", n = 1, turns = 4 } } }
    },
    ["HUN03"] = {
        id = "HUN03", name = "Aimed Shot", cost = "{2}{G}", cmc = 3, color = "G", type = "Sorcery", class = "Hunter",
        text = "Deal 4 damage to target enemy denizen or the opponent.",
        art = "Interface\\Icons\\INV_Spear_07",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 4 } } }
    },
    ["HUN04"] = {
        id = "HUN04", name = "Multi-Shot", cost = "{2}{G}", cmc = 3, color = "G", type = "Sorcery", class = "Hunter",
        text = "Deal 2 damage to each enemy denizen.",
        art = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
        effect = { ops = { { op = "damage", to = "enemy_creatures", n = 2 } } }
    },
    ["HUN05"] = {
        id = "HUN05", name = "Concussive Shot", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Hunter",
        text = "Exhaust target enemy denizen. Draw 1.",
        art = "Interface\\Icons\\Spell_Frost_Stun",
        effect = { target = "enemy_creature", ops = { { op = "tap", to = "target" }, { op = "draw", n = 1 } } }
    },
    ["HUN06"] = {
        id = "HUN06", name = "Freezing Trap", cost = "{1}{U}", cmc = 2, color = "U", type = "Sorcery", class = "Hunter",
        text = "Freeze target enemy denizen.",
        art = "Interface\\Icons\\Spell_Frost_ChainsOfIce",
        effect = { target = "enemy_creature", ops = { { op = "freeze", to = "target" } } }
    },
    ["HUN07"] = {
        id = "HUN07", name = "Immolation Trap", cost = "{2}{R}", cmc = 3, color = "R", type = "Sorcery", class = "Hunter",
        text = "Deal 2 damage to target enemy denizen or the opponent, then DoT 2 for 3 turns.",
        art = "Interface\\Icons\\Spell_Fire_FlameShock",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 2 }, { op = "dot", to = "target", n = 2, turns = 3 } } }
    },
    ["HUN08"] = {
        id = "HUN08", name = "Mend Pet", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Hunter",
        text = "Target denizen you control permanently gets +0/+1, then HoT 1 for 3 turns. Draw 1.",
        art = "Interface\\Icons\\Ability_Hunter_MendPet",
        effect = { target = "friendly_creature", ops = { { op = "heal", to = "target", n = 3, t = 1 }, { op = "hot", to = "target", n = 1, turns = 3 }, { op = "draw", n = 1 } } }
    },
    ["HUN09"] = {
        id = "HUN09", name = "Hunter's Mark", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Hunter",
        text = "Target enemy denizen permanently gets -2/-2.",
        art = "Interface\\Icons\\Ability_Hunter_SniperShot",
        effect = { target = "enemy_creature", ops = { { op = "buff", to = "target", p = -2, t = -2, perm = true } } }
    },
    ["HUN10"] = {
        id = "HUN10", name = "Bestial Wrath", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Sorcery", class = "Hunter",
        text = "Target denizen you control permanently gets +3/+3 and gains Brutish.",
        art = "Interface\\Icons\\Ability_Druid_FerociousBite",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", p = 3, t = 3, kw = { "trample" }, perm = true } } }
    },
})
