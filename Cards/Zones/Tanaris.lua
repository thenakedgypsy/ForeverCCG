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
    -- TANARIS
    ["TAN01"] = {
        id = "TAN01", name = "Scorpid Hunter", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 1, reach = true, isMob = true, isBoss = true, displayId = 2414,
        zone = "Tanaris", creatureType = "Beast", npcId = 5422,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["TAN02"] = {
        id = "TAN02", name = "Glasshide Basilisk", cost = "{W}", cmc = 1, color = "W", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 141,
        zone = "Tanaris", creatureType = "Beast", npcId = 5419,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TAN03"] = {
        id = "TAN03", name = "Steeljaw Snapper", cost = "{1}{W}", cmc = 2, color = "W", type = "Creature",
        power = 1, toughness = 3, isMob = true, isBoss = true, displayId = 7114,
        zone = "Tanaris", creatureType = "Beast", npcId = 14123,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TAN04"] = {
        id = "TAN04", name = "Scorpid Tail Lasher", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 10987,
        zone = "Tanaris", creatureType = "Beast", npcId = 5423,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["TAN05"] = {
        id = "TAN05", name = "Blisterpaw Hyena", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 1536,
        zone = "Tanaris", creatureType = "Beast", npcId = 5426,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["TAN06"] = {
        id = "TAN06", name = "Glasshide Gazer", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 7344,
        zone = "Tanaris", creatureType = "Beast", npcId = 5420,
        modelCam = { zoom = 0.78, camScale = 1.05, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["TAN07"] = {
        id = "TAN07", name = "Rabid Blisterpaw", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 4, toughness = 3, haste = true, isMob = true, isBoss = true, displayId = 2609,
        zone = "Tanaris", creatureType = "Beast", npcId = 5427,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["TAN08"] = {
        id = "TAN08", name = "Dunemaul Brute", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 6, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 11545,
        zone = "Tanaris", creatureType = "Humanoid", faction = "Ogre", npcId = 5474,
        modelCam = { zoom = 0.67, camScale = 1.13, z = -0.13, rotation = 0.15 },
        text = "Brutish."
    },
    ["TAN09"] = {
        id = "TAN09", name = "Surf Glider", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 4, toughness = 8, support = true, isMob = true, isBoss = true, displayId = 7114,
        zone = "Tanaris", creatureType = "Beast", npcId = 5431,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["TAN10"] = {
        id = "TAN10", name = "Cyclok the Mad", cost = "{5}{U}{U}", cmc = 7, color = "U", type = "Creature",
        power = 9, toughness = 9, hexproof = true, isMob = true, isBoss = true, displayId = 11532,
        zone = "Tanaris", creatureType = "Humanoid", faction = "Ogre", npcId = 8202,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Warded."
    },
    -- Solo reward
    ["TAN11"] = {
        id = "TAN11", name = "Marin Noggenfogger", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 2, toughness = 3, isReward = true, displayId = 7185,
        zone = "Tanaris", creatureType = "Humanoid", npcEntry = 7564,
        anthem = { tag = "zone", value = "Tanaris", p = 1 },
        etb = { ops = { { op = "draw", n = 1 } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Arrival: Draw 1. Other Tanaris denizens you control get +1/+0."
    },
})
