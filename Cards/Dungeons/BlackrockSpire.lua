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
    -- BLACKROCK SPIRE
    ["BRS01"] = {
        id = "BRS01", name = "Scarshield Legionnaire", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 9629,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Blackrock", npcId = 9097,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BRS02"] = {
        id = "BRS02", name = "Spirestone Enforcer", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 11577,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Ogre", npcId = 9199,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["BRS03"] = {
        id = "BRS03", name = "Smolderthorn Headhunter", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 4, toughness = 3, haste = true, isMob = true, isBoss = true, displayId = 9682,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Troll", npcId = 9241,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["BRS04"] = {
        id = "BRS04", name = "Smolderthorn Shadow Priest", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 9728,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Troll", npcId = 9240,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["BRS05"] = {
        id = "BRS05", name = "Firebrand Pyromancer", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 9656,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Blackrock", npcId = 9264,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["BRS06"] = {
        id = "BRS06", name = "Spire Spider", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 4, reach = true, isMob = true, isBoss = true, displayId = 9755,
        zone = "Blackrock Spire", creatureType = "Beast", npcId = 10374,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["BRS07"] = {
        id = "BRS07", name = "Blackhand Iron Guard", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 5, toughness = 6, vigilance = true, isMob = true, isBoss = true, displayId = 9696,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Blackrock", npcId = 10319,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant."
    },
    ["BRS08"] = {
        id = "BRS08", name = "Rage Talon Dragonspawn", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 6, isMob = true, isBoss = true, displayId = 2554,
        zone = "Blackrock Spire", creatureType = "Dragonkin", npcId = 9096,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["BRS09"] = {
        id = "BRS09", name = "Quartermaster Zigris", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 9738,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Blackrock", npcId = 9736,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["BRS10"] = {
        id = "BRS10", name = "Halycon", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 7, toughness = 6, haste = true, isMob = true, isBoss = true, displayId = 9567,
        zone = "Blackrock Spire", creatureType = "Beast", npcId = 10220,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["BRS11"] = {
        id = "BRS11", name = "Shadow Hunter Vosh'gajin", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 7, deathtouch = true, isMob = true, isBoss = true, displayId = 9732,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Troll", npcId = 9236,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["BRS12"] = {
        id = "BRS12", name = "War Master Voone", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 8, toughness = 7, firstStrike = true, isMob = true, isBoss = true, displayId = 9733,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Troll", npcId = 9237,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["BRS13"] = {
        id = "BRS13", name = "Mother Smolderweb", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 7, deathtouch = true, reach = true, isMob = true, isBoss = true, displayId = 9929,
        zone = "Blackrock Spire", creatureType = "Beast", npcId = 10596,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal, Anti-Air."
    },
    ["BRS14"] = {
        id = "BRS14", name = "Jed Runewatcher", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 6, toughness = 7, vigilance = true, isMob = true, isBoss = true, displayId = 9686,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Blackrock", npcId = 10509,
        anthem = { tag = "faction", value = "Blackrock", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant. Other Blackrock you control get +1/+1."
    },
    ["BRS15"] = {
        id = "BRS15", name = "Spirestone Butcher", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 8, toughness = 8, isMob = true, isBoss = true, displayId = 11574,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Ogre", npcId = 9219,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["BRS16"] = {
        id = "BRS16", name = "Highlord Omokk", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 7, toughness = 8, trample = true, isMob = true, isBoss = true, displayId = 11565,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Ogre", npcId = 9196,
        rally = { tag = "faction", value = "Ogre", p = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Brutish. Gets +1/+0 for each other Ogre you control."
    },
    ["BRS17"] = {
        id = "BRS17", name = "Goraluk Anvilcrack", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 6, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 10222,
        zone = "Blackrock Spire", creatureType = "Humanoid", npcId = 10899,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["BRS18"] = {
        id = "BRS18", name = "Pyroguard Emberseer", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 9, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 2172,
        zone = "Blackrock Spire", creatureType = "Elemental", npcId = 9816,
        anthem = { tag = "type", value = "Elemental", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Brutish. Other Elementals you control get +1/+1."
    },
    ["BRS19"] = {
        id = "BRS19", name = "The Beast", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 10, toughness = 10, haste = true, trample = true, isMob = true, isBoss = true, displayId = 10193,
        zone = "Blackrock Spire", creatureType = "Beast", npcId = 10430,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Quick, Brutish."
    },
    -- Solo reward
    ["BRS20"] = {
        id = "BRS20", name = "Warchief Rend Blackhand", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 6, toughness = 5, haste = true, trample = true, isReward = true, displayId = 9778,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Blackrock", npcEntry = 10429,
        anthem = { tag = "zone", value = "Blackrock Spire", p = 1, kw = { "haste" } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick, Brutish. Other Blackrock Spire denizens you control get +1/+0 and Quick."
    },
})
