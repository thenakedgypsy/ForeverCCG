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
    -- THE DEADMINES
    ["DMS01"] = {
        id = "DMS01", name = "Defias Pirate", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 2347,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 657,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["DMS02"] = {
        id = "DMS02", name = "Defias Watchman", cost = "{1}{W}", cmc = 2, color = "W", type = "Creature",
        power = 2, toughness = 4, vigilance = true, isMob = true, isBoss = true, displayId = 184,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 1725,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["DMS03"] = {
        id = "DMS03", name = "Goblin Engineer", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 7109,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 622,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DMS04"] = {
        id = "DMS04", name = "Defias Blackguard", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 3, unblockable = true, isMob = true, isBoss = true, displayId = 2314,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 636,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Cannot be blocked."
    },
    ["DMS05"] = {
        id = "DMS05", name = "Defias Evoker", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 2318,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 1729,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DMS06"] = {
        id = "DMS06", name = "Gilnid", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 5, firstStrike = true, isMob = true, isBoss = true, displayId = 7124,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 1763,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["DMS07"] = {
        id = "DMS07", name = "Rhahk'Zor", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 14403,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 644,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["DMS08"] = {
        id = "DMS08", name = "Sneed's Shredder", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 5, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 1269,
        zone = "The Deadmines", creatureType = "Mechanical", faction = "Defias", npcId = 642,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample."
    },
    ["DMS09"] = {
        id = "DMS09", name = "Cookie", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 5, toughness = 6, lifelink = true, isMob = true, isBoss = true, displayId = 1305,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 645,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["DMS10"] = {
        id = "DMS10", name = "Captain Greenskin", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 5, toughness = 6, vigilance = true, isMob = true, isBoss = true, displayId = 7113,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 647,
        anthem = { tag = "faction", value = "Defias", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance. Other Defias you control get +1/+1."
    },
    ["DMS11"] = {
        id = "DMS11", name = "Mr. Smite", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 2026,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 646,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
})
