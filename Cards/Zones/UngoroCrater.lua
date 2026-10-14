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
    -- UN'GORO CRATER
    ["UNG01"] = {
        id = "UNG01", name = "Ferocious Rage Scar", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 3208,
        zone = "Un'Goro Crater", creatureType = "Humanoid", npcId = 5299,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["UNG02"] = {
        id = "UNG02", name = "Ravasaur", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 5242,
        zone = "Un'Goro Crater", creatureType = "Beast", npcId = 6505,
        modelCam = { zoom = 0.68, camScale = 1.12, z = -0.12, rotation = 0.15 },
        text = ""
    },
    ["UNG03"] = {
        id = "UNG03", name = "Bloodpetal Lasher", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 11634,
        zone = "Un'Goro Crater", creatureType = "Elemental", npcId = 6509,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["UNG04"] = {
        id = "UNG04", name = "Un'Goro Gorilla", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 844,
        zone = "Un'Goro Crater", creatureType = "Beast", npcId = 6514,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["UNG05"] = {
        id = "UNG05", name = "Bloodpetal Flayer", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 11635,
        zone = "Un'Goro Crater", creatureType = "Elemental", npcId = 6510,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["UNG06"] = {
        id = "UNG06", name = "Diemetradon", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 8511,
        zone = "Un'Goro Crater", creatureType = "Beast", npcId = 9163,
        modelCam = { zoom = 0.66, camScale = 1.13, z = -0.13, rotation = 0.15 },
        text = "Trample."
    },
    ["UNG07"] = {
        id = "UNG07", name = "Un'Goro Thunderer", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 4, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 5244,
        zone = "Un'Goro Crater", creatureType = "Beast", npcId = 6516,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["UNG08"] = {
        id = "UNG08", name = "Frenzied Pterrordax", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 4, toughness = 4, flying = true, isMob = true, isBoss = true, displayId = 8412,
        zone = "Un'Goro Crater", creatureType = "Beast", npcId = 9167,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["UNG09"] = {
        id = "UNG09", name = "Living Blaze", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 5, toughness = 7, isMob = true, isBoss = true, displayId = 5488,
        zone = "Un'Goro Crater", creatureType = "Elemental", npcId = 6521,
        modelCam = { zoom = 0.75, camScale = 1.07, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["UNG10"] = {
        id = "UNG10", name = "Uhk'loc", cost = "{5}{G}{G}", cmc = 7, color = "G", type = "Creature",
        power = 9, toughness = 8, trample = true, isMob = true, isBoss = true, displayId = 8129,
        zone = "Un'Goro Crater", creatureType = "Beast", npcId = 6585,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
})
