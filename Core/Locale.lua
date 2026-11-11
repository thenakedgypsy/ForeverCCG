--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

-- =========================================================================
-- LOCALISATION
-- English lives in Languages\enUS.lua (UI, logs, rules, keywords) and in the
-- card files themselves (card names and rules text). Every other language is
-- in the load-on-demand ForeverCCG_Languages addon, one file per language;
-- only the chosen file builds its table, so the others cost no memory.
--
-- Lookups fall back: chosen language -> English -> the key itself, so a
-- missing translation is never blank.
--
-- The language is chosen from TTS_Options.language, which only exists once
-- ADDON_LOADED fires -- after every file has already built its frames in
-- English. Texts set while files load therefore go through L:Bind so they
-- can be set again once the language pack has loaded. Changing language
-- needs a /reload.
-- =========================================================================
TTS.Locale = TTS.Locale or {}
local Loc = TTS.Locale

Loc.enUS = Loc.enUS or {}  -- filled by Languages\enUS.lua
Loc.strings = nil          -- the chosen language's table (nil = English)
Loc.code = "enUS"
Loc.wanted = nil           -- language the pack should build (read by its files)

local PACK_ADDON = "ForeverCCG_Languages"

-- Languages a pack may provide, with their names written in that language.
-- The pack's toc lists which of these it actually holds (## X-Languages).
Loc.LANGUAGES = {
    { code = "enUS", name = "English" },
    { code = "deDE", name = "Deutsch" },
    { code = "frFR", name = "Français" },
    { code = "esES", name = "Español (EU)" },
    { code = "esMX", name = "Español (AL)" },
    { code = "ptBR", name = "Português" },
    { code = "itIT", name = "Italiano" },
    { code = "ruRU", name = "Русский" },
    { code = "koKR", name = "한국어" },
    { code = "zhCN", name = "简体中文" },
    { code = "zhTW", name = "繁體中文" },
}

-- =========================================================================
-- PSEUDO-LOCALE (developer aid: /tragic lang pseudo)
-- Accents every letter and brackets every string, so text that never went
-- through L() stands out in plain English, and longer text shows overflow.
-- Format specifiers, {X} symbols and |c / |H / |T escapes are left alone.
-- =========================================================================
local ACCENTS = {
    a = "á", e = "é", i = "í", o = "ó", u = "ú", y = "ý", n = "ñ", c = "ç",
    A = "Á", E = "É", I = "Í", O = "Ó", U = "Ú", Y = "Ý", N = "Ñ", C = "Ç",
}

local function Pseudo(s)
    if type(s) ~= "string" or s == "" then return s end
    local out, i, n = {}, 1, #s
    while i <= n do
        local c = s:sub(i, i)
        local skip
        if c == "%" then
            skip = s:match("^%%[%d%$%.%-]*%a", i) or s:match("^%%%%", i)
        elseif c == "{" then
            skip = s:match("^{[^}]*}", i)
        elseif c == "|" then
            skip = s:match("^|c%x%x%x%x%x%x%x%x", i) or s:match("^|H[^|]*|h", i)
                or s:match("^|T[^|]*|t", i) or s:match("^|[rhn]", i) or s:match("^||", i)
        end
        if skip then
            out[#out + 1] = skip
            i = i + #skip
        else
            out[#out + 1] = ACCENTS[c] or c
            i = i + 1
        end
    end
    return "[" .. table.concat(out) .. "]"
end
Loc.Pseudo = Pseudo

-- =========================================================================
-- LOOKUP
-- =========================================================================
-- Raw string for key, or nil when no language has it
function Loc:Get(key)
    local s = self.strings and self.strings[key]
    if s == nil then
        s = self.enUS[key]
        if s ~= nil and self.code == "pseudo" then s = Pseudo(s) end
    end
    return s
end

-- L("key", ...) -> the string in the chosen language, formatted with any arguments
function TTS.L(key, ...)
    local s = Loc:Get(key) or key
    if select("#", ...) > 0 then
        local ok, res = pcall(string.format, s, ...)
        if ok then return res end
        -- A broken translation must not break the game: fall back to English
        local en = Loc.enUS[key]
        if en then
            ok, res = pcall(string.format, en, ...)
            if ok then return res end
        end
    end
    return s
end
local L = TTS.L

-- Text defined in data files (cards, encounters...): the chosen language's key, else
-- the English the data itself carries.
function Loc:Data(key, english)
    local s = self.strings and self.strings[key]
    if s ~= nil then return s end
    s = self.enUS[key] or english
    if self.code == "pseudo" then s = Pseudo(s) end
    return s
end

-- Translated label for a data value shown to the player: Term("faction", "Kobold").
-- Untranslated values show as they are in the card data.
function Loc:Term(group, value)
    if value == nil or value == "" then return value end
    return self:Data(group .. "." .. value, value)
end

-- Card field in the chosen language (card.<ID>.name / card.<ID>.text), else the card's own English
local function CardField(card, field)
    if type(card) == "string" then card = TTS.Cards and TTS.Cards[card] end
    if not card then return nil end
    if not card.id then return card[field] end
    return Loc:Data("card." .. card.id .. "." .. field, card[field])
end

-- A card with a Horde name (nameHorde, e.g. the innkeeper Hearths) shows it to Horde
-- players. It's display only: everything else, chat links included, goes by the card id.
function TTS:CardName(card)
    if type(card) == "string" then card = TTS.Cards and TTS.Cards[card] end
    if card and card.nameHorde and card.id and UnitFactionGroup and UnitFactionGroup("player") == "Horde" then
        return Loc:Data("card." .. card.id .. ".nameHorde", card.nameHorde)
    end
    return CardField(card, "name")
end
function TTS:CardText(card) return CardField(card, "text") end

-- A card's type as players read it: "Spell", "Denizen"... and "Gear Card" for Gear Cards
-- (spells underneath, type "Sorcery", but never called one)
function TTS:CardTypeName(card)
    if type(card) == "string" then card = TTS.Cards and TTS.Cards[card] end
    if not card then return nil end
    if card.subType == "Gear" then return Loc:Term("type", "Gear") end
    return Loc:Term("type", card.type)
end

-- Damage / healing sources travel (and are stored) as "<cardId>" or "<cardId>/<kind>"
-- (kind: attack, trample) so each player reads them in their own language. Anything
-- else -- older versions sent plain English names -- shows as it is.
function TTS:ReasonText(reason)
    if type(reason) ~= "string" or reason == "" then return reason end
    local id, kind = reason:match("^([%w_]+)/?(%a*)$")
    if id and TTS.Cards and TTS.Cards[id] then
        local name = TTS:CardName(id)
        if kind ~= "" then return L("reason." .. kind, name) end
        return name
    end
    return reason
end

-- Class name ("Mage") as shown: class.<Name> if a pack has it, else the client's own
-- localised class name, else the English
function TTS:ClassName(class)
    if not class then return class end
    local client = LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[class:upper()]
    return Loc:Data("class." .. class, client or class)
end

-- Solo encounters: encounter.<id>.name / .opponent override; otherwise a zone or dungeon
-- encounter is called by its zone's name, a dungeon's opponent is its first boss card,
-- and the practice dummy uses its own strings
local function Override(key, fallback)
    local s = Loc.strings and Loc.strings[key]
    if s ~= nil then return s end
    return fallback
end

function TTS:EncounterName(enc)
    if not enc then return nil end
    local key = "encounter." .. tostring(enc.id) .. ".name"
    if enc.kind == "practice" then return Override(key, L("main.practice")) end
    if enc.zone and enc.zone == enc.name then return Override(key, Loc:Term("zone", enc.zone)) end
    return Loc:Data(key, enc.name)
end

function TTS:EncounterOpponent(enc)
    if not enc then return nil end
    local key = "encounter." .. tostring(enc.id) .. ".opponent"
    if enc.kind == "practice" then return Override(key, L("solo.dummy")) end
    if enc.bosses and enc.bosses[1] and TTS.Cards and TTS.Cards[enc.bosses[1]] then
        return Override(key, TTS:CardName(enc.bosses[1]))
    end
    return Loc:Data(key, enc.opponent)
end

-- The practice dummy's name, in English or the chosen language (it is never a real player)
function TTS:IsDummyName(name)
    return name == "Target Dummy" or name == L("solo.dummy")
end

-- =========================================================================
-- BOUND TEXTS
-- Regions whose text was set while the addon loaded are set again once the
-- chosen language is ready. Callbacks registered with OnReady run then too
-- (e.g. to resize click areas that depend on the text's width).
-- =========================================================================
local bound = {}
local readyCallbacks = {}
Loc.ready = false

-- Sets region's text to L(key, ...) now, and again once the language loads
function Loc:Bind(region, key, ...)
    if not region then return end
    local args = select("#", ...) > 0 and { n = select("#", ...), ... } or nil
    bound[region] = { key = key, args = args }
    if args then
        region:SetText(L(key, unpack(args, 1, args.n)))
    else
        region:SetText(L(key))
    end
    return region
end

-- Stops re-applying a bound text (call before giving the region other text)
function Loc:Unbind(region)
    bound[region] = nil
end

function Loc:OnReady(fn)
    if self.ready then
        pcall(fn)
    else
        readyCallbacks[#readyCallbacks + 1] = fn
    end
end

local function ApplyAll()
    for region, b in pairs(bound) do
        if b.args then
            region:SetText(L(b.key, unpack(b.args, 1, b.args.n)))
        else
            region:SetText(L(b.key))
        end
    end
    Loc.ready = true
    for _, fn in ipairs(readyCallbacks) do
        local ok, err = pcall(fn)
        if not ok and geterrorhandler then geterrorhandler()(err) end
    end
    readyCallbacks = {}
end

-- =========================================================================
-- LANGUAGE PACK
-- =========================================================================
local function AddOnAPI(name)
    return (C_AddOns and C_AddOns[name]) or _G[name]
end

-- Codes the installed language pack offers (from its toc), in LANGUAGES order
function Loc:PackLanguages()
    local getMeta = AddOnAPI("GetAddOnMetadata")
    local list = getMeta and getMeta(PACK_ADDON, "X-Languages")
    local have = {}
    if type(list) == "string" then
        for code in list:gmatch("[%a]+") do have[code] = true end
    end
    return have
end

-- Languages the player can choose: English plus whatever the pack holds
function Loc:Available()
    local have = self:PackLanguages()
    local out = {}
    for _, lang in ipairs(self.LANGUAGES) do
        if lang.code == "enUS" or have[lang.code] then out[#out + 1] = lang end
    end
    return out
end

function Loc:NameOf(code)
    for _, lang in ipairs(self.LANGUAGES) do
        if lang.code == code then return lang.name end
    end
    return code
end

-- Called by a pack file for the language it holds (only when that language is wanted).
-- A language may span several files (e.g. deDE.lua and the generated deDE_Creatures.lua);
-- their tables merge, later files winning on the same key.
function Loc:Register(code, strings)
    if code ~= self.wanted or type(strings) ~= "table" then return end
    if self.code ~= code or not self.strings then
        self.strings = {}
        self.code = code
    end
    for k, v in pairs(strings) do self.strings[k] = v end
end

-- The saved choice ("auto" or a code) turned into the code to load
function Loc:Resolve(choice)
    if choice == nil or choice == "" or choice == "auto" then
        choice = GetLocale and GetLocale() or "enUS"
    end
    if choice == "enGB" then choice = "enUS" end
    return choice
end

local function Chat(msg)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage(msg) end
end

function Loc:Load(choice)
    self.loadedChoice = choice or "auto"
    local code = self:Resolve(choice)
    self.wanted = code
    if code == "pseudo" then
        self.code = "pseudo"
    elseif code ~= "enUS" then
        if self:PackLanguages()[code] then
            local load = AddOnAPI("LoadAddOn")
            local ok, loaded, reason = pcall(load, PACK_ADDON)
            if not (ok and loaded) then
                Chat(L("locale.packFailed", PACK_ADDON, tostring(reason or loaded)))
            end
        end
        -- Explicit choice of a language we don't have: say so (auto just stays English)
        if self.code ~= code and choice and choice ~= "auto" then
            Chat(L("locale.missing", self:NameOf(code)))
        end
    end
    ApplyAll()
end

-- Saved choice for the Options dropdown ("auto" or a code)
function Loc:GetChoice()
    return (type(TTS_Options) == "table" and TTS_Options.language) or "auto"
end

function Loc:SetChoice(choice)
    if type(TTS_Options) ~= "table" then TTS_Options = {} end
    TTS_Options.language = choice
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addon)
    if addon ~= "ForeverCCG" then return end
    self:UnregisterAllEvents()
    Loc:Load(Loc:GetChoice())
end)
