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
    -- GNOMEREGAN
    ["GNO01"] = {
        id = "GNO01", name = "Caverndeep Burrower", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 830,
        zone = "Gnomeregan", creatureType = "Humanoid", npcId = 6206,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["GNO02"] = {
        id = "GNO02", name = "Leprous Defender", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 5, support = true, isMob = true, isBoss = true, displayId = 6982,
        zone = "Gnomeregan", creatureType = "Humanoid", npcId = 6223,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["GNO03"] = {
        id = "GNO03", name = "Mechano-Flamewalker", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 6890,
        zone = "Gnomeregan", creatureType = "Mechanical", npcId = 6226,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["GNO04"] = {
        id = "GNO04", name = "Mechano-Frostwalker", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 5, isMob = true, isBoss = true, displayId = 6891,
        zone = "Gnomeregan", creatureType = "Mechanical", npcId = 6227,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["GNO05"] = {
        id = "GNO05", name = "Viscous Fallout", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 4, deathtouch = true, isMob = true, isBoss = true, displayId = 5497,
        zone = "Gnomeregan", creatureType = "Elemental", npcId = 7079,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["GNO06"] = {
        id = "GNO06", name = "Dark Iron Ambassador", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 6669,
        zone = "Gnomeregan", creatureType = "Humanoid", faction = "Dark Iron", npcId = 6228,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["GNO07"] = {
        id = "GNO07", name = "Electrocutioner 6000", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 6, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 6915,
        zone = "Gnomeregan", creatureType = "Mechanical", npcId = 6235,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["GNO08"] = {
        id = "GNO08", name = "Crowd Pummeler 9-60", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 6, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 6774,
        zone = "Gnomeregan", creatureType = "Mechanical", npcId = 6229,
        anthem = { tag = "type", value = "Mechanical", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Brutish. Other Mechanicals you control get +1/+1."
    },
    -- Solo reward
    ["GNO09"] = {
        id = "GNO09", name = "Grubbis", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 5, toughness = 4, trample = true, isReward = true, displayId = 6533,
        zone = "Gnomeregan", creatureType = "Humanoid", npcEntry = 7361,
        anthem = { tag = "zone", value = "Gnomeregan", p = 1, kw = { "trample" } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish. Other Gnomeregan denizens you control get +1/+0 and Brutish."
    },
})
