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
    -- REDRIDGE MOUNTAINS
    ["RED01"] = {
        id = "RED01", name = "Gray Forest Wolf", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 380,
        zone = "Redridge Mountains", creatureType = "Beast", npcId = 1922,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["RED02"] = {
        id = "RED02", name = "Tarantula", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, reach = true, isMob = true, isBoss = true, displayId = 366,
        zone = "Redridge Mountains", creatureType = "Beast", npcId = 442,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["RED03"] = {
        id = "RED03", name = "Redridge Poacher", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 551,
        zone = "Redridge Mountains", creatureType = "Humanoid", faction = "Gnoll", npcId = 424,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["RED04"] = {
        id = "RED04", name = "Redridge Mystic", cost = "{1}{W}", cmc = 2, color = "W", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 10789,
        zone = "Redridge Mountains", creatureType = "Humanoid", faction = "Gnoll", npcId = 430,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["RED05"] = {
        id = "RED05", name = "Murloc Flesheater", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 506,
        zone = "Redridge Mountains", creatureType = "Humanoid", faction = "Murloc", npcId = 422,
        modelCam = { zoom = 0.73, camScale = 1.08, z = -0.12, rotation = 0.15 },
        text = ""
    },
    ["RED06"] = {
        id = "RED06", name = "Redridge Basher", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 2, toughness = 3, isMob = true, isBoss = true, displayId = 609,
        zone = "Redridge Mountains", creatureType = "Humanoid", faction = "Gnoll", npcId = 446,
        anthem = { tag = "faction", value = "Gnoll", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Gnolls you control get +1/+0."
    },
    ["RED07"] = {
        id = "RED07", name = "Murloc Scout", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 3, toughness = 4, haste = true, isMob = true, isBoss = true, displayId = 391,
        zone = "Redridge Mountains", creatureType = "Humanoid", faction = "Murloc", npcId = 578,
        modelCam = { zoom = 0.68, camScale = 1.12, z = -0.12, rotation = 0.15 },
        text = "Quick."
    },
    ["RED08"] = {
        id = "RED08", name = "Blackrock Champion", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 6, toughness = 5, vigilance = true, isMob = true, isBoss = true, displayId = 6044,
        zone = "Redridge Mountains", creatureType = "Humanoid", faction = "Blackrock", npcId = 435,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant."
    },
    ["RED09"] = {
        id = "RED09", name = "Squiddic", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 5243,
        zone = "Redridge Mountains", creatureType = "Humanoid", faction = "Murloc", npcId = 14270,
        anthem = { tag = "faction", value = "Murloc", p = 1, t = 1 },
        modelCam = { zoom = 0.68, camScale = 1.12, z = -0.12, rotation = 0.15 },
        text = "Other Murlocs you control get +1/+1."
    },
    ["RED10"] = {
        id = "RED10", name = "Kazon", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 9, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 6041,
        zone = "Redridge Mountains", creatureType = "Humanoid", faction = "Blackrock", npcId = 584,
        modelCam = { zoom = 0.58, camScale = 1.20, z = -0.14, rotation = 0.15 },
        text = "Brutish."
    },
    -- Solo reward
    ["RED11"] = {
        id = "RED11", name = "Magistrate Solomon", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 4, isReward = true, displayId = 1753,
        zone = "Redridge Mountains", creatureType = "Humanoid", npcEntry = 344,
        anthem = { tag = "zone", value = "Redridge Mountains", t = 2 },
        etb = { ops = { { op = "heal", to = "self_player", n = 3 } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "When Magistrate Solomon enters the battlefield, you gain 3 life. Other Redridge Mountains denizens you control get +0/+2."
    },
})
