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
    -- RAGEFIRE CHASM
    ["RFC01"] = {
        id = "RFC01", name = "Ragefire Trogg", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 11609,
        zone = "Ragefire Chasm", creatureType = "Humanoid", npcId = 11318,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["RFC02"] = {
        id = "RFC02", name = "Earthborer", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 3, toughness = 2, trample = true, isMob = true, isBoss = true, displayId = 11010,
        zone = "Ragefire Chasm", creatureType = "Beast", npcId = 11320,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["RFC03"] = {
        id = "RFC03", name = "Searing Blade Warlock", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 11438,
        zone = "Ragefire Chasm", creatureType = "Humanoid", faction = "Burning Blade", npcId = 11324,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["RFC04"] = {
        id = "RFC04", name = "Molten Elemental", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 2075,
        zone = "Ragefire Chasm", creatureType = "Elemental", npcId = 11321,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["RFC05"] = {
        id = "RFC05", name = "Oggleflint", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 4, firstStrike = true, isMob = true, isBoss = true, displayId = 11611,
        zone = "Ragefire Chasm", creatureType = "Humanoid", npcId = 11517,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["RFC06"] = {
        id = "RFC06", name = "Jergosh the Invoker", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 5, deathtouch = true, isMob = true, isBoss = true, displayId = 11429,
        zone = "Ragefire Chasm", creatureType = "Humanoid", faction = "Burning Blade", npcId = 11518,
        anthem = { tag = "faction", value = "Burning Blade", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch. Other Burning Blade you control get +1/+1."
    },
    ["RFC07"] = {
        id = "RFC07", name = "Taragaman the Hungerer", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 6, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 7970,
        zone = "Ragefire Chasm", creatureType = "Humanoid", faction = "Burning Blade", npcId = 11520,
        anthem = { tag = "zone", value = "Ragefire Chasm", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample. Other Ragefire Chasm creatures you control get +1/+1."
    },
})
