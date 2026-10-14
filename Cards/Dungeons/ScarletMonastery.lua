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
    -- SCARLET MONASTERY
    ["SMO01"] = {
        id = "SMO01", name = "Scarlet Torturer", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 2607,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 4306,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SMO02"] = {
        id = "SMO02", name = "Scarlet Tracking Hound", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 2709,
        zone = "Scarlet Monastery", creatureType = "Beast", faction = "Scarlet Crusade", npcId = 4304,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["SMO03"] = {
        id = "SMO03", name = "Scarlet Monk", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 4, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 2604,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 4540,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["SMO04"] = {
        id = "SMO04", name = "Scarlet Adept", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 5725,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 4296,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["SMO05"] = {
        id = "SMO05", name = "Haunting Phantasm", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 3, unblockable = true, isMob = true, isBoss = true, displayId = 4629,
        zone = "Scarlet Monastery", creatureType = "Undead", npcId = 6427,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Cannot be blocked."
    },
    ["SMO06"] = {
        id = "SMO06", name = "Scarlet Myrmidon", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 4, trample = true, isMob = true, isBoss = true, displayId = 2515,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 4295,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["SMO07"] = {
        id = "SMO07", name = "Scarlet Champion", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 3, toughness = 3, vigilance = true, isMob = true, isBoss = true, displayId = 2460,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 4302,
        rally = { tag = "faction", value = "Scarlet Crusade", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance. Gets +1/+1 for each other Scarlet Crusade you control."
    },
    ["SMO08"] = {
        id = "SMO08", name = "Interrogator Vishas", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 5, toughness = 6, deathtouch = true, isMob = true, isBoss = true, displayId = 2044,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 3983,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["SMO09"] = {
        id = "SMO09", name = "Houndmaster Loksey", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 5, toughness = 5, haste = true, isMob = true, isBoss = true, displayId = 2040,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 3974,
        anthem = { tag = "type", value = "Beast", kw = { "haste" } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste. Other Beasts you control have Haste."
    },
    ["SMO10"] = {
        id = "SMO10", name = "Fallen Champion", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 7, lifelink = true, isMob = true, isBoss = true, displayId = 5230,
        zone = "Scarlet Monastery", creatureType = "Undead", npcId = 6488,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["SMO11"] = {
        id = "SMO11", name = "Ironspine", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 8, trample = true, isMob = true, isBoss = true, displayId = 5231,
        zone = "Scarlet Monastery", creatureType = "Undead", npcId = 6489,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["SMO12"] = {
        id = "SMO12", name = "High Inquisitor Fairbanks", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 6, toughness = 8, lifelink = true, isMob = true, isBoss = true, displayId = 2605,
        zone = "Scarlet Monastery", creatureType = "Undead", faction = "Scarlet Crusade", npcId = 4542,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["SMO13"] = {
        id = "SMO13", name = "Scarlet Commander Mograine", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 7, toughness = 8, firstStrike = true, vigilance = true, isMob = true, isBoss = true, displayId = 2042,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 3976,
        anthem = { tag = "faction", value = "Scarlet Crusade", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike, Vigilance. Other Scarlet Crusade you control get +1/+1."
    },
})
