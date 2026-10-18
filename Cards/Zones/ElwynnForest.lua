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
    -- ELWYNN FOREST
    ["ELW01"] = {
        id = "ELW01", name = "Kobold Vermin", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 10913,
        zone = "Elwynn Forest", creatureType = "Humanoid", faction = "Kobold", npcId = 6,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ELW02"] = {
        id = "ELW02", name = "Kobold Worker", cost = "{W}", cmc = 1, color = "W", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 10912,
        zone = "Elwynn Forest", creatureType = "Humanoid", faction = "Kobold", npcId = 257,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        etb = { ops = { { op = "token", id = "TOK02", n = 1 } } },
        text = "Arrival: Spawn: 1 Kobold Digger Add (1/1)."
    },
    ["ELW03"] = {
        id = "ELW03", name = "Defias Thug", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 5035,
        zone = "Elwynn Forest", creatureType = "Humanoid", faction = "Defias", npcId = 38,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ELW04"] = {
        id = "ELW04", name = "Stonetusk Boar", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 503,
        zone = "Elwynn Forest", creatureType = "Beast", npcId = 113,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ELW05"] = {
        id = "ELW05", name = "Kobold Tunneler", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 2, toughness = 3, isMob = true, isBoss = true, displayId = 139,
        zone = "Elwynn Forest", creatureType = "Humanoid", faction = "Kobold", npcId = 475,
        anthem = { tag = "faction", value = "Kobold", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Kobolds you control get +1/+0."
    },
    ["ELW06"] = {
        id = "ELW06", name = "Porcine Entourage", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, support = true, isMob = true, isBoss = true, displayId = 377,
        zone = "Elwynn Forest", creatureType = "Beast", npcId = 390,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["ELW07"] = {
        id = "ELW07", name = "Defias Rogue Wizard", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 3, toughness = 4, firstStrike = true, isMob = true, isBoss = true, displayId = 2359,
        zone = "Elwynn Forest", creatureType = "Humanoid", faction = "Defias", npcId = 474,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Strikes-First."
    },
    ["ELW08"] = {
        id = "ELW08", name = "Murloc Forager", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 5, toughness = 6, isMob = true, isBoss = true, displayId = 441,
        zone = "Elwynn Forest", creatureType = "Humanoid", faction = "Murloc", npcId = 46,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ELW09"] = {
        id = "ELW09", name = "Murloc Lurker", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 983,
        zone = "Elwynn Forest", creatureType = "Humanoid", faction = "Murloc", npcId = 732,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        onDeath = { ops = { { op = "token", id = "TOK01", n = 2 } } },
        text = "Martyrdom: Spawn: 2 Murloc Tadpole Adds (1/1)."
    },
    ["ELW10"] = {
        id = "ELW10", name = "Gruff Swiftbite", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 8, toughness = 8, isMob = true, isBoss = true, displayId = 175,
        zone = "Elwynn Forest", creatureType = "Humanoid", npcId = 100,
        anthem = { tag = "zone", value = "Elwynn Forest", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Elwynn Forest denizens you control get +1/+1."
    },
    -- Solo reward
    ["ELW11"] = {
        id = "ELW11", name = "Marshal Dughan", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 3, vigilance = true, isReward = true, displayId = 1985,
        zone = "Elwynn Forest", creatureType = "Humanoid", npcEntry = 240,
        anthem = { tag = "zone", value = "Elwynn Forest", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant. Other Elwynn Forest denizens you control get +1/+1."
    },
})
