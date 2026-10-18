--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- DUNGEON CREATURES & BOSSES - UNLOCKED BY KILLING THEM (same isMob/isBoss tracking as zone creatures)
-- WoW Forever dungeon: names / displayIds / npcId come from Wowhead (Forever) and match the
-- client's creature cache. The final boss keeps its dedicated BOSSxx card (Cards\Bosses.lua).
-- =========================================================================
TTS:AddCards({
    -- THE HALL OF THANES
    ["HOT01"] = {
        id = "HOT01", name = "Bloodhound Runt", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 8180,
        zone = "The Hall of Thanes", creatureType = "Beast", faction = "Dark Iron", npcId = 263470,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["HOT02"] = {
        id = "HOT02", name = "Fiery Assistant", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 2, isMob = true, isBoss = true, displayId = 1070,
        zone = "The Hall of Thanes", creatureType = "Elemental", npcId = 263467,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HOT03"] = {
        id = "HOT03", name = "Dark Iron Looter", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 3452,
        zone = "The Hall of Thanes", creatureType = "Humanoid", faction = "Dark Iron", npcId = 263396,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["HOT04"] = {
        id = "HOT04", name = "Enraged Apparition", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 3, unblockable = true, isMob = true, isBoss = true, displayId = 143689,
        zone = "The Hall of Thanes", creatureType = "Undead", npcId = 263389,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Invisible."
    },
    ["HOT05"] = {
        id = "HOT05", name = "Tormented Soul", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 4, vigilance = true, isMob = true, isBoss = true, displayId = 143690,
        zone = "The Hall of Thanes", creatureType = "Undead", npcId = 263390,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant."
    },
    ["HOT06"] = {
        id = "HOT06", name = "Dark Iron Engineer", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 3954,
        zone = "The Hall of Thanes", creatureType = "Humanoid", faction = "Dark Iron", npcId = 263397,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["HOT07"] = {
        id = "HOT07", name = "Dark Iron Summoner", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 4, isMob = true, isBoss = true, displayId = 143713,
        zone = "The Hall of Thanes", creatureType = "Humanoid", faction = "Dark Iron", npcId = 263438,
        anthem = { tag = "type", value = "Elemental", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Elementals you control get +1/+0."
    },
    ["HOT08"] = {
        id = "HOT08", name = "Lesser Stone Golem", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 5, toughness = 4, haste = true, isMob = true, isBoss = true, displayId = 2693,
        zone = "The Hall of Thanes", creatureType = "Elemental", npcId = 263466,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["HOT09"] = {
        id = "HOT09", name = "Faldrim Anvilmar", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 4, toughness = 5, deathtouch = true, isMob = true, isBoss = true, displayId = 142826,
        zone = "The Hall of Thanes", creatureType = "Undead", npcId = 261306,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["HOT10"] = {
        id = "HOT10", name = "Plunder", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 6, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 142840,
        zone = "The Hall of Thanes", creatureType = "Elemental", npcId = 261311,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["HOT11"] = {
        id = "HOT11", name = "Magmatus", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 6, toughness = 5, isMob = true, isBoss = true, displayId = 1070,
        zone = "The Hall of Thanes", creatureType = "Elemental", npcId = 261316,
        anthem = { tag = "type", value = "Elemental", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Elementals you control get +1/+1."
    },
    -- Solo reward
    ["HOT12"] = {
        id = "HOT12", name = "Ghostly Attendant", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 3, toughness = 4, vigilance = true, isReward = true, displayId = 144348,
        zone = "The Hall of Thanes", creatureType = "Undead", npcEntry = 265002,
        anthem = { tag = "zone", value = "The Hall of Thanes", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant. Other Hall of Thanes denizens you control get +1/+1."
    },
})
