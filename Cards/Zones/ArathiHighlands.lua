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
    -- ARATHI HIGHLANDS
    ["ARA01"] = {
        id = "ARA01", name = "Drywhisker Kobold", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 2153,
        zone = "Arathi Highlands", creatureType = "Humanoid", faction = "Kobold", npcId = 2572,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ARA02"] = {
        id = "ARA02", name = "Elder Mesa Buzzard", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 1, flying = true, isMob = true, isBoss = true, displayId = 388,
        zone = "Arathi Highlands", creatureType = "Beast", npcId = 2580,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["ARA03"] = {
        id = "ARA03", name = "Cresting Exile", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 5561,
        zone = "Arathi Highlands", creatureType = "Elemental", npcId = 2761,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["ARA04"] = {
        id = "ARA04", name = "Thundering Exile", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 5490,
        zone = "Arathi Highlands", creatureType = "Elemental", npcId = 2762,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ARA05"] = {
        id = "ARA05", name = "Daggerspine Raider", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 11254,
        zone = "Arathi Highlands", creatureType = "Humanoid", npcId = 2595,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ARA06"] = {
        id = "ARA06", name = "Syndicate Prowler", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 4, haste = true, isMob = true, isBoss = true, displayId = 4016,
        zone = "Arathi Highlands", creatureType = "Humanoid", faction = "Syndicate", npcId = 2588,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["ARA07"] = {
        id = "ARA07", name = "Stromgarde Troll Hunter", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 4, toughness = 4, support = true, isMob = true, isBoss = true, displayId = 4139,
        zone = "Arathi Highlands", creatureType = "Humanoid", npcId = 2583,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["ARA08"] = {
        id = "ARA08", name = "Boulderfist Shaman", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 5, toughness = 7, support = true, isMob = true, isBoss = true, displayId = 416,
        zone = "Arathi Highlands", creatureType = "Humanoid", faction = "Ogre", npcId = 2570,
        modelCam = { zoom = 0.77, camScale = 1.06, z = -0.11, rotation = 0.15 },
        text = "Support."
    },
    ["ARA09"] = {
        id = "ARA09", name = "Darbel Montrose", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 6, toughness = 7, isMob = true, isNamed = true, isBoss = true, displayId = 4027,
        zone = "Arathi Highlands", creatureType = "Humanoid", faction = "Syndicate", npcId = 2598,
        anthem = { tag = "faction", value = "Syndicate", p = 1, t = 1 },
        modelCam = { zoom = 0.68, camScale = 1.12, z = -0.12, rotation = 0.15 },
        text = "Other Syndicate you control get +1/+1."
    },
    ["ARA10"] = {
        id = "ARA10", name = "Foulbelly", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 10, toughness = 10, isMob = true, isNamed = true, isBoss = true, displayId = 11551,
        zone = "Arathi Highlands", creatureType = "Humanoid", faction = "Ogre", npcId = 2601,
        modelCam = { zoom = 0.68, camScale = 1.12, z = -0.12, rotation = 0.15 },
        text = ""
    },
    -- Solo reward
    ["ARA11"] = {
        id = "ARA11", name = "Captain Nials", cost = "{3}{W}", cmc = 4, color = "W", type = "Creature",
        power = 3, toughness = 3, firstStrike = true, isReward = true, displayId = 4147,
        zone = "Arathi Highlands", creatureType = "Humanoid", npcEntry = 2700,
        rally = { tag = "zone", value = "Arathi Highlands", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First. Gets +1/+1 for each other Arathi Highlands denizen you control."
    },
})
