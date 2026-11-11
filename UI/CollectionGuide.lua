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
-- Which cards each zone and dungeon holds and how many copies of each the player has, in
-- the Deckbuilder's look (its controls, DeckBuilder.lua's D.UI). Names and copies only:
-- what a card looks like and does stays in the Deckbuilder. Three tabs (Zones, Dungeons,
-- Hearthstones); down the left the places of the tab with how many of their cards are
-- still short of 4/4, on the right the chosen place's cards as a scrolling list, sorted and
-- grouped by zone, faction or card type. An "All" row heads each tab's places.
-- A card belongs to its card.zone (denizens, solo rewards and Gear), and a creature also
-- to every other zone it's found in (TTS.MOB_ZONES, MobZones.lua), listed there under
-- "Also found here"; the All rows count it once. Dungeons are the
-- instances BossTracker knows (TTS.BossTracker:IsDungeonZone). The innkeepers' gift
-- prayers have no zone: the Hearthstones tab lists them by set (HEARTH_SETS).
-- Opened from the main window's Collection Guide button (MainFrame.lua).
-- =========================================================================
local G = {}
TTS.CollectionGuide = G

local MAX_COPIES = 4
local PAD = 14
local NAV_W, LIST_PANEL_W = 260, 470
local LOGO_H, HEADER_H = 38, 40       -- the Deckbuilder's header
local PANEL_TOP = -61
local ROW_H = 20
local VISIBLE_ROWS = 24               -- rows of the list on screen, group headers included
local LIST_TOP = 76                   -- where the list starts in its panel
local PANEL_H = LIST_TOP + VISIBLE_ROWS * ROW_H + 8
local BREAKDOWN_H = 30                -- the collection breakdown's two lines, over the footer
local TABS = { "zones", "dungeons", "hearths" }
local ALL = "_all"                    -- the place key of a tab's "All" row

-- The Hearthstones tab's sets, in this order (guide.hearth.<key>): the town innkeepers'
-- Hearthstones, the smaller towns' Dark Hearthstones, the capitals' pool (Cards\Core.lua)
local HEARTH_SETS = { "basic", "dark", "greater" }
local function HearthSet(card)
    if card.type ~= "Land" or not card.isGift then return nil end
    if card.giftPool then return "greater" end
    if card.bouncesPrayer then return "dark" end
    return "basic"
end
local GOLD = "|cFFFFD200"
local GREY = "|cFF8A8A8A"
local GREEN = "|cFF33DD33"

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

-- Which places of a tab a card is in: its card.zone and any other zones its creature is
-- also found in (TTS.MOB_ZONES, MobZones.lua), or its hearth set. Fills `into`, returns it.
local function PlacesOf(card, tab, into)
    if tab == "hearths" then
        into[#into + 1] = HearthSet(card)
        return into
    end
    if not Collectible(card) then return into end
    local wantDungeon = (tab == "dungeons")
    if IsDungeon(card.zone) == wantDungeon then into[#into + 1] = card.zone end
    for _, zone in ipairs(TTS.MOB_ZONES and TTS.MOB_ZONES[card.id] or {}) do
        if zone ~= card.zone and IsDungeon(zone) == wantDungeon then into[#into + 1] = zone end
    end
    return into
end

-- The places of a tab ("zones", "dungeons" or "hearths"): A-Z by their shown name, the
-- hearth sets in HEARTH_SETS order.
-- { zone, name, cards = { card... }, remaining (cards short of 4/4), copiesLeft (copies
-- still to collect across them all), collected (copies owned across them all) }
local function Places(tab)
    local byZone = {}
    for _, card in pairs(TTS.Cards or {}) do
        for _, zone in ipairs(PlacesOf(card, tab, {})) do
            local p = byZone[zone]
            if not p then
                local name = (tab == "hearths") and L("guide.hearth." .. zone) or Loc:Term("zone", zone)
                p = { zone = zone, name = name, cards = {}, remaining = 0, copiesLeft = 0, collected = 0 }
                byZone[zone] = p
            end
            table.insert(p.cards, card)
            local owned = math.min(MAX_COPIES, TTS:GetOwnedCopies(card) or 0)
            if owned < MAX_COPIES then p.remaining = p.remaining + 1 end
            p.copiesLeft = p.copiesLeft + (MAX_COPIES - owned)
            p.collected = p.collected + owned
        end
    end
    local list = {}
    for _, p in pairs(byZone) do table.insert(list, p) end
    if tab == "hearths" then
        local order = {}
        for i, key in ipairs(HEARTH_SETS) do order[key] = i end
        table.sort(list, function(a, b) return order[a.zone] < order[b.zone] end)
    else
        table.sort(list, function(a, b) return a.name < b.name end)
    end
    return list
end

-- The "All" row: every card of the tab's places, added up (a creature found in several
-- zones counted once)
local function AllPlace(list, tab)
    local all = { zone = ALL, name = L("guide.all." .. tab), cards = {}, remaining = 0, copiesLeft = 0, collected = 0 }
    local seen = {}
    for _, p in ipairs(list) do
        for _, card in ipairs(p.cards) do
            if not seen[card] then
                seen[card] = true
                table.insert(all.cards, card)
                local owned = math.min(MAX_COPIES, TTS:GetOwnedCopies(card) or 0)
                if owned < MAX_COPIES then all.remaining = all.remaining + 1 end
                all.copiesLeft = all.copiesLeft + (MAX_COPIES - owned)
                all.collected = all.collected + owned
            end
        end
    end
    return all
end

-- Whether a card can have a foil: the denizens that drop from kills (BossTracker.lua)
local function CanFoil(card)
    return card.isMob and not card.isReward
end

-- =========================================================================
-- WINDOW (built the first time it opens)
-- =========================================================================
local F
local UI                               -- the Deckbuilder's D.UI, once the window is built
local tab = "zones"
local selected = {}                    -- chosen place (card.zone, hearth set or ALL) per tab
local listToTop = true                 -- the next Refresh scrolls the card list back to the top
-- How the places are listed: "name" (A-Z; the hearth sets in their order), "left" (most
-- copies left first) or "collected" (most copies owned first). Clicking the active one
-- flips it. Both remembered in the options (guideSort, guideSortFlip).
local SORTS = { "name", "left", "collected" }
local sortBy = "name"
local sortFlipped = false
-- How the cards are ordered (DeckBuilder.lua's sort modes, shown as db.sort.<mode>),
-- remembered in the options (guideCardSort)
local CARD_SORTS = { "ZONE", "FACTION", "TYPE" }
local cardSort = "ZONE"
local places = {}
local Refresh
local shownZone                        -- the zone whose cards are listed (nil for All and the hearth sets)

local TYPE_LABEL = { Creature = "db.creatures", Spell = "db.spells", Location = "db.locations", Gear = "db.gear", Prayer = "db.prayers" }

-- Whether a card is listed in a zone other than its own (its creature is also found there)
local function Visiting(card)
    return shownZone ~= nil and card.zone ~= shownZone
end

-- The heading a card goes under in the current sort
local function GroupLabel(card)
    if cardSort == "ZONE" then
        if Visiting(card) then return L("guide.alsoHere") end
        return card.zone and Loc:Term("zone", card.zone) or L("guide.other")
    elseif cardSort == "FACTION" then
        return card.faction and Loc:Term("faction", card.faction) or L("guide.other")
    end
    return L(TYPE_LABEL[UI.GetTypeGroup(card)])
end

-- The list's rows: { card = } and, when the sort splits the cards into more than one
-- group, { header =, count = } before each group
local function ListEntries(cards)
    local list, headers, last, current = {}, 0, nil, nil
    for _, card in ipairs(cards) do
        local label = GroupLabel(card)
        if label ~= last then
            current = { header = label, count = 0 }
            list[#list + 1] = current
            headers = headers + 1
            last = label
        end
        current.count = current.count + 1
        list[#list + 1] = { card = card }
    end
    if headers > 1 then return list end
    local plain = {}
    for _, card in ipairs(cards) do plain[#plain + 1] = { card = card } end
    return plain
end

-- A flat selectable row: gold wash and bar when selected
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

local function PaintRow(b, on)
    b.sel:SetShown(on)
    b.bar:SetShown(on)
    b.text:SetFontObject(on and "GameFontHighlight" or "GameFontNormal")
end

-- The Deckbuilder's filter toggle: an accent border and tint when on
local function MakeToggle(parent, w, h, key, onClick)
    local b = UI.CreateFlatButton(parent, w, h, key)
    b.label:ClearAllPoints()
    b.label:SetPoint("LEFT", 2, 0)
    b.label:SetPoint("RIGHT", -2, 0)
    b.label:SetJustifyH("CENTER")
    b:SetScript("OnClick", onClick)
    return b
end

local function PaintToggle(b, on)
    local c = UI.STYLE.accent
    if on then
        UI.SetBg(b, c[1] * 0.22, c[2] * 0.22, c[3] * 0.22, 1)
        UI.SetBorder(b, c[1], c[2], c[3], 0.9)
        b.label:SetAlpha(1)
    else
        local bg, border = UI.STYLE.controlBg, UI.STYLE.controlBorder
        UI.SetBg(b, bg[1], bg[2], bg[3], 1)
        UI.SetBorder(b, border[1], border[2], border[3], 1)
        b.label:SetAlpha(0.6)
    end
end

local function GoldLine(parent, y)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", 8, y)
    line:SetPoint("TOPRIGHT", -8, y)
    line:SetHeight(1)
    line:SetColorTexture(1, 0.82, 0, 0.30)
end

-- One row of the list: a card's name and a pip per copy (gold owned, green at 4/4, dark
-- missing), or a group's heading, its size and a gold line
local function CreateListRow(width)
    local row = CreateFrame("Frame", nil, F.listChild)
    row:SetSize(width, ROW_H)

    local pipsW = MAX_COPIES * 16 + (MAX_COPIES - 1) * 3
    row.pips = {}
    for p = 1, MAX_COPIES do
        local pip = row:CreateTexture(nil, "OVERLAY")
        pip:SetSize(16, 5)
        pip:SetPoint("RIGHT", row, "RIGHT", -6 - (MAX_COPIES - p) * 19, 0)
        row.pips[p] = pip
    end
    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.name:SetPoint("LEFT", 4, 0)
    row.name:SetPoint("RIGHT", row, "RIGHT", -(pipsW + 14), 0)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)

    row.header = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.header:SetPoint("BOTTOMLEFT", 2, 3)
    row.headerCount = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.headerCount:SetPoint("BOTTOMRIGHT", -6, 3)
    row.headerLine = row:CreateTexture(nil, "ARTWORK")
    row.headerLine:SetPoint("BOTTOMLEFT")
    row.headerLine:SetPoint("BOTTOMRIGHT")
    row.headerLine:SetHeight(1)
    row.headerLine:SetColorTexture(1, 0.82, 0, 0.30)

    row:Hide()
    return row
end

local function FillListRow(row, entry)
    local isHeader = entry.header ~= nil
    row.header:SetShown(isHeader)
    row.headerCount:SetShown(isHeader)
    row.headerLine:SetShown(isHeader)
    row.name:SetShown(not isHeader)
    for p = 1, MAX_COPIES do row.pips[p]:SetShown(not isHeader) end

    if isHeader then
        row.header:SetText(entry.header)
        row.headerCount:SetText(entry.count)
    else
        local card = entry.card
        local n = math.min(MAX_COPIES, TTS:GetOwnedCopies(card) or 0)
        local name = TTS:CardName(card) or card.name or card.id
        if card.subType == "Gear" then name = name .. " |cFF888888(" .. Loc:Term("type", "Gear") .. ")|r" end
        row.name:SetText(name)
        if TTS:HasFoil(card.id) then
            row.name:SetTextColor(0.2, 0.87, 0.2)   -- its foil is yours
        else
            local shade = (n == 0) and 0.6 or 1
            row.name:SetTextColor(shade, shade, shade)
        end
        for p = 1, MAX_COPIES do
            if p > n then
                row.pips[p]:SetColorTexture(0.18, 0.18, 0.20, 1)
            elseif n >= MAX_COPIES then
                row.pips[p]:SetColorTexture(0.2, 0.87, 0.2, 1)
            else
                row.pips[p]:SetColorTexture(1, 0.82, 0, 1)
            end
        end
    end
    row:Show()
end

-- Puts the rows on whichever entries are in view: an All row can hold over a thousand
-- cards, so only a screenful of rows exists and they follow the scroll position
local function ShowListRows()
    local entries = F.entries or {}
    local first = math.floor((F.listScroll:GetVerticalScroll() or 0) / ROW_H)
    for i, row in ipairs(F.listRows) do
        local index = first + i
        local entry = entries[index]
        if entry then
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", F.listChild, "TOPLEFT", 0, -(index - 1) * ROW_H)
            FillListRow(row, entry)
        else
            row:Hide()
        end
    end
end

-- The card sort dropdown, in the Deckbuilder's dropdown style. Its menu closes on a click
-- anywhere else in the window (the blocker under it).
local function BuildSortDropdown(parent)
    local width = 130
    local menuRowH = UI.LAYOUT.MENU_ROW_H
    local dd = UI.CreateFlatButton(parent, width, 24, "")
    Loc:Unbind(dd.label)   -- Refresh owns the label
    dd.tooltipTitle, dd.tooltipText = "db.sortOrder", "guide.cardSort.desc"

    local arrow = dd:CreateTexture(nil, "OVERLAY")
    arrow:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
    arrow:SetSize(12, 12)
    arrow:SetPoint("RIGHT", -5, -3)
    dd.label:ClearAllPoints()
    dd.label:SetPoint("LEFT", 7, 0)
    dd.label:SetPoint("RIGHT", arrow, "LEFT", -2, 3)
    dd.label:SetJustifyH("LEFT")

    local blocker = CreateFrame("Button", nil, F)
    blocker:SetAllPoints(F)
    blocker:SetFrameStrata("FULLSCREEN_DIALOG")
    blocker:SetFrameLevel(1)
    blocker:RegisterForClicks("AnyUp")
    blocker:Hide()

    local menu = CreateFrame("Frame", nil, F)
    menu:SetFrameStrata("FULLSCREEN_DIALOG")
    menu:SetFrameLevel(10)
    menu:EnableMouse(true)
    UI.Skin(menu, UI.STYLE.menuBg, UI.STYLE.menuBorder)
    menu:SetPoint("TOPLEFT", dd, "BOTTOMLEFT", 0, -2)
    menu:SetSize(width, 12 + #CARD_SORTS * menuRowH)
    menu:Hide()

    local function CloseMenu()
        menu:Hide()
        blocker:Hide()
    end
    blocker:SetScript("OnClick", CloseMenu)
    F:HookScript("OnHide", CloseMenu)

    local rows = {}
    for i, mode in ipairs(CARD_SORTS) do
        local row = CreateFrame("Button", nil, menu)
        row:SetSize(width - 12, menuRowH)
        row:SetPoint("TOPLEFT", menu, "TOPLEFT", 6, -6 - (i - 1) * menuRowH)
        local hl = row:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints(row)
        hl:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
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
        Loc:Bind(row.text, "db.sort." .. mode)
        row.mode = mode
        row:SetScript("OnClick", function()
            CloseMenu()
            if mode == cardSort then return end
            cardSort = mode
            listToTop = true
            if TTS.Options and TTS.Options.Set then TTS.Options:Set("guideCardSort", mode) end
            Refresh(false)
        end)
        rows[i] = row
    end

    dd:SetScript("OnClick", function()
        for _, row in ipairs(rows) do row.check:SetShown(row.mode == cardSort) end
        if TTS.Tooltip then TTS.Tooltip:Hide() end
        menu:Show()
        blocker:Show()
    end)
    return dd
end

local function Build()
    UI = TTS.DeckBuilderFrame.UI

    F = CreateFrame("Frame", "TTS_CollectionGuideFrame", UIParent)
    G.frame = F
    F:SetSize(PAD * 3 + NAV_W + LIST_PANEL_W, -PANEL_TOP + PANEL_H + 34 + BREAKDOWN_H)
    F:SetPoint("CENTER")
    F:SetClampedToScreen(true)
    UI.Skin(F, UI.STYLE.windowBg, UI.STYLE.windowBorder, "dialog")
    F:SetFrameStrata("DIALOG")
    F:SetToplevel(true)
    F:EnableMouse(true)
    F:SetMovable(true)
    F:RegisterForDrag("LeftButton")
    F:SetScript("OnDragStart", F.StartMoving)
    F:SetScript("OnDragStop", F.StopMovingOrSizing)
    F:Hide()
    tinsert(UISpecialFrames, "TTS_CollectionGuideFrame")   -- Escape closes it

    -- Header: the Deckbuilder's dark strip with a gold line, the logo, then the title
    local bar = F:CreateTexture(nil, "ARTWORK")
    bar:SetPoint("TOPLEFT", 12, -12)
    bar:SetPoint("TOPRIGHT", -12, -12)
    bar:SetHeight(HEADER_H)
    bar:SetColorTexture(0, 0, 0, 0.35)
    local line = F:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, 0)
    line:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, 0)
    line:SetHeight(1)
    line:SetColorTexture(1, 0.82, 0, 0.55)
    local logo = F:CreateTexture(nil, "OVERLAY")
    logo:SetSize(LOGO_H * 350 / 85, LOGO_H)
    logo:SetPoint("LEFT", bar, "LEFT", 2, 0)
    logo:SetTexture("Interface\\AddOns\\ForeverCCG\\Textures\\logo.png")
    local title = F:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", logo, "RIGHT", 8, 0)
    Loc:Bind(title, "guide.title")
    local close = CreateFrame("Button", nil, F, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)

    local footer = F:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    footer:SetPoint("BOTTOMRIGHT", F, "BOTTOMRIGHT", -26, 13)
    footer:SetText("Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy")

    -- The Deckbuilder's collection breakdown (TTS:CollectionBreakdown), two lines over the footer
    F.breakdown = F:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    F.breakdown:SetPoint("BOTTOMLEFT", F, "BOTTOMLEFT", 16, 28)
    F.breakdown:SetJustifyH("LEFT")
    F.breakdown:SetSpacing(2)

    -- Left: the tabs, how the places are sorted, then the places of the chosen tab
    local nav = CreateFrame("Frame", nil, F)
    UI.Skin(nav, UI.STYLE.panelBg, UI.STYLE.panelBorder)
    nav:SetSize(NAV_W, PANEL_H)
    nav:SetPoint("TOPLEFT", F, "TOPLEFT", PAD, PANEL_TOP)

    F.tabs = {}
    local tabW = (NAV_W - 20 - (#TABS - 1) * 4) / #TABS
    for i, key in ipairs(TABS) do
        local b = MakeToggle(nav, tabW, 24, "guide." .. key, function()
            tab = key
            listToTop = true
            Refresh(true)
        end)
        b:SetPoint("TOPLEFT", nav, "TOPLEFT", 10 + (i - 1) * (tabW + 4), -10)
        F.tabs[key] = b
    end
    GoldLine(nav, -40)

    local sortLabel = nav:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    sortLabel:SetPoint("TOPLEFT", 12, -50)
    Loc:Bind(sortLabel, "guide.sort")
    F.sorts = {}
    local sortW = 67
    for i, key in ipairs(SORTS) do
        local b = MakeToggle(nav, sortW, 22, "guide.sort." .. key, function()
            if sortBy == key then
                sortFlipped = not sortFlipped
            else
                sortBy, sortFlipped = key, false
            end
            if TTS.Options and TTS.Options.Set then
                TTS.Options:Set("guideSort", sortBy)
                TTS.Options:Set("guideSortFlip", sortFlipped)
            end
            Refresh(true)
        end)
        b:SetPoint("TOPRIGHT", nav, "TOPRIGHT", -10 - (#SORTS - i) * (sortW + 4), -45)
        b.label:SetPoint("RIGHT", -12, 0)   -- room for the direction arrow
        b.arrow = b:CreateTexture(nil, "OVERLAY")
        b.arrow:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
        b.arrow:SetSize(12, 12)
        F.sorts[key] = b
    end
    GoldLine(nav, -72)

    local navScroll = CreateFrame("ScrollFrame", "TTS_CollectionGuideNavScroll", nav, "UIPanelScrollFrameTemplate")
    navScroll:SetPoint("TOPLEFT", 6, -76)
    navScroll:SetPoint("BOTTOMRIGHT", -26, 6)
    F.navChild = CreateFrame("Frame", nil, navScroll)
    F.navChild:SetSize(NAV_W - 32, 10)
    navScroll:SetScrollChild(F.navChild)
    F.navScroll = navScroll
    F.placeRows = {}

    -- Right: the chosen place and how much of it is left, the sort, then the cards
    local pool = CreateFrame("Frame", nil, F)
    UI.Skin(pool, UI.STYLE.panelBg, UI.STYLE.panelBorder)
    pool:SetSize(LIST_PANEL_W, PANEL_H)
    pool:SetPoint("TOPLEFT", nav, "TOPRIGHT", PAD, 0)

    F.sortDD = BuildSortDropdown(pool)
    F.sortDD:SetPoint("TOPRIGHT", pool, "TOPRIGHT", -10, -10)

    F.placeName = pool:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    F.placeName:SetPoint("TOPLEFT", 12, -14)
    F.placeName:SetPoint("RIGHT", F.sortDD, "LEFT", -10, 0)
    F.placeName:SetJustifyH("LEFT")
    F.placeName:SetWordWrap(false)
    F.remaining = pool:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    F.remaining:SetPoint("TOPLEFT", 12, -38)
    F.remaining:SetJustifyH("LEFT")
    F.mastery = pool:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    F.mastery:SetPoint("TOPLEFT", 12, -53)
    F.mastery:SetJustifyH("LEFT")
    GoldLine(pool, -70)

    F.countText = pool:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    F.countText:SetPoint("TOPRIGHT", pool, "TOPRIGHT", -12, -40)

    local listW = LIST_PANEL_W - 40       -- the scroll bar has the rest
    F.listScroll = CreateFrame("ScrollFrame", "TTS_CollectionGuideCardScroll", pool, "UIPanelScrollFrameTemplate")
    F.listScroll:SetPoint("TOPLEFT", pool, "TOPLEFT", 10, -LIST_TOP)
    F.listScroll:SetPoint("BOTTOMRIGHT", pool, "BOTTOMRIGHT", -30, 8)
    F.listChild = CreateFrame("Frame", nil, F.listScroll)
    F.listChild:SetSize(listW, 10)
    F.listScroll:SetScrollChild(F.listChild)
    F.listScroll:HookScript("OnVerticalScroll", ShowListRows)
    local scrollBar = _G["TTS_CollectionGuideCardScrollScrollBar"]
    if scrollBar then scrollBar.scrollStep = ROW_H * 3 end   -- the wheel and arrows move three rows
    F.listRows = {}
    for i = 1, VISIBLE_ROWS + 1 do F.listRows[i] = CreateListRow(listW) end   -- +1: part of a row at each end

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
        listToTop = true
        Refresh(false)
    end)
    F.placeRows[i] = row
    return row
end

-- resetScroll: a new tab was picked, so the places list goes back to the top
Refresh = function(resetScroll)
    if not F then return end
    for key, b in pairs(F.tabs) do PaintToggle(b, key == tab) end
    for key, b in pairs(F.sorts) do
        PaintToggle(b, key == sortBy)
        -- Down in the normal order, up when flipped (the texture's art sits off-centre, so it moves too)
        b.arrow:SetShown(key == sortBy)
        b.arrow:SetTexCoord(0, 1, sortFlipped and 1 or 0, sortFlipped and 0 or 1)
        b.arrow:ClearAllPoints()
        b.arrow:SetPoint("RIGHT", -1, sortFlipped and 3 or -3)
    end
    F.sortDD.label:SetText(GREY .. L("db.sortPrefix") .. "|r " .. L("db.sort." .. cardSort))

    places = Places(tab)
    -- Highest count first (lowest when flipped); Places' own order (name, or the hearth
    -- sets) breaks ties, and is the sort itself for "name"
    local countField = (sortBy == "left") and "copiesLeft" or (sortBy == "collected") and "collected" or nil
    for i, p in ipairs(places) do p.order = i end
    table.sort(places, function(a, b)
        if countField and a[countField] ~= b[countField] then
            if sortFlipped then return a[countField] < b[countField] end
            return a[countField] > b[countField]
        end
        if not countField and sortFlipped then return a.order > b.order end
        return a.order < b.order
    end)
    if #places > 0 then table.insert(places, 1, AllPlace(places, tab)) end

    local current
    for _, p in ipairs(places) do
        if p.zone == selected[tab] then current = p end
    end
    current = current or places[1]
    selected[tab] = current and current.zone

    -- Places: name, then how many copies are left, or owned while sorting by that (Done,
    -- in green, once it's all 4/4)
    for i, p in ipairs(places) do
        local row = PlaceRow(i)
        row.zone = p.zone
        row.text:SetText(p.copiesLeft == 0 and (GREEN .. p.name .. "|r") or p.name)
        local shown = (sortBy == "collected") and p.collected or p.copiesLeft
        row.count:SetText(p.copiesLeft > 0 and tostring(shown) or GREEN .. L("guide.done") .. "|r")
        PaintRow(row, p == current)
        row:Show()
    end
    for i = #places + 1, #F.placeRows do F.placeRows[i]:Hide() end
    F.navChild:SetHeight(math.max(10, #places * (ROW_H + 1)))

    local cards = current and current.cards or {}
    shownZone = current and current.zone ~= ALL and tab ~= "hearths" and current.zone or nil
    local CompareBy = TTS.DeckBuilderFrame.CompareCardsBy
    -- Sorted by zone, a zone's own cards come first and the creatures also found there after
    local visitorsLast = (cardSort == "ZONE")
    table.sort(cards, function(a, b)
        if visitorsLast then
            local va, vb = Visiting(a), Visiting(b)
            if va ~= vb then return vb end
        end
        return CompareBy(cardSort, a.id, b.id)
    end)

    -- The place's name, copies left, then cards short of 4/4 and foils
    F.placeName:SetText(current and (current.copiesLeft == 0 and (GREEN .. current.name .. "|r") or current.name) or "")
    local mastery = {}
    if not current then
        F.remaining:SetText("")
    elseif current.copiesLeft == 0 then
        F.remaining:SetText(GREEN .. L("guide.complete") .. "|r")
    else
        local key = (current.zone == ALL) and "guide.remainingAll" or (tab == "dungeons") and "guide.remainingDungeon"
            or (tab == "hearths") and "guide.remainingSet" or "guide.remainingZone"
        F.remaining:SetText(L(key, GOLD .. current.copiesLeft .. "|r", #cards * MAX_COPIES))
        mastery[1] = L("guide.mastery", GOLD .. current.remaining .. "|r", #cards)
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
        local n = (foils == foilable) and (GREEN .. foils .. "|r") or (GOLD .. foils .. "|r")
        mastery[#mastery + 1] = L("guide.foils", n, foilable)
    end
    F.mastery:SetText(table.concat(mastery, "     "))

    -- The list
    F.entries = ListEntries(cards)
    F.listChild:SetHeight(math.max(10, #F.entries * ROW_H))
    if listToTop then
        F.listScroll:SetVerticalScroll(0)
        listToTop = false
    end
    ShowListRows()
    F.countText:SetText(#cards == 1 and L("db.oneCard") or L("db.nCards", #cards))
    if TTS.CollectionBreakdown then F.breakdown:SetText(TTS:CollectionBreakdown()) end

    if resetScroll then F.navScroll:SetVerticalScroll(0) end
end

-- Opens the window (built on first use) on the zone the player is in, if it has cards, and returns it
function G:Open()
    if not F then
        local saved = TTS.Options and TTS.Options.Get and TTS.Options:Get("guideSort")
        for _, key in ipairs(SORTS) do
            if key == saved then sortBy = key end
        end
        sortFlipped = (TTS.Options and TTS.Options.Get and TTS.Options:Get("guideSortFlip")) and true or false
        local savedCards = TTS.Options and TTS.Options.Get and TTS.Options:Get("guideCardSort")
        for _, mode in ipairs(CARD_SORTS) do
            if mode == savedCards then cardSort = mode end
        end
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
    listToTop = true
    F:Show()
    return F
end
