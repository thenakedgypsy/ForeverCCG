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
    -- SCHOLOMANCE
    ["SCH01"] = {
        id = "SCH01", name = "Scholomance Acolyte", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 11157,
        zone = "Scholomance", creatureType = "Humanoid", npcId = 10471,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SCH02"] = {
        id = "SCH02", name = "Risen Guard", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 5, vigilance = true, isMob = true, isBoss = true, displayId = 7848,
        zone = "Scholomance", creatureType = "Undead", npcId = 10489,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant."
    },
    ["SCH03"] = {
        id = "SCH03", name = "Scholomance Necromancer", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 11163,
        zone = "Scholomance", creatureType = "Humanoid", npcId = 10477,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["SCH04"] = {
        id = "SCH04", name = "Diseased Ghoul", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 4, toughness = 3, haste = true, isMob = true, isBoss = true, displayId = 519,
        zone = "Scholomance", creatureType = "Undead", npcId = 10495,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["SCH05"] = {
        id = "SCH05", name = "Necrofiend", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 4, toughness = 5, deathtouch = true, reach = true, isMob = true, isBoss = true, displayId = 11178,
        zone = "Scholomance", creatureType = "Undead", npcId = 11551,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal. Anti-Air."
    },
    ["SCH06"] = {
        id = "SCH06", name = "Risen Construct", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 12074,
        zone = "Scholomance", creatureType = "Undead", npcId = 10488,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Brutish."
    },
    ["SCH07"] = {
        id = "SCH07", name = "Marduk Blackpool", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 7, firstStrike = true, isMob = true, isBoss = true, displayId = 10248,
        zone = "Scholomance", creatureType = "Undead", npcId = 10433,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["SCH08"] = {
        id = "SCH08", name = "Vectus", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 2606,
        zone = "Scholomance", creatureType = "Undead", npcId = 10432,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["SCH09"] = {
        id = "SCH09", name = "Jandice Barov", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 6, toughness = 7, hexproof = true, isMob = true, isBoss = true, displayId = 11073,
        zone = "Scholomance", creatureType = "Undead", npcId = 10503,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Warded."
    },
    ["SCH10"] = {
        id = "SCH10", name = "Instructor Malicia", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 8, lifelink = true, isMob = true, isBoss = true, displayId = 11069,
        zone = "Scholomance", creatureType = "Humanoid", npcId = 10505,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["SCH11"] = {
        id = "SCH11", name = "Lorekeeper Polkelt", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 1, toughness = 5, deathtouch = true, firstStrike = true, isMob = true, isBoss = true, displayId = 11492,
        zone = "Scholomance", creatureType = "Undead", npcId = 10901,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal. Strikes-First."
    },
    ["SCH12"] = {
        id = "SCH12", name = "Doctor Theolen Krastinov", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 8, toughness = 7, firstStrike = true, isMob = true, isBoss = true, displayId = 10901,
        zone = "Scholomance", creatureType = "Humanoid", npcId = 11261,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["SCH13"] = {
        id = "SCH13", name = "Lord Alexei Barov", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 8, lifelink = true, isMob = true, isBoss = true, displayId = 11072,
        zone = "Scholomance", creatureType = "Undead", npcId = 10504,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["SCH14"] = {
        id = "SCH14", name = "Lady Illucia Barov", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 6, toughness = 8, hexproof = true, isMob = true, isBoss = true, displayId = 11835,
        zone = "Scholomance", creatureType = "Undead", npcId = 10502,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Warded."
    },
    ["SCH15"] = {
        id = "SCH15", name = "Rattlegore", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 8, toughness = 8, trample = true, isMob = true, isBoss = true, displayId = 12073,
        zone = "Scholomance", creatureType = "Undead", npcId = 11622,
        anthem = { tag = "zone", value = "Scholomance", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Brutish. Other Scholomance denizens you control get +1/+1."
    },
    ["SCH16"] = {
        id = "SCH16", name = "The Ravenian", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 9, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 10433,
        zone = "Scholomance", creatureType = "Undead", npcId = 10507,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Brutish."
    },
    ["SCH17"] = {
        id = "SCH17", name = "Ras Frostwhisper", cost = "{5}{U}{U}", cmc = 7, color = "U", type = "Creature",
        power = 8, toughness = 10, vigilance = true, isMob = true, isBoss = true, displayId = 7919,
        zone = "Scholomance", creatureType = "Undead", npcId = 10508,
        anthem = { tag = "type", value = "Undead", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant. Other Undead you control get +1/+1."
    },
    -- Solo reward
    ["SCH18"] = {
        id = "SCH18", name = "Kirtonos the Herald", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 4, toughness = 4, flying = true, isReward = true, displayId = 7534,
        zone = "Scholomance", creatureType = "Undead", npcEntry = 10506,
        anthem = { tag = "zone", value = "Scholomance", p = 1, t = 1 },
        modelCam = { zoom = 0.70, camScale = 1.15, z = -0.18, rotation = 0.15 },
        text = "Airborne. Other Scholomance denizens you control get +1/+1."
    },
})
