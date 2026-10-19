--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- DUNGEON CREATURES & BOSSES - UNLOCKED BY KILLING THEM (same isMob/isBoss tracking as zone creatures)
-- Names / displayIds / npcId come from the classicdb creature_template table; all are dungeon elites.
-- Final dungeon bosses keep their dedicated BOSSxx cards below.
-- =========================================================================
TTS:AddCards({
    -- MARAUDON
    ["MAR01"] = {
        id = "MAR01", name = "Putridus Shadowstalker", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, unblockable = true, isMob = true, isBoss = true, displayId = 2021,
        zone = "Maraudon", creatureType = "Demon", faction = "Satyr", npcId = 11792,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Invisible."
    },
    ["MAR02"] = {
        id = "MAR02", name = "Barbed Lasher", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 5, reach = true, isMob = true, isBoss = true, displayId = 12347,
        zone = "Maraudon", creatureType = "Elemental", npcId = 12219,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["MAR03"] = {
        id = "MAR03", name = "Deeprot Stomper", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 2079,
        zone = "Maraudon", creatureType = "Elemental", npcId = 13141,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["MAR04"] = {
        id = "MAR04", name = "Celebrian Dryad", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 11714,
        zone = "Maraudon", creatureType = "Humanoid", npcId = 11793,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["MAR05"] = {
        id = "MAR05", name = "Theradrim Guardian", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 5, toughness = 5, support = true, isMob = true, isBoss = true, displayId = 11712,
        zone = "Maraudon", creatureType = "Elemental", npcId = 11784,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Support."
    },
    ["MAR06"] = {
        id = "MAR06", name = "Razorlash", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 6, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 12389,
        zone = "Maraudon", creatureType = "Elemental", npcId = 12258,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["MAR07"] = {
        id = "MAR07", name = "Noxxion", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 6, toughness = 8, deathtouch = true, isMob = true, isBoss = true, displayId = 11172,
        zone = "Maraudon", creatureType = "Elemental", npcId = 13282,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["MAR08"] = {
        id = "MAR08", name = "Lord Vyletongue", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 7, firstStrike = true, isMob = true, isBoss = true, displayId = 12334,
        zone = "Maraudon", creatureType = "Demon", npcId = 12236,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["MAR09"] = {
        id = "MAR09", name = "Tinkerer Gizlock", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 7, firstStrike = true, isMob = true, isBoss = true, displayId = 7125,
        zone = "Maraudon", creatureType = "Humanoid", npcId = 13601,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["MAR10"] = {
        id = "MAR10", name = "Celebras the Cursed", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 7, toughness = 8, lifelink = true, isMob = true, isBoss = true, displayId = 12350,
        zone = "Maraudon", creatureType = "Humanoid", npcId = 12225,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["MAR11"] = {
        id = "MAR11", name = "Rotgrip", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 9, toughness = 8, trample = true, isMob = true, isBoss = true, displayId = 13589,
        zone = "Maraudon", creatureType = "Beast", npcId = 13596,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Brutish."
    },
    ["MAR12"] = {
        id = "MAR12", name = "Landslide", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 7, toughness = 9, support = true, isMob = true, isBoss = true, displayId = 12293,
        zone = "Maraudon", creatureType = "Giant", npcId = 12203,
        anthem = { tag = "zone", value = "Maraudon", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Support. Other Maraudon denizens you control get +1/+1."
    },
    -- Solo reward
    ["MAR13"] = {
        id = "MAR13", name = "Meshlok the Harvester", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 5, toughness = 6, trample = true, isReward = true, displayId = 9014,
        zone = "Maraudon", creatureType = "Elemental", npcEntry = 12237,
        anthem = { tag = "type", value = "Elemental", p = 1, t = 1 },
        modelCam = { zoom = 0.70, camScale = 1.15, z = -0.18, rotation = 0.15 },
        text = "Brutish. Other Elementals you control get +1/+1."
    },
})
