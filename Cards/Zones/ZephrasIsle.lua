--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- ZONE CREATURES - UNLOCKED BY KILLING THEM (isBoss = true reuses BossTracker as-is)
-- WoW Forever zone: names / displayIds / npcId come from forever.warcraftdb.com (zone 2521).
-- Only hostile or neutral mobs; vendors, trainers, quest NPCs and faction-dependent NPCs left out.
-- =========================================================================
TTS:AddCards({
    -- ZEPHRAS ISLE
    ["ZEP01"] = {
        id = "ZEP01", name = "Cirrusfly Soldier", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 1, flying = true, isMob = true, isBoss = true, displayId = 136992,
        zone = "Zephras Isle", creatureType = "Beast", npcId = 251402,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["ZEP02"] = {
        id = "ZEP02", name = "Al'Aketh Convert", cost = "{W}", cmc = 1, color = "W", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 137690,
        zone = "Zephras Isle", creatureType = "Humanoid", faction = "Al'Aketh", npcId = 251160,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ZEP03"] = {
        id = "ZEP03", name = "Ursera Scavenger", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 136605,
        zone = "Zephras Isle", creatureType = "Beast", npcId = 250937,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ZEP04"] = {
        id = "ZEP04", name = "High Order Apprentice", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 1, toughness = 3, support = true, isMob = true, isBoss = true, displayId = 138113,
        zone = "Zephras Isle", creatureType = "Humanoid", faction = "High Order", npcId = 257521,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["ZEP05"] = {
        id = "ZEP05", name = "Cirrusfly Queen", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 2, toughness = 3, flying = true, isMob = true, isBoss = true, displayId = 136996,
        zone = "Zephras Isle", creatureType = "Beast", npcId = 251404,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["ZEP06"] = {
        id = "ZEP06", name = "Ornery Galestrider", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 144242,
        zone = "Zephras Isle", creatureType = "Beast", npcId = 251707,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["ZEP07"] = {
        id = "ZEP07", name = "Al'Aketh Assassin", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 2, deathtouch = true, isMob = true, isBoss = true, displayId = 138289,
        zone = "Zephras Isle", creatureType = "Humanoid", faction = "Al'Aketh", npcId = 254626,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["ZEP08"] = {
        id = "ZEP08", name = "Al'Aketh Stormcaller", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 3, toughness = 4, reach = true, isMob = true, isBoss = true, displayId = 143553,
        zone = "Zephras Isle", creatureType = "Humanoid", faction = "Al'Aketh", npcId = 252068,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["ZEP09"] = {
        id = "ZEP09", name = "Wind Hollow", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 3, toughness = 3, flying = true, isMob = true, isBoss = true, displayId = 137164,
        zone = "Zephras Isle", creatureType = "Elemental", npcId = 251676,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["ZEP10"] = {
        id = "ZEP10", name = "Al'Aketh Guardian", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 4, toughness = 5, vigilance = true, isMob = true, isBoss = true, displayId = 137755,
        zone = "Zephras Isle", creatureType = "Humanoid", faction = "Al'Aketh", npcId = 252762,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant."
    },
    ["ZEP11"] = {
        id = "ZEP11", name = "Malevolent Storm", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 5, toughness = 5, hexproof = true, isMob = true, isBoss = true, displayId = 139139,
        zone = "Zephras Isle", creatureType = "Elemental", npcId = 255830,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Warded."
    },
    ["ZEP12"] = {
        id = "ZEP12", name = "Elaadrin Evengale", cost = "{5}{U}{U}", cmc = 7, color = "U", type = "Creature",
        power = 8, toughness = 8, vigilance = true, isMob = true, isNamed = true, isBoss = true, displayId = 138152,
        zone = "Zephras Isle", creatureType = "Humanoid", faction = "High Order", npcId = 252475,
        anthem = { tag = "zone", value = "Zephras Isle", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant. Other Zephras Isle denizens you control get +1/+1."
    },
})
