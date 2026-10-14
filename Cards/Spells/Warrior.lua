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
    -- WARRIOR
    ["WAR01"] = {
        id = "WAR01", name = "Heroic Strike", cost = "{R}", cmc = 1, color = "R", type = "Sorcery", class = "Warrior",
        text = "Target creature you control gets +2/+0 until end of turn.",
        art = "Interface\\Icons\\Ability_Rogue_Ambush",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", p = 2 } } }
    },
    ["WAR02"] = {
        id = "WAR02", name = "Charge", cost = "{R}", cmc = 1, color = "R", type = "Sorcery", class = "Warrior",
        text = "Target creature you control gets +1/+0 and gains Quick until end of turn.",
        art = "Interface\\Icons\\Ability_Warrior_Charge",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", p = 1, kw = { "haste" } } } }
    },
    ["WAR03"] = {
        id = "WAR03", name = "Rend", cost = "{1}{R}", cmc = 2, color = "R", type = "Sorcery", class = "Warrior",
        text = "Target enemy creature takes 1 damage at the start of each of your turns for 4 turns.",
        art = "Interface\\Icons\\Ability_Gouge",
        effect = { target = "enemy_creature", ops = { { op = "dot", to = "target", n = 1, turns = 4 } } }
    },
    ["WAR04"] = {
        id = "WAR04", name = "Bloodrage", cost = "{R}", cmc = 1, color = "R", type = "Sorcery", class = "Warrior",
        text = "You take 2 damage. Add {R}{R} to your mana pool.",
        art = "Interface\\Icons\\Ability_Racial_BloodRage",
        effect = { ops = { { op = "damage", to = "self_player", n = 2 }, { op = "mana", n = 2, color = "R" } } }
    },
    ["WAR05"] = {
        id = "WAR05", name = "Thunder Clap", cost = "{1}{R}", cmc = 2, color = "R", type = "Sorcery", class = "Warrior",
        text = "Deal 1 damage to each enemy creature and tap them.",
        art = "Interface\\Icons\\Spell_Nature_ThunderClap",
        effect = { ops = { { op = "damage", to = "enemy_creatures", n = 1 }, { op = "tap", to = "enemy_creatures" } } }
    },
    ["WAR06"] = {
        id = "WAR06", name = "Overpower", cost = "{1}{R}", cmc = 2, color = "R", type = "Sorcery", class = "Warrior",
        text = "Target creature you control gets +3/+0 and gains Strikes-First until end of turn.",
        art = "Interface\\Icons\\Ability_MeleeDamage",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", p = 3, kw = { "firstStrike" } } } }
    },
    ["WAR07"] = {
        id = "WAR07", name = "Execute", cost = "{R}", cmc = 1, color = "R", type = "Sorcery", class = "Warrior",
        text = "Destroy target enemy creature that has been dealt damage.",
        art = "Interface\\Icons\\INV_Sword_48",
        effect = { target = "enemy_creature", ops = { { op = "destroy", to = "target", damaged = true } } }
    },
    ["WAR08"] = {
        id = "WAR08", name = "Shield Wall", cost = "{1}{W}", cmc = 2, color = "W", type = "Sorcery", class = "Warrior",
        text = "Prevent the next 6 damage that would be dealt to you.",
        art = "Interface\\Icons\\Ability_Warrior_ShieldWall",
        effect = { ops = { { op = "shield", to = "self_player", n = 6 } } }
    },
    ["WAR09"] = {
        id = "WAR09", name = "Mortal Strike", cost = "{2}{R}", cmc = 3, color = "R", type = "Sorcery", class = "Warrior",
        text = "Deal 4 damage to target enemy creature.",
        art = "Interface\\Icons\\Ability_Warrior_SavageBlow",
        effect = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 4 } } }
    },
    ["WAR10"] = {
        id = "WAR10", name = "Whirlwind", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Sorcery", class = "Warrior",
        text = "Deal 3 damage to each enemy creature.",
        art = "Interface\\Icons\\Ability_Whirlwind",
        effect = { ops = { { op = "damage", to = "enemy_creatures", n = 3 } } }
    },
})
