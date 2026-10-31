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
    -- DUROTAR
    ["DUR01"] = {
        id = "DUR01", name = "Vile Familiar", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 1185,
        zone = "Durotar", creatureType = "Humanoid", npcId = 3101,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DUR02"] = {
        id = "DUR02", name = "Clattering Scorpid", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 1, reach = true, isMob = true, isBoss = true, displayId = 2486,
        zone = "Durotar", creatureType = "Beast", npcId = 3125,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["DUR03"] = {
        id = "DUR03", name = "Dire Mottled Boar", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 1, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 381,
        zone = "Durotar", creatureType = "Beast", npcId = 3099,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["DUR04"] = {
        id = "DUR04", name = "Armored Scorpid", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 2487,
        zone = "Durotar", creatureType = "Beast", npcId = 3126,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["DUR05"] = {
        id = "DUR05", name = "Bloodtalon Taillasher", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 1960,
        zone = "Durotar", creatureType = "Beast", npcId = 3122,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["DUR06"] = {
        id = "DUR06", name = "Elder Mottled Boar", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 193,
        zone = "Durotar", creatureType = "Beast", npcId = 3100,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DUR07"] = {
        id = "DUR07", name = "Venomtail Scorpid", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 3, deathtouch = true, isMob = true, isBoss = true, displayId = 2732,
        zone = "Durotar", creatureType = "Beast", npcId = 3127,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["DUR08"] = {
        id = "DUR08", name = "Bloodtalon Scythemaw", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 6, toughness = 4, haste = true, isMob = true, isBoss = true, displayId = 1959,
        zone = "Durotar", creatureType = "Beast", npcId = 3123,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["DUR09"] = {
        id = "DUR09", name = "Dreadmaw Crocolisk", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 6, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 1250,
        zone = "Durotar", creatureType = "Beast", npcId = 3110,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    ["DUR10"] = {
        id = "DUR10", name = "Death Flayer", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 6, toughness = 8, deathtouch = true, isMob = true, isNamed = true, isBoss = true, displayId = 2491,
        zone = "Durotar", creatureType = "Beast", npcId = 5823,
        anthem = { tag = "zone", value = "Durotar", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal. Other Durotar denizens you control get +1/+1."
    },
    ["DUR12"] = {
        id = "DUR12", name = "Gazz'uz", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isNamed = true, isBoss = true, displayId = 240,
        zone = "Durotar", creatureType = "Humanoid", faction = "Burning Blade", npcId = 3204,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        etb = { ops = { { op = "token", id = "TOK06", n = 1 } } },
        text = "Arrival: Spawn: 1 Imp Add (1/1)."
    },
    -- Solo reward
    ["DUR11"] = {
        id = "DUR11", name = "Vol'jin", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 4, toughness = 4, deathtouch = true, isReward = true, displayId = 10357,
        zone = "Durotar", creatureType = "Humanoid", faction = "Troll", npcEntry = 10540,
        anthem = { tag = "faction", value = "Troll", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal. Other Trolls you control get +1/+1."
    },
})
