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
    -- RAZORFEN KRAUL
    ["RFK01"] = {
        id = "RFK01", name = "Razorfen Warrior", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 6109,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar", npcId = 4435,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["RFK02"] = {
        id = "RFK02", name = "Razorfen Quilguard", cost = "{1}{W}", cmc = 2, color = "W", type = "Creature",
        power = 2, toughness = 4, vigilance = true, isMob = true, isBoss = true, displayId = 6108,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar", npcId = 4436,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant."
    },
    ["RFK03"] = {
        id = "RFK03", name = "Razorfen Geomancer", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 4647,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar", npcId = 4520,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["RFK04"] = {
        id = "RFK04", name = "Kraul Bat", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 3, flying = true, isMob = true, isBoss = true, displayId = 1955,
        zone = "Razorfen Kraul", creatureType = "Beast", npcId = 4538,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["RFK05"] = {
        id = "RFK05", name = "Death's Head Priest", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 6096,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar", npcId = 4517,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["RFK06"] = {
        id = "RFK06", name = "Blind Hunter", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 5, toughness = 5, flying = true, isMob = true, isBoss = true, displayId = 4735,
        zone = "Razorfen Kraul", creatureType = "Beast", npcId = 4425,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["RFK07"] = {
        id = "RFK07", name = "Roogug", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 6, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 6110,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar", npcId = 6168,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["RFK08"] = {
        id = "RFK08", name = "Aggem Thorncurse", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 5, toughness = 7, lifelink = true, isMob = true, isBoss = true, displayId = 6097,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar", npcId = 4424,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["RFK09"] = {
        id = "RFK09", name = "Death Speaker Jargba", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 7, deathtouch = true, isMob = true, isBoss = true, displayId = 4644,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar", npcId = 4428,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["RFK10"] = {
        id = "RFK10", name = "Earthcaller Halmgar", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 7, toughness = 8, vigilance = true, isMob = true, isBoss = true, displayId = 6102,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar", npcId = 4842,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant."
    },
    ["RFK11"] = {
        id = "RFK11", name = "Overlord Ramtusk", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 4652,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar", npcId = 4420,
        anthem = { tag = "faction", value = "Quilboar", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish. Other Quilboar you control get +1/+1."
    },
    ["RFK12"] = {
        id = "RFK12", name = "Agathelos the Raging", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 7, toughness = 7, haste = true, trample = true, isMob = true, isBoss = true, displayId = 2450,
        zone = "Razorfen Kraul", creatureType = "Beast", npcId = 4422,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Quick, Brutish."
    },
    -- Solo reward
    ["RFK13"] = {
        id = "RFK13", name = "Razorfen Totemic", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 3, isReward = true, displayId = 6112,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar", npcEntry = 4440,
        anthem = { tag = "faction", value = "Quilboar", p = 1, t = 1 },
        etb = { ops = { { op = "shield", to = "self_player", n = 3 } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "When Razorfen Totemic enters the battlefield, prevent the next 3 damage that would be dealt to you. Other Quilboar you control get +1/+1."
    },
})
