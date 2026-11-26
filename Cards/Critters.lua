--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- CRITTERS
-- Three overcosted, keywordless denizens per colour (a 1/1 for 3, a 1/2 for 4, a 2/2 for 5).
-- Not collectible: no isBoss / isReward /
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
    ["CRIT06"] = {
        id = "CRIT06", name = "Chicken", cost = "{3}{W}", cmc = 4, color = "W", type = "Creature",
        power = 1, toughness = 2, isCritter = true, displayId = 149203,
        creatureType = "Critter",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["CRIT07"] = {
        id = "CRIT07", name = "Hare", cost = "{4}{W}", cmc = 5, color = "W", type = "Creature",
        power = 2, toughness = 2, isCritter = true, displayId = 1560,
        creatureType = "Critter",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["CRIT08"] = {
        id = "CRIT08", name = "Toad", cost = "{3}{U}", cmc = 4, color = "U", type = "Creature",
        power = 1, toughness = 2, isCritter = true, displayId = 901,
        creatureType = "Critter",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["CRIT09"] = {
        id = "CRIT09", name = "Crab", cost = "{4}{U}", cmc = 5, color = "U", type = "Creature",
        power = 2, toughness = 2, isCritter = true, displayId = 5557,
        creatureType = "Critter",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["CRIT10"] = {
        id = "CRIT10", name = "Tainted Cockroach", cost = "{3}{B}", cmc = 4, color = "B", type = "Creature",
        power = 1, toughness = 2, isCritter = true, displayId = 2177,
        creatureType = "Critter",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["CRIT11"] = {
        id = "CRIT11", name = "Snake", cost = "{4}{B}", cmc = 5, color = "B", type = "Creature",
        power = 2, toughness = 2, isCritter = true, displayId = 1206,
        creatureType = "Critter",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["CRIT12"] = {
        id = "CRIT12", name = "Fire Beetle", cost = "{3}{R}", cmc = 4, color = "R", type = "Creature",
        power = 1, toughness = 2, isCritter = true, displayId = 8971,
        creatureType = "Critter",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["CRIT13"] = {
        id = "CRIT13", name = "Lava Crab", cost = "{4}{R}", cmc = 5, color = "R", type = "Creature",
        power = 2, toughness = 2, isCritter = true, displayId = 5560,
        creatureType = "Critter",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["CRIT14"] = {
        id = "CRIT14", name = "Skunk", cost = "{3}{G}", cmc = 4, color = "G", type = "Creature",
        power = 1, toughness = 2, isCritter = true, displayId = 144358,
        creatureType = "Critter",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["CRIT15"] = {
        id = "CRIT15", name = "Frog", cost = "{4}{G}", cmc = 5, color = "G", type = "Creature",
        power = 2, toughness = 2, isCritter = true, displayId = 6297,
        creatureType = "Critter",
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    -- The secret one: Kel'Thuzad's cat, for 100 critter kills (Systems\Critters.lua). Free, and
    -- while it's out your other Critters get +2/+2 and their cards cost {1} (E:CastCost).
    ["BIGGLES"] = {
        id = "BIGGLES", name = "Mr. Bigglesworth", cost = "{0}", cmc = 0, color = "C", type = "Creature",
        power = 1, toughness = 1, unique = true, alwaysFoil = true, isMob = true, isBoss = true, isNamed = true,
        critterUnlock = 100,   -- critter kills that unlock it (all 4 copies at once)
        critterCost = "{1}",   -- what your Critter cards cost while it's out
        displayId = 9989,      -- White Kitten (classic npc 7386): a white cat, as he is
        creatureType = "Critter", npcId = 245234,
        anthem = { tag = "type", value = "Critter", p = 2, t = 2 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Unique. Other Critters you control get +2/+2. Your Critter cards cost {1}."
    },
})
