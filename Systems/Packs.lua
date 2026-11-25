--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
local L = TTS.L

-- =========================================================================
-- BOOSTER PACKS
-- Packs drop from final dungeon bosses (the Dungeons pack) and raid bosses (that raid's
-- pack). A pack holds PACK_SIZE denizens: the first RANDOM_SLOTS a zone denizen
-- (RANDOM_ZONE_CHANCE) or else a dungeon denizen (a raid pack: a dungeon or raid
-- denizen), the last GUARANTEED_SLOTS
-- always dungeon denizens (a raid pack: that raid's denizens). No card twice in a pack.
-- A raid with fewer denizens than its guaranteed slots fills the rest with dungeon ones.
-- Owned packs: TTS_Packs.owned[packKey] = count (account-wide, like the collection).
-- The opening itself is UI\PackOpener.lua, reached from the main window's Open Packs button.
-- Packs come from kills of boss cards flagged packDrop (AwardFromKill, below; plus the daily
-- dungeon pack, GiveDailyPack), from playing in
-- a prize tournament (AdminGrants.lua TTS:AwardTournamentPack), or from the developer's admin
-- addon (AdminGrants.lua PACK).
-- GRANTS_CARDS: opening a pack adds its cards to the collection (false: only shows them).
-- =========================================================================
local P = {}
TTS.Packs = P

P.PACK_SIZE = 5
P.GUARANTEED_SLOTS = 2
P.RANDOM_SLOTS = P.PACK_SIZE - P.GUARANTEED_SLOTS
P.GRANTS_CARDS = true
-- Chance of each random card being a zone denizen; otherwise it's a dungeon (or raid) one
P.RANDOM_ZONE_CHANCE = 0.75
-- Foil chance of each guaranteed card, in order (the pack's 4th card, then its 5th)
P.FOIL_CHANCE = { 0.05, 0.20 }
-- Foil chance of each random card (the pack's first three)
P.RANDOM_FOIL_CHANCE = 0.02
-- A rare spawn (card.rareSpawn) is this likely to be drawn as any other card of its pool
P.RARE_SPAWN_WEIGHT = 0.25

local TEX = "Interface\\AddOns\\ForeverCCG\\Textures\\Packs\\pack_%s_%s.png"

-- In the order the opener lists them. raid = the card.zone of that raid's denizens.
-- disabled = true: listed as "Currently disabled": still dropped and collected, but not opened (the raid
-- packs, until their raids have cards). Remove it to switch a pack on.
P.TYPES = {
    { key = "dungeon" },
    { key = "barrow", raid = "Barrow Deeps",  disabled = true },
    { key = "onyxia", raid = "Onyxia's Lair", disabled = true },
    { key = "hyjal",  raid = "Hyjal Summit",  disabled = true },
}
P.BY_KEY = {}
local RAID_ZONES = {}
for _, t in ipairs(P.TYPES) do
    t.closed = TEX:format(t.key, "closed")
    t.ripped = TEX:format(t.key, "ripped")
    P.BY_KEY[t.key] = t
    if t.raid then RAID_ZONES[t.raid:lower()] = t.raid end
end

function P:Name(key)
    return L("packs.name." .. key)
end

-- A pack kind that can't be opened yet (P.TYPES disabled); it still drops and is collected
function P:IsDisabled(key)
    local t = self.BY_KEY[key]
    return t ~= nil and t.disabled == true
end

-- =========================================================================
-- CARD POOLS
-- A denizen that can come from a pack: the creatures that drop from kills
-- (BossTracker:BuildMobCardCache's rule) and the Collection Guide lists.
-- =========================================================================
local function IsRaidZone(zone)
    return zone ~= nil and RAID_ZONES[zone:lower()] ~= nil
end

local function IsDungeonZone(zone)
    return TTS.BossTracker and TTS.BossTracker.IsDungeonZone and TTS.BossTracker:IsDungeonZone(zone) or false
end

-- Never the cards earned some other way: solo encounter rewards (isReward), NPC gifts,
-- professions, prizes, the beta card, heroes, Settlements, tokens, death unlocks
local function Packable(card)
    if not (card.isMob and card.zone) then return false end
    if card.isReward or card.isGift or card.isProfession or card.isPrize or card.isBeta or card.campaignPrize
        or card.isHero or card.isToken or card.unlockOnDeath or card.type == "Settlement" then
        return false
    end
    return TTS:GetOwnedCopies(card) ~= nil
end

-- "zone", "dungeon" or "raid" for a packable card
function P:KindOf(card)
    if IsRaidZone(card.zone) then return "raid" end
    if IsDungeonZone(card.zone) then return "dungeon" end
    return "zone"
end

-- The pools, built on first use (every card file has loaded by then):
-- zone, dungeon, instance (dungeon + every raid), raid[raid zone lowercase]
local pools
local function Pools()
    if pools then return pools end
    pools = { zone = {}, dungeon = {}, instance = {}, raid = {} }
    local ids = {}
    for id in pairs(TTS.Cards or {}) do ids[#ids + 1] = id end
    table.sort(ids)   -- a fixed order, so the same random numbers give the same pack
    for _, id in ipairs(ids) do
        local card = TTS.Cards[id]
        if Packable(card) then
            local kind = P:KindOf(card)
            if kind == "raid" then
                local key = card.zone:lower()
                pools.raid[key] = pools.raid[key] or {}
                table.insert(pools.raid[key], card)
            else
                table.insert(pools[kind], card)
            end
            if kind ~= "zone" then table.insert(pools.instance, card) end
        end
    end
    return pools
end

-- A copy of one pool's cards ("zone" or "dungeon"), in a fixed order (the Endless draft,
-- Systems\Endless.lua)
function P:PoolCards(kind)
    local out = {}
    for _, card in ipairs(Pools()[kind] or {}) do out[#out + 1] = card end
    return out
end

-- Whether a card belongs to a raid (its zone is one of P.TYPES' raids)
function P:IsRaidCard(card)
    return card ~= nil and IsRaidZone(card.zone)
end

-- How likely a card is to be drawn against an ordinary one of its pool (rare spawns:
-- card.rareSpawn, in zones and dungeons alike, come up less often)
local function DrawWeight(card)
    return card.rareSpawn and P.RARE_SPAWN_WEIGHT or 1
end

-- A random card of `pool` not already in `taken` (nil when the pool has none left)
local function Draw(pool, taken)
    local left, total = {}, 0
    for _, card in ipairs(pool or {}) do
        if not taken[card.id] then
            left[#left + 1] = card
            total = total + DrawWeight(card)
        end
    end
    if #left == 0 then return nil end
    local roll = math.random() * total
    local card = left[#left]
    for _, c in ipairs(left) do
        roll = roll - DrawWeight(c)
        if roll < 0 then card = c; break end
    end
    taken[card.id] = true
    return card
end

-- The cards in a pack of `key`, in the order they come out:
-- { { card = card, kind = "zone"|"dungeon"|"raid", guaranteed = bool }, ... }
function P:Roll(key)
    local t = self.BY_KEY[key]
    if not t then return nil end
    local pp = Pools()
    local taken, out = {}, {}
    local rarePool = t.raid and pp.instance or pp.dungeon
    for _ = 1, self.RANDOM_SLOTS do
        -- Zone or rarer, then a card of that kind (the other kind if that ran out)
        local first, second = pp.zone, rarePool
        if math.random() >= self.RANDOM_ZONE_CHANCE then first, second = rarePool, pp.zone end
        local card = Draw(first, taken) or Draw(second, taken)
        if card then
            local foil = math.random() < self.RANDOM_FOIL_CHANCE
            out[#out + 1] = { card = card, kind = self:KindOf(card), foil = foil }
        end
    end
    for g = 1, self.GUARANTEED_SLOTS do
        local card = t.raid and Draw(pp.raid[t.raid:lower()], taken) or Draw(pp.dungeon, taken)
        if card then
            local foil = math.random() < (self.FOIL_CHANCE[g] or 0)
            out[#out + 1] = { card = card, kind = self:KindOf(card), guaranteed = true, foil = foil }
        end
    end
    return out
end

-- =========================================================================
-- OWNED PACKS
-- =========================================================================
local function Store()
    if type(TTS_Packs) ~= "table" then TTS_Packs = {} end
    if type(TTS_Packs.owned) ~= "table" then TTS_Packs.owned = {} end
    return TTS_Packs
end

-- The pack count changed: the opener (its onChange) and the main window's button follow
local function Changed()
    if P.onChange then P.onChange() end
    if TTS.MainFrame and TTS.MainFrame.RefreshPacksButton then
        TTS.MainFrame:RefreshPacksButton()
    end
end

function P:Count(key)
    return math.max(0, tonumber(Store().owned[key]) or 0)
end

-- (disabled kinds left out: they can't be opened)
function P:Total()
    local n = 0
    for _, t in ipairs(self.TYPES) do if not t.disabled then n = n + self:Count(t.key) end end
    return n
end

function P:Add(key, n)
    if not self.BY_KEY[key] then return false end
    local owned = Store().owned
    owned[key] = math.max(0, self:Count(key) + (n or 1))
    Changed()
    return true
end

-- Takes one pack of `key` and returns its rolled contents, or nil when there's none to open
function P:Open(key)
    if not self.BY_KEY[key] or self:IsDisabled(key) then return nil end
    if self:Count(key) < 1 then return nil end
    self:Add(key, -1)
    local contents = self:Roll(key)
    -- What the player had before (the opener's "New!"), then the cards go in at once, so
    -- closing the window before turning them all over loses nothing
    for _, entry in ipairs(contents) do
        entry.ownedBefore = TTS:GetOwnedCopies(entry.card) or 0
    end
    if self.GRANTS_CARDS then self:Grant(contents) end
    return contents
end

-- Adds a pack's cards to the collection: each is a sure copy, up to the card's most
-- (TTS:CardMaxCopies), kept where kills keep theirs (TTS_KilledBosses); one more than that
-- gives nothing. A foil pull gives the card's foil too (TTS_FoilCards, as
-- BossTracker:RollFoil keeps it). entry.gained / entry.foilGained say what was new.
function P:Grant(contents)
    TTS_KilledBosses = TTS_KilledBosses or {}
    for _, entry in ipairs(contents or {}) do
        local card = entry.card
        local id = card.id
        local max = TTS.CardMaxCopies and TTS:CardMaxCopies(card) or 4
        local have = tonumber(TTS_KilledBosses[id]) or 0
        if have < max then
            TTS_KilledBosses[id] = have + 1
            entry.gained = true
            TTS:MarkCardNew(id)
        end
        if entry.foil then
            TTS_FoilCards = TTS_FoilCards or {}
            entry.foilGained = not TTS_FoilCards[id]
            TTS_FoilCards[id] = true
        end
    end
    local DB = TTS.DeckBuilderFrame
    if DB and DB:IsShown() and DB.RefreshAll then DB:RefreshAll() end
end

local function Say(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD200[TTSE]|r " .. msg)
end

-- =========================================================================
-- PACKS FROM KILLS
-- A boss card flagged packDrop = "<pack key>" (Cards\Bosses.lua) gives one pack of that
-- kind each time the collection credits its kill (BossTracker:RecordMobKill), as long as
-- the boss would give XP: not grey to you. Its level is read from the dead unit (target,
-- mouseover, a nameplate or a boss frame), or remembered from the last time one of those
-- showed it (levelByNpc). Instances often hide it from add-ons, so failing both, the boss's
-- known level (BOSS_LEVEL) is used. Only a boss missing from all three gives the pack.
-- =========================================================================
local levelByNpc = {}      -- npc id -> level, for the packDrop bosses seen this session
local dropNpcs             -- npc ids of the packDrop bosses (built on first use)

-- npc id -> level of each packDrop boss, for when the game won't show it. Wowhead Forever's
-- levels (2026-11-23); Wowhead gives none for Balnazzar (classic's 62) or the Forever-only
-- bosses, which get the top of their instance's level range (OpenMap's Places.lua).
-- A new packDrop boss needs adding here, or its kills always give a pack.
local BOSS_LEVEL = {
    [11519] = 16,  -- Bazzalan (Ragefire Chasm)
    [639]   = 21,  -- Edwin VanCleef
    [3654]  = 22,  -- Mutanus the Devourer
    [4275]  = 26,  -- Archmage Arugal
    [4829]  = 28,  -- Aku'mai
    [1716]  = 29,  -- Bazil Thredd
    [7800]  = 34,  -- Mekgineer Thermaplugg
    [4421]  = 33,  -- Charlga Razorflank
    [4543]  = 34,  -- Bloodmage Thalnos
    [6487]  = 37,  -- Arcanist Doan
    [3975]  = 40,  -- Herod
    [3977]  = 42,  -- High Inquisitor Whitemane
    [7358]  = 41,  -- Amnennar the Coldbringer
    [2748]  = 47,  -- Archaedas
    [7267]  = 48,  -- Chief Ukorz Sandscalp
    [12201] = 51,  -- Princess Theradras
    [5709]  = 55,  -- Shade of Eranikus
    [9019]  = 59,  -- Emperor Dagran Thaurissan
    [9568]  = 60,  -- Overlord Wyrmthalak
    [10363] = 63,  -- General Drakkisath ("??")
    [11492] = 58,  -- Alzzin the Wildshaper
    [11486] = 61,  -- Prince Tortheldrin
    [11501] = 62,  -- King Gordok
    [1853]  = 61,  -- Darkmaster Gandling
    [10440] = 62,  -- Baron Rivendare
    [10813] = 62,  -- Balnazzar
    [261319] = 20, -- Durgen Dirgehammer (The Hall of Thanes 13-20)
    [250657] = 22, -- Rath'mael (Ruins of Lordaeron 15-22)
    [260326] = 33, -- Relic Guardian (Excavation Site 26-33)
    [246020] = 35, -- Shade of the Archmage (City of Dalaran 28-35)
    [260243] = 42, -- Min'loth the Serpent (The Drowned City 35-42)
    [258968] = 47, -- Overlord Mugg (Krol'dok Stronghold 40-47)
    [255702] = 55, -- Blazeroar (Alcaz Prison 48-55)
    [247234] = 60, -- Varrox Bleakhoof (Blackmaw Hold 55-60)
    [261809] = 60, -- Nanaya (Shaper's Terrace 58-60)
}

local function Secret(v) return issecretvalue and issecretvalue(v) or false end

local function NpcIdOf(guid)
    if type(guid) ~= "string" or Secret(guid) then return nil end
    local kind, _, _, _, _, id = strsplit("-", guid)
    if kind ~= "Creature" and kind ~= "Vehicle" then return nil end
    return tonumber(id)
end

local function DropNpcs()
    if dropNpcs then return dropNpcs end
    dropNpcs = {}
    for _, card in pairs(TTS.Cards or {}) do
        if card.packDrop then
            local id = card.dropsFrom and card.dropsFrom.npcId or card.npcId
            if id then dropNpcs[id] = true end
        end
    end
    return dropNpcs
end

-- The level a unit shows (-1 = "??", a boss far above you), remembered for packDrop bosses
local function NoteUnit(unit)
    local okG, guid = pcall(UnitGUID, unit)
    if not okG or not guid or Secret(guid) then return nil, nil end
    local okL, level = pcall(UnitLevel, unit)
    if not okL or Secret(level) or type(level) ~= "number" or level == 0 then return guid, nil end
    local id = NpcIdOf(guid)
    if id and DropNpcs()[id] then levelByNpc[id] = level end
    return guid, level
end

local LOOK_UNITS = { "target", "focus", "mouseover", "boss1", "boss2", "boss3", "boss4", "boss5" }

-- The killed boss's level: as shown, as last seen, or as known (BOSS_LEVEL); nil if none
local function BossLevel(card, guid)
    if guid and not Secret(guid) then
        local units = {}
        if UnitTokenFromGUID then
            local ok, unit = pcall(UnitTokenFromGUID, guid)
            if ok and unit then units[1] = unit end
        end
        for _, u in ipairs(LOOK_UNITS) do units[#units + 1] = u end
        for _, unit in ipairs(units) do
            local seen, level = NoteUnit(unit)
            if seen == guid and level then return level end
        end
    end
    local id = NpcIdOf(guid) or (card.dropsFrom and card.dropsFrom.npcId) or card.npcId
    if not id then return nil end
    return levelByNpc[id] or BOSS_LEVEL[id]
end

-- The highest level that's grey to a player of `pl` (the classic XP rule)
local function GreyLevel(pl)
    if pl <= 5 then return 0 end
    if pl <= 39 then return pl - math.floor(pl / 10) - 5 end
    if pl <= 59 then return pl - math.floor(pl / 5) - 1 end
    return pl - 9
end

local function PlayerLevel()
    local ok, pl = pcall(UnitLevel, "player")
    return (ok and type(pl) == "number" and not Secret(pl)) and pl or nil
end

local function IsGrey(level)
    if level < 0 then return false end   -- "??": far above you
    local pl = PlayerLevel()
    return pl ~= nil and level <= GreyLevel(pl)
end

-- One pack of `key`, told in chat as coming from `from` (a boss's name, a tournament's name)
function P:Give(key, from)
    if not self:Add(key, 1) then return false end
    Say(L("packs.gained", "|cFFFFD200" .. self:Name(key) .. "|r", from or ""))
    if TTS.Sound and TTS.Sound.PlayUI then TTS.Sound:PlayUI("packOpen") end
    return true
end

local function GivePack(key, card)
    P:Give(key, TTS:CardName(card) or card.name or "")
end

-- =========================================================================
-- WELCOME PACK (1.3): a free Dungeons pack for every account that had collected at least
-- one card before booster packs came in. Decided once, on the first load with packs
-- (TTS_Packs.welcomePack: true = given, false = not due); DataStamp.lua's ADDON_LOADED
-- runs first, so a cleared collection doesn't count. The What's New pages say so
-- (QuickStart.lua, wn13.1.textGift) when this account got one.
-- =========================================================================
local WELCOME_PACK = "dungeon"

local function HadCollection()
    for _, v in pairs(TTS_KilledBosses or {}) do
        if v == true or (tonumber(v) or 0) > 0 then return true end
    end
    return false
end

function P:GotWelcomePack()
    return type(TTS_Packs) == "table" and TTS_Packs.welcomePack == true
end

do
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(self, event, name)
        if name ~= "ForeverCCG" then return end
        self:UnregisterEvent("ADDON_LOADED")
        local store = Store()
        if store.welcomePack ~= nil then return end
        store.welcomePack = HadCollection()
        if not store.welcomePack then return end
        store.owned[WELCOME_PACK] = P:Count(WELCOME_PACK) + 1
        -- (told in chat once the world is up: lines printed at load can be lost)
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self:SetScript("OnEvent", function(s)
            s:UnregisterEvent("PLAYER_ENTERING_WORLD")
            TTS:SafeAfter(5, function()
                Say(L("packs.welcome", "|cFFFFD200" .. P:Name(WELCOME_PACK) .. "|r"))
                Changed()
            end)
        end)
    end)
end

local function NoPack(card)
    Say("|cFF8A8A8A" .. L("packs.tooLow", TTS:CardName(card) or card.name or "") .. "|r")
end

-- =========================================================================
-- DAILY DUNGEON PACK: the first final dungeon boss (packDrop = DAILY_PACK) killed each day
-- gives one more Dungeons pack, grey or not, on top of its usual one. Once a day per account
-- (TTS_Packs.dailyDay), resetting at local midnight as the campfire does (Campfire.lua).
-- =========================================================================
local DAILY_PACK = "dungeon"

local function Today()
    return date("%Y-%m-%d", (GetServerTime and GetServerTime()) or time())
end

-- Seconds until the daily pack can be had again (local midnight) once today's is had; nil
-- while it's still to be had (the minimap tooltip, MinimapButton.lua)
function P:DailyCooldownLeft()
    if Store().dailyDay ~= Today() then return nil end
    local now = (GetServerTime and GetServerTime()) or time()
    local t = date("*t", now)
    t.day, t.hour, t.min, t.sec = t.day + 1, 0, 0, 0
    return math.max(0, time(t) - now)
end

local function GiveDailyPack(key, card)
    if key ~= DAILY_PACK then return end
    local store, today = Store(), Today()
    if store.dailyDay == today then return end
    if not P:Add(key, 1) then return end
    store.dailyDay = today
    Say(L("packs.daily", "|cFFFFD200" .. P:Name(key) .. "|r", TTS:CardName(card) or card.name or ""))
    if TTS.Sound and TTS.Sound.PlayUI then TTS.Sound:PlayUI("packOpen") end
end

function P:AwardFromKill(card, guid)
    local key = card and card.packDrop
    if not (key and self.BY_KEY[key]) then return end
    -- A grey level refuses the pack. Inside instances the client often hides unit levels from
    -- add-ons, so BossLevel falls back to the boss's known level
    local level = BossLevel(card, guid)
    if level and IsGrey(level) then NoPack(card) else GivePack(key, card) end
    GiveDailyPack(key, card)
end

-- Bosses' levels as they show up
local watcher = CreateFrame("Frame")
for _, event in ipairs({ "PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED", "UPDATE_MOUSEOVER_UNIT",
    "NAME_PLATE_UNIT_ADDED", "INSTANCE_ENCOUNTER_ENGAGE_UNIT" }) do
    pcall(watcher.RegisterEvent, watcher, event)
end
watcher:SetScript("OnEvent", function(_, event, arg1)
    if event == "PLAYER_TARGET_CHANGED" then
        NoteUnit("target")
    elseif event == "PLAYER_FOCUS_CHANGED" then
        NoteUnit("focus")
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        NoteUnit("mouseover")
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        if type(arg1) == "string" and not Secret(arg1) then NoteUnit(arg1) end
    elseif event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
        for i = 1, 5 do NoteUnit("boss" .. i) end
    end
end)

-- =========================================================================
-- /tragic pack: the window; list (packs owned); roll <type> (a pack's contents printed to
-- chat, nothing given). Packs are only given by kills and by the developer's admin addon
-- (ForeverCCG_Admin, AdminGrants.lua PACK).
-- =========================================================================

local function KeyFrom(word)
    if not word then return nil end
    word = word:lower()
    if P.BY_KEY[word] then return word end
    for _, t in ipairs(P.TYPES) do
        if t.key:sub(1, #word) == word then return t.key end
    end
    return nil
end

function P:SlashCommand(args)
    local sub, a = (args or ""):lower():match("^(%S*)%s*(%S*)")
    if sub == "" then
        if TTS.PackOpener then TTS.PackOpener:Toggle() end
        return
    end
    if sub == "list" then
        local parts = {}
        for _, t in ipairs(self.TYPES) do parts[#parts + 1] = t.key .. " x" .. self:Count(t.key) end
        Say(L("packs.cmd.owned") .. " " .. table.concat(parts, ", "))
        return
    end
    if sub == "roll" then
        -- Prints a pack's contents to chat, no window
        local key = KeyFrom(a) or "dungeon"
        Say(self:Name(key) .. ":")
        for i, entry in ipairs(self:Roll(key) or {}) do
            Say(("  %d. %s (%s%s)"):format(i, TTS:CardName(entry.card) or entry.card.name,
                L("packs.kind." .. entry.kind), entry.guaranteed and ", " .. L("packs.guaranteed") or "")
                .. (entry.foil and " |cFFFF80FF" .. L("packs.foil") .. "|r" or ""))
        end
    else
        Say(L("packs.cmd.help"))
    end
end
