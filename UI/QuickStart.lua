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
-- QUICK START
-- A short step-by-step walkthrough for new players: one page per step
-- (qs.<n>.title / qs.<n>.text), each with a real card from the game showcased beside it,
-- Back / Next and clickable step dots, and on the last page a button to play the tutorial
-- game (UI\Tutorial.lua). It opens by itself the first time the main window is opened
-- (TTS_Options.quickStartSeen), and with /tragic welcome any time; the main window closes
-- while it's up and comes back when it's done.
-- =========================================================================
local PAGES = 8
local W, H = 620, 410
local CARD_Y = -12         -- the card sits this far below the showcase's centre: its name and cost go above it
local HEADER_H = 40
local SHOWCASE_W = 210
local CARD_SCALE = 1.1
local FADE_TIME = 0.25     -- a page's text and card fading in
local SLIDE = 14           -- and the card sliding in from the right by this much
local GLOW_PULSE = 2.5     -- radians per second

-- The card shown with each page: an id (foil = shown as a foil), or nil for the card back
local PAGE_CARDS = {
    [2] = { id = "DES01" },               -- Burning Blade Augur: a deck's denizens
    [3] = { id = "W01" },                 -- Prayer of Light
    [4] = { id = "MAG02" },               -- Fire Blast: a spell to cast
    [5] = { id = "HIN04" },               -- Primitive Owlbeast: an attacker
    [6] = { id = "FER03" },               -- Groddoc Ape: a blocker
    [7] = { id = "BOSS01", foil = true }, -- Bazzalan, as a foil: something to collect
}
local CARD_BACK = "Interface\\AddOns\\ForeverCCG\\Textures\\Cards\\card_back.png"

local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local Q = CreateFrame("Frame", "TTS_QuickStart", UIParent, backdropTemplate)
TTS.QuickStartFrame = Q
Q:SetSize(W, H)
Q:SetPoint("CENTER", 0, 40)
Q:SetFrameStrata("DIALOG")
Q:SetToplevel(true)
Q:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
Q:EnableMouse(true)
Q:SetMovable(true)
Q:RegisterForDrag("LeftButton")
Q:SetScript("OnDragStart", Q.StartMoving)
Q:SetScript("OnDragStop", Q.StopMovingOrSizing)
Q:Hide()
tinsert(UISpecialFrames, "TTS_QuickStart")   -- Escape closes it

local function PlaySoundFor(name)
    if TTS.Sound and TTS.Sound.PlayUI then pcall(TTS.Sound.PlayUI, TTS.Sound, name) end
end

-- ----- Header: a dark strip with a gold line under it -----
local header = Q:CreateTexture(nil, "ARTWORK")
header:SetPoint("TOPLEFT", 12, -12)
header:SetPoint("TOPRIGHT", -12, -12)
header:SetHeight(HEADER_H)
header:SetColorTexture(0, 0, 0, 0.55)

local headerLine = Q:CreateTexture(nil, "ARTWORK")
headerLine:SetPoint("TOPLEFT", header, "BOTTOMLEFT")
headerLine:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT")
headerLine:SetHeight(1)
headerLine:SetColorTexture(1, 0.82, 0, 0.6)

local icon = Q:CreateTexture(nil, "OVERLAY")
icon:SetSize(26, 36)
icon:SetPoint("LEFT", header, "LEFT", 12, 0)
icon:SetTexture(CARD_BACK)

local heading = Q:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
heading:SetPoint("LEFT", icon, "RIGHT", 10, 0)
Loc:Bind(heading, "qs.heading")

local step = Q:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
step:SetPoint("RIGHT", header, "RIGHT", -34, 0)

local closeBtn = CreateFrame("Button", nil, Q, "UIPanelCloseButton")
closeBtn:SetPoint("RIGHT", header, "RIGHT", -2, 0)

-- ----- Showcase: the page's card on a dark panel, with a soft pulsing glow behind it -----
local showcase = CreateFrame("Frame", nil, Q, backdropTemplate)
showcase:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 10, -12)
showcase:SetPoint("BOTTOM", Q, "BOTTOM", 0, 58)
showcase:SetWidth(SHOWCASE_W)
if showcase.SetBackdrop then
    showcase:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    showcase:SetBackdropColor(0.04, 0.04, 0.06, 0.85)
    showcase:SetBackdropBorderColor(1, 0.82, 0, 0.5)
end

-- (the foil cards' halo: a card fills its middle 192 of 256 px)
local glow = showcase:CreateTexture(nil, "BACKGROUND", nil, 1)
glow:SetTexture("Interface\\AddOns\\ForeverCCG\\Textures\\FoilGlow.tga")
glow:SetBlendMode("ADD")
glow:SetVertexColor(1, 0.82, 0.3)
glow:SetPoint("CENTER", showcase, "CENTER", 0, CARD_Y)
glow:SetSize((TTS.PREVIEW_W or 150) * CARD_SCALE * 256 / 192, (TTS.PREVIEW_H or 212) * CARD_SCALE * 256 / 192)

-- The card itself (the board's own preview card, so it looks just as it does in a game)
local card
if TTS.CreateCardFrame and TTS.PREVIEW_W then
    card = TTS.CreateCardFrame(showcase, TTS.PREVIEW_W, TTS.PREVIEW_H)
    card:EnableMouse(false)
    card:SetScript("OnEnter", nil)
    card:SetScript("OnLeave", nil)
    card:SetScript("OnClick", nil)
    card:SetScale(CARD_SCALE)
    card.camScaleRoot = Q   -- (its model's camera follows this window's scale, not the board's)
    card:Hide()
end

-- Or the card back
local back = showcase:CreateTexture(nil, "ARTWORK")
back:SetSize((TTS.PREVIEW_W or 150) * CARD_SCALE, (TTS.PREVIEW_H or 212) * CARD_SCALE)
back:SetTexture(CARD_BACK)

-- ----- Page: title, gold rule, text -----
local title = Q:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
title:SetPoint("TOPLEFT", showcase, "TOPRIGHT", 22, -10)
title:SetPoint("RIGHT", Q, "RIGHT", -28, 0)
title:SetJustifyH("LEFT")

local rule = Q:CreateTexture(nil, "ARTWORK")
rule:SetHeight(1)
rule:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
rule:SetPoint("RIGHT", Q, "RIGHT", -28, 0)
rule:SetColorTexture(1, 0.82, 0, 0.35)

local text = Q:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
text:SetPoint("TOPLEFT", rule, "BOTTOMLEFT", 0, -12)
text:SetPoint("RIGHT", Q, "RIGHT", -28, 0)
text:SetJustifyH("LEFT")
text:SetJustifyV("TOP")
text:SetSpacing(3)

-- ----- Footer: Back, a clickable dot per step, Next (and on the last page, the tutorial) -----
local backBtn = CreateFrame("Button", nil, Q, "UIPanelButtonTemplate")
backBtn:SetSize(96, 24)
backBtn:SetPoint("BOTTOMLEFT", 22, 20)
Loc:Bind(backBtn, "qs.back")

local nextBtn = CreateFrame("Button", nil, Q, "UIPanelButtonTemplate")
nextBtn:SetSize(120, 24)
nextBtn:SetPoint("BOTTOMRIGHT", -22, 20)

-- Above it on the last page: play the tutorial game
local tutorialBtn = CreateFrame("Button", nil, Q, "UIPanelButtonTemplate")
tutorialBtn:SetSize(150, 24)
tutorialBtn:SetPoint("BOTTOMRIGHT", nextBtn, "TOPRIGHT", 0, 8)
Loc:Bind(tutorialBtn, "tut.play")

-- A pulsing gold glow, to draw the eye (as on the Deckbuilder's Hero button)
do
    local glow = tutorialBtn:CreateTexture(nil, "OVERLAY")
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
    tutorialBtn:HookScript("OnShow", function() pulse:Play() end)
    tutorialBtn:HookScript("OnHide", function() pulse:Stop() end)
end

local Show   -- (below)
local dots = {}
for i = 1, PAGES do
    local d = CreateFrame("Button", nil, Q)
    d:SetSize(12, 12)
    d:SetPoint("BOTTOM", Q, "BOTTOM", (i - (PAGES + 1) / 2) * 18, 26)
    d.tex = d:CreateTexture(nil, "ARTWORK")
    d.tex:SetPoint("CENTER")
    d.tex:SetSize(8, 8)
    d.tex:SetTexture("Interface\\Buttons\\WHITE8X8")
    d:SetScript("OnClick", function() Show(i, true) end)
    d:SetScript("OnEnter", function(self) self.tex:SetSize(10, 10) end)
    d:SetScript("OnLeave", function(self) self.tex:SetSize(8, 8) end)
    dots[i] = d
end

-- ----- Pages -----
local page, shownAt = 1, 0

local function PaintShowcase(n)
    local spec = PAGE_CARDS[n]
    local c = spec and TTS.Cards and TTS.Cards[spec.id]
    if c and card and TTS.PaintPreviewCard then
        back:Hide()
        TTS.PaintPreviewCard(card, c, spec.foil)
        card:Show()
    else
        if card then card:Hide() end
        back:Show()
    end
end

-- n: the page; turned: a page turned by the player (plays its sound)
Show = function(n, turned)
    n = math.max(1, math.min(PAGES, n))
    if turned and n ~= page then PlaySoundFor("page") end
    page = n
    step:SetText(L("qs.step", page, PAGES))
    title:SetText(L("qs." .. page .. ".title"))
    local body = L("qs." .. page .. ".text")
    text:SetText(TTS.FormatSymbols and TTS:FormatSymbols(body, 16) or body)
    for i, d in ipairs(dots) do
        if i == page then d.tex:SetVertexColor(1, 0.82, 0, 1) else d.tex:SetVertexColor(0.4, 0.4, 0.4, 0.8) end
    end
    backBtn:SetEnabled(page > 1)
    nextBtn:SetText(L(page < PAGES and "qs.next" or "qs.done"))
    tutorialBtn:SetShown(page == PAGES and TTS.StartTutorial ~= nil)
    PaintShowcase(page)
    shownAt = GetTime()
end

-- Fades the page in, slides its card in, and pulses the glows
Q:SetScript("OnUpdate", function()
    local t = GetTime() - shownAt
    local p = math.min(1, t / FADE_TIME)
    local e = 1 - (1 - p) ^ 3   -- ease out
    title:SetAlpha(e)
    text:SetAlpha(e)
    rule:SetAlpha(e)
    local dx = SLIDE * (1 - e)
    if card then
        card:SetAlpha(e)
        card:ClearAllPoints()
        card:SetPoint("CENTER", showcase, "CENTER", dx / CARD_SCALE, CARD_Y / CARD_SCALE)
    end
    back:SetAlpha(e)
    back:ClearAllPoints()
    back:SetPoint("CENTER", showcase, "CENTER", dx, CARD_Y)
    local pulse = 0.5 + 0.5 * math.sin(GetTime() * GLOW_PULSE)
    glow:SetAlpha(e * (0.35 + 0.25 * pulse))
end)

backBtn:SetScript("OnClick", function() Show(page - 1, true) end)

-- Done: back to the main window
nextBtn:SetScript("OnClick", function()
    if page < PAGES then
        Show(page + 1, true)
    else
        Q:Hide()
        if TTS.MainFrame and not (TTS.Engine and TTS.Engine.inMatch) then TTS.MainFrame:Show() end
    end
end)

tutorialBtn:SetScript("OnClick", function()
    Q:Hide()
    if TTS.StartTutorial then TTS:StartTutorial() end
end)

-- Opens the walkthrough (at page n, default the first), closing the main window meanwhile
function TTS:ShowQuickStart(n)
    Show(n or 1)
    Q:Show()
    PlaySoundFor("deckCard")
    -- (a moment later: it may be opening from the main window's own OnShow)
    if TTS.MainFrame and TTS.MainFrame:IsShown() then
        TTS:SafeAfter(0, function() if Q:IsShown() then TTS.MainFrame:Hide() end end)
    end
end

-- The first time the main window opens, the walkthrough comes up by itself
if TTS.MainFrame then
    TTS.MainFrame:HookScript("OnShow", function()
        if not (TTS.Options and TTS.Options.Get) or TTS.Options:Get("quickStartSeen") then return end
        TTS.Options:Set("quickStartSeen", true)
        TTS:ShowQuickStart(1)
    end)
end
