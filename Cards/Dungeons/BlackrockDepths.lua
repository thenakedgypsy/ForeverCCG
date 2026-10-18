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
    -- BLACKROCK DEPTHS
    ["BRD01"] = {
        id = "BRD01", name = "Anvilrage Guardsman", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 8750,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 8891,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BRD02"] = {
        id = "BRD02", name = "Fireguard", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 2172,
        zone = "Blackrock Depths", creatureType = "Elemental", npcId = 8909,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BRD03"] = {
        id = "BRD03", name = "Twilight's Hammer Torturer", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 4, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 8790,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 8912,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["BRD04"] = {
        id = "BRD04", name = "Anvilrage Medic", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 8752,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 8894,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["BRD05"] = {
        id = "BRD05", name = "Doomforge Dragoon", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 4, trample = true, isMob = true, isBoss = true, displayId = 8820,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 8899,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["BRD06"] = {
        id = "BRD06", name = "Lord Roccor", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 5781,
        zone = "Blackrock Depths", creatureType = "Elemental", npcId = 9025,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["BRD07"] = {
        id = "BRD07", name = "High Interrogator Gerstahn", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 5, toughness = 6, deathtouch = true, isMob = true, isBoss = true, displayId = 8761,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 9018,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["BRD08"] = {
        id = "BRD08", name = "Verek", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 6, toughness = 6, haste = true, isMob = true, isBoss = true, displayId = 9019,
        zone = "Blackrock Depths", creatureType = "Demon", npcId = 9042,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["BRD09"] = {
        id = "BRD09", name = "Molten War Golem", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 8179,
        zone = "Blackrock Depths", creatureType = "Elemental", npcId = 8908,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Brutish."
    },
    ["BRD10"] = {
        id = "BRD10", name = "Houndmaster Grebmar", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 6, toughness = 6, haste = true, isMob = true, isBoss = true, displayId = 9212,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 9319,
        anthem = { tag = "type", value = "Beast", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick. Other Beasts you control get +1/+1."
    },
    ["BRD11"] = {
        id = "BRD11", name = "Fineous Darkvire", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 7, toughness = 7, lifelink = true, isMob = true, isBoss = true, displayId = 8704,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 9056,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["BRD12"] = {
        id = "BRD12", name = "Pyromancer Loregrain", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 8762,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 9024,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["BRD13"] = {
        id = "BRD13", name = "Warder Stilgiss", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 6, toughness = 9, isMob = true, isBoss = true, displayId = 9089,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 9041,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BRD14"] = {
        id = "BRD14", name = "Phalanx", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 7, toughness = 11, vigilance = true, isMob = true, isBoss = true, displayId = 8177,
        zone = "Blackrock Depths", creatureType = "Elemental", npcId = 9502,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Vigilant."
    },
    ["BRD15"] = {
        id = "BRD15", name = "Doom'rel", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 8, toughness = 9, lifelink = true, isMob = true, isBoss = true, displayId = 8687,
        zone = "Blackrock Depths", creatureType = "Undead", faction = "Dark Iron", npcId = 9039,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["BRD16"] = {
        id = "BRD16", name = "Golem Lord Argelmach", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 8, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 8759,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 8983,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["BRD17"] = {
        id = "BRD17", name = "Ambassador Flamelash", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 9, toughness = 8, firstStrike = true, isMob = true, isBoss = true, displayId = 8329,
        zone = "Blackrock Depths", creatureType = "Humanoid", npcId = 9156,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["BRD18"] = {
        id = "BRD18", name = "Bael'Gar", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 9, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 12162,
        zone = "Blackrock Depths", creatureType = "Giant", npcId = 9016,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Brutish."
    },
    ["BRD19"] = {
        id = "BRD19", name = "Lord Incendius", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 8, toughness = 9, firstStrike = true, isMob = true, isBoss = true, displayId = 1204,
        zone = "Blackrock Depths", creatureType = "Elemental", npcId = 9017,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["BRD20"] = {
        id = "BRD20", name = "Panzor the Invincible", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 3, toughness = 11, hexproof = true, isMob = true, isBoss = true, displayId = 8270,
        zone = "Blackrock Depths", creatureType = "Elemental", npcId = 8923,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Warded."
    },
    ["BRD21"] = {
        id = "BRD21", name = "General Angerforge", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 9, toughness = 9, firstStrike = true, isMob = true, isBoss = true, displayId = 8756,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 9033,
        anthem = { tag = "faction", value = "Dark Iron", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First. Other Dark Iron you control get +1/+1."
    },
    ["BRD22"] = {
        id = "BRD22", name = "Magmus", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 9, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 12162,
        zone = "Blackrock Depths", creatureType = "Giant", npcId = 9938,
        anthem = { tag = "zone", value = "Blackrock Depths", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Brutish. Other Blackrock Depths denizens you control get +1/+1."
    },
    -- Solo reward
    ["BRD23"] = {
        id = "BRD23", name = "Princess Moira Bronzebeard", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 3, toughness = 5, lifelink = true, isReward = true, displayId = 8705,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcEntry = 8929,
        anthem = { tag = "faction", value = "Dark Iron", p = 1, t = 1 },
        etb = { ops = { { op = "buff", to = "friendly_creatures", t = 1, perm = true } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain. Arrival: Denizens you control permanently get +0/+1. Other Dark Iron you control get +1/+1."
    },
})
