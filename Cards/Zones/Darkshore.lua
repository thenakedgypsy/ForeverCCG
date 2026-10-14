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
    -- DARKSHORE
    ["DAR01"] = {
        id = "DAR01", name = "Pygmy Tide Crawler", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 1000,
        zone = "Darkshore", creatureType = "Beast", npcId = 2231,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DAR02"] = {
        id = "DAR02", name = "Young Reef Crawler", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 999,
        zone = "Darkshore", creatureType = "Beast", npcId = 2234,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DAR03"] = {
        id = "DAR03", name = "Foreststrider Fledgling", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 1, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 1042,
        zone = "Darkshore", creatureType = "Beast", npcId = 2321,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["DAR04"] = {
        id = "DAR04", name = "Darkshore Thresher", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 992,
        zone = "Darkshore", creatureType = "Beast", npcId = 2185,
        modelCam = { zoom = 0.54, camScale = 1.22, z = -0.14, rotation = 0.15 },
        text = ""
    },
    ["DAR05"] = {
        id = "DAR05", name = "Rabid Thistle Bear", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 8840,
        zone = "Darkshore", creatureType = "Beast", npcId = 2164,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DAR06"] = {
        id = "DAR06", name = "Coastal Frenzy", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 245,
        zone = "Darkshore", creatureType = "Beast", npcId = 2174,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DAR07"] = {
        id = "DAR07", name = "Giant Foreststrider", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 3, toughness = 4, haste = true, isMob = true, isBoss = true, displayId = 1283,
        zone = "Darkshore", creatureType = "Beast", npcId = 2323,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["DAR08"] = {
        id = "DAR08", name = "Stormscale Myrmidon", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 4036,
        zone = "Darkshore", creatureType = "Humanoid", faction = "Naga", npcId = 2181,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DAR09"] = {
        id = "DAR09", name = "Raging Reef Crawler", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 4, toughness = 8, isMob = true, isBoss = true, displayId = 1001,
        zone = "Darkshore", creatureType = "Beast", npcId = 2236,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DAR10"] = {
        id = "DAR10", name = "Apothecary Falthis", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 4156,
        zone = "Darkshore", creatureType = "Humanoid", npcId = 3735,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    -- Solo reward
    ["DAR11"] = {
        id = "DAR11", name = "Thundris Windweaver", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 1, toughness = 3, isReward = true, displayId = 1770,
        zone = "Darkshore", creatureType = "Humanoid", npcEntry = 3649,
        anthem = { tag = "zone", value = "Darkshore", t = 1 },
        etb = { ops = { { op = "draw", n = 1 } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "When Thundris Windweaver enters the battlefield, draw a card. Other Darkshore creatures you control get +0/+1."
    },
})
