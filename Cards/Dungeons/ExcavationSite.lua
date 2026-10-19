--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- DUNGEON CREATURES & BOSSES - UNLOCKED BY KILLING THEM (same isMob/isBoss tracking as zone creatures)
-- WoW Forever dungeon: names / displayIds / npcId come from Wowhead (Forever) and match the
-- client's creature cache. The final boss keeps its dedicated BOSSxx card (Cards\Bosses.lua).
-- =========================================================================
TTS:AddCards({
    -- EXCAVATION SITE (WETLANDS)
    ["EXC01"] = {
        id = "EXC01", name = "Young Riptooth", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 1959,
        zone = "Excavation Site", creatureType = "Beast", npcId = 260799,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["EXC02"] = {
        id = "EXC02", name = "Highland Spider", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 3, reach = true, isMob = true, isBoss = true, displayId = 1088,
        zone = "Excavation Site", creatureType = "Beast", npcId = 260803,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["EXC03"] = {
        id = "EXC03", name = "Dragonmaw Saboteur", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 4916,
        zone = "Excavation Site", creatureType = "Humanoid", faction = "Blackrock", npcId = 275045,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["EXC04"] = {
        id = "EXC04", name = "Marsh Crocolisk", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 4, isMob = true, isBoss = true, displayId = 1035,
        zone = "Excavation Site", creatureType = "Beast", npcId = 260796,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["EXC05"] = {
        id = "EXC05", name = "Highland Lurker", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 3, unblockable = true, isMob = true, isBoss = true, displayId = 545,
        zone = "Excavation Site", creatureType = "Beast", npcId = 260804,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Invisible."
    },
    ["EXC06"] = {
        id = "EXC06", name = "Dragonmaw Warder", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 5, support = true, isMob = true, isBoss = true, displayId = 4916,
        zone = "Excavation Site", creatureType = "Humanoid", faction = "Blackrock", npcId = 275044,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["EXC07"] = {
        id = "EXC07", name = "Thicket Stalker", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 4, toughness = 2, firstStrike = true, isMob = true, isBoss = true, displayId = 1339,
        zone = "Excavation Site", creatureType = "Beast", npcId = 271732,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["EXC08"] = {
        id = "EXC08", name = "Highland Snapper", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 7114,
        zone = "Excavation Site", creatureType = "Beast", npcId = 260810,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["EXC09"] = {
        id = "EXC09", name = "Thicket Hunter", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 4, toughness = 4, deathtouch = true, isMob = true, isBoss = true, displayId = 11316,
        zone = "Excavation Site", creatureType = "Beast", npcId = 260801,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["EXC10"] = {
        id = "EXC10", name = "Elder Crocolisk", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 5, toughness = 6, isMob = true, isBoss = true, displayId = 1038,
        zone = "Excavation Site", creatureType = "Beast", npcId = 260797,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["EXC11"] = {
        id = "EXC11", name = "Highland Horror", cost = "{3}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 6, lifelink = true, isMob = true, isBoss = true, displayId = 9010,
        zone = "Excavation Site", creatureType = "Elemental", npcId = 260808,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["EXC12"] = {
        id = "EXC12", name = "Dragonmaw Thaumaturgist", cost = "{3}{R}", cmc = 4, color = "R", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 4918,
        zone = "Excavation Site", creatureType = "Humanoid", faction = "Blackrock", npcId = 275046,
        anthem = { tag = "faction", value = "Blackrock", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Blackrock you control get +1/+1."
    },
    ["EXC13"] = {
        id = "EXC13", name = "Captive Fire Elemental", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 1070,
        zone = "Excavation Site", creatureType = "Elemental", npcId = 275049,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["EXC14"] = {
        id = "EXC14", name = "Thicket Matriarch", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 11315,
        zone = "Excavation Site", creatureType = "Beast", npcId = 260802,
        rally = { tag = "type", value = "Beast", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Gets +1/+1 for each other Beast you control."
    },
    ["EXC15"] = {
        id = "EXC15", name = "Saltspine", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 5, toughness = 7, hexproof = true, isMob = true, isBoss = true, displayId = 144209,
        zone = "Excavation Site", creatureType = "Beast", npcId = 260322,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Warded."
    },
    ["EXC16"] = {
        id = "EXC16", name = "Shadetooth", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 6, toughness = 6, haste = true, isMob = true, isBoss = true, displayId = 144210,
        zone = "Excavation Site", creatureType = "Beast", npcId = 260325,
        anthem = { tag = "type", value = "Beast", kw = { "haste" } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick. Other Beasts you control have Quick."
    },
    -- Solo reward
    ["EXC17"] = {
        id = "EXC17", name = "Deathstalker Agent", cost = "{3}{B}", cmc = 4, color = "B", type = "Creature",
        power = 4, toughness = 3, unblockable = true, isReward = true, displayId = 2863,
        zone = "Excavation Site", creatureType = "Humanoid", npcEntry = 13155,
        anthem = { tag = "zone", value = "Excavation Site", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Invisible. Other Excavation Site denizens you control get +1/+1."
    },
})
