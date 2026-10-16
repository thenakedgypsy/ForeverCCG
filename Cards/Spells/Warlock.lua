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
    -- WARLOCK
    ["WLK01"] = {
        id = "WLK01", name = "Shadow Bolt", cost = "{2}{B}", cmc = 3, color = "B", type = "Sorcery", class = "Warlock",
        text = "Deal 4 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 4 } } }
    },
    ["WLK02"] = {
        id = "WLK02", name = "Corruption", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Warlock",
        text = "Choose target enemy creature or the opponent. At the start of each of your turns for 3 turns, the opponent takes 2 damage, or the creature permanently gets -0/-1.",
        art = "Interface\\Icons\\Spell_Shadow_AbominationExplosion",
        effect = { target = "enemy_any", ops = { { op = "dot", to = "target", n = 2, turns = 3 } } }
    },
    ["WLK03"] = {
        id = "WLK03", name = "Curse of Agony", cost = "{B}", cmc = 1, color = "B", type = "Sorcery", class = "Warlock",
        text = "Choose target enemy creature or the opponent. At the start of each of your turns for 4 turns, the opponent takes 1 damage, or the creature permanently gets -0/-1.",
        art = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras",
        effect = { target = "enemy_any", ops = { { op = "dot", to = "target", n = 1, turns = 4 } } }
    },
    ["WLK04"] = {
        id = "WLK04", name = "Drain Life", cost = "{2}{B}", cmc = 3, color = "B", type = "Sorcery", class = "Warlock",
        text = "Deal 3 damage to target enemy creature or the opponent. You regain 3 health.",
        art = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 }, { op = "heal", to = "self_player", n = 3 } } }
    },
    ["WLK05"] = {
        id = "WLK05", name = "Howl of Terror", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Sorcery", class = "Warlock",
        text = "Tap each enemy creature. They do not untap during their controller's next untap step.",
        art = "Interface\\Icons\\Spell_Shadow_DeathScream",
        effect = { ops = { { op = "freeze", to = "enemy_creatures" } } }
    },
    ["WLK06"] = {
        id = "WLK06", name = "Death Coil", cost = "{2}{B}", cmc = 3, color = "B", type = "Sorcery", class = "Warlock",
        text = "Destroy target non-Shadow enemy creature.",
        art = "Interface\\Icons\\Spell_Shadow_DeathCoil",
        effect = { target = "enemy_creature", ops = { { op = "destroy", to = "target", nonColor = "B" } } }
    },
    ["WLK07"] = {
        id = "WLK07", name = "Immolate", cost = "{1}{R}", cmc = 2, color = "R", type = "Sorcery", class = "Warlock",
        text = "Deal 2 damage to target enemy creature or the opponent. Then, at the start of each of your turns for 2 turns, the opponent takes 1 more damage, or the creature permanently gets -0/-1.",
        art = "Interface\\Icons\\Spell_Fire_Immolation",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 2 }, { op = "dot", to = "target", n = 1, turns = 2 } } }
    },
    ["WLK08"] = {
        id = "WLK08", name = "Soul Fire", cost = "{3}{R}", cmc = 4, color = "R", type = "Sorcery", class = "Warlock",
        text = "Deal 5 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Spell_Fire_SoulBurn",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 5 } } }
    },
    ["WLK09"] = {
        id = "WLK09", name = "Life Tap", cost = "{B}", cmc = 1, color = "B", type = "Sorcery", class = "Warlock",
        text = "You take 3 damage. Add {B}{B}{B} to your mana pool.",
        art = "Interface\\Icons\\Spell_Shadow_BurningSpirit",
        effect = { ops = { { op = "damage", to = "self_player", n = 3 }, { op = "mana", n = 3, color = "B" } } }
    },
    ["WLK10"] = {
        id = "WLK10", name = "Enslave Demon", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Sorcery", class = "Warlock",
        text = "Gain control of target enemy creature with power 3 or less.",
        art = "Interface\\Icons\\Spell_Shadow_EnslaveDemon",
        effect = { target = "enemy_creature", ops = { { op = "steal", to = "target", maxPower = 3, permanent = true } } }
    },
})
