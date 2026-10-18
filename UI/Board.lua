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
    top          = 0.60,
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

    -- A signed pair ("+1/+1", "-0/-1") is a power/toughness change: drawn with the stats emblem.
    -- Unsigned pairs stay (they can be counts, "2/4 copies"); rules text marks its own (TTS:CardRulesText).
    str = str:gsub("([%+%-]%d+)/([%+%-]%d+)", "%1{PT}%2")

    local formatted = str:gsub("{(%w+)}", function(key)
        local upperKey = string.upper(key)

        -- Tap Symbol
        if upperKey == "T" or upperKey == "TAP" then
            return string.format("|T%s:%d:%d:0:0|t", TAP_TEX, ts, ts)
        end

        -- Power / toughness emblem (anthem bonuses in rules text)
        if upperKey == "PT" and TTS.StatsEmblemIcon then
            return TTS.StatsEmblemIcon(s)
        end

        -- Generic / Numeric / X: the number takes the text's own colour (black in printed
        -- rules text, white on cost lines and in the log)
        if tonumber(key) or upperKey == "X" then
            return string.format("|cFF8E939B(|r%s|cFF8E939B)|r", upperKey)
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
    if card.creatureType then table.insert(parts, Loc:Term("creatureType", card.creatureType)) end
    if card.faction then table.insert(parts, "|cFFFFD200" .. Loc:Term("faction", card.faction) .. "|r") end
    if card.zone then table.insert(parts, "|cFF888888" .. Loc:Term("zone", card.zone) .. "|r") end
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

-- The targeting to highlight for: one in progress, or the one a card being dragged would start (UI\CardDrag.lua)
local function HighlightTargeting()
    return TTS.Engine.targeting or (TTS.BoardFrame and TTS.BoardFrame.dragTargeting)
end

-- True if the targeting in progress can choose that player (isRemote: the opponent)
local function IsTargetingPlayer(isRemote)
    local t = HighlightTargeting()
    return t and TTS.Engine:IsValidTargetNow("PLAYER", isRemote, nil, t) or false
end

-- True if the targeting in progress can choose this creature
local function IsTargetableCreature(perm, isRemote)
    local t = HighlightTargeting()
    return t and TTS.Engine:IsValidTargetNow("CREATURE", isRemote, perm, t) or false
end

-- How cards are played: "click", "drag" or "both" (Options)
function TTS.CardControls()
    local mode = TTS.Options and TTS.Options:Get("cardControls")
    return (mode == "click" or mode == "drag") and mode or "both"
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
-- A choice left open (UI\Choice.lua) goes with the board
B:HookScript("OnHide", function() if TTS.Choice then TTS.Choice:Cancel() end end)
B:SetSize(1160, 820)
B:SetPoint("CENTER")
Skin(B, "dialog")
-- The top strip holds the opponent's life, the phase and the window buttons
AddTitleStrip(B, 33)
B:EnableMouse(true)
B:SetMovable(true)
B:RegisterForDrag("LeftButton")
B:SetScript("OnDragStart", function(self)
    if TTS.Options and TTS.Options:Get("boardLocked") then return end   -- the Lock checkbox
    self:StartMoving()
end)
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
sideLog:SetSize(250, 820)
sideLog:SetPoint("TOPLEFT", B, "TOPRIGHT", 6, 0)
Skin(sideLog, "dialog")
AddTitleStrip(sideLog)

local logTitle = sideLog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
logTitle:SetPoint("TOPLEFT", 16, -11)
Loc:Bind(logTitle, "board.gameLog")

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
Loc:Bind(clearLogBtn, "board.clear")
clearLogBtn:SetScript("OnClick", function() logMsg:Clear() end)

local bottomLogBtn = CreateFrame("Button", nil, sideLog, "UIPanelButtonTemplate")
bottomLogBtn:SetSize(60, 20)
bottomLogBtn:SetPoint("BOTTOMRIGHT", -14, 12)
StyleButton(bottomLogBtn)
Loc:Bind(bottomLogBtn, "board.bottom")
bottomLogBtn:SetScript("OnClick", function() logMsg:ScrollToBottom() end)

-- Minimising the log folds it up to its title strip (remembered between games)
do
    local logParts = { logPanel, logMsg, clearLogBtn, bottomLogBtn }
    local foldBtn = CreateFrame("Button", nil, sideLog, "UIPanelButtonTemplate")
    foldBtn:SetSize(24, 24)
    foldBtn:SetPoint("TOPRIGHT", -16, -9)

    function sideLog:SetFolded(folded)
        for _, part in ipairs(logParts) do part:SetShown(not folded) end
        self:SetHeight(folded and 44 or 820)
        foldBtn:SetText(folded and "+" or "-")
        if TTS.Options then TTS.Options:Set("gameLogFolded", folded) end
    end

    foldBtn:SetScript("OnClick", function()
        sideLog:SetFolded(not (TTS.Options and TTS.Options:Get("gameLogFolded")))
    end)
    foldBtn:SetScript("OnEnter", function(self)
        local folded = TTS.Options and TTS.Options:Get("gameLogFolded")
        TT:ShowText(self, "ANCHOR_TOP", L(folded and "board.restore" or "board.minimize"))
    end)
    foldBtn:SetScript("OnLeave", function(self) TT:Hide(self) end)
    sideLog:SetScript("OnShow", function(self)
        self:SetFolded(TTS.Options and TTS.Options:Get("gameLogFolded") or false)
    end)
end

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
Loc:Bind(restoreText, "board.minimized")

local restoreBtn = CreateFrame("Button", nil, restoreBar, "UIPanelButtonTemplate")
restoreBtn:SetSize(70, 22)
restoreBtn:SetPoint("RIGHT", -10, 0)
StyleButton(restoreBtn)
Loc:Bind(restoreBtn, "board.restore")
restoreBtn:SetScript("OnClick", function() B:Show() end)

function B:Minimize()
    TT:Hide()
    self:Hide()
    restoreBar:Show()
end

-- Any way the board comes back (Restore, /tragic board, a new match) removes the restore bar
B:SetScript("OnShow", function(self)
    restoreBar:Hide()
    if TTS.RedrawCardModels then TTS.RedrawCardModels() end
    if self.soundCheck and TTS.Sound then self.soundCheck:SetChecked(TTS.Sound.enabled) end
    if self.autoPayCheck and TTS.Options then self.autoPayCheck:SetChecked(TTS.Options:Get("autoPayMana") ~= false) end
    if self.lockCheck and TTS.Options then self.lockCheck:SetChecked(TTS.Options:Get("boardLocked") and true or false) end
    self:UpdateDisplay()
end)

local minimizeBtn = CreateFrame("Button", nil, B, "UIPanelButtonTemplate")
minimizeBtn:SetSize(24, 24)
minimizeBtn:SetPoint("TOPRIGHT", -16, -17)
minimizeBtn:SetText("-")
minimizeBtn:SetScript("OnClick", function() B:Minimize() end)
minimizeBtn:SetScript("OnEnter", function(self) TT:ShowText(self, "ANCHOR_TOP", L("board.minimize")) end)
minimizeBtn:SetScript("OnLeave", function(self) TT:Hide(self) end)

-- =========================================================================
-- TOP & BOTTOM ACTION BUTTONS
-- =========================================================================
local concedeBtn = CreateFrame("Button", nil, B, "UIPanelButtonTemplate")
concedeBtn:SetSize(80, 24)
concedeBtn:SetPoint("RIGHT", minimizeBtn, "LEFT", -4, 0)
Loc:Bind(concedeBtn, "board.concede")
StyleButton(concedeBtn)
concedeBtn:SetScript("OnClick", function() TTS.Engine:ConfirmConcede() end)

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
Loc:Bind(soundLabel, "board.sounds")
soundCheck:SetHitRectInsets(-(soundLabel:GetStringWidth() + 4), 0, 0, 0)

-- Auto-pay: casting taps the prayers the mana pool is short of (CoreEngine.lua)
local autoPayCheck = CreateFrame("CheckButton", nil, B, "UICheckButtonTemplate")
autoPayCheck:SetSize(24, 24)
autoPayCheck:SetPoint("RIGHT", soundLabel, "LEFT", -10, -1)
autoPayCheck:SetScript("OnClick", function(self)
    if TTS.Options then TTS.Options:Set("autoPayMana", self:GetChecked() and true or false) end
end)
B.autoPayCheck = autoPayCheck   -- set from the saved option when the board opens

local autoPayLabel = B:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
autoPayLabel:SetPoint("RIGHT", autoPayCheck, "LEFT", 0, 1)
Loc:Bind(autoPayLabel, "board.autoPay")
autoPayCheck:SetHitRectInsets(-(autoPayLabel:GetStringWidth() + 4), 0, 0, 0)
autoPayCheck:SetScript("OnEnter", function(self)
    TT:ShowText(self, "ANCHOR_TOP", L("board.autoPayTitle"), L("board.autoPayDesc"))
end)
autoPayCheck:SetScript("OnLeave", function(self) TT:Hide(self) end)

-- Lock: the board can't be dragged (OnDragStart above)
local lockCheck = CreateFrame("CheckButton", nil, B, "UICheckButtonTemplate")
lockCheck:SetSize(24, 24)
lockCheck:SetPoint("RIGHT", autoPayLabel, "LEFT", -10, -1)
lockCheck:SetScript("OnClick", function(self)
    if TTS.Options then TTS.Options:Set("boardLocked", self:GetChecked() and true or false) end
end)
B.lockCheck = lockCheck   -- set from the saved option when the board opens

local lockLabel = B:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
lockLabel:SetPoint("RIGHT", lockCheck, "LEFT", 0, 1)
Loc:Bind(lockLabel, "board.lock")
lockCheck:SetHitRectInsets(-(lockLabel:GetStringWidth() + 4), 0, 0, 0)
lockCheck:SetScript("OnEnter", function(self)
    TT:ShowText(self, "ANCHOR_TOP", L("board.lockTitle"), L("board.lockDesc"))
end)
lockCheck:SetScript("OnLeave", function(self) TT:Hide(self) end)

-- Subtitle in the title strip, as on the other Forever: CCG windows
local subtitle = B:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
subtitle:SetPoint("RIGHT", lockLabel, "LEFT", -14, 0)
subtitle:SetText("Forever: CCG")

B.endTurnBtn = CreateFrame("Button", nil, B, "UIPanelButtonTemplate")
B.endTurnBtn:SetSize(90, 24)
B.endTurnBtn:SetPoint("BOTTOMRIGHT", -30, 16)
Loc:Bind(B.endTurnBtn, "board.endTurn")
StyleButton(B.endTurnBtn)
B.endTurnBtn:SetScript("OnClick", function() TTS.Engine:EndTurn() end)

B.nextPhaseBtn = CreateFrame("Button", nil, B, "UIPanelButtonTemplate")
B.nextPhaseBtn:SetSize(160, 24)
B.nextPhaseBtn:SetPoint("RIGHT", B.endTurnBtn, "LEFT", -8, 0)
Loc:Bind(B.nextPhaseBtn, "board.toCombat")
StyleButton(B.nextPhaseBtn)
B.nextPhaseBtn:SetScript("OnClick", function() TTS.Engine:NextPhase() end)

-- Takes back the last card played this phase (greyed out when it cannot be used)
B.undoBtn = CreateFrame("Button", nil, B, "UIPanelButtonTemplate")
B.undoBtn:SetSize(70, 24)
B.undoBtn:SetPoint("RIGHT", B.nextPhaseBtn, "LEFT", -8, 0)
Loc:Bind(B.undoBtn, "board.undo")
StyleButton(B.undoBtn)
if B.undoBtn.SetMotionScriptsWhileDisabled then B.undoBtn:SetMotionScriptsWhileDisabled(true) end
B.undoBtn:SetScript("OnClick", function(self)
    TT:Hide(self)
    TTS.Engine:RequestUndo()
end)
B.undoBtn:SetScript("OnEnter", function(self)
    local E = TTS.Engine
    local ok, reason = E:CanUndo()
    local lines = {}
    if ok then
        table.insert(lines, { L("board.undoDesc", E:UndoCardName()), 1, 1, 1, true })
        if not E.isSolo then
            table.insert(lines, { L("board.undoAgree", E.opponent or L("undo.yourOpponentCap")), 0.7, 0.7, 0.7, true })
        end
    else
        table.insert(lines, { reason, 1, 0.4, 0.4, true })
    end
    TT:ShowText(self, "ANCHOR_TOP", L("board.undo"), nil, { r = 1, g = 0.82, b = 0, lines = lines })
end)
B.undoBtn:SetScript("OnLeave", function(self) TT:Hide(self) end)

-- Shuffles the opening hand back for a new one (shown until the hand is kept, CoreEngine.lua)
B.mulliganBtn = CreateFrame("Button", nil, B, "UIPanelButtonTemplate")
B.mulliganBtn:SetSize(80, 24)
B.mulliganBtn:SetPoint("RIGHT", B.undoBtn, "LEFT", -8, 0)
Loc:Bind(B.mulliganBtn, "board.mulligan")
StyleButton(B.mulliganBtn)
if B.mulliganBtn.SetMotionScriptsWhileDisabled then B.mulliganBtn:SetMotionScriptsWhileDisabled(true) end
B.mulliganBtn:SetScript("OnClick", function(self)
    TT:Hide(self)
    TTS.Engine:ConfirmMulligan()
end)
B.mulliganBtn:SetScript("OnEnter", function(self)
    local ok, reason = TTS.Engine:CanMulligan()
    local lines = { { L("board.mulliganDesc"), 1, 1, 1, true } }
    if not ok and reason then table.insert(lines, { reason, 1, 0.4, 0.4, true }) end
    TT:ShowText(self, "ANCHOR_TOP", L("board.mulligan"), nil, { r = 1, g = 0.82, b = 0, lines = lines })
end)
B.mulliganBtn:SetScript("OnLeave", function(self) TT:Hide(self) end)
B.mulliganBtn:Hide()

B.phaseText = B:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
B.phaseText:SetPoint("TOP", 0, -22)
Loc:Bind(B.phaseText, "phase.label", "SETUP")

-- =========================================================================
-- MATCH OVER
-- The board stays up on the final state until the result popup is accepted.
-- =========================================================================
function B:ShowMatchResult(headline)
    self.phaseText:SetText(headline .. "  |cFFFFFFFF" .. L("board.clickAccept") .. "|r")
    self.nextPhaseBtn:SetText(L("board.matchOver"))
    self.nextPhaseBtn:Disable()
    self.endTurnBtn:Disable()
    self.undoBtn:Disable()
    self.mulliganBtn:Hide()
    concedeBtn:Disable()
end

-- The reward card earned by a solo win, in the docked preview until the board closes
function B:ShowRewardCard(card)
    if card and ShowBoardPreview then ShowBoardPreview(self, card) end
end

function B:CloseAfterMatch()
    TT:Hide()
    if HideBoardPreview then HideBoardPreview() end
    if self.ClearBackground then self:ClearBackground() end
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

-- Solo encounter rules, beside the opponent's name (details in its tooltip)
B.oppRulesText = B:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
B.oppRulesText:SetPoint("TOPLEFT", B.oppLifeBtn, "TOPRIGHT", 8, -2)
B.oppRulesText:SetWidth(220)
B.oppRulesText:SetJustifyH("LEFT")
B.oppRulesText:SetTextColor(1, 0.5, 0.25)

-- PvP opponent's collection score, in the same spot (solo games have rules there instead)
B.oppScoreText = B:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
B.oppScoreText:SetPoint("LEFT", B.oppLifeBtn, "RIGHT", 8, 0)
B.oppScoreText:SetJustifyH("LEFT")

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
        tip:AddLine(TTS.Engine.opponent or L("side.opponentCap"), 1, 0.82, 0)
        tip:AddLine(L("board.oppStats", TTS.Engine.remoteState.life,
            TTS.Engine.remoteState.handCount, TTS.Engine:RemoteDeckCount() or "?"), 1, 1, 1)
        if TTS.Engine.opponentScore then
            tip:AddLine(L("board.score", TTS:ColoredScore(TTS.Engine.opponentScore)), 1, 1, 1)
        end
        local enc = TTS.Engine.isSolo and TTS.Engine.encounter
        if enc and TTS.GetEncounterRuleLines then
            for _, rule in ipairs(TTS:GetEncounterRuleLines(enc)) do
                tip:AddLine(" ")
                tip:AddLine(rule.name, 1, 0.5, 0.25)
                tip:AddLine(rule.text, 1, 1, 1, true)
            end
        end
        if IsTargetingPlayer(true) then
            tip:AddLine(" ")
            tip:AddLine("|cFF00FF00" .. L("board.targetThisPlayer") .. "|r", 0.2, 1.0, 0.2)
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
        tip:AddLine(L("board.you"), 1, 0.82, 0)
        tip:AddLine(L("board.life", TTS.Engine.localState.life), 1, 1, 1)
        if TTS.GetCollectionScore then
            tip:AddLine(L("board.score", TTS:ColoredScore((TTS:GetCollectionScore()))), 1, 1, 1)
        end
        if IsTargetingPlayer(false) then
            tip:AddLine(" ")
            tip:AddLine("|cFF00FF00" .. L("board.targetYourself") .. "|r", 0.2, 1.0, 0.2)
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
Loc:Bind(B.manaText, "board.mana")

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
    Loc:Bind(bar.label, labelText)

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

B.oppEffectBar = CreateEffectBar("board.oppEffects")
B.oppEffectBar:SetPoint("TOPRIGHT", B, "TOPRIGHT", -20, -44)

B.myEffectBar = CreateEffectBar("board.myEffects")
B.myEffectBar:SetPoint("BOTTOMRIGHT", B, "BOTTOMRIGHT", -20, 174)

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
    return TTS.FormatStats(power, toughness, damage, colorCode)
end

-- A hand card's model loads again when hovering zooms it in or out, so it draws at its new size
-- (models otherwise only reload when their card changes, SetupCardVisual)
local function ReloadHandModel(f)
    if f.currentCard and f.model and f.model:IsShown() and TTS.SetupCardVisual then
        f.visualCard = nil
        TTS.SetupCardVisual(f, f.currentCard)
    end
end

local function Card_OnEnter(self)
    if not self.cardId then return end
    if self.isHand then
        self.hovered = true
        self:SetScale((self.baseScale or 1) * 1.18)
        self:SetFrameLevel((self.origFrameLevel or 10) + 15)
        ReloadHandModel(self)
    end

    local card = TTS.Cards[self.cardId]
    if not card then return end
    if ShowBoardPreview then ShowBoardPreview(self, card) end

    local ctx = {}
    if self.fieldIndex then
        ctx.perm = (self.isRemote and TTS.Engine.remoteState.field or TTS.Engine.localState.field)[self.fieldIndex]
        ctx.isRemote = self.isRemote
        ctx.fieldIndex = self.fieldIndex
        if card.colors and not self.isRemote then
            ctx.hint = L(card.makesBoth and "hint.doublePrayer" or "hint.dualPrayer",
                TT:Def("symbol", card.colors[1], "name"), TT:Def("symbol", card.colors[2], "name"))
        end
    end
    TT:ShowCard(self, "ANCHOR_TOP", self.cardId, ctx)
end

local function Card_OnLeave(self)
    if self.isHand then
        self.hovered = nil
        self:SetScale(self.baseScale or 1)
        if self.origFrameLevel then self:SetFrameLevel(self.origFrameLevel) end
        ReloadHandModel(self)
    end
    TT:Hide(self)
    if HideBoardPreview then HideBoardPreview() end
end

-- Dual-colour frames: Textures\Cards\card_frame_<sphere>_<sphere>.png, spheres in alphabetical order
local SPHERE_FILE = { W = "holy", U = "arcane", B = "shadow", R = "fire", G = "nature" }

local function DualFrameTexture(card)
    local spheres = {}
    if card.colors then
        for _, col in ipairs(card.colors) do table.insert(spheres, SPHERE_FILE[col]) end
    end
    for _, col in ipairs(card.colors and {} or { "W", "U", "B", "R", "G" }) do
        if card.cost and card.cost:find("{" .. col .. "}", 1, true) then table.insert(spheres, SPHERE_FILE[col]) end
    end
    if #spheres ~= 2 then return nil end
    table.sort(spheres)
    return TEXTURE_ROOT .. "Cards\\card_frame_" .. spheres[1] .. "_" .. spheres[2] .. ".png"
end

-- The card's single-colour frame (its colour, school, or the first colour in its cost)
local function SingleFrameTexture(card)
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

-- Two colours in the cost: the dual frame for that pair; otherwise the single-colour frame
local function GetCardFrameTexture(card)
    return (card and DualFrameTexture(card)) or SingleFrameTexture(card)
end

local function ApplyFrameTexture(t, card)
    local tex = GetCardFrameTexture(card)
    t:SetTexture(tex)
    -- A missing dual frame falls back to the single-colour one, then the default
    if not t:GetTexture() and card then
        t:SetTexture(SingleFrameTexture(card))
    end
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

    -- DressUpModel (a PlayerModel that can try on items) so an opponent's hero card can
    -- wear the gear they sent (Hero.lua)
    local okModel, model = pcall(CreateFrame, "DressUpModel", nil, f)
    f.model = okModel and model or CreateFrame("PlayerModel", nil, f)
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
local HAND_LEFT, HAND_RIGHT, HAND_BOTTOM = 35, 1054, 52   -- right edge stops short of your deck
local HAND_MAX_SCALE = 1.2

local BF_CARD_W  = 64
local BF_CARD_H  = 84
local BF_STEP_X  = 86
local BF_START_X = 35
local BF_RIGHT   = 1045   -- right edge stops short of your effects bar
local LAND_MAX_SCALE     = 1.0
local CREATURE_MAX_SCALE = 1.2
local MAX_CREATURE_FRAMES = 16   -- cards each creature row can show; they shrink to fit (FitScale)

-- Vertical centre of each battlefield row, measured up from the board's bottom edge
local ROW_Y = {
    myLand     = 256,
    myNonLand  = 380,
    oppNonLand = 513,
    oppLand    = 638,
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

-- A card whose size changed (its row gained or lost a card) loads its model again on the next
-- frame, and once more when any played card has landed: a model already showing keeps its
-- old size otherwise
local MODEL_RESIZE_DELAY = 0.35
local resizedFrames = {}
local function ReloadModels(list)
    for f in pairs(list) do
        if f:IsShown() and f.currentCard and f.model and f.model:IsShown() and TTS.SetupCardVisual then
            f.visualCard = nil
            TTS.SetupCardVisual(f, f.currentCard)
        end
    end
end

local function PlaceCard(f, i, s, left, centerY, cardW, step)
    if f.baseScale and f.baseScale ~= s and f.model then
        if not next(resizedFrames) then
            TTS:SafeAfter(0, function() ReloadModels(resizedFrames) end)
            TTS:SafeAfter(MODEL_RESIZE_DELAY, function()
                local list = resizedFrames
                resizedFrames = {}
                ReloadModels(list)
            end)
        end
        resizedFrames[f] = true
    end
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

    TTS.PlaceCardStats(f)
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
                f.rules:SetText(TTS:FormatSymbols(TTS:CardRulesText(card, true), size + 2 + RULES_TAP_EXTRA, size + 2 + RULES_TAP_EXTRA))
                if not (f.rules.IsTruncated and f.rules:IsTruncated()) then break end
            end
        end
        f.rules:Show()
    else
        f.rules:Hide()
    end
end

-- Battlefield panel behind both sides' rows, with a faint gold line between them
local battlefield = CreateFrame("Frame", nil, B, backdropTemplate)
battlefield:SetPoint("BOTTOMLEFT", B, "BOTTOMLEFT", 24, 209)
battlefield:SetSize(1028, 496)
Skin(battlefield, "panel", STYLE.panelBg, STYLE.panelBorder)

local midLine = battlefield:CreateTexture(nil, "ARTWORK")
midLine:SetPoint("LEFT", battlefield, "BOTTOMLEFT", 8, 456 - 209)
midLine:SetPoint("RIGHT", battlefield, "BOTTOMRIGHT", -8, 456 - 209)
midLine:SetHeight(1)
midLine:SetColorTexture(1, 0.82, 0, 0.25)

-- =========================================================================
-- SOLO BACKGROUNDS
-- A themed image behind the battlefield in solo encounters, inset 4 px inside the panel's
-- border and under the cards and the gold line, with a black overlay so cards stay readable.
--   { map = "Elwynn" }   the client's world map: 12 tiles of 256 px (4 x 3) holding one
--                        1002 x 668 map, scaled to the panel's width and cropped top and bottom
--   { loadscreen = "LoadScreenDeadmines", wide = nil, map = "Westfall", tint = { r, g, b } }
--                        the client's loading screen (4:3, or 16:9 when wide), cropped top and
--                        bottom; else the map, tinted
-- Every texture is checked after it is set; anything missing leaves the plain board.
-- =========================================================================
local BG_INSET = 4
local BG_W, BG_H = 1028 - BG_INSET * 2, 496 - BG_INSET * 2
local MAP_W, MAP_H, MAP_TILE = 1002, 668, 256
local LOADSCREEN_PATH = "Interface\\Glues\\LoadingScreens\\"
local BG_OVERLAY_ALPHA = 0.55
local PANEL_BG_DIMMED = 0.25

local bgTiles = {}
local overlayPool = {}   -- explored-area overlay textures, created as needed
for i = 1, 12 do
    local t = battlefield:CreateTexture(nil, "BACKGROUND", nil, 0)
    t:Hide()
    bgTiles[i] = t
end
local bgArt = battlefield:CreateTexture(nil, "BACKGROUND", nil, 1)
bgArt:SetPoint("TOPLEFT", battlefield, "TOPLEFT", BG_INSET, -BG_INSET)
bgArt:SetSize(BG_W, BG_H)
bgArt:Hide()
local bgOverlay = battlefield:CreateTexture(nil, "BACKGROUND", nil, 2)
bgOverlay:SetPoint("TOPLEFT", battlefield, "TOPLEFT", BG_INSET, -BG_INSET)
bgOverlay:SetSize(BG_W, BG_H)
bgOverlay:SetColorTexture(0, 0, 0, BG_OVERLAY_ALPHA)
bgOverlay:Hide()

local function HideBackground()
    for _, t in ipairs(bgTiles) do t:Hide() end
    bgArt:Hide()
    bgOverlay:Hide()
    for _, t in ipairs(overlayPool) do t:Hide() end
    battlefield:SetBackdropColor(STYLE.panelBg[1], STYLE.panelBg[2], STYLE.panelBg[3], STYLE.panelBg[4])
end

-- A loading screen, cropped top and bottom to the panel's shape. Classic ones are stored
-- square but drawn at 4:3. Returns false if the file is missing.
local function ShowLoadScreen(file, wide)
    local loaded = bgArt:SetTexture(LOADSCREEN_PATH .. file)
    if loaded == false or not bgArt:GetTexture() then return false end
    local scaledH = BG_W / (wide and 16 / 9 or 4 / 3)
    local crop = math.max(0, (scaledH - BG_H) / 2) / scaledH
    bgArt:SetTexCoord(0, 1, crop, 1 - crop)
    bgArt:SetVertexColor(1, 1, 1)
    bgArt:Show()
    return true
end

-- Explored-area overlays (UI\MapOverlays.lua) drawn above the base tiles, from the pool
local function OverlayTexture(i)
    if not overlayPool[i] then
        overlayPool[i] = battlefield:CreateTexture(nil, "BACKGROUND", nil, 1)
    end
    return overlayPool[i]
end

-- Places one piece of the map: it covers map pixels px0..px0+pw, py0..py0+ph and its texture
-- file is fw x fh pixels. Only the part inside the visible window is drawn.
-- Returns false if none of it is visible.
local function PlaceMapPiece(t, px0, py0, pw, ph, fw, fh, s, winTop, winBottom, tint)
    local ix0, ix1 = math.max(px0, 0), math.min(px0 + pw, MAP_W)
    local iy0, iy1 = math.max(py0, winTop), math.min(py0 + ph, winBottom, MAP_H)
    if ix1 <= ix0 or iy1 <= iy0 then
        t:Hide()
        return false
    end
    t:ClearAllPoints()
    t:SetPoint("TOPLEFT", battlefield, "TOPLEFT", BG_INSET + ix0 * s, -(BG_INSET + (iy0 - winTop) * s))
    t:SetSize((ix1 - ix0) * s, (iy1 - iy0) * s)
    t:SetTexCoord((ix0 - px0) / fw, (ix1 - px0) / fw, (iy0 - py0) / fh, (iy1 - py0) / fh)
    if tint then t:SetVertexColor(tint[1], tint[2], tint[3]) else t:SetVertexColor(1, 1, 1) end
    t:Show()
    return true
end

-- Smallest power of two holding n pixels (overlay edge tiles are stored that way)
local function TextureFileSize(n)
    local size = 16
    while size < n do size = size * 2 end
    return size
end

-- A world map, tile by tile, with every explored-area overlay on top so the whole zone
-- shows whether or not this character has explored it.
local function ShowMap(map, tint)
    local s = BG_W / MAP_W
    local winTop = ((MAP_H * s - BG_H) / 2) / s     -- map rows above the visible window
    local winBottom = winTop + BG_H / s
    local shown = 0
    for row = 0, 2 do
        for col = 0, 3 do
            local i = row * 4 + col + 1
            local t = bgTiles[i]
            local loaded = t:SetTexture(string.format("Interface\\WorldMap\\%s\\%s%d", map, map, i))
            if loaded == false or not t:GetTexture() then
                for _, other in ipairs(bgTiles) do other:Hide() end
                return false
            end
            if PlaceMapPiece(t, col * MAP_TILE, row * MAP_TILE, MAP_TILE, MAP_TILE, MAP_TILE, MAP_TILE, s, winTop, winBottom, tint) then
                shown = shown + 1
            end
        end
    end

    local used = 0
    for _, o in ipairs((TTS.MapOverlays and TTS.MapOverlays[map]) or {}) do
        local ox, oy, w, h, files = o[1], o[2], o[3], o[4], o[5]
        local across = math.ceil(w / MAP_TILE)
        local down = math.ceil(h / MAP_TILE)
        for r = 0, down - 1 do
            for c = 0, across - 1 do
                local name = files[r * across + c + 1]
                if name then
                    local pw = (c < across - 1) and MAP_TILE or (w - c * MAP_TILE)
                    local ph = (r < down - 1) and MAP_TILE or (h - r * MAP_TILE)
                    local t = OverlayTexture(used + 1)
                    -- A file this client doesn't have is skipped rather than drawn
                    local loaded = t:SetTexture(string.format("Interface\\WorldMap\\%s\\%s", map, name))
                    if loaded ~= false and t:GetTexture() and PlaceMapPiece(t, ox + c * MAP_TILE, oy + r * MAP_TILE, pw, ph,
                            TextureFileSize(pw), TextureFileSize(ph), s, winTop, winBottom, tint) then
                        used = used + 1
                    end
                end
            end
        end
    end
    for i = used + 1, #overlayPool do overlayPool[i]:Hide() end
    return shown > 0
end

-- spec: an encounter's background table (nil = plain board)
function B:SetBackground(spec)
    self.backgroundSpec = spec
    HideBackground()
    if not spec then return end
    if TTS.Options and TTS.Options:Get("boardBackgrounds") == false then return end
    local ok = (spec.loadscreen and ShowLoadScreen(spec.loadscreen, spec.wide)) or (spec.map and ShowMap(spec.map, spec.tint))
    if not ok then
        HideBackground()
        return
    end
    bgOverlay:Show()
    battlefield:SetBackdropColor(STYLE.panelBg[1], STYLE.panelBg[2], STYLE.panelBg[3], PANEL_BG_DIMMED)
end

function B:ClearBackground()
    self:SetBackground(nil)
end

-- Re-applies the current background (the option was toggled)
function B:RefreshBackground()
    self:SetBackground(self.backgroundSpec)
end

-- =========================================================================
-- BOARD LAYOUT GRIDS
-- =========================================================================
for i = 1, 10 do
    local f = CreateCardFrame(B, HAND_W, HAND_H)
    f.isHand = true
    f.handIndex = i
    f.origFrameLevel = f:GetFrameLevel()
    AttachSlot(f)
    f:SetScript("OnClick", function(self, btn)
        if not TTS.Engine.inMatch then return end
        if self.dragEnded == GetTime() then return end   -- the mouse-up that ended a drag
        if TTS:TryLinkCard(self.cardId) then return end
        PlayUISound("card")
        if btn == "RightButton" and TTS.Engine.targeting then
            TTS.Engine:CancelTargeting()
            return
        end
        -- Drag mode plays cards by dragging; a click still discards when asked to
        if TTS.CardControls() == "drag" and not TTS.Engine.pendingDiscard then
            if TTS.FloatText then TTS.FloatText(L("board.dragToPlay"), TTS.FLOAT_WARN) end
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
        if IsTargetingPlayer(true) then
            TT:ShowText(self, "ANCHOR_TOP", TTS.Engine.opponent or L("side.opponentCap"), nil,
                { r = 1, g = 0.82, b = 0, lines = { { "|cFF00FF00" .. L("board.targetEnemy") .. "|r", 0.2, 1.0, 0.2 } } })
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
    -- An untapped dual prayer asks which colour to make (TapCard re-checks it can still tap)
    local idx = self.fieldIndex
    local perm = idx and TTS.Engine.localState.field[idx]
    local card = perm and TTS.Cards[perm.id]
    if card and card.colors and not card.makesBoth and not perm.tapped and TTS.Engine.isMyTurn and TTS.Choice then
        TTS.Choice:ChooseMana(card.colors, self, function(col)
            if TTS.Engine.localState.field[idx] == perm then TTS.Engine:TapCard(idx, col) end
        end)
        return
    end
    if idx then TTS.Engine:TapCard(idx) end
end

local function MyNonLand_OnClick(self, btn)
    if btn == "RightButton" then
        if TTS.Engine.targeting then TTS.Engine:CancelTargeting(); return end
        local bs = TTS.Engine.blockingState
        if bs and bs.selectedBlocker then
            local idx = bs.selectedBlocker
            bs.selectedBlocker = nil
            if bs.blocks[idx] then
                TTS.Engine:ClearBlocks(bs, idx)
                local perm = TTS.Engine.localState.field[idx]
                local card = perm and TTS.Cards[perm.id]
                TTS.Engine:Log(L("log.unblocked", card and TTS:CardName(card) or L("type.Creature")), "COMBAT")
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
    -- Drag mode attacks and blocks by dragging
    local E = TTS.Engine
    if TTS.CardControls() == "drag" and TTS.FloatText then
        local bs = E.blockingState
        if E.phase == "COMBAT_BLOCK" and bs and bs.isRemoteAttacking and not bs.blocksDeclared then
            TTS.FloatText(L("board.dragToBlock"), TTS.FLOAT_WARN)
            return
        elseif E.phase == "COMBAT_ATTACK" and E.isMyTurn then
            TTS.FloatText(L("board.dragToAttack"), TTS.FLOAT_WARN)
            return
        end
    end
    if self.fieldIndex then TTS.Engine:TapCard(self.fieldIndex) end
end

-- Wraps a click handler for your own permanents with the click / tap sound
local function WithFieldSound(handler)
    return function(self, btn)
        if not TTS.Engine.inMatch then return end
        if self.dragEnded == GetTime() then return end   -- the mouse-up that ended a drag
        local perm = self.fieldIndex and TTS.Engine.localState.field[self.fieldIndex]
        local wasTapped = perm and perm.tapped
        if TTS:TryLinkCard(self.cardId) then return end
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

for i = 1, MAX_CREATURE_FRAMES do
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
        if TTS:TryLinkCard(self.cardId) then return end
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

for i = 1, MAX_CREATURE_FRAMES do
    local f = CreateCardFrame(B, BF_CARD_W, BF_CARD_H)
    f.isRemote = true
    AttachSlot(f)
    f:SetScript("OnClick", function(self, btn)
        if not TTS.Engine.inMatch then return end
        if TTS:TryLinkCard(self.cardId) then return end
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
myDeckFrame:SetSize(HAND_W, HAND_H)
myDeckFrame:SetPoint("BOTTOMRIGHT", -30, 52)
myDeckFrame.back = myDeckFrame:CreateTexture(nil, "ARTWORK")
myDeckFrame.back:SetAllPoints(myDeckFrame)
ApplyBackTexture(myDeckFrame.back)
myDeckFrame.count = myDeckFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
myDeckFrame.count:SetPoint("BOTTOM", myDeckFrame, "TOP", 0, 2)

-- Opponent's deck: top-right, at the end of their hand row, with the cards left beside it
local oppDeckFrame = CreateFrame("Frame", nil, B)
oppDeckFrame:SetSize(52, 68)
oppDeckFrame:SetPoint("TOPRIGHT", B, "TOPRIGHT", -108, -46)
oppDeckFrame.back = oppDeckFrame:CreateTexture(nil, "ARTWORK")
oppDeckFrame.back:SetAllPoints(oppDeckFrame)
ApplyBackTexture(oppDeckFrame.back)
oppDeckFrame.count = oppDeckFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
oppDeckFrame.count:SetPoint("RIGHT", oppDeckFrame, "LEFT", -6, 0)

local function ShowDeckTip(self, title, count)
    TT:ShowText(self, "ANCHOR_LEFT", title, nil, { r = 1, g = 0.82, b = 0,
        lines = { count and L("board.cardsLeft", count) or L("board.cardsLeftUnknown") } })
end
myDeckFrame:EnableMouse(true)
myDeckFrame:SetScript("OnEnter", function(self) ShowDeckTip(self, L("board.yourDeck"), #TTS.Engine.localState.deck) end)
myDeckFrame:SetScript("OnLeave", function(self) TT:Hide(self) end)
oppDeckFrame:EnableMouse(true)
oppDeckFrame:SetScript("OnEnter", function(self)
    ShowDeckTip(self, L("board.oppDeck", TTS.Engine.opponent or L("side.opponentCap")), TTS.Engine:RemoteDeckCount())
end)
oppDeckFrame:SetScript("OnLeave", function(self) TT:Hide(self) end)

-- =========================================================================
-- 3D MODEL VISUAL HELPER
-- =========================================================================
-- The card's camera (zoom, distance, position, facing) on its model. The client loads a
-- model a moment after SetDisplayInfo, and a camera set before that can be lost, so it is
-- also re-applied shortly after a creature comes onto the battlefield (ReapplyModelCameras).
local function ApplyModelCamera(f, card)
    local cam = card.modelCam or {}
    if f.model.SetPortraitZoom then f.model:SetPortraitZoom(cam.zoom or 0.75) end
    if f.model.SetCamDistanceScale then f.model:SetCamDistanceScale(cam.camScale or 1.0) end

    local baseZ = cam.z or -0.10
    local currentScale = B:GetScale() or 1.0
    local zComp = (currentScale - 1.0) * 0.18
    local adjZ = baseZ + zComp

    if f.model.SetPosition then f.model:SetPosition(cam.x or 0, cam.y or 0, adjZ) end
    if f.model.SetRotation then f.model:SetRotation(cam.rotation or 0.15) end
end

-- Card art colour: art keeps its own colours (dual prayers have their own coloured
-- rune art). shade (default 1) darkens it, e.g. for a tapped card.
local function TintArt(tex, card, shade)
    shade = shade or 1
    tex:SetVertexColor(shade, shade, shade)
end
TTS.TintArt = TintArt

-- Bumped to make every frame load its model again on its next refresh (board reopened,
-- opponent's hero now drawable live)
local modelGeneration = 0
function TTS.RedrawCardModels() modelGeneration = modelGeneration + 1 end

local function SetupCardVisual(f, card)
    -- The same card still showing on this frame keeps its model: reloading it on every
    -- refresh made models flicker (worst on dressed ones like hero cards and Leeroy)
    if card and f.visualCard == card and f.visualGen == modelGeneration and f:IsShown() then
        f.currentCard = card
        return
    end
    f.visualCard, f.visualGen = card, modelGeneration
    f.currentCard = card
    -- Cancels a hero model's pending dressing (Hero.lua) now the frame shows something new
    if f.model then f.model.heroDressToken = nil end
    local hero = card and card.isHero and f.model and TTS.Hero
    if hero then
        f.art:Hide()
        f.model:Show()
        f.model:ClearModel()
        hero = TTS.Hero:SetModel(f.model, card, function() ApplyModelCamera(f, card) end)
        if hero then ApplyModelCamera(f, card) end
    end
    if hero then
        -- the hero card (Hero.lua) shows the character itself
    elseif card and card.displayId and not card.isHero then
        f.art:Hide()
        -- A model that finishes loading (or is shown again) resets to the default camera, however
        -- long that takes: put the card's camera back each time (once per model frame)
        if not f.model.ttsCameraHooked then
            f.model.ttsCameraHooked = true
            local function Refit()
                local c = f.currentCard
                if c and c.displayId and not c.isHero then ApplyModelCamera(f, c) end
            end
            if f.model.HasScript and f.model:HasScript("OnModelLoaded") then f.model:HookScript("OnModelLoaded", Refit) end
            f.model:HookScript("OnShow", Refit)
        end
        f.model:Show()
        f.model:ClearModel()
        f.model:SetDisplayInfo(card.displayId)
        -- A card can dress its display in items (e.g. Leeroy Jenkins, Cards\Special.lua)
        if card.dressItems and TTS.Hero then
            TTS.Hero:DressModel(f.model, card.dressItems, function() ApplyModelCamera(f, card) end)
        end
        ApplyModelCamera(f, card)
    else
        if f.model then f.model:Hide() end
        f.art:Show()
        f.art:SetTexture((card and card.art) or "Interface\\Icons\\INV_Misc_QuestionMark")
        TintArt(f.art, card)
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

-- Full camera again on every battlefield model that is showing
local function ReapplyModelCameras()
    for _, group in ipairs({ myLandFrames, myNonLandFrames, oppLandFrames, oppNonLandFrames }) do
        for _, f in ipairs(group) do
            if f:IsShown() and f.currentCard and f.currentCard.displayId and f.model and f.model:IsShown() then
                ApplyModelCamera(f, f.currentCard)
            end
        end
    end
end

-- A creature just came onto the battlefield (either side): fix its camera once the model has
-- loaded, and again when its flight from the hand has landed
local MODEL_SETTLE_DELAY = 0.05
local MODEL_LANDED_DELAY = 0.8    -- well after a played card's 0.3 s flight (FLY_TIME), once the model has settled
local function ScheduleModelCameraFix()
    if B.cameraFixPending then return end
    B.cameraFixPending = true
    TTS:SafeAfter(MODEL_SETTLE_DELAY, function()
        B.cameraFixPending = nil
        ReapplyModelCameras()
    end)
    TTS:SafeAfter(MODEL_LANDED_DELAY, ReapplyModelCameras)
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

-- Paints a full-size preview card (a CreateCardFrame of PREVIEW_W x PREVIEW_H) and shows it
local function PaintPreviewCard(f, card)
    f.visualCard = nil   -- a preview always loads its model afresh (e.g. a card's model was changed)
    SetupCardVisual(f, card)
    ApplyFrameTexture(f.border, card)
    f.border:SetVertexColor(1, 1, 1)
    TintArt(f.art, card)
    f.title:SetText(TTS:CardName(card) or "")

    if card.cost and card.cost ~= "" then
        f.cost:SetText(TTS:FormatSymbols(card.cost, 18))
        f.cost:Show()
    else
        f.cost:Hide()
    end

    TTS.ShowPrintedStats(f, card)

    f:Show()
    UpdateCardRules(f, PREVIEW_RULES)
end

ShowBoardPreview = function(owner, card)
    local f = EnsureBoardPreview()
    previewOwner = owner

    -- Card name and cost sit above the frame, so leave room for them
    f:ClearAllPoints()
    f:SetPoint("TOPRIGHT", B, "TOPLEFT", -12, -76)
    PaintPreviewCard(f, card)
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
-- =========================================================================
-- LEAVING CREATURES
-- A creature that leaves the battlefield stays in its slot for a moment before the row
-- closes up: red with a skull when it died, blue when it went to a hand or library.
-- =========================================================================
local LEAVE_TIME = 1.0
local LEAVE_COLORS = { died = { 1.0, 0.2, 0.2 }, returned = { 0.3, 0.55, 1.0 } }
local LEAVE_SKULL = "Interface\\AddOns\\ForeverCCG\\Textures\\Symbols\\Skull.png"

local leaving = { [false] = {}, [true] = {} }     -- side -> { { perm, kind, untilT, slot } }
local lastShown = { [false] = {}, [true] = {} }   -- side -> perms in the order they were drawn
local lastField = {}                               -- side -> the field table last drawn (new match = new table)
local leavingPerms = setmetatable({}, { __mode = "k" })
local diedPerms = setmetatable({}, { __mode = "k" })

-- How dark a creature is drawn: tapped 0.4, summoning-sick in your attack step this
local SICK_SHADE = 0.7
-- 3D models ignore vertex colour, so they fade instead (less, or they vanish into the card)
local function ModelAlpha(shade) return 0.25 + 0.75 * shade end

-- =========================================================================
-- PLAY ANIMATIONS
-- A card that comes onto the battlefield out of a hand flies to its slot from where
-- it was: the card in your hand (or where a drag dropped it), or the opponent's hand row.
-- Turned off with "Animate played cards" in the options.
-- =========================================================================
local FLY_TIME = 0.3

local flights = setmetatable({}, { __mode = "k" })   -- perm -> { x, y, t }: start, in board coordinates
local seenPerms = setmetatable({}, { __mode = "k" })
local oldHand, oldOppHandCount = {}, nil

-- A frame's centre in the board's coordinates (cards are scaled individually)
local function BoardXY(f)
    local cx, cy = f:GetCenter()
    local left, bottom = B:GetLeft(), B:GetBottom()
    if not (cx and left) then return end
    local r = f:GetEffectiveScale() / B:GetEffectiveScale()
    return cx * r - left, cy * r - bottom
end
B.BoardXY = BoardXY

-- Before a redraw: where each card in your hand is drawn
local function RememberHand()
    wipe(oldHand)
    for i = 1, 10 do
        local f = myHandFrames[i]
        if f:IsShown() and f.cardId then
            local x, y = BoardXY(f)
            if x then table.insert(oldHand, { id = f.cardId, x = x, y = y }) end
        end
    end
end

-- After a redraw: a flight for each permanent that just came out of a hand. Yours must
-- have left your hand since the last redraw (so an undo, which puts copies back, never
-- flies); the opponent's are counted off the cards that left their hand.
local function StartFlights(E)
    -- Where a drag dropped a card (kept until that card arrives: auto-pay redraws first)
    local launch = B.launchFrom
    local animate = not TTS.Options or TTS.Options:Get("animateCards") ~= false

    local before, now = {}, {}
    for _, h in ipairs(oldHand) do before[h.id] = (before[h.id] or 0) + 1 end
    for _, id in ipairs(E.localState.hand) do now[id] = (now[id] or 0) + 1 end
    local oppSlot = math.min(10, oldOppHandCount or 0)
    local oppLeft = math.max(0, (oldOppHandCount or 0) - (E.remoteState.handCount or 0))

    for _, isRemote in ipairs({ false, true }) do
        for _, perm in ipairs(isRemote and E.remoteState.field or E.localState.field) do
            if not seenPerms[perm] then
                seenPerms[perm] = true
                local sx, sy
                if not isRemote and (before[perm.id] or 0) > (now[perm.id] or 0) then
                    before[perm.id] = before[perm.id] - 1
                    if launch and launch.cardId == perm.id then
                        sx, sy = launch.x, launch.y
                        launch, B.launchFrom = nil, nil
                    else
                        for k, h in ipairs(oldHand) do
                            if h.id == perm.id then
                                sx, sy = h.x, h.y
                                table.remove(oldHand, k)
                                break
                            end
                        end
                    end
                elseif isRemote and oppLeft > 0 and oppSlot > 0 then
                    -- The opponent's hand row: the last card back in it (layout as the oppHandFrames)
                    sx, sy = 35 + (oppSlot - 1) * 64 + 26, B:GetHeight() - 46 - 35
                    oppLeft, oppSlot = oppLeft - 1, oppSlot - 1
                end
                if sx and animate then flights[perm] = { x = sx, y = sy, t = 0 } end
                local card = TTS.Cards[perm.id]
                if card and card.displayId then ScheduleModelCameraFix() end
                -- Marked on the permanent itself, so an undo (which restores copies) doesn't replay it
                if card and card.isToken and not perm.spawnShown then
                    perm.spawnShown = true
                    B.StartSpawn(perm, animate)
                end
            end
        end
    end
    oldOppHandCount = E.remoteState.handCount or 0
end

-- =========================================================================
-- TOKEN SPAWNS
-- A token (Cards\Tokens.lua) is on the battlefield from the moment its effect resolves;
-- only its card waits a moment, then fades in with the token's sound (TTS.Sound:PlayTokenSound).
-- Each client draws this for every token on either side, so both PvP players see it.
-- Tokens made together come in one after another; one sound plays for the group.
-- =========================================================================
local SPAWN_DELAY = 0.45     -- seconds before the first token of a group shows
local SPAWN_STAGGER = 0.15   -- between tokens made together
local SPAWN_FADE = 0.35      -- fade-in
local spawns = setmetatable({}, { __mode = "k" })   -- perm -> { t = seconds since made, at = when it shows }
local groupUntil = 0          -- tokens made before this joins the current group
local groupNext = 0           -- when the next token in the group shows

function B.StartSpawn(perm, animate)
    if not animate then
        if TTS.Sound then TTS.Sound:PlayTokenSound(perm.id) end
        return
    end
    local now = GetTime()
    if now > groupUntil then groupNext = SPAWN_DELAY end
    groupUntil = now + 0.05
    spawns[perm] = { t = 0, at = groupNext, sound = (groupNext == SPAWN_DELAY), id = perm.id }
    groupNext = groupNext + SPAWN_STAGGER
end

-- Sets each spawning token's card alpha; cards no longer spawning are reset. Models ignore
-- their parent's alpha (as in MobTooltip.lua), so the model's own alpha fades with the card,
-- on top of its tapped / summoning-sick shade (f.modelAlpha, set by the redraw).
local function ApplySpawns()
    for _, group in ipairs({ myNonLandFrames, oppNonLandFrames }) do
        for _, f in ipairs(group) do
            local sp = f:IsShown() and f.perm and spawns[f.perm]
            if sp then
                local a = math.max(0, math.min(1, (sp.t - sp.at) / SPAWN_FADE))   -- 0 while still waiting
                f:SetAlpha(a)
                if f.model then f.model:SetAlpha((f.modelAlpha or 1) * a) end
                f.spawning = true
            elseif f.spawning then
                f.spawning = nil
                f:SetAlpha(1)
                if f.model then f.model:SetAlpha(f.modelAlpha or 1) end
            end
        end
    end
end
B.ApplySpawns = ApplySpawns

local spawnTicker = CreateFrame("Frame", nil, B)
spawnTicker:SetScript("OnUpdate", function(_, dt)
    if not next(spawns) then return end
    for perm, sp in pairs(spawns) do
        local before = sp.t
        sp.t = sp.t + dt
        if sp.sound and before < sp.at and sp.t >= sp.at and TTS.Sound then
            TTS.Sound:PlayTokenSound(sp.id)
        end
        if sp.t >= sp.at + SPAWN_FADE then spawns[perm] = nil end
    end
    ApplySpawns()
end)

-- Offsets each flying card from its slot by what is left of its flight
local function ApplyFlights()
    local left, bottom = B:GetLeft(), B:GetBottom()
    for _, group in ipairs({ myLandFrames, myNonLandFrames, oppLandFrames, oppNonLandFrames }) do
        for _, f in ipairs(group) do
            local fl = f:IsShown() and f.perm and flights[f.perm]
            local dx, dy = 0, 0
            local sx, sy = f.slot:GetCenter()   -- the slot is unscaled: already in board coordinates
            if fl and sx and left then
                local rest = (1 - math.min(1, fl.t / FLY_TIME)) ^ 3   -- ease out
                local s = f:GetScale()
                dx = (fl.x - (sx - left)) * rest / s
                dy = (fl.y - (sy - bottom)) * rest / s
            end
            if dx ~= (f.flyX or 0) or dy ~= (f.flyY or 0) then
                f.flyX, f.flyY = dx, dy
                f:ClearAllPoints()
                f:SetPoint("CENTER", f.slot, "CENTER", dx, dy)
            end
        end
    end
end

local flyTicker = CreateFrame("Frame", nil, B)
flyTicker:SetScript("OnUpdate", function(_, dt)
    if not next(flights) then return end
    for perm, fl in pairs(flights) do
        fl.t = fl.t + dt
        if fl.t >= FLY_TIME then flights[perm] = nil end
    end
    ApplyFlights()
end)

-- =========================================================================
-- DAMAGE & HEALING NUMBERS
-- Each redraw compares a creature's damage with the last one: more shows a red "-N",
-- less a green "+N" (TTS.FloatText, UI\TargetFX.lua). The end-of-turn reset and
-- regeneration are not healing. Players: life going up shows a green "+N" (damage to
-- players has its own number in TargetFX).
-- =========================================================================
local lastDamage = setmetatable({}, { __mode = "k" })
local lastLife = {}
local pendingFloats = {}

local function SilenceDamage(perm)
    lastDamage[perm] = perm.damage or 0
end

local function TrackDamage(perm, isRemote, f)
    local dmg = perm.damage or 0
    local prev = lastDamage[perm]
    lastDamage[perm] = dmg
    if not prev or dmg == prev then return end
    if dmg > prev then
        -- Deathtouch marks 999: show no more than the creature could take
        local _, t = TTS.Engine:GetCreatureStats(perm, isRemote)
        local shown = math.min(dmg - prev, math.max(1, t - prev))
        table.insert(pendingFloats, { f, "-" .. shown, "FLOAT_DAMAGE" })
    else
        table.insert(pendingFloats, { f, "+" .. (prev - dmg), "FLOAT_HEAL" })
    end
end

local function EmitFloats()
    if TTS.FloatText then
        for _, p in ipairs(pendingFloats) do TTS.FloatText(p[2], TTS[p[3]], p[1]) end
    end
    wipe(pendingFloats)
end

local function TrackLife(E, isRemote, plate)
    local life = (isRemote and E.remoteState or E.localState).life
    local prev = lastLife[isRemote]
    lastLife[isRemote] = life
    if prev and life > prev and TTS.FloatText then
        TTS.FloatText("+" .. (life - prev), TTS.FLOAT_HEAL, plate, true)
    end
end

-- Deaths go through HandleCreatureDeath; any other creature that disappears was returned.
-- Damage wiped at the end of a turn or by regeneration is not shown as healing.
do
    local E = TTS.Engine
    local origDeath = E and E.HandleCreatureDeath
    if origDeath then
        E.HandleCreatureDeath = function(self, perm, ...)
            if perm then diedPerms[perm] = true end
            return origDeath(self, perm, ...)
        end
    end
    local origClear = E and E.ClearCreatureDamage
    if origClear then
        E.ClearCreatureDamage = function(self, ...)
            local results = { origClear(self, ...) }
            for _, field in ipairs({ self.localState.field, self.remoteState.field }) do
                for _, p in ipairs(field) do SilenceDamage(p) end
            end
            return unpack(results)
        end
    end
    local origSBA = E and E.CheckStateBasedActions
    if origSBA then
        E.CheckStateBasedActions = function(self, ...)
            -- Note which creatures had a regeneration shield; one used up wiped its damage
            local shielded = {}
            for _, field in ipairs({ self.localState.field, self.remoteState.field }) do
                for _, p in ipairs(field) do if p.regenerateShield then shielded[p] = true end end
            end
            local results = { origSBA(self, ...) }
            for p in pairs(shielded) do
                if not p.regenerateShield then SilenceDamage(p) end
            end
            return unpack(results)
        end
    end
end

-- The order to draw one side's battlefield: the field, with leaving creatures kept in
-- the slots they had. Entries: { perm, index } or { perm, leaving = "died"|"returned" }.
local function BattlefieldList(E, isRemote)
    local field = isRemote and E.remoteState.field or E.localState.field
    if lastField[isRemote] ~= field then
        lastField[isRemote] = field
        lastShown[isRemote] = {}
        leaving[isRemote] = {}
        lastLife[isRemote] = nil
    end

    local present = {}
    for _, p in ipairs(E.localState.field) do present[p] = true end
    for _, p in ipairs(E.remoteState.field) do present[p] = true end
    local now = GetTime()

    for slot, p in ipairs(lastShown[isRemote]) do
        local card = TTS.Cards[p.id]
        if not present[p] and not leavingPerms[p] and card and card.type == "Creature" then
            leavingPerms[p] = true
            table.insert(leaving[isRemote], { perm = p, kind = diedPerms[p] and "died" or "returned", untilT = now + LEAVE_TIME, slot = slot })
            TTS:SafeAfter(LEAVE_TIME + 0.05, function() E:RefreshUI() end)
        end
    end
    local list = leaving[isRemote]
    for i = #list, 1, -1 do
        if list[i].untilT <= now then table.remove(list, i) end
    end
    table.sort(list, function(a, b) return a.slot < b.slot end)

    local out = {}
    for i, p in ipairs(field) do out[#out + 1] = { perm = p, index = i } end
    for _, l in ipairs(list) do
        table.insert(out, math.min(l.slot, #out + 1), { perm = l.perm, leaving = l.kind })
    end
    local shown = {}
    for k, entry in ipairs(out) do shown[k] = entry.perm end
    lastShown[isRemote] = shown
    return out
end

-- Paints (or clears) the leaving look on a battlefield card frame
local function PaintLeaving(f, kind)
    if not f.leaveTint then
        -- On the card's top layer (with the tap icon), so the skull covers the
        -- model, frame and printed text instead of sitting under them
        local layer = f.tapLayer or f
        f.leaveTint = layer:CreateTexture(nil, "OVERLAY", nil, 5)
        f.leaveTint:SetAllPoints(f)
        f.leaveSkull = layer:CreateTexture(nil, "OVERLAY", nil, 6)
        f.leaveSkull:SetTexture(LEAVE_SKULL)
        f.leaveSkull:SetPoint("CENTER", f, "CENTER", 0, 0)
    end
    if not kind then
        f.leaveTint:Hide()
        f.leaveSkull:Hide()
        return
    end
    local c = LEAVE_COLORS[kind]
    f.leaveTint:SetColorTexture(c[1], c[2], c[3], 0.45)
    f.leaveTint:Show()
    f.border:SetVertexColor(c[1], c[2], c[3])
    f.art:SetVertexColor(c[1], c[2], c[3])
    local w = f:GetWidth() or 64
    f.leaveSkull:SetSize(w * 0.7, w * 0.7)
    f.leaveSkull:SetShown(kind == "died")
    if kind == "died" and f.tapIcon then f.tapIcon:Hide() end
end

function B:UpdateDisplay()
    local E = TTS.Engine
    if not E.inMatch then return end
    RememberHand()
    concedeBtn:Enable()

    B.oppLifeText:SetText(L("board.oppLife", E.opponent or L("side.opponentCap"), E.remoteState.life, E.remoteState.handCount))
    local ruleNames = {}
    if E.isSolo and E.encounter and TTS.GetEncounterRuleLines then
        for _, rule in ipairs(TTS:GetEncounterRuleLines(E.encounter)) do table.insert(ruleNames, rule.name) end
    end
    B.oppRulesText:SetText(#ruleNames > 0 and L("board.rules", table.concat(ruleNames, ", ")) or "")
    if not E.isSolo and E.opponentScore then
        B.oppScoreText:SetText(L("main.score", TTS:ColoredScore(E.opponentScore)))
    else
        B.oppScoreText:SetText("")
    end
    B.myLifeText:SetText(L("board.life", E.localState.life))

    UpdateEffectBar(B.oppEffectBar, E:GetPlayerEffects(true))
    UpdateEffectBar(B.myEffectBar, E:GetPlayerEffects(false))

    local m = E.localState.mana
    for _, key in ipairs(MANA_ORDER) do
        local slot = B.manaSlots[key]
        slot.text:SetText(string.format("%s |cFFFFFFFF%d|r", TTS:FormatSymbols("{" .. key .. "}", 22), m[key] or 0))
        slot:SetWidth(math.max(1, slot.text:GetStringWidth()))
    end

    -- Only the players the targeting can choose light up
    local isTargetingPlayer = IsTargetingPlayer(true)
    for plate, lit in pairs({ [B.oppLifeBtn] = isTargetingPlayer, [B.myLifeBtn] = IsTargetingPlayer(false) }) do
        if lit then
            plate:SetBackdropBorderColor(0.2, 1.0, 0.2, 1.0)
            plate:SetBackdropColor(0.1, 0.35, 0.1, 0.8)
        else
            local bg, bd = STYLE.controlBg, STYLE.controlBorder
            plate:SetBackdropBorderColor(bd[1], bd[2], bd[3], bd[4])
            plate:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
        end
    end

    -- =====================================================================
    -- PHASE & COMBAT BUTTON STATE
    -- =====================================================================
    -- While our attack waits on blocks or on Resolve, End Turn becomes "End Turn After
    -- Combat" (a toggle, see E:ToggleEndAfterCombat); otherwise it's the normal button
    local attackingCombat = E.phase == "COMBAT_BLOCK" and E.blockingState and not E.blockingState.isRemoteAttacking
    if attackingCombat then
        B.endTurnBtn:SetText(L(E.endAfterCombat and "board.btn.endingAfterCombat" or "board.btn.endAfterCombat"))
        B.endTurnBtn:SetWidth(math.max(90, B.endTurnBtn:GetTextWidth() + 24))
    elseif B.endTurnBtn:GetWidth() ~= 90 then
        B.endTurnBtn:SetText(L("board.endTurn"))
        B.endTurnBtn:SetWidth(90)
    end

    if E.phase == "COMBAT_BLOCK" and E.blockingState then
        B.endTurnBtn:Disable()
        if attackingCombat then B.endTurnBtn:Enable() end
        if E.blockingState.isRemoteAttacking then
            if E.blockingState.blocksDeclared then
                -- Local player is defending and has declared: the attacker resolves
                B.nextPhaseBtn:SetText(L("board.btn.waitAttacker"))
                B.nextPhaseBtn:Disable()
            elseif not E.isSolo and not E.blockingState.attacksDone then
                -- More attackers may still be coming (Network.lua, ATTACKS_DONE)
                B.nextPhaseBtn:SetText(L("board.btn.attackersIncoming"))
                B.nextPhaseBtn:Disable()
            else
                -- Local player is defending: enabled to confirm blocks
                B.nextPhaseBtn:Enable()
                local numBlocks = #E:BlockPairs(E.blockingState)
                if numBlocks > 0 then
                    B.nextPhaseBtn:SetText(L("board.btn.confirmBlocks"))
                else
                    B.nextPhaseBtn:SetText(L("board.btn.noBlocks"))
                end
            end
        elseif E.blockingState.blocksDeclared then
            -- Local player is attacking and blocks are in: review them, then resolve
            B.nextPhaseBtn:SetText(L("board.btn.resolveCombat"))
            B.nextPhaseBtn:Enable()
        else
            -- Local player is attacking: waiting for the defender to declare blocks
            B.nextPhaseBtn:SetText(L("board.btn.waitDefender"))
            B.nextPhaseBtn:Disable()
        end
    elseif E.pendingDiscard then
        B.nextPhaseBtn:SetText(L("board.btn.discard"))
        B.nextPhaseBtn:Disable()
        B.endTurnBtn:Disable()
    elseif E.phase == "COMBAT_ATTACK" then
        B.nextPhaseBtn:Enable()
        -- Until an attacker is declared the turn can still end (or skip on to Main 2)
        local hasAttackers = E.blockingState and #E.blockingState.attackers > 0
        if hasAttackers then
            B.nextPhaseBtn:SetText(L("board.btn.declareBlocks"))
            B.endTurnBtn:Disable()
        else
            B.nextPhaseBtn:SetText(L("board.btn.toMain2"))
            B.endTurnBtn:Enable()
        end
    elseif not E.isMyTurn or E.phase == "WAITING" or E.phase == E.AI_TURN_PHASE or E.phase == "PREGAME" then
        B.nextPhaseBtn:SetText(L("board.btn.opponentTurn"))
        B.nextPhaseBtn:Disable()
        B.endTurnBtn:Disable()
    else
        B.nextPhaseBtn:Enable()
        B.endTurnBtn:Enable()
        if E.phase == "MAIN1" then
            B.nextPhaseBtn:SetText(L("board.toCombat"))
        elseif E.phase == "MAIN2" then
            B.nextPhaseBtn:SetText(L("board.endTurn"))
        else
            B.nextPhaseBtn:SetText(L("board.btn.nextPhase"))
        end
    end

    if E:CanUndo() then B.undoBtn:Enable() else B.undoBtn:Disable() end
    B.undoBtn:SetText((E.undo and E.undo.pending) and L("board.asking") or L("board.undo"))
    B.mulliganBtn:SetShown(E.mulliganOpen and true or false)
    if E:CanMulligan() then B.mulliganBtn:Enable() else B.mulliganBtn:Disable() end

    -- =====================================================================
    -- TOP PHASE TEXT
    -- =====================================================================
    if E.pendingDiscard then
        B.phaseText:SetText("|cFFFFCC00" .. L("phase.discard") .. "|r")
    elseif E.targeting then
        B.phaseText:SetText("|cFFFFD200" .. L("phase.targetingFor", Loc:Data("targetType." .. tostring(E.targeting.targetType), E.targeting.targetType), E.targeting.cardName) .. "|r")
    elseif E.phase == "COMBAT_BLOCK" and E.blockingState then
        if E.blockingState.isRemoteAttacking then
            if E.blockingState.blocksDeclared then
                B.phaseText:SetText("|cFFFFD200" .. L("phase.blocksDeclaredWait") .. "|r")
            elseif not E.isSolo and not E.blockingState.attacksDone then
                B.phaseText:SetText("|cFFFFD200" .. L("phase.oppAttacking") .. "|r")
            else
                B.phaseText:SetText("|cFFFF4444" .. L("phase.assignBlockers") .. "|r")
            end
        elseif E.blockingState.blocksDeclared then
            B.phaseText:SetText("|cFFFF4444" .. L("phase.reviewBlocks") .. "|r")
        else
            B.phaseText:SetText("|cFFFFD200" .. L("phase.oppBlocking") .. "|r")
        end
    else
        B.phaseText:SetText(L("phase.label", E:PhaseName(E.phase)))
    end

    myDeckFrame.count:SetText(#E.localState.deck)
    oppDeckFrame.count:SetText(E:RemoteDeckCount() or "?")

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
            f.title:SetText(TTS:CardName(card))

            if card.cost and card.cost ~= "" then
                f.cost:SetText(TTS:FormatSymbols(card.cost, 16))
                f.cost:Show()
            else
                f.cost:Hide()
            end

            TTS.ShowPrintedStats(f, card)

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
    for _, entry in ipairs(BattlefieldList(E, false)) do
        local perm, i, leavingKind = entry.perm, entry.index, entry.leaving
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
                f.perm = perm
                f.cardId = perm.id
                SetupCardVisual(f, card)
                ApplyFrameTexture(f.border, card)
                f.title:SetText(TTS:CardName(card))

                UpdateTuckedFrames(f, perm)

                if card.type == "Creature" then
                    local effP, effT = E:GetCreatureStats(perm, false)
                    local colorCode = (effP > card.power or effT > card.toughness) and "|cFF00FF00" or "|cFFFFD200"
                    TTS.SetCardStats(f, effP, effT, perm.damage, colorCode)
                else
                    TTS.HideCardStats(f)
                end

                local shade = perm.tapped and 0.4 or 1.0
                -- In your attack step, creatures with summoning sickness are dimmed a little
                if not perm.tapped and card.type == "Creature" and E.isMyTurn and E.phase == "COMBAT_ATTACK"
                    and perm.sick and not E:HasKeyword(perm, false, "haste") then
                    shade = SICK_SHADE
                end
                if IsTargetableCreature(perm, false) then
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
                TintArt(f.art, card, shade)
                f.modelAlpha = ModelAlpha(shade)   -- kept for the token fade-in (ApplySpawns)
                f.model:SetAlpha(f.modelAlpha)
                if perm.tapped then f.tapIcon:Show() else f.tapIcon:Hide() end
                PaintLeaving(f, leavingKind)
                f:Show()
                if card.type == "Creature" then TrackDamage(perm, false, f) end
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
    for _, entry in ipairs(BattlefieldList(E, true)) do
        local perm, i, leavingKind = entry.perm, entry.index, entry.leaving
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
                f.perm = perm
                f.cardId = perm.id
                SetupCardVisual(f, card)
                ApplyFrameTexture(f.border, card)
                f.title:SetText(TTS:CardName(card))

                UpdateTuckedFrames(f, perm)

                if card.type == "Creature" then
                    local effP, effT = E:GetCreatureStats(perm, true)
                    TTS.SetCardStats(f, effP, effT, perm.damage, "|cFFFFD200")
                else
                    TTS.HideCardStats(f)
                end

                local shade = perm.tapped and 0.4 or 1.0
                if IsTargetableCreature(perm, true) then
                    f.border:SetVertexColor(0.2, 1.0, 0.2)
                elseif perm.isAttacking then
                    f.border:SetVertexColor(1.0, 0.2, 0.2)
                else
                    f.border:SetVertexColor(shade, shade, shade)
                end
                TintArt(f.art, card, shade)
                f.modelAlpha = ModelAlpha(shade)   -- kept for the token fade-in (ApplySpawns)
                f.model:SetAlpha(f.modelAlpha)
                if perm.tapped then f.tapIcon:Show() else f.tapIcon:Hide() end
                PaintLeaving(f, leavingKind)
                f:Show()
                if card.type == "Creature" then TrackDamage(perm, true, f) end
            end
        end
    end

    LayoutRow(oppLandFrames, oppLandIdx, ROW_Y.oppLand, LAND_MAX_SCALE)
    LayoutRow(oppNonLandFrames, oppNonLandIdx, ROW_Y.oppNonLand, CREATURE_MAX_SCALE)

    -- Damage / healing numbers for this redraw (cards are in place now)
    EmitFloats()
    TrackLife(E, false, B.myLifeBtn)
    TrackLife(E, true, B.oppLifeBtn)

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

    StartFlights(E)
    ApplyFlights()
    B.ApplySpawns()
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
TTS.PaintPreviewCard    = PaintPreviewCard -- full-size preview card in the board's design
TTS.PREVIEW_W, TTS.PREVIEW_H = PREVIEW_W, PREVIEW_H
B.myHandFrames          = myHandFrames  -- read by TargetFX.lua (targeting arrow source)
-- Read by CardDrag.lua (drag sources and drop targets)
B.oppHandFrames         = oppHandFrames
B.myLandFrames          = myLandFrames
B.myNonLandFrames       = myNonLandFrames
B.oppLandFrames         = oppLandFrames
B.oppNonLandFrames      = oppNonLandFrames
B.HAND_W, B.HAND_H      = HAND_W, HAND_H
B.HAND_TOP              = HAND_BOTTOM + HAND_H * HAND_MAX_SCALE   -- top of the hand row, in board coordinates
B.MIDLINE               = (ROW_Y.myNonLand + ROW_Y.oppNonLand) / 2 -- between the two creature rows

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