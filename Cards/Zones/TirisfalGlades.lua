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
    -- TIRISFAL GLADES
    ["TIR01"] = {
        id = "TIR01", name = "Mindless Zombie", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 10973,
        zone = "Tirisfal Glades", creatureType = "Undead", npcId = 1501,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TIR02"] = {
        id = "TIR02", name = "Wretched Zombie", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 10979,
        zone = "Tirisfal Glades", creatureType = "Undead", npcId = 1502,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TIR03"] = {
        id = "TIR03", name = "Young Night Web Spider", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 513,
        zone = "Tirisfal Glades", creatureType = "Beast", npcId = 1504,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["TIR04"] = {
        id = "TIR04", name = "Decrepit Darkhound", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 9021,
        zone = "Tirisfal Glades", creatureType = "Demon", npcId = 1547,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TIR05"] = {
        id = "TIR05", name = "Rotting Dead", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 1200,
        zone = "Tirisfal Glades", creatureType = "Undead", npcId = 1525,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TIR06"] = {
        id = "TIR06", name = "Greater Duskbat", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 2, flying = true, lifelink = true, isMob = true, isBoss = true, displayId = 4734,
        zone = "Tirisfal Glades", creatureType = "Beast", npcId = 1553,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne, Drain."
    },
    ["TIR07"] = {
        id = "TIR07", name = "Vile Fin Minor Oracle", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 3, toughness = 5, isMob = true, isBoss = true, displayId = 1005,
        zone = "Tirisfal Glades", creatureType = "Humanoid", faction = "Murloc", npcId = 1544,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TIR08"] = {
        id = "TIR08", name = "Vile Fin Muckdweller", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 346,
        zone = "Tirisfal Glades", creatureType = "Humanoid", faction = "Murloc", npcId = 1545,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        onDeath = { ops = { { op = "token", id = "TOK01", n = 2 } } },
        text = "When Vile Fin Muckdweller dies, create two 1/1 Murloc Tadpole tokens."
    },
    ["TIR09"] = {
        id = "TIR09", name = "Scarlet Vanguard", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 5, toughness = 6, support = true, vigilance = true, isMob = true, isBoss = true, displayId = 2481,
        zone = "Tirisfal Glades", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 1540,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant, Support."
    },
    ["TIR10"] = {
        id = "TIR10", name = "Fellicent's Shade", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 7, toughness = 9, isMob = true, isBoss = true, displayId = 5430,
        zone = "Tirisfal Glades", creatureType = "Undead", npcId = 10358,
        anthem = { tag = "type", value = "Undead", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Undead you control get +1/+0."
    },
    -- Solo reward
    ["TIR11"] = {
        id = "TIR11", name = "Executor Zygand", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 2, isReward = true, displayId = 1649,
        zone = "Tirisfal Glades", creatureType = "Undead", npcEntry = 1515,
        anthem = { tag = "type", value = "Undead", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Undead you control get +1/+1."
    },
})
