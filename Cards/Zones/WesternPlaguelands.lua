--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- ZONE CREATURES (10 per zone) - UNLOCKED BY KILLING THEM (isBoss = true reuses BossTracker as-is)
-- Names / displayIds / creatureId come from the classicdb creature_template table.
-- =========================================================================
TTS:AddCards({
    -- WESTERN PLAGUELANDS
    ["WPL01"] = {
        id = "WPL01", name = "Venom Mist Lurker", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 1, reach = true, isMob = true, isBoss = true, displayId = 1087,
        zone = "Western Plaguelands", creatureType = "Beast", npcId = 1822,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["WPL02"] = {
        id = "WPL02", name = "Skeletal Sorcerer", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 11403,
        zone = "Western Plaguelands", creatureType = "Undead", npcId = 1784,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WPL03"] = {
        id = "WPL03", name = "Diseased Black Bear", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 1082,
        zone = "Western Plaguelands", creatureType = "Beast", npcId = 1815,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["WPL04"] = {
        id = "WPL04", name = "Carrion Lurker", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 1091,
        zone = "Western Plaguelands", creatureType = "Beast", npcId = 1821,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["WPL05"] = {
        id = "WPL05", name = "Diseased Wolf", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 4124,
        zone = "Western Plaguelands", creatureType = "Beast", npcId = 1817,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["WPL06"] = {
        id = "WPL06", name = "Rotting Cadaver", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 4631,
        zone = "Western Plaguelands", creatureType = "Undead", npcId = 4474,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WPL07"] = {
        id = "WPL07", name = "Diseased Grizzly", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 4, trample = true, isMob = true, isBoss = true, displayId = 1083,
        zone = "Western Plaguelands", creatureType = "Beast", npcId = 1816,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = "Brutish."
    },
    ["WPL08"] = {
        id = "WPL08", name = "Scarlet Worker", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 5, toughness = 6, support = true, isMob = true, isBoss = true, displayId = 10303,
        zone = "Western Plaguelands", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 1883,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["WPL09"] = {
        id = "WPL09", name = "Haunting Vision", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 5, toughness = 7, lifelink = true, isMob = true, isBoss = true, displayId = 146,
        zone = "Western Plaguelands", creatureType = "Undead", npcId = 4472,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["WPL10"] = {
        id = "WPL10", name = "Scarlet High Clerist", cost = "{5}{W}{W}", cmc = 7, color = "W", type = "Creature",
        power = 9, toughness = 10, support = true, isMob = true, isBoss = true, displayId = 10342,
        zone = "Western Plaguelands", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 1839,
        modelCam = { zoom = 0.63, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Support."
    },
    -- Solo reward
    ["WPL11"] = {
        id = "WPL11", name = "Tirion Fordring", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 5, toughness = 6, vigilance = true, lifelink = true, isReward = true, displayId = 9477,
        zone = "Western Plaguelands", creatureType = "Humanoid", npcEntry = 1855,
        anthem = { tag = "type", value = "Humanoid", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant. Drain. Other Humanoids you control get +1/+1."
    },
})
