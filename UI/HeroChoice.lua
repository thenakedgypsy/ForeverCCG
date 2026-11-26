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
-- HERO TALENT CHOICE
-- Opened by the Deckbuilder's glowing "Hero" button, which shows while the character has
-- reached a 10-level milestone its class hasn't chosen for (Systems\Hero.lua). The
-- Deckbuilder hides while this is up. Three talents side by side, one per spec, each with
-- the hero card as it would be after taking it and what it adds; under them the path so far
-- (a slot per milestone, 10 to 60). Choosing flashes the card gold, then the next milestone
-- comes up (or the window closes). "Decide later" (or Escape) leaves it waiting.
-- =========================================================================
local HC = {}
TTS.HeroChoice = HC

local PAD = 24
local CARD_W, CARD_H = TTS.PREVIEW_W or 150, TTS.PREVIEW_H or 212
local COL_W = 190             -- each option's column
local COL_GAP = 24
local HEAD_TOP = 58           -- the spec and talent name over each card
local CARD_TOP = 122          -- card frame top (its own name and cost sit just above it)
local DESC_H = 64             -- what the talent adds, under the card
local PATH_H = 46             -- the path strip
local W = PAD * 2 + COL_W * 3 + COL_GAP * 2
local H = CARD_TOP + CARD_H + 12 + DESC_H + 34 + PATH_H + 52
local MILESTONES = 6

local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local F = CreateFrame("Frame", "TTS_HeroChoice", UIParent, backdropTemplate)
HC.frame = F
F:SetSize(W, H)
F:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
F:SetFrameStrata("FULLSCREEN_DIALOG")
F:SetToplevel(true)
F:SetClampedToScreen(true)
F:EnableMouse(true)
F:SetMovable(true)
F:RegisterForDrag("LeftButton")
F:SetScript("OnDragStart", F.StartMoving)
F:SetScript("OnDragStop", F.StopMovingOrSizing)
if F.SetBackdrop then
    F:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
end
F:Hide()
tinsert(UISpecialFrames, "TTS_HeroChoice")   -- Escape = decide later

local title = F:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", F, "TOP", 0, -PAD)
title:SetWidth(W - PAD * 2)

-- =========================================================================
-- THE THREE OPTIONS
-- =========================================================================
local columns = {}

local function ColumnLeft(i) return PAD + (i - 1) * (COL_W + COL_GAP) end

local function MakeColumn(i)
    local x = ColumnLeft(i)
    local col = {}
    col.spec = F:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    col.spec:SetPoint("TOPLEFT", F, "TOPLEFT", x, -HEAD_TOP)
    col.spec:SetWidth(COL_W)
    col.spec:SetJustifyH("CENTER")
    col.spec:SetTextColor(0.75, 0.75, 0.75)

    col.name = F:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    col.name:SetPoint("TOPLEFT", col.spec, "BOTTOMLEFT", 0, -2)
    col.name:SetWidth(COL_W)
    col.name:SetJustifyH("CENTER")

    local card = TTS.CreateCardFrame(F, CARD_W, CARD_H)
    card:SetScript("OnHide", nil)   -- the shared frame hides its cost on hide (board hand behaviour)
    card:SetScript("OnLeave", function(self) if TTS.Tooltip then TTS.Tooltip:Hide(self) end end)
    card:SetScript("OnEnter", function(self)
        if self.cardId and TTS.Tooltip then TTS.Tooltip:ShowCard(self, "ANCHOR_RIGHT", self.cardId, {}) end
    end)
    card:SetScript("OnClick", nil)
    card:SetFrameLevel(F:GetFrameLevel() + 5)
    card:ClearAllPoints()
    card:SetPoint("TOPLEFT", F, "TOPLEFT", x + (COL_W - CARD_W) / 2, -CARD_TOP)
    col.card = card

    -- A gold flash over the card when it's chosen
    local fl = CreateFrame("Frame", nil, card)
    fl:SetAllPoints(card)
    fl:SetFrameLevel(card:GetFrameLevel() + 20)
    local tex = fl:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints(fl)
    tex:SetColorTexture(1, 0.82, 0.3, 1)
    tex:SetBlendMode("ADD")
    fl:SetAlpha(0)
    col.flash = fl

    col.desc = F:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    col.desc:SetPoint("TOPLEFT", F, "TOPLEFT", x, -(CARD_TOP + CARD_H + 12))
    col.desc:SetSize(COL_W, DESC_H)
    col.desc:SetJustifyH("CENTER")
    col.desc:SetJustifyV("TOP")
    col.desc:SetWordWrap(true)

    col.btn = CreateFrame("Button", nil, F, "UIPanelButtonTemplate")
    col.btn:SetSize(150, 26)
    col.btn:SetPoint("TOP", F, "TOPLEFT", x + COL_W / 2, -(CARD_TOP + CARD_H + 12 + DESC_H))
    columns[i] = col
    return col
end

-- =========================================================================
-- THE PATH (a slot per milestone: the talent taken, the one being chosen, the ones to come)
-- =========================================================================
local pathSlots = {}
local PATH_TOP = CARD_TOP + CARD_H + 12 + DESC_H + 34
local SLOT_GAP = 6
local SLOT_W = math.floor((W - PAD * 2 - SLOT_GAP * (MILESTONES - 1)) / MILESTONES)

for i = 1, MILESTONES do
    local s = CreateFrame("Frame", nil, F, backdropTemplate)
    s:SetSize(SLOT_W, PATH_H)
    s:SetPoint("TOPLEFT", F, "TOPLEFT", PAD + (i - 1) * (SLOT_W + SLOT_GAP), -PATH_TOP)
    if s.SetBackdrop then
        s:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
    end
    s.level = s:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    s.level:SetPoint("TOP", s, "TOP", 0, -6)
    s.name = s:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    s.name:SetPoint("TOPLEFT", s, "TOPLEFT", 4, -20)
    s.name:SetPoint("BOTTOMRIGHT", s, "BOTTOMRIGHT", -4, 4)
    s.name:SetJustifyH("CENTER")
    s.name:SetWordWrap(true)
    s:EnableMouse(true)
    s:SetScript("OnEnter", function(self)
        if self.talent and TTS.Tooltip then
            TTS.Tooltip:ShowText(self, "ANCHOR_TOP", TTS.Hero:TalentName(self.talent), HC.Describe(self.talent))
        end
    end)
    s:SetScript("OnLeave", function(self) if TTS.Tooltip then TTS.Tooltip:Hide(self) end end)
    pathSlots[i] = s
end

local laterBtn = CreateFrame("Button", nil, F, "UIPanelButtonTemplate")
laterBtn:SetSize(140, 24)
laterBtn:SetPoint("BOTTOM", F, "BOTTOM", 0, PAD - 6)

-- =========================================================================
-- PAINTING
-- =========================================================================
-- What a talent adds, e.g. "+1 mana, +2/+0, Enrage" then its effect's text
function HC.Describe(talent)
    local parts = {}
    if (talent.c or 0) ~= 0 then parts[#parts + 1] = L("hero.addMana", talent.c) end
    if (talent.p or 0) ~= 0 or (talent.t or 0) ~= 0 then
        local function S(n) return (n >= 0 and "+" or "") .. n end
        parts[#parts + 1] = S(talent.p or 0) .. "/" .. S(talent.t or 0)
    end
    local TT = TTS.Tooltip
    local Loc = TTS.Locale
    local kws = {}
    for kw, v in pairs(talent.kw or {}) do
        local def = TT and TT.KEYWORDS and TT.KEYWORDS[kw]
        local name = Loc and Loc:Data("keyword." .. kw .. ".name", def and def.name or kw) or kw
        if type(v) == "number" then name = L("hero.keywordValue", name, v) end
        kws[#kws + 1] = "|cFFFFD200" .. name .. "|r"
    end
    table.sort(kws)
    for _, k in ipairs(kws) do parts[#parts + 1] = k end
    local text = table.concat(parts, ", ")
    local effect = TTS.Hero:TalentText(talent)
    if effect then
        effect = TTS.FormatSymbols and TTS:FormatSymbols(effect, 12) or effect
        text = (text ~= "" and (text .. "\n") or "") .. effect
    end
    if text == "" then text = L("hero.noChange") end
    return text
end

local function Paint(col, option, classFile, n)
    col.spec:SetText(TTS.Hero:SpecName(classFile, n))
    col.name:SetText(TTS.Hero:TalentName(option.talent))
    TTS.PaintPreviewCard(col.card, option.card)
    col.card.cardId = option.card.id
    col.card:SetFrameLevel(F:GetFrameLevel() + 5)
    col.desc:SetText(HC.Describe(option.talent))
    col.btn:SetText(L("hero.chooseBtn"))
    col.talentId = option.talent.id
    col.flash:SetAlpha(0)
end

local function PaintPath(tier)
    local chosen = TTS.Hero:ChosenTalents()
    for i, s in ipairs(pathSlots) do
        s.level:SetText(L("hero.pathLevel", i * 10))
        local tal = chosen[i]
        s.talent = tal
        if tal then
            s.name:SetText(TTS.Hero:TalentName(tal))
            s.name:SetTextColor(1, 1, 1)
            s:SetBackdropBorderColor(1, 0.82, 0, 1)
            s:SetBackdropColor(0.18, 0.14, 0.04, 0.9)
        elseif i == tier then
            s.name:SetText(L("hero.pathNow"))
            s.name:SetTextColor(0.2, 1, 0.2)
            s:SetBackdropBorderColor(0.2, 1, 0.2, 1)
            s:SetBackdropColor(0.04, 0.12, 0.04, 0.9)
        else
            s.name:SetText("")
            s.name:SetTextColor(0.5, 0.5, 0.5)
            s:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)
            s:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
        end
    end
end

function HC:Refresh()
    local c = TTS.Hero:NextChoice()
    local classFile = TTS.Hero:MyClass()
    title:SetText(L("hero.choiceTitle", c.level))
    laterBtn:SetText(L("hero.laterBtn"))
    for i = 1, 3 do
        local col = columns[i] or MakeColumn(i)
        local option = c.options[i]
        local shown = option ~= nil
        for _, part in ipairs({ col.spec, col.name, col.card, col.desc, col.btn }) do part:SetShown(shown) end
        if option then Paint(col, option, classFile, i) end
    end
    PaintPath(c.tier)
end

-- =========================================================================
-- OPENING, CLOSING AND CHOOSING
-- =========================================================================
-- The Deckbuilder hides while this is up and comes back when it closes
local deckbuilderWasShown = false
HC.reopening = false
HC.animating = false

local function Close()
    F:Hide()
end

F:SetScript("OnHide", function()
    HC.animating = false
    HC.anim = nil
    if deckbuilderWasShown and TTS.DeckBuilderFrame then
        deckbuilderWasShown = false
        HC.reopening = true   -- its OnShow skips the level snapshot
        TTS.DeckBuilderFrame:Show()
        HC.reopening = false
    end
end)

-- The chosen card flashes gold (up quickly, then fading), then the next milestone or closing
local FLASH_TIME = 0.55
local ticker = CreateFrame("Frame", nil, F)
ticker:SetScript("OnUpdate", function(_, dt)
    local a = HC.anim
    if not a then return end
    a.t = a.t + dt
    local peak = FLASH_TIME * 0.35
    a.col.flash:SetAlpha(a.t < peak and 0.75 * a.t / peak or math.max(0, 0.75 * (1 - (a.t - peak) / (FLASH_TIME - peak))))
    if a.t >= FLASH_TIME then
        HC.anim = nil
        HC.animating = false
        a.col.flash:SetAlpha(0)
        if TTS.Hero:PendingChoices() > 0 then HC:Refresh() else Close() end
    end
end)

local function Choose(col)
    if HC.animating or not col.talentId then return end
    if not TTS.Hero:Choose(col.talentId) then return end
    if TTS.Sound then TTS.Sound:PlayUI("rareCard") end
    PaintPath(#TTS.Hero:ChosenTalents() + 1)
    HC.animating = true
    HC.anim = { t = 0, col = col }
end

for i = 1, 3 do
    local col = MakeColumn(i)
    col.btn:SetScript("OnClick", function() Choose(col) end)
end
laterBtn:SetScript("OnClick", function() if not HC.animating then Close() end end)

function HC:Open()
    if not (TTS.Hero and TTS.CreateCardFrame) or TTS.Hero:PendingChoices() <= 0 then return end
    local D = TTS.DeckBuilderFrame
    if D and D:IsShown() then
        deckbuilderWasShown = true
        self.hidingDeckbuilder = true   -- not a real close: its new-card tags stay
        D:Hide()
        self.hidingDeckbuilder = false
    end
    self:Refresh()
    F:Show()
end
