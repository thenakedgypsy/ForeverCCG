--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

-- =========================================================================
-- TEXTURE PATH CONFIGURATION & MANA ICONS
-- =========================================================================
local TEXTURE_ROOT    = "Interface\\AddOns\\ForeverCCG\\Textures\\"
local CARD_FRAME_DEF  = TEXTURE_ROOT .. "Cards\\card_frame.png"
local CARD_BACK_TEX   = TEXTURE_ROOT .. "Cards\\card_back.png"
local SYMBOL_PATH     = TEXTURE_ROOT .. "Symbols\\"
local TAP_TEX         = SYMBOL_PATH .. "T.png"

local CARD_FRAMES = {
    W       = TEXTURE_ROOT .. "Cards\\card_frame_holy.png",
    U       = TEXTURE_ROOT .. "Cards\\card_frame_arcane.png",
    B       = TEXTURE_ROOT .. "Cards\\card_frame_shadow.png",
    R       = TEXTURE_ROOT .. "Cards\\card_frame_fire.png",
    G       = TEXTURE_ROOT .. "Cards\\card_frame_nature.png",
    HOLY    = TEXTURE_ROOT .. "Cards\\card_frame_holy.png",
    ARCANE  = TEXTURE_ROOT .. "Cards\\card_frame_arcane.png",
    SHADOW  = TEXTURE_ROOT .. "Cards\\card_frame_shadow.png",
    FIRE    = TEXTURE_ROOT .. "Cards\\card_frame_fire.png",
    NATURE  = TEXTURE_ROOT .. "Cards\\card_frame_nature.png",
}

-- Sphere icons (Textures\Symbols)
TTS.MANA_ICONS = {
    W = SYMBOL_PATH .. "W.png",  -- White (Holy)
    U = SYMBOL_PATH .. "U.png",  -- Blue  (Arcane)
    B = SYMBOL_PATH .. "B.png",  -- Black (Shadow)
    R = SYMBOL_PATH .. "R.png",  -- Red   (Fire)
    G = SYMBOL_PATH .. "G.png",  -- Green (Nature)
}

local ART_BOX = {
    left    = 0.06,
    right   = 0.06,
    top     = 0.07,
    bottom  = 0.45,
    shiftUp = 0.01,
}

-- Rules-text box printed on the card, as fractions of the card's size.
-- top: down from the card's top edge. bottom: up from the bottom edge
-- (bottomWithPT leaves the bottom-right corner free for the P/T).
local TEXT_BOX = {
    left         = 0.09,
    right        = 0.12,
    top          = 0.50,
    bottom       = 0.05,
    bottomWithPT = 0.20,
}
local RULES_FONT_MAX = 8   -- tried first; shrinks toward MIN until the text fits
local RULES_FONT_MIN = 6
-- Cards narrower than this on screen (pixels, board zoom included) show no
-- printed text: their rules are in the tooltip only
local CARD_TEXT_MIN_WIDTH = 72
-- Symbols in printed rules text (tap and mana alike) are drawn this many pixels
-- larger than the text's base symbol size
local RULES_TAP_EXTRA = 3

-- Large preview of the hovered card, docked outside the left edge of the board
local PREVIEW_W, PREVIEW_H = 150, 212
local PREVIEW_RULES = {
    fontMax = 11,
    fontMin = 8,
    offsetX = 3,   -- pixels right
    offsetY = 3,   -- pixels down
}

local FALLBACK_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border"
local FALLBACK_BACK   = "Interface\\Buttons\\WHITE8X8"

-- Bulletproof Symbol Formatter
-- tapSize (optional): size of the tap symbol {T}; defaults to size
function TTS:FormatSymbols(str, size, tapSize)
    if not str or str == "" then return "" end
    local s = size or 16
    local ts = tapSize or s

    local formatted = str:gsub("{(%w+)}", function(key)
        local upperKey = string.upper(key)

        -- Tap Symbol
        if upperKey == "T" or upperKey == "TAP" then
            return string.format("|T%s:%d:%d:0:0|t", TAP_TEX, ts, ts)
        end

        -- Generic / Numeric / X
        if tonumber(key) or upperKey == "X" then
            return string.format("|cFF8E939B(|r|cFFFFFFFF%s|r|cFF8E939B)|r", upperKey)
        end

        -- Colored Mana Colours
        local icon = TTS.MANA_ICONS and TTS.MANA_ICONS[upperKey]
        if icon then
            return string.format("|T%s:%d:%d:0:0|t", icon, s, s)
        end

        return string.format("(%s)", upperKey)
    end)
    return formatted
end

-- Creature type, faction and zone as one tooltip line, e.g. "Humanoid  •  Defias  •  The Deadmines"
function TTS:GetCardTagLine(card)
    if not card or card.type ~= "Creature" then return nil end
    local parts = {}
    if card.creatureType then table.insert(parts, card.creatureType) end
    if card.faction then table.insert(parts, "|cFFFFD200" .. card.faction .. "|r") end
    if card.zone then table.insert(parts, "|cFF888888" .. card.zone .. "|r") end
    if #parts == 0 then return nil end
    return table.concat(parts, "  •  ")
end

-- Card click feedback (cards are flagged ttsSilent so the generic button click is skipped)
local function PlayUISound(name)
    if TTS.Sound then TTS.Sound:PlayUI(name) end
end

-- After clicking one of your permanents: "tap" if it just became tapped (outside an attack), otherwise a card click
local function PlayFieldClickSound(perm, wasTapped)
    if perm and not wasTapped and perm.tapped and not perm.isAttacking then
        PlayUISound("tap")
    else
        PlayUISound("card")
    end
end

-- Forward declarations for the camera / printed-text refreshers (run when the board is rescaled)
local RefreshAllModelCameras
local RefreshCardText
-- Forward declarations for the hover preview (built once CreateCardFrame exists)
local ShowBoardPreview, HideBoardPreview

local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil

-- Tooltips go through the manager in UI\Tooltips.lua
local TT = TTS.Tooltip

local function IsTargetingPlayer()
    local t = TTS.Engine.targeting
    return t and (t.targetType == "PLAYER" or t.targetType == "ANY")
end

-- =========================================================================
-- STYLE (matches the Deckbuilder: dialog window, dark title strip with a gold
-- line, tooltip-bordered panels and controls, small-font panel buttons)
-- =========================================================================
local STYLE = {
    panelBg       = { 0.04, 0.04, 0.04, 0.70 },
    panelBorder   = { 0.60, 0.56, 0.48, 1 },
    controlBg     = { 0.10, 0.08, 0.06, 0.95 },
    controlBorder = { 0.55, 0.50, 0.40, 1 },
}

local BACKDROPS = {
    dialog = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    },
    panel = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    },
    control = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    },
}

-- kind: "dialog", "panel" or "control"; bg/border only apply to panel and control
local function Skin(f, kind, bg, border)
    f:SetBackdrop(BACKDROPS[kind])
    if bg then f:SetBackdropColor(bg[1], bg[2], bg[3], bg[4]) end
    if border then f:SetBackdropBorderColor(border[1], border[2], border[3], border[4]) end
end

-- Darkened strip across the top of a window with a gold line under it
local function AddTitleStrip(f, height)
    local strip = f:CreateTexture(nil, "ARTWORK")
    strip:SetPoint("TOPLEFT", 12, -12)
    strip:SetPoint("TOPRIGHT", -12, -12)
    strip:SetHeight(height or 25)
    strip:SetColorTexture(0, 0, 0, 0.35)

    local line = f:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", strip, "BOTTOMLEFT", 0, 0)
    line:SetPoint("TOPRIGHT", strip, "BOTTOMRIGHT", 0, 0)
    line:SetHeight(1)
    line:SetColorTexture(1, 0.82, 0, 0.55)
    return strip
end

-- Red panel button with the Deckbuilder's small fonts
local function StyleButton(b)
    b:SetNormalFontObject("GameFontNormalSmall")
    b:SetHighlightFontObject("GameFontHighlightSmall")
    b:SetDisabledFontObject("GameFontDisableSmall")
end

local B = CreateFrame("Frame", "TTS_BoardFrame", UIParent, backdropTemplate)
TTS.BoardFrame = B
B:SetSize(1160, 780)
B:SetPoint("CENTER")
Skin(B, "dialog")
-- The top strip holds the opponent's life, the phase and the window buttons
AddTitleStrip(B, 33)
B:EnableMouse(true)
B:SetMovable(true)
B:RegisterForDrag("LeftButton")
B:SetScript("OnDragStart", B.StartMoving)
B:SetScript("OnDragStop", B.StopMovingOrSizing)
B:SetScript("OnMouseDown", function(self, button)
    if button == "RightButton" then
        if TTS.Engine.targeting then
            TTS.Engine:CancelTargeting()
        elseif TTS.Engine.blockingState and TTS.Engine.blockingState.selectedBlocker then
            TTS.Engine.blockingState.selectedBlocker = nil
            TTS.Engine:RefreshUI()
        end
    end
end)

-- Board size (scale) is saved so the board always reopens at the size it was left at
local BOARD_MIN_SCALE, BOARD_MAX_SCALE = 0.60, 1.60

local function SaveBoardScale()
    if TTS.Options then TTS.Options:Set("boardScale", B:GetScale()) end
end

B:EnableMouseWheel(true)
B:SetScript("OnMouseWheel", function(self, delta)
    if IsControlKeyDown() then
        local cur = self:GetScale() or 1.0
        local newScale = math.max(BOARD_MIN_SCALE, math.min(BOARD_MAX_SCALE, cur + (delta * 0.05)))
        self:SetScale(newScale)
        SaveBoardScale()
        if RefreshAllModelCameras then RefreshAllModelCameras() end
        if RefreshCardText then RefreshCardText() end
    end
end)
B:Hide()

-- =========================================================================
-- DRAGGABLE SCALE HANDLE (Bottom-Right)
-- =========================================================================
local resizer = CreateFrame("Button", nil, B)
resizer:SetSize(16, 16)
resizer:SetPoint("BOTTOMRIGHT", -6, 6)
resizer:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizer:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizer:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
resizer.ttsSilent = true

local isRescaling = false
local startCursorX, startCursorY, startScale = 0, 0, 1.0

resizer:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        isRescaling = true
        local cx, cy = GetCursorPosition()
        startCursorX = cx
        startCursorY = cy
        startScale = B:GetScale() or 1.0
    end
end)

resizer:SetScript("OnMouseUp", function() isRescaling = false end)
resizer:SetScript("OnHide", function() isRescaling = false end)
resizer:SetScript("OnUpdate", function(self)
    if isRescaling then
        local cx, cy = GetCursorPosition()
        local uiScale = UIParent:GetEffectiveScale()
        local dx = (cx - startCursorX) / uiScale
        local dy = (startCursorY - cy) / uiScale
        local delta = (dx + dy) * 0.5 * 0.0015
        local newScale = math.max(BOARD_MIN_SCALE, math.min(BOARD_MAX_SCALE, startScale + delta))
        if math.abs(newScale - B:GetScale()) > 0.001 then
            B:SetScale(newScale)
            SaveBoardScale()
            if RefreshAllModelCameras then RefreshAllModelCameras() end
            if RefreshCardText then RefreshCardText() end
        end
    end
end)

-- =========================================================================
-- ATTACHED GAME CHAT / COMBAT LOG (Side Panel)
-- =========================================================================
local sideLog = CreateFrame("Frame", "TTS_SideLogFrame", B, backdropTemplate)
sideLog:SetSize(250, 780)
sideLog:SetPoint("TOPLEFT", B, "TOPRIGHT", 6, 0)
Skin(sideLog, "dialog")
AddTitleStrip(sideLog)

local logTitle = sideLog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
logTitle:SetPoint("TOPLEFT", 16, -11)
logTitle:SetText("Game Log")

local logPanel = CreateFrame("Frame", nil, sideLog, backdropTemplate)
logPanel:SetPoint("TOPLEFT", 14, -46)
logPanel:SetPoint("BOTTOMRIGHT", -14, 38)
Skin(logPanel, "panel", STYLE.panelBg, STYLE.panelBorder)

local logMsg = CreateFrame("ScrollingMessageFrame", "TTS_MatchLogFrame", sideLog)
logMsg:SetPoint("TOPLEFT", logPanel, "TOPLEFT", 8, -8)
logMsg:SetPoint("BOTTOMRIGHT", logPanel, "BOTTOMRIGHT", -8, 8)
logMsg:SetFontObject(GameFontHighlightSmall)
logMsg:SetJustifyH("LEFT")
logMsg:SetFading(false)
logMsg:SetMaxLines(250)
logMsg:EnableMouseWheel(true)
logMsg:SetScript("OnMouseWheel", function(self, delta)
    if delta > 0 then
        if IsControlKeyDown() then self:ScrollToTop() else self:ScrollUp() end
    else
        if IsControlKeyDown() then self:ScrollToBottom() else self:ScrollDown() end
    end
end)
TTS.MatchLog = logMsg

local clearLogBtn = CreateFrame("Button", nil, sideLog, "UIPanelButtonTemplate")
clearLogBtn:SetSize(60, 20)
clearLogBtn:SetPoint("BOTTOMLEFT", 14, 12)
StyleButton(clearLogBtn)
clearLogBtn:SetText("Clear")
clearLogBtn:SetScript("OnClick", function() logMsg:Clear() end)

local bottomLogBtn = CreateFrame("Button", nil, sideLog, "UIPanelButtonTemplate")
bottomLogBtn:SetSize(60, 20)
bottomLogBtn:SetPoint("BOTTOMRIGHT", -14, 12)
StyleButton(bottomLogBtn)
bottomLogBtn:SetText("Bottom")
bottomLogBtn:SetScript("OnClick", function() logMsg:ScrollToBottom() end)

-- =========================================================================
-- MINIMIZE / RESTORE
-- Minimizing hides the board (and its game log) and shows a small restore bar.
-- =========================================================================
local restoreBar = CreateFrame("Frame", "TTS_BoardRestoreFrame", UIParent, backdropTemplate)
TTS.BoardRestoreFrame = restoreBar
restoreBar:SetSize(250, 40)
restoreBar:SetPoint("TOP", UIParent, "TOP", 0, -120)
Skin(restoreBar, "panel", { 0.04, 0.04, 0.04, 0.92 }, STYLE.panelBorder)
restoreBar:EnableMouse(true)
restoreBar:SetMovable(true)
restoreBar:RegisterForDrag("LeftButton")
restoreBar:SetScript("OnDragStart", restoreBar.StartMoving)
restoreBar:SetScript("OnDragStop", restoreBar.StopMovingOrSizing)
restoreBar:Hide()

local restoreText = restoreBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
restoreText:SetPoint("LEFT", 14, 0)
restoreText:SetText("Forever: CCG (minimized)")

local restoreBtn = CreateFrame("Button", nil, restoreBar, "UIPanelButtonTemplate")
restoreBtn:SetSize(70, 22)
restoreBtn:SetPoint("RIGHT", -10, 0)
StyleButton(restoreBtn)
restoreBtn:SetText("Restore")
restoreBtn:SetScript("OnClick", function() B:Show() end)

function B:Minimize()
    TT:Hide()
    self:Hide()
    restoreBar:Show()
end

-- Any way the board comes back (Restore, /tragic board, a new match) removes the restore bar
B:SetScript("OnShow", function(self)
    restoreBar:Hide()
    if self.soundCheck and TTS.Sound then self.soundCheck:SetChecked(TTS.Sound.enabled) end
    self:UpdateDisplay()
end)

local minimizeBtn = CreateFrame("Button", nil, B, "UIPanelButtonTemplate")
minimizeBtn:SetSize(24, 24)
minimizeBtn:SetPoint("TOPRIGHT", -16, -17)
minimizeBtn:SetText("-")
minimizeBtn:SetScript("OnClick", function() B:Minimize() end)
minimizeBtn:SetScript("OnEnter", function(self) TT:ShowText(self, "ANCHOR_TOP", "Minimize") end)
minimizeBtn:SetScript("OnLeave", function(self) TT:Hide(self) end)

-- =========================================================================
-- TOP & BOTTOM ACTION BUTTONS
-- =========================================================================
local concedeBtn = CreateFrame("Button", nil, B, "UIPanelButtonTemplate")
concedeBtn:SetSize(80, 24)
concedeBtn:SetPoint("RIGHT", minimizeBtn, "LEFT", -4, 0)
concedeBtn:SetText("Concede")
StyleButton(concedeBtn)
concedeBtn:SetScript("OnClick", function() TTS.Engine:ConcedeMatch() end)

local soundCheck = CreateFrame("CheckButton", nil, B, "UICheckButtonTemplate")
soundCheck:SetSize(24, 24)
soundCheck:SetPoint("RIGHT", concedeBtn, "LEFT", -6, 0)
soundCheck:SetChecked(true)
soundCheck:SetScript("OnClick", function(self)
    if TTS.Sound then TTS.Sound:SetEnabled(self:GetChecked()) end
end)
B.soundCheck = soundCheck   -- kept in step with the options menu

local soundLabel = B:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
soundLabel:SetPoint("RIGHT", soundCheck, "LEFT", 0, 1)
soundLabel:SetText("Sounds")
soundCheck:SetHitRectInsets(-(soundLabel:GetStringWidth() + 4), 0, 0, 0)

B.endTurnBtn = CreateFrame("Button", nil, B, "UIPanelButtonTemplate")
B.endTurnBtn:SetSize(90, 24)
B.endTurnBtn:SetPoint("BOTTOMRIGHT", -30, 16)
B.endTurnBtn:SetText("End Turn")
StyleButton(B.endTurnBtn)
B.endTurnBtn:SetScript("OnClick", function() TTS.Engine:EndTurn() end)

B.nextPhaseBtn = CreateFrame("Button", nil, B, "UIPanelButtonTemplate")
B.nextPhaseBtn:SetSize(160, 24)
B.nextPhaseBtn:SetPoint("RIGHT", B.endTurnBtn, "LEFT", -8, 0)
B.nextPhaseBtn:SetText("To Combat")
StyleButton(B.nextPhaseBtn)
B.nextPhaseBtn:SetScript("OnClick", function() TTS.Engine:NextPhase() end)

B.phaseText = B:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
B.phaseText:SetPoint("TOP", 0, -22)
B.phaseText:SetText("Phase: SETUP")

-- =========================================================================
-- MATCH OVER
-- The board stays up on the final state until the result popup is accepted.
-- =========================================================================
function B:ShowMatchResult(headline)
    self.phaseText:SetText(headline .. "  |cFFFFFFFF(click Accept to leave the board)|r")
    self.nextPhaseBtn:SetText("Match Over")
    self.nextPhaseBtn:Disable()
    self.endTurnBtn:Disable()
    concedeBtn:Disable()
end

function B:CloseAfterMatch()
    TT:Hide()
    self:Hide()
    restoreBar:Hide()
    if TTS.MainFrame then
        TTS.MainFrame:Show()
        if TTS.MainFrame.UpdatePlayState then
            TTS.MainFrame:UpdatePlayState()
        end
    end
end

-- =========================================================================
-- INTERACTIVE PLAYER LIFE PLATES
-- =========================================================================
B.oppLifeBtn = CreateFrame("Button", nil, B, backdropTemplate)
B.oppLifeBtn:SetSize(270, 28)
B.oppLifeBtn:SetPoint("TOPLEFT", 24, -15)
Skin(B.oppLifeBtn, "control", STYLE.controlBg, STYLE.controlBorder)
B.oppLifeBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

B.oppLifeText = B.oppLifeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
B.oppLifeText:SetPoint("LEFT", B.oppLifeBtn, "LEFT", 8, 0)
B.oppLifeText:SetJustifyH("LEFT")

B.oppLifeBtn:SetScript("OnClick", function(self, btn)
    if not TTS.Engine.inMatch then return end
    if btn == "RightButton" and TTS.Engine.targeting then
        TTS.Engine:CancelTargeting()
        return
    end
    if TTS.Engine.targeting and (TTS.Engine.targeting.targetType == "PLAYER" or TTS.Engine.targeting.targetType == "ANY") then
        TTS.Engine:ResolveTarget("PLAYER", true, 0)
    end
end)
B.oppLifeBtn:SetScript("OnEnter", function(self)
    TT:Show(self, "ANCHOR_BOTTOMLEFT", { main = function(tip)
        tip:AddLine(TTS.Engine.opponent or "Opponent", 1, 0.82, 0)
        tip:AddLine(string.format("Life: %d  |  Cards in Hand: %d", TTS.Engine.remoteState.life, TTS.Engine.remoteState.handCount), 1, 1, 1)
        if IsTargetingPlayer() then
            tip:AddLine(" ")
            tip:AddLine("|cFF00FF00[Left-Click to target this player]|r", 0.2, 1.0, 0.2)
        end
    end })
end)
B.oppLifeBtn:SetScript("OnLeave", function(self) TT:Hide(self) end)

B.myLifeBtn = CreateFrame("Button", nil, B, backdropTemplate)
B.myLifeBtn:SetSize(160, 30)
B.myLifeBtn:SetPoint("BOTTOMLEFT", 30, 14)
Skin(B.myLifeBtn, "control", STYLE.controlBg, STYLE.controlBorder)
B.myLifeBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

B.myLifeText = B.myLifeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
B.myLifeText:SetPoint("LEFT", B.myLifeBtn, "LEFT", 8, 0)
B.myLifeText:SetJustifyH("LEFT")

B.myLifeBtn:SetScript("OnClick", function(self, btn)
    if not TTS.Engine.inMatch then return end
    if btn == "RightButton" and TTS.Engine.targeting then
        TTS.Engine:CancelTargeting()
        return
    end
    if TTS.Engine.targeting and (TTS.Engine.targeting.targetType == "PLAYER" or TTS.Engine.targeting.targetType == "ANY") then
        TTS.Engine:ResolveTarget("PLAYER", false, 0)
    end
end)
B.myLifeBtn:SetScript("OnEnter", function(self)
    TT:Show(self, "ANCHOR_TOPLEFT", { main = function(tip)
        tip:AddLine("You", 1, 0.82, 0)
        tip:AddLine(string.format("Life: %d", TTS.Engine.localState.life), 1, 1, 1)
        if IsTargetingPlayer() then
            tip:AddLine(" ")
            tip:AddLine("|cFF00FF00[Left-Click to target yourself]|r", 0.2, 1.0, 0.2)
        end
    end })
end)
B.myLifeBtn:SetScript("OnLeave", function(self) TT:Hide(self) end)

-- =========================================================================
-- MANA COUNTER
-- "Mana:" then one hoverable slot per sphere, so each symbol has its tooltip
-- =========================================================================
local MANA_ORDER = { "W", "U", "B", "R", "G" }

B.manaText = B:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
B.manaText:SetPoint("BOTTOMLEFT", 205, 20)
B.manaText:SetText("Mana: ")

B.manaSlots = {}
do
    local prev = B.manaText
    for i, key in ipairs(MANA_ORDER) do
        local slot = CreateFrame("Frame", nil, B)
        slot:SetSize(40, 24)
        slot:SetPoint("LEFT", prev, "RIGHT", (i == 1) and 4 or 10, 0)
        slot.text = slot:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        slot.text:SetPoint("LEFT", slot, "LEFT", 0, 0)
        slot:EnableMouse(true)
        slot:SetScript("OnEnter", function(self)
            local mana = TTS.Engine.localState.mana or {}
            TT:ShowManaSymbol(self, "ANCHOR_TOP", key, mana[key] or 0)
        end)
        slot:SetScript("OnLeave", function(self) TT:Hide(self) end)
        B.manaSlots[key] = slot
        prev = slot
    end
end

-- =========================================================================
-- PLAYER EFFECT BARS (damage / healing over time, damage shields)
-- Opponent: top-right under Concede. You: right side above your deck.
-- =========================================================================
local EFFECT_ICON  = 24
local EFFECT_GAP   = 4
local EFFECT_COLS  = 3
local EFFECT_ROWS  = 2
local EFFECT_LABEL = 14

local EFFECT_DEFAULT_ICONS = {
    dot    = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
    hot    = "Interface\\Icons\\Spell_Nature_Rejuvenation",
    shield = "Interface\\Icons\\Spell_Holy_PowerWordShield",
}
local EFFECT_COLORS = {
    dot    = { 1.0, 0.2, 0.2 },
    hot    = { 0.2, 1.0, 0.2 },
    shield = { 1.0, 0.82, 0.0 },
}

local function EffectIcon_OnEnter(self)
    if self.effect then TT:ShowPlayerEffect(self, "ANCHOR_LEFT", self.effect) end
end

local function CreateEffectBar(labelText)
    local bar = CreateFrame("Frame", nil, B)
    bar:SetSize(EFFECT_COLS * (EFFECT_ICON + EFFECT_GAP) - EFFECT_GAP,
        EFFECT_LABEL + EFFECT_ROWS * (EFFECT_ICON + EFFECT_GAP))

    bar.label = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    bar.label:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 0, 0)
    bar.label:SetJustifyH("RIGHT")
    bar.label:SetText(labelText)

    bar.icons = {}
    for i = 1, EFFECT_COLS * EFFECT_ROWS do
        local col = (i - 1) % EFFECT_COLS
        local row = math.floor((i - 1) / EFFECT_COLS)
        local icon = CreateFrame("Frame", nil, bar)
        icon:SetSize(EFFECT_ICON, EFFECT_ICON)
        icon:SetPoint("TOPRIGHT", bar, "TOPRIGHT",
            -col * (EFFECT_ICON + EFFECT_GAP),
            -EFFECT_LABEL - row * (EFFECT_ICON + EFFECT_GAP))

        icon.border = icon:CreateTexture(nil, "BACKGROUND")
        icon.border:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
        icon.border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
        icon.border:SetColorTexture(1, 1, 1, 1)

        icon.tex = icon:CreateTexture(nil, "ARTWORK")
        icon.tex:SetAllPoints(icon)
        icon.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        icon.count = icon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        local fontPath = icon.count:GetFont()
        if fontPath then icon.count:SetFont(fontPath, 12, "OUTLINE") end
        icon.count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, 0)

        icon:EnableMouse(true)
        icon:SetScript("OnEnter", EffectIcon_OnEnter)
        icon:SetScript("OnLeave", function(self) TT:Hide(self) end)
        icon:Hide()
        bar.icons[i] = icon
    end
    bar:Hide()
    return bar
end

local function UpdateEffectBar(bar, effects)
    if #effects == 0 then
        bar:Hide()
        return
    end
    for i, icon in ipairs(bar.icons) do
        local e = effects[i]
        if e then
            local src = e.srcId and TTS.Cards[e.srcId]
            icon.effect = e
            icon.tex:SetTexture((src and src.art) or EFFECT_DEFAULT_ICONS[e.kind])
            local c = EFFECT_COLORS[e.kind]
            icon.border:SetVertexColor(c[1], c[2], c[3], 1)
            icon.count:SetText(e.kind == "shield" and e.n or e.turns)
            icon:Show()
        else
            icon.effect = nil
            icon:Hide()
        end
    end
    bar:Show()
end

B.oppEffectBar = CreateEffectBar("Opponent Effects")
B.oppEffectBar:SetPoint("TOPRIGHT", B, "TOPRIGHT", -20, -44)

B.myEffectBar = CreateEffectBar("Your Effects")
B.myEffectBar:SetPoint("BOTTOMRIGHT", B, "BOTTOMRIGHT", -20, 148)

local myHandFrames     = {}
local oppHandFrames    = {}
local myLandFrames     = {}
local myNonLandFrames  = {}
local oppLandFrames    = {}
local oppNonLandFrames = {}

-- =========================================================================
-- CARD TOOLTIPS (UI\Tooltips.lua stacks keywords, effects and symbols on them)
-- =========================================================================
-- P/T text for a creature on the battlefield. Damage taken this turn lowers the
-- toughness shown (in red) until it wears off at end of turn.
local function FormatPT(power, toughness, damage, colorCode)
    damage = damage or 0
    if damage > 0 then
        return string.format("%s%d/|r|cFFFF4444%d|r", colorCode, power, toughness - damage)
    end
    return string.format("%s%d/%d|r", colorCode, power, toughness)
end

local function Card_OnEnter(self)
    if not self.cardId then return end
    if self.isHand then
        self.hovered = true
        self:SetScale((self.baseScale or 1) * 1.18)
        self:SetFrameLevel((self.origFrameLevel or 10) + 15)
    end

    local card = TTS.Cards[self.cardId]
    if not card then return end
    if ShowBoardPreview then ShowBoardPreview(self, card) end

    local ctx = {}
    if self.fieldIndex then
        ctx.perm = (self.isRemote and TTS.Engine.remoteState.field or TTS.Engine.localState.field)[self.fieldIndex]
        ctx.isRemote = self.isRemote
        ctx.fieldIndex = self.fieldIndex
    end
    TT:ShowCard(self, "ANCHOR_TOP", self.cardId, ctx)
end

local function Card_OnLeave(self)
    if self.isHand then
        self.hovered = nil
        self:SetScale(self.baseScale or 1)
        if self.origFrameLevel then self:SetFrameLevel(self.origFrameLevel) end
    end
    TT:Hide(self)
    if HideBoardPreview then HideBoardPreview() end
end

local function GetCardFrameTexture(card)
    if not card then return CARD_FRAME_DEF end
    if card.color and CARD_FRAMES[string.upper(card.color)] then
        return CARD_FRAMES[string.upper(card.color)]
    end
    if card.school and CARD_FRAMES[string.upper(card.school)] then
        return CARD_FRAMES[string.upper(card.school)]
    end
    if card.cost and card.cost ~= "" then
        local firstColor = card.cost:match("{([WUBRGwubrg])}")
        if firstColor then
            return CARD_FRAMES[string.upper(firstColor)] or CARD_FRAME_DEF
        end
    end
    return CARD_FRAME_DEF
end

local function ApplyFrameTexture(t, card)
    local tex = GetCardFrameTexture(card)
    t:SetTexture(tex)
    if not t:GetTexture() then
        t:SetTexture(CARD_FRAME_DEF)
        if not t:GetTexture() then
            t:SetTexture(FALLBACK_BORDER)
        end
    end
end

local function ApplyBackTexture(t)
    t:SetTexture(CARD_BACK_TEX)
    if not t:GetTexture() then
        t:SetTexture(FALLBACK_BACK)
        t:SetVertexColor(0.2, 0.15, 0.1, 1.0)
    end
end

-- =========================================================================
-- CARD FRAME FACTORY
-- =========================================================================
local function CreateCardFrame(parent, sizeX, sizeY)
    local f = CreateFrame("Button", nil, parent)
    f:SetSize(sizeX, sizeY)
    f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    f.ttsSilent = true

    f.tuckedFrames = {}
    for k = 1, 3 do
        local tf = CreateFrame("Frame", nil, f)
        tf:SetSize(sizeX, sizeY)
        tf:SetPoint("TOPLEFT", f, "TOPLEFT", 6 * k, -9 * k)
        tf:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 6 * k, -9 * k)

        tf.bg = tf:CreateTexture(nil, "BACKGROUND")
        tf.bg:SetAllPoints(tf)
        tf.bg:SetColorTexture(0.08, 0.08, 0.08, 0.95)

        tf.art = tf:CreateTexture(nil, "ARTWORK")
        tf.art:SetPoint("TOPLEFT", tf, "TOPLEFT", 4, -4)
        tf.art:SetPoint("BOTTOMRIGHT", tf, "BOTTOMRIGHT", -4, 4)
        tf.art:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

        tf.border = tf:CreateTexture(nil, "OVERLAY")
        tf.border:SetAllPoints(tf)
        ApplyFrameTexture(tf.border)

        tf:EnableMouse(false)
        tf:Hide()
        f.tuckedFrames[k] = tf
    end

    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetAllPoints(f)
    f.bg:SetColorTexture(0.08, 0.08, 0.08, 0.95)

    local artLeft   = math.floor(sizeX * ART_BOX.left)
    local artRight  = math.floor(sizeX * ART_BOX.right)
    local artShift  = math.floor(sizeY * ART_BOX.shiftUp)
    local artTop    = math.floor(sizeY * ART_BOX.top) - artShift
    local artBottom = math.floor(sizeY * ART_BOX.bottom) + artShift

    local boxW = sizeX - artLeft - artRight
    local boxH = sizeY - artTop - artBottom
    local iconPadX = boxW * 0.025
    local iconPadY = boxH * 0.025

    f.art = f:CreateTexture(nil, "ARTWORK")
    f.art:SetPoint("TOPLEFT", f, "TOPLEFT", artLeft - iconPadX, -(artTop - iconPadY))
    f.art:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -artRight + iconPadX, artBottom - iconPadY)
    f.art:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

    f.model = CreateFrame("PlayerModel", nil, f)
    f.model:SetPoint("TOPLEFT", f, "TOPLEFT", artLeft, -artTop)
    f.model:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -artRight, artBottom)
    f.model:EnableMouse(false)
    f.model:Hide()

    f.overlay = CreateFrame("Frame", nil, f)
    f.overlay:SetAllPoints(f)
    f.overlay:EnableMouse(false)

    local function SyncFrameLevels(baseLevel)
        local base = baseLevel or f:GetFrameLevel() or 10
        if f.tuckedFrames then
            for k, tf in ipairs(f.tuckedFrames) do
                tf:SetFrameLevel(math.max(1, base - k))
            end
        end
        if f.model then f.model:SetFrameLevel(base + 1) end
        if f.overlay then f.overlay:SetFrameLevel(base + 2) end
        if f.tapLayer then f.tapLayer:SetFrameLevel(base + 3) end
    end

    f:SetFrameLevel(10)
    SyncFrameLevels(10)

    local origSetFrameLevel = f.SetFrameLevel
    f.SetFrameLevel = function(self, level)
        origSetFrameLevel(self, level)
        SyncFrameLevels(level)
    end

    f.border = f.overlay:CreateTexture(nil, "OVERLAY")
    f.border:SetAllPoints(f.overlay)
    ApplyFrameTexture(f.border)

    f.title = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.title:SetPoint("BOTTOMLEFT", f.overlay, "TOPLEFT", -6, 3)
    f.title:SetPoint("BOTTOMRIGHT", f.overlay, "TOPRIGHT", 6, 3)
    f.title:SetJustifyH("CENTER")

    f.cost = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.cost:SetPoint("BOTTOM", f.title, "TOP", 0, 1)
    f.cost:SetJustifyH("CENTER")
    f.cost:Hide()

    local ptOffsetY = math.floor(sizeY * 0.18)
    f.pt = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    local fontPath = f.pt:GetFont()
    if fontPath then f.pt:SetFont(fontPath, (sizeY > 80 and 15 or 12), "OUTLINE") end
    f.pt:SetPoint("BOTTOM", f.overlay, "BOTTOM", 0, ptOffsetY)
    f.pt:SetJustifyH("CENTER")
    f.pt:SetShadowOffset(1.5, -1.5)
    f.pt:SetShadowColor(0, 0, 0, 1)
    f.pt:Hide()
    f.ptOffsetY = ptOffsetY

    -- Rules text printed on the card (shown only while the card is big enough on screen)
    f.rules = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.rules:SetJustifyH("CENTER")
    f.rules:SetJustifyV("TOP")
    f.rules:SetWordWrap(true)
    f.rules:SetTextColor(0, 0, 0, 1)
    f.rules:SetShadowOffset(0, 0)
    f.rules:Hide()

    -- Tap symbol drawn over the middle of the card while the permanent is tapped
    local tapSize = math.floor(sizeX * 0.5)
    -- On its own layer above the overlay: within one frame WoW draws text over
    -- textures, so on the overlay the symbol would sit under the printed rules
    f.tapLayer = CreateFrame("Frame", nil, f)
    f.tapLayer:SetAllPoints(f)
    f.tapLayer:EnableMouse(false)
    f.tapLayer:SetFrameLevel(f:GetFrameLevel() + 3)
    f.tapIcon = f.tapLayer:CreateTexture(nil, "OVERLAY", nil, 7)
    f.tapIcon:SetSize(tapSize, tapSize)
    f.tapIcon:SetPoint("CENTER", f.tapLayer, "CENTER", 0, 0)
    f.tapIcon:SetTexture(TAP_TEX)
    f.tapIcon:Hide()

    f:SetScript("OnEnter", Card_OnEnter)
    f:SetScript("OnLeave", Card_OnLeave)
    f:SetScript("OnHide", function(self)
        if self.cost then self.cost:Hide() end
        -- A hovered card that disappears takes its preview with it
        if HideBoardPreview then HideBoardPreview(self) end
        if self.isHand then
            self.hovered = nil
            self:SetScale(self.baseScale or 1)
            if self.origFrameLevel then self:SetFrameLevel(self.origFrameLevel) end
        end
    end)
    f:Hide()
    return f
end

-- =========================================================================
-- CARD SCALING & PRINTED TEXT
-- Each row scales its cards by how many it holds: fewer cards, bigger cards,
-- down to the base size when the row is full. A card is centred on an
-- unscaled "slot" so scaling it never moves it.
-- =========================================================================
local HAND_W, HAND_H, HAND_STEP = 72, 102, 96
local HAND_LEFT, HAND_RIGHT, HAND_BOTTOM = 35, 1060, 52   -- right edge stops short of your deck
local HAND_MAX_SCALE = 1.2

local BF_CARD_W  = 64
local BF_CARD_H  = 84
local BF_STEP_X  = 86
local BF_START_X = 35
local BF_RIGHT   = 1045   -- right edge stops short of your effects bar
local LAND_MAX_SCALE     = 1.0
local CREATURE_MAX_SCALE = 1.2

-- Vertical centre of each battlefield row, measured up from the board's bottom edge
local ROW_Y = {
    myLand     = 256,
    myNonLand  = 367,
    oppNonLand = 490,
    oppLand    = 604,
}

local function AttachSlot(f)
    f.slot = CreateFrame("Frame", nil, B)
    f.slot:SetSize(1, 1)
    f:ClearAllPoints()
    f:SetPoint("CENTER", f.slot, "CENTER", 0, 0)
end

-- Largest scale (up to maxScale) at which n cards fit between left and right
local function FitScale(n, cardW, step, left, right, maxScale)
    if n <= 0 then return maxScale end
    local need = (n - 1) * step + cardW
    return math.max(0.5, math.min(maxScale, (right - left) / need))
end

local function PlaceCard(f, i, s, left, centerY, cardW, step)
    f.baseScale = s
    f:SetScale(f.hovered and s * 1.18 or s)
    f.slot:ClearAllPoints()
    f.slot:SetPoint("CENTER", B, "BOTTOMLEFT", left + (i - 1) * step * s + cardW * s / 2, centerY)
end

-- Prints the card's rules on it when the card is wide enough on screen; otherwise
-- hides them (tooltip only). P/T moves to the corner while text is printed.
-- opts (optional): fontMax, fontMin, offsetX (pixels right), offsetY (pixels down)
local function UpdateCardRules(f, opts)
    if not f.rules then return end
    local card = f.currentCard
    local fontMax = (opts and opts.fontMax) or RULES_FONT_MAX
    local fontMin = (opts and opts.fontMin) or RULES_FONT_MIN
    local dx = (opts and opts.offsetX) or 0
    local dy = (opts and opts.offsetY) or 0
    local hasPT = f.pt:IsShown()
    local w, h = f:GetSize()
    -- Width on screen, from the card's real scale (works on the board and in other windows);
    -- a hovered hand card's zoom is left out so hovering never toggles the text
    local onScreen = w * f:GetEffectiveScale() / UIParent:GetEffectiveScale() / (f.hovered and 1.18 or 1)

    f.pt:ClearAllPoints()
    if card and card.text and card.text ~= "" and onScreen >= CARD_TEXT_MIN_WIDTH then
        -- Fitting happens in the card's own (unscaled) size, so it only needs redoing for a new card
        if f.rulesCard ~= card or f.rulesPT ~= hasPT then
            f.rulesCard, f.rulesPT = card, hasPT
            f.rules:ClearAllPoints()
            f.rules:SetPoint("TOPLEFT", f.overlay, "TOPLEFT", w * TEXT_BOX.left + 1 + dx, -h * TEXT_BOX.top - 1 - dy)
            f.rules:SetPoint("BOTTOMRIGHT", f.overlay, "BOTTOMRIGHT", -w * TEXT_BOX.right + dx,
                h * (hasPT and TEXT_BOX.bottomWithPT or TEXT_BOX.bottom) - dy)
            f.rules:SetJustifyH("CENTER")
            local fontPath = f.rules:GetFont() or STANDARD_TEXT_FONT
            for size = fontMax, fontMin, -1 do
                f.rules:SetFont(fontPath, size, "")
                f.rules:SetText(TTS:FormatSymbols(card.text, size + 2 + RULES_TAP_EXTRA, size + 2 + RULES_TAP_EXTRA))
                if not (f.rules.IsTruncated and f.rules:IsTruncated()) then break end
            end
        end
        f.rules:Show()
        f.pt:SetPoint("BOTTOMRIGHT", f.overlay, "BOTTOMRIGHT", -w * 0.08, h * 0.05)
    else
        f.rules:Hide()
        f.pt:SetPoint("BOTTOM", f.overlay, "BOTTOM", 0, f.ptOffsetY or 0)
    end
end

-- Battlefield panel behind both sides' rows, with a faint gold line between them
local battlefield = CreateFrame("Frame", nil, B, backdropTemplate)
battlefield:SetPoint("BOTTOMLEFT", B, "BOTTOMLEFT", 24, 209)
battlefield:SetSize(1028, 456)
Skin(battlefield, "panel", STYLE.panelBg, STYLE.panelBorder)

local midLine = battlefield:CreateTexture(nil, "ARTWORK")
midLine:SetPoint("LEFT", battlefield, "BOTTOMLEFT", 8, 437 - 209)
midLine:SetPoint("RIGHT", battlefield, "BOTTOMRIGHT", -8, 437 - 209)
midLine:SetHeight(1)
midLine:SetColorTexture(1, 0.82, 0, 0.25)

-- =========================================================================
-- BOARD LAYOUT GRIDS
-- =========================================================================
for i = 1, 10 do
    local f = CreateCardFrame(B, HAND_W, HAND_H)
    f.isHand = true
    f.origFrameLevel = f:GetFrameLevel()
    AttachSlot(f)
    f:SetScript("OnClick", function(self, btn)
        if not TTS.Engine.inMatch then return end
        PlayUISound("card")
        if btn == "RightButton" and TTS.Engine.targeting then
            TTS.Engine:CancelTargeting()
            return
        end
        TTS.Engine:PlayCard(i)
    end)
    myHandFrames[i] = f
end

for i = 1, 10 do
    local f = CreateFrame("Button", nil, B)
    f:SetSize(52, 70)
    f:SetPoint("TOPLEFT", 35 + ((i - 1) * 64), -46)
    f.ttsSilent = true
    f.back = f:CreateTexture(nil, "ARTWORK")
    f.back:SetAllPoints(f)
    ApplyBackTexture(f.back)

    f.targetBorder = f:CreateTexture(nil, "OVERLAY")
    f.targetBorder:SetAllPoints(f)
    f.targetBorder:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    f.targetBorder:Hide()

    f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    f:SetScript("OnClick", function(self, btn)
        if not TTS.Engine.inMatch then return end
        PlayUISound("card")
        if btn == "RightButton" and TTS.Engine.targeting then
            TTS.Engine:CancelTargeting()
            return
        end
        if TTS.Engine.targeting and (TTS.Engine.targeting.targetType == "PLAYER" or TTS.Engine.targeting.targetType == "ANY") then
            TTS.Engine:ResolveTarget("PLAYER", true, 0)
        end
    end)
    f:SetScript("OnEnter", function(self)
        if IsTargetingPlayer() then
            TT:ShowText(self, "ANCHOR_TOP", TTS.Engine.opponent or "Opponent", nil,
                { r = 1, g = 0.82, b = 0, lines = { { "|cFF00FF00Click to target enemy player|r", 0.2, 1.0, 0.2 } } })
        end
    end)
    f:SetScript("OnLeave", function(self) TT:Hide(self) end)
    f:Hide()
    oppHandFrames[i] = f
end

local function MyLand_OnClick(self, btn)
    if btn == "RightButton" and TTS.Engine.targeting then
        TTS.Engine:CancelTargeting()
        return
    end
    if TTS.Engine.targeting and (TTS.Engine.targeting.targetType == "LAND") then
        if self.fieldIndex then TTS.Engine:ResolveTarget("LAND", false, self.fieldIndex) end
        return
    end
    if self.fieldIndex then TTS.Engine:TapCard(self.fieldIndex) end
end

local function MyNonLand_OnClick(self, btn)
    if btn == "RightButton" then
        if TTS.Engine.targeting then TTS.Engine:CancelTargeting(); return end
        local bs = TTS.Engine.blockingState
        if bs and bs.selectedBlocker then
            local idx = bs.selectedBlocker
            bs.selectedBlocker = nil
            if bs.blocks[idx] then
                bs.blocks[idx] = nil
                local perm = TTS.Engine.localState.field[idx]
                local card = perm and TTS.Cards[perm.id]
                TTS.Engine:Log(string.format("Removed |cFFFFD200%s|r from blocking.", card and card.name or "Creature"), "COMBAT")
            end
            TTS.Engine:RefreshUI()
            return
        end
    end
    if TTS.Engine.targeting then
        local t = TTS.Engine.targeting.targetType
        if t == "CREATURE" or t == "ANY" or t == "ARTIFACT_ENCHANTMENT" then
            if self.fieldIndex then TTS.Engine:ResolveTarget("CREATURE", false, self.fieldIndex) end
            return
        end
    end
    if self.fieldIndex then TTS.Engine:TapCard(self.fieldIndex) end
end

-- Wraps a click handler for your own permanents with the click / tap sound
local function WithFieldSound(handler)
    return function(self, btn)
        if not TTS.Engine.inMatch then return end
        local perm = self.fieldIndex and TTS.Engine.localState.field[self.fieldIndex]
        local wasTapped = perm and perm.tapped
        handler(self, btn)
        PlayFieldClickSound(perm, wasTapped)
    end
end

for i = 1, 12 do
    local f = CreateCardFrame(B, BF_CARD_W, BF_CARD_H)
    f.isRemote = false
    AttachSlot(f)
    f:SetScript("OnClick", WithFieldSound(MyLand_OnClick))
    myLandFrames[i] = f
end

for i = 1, 12 do
    local f = CreateCardFrame(B, BF_CARD_W, BF_CARD_H)
    f.isRemote = false
    AttachSlot(f)
    f:SetScript("OnClick", WithFieldSound(MyNonLand_OnClick))
    myNonLandFrames[i] = f
end

for i = 1, 12 do
    local f = CreateCardFrame(B, BF_CARD_W, BF_CARD_H)
    f.isRemote = true
    AttachSlot(f)
    f:SetScript("OnClick", function(self, btn)
        if not TTS.Engine.inMatch then return end
        PlayUISound("card")
        if btn == "RightButton" and TTS.Engine.targeting then
            TTS.Engine:CancelTargeting()
            return
        end
        if TTS.Engine.targeting and (TTS.Engine.targeting.targetType == "LAND") then
            if self.fieldIndex then TTS.Engine:ResolveTarget("LAND", true, self.fieldIndex) end
        end
    end)
    oppLandFrames[i] = f
end

for i = 1, 12 do
    local f = CreateCardFrame(B, BF_CARD_W, BF_CARD_H)
    f.isRemote = true
    AttachSlot(f)
    f:SetScript("OnClick", function(self, btn)
        if not TTS.Engine.inMatch then return end
        PlayUISound("card")
        if btn == "RightButton" and TTS.Engine.targeting then
            TTS.Engine:CancelTargeting()
            return
        end
        if TTS.Engine.targeting then
            local t = TTS.Engine.targeting.targetType
            if t == "CREATURE" or t == "ANY" or t == "ARTIFACT_ENCHANTMENT" then
                if self.fieldIndex then TTS.Engine:ResolveTarget("CREATURE", true, self.fieldIndex) end
                return
            end
        end
        if self.fieldIndex then TTS.Engine:ClickOpponentCard(self.fieldIndex) end
    end)
    oppNonLandFrames[i] = f
end

local myDeckFrame = CreateFrame("Frame", nil, B)
myDeckFrame:SetSize(62, 88)
myDeckFrame:SetPoint("BOTTOMRIGHT", -30, 52)
myDeckFrame.back = myDeckFrame:CreateTexture(nil, "ARTWORK")
myDeckFrame.back:SetAllPoints(myDeckFrame)
ApplyBackTexture(myDeckFrame.back)
myDeckFrame.count = myDeckFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
myDeckFrame.count:SetPoint("BOTTOM", myDeckFrame, "TOP", 0, 2)

-- =========================================================================
-- 3D MODEL VISUAL HELPER
-- =========================================================================
local function SetupCardVisual(f, card)
    f.currentCard = card
    if card and card.displayId then
        f.art:Hide()
        f.model:Show()
        f.model:ClearModel()
        f.model:SetDisplayInfo(card.displayId)

        local cam = card.modelCam or {}
        if f.model.SetPortraitZoom then f.model:SetPortraitZoom(cam.zoom or 0.75) end
        if f.model.SetCamDistanceScale then f.model:SetCamDistanceScale(cam.camScale or 1.0) end

        local baseZ = cam.z or -0.10
        local currentScale = B:GetScale() or 1.0
        local zComp = (currentScale - 1.0) * 0.18
        local adjZ = baseZ + zComp

        if f.model.SetPosition then f.model:SetPosition(cam.x or 0, cam.y or 0, adjZ) end
        if f.model.SetRotation then f.model:SetRotation(cam.rotation or 0.15) end
    else
        if f.model then f.model:Hide() end
        f.art:Show()
        f.art:SetTexture((card and card.art) or "Interface\\Icons\\INV_Misc_QuestionMark")
    end
end

RefreshAllModelCameras = function()
    local groups = { myHandFrames, myLandFrames, myNonLandFrames, oppLandFrames, oppNonLandFrames }
    for _, group in ipairs(groups) do
        for _, f in ipairs(group) do
            if f:IsShown() and f.currentCard and f.currentCard.displayId and f.model and f.model:IsShown() then
                local cam = f.currentCard.modelCam or {}
                local baseZ = cam.z or -0.10
                local currentScale = B:GetScale() or 1.0
                local zComp = (currentScale - 1.0) * 0.18
                local adjZ = baseZ + zComp
                if f.model.SetPosition then
                    f.model:SetPosition(cam.x or 0, cam.y or 0, adjZ)
                end
            end
        end
    end
end

RefreshCardText = function()
    local groups = { myHandFrames, myLandFrames, myNonLandFrames, oppLandFrames, oppNonLandFrames }
    for _, group in ipairs(groups) do
        for _, f in ipairs(group) do
            if f:IsShown() then UpdateCardRules(f) end
        end
    end
end

-- =========================================================================
-- CARD PREVIEW
-- Full-size copy of the hovered card, docked outside the left edge of the
-- board (same as the Deckbuilder's preview).
-- =========================================================================
local boardPreview, previewOwner

local function EnsureBoardPreview()
    if boardPreview then return boardPreview end
    local f = CreateCardFrame(B, PREVIEW_W, PREVIEW_H)
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel((B:GetFrameLevel() or 10) + 40)
    f:SetClampedToScreen(true)
    f:EnableMouse(false)
    f:SetScript("OnEnter", nil)
    f:SetScript("OnLeave", nil)
    boardPreview = f
    return f
end

ShowBoardPreview = function(owner, card)
    local f = EnsureBoardPreview()
    previewOwner = owner

    -- Card name and cost sit above the frame, so leave room for them
    f:ClearAllPoints()
    f:SetPoint("TOPRIGHT", B, "TOPLEFT", -12, -76)

    SetupCardVisual(f, card)
    ApplyFrameTexture(f.border, card)
    f.border:SetVertexColor(1, 1, 1)
    f.art:SetVertexColor(1, 1, 1)
    f.title:SetText(card.name or "")

    if card.cost and card.cost ~= "" then
        f.cost:SetText(TTS:FormatSymbols(card.cost, 18))
        f.cost:Show()
    else
        f.cost:Hide()
    end

    if card.type == "Creature" and card.power and card.toughness then
        f.pt:SetText(string.format("|cFFFFD200%d/%d|r", card.power, card.toughness))
        f.pt:Show()
    else
        f.pt:Hide()
    end

    f:Show()
    UpdateCardRules(f, PREVIEW_RULES)
end

-- owner (optional): only hide if this card is the one being previewed
HideBoardPreview = function(owner)
    if not boardPreview then return end
    if owner and owner ~= previewOwner then return end
    previewOwner = nil
    boardPreview:Hide()
end

-- =========================================================================
-- TUCKED CARDS
-- Attachments first, then the cards whose effects are on the permanent.
-- =========================================================================
local function UpdateTuckedFrames(f, perm)
    if not f.tuckedFrames then return end

    local stack = {}
    for _, att in ipairs(perm.attachments or {}) do
        local attId = type(att) == "table" and att.id or att
        local aCard = TTS.Cards[attId]
        if aCard then
            local isEquip = type(att) == "table" and att.isEquipment or (aCard.type == "Equipment" or aCard.isEquipment or aCard.subType == "Equipment")
            if isEquip then
                table.insert(stack, { card = aCard, r = 0.5, g = 0.8, b = 1.0 })
            else
                table.insert(stack, { card = aCard, r = 1.0, g = 0.85, b = 0.3 })
            end
        end
    end
    for _, effId in ipairs(TTS.Engine:GetPermEffectCards(perm)) do
        table.insert(stack, { card = TTS.Cards[effId], r = 1.0, g = 1.0, b = 1.0 })
    end

    for k, tf in ipairs(f.tuckedFrames) do
        local s = stack[k]
        if s then
            ApplyFrameTexture(tf.border, s.card)
            tf.art:SetTexture(s.card.art or "Interface\\Icons\\INV_Misc_QuestionMark")
            tf.border:SetVertexColor(s.r, s.g, s.b)
            tf:Show()
        else
            tf:Hide()
        end
    end
end

-- =========================================================================
-- BOARD DISPLAY UPDATE
-- =========================================================================
function B:UpdateDisplay()
    local E = TTS.Engine
    if not E.inMatch then return end
    concedeBtn:Enable()

    B.oppLifeText:SetText(string.format("%s: %d Life (%d cards)", E.opponent or "Opponent", E.remoteState.life, E.remoteState.handCount))
    B.myLifeText:SetText(string.format("Life: %d", E.localState.life))

    UpdateEffectBar(B.oppEffectBar, E:GetPlayerEffects(true))
    UpdateEffectBar(B.myEffectBar, E:GetPlayerEffects(false))

    local m = E.localState.mana
    for _, key in ipairs(MANA_ORDER) do
        local slot = B.manaSlots[key]
        slot.text:SetText(string.format("%s |cFFFFFFFF%d|r", TTS:FormatSymbols("{" .. key .. "}", 22), m[key] or 0))
        slot:SetWidth(math.max(1, slot.text:GetStringWidth()))
    end

    local isTargetingPlayer = IsTargetingPlayer()

    if isTargetingPlayer then
        B.oppLifeBtn:SetBackdropBorderColor(0.2, 1.0, 0.2, 1.0)
        B.oppLifeBtn:SetBackdropColor(0.1, 0.35, 0.1, 0.8)
        B.myLifeBtn:SetBackdropBorderColor(0.2, 1.0, 0.2, 1.0)
        B.myLifeBtn:SetBackdropColor(0.1, 0.35, 0.1, 0.8)
    else
        local bg, bd = STYLE.controlBg, STYLE.controlBorder
        B.oppLifeBtn:SetBackdropBorderColor(bd[1], bd[2], bd[3], bd[4])
        B.oppLifeBtn:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
        B.myLifeBtn:SetBackdropBorderColor(bd[1], bd[2], bd[3], bd[4])
        B.myLifeBtn:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
    end

    -- =====================================================================
    -- PHASE & COMBAT BUTTON STATE
    -- =====================================================================
    if E.phase == "COMBAT_BLOCK" and E.blockingState then
        B.endTurnBtn:Disable()
        if E.blockingState.isRemoteAttacking then
            if E.blockingState.blocksDeclared then
                -- Local player is defending and has declared: the attacker resolves
                B.nextPhaseBtn:SetText("Waiting for Attacker...")
                B.nextPhaseBtn:Disable()
            else
                -- Local player is defending: enabled to confirm blocks
                B.nextPhaseBtn:Enable()
                local numBlocks = 0
                for _ in pairs(E.blockingState.blocks) do numBlocks = numBlocks + 1 end
                if numBlocks > 0 then
                    B.nextPhaseBtn:SetText("Confirm Blocks")
                else
                    B.nextPhaseBtn:SetText("No Blocks (Pass)")
                end
            end
        elseif E.blockingState.blocksDeclared then
            -- Local player is attacking and blocks are in: review them, then resolve
            B.nextPhaseBtn:SetText("Resolve Combat")
            B.nextPhaseBtn:Enable()
        else
            -- Local player is attacking: waiting for the defender to declare blocks
            B.nextPhaseBtn:SetText("Waiting for Defender...")
            B.nextPhaseBtn:Disable()
        end
    elseif E.pendingDiscard then
        B.nextPhaseBtn:SetText("Discard a Card")
        B.nextPhaseBtn:Disable()
        B.endTurnBtn:Disable()
    elseif E.phase == "COMBAT_ATTACK" then
        B.nextPhaseBtn:Enable()
        B.nextPhaseBtn:SetText("Declare Blocks")
        B.endTurnBtn:Disable()
    elseif not E.isMyTurn or E.phase == "WAITING" or E.phase == "WAITING (Dummy Turn)" or E.phase == "PREGAME" then
        B.nextPhaseBtn:SetText("Opponent Turn")
        B.nextPhaseBtn:Disable()
        B.endTurnBtn:Disable()
    else
        B.nextPhaseBtn:Enable()
        B.endTurnBtn:Enable()
        if E.phase == "MAIN1" then
            B.nextPhaseBtn:SetText("To Combat")
        elseif E.phase == "MAIN2" then
            B.nextPhaseBtn:SetText("End Turn")
        else
            B.nextPhaseBtn:SetText("Next Phase")
        end
    end

    -- =====================================================================
    -- TOP PHASE TEXT
    -- =====================================================================
    if E.pendingDiscard then
        B.phaseText:SetText("|cFFFFCC00DISCARD: Click a card in your hand to discard|r")
    elseif E.targeting then
        B.phaseText:SetText(string.format("|cFFFFD200TARGETING: Select %s for %s (Right-click to cancel)|r", E.targeting.targetType, E.targeting.cardName))
    elseif E.phase == "COMBAT_BLOCK" and E.blockingState then
        if E.blockingState.isRemoteAttacking then
            if E.blockingState.blocksDeclared then
                B.phaseText:SetText("|cFFFFD200COMBAT: Blocks declared. Waiting for attacker to resolve...|r")
            else
                B.phaseText:SetText("|cFFFF4444COMBAT: Assign Blockers, then click Confirm Blocks|r")
            end
        elseif E.blockingState.blocksDeclared then
            B.phaseText:SetText("|cFFFF4444COMBAT: Review the blocks, then click Resolve Combat|r")
        else
            B.phaseText:SetText("|cFFFFD200COMBAT: Opponent is declaring blockers...|r")
        end
    else
        B.phaseText:SetText("Phase: " .. E.phase)
    end

    myDeckFrame.count:SetText(#E.localState.deck)

    local oppCount = math.min(10, E.remoteState.handCount or 0)
    for i = 1, 10 do
        if i <= oppCount then
            ApplyBackTexture(oppHandFrames[i].back)
            if isTargetingPlayer then
                oppHandFrames[i].targetBorder:SetVertexColor(0.2, 1.0, 0.2, 1.0)
                oppHandFrames[i].targetBorder:Show()
            else
                oppHandFrames[i].targetBorder:Hide()
            end
            oppHandFrames[i]:Show()
        else
            oppHandFrames[i]:Hide()
        end
    end

    local handScale = FitScale(math.min(10, #E.localState.hand), HAND_W, HAND_STEP, HAND_LEFT, HAND_RIGHT, HAND_MAX_SCALE)
    for i = 1, 10 do
        local cardId = E.localState.hand[i]
        if cardId then
            local card = TTS.Cards[cardId]
            local f = myHandFrames[i]
            f.cardId = cardId
            SetupCardVisual(f, card)
            ApplyFrameTexture(f.border, card)
            f.title:SetText(card.name)

            if card.cost and card.cost ~= "" then
                f.cost:SetText(TTS:FormatSymbols(card.cost, 16))
                f.cost:Show()
            else
                f.cost:Hide()
            end

            if card.type == "Creature" and card.power and card.toughness then
                f.pt:SetText(string.format("|cFFFFD200%d/%d|r", card.power, card.toughness))
                f.pt:Show()
            else
                f.pt:Hide()
            end

            if E.pendingDiscard then
                f.border:SetVertexColor(1.0, 0.4, 0.4)
            elseif E.targeting and E.targeting.handIndex == i then
                f.border:SetVertexColor(1.0, 0.8, 0.0)
            else
                f.border:SetVertexColor(1.0, 1.0, 1.0)
            end
            PlaceCard(f, i, handScale, HAND_LEFT, HAND_BOTTOM + HAND_H * handScale / 2, HAND_W, HAND_STEP)
            f:Show()
            UpdateCardRules(f)
        else
            myHandFrames[i]:Hide()
        end
    end

    local myLandIdx, myNonLandIdx = 0, 0
    for i, perm in ipairs(E.localState.field) do
        local card = TTS.Cards[perm.id]
        if card then
            local isLand = (card.type == "Land")
            local f = nil
            if isLand then
                myLandIdx = myLandIdx + 1
                if myLandIdx <= #myLandFrames then f = myLandFrames[myLandIdx] end
            else
                myNonLandIdx = myNonLandIdx + 1
                if myNonLandIdx <= #myNonLandFrames then f = myNonLandFrames[myNonLandIdx] end
            end

            if f then
                f.fieldIndex = i
                f.cardId = perm.id
                SetupCardVisual(f, card)
                ApplyFrameTexture(f.border, card)
                f.title:SetText(card.name)

                UpdateTuckedFrames(f, perm)

                if card.type == "Creature" then
                    local effP, effT = E:GetCreatureStats(perm, false)
                    local colorCode = (effP > card.power or effT > card.toughness) and "|cFF00FF00" or "|cFFFFD200"
                    f.pt:SetText(FormatPT(effP, effT, perm.damage, colorCode))
                    f.pt:Show()
                else
                    f.pt:Hide()
                end

                local shade = perm.tapped and 0.4 or 1.0
                if E.targeting then
                    f.border:SetVertexColor(0.2, 1.0, 0.2)
                elseif E.blockingState and E.blockingState.selectedBlocker == i then
                    f.border:SetVertexColor(0.0, 1.0, 1.0)
                elseif E.blockingState and E.blockingState.blocks and E.blockingState.blocks[i] then
                    f.border:SetVertexColor(0.2, 0.9, 0.2)
                elseif perm.isAttacking then
                    f.border:SetVertexColor(1.0, 0.2, 0.2)
                else
                    f.border:SetVertexColor(shade, shade, shade)
                end
                f.art:SetVertexColor(shade, shade, shade)
                if perm.tapped then f.tapIcon:Show() else f.tapIcon:Hide() end
                f:Show()
            end
        end
    end

    local function LayoutRow(frames, count, centerY, maxScale)
        count = math.min(count, #frames)
        local s = FitScale(count, BF_CARD_W, BF_STEP_X, BF_START_X, BF_RIGHT, maxScale)
        for k = 1, count do
            PlaceCard(frames[k], k, s, BF_START_X, centerY, BF_CARD_W, BF_STEP_X)
            UpdateCardRules(frames[k])
        end
    end
    LayoutRow(myLandFrames, myLandIdx, ROW_Y.myLand, LAND_MAX_SCALE)
    LayoutRow(myNonLandFrames, myNonLandIdx, ROW_Y.myNonLand, CREATURE_MAX_SCALE)

    for i = myLandIdx + 1, #myLandFrames do
        myLandFrames[i]:Hide()
        myLandFrames[i].fieldIndex = nil
        if myLandFrames[i].tuckedFrames then for k = 1, #myLandFrames[i].tuckedFrames do myLandFrames[i].tuckedFrames[k]:Hide() end end
    end
    for i = myNonLandIdx + 1, #myNonLandFrames do
        myNonLandFrames[i]:Hide()
        myNonLandFrames[i].fieldIndex = nil
        if myNonLandFrames[i].tuckedFrames then for k = 1, #myNonLandFrames[i].tuckedFrames do myNonLandFrames[i].tuckedFrames[k]:Hide() end end
    end

    local oppLandIdx, oppNonLandIdx = 0, 0
    for i, perm in ipairs(E.remoteState.field) do
        local card = TTS.Cards[perm.id]
        if card then
            local isLand = (card.type == "Land")
            local f = nil
            if isLand then
                oppLandIdx = oppLandIdx + 1
                if oppLandIdx <= #oppLandFrames then f = oppLandFrames[oppLandIdx] end
            else
                oppNonLandIdx = oppNonLandIdx + 1
                if oppNonLandIdx <= #oppNonLandFrames then f = oppNonLandFrames[oppNonLandIdx] end
            end

            if f then
                f.fieldIndex = i
                f.cardId = perm.id
                SetupCardVisual(f, card)
                ApplyFrameTexture(f.border, card)
                f.title:SetText(card.name)

                UpdateTuckedFrames(f, perm)

                if card.type == "Creature" then
                    local effP, effT = E:GetCreatureStats(perm, true)
                    f.pt:SetText(FormatPT(effP, effT, perm.damage, "|cFFFFD200"))
                    f.pt:Show()
                else
                    f.pt:Hide()
                end

                local shade = perm.tapped and 0.4 or 1.0
                if E.targeting then
                    f.border:SetVertexColor(0.2, 1.0, 0.2)
                elseif perm.isAttacking then
                    f.border:SetVertexColor(1.0, 0.2, 0.2)
                else
                    f.border:SetVertexColor(shade, shade, shade)
                end
                f.art:SetVertexColor(shade, shade, shade)
                if perm.tapped then f.tapIcon:Show() else f.tapIcon:Hide() end
                f:Show()
            end
        end
    end

    LayoutRow(oppLandFrames, oppLandIdx, ROW_Y.oppLand, LAND_MAX_SCALE)
    LayoutRow(oppNonLandFrames, oppNonLandIdx, ROW_Y.oppNonLand, CREATURE_MAX_SCALE)

    for i = oppLandIdx + 1, #oppLandFrames do
        oppLandFrames[i]:Hide()
        oppLandFrames[i].fieldIndex = nil
        if oppLandFrames[i].tuckedFrames then for k = 1, #oppLandFrames[i].tuckedFrames do oppLandFrames[i].tuckedFrames[k]:Hide() end end
    end
    for i = oppNonLandIdx + 1, #oppNonLandFrames do
        oppNonLandFrames[i]:Hide()
        oppNonLandFrames[i].fieldIndex = nil
        if oppNonLandFrames[i].tuckedFrames then for k = 1, #oppNonLandFrames[i].tuckedFrames do oppNonLandFrames[i].tuckedFrames[k]:Hide() end end
    end
end

-- =========================================================================
-- FOOTER
-- =========================================================================
local footer = B:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
footer:SetPoint("BOTTOM", B, "BOTTOM", 0, 10)
footer:SetText("Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy")

-- =========================================================================
-- MODULE EXPORTS
-- =========================================================================
TTS.CreateCardFrame     = CreateCardFrame
TTS.SetupCardVisual     = SetupCardVisual
TTS.ApplyFrameTexture   = ApplyFrameTexture
TTS.GetCardFrameTexture = GetCardFrameTexture
TTS.CARD_FRAME_DEF      = CARD_FRAME_DEF
TTS.UpdateCardRules     = UpdateCardRules  -- prints rules text on any card made by CreateCardFrame
TTS.FormatPT            = FormatPT         -- P/T with damage shown, used by the card tooltips
B.myHandFrames          = myHandFrames  -- read by TargetFX.lua (targeting arrow source)

-- =========================================================================
-- SAVED SIZE (applied once the saved settings have loaded)
-- =========================================================================
local scaleLoader = CreateFrame("Frame")
scaleLoader:RegisterEvent("ADDON_LOADED")
scaleLoader:SetScript("OnEvent", function(self, event, addon)
    if addon ~= "ForeverCCG" then return end
    self:UnregisterAllEvents()
    local saved = TTS.Options and tonumber(TTS.Options:Get("boardScale"))
    if saved then
        B:SetScale(math.max(BOARD_MIN_SCALE, math.min(BOARD_MAX_SCALE, saved)))
    end
end)