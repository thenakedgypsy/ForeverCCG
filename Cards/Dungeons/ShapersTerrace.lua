--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- DUNGEON CREATURES & BOSSES - UNLOCKED BY KILLING THEM (same isMob/isBoss tracking as zone creatures)
-- WoW Forever dungeon: npcIds from Wowhead (Forever)'s tooltips (its NPCs carry no zone there),
-- displayIds from Wowhead's model viewer (supplied by hand, 2026-11-17; Cinder and Snowtalon
-- matched forever.warcraftdb.com, King Op is from the client's creature cache). Most ravasaurs
-- and the Stone Guardian have several ids (e.g. Ravasaur Hunter 262688, Ravasaur Trapper
-- 262685-262697, Stone Guardian 261777/272317), which match by name. Venomhide Ravasaur, Ravasaur Matriarch, Stone Guardian and Ravasaur Hunter
-- share their names with outdoor Un'Goro creatures, so they list their ids (npcIds) and set strictIds
-- (BossTracker: by name only inside an instance). The final boss keeps its
-- dedicated BOSSxx card (Cards\Bosses.lua).
-- =========================================================================
TTS:AddCards({
    -- SHAPER'S TERRACE
    ["SHT01"] = {
        id = "SHT01", name = "Ravasaur Juvenile", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 11316,
        zone = "Shaper's Terrace", creatureType = "Beast", npcId = 261898,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["SHT02"] = {
        id = "SHT02", name = "Ravasaur Stalker", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 2, unblockable = true, isMob = true, isBoss = true, displayId = 648,
        zone = "Shaper's Terrace", creatureType = "Beast", npcId = 261934,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Invisible."
    },
    ["SHT03"] = {
        id = "SHT03", name = "Ravasaur Trapper", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 3, isMob = true, isBoss = true, displayId = 1962,
        etb = { target = "enemy_creature", ops = { { op = "freeze", to = "target" } } },
        zone = "Shaper's Terrace", creatureType = "Beast", npcId = 262114,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Arrival: Freeze target enemy denizen."
    },
    ["SHT04"] = {
        id = "SHT04", name = "Ravasaur Assassin", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 2, firstStrike = true, isMob = true, isBoss = true, displayId = 948,
        zone = "Shaper's Terrace", creatureType = "Beast", npcId = 262115,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["SHT05"] = {
        id = "SHT05", name = "Venomhide Ravasaur", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 3, deathtouch = true, isMob = true, isBoss = true, displayId = 143340,
        zone = "Shaper's Terrace", creatureType = "Beast", npcId = 269206, strictIds = true,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["SHT06"] = {
        id = "SHT06", name = "Tor'Rel", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, reach = true, isMob = true, isBoss = true, displayId = 143039,
        zone = "Shaper's Terrace", creatureType = "Beast", npcId = 261811,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["SHT07"] = {
        id = "SHT07", name = "Ironhide Ravasaur", cost = "{3}{G}", cmc = 4, color = "G", type = "Creature",
        power = 3, toughness = 5, bulwark = 2, isMob = true, isBoss = true, displayId = 1337,
        zone = "Shaper's Terrace", creatureType = "Beast", npcId = 261786,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Bulwark 2."
    },
    ["SHT08"] = {
        id = "SHT08", name = "Ravasaur Matriarch", cost = "{3}{G}", cmc = 4, color = "G", type = "Creature",
        power = 3, toughness = 4, support = true, isMob = true, isBoss = true, displayId = 143340,
        zone = "Shaper's Terrace", creatureType = "Beast", npcId = 253215, strictIds = true,
        anthem = { tag = "type", value = "Beast", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support. Other Beasts you control get +1/+0."
    },
    ["SHT09"] = {
        id = "SHT09", name = "Stone Guardian", cost = "{3}{W}", cmc = 4, color = "W", type = "Creature",
        power = 2, toughness = 6, vigilance = true, bulwark = 2, isMob = true, isBoss = true, displayId = 8395,
        zone = "Shaper's Terrace", creatureType = "Elemental", npcId = 262032, npcIds = { 261777, 272317 }, strictIds = true,
        modelCam = { zoom = 0.70, camScale = 1.10, z = -0.15, rotation = 0.15 },
        text = "Vigilant. Bulwark 2."
    },
    -- Bosses
    ["SHT10"] = {
        id = "SHT10", name = "Ravasaur Hunter", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 4, toughness = 3, haste = true, firstStrike = true, isMob = true, isBoss = true, displayId = 4442,
        zone = "Shaper's Terrace", creatureType = "Beast", npcId = 253214, npcIds = { 262688 }, strictIds = true,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick. Strikes-First."
    },
    ["SHT11"] = {
        id = "SHT11", name = "Thunderhoof", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 5, toughness = 4, haste = true, trample = true, isMob = true, isBoss = true, displayId = 144514,
        zone = "Shaper's Terrace", creatureType = "Beast", npcId = 261812,
        modelCam = { zoom = 0.65, camScale = 1.15, z = -0.15, rotation = 0.15 },
        text = "Quick. Brutish."
    },
    ["SHT12"] = {
        id = "SHT12", name = "Venomridge", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 4, toughness = 4, deathtouch = true, reach = true, isMob = true, isBoss = true, displayId = 144511,
        zone = "Shaper's Terrace", creatureType = "Beast", npcId = 261813,
        modelCam = { zoom = 0.65, camScale = 1.15, z = -0.15, rotation = 0.15 },
        text = "Fatal. Anti-Air."
    },
    ["SHT13"] = {
        id = "SHT13", name = "Cinder", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 5, toughness = 3, haste = true, isMob = true, isBoss = true, displayId = 143035,
        etb = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 3 } } },
        zone = "Shaper's Terrace", creatureType = "Beast", npcId = 261974,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick. Arrival: Deal 3 damage to target enemy denizen."
    },
    ["SHT14"] = {
        id = "SHT14", name = "Bolt", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 4, toughness = 3, haste = true, isMob = true, isBoss = true, displayId = 143063,
        etb = { ops = { { op = "damage", to = "enemy_creatures", n = 1 } } },
        zone = "Shaper's Terrace", creatureType = "Beast", npcId = 262081,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick. Arrival: Deal 1 damage to each enemy denizen."
    },
    ["SHT15"] = {
        id = "SHT15", name = "Snowtalon", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 4, flying = true, isMob = true, isBoss = true, displayId = 143122,
        etb = { target = "enemy_creature", ops = { { op = "freeze", to = "target" } } },
        zone = "Shaper's Terrace", creatureType = "Beast", npcId = 262297,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne. Arrival: Freeze target enemy denizen."
    },
    ["SHT16"] = {
        id = "SHT16", name = "Direhorn Matriarch", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 4, toughness = 7, vigilance = true, bulwark = 2, isMob = true, isBoss = true, displayId = 144515,
        zone = "Shaper's Terrace", creatureType = "Beast", npcId = 262127,
        modelCam = { zoom = 0.60, camScale = 1.20, z = -0.15, rotation = 0.15 },
        text = "Vigilant. Bulwark 2."
    },
    ["SHT17"] = {
        id = "SHT17", name = "Vitrix", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 5, toughness = 5, firstStrike = true, hexproof = true, isMob = true, isBoss = true, displayId = 147098,
        zone = "Shaper's Terrace", creatureType = "Beast", npcId = 272561,
        modelCam = { zoom = 0.70, camScale = 1.10, z = -0.15, rotation = 0.15 },
        text = "Strikes-First. Warded."
    },
    ["SHT18"] = {
        id = "SHT18", name = "King Op", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 6, toughness = 6, enrage = true, bulwark = 2, isMob = true, isBoss = true, displayId = 143129,
        zone = "Shaper's Terrace", creatureType = "Beast", npcId = 261993,
        modelCam = { zoom = 0.65, camScale = 1.15, z = -0.15, rotation = 0.15 },
        text = "Enrage. Bulwark 2."
    },
    ["SHT19"] = {
        id = "SHT19", name = "Titanosaur", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 6, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 142989,
        zone = "Shaper's Terrace", creatureType = "Beast", npcId = 253201,
        modelCam = { zoom = 0.45, camScale = 1.40, z = -0.20, rotation = 0.15 },
        text = "Brutish."
    },
    -- Solo reward
    ["SHT20"] = {
        id = "SHT20", name = "Izha'Rel", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 4, toughness = 4, haste = true, isReward = true, displayId = 143040,
        zone = "Shaper's Terrace", creatureType = "Beast", npcEntry = 253218,
        anthem = { tag = "zone", value = "Shaper's Terrace", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick. Other Shaper's Terrace denizens you control get +1/+1."
    },
})
