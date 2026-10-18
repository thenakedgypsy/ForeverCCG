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
    -- ASHENVALE
    ["ASH01"] = {
        id = "ASH01", name = "Clattering Crawler", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 9566,
        zone = "Ashenvale", creatureType = "Beast", npcId = 3812,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ASH02"] = {
        id = "ASH02", name = "Spined Crawler", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 1001,
        zone = "Ashenvale", creatureType = "Beast", npcId = 3814,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ASH03"] = {
        id = "ASH03", name = "Ashenvale Bear", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 820,
        zone = "Ashenvale", creatureType = "Beast", npcId = 3809,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ASH04"] = {
        id = "ASH04", name = "Shadowhorn Stag", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 1991,
        zone = "Ashenvale", creatureType = "Beast", npcId = 3817,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ASH05"] = {
        id = "ASH05", name = "Ghostpaw Howler", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 1207,
        zone = "Ashenvale", creatureType = "Beast", npcId = 3824,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["ASH06"] = {
        id = "ASH06", name = "Befouled Water Elemental", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 525,
        zone = "Ashenvale", creatureType = "Elemental", npcId = 3917,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ASH07"] = {
        id = "ASH07", name = "Shadethicket Bark Ripper", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 3, toughness = 5, isMob = true, isBoss = true, displayId = 2024,
        zone = "Ashenvale", creatureType = "Elemental", npcId = 3784,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ASH08"] = {
        id = "ASH08", name = "Warsong Peon", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 5, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 11857,
        zone = "Ashenvale", creatureType = "Humanoid", npcId = 11656,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["ASH09"] = {
        id = "ASH09", name = "Ghostpaw Alpha", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 6, toughness = 5, isMob = true, isBoss = true, displayId = 776,
        zone = "Ashenvale", creatureType = "Beast", npcId = 3825,
        anthem = { tag = "type", value = "Beast", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Beasts you control get +1/+0."
    },
    ["ASH10"] = {
        id = "ASH10", name = "Terrowulf Packlord", cost = "{5}{G}{G}", cmc = 7, color = "G", type = "Creature",
        power = 9, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 522,
        zone = "Ashenvale", creatureType = "Humanoid", npcId = 3792,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    -- Solo reward
    ["ASH11"] = {
        id = "ASH11", name = "Raene Wolfrunner", cost = "{3}{G}", cmc = 4, color = "G", type = "Creature",
        power = 3, toughness = 3, haste = true, isReward = true, displayId = 1980,
        zone = "Ashenvale", creatureType = "Humanoid", npcEntry = 3691,
        anthem = { tag = "zone", value = "Ashenvale", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick. Other Ashenvale denizens you control get +1/+1."
    },
})
