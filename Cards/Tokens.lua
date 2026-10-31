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
        id = "TOK06", name = "Imp", cost = "", cmc = 0, color = "B", type = "Creature",
        power = 1, toughness = 1, isToken = true, displayId = 4449,   -- warlock imp model
        creatureType = "Demon",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
})
