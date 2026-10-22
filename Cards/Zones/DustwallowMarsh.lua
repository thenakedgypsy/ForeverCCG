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
    -- DUSTWALLOW MARSH
    ["DUS01"] = {
        id = "DUS01", name = "Noxious Flayer", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 1, flying = true, isMob = true, isBoss = true, displayId = 2700,
        zone = "Dustwallow Marsh", creatureType = "Beast", npcId = 4346,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["DUS02"] = {
        id = "DUS02", name = "Withervine Creeper", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 4, defender = true, isMob = true, isBoss = true, displayId = 2024,
        zone = "Dustwallow Marsh", creatureType = "Elemental", npcId = 4382,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Blocker."
    },
    ["DUS03"] = {
        id = "DUS03", name = "Mirefin Murloc", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 652,
        zone = "Dustwallow Marsh", creatureType = "Humanoid", faction = "Murloc", npcId = 4359,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        onDeath = { ops = { { op = "token", id = "TOK01", n = 1 } } },
        text = "Martyrdom: Spawn: 1 Murloc Tadpole Add (1/1)."
    },
    ["DUS04"] = {
        id = "DUS04", name = "Drywallow Snapper", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 814,
        zone = "Dustwallow Marsh", creatureType = "Beast", npcId = 4343,
        modelCam = { zoom = 0.80, camScale = 1.03, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["DUS05"] = {
        id = "DUS05", name = "Mottled Drywallow Crocolisk", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 2548,
        zone = "Dustwallow Marsh", creatureType = "Beast", npcId = 4344,
        modelCam = { zoom = 0.80, camScale = 1.03, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["DUS06"] = {
        id = "DUS06", name = "Darkfang Creeper", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 2, deathtouch = true, isMob = true, isBoss = true, displayId = 2546,
        zone = "Dustwallow Marsh", creatureType = "Beast", npcId = 4412,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["DUS07"] = {
        id = "DUS07", name = "Young Murk Thresher", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 2425,
        zone = "Dustwallow Marsh", creatureType = "Beast", npcId = 4388,
        modelCam = { zoom = 0.46, camScale = 1.28, z = -0.16, rotation = 0.15 },
        text = ""
    },
    ["DUS08"] = {
        id = "DUS08", name = "Muckshell Pincer", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 5, toughness = 5, support = true, isMob = true, isBoss = true, displayId = 2599,
        zone = "Dustwallow Marsh", creatureType = "Humanoid", npcId = 4403,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["DUS09"] = {
        id = "DUS09", name = "Muckshell Scrabbler", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 6, toughness = 6, hexproof = true, isMob = true, isBoss = true, displayId = 2600,
        zone = "Dustwallow Marsh", creatureType = "Humanoid", npcId = 4404,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Warded."
    },
    ["DUS10"] = {
        id = "DUS10", name = "Lord Angler", cost = "{5}{U}{U}", cmc = 7, color = "U", type = "Creature",
        power = 9, toughness = 9, hexproof = true, isMob = true, isNamed = true, isBoss = true, displayId = 14257,
        zone = "Dustwallow Marsh", creatureType = "Humanoid", npcId = 14236,
        modelCam = { zoom = 0.58, camScale = 1.19, z = -0.14, rotation = 0.15 },
        text = "Warded."
    },
    -- Solo reward
    ["DUS11"] = {
        id = "DUS11", name = "Lady Jaina Proudmoore", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 4, toughness = 6, isReward = true, displayId = 2970,
        zone = "Dustwallow Marsh", creatureType = "Humanoid", npcEntry = 4968,
        etb = { ops = { { op = "damage", to = "enemy_creatures", n = 2 }, { op = "tap", to = "enemy_creatures" } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Arrival: Deal 2 damage to each enemy denizen and Exhaust them."
    },
})
