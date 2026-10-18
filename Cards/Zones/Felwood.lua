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
    -- FELWOOD
    ["FEL01"] = {
        id = "FEL01", name = "Felpaw Wolf", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 4124,
        zone = "Felwood", creatureType = "Beast", npcId = 8959,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["FEL02"] = {
        id = "FEL02", name = "Angerclaw Bear", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 9276,
        zone = "Felwood", creatureType = "Beast", npcId = 8956,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["FEL03"] = {
        id = "FEL03", name = "Deadwood Warrior", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 2000,
        zone = "Felwood", creatureType = "Humanoid", faction = "Furbolg", npcId = 7153,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["FEL04"] = {
        id = "FEL04", name = "Felpaw Scavenger", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 9278,
        zone = "Felwood", creatureType = "Beast", npcId = 8960,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["FEL05"] = {
        id = "FEL05", name = "Jadefire Satyr", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 2019,
        zone = "Felwood", creatureType = "Demon", faction = "Satyr", npcId = 7105,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["FEL06"] = {
        id = "FEL06", name = "Angerclaw Mauler", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 2, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 1083,
        zone = "Felwood", creatureType = "Beast", npcId = 8958,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = "Brutish."
    },
    ["FEL07"] = {
        id = "FEL07", name = "Irontree Stomper", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 1, toughness = 9, defender = true, isMob = true, isBoss = true, displayId = 6351,
        zone = "Felwood", creatureType = "Elemental", npcId = 7139,
        modelCam = { zoom = 0.61, camScale = 1.17, z = -0.13, rotation = 0.15 },
        text = "Blocker."
    },
    ["FEL08"] = {
        id = "FEL08", name = "Warpwood Moss Flayer", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 5, toughness = 6, reach = true, isMob = true, isBoss = true, displayId = 8389,
        zone = "Felwood", creatureType = "Elemental", npcId = 7100,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["FEL09"] = {
        id = "FEL09", name = "Jaedenar Darkweaver", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 5, toughness = 7, hexproof = true, isMob = true, isBoss = true, displayId = 6393,
        zone = "Felwood", creatureType = "Humanoid", npcId = 7118,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Warded."
    },
    ["FEL10"] = {
        id = "FEL10", name = "Mezzir the Howler", cost = "{5}{W}{W}", cmc = 7, color = "W", type = "Creature",
        power = 9, toughness = 9, vigilance = true, isMob = true, isBoss = true, displayId = 3208,
        zone = "Felwood", creatureType = "Humanoid", npcId = 10197,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant."
    },
    -- Solo reward
    ["FEL11"] = {
        id = "FEL11", name = "Arathandris Silversky", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 5, toughness = 5, isReward = true, displayId = 8657,
        zone = "Felwood", creatureType = "Humanoid", npcEntry = 9528,
        anthem = { tag = "zone", value = "Felwood", p = 1 },
        etb = { ops = { { op = "heal", to = "self_player", n = 5 }, { op = "buff", to = "friendly_creatures", t = 1, perm = true } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Arrival: You gain 5 life and denizens you control permanently get +0/+1. Other Felwood denizens you control get +1/+0."
    },
})
