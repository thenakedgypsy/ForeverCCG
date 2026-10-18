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
    -- MAGE
    ["MAG01"] = {
        id = "MAG01", name = "Fireball", cost = "{2}{R}", cmc = 3, color = "R", type = "Sorcery", class = "Mage",
        text = "Deal 3 damage to target enemy denizen or the opponent, then DoT 1 for 2 turns.",
        art = "Interface\\Icons\\Spell_Fire_FlameBolt",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 }, { op = "dot", to = "target", n = 1, turns = 2 } } }
    },
    ["MAG02"] = {
        id = "MAG02", name = "Fire Blast", cost = "{R}", cmc = 1, color = "R", type = "Sorcery", class = "Mage",
        text = "Deal 2 damage to target enemy denizen or the opponent.",
        art = "Interface\\Icons\\Spell_Fire_Fireball",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 2 } } }
    },
    ["MAG03"] = {
        id = "MAG03", name = "Flamestrike", cost = "{3}{R}", cmc = 4, color = "R", type = "Sorcery", class = "Mage",
        text = "Deal 3 damage to each enemy denizen.",
        art = "Interface\\Icons\\Spell_Fire_SelfDestruct",
        effect = { ops = { { op = "damage", to = "enemy_creatures", n = 3 } } }
    },
    ["MAG04"] = {
        id = "MAG04", name = "Pyroblast", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Sorcery", class = "Mage",
        text = "Deal 6 damage to target enemy denizen or the opponent.",
        art = "Interface\\Icons\\Spell_Fire_Fireball02",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 6 } } }
    },
    ["MAG05"] = {
        id = "MAG05", name = "Frostbolt", cost = "{2}{U}", cmc = 3, color = "U", type = "Sorcery", class = "Mage",
        text = "Deal 3 damage to target enemy denizen or the opponent. Freeze it if it is a denizen.",
        art = "Interface\\Icons\\Spell_Frost_FrostBolt02",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 }, { op = "freeze", to = "target" } } }
    },
    ["MAG06"] = {
        id = "MAG06", name = "Frost Nova", cost = "{1}{U}", cmc = 2, color = "U", type = "Sorcery", class = "Mage",
        text = "Exhaust each enemy denizen.",
        art = "Interface\\Icons\\Spell_Frost_FrostNova",
        effect = { ops = { { op = "tap", to = "enemy_creatures" } } }
    },
    ["MAG07"] = {
        id = "MAG07", name = "Blizzard", cost = "{3}{U}", cmc = 4, color = "U", type = "Sorcery", class = "Mage",
        text = "Deal 2 damage to each enemy denizen and Exhaust them.",
        art = "Interface\\Icons\\Spell_Frost_IceStorm",
        effect = { ops = { { op = "damage", to = "enemy_creatures", n = 2 }, { op = "tap", to = "enemy_creatures" } } }
    },
    ["MAG08"] = {
        id = "MAG08", name = "Polymorph", cost = "{1}{U}", cmc = 2, color = "U", type = "Sorcery", class = "Mage",
        text = "Put target enemy denizen on top of its owner's deck.",
        art = "Interface\\Icons\\Spell_Nature_Polymorph",
        effect = { target = "enemy_creature", ops = { { op = "tuck", to = "target" } } }
    },
    ["MAG09"] = {
        id = "MAG09", name = "Arcane Missiles", cost = "{1}{U}", cmc = 2, color = "U", type = "Sorcery", class = "Mage",
        text = "Deal 3 damage to target enemy denizen or the opponent.",
        art = "Interface\\Icons\\Spell_Nature_StarFall",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 } } }
    },
    ["MAG10"] = {
        id = "MAG10", name = "Arcane Intellect", cost = "{2}{U}", cmc = 3, color = "U", type = "Sorcery", class = "Mage",
        text = "Draw 2.",
        art = "Interface\\Icons\\Spell_Holy_MagicalSentry",
        effect = { ops = { { op = "draw", n = 2 } } }
    },
})
