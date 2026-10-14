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
    -- PRIEST
    ["PRI01"] = {
        id = "PRI01", name = "Power Word: Shield", cost = "{W}", cmc = 1, color = "W", type = "Sorcery", class = "Priest",
        text = "Prevent the next 4 damage that would be dealt to you, or give target creature you control +0/+4 until end of turn.",
        art = "Interface\\Icons\\Spell_Holy_PowerWordShield",
        effect = { target = "friendly_any", ops = { { op = "shield", to = "target", n = 4 } } }
    },
    ["PRI02"] = {
        id = "PRI02", name = "Renew", cost = "{W}", cmc = 1, color = "W", type = "Sorcery", class = "Priest",
        text = "You or target creature you control regains 2 health at the start of each of your turns for 3 turns.",
        art = "Interface\\Icons\\Spell_Holy_Renew",
        effect = { target = "friendly_any", ops = { { op = "hot", to = "target", n = 2, turns = 3 } } }
    },
    ["PRI03"] = {
        id = "PRI03", name = "Flash Heal", cost = "{1}{W}", cmc = 2, color = "W", type = "Sorcery", class = "Priest",
        text = "You or target creature you control regains 5 health.",
        art = "Interface\\Icons\\Spell_Holy_FlashHeal",
        effect = { target = "friendly_any", ops = { { op = "heal", to = "target", n = 5 } } }
    },
    ["PRI04"] = {
        id = "PRI04", name = "Prayer of Healing", cost = "{3}{W}", cmc = 4, color = "W", type = "Sorcery", class = "Priest",
        text = "You and each creature you control regain 4 health.",
        art = "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
        effect = { ops = { { op = "heal", to = "self_player", n = 4 }, { op = "heal", to = "friendly_creatures", n = 4 } } }
    },
    ["PRI05"] = {
        id = "PRI05", name = "Smite", cost = "{1}{W}", cmc = 2, color = "W", type = "Sorcery", class = "Priest",
        text = "Deal 3 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Spell_Holy_HolySmite",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 } } }
    },
    ["PRI06"] = {
        id = "PRI06", name = "Holy Fire", cost = "{2}{W}", cmc = 3, color = "W", type = "Sorcery", class = "Priest",
        text = "Deal 3 damage to target enemy creature or the opponent. It takes 1 more damage at the start of each of your turns for 2 turns.",
        art = "Interface\\Icons\\Spell_Holy_SearingLight",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 }, { op = "dot", to = "target", n = 1, turns = 2 } } }
    },
    ["PRI07"] = {
        id = "PRI07", name = "Shadow Word: Pain", cost = "{B}", cmc = 1, color = "B", type = "Sorcery", class = "Priest",
        text = "Target enemy creature or the opponent takes 2 damage at the start of each of your turns for 3 turns.",
        art = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
        effect = { target = "enemy_any", ops = { { op = "dot", to = "target", n = 2, turns = 3 } } }
    },
    ["PRI08"] = {
        id = "PRI08", name = "Mind Blast", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Priest",
        text = "Deal 3 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 } } }
    },
    ["PRI09"] = {
        id = "PRI09", name = "Mind Control", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Sorcery", class = "Priest",
        text = "Gain control of target enemy creature until end of turn. Untap it. It gains Quick.",
        art = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
        effect = { target = "enemy_creature", ops = { { op = "steal", to = "target", untilEnd = true } } }
    },
    ["PRI10"] = {
        id = "PRI10", name = "Psychic Scream", cost = "{2}{B}", cmc = 3, color = "B", type = "Sorcery", class = "Priest",
        text = "Tap each enemy creature. They do not untap during their controller's next untap step.",
        art = "Interface\\Icons\\Spell_Shadow_PsychicScream",
        effect = { ops = { { op = "freeze", to = "enemy_creatures" } } }
    },
})
