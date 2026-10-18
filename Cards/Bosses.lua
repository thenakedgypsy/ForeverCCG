--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- BOSS CARDS (WITH RESTORED ART PATHS & 3D MODEL DATA)
-- =========================================================================
TTS:AddCards({
    -- RFC: Bazzalan
    ["BOSS01"] = {
        id = "BOSS01", name = "Bazzalan", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 4, toughness = 4, isBoss = true, displayId = 2007, achievementId = 629,
        zone = "Ragefire Chasm", creatureType = "Demon", faction = "Burning Blade",
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.10, rotation = 0.15 },
        text = "{T}: Deal 2 damage to target opponent and you gain 2 life."
    },

    -- Deadmines: Edwin VanCleef
    ["BOSS02"] = {
        id = "BOSS02", name = "Edwin VanCleef", cost = "{1}{R}{B}", cmc = 3, color = "B", type = "Creature",
        power = 4, toughness = 3, haste = true, firstStrike = true, isBoss = true, displayId = 2029, achievementId = 628,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias",
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.12, rotation = 0.20 },
        anthem = { tag = "faction", value = "Defias", p = 1 },
        text = "Quick, Strikes-First. Other Defias you control get +1/+0."
    },

    -- Wailing Caverns: Mutanus the Devourer
    ["BOSS03"] = {
        id = "BOSS03", name = "Mutanus the Devourer", cost = "{3}{U}{B}", cmc = 5, color = "U", type = "Creature",
        power = 7, toughness = 8, isBoss = true, displayId = 4088, achievementId = 630,
        zone = "Wailing Caverns", creatureType = "Humanoid", faction = "Murloc",
        modelCam = { zoom = 0.55, camScale = 1.25, z = -0.18, rotation = 0.15 },
        text = "Whenever Mutanus attacks, the defending player discards a card and takes 1 damage."
    },

    -- Shadowfang Keep: Archmage Arugal
    ["BOSS04"] = {
        id = "BOSS04", name = "Archmage Arugal", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 3, toughness = 5, isBoss = true, displayId = 2353, achievementId = 631,
        zone = "Shadowfang Keep", creatureType = "Humanoid",
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.10, rotation = 0.15 },
        text = "{2}{U}, {T}: Put target Exhausted denizen on top of its owner's library."
    },

    -- Blackfathom Deeps: Aku'mai
    ["BOSS05"] = {
        id = "BOSS05", name = "Aku'mai", cost = "{4}{G}{U}", cmc = 6, color = "G", type = "Creature",
        power = 8, toughness = 9, trample = true, bulwark = 2, isBoss = true, displayId = 2837, achievementId = 632,
        zone = "Blackfathom Deeps", creatureType = "Beast",
        modelCam = { zoom = 0.20, camScale = 1.80, z = 0.00, rotation = -0.30 },
        text = "Brutish, Bulwark 2."
    },

    -- Stockade: Bazil Thredd
    ["BOSS06"] = {
        id = "BOSS06", name = "Bazil Thredd", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 4, toughness = 4, isBoss = true, displayId = 1621, achievementId = 634,
        zone = "The Stockade", creatureType = "Humanoid", faction = "Defias",
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.12, rotation = 0.15 },
        anthem = { tag = "faction", value = "Defias", p = 1, t = 1 },
        text = "Other Defias you control get +1/+1."
    },

    -- Gnomeregan: Mekgineer Thermaplugg
    ["BOSS07"] = {
        id = "BOSS07", name = "Mekgineer Thermaplugg", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 7, isBoss = true, displayId = 6980, achievementId = 635,
        zone = "Gnomeregan", creatureType = "Humanoid",
        modelCam = { zoom = 0.70, camScale = 0.90, z = 0.05, rotation = 0.15 },
        text = "{1}{R}, {T}: Deal 1 damage to each opposing denizen."
    },

    -- Razorfen Kraul: Charlga Razorflank
    ["BOSS08"] = {
        id = "BOSS08", name = "Charlga Razorflank", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 5, toughness = 6, reach = true, isBoss = true, displayId = 4642, achievementId = 636,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar",
        modelCam = { zoom = 0.70, camScale = 1.10, z = -0.12, rotation = 0.15 },
        text = "Anti-Air. {1}{G}, {T}: Exhaust target denizen. It does not Recover during its controller's next Recover step."
    },

    -- SM Graveyard: Bloodmage Thalnos
    ["BOSS09"] = {
        id = "BOSS09", name = "Bloodmage Thalnos", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, deathtouch = true, isBoss = true, displayId = 11396, achievementId = 638,
        zone = "Scarlet Monastery", creatureType = "Undead", faction = "Scarlet Crusade",
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.10, rotation = 0.15 },
        text = "Fatal. When Bloodmage Thalnos dies, draw a card."
    },

    -- SM Library: Arcanist Doan
    ["BOSS10"] = {
        id = "BOSS10", name = "Arcanist Doan", cost = "{2}{U}{R}", cmc = 4, color = "R", type = "Creature",
        power = 5, toughness = 5, isBoss = true, displayId = 5266, achievementId = 638,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade",
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.12, rotation = 0.15 },
        text = "{1}{R}, {T}: Deal 1 damage to each opposing denizen."
    },

    -- SM Armory: Herod
    ["BOSS11"] = {
        id = "BOSS11", name = "Herod", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 5, haste = true, isBoss = true, displayId = 2041, achievementId = 638,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade",
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.15, rotation = 0.20 },
        text = "Quick. Herod attacks each combat if able. Whenever Herod attacks, he gets +2/+0 until end of turn."
    },

    -- SM Cathedral: High Inquisitor Whitemane
    ["BOSS12"] = {
        id = "BOSS12", name = "High Inquisitor Whitemane", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 4, toughness = 6, shielded = true, lifelink = true, isBoss = true, displayId = 2043, achievementId = 638,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade",
        modelCam = { zoom = 0.85, camScale = 1.0, z = -0.15, rotation = 0.20 },
        text = "Drain, Shielded. When Whitemane dies, return the last other denizen card put into your graveyard to the battlefield."
    },

    -- Razorfen Downs: Amnennar the Coldbringer
    ["BOSS13"] = {
        id = "BOSS13", name = "Amnennar the Coldbringer", cost = "{3}{U}{B}", cmc = 5, color = "U", type = "Creature",
        power = 6, toughness = 8, isBoss = true, displayId = 7971, achievementId = 637,
        zone = "Razorfen Downs", creatureType = "Undead",
        modelCam = { zoom = 0.65, camScale = 1.20, z = -0.15, rotation = 0.15 },
        text = "Whenever Amnennar attacks, Exhaust the ready enemy denizen with the highest power. It does not Recover during its controller's next Recover step."
    },

    -- Uldaman: Archaedas
    ["BOSS14"] = {
        id = "BOSS14", name = "Archaedas", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 8, toughness = 10, vigilance = true, hexproof = true, isBoss = true, displayId = 5988, achievementId = 639,
        zone = "Uldaman", creatureType = "Giant",
        modelCam = { zoom = 0.40, camScale = 1.40, z = -0.22, rotation = 0.15 },
        text = "Vigilant, Warded (Archaedas cannot be the target of spells or abilities your opponents control)."
    },

    -- Zul'Farrak: Chief Ukorz Sandscalp
    ["BOSS15"] = {
        id = "BOSS15", name = "Chief Ukorz Sandscalp", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 8, toughness = 7, haste = true, trample = true, isBoss = true, displayId = 6439, achievementId = 640,
        zone = "Zul'Farrak", creatureType = "Humanoid", faction = "Troll",
        modelCam = { zoom = 0.70, camScale = 1.15, z = -0.15, rotation = 0.15 },
        text = "Brutish, Quick. Ukorz gets +3/+0 as long as your life total is 10 or less."
    },

    -- Maraudon: Princess Theradras
    ["BOSS16"] = {
        id = "BOSS16", name = "Princess Theradras", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 9, toughness = 9, trample = true, isBoss = true, displayId = 12292, achievementId = 641,
        zone = "Maraudon", creatureType = "Elemental",
        modelCam = { zoom = 0.35, camScale = 1.60, z = -0.25, rotation = 0.10 },
        text = "Brutish. Whenever Theradras attacks and isn't blocked, destroy one of the defending player's Prayers."
    },

    -- Sunken Temple: Shade of Eranikus
    ["BOSS17"] = {
        id = "BOSS17", name = "Shade of Eranikus", cost = "{3}{U}{G}", cmc = 5, color = "G", type = "Creature",
        power = 8, toughness = 8, flying = true, isBoss = true, displayId = 7806, achievementId = 642,
        zone = "Sunken Temple", creatureType = "Dragonkin",
        modelCam = { zoom = 0.25, camScale = 1.80, z = -0.05, rotation = -0.20 },
        text = "Airborne. Whenever Eranikus deals combat damage to a denizen, Exhaust that denizen and it does not Recover during its controller's next Recover step."
    },

    -- BRD: Emperor Dagran Thaurissan
    ["BOSS18"] = {
        id = "BOSS18", name = "Emperor Dagran Thaurissan", cost = "{3}{R}{W}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 7, isBoss = true, displayId = 8807, achievementId = 643,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron",
        modelCam = { zoom = 0.75, camScale = 0.95, z = 0.00, rotation = 0.15 },
        text = "Other denizens you control gain +1/+1 and Vigilant."
    },

    -- LBRS: Overlord Wyrmthalak
    ["BOSS19"] = {
        id = "BOSS19", name = "Overlord Wyrmthalak", cost = "{4}{R}{B}", cmc = 6, color = "R", type = "Creature",
        power = 9, toughness = 8, trample = true, isBoss = true, displayId = 8711, achievementId = 644,
        zone = "Blackrock Spire", creatureType = "Dragonkin", faction = "Blackrock",
        modelCam = { zoom = 0.50, camScale = 1.35, z = -0.20, rotation = 0.15 },
        text = "Brutish. When Wyrmthalak enters the battlefield, deal 3 damage to all opposing denizens."
    },

    -- UBRS: General Drakkisath
    ["BOSS20"] = {
        id = "BOSS20", name = "General Drakkisath", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 10, toughness = 9, hexproof = true, trample = true, isBoss = true, displayId = 10115, achievementId = 1307,
        zone = "Blackrock Spire", creatureType = "Dragonkin", faction = "Blackrock",
        modelCam = { zoom = 0.40, camScale = 1.50, z = -0.25, rotation = 0.15 },
        text = "Brutish, Warded. All other denizens lose and cannot gain Quick."
    },

    -- Dire Maul East: Alzzin the Wildshaper
    ["BOSS21"] = {
        id = "BOSS21", name = "Alzzin the Wildshaper", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 7, toughness = 8, deathtouch = true, isBoss = true, displayId = 14416, achievementId = 645,
        zone = "Dire Maul", creatureType = "Demon", faction = "Satyr",
        modelCam = { zoom = 0.70, camScale = 1.10, z = -0.15, rotation = 0.15 },
        text = "Fatal. {T}: You gain 4 life."
    },

    -- Dire Maul West: Prince Tortheldrin
    ["BOSS22"] = {
        id = "BOSS22", name = "Prince Tortheldrin", cost = "{2}{U}{B}", cmc = 4, color = "U", type = "Creature",
        power = 5, toughness = 5, isBoss = true, displayId = 11256, achievementId = 645,
        zone = "Dire Maul", creatureType = "Humanoid",
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.12, rotation = 0.15 },
        text = "{2}{U}: Draw a card, then discard a card. Tortheldrin gets +1/+1 until end of turn."
    },

    -- Dire Maul North: King Gordok
    ["BOSS23"] = {
        id = "BOSS23", name = "King Gordok", cost = "{4}{G}{R}", cmc = 6, color = "R", type = "Creature",
        power = 10, toughness = 8, trample = true, isBoss = true, displayId = 11583, achievementId = 645,
        zone = "Dire Maul", creatureType = "Humanoid", faction = "Ogre",
        modelCam = { zoom = 0.45, camScale = 1.45, z = -0.22, rotation = 0.15 },
        text = "Brutish. Whenever King Gordok attacks, he gets +2/+0 until end of turn."
    },

    -- Scholomance: Darkmaster Gandling
    ["BOSS24"] = {
        id = "BOSS24", name = "Darkmaster Gandling", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 7, isBoss = true, displayId = 11070, achievementId = 646,
        zone = "Scholomance", creatureType = "Humanoid",
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.12, rotation = 0.15 },
        text = "Whenever another denizen you control dies, you draw a card."
    },

    -- Stratholme: Baron Rivendare
    ["BOSS25"] = {
        id = "BOSS25", name = "Baron Rivendare", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 8, toughness = 8, lifelink = true, isBoss = true, displayId = 10729, achievementId = 633,
        zone = "Stratholme", creatureType = "Undead",
        modelCam = { zoom = 0.70, camScale = 1.15, z = -0.18, rotation = 0.15 },
        text = "Drain. Whenever an opposing denizen dies, its controller takes 2 damage."
    },

    -- Stratholme: Balnazzar
    ["BOSS26"] = {
        id = "BOSS26", name = "Balnazzar", cost = "{4}{B}{U}", cmc = 6, color = "B", type = "Creature",
        power = 8, toughness = 9, isBoss = true, displayId = 10691, achievementId = 633,
        zone = "Stratholme", creatureType = "Demon",
        modelCam = { zoom = 0.55, camScale = 1.30, z = -0.20, rotation = 0.15 },
        text = "When Balnazzar enters the battlefield, gain control of the opposing denizen with the highest power of 4 or less."
    },

    -- WoW Forever dungeons: their "achievements" are the kill statistics, so the same id
    -- also goes in statisticId (BossTracker reads the kill count from it in any language)

    -- The Hall of Thanes: Durgen Dirgehammer
    ["BOSS27"] = {
        id = "BOSS27", name = "Durgen Dirgehammer", cost = "{2}{R}{B}", cmc = 4, color = "R", type = "Creature",
        power = 5, toughness = 5, vigilance = true, firstStrike = true, isBoss = true, displayId = 142837,
        achievementId = 63573, statisticId = 63573,
        zone = "The Hall of Thanes", creatureType = "Humanoid", faction = "Dark Iron",
        anthem = { tag = "faction", value = "Dark Iron", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.10, rotation = 0.15 },
        text = "Strikes-First, Vigilant. Other Dark Iron you control get +1/+1."
    },

    -- Ruins of Lordaeron: Rath'mael
    ["BOSS28"] = {
        id = "BOSS28", name = "Rath'mael", cost = "{3}{B}{R}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 6, lifelink = true, deathtouch = true, isBoss = true, displayId = 144175,
        achievementId = 63571, statisticId = 63571,
        zone = "Ruins of Lordaeron", creatureType = "Undead",
        anthem = { tag = "type", value = "Undead", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.10, rotation = 0.15 },
        text = "Fatal, Drain. Other Undead you control get +1/+0."
    },

    -- Excavation Site: Relic Guardian (no kill statistic on Wowhead yet; tracked by statistic name)
    ["BOSS29"] = {
        id = "BOSS29", name = "Relic Guardian", cost = "{4}{G}{W}", cmc = 6, color = "G", type = "Creature",
        power = 8, toughness = 9, trample = true, vigilance = true, isBoss = true, displayId = 144224,
        zone = "Excavation Site", creatureType = "Elemental",
        modelCam = { zoom = 0.55, camScale = 1.30, z = -0.20, rotation = 0.15 },
        text = "Brutish. Vigilant."
    },

    -- City of Dalaran: Shade of the Archmage (no kill statistic on Wowhead yet; tracked by statistic name)
    ["BOSS30"] = {
        id = "BOSS30", name = "Shade of the Archmage", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 6, toughness = 7, flying = true, isBoss = true, displayId = 130061,
        zone = "City of Dalaran", creatureType = "Elemental",
        etb = { ops = { { op = "tap", to = "enemy_creatures" } } },
        modelCam = { zoom = 0.55, camScale = 1.30, z = -0.20, rotation = 0.15 },
        text = "Airborne. When Shade of the Archmage enters the battlefield, Exhaust each enemy denizen."
    },
})
