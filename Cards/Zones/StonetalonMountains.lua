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
    -- STONETALON MOUNTAINS
    ["STO01"] = {
        id = "STO01", name = "Gogger Geomancer", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 26,
        zone = "Stonetalon Mountains", creatureType = "Humanoid", npcId = 11917,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STO02"] = {
        id = "STO02", name = "Gogger Rock Keeper", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 26,
        zone = "Stonetalon Mountains", creatureType = "Humanoid", npcId = 11915,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STO03"] = {
        id = "STO03", name = "Gogger Stonepounder", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 26,
        zone = "Stonetalon Mountains", creatureType = "Humanoid", npcId = 11918,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STO04"] = {
        id = "STO04", name = "Windshear Digger", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 2153,
        zone = "Stonetalon Mountains", creatureType = "Humanoid", faction = "Kobold", npcId = 3999,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        etb = { ops = { { op = "token", id = "TOK02", n = 1 } } },
        text = "When Windshear Digger enters the battlefield, create a 1/1 Kobold Digger token."
    },
    ["STO05"] = {
        id = "STO05", name = "Pridewing Wyvern", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 2, toughness = 2, flying = true, isMob = true, isBoss = true, displayId = 295,
        zone = "Stonetalon Mountains", creatureType = "Beast", npcId = 4012,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["STO06"] = {
        id = "STO06", name = "Pridewing Consort", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 2297,
        zone = "Stonetalon Mountains", creatureType = "Beast", npcId = 4014,
        modelCam = { zoom = 0.78, camScale = 1.05, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["STO07"] = {
        id = "STO07", name = "Rogue Flame Spirit", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 3, toughness = 4, firstStrike = true, isMob = true, isBoss = true, displayId = 4607,
        zone = "Stonetalon Mountains", creatureType = "Elemental", npcId = 4036,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["STO08"] = {
        id = "STO08", name = "Blackened Basilisk", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 2173,
        zone = "Stonetalon Mountains", creatureType = "Beast", npcId = 4044,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STO09"] = {
        id = "STO09", name = "Bloodfury Windcaller", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 5, toughness = 5, flying = true, isMob = true, isBoss = true, displayId = 10282,
        zone = "Stonetalon Mountains", creatureType = "Humanoid", npcId = 4026,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["STO10"] = {
        id = "STO10", name = "Sorrow Wing", cost = "{5}{U}{U}", cmc = 7, color = "U", type = "Creature",
        power = 10, toughness = 10, isMob = true, isBoss = true, displayId = 11012,
        zone = "Stonetalon Mountains", creatureType = "Beast", npcId = 5928,
        modelCam = { zoom = 0.68, camScale = 1.12, z = -0.12, rotation = 0.15 },
        text = ""
    },
    -- Solo reward
    ["STO11"] = {
        id = "STO11", name = "Keeper Albagorm", cost = "{3}{G}", cmc = 4, color = "G", type = "Creature",
        power = 2, toughness = 5, reach = true, isReward = true, displayId = 150,
        zone = "Stonetalon Mountains", creatureType = "Humanoid", npcEntry = 3994,
        anthem = { tag = "zone", value = "Stonetalon Mountains", t = 2 },
        modelCam = { zoom = 0.70, camScale = 1.15, z = -0.18, rotation = 0.15 },
        text = "Anti-Air. Other Stonetalon Mountains creatures you control get +0/+2."
    },
})
