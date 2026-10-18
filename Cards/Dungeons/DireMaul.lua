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
    -- DIRE MAUL
    ["DMA01"] = {
        id = "DMA01", name = "Wildspawn Rogue", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, unblockable = true, isMob = true, isBoss = true, displayId = 2021,
        zone = "Dire Maul", creatureType = "Demon", faction = "Satyr", npcId = 11452,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Cannot be blocked."
    },
    ["DMA02"] = {
        id = "DMA02", name = "Warpwood Tangler", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 5, reach = true, isMob = true, isBoss = true, displayId = 9592,
        zone = "Dire Maul", creatureType = "Elemental", npcId = 11464,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["DMA03"] = {
        id = "DMA03", name = "Gordok Brute", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 5, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 12473,
        zone = "Dire Maul", creatureType = "Humanoid", faction = "Ogre", npcId = 11441,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Brutish."
    },
    ["DMA04"] = {
        id = "DMA04", name = "Eldreth Sorcerer", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 11205,
        zone = "Dire Maul", creatureType = "Undead", npcId = 11470,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DMA05"] = {
        id = "DMA05", name = "Pusillin", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 2, haste = true, unblockable = true, isMob = true, isBoss = true, displayId = 7552,
        zone = "Dire Maul", creatureType = "Demon", npcId = 14354,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick, Cannot be blocked."
    },
    ["DMA06"] = {
        id = "DMA06", name = "Warpwood Crusher", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 6, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 12929,
        zone = "Dire Maul", creatureType = "Elemental", npcId = 13021,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Brutish."
    },
    ["DMA07"] = {
        id = "DMA07", name = "Gordok Mage-Lord", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 11537,
        zone = "Dire Maul", creatureType = "Humanoid", faction = "Ogre", npcId = 11444,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["DMA08"] = {
        id = "DMA08", name = "Zevrim Thornhoof", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 6, lifelink = true, isMob = true, isBoss = true, displayId = 11335,
        zone = "Dire Maul", creatureType = "Demon", faction = "Satyr", npcId = 11490,
        anthem = { tag = "faction", value = "Satyr", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain. Other Satyrs you control get +1/+1."
    },
    ["DMA09"] = {
        id = "DMA09", name = "Lethtendris", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 8, deathtouch = true, isMob = true, isBoss = true, displayId = 14378,
        zone = "Dire Maul", creatureType = "Humanoid", npcId = 14327,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["DMA10"] = {
        id = "DMA10", name = "Hydrospawn", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 7, toughness = 8, isMob = true, isBoss = true, displayId = 5489,
        zone = "Dire Maul", creatureType = "Elemental", npcId = 13280,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DMA11"] = {
        id = "DMA11", name = "Illyanna Ravenoak", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 7, toughness = 7, firstStrike = true, isMob = true, isBoss = true, displayId = 11270,
        zone = "Dire Maul", creatureType = "Undead", npcId = 11488,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["DMA12"] = {
        id = "DMA12", name = "Magister Kalendris", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 8, lifelink = true, isMob = true, isBoss = true, displayId = 14384,
        zone = "Dire Maul", creatureType = "Undead", npcId = 11487,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["DMA13"] = {
        id = "DMA13", name = "Cho'Rush the Observer", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 7, toughness = 8, isMob = true, isBoss = true, displayId = 11537,
        zone = "Dire Maul", creatureType = "Humanoid", faction = "Ogre", npcId = 14324,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["DMA14"] = {
        id = "DMA14", name = "Guard Mol'dar", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 8, vigilance = true, isMob = true, isBoss = true, displayId = 11561,
        zone = "Dire Maul", creatureType = "Humanoid", faction = "Ogre", npcId = 14326,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Vigilant."
    },
    ["DMA15"] = {
        id = "DMA15", name = "Stomper Kreeg", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 8, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 11545,
        zone = "Dire Maul", creatureType = "Humanoid", faction = "Ogre", npcId = 14322,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Brutish."
    },
    ["DMA16"] = {
        id = "DMA16", name = "Tendris Warpwood", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 7, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 14383,
        zone = "Dire Maul", creatureType = "Elemental", npcId = 11489,
        anthem = { tag = "zone", value = "Dire Maul", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Brutish. Other Dire Maul denizens you control get +1/+1."
    },
    ["DMA17"] = {
        id = "DMA17", name = "Captain Kromcrush", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 8, toughness = 8, vigilance = true, isMob = true, isBoss = true, displayId = 11564,
        zone = "Dire Maul", creatureType = "Humanoid", faction = "Ogre", npcId = 14325,
        anthem = { tag = "faction", value = "Ogre", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Vigilant. Other Ogres you control get +1/+1."
    },
    ["DMA18"] = {
        id = "DMA18", name = "Immol'thar", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 9, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 14173,
        zone = "Dire Maul", creatureType = "Demon", npcId = 11496,
        anthem = { tag = "type", value = "Demon", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Brutish. Other Demons you control get +1/+1."
    },
    -- Solo reward
    ["DMA19"] = {
        id = "DMA19", name = "Lord Hel'nurath", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 6, toughness = 6, isReward = true, displayId = 14556,
        zone = "Dire Maul", creatureType = "Demon", npcEntry = 14506,
        anthem = { tag = "type", value = "Demon", p = 1, t = 1 },
        etb = { ops = { { op = "damage", to = "enemy_player", n = 3 } } },
        modelCam = { zoom = 0.70, camScale = 1.15, z = -0.18, rotation = 0.15 },
        text = "When Lord Hel'nurath enters the battlefield, deal 3 damage to the opponent. Other Demons you control get +1/+1."
    },
})
