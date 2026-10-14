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
    -- WETLANDS
    ["WET01"] = {
        id = "WET01", name = "Young Wetlands Crocolisk", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 2, toughness = 1, isMob = true, isBoss = true, displayId = 1035,
        zone = "Wetlands", creatureType = "Beast", npcId = 1417,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WET02"] = {
        id = "WET02", name = "Mosshide Fenrunner", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 714,
        zone = "Wetlands", creatureType = "Humanoid", faction = "Gnoll", npcId = 1010,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["WET03"] = {
        id = "WET03", name = "Mottled Raptor", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 960,
        zone = "Wetlands", creatureType = "Beast", npcId = 1020,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["WET04"] = {
        id = "WET04", name = "Crimson Whelp", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 505,
        zone = "Wetlands", creatureType = "Dragonkin", faction = "Scarlet Crusade", npcId = 1069,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WET05"] = {
        id = "WET05", name = "Dragonmaw Raider", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 4916,
        zone = "Wetlands", creatureType = "Humanoid", npcId = 1034,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WET06"] = {
        id = "WET06", name = "Highland Razormaw", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 180,
        zone = "Wetlands", creatureType = "Beast", npcId = 1018,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["WET07"] = {
        id = "WET07", name = "Syndicate Highwayman", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 4, firstStrike = true, isMob = true, isBoss = true, displayId = 3984,
        zone = "Wetlands", creatureType = "Humanoid", faction = "Syndicate", npcId = 2586,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["WET08"] = {
        id = "WET08", name = "Rumbling Exile", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 4, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 9587,
        zone = "Wetlands", creatureType = "Elemental", npcId = 2592,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["WET09"] = {
        id = "WET09", name = "Burning Exile", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 5, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 2172,
        zone = "Wetlands", creatureType = "Elemental", npcId = 2760,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["WET10"] = {
        id = "WET10", name = "Molok the Crusher", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 9, toughness = 8, trample = true, isMob = true, isBoss = true, displayId = 536,
        zone = "Wetlands", creatureType = "Humanoid", faction = "Ogre", npcId = 2604,
        modelCam = { zoom = 0.73, camScale = 1.08, z = -0.12, rotation = 0.15 },
        text = "Trample."
    },
    -- Solo reward
    ["WET11"] = {
        id = "WET11", name = "Captain Stoutfist", cost = "{3}{R}", cmc = 4, color = "R", type = "Creature",
        power = 4, toughness = 3, trample = true, isReward = true, displayId = 5409,
        zone = "Wetlands", creatureType = "Humanoid", npcEntry = 2104,
        anthem = { tag = "zone", value = "Wetlands", p = 1, kw = { "trample" } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample. Other Wetlands creatures you control get +1/+0 and Trample."
    },
})
