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

-- =========================================================================
-- SAVED SETTINGS (TTS_Options)
-- =========================================================================
local DEFAULTS = {
    tooltipDelay = 0,       -- seconds before a tooltip appears
    extendedTooltipDelay = 0.8,  -- seconds between each further layer of detail after that
    boardScale = 1,         -- game board size (Board.lua)
    deckBuilderScale = 1,   -- Deckbuilder size (DeckBuilder.lua)
    boardBackgrounds = true, -- themed image behind the battlefield in solo encounters (Board.lua)
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

-- Sound categories shown under the master switch, in order
O.SOUND_CATEGORIES = {
    { key = "creatures", label = "Creature voices",         desc = "Aggro and death sounds when creatures are played, attack or die." },
    { key = "cards",     label = "Card & spell sounds",     desc = "Prayers being played and spells being cast, by either player." },
    { key = "ui",        label = "Button & card clicks",    desc = "Clicks on buttons and cards, and the sound of a Prayer tapping." },
    { key = "combat",    label = "Targeting & hit sounds",  desc = "The click when a target is chosen and the hit when a player takes damage." },
    { key = "turn",      label = "Your-turn alert",         desc = "The chime at the start of a game and at the start of each of your turns." },
}

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
F:SetSize(340, 476)
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
title:SetText("Options")

local closeBtn = CreateFrame("Button", nil, F, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -2, -2)

local footer = F:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
footer:SetPoint("BOTTOMRIGHT", F, "BOTTOMRIGHT", -20, 14)
footer:SetText("Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy")

-- Tooltip-bordered panel with a gold section header and divider
local function CreateSection(label, h)
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
    header:SetText(label)

    local line = p:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", 8, -24)
    line:SetPoint("TOPRIGHT", -8, -24)
    line:SetHeight(1)
    line:SetColorTexture(1, 0.82, 0, 0.30)
    return p
end

-- Checkbox with a label; the label is part of the click area
local function CreateCheck(parent, x, y, label, desc)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetSize(24, 24)
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    cb.label = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    cb.label:SetPoint("LEFT", cb, "RIGHT", 2, 1)
    cb.label:SetText(label)
    cb:SetHitRectInsets(0, -(cb.label:GetStringWidth() + 4), 0, 0)
    if desc then
        cb:SetScript("OnEnter", function(self)
            if TTS.Tooltip then TTS.Tooltip:ShowText(self, "ANCHOR_RIGHT", label, desc) end
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
local soundSection = CreateSection("Sound", 182)
soundSection:SetPoint("TOPLEFT", F, "TOPLEFT", 14, -46)

local masterCheck = CreateCheck(soundSection, 10, -30, "Enable sounds",
    "Turns every Forever: CCG sound on or off. Same as the Sounds checkbox on the board.")
masterCheck:SetScript("OnClick", function(self)
    S:SetEnabled(self:GetChecked())
end)

local categoryChecks = {}
for i, cat in ipairs(O.SOUND_CATEGORIES) do
    local cb = CreateCheck(soundSection, 30, -30 - i * 24, cat.label, cat.desc)
    cb:SetScript("OnClick", function(self)
        O:SetSound(cat.key, self:GetChecked())
    end)
    categoryChecks[cat.key] = cb
end

-- =========================================================================
-- TOOLTIP SECTION
-- =========================================================================
local tipSection = CreateSection("Tooltips", 150)
tipSection:SetPoint("TOPLEFT", soundSection, "BOTTOMLEFT", 0, -8)

-- Labelled slider for a delay setting, snapped to DELAY_STEP and saved under key
local function CreateDelaySlider(name, label, desc, y, maxValue, key)
    local text = tipSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT", tipSection, "TOPLEFT", 12, y)
    text:SetText(label)

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
    lowText:SetText(DELAY_MIN .. "s")

    local highText = tipSection:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    highText:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", -2, 0)
    highText:SetText(maxValue .. "s")

    function slider:ShowValue(v)
        if v <= 0 then
            value:SetText("Instant")
        else
            value:SetText(string.format("%.1f s", v))
        end
    end

    slider:SetScript("OnValueChanged", function(self, v)
        v = math.floor(v / DELAY_STEP + 0.5) * DELAY_STEP
        O:Set(key, v)
        self:ShowValue(v)
    end)
    slider:SetScript("OnEnter", function(self)
        if TTS.Tooltip then TTS.Tooltip:ShowText(self, "ANCHOR_RIGHT", label, desc) end
    end)
    slider:SetScript("OnLeave", function(self)
        if TTS.Tooltip then TTS.Tooltip:Hide(self) end
    end)
    slider.key = key
    return slider
end

local delaySlider = CreateDelaySlider("TTS_OptionsDelaySlider", "Tooltip delay",
    "How long the cursor rests on something before its tooltip appears.",
    -34, DELAY_MAX, "tooltipDelay")

local extendedSlider = CreateDelaySlider("TTS_OptionsExtendedDelaySlider", "Extended tooltip delay",
    "How long each further layer of detail (keywords, effects, symbols) waits after the one before it.",
    -92, EXTENDED_MAX, "extendedTooltipDelay")

-- =========================================================================
-- BOARD SECTION
-- =========================================================================
local boardSection = CreateSection("Board", 58)
boardSection:SetPoint("TOPLEFT", tipSection, "BOTTOMLEFT", 0, -8)

local backgroundCheck = CreateCheck(boardSection, 10, -30, "Show zone backgrounds in solo encounters",
    "Shows the zone's map (or the dungeon's art) behind the battlefield during solo encounters. PvP and Practice games always use the plain board.")
backgroundCheck:SetScript("OnClick", function(self)
    O:Set("boardBackgrounds", self:GetChecked() and true or false)
    if TTS.BoardFrame and TTS.BoardFrame.RefreshBackground then TTS.BoardFrame:RefreshBackground() end
end)

-- =========================================================================
-- SYNC
-- =========================================================================
function O:SyncControls()
    local db = self:GetDB()
    local master = db.sound.enabled and true or false
    masterCheck:SetChecked(master)
    for _, cat in ipairs(O.SOUND_CATEGORIES) do
        local cb = categoryChecks[cat.key]
        cb:SetChecked(db.sound[cat.key] ~= false)
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
end

F:SetScript("OnShow", function()
    O:SyncControls()
end)

F:SetScript("OnHide", function()
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