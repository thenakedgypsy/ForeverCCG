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
-- COLLECTION GUIDE
-- Which cards each zone and dungeon holds and how many copies of each the player has
-- (n/4). Names only: what a card does stays in the Deckbuilder. Three tabs (Zones,
-- Dungeons, Hearthstones); down the left the places of the tab with how many of their
-- cards are still short of 4/4, on the right the chosen place's cards.
-- A card belongs to its card.zone (denizens, solo rewards and Gear); dungeons are the
-- instances BossTracker knows (TTS.BossTracker:IsDungeonZone). The innkeepers' gift
-- prayers have no zone: the Hearthstones tab lists them by set (HEARTH_SETS).
-- Opened from the main window's Collection Guide button (MainFrame.lua).
-- =========================================================================
local G = {}
TTS.CollectionGuide = G

local MAX_COPIES = 4
local WIN_W, WIN_H = 640, 520
local NAV_W = 250
local TABS = { "zones", "dungeons", "hearths" }

-- The Hearthstones tab's sets, in this order (guide.hearth.<key>): the town innkeepers'
-- Hearthstones, the smaller towns' Dark Hearthstones, the capitals' pool (Cards\Core.lua)
local HEARTH_SETS = { "basic", "dark", "greater" }
local function HearthSet(card)
    if card.type ~= "Land" or not card.isGift then return nil end
    if card.giftPool then return "greater" end
    if card.bouncesPrayer then return "dark" end
    return "basic"
end
local ROW_H = 20
local GOLD = "|cFFFFD200"

local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil

-- =========================================================================
-- DATA
-- =========================================================================
local function Collectible(card)
    if not card.zone or card.isBeta or card.isToken then return false end
    return TTS:GetOwnedCopies(card) ~= nil
end

local function IsDungeon(zone)
    return TTS.BossTracker and TTS.BossTracker.IsDungeonZone and TTS.BossTracker:IsDungeonZone(zone) or false
end

-- Which place of a tab a card is in (a card.zone, or a hearth set), or nil
local function PlaceOf(card, tab)
    if tab == "hearths" then return HearthSet(card) end
    if Collectible(card) and (IsDungeon(card.zone) == (tab == "dungeons")) then return card.zone end
end

-- The places of a tab ("zones", "dungeons" or "hearths"): A-Z by their shown name, the
-- hearth sets in HEARTH_SETS order.
-- { zone, name, cards = { card... } (denizens in id order, Gear last), remaining (cards
-- short of 4/4), copiesLeft (copies still to collect across them all) }
local function Places(tab)
    local byZone = {}
    for _, card in pairs(TTS.Cards or {}) do
        local zone = PlaceOf(card, tab)
        if zone then
            local p = byZone[zone]
            if not p then
                local name = (tab == "hearths") and L("guide.hearth." .. zone) or Loc:Term("zone", zone)
                p = { zone = zone, name = name, cards = {}, remaining = 0, copiesLeft = 0 }
                byZone[zone] = p
            end
            table.insert(p.cards, card)
            local owned = math.min(MAX_COPIES, TTS:GetOwnedCopies(card) or 0)
            if owned < MAX_COPIES then p.remaining = p.remaining + 1 end
            p.copiesLeft = p.copiesLeft + (MAX_COPIES - owned)
        end
    end
    local list = {}
    for _, p in pairs(byZone) do
        table.sort(p.cards, function(a, b)
            local ga, gb = a.subType == "Gear", b.subType == "Gear"
            if ga ~= gb then return gb end
            return a.id < b.id
        end)
        table.insert(list, p)
    end
    if tab == "hearths" then
        local order = {}
        for i, key in ipairs(HEARTH_SETS) do order[key] = i end
        table.sort(list, function(a, b) return order[a.zone] < order[b.zone] end)
    else
        table.sort(list, function(a, b) return a.name < b.name end)
    end
    return list
end

-- Whether a card can have a foil: the denizens that drop from kills (BossTracker.lua)
local function CanFoil(card)
    return card.isMob and not card.isReward
end

-- n/4 in grey (none), white (some) or green (all)
local function CopiesText(n)
    local color = (n >= MAX_COPIES) and "|cFF33DD33" or (n == 0 and "|cFF888888" or "|cFFFFFFFF")
    return color .. "(" .. n .. "/" .. MAX_COPIES .. ")|r"
end

-- =========================================================================
-- WINDOW (built the first time it opens)
-- =========================================================================
local F
local tab = "zones"
local selected = {}   -- chosen place (card.zone, or hearth set) per tab
-- How the places are listed: "name" (A-Z; the hearth sets in their order) or "left"
-- (most copies left first), remembered in the options (guideSort)
local SORTS = { "name", "left" }
local sortBy = "name"
local places = {}

local function MakePanel(parent)
    local p = CreateFrame("Frame", nil, parent, backdropTemplate)
    p:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    p:SetBackdropColor(0.04, 0.04, 0.04, 0.70)
    p:SetBackdropBorderColor(0.60, 0.56, 0.48, 1)
    return p
end

-- A flat selectable row (the Rules window's tab look): gold wash and bar when selected
local function MakeRow(parent, w, h)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(w, h)
    b.sel = b:CreateTexture(nil, "BORDER")
    b.sel:SetAllPoints()
    b.sel:SetColorTexture(1, 0.82, 0, 0.16)
    b.bar = b:CreateTexture(nil, "ARTWORK")
    b.bar:SetPoint("TOPLEFT")
    b.bar:SetPoint("BOTTOMLEFT")
    b.bar:SetWidth(3)
    b.bar:SetColorTexture(1, 0.82, 0, 0.9)
    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.08)
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    b.text:SetPoint("LEFT", 10, 0)
    b.text:SetJustifyH("LEFT")
    b.text:SetWordWrap(false)
    b.count = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    b.count:SetPoint("RIGHT", -8, 0)
    b.count:SetJustifyH("RIGHT")
    b.text:SetPoint("RIGHT", b.count, "LEFT", -6, 0)
    return b
end

-- small: the tabs, in the small fonts so three fit side by side
local function Paint(b, on)
    b.sel:SetShown(on)
    b.bar:SetShown(on)
    if b.small then
        b.text:SetFontObject(on and "GameFontHighlightSmall" or "GameFontNormalSmall")
    else
        b.text:SetFontObject(on and "GameFontHighlight" or "GameFontNormal")
    end
end

local Refresh

local function Build()
    F = CreateFrame("Frame", "TTS_CollectionGuideFrame", UIParent, backdropTemplate)
    G.frame = F
    F:SetSize(WIN_W, WIN_H)
    F:SetPoint("CENTER")
    F:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    F:SetFrameStrata("DIALOG")
    F:SetToplevel(true)
    F:EnableMouse(true)
    F:SetMovable(true)
    F:RegisterForDrag("LeftButton")
    F:SetScript("OnDragStart", F.StartMoving)
    F:SetScript("OnDragStop", F.StopMovingOrSizing)
    F:Hide()
    tinsert(UISpecialFrames, "TTS_CollectionGuideFrame")   -- Escape closes it

    -- Header: dark strip with a gold line, the logo, then the title
    local bar = F:CreateTexture(nil, "ARTWORK")
    bar:SetPoint("TOPLEFT", 12, -12)
    bar:SetPoint("TOPRIGHT", -12, -12)
    bar:SetHeight(25)
    bar:SetColorTexture(0, 0, 0, 0.35)
    local line = F:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, 0)
    line:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, 0)
    line:SetHeight(1)
    line:SetColorTexture(1, 0.82, 0, 0.55)
    local logo = F:CreateTexture(nil, "OVERLAY")
    logo:SetSize(30 * 350 / 85, 30)
    logo:SetPoint("LEFT", bar, "LEFT", 2, 0)
    logo:SetTexture("Interface\\AddOns\\ForeverCCG\\Textures\\logo.png")
    local title = F:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", logo, "RIGHT", 8, 0)
    Loc:Bind(title, "guide.title")
    local close = CreateFrame("Button", nil, F, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)

    local footer = F:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    footer:SetPoint("BOTTOMRIGHT", F, "BOTTOMRIGHT", -20, 15)
    footer:SetText("Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy")

    -- Left: the two tabs, then the places of the chosen one
    local nav = MakePanel(F)
    nav:SetPoint("TOPLEFT", 14, -46)
    nav:SetPoint("BOTTOMLEFT", 14, 34)
    nav:SetWidth(NAV_W)

    F.tabs = {}
    local tabW = (NAV_W - 12 - (#TABS - 1) * 2) / #TABS
    for i, key in ipairs(TABS) do
        local b = MakeRow(nav, tabW, 26)
        b.small = true
        b:SetPoint("TOPLEFT", nav, "TOPLEFT", 6 + (i - 1) * (tabW + 2), -6)
        b.text:ClearAllPoints()
        b.text:SetPoint("CENTER")
        Loc:Bind(b.text, "guide." .. key)
        b:SetScript("OnClick", function() tab = key; Refresh(true) end)
        F.tabs[key] = b
    end
    local tabLine = nav:CreateTexture(nil, "ARTWORK")
    tabLine:SetPoint("TOPLEFT", 8, -36)
    tabLine:SetPoint("TOPRIGHT", -8, -36)
    tabLine:SetHeight(1)
    tabLine:SetColorTexture(1, 0.82, 0, 0.30)

    -- Sort: by name, or by copies left (most first)
    local sortLabel = nav:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    sortLabel:SetPoint("TOPLEFT", 10, -46)
    Loc:Bind(sortLabel, "guide.sort")
    F.sorts = {}
    local sortW = 76
    for i, key in ipairs(SORTS) do
        local b = MakeRow(nav, sortW, 20)
        b.small = true
        b:SetPoint("TOPRIGHT", nav, "TOPRIGHT", -6 - (#SORTS - i) * (sortW + 2), -40)
        b.text:ClearAllPoints()
        b.text:SetPoint("CENTER")
        Loc:Bind(b.text, "guide.sort." .. key)
        b:SetScript("OnClick", function()
            sortBy = key
            if TTS.Options and TTS.Options.Set then TTS.Options:Set("guideSort", key) end
            Refresh(true)
        end)
        F.sorts[key] = b
    end
    local sortLine = nav:CreateTexture(nil, "ARTWORK")
    sortLine:SetPoint("TOPLEFT", 8, -64)
    sortLine:SetPoint("TOPRIGHT", -8, -64)
    sortLine:SetHeight(1)
    sortLine:SetColorTexture(1, 0.82, 0, 0.30)

    local navScroll = CreateFrame("ScrollFrame", "TTS_CollectionGuideNavScroll", nav, "UIPanelScrollFrameTemplate")
    navScroll:SetPoint("TOPLEFT", 6, -68)
    navScroll:SetPoint("BOTTOMRIGHT", -26, 6)
    F.navChild = CreateFrame("Frame", nil, navScroll)
    F.navChild:SetSize(NAV_W - 32, 10)
    navScroll:SetScrollChild(F.navChild)
    F.navScroll = navScroll
    F.placeRows = {}

    -- Right: the chosen place, how many of its cards are left, then its cards
    local page = MakePanel(F)
    page:SetPoint("TOPLEFT", nav, "TOPRIGHT", 4, 0)
    page:SetPoint("BOTTOMRIGHT", -14, 34)

    F.placeName = page:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    F.placeName:SetPoint("TOPLEFT", 12, -12)
    F.placeName:SetPoint("RIGHT", page, "RIGHT", -12, 0)
    F.placeName:SetJustifyH("LEFT")
    F.remaining = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    F.remaining:SetPoint("TOPLEFT", F.placeName, "BOTTOMLEFT", 0, -4)
    F.remaining:SetJustifyH("LEFT")
    F.mastery = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    F.mastery:SetPoint("TOPLEFT", F.remaining, "BOTTOMLEFT", 0, -3)
    F.mastery:SetJustifyH("LEFT")
    F.foils = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    F.foils:SetPoint("TOPLEFT", F.mastery, "BOTTOMLEFT", 0, -3)
    F.foils:SetJustifyH("LEFT")
    local pageLine = page:CreateTexture(nil, "ARTWORK")
    pageLine:SetPoint("TOPLEFT", 8, -80)
    pageLine:SetPoint("TOPRIGHT", -8, -80)
    pageLine:SetHeight(1)
    pageLine:SetColorTexture(1, 0.82, 0, 0.30)

    local cardScroll = CreateFrame("ScrollFrame", "TTS_CollectionGuideCardScroll", page, "UIPanelScrollFrameTemplate")
    cardScroll:SetPoint("TOPLEFT", 6, -86)
    cardScroll:SetPoint("BOTTOMRIGHT", -26, 6)
    F.cardWidth = WIN_W - 14 - NAV_W - 4 - 14 - 32
    F.cardChild = CreateFrame("Frame", nil, cardScroll)
    F.cardChild:SetSize(F.cardWidth, 10)
    cardScroll:SetScrollChild(F.cardChild)
    F.cardScroll = cardScroll
    F.cardRows = {}

    F:SetScript("OnShow", function() Refresh(false) end)
    if TTS.Sound and TTS.Sound.HookButtons then TTS.Sound:HookButtons(F) end
end

local function PlaceRow(i)
    local row = F.placeRows[i]
    if row then return row end
    row = MakeRow(F.navChild, NAV_W - 32, ROW_H)
    row:SetPoint("TOPLEFT", 0, -(i - 1) * (ROW_H + 1))
    row:SetScript("OnClick", function(self)
        selected[tab] = self.zone
        Refresh(false)
    end)
    F.placeRows[i] = row
    return row
end

local function CardRow(i)
    local row = F.cardRows[i]
    if row then return row end
    row = CreateFrame("Frame", nil, F.cardChild)
    row:SetSize(F.cardWidth, ROW_H)
    row:SetPoint("TOPLEFT", 6, -4 - (i - 1) * ROW_H)
    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.name:SetPoint("LEFT", 0, 0)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)
    row.copies = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.copies:SetPoint("RIGHT", -6, 0)
    row.copies:SetJustifyH("RIGHT")
    row.name:SetPoint("RIGHT", row.copies, "LEFT", -8, 0)
    F.cardRows[i] = row
    return row
end

-- resetScroll: a new tab was picked, so both lists go back to the top
Refresh = function(resetScroll)
    if not F then return end
    for key, b in pairs(F.tabs) do Paint(b, key == tab) end
    for key, b in pairs(F.sorts) do Paint(b, key == sortBy) end

    places = Places(tab)
    if sortBy == "left" then
        -- Most copies left first; Places' own order (name, or the hearth sets) breaks ties
        for i, p in ipairs(places) do p.order = i end
        table.sort(places, function(a, b)
            if a.copiesLeft ~= b.copiesLeft then return a.copiesLeft > b.copiesLeft end
            return a.order < b.order
        end)
    end
    local current
    for _, p in ipairs(places) do
        if p.zone == selected[tab] then current = p end
    end
    current = current or places[1]
    selected[tab] = current and current.zone

    -- Places: name, then how many cards are left (a tick once it's all 4/4)
    for i, p in ipairs(places) do
        local row = PlaceRow(i)
        row.zone = p.zone
        -- Green once every card there is 4/4 (in the text, so Paint's font change keeps it)
        row.text:SetText(p.copiesLeft == 0 and ("|cFF33DD33" .. p.name .. "|r") or p.name)
        -- Copies still to collect there, not just cards short of 4/4
        row.count:SetText(p.copiesLeft > 0 and tostring(p.copiesLeft) or "|cFF33DD33" .. L("guide.done") .. "|r")
        Paint(row, p == current)
        row:Show()
    end
    for i = #places + 1, #F.placeRows do F.placeRows[i]:Hide() end
    F.navChild:SetHeight(math.max(10, #places * (ROW_H + 1)))

    -- The place's cards: names and copies only
    local cards = current and current.cards or {}
    F.placeName:SetText(current and (current.copiesLeft == 0 and ("|cFF33DD33" .. current.name .. "|r") or current.name) or "")
    -- Remaining: copies still to collect (of every copy there is); mastery: cards short of 4/4
    F.mastery:SetText("")
    if not current then
        F.remaining:SetText("")
    elseif current.copiesLeft == 0 then
        F.remaining:SetText("|cFF33DD33" .. L("guide.complete") .. "|r")
    else
        local key = (tab == "dungeons") and "guide.remainingDungeon"
            or (tab == "hearths") and "guide.remainingSet" or "guide.remainingZone"
        F.remaining:SetText(L(key, GOLD .. current.copiesLeft .. "|r", #cards * MAX_COPIES))
        F.mastery:SetText(L("guide.mastery", GOLD .. current.remaining .. "|r", #cards))
    end
    -- Foils: of the denizens that drop from kills (as the collection score counts them)
    local foils, foilable = 0, 0
    for _, card in ipairs(cards) do
        if CanFoil(card) then
            foilable = foilable + 1
            if TTS:HasFoil(card.id) then foils = foils + 1 end
        end
    end
    if foilable > 0 then
        local n = (foils == foilable) and ("|cFF33DD33" .. foils .. "|r") or (GOLD .. foils .. "|r")
        F.foils:SetText(L("guide.foils", n, foilable))
    else
        F.foils:SetText("")
    end
    for i, card in ipairs(cards) do
        local row = CardRow(i)
        local n = TTS:GetOwnedCopies(card) or 0
        local name = TTS:CardName(card) or card.name or card.id
        if card.subType == "Gear" then name = name .. " |cFF888888(" .. Loc:Term("type", "Gear") .. ")|r" end
        row.name:SetText(name)
        if TTS:HasFoil(card.id) then
            row.name:SetTextColor(0.2, 0.87, 0.2)   -- its foil is yours
        else
            row.name:SetTextColor(n == 0 and 0.6 or 1, n == 0 and 0.6 or 1, n == 0 and 0.6 or 1)
        end
        row.copies:SetText(CopiesText(n))
        row:Show()
    end
    for i = #cards + 1, #F.cardRows do F.cardRows[i]:Hide() end
    F.cardChild:SetHeight(math.max(10, 8 + #cards * ROW_H))

    F.cardScroll:SetVerticalScroll(0)
    if resetScroll then F.navScroll:SetVerticalScroll(0) end
end

-- Opens the window (built on first use) on the zone the player is in, if it has cards, and returns it
function G:Open()
    if not F then
        local saved = TTS.Options and TTS.Options.Get and TTS.Options:Get("guideSort")
        if saved == "left" then sortBy = "left" end
        Build()
    end
    local here = GetRealZoneText and GetRealZoneText()
    if here and here ~= "" then
        for _, key in ipairs({ "zones", "dungeons" }) do
            for _, p in ipairs(Places(key)) do
                if p.zone == here or p.name == here then tab, selected[key] = key, p.zone end
            end
        end
    end
    F:Show()
    return F
end
