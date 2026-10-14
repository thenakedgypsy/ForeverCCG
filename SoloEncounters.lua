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
--   chain       zone group shown as a header in the select window
--   life        AI starting life
--   ai          AI profile: dummy | basic | tactical | expert (see AI.lua)
--   reward      card id granted for a win (1 copy per win, up to 4)
--   requires    nil (open) | { cleared = { ids } } (any one cleared) | { killed = "BOSSxx" }
--   bosses      dungeon boss card ids
--   rules       boss rule ids, see TTS.EncounterRules below
--   background  { map = "<WorldMap folder>" } or { file = "<Textures\Backgrounds file>", map = ..., tint = { r, g, b } }
-- =========================================================================
TTS.SoloEncounters = {}
local ENC = TTS.SoloEncounters

local CHAIN_EK_A = "Eastern Kingdoms: Elwynn & Dun Morogh"
local CHAIN_EK_H = "Eastern Kingdoms: Tirisfal"
local CHAIN_KAL  = "Kalimdor"
TTS.SoloZoneChains = { CHAIN_EK_A, CHAIN_EK_H, CHAIN_KAL }

-- id, zone, opponent, world map folder, AI profile, prerequisite encounter ids (any one)
local ZONES = {
    -- Eastern Kingdoms, starting in Elwynn Forest or Dun Morogh
    { "ELW", "Elwynn Forest",        "Hogger's Gang",          "Elwynn",             "basic",    nil,             CHAIN_EK_A },
    { "DUN", "Dun Morogh",           "Frostmane Tribe",        "DunMorogh",          "basic",    nil,             CHAIN_EK_A },
    { "WES", "Westfall",             "Defias Brotherhood",     "Westfall",           "basic",    { "ELW", "DUN" }, CHAIN_EK_A },
    { "LOC", "Loch Modan",           "Tunnel Rat Kobolds",     "LochModan",          "basic",    { "WES" },       CHAIN_EK_A },
    { "RED", "Redridge Mountains",   "Redridge Gnolls",        "Redridge",           "tactical", { "LOC" },       CHAIN_EK_A },
    { "DSK", "Duskwood",             "Nightbane Worgen",       "Duskwood",           "tactical", { "RED" },       CHAIN_EK_A },
    { "WET", "Wetlands",             "Dragonmaw Clan",         "Wetlands",           "tactical", { "DSK" },       CHAIN_EK_A },
    { "ARA", "Arathi Highlands",     "Boulderfist Ogres",      "Arathi",             "tactical", { "WET" },       CHAIN_EK_A },
    { "STV", "Stranglethorn Vale",   "Kurzen's Mercenaries",   "Stranglethorn",      "expert",   { "ARA" },       CHAIN_EK_A },
    { "SWA", "Swamp of Sorrows",     "The Lost Ones",          "SwampOfSorrows",     "expert",   { "STV" },       CHAIN_EK_A },
    { "BLA", "Blasted Lands",        "Shadowsworn Cult",       "BlastedLands",       "expert",   { "SWA" },       CHAIN_EK_A },
    { "BUR", "Burning Steppes",      "Firegut Ogres",          "BurningSteppes",     "expert",   { "BLA" },       CHAIN_EK_A },
    -- Eastern Kingdoms, starting in Tirisfal Glades
    { "TIR", "Tirisfal Glades",      "Scarlet Zealots",        "Tirisfal",           "basic",    nil,             CHAIN_EK_H },
    { "SIL", "Silverpine Forest",    "Moonrage Pack",          "Silverpine",         "basic",    { "TIR" },       CHAIN_EK_H },
    { "HIL", "Hillsbrad Foothills",  "Rot Hide Gnolls",        "Hilsbrad",           "tactical", { "SIL" },       CHAIN_EK_H },
    { "ALT", "Alterac Mountains",    "Crushridge Ogres",       "Alterac",            "tactical", { "HIL" },       CHAIN_EK_H },
    { "BAD", "Badlands",             "Shadowforge Dwarves",    "Badlands",           "expert",   { "ALT" },       CHAIN_EK_H },
    { "HIN", "The Hinterlands",      "Vilebranch Tribe",       "Hinterlands",        "expert",   { "BAD" },       CHAIN_EK_H },
    { "SEA", "Searing Gorge",        "Dark Iron Taskmasters",  "SearingGorge",       "expert",   { "HIN" },       CHAIN_EK_H },
    { "WPL", "Western Plaguelands",  "Scourge of Andorhal",    "WesternPlaguelands", "expert",   { "SEA" },       CHAIN_EK_H },
    { "EPL", "Eastern Plaguelands",  "Plaguewood Scourge",     "EasternPlaguelands", "expert",   { "WPL" },       CHAIN_EK_H },
    -- Kalimdor, starting in Durotar, Mulgore or Teldrassil
    { "DUR", "Durotar",              "Burning Blade Cult",     "Durotar",            "basic",    nil,             CHAIN_KAL },
    { "MUL", "Mulgore",              "Bristleback Quilboar",   "Mulgore",            "basic",    nil,             CHAIN_KAL },
    { "TEL", "Teldrassil",           "Gnarlpine Tribe",        "Teldrassil",         "basic",    nil,             CHAIN_KAL },
    { "DAR", "Darkshore",            "Stormscale Naga",        "Darkshore",          "basic",    { "DUR", "MUL", "TEL" }, CHAIN_KAL },
    { "BRN", "The Barrens",          "Kolkar Centaur",         "Barrens",            "basic",    { "DAR" },       CHAIN_KAL },
    { "STO", "Stonetalon Mountains", "Windshear Diggers",      "StonetalonMountains", "tactical", { "BRN" },      CHAIN_KAL },
    { "ASH", "Ashenvale",            "Warsong Clan",           "Ashenvale",          "tactical", { "STO" },       CHAIN_KAL },
    { "THO", "Thousand Needles",     "Galak Centaur",          "ThousandNeedles",    "tactical", { "ASH" },       CHAIN_KAL },
    { "DES", "Desolace",             "Burning Blade Coven",    "Desolace",           "tactical", { "THO" },       CHAIN_KAL },
    { "DUS", "Dustwallow Marsh",     "Mirefin Tribe",          "Dustwallow",         "expert",   { "DES" },       CHAIN_KAL },
    { "FER", "Feralas",              "Hatecrest Naga",         "Feralas",            "expert",   { "DUS" },       CHAIN_KAL },
    { "TAN", "Tanaris",              "Dunemaul Ogres",         "Tanaris",            "expert",   { "FER" },       CHAIN_KAL },
    { "AZS", "Azshara",              "Spitelash Naga",         "Aszhara",            "expert",   { "TAN" },       CHAIN_KAL },
    { "FEL", "Felwood",              "Jadefire Satyrs",        "Felwood",            "expert",   { "AZS" },       CHAIN_KAL },
    { "UNG", "Un'Goro Crater",       "Ravasaur Pack",          "UngoroCrater",       "expert",   { "FEL" },       CHAIN_KAL },
    { "SLI", "Silithus",             "Twilight's Hammer",      "Silithus",           "expert",   { "UNG" },       CHAIN_KAL },
    { "WIN", "Winterspring",         "Ice Thistle Yetis",      "Winterspring",       "expert",   { "SLI" },       CHAIN_KAL },
}

for i, z in ipairs(ZONES) do
    ENC[z[1]] = {
        id = z[1], kind = "zone", order = i,
        name = z[2], zone = z[2], opponent = z[3], chain = z[7],
        life = 20, ai = z[5],
        reward = z[1] .. "11",
        requires = z[6] and { cleared = z[6] } or nil,
        background = { map = z[4] },
    }
end

-- id, dungeon (zone tag), boss cards, AI life, rules, reward, AI profile, custom art file, fallback map
local DUNGEONS = {
    { "RFC", "Ragefire Chasm",    { "BOSS01" },                               20, { "HEAD_START" },                     "RFC08", "tactical", "RagefireChasm",    "Durotar" },
    { "DMS", "The Deadmines",     { "BOSS02" },                               25, { "REINFORCEMENTS" },                 "DMS12", "tactical", "Deadmines",        "Westfall" },
    { "WCV", "Wailing Caverns",   { "BOSS03" },                               25, { "AWAKENING" },                      "WCV13", "tactical", "WailingCaverns",   "Barrens" },
    { "SFK", "Shadowfang Keep",   { "BOSS04" },                               25, { "OPENING_BOSS" },                   "SFK13", "tactical", "ShadowfangKeep",   "Silverpine" },
    { "BFD", "Blackfathom Deeps", { "BOSS05" },                               25, { "REINFORCEMENTS" },                 "BFD12", "tactical", "BlackfathomDeeps", "Ashenvale" },
    { "STK", "The Stockade",      { "BOSS06" },                               25, { "REINFORCEMENTS" },                 "STK08", "tactical", "Stockade",         "Elwynn" },
    { "GNO", "Gnomeregan",        { "BOSS07" },                               30, { "HEAD_START" },                     "GNO09", "tactical", "Gnomeregan",       "DunMorogh" },
    { "RFK", "Razorfen Kraul",    { "BOSS08" },                               25, { "OPENING_BOSS" },                   "RFK13", "tactical", "RazorfenKraul",    "Barrens" },
    { "SMO", "Scarlet Monastery", { "BOSS09", "BOSS10", "BOSS11", "BOSS12" }, 30, { "NEXT_BOSS" },                      "SMO14", "expert",   "ScarletMonastery", "Tirisfal" },
    { "RFD", "Razorfen Downs",    { "BOSS13" },                               30, { "ENRAGE" },                         "RFD08", "expert",   "RazorfenDowns",    "Barrens" },
    { "ULD", "Uldaman",           { "BOSS14" },                               30, { "AWAKENING" },                      "ULD13", "expert",   "Uldaman",          "Badlands" },
    { "ZFK", "Zul'Farrak",        { "BOSS15" },                               30, { "REINFORCEMENTS" },                 "ZFK12", "expert",   "ZulFarrak",        "Tanaris" },
    { "MAR", "Maraudon",          { "BOSS16" },                               30, { "HEAD_START" },                     "MAR13", "expert",   "Maraudon",         "Desolace" },
    { "SUN", "Sunken Temple",     { "BOSS17" },                               30, { "ENRAGE" },                         "SUN13", "expert",   "SunkenTemple",     "SwampOfSorrows" },
    { "BRD", "Blackrock Depths",  { "BOSS18" },                               35, { "OPENING_BOSS", "REINFORCEMENTS" }, "BRD23", "expert",   "BlackrockDepths",  "SearingGorge" },
    { "BRS", "Blackrock Spire",   { "BOSS19", "BOSS20" },                     35, { "NEXT_BOSS" },                      "BRS20", "expert",   "BlackrockSpire",   "BurningSteppes" },
    { "DMA", "Dire Maul",         { "BOSS21", "BOSS22", "BOSS23" },           35, { "NEXT_BOSS" },                      "DMA19", "expert",   "DireMaul",         "Feralas" },
    { "SCH", "Scholomance",       { "BOSS24" },                               35, { "REINFORCEMENTS", "ENRAGE" },       "SCH18", "expert",   "Scholomance",      "WesternPlaguelands" },
    { "STR", "Stratholme",        { "BOSS25", "BOSS26" },                     40, { "NEXT_BOSS", "ENRAGE" },            "STR21", "expert",   "Stratholme",       "EasternPlaguelands" },
}

for i, d in ipairs(DUNGEONS) do
    local firstBoss = TTS.Cards[d[3][1]]
    ENC[d[1]] = {
        id = d[1], kind = "dungeon", order = i,
        name = d[2], zone = d[2], opponent = firstBoss and firstBoss.name or d[2],
        life = d[4], ai = d[7], rules = d[5], bosses = d[3],
        reward = d[6],
        -- For multi-boss dungeons the last boss in the list must have been killed in the world
        requires = { killed = d[3][#d[3]] },
        background = { file = d[8], map = d[9], tint = { 0.6, 0.55, 0.5 } },
    }
end

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
-- to 22 creatures with the dungeon's creatures; then a few class spells the AI can use;
-- prayers fill the rest, split by the colour share of the creatures' pips.
-- =========================================================================
local DECK_SIZE = 40
local DUNGEON_CREATURES = 22
local SPELLS_BY_PROFILE = { dummy = 0, basic = 2, tactical = 3, expert = 4 }
local PRAYER_IDS = { W = "W01", U = "U01", B = "B01", R = "R01", G = "G01" }

-- Spell ops the AI knows how to use well
local AI_SPELL_OPS = { damage = true, dot = true, destroy = true, freeze = true, tap = true, heal = true,
    hot = true, buff = true, shield = true, draw = true, raise = true, tuck = true }

local function IsAIFriendlySpell(card)
    if card.type ~= "Sorcery" or not card.effect or not card.effect.ops then return false end
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
-- TTS_SoloProgress = { cleared = { [encounterId] = wins }, rewards = { [cardId] = copies } }
-- =========================================================================
local MAX_REWARD_COPIES = 4

local function Progress()
    TTS_SoloProgress = TTS_SoloProgress or {}
    TTS_SoloProgress.cleared = TTS_SoloProgress.cleared or {}
    TTS_SoloProgress.rewards = TTS_SoloProgress.rewards or {}
    return TTS_SoloProgress
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
    if card.isReward then
        if TTS_DevModeActive then return MAX_REWARD_COPIES end
        return math.min(MAX_REWARD_COPIES, Progress().rewards[card.id] or 0)
    end
    if card.isBoss then
        return KillCount(card.id)
    end
    return nil
end

-- Returns unlocked, reason (the reason says what is still needed)
function TTS:IsEncounterUnlocked(enc)
    local req = enc and enc.requires
    if not req then return true end
    if req.cleared then
        local names = {}
        for _, id in ipairs(req.cleared) do
            if self:GetEncounterWins(id) > 0 then return true end
            table.insert(names, ENC[id] and ENC[id].name or id)
        end
        return false, "Clear " .. table.concat(names, " or ") .. " first."
    end
    if req.killed then
        if TTS_DevModeActive or KillCount(req.killed) > 0 then return true end
        local boss = TTS.Cards[req.killed]
        return false, string.format("Defeat %s in %s first.", boss and boss.name or req.killed, enc.name)
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
    if before < MAX_REWARD_COPIES then p.rewards[enc.reward] = before + 1 end
    if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() and TTS.DeckBuilderFrame.RefreshAll then
        TTS.DeckBuilderFrame:RefreshAll()
    end
    return enc.reward, p.rewards[enc.reward], before >= MAX_REWARD_COPIES
end

-- =========================================================================
-- BOSS RULES
-- Each rule may implement onStart, onAITurnStart, onPlayerTurnStart, onCreatureDeath and
-- statBonus (perm, isRemote -> p, t). Hooks receive (engine, encounter, ...).
-- =========================================================================
local function BossName(id)
    local c = TTS.Cards[id]
    return c and c.name or id
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

local function BringInBoss(self, bossId, verb)
    PullFromLibraryOrHand(self, bossId)
    self:Log(string.format("|cFFFF4444%s %s!|r", BossName(bossId), verb), "SYSTEM")
    self:PutCreatureOntoBattlefield(bossId, true, { ready = true })
end

TTS.EncounterRules = {
    OPENING_BOSS = {
        name = "Opening Boss",
        text = "The boss starts on the battlefield, ready to fight.",
        onStart = function(self, enc)
            for _, b in ipairs(enc.bosses or {}) do BringInBoss(self, b, "awaits you") end
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
                table.insert(self.remoteState.field, { id = id, tapped = false, uid = self:NewUid() })
            end
            self:Log(string.format("%s starts with 2 extra prayers.", self.opponent), "SYSTEM")
        end,
    },
    REINFORCEMENTS = {
        name = "Reinforcements",
        text = "At the start of every 3rd turn of the opponent, a random creature from its deck joins the battle.",
        onAITurnStart = function(self, enc)
            if (self.remoteTurns or 0) % 3 ~= 0 then return end
            local options = {}
            for i, id in ipairs(self.remoteState.deck) do
                local c = TTS.Cards[id]
                if c and c.type == "Creature" then table.insert(options, i) end
            end
            if #options == 0 then return end
            local id = table.remove(self.remoteState.deck, options[math.random(#options)])
            self:Log(string.format("|cFFFF4444Reinforcements:|r %s joins %s.", BossName(id), self.opponent), "SYSTEM")
            self:PutCreatureOntoBattlefield(id, true)
        end,
    },
    ENRAGE = {
        name = "Enrage",
        text = "From turn 10, the opponent's creatures get +2/+0.",
        onPlayerTurnStart = function(self, enc)
            if self.turn == 10 then
                self:Log(string.format("|cFFFF4444%s is enraged!|r Its creatures get +2/+0.", self.opponent), "SYSTEM")
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
                    BringInBoss(self, b, "awakens")
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
                self:WinMatch(string.format("Victory! %s has been cleared.", enc.name))
                return
            end
            self.opponent = BossName(nextId)
            BringInBoss(self, nextId, "enters the fight")
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

-- Rule names and text for display, one line each
function TTS:GetEncounterRuleLines(enc)
    local lines = {}
    for _, ruleId in ipairs(enc and enc.rules or {}) do
        local rule = TTS.EncounterRules[ruleId]
        if rule then table.insert(lines, { name = rule.name, text = rule.text }) end
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
