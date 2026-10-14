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
    -- DRUID
    ["DRU01"] = {
        id = "DRU01", name = "Wrath", cost = "{1}{G}", cmc = 2, color = "G", type = "Sorcery", class = "Druid",
        text = "Deal 3 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Spell_Nature_AbolishMagic",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 } } }
    },
    ["DRU02"] = {
        id = "DRU02", name = "Moonfire", cost = "{U}", cmc = 1, color = "U", type = "Sorcery", class = "Druid",
        text = "Deal 1 damage to target enemy creature or the opponent. It takes 1 more damage at the start of each of your turns for 2 turns.",
        art = "Interface\\Icons\\Spell_Nature_StarFall",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 1 }, { op = "dot", to = "target", n = 1, turns = 2 } } }
    },
    ["DRU03"] = {
        id = "DRU03", name = "Healing Touch", cost = "{2}{G}", cmc = 3, color = "G", type = "Sorcery", class = "Druid",
        text = "You or target creature you control regains 8 health.",
        art = "Interface\\Icons\\Spell_Nature_HealingTouch",
        effect = { target = "friendly_any", ops = { { op = "heal", to = "target", n = 8 } } }
    },
    ["DRU04"] = {
        id = "DRU04", name = "Rejuvenation", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Druid",
        text = "You or target creature you control regains 2 health at the start of each of your turns for 3 turns.",
        art = "Interface\\Icons\\Spell_Nature_Rejuvenation",
        effect = { target = "friendly_any", ops = { { op = "hot", to = "target", n = 2, turns = 3 } } }
    },
    ["DRU05"] = {
        id = "DRU05", name = "Regrowth", cost = "{1}{G}", cmc = 2, color = "G", type = "Sorcery", class = "Druid",
        text = "You or target creature you control regains 3 health, then regains 1 health at the start of each of your turns for 3 turns.",
        art = "Interface\\Icons\\Spell_Nature_ResistNature",
        effect = { target = "friendly_any", ops = { { op = "heal", to = "target", n = 3 }, { op = "hot", to = "target", n = 1, turns = 3 } } }
    },
    ["DRU06"] = {
        id = "DRU06", name = "Mark of the Wild", cost = "{1}{G}", cmc = 2, color = "G", type = "Sorcery", class = "Druid",
        text = "Target creature you control permanently gets +1/+1.",
        art = "Interface\\Icons\\Spell_Nature_Regeneration",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", p = 1, t = 1, perm = true } } }
    },
    ["DRU07"] = {
        id = "DRU07", name = "Entangling Roots", cost = "{1}{G}", cmc = 2, color = "G", type = "Sorcery", class = "Druid",
        text = "Tap target enemy creature. It does not untap during its controller's next untap step.",
        art = "Interface\\Icons\\Spell_Nature_StrangleVines",
        effect = { target = "enemy_creature", ops = { { op = "freeze", to = "target" } } }
    },
    ["DRU08"] = {
        id = "DRU08", name = "Thorns", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Druid",
        text = "Target creature you control gets +1/+1 and gains Deathtouch until end of turn.",
        art = "Interface\\Icons\\Spell_Nature_Thorns",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", p = 1, t = 1, kw = { "deathtouch" } } } }
    },
    ["DRU09"] = {
        id = "DRU09", name = "Innervate", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Druid",
        text = "Add {G}{G}{G} to your mana pool.",
        art = "Interface\\Icons\\Spell_Nature_Lightning",
        effect = { ops = { { op = "mana", n = 3, color = "G" } } }
    },
    ["DRU10"] = {
        id = "DRU10", name = "Starfire", cost = "{3}{U}", cmc = 4, color = "U", type = "Sorcery", class = "Druid",
        text = "Deal 5 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Spell_Nature_StarFall",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 5 } } }
    },
})
