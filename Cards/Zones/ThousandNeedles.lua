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
    -- THOUSAND NEEDLES
    ["THO01"] = {
        id = "THO01", name = "Savannah Matriarch", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 1058,
        zone = "Thousand Needles", creatureType = "Beast", npcId = 3416,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["THO02"] = {
        id = "THO02", name = "Galak Windchaser", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 9412,
        zone = "Thousand Needles", creatureType = "Humanoid", npcId = 4096,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["THO03"] = {
        id = "THO03", name = "Galak Wrangler", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 9414,
        zone = "Thousand Needles", creatureType = "Humanoid", npcId = 4093,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["THO04"] = {
        id = "THO04", name = "Pesterhide Hyena", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 2713,
        zone = "Thousand Needles", creatureType = "Beast", npcId = 4248,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["THO05"] = {
        id = "THO05", name = "Needles Cougar", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 1056,
        zone = "Thousand Needles", creatureType = "Beast", npcId = 4124,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["THO06"] = {
        id = "THO06", name = "Pesterhide Snarler", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 10903,
        zone = "Thousand Needles", creatureType = "Beast", npcId = 4249,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["THO07"] = {
        id = "THO07", name = "Screeching Roguefeather", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 3, toughness = 4, firstStrike = true, isMob = true, isBoss = true, displayId = 1350,
        zone = "Thousand Needles", creatureType = "Humanoid", npcId = 4101,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["THO08"] = {
        id = "THO08", name = "Sparkleshell Borer", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 3, toughness = 7, isMob = true, isBoss = true, displayId = 2307,
        zone = "Thousand Needles", creatureType = "Beast", npcId = 4144,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["THO09"] = {
        id = "THO09", name = "Scorpid Terror", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 4, toughness = 6, deathtouch = true, isMob = true, isBoss = true, displayId = 2491,
        zone = "Thousand Needles", creatureType = "Beast", npcId = 4139,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["THO10"] = {
        id = "THO10", name = "Vile Sting", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 8, toughness = 10, deathtouch = true, isMob = true, isBoss = true, displayId = 10988,
        zone = "Thousand Needles", creatureType = "Beast", npcId = 5937,
        modelCam = { zoom = 0.63, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Fatal."
    },
    -- Solo reward
    ["THO11"] = {
        id = "THO11", name = "Pozzik", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 2, haste = true, isReward = true, displayId = 7199,
        zone = "Thousand Needles", creatureType = "Humanoid", npcEntry = 4630,
        anthem = { tag = "zone", value = "Thousand Needles", p = 1, kw = { "haste" } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick. Other Thousand Needles creatures you control get +1/+0 and Quick."
    },
})
