--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- DUNGEON CREATURES & BOSSES - UNLOCKED BY KILLING THEM (same isMob/isBoss tracking as zone creatures)
-- Names / displayIds / npcId come from the classicdb creature_template table; all are dungeon elites.
-- Final dungeon bosses keep their dedicated BOSSxx cards below.
-- =========================================================================
TTS:AddCards({
    -- ULDAMAN
    ["ULD01"] = {
        id = "ULD01", name = "Stonevault Rockchewer", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 721,
        zone = "Uldaman", creatureType = "Humanoid", npcId = 4851,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ULD02"] = {
        id = "ULD02", name = "Shadowforge Relic Hunter", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 4, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 6054,
        zone = "Uldaman", creatureType = "Humanoid", faction = "Dark Iron", npcId = 4847,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["ULD03"] = {
        id = "ULD03", name = "Jadespine Basilisk", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 5, isMob = true, isBoss = true, displayId = 4486,
        zone = "Uldaman", creatureType = "Beast", npcId = 4863,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ULD04"] = {
        id = "ULD04", name = "Venomlash Scorpid", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 4, deathtouch = true, isMob = true, isBoss = true, displayId = 2488,
        zone = "Uldaman", creatureType = "Beast", npcId = 7022,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["ULD05"] = {
        id = "ULD05", name = "Eric \"The Swift\"", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 4, haste = true, isMob = true, isBoss = true, displayId = 5708,
        zone = "Uldaman", creatureType = "Humanoid", npcId = 6907,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["ULD06"] = {
        id = "ULD06", name = "Baelog", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 5, toughness = 6, vigilance = true, isMob = true, isBoss = true, displayId = 5710,
        zone = "Uldaman", creatureType = "Humanoid", npcId = 6906,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["ULD07"] = {
        id = "ULD07", name = "Olaf", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 4, toughness = 8, vigilance = true, isMob = true, isBoss = true, displayId = 5709,
        zone = "Uldaman", creatureType = "Humanoid", npcId = 6908,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["ULD08"] = {
        id = "ULD08", name = "Revelosh", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 5945,
        zone = "Uldaman", creatureType = "Humanoid", npcId = 6910,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ULD09"] = {
        id = "ULD09", name = "Obsidian Sentinel", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 4, toughness = 9, defender = true, isMob = true, isBoss = true, displayId = 5285,
        zone = "Uldaman", creatureType = "Mechanical", npcId = 7023,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Defender."
    },
    ["ULD10"] = {
        id = "ULD10", name = "Galgann Firehammer", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 7, firstStrike = true, isMob = true, isBoss = true, displayId = 6059,
        zone = "Uldaman", creatureType = "Humanoid", faction = "Dark Iron", npcId = 7291,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["ULD11"] = {
        id = "ULD11", name = "Grimlok", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 8, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 11165,
        zone = "Uldaman", creatureType = "Humanoid", npcId = 4854,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["ULD12"] = {
        id = "ULD12", name = "Ancient Stone Keeper", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 7, toughness = 9, vigilance = true, isMob = true, isBoss = true, displayId = 10798,
        zone = "Uldaman", creatureType = "Elemental", npcId = 7206,
        anthem = { tag = "zone", value = "Uldaman", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Vigilance. Other Uldaman creatures you control get +1/+1."
    },
    -- Solo reward
    ["ULD13"] = {
        id = "ULD13", name = "Ironaya", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 6, toughness = 8, vigilance = true, isReward = true, displayId = 6089,
        zone = "Uldaman", creatureType = "Giant", npcEntry = 7228,
        anthem = { tag = "zone", value = "Uldaman", t = 2 },
        etb = { ops = { { op = "damage", to = "enemy_creatures", n = 2 } } },
        modelCam = { zoom = 0.55, camScale = 1.30, z = -0.20, rotation = 0.15 },
        text = "Vigilance. When Ironaya enters the battlefield, deal 2 damage to each enemy creature. Other Uldaman creatures you control get +0/+2."
    },
})
