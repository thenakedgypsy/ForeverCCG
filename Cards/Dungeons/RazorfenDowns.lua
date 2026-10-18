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
    -- RAZORFEN DOWNS
    ["RFD01"] = {
        id = "RFD01", name = "Withered Warrior", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 11386,
        zone = "Razorfen Downs", creatureType = "Undead", npcId = 7327,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["RFD02"] = {
        id = "RFD02", name = "Skeletal Frostweaver", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 5, isMob = true, isBoss = true, displayId = 9783,
        zone = "Razorfen Downs", creatureType = "Undead", npcId = 7341,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["RFD03"] = {
        id = "RFD03", name = "Boneflayer Ghoul", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 4, toughness = 3, haste = true, isMob = true, isBoss = true, displayId = 1065,
        zone = "Razorfen Downs", creatureType = "Undead", npcId = 7347,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["RFD04"] = {
        id = "RFD04", name = "Death's Head Necromancer", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 11381,
        zone = "Razorfen Downs", creatureType = "Humanoid", faction = "Quilboar", npcId = 7337,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["RFD05"] = {
        id = "RFD05", name = "Mordresh Fire Eye", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 8055,
        zone = "Razorfen Downs", creatureType = "Undead", faction = "Quilboar", npcId = 7357,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["RFD06"] = {
        id = "RFD06", name = "Glutton", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 9, lifelink = true, isMob = true, isBoss = true, displayId = 7864,
        zone = "Razorfen Downs", creatureType = "Undead", faction = "Quilboar", npcId = 8567,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Drain."
    },
    ["RFD07"] = {
        id = "RFD07", name = "Ragglesnout", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 8, trample = true, isMob = true, isBoss = true, displayId = 11382,
        zone = "Razorfen Downs", creatureType = "Humanoid", faction = "Quilboar", npcId = 7354,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    -- Solo reward
    ["RFD08"] = {
        id = "RFD08", name = "Tuten'kash", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 4, toughness = 6, reach = true, deathtouch = true, isReward = true, displayId = 7845,
        zone = "Razorfen Downs", creatureType = "Undead", npcEntry = 7355,
        anthem = { tag = "zone", value = "Razorfen Downs", p = 1, t = 1 },
        modelCam = { zoom = 0.70, camScale = 1.15, z = -0.18, rotation = 0.15 },
        text = "Anti-Air. Fatal. Other Razorfen Downs denizens you control get +1/+1."
    },
})
