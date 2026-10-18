--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- THE HERO CARD
-- Every player owns one copy of a card that is their own character: its name, model,
-- class keyword and stats. HERO is yours; HEROOPP is your PvP opponent's, built from the
-- ACTION:HEROINFO message they send when the match starts. Card ids cross the network
-- swapped (Network.lua: their HERO is our HEROOPP), so the engine treats both as
-- ordinary cards.
--
-- Every 10 character levels the player chooses (when the Deckbuilder opens, the only time
-- the level is read, so nothing changes during a match): upgrade the card (+1 cost, and
-- +0/+1 and +1/+0 in turn: six upgrades give +6 cost, +3/+3) or gain another copy (max 4).
-- The choices are the account's (TTS_HeroChoices, in milestone order); each character
-- applies the ones its own level has reached, with its own class, race and gear. An alt
-- at level 25 gets the first two choices a level 60 made; one that gets further than any
-- other character so far makes the next ones. TTS_Hero (per character) = { level }.
-- =========================================================================
TTS = TTS or {}
TTS.Hero = TTS.Hero or {}
local H = TTS.Hero

H.MY_ID, H.OPP_ID = "HERO", "HEROOPP"

-- Level 1-9 stats, the keyword (a card field) and the frame colour, by class file name
H.CLASSES = {
    WARRIOR = { p = 2, t = 2, kw = "haste",       color = "R", text = "Quick." },
    ROGUE   = { p = 2, t = 2, kw = "unblockable", color = "B", text = "Invisible." },
    HUNTER  = { p = 2, t = 2, kw = "reach",       color = "G", text = "Anti-Air." },
    PALADIN = { p = 1, t = 3, kw = "bulwark",     color = "W", text = "Bulwark 2.", kwValue = 2 },
    SHAMAN  = { p = 1, t = 3, kw = "support",     color = "G", text = "Support." },
    WARLOCK = { p = 1, t = 3, kw = "lifelink",    color = "B", text = "Drain." },
    DRUID   = { p = 1, t = 3, kw = "vigilance",   color = "G", text = "Vigilant." },
    PRIEST  = { p = 0, t = 4, kw = "shielded",    color = "W", text = "Shielded." },
    MAGE    = { p = 0, t = 4, kw = "hexproof",    color = "U", text = "Warded." },
}

local CLASS_ICON = {
    WARRIOR = "Interface\\Icons\\ClassIcon_Warrior", ROGUE = "Interface\\Icons\\ClassIcon_Rogue",
    HUNTER = "Interface\\Icons\\ClassIcon_Hunter", PALADIN = "Interface\\Icons\\ClassIcon_Paladin",
    SHAMAN = "Interface\\Icons\\ClassIcon_Shaman", WARLOCK = "Interface\\Icons\\ClassIcon_Warlock",
    DRUID = "Interface\\Icons\\ClassIcon_Druid", PRIEST = "Interface\\Icons\\ClassIcon_Priest",
    MAGE = "Interface\\Icons\\ClassIcon_Mage",
}

-- A class trainer stands in for an opponent who can't be drawn: one of their race and
-- gender if there is one (key race id * 10 + UnitSex: 2 male, 3 female), else their race,
-- else their faction's (TRAINER_DISPLAY). displayIds from the client's creature cache; race
-- and gender from each trainer's model file (/fcap trainers in ForeverCCG_DevCapture).
local TRAINER_BY_RACE = {
    WARRIOR = {
        [12] = 3343,   -- Human male: Llane Beshere
        [13] = 1300,   -- Human female: Lyria Du Lac
        [22] = 4556,   -- Orc male: Malosh
        [32] = 3399,   -- Dwarf male: Thran Khorman
        [42] = 6071,   -- Night Elf male: Darnath Bladesinger
        [43] = 1721,   -- Night Elf female: Alyissia
        [52] = 1578,   -- Undead male: Dannal Stern
        [53] = 2658,   -- Undead female: Angela Curthas
        [62] = 2103,   -- Tauren male: Torm Ragetotem
        [63] = 2113,   -- Tauren female: Ker Ragetotem
        [72] = 3055,   -- Gnome male: Bilban Tosslespanner
        [82] = 4242,   -- Troll male: Zel'mak
    },
    ROGUE = {
        [12] = 3351,   -- Human male: Jorik Kerridan
        [13] = 1297,   -- Human female: Keryn Sylvius
        [22] = 1886,   -- Orc male: Rwag
        [32] = 3407,   -- Dwarf male: Solm Hargrin
        [42] = 1725,   -- Night Elf male: Frahun Shadewhisper
        [43] = 2231,   -- Night Elf female: Syurna
        [52] = 1580,   -- Undead male: David Trias
        [53] = 1603,   -- Undead female: Marion Call
        [72] = 3113,   -- Gnome male: Fenthwick
        [82] = 4360,   -- Troll male: Shenthul
    },
    HUNTER = {
        [13] = 137105, -- Human female: Josephine Carson
        [22] = 4560,   -- Orc male: Ogromm
        [32] = 3395,   -- Dwarf male: Thorgas Grimson
        [33] = 3056,   -- Dwarf female: Daera Brightspear
        [42] = 1703,   -- Night Elf male: Dazalar
        [43] = 1723,   -- Night Elf female: Ayanna Everstride
        [62] = 2087,   -- Tauren male: Holt Thunderhorn
        [63] = 2112,   -- Tauren female: Kary Thunderhorn
        [82] = 4239,   -- Troll male: Xor'juul
        [83] = 1882,   -- Troll female: Jen'shan
    },
    PALADIN = {
        [12] = 3346,   -- Human male: Brother Sammuel
        [32] = 3393,   -- Dwarf male: Bromos Grummner
        [52] = 129405, -- Undead male: Aramis Hammerhand
        [53] = 129943, -- Undead female: Shari Stilwell
    },
    SHAMAN = {
        [22] = 4552,   -- Orc male: Haromm
        [23] = 1878,   -- Orc female: Shikrik
        [32] = 126743, -- Dwarf male: Teo Hammerstorm
        [33] = 140654, -- Dwarf female: Ingrid Dunwald
        [62] = 2102,   -- Tauren male: Tigor Skychaser
        [63] = 2123,   -- Tauren female: Siln Skychaser
        [83] = 4231,   -- Troll female: Sian'tsu
    },
    WARLOCK = {
        [12] = 3271,   -- Human male: Maximillian Crowe
        [13] = 3345,   -- Human female: Drusilla La Salle
        [22] = 4567,   -- Orc male: Kartosh
        [23] = 1325,   -- Orc female: Mirket
        [52] = 1581,   -- Undead male: Maximillion
        [72] = 1930,   -- Gnome male: Alamar Grimm
    },
    DRUID = {
        [42] = 1732,   -- Night Elf male: Mardant Strongoak
        [43] = 2191,   -- Night Elf female: Alfina Nightgaze
        [62] = 2106,   -- Tauren male: Turak Runetotem
        [63] = 2121,   -- Tauren female: Sheal Runetotem
    },
    PRIEST = {
        [12] = 3282,   -- Human male: Brother Benjamin
        [13] = 3344,   -- Human female: Priestess Anetta
        [32] = 3401,   -- Dwarf male: Branstock Khalder
        [33] = 3066,   -- Dwarf female: Braenna Flintcrag
        [43] = 1733,   -- Night Elf female: Shanda
        [52] = 1579,   -- Undead male: Dark Cleric Duesten
        [73] = 140941, -- Gnome female: High Priestess Mims
        [82] = 4068,   -- Troll male: Ken'jai
        [83] = 1897,   -- Troll female: Tai'jin
    },
    MAGE = {
        [12] = 5001,   -- Human male: Khelden Bremen
        [13] = 3292,   -- Human female: Jennea Cannon
        [52] = 1600,   -- Undead male: Cain Firesong
        [53] = 1592,   -- Undead female: Isabella
        [72] = 10216,  -- Gnome male: Marryk Nurribit
        [73] = 3108,   -- Gnome female: Bink
        [82] = 10171,  -- Troll male: Un'Thuwa
        [83] = 4524,   -- Troll female: Pephredo
    },
}
-- Horde races: Orc 2, Undead 5, Tauren 6, Troll 8
local HORDE_RACE = { [2] = true, [5] = true, [6] = true, [8] = true }
local TRAINER_DISPLAY = {
    Alliance = {
        WARRIOR = 3343,    -- Llane Beshere
        ROGUE   = 1297,    -- Keryn Sylvius
        HUNTER  = 3558,    -- Grif Wildheart
        PALADIN = 3346,    -- Brother Sammuel
        SHAMAN  = 140654,  -- Ingrid Dunwald
        WARLOCK = 3345,    -- Drusilla La Salle
        DRUID   = 1732,    -- Mardant Strongoak
        PRIEST  = 3344,    -- Priestess Anetta
        MAGE    = 5001,    -- Khelden Bremen
    },
    Horde = {
        WARRIOR = 1880,    -- Frang
        ROGUE   = 1886,    -- Rwag
        HUNTER  = 1882,    -- Jen'shan
        PALADIN = 129405,  -- Aramis Hammerhand
        SHAMAN  = 1878,    -- Shikrik
        WARLOCK = 1884,    -- Nartok
        DRUID   = 3819,    -- Gart Mistrunner
        PRIEST  = 4068,    -- Ken'jai
        MAGE    = 4526,    -- Mai'ah
    },
}

local MAX_TIER = 6
local MAX_COPIES = 4   -- at 4 copies the choice is still shown, with only the upgrade left
H.MAX_COPIES = MAX_COPIES
H.PREVIEW_ID = "HERONEXT"   -- the upgraded card, shown while choosing

-- Cost and stats for a class with a number of upgrades
function H:Stats(classFile, upgrades)
    local base = self.CLASSES[classFile] or self.CLASSES.WARRIOR
    local tier = math.max(0, math.min(MAX_TIER, tonumber(upgrades) or 0))
    return 1 + tier, base.p + math.floor(tier / 2), base.t + math.ceil(tier / 2)
end

-- info = { name, class (file name), upgrades, race (id), sex (UnitSex), items = { itemIds } }
function H:BuildCard(id, info)
    local classFile = self.CLASSES[info.class] and info.class or "WARRIOR"
    local base = self.CLASSES[classFile]
    local cost, p, t = self:Stats(classFile, info.upgrades)
    local card = {
        id = id, name = info.name or "?", cost = "{" .. cost .. "}", cmc = cost, color = base.color,
        type = "Creature", subType = "Hero", unique = true, power = p, toughness = t, creatureType = "Humanoid",
        isHero = true, notCollectible = (id ~= self.MY_ID) or nil, heroInfo = info,
        displayId = 0,   -- drawn by H:SetModel, never SetDisplayInfo
        art = CLASS_ICON[classFile],
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Unique. " .. base.text,
    }
    card[base.kw] = base.kwValue or true
    if id == self.OPP_ID then self.oppDrawnLive = false end   -- a new opponent: not drawn live yet
    TTS.Cards = TTS.Cards or {}
    TTS.Cards[id] = card
    return card
end

-- Milestones this character has reached (one per 10 levels of its saved level)
local function Earned()
    TTS_Hero = TTS_Hero or {}
    return math.min(MAX_TIER, math.floor((TTS_Hero.level or 1) / 10))
end

-- Upgrades and copies from the account's first n choices
local function Tally(n)
    local upgrades, copies = 0, 1
    for i = 1, n do
        if TTS_HeroChoices[i] == "copy" then copies = copies + 1 else upgrades = upgrades + 1 end
    end
    return upgrades, copies
end

-- This character's upgrades and copies
local function State()
    TTS_HeroChoices = TTS_HeroChoices or {}
    local upgrades, copies = Tally(math.min(Earned(), #TTS_HeroChoices))
    return { upgrades = upgrades, copies = copies }
end

-- Copies of the hero card this character owns
function H:Copies()
    return State().copies
end

-- Milestones this character has reached that no character has chosen for yet
function H:PendingChoices()
    TTS_HeroChoices = TTS_HeroChoices or {}
    return math.max(0, Earned() - #TTS_HeroChoices)
end

-- This character, with the upgrades saved in TTS_Hero
function H:MyInfo()
    local classFile, raceId
    if UnitClass then classFile = select(2, UnitClass("player")) end
    if UnitRace then raceId = select(3, UnitRace("player")) end
    local items = {}
    for slot = 1, 19 do
        local itemId = GetInventoryItemID and GetInventoryItemID("player", slot)
        if itemId then table.insert(items, itemId) end
    end
    return {
        name = UnitName and UnitName("player") or "?",
        class = classFile or "WARRIOR",
        upgrades = State().upgrades,
        race = raceId or 1,
        sex = UnitSex and UnitSex("player") or 2,
        items = items,
    }
end

function H:RebuildMine()
    return self:BuildCard(self.MY_ID, self:MyInfo())
end

-- The Deckbuilder opening is the only time the hero's level is updated
function H:Snapshot()
    TTS_Hero = TTS_Hero or {}
    TTS_Hero.level = (UnitLevel and UnitLevel("player")) or TTS_Hero.level or 1
    self:RebuildMine()
end

-- Makes the next milestone's choice for the account: "upgrade" or "copy"
function H:Choose(kind)
    if self:PendingChoices() <= 0 then return end
    if kind ~= "copy" or State().copies >= MAX_COPIES then kind = "upgrade" end
    table.insert(TTS_HeroChoices, kind)
    self:RebuildMine()
    if TTS.MarkCardNew then TTS:MarkCardNew(self.MY_ID) end   -- the Deckbuilder's "new" tag
end

-- What the next choice is about (UI\HeroChoice.lua): the card now, the card upgraded
-- (H.PREVIEW_ID), the copies owned, and the level of the milestone
function H:NextChoice()
    local mine = self:RebuildMine()
    local next = self:MyInfo()
    next.upgrades = next.upgrades + 1
    return {
        current = mine,
        upgraded = self:BuildCard(self.PREVIEW_ID, next),
        copies = State().copies,
        level = (#TTS_HeroChoices + 1) * 10,
    }
end

-- ACTION:HEROINFO:<upgrades>:<class>:<race id>:<sex>:<item,item,...>
function H:Encode()
    local info = self:MyInfo()
    local items = {}
    for _, id in ipairs(info.items) do table.insert(items, tostring(id)) end
    return string.format("%d:%s:%d:%d:%s", info.upgrades, info.class, info.race, info.sex, table.concat(items, ","))
end

function H:SetOpponent(name, upgrades, classFile, race, sex, items)
    local list = {}
    for id in string.gmatch(items or "", "%d+") do table.insert(list, tonumber(id)) end
    self:BuildCard(self.OPP_ID, {
        name = name, class = classFile, upgrades = tonumber(upgrades) or 0,
        race = tonumber(race) or 1, sex = tonumber(sex) or 2, items = list,
    })
end

-- A unit token for a player by name (target, party, raid), so their real model can be shown
local function FindUnit(name)
    if not (name and UnitName) then return nil end
    local want = (name:match("^[^-]+") or name):lower()
    local function Matches(unit)
        local n = UnitName(unit)
        return type(n) == "string" and n:lower() == want
    end
    local units = { "target", "focus", "mouseover" }
    for i = 1, 4 do table.insert(units, "party" .. i) end
    for i = 1, 40 do table.insert(units, "raid" .. i) end
    for _, unit in ipairs(units) do
        if UnitExists and UnitExists(unit) and UnitIsPlayer and UnitIsPlayer(unit) and Matches(unit) then
            return unit
        end
    end
    return nil
end

-- Puts a hero card's character on a model frame. Returns false when it can't be shown
-- (the caller shows the class icon instead).
-- This client can only dress a model made from a real character (no SetCustomRace, and
-- bare race displays load untextured), so an opponent out of sight is drawn as your own
-- character in their gear when you share race and gender, and if not as a class trainer
-- of their race and gender (TRAINER_BY_RACE), their race, or their faction, dressed in
-- their gear (NPC displays take TryOn; bare race displays don't).
function H:SetModel(model, card, onDressed)
    local info = card.heroInfo
    if not (model and info) then return false end
    -- Yours and the upgrade preview show you
    if card.id ~= self.OPP_ID then return pcall(model.SetUnit, model, "player") end

    local unit = FindUnit(info.name)
    self.oppDrawnLive = unit and pcall(model.SetUnit, model, unit) or false
    if self.oppDrawnLive then return true end

    local race = UnitRace and select(3, UnitRace("player"))
    local sex = UnitSex and UnitSex("player")
    if race == info.race and sex == info.sex and model.TryOn and pcall(model.SetUnit, model, "player") then
        if model.Undress then pcall(model.Undress, model) end
        for _, itemId in ipairs(info.items or {}) do pcall(model.TryOn, model, "item:" .. itemId) end
        return true
    end

    local displayId
    local byRace = TRAINER_BY_RACE[info.class]
    local race = tonumber(info.race)
    if byRace and race then
        local otherSex = (info.sex == 3) and 2 or 3
        displayId = byRace[race * 10 + (info.sex or 2)] or byRace[race * 10 + otherSex]
    end
    if not displayId then
        local trainers = TRAINER_DISPLAY[HORDE_RACE[info.race] and "Horde" or "Alliance"]
        displayId = trainers[info.class] or trainers.WARRIOR
    end
    if not (model.SetDisplayInfo and pcall(model.SetDisplayInfo, model, displayId)) then return false end
    self:DressModel(model, info.items, onDressed)   -- the trainer wears the opponent's gear
    return true
end

-- Dresses a display model (an NPC display, e.g. a trainer) in items, stripping its own
-- outfit first. A display model takes items only once it has loaded, so they go on now and
-- again shortly after; the token stops a delayed dressing landing on a frame that has moved
-- on to another card (UI\Board.lua clears it). Also used for cards with dressItems.
-- onDressed (optional) runs after each dressing, e.g. to set the card's camera again (dressing
-- can reset it)
function H:DressModel(model, items, onDressed)
    if not (model and model.TryOn and items and #items > 0) then return end
    -- TryOn needs the item's data on the client: ask for any not loaded yet, so the later
    -- retries find it
    for _, itemId in ipairs(items) do
        if C_Item and C_Item.RequestLoadItemDataByID then
            pcall(C_Item.RequestLoadItemDataByID, itemId)
        elseif GetItemInfo then
            pcall(GetItemInfo, itemId)
        end
    end
    local token = {}
    model.heroDressToken = token
    local function Dress()
        if model.heroDressToken ~= token then return end
        -- Clear everything first: Undress, then each slot on its own (an NPC display's
        -- outfit can cover what TryOn adds to that slot)
        if model.Undress then pcall(model.Undress, model) end
        if model.UndressSlot then
            for slot = 1, 19 do pcall(model.UndressSlot, model, slot) end
        end
        for _, itemId in ipairs(items) do pcall(model.TryOn, model, "item:" .. itemId) end
        if onDressed then pcall(onDressed) end
    end
    Dress()
    if C_Timer then
        C_Timer.After(0.3, Dress)
        C_Timer.After(1, Dress)
        C_Timer.After(2.5, Dress)   -- items the server was still sending
    end
end

-- The moment the opponent can be drawn live (targeted, moused over, focused or grouped),
-- the board is redrawn so their hero card shows their real character
local liveWatch = CreateFrame("Frame")
for _, ev in ipairs({ "PLAYER_TARGET_CHANGED", "UPDATE_MOUSEOVER_UNIT", "PLAYER_FOCUS_CHANGED", "GROUP_ROSTER_UPDATE" }) do
    pcall(liveWatch.RegisterEvent, liveWatch, ev)
end
liveWatch:SetScript("OnEvent", function()
    local E = TTS.Engine
    if not (E and E.inMatch and not E.isSolo) or H.oppDrawnLive then return end
    local info = TTS.Cards[H.OPP_ID] and TTS.Cards[H.OPP_ID].heroInfo
    if not (info and FindUnit(info.name)) then return end
    for _, st in ipairs({ E.localState, E.remoteState }) do
        for _, perm in ipairs(st.field or {}) do
            if perm.id == H.OPP_ID then
                if TTS.RedrawCardModels then TTS.RedrawCardModels() end
                E:RefreshUI(); return
            end
        end
        for _, id in ipairs(st.hand or {}) do
            if id == H.OPP_ID then
                if TTS.RedrawCardModels then TTS.RedrawCardModels() end
                E:RefreshUI(); return
            end
        end
    end
end)

-- Both ids exist from load, so saved decks keep HERO and their messages always resolve
H:BuildCard(H.MY_ID, { name = "?", class = "WARRIOR" })
H:BuildCard(H.OPP_ID, { name = "?", class = "WARRIOR" })

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    TTS_Hero = TTS_Hero or {}
    if not TTS_Hero.level then TTS_Hero.level = (UnitLevel and UnitLevel("player")) or 1 end
    H:RebuildMine()
    self:UnregisterAllEvents()
end)
