--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- ZONE CREATURES - UNLOCKED BY KILLING THEM (isBoss = true reuses BossTracker as-is)
-- WoW Forever zone: names / displayIds / npcId come from forever.warcraftdb.com (zone 2548).
-- Only hostile or neutral wildlife and Twilight's Hammer mobs; vendors and quest NPCs left out.
-- =========================================================================
TTS:AddCards({
    -- RIVERGLADES
    ["RIV01"] = {
        id = "RIV01", name = "Roosting Duskbat", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 1, flying = true, lifelink = true, isMob = true, isBoss = true, displayId = 10033,
        zone = "Riverglades", creatureType = "Beast", npcId = 262037,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne. Drain."
    },
    ["RIV02"] = {
        id = "RIV02", name = "Young Paletusk", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 6807,
        zone = "Riverglades", creatureType = "Beast", npcId = 258331,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["RIV03"] = {
        id = "RIV03", name = "High Plains Buzzard", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, flying = true, isMob = true, isBoss = true, displayId = 2305,
        zone = "Riverglades", creatureType = "Beast", npcId = 259269,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["RIV04"] = {
        id = "RIV04", name = "Roving Tallstrider", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 4, reach = true, isMob = true, isBoss = true, displayId = 1284,
        zone = "Riverglades", creatureType = "Beast", npcId = 263348,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["RIV05"] = {
        id = "RIV05", name = "Twilight Peon", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 2, support = true, isMob = true, isBoss = true, displayId = 143058,
        zone = "Riverglades", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 277611,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["RIV06"] = {
        id = "RIV06", name = "Mature Paletusk", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 3027,
        zone = "Riverglades", creatureType = "Beast", npcId = 255851,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["RIV07"] = {
        id = "RIV07", name = "Freshwater Crocolisk", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 1251,
        zone = "Riverglades", creatureType = "Beast", npcId = 259046,
        modelCam = { zoom = 0.80, camScale = 1.03, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["RIV08"] = {
        id = "RIV08", name = "Twilight Fanatic", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 4, toughness = 3, haste = true, isMob = true, isBoss = true, displayId = 147688,
        zone = "Riverglades", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 256795,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["RIV09"] = {
        id = "RIV09", name = "Twilight Corrupter", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 4, toughness = 5, lifelink = true, isMob = true, isBoss = true, displayId = 139817,
        zone = "Riverglades", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 256797,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["RIV10"] = {
        id = "RIV10", name = "Twilight Enforcer", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 5, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 142910,
        zone = "Riverglades", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 256800,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["RIV12"] = {
        id = "RIV12", name = "Twilight Champion", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 6, toughness = 5, firstStrike = true, isMob = true, isBoss = true, displayId = 139889,
        zone = "Riverglades", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 256799,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["RIV13"] = {
        id = "RIV13", name = "Overlord Kilgar", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 8, toughness = 8, vigilance = true, isMob = true, isNamed = true, isBoss = true, displayId = 139857,
        zone = "Riverglades", creatureType = "Humanoid", npcId = 256881,
        anthem = { tag = "zone", value = "Riverglades", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant. Other Riverglades denizens you control get +1/+1."
    },
    -- Solo reward (RIV11: the Zone Gauntlet grants <ZONE>11)
    ["RIV11"] = {
        id = "RIV11", name = "Demar Brant", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 4, toughness = 4, haste = true, vigilance = true, isReward = true, displayId = 140257,
        zone = "Riverglades", creatureType = "Humanoid", npcEntry = 257558,
        anthem = { tag = "zone", value = "Riverglades", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick. Vigilant. Other Riverglades denizens you control get +1/+0."
    },
})
