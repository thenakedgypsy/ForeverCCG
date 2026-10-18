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
-- HERO CARD MILESTONE CHOICE
-- Opened by the Deckbuilder's glowing "Hero" button, which shows while the character has
-- reached a 10-level milestone nobody on the account has chosen for (Hero.lua). The
-- Deckbuilder hides while this is up. Upgrade the card, shown before and after, or take
-- another copy (greyed out at 4 copies). "Decide later" (or Escape) leaves it waiting.
-- =========================================================================
local HC = {}
TTS.HeroChoice = HC

local PAD = 24
local CARD_W, CARD_H = TTS.PREVIEW_W or 150, TTS.PREVIEW_H or 212
local ARROW_GAP = 56          -- between the before and after cards
local PANEL_GAP = 64          -- between the upgrade and copy panels
local CARD_TOP = 112          -- card frame top, below the title, heading and the card's name/cost
local W = PAD * 2 + CARD_W * 3 + ARROW_GAP + PANEL_GAP
local H = CARD_TOP + CARD_H + 118

local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local F = CreateFrame("Frame", "TTS_HeroChoice", UIParent, backdropTemplate)
HC.frame = F
F:SetSize(W, H)
F:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
F:SetFrameStrata("FULLSCREEN_DIALOG")
F:SetToplevel(true)
F:SetClampedToScreen(true)
F:EnableMouse(true)
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

-- Left: upgrade (before -> after). Right: another copy.
local upLeft = PAD
local copyLeft = PAD + CARD_W * 2 + ARROW_GAP + PANEL_GAP

local function Heading(x, width)
    local fs = F:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    fs:SetPoint("TOPLEFT", F, "TOPLEFT", x, -(PAD + 34))
    fs:SetWidth(width)
    fs:SetJustifyH("CENTER")
    return fs
end
local upHead = Heading(upLeft, CARD_W * 2 + ARROW_GAP)
local copyHead = Heading(copyLeft, CARD_W)

local function Card(x)
    local f = TTS.CreateCardFrame(F, CARD_W, CARD_H)
    f:SetScript("OnHide", nil)   -- the shared frame hides its cost on hide (board hand behaviour)
    f:SetScript("OnEnter", nil)
    f:SetScript("OnLeave", nil)
    f:EnableMouse(false)
    f:SetFrameLevel(F:GetFrameLevel() + 5)
    f:ClearAllPoints()
    f:SetPoint("TOPLEFT", F, "TOPLEFT", x, -CARD_TOP)
    return f
end
local beforeCard, afterCard, copyCard

-- Three arrows stacked between the before and after cards
local ARROW_SIZE, ARROW_STEP = 40, 48
for i = -1, 1 do
    local arrow = F:CreateTexture(nil, "OVERLAY")
    arrow:SetSize(ARROW_SIZE, ARROW_SIZE)
    arrow:SetPoint("CENTER", F, "TOPLEFT", upLeft + CARD_W + ARROW_GAP / 2, -(CARD_TOP + CARD_H / 2 + i * ARROW_STEP))
    arrow:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
end

local function Caption(x, width)
    local fs = F:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetPoint("TOPLEFT", F, "TOPLEFT", x, -(CARD_TOP + CARD_H + 10))
    fs:SetWidth(width)
    fs:SetJustifyH("CENTER")
    return fs
end
local upCaption = Caption(upLeft, CARD_W * 2 + ARROW_GAP)
-- Copies owned, as the pips under the Deckbuilder's cards: grey = owned, gold = the copy
-- this choice would add, dark = not owned
local PIP_W, PIP_H, PIP_GAP = 16, 5, 3
local copyPips = {}
do
    local pipsW = 4 * PIP_W + 3 * PIP_GAP
    for p = 1, 4 do
        local pip = F:CreateTexture(nil, "OVERLAY")
        pip:SetSize(PIP_W, PIP_H)
        pip:SetPoint("TOPLEFT", F, "TOPLEFT",
            copyLeft + math.floor((CARD_W - pipsW) / 2) + (p - 1) * (PIP_W + PIP_GAP), -(CARD_TOP + CARD_H + 14))
        copyPips[p] = pip
    end
end

local function Button(width)
    local b = CreateFrame("Button", nil, F, "UIPanelButtonTemplate")
    b:SetSize(width, 26)
    return b
end
local upBtn = Button(160)
upBtn:SetPoint("TOP", F, "TOPLEFT", upLeft + (CARD_W * 2 + ARROW_GAP) / 2, -(CARD_TOP + CARD_H + 36))
local copyBtn = Button(160)
copyBtn:SetPoint("TOP", F, "TOPLEFT", copyLeft + CARD_W / 2, -(CARD_TOP + CARD_H + 36))
local laterBtn = Button(140)
laterBtn:SetPoint("BOTTOM", F, "BOTTOM", 0, PAD - 6)

-- "+0/+1" style difference between two cards' stats
local function Diff(a, b)
    local function S(n) return (n >= 0 and "+" or "") .. n end
    return S(b.power - a.power) .. "/" .. S(b.toughness - a.toughness)
end

local function Paint(card, f)
    TTS.PaintPreviewCard(f, card)
    f:SetFrameLevel(F:GetFrameLevel() + 5)
end

function HC:Refresh()
    local c = TTS.Hero:NextChoice()
    beforeCard = beforeCard or Card(upLeft)
    afterCard = afterCard or Card(upLeft + CARD_W + ARROW_GAP)
    copyCard = copyCard or Card(copyLeft)
    title:SetText(L("hero.choiceTitle", c.level))
    upBtn:SetText(L("hero.upgradeBtn"))
    copyBtn:SetText(L("hero.copyBtn"))
    laterBtn:SetText(L("hero.laterBtn"))
    upHead:SetText(L("hero.upgradeHead"))
    copyHead:SetText(L("hero.copyHead"))
    Paint(c.current, beforeCard)
    Paint(c.upgraded, afterCard)
    Paint(c.current, copyCard)
    upCaption:SetText(L("hero.upgradeText", c.upgraded.cmc - c.current.cmc, Diff(c.current, c.upgraded)))
    -- With 4 copies only the upgrade is left, still shown so the change can be seen
    local canCopy = c.copies < TTS.Hero.MAX_COPIES
    for p, pip in ipairs(copyPips) do
        if p <= c.copies then
            pip:SetColorTexture(0.45, 0.45, 0.48, 1)
        elseif p == c.copies + 1 then
            pip:SetColorTexture(1, 0.82, 0, 1)
        else
            pip:SetColorTexture(0.18, 0.18, 0.20, 1)
        end
    end
    if canCopy then copyBtn:Enable() else copyBtn:Disable() end
    copyCard:SetAlpha(canCopy and 1 or 0.4)
end

-- The Deckbuilder hides while this is up and comes back when it closes
local deckbuilderWasShown = false
HC.reopening = false

local function Close()
    F:Hide()
end

F:SetScript("OnHide", function()
    -- Closing mid-animation drops it (the choice itself is already saved)
    HC.animating = false
    if HC.StopAnimation then HC:StopAnimation() end
    if deckbuilderWasShown and TTS.DeckBuilderFrame then
        deckbuilderWasShown = false
        HC.reopening = true   -- its OnShow skips the level snapshot
        TTS.DeckBuilderFrame:Show()
        HC.reopening = false
    end
end)

-- =========================================================================
-- CHOICE ANIMATIONS
-- Upgrade: the upgraded card flashes gold, then slides onto the old card's place as the
-- old one fades out. Copy: the copy card flashes gold. The next choice (or closing) waits
-- for it to finish.
-- Done like the board's card flights (UI\Board.lua): an OnUpdate re-anchors the card each
-- frame, since animation groups move a frame's textures but not the model inside it, and
-- models ignore their parent's alpha, so the model's alpha is set alongside the card's.
-- =========================================================================
HC.animating = false

local FLASH_TIME, SLIDE_TIME = 0.35, 0.45
local SLIDE_DIST = CARD_W + ARROW_GAP
local afterLeft = upLeft + CARD_W + ARROW_GAP

local FLASH_FADE = 0.2   -- the flash's tail, after FLASH_TIME
local flashes = {}       -- [card frame] = its gold flash overlay
local anim               -- { t, onDone, card, slide } while running
local fadeIn             -- after an upgrade: seconds into the next upgraded card's fade-in

local function SetCardAlpha(f, a)
    f:SetAlpha(a)
    if f.model then f.model:SetAlpha(a) end
end

-- The gold overlay a card flashes with (made once per card)
local function Flash(card)
    local fl = flashes[card]
    if not fl then
        fl = CreateFrame("Frame", nil, card)
        fl:SetAllPoints(card)
        local tex = fl:CreateTexture(nil, "OVERLAY")
        tex:SetAllPoints(fl)
        tex:SetColorTexture(1, 0.82, 0.3, 1)
        tex:SetBlendMode("ADD")
        flashes[card] = fl
    end
    fl:SetFrameLevel(card:GetFrameLevel() + 20)
    return fl
end

-- Puts the cards back where (and how) they normally are
local function ResetAnimatedCards()
    if afterCard then
        afterCard:ClearAllPoints()
        afterCard:SetPoint("TOPLEFT", F, "TOPLEFT", afterLeft, -CARD_TOP)
    end
    if beforeCard then SetCardAlpha(beforeCard, 1) end
    if afterCard then SetCardAlpha(afterCard, 1) end
    fadeIn = nil
    for _, fl in pairs(flashes) do fl:SetAlpha(0) end
end

-- After an upgrade the next upgraded card fades in where the old one slid from
local FADE_IN_TIME = 0.35

local ticker = CreateFrame("Frame", nil, F)
ticker:SetScript("OnUpdate", function(_, dt)
    if fadeIn and afterCard then
        fadeIn = fadeIn + dt
        local a = math.min(1, fadeIn / FADE_IN_TIME)
        SetCardAlpha(afterCard, a)
        if a >= 1 then fadeIn = nil end
    end
    if not anim then return end
    anim.t = anim.t + dt
    local t = anim.t
    -- Flash: up quickly, then fades over the rest of FLASH_TIME and a little after
    local peak = FLASH_TIME * 0.4
    Flash(anim.card):SetAlpha(t < peak and 0.7 * t / peak
        or math.max(0, 0.7 * (1 - (t - peak) / (FLASH_TIME + FLASH_FADE - peak))))
    local length = FLASH_TIME + FLASH_FADE
    if anim.slide then
        -- Slide (ease in-out), the old card fading out under it
        local p = math.max(0, math.min(1, (t - FLASH_TIME) / SLIDE_TIME))
        local ease = p * p * (3 - 2 * p)
        afterCard:ClearAllPoints()
        afterCard:SetPoint("TOPLEFT", F, "TOPLEFT", afterLeft - SLIDE_DIST * ease, -CARD_TOP)
        SetCardAlpha(beforeCard, 1 - p)
        length = FLASH_TIME + SLIDE_TIME
    end
    if t >= length then
        local onDone, slid = anim.onDone, anim.slide
        anim = nil
        onDone()   -- repaints the cards for the next choice (or closes), then back in place
        ResetAnimatedCards()
        if slid and F:IsShown() then
            SetCardAlpha(afterCard, 0)
            fadeIn = 0
        end
    end
end)

-- card: the frame that flashes; slide: the upgrade's slide follows
local function PlayChoiceAnim(card, slide, onDone)
    ResetAnimatedCards()   -- a fade-in still running finishes at once
    Flash(card):SetAlpha(0)
    anim = { t = 0, onDone = onDone, card = card, slide = slide }
end

-- Closing mid-animation (Escape): drop it and put the cards back
function HC:StopAnimation()
    anim = nil
    ResetAnimatedCards()
end

local function AfterChoice()
    HC.animating = false
    if TTS.Hero:PendingChoices() > 0 then
        HC:Refresh()
    else
        Close()
    end
end

local function Choose(kind)
    if HC.animating then return end
    TTS.Hero:Choose(kind)
    local card = (kind == "upgrade") and afterCard or copyCard
    if card and beforeCard then
        HC.animating = true
        PlayChoiceAnim(card, kind == "upgrade", AfterChoice)
    else
        AfterChoice()
    end
end
upBtn:SetScript("OnClick", function() Choose("upgrade") end)
copyBtn:SetScript("OnClick", function() Choose("copy") end)
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
