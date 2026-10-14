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
    -- SWAMP OF SORROWS
    ["SWA01"] = {
        id = "SWA01", name = "Young Sawtooth Crocolisk", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 2, toughness = 1, isMob = true, isBoss = true, displayId = 814,
        zone = "Swamp of Sorrows", creatureType = "Beast", npcId = 1084,
        modelCam = { zoom = 0.80, camScale = 1.03, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["SWA02"] = {
        id = "SWA02", name = "Sorrow Spinner", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, reach = true, isMob = true, isBoss = true, displayId = 2543,
        zone = "Swamp of Sorrows", creatureType = "Beast", npcId = 858,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["SWA03"] = {
        id = "SWA03", name = "Lost One Hunter", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 152,
        zone = "Swamp of Sorrows", creatureType = "Humanoid", npcId = 759,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SWA04"] = {
        id = "SWA04", name = "Shadow Panther", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 633,
        zone = "Swamp of Sorrows", creatureType = "Beast", npcId = 768,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["SWA05"] = {
        id = "SWA05", name = "Tangled Horror", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 697,
        zone = "Swamp of Sorrows", creatureType = "Elemental", npcId = 766,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["SWA06"] = {
        id = "SWA06", name = "Silt Crawler", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 2, toughness = 4, isMob = true, isBoss = true, displayId = 9571,
        zone = "Swamp of Sorrows", creatureType = "Beast", npcId = 922,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SWA07"] = {
        id = "SWA07", name = "Sawtooth Snapper", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 815,
        zone = "Swamp of Sorrows", creatureType = "Beast", npcId = 1087,
        modelCam = { zoom = 0.70, camScale = 1.11, z = -0.12, rotation = 0.15 },
        text = ""
    },
    ["SWA08"] = {
        id = "SWA08", name = "Witherbark Sadist", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 6489,
        zone = "Swamp of Sorrows", creatureType = "Humanoid", faction = "Troll", npcId = 2653,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SWA09"] = {
        id = "SWA09", name = "Witherbark Broodguard", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 4, toughness = 6, deathtouch = true, isMob = true, isBoss = true, displayId = 1157,
        zone = "Swamp of Sorrows", creatureType = "Beast", faction = "Troll", npcId = 2686,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["SWA10"] = {
        id = "SWA10", name = "Zekkis", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 9, toughness = 11, isMob = true, isBoss = true, displayId = 6693,
        zone = "Swamp of Sorrows", creatureType = "Undead", npcId = 5400,
        modelCam = { zoom = 0.63, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },
    -- Solo reward
    ["SWA11"] = {
        id = "SWA11", name = "Fallen Hero of the Horde", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 5, toughness = 5, lifelink = true, isReward = true, displayId = 6775,
        zone = "Swamp of Sorrows", creatureType = "Humanoid", npcEntry = 7572,
        anthem = { tag = "zone", value = "Swamp of Sorrows", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink. Other Swamp of Sorrows creatures you control get +1/+1."
    },
})
