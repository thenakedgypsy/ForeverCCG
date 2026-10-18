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
    -- RUINS OF LORDAERON
    ["ROL01"] = {
        id = "ROL01", name = "Broodling", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 9756,
        zone = "Ruins of Lordaeron", creatureType = "Beast", npcId = 250625,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["ROL02"] = {
        id = "ROL02", name = "Ragged Ghoul", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 414,
        zone = "Ruins of Lordaeron", creatureType = "Undead", npcId = 250622,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ROL03"] = {
        id = "ROL03", name = "Skeletal Soldier", cost = "{1}{W}", cmc = 2, color = "W", type = "Creature",
        power = 2, toughness = 4, vigilance = true, isMob = true, isBoss = true, displayId = 7848,
        zone = "Ruins of Lordaeron", creatureType = "Undead", npcId = 250626,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant."
    },
    ["ROL04"] = {
        id = "ROL04", name = "Broodwidow", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, deathtouch = true, isMob = true, isBoss = true, displayId = 963,
        zone = "Ruins of Lordaeron", creatureType = "Beast", npcId = 250619,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["ROL05"] = {
        id = "ROL05", name = "Skeletal Mage", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 4, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 7550,
        zone = "Ruins of Lordaeron", creatureType = "Undead", npcId = 250624,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["ROL06"] = {
        id = "ROL06", name = "Wailing Banshee", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 3, unblockable = true, isMob = true, isBoss = true, displayId = 8782,
        zone = "Ruins of Lordaeron", creatureType = "Undead", npcId = 250650,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Invisible."
    },
    ["ROL07"] = {
        id = "ROL07", name = "Mangled Cadaver", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 10972,
        zone = "Ruins of Lordaeron", creatureType = "Undead", npcId = 250623,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["ROL08"] = {
        id = "ROL08", name = "Fallen Berserker", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 4, trample = true, isMob = true, isBoss = true, displayId = 9784,
        zone = "Ruins of Lordaeron", creatureType = "Undead", npcId = 250656,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["ROL09"] = {
        id = "ROL09", name = "Fallen Necromancer", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 4, isMob = true, isBoss = true, displayId = 9785,
        zone = "Ruins of Lordaeron", creatureType = "Undead", npcId = 255964,
        rally = { tag = "type", value = "Undead", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Gets +1/+1 for each other Undead you control."
    },
    ["ROL10"] = {
        id = "ROL10", name = "Witherfang", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 5, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 144189,
        zone = "Ruins of Lordaeron", creatureType = "Beast", npcId = 250483,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["ROL11"] = {
        id = "ROL11", name = "Bjork", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 4, toughness = 5, hexproof = true, isMob = true, isBoss = true, displayId = 144170,
        zone = "Ruins of Lordaeron", creatureType = "Undead", npcId = 256097,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Warded."
    },
    ["ROL12"] = {
        id = "ROL12", name = "Flesh Golem", cost = "{3}{B}", cmc = 4, color = "B", type = "Creature",
        power = 5, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 1693,
        zone = "Ruins of Lordaeron", creatureType = "Undead", npcId = 255109,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["ROL13"] = {
        id = "ROL13", name = "The Baron", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 144188,
        zone = "Ruins of Lordaeron", creatureType = "Undead", npcId = 250660,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["ROL14"] = {
        id = "ROL14", name = "Viktor the Vile", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 7, toughness = 6, lifelink = true, isMob = true, isBoss = true, displayId = 139455,
        zone = "Ruins of Lordaeron", creatureType = "Undead", npcId = 256035,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["ROL15"] = {
        id = "ROL15", name = "The Abandoned", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 5, toughness = 6, isMob = true, isBoss = true, displayId = 138667,
        zone = "Ruins of Lordaeron", creatureType = "Undead", npcId = 250631,
        anthem = { tag = "type", value = "Undead", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Undead you control get +1/+1."
    },
    -- Solo reward
    ["ROL16"] = {
        id = "ROL16", name = "Captain Truman", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 4, toughness = 3, firstStrike = true, isReward = true, displayId = 5711,
        zone = "Ruins of Lordaeron", creatureType = "Humanoid", npcEntry = 265701,
        anthem = { tag = "type", value = "Humanoid", p = 1, kw = { "vigilance" } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First. Other Humanoids you control get +1/+0 and Vigilant."
    },
})
