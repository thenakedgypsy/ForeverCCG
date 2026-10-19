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
    -- WESTFALL
    ["WES01"] = {
        id = "WES01", name = "Coyote", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 643,
        zone = "Westfall", creatureType = "Beast", npcId = 834,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["WES02"] = {
        id = "WES02", name = "Defias Smuggler", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 1, firstStrike = true, isMob = true, isBoss = true, displayId = 4418,
        zone = "Westfall", creatureType = "Humanoid", faction = "Defias", npcId = 95,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["WES03"] = {
        id = "WES03", name = "Harvest Golem", cost = "{1}{W}", cmc = 2, color = "W", type = "Creature",
        power = 1, toughness = 5, defender = true, isMob = true, isBoss = true, displayId = 367,
        zone = "Westfall", creatureType = "Mechanical", npcId = 36,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Blocker."
    },
    ["WES04"] = {
        id = "WES04", name = "Fleshripper", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, flying = true, isMob = true, isBoss = true, displayId = 2305,
        zone = "Westfall", creatureType = "Beast", npcId = 1109,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["WES05"] = {
        id = "WES05", name = "Goretusk", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 3027,
        zone = "Westfall", creatureType = "Beast", npcId = 157,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["WES06"] = {
        id = "WES06", name = "Harvest Watcher", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 1, toughness = 7, defender = true, isMob = true, isBoss = true, displayId = 378,
        zone = "Westfall", creatureType = "Mechanical", npcId = 114,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Blocker."
    },
    ["WES07"] = {
        id = "WES07", name = "Defias Digger", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 2441,
        zone = "Westfall", creatureType = "Humanoid", faction = "Defias", npcId = 824,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WES08"] = {
        id = "WES08", name = "Riverpaw Bandit", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 5, toughness = 5, firstStrike = true, isMob = true, isBoss = true, displayId = 383,
        zone = "Westfall", creatureType = "Humanoid", faction = "Gnoll", npcId = 452,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["WES09"] = {
        id = "WES09", name = "Shore Crawler", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 4, toughness = 8, support = true, isMob = true, isBoss = true, displayId = 9570,
        zone = "Westfall", creatureType = "Beast", npcId = 1216,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["WES10"] = {
        id = "WES10", name = "Vultros", cost = "{5}{G}{G}", cmc = 7, color = "G", type = "Creature",
        power = 7, toughness = 7, flying = true, isMob = true, isBoss = true, displayId = 507,
        zone = "Westfall", creatureType = "Beast", npcId = 462,
        anthem = { tag = "zone", value = "Westfall", p = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Airborne. Other Westfall denizens you control get +1/+0."
    },
    -- Solo reward
    ["WES11"] = {
        id = "WES11", name = "Gryan Stoutmantle", cost = "{3}{W}", cmc = 4, color = "W", type = "Creature",
        power = 3, toughness = 4, vigilance = true, isReward = true, displayId = 1690,
        zone = "Westfall", creatureType = "Humanoid", npcEntry = 234,
        anthem = { tag = "zone", value = "Westfall", p = 1, t = 1, kw = { "support" } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant. Other Westfall denizens you control get +1/+1 and Support."
    },
})
