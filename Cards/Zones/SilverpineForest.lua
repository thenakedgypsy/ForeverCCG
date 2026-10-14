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
    -- SILVERPINE FOREST
    ["SIL01"] = {
        id = "SIL01", name = "Moonrage Whitescalp", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 11180,
        zone = "Silverpine Forest", creatureType = "Humanoid", faction = "Worgen", npcId = 1769,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SIL02"] = {
        id = "SIL02", name = "Mottled Worg", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 246,
        zone = "Silverpine Forest", creatureType = "Beast", npcId = 1766,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["SIL03"] = {
        id = "SIL03", name = "Ferocious Grizzled Bear", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 1006,
        zone = "Silverpine Forest", creatureType = "Beast", npcId = 1778,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SIL04"] = {
        id = "SIL04", name = "Moonrage Glutton", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 1947,
        zone = "Silverpine Forest", creatureType = "Humanoid", faction = "Worgen", npcId = 1779,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SIL05"] = {
        id = "SIL05", name = "Vile Fin Shredder", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 441,
        zone = "Silverpine Forest", creatureType = "Humanoid", faction = "Murloc", npcId = 1767,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SIL06"] = {
        id = "SIL06", name = "Giant Grizzled Bear", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 4, isMob = true, isBoss = true, displayId = 820,
        zone = "Silverpine Forest", creatureType = "Beast", npcId = 1797,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SIL07"] = {
        id = "SIL07", name = "Mist Creeper", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 3, toughness = 3, deathtouch = true, isMob = true, isBoss = true, displayId = 760,
        zone = "Silverpine Forest", creatureType = "Beast", npcId = 1781,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["SIL08"] = {
        id = "SIL08", name = "Bloodsnout Worg", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 6, toughness = 4, isMob = true, isBoss = true, displayId = 741,
        zone = "Silverpine Forest", creatureType = "Beast", npcId = 1923,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SIL09"] = {
        id = "SIL09", name = "Ravenclaw Guardian", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 5, toughness = 6, vigilance = true, isMob = true, isBoss = true, displayId = 370,
        zone = "Silverpine Forest", creatureType = "Undead", npcId = 1973,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["SIL10"] = {
        id = "SIL10", name = "Ravenclaw Regent", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 8, toughness = 9, vigilance = true, isMob = true, isBoss = true, displayId = 1019,
        zone = "Silverpine Forest", creatureType = "Undead", npcId = 2283,
        modelCam = { zoom = 0.63, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Vigilance."
    },
    -- Solo reward
    ["SIL11"] = {
        id = "SIL11", name = "High Executor Hadrec", cost = "{3}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 3, isReward = true, displayId = 3545,
        zone = "Silverpine Forest", creatureType = "Undead", npcEntry = 1952,
        anthem = { tag = "zone", value = "Silverpine Forest", t = 1, kw = { "lifelink" } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Silverpine Forest creatures you control get +0/+1 and Lifelink."
    },
})
