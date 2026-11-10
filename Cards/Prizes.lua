--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- PRIZE CARDS
-- Tournament prizes: the leaders of Azeroth, two to a sphere. Handed out by the developer
-- through the admin addon (AdminGrants.lua PRIZE / GRANT); nothing in the game drops them.
-- Leaders who are already zone denizens (Jaina, Vol'jin, Baine) aren't repeated here.
--   isPrize = true: copies live in TTS_NpcGifts.prizes[cardId] (SoloEncounters.lua
--                   GetOwnedCopies), up to 4. Like the beta card they never count towards the
--                   collection score, since not everyone can get them.
--   prizeWeight = n: its share of a random prize draw (default 1). The draw only picks from
--                    prizes the player has fewer than 4 copies of.
-- All of them are Unique (CardLogic.lua) and come only as foils (alwaysFoil, Cards\Special.lua).
-- displayIds are the NPCs' own (Wowhead's model viewer); modelCam still to be tuned in game.
-- =========================================================================
TTS:AddCards({
    -- HOLY
    -- Stormwind Keep (npc 1748)
    ["PRZ01"] = {
        id = "PRZ01", name = "Highlord Bolvar Fordragon", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 4, toughness = 5, vigilance = true, unique = true, isPrize = true, alwaysFoil = true,
        displayId = 5566, creatureType = "Humanoid", npcId = 1748,
        etb = { ops = { { op = "buff", to = "friendly_creatures", p = 1, t = 1, perm = true } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Unique. Vigilant. Arrival: Denizens you control permanently get +1/+1."
    },
    -- Ironforge (npc 2784)
    ["PRZ02"] = {
        id = "PRZ02", name = "King Magni Bronzebeard", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 4, toughness = 6, bulwark = 2, unique = true, isPrize = true, alwaysFoil = true,
        displayId = 3597, creatureType = "Humanoid", npcId = 2784,
        etb = { ops = { { op = "shield", to = "self_player", n = 4 } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Unique. Bulwark 2. Arrival: Prevent the next 4 damage to you."
    },

    -- ARCANE
    -- Darnassus (npc 7999)
    ["PRZ03"] = {
        id = "PRZ03", name = "Tyrande Whisperwind", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 4, toughness = 4, vigilance = true, unique = true, isPrize = true, alwaysFoil = true,
        displayId = 7274, creatureType = "Humanoid", npcId = 7999,
        etb = { ops = { { op = "damage", to = "enemy_creatures", n = 2 } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Unique. Vigilant. Arrival: Deal 2 damage to each enemy denizen."
    },
    -- Ironforge, Tinker Town (npc 7937)
    ["PRZ04"] = {
        id = "PRZ04", name = "High Tinker Mekkatorque", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 2, toughness = 4, unique = true, isPrize = true, alwaysFoil = true,
        displayId = 7006, creatureType = "Humanoid", npcId = 7937,
        etb = { ops = { { op = "tap", to = "enemy_creatures" }, { op = "draw", n = 1 } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Unique. Arrival: Exhaust each enemy denizen. Draw 1."
    },

    -- SHADOW
    -- Undercity (npc 10181)
    ["PRZ05"] = {
        id = "PRZ05", name = "Lady Sylvanas Windrunner", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 4, toughness = 4, deathtouch = true, unique = true, isPrize = true, alwaysFoil = true,
        displayId = 11657, creatureType = "Undead", npcId = 10181,
        etb = { ops = { { op = "raise", src = "own" } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Unique. Fatal. Arrival: Return a denizen card from your graveyard to the battlefield."
    },
    -- Stormwind Keep: Onyxia in disguise (npc 1749)
    ["PRZ06"] = {
        id = "PRZ06", name = "Lady Katrana Prestor", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 3, toughness = 4, hexproof = true, unique = true, isPrize = true, alwaysFoil = true,
        displayId = 8769, creatureType = "Humanoid", npcId = 1749,
        etb = { ops = { { op = "draw", n = 1 } } },
        onDeath = { ops = { { op = "token", id = "TOK05", n = 3 } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Unique. Warded. Arrival: Draw 1. Martyrdom: Spawn: 3 Rookery Whelp Adds (1/1, Airborne)."
    },

    -- FIRE
    -- Orgrimmar (npc 4949)
    ["PRZ07"] = {
        id = "PRZ07", name = "Thrall", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 5, toughness = 4, haste = true, unique = true, isPrize = true, alwaysFoil = true,
        displayId = 4527, creatureType = "Humanoid", npcId = 4949,
        etb = { ops = { { op = "damage", to = "enemy_player", n = 3 } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Unique. Quick. Arrival: Deal 3 damage to the opponent."
    },
    -- Orgrimmar (npc 14720)
    ["PRZ08"] = {
        id = "PRZ08", name = "High Overlord Saurfang", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 5, toughness = 3, firstStrike = true, trample = true, unique = true, isPrize = true, alwaysFoil = true,
        displayId = 14732, creatureType = "Humanoid", npcId = 14720,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Unique. Strikes-First. Brutish."
    },

    -- NATURE
    -- Thunder Bluff (npc 3057)
    ["PRZ09"] = {
        id = "PRZ09", name = "Cairne Bloodhoof", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 7, toughness = 7, trample = true, unique = true, isPrize = true, alwaysFoil = true,
        displayId = 4307, creatureType = "Humanoid", npcId = 3057,
        etb = { ops = { { op = "tap", to = "enemy_creatures" } } },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Unique. Brutish. Arrival: Exhaust each enemy denizen."
    },
    -- Darnassus (npc 3516)
    ["PRZ10"] = {
        id = "PRZ10", name = "Arch Druid Fandral Staghelm", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 3, toughness = 5, unique = true, isPrize = true, alwaysFoil = true,
        displayId = 1542, creatureType = "Humanoid", npcId = 3516,
        etb = { ops = { { op = "heal", to = "self_player", n = 3 }, { op = "buff", to = "friendly_creatures", t = 2, perm = true } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Unique. Arrival: You gain 3 life and denizens you control permanently get +0/+2."
    },
})
