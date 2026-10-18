--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
local L = TTS.L
local Loc = TTS.Locale

-- =========================================================================
-- DECK SLOTS (up to 3 saved decks, switchable from the Deckbuilder)
-- =========================================================================
TTS.MAX_DECK_SLOTS = 3

-- Maximum number of spells (non-Prayer, non-Creature cards) allowed in a deck
TTS.MAX_DECK_SPELLS = 12

-- =========================================================================
-- CLASS SPELL UNLOCKS (by character level)
-- One spell per class unlocks at level 1 and every 6 levels after (1, 7, 13 ... 55),
-- so all 10 spells of every class are available by level 55. Each tier is picked so
-- the nine new spells cover all five spheres as evenly as the card pool allows.
-- =========================================================================
TTS.SPELL_UNLOCK_FIRST_LEVEL = 6
TTS.SPELL_UNLOCK_LEVEL_STEP  = 6

TTS.SPELL_UNLOCK_TIER = {
    -- Level 1
    WAR07 = 1, PAL04 = 1, HUN01 = 1, ROG04 = 1, PRI01 = 1, SHA09 = 1, MAG02 = 1, WLK03 = 1, DRU09 = 1,
    -- Level 7
    WAR02 = 2, PAL03 = 2, HUN08 = 2, ROG01 = 2, PRI02 = 2, SHA07 = 2, MAG09 = 2, WLK09 = 2, DRU04 = 2,
    -- Level 13
    WAR04 = 3, PAL02 = 3, HUN09 = 3, ROG09 = 3, PRI07 = 3, SHA02 = 3, MAG08 = 3, WLK07 = 3, DRU02 = 3,
    -- Level 19
    WAR01 = 4, PAL06 = 4, HUN02 = 4, ROG06 = 4, PRI05 = 4, SHA03 = 4, MAG10 = 4, WLK02 = 4, DRU08 = 4,
    -- Level 25
    WAR08 = 5, PAL01 = 5, HUN05 = 5, ROG07 = 5, PRI08 = 5, SHA04 = 5, MAG01 = 5, WLK01 = 5, DRU06 = 5,
    -- Level 31
    WAR06 = 6, PAL07 = 6, HUN07 = 6, ROG05 = 6, PRI03 = 6, SHA01 = 6, MAG05 = 6, WLK06 = 6, DRU07 = 6,
    -- Level 37
    WAR03 = 7, PAL05 = 7, HUN06 = 7, ROG02 = 7, PRI06 = 7, SHA08 = 7, MAG03 = 7, WLK04 = 7, DRU05 = 7,
    -- Level 43
    WAR05 = 8, PAL08 = 8, HUN03 = 8, ROG08 = 8, PRI10 = 8, SHA06 = 8, MAG06 = 8, WLK08 = 8, DRU01 = 8,
    -- Level 49
    WAR09 = 9, PAL10 = 9, HUN04 = 9, ROG10 = 9, PRI04 = 9, SHA05 = 9, MAG04 = 9, WLK05 = 9, DRU10 = 9,
    -- Level 55
    WAR10 = 10, PAL09 = 10, HUN10 = 10, ROG03 = 10, PRI09 = 10, SHA10 = 10, MAG07 = 10, WLK10 = 10, DRU03 = 10,
}

-- Character level a class spell unlocks at (nil for cards that are not level-gated)
function TTS:GetSpellUnlockLevel(cardId)
    local tier = TTS.SPELL_UNLOCK_TIER[cardId]
    if not tier then return nil end
    return TTS.SPELL_UNLOCK_FIRST_LEVEL + (tier - 1) * TTS.SPELL_UNLOCK_LEVEL_STEP
end

function TTS:IsSpellUnlocked(cardId)
    local level = TTS:GetSpellUnlockLevel(cardId)
    if not level then return true end
    return (UnitLevel("player") or 1) >= level
end

local function DefaultDeckName(i)
    return (i == 1) and L("deck.defaultName") or L("deck.numbered", i)
end

function TTS:EnsureDeckSlots()
    TTS_SavedDecks = TTS_SavedDecks or {}
    for i = 1, TTS.MAX_DECK_SLOTS do
        local deck = TTS_SavedDecks[i]
        if type(deck) ~= "table" then
            TTS_SavedDecks[i] = { name = DefaultDeckName(i), cards = {} }
        else
            deck.cards = deck.cards or {}
            deck.name = deck.name or DefaultDeckName(i)
        end
    end
    TTS_ActiveDeckIndex = tonumber(TTS_ActiveDeckIndex) or 1
    if TTS_ActiveDeckIndex < 1 or TTS_ActiveDeckIndex > TTS.MAX_DECK_SLOTS then
        TTS_ActiveDeckIndex = 1
    end
end

-- =========================================================================
-- STYLE
-- Classic Blizzard look: dialog-box window, tooltip-bordered panels and
-- controls, red panel buttons. Sphere colours drive the filter toggles and
-- the distribution chart.
-- =========================================================================
local STYLE = {
    windowBg      = { 1, 1, 1, 1 },             -- dialog texture at its natural colour
    windowBorder  = { 1, 1, 1, 1 },
    panelBg       = { 0.04, 0.04, 0.04, 0.70 },
    panelBorder   = { 0.60, 0.56, 0.48, 1 },
    controlBg     = { 0.10, 0.08, 0.06, 0.95 },
    controlBorder = { 0.55, 0.50, 0.40, 1 },
    menuBg        = { 0.02, 0.02, 0.02, 0.95 },
    menuBorder    = { 0.85, 0.75, 0.45, 1 },
    accent        = { 1.00, 0.82, 0.00, 1 },
}

local BACKDROPS = {
    dialog = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    },
    panel = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    },
    control = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    },
}

local HIGHLIGHT_TEX = "Interface\\QuestFrame\\UI-QuestTitleHighlight"
local BAR_TEX       = "Interface\\TargetingFrame\\UI-StatusBar"

local GOLD  = "|cFFFFD200"
local GREY  = "|cFF8A8A8A"
local GREEN = "|cFF33DD33"
local RED   = "|cFFFF4444"

local QUESTION_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

local SPHERE_ORDER = { "W", "U", "B", "R", "G" }
local SPHERE_RGB = {
    W = { 1.00, 0.82, 0.00 },  -- Holy
    U = { 0.40, 0.73, 1.00 },  -- Arcane
    B = { 0.60, 0.40, 1.00 },  -- Shadow
    R = { 1.00, 0.27, 0.27 },  -- Fire
    G = { 0.27, 1.00, 0.27 },  -- Nature
}
local SPHERE_NAME = { W = "Holy", U = "Arcane", B = "Shadow", R = "Fire", G = "Nature" }
local NEUTRAL_RGB = { 0.55, 0.55, 0.58 }

local function RGBHex(rgb)
    return string.format("|cFF%02X%02X%02X", math.floor(rgb[1] * 255), math.floor(rgb[2] * 255), math.floor(rgb[3] * 255))
end

-- Sphere/cost symbols come from Board.lua, which loads after this file
local function Sym(str, size, tapSize)
    if TTS.FormatSymbols then return TTS:FormatSymbols(str, size, tapSize) end
    return str
end

-- Gives any frame SetBackdrop (built in on old clients, a mixin on newer ones)
local function EnsureBackdrop(f)
    if f.SetBackdrop then return true end
    if BackdropTemplateMixin and Mixin then
        Mixin(f, BackdropTemplateMixin)
        if f.OnBackdropSizeChanged then
            f:HookScript("OnSizeChanged", f.OnBackdropSizeChanged)
        end
    end
    return f.SetBackdrop ~= nil
end

local function SetBg(f, r, g, b, a)
    if f.SetBackdropColor then f:SetBackdropColor(r, g, b, a or 1) end
end

local function SetBorder(f, r, g, b, a)
    if f.SetBackdropBorderColor then f:SetBackdropBorderColor(r, g, b, a or 1) end
end

-- kind: "dialog", "panel" (default) or "control"
local function Skin(f, bg, border, kind)
    if not EnsureBackdrop(f) then return end
    f:SetBackdrop(BACKDROPS[kind or "panel"])
    SetBg(f, bg[1], bg[2], bg[3], bg[4])
    SetBorder(f, border[1], border[2], border[3], border[4])
end

-- Tooltips go through the manager in UI\Tooltips.lua.
-- tooltipSymbol (optional): stacks that symbol's explanation (the sphere toggles)
local TT = TTS.Tooltip

local function AddTooltipScripts(b)
    b:SetScript("OnEnter", function(self)
        -- Titles and texts are locale keys (plain text passes through L unchanged) or functions
        local title, text = self.tooltipTitle, self.tooltipText
        if type(title) == "function" then title = title() end
        if type(text) == "function" then text = text() end
        if title then
            TT:ShowText(self, "ANCHOR_TOP", L(title), text and L(text), { symbol = self.tooltipSymbol })
        end
    end)
    b:SetScript("OnLeave", function(self) TT:Hide(self) end)
end

-- Tooltip-bordered control (dropdowns, toggles)
local function CreateFlatButton(parent, w, h, text)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(w, h)
    Skin(b, STYLE.controlBg, STYLE.controlBorder, "control")

    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetPoint("TOPLEFT", 3, -3)
    hl:SetPoint("BOTTOMRIGHT", -3, 3)
    hl:SetTexture(HIGHLIGHT_TEX)
    hl:SetBlendMode("ADD")

    b.label = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.label:SetPoint("LEFT", 6, 0)
    b.label:SetPoint("RIGHT", -6, 0)
    b.label:SetWordWrap(false)
    Loc:Bind(b.label, text or "")

    AddTooltipScripts(b)
    return b
end

-- Classic red panel button (actions and deck tabs)
local function CreatePanelButton(parent, w, h, text)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(w, h)
    b:SetNormalFontObject("GameFontNormalSmall")
    b:SetHighlightFontObject("GameFontHighlightSmall")
    b:SetDisabledFontObject("GameFontDisableSmall")
    Loc:Bind(b, text or "")
    b.label = b:GetFontString()
    AddTooltipScripts(b)
    return b
end

local function SetButtonEnabled(b, enabled)
    if enabled then
        b:Enable()
        b.label:SetAlpha(1)
    else
        b:Disable()
        b.label:SetAlpha(0.5)
    end
end

-- =========================================================================
-- LAYOUT
-- =========================================================================
local WIN_W, WIN_H = 1090, 680
local PAD          = 14
local PANEL_TOP    = -46
local PANEL_H      = 598
local POOL_W       = 684
local DECK_W       = WIN_W - PAD * 3 - POOL_W   -- 364

local TILE_W, TILE_H     = 104, 152
local TILE_GAP_X         = 8
local TILE_GAP_Y         = 10
local GRID_COLS          = 6
local GRID_ROWS          = 3
local TILES_PER_PAGE     = GRID_COLS * GRID_ROWS

local LIST_W   = DECK_W - 20                    -- 344
local LIST_H   = 388
local ROW_H    = 15
local COL_GAP  = 8

-- =========================================================================
-- MAIN WINDOW
-- =========================================================================
local D = CreateFrame("Frame", "TTS_DeckBuilderFrame", UIParent)
TTS.DeckBuilderFrame = D
D:SetSize(WIN_W, WIN_H)
D:SetPoint("CENTER")
D:SetClampedToScreen(true)
Skin(D, STYLE.windowBg, STYLE.windowBorder, "dialog")
D:EnableMouse(true)
D:SetMovable(true)
D:RegisterForDrag("LeftButton")
D:SetScript("OnDragStart", D.StartMoving)
D:SetScript("OnDragStop", D.StopMovingOrSizing)
D:Hide()

local titleBar = D:CreateTexture(nil, "ARTWORK")
-- Darkened strip inside the dialog border; its bottom edge stays where it was
titleBar:SetPoint("TOPLEFT", 12, -12)
titleBar:SetPoint("TOPRIGHT", -12, -12)
titleBar:SetHeight(25)
titleBar:SetColorTexture(0, 0, 0, 0.35)

local titleLine = D:CreateTexture(nil, "ARTWORK")
titleLine:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 0)
titleLine:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
titleLine:SetHeight(1)
titleLine:SetColorTexture(1, 0.82, 0, 0.55)

local title = D:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -11)
Loc:Bind(title, "db.title")
do  -- the grey Forever: CCG tag after the title, as on Rules & Guide
    local tag = D:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    tag:SetPoint("LEFT", title, "RIGHT", 10, -1)
    tag:SetText("Forever: CCG")
end

local close = CreateFrame("Button", nil, D, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -2, -2)

-- =========================================================================
-- SCALING (drag the bottom-right grip)
-- The whole window scales as one, so the layout never reflows. The top-left
-- corner stays put while dragging.
-- =========================================================================
local MIN_SCALE, MAX_SCALE = 0.6, 1.5

local scaleGrip = CreateFrame("Button", nil, D)
scaleGrip:SetSize(16, 16)
scaleGrip:SetPoint("BOTTOMRIGHT", D, "BOTTOMRIGHT", -3, 3)
scaleGrip:SetFrameLevel(D:GetFrameLevel() + 20)
scaleGrip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
scaleGrip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
scaleGrip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

local function ScaleGrip_OnUpdate(self)
    local cx, cy = GetCursorPosition()
    -- Grow by however far the cursor moved along the window's diagonal
    local grow = ((cx - self.startX) / self.startW + (self.startY - cy) / self.startH) / 2
    local scale = math.max(MIN_SCALE, math.min(MAX_SCALE, self.startScale * (1 + grow)))
    D:SetScale(scale)
    -- Saved so the Deckbuilder always reopens at this size
    if TTS.Options then TTS.Options:Set("deckBuilderScale", scale) end
    local eff = D:GetEffectiveScale()
    D:ClearAllPoints()
    D:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.leftPx / eff, self.topPx / eff)
end

scaleGrip:SetScript("OnMouseDown", function(self, button)
    if button ~= "LeftButton" then return end
    local eff = D:GetEffectiveScale()
    self.startX, self.startY = GetCursorPosition()
    self.startScale = D:GetScale()
    self.startW = D:GetWidth() * eff     -- screen pixels
    self.startH = D:GetHeight() * eff
    self.leftPx = D:GetLeft() * eff
    self.topPx = D:GetTop() * eff
    self:SetScript("OnUpdate", ScaleGrip_OnUpdate)
end)
scaleGrip:SetScript("OnMouseUp", function(self)
    self:SetScript("OnUpdate", nil)
    -- Cards that got too small (or big enough) for printed rules text
    if D.RefreshCardText then D:RefreshCardText() end
end)
scaleGrip:SetScript("OnHide", function(self)
    self:SetScript("OnUpdate", nil)
end)
scaleGrip:SetScript("OnEnter", function(self)
    TT:ShowText(self, "ANCHOR_TOP", L("db.dragScale"))
end)
scaleGrip:SetScript("OnLeave", function(self) TT:Hide(self) end)

local footer = D:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
footer:SetPoint("BOTTOMRIGHT", D, "BOTTOMRIGHT", -26, 13)
footer:SetText("Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy")

local poolPanel = CreateFrame("Frame", nil, D)
poolPanel:SetSize(POOL_W, PANEL_H)
poolPanel:SetPoint("TOPLEFT", D, "TOPLEFT", PAD, PANEL_TOP)
Skin(poolPanel, STYLE.panelBg, STYLE.panelBorder)

local deckPanel = CreateFrame("Frame", nil, D)
deckPanel:SetSize(DECK_W, PANEL_H)
deckPanel:SetPoint("TOPLEFT", poolPanel, "TOPRIGHT", PAD, 0)
Skin(deckPanel, STYLE.panelBg, STYLE.panelBorder)

-- =========================================================================
-- FILTER STATE
-- =========================================================================
local onlyUnlocked = true   -- locked cards are never shown in the card pool
local colorOn = { W = true, U = true, B = true, R = true, G = true }
local typeOn  = { Prayer = true, Creature = true, Spell = true }
local classFilter = nil      -- nil = all classes; otherwise only spells of this class are shown
local zoneFilter = nil       -- nil = all zones; otherwise only creatures from this zone are shown
local factionFilter = nil    -- nil = all factions; otherwise only creatures of this faction are shown
local creatureTypeFilter = nil -- nil = all creature types; otherwise only creatures of this type are shown
-- Keyword filter, kept in one table (this file is near Lua's 200-locals limit):
-- value = nil (any) or a TT.KEYWORDS key; Name(k), List() and dd (its dropdown) below
local Keyword = {}
local searchText = ""        -- lower-case; matched against card name and rules text
local sortMode = "COST"      -- a key of SORT_LABEL: COST, COLOR, TYPE, CLASS, FACTION, ZONE, CREATURETYPE
local poolPage = 1
local cardPoolKeys = {}

-- =========================================================================
-- UNLOCK HELPERS
-- Collectible cards are owned in copies (max 4 in a deck): isBoss cards by killing the
-- creature, isReward cards by winning their solo encounter, isGift cards from an NPC
-- (TTS:GetOwnedCopies).
-- =========================================================================
local function IsCollectible(card)
    return card and (card.isBoss or card.isReward or card.isGift or card.isHero) and true or false
end

local function GetKillCount(cardId, card)
    if not IsCollectible(card) then return 0 end
    return TTS:GetOwnedCopies(card) or 0
end

-- What the player has to do to earn a locked collectible card
local function UnlockHint(card)
    if card.isReward then
        local enc = TTS.GetRewardEncounter and TTS:GetRewardEncounter(card.id)
        return enc and L("db.unlockWin", TTS:EncounterName(enc)) or L("link.winItsEncounter")
    end
    if card.isGift then return TTS:GiftHow(card) end
    if card.unlockOnDeath then return L("link.dieToUnlock") end
    return L("link.defeat", TTS:CardName(card))
end

local function IsCardUnlocked(cardId, card)
    if IsCollectible(card) then return GetKillCount(cardId, card) > 0 end
    return TTS:IsSpellUnlocked(cardId)
end

-- Land = Prayer, Creature = Creature, everything else (Sorcery, ...) = Spell
local function GetTypeGroup(card)
    if card.type == "Land" then return "Prayer" end
    if card.type == "Creature" then return "Creature" end
    return "Spell"
end

-- Copies of a card the deck may hold (nil = unlimited, used for Prayers)
local function GetCopyLimit(cardId, card)
    if IsCollectible(card) then return math.min(4, GetKillCount(cardId, card)) end
    if card.type == "Land" then return nil end
    return 4
end

local function CardPassesFilters(cardId, card)
    if card.isToken then return false end   -- made by effects, never collected
    if card.notCollectible then return false end   -- an opponent's hero, or the upgrade preview (Hero.lua)
    if not typeOn[GetTypeGroup(card)] then return false end
    if card.color and colorOn[card.color] == false then return false end
    if onlyUnlocked and not IsCardUnlocked(cardId, card) then return false end
    if classFilter and GetTypeGroup(card) == "Spell" and card.class ~= classFilter then return false end
    if zoneFilter and GetTypeGroup(card) == "Creature" and card.zone ~= zoneFilter then return false end
    if factionFilter and GetTypeGroup(card) == "Creature" and card.faction ~= factionFilter then return false end
    if creatureTypeFilter and GetTypeGroup(card) == "Creature" and card.creatureType ~= creatureTypeFilter then return false end
    if Keyword.value and not Keyword.Has(card, Keyword.value) then return false end
    if searchText ~= "" then
        -- Search the shown (translated) name and text, and the English ones
        local hay = string.lower((card.name or "") .. "\n" .. (card.text or "") .. "\n"
            .. (TTS:CardName(card) or "") .. "\n" .. (TTS:CardText(card) or ""))
        if not string.find(hay, searchText, 1, true) then return false end
    end
    return true
end

-- =========================================================================
-- SORTING
-- Every mode groups cards by one field, then sorts by mana cost, name and id
-- inside each group. Cards without that field go after the ones that have it.
-- =========================================================================
local CLASS_ORDER = { "Warrior", "Paladin", "Hunter", "Rogue", "Priest", "Shaman", "Mage", "Warlock", "Druid" }

local function IndexOf(list)
    local t = {}
    for i, v in ipairs(list) do t[v] = i end
    return t
end
local CLASS_RANK  = IndexOf(CLASS_ORDER)
local SPHERE_RANK = IndexOf(SPHERE_ORDER)
local TYPE_RANK   = { Creature = 1, Spell = 2, Prayer = 3 }

local SORT_ORDER = { "COST", "COLOR", "TYPE", "CLASS", "FACTION", "ZONE", "CREATURETYPE" }
-- Shown as db.sort.<mode>
local SORT_LABEL = setmetatable({}, { __index = function(_, mode) return L("db.sort." .. mode) end })

-- Returns group rank, then a value to order by inside that rank, then the label
-- shown next to the card (nil = no label)
local SORT_KEY = {
    COLOR = function(card)
        local r = SPHERE_RANK[card.color]
        if r then return 1, r, nil end
        return 2, 0, nil
    end,
    TYPE = function(card)
        return TYPE_RANK[GetTypeGroup(card)] or 4, 0, nil
    end,
    CLASS = function(card)
        if card.class then return 1, CLASS_RANK[card.class] or 99, TTS:ClassName(card.class) end
        return 2, 0, nil
    end,
    FACTION = function(card)
        if card.faction then local s = Loc:Term("faction", card.faction); return 1, s, s end
        return 2, "", nil
    end,
    -- Zone creatures (A-Z by zone), then class spells (by class), then everything else
    ZONE = function(card)
        if card.zone then local s = Loc:Term("zone", card.zone); return 1, s, s end
        if card.class then local s = TTS:ClassName(card.class); return 2, s, s end
        return 3, "", nil
    end,
    CREATURETYPE = function(card)
        if card.creatureType then local s = Loc:Term("creatureType", card.creatureType); return 1, s, s end
        return 2, "", nil
    end,
}

local function CompareCards(a, b)
    local ca, cb = TTS.Cards[a], TTS.Cards[b]
    local key = SORT_KEY[sortMode]
    if key then
        local ga, va = key(ca)
        local gb, vb = key(cb)
        if ga ~= gb then return ga < gb end
        if va ~= vb then return va < vb end
    end
    local ma, mb = ca.cmc or 0, cb.cmc or 0
    if ma ~= mb then return ma < mb end
    local na, nb = TTS:CardName(ca) or "", TTS:CardName(cb) or ""
    if na ~= nb then return na < nb end
    return a < b
end

-- The value the current sort groups this card by (nil when sorting by cost, or when it has none)
local function SortLabel(card)
    local key = SORT_KEY[sortMode]
    if not key then return nil end
    local _, _, label = key(card)
    return label
end

-- Grey label shown after a card's name in the deck list while grouping by a text field
local function SortSuffix(card)
    local label = SortLabel(card)
    return label and ("  |cFF888888" .. label .. "|r") or ""
end

-- =========================================================================
-- CLASS HELPERS
-- =========================================================================

local function ClassColored(className)
    local c = RAID_CLASS_COLORS and RAID_CLASS_COLORS[string.upper(className)]
    if c then
        return string.format("|cFF%02X%02X%02X%s|r", math.floor(c.r * 255), math.floor(c.g * 255), math.floor(c.b * 255), TTS:ClassName(className))
    end
    return TTS:ClassName(className)
end

-- Every class that has at least one spell in the card database, in CLASS_ORDER first
local function BuildClassList()
    local present, list, seen = {}, {}, {}
    for _, card in pairs(TTS.Cards or {}) do
        if card.class then present[card.class] = true end
    end
    for _, cls in ipairs(CLASS_ORDER) do
        if present[cls] then
            table.insert(list, cls)
            seen[cls] = true
        end
    end
    local extras = {}
    for cls in pairs(present) do
        if not seen[cls] then table.insert(extras, cls) end
    end
    table.sort(extras)
    for _, cls in ipairs(extras) do table.insert(list, cls) end
    return list
end

-- Sorted unique values of a card field (zone, faction, creatureType ...)
local function BuildFieldList(field)
    local present, list = {}, {}
    for _, card in pairs(TTS.Cards or {}) do
        local v = card[field]
        if v and not present[v] then
            present[v] = true
            table.insert(list, v)
        end
    end
    -- In the order the player reads them (translated values sort differently)
    local group = (field == "creatureType") and "creatureType" or field
    table.sort(list, function(a, b) return Loc:Term(group, a) < Loc:Term(group, b) end)
    return list
end

-- Keywords at least one collectable card has, by their shown name, plus the card
-- abilities listed with them (filter value -> TT.EFFECTS id)
Keyword.ABILITIES = { aura = "anthem", spawn = "spawn" }
function Keyword.Name(k)
    local effect = Keyword.ABILITIES[k]
    if effect then return TT:Def("effect", effect, "name") end
    return TT:Def("keyword", k, "name")
end
-- Kinsmanship is the card's rally, not a keyword field; Aura its anthem; Spawn an Arrival,
-- Martyrdom or Aggro that puts Adds onto the battlefield
function Keyword.Has(card, k)
    if k == "kinsmanship" then return card.rally ~= nil end
    if k == "aura" then return card.anthem ~= nil end
    if k == "spawn" then
        for _, key in ipairs({ "etb", "onDeath", "onAttack" }) do
            for _, op in ipairs((card[key] and card[key].ops) or {}) do
                if op.op == "token" then return true end
            end
        end
        return false
    end
    if card[k] then return true end
    -- A spell has the keywords it grants ("gains Quick and Invisible", Shielded)
    for _, op in ipairs((card.effect and card.effect.ops) or {}) do
        if k == "shielded" and op.op == "shielded" then return true end
        for _, kw in ipairs(op.kw or {}) do
            if kw == k then return true end
        end
    end
    return false
end
function Keyword.List()
    local list = {}
    local keys = {}
    for _, k in ipairs(TT.KEYWORD_ORDER) do keys[#keys + 1] = k end
    for k in pairs(Keyword.ABILITIES) do keys[#keys + 1] = k end
    for _, k in ipairs(keys) do
        for _, card in pairs(TTS.Cards or {}) do
            if Keyword.Has(card, k) and not card.isToken then table.insert(list, k); break end
        end
    end
    table.sort(list, function(a, b) return Keyword.Name(a) < Keyword.Name(b) end)
    return list
end

-- =========================================================================
-- ACTIVE DECK & ADD RULES
-- =========================================================================
local function GetActiveDeck()
    TTS:EnsureDeckSlots()
    return TTS_SavedDecks[TTS_ActiveDeckIndex]
end

-- Returns the chat message explaining why the card can't be added, or nil if it can
local function CheckAdd(cardId, card, deck)
    local cards = (deck and deck.cards) or {}

    -- Total deck size cap (50 cards maximum)
    local totalCards = 0
    for _, qty in pairs(cards) do
        totalCards = totalCards + qty
    end
    if totalCards >= 50 then
        return L("db.maxDeck")
    end

    -- Spell cap (TTS.MAX_DECK_SPELLS spells maximum)
    if GetTypeGroup(card) == "Spell" then
        local spellCards = 0
        for id, qty in pairs(cards) do
            local c = TTS.Cards[id]
            if c and GetTypeGroup(c) == "Spell" then
                spellCards = spellCards + qty
            end
        end
        if spellCards >= TTS.MAX_DECK_SPELLS then
            return L("db.maxSpells", TTS.MAX_DECK_SPELLS)
        end
    end

    local current = cards[cardId] or 0

    if IsCollectible(card) then
        local kills = GetKillCount(cardId, card)
        if kills <= 0 then
            return L("db.toUnlock", UnlockHint(card))
        end
        local maxAllowed = math.min(4, kills)
        if current >= maxAllowed then
            if card.isHero then
                return L(kills == 1 and "db.heroCopies.one" or "db.heroCopies.other", kills)
            elseif maxAllowed >= 4 then
                return L("db.max4", TTS:CardName(card))
            else
                if card.isReward or card.isGift then
                    return L(kills == 1 and "db.ownCopies.one" or "db.ownCopies.other", kills, TTS:CardName(card), UnlockHint(card))
                end
                return L("db.kills", kills, TTS:CardName(card))
            end
        end
    else
        if not TTS:IsSpellUnlocked(cardId) then
            return L("db.unlocksAt", TTS:CardName(card), TTS:GetSpellUnlockLevel(cardId))
        end
        if card.type ~= "Land" and current >= 4 then
            return L("db.max4Allowed", TTS:CardName(card))
        end
    end

    return nil
end

-- =========================================================================
-- PREVIEW CARD FRAME (Built identically to Board.lua)
-- =========================================================================
local previewCard = nil

local function BuildStandaloneCardPreview(parent, sizeX, sizeY, name)
    local f = CreateFrame("Frame", name, parent)
    f:SetSize(sizeX, sizeY)
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel((parent:GetFrameLevel() or 10) + 10)

    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetAllPoints(f)
    f.bg:SetColorTexture(0.08, 0.08, 0.08, 0.95)

    -- Art dimensions matching ART_BOX ratios from Board.lua
    local artLeft   = math.floor(sizeX * 0.06)
    local artRight  = math.floor(sizeX * 0.06)
    local artTop    = math.floor(sizeY * 0.06)
    local artBottom = math.floor(sizeY * 0.44)

    f.art = f:CreateTexture(nil, "ARTWORK")
    f.art:SetPoint("TOPLEFT", f, "TOPLEFT", artLeft, -artTop)
    f.art:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -artRight, artBottom)
    f.art:SetTexture(QUESTION_ICON)

    -- DressUpModel (a PlayerModel that can try on items) for cards with dressItems
    local okModel, model = pcall(CreateFrame, "DressUpModel", nil, f)
    f.model = okModel and model or CreateFrame("PlayerModel", nil, f)
    f.model:SetPoint("TOPLEFT", f, "TOPLEFT", artLeft, -artTop)
    f.model:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -artRight, artBottom)
    f.model:EnableMouse(false)
    f.model:Hide()

    f.overlay = CreateFrame("Frame", nil, f)
    f.overlay:SetAllPoints(f)
    f.overlay:EnableMouse(false)

    f.border = f.overlay:CreateTexture(nil, "OVERLAY")
    f.border:SetAllPoints(f.overlay)

    f.title = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.title:SetPoint("BOTTOMLEFT", f.overlay, "TOPLEFT", -6, 3)
    f.title:SetPoint("BOTTOMRIGHT", f.overlay, "TOPRIGHT", 6, 3)
    f.title:SetJustifyH("CENTER")

    f.cost = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.cost:SetPoint("BOTTOM", f.title, "TOP", 0, 2)
    f.cost:SetJustifyH("CENTER")

    local ptOffsetY = math.floor(sizeY * 0.18)
    f.pt = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    local fontPath = f.pt:GetFont()
    if fontPath then f.pt:SetFont(fontPath, 15, "OUTLINE") end
    f.pt:SetPoint("BOTTOM", f.overlay, "BOTTOM", 0, ptOffsetY)
    f.pt:SetJustifyH("CENTER")
    f.pt:SetShadowOffset(1.5, -1.5)
    f.pt:SetShadowColor(0, 0, 0, 1)

    f:Hide()
    return f
end

local PREVIEW_W, PREVIEW_H = 150, 212

-- A card in Board.lua's design (or the identical standalone copy if Board.lua isn't loaded)
local function CreateCardDesign(parent, w, h, name)
    if TTS.CreateCardFrame then
        return TTS.CreateCardFrame(parent, w, h)
    end
    return BuildStandaloneCardPreview(parent, w, h, name)
end

-- Fills a card frame with a card's art, frame, name, cost and stats
local function PaintCardFrame(f, card, costSize)
    if TTS.SetupCardVisual then
        TTS.SetupCardVisual(f, card)
    else
        if card.displayId and f.model then
            f.art:Hide()
            f.model:Show()
            f.model:ClearModel()
            f.model:SetDisplayInfo(card.displayId)
        else
            if f.model then f.model:Hide() end
            f.art:Show()
            f.art:SetTexture(card.art or QUESTION_ICON)
            if TTS.TintArt then TTS.TintArt(f.art, card) end
        end
    end

    if TTS.ApplyFrameTexture then
        TTS.ApplyFrameTexture(f.border, card)
    else
        f.border:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    end

    f.title:SetText(TTS:CardName(card) or "")

    if card.cost and card.cost ~= "" then
        f.cost:SetText(Sym(card.cost, costSize))
        f.cost:Show()
    else
        f.cost:Hide()
    end

    TTS.ShowPrintedStats(f, card)
end

-- Rules text printed on the card, matching Board.lua's UpdateCardRules: same
-- text box, font range and P/T placement. Board.lua keeps that function local,
-- so its numbers are mirrored here.
local TEXT_BOX = {
    left         = 0.09,
    right        = 0.12,
    top          = 0.60,
    bottom       = 0.08,
    bottomWithPT = 0.20,
}
local RULES_FONT_MAX = 8   -- tried first; shrinks toward MIN until the text fits
local RULES_FONT_MIN = 6
-- Cards narrower than this on screen (pixels, Deckbuilder scale included) show
-- no printed text: their rules are in the tooltip only
local CARD_TEXT_MIN_WIDTH = 72
-- Symbols in printed rules text (tap and mana alike) are drawn this many pixels
-- larger than the text's base symbol size (mirrors Board.lua)
local RULES_TAP_EXTRA = 3

-- Rules text settings for the large preview card on the left
local PREVIEW_RULES = {
    fontMax = 11,
    fontMin = 8,
    offsetX = 3,   -- pixels right
    offsetY = 3,   -- pixels down
}

-- Call after the card is shown (fitting needs the text laid out)
-- opts (optional): fontMax, fontMin, offsetX (pixels right), offsetY (pixels down)
local function PrintCardRules(f, card, opts)
    if not f.rules or not f.pt then return end
    local fontMax = (opts and opts.fontMax) or RULES_FONT_MAX
    local fontMin = (opts and opts.fontMin) or RULES_FONT_MIN
    local dx = (opts and opts.offsetX) or 0
    local dy = (opts and opts.offsetY) or 0
    local hasPT = f.pt:IsShown()
    local w, h = f:GetSize()
    local onScreen = w * (D:GetScale() or 1)

    TTS.PlaceCardStats(f)
    if card and card.text and card.text ~= "" and onScreen >= CARD_TEXT_MIN_WIDTH then
        -- Fitting happens in the card's own (unscaled) size, so it only needs redoing for a new card
        if f.rulesCard ~= card or f.rulesPT ~= hasPT then
            f.rulesCard, f.rulesPT = card, hasPT
            f.rules:ClearAllPoints()
            f.rules:SetPoint("TOPLEFT", f.overlay, "TOPLEFT", w * TEXT_BOX.left + 1 + dx, -h * TEXT_BOX.top - 1 - dy)
            f.rules:SetPoint("BOTTOMRIGHT", f.overlay, "BOTTOMRIGHT", -w * TEXT_BOX.right + dx,
                h * (hasPT and TEXT_BOX.bottomWithPT or TEXT_BOX.bottom) - dy)
            f.rules:SetJustifyH("CENTER")
            local fontPath = f.rules:GetFont() or STANDARD_TEXT_FONT
            for size = fontMax, fontMin, -1 do
                f.rules:SetFont(fontPath, size, "")
                f.rules:SetText(Sym(TTS:CardRulesText(card, true), size + 2 + RULES_TAP_EXTRA, size + 2 + RULES_TAP_EXTRA))
                if not (f.rules.IsTruncated and f.rules:IsTruncated()) then break end
            end
        end
        f.rules:Show()
    else
        f.rules:Hide()
    end
end

local function EnsurePreviewFrame()
    if previewCard then return previewCard end

    previewCard = CreateCardDesign(D, PREVIEW_W, PREVIEW_H, "TTS_DeckBuilder_PreviewCard")

    previewCard:SetSize(PREVIEW_W, PREVIEW_H)
    previewCard:SetFrameStrata("DIALOG")
    previewCard:SetFrameLevel((D:GetFrameLevel() or 10) + 40)
    previewCard:SetClampedToScreen(true)
    previewCard:EnableMouse(false)

    return previewCard
end

-- The Adds a card spawns (and the Adds those spawn), as small cards stacked under the preview,
-- each labelled "3x Add" over its tags. Kept on D: this file is at Lua's 200-locals limit.
D.ADD_PREVIEW = { w = 106, h = 150, gap = 52, rules = { fontMax = 9, fontMin = 6 } }
function D:UpdateAddPreviews(f, card)
    f.adds = f.adds or {}
    local list, seen = {}, {}
    local function Collect(c, depth)
        for _, key in ipairs({ "etb", "onDeath", "onAttack" }) do
            for _, op in ipairs((c[key] and c[key].ops) or {}) do
                local tok = op.op == "token" and TTS.Cards[op.id]
                if tok and not seen[op.id] then
                    seen[op.id] = true
                    list[#list + 1] = { card = tok, n = op.n or 1 }
                    if depth < 2 then Collect(tok, depth + 1) end
                end
            end
        end
    end
    Collect(card, 1)

    local size, anchor = self.ADD_PREVIEW, f
    for i, e in ipairs(list) do
        local a = f.adds[i]
        if not a then
            a = CreateCardDesign(f, size.w, size.h, nil)
            a:SetSize(size.w, size.h)
            a:SetFrameStrata("DIALOG")
            a:SetFrameLevel((f:GetFrameLevel() or 10) + 1)
            a:EnableMouse(false)
            a.addLabel = a.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            a.addLabel:SetPoint("TOP", a, "BOTTOM", 0, -3)
            a.addLabel:SetJustifyH("CENTER")
            f.adds[i] = a
        end
        a:ClearAllPoints()
        -- room for the previous card's label and this card's name and cost above it
        a:SetPoint("TOP", anchor, "BOTTOM", 0, -(anchor == f and size.gap - 16 or size.gap))
        PaintCardFrame(a, e.card, 14)
        local tags = TTS.GetCardTagLine and TTS:GetCardTagLine(e.card)
        a.addLabel:SetText(string.format("|cFFFFFFFF%dx|r %s", e.n, TT:Def("effect", "token", "name"))
            .. (tags and ("\n" .. tags) or ""))
        a:Show()
        PrintCardRules(a, e.card, size.rules)
        anchor = a
    end
    for i = #list + 1, #f.adds do f.adds[i]:Hide() end
end

-- Shows the full card docked outside the left edge of the Deckbuilder
local function UpdateCardPreview(cardId)
    local f = EnsurePreviewFrame()
    if not f then return end

    if not cardId or not TTS.Cards or not TTS.Cards[cardId] then
        f:Hide()
        return
    end

    local card = TTS.Cards[cardId]
    f.cardId = cardId

    -- Card name and cost sit above the frame, so leave room for them
    f:ClearAllPoints()
    f:SetPoint("TOPRIGHT", D, "TOPLEFT", -12, PANEL_TOP - 30)

    PaintCardFrame(f, card, 18)

    f:Show()
    PrintCardRules(f, card, PREVIEW_RULES)
    D:UpdateAddPreviews(f, card)
    return f
end

-- =========================================================================
-- MOUSEOVER HANDLERS (Preview Card + Tooltip)
-- =========================================================================
local function CardTooltip_OnEnter(self)
    if not self.cardId then return end
    local card = TTS.Cards and TTS.Cards[self.cardId]
    if not card then return end

    -- 1. Full card preview docked to the left of the Deckbuilder
    UpdateCardPreview(self.cardId)

    -- 2. Tooltip at the mouse cursor, with the collection status under the name
    local cardId = self.cardId
    TT:ShowCard(self, "ANCHOR_CURSOR", cardId, {
        hint = self.hint and L(self.hint),
        header = function(tip)
            if IsCollectible(card) then
                local kills = GetKillCount(cardId, card)
                if kills == 0 then
                    if card.isReward or card.isGift then
                        tip:AddLine("|cFFFF2222" .. L("db.lockedHow", UnlockHint(card)) .. "|r", 1, 0.2, 0.2, true)
                    else
                        tip:AddLine("|cFFFF2222" .. L("db.lockedDefeat") .. "|r", 1, 0.2, 0.2)
                    end
                else
                    local maxAllowed = math.min(4, kills)
                    tip:AddLine("|cFF00FF00" .. L("db.collected", kills, maxAllowed) .. "|r", 0.2, 1.0, 0.2)
                end
            elseif not TTS:IsSpellUnlocked(cardId) then
                tip:AddLine("|cFFFF2222" .. L("db.lockedLevel", TTS:GetSpellUnlockLevel(cardId)) .. "|r", 1, 0.2, 0.2)
            end
        end,
    })
end

local function CardTooltip_OnLeave()
    TT:Hide()
    if previewCard then
        previewCard:Hide()
    end
end

-- =========================================================================
-- DROPDOWN MENUS
-- One menu open at a time; clicking anywhere else in the window closes it.
-- =========================================================================
local openMenu = nil

local menuBlocker = CreateFrame("Button", nil, D)
menuBlocker:SetAllPoints(D)
menuBlocker:SetFrameStrata("FULLSCREEN_DIALOG")
menuBlocker:SetFrameLevel(1)
menuBlocker:RegisterForClicks("AnyUp")
menuBlocker:Hide()

local function CloseMenus()
    if openMenu then
        openMenu:Hide()
        openMenu = nil
    end
    menuBlocker:Hide()
end
menuBlocker:SetScript("OnClick", CloseMenus)

local MENU_ROW_H, MENU_COL_W = 18, 140

-- cfg: values() -> list, cols, colorize(value) -> text, onSelect(value or nil)
local function CreateDropdown(parent, width, allText, cfg)
    local dd = CreateFlatButton(parent, width, 24, "")
    -- SetValue owns the label; a bound "" would blank it once the language loads
    Loc:Unbind(dd.label)

    dd.arrow = dd:CreateTexture(nil, "OVERLAY")
    dd.arrow:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
    dd.arrow:SetSize(12, 12)
    dd.arrow:SetPoint("RIGHT", -5, -3)

    dd.label:ClearAllPoints()
    dd.label:SetPoint("LEFT", 7, 0)
    dd.label:SetPoint("RIGHT", dd.arrow, "LEFT", -2, 3)
    dd.label:SetJustifyH("LEFT")

    -- allText is a locale key; cfg.display(v) (optional) is the shown form of a value
    local function Display(v)
        if cfg.colorize then return cfg.colorize(v) end
        if cfg.display then return cfg.display(v) end
        return v
    end

    function dd:SetValue(v)
        self.value = v
        if cfg.noAll then
            -- Always has a value, so no "active filter" highlight
            self.label:SetText(cfg.buttonText and cfg.buttonText(v) or Display(v))
        elseif v then
            self.label:SetText(cfg.colorize and cfg.colorize(v) or (GOLD .. Display(v) .. "|r"))
            SetBorder(self, STYLE.accent[1], STYLE.accent[2], STYLE.accent[3], 0.8)
        else
            self.label:SetText(GREY .. L(allText) .. "|r")
            SetBorder(self, STYLE.controlBorder[1], STYLE.controlBorder[2], STYLE.controlBorder[3], 1)
        end
    end

    local menu, rows

    local function BuildMenu()
        menu = CreateFrame("Frame", nil, D)
        menu:SetFrameStrata("FULLSCREEN_DIALOG")
        menu:SetFrameLevel(10)
        menu:EnableMouse(true)
        Skin(menu, STYLE.menuBg, STYLE.menuBorder)
        menu:SetPoint("TOPLEFT", dd, "BOTTOMLEFT", 0, -2)

        local entries = cfg.noAll and {} or { false }  -- false = "All"
        for _, v in ipairs(cfg.values()) do table.insert(entries, v) end

        local cols = math.max(1, cfg.cols or 1)
        local perCol = math.ceil(#entries / cols)
        rows = {}
        for i, value in ipairs(entries) do
            local col = math.floor((i - 1) / perCol)
            local rowIdx = (i - 1) % perCol
            local row = CreateFrame("Button", nil, menu)
            row:SetSize(MENU_COL_W - 4, MENU_ROW_H)
            row:SetPoint("TOPLEFT", menu, "TOPLEFT", 6 + col * MENU_COL_W, -6 - rowIdx * MENU_ROW_H)

            local hl = row:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints(row)
            hl:SetTexture(HIGHLIGHT_TEX)
            hl:SetBlendMode("ADD")

            row.check = row:CreateTexture(nil, "OVERLAY")
            row.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
            row.check:SetSize(14, 14)
            row.check:SetPoint("LEFT", 2, 0)

            row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.text:SetPoint("LEFT", 18, 0)
            row.text:SetPoint("RIGHT", -2, 0)
            row.text:SetJustifyH("LEFT")
            row.text:SetWordWrap(false)
            row.text:SetText(value and Display(value) or L(allText))

            row.value = value or nil
            row:SetScript("OnClick", function()
                dd:SetValue(row.value)
                CloseMenus()
                cfg.onSelect(row.value)
            end)
            rows[i] = row
        end
        local usedCols = math.ceil(#entries / perCol)
        menu:SetSize(8 + usedCols * MENU_COL_W, 12 + perCol * MENU_ROW_H)
        menu:Hide()
    end

    dd:SetScript("OnClick", function()
        CloseMenus()
        if not menu then BuildMenu() end
        for _, row in ipairs(rows) do
            row.check:SetShown(row.value == dd.value)
        end
        TT:Hide()
        menu:Show()
        openMenu = menu
        menuBlocker:Show()
    end)

    dd:SetValue(cfg.initial)
    Loc:OnReady(function() dd:SetValue(dd.value) end)
    return dd
end

-- =========================================================================
-- FILTER BAR (row 1: search, card types, spheres)
-- Every filter combines: a card must pass all of them.
-- =========================================================================
local filterToggles = {}

local function OnFiltersChanged()
    poolPage = 1
    CardTooltip_OnLeave()
    D:RefreshPool()
end

local function CreateToggle(parent, w, label, rgb, getter, setter)
    local b = CreateFlatButton(parent, w, 24, label)
    b.label:SetJustifyH("CENTER")
    function b:Sync()
        if getter() then
            SetBg(b, rgb[1] * 0.22, rgb[2] * 0.22, rgb[3] * 0.22, 1)
            SetBorder(b, rgb[1], rgb[2], rgb[3], 0.9)
            b.label:SetAlpha(1)
        else
            SetBg(b, STYLE.controlBg[1], STYLE.controlBg[2], STYLE.controlBg[3], 1)
            SetBorder(b, STYLE.controlBorder[1], STYLE.controlBorder[2], STYLE.controlBorder[3], 1)
            b.label:SetAlpha(0.35)
        end
    end
    b:SetScript("OnClick", function()
        setter(not getter())
        b:Sync()
        OnFiltersChanged()
    end)
    b:Sync()
    table.insert(filterToggles, b)
    return b
end

-- Search box
local searchBox = CreateFrame("EditBox", nil, poolPanel)
searchBox:SetSize(170, 24)
searchBox:SetPoint("TOPLEFT", poolPanel, "TOPLEFT", 10, -10)
Skin(searchBox, STYLE.controlBg, STYLE.controlBorder, "control")
searchBox:SetFontObject(ChatFontNormal)
searchBox:SetAutoFocus(false)
searchBox:SetMaxLetters(40)
searchBox:SetTextInsets(8, 22, 0, 0)

local searchPlaceholder = searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
searchPlaceholder:SetPoint("LEFT", 8, 0)
Loc:Bind(searchPlaceholder, "db.searchPlaceholder")

local searchClear = CreateFrame("Button", nil, searchBox)
searchClear:SetSize(18, 18)
searchClear:SetPoint("RIGHT", -3, 0)
searchClear.text = searchClear:CreateFontString(nil, "OVERLAY", "GameFontDisable")
searchClear.text:SetPoint("CENTER", 0, 1)
searchClear.text:SetText("x")
searchClear:SetScript("OnEnter", function(self) self.text:SetFontObject("GameFontHighlight") end)
searchClear:SetScript("OnLeave", function(self) self.text:SetFontObject("GameFontDisable") end)
searchClear:SetScript("OnClick", function()
    searchBox:SetText("")
    searchBox:ClearFocus()
end)
searchClear:Hide()

local function UpdateSearchVisuals()
    local text = searchBox:GetText() or ""
    local focused = searchBox:HasFocus()
    searchPlaceholder:SetShown(text == "" and not focused)
    searchClear:SetShown(text ~= "")
    if focused or text ~= "" then
        SetBorder(searchBox, STYLE.accent[1], STYLE.accent[2], STYLE.accent[3], 0.8)
    else
        SetBorder(searchBox, STYLE.controlBorder[1], STYLE.controlBorder[2], STYLE.controlBorder[3], 1)
    end
end

searchBox:SetScript("OnTextChanged", function(self)
    local text = (self:GetText() or ""):gsub("^%s+", ""):gsub("%s+$", "")
    text = string.lower(text)
    UpdateSearchVisuals()
    if text ~= searchText then
        searchText = text
        OnFiltersChanged()
    end
end)
searchBox:SetScript("OnEditFocusGained", UpdateSearchVisuals)
searchBox:SetScript("OnEditFocusLost", UpdateSearchVisuals)
searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
searchBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

-- Card type toggles
local TYPE_DEFS = {
    { key = "Creature", label = "db.creatures" },
    { key = "Spell",    label = "db.spells" },
    { key = "Prayer",   label = "db.prayers" },
}
for n, def in ipairs(TYPE_DEFS) do
    local b = CreateToggle(poolPanel, 74, def.label, STYLE.accent,
        function() return typeOn[def.key] end,
        function(v) typeOn[def.key] = v end)
    b:SetPoint("TOPLEFT", poolPanel, "TOPLEFT", 192 + (n - 1) * 78, -10)
end

-- Sphere toggles (icons filled in on show, once Board.lua's symbols exist)
local sphereToggles = {}
for n, key in ipairs(SPHERE_ORDER) do
    local rgb = SPHERE_RGB[key]
    local b = CreateToggle(poolPanel, 44, RGBHex(rgb) .. key .. "|r", rgb,
        function() return colorOn[key] end,
        function(v) colorOn[key] = v end)
    b:SetPoint("TOPLEFT", poolPanel, "TOPLEFT", 434 + (n - 1) * 49, -10)
    b.tooltipTitle = function() return RGBHex(rgb) .. TT:Def("symbol", key, "name") .. "|r" end
    b.tooltipText = function() return L("db.showHideSphere", TT:Def("symbol", key, "name")) end
    b.tooltipSymbol = key
    sphereToggles[key] = b
end

local function UpdateSphereToggleLabels()
    if not TTS.FormatSymbols then return end
    for key, b in pairs(sphereToggles) do
        b.label:SetText(Sym("{" .. key .. "}", 16))
    end
end

-- =========================================================================
-- FILTER BAR (row 2: class, zone, faction, creature type, keyword, sort, reset)
-- Class applies to spells only; zone, faction and creature type to creatures only.
-- =========================================================================
local classDD = CreateDropdown(poolPanel, 92, "db.allClasses", {
    values = BuildClassList,
    cols = 1,
    colorize = ClassColored,
    onSelect = function(v) classFilter = v; OnFiltersChanged() end,
})
classDD:SetPoint("TOPLEFT", poolPanel, "TOPLEFT", 10, -42)
classDD.tooltipTitle = "db.class"
classDD.tooltipText = "db.class.desc"

local zoneDD = CreateDropdown(poolPanel, 100, "db.allZones", {
    values = function() return BuildFieldList("zone") end,
    cols = 3,
    display = function(v) return Loc:Term("zone", v) end,
    onSelect = function(v) zoneFilter = v; OnFiltersChanged() end,
})
zoneDD:SetPoint("TOPLEFT", poolPanel, "TOPLEFT", 106, -42)
zoneDD.tooltipTitle = "db.zone"
zoneDD.tooltipText = "db.zone.desc"

local factionDD = CreateDropdown(poolPanel, 92, "db.allFactions", {
    values = function() return BuildFieldList("faction") end,
    cols = 2,
    display = function(v) return Loc:Term("faction", v) end,
    onSelect = function(v) factionFilter = v; OnFiltersChanged() end,
})
factionDD:SetPoint("TOPLEFT", poolPanel, "TOPLEFT", 210, -42)
factionDD.tooltipTitle = "db.faction"
factionDD.tooltipText = "db.faction.desc"

local creatureTypeDD = CreateDropdown(poolPanel, 100, "db.allCreatureTypes", {
    values = function() return BuildFieldList("creatureType") end,
    cols = 1,
    display = function(v) return Loc:Term("creatureType", v) end,
    onSelect = function(v) creatureTypeFilter = v; OnFiltersChanged() end,
})
creatureTypeDD:SetPoint("TOPLEFT", poolPanel, "TOPLEFT", 306, -42)
creatureTypeDD.tooltipTitle = "db.creatureType"
creatureTypeDD.tooltipText = "db.creatureType.desc"

Keyword.dd = CreateDropdown(poolPanel, 92, "db.allKeywords", {
    values = Keyword.List,
    cols = 1,
    display = Keyword.Name,
    onSelect = function(v) Keyword.value = v; OnFiltersChanged() end,
})
Keyword.dd:SetPoint("TOPLEFT", poolPanel, "TOPLEFT", 410, -42)
Keyword.dd.tooltipTitle = "db.keyword"
Keyword.dd.tooltipText = "db.keyword.desc"

local sortDD = CreateDropdown(poolPanel, 106, "", {
    values = function() return SORT_ORDER end,
    cols = 1,
    noAll = true,
    initial = sortMode,
    colorize = function(v) return SORT_LABEL[v] end,
    buttonText = function(v) return GREY .. L("db.sortPrefix") .. "|r " .. SORT_LABEL[v] end,
    onSelect = function(v)
        if not v or v == sortMode then return end
        sortMode = v
        poolPage = 1
        CardTooltip_OnLeave()
        D:RefreshAll()
    end,
})
sortDD:SetPoint("TOPLEFT", poolPanel, "TOPLEFT", 506, -42)
sortDD.tooltipTitle = "db.sortOrder"
sortDD.tooltipText = "db.sortOrder.desc"

local resetFiltersBtn = CreatePanelButton(poolPanel, 58, 24, "db.reset")
resetFiltersBtn:SetPoint("TOPLEFT", poolPanel, "TOPLEFT", 616, -42)
resetFiltersBtn.tooltipTitle = "db.resetFilters"
resetFiltersBtn.tooltipText = "db.resetFilters.desc"
resetFiltersBtn.label:SetJustifyH("CENTER")
resetFiltersBtn:SetScript("OnClick", function()
    for k in pairs(colorOn) do colorOn[k] = true end
    for k in pairs(typeOn) do typeOn[k] = true end
    classFilter = nil
    zoneFilter = nil
    factionFilter = nil
    creatureTypeFilter = nil
    Keyword.value = nil
    classDD:SetValue(nil)
    zoneDD:SetValue(nil)
    factionDD:SetValue(nil)
    creatureTypeDD:SetValue(nil)
    Keyword.dd:SetValue(nil)
    CloseMenus()
    for _, b in ipairs(filterToggles) do b:Sync() end
    searchBox:SetText("")   -- triggers a refresh if the search changed
    searchBox:ClearFocus()
    searchText = ""
    OnFiltersChanged()
end)

-- =========================================================================
-- CARD GRID (pool)
-- =========================================================================
local gridFrame = CreateFrame("Frame", nil, poolPanel)
gridFrame:SetPoint("TOPLEFT", poolPanel, "TOPLEFT", 10, -76)
gridFrame:SetSize(GRID_COLS * TILE_W + (GRID_COLS - 1) * TILE_GAP_X, GRID_ROWS * TILE_H + (GRID_ROWS - 1) * TILE_GAP_Y)

local poolEmptyText = gridFrame:CreateFontString(nil, "OVERLAY", "GameFontDisable")
poolEmptyText:SetPoint("CENTER")
Loc:Bind(poolEmptyText, "db.noMatch")
poolEmptyText:Hide()

local function ChangePoolPage(delta)
    local pages = math.max(1, math.ceil(#cardPoolKeys / TILES_PER_PAGE))
    local newPage = math.max(1, math.min(pages, poolPage + delta))
    if newPage ~= poolPage then
        poolPage = newPage
        CardTooltip_OnLeave()
        D:RefreshPool()
    end
end

gridFrame:EnableMouseWheel(true)
gridFrame:SetScript("OnMouseWheel", function(_, delta) ChangePoolPage(-delta) end)

local tiles = {}

-- Each grid slot shows the card in Board.lua's design, with its name and cost
-- above it (as on the board) and the copy pips below.
local CARD_W, CARD_H = 78, 110
local CARD_TOP = 30          -- room above the card for its cost and name

local function CreateTile(index)
    local t = CreateFrame("Frame", nil, gridFrame)
    t:SetSize(TILE_W, TILE_H)
    local col = (index - 1) % GRID_COLS
    local row = math.floor((index - 1) / GRID_COLS)
    t:SetPoint("TOPLEFT", gridFrame, "TOPLEFT", col * (TILE_W + TILE_GAP_X), -row * (TILE_H + TILE_GAP_Y))

    local card = CreateCardDesign(t, CARD_W, CARD_H, nil)
    card:SetSize(CARD_W, CARD_H)
    card:ClearAllPoints()
    card:SetPoint("TOP", t, "TOP", 0, -CARD_TOP)
    card:SetFrameStrata(D:GetFrameStrata())
    card:EnableMouse(false)
    if card.model then card.model:EnableMouse(false) end
    if card.overlay then card.overlay:EnableMouse(false) end
    if card.title then card.title:SetWordWrap(false) end
    card:Show()
    t.card = card

    -- Newly acquired: a pulsing gold glow behind the card
    t.newGlow = CreateFrame("Frame", nil, t)
    t.newGlow:SetPoint("TOPLEFT", card, "TOPLEFT", -5, 5)
    t.newGlow:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", 5, -5)
    t.newGlow:SetFrameLevel(math.max(0, card:GetFrameLevel() - 1))
    local glowTex = t.newGlow:CreateTexture(nil, "BACKGROUND")
    glowTex:SetAllPoints(t.newGlow)
    glowTex:SetColorTexture(1, 0.82, 0, 1)
    if t.newGlow.CreateAnimationGroup then
        local pulse = t.newGlow:CreateAnimationGroup()
        local fade = pulse:CreateAnimation("Alpha")
        fade:SetFromAlpha(0.9)
        fade:SetToAlpha(0.3)
        fade:SetDuration(0.8)
        pulse:SetLooping("BOUNCE")
        t.newPulse = pulse
    end
    t.newGlow:Hide()

    -- Click target above the card (so the card frame's own mouse handling never interferes)
    local hit = CreateFrame("Button", nil, t)
    hit:SetAllPoints(t)
    hit:SetFrameLevel(card:GetFrameLevel() + 30)
    hit.hint = "db.poolHint"
    t.hit = hit

    -- Dimmed when the card can't be added right now
    t.dim = hit:CreateTexture(nil, "ARTWORK")
    t.dim:SetAllPoints(card)
    t.dim:SetColorTexture(0, 0, 0, 0.55)
    t.dim:Hide()

    t.hover = hit:CreateTexture(nil, "OVERLAY")
    t.hover:SetAllPoints(card)
    t.hover:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    t.hover:SetBlendMode("ADD")
    t.hover:Hide()

    -- "NEW" badge in the card's top corner
    t.newBadge = hit:CreateTexture(nil, "OVERLAY", nil, 6)
    t.newBadge:SetColorTexture(0, 0, 0, 0.8)
    t.newBadge:SetSize(30, 13)
    t.newBadge:SetPoint("TOPRIGHT", card, "TOPRIGHT", -3, -3)
    t.newText = hit:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    t.newText:SetDrawLayer("OVERLAY", 7)
    t.newText:SetPoint("CENTER", t.newBadge, "CENTER", 0, 0)
    Loc:Bind(t.newText, "db.new")
    t.newText:SetTextColor(0.3, 1, 0.3)
    t.newBadge:Hide()
    t.newText:Hide()

    -- Copy pips: gold = in deck, grey = available, dark = not yet collected
    t.pips = {}
    local pipsW = 4 * 16 + 3 * 3
    for p = 1, 4 do
        local pip = hit:CreateTexture(nil, "OVERLAY")
        pip:SetSize(16, 5)
        pip:SetPoint("BOTTOMLEFT", t, "BOTTOMLEFT", math.floor((TILE_W - pipsW) / 2) + (p - 1) * 19, 4)
        t.pips[p] = pip
    end
    t.copyText = hit:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    t.copyText:SetPoint("BOTTOM", t, "BOTTOM", 0, 1)

    hit:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    hit:SetScript("OnClick", function(self, button)
        if not self.cardId then return end
        if TTS:TryLinkCard(self.cardId) then return end
        if button == "RightButton" then
            D:RemoveCardFromDeck(self.cardId)
        else
            D:AddCardToDeck(self.cardId)
        end
    end)
    hit:SetScript("OnEnter", function(self)
        t.hover:Show()
        CardTooltip_OnEnter(self)
    end)
    hit:SetScript("OnLeave", function()
        t.hover:Hide()
        CardTooltip_OnLeave()
    end)
    hit:EnableMouseWheel(true)
    hit:SetScript("OnMouseWheel", function(_, delta) ChangePoolPage(-delta) end)

    t:Hide()
    return t
end

-- Built on first use: Board.lua's card frame doesn't exist yet when this file loads
local function EnsureTiles()
    if #tiles > 0 then return end
    for i = 1, TILES_PER_PAGE do
        tiles[i] = CreateTile(i)
    end
end

function D:RefreshCardText()
    for _, t in ipairs(tiles) do
        if t:IsShown() and t.cardId and TTS.Cards and TTS.Cards[t.cardId] then
            PrintCardRules(t.card, TTS.Cards[t.cardId])
        end
    end
end

local function UpdateTileState(t, deck)
    local id = t.cardId
    local card = id and TTS.Cards and TTS.Cards[id]
    if not card then return end

    local inDeck = (deck and deck.cards and deck.cards[id]) or 0
    local limit = GetCopyLimit(id, card)
    if limit == nil then
        for p = 1, 4 do t.pips[p]:Hide() end
        t.copyText:SetText(inDeck > 0 and L("db.inDeck", GOLD .. inDeck .. "|r") or (GREY .. L("db.unlimited") .. "|r"))
        t.copyText:Show()
    else
        t.copyText:Hide()
        for p = 1, 4 do
            local pip = t.pips[p]
            if p <= inDeck then
                pip:SetColorTexture(1, 0.82, 0, 1)
            elseif p <= limit then
                pip:SetColorTexture(0.45, 0.45, 0.48, 1)
            else
                pip:SetColorTexture(0.18, 0.18, 0.20, 1)
            end
            pip:Show()
        end
    end

    t.dim:SetShown(CheckAdd(id, card, deck) ~= nil)
end

local function UpdateTile(t, id, card, deck)
    t.cardId = id
    t.hit.cardId = id
    -- Repainting resets creature models, so only do it when the card changes
    if t.paintedId ~= id then
        PaintCardFrame(t.card, card, 12)
        t.paintedId = id
    end
    PrintCardRules(t.card, card)
    UpdateTileState(t, deck)

    local isNew = TTS:IsCardNew(id)
    t.newGlow:SetShown(isNew)
    t.newBadge:SetShown(isNew)
    t.newText:SetShown(isNew)
    if t.newPulse then
        if isNew then t.newPulse:Play() else t.newPulse:Stop() end
    end
end

-- Pager
local poolCountText = poolPanel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
poolCountText:SetPoint("TOPLEFT", poolPanel, "TOPLEFT", 12, -568)

local nextBtn = CreatePanelButton(poolPanel, 28, 24, ">")
nextBtn:SetPoint("TOPRIGHT", poolPanel, "TOPRIGHT", -10, -562)
nextBtn.label:SetJustifyH("CENTER")
nextBtn:SetScript("OnClick", function() ChangePoolPage(1) end)

local pageText = poolPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
pageText:SetPoint("RIGHT", nextBtn, "LEFT", -8, 0)
pageText:SetWidth(84)
pageText:SetJustifyH("CENTER")

local prevBtn = CreatePanelButton(poolPanel, 28, 24, "<")
prevBtn:SetPoint("RIGHT", pageText, "LEFT", -8, 0)
prevBtn.label:SetJustifyH("CENTER")
prevBtn:SetScript("OnClick", function() ChangePoolPage(-1) end)

-- =========================================================================
-- COLLECTION PROGRESS (bottom-left)
-- Collected = at least 1 copy of a creature card, Mastered = all 4 copies,
-- and the same for Hearthstones (the innkeepers' gift prayers).
-- =========================================================================
local collectionLabel = D:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
collectionLabel:SetPoint("BOTTOMLEFT", D, "BOTTOMLEFT", 16, 13)
collectionLabel:SetJustifyH("LEFT")

local function UpdateCollectionProgress()
    local score, collected, mastered, total, hCollected, hMastered, hTotal = TTS:GetCollectionScore()
    -- In the order of the score: (Hearthstones + creatures collected) x (Hearthstones + creatures mastered + 1)
    collectionLabel:SetText(L("db.collection", TTS:ColoredCount(hCollected, hTotal),
        TTS:ColoredCount(collected, total), TTS:ColoredCount(hMastered, hTotal),
        TTS:ColoredCount(mastered, total), TTS:ColoredScore(score)))
end

-- =========================================================================
-- DECK TABS (rename with right-click)
-- =========================================================================
local deckTabs = {}

local function UpdateDeckTabs()
    for i, tab in ipairs(deckTabs) do
        local deck = TTS_SavedDecks and TTS_SavedDecks[i]
        local count = 0
        if deck and deck.cards then
            for _, qty in pairs(deck.cards) do count = count + qty end
        end
        local name = (deck and deck.name) or DefaultDeckName(i)
        tab.countText:SetText(count)
        if i == TTS_ActiveDeckIndex then
            tab:LockHighlight()
            tab.label:SetText(GOLD .. name .. "|r")
        else
            tab:UnlockHighlight()
            tab.label:SetText("|cFFBBBBBB" .. name .. "|r")
        end
    end
end

local pendingRenameIndex = nil

local function ApplyDeckRename(index, text)
    TTS:EnsureDeckSlots()
    local deck = index and TTS_SavedDecks[index]
    if not deck then return end
    text = tostring(text or ""):gsub("|", ""):gsub("^%s+", ""):gsub("%s+$", "")
    deck.name = (text ~= "") and text or DefaultDeckName(index)
    UpdateDeckTabs()
end

StaticPopupDialogs["TTS_RENAME_DECK"] = {
    text = L("db.renameDeck"),
    button1 = ACCEPT or "Accept",
    button2 = CANCEL or "Cancel",
    hasEditBox = true,
    maxLetters = 24,
    OnShow = function(self)
        local eb = self.editBox or self.EditBox
        local deck = TTS_SavedDecks and pendingRenameIndex and TTS_SavedDecks[pendingRenameIndex]
        if eb then
            eb:SetText((deck and deck.name) or "")
            eb:SetFocus()
            eb:HighlightText()
        end
    end,
    OnAccept = function(self)
        local eb = self.editBox or self.EditBox
        if eb then ApplyDeckRename(pendingRenameIndex, eb:GetText()) end
    end,
    EditBoxOnEnterPressed = function(self)
        ApplyDeckRename(pendingRenameIndex, self:GetText())
        self:GetParent():Hide()
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
Loc:OnReady(function() StaticPopupDialogs["TTS_RENAME_DECK"].text = L("db.renameDeck") end)

local TAB_W = math.floor((LIST_W - (TTS.MAX_DECK_SLOTS - 1) * 7) / TTS.MAX_DECK_SLOTS)

for i = 1, TTS.MAX_DECK_SLOTS do
    local tab = CreatePanelButton(deckPanel, TAB_W, 26, "")
    tab:SetPoint("TOPLEFT", deckPanel, "TOPLEFT", 10 + (i - 1) * (TAB_W + 7), -10)

    tab.countText = tab:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    tab.countText:SetPoint("RIGHT", -7, 0)

    -- Own name text: the button template re-anchors its built-in text when pressed
    tab.label = tab:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    tab.label:SetPoint("LEFT", 9, 0)
    tab.label:SetPoint("RIGHT", tab.countText, "LEFT", -4, 0)
    tab.label:SetJustifyH("LEFT")
    tab.label:SetWordWrap(false)

    tab.tooltipTitle = function() return L("db.deckSlot", i) end
    tab.tooltipText = "db.deckSlot.desc"

    tab:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    tab:SetScript("OnClick", function(_, button)
        TTS:EnsureDeckSlots()
        if button == "RightButton" then
            CloseMenus()
            TT:Hide()
            pendingRenameIndex = i
            StaticPopup_Show("TTS_RENAME_DECK")
            return
        end
        if TTS_ActiveDeckIndex == i then return end
        TTS_ActiveDeckIndex = i
        CardTooltip_OnLeave()
        D:RefreshDeck()
        DEFAULT_CHAT_FRAME:AddMessage(L("db.loadedDeck", TTS_SavedDecks[i].name))
    end)
    deckTabs[i] = tab
end

-- =========================================================================
-- DECK STATUS ROW (card count + Clear Deck)
-- =========================================================================
local countLabel = deckPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
countLabel:SetPoint("TOPLEFT", deckPanel, "TOPLEFT", 12, -48)

local statusHint = deckPanel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
statusHint:SetPoint("LEFT", countLabel, "RIGHT", 8, -1)

local clearBtn = CreatePanelButton(deckPanel, 84, 22, "db.clearDeck")
clearBtn:SetPoint("TOPRIGHT", deckPanel, "TOPRIGHT", -10, -43)
clearBtn.label:SetJustifyH("CENTER")
clearBtn:SetScript("OnClick", function()
    D:ConfirmClearDeck()
end)

local HeroBtns = {}   -- the Hero button (one local: this file is at the 200-locals limit)

-- Reopens the hero card's milestone choice after "Decide later" (shown while one is waiting)
HeroBtns.choice = CreatePanelButton(deckPanel, 60, 22, "db.heroChoice")
HeroBtns.choice:SetPoint("RIGHT", clearBtn, "LEFT", -6, 0)
HeroBtns.choice.label:SetJustifyH("CENTER")
HeroBtns.choice.tooltipTitle = "db.heroChoiceTip"
HeroBtns.choice:SetScript("OnClick", function()
    if TTS.HeroChoice then TTS.HeroChoice:Open() end
end)
HeroBtns.choice:Hide()

-- A pulsing gold glow while it is shown, so a waiting choice gets noticed
do
    local glow = HeroBtns.choice:CreateTexture(nil, "OVERLAY")
    glow:SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
    glow:SetTexCoord(0, 0.625, 0, 0.6875)
    glow:SetBlendMode("ADD")
    glow:SetVertexColor(1, 0.82, 0.2)
    glow:SetPoint("TOPLEFT", -4, 4)
    glow:SetPoint("BOTTOMRIGHT", 4, -4)
    local pulse = glow:CreateAnimationGroup()
    pulse:SetLooping("BOUNCE")
    local fade = pulse:CreateAnimation("Alpha")
    fade:SetFromAlpha(0.15)
    fade:SetToAlpha(1)
    fade:SetDuration(0.8)
    fade:SetSmoothing("IN_OUT")
    HeroBtns.choice:HookScript("OnShow", function() pulse:Play() end)
    HeroBtns.choice:HookScript("OnHide", function() pulse:Stop() end)
end

function HeroBtns.Update()
    HeroBtns.choice:SetShown(TTS.Hero and TTS.HeroChoice and TTS.Hero:PendingChoices() > 0 or false)
end

local listDivider = deckPanel:CreateTexture(nil, "ARTWORK")
listDivider:SetPoint("TOPLEFT", deckPanel, "TOPLEFT", 10, -70)
listDivider:SetPoint("TOPRIGHT", deckPanel, "TOPRIGHT", -10, -70)
listDivider:SetHeight(1)
listDivider:SetColorTexture(1, 0.82, 0, 0.25)

-- =========================================================================
-- DECK LIST
-- Grouped Creatures / Spells / Prayers. Flows into two columns when needed so
-- a full deck is always visible without scrolling.
-- =========================================================================
local listArea = CreateFrame("Frame", nil, deckPanel)
listArea:SetPoint("TOPLEFT", deckPanel, "TOPLEFT", 10, -76)
listArea:SetSize(LIST_W, LIST_H)

local deckEmptyText = listArea:CreateFontString(nil, "OVERLAY", "GameFontDisable")
deckEmptyText:SetPoint("CENTER", 0, 20)
deckEmptyText:SetWidth(LIST_W - 40)
Loc:Bind(deckEmptyText, "db.deckEmpty")

local GROUP_ORDER = { "Creature", "Spell", "Prayer" }
-- Deck list group headers: db.group.<group>
local GROUP_LABEL = setmetatable({}, { __index = function(_, group) return L("db.group." .. group) end })

local deckRows = {}

local function GetDeckRow(i)
    if deckRows[i] then return deckRows[i] end

    local r = CreateFrame("Button", nil, listArea)

    r.rowHl = r:CreateTexture(nil, "HIGHLIGHT")
    r.rowHl:SetAllPoints(r)
    r.rowHl:SetTexture(HIGHLIGHT_TEX)
    r.rowHl:SetBlendMode("ADD")

    -- Colour pips at the left edge: one stripe per colour in the card's cost
    r.stripes = {}
    for k = 1, #SPHERE_ORDER do
        local s = r:CreateTexture(nil, "ARTWORK")
        s:SetPoint("TOPLEFT", (k - 1) * 4, -1)
        s:SetPoint("BOTTOMLEFT", (k - 1) * 4, 1)
        s:SetWidth(3)
        s:Hide()
        r.stripes[k] = s
    end
    r.stripe = r.stripes[1]

    r.count = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    r.count:SetPoint("LEFT", 6, 0)
    r.count:SetWidth(20)
    r.count:SetJustifyH("RIGHT")

    r.cost = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    r.cost:SetPoint("RIGHT", -4, 0)
    r.cost:SetJustifyH("RIGHT")

    r.name = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    r.name:SetPoint("LEFT", r.count, "RIGHT", 6, 0)
    r.name:SetPoint("RIGHT", r.cost, "LEFT", -4, 0)
    r.name:SetJustifyH("LEFT")
    r.name:SetWordWrap(false)

    r.header = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    r.header:SetPoint("BOTTOMLEFT", 2, 2)

    r.headerCount = r:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    r.headerCount:SetPoint("BOTTOMRIGHT", -4, 2)

    r.headerLine = r:CreateTexture(nil, "ARTWORK")
    r.headerLine:SetPoint("BOTTOMLEFT", 0, 0)
    r.headerLine:SetPoint("BOTTOMRIGHT", 0, 0)
    r.headerLine:SetHeight(1)
    r.headerLine:SetColorTexture(1, 0.82, 0, 0.30)

    r.hint = "db.deckRowHint"

    r:SetScript("OnEnter", function(self)
        if self.cardId then CardTooltip_OnEnter(self) end
    end)
    r:SetScript("OnLeave", CardTooltip_OnLeave)
    r:SetScript("OnClick", function(self)
        if not self.cardId then return end
        if TTS:TryLinkCard(self.cardId) then return end
        D:RemoveCardFromDeck(self.cardId)
        -- Rows shift after a removal, so refresh what's under the cursor
        if self:IsShown() and self.cardId and self:IsMouseOver() then
            CardTooltip_OnEnter(self)
        else
            CardTooltip_OnLeave()
        end
    end)

    deckRows[i] = r
    return r
end

local function SetupHeaderRow(r, group, count)
    r.cardId = nil
    r:EnableMouse(false)
    for _, s in ipairs(r.stripes) do s:Hide() end
    r.count:Hide()
    r.cost:Hide()
    r.name:Hide()
    r.header:SetText(GROUP_LABEL[group])
    r.header:Show()
    if group == "Spell" then
        local color = (count >= TTS.MAX_DECK_SPELLS) and GOLD or ""
        r.headerCount:SetText(color .. count .. " / " .. TTS.MAX_DECK_SPELLS .. ((color ~= "") and "|r" or ""))
    else
        r.headerCount:SetText(count)
    end
    r.headerCount:Show()
    r.headerLine:Show()
end

local function SetupCardRow(r, cardId, card, count)
    r.cardId = cardId
    r:EnableMouse(true)
    -- One pip per colour in the cost (in sphere order); the card's colour if its cost has none
    local colors = {}
    for _, col in ipairs(SPHERE_ORDER) do
        if card.cost and card.cost:find("{" .. col .. "}", 1, true) then table.insert(colors, col) end
    end
    if #colors == 0 then colors[1] = card.color end
    for k, s in ipairs(r.stripes) do
        if colors[k] ~= nil or k == 1 then
            local rgb = SPHERE_RGB[colors[k]] or NEUTRAL_RGB
            s:SetColorTexture(rgb[1], rgb[2], rgb[3], 0.9)
            s:Show()
        else
            s:Hide()
        end
    end
    r.count:SetText(count .. "x")
    r.count:Show()
    if card.cost and card.cost ~= "" then
        r.cost:SetText(Sym(card.cost, 12))
    else
        r.cost:SetText("")
    end
    r.cost:Show()
    r.name:SetText((TTS:CardName(card) or cardId) .. SortSuffix(card))
    r.name:Show()
    r.header:Hide()
    r.headerCount:Hide()
    r.headerLine:Hide()
end

-- =========================================================================
-- DECK STATS (mana curve + sphere distribution, under the deck list)
-- Both charts count every non-Prayer card in the active deck.
-- =========================================================================
local statsFrame = CreateFrame("Frame", "TTS_DeckStatsFrame", deckPanel)
statsFrame:SetPoint("BOTTOMLEFT", deckPanel, "BOTTOMLEFT", 10, 10)
statsFrame:SetSize(LIST_W, 118)
Skin(statsFrame, { 0.02, 0.02, 0.02, 0.6 }, STYLE.panelBorder)

local statsDivider = statsFrame:CreateTexture(nil, "ARTWORK")
statsDivider:SetPoint("TOPLEFT", statsFrame, "TOPLEFT", 200, -8)
statsDivider:SetPoint("BOTTOMLEFT", statsFrame, "BOTTOMLEFT", 200, 24)
statsDivider:SetWidth(1)
statsDivider:SetColorTexture(1, 0.82, 0, 0.25)

local deckSummary = statsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
deckSummary:SetPoint("BOTTOMLEFT", statsFrame, "BOTTOMLEFT", 10, 7)

local chartsNote = statsFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
chartsNote:SetPoint("BOTTOMRIGHT", statsFrame, "BOTTOMRIGHT", -8, 7)
Loc:Bind(chartsNote, "db.prayersNotCharted")

local BAR_BASE_Y = 36
local BAR_MAX_H  = 48

-- Mana curve
local CURVE_COLUMNS = 8      -- mana values 0..7+
local CURVE_BAR_W   = 16
local CURVE_BAR_GAP = 7

local curveFrame = CreateFrame("Frame", "TTS_ManaCurveFrame", statsFrame)
curveFrame:SetPoint("TOPLEFT", statsFrame, "TOPLEFT", 0, 0)
curveFrame:SetSize(200, 118)

local curveTitle = curveFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
curveTitle:SetPoint("TOPLEFT", curveFrame, "TOPLEFT", 10, -8)
Loc:Bind(curveTitle, "db.manaCurve")

local curveAvg = curveFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
curveAvg:SetPoint("TOPRIGHT", curveFrame, "TOPRIGHT", -10, -8)

local curveBars, curveCounts = {}, {}
for m = 0, CURVE_COLUMNS - 1 do
    local x = 10 + m * (CURVE_BAR_W + CURVE_BAR_GAP)

    local track = curveFrame:CreateTexture(nil, "BACKGROUND", nil, 1)
    track:SetColorTexture(0, 0, 0, 0.35)
    track:SetSize(CURVE_BAR_W, BAR_MAX_H)
    track:SetPoint("BOTTOMLEFT", curveFrame, "BOTTOMLEFT", x, BAR_BASE_Y)

    local bar = curveFrame:CreateTexture(nil, "ARTWORK")
    bar:SetTexture(BAR_TEX)
    bar:SetVertexColor(0.30, 0.60, 1.00, 0.95)
    bar:SetSize(CURVE_BAR_W, 1)
    bar:SetPoint("BOTTOMLEFT", curveFrame, "BOTTOMLEFT", x, BAR_BASE_Y)
    curveBars[m] = bar

    local cnt = curveFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    cnt:SetPoint("BOTTOM", bar, "TOP", 0, 1)
    curveCounts[m] = cnt

    local lbl = curveFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    lbl:SetPoint("TOP", track, "BOTTOM", 0, -3)
    lbl:SetText(m == CURVE_COLUMNS - 1 and (m .. "+") or tostring(m))
end

function D:UpdateManaCurve(deck)
    local buckets = {}
    for m = 0, CURVE_COLUMNS - 1 do buckets[m] = 0 end
    local spellCount, cmcSum = 0, 0
    local nCreature, nSpell, nPrayer = 0, 0, 0

    if deck and deck.cards then
        for id, count in pairs(deck.cards) do
            local c = TTS.Cards and TTS.Cards[id]
            if c and count > 0 then
                local group = GetTypeGroup(c)
                if group == "Prayer" then
                    nPrayer = nPrayer + count
                else
                    if group == "Creature" then nCreature = nCreature + count else nSpell = nSpell + count end
                    local cmc = c.cmc or 0
                    local m = math.min(CURVE_COLUMNS - 1, cmc)
                    buckets[m] = buckets[m] + count
                    spellCount = spellCount + count
                    cmcSum = cmcSum + cmc * count
                end
            end
        end
    end

    local maxCount = 1
    for m = 0, CURVE_COLUMNS - 1 do
        if buckets[m] > maxCount then maxCount = buckets[m] end
    end
    for m = 0, CURVE_COLUMNS - 1 do
        local n = buckets[m]
        if n > 0 then
            curveBars[m]:SetHeight(math.max(2, math.floor(n / maxCount * BAR_MAX_H)))
            curveBars[m]:Show()
            curveCounts[m]:SetText(n)
        else
            curveBars[m]:SetHeight(1)
            curveBars[m]:Hide()
            curveCounts[m]:SetText("")
        end
    end

    local avg = spellCount > 0 and (cmcSum / spellCount) or 0
    curveAvg:SetText(L("db.avg", avg))
    deckSummary:SetText(L("db.summary", nCreature, nSpell, nPrayer))
end

-- Sphere distribution
local COLOR_BAR_W   = 18
local COLOR_BAR_GAP = 8

local colorFrame = CreateFrame("Frame", "TTS_ColorDistFrame", statsFrame)
colorFrame:SetPoint("TOPLEFT", statsFrame, "TOPLEFT", 200, 0)
colorFrame:SetSize(LIST_W - 200, 118)

local colorTitle = colorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
colorTitle:SetPoint("TOPLEFT", colorFrame, "TOPLEFT", 10, -8)
Loc:Bind(colorTitle, "db.colours")

local colorTotal = colorFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
colorTotal:SetPoint("TOPRIGHT", colorFrame, "TOPRIGHT", -8, -8)

local colorBars, colorCounts, colorLabels = {}, {}, {}
for i, col in ipairs(SPHERE_ORDER) do
    local x = 10 + (i - 1) * (COLOR_BAR_W + COLOR_BAR_GAP)
    local rgb = SPHERE_RGB[col]

    local track = colorFrame:CreateTexture(nil, "BACKGROUND", nil, 1)
    track:SetColorTexture(0, 0, 0, 0.35)
    track:SetSize(COLOR_BAR_W, BAR_MAX_H)
    track:SetPoint("BOTTOMLEFT", colorFrame, "BOTTOMLEFT", x, BAR_BASE_Y)

    local bar = colorFrame:CreateTexture(nil, "ARTWORK")
    bar:SetTexture(BAR_TEX)
    bar:SetVertexColor(rgb[1], rgb[2], rgb[3], 0.95)
    bar:SetSize(COLOR_BAR_W, 1)
    bar:SetPoint("BOTTOMLEFT", colorFrame, "BOTTOMLEFT", x, BAR_BASE_Y)
    colorBars[col] = bar

    local cnt = colorFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    cnt:SetPoint("BOTTOM", bar, "TOP", 0, 1)
    colorCounts[col] = cnt

    local lbl = colorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("TOP", track, "BOTTOM", 0, -2)
    lbl:SetText(RGBHex(rgb) .. col .. "|r")
    colorLabels[col] = lbl
end

function D:UpdateColorDistribution(deck)
    local counts = { W = 0, U = 0, B = 0, R = 0, G = 0 }
    local total = 0

    if deck and deck.cards then
        for id, count in pairs(deck.cards) do
            local c = TTS.Cards and TTS.Cards[id]
            if c and count > 0 and GetTypeGroup(c) ~= "Prayer" and counts[c.color] then
                counts[c.color] = counts[c.color] + count
                total = total + count
            end
        end
    end

    local maxCount = 1
    for _, col in ipairs(SPHERE_ORDER) do
        if counts[col] > maxCount then maxCount = counts[col] end
    end

    for _, col in ipairs(SPHERE_ORDER) do
        local n = counts[col]
        if TTS.FormatSymbols then
            colorLabels[col]:SetText(Sym("{" .. col .. "}", 12))
        end
        if n > 0 then
            colorBars[col]:SetHeight(math.max(2, math.floor(n / maxCount * BAR_MAX_H)))
            colorBars[col]:Show()
            colorCounts[col]:SetText(n)
        else
            colorBars[col]:SetHeight(1)
            colorBars[col]:Hide()
            colorCounts[col]:SetText("")
        end
    end

    colorTotal:SetText(L("db.nCards", total))
end

-- =========================================================================
-- POOL & DECK LOGIC
-- =========================================================================
function D:RefreshAll()
    D:RefreshPool()
    D:RefreshDeck()
end

function D:RefreshPool()
    UpdateCollectionProgress()
    HeroBtns.Update()

    wipe(cardPoolKeys)
    for id, card in pairs(TTS.Cards or {}) do
        if CardPassesFilters(id, card) then
            table.insert(cardPoolKeys, id)
        end
    end
    table.sort(cardPoolKeys, CompareCards)

    -- Newly acquired cards first (still filtered; in sort order among themselves)
    local newFirst, rest = {}, {}
    for _, id in ipairs(cardPoolKeys) do
        table.insert(TTS:IsCardNew(id) and newFirst or rest, id)
    end
    wipe(cardPoolKeys)
    for _, id in ipairs(newFirst) do table.insert(cardPoolKeys, id) end
    for _, id in ipairs(rest) do table.insert(cardPoolKeys, id) end

    local total = #cardPoolKeys
    local pages = math.max(1, math.ceil(total / TILES_PER_PAGE))
    if poolPage > pages then poolPage = pages end
    if poolPage < 1 then poolPage = 1 end

    EnsureTiles()
    local deck = GetActiveDeck()
    for i = 1, TILES_PER_PAGE do
        local t = tiles[i]
        local id = cardPoolKeys[(poolPage - 1) * TILES_PER_PAGE + i]
        if id then
            t:Show()
            UpdateTile(t, id, TTS.Cards[id], deck)
        else
            t.cardId = nil
            t.hit.cardId = nil
            t.paintedId = nil
            t:Hide()
        end
    end

    poolEmptyText:SetShown(total == 0)
    poolCountText:SetText(total == 1 and L("db.oneCard") or L("db.nCards", total))
    pageText:SetText(L("db.page", poolPage, pages))
    SetButtonEnabled(prevBtn, poolPage > 1)
    SetButtonEnabled(nextBtn, poolPage < pages)
end

function D:RefreshDeck()
    local deck = GetActiveDeck()

    local groups = { Creature = {}, Spell = {}, Prayer = {} }
    local groupTotals = { Creature = 0, Spell = 0, Prayer = 0 }
    local totalCards = 0
    if deck and deck.cards then
        for id, count in pairs(deck.cards) do
            local c = TTS.Cards and TTS.Cards[id]
            if c and count > 0 then
                local g = GetTypeGroup(c)
                table.insert(groups[g], id)
                groupTotals[g] = groupTotals[g] + count
                totalCards = totalCards + count
            end
        end
    end

    local entries = {}
    for _, g in ipairs(GROUP_ORDER) do
        if #groups[g] > 0 then
            table.sort(groups[g], CompareCards)
            table.insert(entries, { header = g, count = groupTotals[g] })
            for _, id in ipairs(groups[g]) do
                table.insert(entries, { id = id, count = deck.cards[id] })
            end
        end
    end

    -- Layout: one column if it fits, otherwise two (never leave a header at the foot of column 1)
    local n = #entries
    local cols, perCol, rowH = 1, n, ROW_H
    if n > math.floor(LIST_H / ROW_H) then
        cols = 2
        perCol = math.ceil(n / 2)
        if entries[perCol] and entries[perCol].header then perCol = perCol - 1 end
        local tallest = math.max(perCol, n - perCol)
        rowH = math.min(ROW_H, math.floor(LIST_H / tallest))
    end
    local colW = (cols == 1) and LIST_W or math.floor((LIST_W - COL_GAP) / 2)

    for i, e in ipairs(entries) do
        local r = GetDeckRow(i)
        local col, idx = 0, i - 1
        if cols == 2 and i > perCol then
            col, idx = 1, i - perCol - 1
        end
        r:ClearAllPoints()
        r:SetSize(colW, rowH)
        r:SetPoint("TOPLEFT", listArea, "TOPLEFT", col * (colW + COL_GAP), -idx * rowH)
        if e.header then
            SetupHeaderRow(r, e.header, e.count)
        else
            SetupCardRow(r, e.id, TTS.Cards[e.id], e.count)
        end
        r:Show()
    end
    for i = n + 1, #deckRows do
        deckRows[i].cardId = nil
        deckRows[i]:Hide()
    end
    deckEmptyText:SetShown(n == 0)

    if totalCards >= 40 and totalCards <= 50 then
        countLabel:SetText(GREEN .. totalCards .. "|r" .. GREY .. L("db.of50") .. "|r")
        statusHint:SetText(GREEN .. L("db.legalSize") .. "|r")
    elseif totalCards > 50 then
        countLabel:SetText(RED .. totalCards .. "|r" .. GREY .. L("db.of50") .. "|r")
        statusHint:SetText(RED .. L("db.maxExceeded") .. "|r")
    else
        countLabel:SetText(RED .. totalCards .. "|r" .. GREY .. L("db.of50") .. "|r")
        statusHint:SetText(GREY .. L("db.needMore", 40 - totalCards) .. "|r")
    end
    SetButtonEnabled(clearBtn, totalCards > 0)

    D:UpdateManaCurve(deck)
    D:UpdateColorDistribution(deck)
    UpdateDeckTabs()

    -- Copy pips and availability on the visible pool tiles
    for _, t in ipairs(tiles) do
        if t:IsShown() and t.cardId then UpdateTileState(t, deck) end
    end

    if TTS.MainFrame and TTS.MainFrame.UpdatePlayState then
        TTS.MainFrame:UpdatePlayState()
    end
end

-- While queued in the waiting room at least one deck must stay playable (40-50 cards):
-- true (and a chat warning) if taking this deck to newCount cards would leave none
local function BreaksLastPlayableDeck(deck, newCount)
    if not (TTS.WaitingRoom and TTS.WaitingRoom.isQueued) then return false end
    if newCount >= 40 and newCount <= 50 then return false end
    if not TTS:IsDeckPlayable(deck) or TTS:PlayableDeckCount() > 1 then return false end
    DEFAULT_CHAT_FRAME:AddMessage(L("db.lastPlayableDeck"))
    return true
end

function D:AddCardToDeck(cardId)
    local card = TTS.Cards and TTS.Cards[cardId]
    if not card then return end

    local deck = GetActiveDeck()
    deck.cards = deck.cards or {}

    local err = CheckAdd(cardId, card, deck)
    if err then
        DEFAULT_CHAT_FRAME:AddMessage(err)
        return
    end
    if BreaksLastPlayableDeck(deck, TTS:DeckCardCount(deck) + 1) then return end

    deck.cards[cardId] = (deck.cards[cardId] or 0) + 1
    D:RefreshDeck()
end

function D:RemoveCardFromDeck(cardId)
    local deck = GetActiveDeck()
    if not deck or not deck.cards or not deck.cards[cardId] then return end
    if BreaksLastPlayableDeck(deck, TTS:DeckCardCount(deck) - 1) then return end
    deck.cards[cardId] = deck.cards[cardId] - 1
    if deck.cards[cardId] <= 0 then
        deck.cards[cardId] = nil
    end
    D:RefreshDeck()
end

function D:ClearDeck()
    local deck = GetActiveDeck()
    if not deck then return end
    if BreaksLastPlayableDeck(deck, 0) then return end
    deck.cards = {}
    D:RefreshDeck()
end

StaticPopupDialogs["TTS_CLEAR_DECK"] = {
    text = "%s",
    button1 = YES or "Yes",
    button2 = NO or "No",
    -- Still the deck that was asked about (the player may have switched tabs meanwhile)
    OnAccept = function(_, deck) if deck and deck == GetActiveDeck() then D:ClearDeck() end end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- The Clear Deck button asks first (an empty deck has nothing to lose)
function D:ConfirmClearDeck()
    local deck = GetActiveDeck()
    if not (deck and deck.cards and next(deck.cards)) then return end
    if BreaksLastPlayableDeck(deck, 0) then return end
    local popup = StaticPopup_Show("TTS_CLEAR_DECK", L("db.clearDeckConfirm", deck.name or ""))
    if popup then popup.data = deck end
end

-- =========================================================================
-- BOTTOM CONTROLS
-- Dev Unlock and Reset / Scan buttons disabled for release.
-- (If re-enabled, move them off the collection progress text at the bottom-left.)
-- =========================================================================
--[==[
local devBtn = CreateFrame("Button", nil, D, "UIPanelButtonTemplate")
devBtn:SetSize(115, 24)
devBtn:SetPoint("BOTTOMLEFT", 20, 18)
Loc:Bind(devBtn, "db.devUnlock")
devBtn:SetScript("OnClick", function()
    if TTS.BossTracker and TTS.BossTracker.UnlockAllBosses then
        TTS.BossTracker:UnlockAllBosses()
    else
        TTS_KilledBosses = TTS_KilledBosses or {}
        for cardId, card in pairs(TTS.Cards or {}) do
            if card.isBoss then TTS_KilledBosses[cardId] = 4 end
        end
        DEFAULT_CHAT_FRAME:AddMessage(L("db.devUnlocked"))
        D:RefreshAll()
    end
end)

local resetBtn = CreateFrame("Button", nil, D, "UIPanelButtonTemplate")
resetBtn:SetSize(115, 24)
resetBtn:SetPoint("LEFT", devBtn, "RIGHT", 6, 0)
Loc:Bind(resetBtn, "db.resetScan")
resetBtn:SetScript("OnClick", function()
    if TTS.BossTracker and TTS.BossTracker.ResetBosses then
        TTS.BossTracker:ResetBosses()
    else
        TTS_DevModeActive = false
        if TTS.BossTracker and TTS.BossTracker.ScanAllBosses then
            TTS_KilledBosses = {}
            TTS.BossTracker:ScanAllBosses()
        end
        D:RefreshAll()
    end
end)
]==]

-- =========================================================================
-- OPENING (blocked while a game is in progress or a deck is being picked for one;
-- allowed while queued, see BreaksLastPlayableDeck)
-- =========================================================================
local function InMatch()
    return (TTS.Engine and TTS.Engine.inMatch) or (TTS.DeckPicker and TTS.DeckPicker:IsPending())
end

local function PrintInMatchWarning()
    DEFAULT_CHAT_FRAME:AddMessage(L("db.noOpenInMatch"))
end

-- Use this instead of :Show(). Returns true if the Deckbuilder opened.
function D:TryOpen()
    if InMatch() then
        PrintInMatchWarning()
        return false
    end
    self:Show()
    return true
end

-- =========================================================================
-- EVENT HOOKS
-- =========================================================================
D:SetScript("OnShow", function()
    -- Safety net for any path that calls :Show() directly
    if InMatch() then
        PrintInMatchWarning()
        D:Hide()
        return
    end
    -- The hero card's level is only ever updated here, never during a match; each 10 levels
    -- reached asks for an upgrade or another copy
    -- (a choice waiting lights up the Hero button; UI\HeroChoice.lua)
    if TTS.Hero and not (TTS.HeroChoice and TTS.HeroChoice.reopening) then
        TTS.Hero:Snapshot()
    end
    UpdateSphereToggleLabels()
    UpdateSearchVisuals()
    D:RefreshPool()
    D:RefreshDeck()
end)

-- Chat notice for every class spell that unlocks at the level just reached
local function AnnounceSpellUnlocks(newLevel)
    local unlocked = {}
    for cardId in pairs(TTS.SPELL_UNLOCK_TIER) do
        if TTS:GetSpellUnlockLevel(cardId) == newLevel and TTS.Cards and TTS.Cards[cardId] then
            table.insert(unlocked, cardId)
        end
    end
    table.sort(unlocked)
    for _, cardId in ipairs(unlocked) do
        local card = TTS.Cards[cardId]
        TTS:MarkCardNew(cardId)
        local cardText = TTS.CardLink and TTS:CardLink(cardId) or ("|cFFFFD200" .. TTS:CardName(card) .. "|r")
        DEFAULT_CHAT_FRAME:AddMessage(L("db.levelUnlock", newLevel, cardText, card.class and ClassColored(card.class) or L("type.Spell")))
    end
end

-- Levelling up: announce new spells, and show them if the Deckbuilder is open
local levelWatcher = CreateFrame("Frame")
levelWatcher:RegisterEvent("PLAYER_LEVEL_UP")
levelWatcher:SetScript("OnEvent", function(self, event, newLevel)
    if type(newLevel) == "number" then
        AnnounceSpellUnlocks(newLevel)
    end
    -- UnitLevel can still report the old level during the event, so refresh a moment later
    if C_Timer and C_Timer.After then
        C_Timer.After(0.5, function() if D:IsShown() then D:RefreshAll() end end)
    elseif D:IsShown() then
        D:RefreshAll()
    end
end)

-- Saved size (scale), applied once the saved settings have loaded
local scaleLoader = CreateFrame("Frame")
scaleLoader:RegisterEvent("ADDON_LOADED")
scaleLoader:SetScript("OnEvent", function(self, event, addon)
    if addon ~= "ForeverCCG" then return end
    self:UnregisterAllEvents()
    local saved = TTS.Options and tonumber(TTS.Options:Get("deckBuilderScale"))
    if saved then
        D:SetScale(math.max(MIN_SCALE, math.min(MAX_SCALE, saved)))
    end
end)

D:SetScript("OnHide", function()
    CardTooltip_OnLeave()
    CloseMenus()
    searchBox:ClearFocus()
    StaticPopup_Hide("TTS_RENAME_DECK")
    -- Models may not survive the window being hidden, so force a reload next time
    for _, t in ipairs(tiles) do t.paintedId = nil end
    -- New cards have been seen: no longer marked new (not when the hero card's choice
    -- dialog only hides the Deckbuilder for a moment, UI\HeroChoice.lua)
    if not (TTS.HeroChoice and TTS.HeroChoice.hidingDeckbuilder) then
        TTS:ClearNewCards()
    end
    if TTS.MainFrame and TTS.MainFrame.UpdatePlayState then
        TTS.MainFrame:UpdatePlayState()
    end
end)