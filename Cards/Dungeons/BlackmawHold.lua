--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- DUNGEON CREATURES & BOSSES - UNLOCKED BY KILLING THEM (same isMob/isBoss tracking as zone creatures)
-- WoW Forever dungeon: npcIds and zone from Wowhead (Forever)'s tooltips (zone 16554), displayIds
-- from Wowhead's model viewer (supplied by hand, 2026-11-17; the four also in the client's
-- creature cache matched). Blackmaw Behemoth (247207) has no displayId yet, so it has no card.
-- The final boss keeps its dedicated BOSSxx card (Cards\Bosses.lua).
-- =========================================================================
TTS:AddCards({
    -- BLACKMAW HOLD
    ["BMH01"] = {
        id = "BMH01", name = "Flesh Maggot", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 2, deathtouch = true, isMob = true, isBoss = true, displayId = 7899,
        zone = "Blackmaw Hold", creatureType = "Beast", npcId = 268878,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["BMH02"] = {
        id = "BMH02", name = "Felfire Imp", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 121882,
        zone = "Blackmaw Hold", creatureType = "Demon", npcId = 247249,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["BMH03"] = {
        id = "BMH03", name = "Festering Swarmer", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, lifelink = true, isMob = true, isBoss = true, displayId = 1141,
        zone = "Blackmaw Hold", creatureType = "Beast", npcId = 268865,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain."
    },
    ["BMH04"] = {
        id = "BMH04", name = "Bloodstarved Frenzy", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 15101,
        zone = "Blackmaw Hold", creatureType = "Beast", npcId = 268834,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["BMH05"] = {
        id = "BMH05", name = "Blackmaw Thrall", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 897,
        zone = "Blackmaw Hold", creatureType = "Humanoid", faction = "Furbolg", npcId = 250023,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BMH06"] = {
        id = "BMH06", name = "Blackmaw Berserker", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 2, haste = true, enrage = true, isMob = true, isBoss = true, displayId = 5851,
        zone = "Blackmaw Hold", creatureType = "Humanoid", faction = "Furbolg", npcId = 247237,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick. Enrage."
    },
    ["BMH07"] = {
        id = "BMH07", name = "Blackmaw Headhunter", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 6800,
        zone = "Blackmaw Hold", creatureType = "Humanoid", faction = "Furbolg", npcId = 250027,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["BMH08"] = {
        id = "BMH08", name = "Blackmaw Spearfisher", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 4, reach = true, isMob = true, isBoss = true, displayId = 1997,
        zone = "Blackmaw Hold", creatureType = "Humanoid", faction = "Furbolg", npcId = 258152,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["BMH09"] = {
        id = "BMH09", name = "Blackmaw Shaman", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 4, support = true, isMob = true, isBoss = true, displayId = 6820,
        zone = "Blackmaw Hold", creatureType = "Humanoid", faction = "Furbolg", npcId = 258508,
        anthem = { tag = "faction", value = "Furbolg", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support. Other Furbolgs you control get +1/+0."
    },
    ["BMH10"] = {
        id = "BMH10", name = "Blackmaw Druid", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 4, support = true, shielded = true, isMob = true, isBoss = true, displayId = 3024,
        zone = "Blackmaw Hold", creatureType = "Humanoid", faction = "Furbolg", npcId = 258516,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support. Shielded."
    },
    ["BMH11"] = {
        id = "BMH11", name = "Legashi Slayer", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 2, unblockable = true, isMob = true, isBoss = true, displayId = 2007,
        zone = "Blackmaw Hold", creatureType = "Demon", faction = "Satyr", npcId = 255347,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Invisible."
    },
    ["BMH12"] = {
        id = "BMH12", name = "Legashi Subjugator", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 3, deathtouch = true, isMob = true, isBoss = true, displayId = 2011,
        zone = "Blackmaw Hold", creatureType = "Demon", faction = "Satyr", npcId = 247235,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal."
    },
    ["BMH13"] = {
        id = "BMH13", name = "Mopes", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 3, haste = true, firstStrike = true, isMob = true, isBoss = true, displayId = 130499,
        zone = "Blackmaw Hold", creatureType = "Demon", npcId = 247412,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick. Strikes-First."
    },
    ["BMH14"] = {
        id = "BMH14", name = "Legashi Ritualist", cost = "{3}{B}", cmc = 4, color = "B", type = "Creature",
        power = 2, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 2010,
        zone = "Blackmaw Hold", creatureType = "Demon", faction = "Satyr", npcId = 258668,
        anthem = { tag = "faction", value = "Satyr", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Drain. Other Satyrs you control get +1/+0."
    },
    ["BMH15"] = {
        id = "BMH15", name = "Legashi Plaguebringer", cost = "{3}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 11345,
        etb = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 3 } } },
        zone = "Blackmaw Hold", creatureType = "Demon", faction = "Satyr", npcId = 268864,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Arrival: Deal 3 damage to target enemy denizen."
    },
    ["BMH16"] = {
        id = "BMH16", name = "Tunnelweb Matriarch", cost = "{3}{G}", cmc = 4, color = "G", type = "Creature",
        power = 3, toughness = 5, reach = true, isMob = true, isBoss = true, displayId = 2424,
        zone = "Blackmaw Hold", creatureType = "Beast", npcId = 250034,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Anti-Air."
    },
    ["BMH17"] = {
        id = "BMH17", name = "Depraved Owlbeast", cost = "{3}{G}", cmc = 4, color = "G", type = "Creature",
        power = 4, toughness = 5, enrage = true, bulwark = 2, isMob = true, isBoss = true, displayId = 12238,
        zone = "Blackmaw Hold", creatureType = "Beast", npcId = 258264,
        modelCam = { zoom = 0.70, camScale = 1.10, z = -0.15, rotation = 0.15 },
        text = "Enrage. Bulwark 2."
    },
    ["BMH18"] = {
        id = "BMH18", name = "Blackmaw Champion", cost = "{3}{G}", cmc = 4, color = "G", type = "Creature",
        power = 5, toughness = 4, trample = true, isMob = true, isBoss = true, displayId = 1010,
        zone = "Blackmaw Hold", creatureType = "Humanoid", faction = "Furbolg", npcId = 255394,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Brutish."
    },
    -- Bosses
    ["BMH19"] = {
        id = "BMH19", name = "Elder Shaman Bloodmane", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 4, toughness = 5, support = true, isMob = true, isBoss = true, displayId = 130440,
        zone = "Blackmaw Hold", creatureType = "Humanoid", faction = "Furbolg", npcId = 247209,
        anthem = { tag = "faction", value = "Furbolg", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support. Other Furbolgs you control get +1/+1."
    },
    ["BMH20"] = {
        id = "BMH20", name = "Withermaw", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 6, toughness = 6, trample = true, reach = true, isMob = true, isBoss = true, displayId = 140708,
        zone = "Blackmaw Hold", creatureType = "Beast", npcId = 247195,
        modelCam = { zoom = 0.65, camScale = 1.15, z = -0.15, rotation = 0.15 },
        text = "Brutish. Anti-Air."
    },
    ["BMH21"] = {
        id = "BMH21", name = "Bonesnout the Unbroken", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 5, toughness = 6, vigilance = true, bulwark = 2, isMob = true, isBoss = true, displayId = 130427,
        zone = "Blackmaw Hold", creatureType = "Undead", npcId = 247198,
        modelCam = { zoom = 0.70, camScale = 1.10, z = -0.15, rotation = 0.15 },
        text = "Vigilant. Bulwark 2."
    },
    ["BMH22"] = {
        id = "BMH22", name = "Impaan the Imprisoner", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 5, toughness = 5, deathtouch = true, isMob = true, isBoss = true, displayId = 130432,
        etb = { target = "enemy_creature", ops = { { op = "freeze", to = "target" } } },
        zone = "Blackmaw Hold", creatureType = "Demon", npcId = 247206,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Fatal. Arrival: Freeze target enemy denizen."
    },
    ["BMH23"] = {
        id = "BMH23", name = "Unbound Spirit", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 6, toughness = 6, trample = true, hexproof = true, isMob = true, isBoss = true, displayId = 131644,
        zone = "Blackmaw Hold", creatureType = "Elemental", npcId = 247231,
        modelCam = { zoom = 0.55, camScale = 1.30, z = -0.20, rotation = 0.15 },
        text = "Brutish. Warded."
    },
    -- Solo reward
    ["BMH24"] = {
        id = "BMH24", name = "Elder Bramblesnap", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 3, toughness = 5, support = true, isReward = true, displayId = 146761,
        zone = "Blackmaw Hold", creatureType = "Humanoid", faction = "Furbolg", npcEntry = 248765,
        anthem = { tag = "zone", value = "Blackmaw Hold", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support. Other Blackmaw Hold denizens you control get +1/+1."
    },
})
