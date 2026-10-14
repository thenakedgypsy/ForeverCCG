--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- ZONE CREATURES (10 per zone) - UNLOCKED BY KILLING THEM (isBoss = true reuses BossTracker as-is)
-- Names / displayIds / creatureId come from the classicdb creature_template table.
-- =========================================================================
TTS:AddCards({
    -- WINTERSPRING
    ["WIN01"] = {
        id = "WIN01", name = "Winterspring Owl", cost = "{W}", cmc = 1, color = "W", type = "Creature",
        power = 1, toughness = 1, flying = true, isMob = true, isBoss = true, displayId = 6212,
        zone = "Winterspring", creatureType = "Beast", npcId = 7455,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["WIN02"] = {
        id = "WIN02", name = "Ice Thistle Yeti", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 10579,
        zone = "Winterspring", creatureType = "Humanoid", npcId = 7458,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WIN03"] = {
        id = "WIN03", name = "Shardtooth Mauler", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 8842,
        zone = "Winterspring", creatureType = "Beast", npcId = 7443,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["WIN04"] = {
        id = "WIN04", name = "Chillwind Chimaera", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 1, toughness = 2, flying = true, isMob = true, isBoss = true, displayId = 10810,
        zone = "Winterspring", creatureType = "Beast", npcId = 7448,
        modelCam = { zoom = 0.77, camScale = 1.06, z = -0.11, rotation = 0.15 },
        text = "Flying."
    },
    ["WIN05"] = {
        id = "WIN05", name = "Moontouched Owlbeast", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 12237,
        zone = "Winterspring", creatureType = "Humanoid", npcId = 7453,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WIN06"] = {
        id = "WIN06", name = "Elder Shardtooth", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 4, isMob = true, isBoss = true, displayId = 8837,
        zone = "Winterspring", creatureType = "Beast", npcId = 7445,
        modelCam = { zoom = 0.73, camScale = 1.08, z = -0.12, rotation = 0.15 },
        text = ""
    },
    ["WIN07"] = {
        id = "WIN07", name = "Chillwind Ravager", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 10809,
        zone = "Winterspring", creatureType = "Beast", npcId = 7449,
        modelCam = { zoom = 0.73, camScale = 1.08, z = -0.12, rotation = 0.15 },
        text = ""
    },
    ["WIN08"] = {
        id = "WIN08", name = "Winterspring Screecher", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 4, toughness = 4, flying = true, isMob = true, isBoss = true, displayId = 10833,
        zone = "Winterspring", creatureType = "Beast", npcId = 7456,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = "Flying."
    },
    ["WIN09"] = {
        id = "WIN09", name = "Frostsaber Huntress", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 6, toughness = 5, firstStrike = true, isMob = true, isBoss = true, displayId = 11444,
        zone = "Winterspring", creatureType = "Beast", npcId = 7433,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["WIN10"] = {
        id = "WIN10", name = "Lady Hederine", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 10, toughness = 10, isMob = true, isBoss = true, displayId = 10925,
        zone = "Winterspring", creatureType = "Demon", npcId = 10201,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = ""
    },
})
