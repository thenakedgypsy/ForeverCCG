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
    -- DUSKWOOD
    ["DSK01"] = {
        id = "DSK01", name = "Skeletal Warrior", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 200,
        zone = "Duskwood", creatureType = "Undead", npcId = 48,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DSK02"] = {
        id = "DSK02", name = "Young Black Ravager", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 246,
        zone = "Duskwood", creatureType = "Beast", npcId = 923,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["DSK03"] = {
        id = "DSK03", name = "Skeletal Horror", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 9786,
        zone = "Duskwood", creatureType = "Undead", npcId = 202,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DSK04"] = {
        id = "DSK04", name = "Black Widow Hatchling", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 368,
        zone = "Duskwood", creatureType = "Beast", npcId = 930,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["DSK05"] = {
        id = "DSK05", name = "Defias Night Runner", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 2, haste = true, firstStrike = true, isMob = true, isBoss = true, displayId = 4276,
        zone = "Duskwood", creatureType = "Humanoid", faction = "Defias", npcId = 215,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First, Quick."
    },
    ["DSK06"] = {
        id = "DSK06", name = "Carrion Recluse", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 2, deathtouch = true, isMob = true, isBoss = true, displayId = 545,
        zone = "Duskwood", creatureType = "Beast", npcId = 949,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["DSK07"] = {
        id = "DSK07", name = "Nightbane Worgen", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 657,
        zone = "Duskwood", creatureType = "Humanoid", faction = "Worgen", npcId = 898,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DSK08"] = {
        id = "DSK08", name = "Plague Spreader", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 4, toughness = 6, isMob = true, isBoss = true, displayId = 519,
        zone = "Duskwood", creatureType = "Undead", npcId = 604,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DSK09"] = {
        id = "DSK09", name = "Nightbane Dark Runner", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 5, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 736,
        zone = "Duskwood", creatureType = "Humanoid", faction = "Worgen", npcId = 205,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["DSK10"] = {
        id = "DSK10", name = "Nefaru", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 11181,
        zone = "Duskwood", creatureType = "Humanoid", npcId = 534,
        modelCam = { zoom = 0.77, camScale = 1.06, z = -0.11, rotation = 0.15 },
        text = ""
    },
    -- Solo reward
    ["DSK11"] = {
        id = "DSK11", name = "Lord Ello Ebonlocke", cost = "{3}{W}", cmc = 4, color = "W", type = "Creature",
        power = 3, toughness = 4, isReward = true, displayId = 4321,
        zone = "Duskwood", creatureType = "Humanoid", npcEntry = 263,
        anthem = { tag = "zone", value = "Duskwood", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Duskwood creatures you control get +1/+1."
    },
})
