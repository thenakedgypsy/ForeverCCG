--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- DUNGEON CREATURES & BOSSES - UNLOCKED BY KILLING THEM (same isMob/isBoss tracking as zone creatures)
-- WoW Forever dungeon: names / displayIds / npcId come from Wowhead (Forever). The final boss
-- keeps its dedicated BOSSxx card (Cards\Bosses.lua).
-- =========================================================================
TTS:AddCards({
    -- CITY OF DALARAN
    ["DAL01"] = {
        id = "DAL01", name = "Arcane Manaling", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 1, flying = true, isMob = true, isBoss = true, displayId = 130209,
        zone = "City of Dalaran", creatureType = "Elemental", npcId = 246890,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["DAL02"] = {
        id = "DAL02", name = "Mana Fiend", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 130072,
        zone = "City of Dalaran", creatureType = "Elemental", npcId = 246602,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["DAL03"] = {
        id = "DAL03", name = "Mana Phantom", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 130112,
        zone = "City of Dalaran", creatureType = "Elemental", npcId = 246683,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["DAL04"] = {
        id = "DAL04", name = "Seeking Remnant", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, reach = true, isMob = true, isBoss = true, displayId = 130224,
        zone = "City of Dalaran", creatureType = "Elemental", npcId = 247003,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["DAL05"] = {
        id = "DAL05", name = "Saturated Remnant", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 2, toughness = 3, unblockable = true, isMob = true, isBoss = true, displayId = 130223,
        zone = "City of Dalaran", creatureType = "Elemental", npcId = 247001,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Cannot be blocked."
    },
    ["DAL06"] = {
        id = "DAL06", name = "Phantasm", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 2, toughness = 4, hexproof = true, isMob = true, isBoss = true, displayId = 130218,
        zone = "City of Dalaran", creatureType = "Elemental", npcId = 246990,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Warded."
    },
    ["DAL07"] = {
        id = "DAL07", name = "Fragmented Sentry", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 5, vigilance = true, isMob = true, isBoss = true, displayId = 130116,
        zone = "City of Dalaran", creatureType = "Mechanical", npcId = 246664,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant."
    },
    ["DAL08"] = {
        id = "DAL08", name = "Kirin Tor Necromancer", cost = "{3}{B}", cmc = 4, color = "B", type = "Creature",
        power = 0, toughness = 3, isMob = true, isBoss = true, displayId = 145809,
        zone = "City of Dalaran", creatureType = "Humanoid", faction = "Kirin Tor", npcId = 269134,
        etb = { ops = { { op = "token", id = "TOK03", n = 3 } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "When Kirin Tor Necromancer enters the battlefield, create three 1/1 Skeleton tokens."
    },
    ["DAL09"] = {
        id = "DAL09", name = "Arcane Echo", cost = "{3}{U}", cmc = 4, color = "U", type = "Creature",
        power = 3, toughness = 3, flying = true, isMob = true, isBoss = true, displayId = 130218,
        zone = "City of Dalaran", creatureType = "Elemental", npcId = 246992,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["DAL10"] = {
        id = "DAL10", name = "Mana Stalker", cost = "{3}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 130220,
        zone = "City of Dalaran", creatureType = "Elemental", npcId = 246993,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["DAL11"] = {
        id = "DAL11", name = "Arcane Elemental", cost = "{3}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 130208,
        zone = "City of Dalaran", creatureType = "Elemental", npcId = 246888,
        anthem = { tag = "type", value = "Elemental", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Elementals you control get +1/+0."
    },
    ["DAL12"] = {
        id = "DAL12", name = "Mana Echo", cost = "{3}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 6, isMob = true, isBoss = true, displayId = 14272,
        zone = "City of Dalaran", creatureType = "Elemental", npcId = 246600,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DAL13"] = {
        id = "DAL13", name = "Suffused Treant", cost = "{3}{G}", cmc = 4, color = "G", type = "Creature",
        power = 4, toughness = 5, reach = true, isMob = true, isBoss = true, displayId = 130229,
        zone = "City of Dalaran", creatureType = "Elemental", npcId = 247016,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["DAL14"] = {
        id = "DAL14", name = "Mana Wraith", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 5, toughness = 4, flying = true, isMob = true, isBoss = true, displayId = 130220,
        zone = "City of Dalaran", creatureType = "Elemental", npcId = 246931,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["DAL15"] = {
        id = "DAL15", name = "Arcane Anomaly", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 129891,
        zone = "City of Dalaran", creatureType = "Elemental", npcId = 245999,
        etb = { ops = { { op = "damage", to = "enemy_creatures", n = 2 } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "When Arcane Anomaly enters the battlefield, deal 2 damage to each enemy creature."
    },
    ["DAL16"] = {
        id = "DAL16", name = "Arcanic Enigma", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 129900,
        zone = "City of Dalaran", creatureType = "Elemental", npcId = 246016,
        etb = { ops = { { op = "freeze", to = "enemy_creatures" } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "When Arcanic Enigma enters the battlefield, tap each enemy creature. They don't untap during their controller's next untap step."
    },
    ["DAL17"] = {
        id = "DAL17", name = "Unstable Sentinel", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 130116,
        zone = "City of Dalaran", creatureType = "Elemental", npcId = 246017,
        onDeath = { ops = { { op = "damage", to = "enemy_creatures", n = 2 } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "When Unstable Sentinel dies, deal 2 damage to each enemy creature."
    },
    ["DAL18"] = {
        id = "DAL18", name = "Mana Devourer", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 5, toughness = 5, lifelink = true, isMob = true, isBoss = true, displayId = 129895,
        zone = "City of Dalaran", creatureType = "Demon", npcId = 246008,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["DAL19"] = {
        id = "DAL19", name = "Lyn the Ignored", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 130235,
        zone = "City of Dalaran", creatureType = "Humanoid", npcId = 247032,
        etb = { ops = { { op = "raise", src = "own" } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "When Lyn the Ignored enters the battlefield, return a creature card from your graveyard to the battlefield."
    },
    ["DAL20"] = {
        id = "DAL20", name = "Fel Ancient", cost = "{4}{G}{B}", cmc = 6, color = "G", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 129894,
        zone = "City of Dalaran", creatureType = "Demon", npcId = 246003,
        etb = { ops = { { op = "tap", to = "enemy_creatures" } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "When Fel Ancient enters the battlefield, tap each enemy creature."
    },
    ["DAL21"] = {
        id = "DAL21", name = "Atrexis the Grave Knight", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 5, toughness = 4, isMob = true, isBoss = true, displayId = 145787,
        zone = "City of Dalaran", creatureType = "Humanoid", npcId = 247126,
        etb = { ops = { { op = "token", id = "TOK03", n = 2 } } },
        anthem = { tag = "type", value = "Undead", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "When Atrexis the Grave Knight enters the battlefield, create two 1/1 Skeleton tokens. Undead you control get +1/+0."
    },
    -- Solo reward
    ["DAL22"] = {
        id = "DAL22", name = "Archmage Modera", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 3, toughness = 4, hexproof = true, isReward = true, displayId = 130165,
        zone = "City of Dalaran", creatureType = "Humanoid", faction = "Kirin Tor", npcEntry = 246748,
        anthem = { tag = "zone", value = "City of Dalaran", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Warded. Other City of Dalaran creatures you control get +1/+1."
    },
})
