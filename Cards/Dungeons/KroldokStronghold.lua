--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- DUNGEON CREATURES & BOSSES - UNLOCKED BY KILLING THEM (same isMob/isBoss tracking as zone creatures)
-- WoW Forever dungeon: npcIds from Wowhead (Forever)'s tooltips (zone 16842, though most of
-- its NPCs carry no zone there and were matched by name and id), displayIds from
-- forever.warcraftdb.com (api/data/node/npc/<id>). The Krol'dok Brute and Centurion also have
-- second ids (272199, 278310), which match by name. The final boss keeps its dedicated
-- BOSSxx card (Cards\Bosses.lua).
-- =========================================================================
TTS:AddCards({
    -- KROL'DOK STRONGHOLD
    ["KRD01"] = {
        id = "KRD01", name = "Twilight Outrider", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 139813,
        zone = "Krol'dok Stronghold", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 258102,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Charge."
    },
    ["KRD02"] = {
        id = "KRD02", name = "Twilight Grunt", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 140001,
        zone = "Krol'dok Stronghold", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 258042,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Ambush."
    },
    ["KRD03"] = {
        id = "KRD03", name = "Twilight Warlock", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 2, lifelink = true, isMob = true, isBoss = true, displayId = 139817,
        zone = "Krol'dok Stronghold", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 258100,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Leech."
    },
    ["KRD04"] = {
        id = "KRD04", name = "Krol'dok Shaman", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 4, support = true, isMob = true, isBoss = true, displayId = 326,
        zone = "Krol'dok Stronghold", creatureType = "Humanoid", faction = "Ogre", npcId = 257888,
        anthem = { tag = "faction", value = "Ogre", p = 1 },
        modelCam = { zoom = 0.70, camScale = 1.10, z = -0.15, rotation = 0.15 },
        text = "Support. Other Ogres you control get +1/+0."
    },
    ["KRD05"] = {
        id = "KRD05", name = "Krol'dok Brute", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 1045,
        zone = "Krol'dok Stronghold", creatureType = "Humanoid", faction = "Ogre", npcId = 258687,
        modelCam = { zoom = 0.70, camScale = 1.10, z = -0.15, rotation = 0.15 },
        text = "Cleave."
    },
    ["KRD06"] = {
        id = "KRD06", name = "Krol'dok Centurion", cost = "{3}{R}", cmc = 4, color = "R", type = "Creature",
        power = 4, toughness = 5, bulwark = 2, isMob = true, isBoss = true, displayId = 11571,
        zone = "Krol'dok Stronghold", creatureType = "Humanoid", faction = "Ogre", npcId = 257885,
        modelCam = { zoom = 0.70, camScale = 1.10, z = -0.15, rotation = 0.15 },
        text = "Shield Wall 2."
    },
    -- Bosses
    ["KRD07"] = {
        id = "KRD07", name = "Slavecrusher Grox", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 5, toughness = 4, trample = true, enrage = true, isMob = true, isBoss = true, displayId = 141217,
        zone = "Krol'dok Stronghold", creatureType = "Humanoid", faction = "Ogre", npcId = 258966,
        modelCam = { zoom = 0.70, camScale = 1.10, z = -0.15, rotation = 0.15 },
        text = "Cleave. Enrage."
    },
    ["KRD08"] = {
        id = "KRD08", name = "Twilight Commander Zarmok", cost = "{2}{R}{B}", cmc = 4, color = "R", type = "Creature",
        power = 4, toughness = 4, firstStrike = true, isMob = true, isBoss = true, displayId = 141219,
        zone = "Krol'dok Stronghold", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 258972,
        anthem = { tag = "faction", value = "Twilight's Hammer", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Ambush. Other Twilight's Hammer you control get +1/+1."
    },
    ["KRD09"] = {
        id = "KRD09", name = "War Handler Ashka", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 4, toughness = 4, haste = true, isMob = true, isBoss = true, displayId = 141443,
        zone = "Krol'dok Stronghold", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 259281,
        anthem = { tag = "type", value = "Beast", kw = { "haste" } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Charge. Beasts you control have Charge."
    },
    ["KRD10"] = {
        id = "KRD10", name = "Nar'gurk", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 6, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 141215,
        zone = "Krol'dok Stronghold", creatureType = "Humanoid", faction = "Ogre", npcId = 258964,
        modelCam = { zoom = 0.70, camScale = 1.10, z = -0.15, rotation = 0.15 },
        text = "Cleave."
    },
    -- Solo reward
    ["KRD11"] = {
        id = "KRD11", name = "Twilight Lieutenant", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 3, toughness = 4, firstStrike = true, isReward = true, displayId = 143142,
        zone = "Krol'dok Stronghold", creatureType = "Humanoid", faction = "Twilight's Hammer", npcEntry = 258104,
        anthem = { tag = "zone", value = "Krol'dok Stronghold", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Ambush. Other Krol'dok Stronghold denizens you control get +1/+1."
    },
})
