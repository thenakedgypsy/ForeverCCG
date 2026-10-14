--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- DUNGEON CREATURES & BOSSES - UNLOCKED BY KILLING THEM (same isMob/isBoss tracking as zone creatures)
-- Names / displayIds / npcId come from the classicdb creature_template table; all are dungeon elites.
-- Final dungeon bosses keep their dedicated BOSSxx cards below.
-- =========================================================================
TTS:AddCards({
    -- SUNKEN TEMPLE
    ["SUN01"] = {
        id = "SUN01", name = "Atal'ai Warrior", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 7709,
        zone = "Sunken Temple", creatureType = "Humanoid", faction = "Troll", npcId = 5256,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SUN02"] = {
        id = "SUN02", name = "Murk Worm", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 4, deathtouch = true, isMob = true, isBoss = true, displayId = 7549,
        zone = "Sunken Temple", creatureType = "Beast", npcId = 5226,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["SUN03"] = {
        id = "SUN03", name = "Atal'ai Witch Doctor", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 6670,
        zone = "Sunken Temple", creatureType = "Humanoid", faction = "Troll", npcId = 5259,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["SUN04"] = {
        id = "SUN04", name = "Hakkari Frostwing", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, flying = true, isMob = true, isBoss = true, displayId = 7569,
        zone = "Sunken Temple", creatureType = "Beast", npcId = 5291,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["SUN05"] = {
        id = "SUN05", name = "Nightmare Scalebane", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 5, toughness = 5, vigilance = true, isMob = true, isBoss = true, displayId = 7903,
        zone = "Sunken Temple", creatureType = "Dragonkin", npcId = 5277,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Vigilance."
    },
    ["SUN06"] = {
        id = "SUN06", name = "Gasher", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 5, haste = true, isMob = true, isBoss = true, displayId = 6698,
        zone = "Sunken Temple", creatureType = "Undead", faction = "Troll", npcId = 5713,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["SUN07"] = {
        id = "SUN07", name = "Hukku", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 5, toughness = 6, deathtouch = true, isMob = true, isBoss = true, displayId = 6702,
        zone = "Sunken Temple", creatureType = "Undead", faction = "Troll", npcId = 5715,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["SUN08"] = {
        id = "SUN08", name = "Spawn of Hakkar", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 6, flying = true, isMob = true, isBoss = true, displayId = 4065,
        zone = "Sunken Temple", creatureType = "Beast", npcId = 5708,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Flying."
    },
    ["SUN09"] = {
        id = "SUN09", name = "Ogom the Wretched", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 7, deathtouch = true, isMob = true, isBoss = true, displayId = 6709,
        zone = "Sunken Temple", creatureType = "Undead", faction = "Troll", npcId = 5711,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["SUN10"] = {
        id = "SUN10", name = "Jammal'an the Prophet", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 5, toughness = 6, lifelink = true, isMob = true, isBoss = true, displayId = 6708,
        zone = "Sunken Temple", creatureType = "Humanoid", faction = "Troll", npcId = 5710,
        rally = { tag = "faction", value = "Troll", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink. Gets +1/+1 for each other Troll you control."
    },
    ["SUN11"] = {
        id = "SUN11", name = "Morphaz", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 7, toughness = 7, flying = true, isMob = true, isBoss = true, displayId = 7975,
        zone = "Sunken Temple", creatureType = "Dragonkin", npcId = 5719,
        anthem = { tag = "type", value = "Dragonkin", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Flying. Other Dragonkin you control get +1/+1."
    },
    ["SUN12"] = {
        id = "SUN12", name = "Hazzas", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 7, toughness = 9, flying = true, vigilance = true, isMob = true, isBoss = true, displayId = 9584,
        zone = "Sunken Temple", creatureType = "Dragonkin", npcId = 5722,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Flying, Vigilance."
    },
    -- Solo reward
    ["SUN13"] = {
        id = "SUN13", name = "Avatar of Hakkar", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 7, toughness = 7, flying = true, lifelink = true, isReward = true, displayId = 8053,
        zone = "Sunken Temple", creatureType = "Beast", npcEntry = 8443,
        anthem = { tag = "faction", value = "Troll", p = 1, t = 1 },
        modelCam = { zoom = 0.55, camScale = 1.30, z = -0.20, rotation = 0.15 },
        text = "Flying, Lifelink. Other Trolls you control get +1/+1."
    },
})
