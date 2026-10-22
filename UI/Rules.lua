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
-- RULES & GUIDE
-- A tab per topic down the left, one scrolling page per tab on the right.
-- Pages are lists of blocks (PAGES below): an "In short" box first, then
-- headings, short paragraphs and example cards. Each page is built the first
-- time its tab is opened and laid out again every time it is shown.
-- =========================================================================
local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local R = CreateFrame("Frame", "TTS_RulesFrame", UIParent, backdropTemplate)
TTS.RulesFrame = R

local NAV_W = 168
R:SetSize(820, 640)
R:SetPoint("CENTER")
R:SetFrameStrata("DIALOG")
R:SetToplevel(true)
-- Same look as the Deckbuilder: dialog window, dark title strip, tooltip-bordered panel
R:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
R:EnableMouse(true)
R:SetMovable(true)
R:RegisterForDrag("LeftButton")
R:SetScript("OnDragStart", R.StartMoving)
R:SetScript("OnDragStop", R.StopMovingOrSizing)
R:Hide()

local SYMBOL_PATH = "Interface\\AddOns\\ForeverCCG\\Textures\\Symbols\\"
local TAP_TEX = SYMBOL_PATH .. "T.png"
local GOLD = "|cFFFFD200"

local function FormatTextWithSymbols(str, size)
    if not str or str == "" then return "" end
    local s = size or 16

    local tapTexture = string.format("|T%s:%d:%d:0:0|t", TAP_TEX, s, s)
    str = str:gsub("{[tT]}", tapTexture)
    str = str:gsub("{[tT][aA][pP]}", tapTexture)

    -- Stat lines ("• 2/2: Warrior", "a 2/3 means") are power/toughness
    str = str:gsub("(%d+)/(%d+):", "%1{PT}%2:"):gsub("(%d+)/(%d+)：", "%1{PT}%2：")

    if TTS.FormatSymbols then
        return TTS:FormatSymbols(str, s)
    end

    local defaultIcons = {
        W = SYMBOL_PATH .. "W.png",
        U = SYMBOL_PATH .. "U.png",
        B = SYMBOL_PATH .. "B.png",
        R = SYMBOL_PATH .. "R.png",
        G = SYMBOL_PATH .. "G.png",
    }

    return str:gsub("{(%w+)}", function(key)
        local upperKey = string.upper(key)
        if tonumber(key) or upperKey == "X" then
            return string.format("|cFF8E939B(|r%s|cFF8E939B)|r", upperKey)
        end
        local icon = defaultIcons[upperKey]
        if icon then
            return string.format("|T%s:%d:%d:0:0|t", icon, s, s)
        end
        return "(" .. upperKey .. ")"
    end)
end

local function Text(key) return FormatTextWithSymbols(L(key), 16) end

-- Header: darkened strip with a gold line, title on the left
local titleBar = R:CreateTexture(nil, "ARTWORK")
titleBar:SetPoint("TOPLEFT", 12, -12)
titleBar:SetPoint("TOPRIGHT", -12, -12)
titleBar:SetHeight(25)
titleBar:SetColorTexture(0, 0, 0, 0.35)

local titleLine = R:CreateTexture(nil, "ARTWORK")
titleLine:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 0)
titleLine:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
titleLine:SetHeight(1)
titleLine:SetColorTexture(1, 0.82, 0, 0.55)

local title = R:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -11)
Loc:Bind(title, "rules.title")

local subtitle = R:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
subtitle:SetPoint("LEFT", title, "RIGHT", 10, -1)
subtitle:SetText("Forever: CCG")

local closeBtn = CreateFrame("Button", nil, R, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -2, -2)
closeBtn:SetScript("OnClick", function() R:Hide() end)

-- Footer is pinned to the bottom of the window (outside the scroll area), like the title at the top
local footer = R:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
footer:SetPoint("BOTTOMRIGHT", R, "BOTTOMRIGHT", -20, 15)
footer:SetText("Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy")

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

-- Left: the tabs. Right: the scrolling page.
local navPanel = MakePanel(R)
navPanel:SetPoint("TOPLEFT", 14, -46)
navPanel:SetPoint("BOTTOMLEFT", 14, 34)
navPanel:SetWidth(NAV_W)

local rulesPanel = MakePanel(R)
rulesPanel:SetPoint("TOPLEFT", navPanel, "TOPRIGHT", 4, 0)
rulesPanel:SetPoint("BOTTOMRIGHT", -14, 34)

local scrollFrame = CreateFrame("ScrollFrame", "TTS_RulesScrollFrame", rulesPanel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", rulesPanel, "TOPLEFT", 6, -8)
scrollFrame:SetPoint("BOTTOMRIGHT", rulesPanel, "BOTTOMRIGHT", -28, 8)

-- 820 window - 14 - nav - 4 - 14, less the scroll bar
local CONTENT_W = 820 - 14 - NAV_W - 4 - 14 - 34
local TEXT_W    = CONTENT_W - 20

-- =========================================================================
-- EXAMPLE CARDS (same frames as the board and the Deckbuilder)
-- =========================================================================
local function SetupRuleCard(f, cardId, rulesOpts)
    local card = TTS.Cards and TTS.Cards[cardId]
    if not card then return false end

    f.cardId = cardId
    f.currentCard = card

    if TTS.SetupCardVisual then TTS.SetupCardVisual(f, card) end
    if TTS.ApplyFrameTexture then
        TTS.ApplyFrameTexture(f.border, card)
    elseif TTS.GetCardFrameTexture then
        f.border:SetTexture(TTS.GetCardFrameTexture(card))
    end
    f.border:SetVertexColor(1, 1, 1, 1)

    if f.title then f.title:SetText(TTS:CardName(card) or "") end
    if f.cost then
        if card.cost and card.cost ~= "" then
            f.cost:SetText(TTS.FormatCost and TTS:FormatCost(card.cost, rulesOpts and 18 or 16) or FormatTextWithSymbols(card.cost, rulesOpts and 18 or 16))
            f.cost:Show()
        else
            f.cost:Hide()
        end
    end
    if f.pt then TTS.ShowPrintedStats(f, card) end

    f:Show()
    -- Rules text printed on the card, same as on the board
    if f.rules and TTS.UpdateCardRules then TTS.UpdateCardRules(f, rulesOpts) end
    return true
end

-- Full-size copy of the hovered example card, docked outside the left edge
-- of the window (same as the Deckbuilder and the board)
local PREVIEW_W, PREVIEW_H = 150, 212
local PREVIEW_RULES = {
    fontMax = 11,
    fontMin = 8,
    offsetX = 3,   -- pixels right
    offsetY = 3,   -- pixels down
}

local previewCard

local function ShowRulesPreview(cardId)
    if not TTS.CreateCardFrame then return end
    if not previewCard then
        previewCard = TTS.CreateCardFrame(R, PREVIEW_W, PREVIEW_H)
        previewCard:SetFrameStrata("DIALOG")
        previewCard:SetFrameLevel((R:GetFrameLevel() or 10) + 40)
        previewCard:SetClampedToScreen(true)
        previewCard:EnableMouse(false)
        previewCard:SetScript("OnEnter", nil)
        previewCard:SetScript("OnLeave", nil)
    end
    -- Card name and cost sit above the frame, so leave room for them
    previewCard:ClearAllPoints()
    previewCard:SetPoint("TOPRIGHT", R, "TOPLEFT", -12, -76)
    SetupRuleCard(previewCard, cardId, PREVIEW_RULES)
end

local function HideRulesPreview()
    if previewCard then previewCard:Hide() end
end

local CARD_W, CARD_H   = 72, 102
local BIG_W, BIG_H     = PREVIEW_W, PREVIEW_H
local CARD_HEADROOM    = 32  -- room for the name and cost shown above each card

local function CreateExampleCard(parent, w, h, noPreview)
    if not TTS.CreateCardFrame then return nil end
    local f = TTS.CreateCardFrame(parent, w or CARD_W, h or CARD_H)
    f:SetFrameLevel(parent:GetFrameLevel() + 2)
    -- The shared card frame hides its cost whenever the card is hidden (for the board's hand);
    -- rule example cards keep their cost, so drop that handler here
    f:SetScript("OnHide", nil)
    f:EnableMouse(true)
    f:RegisterForClicks("LeftButtonUp")

    -- Preview and tooltip (UI\Tooltips.lua) when hovering over rule examples
    f:SetScript("OnEnter", function(self)
        if not (TTS.Cards and TTS.Cards[self.cardId]) then return end
        if not noPreview then ShowRulesPreview(self.cardId) end
        if TTS.Tooltip then TTS.Tooltip:ShowCard(self, "ANCHOR_TOP", self.cardId) end
    end)
    f:SetScript("OnLeave", function(self)
        if TTS.Tooltip then TTS.Tooltip:Hide(self) end
        HideRulesPreview()
    end)
    -- Shift-click while typing in chat links the card (UI\CardLinks.lua)
    f:SetScript("OnClick", function(self)
        if TTS.TryLinkCard then TTS:TryLinkCard(self.cardId) end
    end)
    return f
end

-- Puts cardId into slot[field] (making the frame the first time); false when the card
-- doesn't exist (yet), e.g. the Hero card before it has been built
local function PlaceCard(slot, field, parent, cardId, x, y, big)
    if not (TTS.Cards and TTS.Cards[cardId]) then
        if slot[field] then slot[field]:Hide() end
        return false
    end
    if not slot[field] then
        slot[field] = big and CreateExampleCard(parent, BIG_W, BIG_H, true) or CreateExampleCard(parent)
        if not slot[field] then return false end
    end
    local f = slot[field]
    SetupRuleCard(f, cardId, big and PREVIEW_RULES or nil)
    f:ClearAllPoints()
    f:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    return true
end

-- =========================================================================
-- BLOCKS
-- Each kind has make(page, blk) (creates its widgets once) and
-- place(page, blk, y) (sets text, positions everything, returns the new y).
-- =========================================================================
local function NewText(parent, font, width, justify)
    local fs = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlight")
    if width then fs:SetWidth(width) end
    fs:SetJustifyH(justify or "LEFT")
    fs:SetJustifyV("TOP")
    fs:SetWordWrap(true)
    return fs
end

local function Def(group, key, field)
    local TT = TTS.Tooltip
    return TT and TT.Def and TT:Def(group, key, field) or key
end

local function Box(parent, r, g, b, a, br, bg, bb)
    local f = CreateFrame("Frame", nil, parent, backdropTemplate)
    f:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    f:SetBackdropColor(r, g, b, a)
    f:SetBackdropBorderColor(br, bg, bb, 1)
    return f
end

local SECTION_GAP = 18

local Blocks = {}

-- "In short" box: the whole page in a sentence or two
Blocks.tldr = {
    make = function(page, blk)
        blk.box = Box(page, 0.30, 0.22, 0.02, 0.45, 1, 0.82, 0, 1)
        blk.icon = blk.box:CreateTexture(nil, "ARTWORK")
        blk.icon:SetSize(28, 28)
        blk.icon:SetPoint("TOPLEFT", 10, -10)
        blk.icon:SetTexture("Interface\\GossipFrame\\AvailableQuestIcon")
        blk.label = NewText(blk.box, "GameFontNormalSmall")
        blk.label:SetPoint("TOPLEFT", 46, -9)
        blk.text = NewText(blk.box, "GameFontHighlight", TEXT_W - 56)
        blk.text:SetPoint("TOPLEFT", blk.label, "BOTTOMLEFT", 0, -3)
    end,
    place = function(page, blk, y)
        blk.label:SetText(string.upper(L("rules.tldr")))
        blk.text:SetText(Text(blk[2]))
        local h = math.max(48, blk.label:GetStringHeight() + blk.text:GetStringHeight() + 22)
        blk.box:ClearAllPoints()
        blk.box:SetPoint("TOPLEFT", page, "TOPLEFT", 6, y)
        blk.box:SetSize(CONTENT_W - 12, h)
        return y - h - SECTION_GAP
    end,
}

-- Heading with a thin gold divider underneath
Blocks.h = {
    make = function(page, blk)
        blk.text = NewText(page, "GameFontNormalLarge")
        blk.rule = page:CreateTexture(nil, "ARTWORK")
        blk.rule:SetHeight(1)
        blk.rule:SetColorTexture(1, 0.82, 0, 0.30)
    end,
    place = function(page, blk, y)
        blk.text:SetText(L(blk[2]))
        blk.text:ClearAllPoints()
        blk.text:SetPoint("TOPLEFT", page, "TOPLEFT", 10, y)
        y = y - (blk.text:GetStringHeight() + 4)
        blk.rule:ClearAllPoints()
        blk.rule:SetPoint("TOPLEFT", page, "TOPLEFT", 10, y)
        blk.rule:SetPoint("TOPRIGHT", page, "TOPRIGHT", -10, y)
        return y - 8
    end,
}

Blocks.p = {
    make = function(page, blk)
        blk.text = NewText(page, "GameFontHighlight", TEXT_W)
        blk.text:SetSpacing(2)
    end,
    place = function(page, blk, y)
        blk.text:SetText(Text(blk[2]))
        blk.text:ClearAllPoints()
        blk.text:SetPoint("TOPLEFT", page, "TOPLEFT", 10, y)
        return y - blk.text:GetStringHeight() - SECTION_GAP
    end,
}

-- A tip line with a "!" icon, set apart in a faint box
Blocks.tip = {
    make = function(page, blk)
        blk.box = Box(page, 0.10, 0.10, 0.12, 0.6, 0.45, 0.42, 0.36)
        blk.icon = blk.box:CreateTexture(nil, "ARTWORK")
        blk.icon:SetSize(18, 18)
        blk.icon:SetPoint("TOPLEFT", 8, -7)
        blk.icon:SetTexture("Interface\\GossipFrame\\ActiveQuestIcon")
        blk.text = NewText(blk.box, "GameFontHighlightSmall", TEXT_W - 40)
        blk.text:SetPoint("TOPLEFT", 32, -9)
        blk.text:SetSpacing(2)
    end,
    place = function(page, blk, y)
        blk.text:SetText(GOLD .. L("rules.tip") .. ":|r " .. Text(blk[2]))
        local h = math.max(32, blk.text:GetStringHeight() + 18)
        blk.box:ClearAllPoints()
        blk.box:SetPoint("TOPLEFT", page, "TOPLEFT", 6, y)
        blk.box:SetSize(CONTENT_W - 12, h)
        return y - h - SECTION_GAP
    end,
}

-- A row of example cards, centred, each with an optional caption underneath:
-- { "cards", { { "W01", "caption.key" }, { "ELW04" }, ... } }
Blocks.cards = {
    make = function(page, blk)
        blk.slots = {}
        for i in ipairs(blk[2]) do
            blk.slots[i] = { caption = NewText(page, "GameFontHighlightSmall", nil, "CENTER") }
        end
    end,
    place = function(page, blk, y)
        local shown = {}
        for i, item in ipairs(blk[2]) do
            if TTS.Cards and TTS.Cards[item[1]] then
                shown[#shown + 1] = i
            else
                if blk.slots[i].card then blk.slots[i].card:Hide() end
                blk.slots[i].caption:Hide()
            end
        end
        local n = #shown
        if n == 0 then return y end
        local slotW = math.min(150, math.floor((CONTENT_W - 10) / n))
        local x0 = (CONTENT_W - n * slotW) / 2
        local top = y - CARD_HEADROOM
        local lowest = top - CARD_H
        for k, i in ipairs(shown) do
            local item, slot = blk[2][i], blk.slots[i]
            local x = x0 + (k - 1) * slotW
            PlaceCard(slot, "card", page, item[1], x + (slotW - CARD_W) / 2, top)
            if item[2] then
                slot.caption:SetWidth(slotW - 8)
                slot.caption:SetText(Text(item[2]))
                slot.caption:ClearAllPoints()
                slot.caption:SetPoint("TOP", page, "TOPLEFT", x + slotW / 2, top - CARD_H - 6)
                slot.caption:Show()
                lowest = math.min(lowest, top - CARD_H - 6 - slot.caption:GetStringHeight())
            else
                slot.caption:Hide()
            end
        end
        return lowest - SECTION_GAP
    end,
}

-- Big numbers in tiles: { "stats", { { "40-50", "label.key" }, ... } }
Blocks.stats = {
    make = function(page, blk)
        blk.tiles = {}
        for i in ipairs(blk[2]) do
            local t = Box(page, 0.08, 0.07, 0.05, 0.85, 0.60, 0.50, 0.25)
            t.value = NewText(t, "GameFontNormalHuge", nil, "CENTER")
            t.value:SetPoint("TOP", 0, -10)
            t.label = NewText(t, "GameFontHighlightSmall", nil, "CENTER")
            t.label:SetPoint("TOP", t.value, "BOTTOM", 0, -4)
            blk.tiles[i] = t
        end
    end,
    place = function(page, blk, y)
        local n, gap = #blk[2], 8
        local w = math.floor((CONTENT_W - 12 - (n - 1) * gap) / n)
        local h = 0
        for i, item in ipairs(blk[2]) do
            local t = blk.tiles[i]
            t.value:SetText(item[1])
            t.label:SetWidth(w - 10)
            t.label:SetText(L(item[2]))
            h = math.max(h, t.value:GetStringHeight() + t.label:GetStringHeight() + 26)
        end
        for i, t in ipairs(blk.tiles) do
            t:ClearAllPoints()
            t:SetPoint("TOPLEFT", page, "TOPLEFT", 6 + (i - 1) * (w + gap), y)
            t:SetSize(w, h)
        end
        return y - h - SECTION_GAP
    end,
}

-- The turn as a strip of numbered steps with arrows: { "phases", { "key1", "key2", ... } }
Blocks.phases = {
    make = function(page, blk)
        blk.steps, blk.arrows = {}, {}
        for i in ipairs(blk[2]) do
            local s = Box(page, 0.12, 0.09, 0.03, 0.85, 1, 0.82, 0)
            s.num = NewText(s, "GameFontNormalHuge", nil, "CENTER")
            s.num:SetPoint("TOP", 0, -6)
            s.name = NewText(s, "GameFontHighlightSmall", nil, "CENTER")
            s.name:SetPoint("TOP", s.num, "BOTTOM", 0, -2)
            blk.steps[i] = s
            if i > 1 then blk.arrows[i] = NewText(page, "GameFontNormalLarge", nil, "CENTER") end
        end
    end,
    place = function(page, blk, y)
        local n, gap = #blk[2], 18
        local w = math.floor((CONTENT_W - 12 - (n - 1) * gap) / n)
        local h = 0
        for i, key in ipairs(blk[2]) do
            local s = blk.steps[i]
            s.num:SetText(tostring(i))
            s.name:SetWidth(w - 8)
            s.name:SetText(L(key))
            h = math.max(h, s.num:GetStringHeight() + s.name:GetStringHeight() + 18)
        end
        for i, s in ipairs(blk.steps) do
            local x = 6 + (i - 1) * (w + gap)
            s:ClearAllPoints()
            s:SetPoint("TOPLEFT", page, "TOPLEFT", x, y)
            s:SetSize(w, h)
            local a = blk.arrows[i]
            if a then
                a:SetText(">")
                a:ClearAllPoints()
                a:SetPoint("CENTER", page, "TOPLEFT", x - gap / 2, y - h / 2)
            end
        end
        return y - h - SECTION_GAP
    end,
}

-- Large card on the left, text beside it: { "anatomy", "CARDID", "text.key" }
Blocks.anatomy = {
    make = function(page, blk)
        blk.text = NewText(page, "GameFontHighlight", TEXT_W - BIG_W - 40)
        blk.text:SetSpacing(2)
    end,
    place = function(page, blk, y)
        local top = y - CARD_HEADROOM
        local hasCard = PlaceCard(blk, "card", page, blk[2], 20, top, true)
        blk.text:SetText(Text(blk[3]))
        blk.text:ClearAllPoints()
        blk.text:SetPoint("TOPLEFT", page, "TOPLEFT", hasCard and (BIG_W + 44) or 10, top - 6)
        local bottom = top - 6 - blk.text:GetStringHeight()
        if hasCard then bottom = math.min(bottom, top - BIG_H) end
        return bottom - SECTION_GAP
    end,
}

-- Worked combat example: attacker, "vs", blocker, and what happens beside them:
-- { "versus", "ATTACKER", "BLOCKER", "text.key" }
Blocks.versus = {
    make = function(page, blk)
        blk.vs = NewText(page, "GameFontNormalLarge", nil, "CENTER")
        blk.capA = NewText(page, "GameFontDisableSmall", CARD_W + 20, "CENTER")
        blk.capB = NewText(page, "GameFontDisableSmall", CARD_W + 20, "CENTER")
        blk.text = NewText(page, "GameFontHighlight", nil)
        blk.text:SetSpacing(2)
        blk.bg = page:CreateTexture(nil, "BACKGROUND")
        blk.bg:SetColorTexture(1, 1, 1, 0.035)
    end,
    place = function(page, blk, y)
        local top = y - CARD_HEADROOM - 4
        local xA, xB = 24, 24 + CARD_W + 44
        PlaceCard(blk, "a", page, blk[2], xA, top)
        PlaceCard(blk, "b", page, blk[3], xB, top)
        blk.vs:SetText("vs")
        blk.vs:ClearAllPoints()
        blk.vs:SetPoint("CENTER", page, "TOPLEFT", xA + CARD_W + 22, top - CARD_H / 2)
        blk.capA:SetText(L("rules.attacker"))
        blk.capA:ClearAllPoints()
        blk.capA:SetPoint("TOP", page, "TOPLEFT", xA + CARD_W / 2, top - CARD_H - 4)
        blk.capB:SetText(L("rules.blocker"))
        blk.capB:ClearAllPoints()
        blk.capB:SetPoint("TOP", page, "TOPLEFT", xB + CARD_W / 2, top - CARD_H - 4)
        local textX = xB + CARD_W + 24
        blk.text:SetWidth(CONTENT_W - textX - 12)
        blk.text:SetText(Text(blk[4]))
        blk.text:ClearAllPoints()
        blk.text:SetPoint("TOPLEFT", page, "TOPLEFT", textX, y - 10)
        local bottom = math.min(top - CARD_H - 4 - blk.capA:GetStringHeight(), y - 10 - blk.text:GetStringHeight()) - 8
        blk.bg:ClearAllPoints()
        blk.bg:SetPoint("TOPLEFT", page, "TOPLEFT", 6, y)
        blk.bg:SetPoint("BOTTOMRIGHT", page, "TOPRIGHT", -6, bottom)
        return bottom - 10
    end,
}

-- Two-column glossary of tooltip definitions, each with an example card where there is one:
-- { "glossary", "keyword", { { "flying", "WES04" }, { "sick" }, ... } }
-- Names and texts come from the tooltips (keyword.* / effect.*), already translated.
local TILE_GAP = 8
Blocks.glossary = {
    make = function(page, blk)
        blk.tiles = {}
        for i in ipairs(blk[3]) do
            local t = {}
            t.bg = page:CreateTexture(nil, "BACKGROUND")
            t.bg:SetColorTexture(1, 1, 1, 0.04)
            t.bar = page:CreateTexture(nil, "ARTWORK")
            t.bar:SetColorTexture(1, 0.82, 0, 0.6)
            t.bar:SetWidth(2)
            t.name = NewText(page, "GameFontNormal")
            t.text = NewText(page, "GameFontHighlightSmall")
            t.text:SetSpacing(2)
            blk.tiles[i] = t
        end
    end,
    place = function(page, blk, y)
        local colW = math.floor((CONTENT_W - 12 - TILE_GAP) / 2)
        local rowTop, rowH = y, 0
        for i, item in ipairs(blk[3]) do
            local t = blk.tiles[i]
            local col = (i - 1) % 2
            if col == 0 and i > 1 then
                rowTop = rowTop - rowH - TILE_GAP
                rowH = 0
            end
            local x = 6 + col * (colW + TILE_GAP)
            local hasCard = item[2] and PlaceCard(t, "card", page, item[2], x + 8, rowTop - CARD_HEADROOM)
            local textX = hasCard and (x + CARD_W + 18) or (x + 12)
            local textW = colW - (textX - x) - 8
            t.name:SetWidth(textW)
            t.name:SetText(Def(blk[2], item[1], "name"))
            t.name:ClearAllPoints()
            t.name:SetPoint("TOPLEFT", page, "TOPLEFT", textX, rowTop - 8)
            t.text:SetWidth(textW)
            t.text:SetText(FormatTextWithSymbols(Def(blk[2], item[1], "text"), 14))
            t.text:ClearAllPoints()
            t.text:SetPoint("TOPLEFT", t.name, "BOTTOMLEFT", 0, -3)
            local h = 8 + t.name:GetStringHeight() + 3 + t.text:GetStringHeight() + 8
            if hasCard then h = math.max(h, CARD_HEADROOM + CARD_H + 8) end
            t.x, t.h = x, h
            rowH = math.max(rowH, h)
            -- Both tiles in a row share its height: finish the row once it's full (or last)
            if col == 1 or i == #blk[3] then
                for j = i - col, i do
                    local u = blk.tiles[j]
                    u.bg:ClearAllPoints()
                    u.bg:SetPoint("TOPLEFT", page, "TOPLEFT", u.x, rowTop)
                    u.bg:SetSize(colW, rowH)
                    u.bar:ClearAllPoints()
                    u.bar:SetPoint("TOPLEFT", page, "TOPLEFT", u.x, rowTop)
                    u.bar:SetHeight(rowH)
                end
            end
        end
        return rowTop - rowH - SECTION_GAP
    end,
}

-- A plain button: { "button", "label.key", onClick }
Blocks.button = {
    make = function(page, blk)
        blk.btn = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
        blk.btn:SetHeight(24)
        blk.btn:SetScript("OnClick", blk[3])
    end,
    place = function(page, blk, y)
        blk.btn:SetText(L(blk[2]))
        blk.btn:SetWidth(math.max(160, blk.btn:GetFontString():GetStringWidth() + 40))
        blk.btn:ClearAllPoints()
        blk.btn:SetPoint("TOPLEFT", page, "TOPLEFT", 10, y)
        return y - 24 - SECTION_GAP
    end,
}

-- =========================================================================
-- PAGES
-- =========================================================================
local function OpenOther(frame)
    if not frame then return end
    frame:Show()
    if frame:IsShown() then R:Hide() end
end

local PAGES = {
    {
        key = "rules.tab.start", icon = "INV_Misc_Book_09",
        { "tldr", "rules.start.tldr" },
        { "h", "rules.start.h.win" },
        { "p", "rules.start.win" },
        { "h", "rules.start.h.kinds" },
        { "cards", { { "W01", "rules.start.c.prayer" }, { "ELW04", "rules.start.c.denizen" },
                     { "MAG01", "rules.start.c.spell" }, { "GEAR01", "rules.start.c.gear" } } },
        { "h", "rules.start.h.read" },
        { "anatomy", "WES05", "rules.start.read" },
        { "h", "rules.start.h.new" },
        { "p", "rules.start.new" },
        { "button", "tut.play", function() if TTS.StartTutorial then TTS:StartTutorial() end end },
        { "tip", "rules.start.tip" },
    },
    {
        key = "rules.tab.deck", icon = "INV_Misc_Book_11",
        { "tldr", "rules.deck.tldr" },
        { "stats", { { "40-50", "rules.deck.s.size" }, { "4", "rules.deck.s.copies" },
                     { "12", "rules.deck.s.spells" }, { "8", "rules.deck.s.gear" },
                     { "~17", "rules.deck.s.prayers" } } },
        { "h", "rules.deck.h.limits" },
        { "p", "rules.deck.limits" },
        { "h", "rules.deck.h.tips" },
        { "p", "rules.deck.tips" },
        { "tip", "rules.deck.tip" },
    },
    {
        key = "rules.tab.collect", icon = "INV_Misc_Bag_10",
        { "tldr", "rules.collect.tldr" },
        { "h", "rules.collect.h.prayers" },
        { "p", "rules.collect.prayers" },
        { "cards", { { "W01" }, { "PRY01" } } },
        { "h", "rules.collect.h.spells" },
        { "p", "rules.collect.spells" },
        { "cards", { { "WAR01" }, { "PRI01" }, { "HUN02" } } },
        { "h", "rules.collect.h.denizens" },
        { "p", "rules.collect.denizens" },
        { "cards", { { "WES01", "rules.collect.c.zone" }, { "BOSS01", "rules.collect.c.boss" } } },
        { "h", "rules.collect.h.dungeons" },
        { "p", "rules.collect.dungeons" },
        { "h", "rules.collect.h.hero" },
        { "p", "rules.collect.hero" },
        { "cards", { { "HERO" } } },
        { "h", "rules.collect.h.gear" },
        { "p", "rules.collect.gear" },
        { "cards", { { "GEAR01" }, { "GEAR02" } } },
        { "tip", "rules.collect.tip" },
    },
    {
        key = "rules.tab.mana", icon = "Spell_Holy_HolyBolt",
        { "tldr", "rules.mana.tldr" },
        { "h", "rules.mana.h.make" },
        { "p", "rules.mana.make" },
        { "h", "rules.mana.h.pay" },
        { "p", "rules.mana.pay" },
        { "h", "rules.mana.h.colours" },
        { "cards", { { "W01", "rules.mana.c.W" }, { "U01", "rules.mana.c.U" }, { "B01", "rules.mana.c.B" },
                     { "R01", "rules.mana.c.R" }, { "G01", "rules.mana.c.G" } } },
        { "h", "rules.mana.h.dual" },
        { "p", "rules.mana.dual" },
        { "cards", { { "PRY01" }, { "PRY02" } } },
    },
    {
        key = "rules.tab.turn", icon = "INV_Misc_PocketWatch_01",
        { "tldr", "rules.turn.tldr" },
        { "phases", { "rules.turn.p.start", "rules.turn.p.main1", "rules.turn.p.combat",
                      "rules.turn.p.main2", "rules.turn.p.end" } },
        { "h", "rules.turn.h.start" },
        { "p", "rules.turn.start" },
        { "h", "rules.turn.h.main1" },
        { "p", "rules.turn.main1" },
        { "h", "rules.turn.h.combat" },
        { "p", "rules.turn.combat" },
        { "h", "rules.turn.h.main2" },
        { "p", "rules.turn.main2" },
        { "h", "rules.turn.h.end" },
        { "p", "rules.turn.end" },
        { "h", "rules.turn.h.buttons" },
        { "p", "rules.turn.buttons" },
    },
    {
        key = "rules.tab.combat", icon = "INV_Sword_04",
        { "tldr", "rules.combat.tldr" },
        { "h", "rules.combat.h.attack" },
        { "p", "rules.combat.attack" },
        { "h", "rules.combat.h.block" },
        { "p", "rules.combat.block" },
        { "h", "rules.combat.h.damage" },
        { "p", "rules.combat.damage" },
        { "h", "rules.combat.h.examples" },
        { "versus", "WES05", "WES01", "rules.combat.ex1" },
        { "versus", "WES02", "WES01", "rules.combat.ex2" },
        { "versus", "WES04", "ARA03", "rules.combat.ex3" },
        { "tip", "rules.combat.tip" },
    },
    {
        key = "rules.tab.keywords", icon = "INV_Misc_Rune_01",
        { "tldr", "rules.keywords.tldr" },
        { "h", "rules.keywords.h.attack" },
        { "glossary", "keyword", {
            { "haste", "WES01" }, { "flying", "WES04" }, { "unblockable", "AZS01" }, { "trample", "WES05" },
            { "firstStrike", "WES02" }, { "deathtouch", "BRN08" }, { "lifelink", "BRD04" }, { "vigilance", "BRN05" },
        } },
        { "h", "rules.keywords.h.defend" },
        { "glossary", "keyword", {
            { "reach", "ARA03" }, { "defender", "WES03" }, { "bulwark", "SEA08" }, { "support", "WES09" },
            { "shielded", "PRI01" }, { "hexproof", "DAL06" },
        } },
        { "h", "rules.keywords.h.other" },
        { "glossary", "keyword", { { "kinsmanship", "BFD09" }, { "unique", "HERO" } } },
    },
    {
        key = "rules.tab.terms", icon = "INV_Scroll_03",
        { "tldr", "rules.terms.tldr" },
        { "h", "rules.terms.h.triggers" },
        { "glossary", "effect", {
            { "arrival", "BFD12" }, { "aggro", "BOSS11" }, { "martyrdom", "DAL17" }, { "activated", "BOSS08" },
        } },
        { "h", "rules.terms.h.board" },
        { "glossary", "effect", {
            { "spawn", "ELW02" }, { "token" }, { "anthem", "ELW11" }, { "gear", "GEAR01" },
        } },
        { "h", "rules.terms.h.effects" },
        { "glossary", "effect", {
            { "freeze", "HUN06" }, { "dot", "PRI07" }, { "hot", "PRI02" }, { "regen", "PAL04" },
            { "dispel" }, { "draw" },
        } },
        { "h", "rules.terms.h.states" },
        { "glossary", "effect", { { "sick" }, { "tapped" }, { "frozen" }, { "damaged" } } },
    },
    {
        key = "rules.tab.solo", icon = "INV_Misc_Map_01",
        { "tldr", "rules.solo.tldr" },
        { "button", "rules.solo.open", function() OpenOther(TTS.SoloSelectFrame) end },
        { "h", "rules.solo.h.how" },
        { "p", "rules.solo.how" },
        { "h", "rules.solo.h.zones" },
        { "p", "rules.solo.zones" },
        { "h", "rules.solo.h.dungeons" },
        { "p", "rules.solo.dungeons" },
        { "h", "rules.solo.h.rewards" },
        { "p", "rules.solo.rewards" },
        { "cards", { { "ELW11", "rules.solo.c.zone" }, { "DMS12", "rules.solo.c.dungeon" } } },
        { "tip", "rules.solo.tip" },
    },
    {
        key = "rules.tab.pvp", icon = "Ability_Warrior_BattleShout",
        { "tldr", "rules.pvp.tldr" },
        { "button", "rules.pvp.open", function() OpenOther(TTS.WaitingRoom and TTS.WaitingRoom.frame) end },
        { "h", "rules.pvp.h.find" },
        { "p", "rules.pvp.find" },
        { "h", "rules.pvp.h.versions" },
        { "p", "rules.pvp.versions" },
        { "h", "rules.pvp.h.connection" },
        { "p", "rules.pvp.connection" },
        { "h", "rules.pvp.h.links" },
        { "p", "rules.pvp.links" },
        { "tip", "rules.pvp.tip" },
        { "cards", { { "WES10" } } },
    },
}

-- =========================================================================
-- TABS
-- =========================================================================
local tabs = {}
local current = 1
local SelectTab

local function BuildPage(i)
    local page = PAGES[i]
    if page.frame then return page.frame end
    local f = CreateFrame("Frame", nil, scrollFrame)
    f:SetSize(CONTENT_W, 100)
    f:Hide()
    for _, blk in ipairs(page) do Blocks[blk[1]].make(f, blk) end
    -- "Next: <tab>" at the bottom of every page but the last
    if PAGES[i + 1] then
        f.nextBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        f.nextBtn:SetHeight(24)
        f.nextBtn:SetScript("OnClick", function() SelectTab(i + 1) end)
    end
    page.frame = f
    return f
end

local function LayoutPage(i)
    local page, f = PAGES[i], PAGES[i].frame
    local y = -10
    for _, blk in ipairs(page) do y = Blocks[blk[1]].place(f, blk, y) end
    if f.nextBtn then
        f.nextBtn:SetText(L("rules.next", L(PAGES[i + 1].key)))
        f.nextBtn:SetWidth(f.nextBtn:GetFontString():GetStringWidth() + 40)
        f.nextBtn:ClearAllPoints()
        f.nextBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, y)
        y = y - 24 - 10
    end
    f:SetHeight(math.abs(y))
end

local function PaintTab(b, selected)
    b.sel:SetShown(selected)
    b.bar:SetShown(selected)
    b.text:SetFontObject(selected and "GameFontHighlight" or "GameFontNormal")
    b.icon:SetDesaturated(not selected)
    b.icon:SetAlpha(selected and 1 or 0.75)
end

SelectTab = function(i)
    if PAGES[current].frame then PAGES[current].frame:Hide() end
    current = i
    for j, b in ipairs(tabs) do PaintTab(b, j == i) end
    local f = BuildPage(i)
    scrollFrame:SetScrollChild(f)
    f:Show()
    LayoutPage(i)
    scrollFrame:SetVerticalScroll(0)
    HideRulesPreview()
end

local TAB_H = 34
for i, page in ipairs(PAGES) do
    local b = CreateFrame("Button", nil, navPanel)
    b:SetSize(NAV_W - 12, TAB_H)
    b:SetPoint("TOPLEFT", navPanel, "TOPLEFT", 6, -6 - (i - 1) * (TAB_H + 2))

    b.bg = b:CreateTexture(nil, "BACKGROUND")
    b.bg:SetAllPoints()
    b.bg:SetColorTexture(1, 1, 1, 0.03)
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

    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetSize(24, 24)
    b.icon:SetPoint("LEFT", 8, 0)
    b.icon:SetTexture("Interface\\Icons\\" .. page.icon)
    b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    b.text:SetPoint("LEFT", b.icon, "RIGHT", 8, 0)
    b.text:SetPoint("RIGHT", b, "RIGHT", -4, 0)
    b.text:SetJustifyH("LEFT")
    b.text:SetWordWrap(true)
    Loc:Bind(b.text, page.key)

    b:SetScript("OnClick", function() SelectTab(i) end)
    tabs[i] = b
    PaintTab(b, false)
end

-- Reopens on the tab you last read
R:SetScript("OnShow", function() SelectTab(current) end)
R:SetScript("OnHide", HideRulesPreview)
