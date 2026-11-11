--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- LOCATION CARDS
-- Won by beating a zone's notable NPC at cards (Duels.lua). How a Location plays: Engine\
-- CardLogic.lua's LOCATIONS section. Up to 4 copies (SoloEncounters.lua TTS:CardMaxCopies).
-- In the hand it's an ordinary card; on the battlefield it turns into a landscape card
-- (UI\Board.lua, the frames' <frame>_landscape.png).
-- A Location with a zone and no art of its own shows that zone's map as its picture
-- (UI\Board.lua PaintZoneArt).
--
-- PLACEHOLDERS (isPlaceholder): one per duel, all alike, until the real cards are written:
-- an Aura on the zone's denizens and an Exhaust ability, so every part of a Location can be
-- tried. Each is named after a landmark near its NPC.
-- =========================================================================
TTS:AddCards({
    ["LCN_ELW"] = {
        id = "LCN_ELW", name = "Lion's Pride Inn", cost = "{1}{B}{R}", cmc = 3, color = "B", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Elwynn Forest",
        anthem = { tag = "zone", value = "Elwynn Forest", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Elwynn Forest denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_DUN"] = {
        id = "LCN_DUN", name = "Kharanos", cost = "{2}{U}", cmc = 3, color = "U", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Dun Morogh",
        anthem = { tag = "zone", value = "Dun Morogh", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Dun Morogh denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_TIR"] = {
        id = "LCN_TIR", name = "Deathknell", cost = "{2}{B}", cmc = 3, color = "B", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Tirisfal Glades",
        anthem = { tag = "zone", value = "Tirisfal Glades", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Tirisfal Glades denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_WES"] = {
        id = "LCN_WES", name = "Westfall Lighthouse", cost = "{1}{U}{B}", cmc = 3, color = "U", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Westfall",
        anthem = { tag = "zone", value = "Westfall", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Westfall denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_LOC"] = {
        id = "LCN_LOC", name = "Stonewrought Dam", cost = "{2}{R}", cmc = 3, color = "R", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Loch Modan",
        anthem = { tag = "zone", value = "Loch Modan", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Loch Modan denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_SIL"] = {
        id = "LCN_SIL", name = "Pyrewood Village", cost = "{2}{G}", cmc = 3, color = "G", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Silverpine Forest",
        anthem = { tag = "zone", value = "Silverpine Forest", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Silverpine Forest denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_RED"] = {
        id = "LCN_RED", name = "Lakeshire", cost = "{2}{W}", cmc = 3, color = "W", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Redridge Mountains",
        anthem = { tag = "zone", value = "Redridge Mountains", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Redridge Mountains denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_DSK"] = {
        id = "LCN_DSK", name = "Raven Hill", cost = "{2}{B}", cmc = 3, color = "B", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Duskwood",
        anthem = { tag = "zone", value = "Duskwood", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Duskwood denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_WET"] = {
        id = "LCN_WET", name = "The Green Belt", cost = "{2}{G}", cmc = 3, color = "G", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Wetlands",
        anthem = { tag = "zone", value = "Wetlands", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Wetlands denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_HIL"] = {
        id = "LCN_HIL", name = "Southshore", cost = "{1}{R}{W}", cmc = 3, color = "R", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Hillsbrad Foothills",
        anthem = { tag = "zone", value = "Hillsbrad Foothills", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Hillsbrad Foothills denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_ALT"] = {
        id = "LCN_ALT", name = "Ravenholdt Manor", cost = "{2}{B}", cmc = 3, color = "B", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Alterac Mountains",
        anthem = { tag = "zone", value = "Alterac Mountains", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Alterac Mountains denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_ARA"] = {
        id = "LCN_ARA", name = "Faldir's Cove", cost = "{2}{U}", cmc = 3, color = "U", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Arathi Highlands",
        anthem = { tag = "zone", value = "Arathi Highlands", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Arathi Highlands denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_STV"] = {
        id = "LCN_STV", name = "Nesingwary's Expedition", cost = "{2}{G}", cmc = 3, color = "G", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Stranglethorn Vale",
        anthem = { tag = "zone", value = "Stranglethorn Vale", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Stranglethorn Vale denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_BAD"] = {
        id = "LCN_BAD", name = "The Dustbowl", cost = "{1}{R}{U}", cmc = 3, color = "R", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Badlands",
        anthem = { tag = "zone", value = "Badlands", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Badlands denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_SWA"] = {
        id = "LCN_SWA", name = "Fallow Sanctuary", cost = "{1}{G}{B}", cmc = 3, color = "G", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Swamp of Sorrows",
        anthem = { tag = "zone", value = "Swamp of Sorrows", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Swamp of Sorrows denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_HIN"] = {
        id = "LCN_HIN", name = "Overlook Cliffs", cost = "{2}{R}", cmc = 3, color = "R", type = "Location",
        isReward = true, isPlaceholder = true, zone = "The Hinterlands",
        anthem = { tag = "zone", value = "The Hinterlands", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your The Hinterlands denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_SEA"] = {
        id = "LCN_SEA", name = "Thorium Point", cost = "{2}{W}", cmc = 3, color = "W", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Searing Gorge",
        anthem = { tag = "zone", value = "Searing Gorge", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Searing Gorge denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_BLA"] = {
        id = "LCN_BLA", name = "Nethergarde Keep", cost = "{2}{B}", cmc = 3, color = "B", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Blasted Lands",
        anthem = { tag = "zone", value = "Blasted Lands", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Blasted Lands denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_BUR"] = {
        id = "LCN_BUR", name = "Dreadmaul Rock", cost = "{2}{R}", cmc = 3, color = "R", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Burning Steppes",
        anthem = { tag = "zone", value = "Burning Steppes", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Burning Steppes denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_WPL"] = {
        id = "LCN_WPL", name = "Sorrow Hill", cost = "{1}{B}{W}", cmc = 3, color = "B", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Western Plaguelands",
        anthem = { tag = "zone", value = "Western Plaguelands", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Western Plaguelands denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_EPL"] = {
        id = "LCN_EPL", name = "Terrordale", cost = "{2}{B}", cmc = 3, color = "B", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Eastern Plaguelands",
        anthem = { tag = "zone", value = "Eastern Plaguelands", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Eastern Plaguelands denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_DUR"] = {
        id = "LCN_DUR", name = "Skull Rock", cost = "{1}{G}{R}", cmc = 3, color = "G", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Durotar",
        anthem = { tag = "zone", value = "Durotar", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Durotar denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_MUL"] = {
        id = "LCN_MUL", name = "Red Rocks", cost = "{2}{G}", cmc = 3, color = "G", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Mulgore",
        anthem = { tag = "zone", value = "Mulgore", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Mulgore denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_TEL"] = {
        id = "LCN_TEL", name = "Lake Al'Ameth", cost = "{1}{G}{W}", cmc = 3, color = "G", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Teldrassil",
        anthem = { tag = "zone", value = "Teldrassil", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Teldrassil denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_DAR"] = {
        id = "LCN_DAR", name = "Grove of the Ancients", cost = "{1}{G}{U}", cmc = 3, color = "G", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Darkshore",
        anthem = { tag = "zone", value = "Darkshore", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Darkshore denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_BRN"] = {
        id = "LCN_BRN", name = "Ratchet Docks", cost = "{2}{U}", cmc = 3, color = "U", type = "Location",
        isReward = true, isPlaceholder = true, zone = "The Barrens",
        anthem = { tag = "zone", value = "The Barrens", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your The Barrens denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_STO"] = {
        id = "LCN_STO", name = "Windshear Crag", cost = "{2}{U}", cmc = 3, color = "U", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Stonetalon Mountains",
        anthem = { tag = "zone", value = "Stonetalon Mountains", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Stonetalon Mountains denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_ASH"] = {
        id = "LCN_ASH", name = "Raynewood Retreat", cost = "{2}{G}", cmc = 3, color = "G", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Ashenvale",
        anthem = { tag = "zone", value = "Ashenvale", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Ashenvale denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_THO"] = {
        id = "LCN_THO", name = "Mirage Raceway", cost = "{1}{R}{W}", cmc = 3, color = "R", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Thousand Needles",
        anthem = { tag = "zone", value = "Thousand Needles", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Thousand Needles denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_DES"] = {
        id = "LCN_DES", name = "Kodo Graveyard", cost = "{2}{B}", cmc = 3, color = "B", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Desolace",
        anthem = { tag = "zone", value = "Desolace", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Desolace denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_DUS"] = {
        id = "LCN_DUS", name = "Tabetha's Farm", cost = "{2}{U}", cmc = 3, color = "U", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Dustwallow Marsh",
        anthem = { tag = "zone", value = "Dustwallow Marsh", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Dustwallow Marsh denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_FER"] = {
        id = "LCN_FER", name = "The Twin Colossals", cost = "{2}{R}", cmc = 3, color = "R", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Feralas",
        anthem = { tag = "zone", value = "Feralas", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Feralas denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_TAN"] = {
        id = "LCN_TAN", name = "Steamwheedle Port", cost = "{2}{W}", cmc = 3, color = "W", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Tanaris",
        anthem = { tag = "zone", value = "Tanaris", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Tanaris denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_AZS"] = {
        id = "LCN_AZS", name = "Bay of Storms", cost = "{2}{U}", cmc = 3, color = "U", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Azshara",
        anthem = { tag = "zone", value = "Azshara", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Azshara denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_FEL"] = {
        id = "LCN_FEL", name = "Emerald Sanctuary", cost = "{2}{G}", cmc = 3, color = "G", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Felwood",
        anthem = { tag = "zone", value = "Felwood", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Felwood denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_UNG"] = {
        id = "LCN_UNG", name = "Golakka Hot Springs", cost = "{2}{R}", cmc = 3, color = "R", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Un'Goro Crater",
        anthem = { tag = "zone", value = "Un'Goro Crater", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Un'Goro Crater denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_SLI"] = {
        id = "LCN_SLI", name = "Hive'Regal", cost = "{2}{W}", cmc = 3, color = "W", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Silithus",
        anthem = { tag = "zone", value = "Silithus", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Silithus denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_WIN"] = {
        id = "LCN_WIN", name = "Frostfire Hot Springs", cost = "{1}{U}{W}", cmc = 3, color = "U", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Winterspring",
        anthem = { tag = "zone", value = "Winterspring", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Winterspring denizens get +1/+0. {T}, {2}: You regain 2 health."
    },
    ["LCN_ZEP"] = {
        id = "LCN_ZEP", name = "Zephras Heights", cost = "{2}{W}", cmc = 3, color = "W", type = "Location",
        isReward = true, isPlaceholder = true, zone = "Zephras Isle",
        anthem = { tag = "zone", value = "Zephras Isle", p = 1, t = 0 },
        ability = { tap = true, cost = "{2}", ops = { { op = "heal", to = "self_player", n = 2 } } },
        text = "Your Zephras Isle denizens get +1/+0. {T}, {2}: You regain 2 health."
    },

    -- The tutorial's (UI\Tutorial.lua; Systems\SoloEncounters.lua TUTORIAL): cheap enough to
    -- play on its last turn, and never collected (notCollectible: not in the Deckbuilder,
    -- the collection or a ban list). Shows Elwynn Forest's map as its picture.
    ["LCN_TUT"] = {
        id = "LCN_TUT", name = "Training Grounds", cost = "{W}", cmc = 1, color = "W", type = "Location",
        notCollectible = true, zone = "Elwynn Forest",
        anthem = { tag = "any", p = 1, t = 0 },
        text = "Your denizens get +1/+0."
    },
})
