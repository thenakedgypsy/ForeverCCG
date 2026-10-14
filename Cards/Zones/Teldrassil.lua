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
    -- TELDRASSIL
    ["TEL01"] = {
        id = "TEL01", name = "Young Nightsaber", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 11454,
        zone = "Teldrassil", creatureType = "Beast", npcId = 2031,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["TEL02"] = {
        id = "TEL02", name = "Young Thistle Boar", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 8869,
        zone = "Teldrassil", creatureType = "Beast", npcId = 1984,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TEL03"] = {
        id = "TEL03", name = "Mangy Nightsaber", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 11448,
        zone = "Teldrassil", creatureType = "Beast", npcId = 2032,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["TEL04"] = {
        id = "TEL04", name = "Webwood Spider", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 709,
        zone = "Teldrassil", creatureType = "Beast", npcId = 1986,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["TEL05"] = {
        id = "TEL05", name = "Webwood Lurker", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 2, deathtouch = true, unblockable = true, isMob = true, isBoss = true, displayId = 760,
        zone = "Teldrassil", creatureType = "Beast", npcId = 1998,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch, Cannot be blocked."
    },
    ["TEL06"] = {
        id = "TEL06", name = "Strigid Owl", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 2, flying = true, isMob = true, isBoss = true, displayId = 10832,
        zone = "Teldrassil", creatureType = "Beast", npcId = 1995,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["TEL07"] = {
        id = "TEL07", name = "Gnarlpine Shaman", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 3, toughness = 5, isMob = true, isBoss = true, displayId = 897,
        zone = "Teldrassil", creatureType = "Humanoid", faction = "Furbolg", npcId = 2009,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TEL08"] = {
        id = "TEL08", name = "Gnarlpine Defender", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 4, toughness = 5, vigilance = true, isMob = true, isBoss = true, displayId = 6801,
        zone = "Teldrassil", creatureType = "Humanoid", faction = "Furbolg", npcId = 2010,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["TEL09"] = {
        id = "TEL09", name = "Strigid Screecher", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 5, toughness = 5, flying = true, isMob = true, isBoss = true, displayId = 4877,
        zone = "Teldrassil", creatureType = "Beast", npcId = 1996,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["TEL10"] = {
        id = "TEL10", name = "Blackmoss the Fetid", cost = "{5}{G}{G}", cmc = 7, color = "G", type = "Creature",
        power = 8, toughness = 10, isMob = true, isBoss = true, displayId = 1549,
        zone = "Teldrassil", creatureType = "Elemental", npcId = 3535,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
})
