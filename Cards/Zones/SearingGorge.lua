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
    -- SEARING GORGE
    ["SEA01"] = {
        id = "SEA01", name = "Dark Iron Slaver", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 7789,
        zone = "Searing Gorge", creatureType = "Humanoid", faction = "Dark Iron", npcId = 5844,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SEA02"] = {
        id = "SEA02", name = "Enslaved Archaeologist", cost = "{W}", cmc = 1, color = "W", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 7751,
        zone = "Searing Gorge", creatureType = "Humanoid", npcId = 8402,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SEA03"] = {
        id = "SEA03", name = "Searing Lava Spider", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 4457,
        zone = "Searing Gorge", creatureType = "Beast", npcId = 5857,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["SEA04"] = {
        id = "SEA04", name = "Blazing Elemental", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 1070,
        zone = "Searing Gorge", creatureType = "Elemental", npcId = 5850,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SEA05"] = {
        id = "SEA05", name = "Dark Iron Taskmaster", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 3, isMob = true, isBoss = true, displayId = 7798,
        zone = "Searing Gorge", creatureType = "Humanoid", faction = "Dark Iron", npcId = 5846,
        anthem = { tag = "faction", value = "Dark Iron", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Dark Iron you control get +1/+0."
    },
    ["SEA06"] = {
        id = "SEA06", name = "Magma Elemental", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 1, toughness = 7, defender = true, isMob = true, isBoss = true, displayId = 2075,
        zone = "Searing Gorge", creatureType = "Elemental", npcId = 5855,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Blocker."
    },
    ["SEA07"] = {
        id = "SEA07", name = "Greater Lava Spider", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 3, deathtouch = true, isMob = true, isBoss = true, displayId = 7510,
        zone = "Searing Gorge", creatureType = "Beast", npcId = 5858,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["SEA08"] = {
        id = "SEA08", name = "Heavy War Golem", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 1, toughness = 11, bulwark = 2, defender = true, isMob = true, isBoss = true, displayId = 10801,
        zone = "Searing Gorge", creatureType = "Mechanical", npcId = 5854,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = "Blocker, Bulwark 2."
    },
    ["SEA09"] = {
        id = "SEA09", name = "Incendosaur", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 6, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 8509,
        zone = "Searing Gorge", creatureType = "Beast", npcId = 9318,
        modelCam = { zoom = 0.75, camScale = 1.07, z = -0.11, rotation = 0.15 },
        text = "Brutish."
    },
    ["SEA10"] = {
        id = "SEA10", name = "Smoldar", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 8, toughness = 10, trample = true, isMob = true, isBoss = true, displayId = 5781,
        zone = "Searing Gorge", creatureType = "Elemental", npcId = 8278,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    -- Solo reward
    ["SEA11"] = {
        id = "SEA11", name = "Kalaran Windblade", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 4, toughness = 4, flying = true, isReward = true, displayId = 7820,
        zone = "Searing Gorge", creatureType = "Dragonkin", npcEntry = 8479,
        anthem = { tag = "zone", value = "Searing Gorge", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne. Other Searing Gorge denizens you control get +1/+1."
    },
})
