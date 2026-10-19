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
    -- THE STOCKADE
    ["STK01"] = {
        id = "STK01", name = "Defias Prisoner", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 2148,
        zone = "The Stockade", creatureType = "Humanoid", faction = "Defias", npcId = 1706,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STK02"] = {
        id = "STK02", name = "Defias Insurgent", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 3, haste = true, isMob = true, isBoss = true, displayId = 2147,
        zone = "The Stockade", creatureType = "Humanoid", faction = "Defias", npcId = 1715,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["STK03"] = {
        id = "STK03", name = "Targorr the Dread", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 517,
        zone = "The Stockade", creatureType = "Humanoid", faction = "Defias", npcId = 1696,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["STK04"] = {
        id = "STK04", name = "Dextren Ward", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 5, toughness = 6, support = true, isMob = true, isBoss = true, displayId = 2149,
        zone = "The Stockade", creatureType = "Humanoid", faction = "Defias", npcId = 1663,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["STK05"] = {
        id = "STK05", name = "Kam Deepfury", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 4, toughness = 7, support = true, isMob = true, isBoss = true, displayId = 825,
        zone = "The Stockade", creatureType = "Humanoid", faction = "Defias", npcId = 1666,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["STK06"] = {
        id = "STK06", name = "Hamhock", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 8, isMob = true, isBoss = true, displayId = 3250,
        zone = "The Stockade", creatureType = "Humanoid", faction = "Defias", npcId = 1717,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["STK07"] = {
        id = "STK07", name = "Bruegal Ironknuckle", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 6, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 2142,
        zone = "The Stockade", creatureType = "Humanoid", faction = "Defias", npcId = 1720,
        anthem = { tag = "zone", value = "The Stockade", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First. Other Stockade denizens you control get +1/+1."
    },
    -- Solo reward
    ["STK08"] = {
        id = "STK08", name = "Defias Convict", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, haste = true, isReward = true, displayId = 2145,
        zone = "The Stockade", creatureType = "Humanoid", faction = "Defias", npcEntry = 1711,
        anthem = { tag = "zone", value = "The Stockade", p = 0, kw = { "haste" } },
        rally = { tag = "faction", value = "Defias", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick. Gets +1/+0 for each other Defias you control. Other Stockade denizens you control have Quick."
    },
})
