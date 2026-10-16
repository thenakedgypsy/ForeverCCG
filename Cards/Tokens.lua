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
})
