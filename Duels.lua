--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

-- =========================================================================
-- NPC DUELS
-- One notable friendly NPC per zone (a hermit, loner or someone out of the way, neutral where
-- one could be found) plays a game of cards for their Location card. See TTS:AddDuel in
-- SoloEncounters.lua for the fields. Each deck is their own: 38 cards on a theme, leaving 2
-- slots for 2 copies of their Location, added with the card (reward = its id).
-- A duel stays hidden (no gossip option, no grants) until its Location card exists.
-- Two npc ids on one duel: an NPC for each faction, sharing the deck and the Location.
-- faction = "Alliance": only Alliance can reach the NPC; Horde characters are granted the
-- Location once they have beaten every duel they can reach (TTS:CheckDuelGrants).
-- Still to pick in game: Riverglades and Mount Hyjal.
-- =========================================================================

-- Elwynn Forest: Remy "Two Times" (Goldshire's smooth talker: Defias rogues and kobold rabble, cheap tricks)
TTS:AddDuel({
    id = "DUEL_ELW", npcs = { 241 }, name = "Remy \"Two Times\"", zone = "Elwynn Forest",
    life = 20, ai = "basic", background = { map = "Elwynn" }, faction = "Alliance",
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "ARA01", "ELW01", "ELW01", "LOC01", "WES02", "ELW03", "ELW03", "ELW04", "ELW04",
        "DSK05", "DSK05", "ELW05", "ELW05", "WES07", "WES07", "ELW12", "WES08",
        "ROG01", "ROG04", "ROG07", "GEAR01",
        "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01",
    },
})

-- Dun Morogh: Binjy Featherwhistle (Gnome mechanostrider pilot: machines, troggs and frost)
TTS:AddDuel({
    id = "DUEL_DUN", npcs = { 7954 }, name = "Binjy Featherwhistle", zone = "Dun Morogh",
    life = 20, ai = "basic", background = { map = "DunMorogh" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "DUN02", "DUN02", "DUN04", "DUN04", "GNO01", "GNO01", "DUN06", "DUN06",
        "GNO03", "GNO03", "GNO04", "DUN07", "DUN07", "GNO07", "DUN08", "GNO08",
        "DUN09",
        "MAG02", "MAG02", "MAG06", "MAG06", "EGR01", "GEAR02",
        "R01", "R01", "R01", "R01", "R01", "R01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01",
    },
})

-- Tirisfal Glades: Calvin Montague (A lone Forsaken at Deathknell: the risen dead and shadow)
TTS:AddDuel({
    id = "DUEL_TIR", npcs = { 6784 }, name = "Calvin Montague", zone = "Tirisfal Glades",
    life = 20, ai = "basic", background = { map = "Tirisfal" }, faction = "Horde",
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "TIR01", "TIR01", "SIL04", "TIR03", "TIR03", "TIR04", "TIR04", "TIR05", "TIR05",
        "TIR06", "TIR06", "TIR07", "TIR07", "DES08", "DSK08", "TIR08", "TIR10",
        "PRI07", "WLK02", "PRI08", "GEAR06",
        "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "U01", "U01", "U01",
    },
})

-- Westfall: Captain Grayson (The lighthouse ghost: murlocs off the coast, drowned dead, cold sea)
TTS:AddDuel({
    id = "DUEL_WES", npcs = { 392 }, name = "Captain Grayson", zone = "Westfall",
    life = 20, ai = "basic", background = { map = "Westfall" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "WES02", "WES02", "DAR04", "DAR04", "DSK03", "DSK03", "DUS03", "DAR06", "DAR06",
        "EPL05", "EPL05", "RED07", "WES07", "WES07", "DAR08", "DES08", "WES09",
        "MAG05", "PRI07", "SHA04", "GEAR07",
        "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01",
    },
})

-- Loch Modan: Bingles Blastenheimer (A gnome with too much blasting powder: explosives and the loch's wildlife)
TTS:AddDuel({
    id = "DUEL_LOC", npcs = { 6577 }, name = "Bingles Blastenheimer", zone = "Loch Modan",
    life = 20, ai = "basic", background = { map = "LochModan" }, faction = "Alliance",
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "LOC01", "LOC01", "LOC02", "BAD04", "BAD04", "LOC04", "LOC04", "BAD06", "BAD06",
        "LOC05", "LOC05", "LOC07", "LOC07", "LOC08", "LOC09", "BAD10", "LOC10",
        "MAG02", "MAG02", "HUN07", "HUN07", "EGR01", "GEAR08",
        "R01", "R01", "R01", "R01", "R01", "R01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01",
    },
})

-- Silverpine Forest: Pyrewood Tailor (Pyrewood's curse and the deathstalkers who watch it: worgen and undead)
TTS:AddDuel({
    id = "DUEL_SIL", npcs = { 3530, 1950 }, name = "Pyrewood Tailor", zone = "Silverpine Forest",
    life = 20, ai = "basic", background = { map = "Silverpine" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "SIL01", "SIL01", "DSK03", "DSK03", "SIL03", "SIL04", "SIL04", "DSK05", "DSK05",
        "SIL06", "SIL06", "DSK07", "DSK07", "SIL07", "DSK08", "SIL08", "SIL09",
        "ROG02", "WLK02", "HUN02", "GEAR10",
        "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "G01", "G01", "G01", "G01", "G01",
    },
})

-- Redridge Mountains: Martie Jainrose (A farmer out past Lakeshire: livestock, hounds and honest work)
TTS:AddDuel({
    id = "DUEL_RED", npcs = { 342 }, name = "Martie Jainrose", zone = "Redridge Mountains",
    life = 20, ai = "tactical", background = { map = "Redridge" }, faction = "Alliance",
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "RED01", "RED01", "ALT04", "ALT04", "ASH03", "RED04", "RED04", "ASH05", "ASH05",
        "ELW06", "ELW06", "AZS07", "AZS07", "DAR07", "LOC08", "SIL08", "ASH09",
        "PAL02", "DRU04", "DRU06", "GEAR12",
        "W01", "W01", "W01", "W01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01",
    },
})

-- Duskwood: Abercrombie (The hermit and the apothecary, both up to something: stitched dead and shadow magic)
TTS:AddDuel({
    id = "DUEL_DSK", npcs = { 289, 5414 }, name = "Abercrombie", zone = "Duskwood",
    life = 20, ai = "tactical", background = { map = "Duskwood" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "DSK01", "DSK01", "DSK03", "DSK03", "DSK04", "DSK04", "WPL03", "DSK05", "DSK05",
        "DSK06", "DSK06", "DSK07", "DSK07", "WPL07", "DES08", "DSK08", "DSK09",
        "WLK01", "WLK04", "PRI10",
        "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01",
    },
})

-- Wetlands: Rethiel the Greenwarden (The Green Belt's warden: bog elementals, raptors and growing things)
TTS:AddDuel({
    id = "DUEL_WET", npcs = { 1244 }, name = "Rethiel the Greenwarden", zone = "Wetlands",
    life = 20, ai = "tactical", background = { map = "Wetlands" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "WET01", "WET01", "ARA03", "ASH03", "ASH03", "WET03", "WET03", "ASH06", "ASH06",
        "WET06", "WET06", "ASH07", "ASH07", "FEL07", "FEL08", "FER08", "ASH09",
        "DRU07", "SHA04", "DRU05",
        "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "U01", "U01", "U01", "U01",
    },
})

-- Hillsbrad Foothills: Zixil (A travelling goblin merchant: hired muscle and whatever's for sale)
TTS:AddDuel({
    id = "DUEL_HIL", npcs = { 3537 }, name = "Zixil", zone = "Hillsbrad Foothills",
    life = 20, ai = "tactical", background = { map = "Hilsbrad" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "ARA01", "ARA01", "AZS04", "AZS04", "DES03", "DES03", "FEL03", "ALT06", "ALT06",
        "HIL05", "HIL05", "ALT07", "ALT07", "ARA07", "ARA08", "HIL08", "HIL09",
        "WAR01", "WAR01", "PAL06", "PAL06", "GEAR17", "GEAR22",
        "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "W01", "W01", "W01", "W01", "W01", "W01",
    },
})

-- Alterac Mountains: Lord Jorach Ravenholdt (Lord of the assassins' manor: the Syndicate's knives and dirty fighting)
TTS:AddDuel({
    id = "DUEL_ALT", npcs = { 6768 }, name = "Lord Jorach Ravenholdt", zone = "Alterac Mountains",
    life = 20, ai = "tactical", background = { map = "Alterac" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "ALT02", "ALT02", "HIL01", "HIL02", "HIL03", "HIL03", "ALT06", "ALT06",
        "ALT07", "ALT07", "WET07", "WET07", "ALT08", "HIL09", "ALT10", "HIL10",
        "ROG03", "ROG10", "ROG05", "ROG02",
        "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "R01", "R01", "R01", "R01", "R01", "R01", "R01",
    },
})

-- Arathi Highlands: Captain Steelgut (A pirate captain at Faldir's Cove: sea-raiders, nagas and cutlasses)
TTS:AddDuel({
    id = "DUEL_ARA", npcs = { 2769 }, name = "Captain Steelgut", zone = "Arathi Highlands",
    life = 20, ai = "tactical", background = { map = "Arathi" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "ARA02", "ARA02", "ARA03", "ARA03", "ARA04", "ARA04", "AZS03", "AZS06", "AZS06",
        "RED05", "RED05", "RED07", "RED07", "TIR07", "DAR08", "ELW08", "STV09",
        "ROG01", "MAG08", "SHA04", "GEAR22",
        "B01", "B01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01",
    },
})

-- Stranglethorn Vale: Hemet Nesingwary (The big-game hunter: the jungle's biggest cats, apes and raptors)
TTS:AddDuel({
    id = "DUEL_STV", npcs = { 715 }, name = "Hemet Nesingwary", zone = "Stranglethorn Vale",
    life = 25, ai = "expert", background = { map = "Stranglethorn" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "STV01", "STV01", "STV03", "STV03", "STV04", "STV04", "UNG04", "STV05", "STV05",
        "STV06", "STV06", "STV07", "STV07", "UNG07", "DUR08", "HYJ12", "UNG10",
        "HUN03", "HUN09", "HUN10", "GEAR18",
        "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "R01", "R01", "R01", "R01", "R01", "R01",
    },
})

-- Badlands: Lotwil Veriatus (A gnome binding elementals in the desert: fire, stone and arcane)
TTS:AddDuel({
    id = "DUEL_BAD", npcs = { 2921 }, name = "Lotwil Veriatus", zone = "Badlands",
    life = 25, ai = "expert", background = { map = "Badlands" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "BAD02", "BAD02", "ARA03", "ARA03", "ARA04", "SEA04", "SEA04", "BAD06", "BAD06",
        "SEA06", "SEA06", "STO07", "STO07", "ZEP09", "FER08", "BUR09", "BAD10",
        "MAG01", "SHA03", "MAG09",
        "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "U01", "U01", "U01", "U01", "U01", "U01",
    },
})

-- Swamp of Sorrows: Galen Goodward (The swamp's lone survivor: crocolisks, rot and getting away)
TTS:AddDuel({
    id = "DUEL_SWA", npcs = { 5391 }, name = "Galen Goodward", zone = "Swamp of Sorrows",
    life = 25, ai = "expert", background = { map = "SwampOfSorrows" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "SWA01", "SWA01", "ALT04", "SWA03", "SWA03", "SWA04", "SWA04", "DUS05", "DUS05",
        "DUS06", "DUS06", "AZS07", "AZS07", "BUR07", "BRN08", "LOC08", "SWA09",
        "HUN02", "DRU04", "ROG07",
        "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "B01", "B01", "B01", "B01", "B01", "B01", "B01",
    },
})

-- The Hinterlands: Rhapsody Shindigger (A goblin brewing on the cliffs: trolls, owlbeasts and a storm in a bottle)
TTS:AddDuel({
    id = "DUEL_HIN", npcs = { 5634 }, name = "Rhapsody Shindigger", zone = "The Hinterlands",
    life = 25, ai = "expert", background = { map = "Hinterlands" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "HIN01", "HIN01", "HIN03", "HIN03", "SWA08", "HIL09", "SWA09",
        "WAR04", "WAR04", "SHA05", "SHA05", "GEAR28",
        "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01",
    },
})

-- Searing Gorge: Hansel Heavyhands (A Thorium Brotherhood smith: forged steel against Dark Iron and fire)
TTS:AddDuel({
    id = "DUEL_SEA", npcs = { 14627 }, name = "Hansel Heavyhands", zone = "Searing Gorge",
    life = 25, ai = "expert", background = { map = "SearingGorge" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "SEA02", "SEA02", "BUR03", "BUR03", "BUR04", "SEA04", "SEA04", "BUR05", "BUR05",
        "SEA06", "SEA06", "SLI07", "SLI07", "STO07", "BUR08", "SEA08", "SEA10",
        "WAR05", "WAR05", "WAR09", "WAR09", "GEAR29", "BSM03",
        "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "W01", "W01", "W01", "W01",
    },
})

-- Blasted Lands: Kum'isha the Collector (A collector of things from beyond the Dark Portal: demons and fel fire)
TTS:AddDuel({
    id = "DUEL_BLA", npcs = { 7363 }, name = "Kum'isha the Collector", zone = "Blasted Lands",
    life = 25, ai = "expert", background = { map = "BlastedLands" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "FEL01", "FEL01", "BLA03", "BLA03", "BLA04", "BLA04", "FEL03", "BLA06", "BLA06",
        "FEL05", "FEL05", "BLA07", "BLA07", "HYJ10", "AZS08", "BLA08", "BLA09",
        "WLK07", "WLK06", "WLK01", "GEAR31",
        "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "R01", "R01", "R01", "R01", "R01",
    },
})

-- Burning Steppes: Cyrus Therepentous (A black dragon in disguise: dragonkin, the Blackrock orcs and flame)
TTS:AddDuel({
    id = "DUEL_BUR", npcs = { 9459 }, name = "Cyrus Therepentous", zone = "Burning Steppes",
    life = 25, ai = "expert", background = { map = "BurningSteppes" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "BUR01", "BUR01", "BUR03", "BUR03", "BUR04", "BUR04", "WET04", "BUR05", "BUR05",
        "BUR06", "BUR06", "BUR07", "BUR07", "BUR08", "RED08", "BUR09", "BUR10",
        "MAG03", "MAG04", "WLK08",
        "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "B01", "B01",
    },
})

-- Western Plaguelands: Myranda the Hag (The hag of illusions: the Scarlet Crusade and the dead, turned on each other)
TTS:AddDuel({
    id = "DUEL_WPL", npcs = { 11872 }, name = "Myranda the Hag", zone = "Western Plaguelands",
    life = 25, ai = "expert", background = { map = "WesternPlaguelands" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "WPL02", "WPL02", "DSK03", "WPL03", "WPL03", "WPL04", "WPL04", "WPL05", "WPL05",
        "WPL06", "WPL06", "WPL07", "WPL07", "DES08", "DSK08", "WPL08", "WPL09",
        "PRI10", "PAL07", "PRI09",
        "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "W01", "W01",
    },
})

-- Eastern Plaguelands: Augustus the Touched (The mad trader of Terrordale: plague, rot and things that crawl)
TTS:AddDuel({
    id = "DUEL_EPL", npcs = { 12384 }, name = "Augustus the Touched", zone = "Eastern Plaguelands",
    life = 25, ai = "expert", background = { map = "EasternPlaguelands" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "EPL02", "EPL02", "EPL03", "EPL03", "EPL04", "EPL04", "WPL03", "EPL05", "EPL05",
        "EPL06", "EPL06", "EPL07", "EPL07", "WPL07", "BRN08", "EPL08", "EPL09",
        "WLK03", "HUN02", "ROG09",
        "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01",
    },
})

-- Durotar: Rezlak (A goblin out in the Durotar scrub: boars, scorpids and quilboar)
TTS:AddDuel({
    id = "DUEL_DUR", npcs = { 3293 }, name = "Rezlak", zone = "Durotar",
    life = 20, ai = "basic", background = { map = "Durotar" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "BRN01", "BRN01", "BRN02", "BRN03", "BRN03", "BRN04", "DUR03", "DUR03",
        "DUR05", "DUR05", "DUR06", "DUR06", "BRN07", "BRN07", "DUR08", "BRN09",
        "DUR09",
        "WAR02", "WAR02", "SHA01", "SHA01", "GEAR04",
        "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01",
    },
})

-- Mulgore: Ahab Wheathoof (The old rancher: plainstriders, kodos and a lost dog)
TTS:AddDuel({
    id = "DUEL_MUL", npcs = { 277182 }, name = "Ahab Wheathoof", zone = "Mulgore",
    life = 20, ai = "basic", background = { map = "Mulgore" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "MUL01", "MUL01", "BRN03", "BRN03", "BRN04", "MUL03", "MUL03", "BRN06",
        "BRN12", "MUL06", "MUL06", "AZS07", "MUL07", "MUL07", "LOC08", "SIL08",
        "ASH09",
        "DRU06", "HUN08", "PAL04", "GEAR05",
        "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01",
    },
})

-- Teldrassil: Denalan (A druid alone at Lake Al'Ameth: timberlings and the forest's spirits)
TTS:AddDuel({
    id = "DUEL_TEL", npcs = { 2080 }, name = "Denalan", zone = "Teldrassil",
    life = 20, ai = "basic", background = { map = "Teldrassil" }, faction = "Alliance",
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "TEL01", "TEL01", "DAR03", "TEL03", "TEL03", "TEL04", "TEL04", "TEL05", "TEL05",
        "TEL06", "TEL06", "DAR07", "TEL07", "TEL07", "FEL08", "TEL08", "TEL10",
        "DRU04", "DRU03", "DRU08", "GEAR03",
        "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "W01", "W01", "W01", "W01", "W01",
    },
})

-- Darkshore: Onu (The ancient of lore: furbolgs, the moon and old roots)
TTS:AddDuel({
    id = "DUEL_DAR", npcs = { 3616 }, name = "Onu", zone = "Darkshore",
    life = 20, ai = "basic", background = { map = "Darkshore" }, faction = "Alliance",
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "DAR01", "DAR01", "ASH03", "DAR03", "DAR03", "DAR04", "DAR04", "ASH06", "ASH06",
        "DAR05", "DAR05", "ASH07", "ASH07", "DAR07", "DAR08", "FEL08", "DAR09",
        "DRU10", "DRU02", "DRU07", "GEAR09",
        "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "U01", "U01", "U01", "U01", "U01", "U01", "U01",
    },
})

-- The Barrens: Kilxx (Ratchet's fisherman: what comes up on the line)
TTS:AddDuel({
    id = "DUEL_BRN", npcs = { 3497 }, name = "Kilxx", zone = "The Barrens",
    life = 20, ai = "basic", background = { map = "Barrens" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "BRN02", "BRN02", "BRN03", "BRN03", "BRN04", "BRN04", "DUS03", "BRN06",
        "BRN12", "BRN12", "DUS05", "DUS07", "DUS07", "RED07", "DUS08", "ELW08",
        "DUS09",
        "SHA04", "SHA04", "MAG05", "MAG05", "FSH01",
        "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "G01", "G01", "G01", "G01", "G01",
    },
})

-- Stonetalon Mountains: Ziz Fizziks (A goblin in a hut at Windshear Crag: Venture Co. machines and stone)
TTS:AddDuel({
    id = "DUEL_STO", npcs = { 4201 }, name = "Ziz Fizziks", zone = "Stonetalon Mountains",
    life = 20, ai = "tactical", background = { map = "StonetalonMountains" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "STO01", "STO01", "ARA03", "STO03", "STO03", "STO04", "STO04", "STO05", "STO05",
        "STO06", "STO06", "STO07", "STO07", "ZEP09", "FER08", "MUL08", "STO09",
        "MAG02", "MAG02", "MAG06", "MAG06", "EGR03",
        "R01", "R01", "R01", "R01", "R01", "R01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01",
    },
})

-- Ashenvale: Bhaldaran Ravenshade (The bowyer in the woods, and the Zoram'gar trolls on the coast: hunters and their quarry)
TTS:AddDuel({
    id = "DUEL_ASH", npcs = { 3951, 12719 }, name = "Bhaldaran Ravenshade", zone = "Ashenvale",
    life = 20, ai = "tactical", background = { map = "Ashenvale" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "ASH01", "ASH01", "ALT04", "ALT04", "ASH03", "ASH03", "BAD04", "ASH06", "ASH06",
        "AZS05", "AZS05", "ASH07", "ASH07", "AZS07", "DUN08", "LOC08", "ASH09",
        "HUN03", "HUN04", "HUN06", "GEAR14",
        "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "U01", "U01", "U01", "U01", "U01",
    },
})

-- Thousand Needles: Pozzik (A Mirage Raceway racer: everything fast)
TTS:AddDuel({
    id = "DUEL_THO", npcs = { 4630 }, name = "Pozzik", zone = "Thousand Needles",
    life = 20, ai = "tactical", background = { map = "ThousandNeedles" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "BRN01", "BRN01", "DES04", "DES04", "ELW04", "THO03", "THO03", "ASH05", "ASH05",
        "BRN05", "BRN05", "BRN07", "BRN07", "UNG07", "DUR08", "THO08", "AZS09",
        "WAR02", "WAR02", "ROG06", "ROG06", "GEAR18",
        "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "W01", "W01", "W01", "W01", "W01",
    },
})

-- Desolace: Smeed Scrabblescrew (Scavenging the Kodo Graveyard: bones, scavengers and centaur raiders)
TTS:AddDuel({
    id = "DUEL_DES", npcs = { 11596 }, name = "Smeed Scrabblescrew", zone = "Desolace",
    life = 20, ai = "tactical", background = { map = "Desolace" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "DES02", "DES02", "ALT04", "ALT04", "ASH03", "ASH03", "ASH04", "BRN06",
        "BRN12", "DES05", "DES05", "AZS07", "DES07", "DES07", "BRN08", "DES08",
        "ASH09",
        "WLK04", "WLK04", "ROG07", "ROG07",
        "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "G01", "G01", "G01", "G01", "G01", "G01",
    },
})

-- Dustwallow Marsh: Tabetha (A mage living alone in the swamp: elementals and spellbooks)
TTS:AddDuel({
    id = "DUEL_DUS", npcs = { 6546 }, name = "Tabetha", zone = "Dustwallow Marsh",
    life = 25, ai = "expert", background = { map = "Dustwallow" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "DUS01", "DUS01", "ARA03", "DUS03", "DUS03", "DUS04", "DUS04", "ASH06", "ASH06",
        "SEA06", "SEA06", "DUS07", "DUS07", "STO07", "DUS08", "FER08", "DUS09",
        "MAG05", "MAG07", "MAG01", "MAG10",
        "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "R01", "R01", "R01",
    },
})

-- Feralas: Gregan Brewspewer (A dwarf drinking alone by the Twin Colossals: ogres, gnolls and a bar fight)
TTS:AddDuel({
    id = "DUEL_FER", npcs = { 7775 }, name = "Gregan Brewspewer", zone = "Feralas",
    life = 25, ai = "expert", background = { map = "Feralas" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "FER02", "FER02", "FER03", "FER03", "RED03", "RED03", "ALT06", "ALT06",
        "FER06", "FER06", "RED06", "ALT07", "ALT07", "BUR08", "ELW12", "TAN08",
        "ALT10",
        "WAR04", "WAR04", "WAR01", "WAR01", "GEAR26", "COK03",
        "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "R01", "G01", "G01",
    },
})

-- Tanaris: Prospector Ironboot (A prospector at Steamwheedle Port: sand, stone and dynamite)
TTS:AddDuel({
    id = "DUEL_TAN", npcs = { 10460 }, name = "Prospector Ironboot", zone = "Tanaris",
    life = 25, ai = "expert", background = { map = "Tanaris" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "TAN02", "TAN02", "DES04", "DES04", "ELW04", "TAN03", "TAN03", "BAD05", "BAD05",
        "TAN06", "TAN06", "SLI07", "SLI07", "STO07", "DUR08", "TAN08", "TAN09",
        "WAR06", "WAR06", "SHA02", "SHA02", "MNG02", "GEAR27",
        "R01", "R01", "R01", "R01", "R01", "R01", "R01", "W01", "W01", "W01", "W01", "W01", "W01", "W01", "W01",
    },
})

-- Azshara: Loramus Thalipedes (The hermit of the Bay of Storms: what the Highborne left behind)
TTS:AddDuel({
    id = "DUEL_AZS", npcs = { 7783 }, name = "Loramus Thalipedes", zone = "Azshara",
    life = 25, ai = "expert", background = { map = "Aszhara" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "AZS01", "AZS01", "EPL01", "AZS03", "AZS03", "BLA04", "BLA04", "FER04",
        "AZS05", "AZS05", "AZS06", "AZS06", "HYJ10", "AZS08", "DAR08", "EPL08",
        "HYJ13",
        "MAG09", "MAG09", "WLK05", "WLK05", "GEAR30",
        "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "U01", "U01", "U01", "U01", "U01", "U01",
    },
})

-- Felwood: Arathandris Silversky (An Emerald Circle druid fighting the corruption: tainted beasts and satyrs)
TTS:AddDuel({
    id = "DUEL_FEL", npcs = { 9528 }, name = "Arathandris Silversky", zone = "Felwood",
    life = 25, ai = "expert", background = { map = "Felwood" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "FEL01", "FEL01", "ALT04", "ALT04", "ASH03", "FEL04", "FEL04", "BRN06",
        "BRN12", "BRN12", "DAR05", "AZS07", "FEL07", "FEL07", "AZS08", "FEL08",
        "ASH09",
        "DRU07", "DRU05", "HUN02", "GEAR33",
        "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "B01", "B01", "B01",
    },
})

-- Un'Goro Crater: Torwa Pathfinder (A tauren tracking the crater's dinosaurs)
TTS:AddDuel({
    id = "DUEL_UNG", npcs = { 9619 }, name = "Torwa Pathfinder", zone = "Un'Goro Crater",
    life = 25, ai = "expert", background = { map = "UngoroCrater" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "UNG02", "UNG02", "ALT04", "UNG03", "UNG03", "UNG04", "UNG04", "UNG05", "UNG05",
        "UNG06", "UNG06", "AZS07", "UNG07", "UNG07", "DUR08", "HYJ12", "UNG10",
        "HUN10", "HUN10", "DRU06", "DRU06", "GEAR32", "LTW04",
        "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "R01", "R01", "R01", "R01",
    },
})

-- Silithus: Hermit Ortell (The Silithus hermit: sand, silithid and the Twilight's Hammer)
TTS:AddDuel({
    id = "DUEL_SLI", npcs = { 15194 }, name = "Hermit Ortell", zone = "Silithus",
    life = 25, ai = "expert", background = { map = "Silithus" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "SLI01", "SLI01", "SLI03", "SLI03", "SLI04", "SLI04", "RIV05", "RIV05",
        "SLI06", "SLI06", "RIV08", "RIV08", "SLI07", "SLI07", "RIV09", "SLI08",
        "SLI09",
        "PRI07", "PRI07", "PAL08", "PAL08", "GEAR38",
        "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "B01", "W01", "W01", "W01", "W01",
    },
})

-- Winterspring: Donova Snowden (A researcher alone in the snow: Winterspring's wildlife and the cold)
TTS:AddDuel({
    id = "DUEL_WIN", npcs = { 9298 }, name = "Donova Snowden", zone = "Winterspring",
    life = 25, ai = "expert", background = { map = "Winterspring" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "WIN01", "WIN01", "AZS04", "AZS04", "DAR04", "WIN04", "WIN04", "ASH05", "ASH05",
        "WIN05", "WIN05", "DUN07", "WIN07", "WIN07", "DUN08", "WIN08", "WIN09",
        "MAG06", "SHA04", "MAG05", "GEAR36",
        "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "W01", "W01", "W01", "W01", "W01", "W01",
    },
})

-- Zephras Isle: Aetheen of the Gales (An elder of the isle: its winds and its people)
TTS:AddDuel({
    id = "DUEL_ZEP", npcs = { 251366 }, name = "Aetheen of the Gales", zone = "Zephras Isle",
    life = 25, ai = "expert", background = { map = "ZephrasIsle" },
    reward = nil,   -- their Location card, once it exists
    deck = {   -- 38 cards, and 2 slots for their Location (2 copies) when it's added
        "ZEP02", "ZEP02", "ARA03", "ARA03", "ARA04", "ZEP04", "ZEP04", "ASH06", "ASH06",
        "ZEP05", "ZEP05", "ZEP08", "ZEP08", "ZEP09", "FER08", "ZEP10", "ZEP11",
        "SHA04", "SHA04", "MAG09", "MAG09",
        "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "U01", "W01", "W01",
    },
})
