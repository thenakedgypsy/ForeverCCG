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
-- ENDLESS WINDOW (Systems\Endless.lua)
-- One window whose middle follows the run's stage:
--   no run   the best run, pack charges, the last run's result, Start Run
--   draft    X.OFFER_SIZE cards to pick from, a pip per pick (the rare picks marked)
--   prayers  a column per colour (its pips among the picks, a stepper), summing to 8
--   ready    the run screen: the milestone track, the next opponent (its background, life,
--            AI), the fight's rules, charges; Fight, View Deck, Abandon Run
--   reward   X.OFFER_SIZE cards from the beaten encounter, +1 Prayer of any colour, or Skip
-- The header shows the best run and the pack charges (a pack per charge); the run's deck is
-- on the right with its mana curve (hover a line for the card).
-- =========================================================================
local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local GOLD, GREY, RED, GREEN, ORANGE = "|cFFFFD200", "|cFF8A8A8A", "|cFFFF4444", "|cFF33DD33", "|cFFFF8040"
local CURSE_COLOR, TWIST_COLOR = "|cFFFF6060", "|cFF66BBFF"

local X = TTS.Endless
local OFFER = X.OFFER_SIZE or 5

local WIN_W, WIN_H = 980, 600
local DECK_W = 220
local MAIN_W = WIN_W - DECK_W - 52
local MAIN_TOP = -48
local MAIN_H = WIN_H - 48 - 58
local CARD_SCALE = 0.85
local CARD_GAP = 12
local CARDS_Y = -74
local LINE_H = 15
local GLOW_TEX = "Interface\\Buttons\\UI-ActionButton-Border"
local PACK_TEX = "Interface\\AddOns\\ForeverCCG\\Textures\\Packs\\pack_dungeon_closed.png"
local SKULL_ICON = "Interface\\Icons\\INV_Misc_Bone_HumanSkull_01"

-- Card names in their colour (the deck list)
local NAME_COLOR = { W = "FFF2D9", U = "7FB8FF", B = "C48BFF", R = "FF7A5C", G = "7FE07F", C = "C8C8C8" }

local F = CreateFrame("Frame", "TTS_EndlessFrame", UIParent, backdropTemplate)
TTS.EndlessFrame = F
F:SetSize(WIN_W, WIN_H)
F:SetPoint("CENTER")
F:SetClampedToScreen(true)
F:SetFrameStrata("DIALOG")
F:SetToplevel(true)
F:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
F:EnableMouse(true)
F:SetMovable(true)
F:RegisterForDrag("LeftButton")
F:SetScript("OnDragStart", F.StartMoving)
F:SetScript("OnDragStop", F.StopMovingOrSizing)
F:Hide()
tinsert(UISpecialFrames, "TTS_EndlessFrame")

do
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
end

local title = F:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
Loc:Bind(title, "endless.title")
local runText = F:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
runText:SetPoint("LEFT", title, "RIGHT", 12, -1)

local closeBtn = CreateFrame("Button", nil, F, "UIPanelCloseButton")
closeBtn:SetScript("OnClick", TTS.CloseParent)
closeBtn:SetPoint("TOPRIGHT", -2, -2)

local footer = F:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
footer:SetPoint("BOTTOMRIGHT", F, "BOTTOMRIGHT", -20, 14)
footer:SetText("Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy")

local function PanelButton(parent, w, h, key, font)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(w, h)
    b:SetNormalFontObject(font or "GameFontNormalSmall")
    b:SetHighlightFontObject(font == "GameFontNormal" and "GameFontHighlight" or "GameFontHighlightSmall")
    b:SetDisabledFontObject(font == "GameFontNormal" and "GameFontDisable" or "GameFontDisableSmall")
    if key then Loc:Bind(b, key) end
    return b
end

local function Panel(parent, w, h)
    local p = CreateFrame("Frame", nil, parent, backdropTemplate)
    p:SetSize(w, h)
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

-- A gold section header and divider at the top of a panel
local function PanelHeader(p, key)
    local h = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    h:SetPoint("TOPLEFT", 10, -9)
    if key then Loc:Bind(h, key) end
    local line = p:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", 8, -24)
    line:SetPoint("TOPRIGHT", -8, -24)
    line:SetHeight(1)
    line:SetColorTexture(1, 0.82, 0, 0.30)
    return h
end

local function Sym(s, size) return TTS.FormatSymbols and TTS:FormatSymbols(s, size or 14) or s end

local AI_LABEL = setmetatable({}, { __index = function(_, ai) return Loc:Data("solo.ai." .. tostring(ai), ai) end })

-- =========================================================================
-- HEADER: best run and the pack charges, a pack per charge
-- =========================================================================
local chargeIcons = {}
local chargeHover = CreateFrame("Frame", nil, F)
chargeHover:SetSize(7 * 16 + 4, 22)
chargeHover:SetPoint("TOPRIGHT", F, "TOPRIGHT", -36, -14)
chargeHover:EnableMouse(true)
for i = 1, X.MAX_CHARGES do
    local t = chargeHover:CreateTexture(nil, "OVERLAY")
    t:SetTexture(PACK_TEX)
    t:SetSize(14, 20)
    t:SetPoint("RIGHT", chargeHover, "RIGHT", -(X.MAX_CHARGES - i) * 16, 0)
    chargeIcons[i] = t
end
local chargeLabel = F:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
chargeLabel:SetPoint("RIGHT", chargeHover, "LEFT", -4, 0)
local bestLabel = F:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
bestLabel:SetPoint("RIGHT", chargeLabel, "LEFT", -18, 0)

local function ChargesText()
    local n = X:Charges()
    local wait = X:NextChargeWait()
    if wait then return L("endless.chargesNext", n, X.MAX_CHARGES, TTS:FormatWait(wait)) end
    return L("endless.charges", n, X.MAX_CHARGES)
end

local function PaintHeader()
    local n = X:Charges()
    for i, t in ipairs(chargeIcons) do
        local have = i <= n
        if t.SetDesaturated then t:SetDesaturated(not have) end
        t:SetAlpha(have and 1 or 0.35)
    end
    chargeLabel:SetText(L("endless.chargesShort"))
    bestLabel:SetText(L("endless.bestShort", GOLD .. X:Best() .. "|r"))
    local run = X:Run()
    runText:SetText(run and run.stage ~= "draft" and run.stage ~= "prayers"
        and L("endless.runWins", (run.fight or 1) - 1) or "")
end

chargeHover:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
    GameTooltip:SetText(L("endless.chargesTipTitle"), 1, 0.82, 0)
    GameTooltip:AddLine(ChargesText(), 1, 1, 1)
    GameTooltip:AddLine(L("endless.chargesTip"), 0.8, 0.8, 0.8, true)
    GameTooltip:Show()
end)
chargeHover:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- =========================================================================
-- HOVER PREVIEW (docked to the left of the window, as the solo map's)
-- =========================================================================
local preview
local function ShowPreview(cardId)
    local card = cardId and TTS.Cards[cardId]
    if not card or not TTS.CreateCardFrame then return end
    if not preview then
        preview = TTS.CreateCardFrame(F, TTS.PREVIEW_W, TTS.PREVIEW_H)
        preview:SetFrameStrata("DIALOG")
        preview:SetFrameLevel(F:GetFrameLevel() + 40)
        preview:SetClampedToScreen(true)
        preview:EnableMouse(false)
        preview:SetScript("OnEnter", nil)
        preview:SetScript("OnLeave", nil)
        preview:ClearAllPoints()
        preview:SetPoint("TOPRIGHT", F, "TOPLEFT", -12, -50)
    end
    TTS.PaintPreviewCard(preview, card, card.alwaysFoil)
    preview:Show()
end
local function HidePreview() if preview then preview:Hide() end end

-- =========================================================================
-- DECK PANEL (right): colours, mana curve, the list
-- =========================================================================
local deckPanel = Panel(F, DECK_W, MAIN_H)
deckPanel:SetPoint("TOPRIGHT", F, "TOPRIGHT", -20, MAIN_TOP)
local deckHeader = PanelHeader(deckPanel)
local deckColors = deckPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
deckColors:SetPoint("TOPRIGHT", -10, -8)

-- The Deckbuilder's mana curve and colour distribution (UI\DeckStats.lua), stacked at the
-- bottom of the panel
local deckStats = TTS.CreateDeckStats(deckPanel, DECK_W - 16, true)
deckStats.frame:SetPoint("BOTTOMLEFT", deckPanel, "BOTTOMLEFT", 8, 8)

local scroll = CreateFrame("ScrollFrame", "TTS_EndlessDeckScroll", deckPanel, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", 8, -30)
scroll:SetPoint("BOTTOMRIGHT", deckStats.frame, "TOPRIGHT", -20, 4)
local scrollChild = CreateFrame("Frame", nil, scroll)
scrollChild:SetSize(DECK_W - 40, 10)
scroll:SetScrollChild(scrollChild)

local deckLines = {}
local function DeckLine(i)
    local b = deckLines[i]
    if b then return b end
    b = CreateFrame("Button", nil, scrollChild)
    b:SetSize(DECK_W - 40, LINE_H)
    b:SetPoint("TOPLEFT", 0, -(i - 1) * LINE_H)
    b.cost = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    b.cost:SetPoint("RIGHT", b, "RIGHT", -2, 0)
    b.cost:SetJustifyH("RIGHT")
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    b.text:SetPoint("LEFT", b, "LEFT", 2, 0)
    b.text:SetPoint("RIGHT", b.cost, "LEFT", -4, 0)
    b.text:SetJustifyH("LEFT")
    if b.text.SetWordWrap then b.text:SetWordWrap(false) end
    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.12)
    b:SetScript("OnEnter", function(self) ShowPreview(self.cardId) end)
    b:SetScript("OnLeave", HidePreview)
    deckLines[i] = b
    return b
end

-- Denizens by cost, then spells, then Prayers
local function SortKey(card)
    local group = card.type == "Creature" and 1 or (card.type == "Land" and 3 or 2)
    return group, card.cmc or 0
end

local function FillDeck(list)
    list = list or {}
    local counts, ids = {}, {}
    for _, id in ipairs(list) do
        if not counts[id] then ids[#ids + 1] = id end
        counts[id] = (counts[id] or 0) + 1
    end
    deckStats:Update(counts)
    table.sort(ids, function(a, b)
        local ca, cb = TTS.Cards[a], TTS.Cards[b]
        if not (ca and cb) then return a < b end
        local ga, ma = SortKey(ca)
        local gb, mb = SortKey(cb)
        if ga ~= gb then return ga < gb end
        if ma ~= mb then return ma < mb end
        return TTS:CardName(ca) < TTS:CardName(cb)
    end)
    for i, id in ipairs(ids) do
        local b = DeckLine(i)
        local card = TTS.Cards[id]
        b.cardId = id
        local color = NAME_COLOR[card and card.color or "C"] or NAME_COLOR.C
        b.text:SetText(string.format("|cFF999999%dx|r |cFF%s%s|r", counts[id], color, card and TTS:CardName(card) or id))
        b.cost:SetText(card and card.cost and Sym(card.cost, 11) or "")
        b:Show()
    end
    for i = #ids + 1, #deckLines do deckLines[i]:Hide() end
    scrollChild:SetHeight(math.max(10, #ids * LINE_H))
    deckHeader:SetText(L("endless.deck", #list))
    local cols = {}
    local set = X.ColorsOf(list)
    for _, col in ipairs(X.COLORS) do
        if set[col] then cols[#cols + 1] = "{" .. col .. "}" end
    end
    deckColors:SetText(Sym(table.concat(cols, ""), 13))
end

-- =========================================================================
-- MAIN AREA: a title and a line under it, then the stage's own parts
-- =========================================================================
local main = CreateFrame("Frame", nil, F)
main:SetPoint("TOPLEFT", F, "TOPLEFT", 20, MAIN_TOP)
main:SetSize(MAIN_W, MAIN_H)

local stageTitle = main:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
stageTitle:SetPoint("TOPLEFT", main, "TOPLEFT", 4, -4)
local stageBadge = main:CreateFontString(nil, "OVERLAY", "GameFontNormal")
stageBadge:SetPoint("LEFT", stageTitle, "RIGHT", 10, 0)
local stageSub = main:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
stageSub:SetPoint("TOPLEFT", stageTitle, "BOTTOMLEFT", 0, -4)
stageSub:SetWidth(MAIN_W - 8)
stageSub:SetJustifyH("LEFT")

local hint = F:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
hint:SetPoint("BOTTOMLEFT", F, "BOTTOMLEFT", 24, 52)
hint:SetWidth(MAIN_W - 8)
hint:SetJustifyH("LEFT")

-- Pips along the top right: one per draft pick (rare picks ringed in orange)
local pickPips = {}
for i = 1, X.DRAFT_PICKS do
    local p = main:CreateTexture(nil, "ARTWORK")
    p:SetSize(12, 12)
    p:SetPoint("TOPRIGHT", main, "TOPRIGHT", -4 - (X.DRAFT_PICKS - i) * 16, -8)
    local ring = main:CreateTexture(nil, "BORDER")
    ring:SetSize(16, 16)
    ring:SetPoint("CENTER", p, "CENTER")
    ring:SetColorTexture(1, 0.5, 0.15, 0.9)
    p.ring = ring
    p:Hide(); ring:Hide()
    pickPips[i] = p
end

local function ShowPickPips(done)
    for i, p in ipairs(pickPips) do
        if done then
            if i <= done then p:SetColorTexture(1, 0.82, 0, 1)
            elseif i == done + 1 then p:SetColorTexture(1, 1, 1, 0.9)
            else p:SetColorTexture(0.25, 0.25, 0.25, 1) end
            p:Show()
            p.ring:SetShown(X.RARE_PICKS[i] and true or false)
        else
            p:Hide(); p.ring:Hide()
        end
    end
end

-- The cards on offer (a draft pick, or a reward): full-size card frames, scaled down
local cardW, cardH = TTS.PREVIEW_W or 150, TTS.PREVIEW_H or 212
local cards = {}
for i = 1, OFFER do
    local b = CreateFrame("Button", nil, main)
    b:SetSize(cardW, cardH)
    b:SetScale(CARD_SCALE)
    local rowW = OFFER * cardW * CARD_SCALE + (OFFER - 1) * CARD_GAP
    b.x = ((MAIN_W - rowW) / 2 + (i - 1) * (cardW * CARD_SCALE + CARD_GAP)) / CARD_SCALE
    b.y = CARDS_Y / CARD_SCALE
    b:SetPoint("TOPLEFT", main, "TOPLEFT", b.x, b.y)
    b.glow = b:CreateTexture(nil, "BACKGROUND")
    b.glow:SetTexture(GLOW_TEX)
    b.glow:SetBlendMode("ADD")
    b.glow:SetPoint("TOPLEFT", -30, 36)
    b.glow:SetPoint("BOTTOMRIGHT", 30, -36)
    b.glow:SetVertexColor(1, 0.82, 0)
    b.glow:Hide()
    b.badge = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    b.badge:SetPoint("BOTTOM", b, "TOP", 0, 4)
    -- Hovered: lifts a little and glows
    b:SetScript("OnEnter", function(self)
        self.glow:Show()
        self:SetPoint("TOPLEFT", main, "TOPLEFT", self.x, self.y + 8)
    end)
    b:SetScript("OnLeave", function(self)
        self.glow:Hide()
        self:SetPoint("TOPLEFT", main, "TOPLEFT", self.x, self.y)
    end)
    b:Hide()
    cards[i] = b
end

local function ShowCards(list, badges, onClick)
    for i, b in ipairs(cards) do
        local id = list and list[i]
        local card = id and TTS.Cards[id]
        if card and TTS.CreateCardFrame then
            if not b.face then
                b.face = TTS.CreateCardFrame(b, cardW, cardH)
                b.face:ClearAllPoints()
                b.face:SetPoint("CENTER")
                b.face:EnableMouse(false)
                b.face:SetScript("OnEnter", nil)
                b.face:SetScript("OnLeave", nil)
            end
            TTS.PaintPreviewCard(b.face, card, card.alwaysFoil)
            b.face:Show()
            b.badge:SetText(badges and badges[i] or "")
            b.glow:Hide()
            b:SetPoint("TOPLEFT", main, "TOPLEFT", b.x, b.y)
            b:SetScript("OnClick", function() if onClick then onClick(i) end end)
            b:Show()
        else
            b:Hide()
        end
    end
end

-- =========================================================================
-- PRAYER COLUMNS: the Prayer steppers, and the reward's +1 Prayer
-- =========================================================================
local COL_W, COL_H, COL_GAP = 112, 168, 12
local colorRow = CreateFrame("Frame", nil, main)
colorRow:SetSize(MAIN_W, COL_H + 30)
colorRow:Hide()
local colorLabel = colorRow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
colorLabel:SetPoint("TOP", colorRow, "TOP", 0, 0)
local columns = {}
for i, col in ipairs(X.COLORS) do
    local c = Panel(colorRow, COL_W, COL_H)
    local rowW = #X.COLORS * COL_W + (#X.COLORS - 1) * COL_GAP
    c:SetPoint("TOPLEFT", colorRow, "TOPLEFT", (MAIN_W - rowW) / 2 + (i - 1) * (COL_W + COL_GAP), -22)
    c.col = col
    c.icon = c:CreateTexture(nil, "ARTWORK")
    c.icon:SetSize(40, 40)
    c.icon:SetPoint("TOP", 0, -12)
    local prayer = TTS.Cards[X.PRAYER_IDS[col]]
    if prayer and prayer.art then c.icon:SetTexture(prayer.art) end
    c.name = c:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    c.name:SetPoint("TOP", c.icon, "BOTTOM", 0, -3)
    c.name:SetWidth(COL_W - 10)
    if c.name.SetWordWrap then c.name:SetWordWrap(false) end
    c.count = c:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    c.count:SetPoint("TOP", c.name, "BOTTOM", 0, -4)
    c.pips = c:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    c.pips:SetPoint("TOP", c.count, "BOTTOM", 0, -3)
    c.minus = PanelButton(c, 30, 22)
    c.minus:SetText("-")
    c.minus:SetPoint("BOTTOMLEFT", c, "BOTTOMLEFT", 12, 10)
    c.plus = PanelButton(c, 30, 22)
    c.plus:SetText("+")
    c.plus:SetPoint("BOTTOMRIGHT", c, "BOTTOMRIGHT", -12, 10)
    -- In the reward: one button that takes a Prayer of this colour
    c.take = PanelButton(c, COL_W - 20, 22)
    c.take:SetPoint("BOTTOM", c, "BOTTOM", 0, 10)
    c.take:Hide()
    columns[i] = c
end

-- =========================================================================
-- RUN SCREEN PARTS: the milestone track, the opponent, the rules
-- =========================================================================
local TRACK_Y = -50
local track = CreateFrame("Frame", nil, main)
track:SetPoint("TOPLEFT", main, "TOPLEFT", 4, TRACK_Y)
track:SetSize(MAIN_W - 8, 26)
track:Hide()
local segs = {}
do
    local n = X.MILESTONE_EVERY
    local segW = (MAIN_W - 8 - (n - 1) * 4 - 24) / n
    for i = 1, n do
        local s = track:CreateTexture(nil, "ARTWORK")
        s:SetSize(segW, 8)
        s:SetPoint("LEFT", track, "LEFT", (i - 1) * (segW + 4), 0)
        local num = track:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        num:SetPoint("TOP", s, "BOTTOM", 0, -1)
        s.num = num
        segs[i] = s
    end
    local skull = track:CreateTexture(nil, "OVERLAY")
    skull:SetSize(20, 20)
    skull:SetPoint("LEFT", segs[n], "RIGHT", 4, 0)
    skull:SetTexture(SKULL_ICON)
    skull:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    track.skull = skull
end

local function PaintTrack(f)
    local n = X.MILESTONE_EVERY
    local first = (math.ceil(f / n) - 1) * n + 1
    for i, s in ipairs(segs) do
        local fight = first + i - 1
        if fight < f then s:SetColorTexture(1, 0.82, 0, 0.9)
        elseif fight == f then s:SetColorTexture(1, 1, 1, 0.95)
        else s:SetColorTexture(0.22, 0.22, 0.22, 1) end
        if i == n then s:SetColorTexture(fight == f and 1 or 0.55, fight == f and 0.5 or 0.25, 0.15, 1) end
        s.num:SetText(tostring(fight))
    end
end

local ART_W, ART_H = 228, 152
local oppPanel = Panel(main, MAIN_W, ART_H + 24)
oppPanel:SetPoint("TOPLEFT", main, "TOPLEFT", 0, TRACK_Y - 38)
oppPanel:Hide()
local oppArt = TTS.CreateEncounterArt and TTS.CreateEncounterArt(oppPanel, ART_W, ART_H)
if oppArt then oppArt:SetPoint("TOPLEFT", oppPanel, "TOPLEFT", 8, -8) end
local oppName = oppPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
oppName:SetPoint("TOPLEFT", oppPanel, "TOPLEFT", ART_W + 30, -16)
local oppWho = oppPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
oppWho:SetPoint("TOPLEFT", oppName, "BOTTOMLEFT", 0, -4)
local oppStats = oppPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
oppStats:SetPoint("TOPLEFT", oppWho, "BOTTOMLEFT", 0, -12)
local oppNote = oppPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
oppNote:SetPoint("TOPLEFT", oppStats, "BOTTOMLEFT", 0, -12)
oppNote:SetWidth(MAIN_W - ART_W - 50)
oppNote:SetJustifyH("LEFT")

local rulesPanel = Panel(main, MAIN_W, 10)
rulesPanel:SetPoint("TOPLEFT", oppPanel, "BOTTOMLEFT", 0, -8)
rulesPanel:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", 0, 34)
rulesPanel:Hide()
PanelHeader(rulesPanel, "endless.rules")
local rulesScroll = CreateFrame("ScrollFrame", "TTS_EndlessRulesScroll", rulesPanel, "UIPanelScrollFrameTemplate")
rulesScroll:SetPoint("TOPLEFT", 10, -30)
rulesScroll:SetPoint("BOTTOMRIGHT", -28, 8)
local rulesChild = CreateFrame("Frame", nil, rulesScroll)
rulesChild:SetSize(MAIN_W - 48, 10)
rulesScroll:SetScrollChild(rulesChild)
local rulesText = rulesChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
rulesText:SetPoint("TOPLEFT")
rulesText:SetWidth(MAIN_W - 48)
rulesText:SetJustifyH("LEFT")
rulesText:SetJustifyV("TOP")
if rulesText.SetSpacing then rulesText:SetSpacing(2) end

-- =========================================================================
-- START SCREEN PARTS
-- =========================================================================
-- Three stat tiles (best run, pack charges, runs started), how a run works step by step,
-- and the last run's result
local startPanel = CreateFrame("Frame", nil, main)
startPanel:SetPoint("TOPLEFT", main, "TOPLEFT", 0, -64)
startPanel:SetSize(MAIN_W, 10)
startPanel:Hide()

local TILE_H, TILE_GAP = 78, 10
local tiles = {}
for i = 1, 3 do
    local tileW = (MAIN_W - 2 * TILE_GAP) / 3
    local t = Panel(startPanel, tileW, TILE_H)
    t:SetPoint("TOPLEFT", startPanel, "TOPLEFT", (i - 1) * (tileW + TILE_GAP), 0)
    t.value = t:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    t.value:SetPoint("TOP", 0, -16)
    t.label = t:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    t.label:SetPoint("TOP", t.value, "BOTTOM", 0, -4)
    tiles[i] = t
end
Loc:Bind(tiles[1].label, "endless.tile.best")
Loc:Bind(tiles[2].label, "endless.tile.charges")
Loc:Bind(tiles[3].label, "endless.tile.runs")

local STEP_H = 46
local STEP_ICONS = {
    "Interface\\Icons\\INV_Misc_Note_01",
    "Interface\\AddOns\\ForeverCCG\\Textures\\Symbols\\W.png",
    "Interface\\Icons\\INV_Sword_04",
    SKULL_ICON,
}
local howPanel = Panel(startPanel, MAIN_W, 34 + #STEP_ICONS * STEP_H)
howPanel:SetPoint("TOPLEFT", startPanel, "TOPLEFT", 0, -(TILE_H + 10))
PanelHeader(howPanel, "endless.how")
for i, icon in ipairs(STEP_ICONS) do
    local tex = howPanel:CreateTexture(nil, "ARTWORK")
    tex:SetSize(28, 28)
    tex:SetPoint("TOPLEFT", howPanel, "TOPLEFT", 14, -32 - (i - 1) * STEP_H)
    tex:SetTexture(icon)
    if icon:find("Icons") then tex:SetTexCoord(0.08, 0.92, 0.08, 0.92) end
    local text = howPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("LEFT", tex, "RIGHT", 12, 0)
    text:SetWidth(MAIN_W - 80)
    text:SetJustifyH("LEFT")
    Loc:Bind(text, "endless.how." .. i)
end

local startLast = startPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
startLast:SetPoint("TOP", howPanel, "BOTTOM", 0, -14)
startLast:SetWidth(MAIN_W - 20)
startLast:SetJustifyH("CENTER")

-- =========================================================================
-- BUTTONS
-- =========================================================================
local primary = PanelButton(F, 160, 30, nil, "GameFontNormal")
primary:SetPoint("BOTTOMLEFT", F, "BOTTOMLEFT", 24, 18)
local secondary = PanelButton(F, 120, 24)
secondary:SetPoint("LEFT", primary, "RIGHT", 10, 0)
local tertiary = PanelButton(F, 120, 24)
tertiary:SetPoint("LEFT", secondary, "RIGHT", 8, 0)
local danger = PanelButton(F, 120, 24)
danger:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", 0, -30)

TTS.Dialog:Register("TTS_ENDLESS_ABANDON", {
    text = "%s",
    button1 = YES or "Yes",
    button2 = NO or "No",
    OnAccept = function() X:EndRun() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
})

-- =========================================================================
-- STAGES
-- =========================================================================
local prayerCounts = {}
local prayerTarget = X.PRAYERS   -- the Prayers the steppers must add up to
local adjusting = false          -- the run screen is showing Adjust Prayers

local function Reset()
    ShowCards(nil)
    ShowPickPips(nil)
    colorRow:Hide()
    track:Hide(); oppPanel:Hide(); rulesPanel:Hide(); startPanel:Hide()
    for _, c in ipairs(columns) do
        c.take:Hide(); c.minus:Show(); c.plus:Show(); c.count:Show(); c.pips:Show()
    end
    for _, b in ipairs({ primary, secondary, tertiary, danger }) do
        b:Hide()
        b:SetScript("OnClick", nil)
        b:Enable()
    end
    hint:SetText("")
    stageTitle:SetText("")
    stageBadge:SetText("")
    stageSub:SetText("")
end

local function ShowStart()
    stageTitle:SetText(L("endless.start.title"))
    stageSub:SetText(GREY .. L("endless.start.sub") .. "|r")
    startPanel:Show()
    tiles[1].value:SetText(GOLD .. X:Best() .. "|r")
    tiles[2].value:SetText(GOLD .. X:Charges() .. "|r|cFF8A8A8A/" .. X.MAX_CHARGES .. "|r")
    tiles[3].value:SetText(GOLD .. X:Runs() .. "|r")
    local last = X:LastRun()
    if last then
        startLast:SetText(ORANGE .. L("endless.over.title") .. "|r   "
            .. L("endless.over.line", last.wins, last.packs or 0))
    else
        startLast:SetText("")
    end
    local wait = X:NextChargeWait()
    if wait then hint:SetText(GREY .. L("endless.nextCharge", TTS:FormatWait(wait)) .. "|r") end
    primary:SetText(L("endless.start"))
    primary:SetScript("OnClick", function() X:StartRun() end)
    primary:Show()
    FillDeck({})
end

local function ShowDraft(run)
    local k = #run.picks + 1
    stageTitle:SetText(L("endless.draft.title", k, X.DRAFT_PICKS))
    if X.RARE_PICKS[k] then stageBadge:SetText(ORANGE .. L("endless.rarePick") .. "|r") end
    stageSub:SetText(GREY .. L("endless.draft.hint", OFFER) .. "|r")
    ShowPickPips(#run.picks)
    local badges = {}
    if X.RARE_PICKS[k] then badges[1] = ORANGE .. L("endless.rare") .. "|r" end
    ShowCards(run.offer, badges, function(i) X:Pick(i) end)
    FillDeck(run.deck)
end

-- The colour pips in the costs of a list of cards (Prayers have none)
local function PickPips(list)
    local pips = {}
    for _, id in ipairs(list or {}) do
        local c = TTS.Cards[id]
        for pip in string.gmatch(c and c.cost or "", "{(%a)}") do pips[pip] = (pips[pip] or 0) + 1 end
    end
    return pips
end

local function PaintSteppers()
    local total = 0
    for _, col in ipairs(X.COLORS) do total = total + (prayerCounts[col] or 0) end
    for _, c in ipairs(columns) do
        local n = prayerCounts[c.col] or 0
        c.count:SetText((n > 0 and GOLD or GREY) .. n .. "|r")
        c.minus:SetEnabled(n > 0)
        c.plus:SetEnabled(total < prayerTarget)
        if c.icon.SetDesaturated then c.icon:SetDesaturated(n == 0) end
    end
    colorLabel:SetText(L("endless.prayers.total", (total == prayerTarget and GREEN or GOLD) .. total .. "|r", prayerTarget))
    primary:SetEnabled(total == prayerTarget)
end

-- The five colour columns as steppers (the draft's Prayers, and Adjust Prayers)
local function ShowSteppers(pips, pipsKey)
    colorRow:ClearAllPoints()
    colorRow:SetPoint("TOPLEFT", main, "TOPLEFT", 0, -70)
    colorRow:Show()
    for _, c in ipairs(columns) do
        local prayer = TTS.Cards[X.PRAYER_IDS[c.col]]
        c.name:SetText(prayer and TTS:CardName(prayer) or c.col)
        c.pips:SetText(L(pipsKey, pips[c.col] or 0))
        c.minus:SetScript("OnClick", function()
            prayerCounts[c.col] = math.max(0, (prayerCounts[c.col] or 0) - 1)
            PaintSteppers()
        end)
        c.plus:SetScript("OnClick", function()
            prayerCounts[c.col] = (prayerCounts[c.col] or 0) + 1
            PaintSteppers()
        end)
    end
end

-- Between fights: the deck's Prayers moved between colours, the total kept
local function ShowAdjust(run)
    stageTitle:SetText(L("endless.adjust.title"))
    local _, have = X:PrayerCounts()
    stageSub:SetText(GREY .. L("endless.adjust.hint", have) .. "|r")
    prayerTarget = have
    ShowSteppers(PickPips(run.deck), "endless.adjust.pips")
    primary:SetText(L("endless.confirm"))
    primary:SetScript("OnClick", function()
        local counts = {}
        for _, col in ipairs(X.COLORS) do counts[col] = prayerCounts[col] or 0 end
        adjusting = false
        if not X:AdjustPrayers(counts) then F:Refresh() end
    end)
    primary:Show()
    secondary:SetText(CANCEL or "Cancel")
    secondary:SetScript("OnClick", function()
        adjusting = false
        F:Refresh()
    end)
    secondary:Show()
    PaintSteppers()
    FillDeck(run.deck)
end

local function ShowPrayers(run)
    stageTitle:SetText(L("endless.prayers.title", X.PRAYERS))
    stageSub:SetText(GREY .. L("endless.prayers.hint") .. "|r")
    prayerTarget = X.PRAYERS
    local pips = PickPips(run.picks)
    -- A starting split by the colours picked, so Confirm can be pressed straight away
    if not prayerCounts.seeded then
        local sum = 0
        for _, col in ipairs(X.COLORS) do sum = sum + (pips[col] or 0) end
        local given = 0
        for _, col in ipairs(X.COLORS) do
            prayerCounts[col] = sum > 0 and math.floor(X.PRAYERS * (pips[col] or 0) / sum) or 0
            given = given + prayerCounts[col]
        end
        local order = {}
        for _, col in ipairs(X.COLORS) do order[#order + 1] = col end
        table.sort(order, function(a, b) return (pips[a] or 0) > (pips[b] or 0) end)
        local k = 1
        while given < X.PRAYERS do
            prayerCounts[order[k]] = prayerCounts[order[k]] + 1
            given = given + 1
            k = k % #order + 1
        end
        prayerCounts.seeded = true
    end
    ShowSteppers(pips, "endless.prayers.pips")
    primary:SetText(L("endless.confirm"))
    primary:SetScript("OnClick", function()
        local counts = {}
        for _, col in ipairs(X.COLORS) do counts[col] = prayerCounts[col] or 0 end
        if X:SetPrayers(counts) then wipe(prayerCounts) end
    end)
    primary:Show()
    PaintSteppers()
    FillDeck(run.deck)
end

local function RuleLines(ids, color, out)
    for _, rule in ipairs(TTS:GetEncounterRuleLines({ rules = ids })) do
        out[#out + 1] = color .. rule.name .. "|r  " .. rule.text
    end
end

local function ShowReady(run)
    local plan = X:PlanFight()
    local src = plan and TTS.SoloEncounters[plan.source]
    if not (plan and src) then return end
    stageTitle:SetText(L("endless.fight", plan.fight))
    if plan.milestone then stageBadge:SetText(ORANGE .. L("endless.milestone") .. "|r") end
    local toGo = X:NextMilestone(plan.fight) - plan.fight
    stageSub:SetText(GREY .. (toGo == 0 and L("endless.milestoneNow") or L("endless.milestoneIn", toGo)) .. "|r")

    track:Show()
    PaintTrack(plan.fight)

    oppPanel:Show()
    if oppArt then oppArt:SetBackground(src.background) end
    oppName:SetText(TTS:EncounterName(src))
    oppWho:SetText(L("endless.vs", GOLD .. (TTS:EncounterOpponent(src) or "") .. "|r")
        .. "   " .. GREY .. (src.kind == "dungeon" and L("solo.dungeon") or L("solo.zoneGauntlet")) .. "|r")
    oppStats:SetText(L("endless.lifeAi", GOLD .. plan.life .. "|r", GOLD .. AI_LABEL[plan.ai] .. "|r"))
    local notes = {}
    if plan.milestone then
        if X:Charges() > 0 then
            notes[#notes + 1] = GREEN .. L("endless.milestonePack") .. "|r"
        else
            notes[#notes + 1] = RED .. L("endless.noChargeWarning") .. "|r"
        end
    end
    if plan.newCurse or plan.newTwist then
        local names = {}
        for _, id in ipairs({ plan.newCurse, plan.newTwist }) do
            if id then names[#names + 1] = Loc:Data("rule." .. id .. ".name", TTS.EncounterRules[id].name) end
        end
        notes[#notes + 1] = RED .. L("endless.newMutator", table.concat(names, ", ")) .. "|r"
    end
    oppNote:SetText(table.concat(notes, "\n"))

    -- The rules: the opponent's own (a dungeon's, this fight's curse, Endless Might), then the
    -- lasting curses and twists
    local isLasting = {}
    for _, id in ipairs(run.curses) do isLasting[id] = true end
    for _, id in ipairs(run.twists) do isLasting[id] = true end
    local own, curses, twists = {}, {}, {}
    for _, id in ipairs(plan.rules) do
        local rule = TTS.EncounterRules[id]
        if not isLasting[id] then own[#own + 1] = id
        elseif rule and rule.mutator == "twist" then twists[#twists + 1] = id
        else curses[#curses + 1] = id end
    end
    local lines = {}
    if #own > 0 then
        lines[#lines + 1] = GOLD .. L("endless.rules.fight") .. "|r"
        RuleLines(own, ORANGE, lines)
    end
    if #curses > 0 then
        if #lines > 0 then lines[#lines + 1] = " " end
        lines[#lines + 1] = GOLD .. L("endless.rules.curses") .. "|r"
        RuleLines(curses, CURSE_COLOR, lines)
    end
    if #twists > 0 then
        if #lines > 0 then lines[#lines + 1] = " " end
        lines[#lines + 1] = GOLD .. L("endless.rules.twists") .. "|r"
        RuleLines(twists, TWIST_COLOR, lines)
    end
    if #lines == 0 then lines[1] = GREY .. L("endless.rules.none") .. "|r" end
    rulesPanel:Show()
    rulesText:SetText(table.concat(lines, "\n"))
    rulesChild:SetHeight(math.max(10, (rulesText:GetStringHeight() or 10) + 4))
    rulesScroll:SetVerticalScroll(0)

    primary:SetText(L("endless.fightBtn"))
    primary:SetScript("OnClick", function()
        local blocker = X:StartBlocker()
        if blocker then
            hint:SetText(RED .. blocker .. "|r")
            return
        end
        -- The board takes the window's place (it comes back after the result: Board.lua)
        F:Hide()
        local ok, why = X:StartFight()
        if not ok then
            F:Show()
            if why then hint:SetText(RED .. why .. "|r") end
        end
    end)
    primary:Show()
    local blocker = X:StartBlocker()
    if blocker then hint:SetText(RED .. blocker .. "|r") end
    secondary:SetText(L(deckPanel:IsShown() and "endless.hideDeck" or "endless.viewDeck"))
    secondary:SetScript("OnClick", function()
        deckPanel:SetShown(not deckPanel:IsShown())
        secondary:SetText(L(deckPanel:IsShown() and "endless.hideDeck" or "endless.viewDeck"))
    end)
    secondary:Show()
    -- After each win (and before the first fight): move the deck's Prayers between colours
    tertiary:SetText(L("endless.adjust.button"))
    tertiary:SetScript("OnClick", function()
        wipe(prayerCounts)
        local counts = X:PrayerCounts()
        for col, n in pairs(counts) do prayerCounts[col] = n end
        adjusting = true
        deckPanel:Show()
        F:Refresh()
    end)
    tertiary:Show()
    danger:SetText(L("endless.abandon"))
    danger:SetScript("OnClick", function()
        TTS.Dialog:Popup("TTS_ENDLESS_ABANDON", L("endless.abandonConfirm", (run.fight or 1) - 1))
    end)
    danger:Show()
    FillDeck(run.deck)
end

local function ShowReward(run)
    stageTitle:SetText(L("endless.reward.title", (run.fight or 2) - 1))
    stageSub:SetText(GREY .. L("endless.reward.hint") .. "|r")
    ShowCards(run.reward, nil, function(i) X:TakeReward(i) end)
    colorRow:ClearAllPoints()
    colorRow:SetPoint("TOPLEFT", main, "TOPLEFT", 0, CARDS_Y - cardH * CARD_SCALE - 26)
    colorRow:Show()
    colorLabel:SetText(L("endless.reward.prayer"))
    for _, c in ipairs(columns) do
        local prayer = TTS.Cards[X.PRAYER_IDS[c.col]]
        c.name:SetText(prayer and TTS:CardName(prayer) or c.col)
        if c.icon.SetDesaturated then c.icon:SetDesaturated(false) end
        c.count:Hide()
        c.pips:Hide()
        c.minus:Hide()
        c.plus:Hide()
        c.take:SetText(L("endless.addOne"))
        c.take:SetScript("OnClick", function() X:TakePrayer(c.col) end)
        c.take:Show()
    end
    secondary:SetText(L("endless.skip"))
    secondary:SetScript("OnClick", function() X:SkipReward() end)
    secondary:Show()
    FillDeck(run.deck)
end

function F:Refresh()
    if not self:IsShown() then return end
    Reset()
    PaintHeader()
    local run = X:Run()
    if not run then
        deckPanel:Show()
        ShowStart()
    elseif run.stage == "draft" then
        deckPanel:Show()
        ShowDraft(run)
    elseif run.stage == "prayers" then
        deckPanel:Show()
        ShowPrayers(run)
    elseif run.stage == "reward" then
        deckPanel:Show()
        ShowReward(run)
    elseif adjusting and X:CanAdjustPrayers() then
        ShowAdjust(run)
    else
        adjusting = false
        ShowReady(run)
    end
    if not (run and run.stage == "ready") then adjusting = false end
end

X.onChange = function() if F:IsShown() then F:Refresh() end end

F:SetScript("OnShow", function(self)
    if TTS.Engine and TTS.Engine.inMatch then
        self:Hide()
        return
    end
    self:Refresh()
end)
F:SetScript("OnHide", function()
    HidePreview()
    adjusting = false   -- (unconfirmed changes are dropped)
end)

-- Opened any way while the main window is up, it takes its place (as the solo map does)
F:HookScript("OnShow", function(self)
    local M = TTS.MainFrame
    if self:IsShown() and M and M:IsShown() and M.OpenChild then M:OpenChild(self) end
end)

function F:Open()
    self:Show()
    return self
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    if TTS.Sound and TTS.Sound.HookButtons then TTS.Sound:HookButtons(F) end
    self:UnregisterAllEvents()
end)
