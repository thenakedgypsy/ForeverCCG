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
    -- THE BARRENS
    ["BRN01"] = {
        id = "BRN01", name = "Kolkar Wrangler", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 9442,
        zone = "The Barrens", creatureType = "Humanoid", npcId = 3272,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BRN02"] = {
        id = "BRN02", name = "Sunscale Screecher", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 1747,
        zone = "The Barrens", creatureType = "Beast", npcId = 3255,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["BRN03"] = {
        id = "BRN03", name = "Savannah Prowler", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 1973,
        zone = "The Barrens", creatureType = "Beast", npcId = 3425,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["BRN04"] = {
        id = "BRN04", name = "Hecklefang Hyena", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 2710,
        zone = "The Barrens", creatureType = "Beast", npcId = 4127,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["BRN05"] = {
        id = "BRN05", name = "Theramore Marine", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 2, firstStrike = true, vigilance = true, isMob = true, isBoss = true, displayId = 1858,
        zone = "The Barrens", creatureType = "Humanoid", npcId = 3385,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First, Vigilant."
    },
    ["BRN06"] = {
        id = "BRN06", name = "Stormsnout", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 1537,
        zone = "The Barrens", creatureType = "Beast", npcId = 3240,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BRN07"] = {
        id = "BRN07", name = "Bael'dun Excavator", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 1968,
        zone = "The Barrens", creatureType = "Humanoid", npcId = 3374,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BRN08"] = {
        id = "BRN08", name = "Silithid Swarmer", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 4, toughness = 4, deathtouch = true, isMob = true, isBoss = true, displayId = 2731,
        zone = "The Barrens", creatureType = "Beast", npcId = 3252,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["BRN09"] = {
        id = "BRN09", name = "Stormhide", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 1539,
        zone = "The Barrens", creatureType = "Beast", npcId = 3238,
        modelCam = { zoom = 0.82, camScale = 1.02, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BRN10"] = {
        id = "BRN10", name = "Azzere the Skyblade", cost = "{5}{U}{U}", cmc = 7, color = "U", type = "Creature",
        power = 8, toughness = 8, flying = true, isMob = true, isBoss = true, displayId = 2702,
        zone = "The Barrens", creatureType = "Beast", npcId = 5834,
        modelCam = { zoom = 0.58, camScale = 1.20, z = -0.14, rotation = 0.15 },
        text = "Airborne."
    },
    -- Solo reward
    ["BRN11"] = {
        id = "BRN11", name = "Mankrik", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 2, haste = true, isReward = true, displayId = 3855,
        zone = "The Barrens", creatureType = "Humanoid", npcEntry = 3432,
        rally = { tag = "zone", value = "The Barrens", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick. Gets +1/+0 for each other Barrens creature you control."
    },
})
