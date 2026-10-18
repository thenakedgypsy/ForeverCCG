--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
TTS.Options = TTS.Options or {}
local O = TTS.Options
local L = TTS.L
local Loc = TTS.Locale

-- =========================================================================
-- SAVED SETTINGS (TTS_Options)
-- =========================================================================
local DEFAULTS = {
    tooltipDelay = 0,       -- seconds before a tooltip appears
    extendedTooltipDelay = 0.8,  -- seconds between each further layer of detail after that
    boardScale = 1,         -- game board size (Board.lua)
    deckBuilderScale = 1,   -- Deckbuilder size (DeckBuilder.lua)
    boardBackgrounds = true, -- themed image behind the battlefield in solo encounters (Board.lua)
    cardControls = "both",   -- "click", "drag" or "both" (CardDrag.lua)
    animateCards = true,     -- played cards fly from the hand to the battlefield (Board.lua)
    autoPayMana = true,      -- casting taps the prayers it needs (the board's Auto-pay checkbox)
    gameLogFolded = false,   -- the board's game log folded up to its title (Board.lua)
    boardLocked = false,     -- the board can't be dragged (the board's Lock checkbox)
    sound = {
        enabled   = true,   -- master switch (also the board's Sounds checkbox)
        creatures = true,
        cards     = true,
        ui        = true,
        combat    = true,
        turn      = true,
    },
}

local DELAY_MIN, DELAY_MAX, DELAY_STEP = 0, 2, 0.1
local EXTENDED_MAX = 3

-- Sound categories shown under the master switch, in order (label / tooltip: options.sound.<key>[.desc])
O.SOUND_CATEGORIES = { "creatures", "cards", "ui", "combat", "turn" }

local function MergeDefaults(db, defaults)
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            if type(db[k]) ~= "table" then db[k] = {} end
            MergeDefaults(db[k], v)
        elseif db[k] == nil then
            db[k] = v
        end
    end
end

function O:GetDB()
    if type(TTS_Options) ~= "table" then TTS_Options = {} end
    MergeDefaults(TTS_Options, DEFAULTS)
    return TTS_Options
end

function O:Get(key)
    return self:GetDB()[key]
end

function O:Set(key, value)
    self:GetDB()[key] = value
end

function O:GetSound(category)
    return self:GetDB().sound[category]
end

function O:SetSound(category, on)
    self:GetDB().sound[category] = on and true or false
end

-- =========================================================================
-- SOUND SWITCHES
-- Sound.lua's master switch (S.enabled) is saved here, and each category
-- gates the entry points that play it.
-- =========================================================================
local S = TTS.Sound
local E = TTS.Engine

-- True if sounds of this category may play (category nil = master switch only)
function S:IsOn(category)
    if not self.enabled then return false end
    if not category then return true end
    return O:GetSound(category) ~= false
end

local origSetEnabled = S.SetEnabled
function S:SetEnabled(on)
    origSetEnabled(self, on)
    O:SetSound("enabled", self.enabled)
    if O.SyncControls then O:SyncControls() end
end

local origPlayUI = S.PlayUI
function S:PlayUI(name)
    if not self:IsOn("ui") then return end
    return origPlayUI(self, name)
end

local origQueueCreature = S.QueueCreature
function S:QueueCreature(kind, cardId)
    if not self:IsOn("creatures") then return end
    return origQueueCreature(self, kind, cardId)
end

if E and E.PlayNonCreatureCardSound then
    local origPrayerSound = E.PlayNonCreatureCardSound
    function E:PlayNonCreatureCardSound()
        if not S:IsOn("cards") then return end
        return origPrayerSound(self)
    end
end

if E and E.PlaySpellCastSound then
    local origSpellSound = E.PlaySpellCastSound
    function E:PlaySpellCastSound()
        if not S:IsOn("cards") then return end
        return origSpellSound(self)
    end
end

-- =========================================================================
-- OPTIONS WINDOW (same look as the main window)
-- =========================================================================
local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local PANEL_BG     = { 0.04, 0.04, 0.04, 0.70 }
local PANEL_BORDER = { 0.60, 0.56, 0.48, 1 }

local F = CreateFrame("Frame", "TTS_OptionsFrame", UIParent, backdropTemplate)
TTS.OptionsFrame = F
F:SetSize(340, 624)
F:SetPoint("CENTER")
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

local titleBar = F:CreateTexture(nil, "ARTWORK")
titleBar:SetPoint("TOPLEFT", 12, -12)
titleBar:SetPoint("TOPRIGHT", -12, -12)
titleBar:SetHeight(25)
titleBar:SetColorTexture(0, 0, 0, 0.35)

local titleLine = F:CreateTexture(nil, "ARTWORK")
titleLine:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 0)
titleLine:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
titleLine:SetHeight(1)
titleLine:SetColorTexture(1, 0.82, 0, 0.55)

local title = F:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -11)
Loc:Bind(title, "options.title")
do  -- the grey Forever: CCG tag after the title, as on Rules & Guide
    local tag = F:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    tag:SetPoint("LEFT", title, "RIGHT", 10, -1)
    tag:SetText("Forever: CCG")
end

local closeBtn = CreateFrame("Button", nil, F, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -2, -2)

local footer = F:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
footer:SetPoint("BOTTOMRIGHT", F, "BOTTOMRIGHT", -20, 14)
footer:SetText("Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy")

-- Tooltip-bordered panel with a gold section header (locale key) and divider
local function CreateSection(labelKey, h)
    local p = CreateFrame("Frame", nil, F, backdropTemplate)
    p:SetSize(312, h)
    p:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    p:SetBackdropColor(PANEL_BG[1], PANEL_BG[2], PANEL_BG[3], PANEL_BG[4])
    p:SetBackdropBorderColor(PANEL_BORDER[1], PANEL_BORDER[2], PANEL_BORDER[3], PANEL_BORDER[4])

    local header = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header:SetPoint("TOPLEFT", 10, -9)
    Loc:Bind(header, labelKey)

    local line = p:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", 8, -24)
    line:SetPoint("TOPRIGHT", -8, -24)
    line:SetHeight(1)
    line:SetColorTexture(1, 0.82, 0, 0.30)
    return p
end

-- Checkbox labelled with locale key (tooltip: key .. ".desc"); the label is part of the click area
local function CreateCheck(parent, x, y, key)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetSize(24, 24)
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    cb.label = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    cb.label:SetPoint("LEFT", cb, "RIGHT", 2, 1)
    Loc:Bind(cb.label, key)
    Loc:OnReady(function() cb:SetHitRectInsets(0, -(cb.label:GetStringWidth() + 4), 0, 0) end)
    do
        cb:SetScript("OnEnter", function(self)
            if TTS.Tooltip then TTS.Tooltip:ShowText(self, "ANCHOR_RIGHT", L(key), L(key .. ".desc")) end
        end)
        cb:SetScript("OnLeave", function(self)
            if TTS.Tooltip then TTS.Tooltip:Hide(self) end
        end)
    end
    return cb
end

local function SetCheckEnabled(cb, enabled)
    if enabled then
        cb:Enable()
        cb.label:SetFontObject("GameFontHighlightSmall")
    else
        cb:Disable()
        cb.label:SetFontObject("GameFontDisableSmall")
    end
end

-- =========================================================================
-- SOUND SECTION
-- =========================================================================
local soundSection = CreateSection("options.sound", 182)
soundSection:SetPoint("TOPLEFT", F, "TOPLEFT", 14, -46)

local masterCheck = CreateCheck(soundSection, 10, -30, "options.sound.enable")
masterCheck:SetScript("OnClick", function(self)
    S:SetEnabled(self:GetChecked())
end)

local categoryChecks = {}
for i, cat in ipairs(O.SOUND_CATEGORIES) do
    local cb = CreateCheck(soundSection, 30, -30 - i * 24, "options.sound." .. cat)
    cb:SetScript("OnClick", function(self)
        O:SetSound(cat, self:GetChecked())
    end)
    categoryChecks[cat] = cb
end

-- =========================================================================
-- TOOLTIP SECTION
-- =========================================================================
local tipSection = CreateSection("options.tooltips", 150)
tipSection:SetPoint("TOPLEFT", soundSection, "BOTTOMLEFT", 0, -8)

-- Slider for a delay setting labelled with locale labelKey (tooltip: labelKey .. ".desc"), snapped to DELAY_STEP and saved under key
local function CreateDelaySlider(name, labelKey, y, maxValue, key)
    local text = tipSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT", tipSection, "TOPLEFT", 12, y)
    Loc:Bind(text, labelKey)

    local value = tipSection:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    value:SetPoint("TOPRIGHT", tipSection, "TOPRIGHT", -14, y)

    local slider = CreateFrame("Slider", name, tipSection, backdropTemplate)
    slider:SetOrientation("HORIZONTAL")
    slider:SetSize(284, 17)
    slider:SetPoint("TOPLEFT", tipSection, "TOPLEFT", 14, y - 18)
    slider:SetBackdrop({
        bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
        edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 3, right = 3, top = 6, bottom = 6 }
    })
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    slider:SetMinMaxValues(DELAY_MIN, maxValue)
    slider:SetValueStep(DELAY_STEP)
    if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end

    local lowText = tipSection:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    lowText:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 2, 0)
    Loc:Bind(lowText, "options.secondsShort", DELAY_MIN)

    local highText = tipSection:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    highText:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", -2, 0)
    Loc:Bind(highText, "options.secondsShort", maxValue)

    function slider:ShowValue(v)
        if v <= 0 then
            value:SetText(L("options.instant"))
        else
            value:SetText(L("options.seconds", v))
        end
    end

    slider:SetScript("OnValueChanged", function(self, v)
        v = math.floor(v / DELAY_STEP + 0.5) * DELAY_STEP
        O:Set(key, v)
        self:ShowValue(v)
    end)
    slider:SetScript("OnEnter", function(self)
        if TTS.Tooltip then TTS.Tooltip:ShowText(self, "ANCHOR_RIGHT", L(labelKey), L(labelKey .. ".desc")) end
    end)
    slider:SetScript("OnLeave", function(self)
        if TTS.Tooltip then TTS.Tooltip:Hide(self) end
    end)
    slider.key = key
    return slider
end

local delaySlider = CreateDelaySlider("TTS_OptionsDelaySlider", "options.tooltipDelay",
    -34, DELAY_MAX, "tooltipDelay")

local extendedSlider = CreateDelaySlider("TTS_OptionsExtendedDelaySlider", "options.extendedDelay",
    -92, EXTENDED_MAX, "extendedTooltipDelay")

-- =========================================================================
-- BOARD SECTION
-- =========================================================================
local boardSection = CreateSection("options.board", 132)
boardSection:SetPoint("TOPLEFT", tipSection, "BOTTOMLEFT", 0, -8)

local backgroundCheck = CreateCheck(boardSection, 10, -30, "options.backgrounds")
backgroundCheck:SetScript("OnClick", function(self)
    O:Set("boardBackgrounds", self:GetChecked() and true or false)
    if TTS.BoardFrame and TTS.BoardFrame.RefreshBackground then TTS.BoardFrame:RefreshBackground() end
end)

local animateCheck = CreateCheck(boardSection, 10, -54, "options.animate")
animateCheck:SetScript("OnClick", function(self)
    O:Set("animateCards", self:GetChecked() and true or false)
end)

local controlsText = boardSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
controlsText:SetPoint("TOPLEFT", boardSection, "TOPLEFT", 14, -86)
Loc:Bind(controlsText, "options.controls")

-- One choice of how cards are played; saved as cardControls (label / tooltip: options.controls.<mode>[.desc])
local CONTROL_MODES = { "click", "drag", "both" }
local controlRadios = {}
for i, mode in ipairs(CONTROL_MODES) do
    local key = "options.controls." .. mode
    local rb = CreateFrame("CheckButton", nil, boardSection, "UIRadioButtonTemplate")
    rb:SetPoint("TOPLEFT", boardSection, "TOPLEFT", 14 + (i - 1) * 90, -104)
    rb.label = rb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    rb.label:SetPoint("LEFT", rb, "RIGHT", 4, 1)
    Loc:Bind(rb.label, key)
    Loc:OnReady(function() rb:SetHitRectInsets(0, -(rb.label:GetStringWidth() + 6), 0, 0) end)
    rb:SetScript("OnClick", function()
        O:Set("cardControls", mode)
        for _, other in ipairs(controlRadios) do other:SetChecked(other == rb) end
        if TTS.ApplyCardControls then TTS.ApplyCardControls() end
    end)
    rb:SetScript("OnEnter", function(self)
        if TTS.Tooltip then TTS.Tooltip:ShowText(self, "ANCHOR_RIGHT", L(key), L(key .. ".desc")) end
    end)
    rb:SetScript("OnLeave", function(self)
        if TTS.Tooltip then TTS.Tooltip:Hide(self) end
    end)
    rb.key = mode
    controlRadios[i] = rb
end

-- =========================================================================
-- LANGUAGE SECTION
-- A button showing the saved choice; clicking it lists the installed
-- languages (English plus the ForeverCCG_Languages pack). A new choice is
-- used after a /reload.
-- =========================================================================
local langSection = CreateSection("options.language", 66)
langSection:SetPoint("TOPLEFT", boardSection, "BOTTOMLEFT", 0, -8)

local langButton = CreateFrame("Button", nil, langSection, "UIPanelButtonTemplate")
langButton:SetSize(170, 22)
langButton:SetPoint("TOPLEFT", langSection, "TOPLEFT", 12, -32)

local reloadButton = CreateFrame("Button", nil, langSection, "UIPanelButtonTemplate")
reloadButton:SetSize(110, 22)
reloadButton:SetPoint("LEFT", langButton, "RIGHT", 8, 0)
Loc:Bind(reloadButton, "options.language.reloadNow")
reloadButton:SetScript("OnClick", function() if ReloadUI then ReloadUI() end end)
reloadButton:Hide()

local function ChoiceLabel(choice)
    if choice == "auto" then
        return L("locale.auto", Loc:NameOf(Loc:Resolve("auto")))
    end
    return Loc:NameOf(choice)
end

local langList = CreateFrame("Frame", nil, langButton, backdropTemplate)
langList:SetFrameStrata("FULLSCREEN_DIALOG")
langList:SetPoint("TOPLEFT", langButton, "BOTTOMLEFT", 0, -2)
langList:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
langList:SetBackdropColor(0, 0, 0, 0.95)
langList:Hide()
local langRows = {}

local function PickLanguage(choice)
    langList:Hide()
    Loc:SetChoice(choice)
    langButton:SetText(ChoiceLabel(choice))
    local changed = choice ~= Loc.loadedChoice
    reloadButton:SetShown(changed)
    if changed and DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD200[TTSE]|r " .. L("locale.reload"))
    end
end

local function OpenLanguageList()
    local choices = { "auto" }
    for _, lang in ipairs(Loc:Available()) do choices[#choices + 1] = lang.code end
    for i, choice in ipairs(choices) do
        local row = langRows[i]
        if not row then
            row = CreateFrame("Button", nil, langList)
            row:SetSize(160, 18)
            row:SetPoint("TOPLEFT", langList, "TOPLEFT", 6, -6 - (i - 1) * 18)
            row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
            row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.text:SetPoint("LEFT", 4, 0)
            langRows[i] = row
        end
        row.text:SetText(ChoiceLabel(choice))
        row:SetScript("OnClick", function() PickLanguage(choice) end)
        row:Show()
    end
    for i = #choices + 1, #langRows do langRows[i]:Hide() end
    langList:SetSize(172, 12 + #choices * 18)
    langList:Show()
end

langButton:SetScript("OnClick", function()
    if langList:IsShown() then langList:Hide() else OpenLanguageList() end
end)
langButton:SetScript("OnEnter", function(self)
    if TTS.Tooltip then TTS.Tooltip:ShowText(self, "ANCHOR_RIGHT", L("options.language"), L("options.language.desc")) end
end)
langButton:SetScript("OnLeave", function(self)
    if TTS.Tooltip then TTS.Tooltip:Hide(self) end
end)

-- =========================================================================
-- SYNC
-- =========================================================================
function O:SyncControls()
    local db = self:GetDB()
    local master = db.sound.enabled and true or false
    masterCheck:SetChecked(master)
    for _, cat in ipairs(O.SOUND_CATEGORIES) do
        local cb = categoryChecks[cat]
        cb:SetChecked(db.sound[cat] ~= false)
        SetCheckEnabled(cb, master)
    end
    for _, sl in ipairs({ delaySlider, extendedSlider }) do
        sl:SetValue(db[sl.key] or 0)
        sl:ShowValue(db[sl.key] or 0)
    end
    if TTS.BoardFrame and TTS.BoardFrame.soundCheck then
        TTS.BoardFrame.soundCheck:SetChecked(master)
    end
    backgroundCheck:SetChecked(db.boardBackgrounds ~= false)
    animateCheck:SetChecked(db.animateCards ~= false)
    local mode = TTS.CardControls and TTS.CardControls() or "both"
    for _, rb in ipairs(controlRadios) do rb:SetChecked(rb.key == mode) end
    langButton:SetText(ChoiceLabel(Loc:GetChoice()))
end

F:SetScript("OnShow", function()
    O:SyncControls()
end)

F:SetScript("OnHide", function()
    langList:Hide()
    if TTS.Tooltip then TTS.Tooltip:Hide() end
end)

-- =========================================================================
-- LOADING
-- Saved settings arrive with ADDON_LOADED; button click sounds are hooked at
-- login like the other windows (Sound.lua).
-- =========================================================================
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "ForeverCCG" then
        S.enabled = O:GetDB().sound.enabled and true or false
        O:SyncControls()
    elseif event == "PLAYER_LOGIN" then
        S:HookButtons(F)
    end
end)