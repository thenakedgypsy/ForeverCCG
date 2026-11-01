--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- CRITTERS
-- One overcosted, keywordless 1/1 denizen per colour. Not collectible: no isBoss / isReward /
-- isGift flag, so every player can use them from the start (4 copies, like spells) and they
-- never count towards collected, mastered or the collection score (SoloEncounters.lua
-- GetCollectionScore), nor have foils. They carry no zone, so no solo deck picks them.
--   isCritter = true: hidden by the Deckbuilder's "Hide critters" checkbox (DeckBuilder.lua)
-- =========================================================================
TTS:AddCards({
    ["CRIT01"] = {
        id = "CRIT01", name = "Rabbit", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 1, toughness = 1, isCritter = true, displayId = 328,
        creatureType = "Critter",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["CRIT02"] = {
        id = "CRIT02", name = "Sheep", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 1, toughness = 1, isCritter = true, displayId = 856,
        creatureType = "Critter",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["CRIT03"] = {
        id = "CRIT03", name = "Rat", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 1, toughness = 1, isCritter = true, displayId = 1141,
        creatureType = "Critter",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["CRIT04"] = {
        id = "CRIT04", name = "Prairie Dog", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 1, toughness = 1, isCritter = true, displayId = 1072,
        creatureType = "Critter",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["CRIT05"] = {
        id = "CRIT05", name = "Squirrel", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 1, toughness = 1, isCritter = true, displayId = 134,
        creatureType = "Critter",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
})
