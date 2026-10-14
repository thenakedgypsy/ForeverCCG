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
    -- BADLANDS
    ["BAD01"] = {
        id = "BAD01", name = "Shadowforge Tunneler", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 4932,
        zone = "Badlands", creatureType = "Humanoid", faction = "Dark Iron", npcId = 2739,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BAD02"] = {
        id = "BAD02", name = "Shadowforge Darkweaver", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 4933,
        zone = "Badlands", creatureType = "Humanoid", faction = "Dark Iron", npcId = 2740,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BAD03"] = {
        id = "BAD03", name = "Starving Buzzard", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 1, flying = true, isMob = true, isBoss = true, displayId = 10824,
        zone = "Badlands", creatureType = "Beast", npcId = 2829,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["BAD04"] = {
        id = "BAD04", name = "Ridge Huntress", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, firstStrike = true, isMob = true, isBoss = true, displayId = 1055,
        zone = "Badlands", creatureType = "Beast", npcId = 2732,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["BAD05"] = {
        id = "BAD05", name = "Rock Elemental", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 1, toughness = 7, defender = true, isMob = true, isBoss = true, displayId = 171,
        zone = "Badlands", creatureType = "Elemental", npcId = 92,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Blocker."
    },
    ["BAD06"] = {
        id = "BAD06", name = "Scalding Whelp", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 2, toughness = 2, flying = true, isMob = true, isBoss = true, displayId = 715,
        zone = "Badlands", creatureType = "Dragonkin", npcId = 2725,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["BAD07"] = {
        id = "BAD07", name = "Dark Iron Kidnapper", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 7789,
        zone = "Badlands", creatureType = "Humanoid", faction = "Dark Iron", npcId = 15692,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BAD08"] = {
        id = "BAD08", name = "Shadowforge Surveyor", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 6051,
        zone = "Badlands", creatureType = "Humanoid", faction = "Dark Iron", npcId = 4844,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BAD09"] = {
        id = "BAD09", name = "Shadowforge Digger", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 7, toughness = 7, isMob = true, isBoss = true, displayId = 6052,
        zone = "Badlands", creatureType = "Humanoid", faction = "Dark Iron", npcId = 4846,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BAD10"] = {
        id = "BAD10", name = "Anathemus", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 10, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 10040,
        zone = "Badlands", creatureType = "Giant", npcId = 2754,
        modelCam = { zoom = 0.64, camScale = 1.15, z = -0.13, rotation = 0.15 },
        text = "Brutish."
    },
    -- Solo reward
    ["BAD11"] = {
        id = "BAD11", name = "Lotwil Veriatus", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 2, toughness = 3, isReward = true, displayId = 4896,
        zone = "Badlands", creatureType = "Humanoid", npcEntry = 2921,
        anthem = { tag = "zone", value = "Badlands", p = 1 },
        etb = { ops = { { op = "damage", to = "enemy_creatures", n = 1 } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "When Lotwil Veriatus enters the battlefield, deal 1 damage to each enemy creature. Other Badlands creatures you control get +1/+0."
    },
})
