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
    -- SILITHUS
    ["SLI01"] = {
        id = "SLI01", name = "Tortured Druid", cost = "{W}", cmc = 1, color = "W", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 12269,
        zone = "Silithus", creatureType = "Undead", npcId = 12178,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SLI02"] = {
        id = "SLI02", name = "Dredge Striker", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 15386,
        zone = "Silithus", creatureType = "Beast", npcId = 11740,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SLI03"] = {
        id = "SLI03", name = "Stonelash Pincer", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 15384,
        zone = "Silithus", creatureType = "Beast", npcId = 11736,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["SLI04"] = {
        id = "SLI04", name = "Sand Skitterer", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 8014,
        zone = "Silithus", creatureType = "Beast", npcId = 11738,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["SLI05"] = {
        id = "SLI05", name = "Dust Stormer", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 8715,
        zone = "Silithus", creatureType = "Elemental", npcId = 11744,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SLI06"] = {
        id = "SLI06", name = "Stonelash Flayer", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 2, deathtouch = true, isMob = true, isBoss = true, displayId = 15385,
        zone = "Silithus", creatureType = "Beast", npcId = 11737,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["SLI07"] = {
        id = "SLI07", name = "Desert Rumbler", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 3, toughness = 4, trample = true, isMob = true, isBoss = true, displayId = 8550,
        zone = "Silithus", creatureType = "Elemental", npcId = 11746,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["SLI08"] = {
        id = "SLI08", name = "Twilight Avenger", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 5, toughness = 5, firstStrike = true, isMob = true, isBoss = true, displayId = 11811,
        zone = "Silithus", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 11880,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["SLI09"] = {
        id = "SLI09", name = "Twilight Geolord", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 6, toughness = 6, lifelink = true, isMob = true, isBoss = true, displayId = 11819,
        zone = "Silithus", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 11881,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["SLI10"] = {
        id = "SLI10", name = "Mistress Natalia Mar'alith", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 10, toughness = 10, isMob = true, isBoss = true, displayId = 15330,
        zone = "Silithus", creatureType = "Humanoid", npcId = 15215,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    -- Solo reward
    ["SLI11"] = {
        id = "SLI11", name = "Highlord Demitrian", cost = "{5}{W}{W}", cmc = 7, color = "W", type = "Creature",
        power = 6, toughness = 6, vigilance = true, firstStrike = true, isReward = true, displayId = 14395,
        zone = "Silithus", creatureType = "Humanoid", npcEntry = 14347,
        anthem = { tag = "zone", value = "Silithus", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant. Strikes-First. Other Silithus denizens you control get +1/+1."
    },
})
