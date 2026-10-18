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
    -- DESOLACE
    ["DES01"] = {
        id = "DES01", name = "Burning Blade Augur", cost = "{W}", cmc = 1, color = "W", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 4699,
        zone = "Desolace", creatureType = "Humanoid", faction = "Burning Blade", npcId = 4663,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DES02"] = {
        id = "DES02", name = "Scorpashi Snapper", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 1, reach = true, isMob = true, isBoss = true, displayId = 2729,
        zone = "Desolace", creatureType = "Beast", npcId = 4696,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["DES03"] = {
        id = "DES03", name = "Burning Blade Reaver", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 1, firstStrike = true, isMob = true, isBoss = true, displayId = 4703,
        zone = "Desolace", creatureType = "Humanoid", faction = "Burning Blade", npcId = 4664,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["DES04"] = {
        id = "DES04", name = "Gritjaw Basilisk", cost = "{1}{W}", cmc = 2, color = "W", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 1074,
        zone = "Desolace", creatureType = "Beast", npcId = 4728,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DES05"] = {
        id = "DES05", name = "Dread Swoop", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 2, flying = true, haste = true, isMob = true, isBoss = true, displayId = 1192,
        zone = "Desolace", creatureType = "Beast", npcId = 4692,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne. Quick."
    },
    ["DES06"] = {
        id = "DES06", name = "Raging Thunder Lizard", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 2, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 2742,
        zone = "Desolace", creatureType = "Beast", npcId = 4726,
        modelCam = { zoom = 0.82, camScale = 1.02, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["DES07"] = {
        id = "DES07", name = "Dread Flyer", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 3, flying = true, isMob = true, isBoss = true, displayId = 10273,
        zone = "Desolace", creatureType = "Beast", npcId = 4693,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["DES08"] = {
        id = "DES08", name = "Undead Ravager", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 4, toughness = 6, lifelink = true, isMob = true, isBoss = true, displayId = 11369,
        zone = "Desolace", creatureType = "Undead", npcId = 11561,
        modelCam = { zoom = 0.68, camScale = 1.12, z = -0.12, rotation = 0.15 },
        text = "Drain."
    },
    ["DES09"] = {
        id = "DES09", name = "Elder Thunder Lizard", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 7, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 2764,
        zone = "Desolace", creatureType = "Beast", npcId = 4727,
        modelCam = { zoom = 0.78, camScale = 1.05, z = -0.11, rotation = 0.15 },
        text = "Brutish."
    },
    ["DES10"] = {
        id = "DES10", name = "Kaskk", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 9, toughness = 9, deathtouch = true, isMob = true, isBoss = true, displayId = 14255,
        zone = "Desolace", creatureType = "Demon", npcId = 14226,
        modelCam = { zoom = 0.78, camScale = 1.05, z = -0.11, rotation = 0.15 },
        text = "Fatal."
    },
    -- Solo reward
    ["DES11"] = {
        id = "DES11", name = "Uthek the Wise", cost = "{3}{B}", cmc = 4, color = "B", type = "Creature",
        power = 2, toughness = 4, isReward = true, displayId = 4875,
        zone = "Desolace", creatureType = "Humanoid", npcEntry = 5397,
        anthem = { tag = "zone", value = "Desolace", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Desolace denizens you control get +1/+1."
    },
})
