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
    -- HILLSBRAD FOOTHILLS
    ["HIL01"] = {
        id = "HIL01", name = "Rot Hide Brute", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 10851,
        zone = "Hillsbrad Foothills", creatureType = "Undead", faction = "Gnoll", npcId = 1939,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIL02"] = {
        id = "HIL02", name = "Rot Hide Plague Weaver", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 10855,
        zone = "Hillsbrad Foothills", creatureType = "Undead", faction = "Gnoll", npcId = 1940,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIL03"] = {
        id = "HIL03", name = "Raging Rot Hide", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 10856,
        zone = "Hillsbrad Foothills", creatureType = "Undead", faction = "Gnoll", npcId = 1943,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIL04"] = {
        id = "HIL04", name = "Elder Lake Creeper", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 631,
        zone = "Hillsbrad Foothills", creatureType = "Elemental", npcId = 1956,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIL05"] = {
        id = "HIL05", name = "Syndicate Watchman", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 3, vigilance = true, isMob = true, isBoss = true, displayId = 3623,
        zone = "Hillsbrad Foothills", creatureType = "Humanoid", faction = "Syndicate", npcId = 2261,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant."
    },
    ["HIL06"] = {
        id = "HIL06", name = "Vicious Gray Bear", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 4, isMob = true, isBoss = true, displayId = 1007,
        zone = "Hillsbrad Foothills", creatureType = "Beast", npcId = 2354,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIL07"] = {
        id = "HIL07", name = "Starving Mountain Lion", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 4, toughness = 3, haste = true, isMob = true, isBoss = true, displayId = 1059,
        zone = "Hillsbrad Foothills", creatureType = "Beast", npcId = 2384,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Quick."
    },
    ["HIL08"] = {
        id = "HIL08", name = "Hillsbrad Miner", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 5, toughness = 5, support = true, isMob = true, isBoss = true, displayId = 3629,
        zone = "Hillsbrad Foothills", creatureType = "Humanoid", npcId = 2269,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Support."
    },
    ["HIL09"] = {
        id = "HIL09", name = "Witherbark Headhunter", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 3997,
        zone = "Hillsbrad Foothills", creatureType = "Humanoid", faction = "Troll", npcId = 2556,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIL10"] = {
        id = "HIL10", name = "Zalas Witherbark", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 4003,
        zone = "Hillsbrad Foothills", creatureType = "Humanoid", npcId = 2605,
        modelCam = { zoom = 0.58, camScale = 1.19, z = -0.14, rotation = 0.15 },
        text = ""
    },
    -- Solo reward
    ["HIL11"] = {
        id = "HIL11", name = "Magistrate Henry Maleb", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 3, vigilance = true, isReward = true, displayId = 3665,
        zone = "Hillsbrad Foothills", creatureType = "Humanoid", npcEntry = 2276,
        anthem = { tag = "zone", value = "Hillsbrad Foothills", p = 1 },
        etb = { ops = { { op = "shield", to = "self_player", n = 4 } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilant. When Magistrate Henry Maleb enters the battlefield, prevent the next 4 damage that would be dealt to you. Other Hillsbrad Foothills creatures you control get +1/+0."
    },
})
