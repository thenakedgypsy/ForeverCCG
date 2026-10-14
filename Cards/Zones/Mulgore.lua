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
    -- MULGORE
    ["MUL01"] = {
        id = "MUL01", name = "Plainstrider", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 1219,
        zone = "Mulgore", creatureType = "Beast", npcId = 2955,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["MUL02"] = {
        id = "MUL02", name = "Mountain Cougar", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 11451,
        zone = "Mulgore", creatureType = "Beast", npcId = 2961,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["MUL03"] = {
        id = "MUL03", name = "Battleboar", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 8869,
        zone = "Mulgore", creatureType = "Beast", npcId = 2966,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["MUL04"] = {
        id = "MUL04", name = "Bristleback Quilboar", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 1967,
        zone = "Mulgore", creatureType = "Humanoid", faction = "Quilboar", npcId = 2952,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["MUL05"] = {
        id = "MUL05", name = "Palemane Tanner", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 550,
        zone = "Mulgore", creatureType = "Humanoid", npcId = 2949,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["MUL06"] = {
        id = "MUL06", name = "Prairie Wolf", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 1100,
        zone = "Mulgore", creatureType = "Beast", npcId = 2958,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["MUL07"] = {
        id = "MUL07", name = "Wiry Swoop", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 2, toughness = 3, flying = true, haste = true, isMob = true, isBoss = true, displayId = 1228,
        zone = "Mulgore", creatureType = "Beast", npcId = 2969,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne, Quick."
    },
    ["MUL08"] = {
        id = "MUL08", name = "Venture Co. Worker", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 7247,
        zone = "Mulgore", creatureType = "Humanoid", faction = "Venture Co.", npcId = 2978,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["MUL09"] = {
        id = "MUL09", name = "Venture Co. Supervisor", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 7245,
        zone = "Mulgore", creatureType = "Humanoid", faction = "Venture Co.", npcId = 2979,
        anthem = { tag = "faction", value = "Venture Co.", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Venture Co. you control get +1/+1."
    },
    ["MUL10"] = {
        id = "MUL10", name = "Snagglespear", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 275,
        zone = "Mulgore", creatureType = "Humanoid", faction = "Quilboar", npcId = 5786,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    -- Solo reward
    ["MUL11"] = {
        id = "MUL11", name = "Baine Bloodhoof", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isReward = true, displayId = 3792,
        zone = "Mulgore", creatureType = "Humanoid", npcEntry = 2993,
        anthem = { tag = "zone", value = "Mulgore", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Mulgore creatures you control get +1/+1."
    },
})
