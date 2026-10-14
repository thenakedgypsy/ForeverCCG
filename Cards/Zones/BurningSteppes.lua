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
    -- BURNING STEPPES
    ["BUR01"] = {
        id = "BUR01", name = "Dustbelcher Mauler", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 2, toughness = 1, isMob = true, isBoss = true, displayId = 1120,
        zone = "Burning Steppes", creatureType = "Humanoid", faction = "Ogre", npcId = 2717,
        modelCam = { zoom = 0.70, camScale = 1.10, z = -0.12, rotation = 0.15 },
        text = ""
    },
    ["BUR02"] = {
        id = "BUR02", name = "Firegut Ogre", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 11549,
        zone = "Burning Steppes", creatureType = "Humanoid", faction = "Ogre", npcId = 7033,
        modelCam = { zoom = 0.64, camScale = 1.15, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["BUR03"] = {
        id = "BUR03", name = "Flamekin Sprite", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 10816,
        zone = "Burning Steppes", creatureType = "Demon", npcId = 9777,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BUR04"] = {
        id = "BUR04", name = "Black Broodling", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 397,
        zone = "Burning Steppes", creatureType = "Dragonkin", npcId = 7047,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BUR05"] = {
        id = "BUR05", name = "Ember Worg", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 9371,
        zone = "Burning Steppes", creatureType = "Beast", npcId = 9690,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["BUR06"] = {
        id = "BUR06", name = "Flamekin Spitter", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 10815,
        zone = "Burning Steppes", creatureType = "Demon", npcId = 9776,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BUR07"] = {
        id = "BUR07", name = "Venomtip Scorpid", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 3, deathtouch = true, isMob = true, isBoss = true, displayId = 8970,
        zone = "Burning Steppes", creatureType = "Beast", npcId = 9691,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["BUR08"] = {
        id = "BUR08", name = "Firegut Brute", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 5, toughness = 4, trample = true, isMob = true, isBoss = true, displayId = 10707,
        zone = "Burning Steppes", creatureType = "Humanoid", faction = "Ogre", npcId = 7035,
        modelCam = { zoom = 0.61, camScale = 1.17, z = -0.13, rotation = 0.15 },
        text = "Trample."
    },
    ["BUR09"] = {
        id = "BUR09", name = "War Reaver", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 5, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 10806,
        zone = "Burning Steppes", creatureType = "Elemental", npcId = 7039,
        modelCam = { zoom = 0.73, camScale = 1.08, z = -0.12, rotation = 0.15 },
        text = "First Strike."
    },
    ["BUR10"] = {
        id = "BUR10", name = "Volchan", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 10, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 12232,
        zone = "Burning Steppes", creatureType = "Giant", npcId = 10119,
        modelCam = { zoom = 0.54, camScale = 1.22, z = -0.14, rotation = 0.15 },
        text = "Trample."
    },
    -- Solo reward
    ["BUR11"] = {
        id = "BUR11", name = "Marshal Maxwell", cost = "{4}{R}", cmc = 5, color = "R", type = "Creature",
        power = 4, toughness = 4, vigilance = true, isReward = true, displayId = 8685,
        zone = "Burning Steppes", creatureType = "Humanoid", npcEntry = 9560,
        anthem = { tag = "zone", value = "Burning Steppes", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance. Other Burning Steppes creatures you control get +1/+1."
    },
})
