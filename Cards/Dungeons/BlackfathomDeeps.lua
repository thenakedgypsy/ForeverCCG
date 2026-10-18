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
    -- BLACKFATHOM DEEPS
    ["BFD01"] = {
        id = "BFD01", name = "Blindlight Murloc", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 4920,
        zone = "Blackfathom Deeps", creatureType = "Humanoid", faction = "Murloc", npcId = 4818,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BFD02"] = {
        id = "BFD02", name = "Aku'mai Fisher", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 1244,
        zone = "Blackfathom Deeps", creatureType = "Beast", npcId = 4824,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["BFD03"] = {
        id = "BFD03", name = "Fallenroot Shadowstalker", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 2, unblockable = true, isMob = true, isBoss = true, displayId = 2014,
        zone = "Blackfathom Deeps", creatureType = "Demon", faction = "Satyr", npcId = 4798,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Cannot be blocked."
    },
    ["BFD04"] = {
        id = "BFD04", name = "Twilight Reaver", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 2901,
        zone = "Blackfathom Deeps", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 4810,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BFD05"] = {
        id = "BFD05", name = "Blackfathom Sea Witch", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 5, isMob = true, isBoss = true, displayId = 4982,
        zone = "Blackfathom Deeps", creatureType = "Humanoid", faction = "Naga", npcId = 4805,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BFD06"] = {
        id = "BFD06", name = "Lady Sarevess", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 5, firstStrike = true, isMob = true, isBoss = true, displayId = 4979,
        zone = "Blackfathom Deeps", creatureType = "Humanoid", faction = "Naga", npcId = 4831,
        anthem = { tag = "faction", value = "Naga", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First. Other Naga you control get +1/+1."
    },
    ["BFD07"] = {
        id = "BFD07", name = "Ghamoo-ra", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 2, toughness = 8, vigilance = true, isMob = true, isBoss = true, displayId = 5027,
        zone = "Blackfathom Deeps", creatureType = "Beast", npcId = 4887,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Vigilant."
    },
    ["BFD08"] = {
        id = "BFD08", name = "Lorgus Jett", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 5, haste = true, isMob = true, isBoss = true, displayId = 12822,
        zone = "Blackfathom Deeps", creatureType = "Humanoid", npcId = 12902,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["BFD09"] = {
        id = "BFD09", name = "Gelihast", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 1773,
        zone = "Blackfathom Deeps", creatureType = "Humanoid", faction = "Murloc", npcId = 6243,
        rally = { tag = "faction", value = "Murloc", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Gets +1/+1 for each other Murloc you control."
    },
    ["BFD10"] = {
        id = "BFD10", name = "Old Serra'kis", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 7, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 1816,
        zone = "Blackfathom Deeps", creatureType = "Beast", npcId = 4830,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Brutish."
    },
    ["BFD11"] = {
        id = "BFD11", name = "Twilight Lord Kelris", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 5, toughness = 7, lifelink = true, isMob = true, isBoss = true, displayId = 4939,
        zone = "Blackfathom Deeps", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 4832,
        anthem = { tag = "faction", value = "Twilight's Hammer", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain. Other Twilight's Hammer you control get +1/+1."
    },
    -- Solo reward
    ["BFD12"] = {
        id = "BFD12", name = "Baron Aquanis", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 4, toughness = 5, isReward = true, displayId = 110,
        zone = "Blackfathom Deeps", creatureType = "Elemental", npcEntry = 12876,
        anthem = { tag = "zone", value = "Blackfathom Deeps", p = 1, t = 1 },
        etb = { ops = { { op = "draw", n = 1 } } },
        modelCam = { zoom = 0.70, camScale = 1.15, z = -0.18, rotation = 0.15 },
        text = "When Baron Aquanis enters the battlefield, draw a card. Other Blackfathom Deeps denizens you control get +1/+1."
    },
})
