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
    -- THE HINTERLANDS
    ["HIN01"] = {
        id = "HIN01", name = "Mangy Silvermane", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 11413,
        zone = "The Hinterlands", creatureType = "Beast", npcId = 2923,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["HIN02"] = {
        id = "HIN02", name = "Trained Razorbeak", cost = "{W}", cmc = 1, color = "W", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 1149,
        zone = "The Hinterlands", creatureType = "Beast", npcId = 2657,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIN03"] = {
        id = "HIN03", name = "Witherbark Hideskinner", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 6483,
        zone = "The Hinterlands", creatureType = "Humanoid", faction = "Troll", npcId = 2651,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIN04"] = {
        id = "HIN04", name = "Primitive Owlbeast", cost = "{1}{W}", cmc = 2, color = "W", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 12238,
        zone = "The Hinterlands", creatureType = "Humanoid", npcId = 2928,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIN05"] = {
        id = "HIN05", name = "Highvale Scout", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 2, haste = true, vigilance = true, isMob = true, isBoss = true, displayId = 6549,
        zone = "The Hinterlands", creatureType = "Humanoid", npcId = 2692,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick. Vigilant."
    },
    ["HIN06"] = {
        id = "HIN06", name = "Saltwater Snapjaw", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 4, isMob = true, isBoss = true, displayId = 5027,
        zone = "The Hinterlands", creatureType = "Beast", npcId = 2505,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIN07"] = {
        id = "HIN07", name = "Revantusk Watcher", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 3, toughness = 4, support = true, isMob = true, isBoss = true, displayId = 14760,
        zone = "The Hinterlands", creatureType = "Humanoid", faction = "Troll", npcId = 14730,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["HIN08"] = {
        id = "HIN08", name = "Vilebranch Shadow Hunter", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 6538,
        zone = "The Hinterlands", creatureType = "Humanoid", faction = "Troll", npcId = 2645,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIN09"] = {
        id = "HIN09", name = "Vilebranch Blood Drinker", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 6, toughness = 6, lifelink = true, isMob = true, isBoss = true, displayId = 6495,
        zone = "The Hinterlands", creatureType = "Humanoid", faction = "Troll", npcId = 2646,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["HIN10"] = {
        id = "HIN10", name = "Mith'rethis the Enchanter", cost = "{5}{U}{U}", cmc = 7, color = "U", type = "Creature",
        power = 10, toughness = 10, isMob = true, isBoss = true, displayId = 6512,
        zone = "The Hinterlands", creatureType = "Humanoid", npcId = 8217,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    -- Solo reward
    ["HIN11"] = {
        id = "HIN11", name = "Falstad Wildhammer", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 5, toughness = 5, flying = true, vigilance = true, isReward = true, displayId = 7005,
        zone = "The Hinterlands", creatureType = "Humanoid", npcEntry = 5635,
        anthem = { tag = "zone", value = "The Hinterlands", p = 1, t = 1, kw = { "flying" } },
        modelCam = { zoom = 0.70, camScale = 1.15, z = -0.18, rotation = 0.15 },
        text = "Airborne. Vigilant. Other Hinterlands denizens you control get +1/+1 and Airborne."
    },
})
