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
    -- DUN MOROGH
    ["DUN01"] = {
        id = "DUN01", name = "Ragged Young Wolf", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 855,
        zone = "Dun Morogh", creatureType = "Beast", npcId = 705,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["DUN02"] = {
        id = "DUN02", name = "Burly Rockjaw Trogg", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 611,
        zone = "Dun Morogh", creatureType = "Humanoid", npcId = 724,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DUN03"] = {
        id = "DUN03", name = "Ragged Timber Wolf", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 11416,
        zone = "Dun Morogh", creatureType = "Beast", npcId = 704,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["DUN04"] = {
        id = "DUN04", name = "Frostmane Troll Whelp", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 5606,
        zone = "Dun Morogh", creatureType = "Humanoid", faction = "Troll", npcId = 706,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DUN05"] = {
        id = "DUN05", name = "Crag Boar", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 607,
        zone = "Dun Morogh", creatureType = "Beast", npcId = 1125,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DUN06"] = {
        id = "DUN06", name = "Wendigo", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 950,
        zone = "Dun Morogh", creatureType = "Humanoid", npcId = 1135,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DUN07"] = {
        id = "DUN07", name = "Snow Leopard", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 3, haste = true, isMob = true, isBoss = true, displayId = 954,
        zone = "Dun Morogh", creatureType = "Beast", npcId = 1201,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["DUN08"] = {
        id = "DUN08", name = "Winter Wolf", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 6, toughness = 4, isMob = true, isBoss = true, displayId = 785,
        zone = "Dun Morogh", creatureType = "Beast", npcId = 1131,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DUN09"] = {
        id = "DUN09", name = "Ice Claw Bear", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 4, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 8840,
        zone = "Dun Morogh", creatureType = "Beast", npcId = 1196,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["DUN10"] = {
        id = "DUN10", name = "Hammerspine", cost = "{5}{G}{G}", cmc = 7, color = "G", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 830,
        zone = "Dun Morogh", creatureType = "Humanoid", npcId = 1119,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
})
