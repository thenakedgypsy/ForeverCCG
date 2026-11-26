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
-- Every 10 character levels (when the Deckbuilder opens, the only time the level is read,
-- so nothing changes during a match) the player takes one of three class talents, one per
-- spec (Systems\HeroTalents.lua): stats, keywords, an Arrival or attack effect, and at 60 a
-- signature ability. A hero card has one copy. The choices are the account's, per class
-- (TTS_HeroChoices[class], in milestone order): each character of that class applies the
-- ones its own level has reached, with its own race and gear; one that gets further than
-- any other of its class makes the next ones. They can be reset (H:Respec) outside a match.
-- TTS_Hero (per character) = { level }.
-- =========================================================================
TTS = TTS or {}
TTS.Hero = TTS.Hero or {}
local H = TTS.Hero

H.MY_ID, H.OPP_ID = "HERO", "HEROOPP"

-- Level 1-9 stats, the keyword (a card field) and the frame colour, by class file name
H.CLASSES = {
    WARRIOR = { p = 2, t = 2, kw = "haste",       color = "R", text = "Charge." },
    ROGUE   = { p = 2, t = 2, kw = "unblockable", color = "B", text = "Stealth." },
    HUNTER  = { p = 2, t = 2, kw = "reach",       color = "G", text = "Ranged." },
    PALADIN = { p = 1, t = 3, kw = "bulwark",     color = "W", text = "Shield Wall 2.", kwValue = 2 },
    SHAMAN  = { p = 1, t = 3, kw = "support",     color = "G", text = "Support." },
    WARLOCK = { p = 1, t = 3, kw = "lifelink",    color = "B", text = "Leech." },
    DRUID   = { p = 1, t = 3, kw = "vigilance",   color = "G", text = "Vigilant." },
    PRIEST  = { p = 0, t = 4, kw = "shielded",    color = "W", text = "Absorb." },
    MAGE    = { p = 0, t = 4, kw = "hexproof",    color = "U", text = "Anti-Magic." },
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
local MAX_COPIES = 1   -- one hero card, however far it has come
H.MAX_COPIES = MAX_COPIES
H.MAX_TIER = MAX_TIER
H.PREVIEW_ID = "HERONEXT"   -- the card with one option taken, shown while choosing: HERONEXT1..3
local BASE_COST = 1
-- TTS_HeroChoices = { version = CHOICES_VERSION, [class file] = { talent ids, in milestone order } }.
-- Saved choices in any older shape (the upgrade/copy list before talents) are cleared once:
-- every player chooses again with this update.
local CHOICES_VERSION = 2

-- The account's choices, in this shape (cleared if they're from before talents)
local function AllChoices()
    if type(TTS_HeroChoices) ~= "table" or TTS_HeroChoices.version ~= CHOICES_VERSION then
        local hadOld = type(TTS_HeroChoices) == "table" and next(TTS_HeroChoices) ~= nil
        TTS_HeroChoices = { version = CHOICES_VERSION }
        if hadOld then H.wasReset = true end   -- (told once at login)
    end
    return TTS_HeroChoices
end

local function MyClass()
    local classFile = UnitClass and select(2, UnitClass("player"))
    return H.CLASSES[classFile] and classFile or "WARRIOR"
end

-- This class's talent ids so far (made if missing)
local function ClassChoices(classFile)
    local all = AllChoices()
    if type(all[classFile]) ~= "table" then all[classFile] = {} end
    return all[classFile]
end

-- Milestones this character has reached (one per 10 levels of its saved level)
local function Earned()
    TTS_Hero = TTS_Hero or {}
    return math.min(MAX_TIER, math.floor((TTS_Hero.level or 1) / 10))
end

-- The talents a list of ids gives a class, in tier order, keeping only real ones for it (one
-- per tier). Used for our own card and an opponent's.
function H:TalentList(classFile, ids)
    local list, seen = {}, {}
    for _, id in ipairs(ids or {}) do
        local e = self.TALENT_BY_ID and self.TALENT_BY_ID[id]
        if e and e.class == classFile and not seen[e.tier] then
            seen[e.tier] = true
            list[#list + 1] = e
        end
    end
    table.sort(list, function(a, b) return a.tier < b.tier end)
    local out = {}
    for _, e in ipairs(list) do out[#out + 1] = e.talent end
    return out
end

-- Copies of the hero card this character owns
function H:Copies()
    return MAX_COPIES
end

-- This character's class file name (WARRIOR if unknown)
function H:MyClass()
    return MyClass()
end

-- Milestones this character's level has reached (0 to 6)
function H:Earned()
    return Earned()
end

-- Milestones this character has reached that its class hasn't chosen for yet
function H:PendingChoices()
    return math.max(0, Earned() - #ClassChoices(MyClass()))
end

-- This character's talent ids: as many of its class's picks as its level has reached
local function MyTalents()
    local picks, out = ClassChoices(MyClass()), {}
    for i = 1, math.min(Earned(), #picks) do out[i] = picks[i] end
    return out
end

-- This character
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
        talents = MyTalents(),
        race = raceId or 1,
        sex = UnitSex and UnitSex("player") or 2,
        items = items,
    }
end

-- Adds an effect table's ops onto the card's ({ target, ops }); a target is kept from
-- whichever has one (the talent data keeps targeted Arrivals to one tier per class)
local function MergeEffect(into, eff)
    if not eff then return into end
    into = into or { ops = {} }
    if eff.target then into.target = eff.target end
    for _, op in ipairs(eff.ops or {}) do into.ops[#into.ops + 1] = op end
    return into
end

-- info = { name, class (file name), talents = { ids }, race (id), sex (UnitSex), items = { itemIds } }
function H:BuildCard(id, info)
    local classFile = self.CLASSES[info.class] and info.class or "WARRIOR"
    local base = self.CLASSES[classFile]
    local talents = self:TalentList(classFile, info.talents)
    local cost, p, t = BASE_COST, base.p, base.t
    local kws = { [base.kw] = base.kwValue or true }
    local etb, atk, ab
    for _, tal in ipairs(talents) do
        cost, p, t = cost + (tal.c or 0), p + (tal.p or 0), t + (tal.t or 0)
        for kw, v in pairs(tal.kw or {}) do
            local had = kws[kw]
            if type(v) == "number" and type(had) == "number" then v = math.max(v, had) end
            kws[kw] = v
        end
        etb = MergeEffect(etb, tal.etb)
        atk = MergeEffect(atk, tal.atk)
        if tal.ab then ab = tal.ab end
    end
    local card = {
        id = id, name = info.name or "?", cost = "{" .. cost .. "}", cmc = cost, color = base.color,
        type = "Creature", subType = "Hero", unique = true, power = p, toughness = t, creatureType = "Humanoid",
        isHero = true, notCollectible = (id ~= self.MY_ID) or nil, heroInfo = info,
        displayId = 0,   -- drawn by H:SetModel, never SetDisplayInfo
        art = CLASS_ICON[classFile],
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        -- Its rules text is put together in the chosen language (H:CardText, via TTS:CardText)
        heroKeyword = base.kw, heroKeywords = kws, heroTalents = talents,
        etb = etb, onAttack = atk, ability = ab,
    }
    for kw, v in pairs(kws) do card[kw] = v end
    card.text = self:CardText(card)
    if id == self.OPP_ID then self.oppDrawnLive = false end   -- a new opponent: not drawn live yet
    TTS.Cards = TTS.Cards or {}
    TTS.Cards[id] = card
    return card
end

-- Keywords in the order the rules text lists them (the class's own first)
local KEYWORD_ORDER = { "flying", "reach", "haste", "vigilance", "firstStrike", "deathtouch", "lifelink",
    "trample", "hexproof", "shielded", "unblockable", "bulwark", "enrage", "support" }

-- "Unique. Charge, Ambush, Shield Wall 2. Arrival: ...", in the chosen language
function H:CardText(card)
    local L, Loc = TTS.L, TTS.Locale
    local TT = TTS.Tooltip
    local function KeywordName(kw)
        local def = TT and TT.KEYWORDS and TT.KEYWORDS[kw]
        local name = Loc and Loc:Data("keyword." .. kw .. ".name", def and def.name or kw) or (def and def.name or kw)
        local v = card.heroKeywords and card.heroKeywords[kw]
        if type(v) == "number" and L then name = L("hero.keywordValue", name, v) end
        return name
    end
    local names = {}
    if card.heroKeyword then names[1] = KeywordName(card.heroKeyword) end
    for _, kw in ipairs(KEYWORD_ORDER) do
        if kw ~= card.heroKeyword and card.heroKeywords and card.heroKeywords[kw] then names[#names + 1] = KeywordName(kw) end
    end
    local unique = Loc and Loc:Data("keyword.unique.name", "Unique") or "Unique"
    local text = (L and L("hero.text", unique, table.concat(names, ", "))) or (unique .. ". " .. table.concat(names, ", ") .. ".")
    -- Talents' lines with the same lead-in ("Arrival:", "Aggro:") are joined under one, in the
    -- order they first come; an ability ("{T}, {2}: ...") stays a line of its own
    local groups, order = {}, {}
    for _, tal in ipairs(card.heroTalents or {}) do
        local line = self:TalentText(tal)
        if line then
            local head, body = line:match("^([^{:][^:]-): (.*)$")
            local key = head or line
            if not groups[key] then
                groups[key] = { head = head, bodies = {} }
                order[#order + 1] = key
            end
            table.insert(groups[key].bodies, body or line)
        end
    end
    for _, key in ipairs(order) do
        local g = groups[key]
        local joined = table.concat(g.bodies, " ")
        text = text .. " " .. (g.head and (g.head .. ": " .. joined) or joined)
    end
    return text
end

-- Rebuilds our own card (talents, gear, level). TTS.Engine's GetAbility and so on read it fresh.
function H:RebuildMine()
    return self:BuildCard(self.MY_ID, self:MyInfo())
end

-- The Deckbuilder opening is the only time the hero's level is updated
function H:Snapshot()
    TTS_Hero = TTS_Hero or {}
    TTS_Hero.level = (UnitLevel and UnitLevel("player")) or TTS_Hero.level or 1
    self:RebuildMine()
end

-- The three talents the next milestone offers this class (nil when none is waiting)
function H:NextOptions()
    if self:PendingChoices() <= 0 then return nil end
    local tiers = self.TALENTS and self.TALENTS[MyClass()]
    return tiers and tiers[#ClassChoices(MyClass()) + 1] or nil
end

-- Takes a talent at the next milestone (talentId: one of H:NextOptions)
function H:Choose(talentId)
    local options = self:NextOptions()
    if not options then return end
    for _, tal in ipairs(options) do
        if tal.id == talentId then
            table.insert(ClassChoices(MyClass()), talentId)
            self:RebuildMine()
            if TTS.MarkCardNew then TTS:MarkCardNew(self.MY_ID) end   -- the Deckbuilder's "new" tag
            return true
        end
    end
end

-- Forgets this class's talents, so every milestone reached can be chosen again (the
-- Deckbuilder's Reset Talents button; never during a match, when the card is in play)
function H:Respec()
    if TTS.Engine and TTS.Engine.inMatch then return false end
    AllChoices()[MyClass()] = {}
    self:RebuildMine()
    return true
end

-- This class's chosen talents, for showing the path so far (UI\HeroChoice.lua)
function H:ChosenTalents()
    return self:TalentList(MyClass(), ClassChoices(MyClass()))
end

-- What the next choice is about (UI\HeroChoice.lua): the card now, each option with the card
-- it makes (H.PREVIEW_ID .. n), and the milestone's level and tier
function H:NextChoice()
    local mine = self:RebuildMine()
    local options = self:NextOptions() or {}
    local out = { current = mine, options = {}, tier = #ClassChoices(MyClass()) + 1 }
    out.level = out.tier * 10
    for n, tal in ipairs(options) do
        local info = self:MyInfo()
        local ids = {}
        for _, id in ipairs(ClassChoices(MyClass())) do ids[#ids + 1] = id end
        ids[#ids + 1] = tal.id
        info.talents = ids
        out.options[n] = { talent = tal, card = self:BuildCard(self.PREVIEW_ID .. n, info) }
    end
    return out
end

-- ACTION:HEROINFO:<talent ids, dot-separated, or 0>:<class>:<race id>:<sex>:<item,item,...>
-- (before talents the first field was a number of upgrades: an older client reads ours as 0,
-- and we read a number as no talents)
function H:Encode()
    local info = self:MyInfo()
    local items = {}
    for _, id in ipairs(info.items) do table.insert(items, tostring(id)) end
    local talents = #info.talents > 0 and table.concat(info.talents, ".") or "0"
    return string.format("%s:%s:%d:%d:%s", talents, info.class, info.race, info.sex, table.concat(items, ","))
end

function H:SetOpponent(name, talents, classFile, race, sex, items)
    local list = {}
    for id in string.gmatch(items or "", "%d+") do table.insert(list, tonumber(id)) end
    local ids = {}
    for id in string.gmatch(tostring(talents or ""), "[%w_]+") do
        if self.TALENT_BY_ID and self.TALENT_BY_ID[id] then ids[#ids + 1] = id end
    end
    self:BuildCard(self.OPP_ID, {
        name = name, class = classFile, talents = ids,
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
-- (the caller shows the class icon instead). An opponent is shown live when possible;
-- otherwise a class trainer is used, dressed in the opponent's gear.
function H:SetModel(model, card, onDressed)
    local info = card.heroInfo
    if not (model and info) then return false end
    -- Yours and the upgrade preview show you
    if card.id ~= self.OPP_ID then return pcall(model.SetUnit, model, "player") end

    local unit = FindUnit(info.name)
    self.oppDrawnLive = unit and pcall(model.SetUnit, model, unit) or false
    if self.oppDrawnLive then return true end

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
-- can reset it). keepOutfit (optional): the items go on over the display's own outfit instead
-- (a denizen's Gear, UI\Board.lua)
function H:DressModel(model, items, onDressed, keepOutfit)
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
        if model.Undress and not keepOutfit then pcall(model.Undress, model) end
        if model.UndressSlot and not keepOutfit then
            for slot = 1, 19 do pcall(model.UndressSlot, model, slot) end
        end
        for _, itemId in ipairs(items) do pcall(model.TryOn, model, "item:" .. itemId) end
        if onDressed then pcall(onDressed) end
    end
    Dress()
    C_Timer.After(0.3, Dress)
    C_Timer.After(1, Dress)
    C_Timer.After(2.5, Dress)   -- items the server was still sending
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
    -- Choices saved before talents were cleared (AllChoices): say so, once
    if H.wasReset then
        H.wasReset = nil
        DEFAULT_CHAT_FRAME:AddMessage(TTS.L("hero.resetNotice"))
    end
    self:UnregisterAllEvents()
end)
