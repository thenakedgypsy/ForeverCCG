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
    -- STRANGLETHORN VALE
    ["STV01"] = {
        id = "STV01", name = "Young Panther", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 2437,
        zone = "Stranglethorn Vale", creatureType = "Beast", npcId = 683,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["STV02"] = {
        id = "STV02", name = "Kurzen Medicine Man", cost = "{W}", cmc = 1, color = "W", type = "Creature",
        power = 1, toughness = 2, support = true, isMob = true, isBoss = true, displayId = 4436,
        zone = "Stranglethorn Vale", creatureType = "Humanoid", npcId = 940,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["STV03"] = {
        id = "STV03", name = "Stranglethorn Tiger", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 320,
        zone = "Stranglethorn Vale", creatureType = "Beast", npcId = 682,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["STV04"] = {
        id = "STV04", name = "Venture Co. Geologist", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 7197,
        zone = "Stranglethorn Vale", creatureType = "Humanoid", faction = "Venture Co.", npcId = 1096,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STV05"] = {
        id = "STV05", name = "Stranglethorn Tigress", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 614,
        zone = "Stranglethorn Vale", creatureType = "Beast", npcId = 772,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["STV06"] = {
        id = "STV06", name = "Jungle Thunderer", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 845,
        zone = "Stranglethorn Vale", creatureType = "Beast", npcId = 1114,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STV07"] = {
        id = "STV07", name = "Elder Mistvale Gorilla", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 4, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 838,
        zone = "Stranglethorn Vale", creatureType = "Beast", npcId = 1557,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["STV08"] = {
        id = "STV08", name = "Venture Co. Strip Miner", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 5, toughness = 5, support = true, isMob = true, isBoss = true, displayId = 7202,
        zone = "Stranglethorn Vale", creatureType = "Humanoid", faction = "Venture Co.", npcId = 674,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["STV09"] = {
        id = "STV09", name = "Southern Sand Crawler", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 4, toughness = 8, support = true, vigilance = true, isMob = true, isBoss = true, displayId = 9573,
        zone = "Stranglethorn Vale", creatureType = "Beast", npcId = 2544,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant. Support."
    },
    ["STV10"] = {
        id = "STV10", name = "Lord Sakrasis", cost = "{5}{U}{U}", cmc = 7, color = "U", type = "Creature",
        power = 9, toughness = 9, hexproof = true, isMob = true, isBoss = true, displayId = 4910,
        zone = "Stranglethorn Vale", creatureType = "Humanoid", npcId = 2541,
        modelCam = { zoom = 0.58, camScale = 1.20, z = -0.14, rotation = 0.15 },
        text = "Warded."
    },
    -- Solo reward
    ["STV11"] = {
        id = "STV11", name = "Hemet Nesingwary", cost = "{3}{G}", cmc = 4, color = "G", type = "Creature",
        power = 3, toughness = 3, reach = true, isReward = true, displayId = 1410,
        zone = "Stranglethorn Vale", creatureType = "Humanoid", npcEntry = 715,
        anthem = { tag = "zone", value = "Stranglethorn Vale", p = 1 },
        etb = { ops = { { op = "damage", to = "enemy_creatures", n = 2, filter = { tag = "type", value = "Beast" } } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air. Arrival: Deal 2 damage to each enemy Beast. Other Stranglethorn Vale denizens you control get +1/+0."
    },
})
