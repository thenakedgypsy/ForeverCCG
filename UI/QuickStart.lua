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
-- (qs.<n>.title / qs.<n>.text), with Back / Next, and on the last page a button
-- to play the tutorial game (UI\Tutorial.lua). It opens by itself the first time
-- the main window is opened (TTS_Options.quickStartSeen), and never again.
-- =========================================================================
local PAGES = 8
local W, H = 420, 300

local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local Q = CreateFrame("Frame", "TTS_QuickStart", UIParent, backdropTemplate)
TTS.QuickStartFrame = Q
Q:SetSize(W, H)
Q:SetPoint("CENTER", 0, 40)
Q:SetFrameStrata("DIALOG")
Q:SetToplevel(true)
Q:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
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

local closeBtn = CreateFrame("Button", nil, Q, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -4, -4)

local icon = Q:CreateTexture(nil, "ARTWORK")
icon:SetSize(36, 36)
icon:SetPoint("TOPLEFT", 22, -22)
icon:SetTexture("Interface\\AddOns\\ForeverCCG\\Textures\\Cards\\card_back.png")

local step = Q:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
step:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, -2)

local title = Q:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", step, "BOTTOMLEFT", 0, -3)
title:SetPoint("RIGHT", Q, "RIGHT", -34, 0)
title:SetJustifyH("LEFT")

local rule = Q:CreateTexture(nil, "ARTWORK")
rule:SetHeight(1)
rule:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -10)
rule:SetPoint("RIGHT", Q, "RIGHT", -22, 0)
rule:SetColorTexture(1, 0.82, 0, 0.35)

local text = Q:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
text:SetPoint("TOPLEFT", rule, "BOTTOMLEFT", 0, -12)
text:SetPoint("RIGHT", Q, "RIGHT", -24, 0)
text:SetJustifyH("LEFT")
text:SetJustifyV("TOP")
text:SetSpacing(2)

-- One dot per step along the bottom, the current one lit
local dots = {}
for i = 1, PAGES do
    local d = Q:CreateTexture(nil, "ARTWORK")
    d:SetSize(8, 8)
    d:SetTexture("Interface\\Buttons\\WHITE8X8")
    d:SetPoint("BOTTOM", Q, "BOTTOM", (i - (PAGES + 1) / 2) * 14, 48)
    dots[i] = d
end

local backBtn = CreateFrame("Button", nil, Q, "UIPanelButtonTemplate")
backBtn:SetSize(96, 24)
backBtn:SetPoint("BOTTOMLEFT", 20, 18)
Loc:Bind(backBtn, "qs.back")

local nextBtn = CreateFrame("Button", nil, Q, "UIPanelButtonTemplate")
nextBtn:SetSize(110, 24)
nextBtn:SetPoint("BOTTOMRIGHT", -20, 18)

-- On the last page: play the tutorial game
local tutorialBtn = CreateFrame("Button", nil, Q, "UIPanelButtonTemplate")
tutorialBtn:SetSize(140, 24)
tutorialBtn:SetPoint("RIGHT", nextBtn, "LEFT", -8, 0)
Loc:Bind(tutorialBtn, "tut.play")
tutorialBtn:SetScript("OnClick", function()
    Q:Hide()
    if TTS.StartTutorial then TTS:StartTutorial() end
end)

local page = 1

local function Show(n)
    page = math.max(1, math.min(PAGES, n))
    step:SetText(L("qs.step", page, PAGES))
    title:SetText(L("qs." .. page .. ".title"))
    local body = L("qs." .. page .. ".text")
    text:SetText(TTS.FormatSymbols and TTS:FormatSymbols(body, 16) or body)
    for i, d in ipairs(dots) do
        if i == page then d:SetVertexColor(1, 0.82, 0, 1) else d:SetVertexColor(0.4, 0.4, 0.4, 0.8) end
    end
    backBtn:SetEnabled(page > 1)
    nextBtn:SetText(L(page < PAGES and "qs.next" or "qs.done"))
    tutorialBtn:SetShown(page == PAGES and TTS.StartTutorial ~= nil)
end

backBtn:SetScript("OnClick", function() Show(page - 1) end)
nextBtn:SetScript("OnClick", function()
    if page < PAGES then Show(page + 1) else Q:Hide() end
end)

-- The first time the main window opens, the walkthrough comes up by itself
if TTS.MainFrame then
    TTS.MainFrame:HookScript("OnShow", function()
        if not (TTS.Options and TTS.Options.Get) or TTS.Options:Get("quickStartSeen") then return end
        TTS.Options:Set("quickStartSeen", true)
        Show(1)
        Q:Show()
    end)
end
