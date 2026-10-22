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
    -- AZSHARA
    ["AZS01"] = {
        id = "AZS01", name = "Highborne Apparition", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 1, unblockable = true, isMob = true, isBoss = true, displayId = 10702,
        zone = "Azshara", creatureType = "Undead", npcId = 6116,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Invisible."
    },
    ["AZS02"] = {
        id = "AZS02", name = "Mosshoof Runner", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 8013,
        zone = "Azshara", creatureType = "Beast", npcId = 8759,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["AZS03"] = {
        id = "AZS03", name = "Spitelash Warrior", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 6747,
        zone = "Azshara", creatureType = "Humanoid", faction = "Naga", npcId = 6190,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["AZS04"] = {
        id = "AZS04", name = "Timbermaw Shaman", cost = "{1}{W}", cmc = 2, color = "W", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 2000,
        zone = "Azshara", creatureType = "Humanoid", faction = "Furbolg", npcId = 6188,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["AZS05"] = {
        id = "AZS05", name = "Thunderhead Skystormer", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 2, toughness = 2, flying = true, isMob = true, isBoss = true, displayId = 10893,
        zone = "Azshara", creatureType = "Beast", npcId = 6378,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["AZS06"] = {
        id = "AZS06", name = "Spitelash Myrmidon", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 11265,
        zone = "Azshara", creatureType = "Humanoid", faction = "Naga", npcId = 6196,
        modelCam = { zoom = 0.73, camScale = 1.08, z = -0.12, rotation = 0.15 },
        text = ""
    },
    ["AZS07"] = {
        id = "AZS07", name = "Mosshoof Courser", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 3, toughness = 4, haste = true, isMob = true, isBoss = true, displayId = 10957,
        zone = "Azshara", creatureType = "Beast", npcId = 8761,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["AZS08"] = {
        id = "AZS08", name = "Legashi Rogue", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 5, toughness = 5, firstStrike = true, isMob = true, isBoss = true, displayId = 6743,
        zone = "Azshara", creatureType = "Demon", faction = "Satyr", npcId = 6201,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["AZS09"] = {
        id = "AZS09", name = "Coralshell Lurker", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 4, toughness = 8, support = true, isMob = true, isBoss = true, displayId = 10947,
        zone = "Azshara", creatureType = "Beast", npcId = 6352,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["AZS10"] = {
        id = "AZS10", name = "Monnos the Elder", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 10, toughness = 9, trample = true, isMob = true, isNamed = true, isBoss = true, displayId = 10042,
        zone = "Azshara", creatureType = "Giant", npcId = 6646,
        modelCam = { zoom = 0.64, camScale = 1.15, z = -0.13, rotation = 0.15 },
        text = "Brutish."
    },
    -- Solo reward
    ["AZS11"] = {
        id = "AZS11", name = "Kim'jael", cost = "{3}{R}", cmc = 4, color = "R", type = "Creature",
        power = 2, toughness = 3, isReward = true, displayId = 7670,
        zone = "Azshara", creatureType = "Humanoid", npcEntry = 8420,
        rally = { tag = "zone", value = "Azshara", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Gets +1/+1 for each other Azshara denizen you control."
    },
})
