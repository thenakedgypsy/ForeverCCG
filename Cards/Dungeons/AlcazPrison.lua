--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- DUNGEON CREATURES & BOSSES - UNLOCKED BY KILLING THEM (same isMob/isBoss tracking as zone creatures)
-- WoW Forever dungeon: npcIds and zone from Wowhead (Forever)'s tooltips (zone 16620),
-- displayIds from forever.warcraftdb.com (api/data/node/npc/<id>). The Defias Mercenary and
-- Alcaz Jailer also have second ids (271780, 271784), which match by name. The final boss
-- keeps its dedicated BOSSxx card (Cards\Bosses.lua).
-- =========================================================================
TTS:AddCards({
    -- ALCAZ PRISON
    ["ALZ01"] = {
        id = "ALZ01", name = "Slavering Hound", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 6195,
        zone = "Alcaz Prison", creatureType = "Beast", npcId = 255267,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Charge."
    },
    ["ALZ02"] = {
        id = "ALZ02", name = "Alcaz Jailer", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 4, support = true, isMob = true, isBoss = true, displayId = 138843,
        zone = "Alcaz Prison", creatureType = "Humanoid", npcId = 255377,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["ALZ03"] = {
        id = "ALZ03", name = "Defias Mercenary", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 2315,
        zone = "Alcaz Prison", creatureType = "Humanoid", faction = "Defias", npcId = 255276,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Ambush."
    },
    ["ALZ04"] = {
        id = "ALZ04", name = "Defias Bounty Hunter", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 2, unblockable = true, isMob = true, isBoss = true, displayId = 138839,
        zone = "Alcaz Prison", creatureType = "Humanoid", faction = "Defias", npcId = 255309,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Stealth."
    },
    ["ALZ05"] = {
        id = "ALZ05", name = "Defias Truthfinder", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 3, lifelink = true, isMob = true, isBoss = true, displayId = 144356,
        zone = "Alcaz Prison", creatureType = "Humanoid", faction = "Defias", npcId = 255271,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Leech."
    },
    ["ALZ06"] = {
        id = "ALZ06", name = "Alcaz Chaplain", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 4, support = true, shielded = true, isMob = true, isBoss = true, displayId = 138722,
        zone = "Alcaz Prison", creatureType = "Humanoid", npcId = 255262,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support. Absorb."
    },
    ["ALZ07"] = {
        id = "ALZ07", name = "Arcane Servitor", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 2, flying = true, isMob = true, isBoss = true, displayId = 130209,
        zone = "Alcaz Prison", creatureType = "Elemental", npcId = 255369,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Airborne."
    },
    ["ALZ08"] = {
        id = "ALZ08", name = "Strashaz Soldier", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 4764,
        zone = "Alcaz Prison", creatureType = "Humanoid", faction = "Naga", npcId = 255995,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Ambush."
    },
    ["ALZ09"] = {
        id = "ALZ09", name = "Renegade Conjurer", cost = "{3}{R}", cmc = 4, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 2561,
        etb = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 3 } } },
        zone = "Alcaz Prison", creatureType = "Humanoid", npcId = 255364,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Arrival: Deal 3 damage to target enemy denizen."
    },
    ["ALZ10"] = {
        id = "ALZ10", name = "Molten Servitor", cost = "{3}{R}", cmc = 4, color = "R", type = "Creature",
        power = 5, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 1070,
        zone = "Alcaz Prison", creatureType = "Elemental", npcId = 255366,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Cleave."
    },
    ["ALZ11"] = {
        id = "ALZ11", name = "Frozen Servitor", cost = "{3}{U}", cmc = 4, color = "U", type = "Creature",
        power = 3, toughness = 5, isMob = true, isBoss = true, displayId = 5561,
        etb = { target = "enemy_creature", ops = { { op = "freeze", to = "target" } } },
        zone = "Alcaz Prison", creatureType = "Elemental", npcId = 255367,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Arrival: Freeze target enemy denizen."
    },
    ["ALZ12"] = {
        id = "ALZ12", name = "Strashaz Enchantress", cost = "{3}{U}", cmc = 4, color = "U", type = "Creature",
        power = 2, toughness = 4, shielded = true, isMob = true, isBoss = true, displayId = 4972,
        etb = { target = "enemy_creature", ops = { { op = "bounce", to = "target" } } },
        zone = "Alcaz Prison", creatureType = "Humanoid", faction = "Naga", npcId = 255373,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Absorb. Arrival: Return target enemy denizen to its owner's hand."
    },
    -- Bosses
    ["ALZ13"] = {
        id = "ALZ13", name = "Overseer Wrex", cost = "{3}{R}", cmc = 4, color = "R", type = "Creature",
        power = 4, toughness = 5, vigilance = true, bulwark = 2, isMob = true, isBoss = true, displayId = 7914,
        zone = "Alcaz Prison", creatureType = "Humanoid", npcId = 255391,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant. Shield Wall 2."
    },
    ["ALZ14"] = {
        id = "ALZ14", name = "Katerina the Cleaner", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 4, toughness = 3, deathtouch = true, firstStrike = true, isMob = true, isBoss = true, displayId = 2317,
        zone = "Alcaz Prison", creatureType = "Humanoid", npcId = 257016,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Ambush. Execute."
    },
    ["ALZ15"] = {
        id = "ALZ15", name = "Tidemistress Ca'zass", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 4, toughness = 6, reach = true, isMob = true, isBoss = true, displayId = 4973,
        zone = "Alcaz Prison", creatureType = "Humanoid", faction = "Naga", npcId = 255997,
        anthem = { tag = "faction", value = "Naga", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Ranged. Other Naga you control get +1/+1."
    },
    ["ALZ16"] = {
        id = "ALZ16", name = "The Questioner", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 4, toughness = 6, lifelink = true, isMob = true, isBoss = true, displayId = 140092,
        etb = { target = "enemy_creature", ops = { { op = "freeze", to = "target" } } },
        zone = "Alcaz Prison", creatureType = "Humanoid", npcId = 256236,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Leech. Arrival: Freeze target enemy denizen."
    },
    -- Solo reward
    ["ALZ17"] = {
        id = "ALZ17", name = "Commander Folkar", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 4, toughness = 4, firstStrike = true, isReward = true, displayId = 142414,
        zone = "Alcaz Prison", creatureType = "Humanoid", npcEntry = 260386,
        anthem = { tag = "zone", value = "Alcaz Prison", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Ambush. Other Alcaz Prison denizens you control get +1/+1."
    },
})
