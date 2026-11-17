--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- DUNGEON CREATURES & BOSSES - UNLOCKED BY KILLING THEM (same isMob/isBoss tracking as zone creatures)
-- WoW Forever dungeon: names / displayIds / npcId come from the client's creature cache
-- (ForeverCCG_DevCapture\tools\wdb_creatures.lua), each checked against Wowhead (Forever)'s
-- zone 16550. The Deathless Watcher, Guardian and Sorcerer also have second ids
-- (268477, 268478, 268476), which match by name. The final boss keeps its dedicated
-- BOSSxx card (Cards\Bosses.lua).
-- =========================================================================
TTS:AddCards({
    -- THE DROWNED CITY
    ["TDC01"] = {
        id = "TDC01", name = "Saltscale Muckdweller", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 3, isMob = true, isBoss = true, displayId = 983,
        zone = "The Drowned City", creatureType = "Humanoid", faction = "Murloc", npcId = 258849,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TDC02"] = {
        id = "TDC02", name = "Chasm Crawler", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 1, toughness = 4, support = true, isMob = true, isBoss = true, displayId = 981,
        zone = "The Drowned City", creatureType = "Beast", npcId = 258818,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["TDC03"] = {
        id = "TDC03", name = "Mana-Rich Frenzy", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 3, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 14528,
        zone = "The Drowned City", creatureType = "Beast", npcId = 268462,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["TDC04"] = {
        id = "TDC04", name = "Saltseer Cultist", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, lifelink = true, isMob = true, isBoss = true, displayId = 142129,
        zone = "The Drowned City", creatureType = "Humanoid", npcId = 259981,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["TDC05"] = {
        id = "TDC05", name = "Undying Offering", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 3, support = true, isMob = true, isBoss = true, displayId = 143899,
        zone = "The Drowned City", creatureType = "Undead", npcId = 263899,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["TDC06"] = {
        id = "TDC06", name = "Saltseer Murderer", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 2, deathtouch = true, isMob = true, isBoss = true, displayId = 142126,
        zone = "The Drowned City", creatureType = "Humanoid", npcId = 259979,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["TDC07"] = {
        id = "TDC07", name = "Saltseer Manhunter", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 142131,
        zone = "The Drowned City", creatureType = "Humanoid", npcId = 259987,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["TDC08"] = {
        id = "TDC08", name = "Saltseer Coroner", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 4, isMob = true, isBoss = true, displayId = 142401,
        zone = "The Drowned City", creatureType = "Humanoid", npcId = 260353,
        anthem = { tag = "type", value = "Undead", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Undead you control get +1/+0."
    },
    ["TDC09"] = {
        id = "TDC09", name = "Makrura Snapper", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 2, toughness = 5, reach = true, isMob = true, isBoss = true, displayId = 2426,
        zone = "The Drowned City", creatureType = "Beast", npcId = 258897,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["TDC10"] = {
        id = "TDC10", name = "Brinescale Sorceress", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 2, toughness = 3, isMob = true, isBoss = true, displayId = 4975,
        etb = { target = "enemy_creature", ops = { { op = "freeze", to = "target" } } },
        zone = "The Drowned City", creatureType = "Humanoid", faction = "Naga", npcId = 258804,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Arrival: Freeze target enemy denizen."
    },
    ["TDC11"] = {
        id = "TDC11", name = "Brinescale Priestess", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 4, support = true, shielded = true, isMob = true, isBoss = true, displayId = 4974,
        zone = "The Drowned City", creatureType = "Humanoid", faction = "Naga", npcId = 260096,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support. Shielded."
    },
    ["TDC12"] = {
        id = "TDC12", name = "Deathless Marrow", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 2, unblockable = true, isMob = true, isBoss = true, displayId = 142245,
        zone = "The Drowned City", creatureType = "Elemental", npcId = 260202,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Invisible."
    },
    ["TDC13"] = {
        id = "TDC13", name = "Deathless Watcher", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 3, reach = true, isMob = true, isBoss = true, displayId = 142246,
        zone = "The Drowned City", creatureType = "Undead", npcId = 260205,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["TDC14"] = {
        id = "TDC14", name = "Deathless Guardian", cost = "{3}{W}", cmc = 4, color = "W", type = "Creature",
        power = 3, toughness = 5, vigilance = true, bulwark = 2, isMob = true, isBoss = true, displayId = 142268,
        zone = "The Drowned City", creatureType = "Undead", npcId = 260213,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant. Bulwark 2."
    },
    ["TDC15"] = {
        id = "TDC15", name = "Deathless Sorcerer", cost = "{3}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 142269,
        etb = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 3 } } },
        zone = "The Drowned City", creatureType = "Undead", npcId = 260214,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Arrival: Deal 3 damage to target enemy denizen."
    },
    -- Bosses
    ["TDC16"] = {
        id = "TDC16", name = "Zul'Alai", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 4, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 144475,
        zone = "The Drowned City", creatureType = "Undead", npcId = 258905,
        anthem = { tag = "type", value = "Undead", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain. Other Undead you control get +1/+0."
    },
    ["TDC17"] = {
        id = "TDC17", name = "Var'Taka", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 5, toughness = 4, haste = true, enrage = true, isMob = true, isBoss = true, displayId = 144487,
        zone = "The Drowned City", creatureType = "Humanoid", npcId = 258924,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick. Enrage."
    },
    ["TDC18"] = {
        id = "TDC18", name = "Captain Dreadrise", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 5, firstStrike = true, isMob = true, isBoss = true, displayId = 142144,
        etb = { target = "enemy_creature", ops = { { op = "bounce", to = "target" } } },
        zone = "The Drowned City", creatureType = "Humanoid", npcId = 260042,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First. Arrival: Return target enemy denizen to its owner's hand."
    },
    ["TDC19"] = {
        id = "TDC19", name = "Primeval Elemental", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 6, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 143898,
        zone = "The Drowned City", creatureType = "Elemental", npcId = 263886,
        modelCam = { zoom = 0.70, camScale = 1.10, z = -0.15, rotation = 0.15 },
        text = "Brutish."
    },
    -- Solo reward (Powderfuse's goblin, outside the dungeon)
    ["TDC20"] = {
        id = "TDC20", name = "Argo Brinewhistle", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 3, toughness = 4, firstStrike = true, isReward = true, displayId = 142264,
        zone = "The Drowned City", creatureType = "Humanoid", npcEntry = 260231,
        anthem = { tag = "zone", value = "The Drowned City", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First. Other Drowned City denizens you control get +1/+1."
    },
})
