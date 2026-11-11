--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- ZONE CREATURES - UNLOCKED BY KILLING THEM (isBoss = true reuses BossTracker as-is)
-- WoW Forever zone: names / displayIds / npcId come from wowhead.com/forever (zone 616).
-- Only hostile or neutral mobs and the zone's rares; vendors, quest NPCs and the Wild Gods left out.
-- =========================================================================
TTS:AddCards({
    -- MOUNT HYJAL
    ["HYJ01"] = {
        id = "HYJ01", name = "Rustleaf Fox", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 131968,
        zone = "Mount Hyjal", creatureType = "Beast", npcId = 249474,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["HYJ02"] = {
        id = "HYJ02", name = "Hyjal Owl", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, flying = true, isMob = true, isBoss = true, displayId = 10828,
        zone = "Mount Hyjal", creatureType = "Beast", npcId = 249053,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["HYJ03"] = {
        id = "HYJ03", name = "Defiling Hound", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 1, lifelink = true, isMob = true, isBoss = true, displayId = 6173,
        zone = "Mount Hyjal", creatureType = "Demon", npcId = 249230,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["HYJ04"] = {
        id = "HYJ04", name = "Blackthorne Cultist", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 145457,
        zone = "Mount Hyjal", creatureType = "Humanoid", faction = "Blackthorne Pact", npcId = 249551,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["HYJ05"] = {
        id = "HYJ05", name = "Ashen Acolyte", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 3, support = true, isMob = true, isBoss = true, displayId = 142428,
        zone = "Mount Hyjal", creatureType = "Humanoid", faction = "Cult of the Ashen Reign", npcId = 260422,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["HYJ06"] = {
        id = "HYJ06", name = "Hyjal Bear", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 148858,
        zone = "Mount Hyjal", creatureType = "Beast", npcId = 244525,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["HYJ07"] = {
        id = "HYJ07", name = "Fleshflay Ravener", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 414,
        zone = "Mount Hyjal", creatureType = "Undead", npcId = 249228,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HYJ08"] = {
        id = "HYJ08", name = "Nightsaber Guardian", cost = "{3}{G}", cmc = 4, color = "G", type = "Creature",
        power = 4, toughness = 3, haste = true, isMob = true, isBoss = true, displayId = 144996,
        zone = "Mount Hyjal", creatureType = "Beast", npcId = 249493,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["HYJ09"] = {
        id = "HYJ09", name = "Tainted Grovewalker", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 1, toughness = 8, defender = true, isMob = true, isBoss = true, displayId = 123593,
        zone = "Mount Hyjal", creatureType = "Elemental", npcId = 260822,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Blocker."
    },
    ["HYJ10"] = {
        dropChance = { 100, 25, 12, 6 },   -- rare spawn: normal rates
        id = "HYJ10", name = "Jezerelle the Swaying", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isNamed = true, isBoss = true, displayId = 138685,
        zone = "Mount Hyjal", creatureType = "Demon", npcId = 255183,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["HYJ12"] = {
        id = "HYJ12", name = "Wildbreath Chimaerok", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 4, toughness = 4, bulwark = 2, flying = true, isMob = true, isBoss = true, displayId = 4269,
        zone = "Mount Hyjal", creatureType = "Beast", npcId = 249490,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne. Bulwark 2."
    },
    ["HYJ13"] = {
        id = "HYJ13", name = "Felguard Sentinel", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 5, toughness = 4, firstStrike = true, isMob = true, isBoss = true, displayId = 9129,
        zone = "Mount Hyjal", creatureType = "Demon", npcId = 249229,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["HYJ14"] = {
        id = "HYJ14", name = "Blackthorne Outrunner", cost = "{4}{R}", cmc = 5, color = "R", type = "Creature",
        power = 5, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 148136,
        zone = "Mount Hyjal", creatureType = "Humanoid", faction = "Blackthorne Pact", npcId = 275173,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["HYJ15"] = {
        dropChance = { 100, 25, 12, 6 },   -- rare spawn: normal rates
        id = "HYJ15", name = "Death Wailer", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 5, toughness = 5, flying = true, lifelink = true, isMob = true, isNamed = true, isBoss = true, displayId = 8783,
        zone = "Mount Hyjal", creatureType = "Undead", npcId = 249226,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne. Drain."
    },
    ["HYJ16"] = {
        id = "HYJ16", name = "Ve'han Talongrasp", cost = "{5}{G}{G}", cmc = 7, color = "G", type = "Creature",
        power = 6, toughness = 6, vigilance = true, isMob = true, isNamed = true, isBoss = true, displayId = 149297,
        zone = "Mount Hyjal", creatureType = "Humanoid", faction = "Blackthorne Pact", npcId = 267182,
        anthem = { tag = "faction", value = "Blackthorne Pact", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant. Other Blackthorne Pact denizens you control get +1/+1."
    },
    -- Solo reward (HYJ11: the Zone Gauntlet grants <ZONE>11). A Wild God the Blackthorne Pact hunts.
    ["HYJ11"] = {
        id = "HYJ11", name = "Jereman", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 5, toughness = 5, vigilance = true, isReward = true, displayId = 142089,
        zone = "Mount Hyjal", creatureType = "Beast", npcEntry = 259944,
        anthem = { tag = "zone", value = "Mount Hyjal", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant. Other Mount Hyjal denizens you control get +1/+0."
    },
})
