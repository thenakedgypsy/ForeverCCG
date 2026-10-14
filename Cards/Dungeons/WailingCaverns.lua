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
    -- WAILING CAVERNS
    ["WCV01"] = {
        id = "WCV01", name = "Deviate Adder", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 2, deathtouch = true, isMob = true, isBoss = true, displayId = 4317,
        zone = "Wailing Caverns", creatureType = "Beast", npcId = 5048,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["WCV02"] = {
        id = "WCV02", name = "Deviate Ravager", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 4, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 1747,
        zone = "Wailing Caverns", creatureType = "Beast", npcId = 3636,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["WCV03"] = {
        id = "WCV03", name = "Deviate Guardian", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 7, defender = true, isMob = true, isBoss = true, displayId = 755,
        zone = "Wailing Caverns", creatureType = "Beast", npcId = 3637,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Blocker."
    },
    ["WCV04"] = {
        id = "WCV04", name = "Druid of the Fang", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 4233,
        zone = "Wailing Caverns", creatureType = "Humanoid", faction = "Druids of the Fang", npcId = 3840,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["WCV05"] = {
        id = "WCV05", name = "Deviate Faerie Dragon", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, flying = true, isMob = true, isBoss = true, displayId = 1267,
        zone = "Wailing Caverns", creatureType = "Dragonkin", npcId = 5912,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["WCV06"] = {
        id = "WCV06", name = "Skum", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 4, toughness = 5, isMob = true, isBoss = true, displayId = 4203,
        zone = "Wailing Caverns", creatureType = "Beast", npcId = 3674,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WCV07"] = {
        id = "WCV07", name = "Kresh", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 8, vigilance = true, isMob = true, isBoss = true, displayId = 5126,
        zone = "Wailing Caverns", creatureType = "Beast", npcId = 3653,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant."
    },
    ["WCV08"] = {
        id = "WCV08", name = "Lady Anacondra", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 5, toughness = 6, lifelink = true, isMob = true, isBoss = true, displayId = 4313,
        zone = "Wailing Caverns", creatureType = "Humanoid", faction = "Druids of the Fang", npcId = 3671,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["WCV09"] = {
        id = "WCV09", name = "Lord Cobrahn", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 5, toughness = 6, deathtouch = true, isMob = true, isBoss = true, displayId = 4213,
        zone = "Wailing Caverns", creatureType = "Humanoid", faction = "Druids of the Fang", npcId = 3669,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["WCV10"] = {
        id = "WCV10", name = "Lord Pythas", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 6, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 4214,
        zone = "Wailing Caverns", creatureType = "Humanoid", faction = "Druids of the Fang", npcId = 3670,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["WCV11"] = {
        id = "WCV11", name = "Lord Serpentis", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 6, toughness = 6, deathtouch = true, isMob = true, isBoss = true, displayId = 4215,
        zone = "Wailing Caverns", creatureType = "Humanoid", faction = "Druids of the Fang", npcId = 3673,
        anthem = { tag = "faction", value = "Druids of the Fang", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal. Other Druids of the Fang you control get +1/+1."
    },
    ["WCV12"] = {
        id = "WCV12", name = "Verdan the Everliving", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 7, toughness = 8, trample = true, isMob = true, isBoss = true, displayId = 4256,
        zone = "Wailing Caverns", creatureType = "Elemental", npcId = 5775,
        anthem = { tag = "zone", value = "Wailing Caverns", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Brutish. Other Wailing Caverns creatures you control get +1/+1."
    },
    -- Solo reward
    ["WCV13"] = {
        id = "WCV13", name = "Boahn", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 3, lifelink = true, isReward = true, displayId = 4212,
        zone = "Wailing Caverns", creatureType = "Humanoid", faction = "Druids of the Fang", npcEntry = 3672,
        anthem = { tag = "zone", value = "Wailing Caverns", p = 0, kw = { "lifelink" } },
        rally = { tag = "faction", value = "Druids of the Fang", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain. Gets +1/+1 for each other Druid of the Fang you control. Other Wailing Caverns creatures you control have Drain."
    },
})
