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
    -- BLASTED LANDS
    ["BLA01"] = {
        id = "BLA01", name = "Starving Snickerfang", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 8050,
        zone = "Blasted Lands", creatureType = "Beast", npcId = 5984,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["BLA02"] = {
        id = "BLA02", name = "Snickerfang Hyena", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 2714,
        zone = "Blasted Lands", creatureType = "Beast", npcId = 5985,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["BLA03"] = {
        id = "BLA03", name = "Scorpok Stinger", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 6068,
        zone = "Blasted Lands", creatureType = "Beast", npcId = 5988,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["BLA04"] = {
        id = "BLA04", name = "Felbeast", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 7949,
        zone = "Blasted Lands", creatureType = "Demon", npcId = 8675,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BLA05"] = {
        id = "BLA05", name = "Redstone Crystalhide", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 798,
        zone = "Blasted Lands", creatureType = "Beast", npcId = 5991,
        modelCam = { zoom = 0.74, camScale = 1.08, z = -0.12, rotation = 0.15 },
        text = ""
    },
    ["BLA06"] = {
        id = "BLA06", name = "Helboar", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 11410,
        zone = "Blasted Lands", creatureType = "Demon", npcId = 5993,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BLA07"] = {
        id = "BLA07", name = "Shadowsworn Warlock", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 5, isMob = true, isBoss = true, displayId = 6789,
        zone = "Blasted Lands", creatureType = "Humanoid", npcId = 6008,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BLA08"] = {
        id = "BLA08", name = "Shadowsworn Enforcer", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 4, haste = true, isMob = true, isBoss = true, displayId = 7841,
        zone = "Blasted Lands", creatureType = "Humanoid", npcId = 6007,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["BLA09"] = {
        id = "BLA09", name = "Dreadmaul Mauler", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 7, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 14401,
        zone = "Blasted Lands", creatureType = "Humanoid", faction = "Ogre", npcId = 5977,
        modelCam = { zoom = 0.58, camScale = 1.20, z = -0.14, rotation = 0.15 },
        text = "Brutish."
    },
    ["BLA10"] = {
        id = "BLA10", name = "Dreadscorn", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 9, toughness = 9, lifelink = true, isMob = true, isBoss = true, displayId = 7844,
        zone = "Blasted Lands", creatureType = "Humanoid", npcId = 8304,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    -- Solo reward
    ["BLA11"] = {
        id = "BLA11", name = "Kum'isha the Collector", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 3, toughness = 4, isReward = true, displayId = 11653,
        zone = "Blasted Lands", creatureType = "Humanoid", npcEntry = 7363,
        etb = { ops = { { op = "raise", src = "own" } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "When Kum'isha the Collector enters the battlefield, return a denizen card from your graveyard to the battlefield."
    },
})
