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
    -- ALTERAC MOUNTAINS
    ["ALT01"] = {
        id = "ALT01", name = "Mountain Yeti", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 1050,
        zone = "Alterac Mountains", creatureType = "Humanoid", npcId = 2250,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ALT02"] = {
        id = "ALT02", name = "Syndicate Thief", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 1, firstStrike = true, isMob = true, isBoss = true, displayId = 3709,
        zone = "Alterac Mountains", creatureType = "Humanoid", faction = "Syndicate", npcId = 2241,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["ALT03"] = {
        id = "ALT03", name = "Giant Yeti", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 6767,
        zone = "Alterac Mountains", creatureType = "Humanoid", npcId = 2251,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ALT04"] = {
        id = "ALT04", name = "Hulking Mountain Lion", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 2300,
        zone = "Alterac Mountains", creatureType = "Beast", npcId = 2407,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["ALT05"] = {
        id = "ALT05", name = "Syndicate Wizard", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 2, toughness = 4, isMob = true, isBoss = true, displayId = 3712,
        zone = "Alterac Mountains", creatureType = "Humanoid", faction = "Syndicate", npcId = 2319,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ALT06"] = {
        id = "ALT06", name = "Crushridge Ogre", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 2, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 11567,
        zone = "Alterac Mountains", creatureType = "Humanoid", faction = "Ogre", npcId = 2252,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["ALT07"] = {
        id = "ALT07", name = "Crushridge Brute", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 4, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 610,
        zone = "Alterac Mountains", creatureType = "Humanoid", faction = "Ogre", npcId = 2253,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["ALT08"] = {
        id = "ALT08", name = "Syndicate Assassin", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 5, toughness = 5, firstStrike = true, isMob = true, isBoss = true, displayId = 3727,
        zone = "Alterac Mountains", creatureType = "Humanoid", faction = "Syndicate", npcId = 2246,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["ALT09"] = {
        id = "ALT09", name = "Crushridge Mage", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 6, toughness = 8, isMob = true, isBoss = true, displayId = 6705,
        zone = "Alterac Mountains", creatureType = "Humanoid", faction = "Ogre", npcId = 2255,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ALT10"] = {
        id = "ALT10", name = "Crushridge Warmonger", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 9, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 536,
        zone = "Alterac Mountains", creatureType = "Humanoid", faction = "Ogre", npcId = 2287,
        modelCam = { zoom = 0.73, camScale = 1.08, z = -0.12, rotation = 0.15 },
        text = "Brutish."
    },
    -- Solo reward
    ["ALT11"] = {
        id = "ALT11", name = "Archmage Ansirem Runeweaver", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 3, toughness = 5, isReward = true, displayId = 1595,
        zone = "Alterac Mountains", creatureType = "Humanoid", npcEntry = 2543,
        anthem = { tag = "zone", value = "Alterac Mountains", t = 2 },
        etb = { ops = { { op = "tap", to = "enemy_creatures" } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "When Archmage Ansirem Runeweaver enters the battlefield, Exhaust each enemy denizen. Other Alterac Mountains denizens you control get +0/+2."
    },
})
