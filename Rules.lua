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

local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local R = CreateFrame("Frame", "TTS_RulesFrame", UIParent, backdropTemplate)
TTS.RulesFrame = R

R:SetSize(620, 640)
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
-- If your file is T.tga, change ".png" to ".tga" below:
local TAP_TEX = SYMBOL_PATH .. "T.png"

local function FormatTextWithSymbols(str, size)
    if not str or str == "" then return "" end
    local s = size or 16

    -- Format Tap directly using your disk symbol
    local tapTexture = string.format("|T%s:%d:%d:0:0|t", TAP_TEX, s, s)
    str = str:gsub("{[tT]}", tapTexture)
    str = str:gsub("{[tT][aA][pP]}", tapTexture)

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
            return string.format("|cFF8E939B(|r|cFFFFFFFF%s|r|cFF8E939B)|r", upperKey)
        end
        local icon = defaultIcons[upperKey]
        if icon then
            return string.format("|T%s:%d:%d:0:0|t", icon, s, s)
        end
        return "(" .. upperKey .. ")"
    end)
end

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

-- Close Button
local closeBtn = CreateFrame("Button", nil, R, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -2, -2)
closeBtn:SetScript("OnClick", function() R:Hide() end)

-- Panel holding the scrolling rules
local rulesPanel = CreateFrame("Frame", nil, R, backdropTemplate)
rulesPanel:SetPoint("TOPLEFT", 14, -46)
rulesPanel:SetPoint("BOTTOMRIGHT", -14, 34)
rulesPanel:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
rulesPanel:SetBackdropColor(0.04, 0.04, 0.04, 0.70)
rulesPanel:SetBackdropBorderColor(0.60, 0.56, 0.48, 1)

-- Scroll Frame & Content Container
local scrollFrame = CreateFrame("ScrollFrame", "TTS_RulesScrollFrame", rulesPanel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", rulesPanel, "TOPLEFT", 6, -8)
scrollFrame:SetPoint("BOTTOMRIGHT", rulesPanel, "BOTTOMRIGHT", -28, 8)

local content = CreateFrame("Frame", "TTS_RulesContent", scrollFrame)
local CONTENT_W = 550
content:SetWidth(CONTENT_W)
content:SetHeight(100)
scrollFrame:SetScrollChild(content)

-- =========================================================================
-- EXACT IN-GAME CARD BUILDER (Matching Board.lua & DeckBuilder.lua)
-- =========================================================================
local function SetupRuleCard(f, cardId)
    local card = TTS.Cards and TTS.Cards[cardId]
    if not card then return end

    f.cardId = cardId
    f.currentCard = card

    -- 1. Setup Artwork or 3D Model exactly like Board.lua
    if TTS.SetupCardVisual then
        TTS.SetupCardVisual(f, card)
    else
        if card.displayId and f.model then
            f.art:Hide()
            f.model:Show()
            f.model:ClearModel()
            f.model:SetDisplayInfo(card.displayId)
            local cam = card.modelCam or {}
            if f.model.SetPortraitZoom then f.model:SetPortraitZoom(cam.zoom or 0.75) end
            if f.model.SetCamDistanceScale then f.model:SetCamDistanceScale(cam.camScale or 1.0) end
            if f.model.SetPosition then f.model:SetPosition(cam.x or 0, cam.y or 0, cam.z or -0.10) end
            if f.model.SetRotation then f.model:SetRotation(cam.rotation or 0.15) end
        else
            if f.model then f.model:Hide() end
            f.art:Show()
            f.art:SetTexture(card.art or "Interface\\Icons\\INV_Misc_QuestionMark")
            if TTS.TintArt then TTS.TintArt(f.art, card) end
        end
    end

    -- 2. Apply Colored Outer Frame
    if TTS.ApplyFrameTexture then
        TTS.ApplyFrameTexture(f.border, card)
    elseif TTS.GetCardFrameTexture then
        f.border:SetTexture(TTS.GetCardFrameTexture(card))
    end
    f.border:SetVertexColor(1, 1, 1, 1)

    -- 3. Card Title
    if f.title then
        f.title:SetText(TTS:CardName(card) or "")
    end

    -- 4. Cost String
    if f.cost then
        if card.cost and card.cost ~= "" then
            f.cost:SetText(FormatTextWithSymbols(card.cost, 16))
            f.cost:Show()
        else
            f.cost:Hide()
        end
    end

    -- 5. Power / Toughness
    if f.pt then TTS.ShowPrintedStats(f, card) end

    f:Show()

    -- 6. Rules text printed on the card, same as on the board
    if f.rules and TTS.UpdateCardRules then
        TTS.UpdateCardRules(f)
    end
end

-- =========================================================================
-- CARD PREVIEW
-- Full-size copy of the hovered example card, docked outside the left edge
-- of the window (same as the Deckbuilder and the board).
-- =========================================================================
local PREVIEW_W, PREVIEW_H = 150, 212
local PREVIEW_RULES = {
    fontMax = 11,
    fontMin = 8,
    offsetX = 3,   -- pixels right
    offsetY = 3,   -- pixels down
}

local previewCard

local function ShowRulesPreview(card)
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
    local f = previewCard

    -- Card name and cost sit above the frame, so leave room for them
    f:ClearAllPoints()
    f:SetPoint("TOPRIGHT", R, "TOPLEFT", -12, -76)

    if TTS.SetupCardVisual then TTS.SetupCardVisual(f, card) end
    f.currentCard = card
    if TTS.ApplyFrameTexture then TTS.ApplyFrameTexture(f.border, card) end
    f.border:SetVertexColor(1, 1, 1, 1)
    f.title:SetText(TTS:CardName(card) or "")

    if card.cost and card.cost ~= "" then
        f.cost:SetText(FormatTextWithSymbols(card.cost, 18))
        f.cost:Show()
    else
        f.cost:Hide()
    end

    TTS.ShowPrintedStats(f, card)

    f:Show()
    if TTS.UpdateCardRules then TTS.UpdateCardRules(f, PREVIEW_RULES) end
end

local function HideRulesPreview()
    if previewCard then previewCard:Hide() end
end

local function CreateExampleCard(parent, cardId)
    local cardW, cardH = 72, 102
    local f = nil

    if TTS.CreateCardFrame then
        f = TTS.CreateCardFrame(parent, cardW, cardH)
    else
        f = CreateFrame("Button", nil, parent)
        f:SetSize(cardW, cardH)

        f.bg = f:CreateTexture(nil, "BACKGROUND")
        f.bg:SetAllPoints(f)
        f.bg:SetColorTexture(0.08, 0.08, 0.08, 0.95)

        f.art = f:CreateTexture(nil, "ARTWORK")
        f.art:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -6)
        f.art:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -4, 45)

        f.model = CreateFrame("PlayerModel", nil, f)
        f.model:SetAllPoints(f.art)
        f.model:EnableMouse(false)
        f.model:Hide()

        f.overlay = CreateFrame("Frame", nil, f)
        f.overlay:SetAllPoints(f)
        f.overlay:EnableMouse(false)

        f.border = f.overlay:CreateTexture(nil, "OVERLAY")
        f.border:SetAllPoints(f.overlay)

        f.title = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        f.title:SetPoint("BOTTOMLEFT", f.overlay, "TOPLEFT", -6, 2)
        f.title:SetPoint("BOTTOMRIGHT", f.overlay, "TOPRIGHT", 6, 2)
        f.title:SetJustifyH("CENTER")

        f.cost = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        f.cost:SetPoint("BOTTOM", f.title, "TOP", 0, 1)
        f.cost:SetJustifyH("CENTER")

        f.pt = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        f.pt:SetPoint("BOTTOM", f.overlay, "BOTTOM", 0, 16)
        f.pt:SetJustifyH("CENTER")
    end

    f:SetFrameLevel(parent:GetFrameLevel() + 2)
    -- The shared card frame hides its cost whenever the card is hidden (for the board's hand);
    -- rule example cards keep their cost, so drop that handler here
    f:SetScript("OnHide", nil)
    f:EnableMouse(true)
    f:RegisterForClicks("LeftButtonUp")

    -- Preview and tooltip (UI\Tooltips.lua) when hovering over rule examples
    f:SetScript("OnEnter", function(self)
        local card = TTS.Cards and TTS.Cards[self.cardId]
        if not card then return end
        ShowRulesPreview(card)
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

    SetupRuleCard(f, cardId)
    return f
end

-- =========================================================================
-- TEXT ELEMENTS
-- =========================================================================
-- Section heading (locale key) with a thin gold divider underneath
local function MakeHeading(key)
    local h = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    Loc:Bind(h, key)
    h.rule = content:CreateTexture(nil, "ARTWORK")
    h.rule:SetHeight(1)
    h.rule:SetColorTexture(1, 0.82, 0, 0.30)
    return h
end

local h1 = MakeHeading("rules.h.overview")

local p1 = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
p1:SetWidth(540)
p1:SetJustifyH("LEFT")
p1:SetWordWrap(true)
p1.rawKey = "rules.overview"

local hU = MakeHeading("rules.h.unlocking")

local pU = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
pU:SetWidth(540)
pU:SetJustifyH("LEFT")
pU:SetWordWrap(true)
pU.rawKey = "rules.unlocking"

local h2 = MakeHeading("rules.h.colours")

local p2 = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
p2:SetWidth(540)
p2:SetJustifyH("LEFT")
p2:SetWordWrap(true)
p2.rawKey = "rules.colours"

local h3 = MakeHeading("rules.h.turns")

local p3 = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
p3:SetWidth(540)
p3:SetJustifyH("LEFT")
p3:SetWordWrap(true)
p3.rawKey = "rules.turns"

local h4 = MakeHeading("rules.h.keywords")

local p4 = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
p4:SetWidth(540)
p4:SetJustifyH("LEFT")
p4:SetWordWrap(true)
p4.rawKey = "rules.keywords"

local hS = MakeHeading("rules.h.solo")

local pS = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
pS:SetWidth(540)
pS:SetJustifyH("LEFT")
pS:SetWordWrap(true)
pS.rawKey = "rules.solo"

local hL = MakeHeading("rules.h.links")

local pL = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
pL:SetWidth(540)
pL:SetJustifyH("LEFT")
pL:SetWordWrap(true)
pL.rawKey = "rules.links"

local h5 = MakeHeading("rules.h.challenging")

local p5 = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
p5:SetWidth(540)
p5:SetJustifyH("LEFT")
p5:SetWordWrap(true)
p5.rawKey = "rules.challenging"

-- Footer is pinned to the bottom of the window (outside the scroll area), like the title at the top
local footer = R:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
footer:SetPoint("BOTTOMRIGHT", R, "BOTTOMRIGHT", -20, 15)
footer:SetText("Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy")

-- Card Frame containers
local landFrames = {}
local unlockFrames = {}
local kwFrames = {}
local soloFrames = {}

-- =========================================================================
-- DYNAMIC LAYOUT & VISUAL REFRESH
-- =========================================================================
local CARD_W, CARD_H  = 72, 102
local CARD_GAP        = 40  -- space between example cards in a row
local CARD_HEADROOM   = 32  -- room for the name and cost shown above each card
local SECTION_GAP     = 22  -- space before the next heading

local function PlaceHeading(h, y)
    h:ClearAllPoints()
    h:SetPoint("TOPLEFT", content, "TOPLEFT", 10, y)
    y = y - (h:GetStringHeight() + 4)
    h.rule:ClearAllPoints()
    h.rule:SetPoint("TOPLEFT", content, "TOPLEFT", 10, y)
    h.rule:SetPoint("TOPRIGHT", content, "TOPRIGHT", -10, y)
    return y - 8
end

local function PlaceParagraph(p, y)
    p:ClearAllPoints()
    p:SetPoint("TOPLEFT", content, "TOPLEFT", 10, y)
    return y - p:GetStringHeight()
end

-- A row of example cards, centred across the content width
local function PlaceCardRow(frames, ids, y)
    y = y - CARD_HEADROOM
    local n = #ids
    local x = (CONTENT_W - (n * CARD_W + (n - 1) * CARD_GAP)) / 2
    for i, id in ipairs(ids) do
        if not frames[i] then
            frames[i] = CreateExampleCard(content, id)
        else
            SetupRuleCard(frames[i], id)
        end
        frames[i]:ClearAllPoints()
        frames[i]:SetPoint("TOPLEFT", content, "TOPLEFT", x + (i - 1) * (CARD_W + CARD_GAP), y)
    end
    return y - CARD_H
end

local function LayoutRules()
    for _, p in ipairs({ p1, p2, p3, p4, pU, p5, pS, pL }) do
        p:SetText(FormatTextWithSymbols(L(p.rawKey), 16))
    end

    local y = -10

    -- Section 1: Overview
    y = PlaceHeading(h1, y)
    y = PlaceParagraph(p1, y) - SECTION_GAP

    -- Section 1b: Unlocking Cards, with a zone creature, a dungeon boss and a class spell
    y = PlaceHeading(hU, y)
    y = PlaceParagraph(pU, y)
    y = PlaceCardRow(unlockFrames, { "WES01", "BOSS01", "WAR01" }, y) - SECTION_GAP

    -- Section 2: Colours of Mana, with one Prayer of each colour
    y = PlaceHeading(h2, y)
    y = PlaceParagraph(p2, y)
    y = PlaceCardRow(landFrames, { "W01", "U01", "B01", "R01", "G01" }, y) - SECTION_GAP

    -- Section 3: Turn Sequence
    y = PlaceHeading(h3, y)
    y = PlaceParagraph(p3, y) - SECTION_GAP

    -- Section 4: Keywords & Mechanics, with keyword creatures
    y = PlaceHeading(h4, y)
    y = PlaceParagraph(p4, y)
    y = PlaceCardRow(kwFrames, { "WES04", "WES02", "DSK06", "WES05" }, y) - SECTION_GAP

    -- Section 5: Solo Mode, with a zone reward and a dungeon reward
    y = PlaceHeading(hS, y)
    y = PlaceParagraph(pS, y)
    y = PlaceCardRow(soloFrames, { "ELW11", "DMS12" }, y) - SECTION_GAP

    -- Section 5b: Card Links
    y = PlaceHeading(hL, y)
    y = PlaceParagraph(pL, y) - SECTION_GAP

    -- Section 6: Challenging Players
    y = PlaceHeading(h5, y)
    y = PlaceParagraph(p5, y) - 16

    content:SetHeight(math.abs(y))
end

R:SetScript("OnShow", function()
    LayoutRules()
end)