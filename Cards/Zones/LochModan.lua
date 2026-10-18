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
    -- LOCH MODAN
    ["LOC01"] = {
        id = "LOC01", name = "Tunnel Rat Vermin", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 10913,
        zone = "Loch Modan", creatureType = "Humanoid", faction = "Kobold", npcId = 1172,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["LOC02"] = {
        id = "LOC02", name = "Forest Lurker", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, reach = true, isMob = true, isBoss = true, displayId = 827,
        zone = "Loch Modan", creatureType = "Beast", npcId = 1195,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["LOC03"] = {
        id = "LOC03", name = "Loch Frenzy", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 1004,
        zone = "Loch Modan", creatureType = "Beast", npcId = 1193,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["LOC04"] = {
        id = "LOC04", name = "Grizzled Black Bear", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 762,
        zone = "Loch Modan", creatureType = "Beast", npcId = 1188,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["LOC05"] = {
        id = "LOC05", name = "Mangy Mountain Boar", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 3027,
        zone = "Loch Modan", creatureType = "Beast", npcId = 1191,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["LOC06"] = {
        id = "LOC06", name = "Mountain Buzzard", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 2, flying = true, isMob = true, isBoss = true, displayId = 410,
        zone = "Loch Modan", creatureType = "Beast", npcId = 1194,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["LOC07"] = {
        id = "LOC07", name = "Elder Mountain Boar", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 3, toughness = 4, trample = true, isMob = true, isBoss = true, displayId = 1208,
        zone = "Loch Modan", creatureType = "Beast", npcId = 1192,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["LOC08"] = {
        id = "LOC08", name = "Black Bear Patriarch", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 5, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 762,
        zone = "Loch Modan", creatureType = "Beast", npcId = 1189,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["LOC09"] = {
        id = "LOC09", name = "Young Threshadon", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 6, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 867,
        zone = "Loch Modan", creatureType = "Beast", npcId = 1224,
        modelCam = { zoom = 0.54, camScale = 1.22, z = -0.14, rotation = 0.15 },
        text = "Brutish."
    },
    ["LOC10"] = {
        id = "LOC10", name = "Large Loch Crocolisk", cost = "{5}{G}{G}", cmc = 7, color = "G", type = "Creature",
        power = 9, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 831,
        zone = "Loch Modan", creatureType = "Beast", npcId = 2476,
        modelCam = { zoom = 0.81, camScale = 1.03, z = -0.11, rotation = 0.15 },
        text = "Brutish."
    },
    -- Solo reward
    ["LOC11"] = {
        id = "LOC11", name = "Mountaineer Stormpike", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 2, firstStrike = true, isReward = true, displayId = 1894,
        zone = "Loch Modan", creatureType = "Humanoid", npcEntry = 1343,
        rally = { tag = "zone", value = "Loch Modan", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First. Gets +1/+1 for each other Loch Modan denizen you control."
    },
})
