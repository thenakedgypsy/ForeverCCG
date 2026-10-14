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
    -- ZUL'FARRAK
    ["ZFK01"] = {
        id = "ZFK01", name = "Sandfury Blood Drinker", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 3, lifelink = true, isMob = true, isBoss = true, displayId = 6423,
        zone = "Zul'Farrak", creatureType = "Humanoid", faction = "Troll", npcId = 5649,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["ZFK02"] = {
        id = "ZFK02", name = "Sandfury Shadowhunter", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 6425,
        zone = "Zul'Farrak", creatureType = "Humanoid", faction = "Troll", npcId = 7246,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ZFK03"] = {
        id = "ZFK03", name = "Sandfury Executioner", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 6440,
        zone = "Zul'Farrak", creatureType = "Humanoid", faction = "Troll", npcId = 7274,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["ZFK04"] = {
        id = "ZFK04", name = "Sul'lithuz Sandcrawler", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 5, isMob = true, isBoss = true, displayId = 7345,
        zone = "Zul'Farrak", creatureType = "Beast", npcId = 8095,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ZFK05"] = {
        id = "ZFK05", name = "Theka the Martyr", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 5, toughness = 7, lifelink = true, isMob = true, isBoss = true, displayId = 6696,
        zone = "Zul'Farrak", creatureType = "Undead", faction = "Troll", npcId = 7272,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["ZFK06"] = {
        id = "ZFK06", name = "Hydromancer Velratha", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 5, toughness = 7, isMob = true, isBoss = true, displayId = 6685,
        zone = "Zul'Farrak", creatureType = "Humanoid", faction = "Troll", npcId = 7795,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ZFK07"] = {
        id = "ZFK07", name = "Witch Doctor Zum'rah", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 5, toughness = 6, deathtouch = true, isMob = true, isBoss = true, displayId = 6434,
        zone = "Zul'Farrak", creatureType = "Humanoid", faction = "Troll", npcId = 7271,
        anthem = { tag = "faction", value = "Troll", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch. Other Trolls you control get +1/+1."
    },
    ["ZFK08"] = {
        id = "ZFK08", name = "Ruuzlu", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 6687,
        zone = "Zul'Farrak", creatureType = "Humanoid", faction = "Troll", npcId = 7797,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["ZFK09"] = {
        id = "ZFK09", name = "Dustwraith", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 6, unblockable = true, isMob = true, isBoss = true, displayId = 9292,
        zone = "Zul'Farrak", creatureType = "Humanoid", npcId = 10081,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Cannot be blocked."
    },
    ["ZFK10"] = {
        id = "ZFK10", name = "Sandarr Dunereaver", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 8, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 9291,
        zone = "Zul'Farrak", creatureType = "Humanoid", faction = "Troll", npcId = 10080,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["ZFK11"] = {
        id = "ZFK11", name = "Antu'sul", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 7, toughness = 8, deathtouch = true, isMob = true, isBoss = true, displayId = 7353,
        zone = "Zul'Farrak", creatureType = "Humanoid", npcId = 8127,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    -- Solo reward
    ["ZFK12"] = {
        id = "ZFK12", name = "Gahz'rilla", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 6, toughness = 6, isReward = true, displayId = 7271,
        zone = "Zul'Farrak", creatureType = "Beast", npcEntry = 7273,
        anthem = { tag = "zone", value = "Zul'Farrak", p = 1, t = 1 },
        etb = { ops = { { op = "freeze", to = "enemy_creatures" } } },
        modelCam = { zoom = 0.55, camScale = 1.30, z = -0.20, rotation = 0.15 },
        text = "When Gahz'rilla enters the battlefield, tap each enemy creature. They don't untap during their controller's next untap step. Other Zul'Farrak creatures you control get +1/+1."
    },
})
