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
    -- SHADOWFANG KEEP
    ["SFK01"] = {
        id = "SFK01", name = "Shadowfang Whitescalp", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 729,
        zone = "Shadowfang Keep", creatureType = "Humanoid", faction = "Worgen", npcId = 3851,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SFK02"] = {
        id = "SFK02", name = "Slavering Worg", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 11421,
        zone = "Shadowfang Keep", creatureType = "Beast", npcId = 3862,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["SFK03"] = {
        id = "SFK03", name = "Haunted Servitor", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 3229,
        zone = "Shadowfang Keep", creatureType = "Undead", npcId = 3875,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SFK04"] = {
        id = "SFK04", name = "Vile Bat", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 3, flying = true, lifelink = true, isMob = true, isBoss = true, displayId = 8808,
        zone = "Shadowfang Keep", creatureType = "Beast", npcId = 3866,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying, Lifelink."
    },
    ["SFK05"] = {
        id = "SFK05", name = "Lupine Horror", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 2446,
        zone = "Shadowfang Keep", creatureType = "Undead", faction = "Worgen", npcId = 3863,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SFK06"] = {
        id = "SFK06", name = "Rethilgore", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 5, toughness = 6, isMob = true, isBoss = true, displayId = 524,
        zone = "Shadowfang Keep", creatureType = "Humanoid", npcId = 3914,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SFK07"] = {
        id = "SFK07", name = "Razorclaw the Butcher", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 524,
        zone = "Shadowfang Keep", creatureType = "Humanoid", faction = "Worgen", npcId = 3886,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["SFK08"] = {
        id = "SFK08", name = "Odo the Blindwatcher", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 6, toughness = 5, haste = true, isMob = true, isBoss = true, displayId = 522,
        zone = "Shadowfang Keep", creatureType = "Humanoid", faction = "Worgen", npcId = 4279,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["SFK09"] = {
        id = "SFK09", name = "Baron Silverlaine", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 7, lifelink = true, isMob = true, isBoss = true, displayId = 3222,
        zone = "Shadowfang Keep", creatureType = "Undead", npcId = 3887,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["SFK10"] = {
        id = "SFK10", name = "Commander Springvale", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 5, toughness = 6, vigilance = true, isMob = true, isBoss = true, displayId = 3223,
        zone = "Shadowfang Keep", creatureType = "Undead", npcId = 4278,
        anthem = { tag = "zone", value = "Shadowfang Keep", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance. Other Shadowfang Keep creatures you control get +1/+1."
    },
    ["SFK11"] = {
        id = "SFK11", name = "Wolf Master Nandos", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 6, toughness = 5, haste = true, isMob = true, isBoss = true, displayId = 11179,
        zone = "Shadowfang Keep", creatureType = "Humanoid", faction = "Worgen", npcId = 3927,
        anthem = { tag = "faction", value = "Worgen", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste. Other Worgen you control get +1/+1."
    },
    ["SFK12"] = {
        id = "SFK12", name = "Fenrus the Devourer", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 7, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 2352,
        zone = "Shadowfang Keep", creatureType = "Beast", npcId = 4274,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
})
