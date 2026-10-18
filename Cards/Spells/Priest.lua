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
        text = "Prevent the next 4 damage to you, or target denizen you control gains Shielded.",
        art = "Interface\\Icons\\Spell_Holy_PowerWordShield",
        effect = { target = "friendly_any", ops = { { op = "shield", to = "target", n = 4, playerOnly = true }, { op = "shielded", to = "target" } } }
    },
    ["PRI02"] = {
        id = "PRI02", name = "Renew", cost = "{W}", cmc = 1, color = "W", type = "Sorcery", class = "Priest",
        text = "You or target denizen you control: HoT 2 for 3 turns.",
        art = "Interface\\Icons\\Spell_Holy_Renew",
        effect = { target = "friendly_any", ops = { { op = "hot", to = "target", n = 2, turns = 3 } } }
    },
    ["PRI03"] = {
        id = "PRI03", name = "Flash Heal", cost = "{1}{W}", cmc = 2, color = "W", type = "Sorcery", class = "Priest",
        text = "You regain 5 health, or target denizen you control permanently gets +0/+2.",
        art = "Interface\\Icons\\Spell_Holy_FlashHeal",
        effect = { target = "friendly_any", ops = { { op = "heal", to = "target", n = 5, t = 2 } } }
    },
    ["PRI04"] = {
        id = "PRI04", name = "Prayer of Healing", cost = "{3}{W}", cmc = 4, color = "W", type = "Sorcery", class = "Priest",
        text = "You regain 4 health and denizens you control permanently get +0/+1.",
        art = "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
        effect = { ops = { { op = "heal", to = "self_player", n = 4 }, { op = "heal", to = "friendly_creatures", n = 4, t = 1 } } }
    },
    ["PRI05"] = {
        id = "PRI05", name = "Smite", cost = "{1}{W}", cmc = 2, color = "W", type = "Sorcery", class = "Priest",
        text = "Deal 3 damage to target enemy denizen or the opponent.",
        art = "Interface\\Icons\\Spell_Holy_HolySmite",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 } } }
    },
    ["PRI06"] = {
        id = "PRI06", name = "Holy Fire", cost = "{2}{W}", cmc = 3, color = "W", type = "Sorcery", class = "Priest",
        text = "Deal 3 damage to target enemy denizen or the opponent, then DoT 1 for 2 turns.",
        art = "Interface\\Icons\\Spell_Holy_SearingLight",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 }, { op = "dot", to = "target", n = 1, turns = 2 } } }
    },
    ["PRI07"] = {
        id = "PRI07", name = "Shadow Word: Pain", cost = "{B}", cmc = 1, color = "B", type = "Sorcery", class = "Priest",
        text = "Target enemy denizen or the opponent: DoT 1 for 4 turns.",
        art = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
        effect = { target = "enemy_any", ops = { { op = "dot", to = "target", n = 1, turns = 4 } } }
    },
    ["PRI08"] = {
        id = "PRI08", name = "Mind Blast", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Priest",
        text = "Deal 3 damage to target enemy denizen or the opponent.",
        art = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 } } }
    },
    ["PRI09"] = {
        id = "PRI09", name = "Mind Control", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Sorcery", class = "Priest",
        text = "Gain control of target enemy denizen until end of turn. Recover it. It gains Quick.",
        art = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
        effect = { target = "enemy_creature", ops = { { op = "steal", to = "target", untilEnd = true } } }
    },
    ["PRI10"] = {
        id = "PRI10", name = "Psychic Scream", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Priest",
        text = "Exhaust each enemy denizen.",
        art = "Interface\\Icons\\Spell_Shadow_PsychicScream",
        effect = { ops = { { op = "tap", to = "enemy_creatures" } } }
    },
})
