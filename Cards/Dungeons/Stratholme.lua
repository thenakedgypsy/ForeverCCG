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
    -- STRATHOLME
    ["STR01"] = {
        id = "STR01", name = "Crimson Initiate", cost = "{1}{W}", cmc = 2, color = "W", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 10496,
        zone = "Stratholme", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 10420,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STR02"] = {
        id = "STR02", name = "Plague Ghoul", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 559,
        zone = "Stratholme", creatureType = "Undead", npcId = 10405,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["STR03"] = {
        id = "STR03", name = "Crimson Gallant", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 4, vigilance = true, isMob = true, isBoss = true, displayId = 10512,
        zone = "Stratholme", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 10424,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["STR04"] = {
        id = "STR04", name = "Rockwing Gargoyle", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 3, flying = true, isMob = true, isBoss = true, displayId = 7533,
        zone = "Stratholme", creatureType = "Undead", npcId = 10408,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["STR05"] = {
        id = "STR05", name = "Shrieking Banshee", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 3, unblockable = true, isMob = true, isBoss = true, displayId = 10728,
        zone = "Stratholme", creatureType = "Undead", npcId = 10463,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Cannot be blocked."
    },
    ["STR06"] = {
        id = "STR06", name = "Crypt Crawler", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 4, deathtouch = true, isMob = true, isBoss = true, displayId = 6841,
        zone = "Stratholme", creatureType = "Undead", npcId = 10412,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["STR07"] = {
        id = "STR07", name = "Patchwork Horror", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 1693,
        zone = "Stratholme", creatureType = "Undead", npcId = 10414,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["STR08"] = {
        id = "STR08", name = "Venom Belcher", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 8, isMob = true, isBoss = true, displayId = 12819,
        zone = "Stratholme", creatureType = "Undead", npcId = 10417,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["STR09"] = {
        id = "STR09", name = "Magistrate Barthilas", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 6, toughness = 5, haste = true, isMob = true, isBoss = true, displayId = 10433,
        zone = "Stratholme", creatureType = "Undead", npcId = 10435,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["STR10"] = {
        id = "STR10", name = "Hearthsinger Forresten", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 5, toughness = 6, lifelink = true, isMob = true, isBoss = true, displayId = 10482,
        zone = "Stratholme", creatureType = "Undead", npcId = 10558,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["STR11"] = {
        id = "STR11", name = "The Unforgiven", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 6, toughness = 8, isMob = true, isBoss = true, displayId = 10771,
        zone = "Stratholme", creatureType = "Undead", npcId = 10516,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STR12"] = {
        id = "STR12", name = "Skul", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 7, toughness = 7, firstStrike = true, isMob = true, isBoss = true, displayId = 2606,
        zone = "Stratholme", creatureType = "Undead", npcId = 10393,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["STR13"] = {
        id = "STR13", name = "Cannon Master Willey", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 8, toughness = 7, isMob = true, isBoss = true, displayId = 10674,
        zone = "Stratholme", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 10997,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STR14"] = {
        id = "STR14", name = "Archivist Galford", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 8, firstStrike = true, isMob = true, isBoss = true, displayId = 10544,
        zone = "Stratholme", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 10811,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["STR15"] = {
        id = "STR15", name = "Malor the Zealous", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 7, toughness = 8, vigilance = true, isMob = true, isBoss = true, displayId = 10458,
        zone = "Stratholme", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 11032,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["STR16"] = {
        id = "STR16", name = "Baroness Anastari", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 8, lifelink = true, isMob = true, isBoss = true, displayId = 10698,
        zone = "Stratholme", creatureType = "Undead", npcId = 10436,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["STR17"] = {
        id = "STR17", name = "Nerub'enkan", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 8, deathtouch = true, isMob = true, isBoss = true, displayId = 9793,
        zone = "Stratholme", creatureType = "Undead", npcId = 10437,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["STR18"] = {
        id = "STR18", name = "Stonespine", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 8, toughness = 8, trample = true, isMob = true, isBoss = true, displayId = 7856,
        zone = "Stratholme", creatureType = "Undead", npcId = 10809,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["STR19"] = {
        id = "STR19", name = "Maleki the Pallid", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 8, toughness = 8, isMob = true, isBoss = true, displayId = 10546,
        zone = "Stratholme", creatureType = "Humanoid", npcId = 10438,
        anthem = { tag = "zone", value = "Stratholme", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Stratholme creatures you control get +1/+1."
    },
    ["STR20"] = {
        id = "STR20", name = "Grand Crusader Dathrohan", cost = "{5}{W}{W}", cmc = 7, color = "W", type = "Creature",
        power = 10, toughness = 10, lifelink = true, vigilance = true, isMob = true, isBoss = true, displayId = 10545,
        zone = "Stratholme", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 10812,
        anthem = { tag = "faction", value = "Scarlet Crusade", kw = { "lifelink" } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink, Vigilance. Other Scarlet Crusade you control have Lifelink."
    },
})
