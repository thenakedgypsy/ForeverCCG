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
    -- ROGUE
    ["ROG01"] = {
        id = "ROG01", name = "Sinister Strike", cost = "{B}", cmc = 1, color = "B", type = "Sorcery", class = "Rogue",
        text = "Deal 2 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 2 } } }
    },
    ["ROG02"] = {
        id = "ROG02", name = "Backstab", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Rogue",
        text = "Deal 3 damage to target enemy creature, or 6 damage if it is tapped.",
        art = "Interface\\Icons\\Ability_BackStab",
        effect = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 3, bonusIfTapped = 3 } } }
    },
    ["ROG03"] = {
        id = "ROG03", name = "Eviscerate", cost = "{2}{B}", cmc = 3, color = "B", type = "Sorcery", class = "Rogue",
        text = "Deal 5 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Ability_Rogue_Eviscerate",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 5 } } }
    },
    ["ROG04"] = {
        id = "ROG04", name = "Gouge", cost = "{B}", cmc = 1, color = "B", type = "Sorcery", class = "Rogue",
        text = "Deal 1 damage to target enemy creature and tap it.",
        art = "Interface\\Icons\\Ability_Gouge",
        effect = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 1 }, { op = "tap", to = "target" } } }
    },
    ["ROG05"] = {
        id = "ROG05", name = "Cheap Shot", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Rogue",
        text = "Tap target enemy creature. It does not untap during its controller's next untap step.",
        art = "Interface\\Icons\\Ability_CheapShot",
        effect = { target = "enemy_creature", ops = { { op = "freeze", to = "target" } } }
    },
    ["ROG06"] = {
        id = "ROG06", name = "Sprint", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Rogue",
        text = "Target creature you control gains Quick and Unblockable until end of turn.",
        art = "Interface\\Icons\\Ability_Rogue_Sprint",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", kw = { "haste", "unblockable" } } } }
    },
    ["ROG07"] = {
        id = "ROG07", name = "Vanish", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Rogue",
        text = "Target creature you control gains Warded until end of turn and a regeneration shield.",
        art = "Interface\\Icons\\Ability_Vanish",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", kw = { "hexproof" } }, { op = "regen", to = "target" } } }
    },
    ["ROG08"] = {
        id = "ROG08", name = "Evasion", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Rogue",
        text = "Target creature you control gets +0/+2 and gains Strikes-First until end of turn.",
        art = "Interface\\Icons\\Spell_Shadow_ShadowWard",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", t = 2, kw = { "firstStrike" } } } }
    },
    ["ROG09"] = {
        id = "ROG09", name = "Slice and Dice", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Rogue",
        text = "Creatures you control get +1/+0 and gain Quick until end of turn.",
        art = "Interface\\Icons\\Ability_Rogue_SliceDice",
        effect = { ops = { { op = "buff", to = "friendly_creatures", p = 1, kw = { "haste" } } } }
    },
    ["ROG10"] = {
        id = "ROG10", name = "Garrote", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Rogue",
        text = "Target enemy creature permanently gets -0/-1 at the start of each of your turns for 3 turns.",
        art = "Interface\\Icons\\Ability_Rogue_Garrote",
        effect = { target = "enemy_creature", ops = { { op = "dot", to = "target", n = 2, turns = 3 } } }
    },
})
