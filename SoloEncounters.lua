--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
TTS.Engine = TTS.Engine or {}
local E = TTS.Engine
local L = TTS.L

-- =========================================================================
-- SOLO ENCOUNTERS
-- Zone Gauntlet: one opponent per zone playing that zone's 10 creatures; winning grants
-- the zone's reward card (<ZONE>11). Dungeons: the dungeon's creatures plus its BOSSxx
-- card(s) under one or two boss rules; winning grants the dungeon's reward card.
--
-- Encounter fields:
--   kind        "zone" | "dungeon" | "practice"
--   name        shown in the select window
--   opponent    display name used for E.opponent (dungeons: the first boss)
--   zone        the deck is built from creatures carrying this zone tag
--   life        AI starting life
--   ai          AI profile: dummy | basic | tactical | expert (see AI.lua)
--   reward      card id granted for a win (1 copy per win, up to 4)
--   requires    nil (open) | { cleared = { ids } } (any one cleared) | { killed = "BOSSxx" }
--               Zones need a connected zone cleared (TTS.SoloConnections); a dungeon needs
--               the zone it sits in cleared.
--   map         { continent, x, y } button position on the select map (UI\SoloMapData.lua)
--   bosses      dungeon boss card ids
--   rules       boss rule ids, see TTS.EncounterRules below
--   background  { map = "<WorldMap folder>" } or
--               { loadscreen = "<Glues\LoadingScreens file>", wide = bool, map = ..., tint = { r, g, b } }
-- =========================================================================
TTS.SoloEncounters = {}
local ENC = TTS.SoloEncounters

-- Zones that are open from the start
local START_ZONES = { ELW = true, TIR = true, DUR = true, MUL = true, TEL = true }

-- id, zone, opponent, world map folder, AI profile
local ZONES = {
    -- Eastern Kingdoms
    { "ELW", "Elwynn Forest",        "Elwynn Exterminators",            "Elwynn",              "basic" },
    { "DUN", "Dun Morogh",           "Dun Morogh Defenders",            "DunMorogh",           "basic" },
    { "TIR", "Tirisfal Glades",      "Tirisfal Tormentors",             "Tirisfal",            "basic" },
    { "WES", "Westfall",             "Westfall Wreckers",               "Westfall",            "basic" },
    { "LOC", "Loch Modan",           "Loch Modan Looters",              "LochModan",           "basic" },
    { "SIL", "Silverpine Forest",    "Silverpine Skulkers",             "Silverpine",          "basic" },
    { "RED", "Redridge Mountains",   "Redridge Raiders",                "Redridge",            "tactical" },
    { "DSK", "Duskwood",             "Duskwood Dreadstalkers",          "Duskwood",            "tactical" },
    { "WET", "Wetlands",             "Wetlands Warband",                "Wetlands",            "tactical" },
    { "HIL", "Hillsbrad Foothills",  "Hillsbrad Harriers",              "Hilsbrad",            "tactical" },
    { "ALT", "Alterac Mountains",    "Alterac Ambushers",               "Alterac",             "tactical" },
    { "ARA", "Arathi Highlands",     "Arathi Avengers",                 "Arathi",              "tactical" },
    { "STV", "Stranglethorn Vale",   "Stranglethorn Stalkers",          "Stranglethorn",       "expert" },
    { "BAD", "Badlands",             "Badlands Bruisers",               "Badlands",            "expert" },
    { "SWA", "Swamp of Sorrows",     "Swamp of Sorrows Slitherers",     "SwampOfSorrows",      "expert" },
    { "HIN", "The Hinterlands",      "Hinterlands Headhunters",         "Hinterlands",         "expert" },
    { "SEA", "Searing Gorge",        "Searing Gorge Scorchers",         "SearingGorge",        "expert" },
    { "BLA", "Blasted Lands",        "Blasted Lands Bloodbringers",     "BlastedLands",        "expert" },
    { "BUR", "Burning Steppes",      "Burning Steppes Brutes",          "BurningSteppes",      "expert" },
    { "WPL", "Western Plaguelands",  "Western Plaguelands Wretches",    "WesternPlaguelands",  "expert" },
    { "EPL", "Eastern Plaguelands",  "Eastern Plaguelands Eradicators", "EasternPlaguelands",  "expert" },
    -- Kalimdor
    { "DUR", "Durotar",              "Durotar Despoilers",              "Durotar",             "basic" },
    { "MUL", "Mulgore",              "Mulgore Marauders",               "Mulgore",             "basic" },
    { "TEL", "Teldrassil",           "Teldrassil Tricksters",           "Teldrassil",          "basic" },
    { "DAR", "Darkshore",            "Darkshore Drifters",              "Darkshore",           "basic" },
    { "BRN", "The Barrens",          "Barrens Bandits",                 "Barrens",             "basic" },
    { "STO", "Stonetalon Mountains", "Stonetalon Saboteurs",            "StonetalonMountains", "tactical" },
    { "ASH", "Ashenvale",            "Ashenvale Assassins",             "Ashenvale",           "tactical" },
    { "THO", "Thousand Needles",     "Thousand Needles Thrashers",      "ThousandNeedles",     "tactical" },
    { "DES", "Desolace",             "Desolace Defilers",               "Desolace",            "tactical" },
    { "DUS", "Dustwallow Marsh",     "Dustwallow Drowners",             "Dustwallow",          "expert" },
    { "FER", "Feralas",              "Feralas Fangs",                   "Feralas",             "expert" },
    { "TAN", "Tanaris",              "Tanaris Tomb Raiders",            "Tanaris",             "expert" },
    { "AZS", "Azshara",              "Azshara Abominations",            "Aszhara",             "expert" },
    { "FEL", "Felwood",              "Felwood Fiends",                  "Felwood",             "expert" },
    { "UNG", "Un'Goro Crater",       "Un'Goro Usurpers",                "UngoroCrater",        "expert" },
    { "SLI", "Silithus",             "Silithus Swarm",                  "Silithus",            "expert" },
    { "WIN", "Winterspring",         "Winterspring Wendigos",           "Winterspring",        "expert" },
}

-- Zones that border each other (and the Deeprun Tram between Elwynn and Dun Morogh).
-- Clearing a zone opens every zone connected to it.
TTS.SoloConnections = {
    -- Eastern Kingdoms
    { "ELW", "WES" }, { "ELW", "RED" }, { "ELW", "DSK" }, { "ELW", "DUN" },
    { "DUN", "LOC" }, { "LOC", "WET" }, { "LOC", "BAD" },
    { "WES", "DSK" }, { "RED", "DSK" }, { "RED", "BUR" }, { "RED", "SWA" },
    { "DSK", "STV" }, { "DSK", "SWA" }, { "SWA", "BLA" },
    { "BUR", "SEA" }, { "SEA", "BAD" },
    { "WET", "ARA" }, { "ARA", "HIL" }, { "ARA", "HIN" },
    { "HIL", "ALT" }, { "HIL", "SIL" }, { "HIL", "HIN" },
    { "ALT", "SIL" }, { "ALT", "WPL" }, { "SIL", "TIR" }, { "TIR", "WPL" },
    { "WPL", "EPL" }, { "WPL", "HIN" }, { "HIN", "EPL" },
    -- Kalimdor
    { "TEL", "DAR" }, { "DAR", "ASH" },
    { "ASH", "AZS" }, { "ASH", "FEL" }, { "ASH", "STO" }, { "ASH", "BRN" }, { "FEL", "WIN" },
    { "DUR", "BRN" }, { "MUL", "BRN" }, { "MUL", "STO" },
    { "BRN", "STO" }, { "BRN", "DUS" }, { "BRN", "THO" },
    { "STO", "DES" }, { "DES", "FER" }, { "FER", "THO" },
    { "THO", "TAN" }, { "TAN", "UNG" }, { "UNG", "SLI" },
}

-- The zone each dungeon's entrance is in; clearing that zone opens the dungeon
TTS.SoloDungeonZone = {
    RFC = "DUR", DMS = "WES", WCV = "BRN", SFK = "SIL", BFD = "ASH", STK = "ELW", GNO = "DUN",
    RFK = "BRN", SMO = "TIR", RFD = "BRN", ULD = "BAD", ZFK = "TAN", MAR = "DES", SUN = "SWA",
    BRD = "SEA", BRS = "BUR", DMA = "FER", SCH = "WPL", STR = "EPL",
    -- WoW Forever dungeons
    HOT = "DUN", ROL = "TIR", EXC = "WET", DAL = "ALT",
}

local neighbours = {}
for _, link in ipairs(TTS.SoloConnections) do
    local a, b = link[1], link[2]
    neighbours[a] = neighbours[a] or {}
    neighbours[b] = neighbours[b] or {}
    table.insert(neighbours[a], b)
    table.insert(neighbours[b], a)
end

for i, z in ipairs(ZONES) do
    ENC[z[1]] = {
        id = z[1], kind = "zone", order = i,
        name = z[2], zone = z[2], opponent = z[3],
        life = 20, ai = z[5],
        reward = z[1] .. "11",
        requires = (not START_ZONES[z[1]]) and { cleared = neighbours[z[1]] } or nil,
        background = { map = z[4] },
    }
end

-- id, dungeon (zone tag), boss cards, AI life, rules, reward, AI profile, loading screen, fallback map
local DUNGEONS = {
    { "RFC", "Ragefire Chasm",    { "BOSS01" },                               20, { "HEAD_START" },                     "RFC08", "tactical", "LoadScreenRagefireChasm",    "Durotar" },
    { "DMS", "The Deadmines",     { "BOSS02" },                               25, { "REINFORCEMENTS" },                 "DMS12", "tactical", "LoadScreenDeadmines",        "Westfall" },
    { "WCV", "Wailing Caverns",   { "BOSS03" },                               25, { "AWAKENING" },                      "WCV13", "tactical", "LoadScreenWailingCaverns",   "Barrens" },
    { "SFK", "Shadowfang Keep",   { "BOSS04" },                               25, { "OPENING_BOSS" },                   "SFK13", "tactical", "LoadScreenShadowfangKeep",   "Silverpine" },
    { "BFD", "Blackfathom Deeps", { "BOSS05" },                               25, { "REINFORCEMENTS" },                 "BFD12", "tactical", "LoadScreenBlackfathomDeeps", "Ashenvale" },
    { "STK", "The Stockade",      { "BOSS06" },                               25, { "REINFORCEMENTS" },                 "STK08", "tactical", "LoadScreenStormwindStockade", "Elwynn" },
    { "GNO", "Gnomeregan",        { "BOSS07" },                               30, { "HEAD_START" },                     "GNO09", "tactical", "LoadScreenGnomeregan",       "DunMorogh" },
    { "RFK", "Razorfen Kraul",    { "BOSS08" },                               25, { "OPENING_BOSS" },                   "RFK13", "tactical", "LoadScreenRazorfenKraul",    "Barrens" },
    { "SMO", "Scarlet Monastery", { "BOSS09", "BOSS10", "BOSS11", "BOSS12" }, 30, { "NEXT_BOSS" },                      "SMO14", "expert",   "LoadScreenMonastery",        "Tirisfal" },
    { "RFD", "Razorfen Downs",    { "BOSS13" },                               30, { "ENRAGE" },                         "RFD08", "expert",   "LoadScreenRazorfenDowns",    "Barrens" },
    { "ULD", "Uldaman",           { "BOSS14" },                               30, { "AWAKENING" },                      "ULD13", "expert",   "LoadScreenUldaman",          "Badlands" },
    { "ZFK", "Zul'Farrak",        { "BOSS15" },                               30, { "REINFORCEMENTS" },                 "ZFK12", "expert",   "LoadScreenZulFarrak",        "Tanaris" },
    { "MAR", "Maraudon",          { "BOSS16" },                               30, { "HEAD_START" },                     "MAR13", "expert",   "LoadScreenMaraudon",         "Desolace" },
    { "SUN", "Sunken Temple",     { "BOSS17" },                               30, { "ENRAGE" },                         "SUN13", "expert",   "LoadScreenSunkenTemple",     "SwampOfSorrows" },
    { "BRD", "Blackrock Depths",  { "BOSS18" },                               35, { "OPENING_BOSS", "REINFORCEMENTS" }, "BRD23", "expert",   "LoadScreenBlackrockDepths",  "SearingGorge" },
    { "BRS", "Blackrock Spire",   { "BOSS19", "BOSS20" },                     35, { "NEXT_BOSS" },                      "BRS20", "expert",   "LoadScreenBlackrockSpire",   "BurningSteppes" },
    { "DMA", "Dire Maul",         { "BOSS21", "BOSS22", "BOSS23" },           35, { "NEXT_BOSS" },                      "DMA19", "expert",   "LoadScreenDireMaul",         "Feralas" },
    { "SCH", "Scholomance",       { "BOSS24" },                               35, { "REINFORCEMENTS", "ENRAGE" },       "SCH18", "expert",   "LoadScreenScholomance",      "WesternPlaguelands" },
    { "STR", "Stratholme",        { "BOSS25", "BOSS26" },                     40, { "NEXT_BOSS", "ENRAGE" },            "STR21", "expert",   "LoadScreenStrathome",        "EasternPlaguelands" },
    -- WoW Forever dungeons (16:9 loading screens)
    { "HOT", "The Hall of Thanes", { "BOSS27" },                              25, { "REINFORCEMENTS" },                 "HOT12", "tactical", "Camelot160\\Main\\LoadScreen_Camelot_OldIronforge",      "Ironforge" },
    { "ROL", "Ruins of Lordaeron", { "BOSS28" },                              25, { "AWAKENING" },                      "ROL16", "tactical", "Camelot160\\Main\\LoadScreen_Camelot_RuinsOfLordaeron", "Tirisfal" },
    { "EXC", "Excavation Site",    { "BOSS29" },                              30, { "AWAKENING" },                      "EXC17", "expert",   "Camelot160\\Main\\LoadScreen_Camelot_Excavation",       "Wetlands" },
    { "DAL", "City of Dalaran",    { "BOSS30" },                              30, { "AWAKENING", "ENRAGE" },            "DAL22", "expert",   "Camelot160\\Main\\LoadScreen_Camelot_Dalaran",          "Alterac" },
}
local WIDE_LOADSCREENS = { HOT = true, ROL = true, EXC = true, DAL = true }

for i, d in ipairs(DUNGEONS) do
    local firstBoss = TTS.Cards[d[3][1]]
    ENC[d[1]] = {
        id = d[1], kind = "dungeon", order = i,
        name = d[2], zone = d[2], opponent = firstBoss and firstBoss.name or d[2],
        life = d[4], ai = d[7], rules = d[5], bosses = d[3],
        reward = d[6],
        -- Opened by clearing the zone the dungeon sits in
        requires = { cleared = { TTS.SoloDungeonZone[d[1]] } },
        background = { loadscreen = d[8], wide = WIDE_LOADSCREENS[d[1]], map = d[9], tint = { 0.6, 0.55, 0.5 } },
    }
end

-- The tutorial (UI\Tutorial.lua): a short scripted game. Both decks are drawn in this
-- order (top first; the first 7 are the opening hands) and the dummy AI plays them
-- predictably, so the coach's steps line up turn by turn:
--   you 1: Prayer of Light, Burning Blade Augur   them 1: Ragged Young Wolf (Quick) attacks, you block
--   you 2: Prayer, Primitive Owlbeast, attack       them 2: Groddoc Ape
--   you 3: Prayer of Fire, Fire Blast the Ape, attack with both for the win (they start on 4 life)
ENC.TUTORIAL = {
    id = "TUTORIAL", kind = "practice", name = "Tutorial", opponent = "Training Partner",
    life = 4, ai = "dummy", fixedOrder = true, isTutorial = true,
    playerDeck = { "W01", "DES01", "W01", "HIN04", "R01", "MAG02", "W01",
                   "W01", "W01", "W01", "W01", "W01", "W01", "W01", "W01", "W01" },
    deck = { "G01", "DUN01", "G01", "FER03", "G01", "G01", "G01",
             "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01", "G01" },
}

-- The sandbox: today's fixed dummy deck and simple AI
ENC.PRACTICE = {
    id = "PRACTICE", kind = "practice", name = "Practice vs Dummy", opponent = "Target Dummy",
    life = 20, ai = "dummy",
    deck = {
        "W01", "W01", "W01", "W01",
        "U01", "U01", "U01", "U01",
        "B01", "B01", "B01", "B01",
        "R01", "R01", "R01", "R01",
        "G01", "G01",
        "ELW02", "RED04", "TEL06", "TEL07",
        "DAR01", "DUN04", "LOC03", "DUN06",
        "TIR01", "ELW03", "TIR03", "TIR05", "WES07",
        "ELW01", "ELW04", "RED03", "ELW05",
        "DUN01", "DUN03", "WES04", "ELW06", "LOC07",
    },
}

-- Encounters of one kind in display order
function TTS:GetSoloEncounters(kind)
    local list = {}
    for _, enc in pairs(ENC) do
        if enc.kind == kind then table.insert(list, enc) end
    end
    table.sort(list, function(a, b) return a.order < b.order end)
    return list
end

-- The encounter that grants a reward card (nil if the card is not a reward)
function TTS:GetRewardEncounter(cardId)
    for _, enc in pairs(ENC) do
        if enc.reward == cardId then return enc end
    end
end

-- =========================================================================
-- DECK GENERATION
-- 40 cards: the zone's creatures (2 copies each), or for a dungeon its boss card(s) padded
-- to 22 creatures with the dungeon's creatures; then a few class spells the AI can use
-- (and for a zone, 2 copies of its Gear Card); prayers fill the rest, split by the colour share of the creatures' pips.
-- =========================================================================
local DECK_SIZE = 40
local DUNGEON_CREATURES = 22
local SPELLS_BY_PROFILE = { dummy = 0, basic = 2, tactical = 3, expert = 4 }
local ZONE_GEAR_COPIES = 2   -- copies of the zone's Gear Card in a zone opponent's deck
local PRAYER_IDS = { W = "W01", U = "U01", B = "B01", R = "R01", G = "G01" }

-- Spell ops the AI knows how to use well
local AI_SPELL_OPS = { damage = true, dot = true, destroy = true, freeze = true, tap = true, heal = true,
    hot = true, buff = true, shield = true, draw = true, raise = true, tuck = true, shielded = true }

local function IsAIFriendlySpell(card)
    if card.type ~= "Sorcery" or not card.effect or not card.effect.ops then return false end
    if card.isGift then return false end   -- Gear is the zone's own (ZONE_GEAR_COPIES), not a class spell
    for _, op in ipairs(card.effect.ops) do
        if not AI_SPELL_OPS[op.op] then return false end
        if op.to == "self_player" and op.op == "damage" then return false end
    end
    return true
end

local function IsRemovalSpell(card)
    for _, op in ipairs(card.effect.ops) do
        if (op.op == "damage" or op.op == "destroy" or op.op == "tuck" or op.op == "freeze")
            and (op.to == "target" or op.to == "enemy_creatures") then
            return true
        end
    end
    return false
end

-- Small stable string hash, so an encounter always gets the same spells
local function Hash(s)
    local h = 5381
    for i = 1, #s do h = (h * 33 + s:byte(i)) % 2147483647 end
    return h
end

local function CountPips(cost, into)
    for pip in string.gmatch(cost or "", "{(%a)}") do
        if PRAYER_IDS[pip] then into[pip] = (into[pip] or 0) + 1 end
    end
end

function E:BuildEncounterDeck(enc)
    local deck = {}
    if enc.deck then
        for _, id in ipairs(enc.deck) do table.insert(deck, id) end
        return deck
    end

    local isBossCard = {}
    for _, b in ipairs(enc.bosses or {}) do isBossCard[b] = true end
    local nextBoss = false
    for _, r in ipairs(enc.rules or {}) do if r == "NEXT_BOSS" then nextBoss = true end end

    -- The encounter's own creatures (never reward cards or BOSSxx cards)
    local pool = {}
    for id, c in pairs(TTS.Cards) do
        if c.type == "Creature" and c.zone == enc.zone and not c.isReward and not id:match("^BOSS") then
            table.insert(pool, id)
        end
    end
    table.sort(pool, function(a, b)
        local ca, cb = TTS.Cards[a], TTS.Cards[b]
        if (ca.cmc or 0) ~= (cb.cmc or 0) then return (ca.cmc or 0) < (cb.cmc or 0) end
        return a < b
    end)

    local creatures = {}
    if enc.kind == "dungeon" then
        -- Next Boss dungeons shuffle in only the first boss; the rule brings in the rest
        if nextBoss then
            table.insert(creatures, enc.bosses[1])
        else
            for _, b in ipairs(enc.bosses) do table.insert(creatures, b) end
        end
        local copies = {}
        local maxCopies = 2
        while #creatures < DUNGEON_CREATURES and #pool > 0 do
            local added = false
            for _, id in ipairs(pool) do
                if #creatures >= DUNGEON_CREATURES then break end
                if (copies[id] or 0) < maxCopies then
                    copies[id] = (copies[id] or 0) + 1
                    table.insert(creatures, id)
                    added = true
                end
            end
            if not added then
                if maxCopies >= 4 then break end
                maxCopies = maxCopies + 1
            end
        end
    else
        for _, id in ipairs(pool) do
            table.insert(creatures, id)
            table.insert(creatures, id)
        end
    end

    -- Colour share of the creatures' pips
    local pips = {}
    for _, id in ipairs(creatures) do CountPips(TTS.Cards[id].cost, pips) end
    if enc.bosses and nextBoss then
        for _, b in ipairs(enc.bosses) do CountPips(TTS.Cards[b] and TTS.Cards[b].cost, pips) end
    end

    -- Class spells in the deck's colours
    local spells = {}
    local want = SPELLS_BY_PROFILE[enc.ai] or 0
    if want > 0 then
        -- Only the deck's main colours (a fifth of the pips or more), so spells are castable
        local totalPips, mainColor = 0, {}
        for _, n in pairs(pips) do totalPips = totalPips + n end
        for col, n in pairs(pips) do
            if n >= math.max(2, totalPips * 0.2) then mainColor[col] = true end
        end
        local removal, other = {}, {}
        for id, c in pairs(TTS.Cards) do
            if mainColor[c.color] and IsAIFriendlySpell(c) then
                table.insert(IsRemovalSpell(c) and removal or other, id)
            end
        end
        local seed = Hash(enc.id or enc.name or "")
        local function Pick(list)
            if #list == 0 then return nil end
            table.sort(list)
            local i = (seed % #list) + 1
            seed = Hash(tostring(seed))
            return table.remove(list, i)
        end
        -- At least half removal, the rest from anything that fits
        local nRemoval = math.ceil(want / 2)
        for _ = 1, nRemoval do
            local id = Pick(removal)
            if id then table.insert(spells, id) end
        end
        for _, id in ipairs(removal) do table.insert(other, id) end
        while #spells < want do
            local id = Pick(other)
            if not id then break end
            table.insert(spells, id)
        end
    end

    -- A zone opponent arms its denizens with the zone's own Gear Card (colourless, so
    -- always castable). The dummy casts no spells, so it gets none.
    if enc.kind == "zone" and want > 0 then
        local gear = {}
        for id, c in pairs(TTS.Cards) do
            if c.subType == "Gear" and c.zone == enc.zone then table.insert(gear, id) end
        end
        table.sort(gear)
        for _, id in ipairs(gear) do
            for _ = 1, ZONE_GEAR_COPIES do table.insert(spells, id) end
        end
    end

    for _, id in ipairs(creatures) do table.insert(deck, id) end
    for _, id in ipairs(spells) do table.insert(deck, id) end

    -- Prayers: largest remainder split of the pip share, at least 2 of every colour used
    local nPrayers = DECK_SIZE - #deck
    local totalPips = 0
    for _, n in pairs(pips) do totalPips = totalPips + n end
    if totalPips == 0 then pips, totalPips = { W = 1 }, 1 end
    local alloc, rema, given = {}, {}, 0
    for col, n in pairs(pips) do
        local exact = nPrayers * n / totalPips
        alloc[col] = math.max(2, math.floor(exact))
        rema[col] = exact - math.floor(exact)
        given = given + alloc[col]
    end
    local order = {}
    for col in pairs(alloc) do table.insert(order, col) end
    table.sort(order, function(a, b)
        if rema[a] ~= rema[b] then return rema[a] > rema[b] end
        return a < b
    end)
    local k = 1
    while given < nPrayers do
        alloc[order[k]] = alloc[order[k]] + 1
        given = given + 1
        k = k % #order + 1
    end
    while given > nPrayers do
        -- The minimum of 2 overshot: take back from the colour with the most
        table.sort(order, function(a, b) return alloc[a] > alloc[b] end)
        alloc[order[1]] = alloc[order[1]] - 1
        given = given - 1
    end
    for _, col in ipairs({ "W", "U", "B", "R", "G" }) do
        for _ = 1, (alloc[col] or 0) do table.insert(deck, PRAYER_IDS[col]) end
    end
    return deck
end

-- =========================================================================
-- PROGRESS & REWARDS
-- TTS_SoloProgress = { cleared = { [encounterId] = wins }, rewards = { [cardId] = copies },
--                      attempts = { [dungeonId] = server time its last game started or ended } }
-- =========================================================================
local MAX_REWARD_COPIES = 4

local function Progress()
    TTS_SoloProgress = TTS_SoloProgress or {}
    TTS_SoloProgress.cleared = TTS_SoloProgress.cleared or {}
    TTS_SoloProgress.rewards = TTS_SoloProgress.rewards or {}
    TTS_SoloProgress.attempts = TTS_SoloProgress.attempts or {}
    return TTS_SoloProgress
end

-- A dungeon can be attempted again an hour after its last game, won or lost (zones have
-- no wait). The wait is set as a game starts too, so leaving one with a /reload still counts.
-- Server time, so changing the computer's clock doesn't bring it forward.
local DUNGEON_COOLDOWN = 3600
local function Now() return (GetServerTime and GetServerTime()) or time() end

function TTS:RecordEncounterAttempt(enc)
    if not (enc and enc.kind == "dungeon") then return end
    Progress().attempts[enc.id] = Now()
end

-- Seconds before the encounter can be attempted again (0 = it can now)
function TTS:EncounterCooldownLeft(enc)
    if not (enc and enc.kind == "dungeon") then return 0 end
    local last = tonumber(Progress().attempts[enc.id])
    if not last then return 0 end
    -- More than an hour ahead: a bad saved time, not a real wait
    local left = last + DUNGEON_COOLDOWN - Now()
    if left > DUNGEON_COOLDOWN then return 0 end
    return math.max(0, left)
end

function TTS:GetEncounterWins(id)
    return Progress().cleared[id] or 0
end

local function KillCount(cardId)
    local raw = TTS_KilledBosses and TTS_KilledBosses[cardId]
    if raw == true then return 4 end
    if type(raw) == "number" then return raw end
    return 0
end

-- Copies of a collectible card the player owns: reward cards from solo wins, boss and
-- mob cards from kills. Returns nil for cards anyone can use (spells, prayers).
function TTS:GetOwnedCopies(card)
    if not card then return 0 end
    if card.isHero then   -- always yours; more copies can be chosen every 10 levels (Hero.lua)
        return (card.id == "HERO" and TTS.Hero) and TTS.Hero:Copies() or 1
    end
    if card.isReward then
        return math.min(MAX_REWARD_COPIES, Progress().rewards[card.id] or 0)
    end
    if card.isBoss then
        return KillCount(card.id)
    end
    if card.isGift then
        -- Handed out by an NPC (UI\NpcGossip.lua): TTS_NpcGifts.copies[cardId]
        local copies = TTS_NpcGifts and TTS_NpcGifts.copies and TTS_NpcGifts.copies[card.id]
        return math.min(MAX_REWARD_COPIES, tonumber(copies) or 0)
    end
    if card.isBeta then
        -- One copy for beta players (DataStamp.lua)
        return (TTS_DataStamp and TTS_DataStamp.beta) and 1 or 0
    end
    return nil
end

-- Collection score: (Hearthstones + Gear + creature cards collected (1+ copies)) x
-- (Hearthstones + Gear + creature cards mastered (all 4) + 1). Hearthstones are the
-- innkeepers' gift prayers, Gear the weapon merchants' gift spells.
-- Returns score, collected, mastered, total, hearths collected, hearths mastered, hearth total,
-- gear collected, gear mastered, gear total.
function TTS:GetCollectionScore()
    local total, collected, mastered = 0, 0, 0
    local hTotal, hCollected, hMastered = 0, 0, 0
    local gTotal, gCollected, gMastered = 0, 0, 0
    for _, card in pairs(TTS.Cards or {}) do
        if card.isBeta then
            -- Beta players only: no one else can get it, so it never counts towards a collection
        elseif card.type == "Creature" and (card.isBoss or card.isReward) then
            total = total + 1
            local copies = self:GetOwnedCopies(card) or 0
            if copies >= 1 then collected = collected + 1 end
            if copies >= 4 then mastered = mastered + 1 end
        elseif card.type == "Land" and card.isGift then
            hTotal = hTotal + 1
            local copies = self:GetOwnedCopies(card) or 0
            if copies >= 1 then hCollected = hCollected + 1 end
            if copies >= MAX_REWARD_COPIES then hMastered = hMastered + 1 end
        elseif card.subType == "Gear" and card.isGift then
            gTotal = gTotal + 1
            local copies = self:GetOwnedCopies(card) or 0
            if copies >= 1 then gCollected = gCollected + 1 end
            if copies >= MAX_REWARD_COPIES then gMastered = gMastered + 1 end
        end
    end
    local score = (hCollected + gCollected + collected) * (hMastered + gMastered + mastered + 1)
    return score, collected, mastered, total, hCollected, hMastered, hTotal, gCollected, gMastered, gTotal
end

-- "1,234,567" (falls back to plain digits if the client lacks BreakUpLargeNumbers)
function TTS:FormatScore(n)
    if not n then return "?" end
    return BreakUpLargeNumbers and BreakUpLargeNumbers(n) or tostring(n)
end

-- FormatScore coloured by how far it is towards the best possible score, in item-quality
-- colours (grey -> white -> green -> blue -> purple -> orange), red when complete. The score grows
-- quadratically, so the square root of score/max tracks how much of the collection is done.
local SCORE_TIERS = {
    { 0.10, "9D9D9D" }, { 0.25, "FFFFFF" }, { 0.45, "1EFF00" },
    { 0.65, "0070DD" }, { 0.85, "A335EE" }, { 1, "FF8000" },
    { math.huge, "FF2020" },   -- red only when complete
}
-- text in the tier colour for a completion fraction (0..1)
function TTS:TierColored(f, text)
    for _, tier in ipairs(SCORE_TIERS) do
        if f < tier[1] then return "|cFF" .. tier[2] .. text .. "|r" end
    end
end

local maxScore
function TTS:ColoredScore(n)
    if not n then return "|cFF888888?|r" end
    if not maxScore then
        local _, _, _, total, _, _, hTotal, _, _, gTotal = self:GetCollectionScore()
        local all = hTotal + gTotal + total
        maxScore = all * (all + 1)
    end
    return self:TierColored(maxScore > 0 and math.sqrt(n / maxScore) or 0, self:FormatScore(n))
end

-- "n/max" coloured by n/max (collection counters)
function TTS:ColoredCount(n, max)
    return self:TierColored(max > 0 and n / max or 0, n .. "/" .. max)
end

-- Returns unlocked, reason (the reason says what is still needed)
function TTS:IsEncounterUnlocked(enc)
    local req = enc and enc.requires
    if not req then return true end
    if req.cleared then
        local names = {}
        for _, id in ipairs(req.cleared) do
            if self:GetEncounterWins(id) > 0 then return true end
            table.insert(names, ENC[id] and TTS:EncounterName(ENC[id]) or id)
        end
        return false, L("solo.clearFirst", table.concat(names, L("solo.or")))
    end
    if req.killed then
        if KillCount(req.killed) > 0 then return true end
        local boss = TTS.Cards[req.killed]
        return false, L("solo.defeatFirst", boss and TTS:CardName(boss) or req.killed, TTS:EncounterName(enc))
    end
    return true
end

-- Records a win; returns the reward card id and the copies now owned (nil if no reward)
function TTS:RecordEncounterWin(enc)
    if not enc or enc.kind == "practice" then return nil end
    local p = Progress()
    p.cleared[enc.id] = (p.cleared[enc.id] or 0) + 1
    if not enc.reward or not TTS.Cards[enc.reward] then return nil end
    local before = p.rewards[enc.reward] or 0
    if before < MAX_REWARD_COPIES then
        p.rewards[enc.reward] = before + 1
        if TTS.MarkCardNew then TTS:MarkCardNew(enc.reward) end
    end
    if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() and TTS.DeckBuilderFrame.RefreshAll then
        TTS.DeckBuilderFrame:RefreshAll()
    end
    return enc.reward, p.rewards[enc.reward], before >= MAX_REWARD_COPIES
end

-- =========================================================================
-- BOSS RULES
-- Each rule may implement onStart, onAITurnStart, onPlayerTurnStart, onCreatureDeath and
-- statBonus (perm, isRemote -> p, t) and freeCast (cardId -> true if the AI casts it for
-- nothing). Hooks receive (engine, encounter, ...).
-- =========================================================================
local function BossName(id)
    local c = TTS.Cards[id]
    return c and TTS:CardName(c) or id
end

-- Takes a card out of the AI's deck or hand (deck first). Returns true if found.
local function PullFromLibraryOrHand(self, cardId)
    for _, list in ipairs({ self.remoteState.deck, self.remoteState.hand }) do
        for i, id in ipairs(list) do
            if id == cardId then
                table.remove(list, i)
                self.remoteState.handCount = #self.remoteState.hand
                return true
            end
        end
    end
    return false
end

local function OnAIBattlefield(self, cardId)
    for _, p in ipairs(self.remoteState.field) do
        if p.id == cardId then return true end
    end
    return false
end

-- verbKey: locale key of the announcement, filled with the boss name
local function BringInBoss(self, bossId, verbKey)
    PullFromLibraryOrHand(self, bossId)
    self:Log("|cFFFF4444" .. L(verbKey, BossName(bossId)) .. "|r", "SYSTEM")
    self:PutCreatureOntoBattlefield(bossId, true, { ready = true, spawned = true })
end

TTS.EncounterRules = {
    OPENING_BOSS = {
        name = "Free Boss",
        text = "The boss costs the opponent nothing: it's cast as soon as it's drawn.",
        freeCast = function(self, enc, cardId)
            for _, b in ipairs(enc.bosses or {}) do
                if b == cardId then return true end
            end
            return false
        end,
    },
    HEAD_START = {
        name = "Head Start",
        text = "The opponent starts with 2 extra prayers on the battlefield.",
        onStart = function(self, enc)
            -- The two colours the deck leans on most
            local count = {}
            for _, id in ipairs(self.remoteState.deck) do
                local c = TTS.Cards[id]
                if c and c.type == "Land" then count[id] = (count[id] or 0) + 1 end
            end
            local ids = {}
            for id in pairs(count) do table.insert(ids, id) end
            table.sort(ids, function(a, b)
                if count[a] ~= count[b] then return count[a] > count[b] end
                return a < b
            end)
            for i = 1, 2 do
                local id = ids[((i - 1) % math.max(1, #ids)) + 1] or "W01"
                table.insert(self.remoteState.field, { id = id, tapped = false, uid = self:NewUid(), spawned = true })
            end
            self:Log(L("solo.headStart", self.opponent), "SYSTEM")
        end,
    },
    REINFORCEMENTS = {
        name = "Reinforcements",
        text = "At the start of every 3rd turn of the opponent, a random denizen from its deck joins the battle.",
        onAITurnStart = function(self, enc)
            if (self.remoteTurns or 0) % 3 ~= 0 then return end
            local options = {}
            for i, id in ipairs(self.remoteState.deck) do
                local c = TTS.Cards[id]
                if c and c.type == "Creature" then table.insert(options, i) end
            end
            if #options == 0 then return end
            local id = table.remove(self.remoteState.deck, options[math.random(#options)])
            self:Log(L("solo.reinforcements", BossName(id), self.opponent), "SYSTEM")
            self:PutCreatureOntoBattlefield(id, true, { spawned = true })
        end,
    },
    ENRAGE = {
        name = "Enrage",
        text = "From turn 10, the opponent's denizens get +2/+0.",
        onPlayerTurnStart = function(self, enc)
            if self.turn == 10 then
                self:Log(L("solo.enraged", self.opponent), "SYSTEM")
            end
        end,
        statBonus = function(self, enc, perm, isRemote)
            if isRemote and (self.turn or 0) >= 10 then return 2, 0 end
            return 0, 0
        end,
    },
    AWAKENING = {
        name = "Awakening",
        text = "The boss joins the battle at the start of the opponent's 5th turn, drawn or not.",
        onAITurnStart = function(self, enc)
            if self.remoteTurns ~= 5 then return end
            for _, b in ipairs(enc.bosses or {}) do
                -- Already in play or already defeated: nothing to awaken
                local inGraveyard = false
                for _, id in ipairs(self.remoteState.graveyard) do if id == b then inGraveyard = true end end
                if not OnAIBattlefield(self, b) and not inGraveyard then
                    BringInBoss(self, b, "solo.bossAwakens")
                end
            end
        end,
    },
    NEXT_BOSS = {
        name = "Next Boss",
        text = "Bosses fight one after another: the first is in the deck, and when a boss dies the next enters. Defeat the last boss to win.",
        onStart = function(self, enc)
            self.bossIndex = 1
            self.opponent = BossName(enc.bosses[1])
        end,
        onCreatureDeath = function(self, enc, perm, isRemote)
            local current = enc.bosses[self.bossIndex or 1]
            if perm.id ~= current then return end
            self.bossIndex = (self.bossIndex or 1) + 1
            local nextId = enc.bosses[self.bossIndex]
            if not nextId then
                self:WinMatch(L("solo.cleared", TTS:EncounterName(enc)))
                return
            end
            self.opponent = BossName(nextId)
            BringInBoss(self, nextId, "solo.bossEnters")
        end,
    },
}

-- Sum of the stat bonuses the encounter's rules give a creature
function E:EncounterStatBonus(perm, isRemote)
    local enc = self.encounter
    if not (enc and enc.rules) then return 0, 0 end
    local p, t = 0, 0
    for _, ruleId in ipairs(enc.rules) do
        local rule = TTS.EncounterRules[ruleId]
        if rule and rule.statBonus then
            local bp, bt = rule.statBonus(self, enc, perm, isRemote)
            p, t = p + (bp or 0), t + (bt or 0)
        end
    end
    return p, t
end

-- True if a rule lets the AI cast this card for nothing (Free Boss)
function E:EncounterFreeCast(cardId)
    local enc = self.encounter
    if not (self.isSolo and enc and enc.rules) then return false end
    for _, ruleId in ipairs(enc.rules) do
        local rule = TTS.EncounterRules[ruleId]
        if rule and rule.freeCast and rule.freeCast(self, enc, cardId) then return true end
    end
    return false
end

-- Rule names and text for display, one line each
function TTS:GetEncounterRuleLines(enc)
    local lines = {}
    for _, ruleId in ipairs(enc and enc.rules or {}) do
        local rule = TTS.EncounterRules[ruleId]
        if rule then
            table.insert(lines, {
                name = TTS.Locale:Data("rule." .. ruleId .. ".name", rule.name),
                text = TTS.Locale:Data("rule." .. ruleId .. ".text", rule.text),
            })
        end
    end
    return lines
end

local progressFrame = CreateFrame("Frame")
progressFrame:RegisterEvent("ADDON_LOADED")
progressFrame:SetScript("OnEvent", function(self, event, name)
    if name == "ForeverCCG" then
        Progress()
        self:UnregisterAllEvents()
    end
end)
