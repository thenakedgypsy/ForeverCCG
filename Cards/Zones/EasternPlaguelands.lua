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
    -- EASTERN PLAGUELANDS
    ["EPL01"] = {
        id = "EPL01", name = "Plaguehound Runt", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 2, toughness = 1, isMob = true, isBoss = true, displayId = 7890,
        zone = "Eastern Plaguelands", creatureType = "Demon", npcId = 8596,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["EPL02"] = {
        id = "EPL02", name = "Carrion Grub", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 7898,
        zone = "Eastern Plaguelands", creatureType = "Beast", npcId = 8603,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["EPL03"] = {
        id = "EPL03", name = "Cannibal Ghoul", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 10626,
        zone = "Eastern Plaguelands", creatureType = "Undead", npcId = 8530,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["EPL04"] = {
        id = "EPL04", name = "Noxious Plaguebat", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 1, flying = true, isMob = true, isBoss = true, displayId = 7896,
        zone = "Eastern Plaguelands", creatureType = "Beast", npcId = 8601,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["EPL05"] = {
        id = "EPL05", name = "Putrid Gargoyle", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 2, flying = true, isMob = true, isBoss = true, displayId = 7854,
        zone = "Eastern Plaguelands", creatureType = "Undead", npcId = 8534,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["EPL06"] = {
        id = "EPL06", name = "Carrion Devourer", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 7900,
        zone = "Eastern Plaguelands", creatureType = "Beast", npcId = 8605,
        modelCam = { zoom = 0.66, camScale = 1.13, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["EPL07"] = {
        id = "EPL07", name = "Monstrous Plaguebat", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 2, toughness = 3, flying = true, lifelink = true, isMob = true, isBoss = true, displayId = 7897,
        zone = "Eastern Plaguelands", creatureType = "Beast", npcId = 8602,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne, Drain."
    },
    ["EPL08"] = {
        id = "EPL08", name = "Frenzied Plaguehound", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 5, toughness = 5, haste = true, isMob = true, isBoss = true, displayId = 9022,
        zone = "Eastern Plaguelands", creatureType = "Demon", npcId = 8598,
        modelCam = { zoom = 0.74, camScale = 1.08, z = -0.12, rotation = 0.15 },
        text = "Quick."
    },
    ["EPL09"] = {
        id = "EPL09", name = "Stitched Horror", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 5, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 1693,
        zone = "Eastern Plaguelands", creatureType = "Undead", npcId = 8543,
        modelCam = { zoom = 0.80, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = "Brutish."
    },
    ["EPL10"] = {
        id = "EPL10", name = "Nerubian Overseer", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 9, toughness = 10, vigilance = true, isMob = true, isBoss = true, displayId = 14698,
        zone = "Eastern Plaguelands", creatureType = "Undead", npcId = 16184,
        modelCam = { zoom = 0.75, camScale = 1.07, z = -0.11, rotation = 0.15 },
        text = "Vigilant."
    },
    -- Solo reward
    ["EPL11"] = {
        id = "EPL11", name = "Duke Nicholas Zverenhoff", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 4, toughness = 5, vigilance = true, isReward = true, displayId = 10468,
        zone = "Eastern Plaguelands", creatureType = "Humanoid", npcEntry = 11039,
        etb = { ops = { { op = "damage", to = "enemy_creatures", n = 3, filter = { tag = "type", value = "Undead" } } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant. When Duke Nicholas Zverenhoff enters the battlefield, deal 3 damage to each enemy Undead."
    },
})
