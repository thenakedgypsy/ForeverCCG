--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- TOKENS
-- Creatures made by other cards' effects (op = "token"). They are never in a deck or a
-- collection, can't be unlocked, and vanish instead of going to a graveyard, hand or
-- library. They carry a faction so tribal anthems and rallies count them.
-- =========================================================================
TTS:AddCards({
    ["TOK01"] = {
        id = "TOK01", name = "Murloc Tadpole", cost = "", cmc = 0, color = "U", type = "Creature",
        power = 1, toughness = 1, isToken = true, displayId = 652,
        creatureType = "Humanoid", faction = "Murloc",
        modelCam = { zoom = 0.80, camScale = 0.75, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TOK02"] = {
        id = "TOK02", name = "Kobold Digger", cost = "", cmc = 0, color = "W", type = "Creature",
        power = 1, toughness = 1, isToken = true, displayId = 10912,
        creatureType = "Humanoid", faction = "Kobold",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TOK03"] = {
        id = "TOK03", name = "Skeleton", cost = "", cmc = 0, color = "B", type = "Creature",
        power = 1, toughness = 1, isToken = true, displayId = 7846,
        creatureType = "Undead",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    -- Leeroy Jenkins (Cards\Special.lua): the Rookery's eggs and what hatches from them
    ["TOK04"] = {
        id = "TOK04", name = "Dragon Egg", cost = "", cmc = 0, color = "R", type = "Creature",
        power = 0, toughness = 1, defender = true, isToken = true, displayId = 10056,   -- murloc egg model (classic npc 205765)
        creatureType = "Dragonkin",
        onDeath = { ops = { { op = "token", id = "TOK05", n = 1 } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Blocker. Martyrdom: Spawn: 1 Rookery Whelp Add (1/1, Airborne)."
    },
    ["TOK05"] = {
        id = "TOK05", name = "Rookery Whelp", cost = "", cmc = 0, color = "R", type = "Creature",
        power = 1, toughness = 1, flying = true, isToken = true, displayId = 397,   -- Rookery Whelp (classic npc 10161)
        creatureType = "Dragonkin",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    -- Gazz'uz (Cards\Zones\Durotar.lua)
    ["TOK06"] = {
        id = "TOK06", name = "Voidwalker", cost = "", cmc = 0, color = "B", type = "Creature",
        power = 1, toughness = 5, defender = true, isToken = true, displayId = 1132,   -- warlock voidwalker model
        creatureType = "Demon",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Blocker."
    },
    -- Sneed's Shredder (Cards\Dungeons\Deadmines.lua): the pilot, once his shredder is scrap
    ["TOK07"] = {
        id = "TOK07", name = "Sneed", cost = "", cmc = 0, color = "R", type = "Creature",
        power = 2, toughness = 2, isToken = true, displayId = 7125,   -- Sneed (classic npc 643)
        creatureType = "Humanoid", faction = "Defias",
        anthem = { tag = "faction", value = "Defias", p = 0, kw = { "haste" } },
        rally = { tag = "faction", value = "Defias", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Gets +1/+1 for each other Defias you control. Other Defias you control have Quick."
    },
    -- Arcanite Dragonling (Cards\Professions.lua). No displayId yet, so it shows its icon
    ["TOK08"] = {
        id = "TOK08", name = "Arcanite Dragonling", cost = "", cmc = 0, color = "C", type = "Creature",
        power = 3, toughness = 3, flying = true, isToken = true,
        art = "Interface\\Icons\\INV_Misc_Head_Dragon_01",
        creatureType = "Mechanical",
        text = "Airborne."
    },
    -- Settlements' Adds (Cards\Settlements.lua). Their models are borrowed from cards that
    -- already show them: Hillsbrad Miner (Peasant), Warsong Peon, Skeletal Soldier,
    -- Young Sawtooth Crocolisk and Diemetradon.
    ["TOK09"] = {   -- Goldshire
        id = "TOK09", name = "Peasant", cost = "", cmc = 0, color = "W", type = "Creature",
        power = 1, toughness = 2, support = true, isToken = true, displayId = 3629,
        creatureType = "Humanoid",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["TOK10"] = {   -- Razor Hill
        id = "TOK10", name = "Peon", cost = "", cmc = 0, color = "R", type = "Creature",
        power = 2, toughness = 1, haste = true, isToken = true, displayId = 11857,
        creatureType = "Humanoid",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["TOK11"] = {   -- Agamand Mills
        id = "TOK11", name = "Rattlecage Soldier", cost = "", cmc = 0, color = "B", type = "Creature",
        power = 3, toughness = 3, isToken = true, displayId = 7848,
        creatureType = "Undead",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TOK12"] = {   -- Stonard
        id = "TOK12", name = "Sawtooth Crocolisk", cost = "", cmc = 0, color = "G", type = "Creature",
        power = 3, toughness = 3, isToken = true, displayId = 814,
        creatureType = "Beast",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TOK13"] = {   -- Marshal's Refuge
        id = "TOK13", name = "Diemetradon Bull", cost = "", cmc = 0, color = "G", type = "Creature",
        power = 4, toughness = 4, trample = true, isToken = true, displayId = 8511,
        creatureType = "Beast",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
})
