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
    -- FERALAS
    ["FER01"] = {
        id = "FER01", name = "Woodpaw Mystic", cost = "{W}", cmc = 1, color = "W", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 10794,
        zone = "Feralas", creatureType = "Humanoid", faction = "Gnoll", npcId = 5254,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["FER02"] = {
        id = "FER02", name = "Woodpaw Reaver", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 1, firstStrike = true, isMob = true, isBoss = true, displayId = 10795,
        zone = "Feralas", creatureType = "Humanoid", faction = "Gnoll", npcId = 5255,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = "First Strike."
    },
    ["FER03"] = {
        id = "FER03", name = "Groddoc Ape", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 3186,
        zone = "Feralas", creatureType = "Beast", npcId = 5260,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["FER04"] = {
        id = "FER04", name = "Hatecrest Sorceress", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 11260,
        zone = "Feralas", creatureType = "Humanoid", faction = "Naga", npcId = 5336,
        modelCam = { zoom = 0.80, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["FER05"] = {
        id = "FER05", name = "Longtooth Howler", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 3202,
        zone = "Feralas", creatureType = "Beast", npcId = 5287,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["FER06"] = {
        id = "FER06", name = "Grizzled Ironfur Bear", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 4, isMob = true, isBoss = true, displayId = 8838,
        zone = "Feralas", creatureType = "Beast", npcId = 5272,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["FER07"] = {
        id = "FER07", name = "Frayfeather Patriarch", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 6756,
        zone = "Feralas", creatureType = "Beast", npcId = 5306,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["FER08"] = {
        id = "FER08", name = "Sea Spray", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 4, toughness = 6, isMob = true, isBoss = true, displayId = 5562,
        zone = "Feralas", creatureType = "Elemental", npcId = 5462,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["FER09"] = {
        id = "FER09", name = "Sea Elemental", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 5, toughness = 7, isMob = true, isBoss = true, displayId = 5450,
        zone = "Feralas", creatureType = "Elemental", npcId = 5461,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["FER10"] = {
        id = "FER10", name = "Antilus the Soarer", cost = "{5}{U}{U}", cmc = 7, color = "U", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 10889,
        zone = "Feralas", creatureType = "Beast", npcId = 5347,
        modelCam = { zoom = 0.58, camScale = 1.20, z = -0.14, rotation = 0.15 },
        text = ""
    },
    -- Solo reward
    ["FER11"] = {
        id = "FER11", name = "Kindal Moonweaver", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 3, toughness = 4, isReward = true, displayId = 7044,
        zone = "Feralas", creatureType = "Humanoid", npcEntry = 7956,
        anthem = { tag = "zone", value = "Feralas", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Feralas creatures you control get +1/+1."
    },
})
