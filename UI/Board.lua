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

-- Sizes and timings are grouped in tables (filled in where each is explained) to keep this
-- file well under Lua's 200-locals limit: LAYOUT (card and row geometry, board scale), RULES
-- (printed rules text), EFFECT_BAR (player effect icons), BG (solo backgrounds), TIMING
-- (animations and model reloads)
local LAYOUT, RULES, EFFECT_BAR, BG, TIMING = {}, {}, {}, {}, {}

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
    C       = TEXTURE_ROOT .. "Cards\\card_frame_neutral.png",   -- colourless (Gear Cards)
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
-- While a card effect plays (CardFX.lua) the card shows its full-art frame (<frame>_full.png,
-- faded in over FULL_ART_FADE seconds) and the art window grows down to that frame's window,
-- whose bottom edge is FULL_ART_BOTTOM of the card's height up from the bottom
local FULL_ART_BOTTOM = 0.045
local FULL_ART_FADE   = 0.15
local FX_MODEL_CAM_PULL = 0.8 -- and its camera, standing back for the grown window, comes this much closer

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
RULES.RULES_FONT_MAX = 8   -- tried first; shrinks toward MIN until the text fits
RULES.RULES_FONT_MIN = 6
-- Cards narrower than this on screen (pixels, board zoom included) show no
-- printed text: their rules are in the tooltip only
RULES.CARD_TEXT_MIN_WIDTH = 72
-- Symbols in printed rules text (tap and mana alike) are drawn this many pixels
-- larger than the text's base symbol size
RULES.RULES_TAP_EXTRA = 3

-- Large preview of the hovered card, docked outside the left edge of the board
LAYOUT.PREVIEW_W, LAYOUT.PREVIEW_H = 150, 212
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

-- A card's cost as shown over the card and in tooltips: as FormatSymbols, with a "+"
-- between the generic part and the spheres, e.g. (1)+[B]
function TTS:FormatCost(cost, size)
    if not cost or cost == "" then return "" end
    cost = cost:gsub("({[%dXx]+})({[WUBRGwubrg]})", "%1{+}%2", 1)
    return (self:FormatSymbols(cost, size):gsub("{%+}", "|cFF8E939B+|r"))
end

-- Creature type, faction and zone as one tooltip line, e.g. "Humanoid  •  Defias  •  The Deadmines"
-- (Gear shows its zone)
function TTS:GetCardTagLine(card)
    if not card or (card.type ~= "Creature" and card.subType ~= "Gear") then return nil end
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
local QueueBoardModelReload
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
LAYOUT.BOARD_MIN_SCALE, LAYOUT.BOARD_MAX_SCALE = 0.60, 1.60

local function SaveBoardScale()
    if TTS.Options then TTS.Options:Set("boardScale", B:GetScale()) end
end

B:EnableMouseWheel(true)
B:SetScript("OnMouseWheel", function(self, delta)
    if IsControlKeyDown() then
        local cur = self:GetScale() or 1.0
        local newScale = math.max(LAYOUT.BOARD_MIN_SCALE, math.min(LAYOUT.BOARD_MAX_SCALE, cur + (delta * 0.05)))
        self:SetScale(newScale)
        SaveBoardScale()
        if RefreshAllModelCameras then RefreshAllModelCameras() end
        if RefreshCardText then RefreshCardText() end
        if QueueBoardModelReload then QueueBoardModelReload() end
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

-- The models are reloaded once the drag ends, not on every frame of it
local function StopRescaling()
    if not isRescaling then return end
    isRescaling = false
    if QueueBoardModelReload then QueueBoardModelReload() end
end
resizer:SetScript("OnMouseUp", StopRescaling)
resizer:SetScript("OnHide", StopRescaling)
resizer:SetScript("OnUpdate", function(self)
    if isRescaling then
        local cx, cy = GetCursorPosition()
        local uiScale = UIParent:GetEffectiveScale()
        local dx = (cx - startCursorX) / uiScale
        local dy = (startCursorY - cy) / uiScale
        local delta = (dx + dy) * 0.5 * 0.0015
        local newScale = math.max(LAYOUT.BOARD_MIN_SCALE, math.min(LAYOUT.BOARD_MAX_SCALE, startScale + delta))
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
    if self.autoPassCheck and TTS.Options then self.autoPassCheck:SetChecked(TTS.Options:Get("autoPassBlocks") ~= false) end
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

-- Auto-pass: with nothing able to block an attack, blocking is passed on after a second
-- (CoreEngine.lua, E:AutoPassBlocksSoon)
local autoPassCheck = CreateFrame("CheckButton", nil, B, "UICheckButtonTemplate")
autoPassCheck:SetSize(24, 24)
autoPassCheck:SetPoint("RIGHT", autoPayLabel, "LEFT", -10, -1)
autoPassCheck:SetScript("OnClick", function(self)
    if TTS.Options then TTS.Options:Set("autoPassBlocks", self:GetChecked() and true or false) end
    -- Ticked during an attack nothing can block: pass on it as usual
    if self:GetChecked() and TTS.Engine.AutoPassBlocksSoon then TTS.Engine:AutoPassBlocksSoon() end
end)
B.autoPassCheck = autoPassCheck   -- set from the saved option when the board opens

local autoPassLabel = B:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
autoPassLabel:SetPoint("RIGHT", autoPassCheck, "LEFT", 0, 1)
Loc:Bind(autoPassLabel, "board.autoPass")
autoPassCheck:SetHitRectInsets(-(autoPassLabel:GetStringWidth() + 4), 0, 0, 0)
autoPassCheck:SetScript("OnEnter", function(self)
    TT:ShowText(self, "ANCHOR_TOP", L("board.autoPassTitle"), L("board.autoPassDesc"))
end)
autoPassCheck:SetScript("OnLeave", function(self) TT:Hide(self) end)

-- Lock: the board can't be dragged (OnDragStart above)
local lockCheck = CreateFrame("CheckButton", nil, B, "UICheckButtonTemplate")
lockCheck:SetSize(24, 24)
lockCheck:SetPoint("RIGHT", autoPassLabel, "LEFT", -10, -1)
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
    if E:CanUndoCombat() then
        -- Combat not committed yet: Undo goes back to Main 1 (Undo.lua), no agreement needed
        table.insert(lines, { L("board.undoCombatDesc"), 1, 1, 1, true })
    elseif ok then
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
B.mulliganBtn:SetPoint("BOTTOM", B.nextPhaseBtn, "TOP", 0, 6)
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

-- Flashes while a mulligan can be taken: an additive highlight pulsed over the button
local MULLIGAN_FLASH = 4   -- pulse speed (radians per second)
B.mulliganBtn.flash = B.mulliganBtn:CreateTexture(nil, "OVERLAY")
B.mulliganBtn.flash:SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
B.mulliganBtn.flash:SetTexCoord(0, 0.625, 0, 0.6875)
B.mulliganBtn.flash:SetBlendMode("ADD")
B.mulliganBtn.flash:SetAllPoints()
B.mulliganBtn.flash:SetAlpha(0)
B.mulliganBtn:SetScript("OnUpdate", function(self, elapsed)
    if not self:IsEnabled() then self.flash:SetAlpha(0); return end
    self.flashT = (self.flashT or 0) + elapsed
    self.flash:SetAlpha(0.5 + 0.5 * math.sin(self.flashT * MULLIGAN_FLASH))
end)
B.mulliganBtn:Hide()

B.phaseText = B:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
B.phaseText:SetPoint("TOPLEFT", 30, -22)
B.phaseText:SetJustifyH("LEFT")
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
        -- A solo zone or dungeon goes back to the solo map, which closes to the main window
        -- (practice, the tutorial and PvP stay on the main window)
        local enc = TTS.Engine and TTS.Engine.isSolo and TTS.Engine.encounter
        if enc and enc.kind ~= "practice" and TTS.SoloSelectFrame and TTS.MainFrame.OpenChild then
            TTS.MainFrame:OpenChild(TTS.SoloSelectFrame)
        end
    end
end

-- =========================================================================
-- INTERACTIVE PLAYER LIFE PLATES
-- =========================================================================
B.oppLifeBtn = CreateFrame("Button", nil, B, backdropTemplate)
B.oppLifeBtn:SetSize(270, 28)
B.oppLifeBtn.minWidth = 270   -- wider for a long name (UpdateDisplay)
B.oppLifeBtn:SetPoint("TOP", 0, -15)
Skin(B.oppLifeBtn, "control", STYLE.controlBg, STYLE.controlBorder)
B.oppLifeBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

B.oppLifeText = B.oppLifeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
B.oppLifeText:SetPoint("LEFT", B.oppLifeBtn, "LEFT", 8, 0)
B.oppLifeText:SetJustifyH("LEFT")

-- Solo encounter rules, left of the opponent's name (details in its tooltip); the
-- top-right controls leave no room on its right
B.oppRulesText = B:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
B.oppRulesText:SetPoint("TOPRIGHT", B.oppLifeBtn, "TOPLEFT", -8, -2)
B.oppRulesText:SetWidth(220)
B.oppRulesText:SetJustifyH("RIGHT")
B.oppRulesText:SetTextColor(1, 0.5, 0.25)

-- PvP opponent's collection score, in the same spot (solo games have rules there instead)
B.oppScoreText = B:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
B.oppScoreText:SetPoint("RIGHT", B.oppLifeBtn, "LEFT", -8, 0)
B.oppScoreText:SetJustifyH("RIGHT")

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
B.myLifeBtn:SetPoint("BOTTOM", 0, 20)   -- centred, mirroring the opponent's; clears the footer below
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

-- A player the targeting can choose lights up green; with the cursor (or a card being
-- dragged) over it, gold, with a pulsing gold halo. Checked every frame, as a drag sends no
-- OnEnter.
local PLATE_HALO_PAD = 7
local PLATE_PULSE = 4   -- radians per second
local function PaintPlate(plate)
    local lit = TTS.Engine.inMatch and IsTargetingPlayer(plate == B.oppLifeBtn)
    local hot = lit and plate:IsMouseOver()
    if hot then
        plate:SetBackdropBorderColor(1.0, 0.9, 0.4, 1.0)
        plate:SetBackdropColor(0.55, 0.42, 0.05, 0.9)
    elseif lit then
        plate:SetBackdropBorderColor(0.2, 1.0, 0.2, 1.0)
        plate:SetBackdropColor(0.1, 0.35, 0.1, 0.8)
    else
        local bg, bd = STYLE.controlBg, STYLE.controlBorder
        plate:SetBackdropBorderColor(bd[1], bd[2], bd[3], bd[4])
        plate:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
    end
    plate.halo:SetShown(hot and true or false)
    if hot then plate.halo:SetAlpha(0.35 + 0.25 * math.sin(GetTime() * PLATE_PULSE)) end
end
B.PaintPlate = PaintPlate

for _, plate in ipairs({ B.oppLifeBtn, B.myLifeBtn }) do
    plate.halo = B:CreateTexture(nil, "ARTWORK")   -- (under the plate, so it shows round its edge)
    plate.halo:SetPoint("TOPLEFT", plate, "TOPLEFT", -PLATE_HALO_PAD, PLATE_HALO_PAD)
    plate.halo:SetPoint("BOTTOMRIGHT", plate, "BOTTOMRIGHT", PLATE_HALO_PAD, -PLATE_HALO_PAD)
    plate.halo:SetColorTexture(1.0, 0.82, 0.0, 1)   -- the target arrow's gold
    plate.halo:SetBlendMode("ADD")
    plate.halo:Hide()
end

do
    local plateWatcher = CreateFrame("Frame", nil, B)
    plateWatcher:SetScript("OnUpdate", function()
        if not TTS.Engine.inMatch then return end
        PaintPlate(B.oppLifeBtn)
        PaintPlate(B.myLifeBtn)
    end)
end

-- =========================================================================
-- HEALTH BARS
-- Each life plate fills with a bar behind its text: green when full, through yellow to
-- red. It slides to a new value, and a pale chunk shows life just lost, then drains.
-- Full is the side's starting life (20, or a solo encounter's own); healing above it
-- keeps the bar full. B.SetLifeBar is called from UpdateDisplay.
-- =========================================================================
local LIFE_BAR_TEX   = "Interface\\TargetingFrame\\UI-StatusBar"
local LIFE_INSET     = 3      -- inside the plate's border
local LIFE_SLIDE     = 6      -- how fast the bar moves to its new value (share of the gap per second)
local LIFE_LOST_WAIT = 0.45   -- seconds the lost chunk stays before draining
local LIFE_LOST_RATE = 0.6    -- bar widths per second the lost chunk drains

local function LifeColor(frac)
    if frac > 0.5 then
        local k = (frac - 0.5) * 2   -- yellow -> green
        return 1 - 0.9 * k, 0.85 - 0.05 * k, 0.1 * k
    end
    local k = frac * 2               -- red -> yellow
    return 0.9 + 0.1 * k, 0.1 + 0.75 * k, 0.1 - 0.1 * k
end

local function LifeBar_OnUpdate(self, elapsed)
    local bar = self.bar
    local target = bar.target or 0
    bar.cur = bar.cur or target
    bar.cur = bar.cur + (target - bar.cur) * math.min(1, elapsed * LIFE_SLIDE)
    if math.abs(target - bar.cur) < 0.002 then bar.cur = target end
    bar.lost = math.max(bar.lost or 0, bar.cur)
    if bar.lostWait and bar.lostWait > 0 then
        bar.lostWait = bar.lostWait - elapsed
    elseif bar.lost > bar.cur then
        bar.lost = math.max(bar.cur, bar.lost - elapsed * LIFE_LOST_RATE)
    end
    local inner = math.max(1, bar.plate:GetWidth() - 2 * LIFE_INSET)
    local function Size(t, frac)
        if frac <= 0.001 then t:Hide() else t:SetWidth(inner * math.min(1, frac)); t:Show() end
    end
    Size(bar.fill, bar.cur)
    Size(bar.lostTex, bar.lost)
    bar.fill:SetVertexColor(LifeColor(math.max(0, math.min(1, bar.cur))))
    local settled = bar.cur == target and bar.lost <= bar.cur
    -- The life tracker's number follows the bar: it counts down as the lost chunk drains
    -- (up as healing fills it) and shows the exact life once the bar has settled
    if bar.row and bar.full then
        local shown = settled and bar.life or math.floor(math.max(bar.lost, bar.cur) * bar.full + 0.5)
        bar.row.life:SetText(shown)
        bar.row.life:SetTextColor(LifeColor(math.max(0, math.min(1, shown / bar.full))))
    end
    if settled then self:Hide() end   -- settled: stop updating
end

local function MakeLifeBar(plate)
    local bar = { plate = plate }
    bar.lostTex = plate:CreateTexture(nil, "ARTWORK", nil, 1)
    bar.fill = plate:CreateTexture(nil, "ARTWORK", nil, 2)
    for _, t in ipairs({ bar.lostTex, bar.fill }) do
        t:SetTexture(LIFE_BAR_TEX)
        t:SetPoint("TOPLEFT", plate, "TOPLEFT", LIFE_INSET, -LIFE_INSET)
        t:SetPoint("BOTTOMLEFT", plate, "BOTTOMLEFT", LIFE_INSET, LIFE_INSET)
        t:Hide()
    end
    bar.lostTex:SetVertexColor(1, 0.9, 0.7, 0.85)
    bar.driver = CreateFrame("Frame", nil, plate)
    bar.driver.bar = bar
    bar.driver:SetScript("OnUpdate", LifeBar_OnUpdate)
    plate.lifeBar = bar
end
MakeLifeBar(B.oppLifeBtn)
MakeLifeBar(B.myLifeBtn)

-- The plate's text in an outline, to read over the bar
for _, text in ipairs({ B.oppLifeText, B.myLifeText }) do
    local font, size = text:GetFont()
    if font then text:SetFont(font, size, "OUTLINE") end
end

-- life out of full (full: the side's starting life, or more after healing above it)
function B.SetLifeBar(plate, life, full)
    local bar = plate.lifeBar
    if not bar then return end
    bar.life, bar.full = life, math.max(1, full, life)
    local frac = math.max(0, math.min(1, life / bar.full))
    if bar.target and frac < bar.target then bar.lostWait = LIFE_LOST_WAIT end
    if frac > (bar.target or 0) then bar.lost = bar.cur end   -- healing: nothing lost to show
    bar.target = frac
    bar.driver:Show()
end

-- =========================================================================
-- LIFE TRACKER
-- Both players' life at a glance, in the free space on the board's right edge (the
-- battlefield stops at LAYOUT.BF_RIGHT), a little above the middle: the opponent's above,
-- yours below, each number coloured like its life bar and changing with it (LifeBar_OnUpdate)
-- =========================================================================
do
local TRACKER_W, TRACKER_H = 70, 96
local TRACKER_X, TRACKER_Y = -23, 46   -- from the middle of the board's right edge

B.lifeTracker = CreateFrame("Frame", nil, B, backdropTemplate)
B.lifeTracker:SetSize(TRACKER_W, TRACKER_H)
B.lifeTracker:SetPoint("RIGHT", B, "RIGHT", TRACKER_X, TRACKER_Y)
Skin(B.lifeTracker, "control", STYLE.controlBg, STYLE.controlBorder)

local function TrackerRow(yOffset)
    local row = {}
    row.life = B.lifeTracker:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    row.life:SetPoint("CENTER", B.lifeTracker, "CENTER", 0, yOffset)
    local font = row.life:GetFont()
    if font then row.life:SetFont(font, 30, "THICKOUTLINE") end
    return row
end
B.lifeTracker.opp = TrackerRow(TRACKER_H / 4)
B.lifeTracker.me = TrackerRow(-TRACKER_H / 4)

local trackerLine = B.lifeTracker:CreateTexture(nil, "ARTWORK")
trackerLine:SetPoint("LEFT", B.lifeTracker, "LEFT", 10, 0)
trackerLine:SetPoint("RIGHT", B.lifeTracker, "RIGHT", -10, 0)
trackerLine:SetHeight(1)
trackerLine:SetColorTexture(1, 0.82, 0, 0.5)

B.oppLifeBtn.lifeBar.row = B.lifeTracker.opp
B.myLifeBtn.lifeBar.row = B.lifeTracker.me
end

-- =========================================================================
-- MANA COUNTER
-- "Mana:" then one hoverable slot per sphere, so each symbol has its tooltip
-- =========================================================================
local MANA_ORDER = { "W", "U", "B", "R", "G" }

B.manaText = B:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
B.manaText:SetPoint("BOTTOMLEFT", 30, 26)
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
EFFECT_BAR.EFFECT_ICON  = 24
EFFECT_BAR.EFFECT_GAP   = 4
EFFECT_BAR.EFFECT_COLS  = 3
EFFECT_BAR.EFFECT_ROWS  = 2
EFFECT_BAR.EFFECT_LABEL = 14

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
    bar:SetSize(EFFECT_BAR.EFFECT_COLS * (EFFECT_BAR.EFFECT_ICON + EFFECT_BAR.EFFECT_GAP) - EFFECT_BAR.EFFECT_GAP,
        EFFECT_BAR.EFFECT_LABEL + EFFECT_BAR.EFFECT_ROWS * (EFFECT_BAR.EFFECT_ICON + EFFECT_BAR.EFFECT_GAP))

    bar.label = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    bar.label:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 0, 0)
    bar.label:SetJustifyH("RIGHT")
    Loc:Bind(bar.label, labelText)

    bar.icons = {}
    for i = 1, EFFECT_BAR.EFFECT_COLS * EFFECT_BAR.EFFECT_ROWS do
        local col = (i - 1) % EFFECT_BAR.EFFECT_COLS
        local row = math.floor((i - 1) / EFFECT_BAR.EFFECT_COLS)
        local icon = CreateFrame("Frame", nil, bar)
        icon:SetSize(EFFECT_BAR.EFFECT_ICON, EFFECT_BAR.EFFECT_ICON)
        icon:SetPoint("TOPRIGHT", bar, "TOPRIGHT",
            -col * (EFFECT_BAR.EFFECT_ICON + EFFECT_BAR.EFFECT_GAP),
            -EFFECT_BAR.EFFECT_LABEL - row * (EFFECT_BAR.EFFECT_ICON + EFFECT_BAR.EFFECT_GAP))

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
        TTS.SetupCardVisual(f, f.currentCard, f.isFoil)
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
    if ShowBoardPreview then ShowBoardPreview(self, card, self.isFoil) end

    local ctx = { foil = self.isFoil }
    if self.fieldIndex then
        ctx.perm = (self.isRemote and TTS.Engine.remoteState.field or TTS.Engine.localState.field)[self.fieldIndex]
        ctx.isRemote = self.isRemote
        ctx.fieldIndex = self.fieldIndex
        if card.colors and not self.isRemote then
            ctx.hint = L(card.noPartner and "hint.bothPrayer" or card.makesBoth and "hint.doublePrayer" or "hint.dualPrayer",
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

-- t.full (optional): the card's full-art frame texture (CreateCardFrame), set to the same
-- frame's <name>_full.png, or cleared when there isn't one
local function ApplyFrameTexture(t, card)
    local tex = GetCardFrameTexture(card)
    t:SetTexture(tex)
    -- A missing dual frame falls back to the single-colour one, then the default
    if not t:GetTexture() and card then
        tex = SingleFrameTexture(card)
        t:SetTexture(tex)
    end
    if not t:GetTexture() then
        tex = CARD_FRAME_DEF
        t:SetTexture(tex)
        if not t:GetTexture() then
            tex = nil
            t:SetTexture(FALLBACK_BORDER)
        end
    end
    if t.full then
        t.full:SetTexture(tex and (tex:gsub("%.png$", "_full.png")) or nil)
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
-- FOIL GLOW
-- A foil card (BossTracker.lua) glows in its colour: a soft halo round its edges and a rim
-- inside its art window, pulsing slowly, with sparkles twinkling off its edges; a two-colour
-- card fades between both. Purely a look; each client paints it for both players' cards
-- (E:IsFoil / E:IsPermFoil).
-- =========================================================================
local FOIL_GLOW_TEX = TEXTURE_ROOT .. "FoilGlow.tga"   -- the card fills its middle 192 of 256 px
local FOIL_GLOW_PAD = 32 / 192   -- halo width beyond the card, as a share of the card's size
local FOIL_RIM_TEX  = TEXTURE_ROOT .. "FoilRim.tga"    -- glow fading in from the art window's edges
local FOIL_RIM_ALPHA = 0.8   -- the rim's strength, at the top of the pulse
local FOIL_PULSE = 1.2    -- pulse speed (radians per second)
local FOIL_FADE  = 0.8    -- a two-colour card's fade between its colours (radians per second)
-- The spheres' colours, as the Deckbuilder shows them; colourless cards glow gold
local FOIL_RGB = {
    W = { 1.00, 0.82, 0.00 },  -- Holy
    U = { 0.40, 0.73, 1.00 },  -- Arcane
    B = { 0.60, 0.40, 1.00 },  -- Shadow
    R = { 1.00, 0.27, 0.27 },  -- Fire
    G = { 0.27, 1.00, 0.27 },  -- Nature
}
local FOIL_GOLD = { 1.00, 0.82, 0.20 }

-- The card's colours as its frame picks them (DualFrameTexture / SingleFrameTexture): its
-- two colours, or its colour, school or first colour in its cost
local function FoilColors(card)
    local list = {}
    if card then
        for _, col in ipairs(card.colors or { "W", "U", "B", "R", "G" }) do
            if card.colors or (card.cost and card.cost:find("{" .. col .. "}", 1, true)) then
                list[#list + 1] = FOIL_RGB[col]
            end
        end
        if #list ~= 2 then
            local col = card.color or card.school or (card.cost and card.cost:match("{([WUBRGwubrg])}"))
            list = { FOIL_RGB[col and string.upper(col)] }
        end
    end
    if not list[1] then list = { FOIL_GOLD } end
    return list
end
TTS.CardColors = FoilColors
TTS.SPHERE_RGB = FOIL_RGB

-- Sparkles: little stars that twinkle on round the card's edge and drift off it, in the
-- glow's colour washed towards white. Made on the overlay (over the model and frame) the
-- first time a frame shows a foil.
local FOIL_SPARKLE_TEX = TEXTURE_ROOT .. "FoilSparkle.tga"
local FOIL_SPARKS      = 6       -- alive at once per card
local FOIL_SPARK_SIZE  = 0.22    -- largest size, as a share of the card's width
local FOIL_SPARK_LIFE  = { 0.7, 1.5 }   -- seconds, shortest and longest
local FOIL_SPARK_DRIFT = 6       -- px per second off the card's edge (card's own scale)
local FOIL_SPARK_RISE  = 5       -- px per second upwards
local FOIL_SPARK_WHITE = 0.45    -- how far towards white the colour is washed

-- A new sparkle somewhere on the card's edge (w x h), after a short random wait
local function SpawnSpark(s, w, h)
    local u = math.random() * 2 * (w + h)
    if u < w then s.x, s.y, s.nx, s.ny = u, h, 0, 1
    elseif u < w + h then s.x, s.y, s.nx, s.ny = w, h - (u - w), 1, 0
    elseif u < 2 * w + h then s.x, s.y, s.nx, s.ny = w - (u - w - h), 0, 0, -1
    else s.x, s.y, s.nx, s.ny = 0, u - 2 * w - h, -1, 0 end
    -- A little either side of the edge
    local off = (math.random() - 0.3) * w * 0.08
    s.x, s.y = s.x + s.nx * off, s.y + s.ny * off
    s.t = -math.random() * 0.6
    s.life = FOIL_SPARK_LIFE[1] + math.random() * (FOIL_SPARK_LIFE[2] - FOIL_SPARK_LIFE[1])
    s.spin = (math.random() - 0.5) * 2
    s.size = w * FOIL_SPARK_SIZE * (0.6 + 0.4 * math.random())
end

local function UpdateSparks(self, elapsed, r, g, b)
    local w, h = self.w, self.h
    local shade = self.shade or 1
    r, g, b = r + (1 - r) * FOIL_SPARK_WHITE, g + (1 - g) * FOIL_SPARK_WHITE, b + (1 - b) * FOIL_SPARK_WHITE
    for _, s in ipairs(self.sparks) do
        s.t = s.t + elapsed
        if s.t >= s.life then SpawnSpark(s, w, h) end
        local tex = s.tex
        if s.t < 0 then
            tex:Hide()
        else
            local k = math.sin(math.pi * s.t / s.life)   -- 0 -> 1 -> 0 over its life
            local size = s.size * (0.3 + 0.7 * k)
            tex:SetSize(size, size)
            tex:ClearAllPoints()
            tex:SetPoint("CENTER", self.anchor, "BOTTOMLEFT",
                s.x + s.nx * FOIL_SPARK_DRIFT * s.t, s.y + s.ny * FOIL_SPARK_DRIFT * s.t + FOIL_SPARK_RISE * s.t)
            tex:SetVertexColor(r, g, b, k * shade)
            if tex.SetRotation then tex:SetRotation(s.spin * s.t) end
            tex:Show()
        end
    end
end

local function HideSparks(foil)
    for _, s in ipairs(foil.sparks or {}) do s.tex:Hide() end
end

local function MakeSparks(foil)
    if foil.sparks then return end
    foil.sparks = {}
    for k = 1, FOIL_SPARKS do
        local tex = foil.anchor:CreateTexture(nil, "OVERLAY", nil, 6)
        tex:SetTexture(FOIL_SPARKLE_TEX)
        tex:SetBlendMode("ADD")
        tex:Hide()
        local s = { tex = tex }
        SpawnSpark(s, foil.w, foil.h)
        s.t = -(k - 1) * FOIL_SPARK_LIFE[2] / FOIL_SPARKS   -- staggered from the start
        foil.sparks[k] = s
    end
end

local function Foil_OnUpdate(self, elapsed)
    self.t = (self.t or 0) + elapsed
    local a, b = self.colors[1], self.colors[2] or self.colors[1]
    local mix = 0.5 + 0.5 * math.sin(self.t * FOIL_FADE)
    local r, g, bl = a[1] + (b[1] - a[1]) * mix, a[2] + (b[2] - a[2]) * mix, a[3] + (b[3] - a[3]) * mix
    local pulse = 0.5 + 0.5 * math.sin(self.t * FOIL_PULSE)
    self.glow:SetVertexColor(r, g, bl, (0.4 + 0.6 * pulse) * (self.shade or 1))
    self.rim:SetVertexColor(r, g, bl, FOIL_RIM_ALPHA * (0.4 + 0.6 * pulse) * (self.shade or 1))
    self.title:SetTextColor(r, g, bl)
    UpdateSparks(self, elapsed, r, g, bl)
end

-- foil: show the glow (true) or not, in the card's colours, with the card's name in them too.
-- shade (default 1) dims it with the card, e.g. a tapped one (TintArt).
local function SetCardFoil(f, foil, card, shade)
    if not f.foil then return end
    foil = foil or (card and card.alwaysFoil)   -- only comes as a foil (Cards\Special.lua)
    f.isFoil = foil and true or nil
    f.foil.shade = shade or 1
    if foil then
        f.foil.colors = FoilColors(card)
        local c = f.foil.colors[1]
        f.title:SetTextColor(c[1], c[2], c[3])
        MakeSparks(f.foil)
        f.foil.glow:Show()
        f.foil.rim:SetShown(not f.modelInFront)   -- (none round the full-art window, SetModelInFront)
        f.foil:Show()
    else
        f.foil:Hide()
        f.foil.glow:Hide()
        f.foil.rim:Hide()
        HideSparks(f.foil)
        local c = f.foil.titleColor
        f.title:SetTextColor(c[1] or 1, c[2] or 1, c[3] or 1)
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
    -- While an effect plays (SetModelInFront) a backing of the card's own background fills the
    -- full-art frame's window, over the rules box, and the model's window grows by as much
    -- above as below so a swing isn't cut off at the art box. Its centre stays put and its
    -- camera stands back by as much as it grew (f.modelFullCam), so the creature keeps its
    -- place and size while the frame changes round it.
    local fullBottom = math.floor(sizeY * FULL_ART_BOTTOM)
    local grow = math.max(0, artBottom - fullBottom)
    f.model.fxBack = f.model:CreateTexture(nil, "BACKGROUND")
    f.model.fxBack:SetPoint("TOPLEFT", f, "TOPLEFT", artLeft, -artTop)
    f.model.fxBack:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -artRight, fullBottom)
    f.model.fxBack:SetColorTexture(0.08, 0.08, 0.08, 0.95)
    f.model.fxBack:Hide()
    f.modelWindow = {
        [false] = { artLeft, -artTop, -artRight, artBottom },
        [true]  = { artLeft, -artTop + grow, -artRight, fullBottom },
    }
    f.modelFullCam = (boxH + 2 * grow) / boxH * FX_MODEL_CAM_PULL
    f.model:EnableMouse(false)
    f.model:Hide()

    -- Foil glow (SetCardFoil): a halo just outside the card, under the card's own background.
    -- f.foil only runs its pulse while shown.
    local glowX, glowY = sizeX * FOIL_GLOW_PAD, sizeY * FOIL_GLOW_PAD
    f.foil = CreateFrame("Frame", nil, f)
    f.foil:SetSize(1, 1)
    f.foil:SetPoint("CENTER", f, "CENTER")
    f.foil:EnableMouse(false)
    f.foil.glow = f:CreateTexture(nil, "BACKGROUND", nil, -8)
    f.foil.glow:SetPoint("TOPLEFT", f, "TOPLEFT", -glowX, glowY)
    f.foil.glow:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", glowX, -glowY)
    f.foil.glow:SetTexture(FOIL_GLOW_TEX)
    f.foil.glow:SetBlendMode("ADD")
    f.foil.glow:Hide()
    f.foil:SetScript("OnUpdate", Foil_OnUpdate)
    f.foil:Hide()

    f.overlay = CreateFrame("Frame", nil, f)
    f.overlay:SetAllPoints(f)
    f.overlay:EnableMouse(false)
    -- The foil's sparkles go on the overlay (MakeSparks), positioned in the card's own size
    f.foil.anchor, f.foil.w, f.foil.h = f.overlay, sizeX, sizeY
    -- The foil's rim round the art window: on the overlay, so over the art and model, and
    -- under the card frame (OVERLAY layer), which covers its outer edge
    f.foil.rim = f.overlay:CreateTexture(nil, "ARTWORK")
    f.foil.rim:SetPoint("TOPLEFT", f, "TOPLEFT", artLeft - iconPadX, -(artTop - iconPadY))
    f.foil.rim:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -artRight + iconPadX, artBottom - iconPadY)
    f.foil.rim:SetTexture(FOIL_RIM_TEX)
    f.foil.rim:SetBlendMode("ADD")
    f.foil.rim:Hide()

    local function SyncFrameLevels(baseLevel)
        local base = baseLevel or f:GetFrameLevel() or 10
        if f.tuckedFrames then
            for k, tf in ipairs(f.tuckedFrames) do
                tf:SetFrameLevel(math.max(1, base - k))
            end
        end
        -- (CardFX.lua brings the model in front of the frame and tap symbol while an effect plays)
        if f.model then f.model:SetFrameLevel(base + (f.modelInFront and 4 or 1)) end
        if f.overlay then f.overlay:SetFrameLevel(base + 2) end
        if f.tapLayer then f.tapLayer:SetFrameLevel(base + 3) end
        if f.fxLayer then f.fxLayer:SetFrameLevel(base + 5) end   -- (CardFX.lua's FX layer: over everything)
    end

    -- f.fullArtPinned (the Deckbuilder's Show full art) keeps it in front whatever asks otherwise
    function f:SetModelInFront(on)
        on = (on or f.fullArtPinned) and true or false
        if f.modelInFront == on then return end
        f.modelInFront = on
        SyncFrameLevels()
        if not f.model then return end
        -- In front it drops its tapped / summoning-sick shade (f.modelAlpha), and takes it back after
        if not f.spawning then f.model:SetAlpha(on and 1 or (f.modelAlpha or 1)) end
        -- The backing fills the full-art frame's window, which fades in over the usual one; the
        -- model's window grows round its centre with the camera standing back to match
        local w = f.modelWindow[on]
        f.model:ClearAllPoints()
        f.model:SetPoint("TOPLEFT", f, "TOPLEFT", w[1], w[2])
        f.model:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", w[3], w[4])
        if f.model.SetCamDistanceScale and f.modelCamScale then
            f.model:SetCamDistanceScale(f.modelCamScale * (on and f.modelFullCam or 1))
        end
        f.model.fxBack:SetShown(on)
        -- A foil's rim glows round the usual art window only, not the full-art one
        f.foil.rim:SetShown(f.isFoil and not on or false)
        if f.borderFull then
            f.borderFull:SetVertexColor(f.border:GetVertexColor())
            local fader = f.fullArtFader
            fader.target = on and 1 or 0
            fader:Show()
            -- (a card not showing never ticks: straight there)
            if not f:IsVisible() then fader:GetScript("OnUpdate")(fader, FULL_ART_FADE) end
        end
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
    -- The full-art frame (SetModelInFront), kept in step with the usual one by ApplyFrameTexture
    f.borderFull = f.overlay:CreateTexture(nil, "OVERLAY")
    f.borderFull:SetAllPoints(f.overlay)
    f.borderFull:SetAlpha(0)
    f.border.full = f.borderFull
    ApplyFrameTexture(f.border)

    -- Fades between the two frames (target: 1 full art, 0 the usual); a card not showing goes
    -- straight there. A card without a full-art frame keeps its usual one.
    f.fullArtFader = CreateFrame("Frame", nil, f)
    f.fullArtFader.alpha, f.fullArtFader.target = 0, 0
    f.fullArtFader:Hide()
    f.fullArtFader:SetScript("OnUpdate", function(self, elapsed)
        local target = f.borderFull:GetTexture() and self.target or 0
        local step = (elapsed or 0) / FULL_ART_FADE
        if self.alpha < target then
            self.alpha = math.min(target, self.alpha + step)
        else
            self.alpha = math.max(target, self.alpha - step)
        end
        f.border:SetAlpha(1 - self.alpha)
        f.borderFull:SetAlpha(self.alpha)
        if self.alpha == target then self:Hide() end
    end)

    f.title = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.title:SetPoint("BOTTOMLEFT", f.overlay, "TOPLEFT", -6, 3)
    f.title:SetPoint("BOTTOMRIGHT", f.overlay, "TOPRIGHT", 6, 3)
    f.title:SetJustifyH("CENTER")
    -- A foil card's name takes its colours (SetCardFoil); its own colour is kept to go back to
    f.foil.title, f.foil.titleColor = f.title, { f.title:GetTextColor() }

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
LAYOUT.HAND_W, LAYOUT.HAND_H, LAYOUT.HAND_STEP = 72, 102, 96
LAYOUT.HAND_LEFT, LAYOUT.HAND_RIGHT, LAYOUT.HAND_BOTTOM = 35, 1054, 52   -- right edge stops short of your deck
LAYOUT.HAND_MAX_SCALE = 1.1   -- keeps a two-line title and its cost under the battlefield

LAYOUT.BF_CARD_W  = 64
LAYOUT.BF_CARD_H  = 84
LAYOUT.BF_STEP_X  = 86
LAYOUT.BF_START_X = 35
LAYOUT.BF_RIGHT   = 1045   -- right edge stops short of your effects bar
LAYOUT.LAND_MAX_SCALE     = 1.0
LAYOUT.CREATURE_MAX_SCALE = 1.2
LAYOUT.MAX_CREATURE_FRAMES = 16   -- frames each creature row starts with; more are made as needed (FieldFrame)
LAYOUT.BF_MIN_SCALE = 0.15        -- battlefield cards shrink to fit (FitScale) down to this

-- Vertical centre of each battlefield row, measured up from the board's bottom edge. Rows
-- stack up from BF_BOTTOM, each leaving room above its cards for a two-line title
-- (GameFontHighlightSmall lines, its 3px offset and a little clearance), scaled with the row.
-- The top row's title ends just under the opponent's hand.
LAYOUT.BF_BOTTOM  = 212
LAYOUT.TITLE_ROOM = 2 * 11 + 3 + 3
local ROW_Y = {}
do
    local y = LAYOUT.BF_BOTTOM
    for _, row in ipairs({
        { "myLand", LAYOUT.LAND_MAX_SCALE }, { "myNonLand", LAYOUT.CREATURE_MAX_SCALE },
        { "oppNonLand", LAYOUT.CREATURE_MAX_SCALE }, { "oppLand", LAYOUT.LAND_MAX_SCALE },
    }) do
        local h = LAYOUT.BF_CARD_H * row[2]
        ROW_Y[row[1]] = y + h / 2
        y = y + h + LAYOUT.TITLE_ROOM * row[2]
    end
end

local function AttachSlot(f)
    f.slot = CreateFrame("Frame", nil, B)
    f.slot:SetSize(1, 1)
    f:ClearAllPoints()
    f:SetPoint("CENTER", f.slot, "CENTER", 0, 0)
end

-- Largest scale (up to maxScale) at which n cards fit between left and right, but no
-- smaller than minScale (default 0.5)
local function FitScale(n, cardW, step, left, right, maxScale, minScale)
    if n <= 0 then return maxScale end
    local need = (n - 1) * step + cardW
    return math.max(minScale or 0.5, math.min(maxScale, (right - left) / need))
end

-- A card whose size changed (its row gained or lost a card, or its slot is used for the first
-- time and so starts at scale 1) loads its model again on the next frame, and once more when
-- any played card has landed: a model already showing keeps its old size otherwise. A model
-- the client has cached loads at once, at the size of the moment, before the card is placed.
TIMING.MODEL_RESIZE_DELAY = 0.35
local resizedFrames = {}
local function ReloadModels(list)
    for f in pairs(list) do
        if f:IsShown() and f.currentCard and f.model and f.model:IsShown() and TTS.SetupCardVisual then
            f.visualCard = nil
            TTS.SetupCardVisual(f, f.currentCard, f.isFoil)
        end
    end
end

local function QueueModelReload(f)
    if not next(resizedFrames) then
        TTS:SafeAfter(0, function() ReloadModels(resizedFrames) end)
        TTS:SafeAfter(TIMING.MODEL_RESIZE_DELAY, function()
            local list = resizedFrames
            resizedFrames = {}
            ReloadModels(list)
        end)
    end
    resizedFrames[f] = true
end

-- Any resize on the battlefield (a row rescaling, the board itself, or the game window / UI
-- scale) reloads every model on the board, hand included, not just the cards whose size
-- changed: a model left at its old size drifts off its card
QueueBoardModelReload = function()
    for _, group in ipairs({ myHandFrames, myLandFrames, myNonLandFrames, oppLandFrames, oppNonLandFrames }) do
        for _, f in ipairs(group) do
            if f.model and f:IsShown() then QueueModelReload(f) end
        end
    end
end

do
    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("DISPLAY_SIZE_CHANGED")
    watcher:RegisterEvent("UI_SCALE_CHANGED")
    watcher:SetScript("OnEvent", function()
        if not B:IsShown() then return end
        if RefreshAllModelCameras then RefreshAllModelCameras() end
        if RefreshCardText then RefreshCardText() end
        QueueBoardModelReload()
    end)
end

-- Returns true when the card's size changed
local function PlaceCard(f, i, s, left, centerY, cardW, step)
    local resized = (f.baseScale or 1) ~= s
    if resized and f.model then QueueModelReload(f) end
    f.baseScale = s
    f:SetScale(f.hovered and s * 1.18 or s)
    f.slot:ClearAllPoints()
    f.slot:SetPoint("CENTER", B, "BOTTOMLEFT", left + (i - 1) * step * s + cardW * s / 2, centerY)
    return resized
end

-- Prints the card's rules on it when the card is wide enough on screen; otherwise
-- hides them (tooltip only). P/T moves to the corner while text is printed.
-- opts (optional): fontMax, fontMin, offsetX (pixels right), offsetY (pixels down)
local function UpdateCardRules(f, opts)
    if not f.rules then return end
    local card = f.currentCard
    local fontMax = (opts and opts.fontMax) or RULES.RULES_FONT_MAX
    local fontMin = (opts and opts.fontMin) or RULES.RULES_FONT_MIN
    local dx = (opts and opts.offsetX) or 0
    local dy = (opts and opts.offsetY) or 0
    local hasPT = f.pt:IsShown()
    local w, h = f:GetSize()
    -- Width on screen, from the card's real scale (works on the board and in other windows);
    -- a hovered hand card's zoom is left out so hovering never toggles the text
    local onScreen = w * f:GetEffectiveScale() / UIParent:GetEffectiveScale() / (f.hovered and 1.18 or 1)

    TTS.PlaceCardStats(f)
    -- On the battlefield (f.perm) the text also shows keywords the denizen gained or lost
    local text = card and TTS:CardRulesText(card, true, f.perm, f.isRemote)
    if text and text ~= "" and onScreen >= RULES.CARD_TEXT_MIN_WIDTH then
        -- Fitting happens in the card's own (unscaled) size, so it only needs redoing for new text
        if f.rulesText ~= text or f.rulesPT ~= hasPT then
            f.rulesText, f.rulesPT = text, hasPT
            f.rules:ClearAllPoints()
            f.rules:SetPoint("TOPLEFT", f.overlay, "TOPLEFT", w * TEXT_BOX.left + 1 + dx, -h * TEXT_BOX.top - 1 - dy)
            f.rules:SetPoint("BOTTOMRIGHT", f.overlay, "BOTTOMRIGHT", -w * TEXT_BOX.right + dx,
                h * (hasPT and TEXT_BOX.bottomWithPT or TEXT_BOX.bottom) - dy)
            f.rules:SetJustifyH("CENTER")
            local fontPath = f.rules:GetFont() or STANDARD_TEXT_FONT
            for size = fontMax, fontMin, -1 do
                f.rules:SetFont(fontPath, size, "")
                f.rules:SetText(TTS:FormatSymbols(text, size + 2 + RULES.RULES_TAP_EXTRA, size + 2 + RULES.RULES_TAP_EXTRA))
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
BG.BG_INSET = 4
BG.BG_W, BG.BG_H = 1028 - BG.BG_INSET * 2, 496 - BG.BG_INSET * 2
BG.MAP_W, BG.MAP_H, BG.MAP_TILE = 1002, 668, 256
BG.LOADSCREEN_PATH = "Interface\\Glues\\LoadingScreens\\"
BG.BG_OVERLAY_ALPHA = 0.55
BG.PANEL_BG_DIMMED = 0.25

local bgTiles = {}
local overlayPool = {}   -- explored-area overlay textures, created as needed
for i = 1, 12 do
    local t = battlefield:CreateTexture(nil, "BACKGROUND", nil, 0)
    t:Hide()
    bgTiles[i] = t
end
local bgArt = battlefield:CreateTexture(nil, "BACKGROUND", nil, 1)
bgArt:SetPoint("TOPLEFT", battlefield, "TOPLEFT", BG.BG_INSET, -BG.BG_INSET)
bgArt:SetSize(BG.BG_W, BG.BG_H)
bgArt:Hide()
local bgOverlay = battlefield:CreateTexture(nil, "BACKGROUND", nil, 2)
bgOverlay:SetPoint("TOPLEFT", battlefield, "TOPLEFT", BG.BG_INSET, -BG.BG_INSET)
bgOverlay:SetSize(BG.BG_W, BG.BG_H)
bgOverlay:SetColorTexture(0, 0, 0, BG.BG_OVERLAY_ALPHA)
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
    local loaded = bgArt:SetTexture(BG.LOADSCREEN_PATH .. file)
    if loaded == false or not bgArt:GetTexture() then return false end
    local scaledH = BG.BG_W / (wide and 16 / 9 or 4 / 3)
    local crop = math.max(0, (scaledH - BG.BG_H) / 2) / scaledH
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
    local ix0, ix1 = math.max(px0, 0), math.min(px0 + pw, BG.MAP_W)
    local iy0, iy1 = math.max(py0, winTop), math.min(py0 + ph, winBottom, BG.MAP_H)
    if ix1 <= ix0 or iy1 <= iy0 then
        t:Hide()
        return false
    end
    t:ClearAllPoints()
    t:SetPoint("TOPLEFT", battlefield, "TOPLEFT", BG.BG_INSET + ix0 * s, -(BG.BG_INSET + (iy0 - winTop) * s))
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
    local s = BG.BG_W / BG.MAP_W
    local winTop = ((BG.MAP_H * s - BG.BG_H) / 2) / s     -- map rows above the visible window
    local winBottom = winTop + BG.BG_H / s
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
            if PlaceMapPiece(t, col * BG.MAP_TILE, row * BG.MAP_TILE, BG.MAP_TILE, BG.MAP_TILE, BG.MAP_TILE, BG.MAP_TILE, s, winTop, winBottom, tint) then
                shown = shown + 1
            end
        end
    end

    local used = 0
    for _, o in ipairs((TTS.MapOverlays and TTS.MapOverlays[map]) or {}) do
        local ox, oy, w, h, files = o[1], o[2], o[3], o[4], o[5]
        local across = math.ceil(w / BG.MAP_TILE)
        local down = math.ceil(h / BG.MAP_TILE)
        for r = 0, down - 1 do
            for c = 0, across - 1 do
                local name = files[r * across + c + 1]
                if name then
                    local pw = (c < across - 1) and BG.MAP_TILE or (w - c * BG.MAP_TILE)
                    local ph = (r < down - 1) and BG.MAP_TILE or (h - r * BG.MAP_TILE)
                    local t = OverlayTexture(used + 1)
                    -- A file this client doesn't have is skipped rather than drawn
                    local loaded = t:SetTexture(string.format("Interface\\WorldMap\\%s\\%s", map, name))
                    if loaded ~= false and t:GetTexture() and PlaceMapPiece(t, ox + c * BG.MAP_TILE, oy + r * BG.MAP_TILE, pw, ph,
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
    battlefield:SetBackdropColor(STYLE.panelBg[1], STYLE.panelBg[2], STYLE.panelBg[3], BG.PANEL_BG_DIMMED)
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
    local f = CreateCardFrame(B, LAYOUT.HAND_W, LAYOUT.HAND_H)
    f.isHand = true
    f.handIndex = i
    f.origFrameLevel = f:GetFrameLevel()
    AttachSlot(f)
    f:SetScript("OnClick", function(self, btn)
        if not TTS.Engine.inMatch then return end
        if self.dragEnded == GetTime() then return end   -- the mouse-up that ended a drag
        if TTS:TryLinkCard(self.cardId, self.isFoil) then return end
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

    -- Not a target: the opponent is targeted with their life plate. Right-click still cancels.
    f:RegisterForClicks("RightButtonUp")
    f:SetScript("OnClick", function(self, btn)
        if TTS.Engine.inMatch and btn == "RightButton" and TTS.Engine.targeting then
            TTS.Engine:CancelTargeting()
        end
    end)
    f:Hide()
    oppHandFrames[i] = f
end

-- How many cards the opponent holds, just after the last card back (UpdateDisplay moves it)
local oppHandCount = B:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
B.oppHandCount = oppHandCount

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
        if TTS:TryLinkCard(self.cardId, self.isFoil) then return end
        handler(self, btn)
        PlayFieldClickSound(perm, wasTapped)
    end
end

local FieldFrame   -- (group, i): a battlefield row's i-th card frame, made if it doesn't exist yet
do
local function NewFieldFrame(isRemote, onClick)
    local f = CreateCardFrame(B, LAYOUT.BF_CARD_W, LAYOUT.BF_CARD_H)
    f.isRemote = isRemote
    AttachSlot(f)
    f:SetScript("OnClick", onClick)
    return f
end

local OppLand_OnClick = function(self, btn)
    if not TTS.Engine.inMatch then return end
    if TTS:TryLinkCard(self.cardId, self.isFoil) then return end
    PlayUISound("card")
    if btn == "RightButton" and TTS.Engine.targeting then
        TTS.Engine:CancelTargeting()
        return
    end
    if TTS.Engine.targeting and (TTS.Engine.targeting.targetType == "LAND") then
        if self.fieldIndex then TTS.Engine:ResolveTarget("LAND", true, self.fieldIndex) end
    end
end

local OppNonLand_OnClick = function(self, btn)
    if not TTS.Engine.inMatch then return end
    if TTS:TryLinkCard(self.cardId, self.isFoil) then return end
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
end

-- How each battlefield row makes a card frame. A row starts with its usual number of frames
-- and gains more as needed (FieldFrame), the cards shrinking to fit; B.fieldFrameHooks
-- run on every frame made after loading (e.g. CardDrag.lua's drag scripts).
local FIELD_FRAME_MAKERS = {
    [myLandFrames]     = function() return NewFieldFrame(false, WithFieldSound(MyLand_OnClick)) end,
    [myNonLandFrames]  = function() return NewFieldFrame(false, WithFieldSound(MyNonLand_OnClick)) end,
    [oppLandFrames]    = function() return NewFieldFrame(true, OppLand_OnClick) end,
    [oppNonLandFrames] = function() return NewFieldFrame(true, OppNonLand_OnClick) end,
}
B.fieldFrameHooks = {}

FieldFrame = function(group, i)
    if not group[i] then
        local f = FIELD_FRAME_MAKERS[group]()
        group[i] = f
        for _, hook in ipairs(B.fieldFrameHooks) do hook(f, group) end
    end
    return group[i]
end
end

for i = 1, 12 do FieldFrame(myLandFrames, i) end
for i = 1, LAYOUT.MAX_CREATURE_FRAMES do FieldFrame(myNonLandFrames, i) end
for i = 1, 12 do FieldFrame(oppLandFrames, i) end
for i = 1, LAYOUT.MAX_CREATURE_FRAMES do FieldFrame(oppNonLandFrames, i) end

local myDeckFrame = CreateFrame("Frame", nil, B)
myDeckFrame:SetSize(LAYOUT.HAND_W, LAYOUT.HAND_H)
myDeckFrame:SetPoint("BOTTOMRIGHT", -30, 52)
myDeckFrame.back = myDeckFrame:CreateTexture(nil, "ARTWORK")
myDeckFrame.back:SetAllPoints(myDeckFrame)
ApplyBackTexture(myDeckFrame.back)
myDeckFrame.count = myDeckFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
myDeckFrame.count:SetPoint("BOTTOM", myDeckFrame.back, "TOP", 0, 2)   -- on the pile, which grows up and left

-- Opponent's deck: top-right, at the end of their hand row, with the cards left beside it
local oppDeckFrame = CreateFrame("Frame", nil, B)
oppDeckFrame:SetSize(52, 68)
oppDeckFrame:SetPoint("TOPRIGHT", B, "TOPRIGHT", -108, -54)
oppDeckFrame.back = oppDeckFrame:CreateTexture(nil, "ARTWORK")
oppDeckFrame.back:SetAllPoints(oppDeckFrame)
ApplyBackTexture(oppDeckFrame.back)
oppDeckFrame.count = oppDeckFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
oppDeckFrame.count:SetPoint("RIGHT", oppDeckFrame.back, "LEFT", -6, 0)

-- A deck is drawn as a stack that gets lower as it runs down, then a lone card back.
-- The stack images hold the top card (the size of card_back.png) with the stack's sides
-- beyond it, so each is scaled as the card back is and anchored by its bottom-right corner.
do   -- its own block: the file is at Lua's 200 locals
local DECK_STACKS = {   -- from the most cards left: { at least this many, texture, width, height (px) }
    { 35, TEXTURE_ROOT .. "Cards\\card_stack_tall.png",   675, 908 },
    { 20, TEXTURE_ROOT .. "Cards\\card_stack_medium.png", 664, 890 },
    { 4,  TEXTURE_ROOT .. "Cards\\card_stack_short.png",  643, 855 },
}
local CARD_BACK_PX_W, CARD_BACK_PX_H = 512, 717
local STACK_TOP_PX_X, STACK_TOP_PX_Y = 62, 60   -- the top card's top-left corner in every stack image

-- count: cards left (nil when unknown: drawn as a full deck)
function B.SetDeckStack(deck, count)
    local stack
    for _, s in ipairs(DECK_STACKS) do
        if not count or count >= s[1] then stack = s break end
    end
    if deck.stack == stack then return end
    deck.stack = stack
    local t = deck.back
    t:ClearAllPoints()
    t:SetPoint("BOTTOMRIGHT", deck, "BOTTOMRIGHT")
    if stack then
        t:SetTexture(stack[2])
        t:SetVertexColor(1, 1, 1, 1)
        if t:GetTexture() then
            local w, h = deck:GetWidth() * stack[3] / CARD_BACK_PX_W, deck:GetHeight() * stack[4] / CARD_BACK_PX_H
            t:SetSize(w, h)
            -- The mouse finds the deck (its tooltip) anywhere on the stack, which reaches up and left
            deck:SetHitRectInsets(deck:GetWidth() - w, 0, deck:GetHeight() - h, 0)
            return
        end
    end
    t:SetSize(deck:GetWidth(), deck:GetHeight())
    deck:SetHitRectInsets(0, 0, 0, 0)
    ApplyBackTexture(t)
end

-- Where the stack's top card is drawn, from the deck frame: x (left) and y (up) offsets
function B.DeckTopCardOffset(deck)
    local s = deck.stack
    if not s then return 0, 0 end
    return -deck:GetWidth() * (s[3] - STACK_TOP_PX_X - CARD_BACK_PX_W) / CARD_BACK_PX_W,
        deck:GetHeight() * (s[4] - STACK_TOP_PX_Y - CARD_BACK_PX_H) / CARD_BACK_PX_H
end
end

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
-- GRAVEYARD LISTS
-- A button per player; clicking it drops down the cards in that graveyard, most
-- recent first. Hovering one shows it in the docked preview. Opponent's: beside
-- their deck, opening downwards. Yours: in the bottom bar, opening upwards.
-- (In a block of its own, so its locals don't count towards the file's.)
-- =========================================================================
do
    local GRAVE_BTN_W  = 120
    local GRAVE_LIST_W = 210
    local GRAVE_ROW_H  = 18
    local GRAVE_ROWS   = 16   -- rows shown at once; the mouse wheel scrolls the rest

    local function GraveyardCards(isRemote)
        local st = isRemote and TTS.Engine.remoteState or TTS.Engine.localState
        return st.graveyard or {}
    end

    local function GraveRow_OnEnter(self)
        local card = self.cardId and TTS.Cards[self.cardId]
        if card and ShowBoardPreview then ShowBoardPreview(self, card, self.isFoil) end
    end

    local function GraveRow_OnLeave(self)
        if HideBoardPreview then HideBoardPreview(self) end
    end

    local function GraveyardRow(list, r)
        local row = list.rows[r]
        if row then return row end
        row = CreateFrame("Button", nil, list)
        row:SetSize(GRAVE_LIST_W - 12, GRAVE_ROW_H)
        row:SetPoint("TOPLEFT", list, "TOPLEFT", 6, -6 - (r - 1) * GRAVE_ROW_H)
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        row.ttsSilent = true
        row.cost = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.cost:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        row.cost:SetJustifyH("RIGHT")
        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.text:SetPoint("LEFT", row, "LEFT", 4, 0)
        row.text:SetPoint("RIGHT", row.cost, "LEFT", -4, 0)
        row.text:SetJustifyH("LEFT")
        row.text:SetWordWrap(false)
        row:SetScript("OnEnter", GraveRow_OnEnter)
        row:SetScript("OnLeave", GraveRow_OnLeave)
        row:SetScript("OnClick", function(self) TTS:TryLinkCard(self.cardId, self.isFoil) end)   -- shift-click links it
        row:SetScript("OnHide", GraveRow_OnLeave)
        list.rows[r] = row
        return row
    end

    local graveButtons = {}

    -- Fills an open list from its graveyard (offset: rows scrolled past)
    local function FillGraveyardList(list)
        local cards = GraveyardCards(list.isRemote)
        local n = #cards
        local shown = math.min(n, GRAVE_ROWS)
        list.offset = math.max(0, math.min(list.offset or 0, n - shown))
        for r = 1, shown do
            local cardId = cards[n - list.offset - r + 1]
            local card = TTS.Cards[cardId]
            local row = GraveyardRow(list, r)
            row.cardId = cardId
            row.isFoil = TTS.Engine:IsFoil(cardId, list.isRemote)
            row.text:SetText(card and TTS:CardName(card) or tostring(cardId))
            row.cost:SetText((card and card.cost and card.cost ~= "") and TTS:FormatCost(card.cost, 12) or "")
            row:Show()
        end
        for r = shown + 1, #list.rows do list.rows[r]:Hide() end
        list.empty:SetShown(n == 0)
        list.more:SetShown(n > shown)
        if n > shown then
            list.more:SetText(L("board.graveyardRange", list.offset + 1, list.offset + shown, n))
        end
        list:SetHeight(12 + math.max(1, shown) * GRAVE_ROW_H + (n > shown and 14 or 0))
    end

    local function CreateGraveyardButton(isRemote)
        local btn = CreateFrame("Button", nil, B, "UIPanelButtonTemplate")
        btn:SetSize(GRAVE_BTN_W, 22)
        StyleButton(btn)

        local list = CreateFrame("Frame", nil, btn, backdropTemplate)
        list:SetFrameStrata("DIALOG")
        list:SetWidth(GRAVE_LIST_W)
        list:SetClampedToScreen(true)
        Skin(list, "panel", { 0.04, 0.04, 0.04, 0.95 }, STYLE.panelBorder)
        list:EnableMouse(true)
        list:EnableMouseWheel(true)
        list.isRemote = isRemote
        list.rows = {}
        if isRemote then
            list:SetPoint("TOPRIGHT", btn, "BOTTOMRIGHT", 0, -2)
        else
            list:SetPoint("BOTTOMRIGHT", btn, "TOPRIGHT", 0, 2)
        end
        list.empty = list:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        list.empty:SetPoint("LEFT", list, "LEFT", 10, 0)
        Loc:Bind(list.empty, "board.graveyardEmpty")
        list.more = list:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        list.more:SetPoint("BOTTOM", list, "BOTTOM", 0, 6)
        list:SetScript("OnMouseWheel", function(self, delta)
            self.offset = (self.offset or 0) - delta * 3
            FillGraveyardList(self)
        end)
        list:Hide()
        btn.list = list

        btn:SetScript("OnClick", function(self)
            TT:Hide(self)
            if list:IsShown() then list:Hide(); return end
            for _, other in ipairs(graveButtons) do other.list:Hide() end
            list.offset = 0
            FillGraveyardList(list)
            list:Show()
        end)
        btn:SetScript("OnEnter", function(self)
            if list:IsShown() then return end
            local title = isRemote and L("board.oppGraveyard", TTS.Engine.opponent or L("side.opponentCap")) or L("board.yourGraveyard")
            TT:ShowText(self, "ANCHOR_TOP", title, L("board.graveyardDesc"))
        end)
        btn:SetScript("OnLeave", function(self) TT:Hide(self) end)
        table.insert(graveButtons, btn)
        return btn
    end

    B.oppGraveBtn = CreateGraveyardButton(true)
    B.oppGraveBtn:SetPoint("RIGHT", oppDeckFrame, "LEFT", -52, 0)   -- clear of the deck count beside the tall pile

    -- Yours sits left of your health
    B.myGraveBtn = CreateGraveyardButton(false)
    B.myGraveBtn:SetPoint("RIGHT", B.myLifeBtn, "LEFT", -8, 0)

    -- Button labels with the counts, and any open list refilled (UpdateDisplay)
    function B:UpdateGraveyards()
        for _, btn in ipairs(graveButtons) do
            btn:SetText(L("board.graveyard", #GraveyardCards(btn.list.isRemote)))
            btn:SetWidth(math.max(GRAVE_BTN_W, btn:GetTextWidth() + 24))
            if btn.list:IsShown() then FillGraveyardList(btn.list) end
        end
    end

    -- Lists close with the board (they would otherwise come back open with the next match)
    B:HookScript("OnHide", function()
        for _, btn in ipairs(graveButtons) do btn.list:Hide() end
    end)
end

-- =========================================================================
-- SHUFFLE
-- A deck being shuffled riffles: the top cards split to either side and fall back in
-- one after another, twice. Both decks at the start of a game, yours again on a
-- mulligan. Turned off with "Animate played cards" in the options.
-- =========================================================================
do
    local SHUFFLE_CARDS   = 8      -- card backs in the animation
    local SHUFFLE_PASS    = 0.5    -- seconds per riffle
    local SHUFFLE_PASSES  = 2
    local SHUFFLE_STAGGER = 0.03   -- each card moves a little after the one under it
    local SHUFFLE_SPREAD  = 0.6    -- how far a card swings out, in deck widths
    local SHUFFLE_TILT    = 0.18   -- radians a card leans as it swings out

    local function CreateShuffleLayer(deck)
        local layer = CreateFrame("Frame", nil, B)
        layer:SetAllPoints(deck)
        layer:SetFrameLevel(deck:GetFrameLevel() + 5)
        layer.cards = {}
        for i = 1, SHUFFLE_CARDS do
            local t = layer:CreateTexture(nil, "ARTWORK", nil, i - 1)   -- higher cards draw on top
            t:SetSize(deck:GetWidth(), deck:GetHeight())
            ApplyBackTexture(t)
            layer.cards[i] = t
        end
        layer:Hide()
        -- The deck itself hides while its cards are riffling
        layer:SetScript("OnShow", function() deck.back:Hide() end)
        layer:SetScript("OnHide", function() deck.back:Show() end)

        layer:SetScript("OnUpdate", function(self, dt)
            self.t = self.t + dt
            if self.t >= SHUFFLE_PASS * SHUFFLE_PASSES then
                self:Hide()
                return
            end
            local w = deck:GetWidth()
            local pass = math.floor(self.t / SHUFFLE_PASS)
            local within = self.t - pass * SHUFFLE_PASS
            local swing = SHUFFLE_PASS - SHUFFLE_STAGGER * (SHUFFLE_CARDS - 1)
            for i, tex in ipairs(self.cards) do
                local u = math.max(0, math.min(1, (within - (i - 1) * SHUFFLE_STAGGER) / swing))
                local out = math.sin(math.pi * u)
                -- Alternate cards go to alternate sides, swapped on the next pass
                local side = ((i + pass) % 2 == 0) and 1 or -1
                tex:ClearAllPoints()
                tex:SetPoint("CENTER", self, "CENTER", side * out * w * SHUFFLE_SPREAD, (i - 1) * 0.6 + out * 4)
                if tex.SetRotation then tex:SetRotation(-side * out * SHUFFLE_TILT) end
            end
        end)
        return layer
    end

    local shuffleLayers = {
        [false] = CreateShuffleLayer(myDeckFrame),
        [true]  = CreateShuffleLayer(oppDeckFrame),
    }

    -- isRemote: that player's deck only (nil: both)
    function B:PlayShuffle(isRemote)
        if TTS.Options and TTS.Options:Get("animateCards") == false then return end
        for side, layer in pairs(shuffleLayers) do
            if isRemote == nil or isRemote == side then
                -- Over the stack's top card, not the deck's corner
                local deck = side and oppDeckFrame or myDeckFrame
                local E = TTS.Engine
                if side then B.SetDeckStack(deck, E:RemoteDeckCount()) else B.SetDeckStack(deck, #E.localState.deck) end
                local x, y = B.DeckTopCardOffset(deck)
                layer:ClearAllPoints()
                layer:SetPoint("TOPLEFT", deck, "TOPLEFT", x, y)
                layer:SetPoint("BOTTOMRIGHT", deck, "BOTTOMRIGHT", x, y)
                layer.t = 0
                layer:Show()
            end
        end
    end

    do
        local E = TTS.Engine
        local origStart = E and E.StartMatch
        if origStart then
            E.StartMatch = function(self, ...)
                local results = { origStart(self, ...) }
                if self.inMatch then B:PlayShuffle() end
                return unpack(results)
            end
        end
        local origMulligan = E and E.Mulligan
        if origMulligan then
            E.Mulligan = function(self, ...)
                local open = self.mulliganOpen
                local results = { origMulligan(self, ...) }
                if open and not self.mulliganOpen then B:PlayShuffle(false) end
                return unpack(results)
            end
        end
    end
end

-- =========================================================================
-- 3D MODEL VISUAL HELPER
-- =========================================================================
-- The card's camera (zoom, distance, position, facing) on its model. The client loads a
-- model a moment after SetDisplayInfo, and a camera set before that can be lost, so it is
-- also re-applied shortly after a creature comes onto the battlefield (ReapplyModelCameras).
LAYOUT.MODEL_SMALL_LIFT = 0.25  -- how far a model rises in its frame as its card gets smaller (x (1/size - 1))

-- The model's height in its frame: the card's own, adjusted for the card's size on screen
-- (the board's scale times the card's own, shrunk to fit a crowded row). Bigger cards sit a
-- little higher; smaller ones rise more and more, as small models otherwise sink out of view.
-- The window's scale is the board's, or f.camScaleRoot's for a card in another window (the Deckbuilder).
local function ModelCamZ(f, cam)
    local z = cam.z or -0.10
    local size = ((f.camScaleRoot or B):GetScale() or 1.0) * (f.baseScale or 1)
    if size >= 1 then
        return z + (size - 1.0) * 0.18
    end
    return z + (1 / math.max(size, 0.05) - 1) * LAYOUT.MODEL_SMALL_LIFT
end

local function ApplyModelCamera(f, card)
    local cam = card.modelCam or {}
    if f.model.SetPortraitZoom then f.model:SetPortraitZoom(cam.zoom or 0.75) end
    f.modelCamScale = cam.camScale or 1.0
    -- (a grown window, SetModelInFront, stands its camera further back)
    if f.model.SetCamDistanceScale then
        f.model:SetCamDistanceScale(f.modelCamScale * (f.modelInFront and f.modelFullCam or 1))
    end

    if f.model.SetPosition then f.model:SetPosition(cam.x or 0, cam.y or 0, ModelCamZ(f, cam)) end
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

-- foil (optional): the card shows as a foil (SetCardFoil); left out, it doesn't
local function SetupCardVisual(f, card, foil)
    SetCardFoil(f, foil, card)
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
        if hero and TTS.CardFX then TTS.CardFX:ModelReset(f) end
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
        if TTS.CardFX then TTS.CardFX:ModelReset(f) end
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
                if f.model.SetPosition then
                    f.model:SetPosition(cam.x or 0, cam.y or 0, ModelCamZ(f, cam))
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
TIMING.MODEL_SETTLE_DELAY = 0.05
TIMING.MODEL_LANDED_DELAY = 0.8    -- well after a played card's 0.3 s flight (TIMING.FLY_TIME), once the model has settled
local function ScheduleModelCameraFix()
    if B.cameraFixPending then return end
    B.cameraFixPending = true
    TTS:SafeAfter(TIMING.MODEL_SETTLE_DELAY, function()
        B.cameraFixPending = nil
        ReapplyModelCameras()
    end)
    TTS:SafeAfter(TIMING.MODEL_LANDED_DELAY, ReapplyModelCameras)
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
    local f = CreateCardFrame(B, LAYOUT.PREVIEW_W, LAYOUT.PREVIEW_H)
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel((B:GetFrameLevel() or 10) + 40)
    f:SetClampedToScreen(true)
    f:EnableMouse(false)
    f:SetScript("OnEnter", nil)
    f:SetScript("OnLeave", nil)
    boardPreview = f
    return f
end

-- Paints a full-size preview card (a CreateCardFrame of LAYOUT.PREVIEW_W x LAYOUT.PREVIEW_H) and shows it.
-- foil (optional): shown as a foil.
local function PaintPreviewCard(f, card, foil)
    f.visualCard = nil   -- a preview always loads its model afresh (e.g. a card's model was changed)
    SetupCardVisual(f, card, foil)
    ApplyFrameTexture(f.border, card)
    f.border:SetVertexColor(1, 1, 1)
    TintArt(f.art, card)
    f.title:SetText(TTS:CardName(card) or "")

    if card.cost and card.cost ~= "" then
        f.cost:SetText(TTS:FormatCost(card.cost, 18))
        f.cost:Show()
    else
        f.cost:Hide()
    end

    TTS.ShowPrintedStats(f, card)

    f:Show()
    UpdateCardRules(f, PREVIEW_RULES)
end

ShowBoardPreview = function(owner, card, foil)
    local f = EnsureBoardPreview()
    previewOwner = owner

    -- Card name and cost sit above the frame, so leave room for them
    f:ClearAllPoints()
    f:SetPoint("TOPRIGHT", B, "TOPLEFT", -12, -76)
    -- A denizen on the battlefield previews with the keywords it has gained and lost
    f.perm = owner and owner.fieldIndex and owner.perm or nil
    f.isRemote = f.perm and owner.isRemote or nil
    PaintPreviewCard(f, card, foil)
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
TIMING.LEAVE_TIME = 1.0
TIMING.DIED_LEAVE_TIME = 1.6   -- a death, with card effects on: its death animation plays out first
local LEAVE_COLORS = { died = { 1.0, 0.2, 0.2 }, returned = { 0.3, 0.55, 1.0 } }
local LEAVE_SKULL = "Interface\\AddOns\\ForeverCCG\\Textures\\Symbols\\Skull.png"

local leaving = { [false] = {}, [true] = {} }     -- side -> { { perm, kind, untilT, slot } }
local lastShown = { [false] = {}, [true] = {} }   -- side -> perms in the order they were drawn
local lastField = {}                               -- side -> the field table last drawn (new match = new table)
local leavingPerms = setmetatable({}, { __mode = "k" })
local diedPerms = setmetatable({}, { __mode = "k" })

-- How dark a creature is drawn: tapped 0.4, summoning-sick in your attack step this
TIMING.SICK_SHADE = 0.7
-- 3D models ignore vertex colour, so they fade instead (less, or they vanish into the card)
local function ModelAlpha(shade) return 0.25 + 0.75 * shade end

-- =========================================================================
-- PLAY ANIMATIONS
-- A card that comes onto the battlefield out of a hand flies to its slot from where
-- it was: the card in your hand (or where a drag dropped it), or the opponent's hand row.
-- Turned off with "Animate played cards" in the options.
-- =========================================================================
TIMING.FLY_TIME = 0.3

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
                if perm.spawned then
                    -- Made by an encounter rule (SoloEncounters.lua): fades in where it is, as
                    -- a token does, even when it was taken from the opponent's hand
                elseif not isRemote and (before[perm.id] or 0) > (now[perm.id] or 0) then
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
                if card and (card.isToken or perm.spawned) and not perm.spawnShown then
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
TIMING.SPAWN_DELAY = 0.45     -- seconds before the first token of a group shows
TIMING.SPAWN_STAGGER = 0.15   -- between tokens made together
TIMING.SPAWN_FADE = 0.35      -- fade-in
local spawns = setmetatable({}, { __mode = "k" })   -- perm -> { t = seconds since made, at = when it shows }
local groupUntil = 0          -- tokens made before this joins the current group
local groupNext = 0           -- when the next token in the group shows

function B.StartSpawn(perm, animate)
    if not animate then
        if TTS.Sound then TTS.Sound:PlayTokenSound(perm.id) end
        return
    end
    local now = GetTime()
    if now > groupUntil then groupNext = TIMING.SPAWN_DELAY end
    groupUntil = now + 0.05
    spawns[perm] = { t = 0, at = groupNext, sound = (groupNext == TIMING.SPAWN_DELAY), id = perm.id }
    groupNext = groupNext + TIMING.SPAWN_STAGGER
end

-- Sets each spawning token's card alpha; cards no longer spawning are reset. Models ignore
-- their parent's alpha (as in MobTooltip.lua), so the model's own alpha fades with the card,
-- on top of its tapped / summoning-sick shade (f.modelAlpha, set by the redraw).
local function ApplySpawns()
    for _, group in ipairs({ myLandFrames, myNonLandFrames, oppLandFrames, oppNonLandFrames }) do
        for _, f in ipairs(group) do
            local sp = f:IsShown() and f.perm and spawns[f.perm]
            if sp then
                local a = math.max(0, math.min(1, (sp.t - sp.at) / TIMING.SPAWN_FADE))   -- 0 while still waiting
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
        if sp.t >= sp.at + TIMING.SPAWN_FADE then spawns[perm] = nil end
    end
    ApplySpawns()
end)

-- =========================================================================
-- REORDER SLIDES
-- A card already on a row (or in your hand) whose slot moves, because a card came, left or
-- the row was re-centred, slides to its new slot along a small arc instead of jumping:
-- up when it moves right, down when it moves left, so cards swapping places pass each other.
-- Keyed by frame and worked out again on every redraw, from where each card is drawn then.
-- =========================================================================
TIMING.SLIDE_TIME = 0.25
TIMING.HAND_SLIDE_DELAY = 0.12   -- the hand moves just after the battlefield, not in step with it
TIMING.SLIDE_STAGGER = 0.035     -- between cards of a row, in the order they move
LAYOUT.SLIDE_ARC = 10            -- the hand arcs the other way (see StartSlides)

local slides = setmetatable({}, { __mode = "k" })   -- frame -> { x, y, t, dir }: start, in board coordinates
local oldField = setmetatable({}, { __mode = "k" }) -- perm -> { x, y } where it was drawn before the redraw
local FIELD_GROUPS = { myLandFrames, myNonLandFrames, oppLandFrames, oppNonLandFrames }

-- Before a redraw: where each permanent is drawn (mid-slide included, so a slide that is
-- interrupted carries on from where the card is)
function B.RememberField()
    wipe(oldField)
    for _, group in ipairs(FIELD_GROUPS) do
        for _, f in ipairs(group) do
            if f:IsShown() and f.perm then
                local x, y = BoardXY(f)
                if x then oldField[f.perm] = { x = x, y = y } end
            end
        end
    end
end

local function SlideFrom(f, old)
    local sx, sy = f.slot:GetCenter()
    local left, bottom = B:GetLeft(), B:GetBottom()
    if not (old and sx and left) then return nil end
    sx, sy = sx - left, sy - bottom
    if math.abs(old.x - sx) < 1 and math.abs(old.y - sy) < 1 then return nil end
    return { x = old.x, y = old.y, t = 0, dir = (sx >= old.x) and 1 or -1, newX = sx }
end

-- Each row's cards set off one after another, the one furthest along the way they move
-- first (so cards closing a gap go in turn, nearest the gap first). Cards moving left and
-- cards moving right are staggered on their own, so both sides of a gap start together.
-- start: the row's delay
local function Stagger(frames, start)
    for _, dir in ipairs({ 1, -1 }) do
        local list = {}
        for _, f in ipairs(frames) do
            if slides[f] and slides[f].dir == dir then list[#list + 1] = slides[f] end
        end
        table.sort(list, function(a, b) return a.newX * dir > b.newX * dir end)
        for i, sl in ipairs(list) do sl.t = -(start + (i - 1) * TIMING.SLIDE_STAGGER) end
    end
end

-- After a redraw: a slide for each card whose slot moved. Hand cards are matched to where
-- the same card was drawn before, in order (copies of a card keep their order)
function B.StartSlides(E)
    wipe(slides)
    if TTS.Options and TTS.Options:Get("animateCards") == false then return end
    for _, group in ipairs(FIELD_GROUPS) do
        for _, f in ipairs(group) do
            local fl = f:IsShown() and f.perm and flights[f.perm]
            if fl then
                -- Still flying in from the hand and its slot moved (the row re-centred): aim
                -- the rest of the flight from where the card is drawn now, so it doesn't skip
                local old, sx, sy = oldField[f.perm], f.slot:GetCenter()
                local left, bottom = B:GetLeft(), B:GetBottom()
                local rest = (1 - math.min(1, fl.t / TIMING.FLY_TIME)) ^ 3
                if old and sx and left and rest > 0.01 then
                    sx, sy = sx - left, sy - bottom
                    fl.x = (old.x - (1 - rest) * sx) / rest
                    fl.y = (old.y - (1 - rest) * sy) / rest
                end
            elseif f:IsShown() and f.perm then
                slides[f] = SlideFrom(f, oldField[f.perm])
            end
        end
    end
    local used = {}
    for i = 1, 10 do
        local f = myHandFrames[i]
        local id = E.localState.hand[i]
        if f:IsShown() and id then
            for k, h in ipairs(oldHand) do
                if not used[k] and h.id == id then
                    used[k] = true
                    slides[f] = SlideFrom(f, h)
                    break
                end
            end
        end
    end
    for _, group in ipairs(FIELD_GROUPS) do Stagger(group, 0) end
    -- The hand waits a moment at its old spot first, then arcs the other way
    Stagger(myHandFrames, TIMING.HAND_SLIDE_DELAY)
    for i = 1, 10 do
        local sl = slides[myHandFrames[i]]
        if sl then sl.arc = -1 end
    end
end

-- Offsets each flying or sliding card from its slot by what is left of its move
local function ApplyFlights()
    local left, bottom = B:GetLeft(), B:GetBottom()
    for _, group in ipairs({ myLandFrames, myNonLandFrames, oppLandFrames, oppNonLandFrames, myHandFrames }) do
        for _, f in ipairs(group) do
            local fl = f:IsShown() and f.perm and flights[f.perm]
            local sl = f:IsShown() and slides[f]
            local dx, dy = 0, 0
            local sx, sy = f.slot:GetCenter()   -- the slot is unscaled: already in board coordinates
            if fl and sx and left then
                local rest = (1 - math.min(1, fl.t / TIMING.FLY_TIME)) ^ 3   -- ease out
                local s = f:GetScale()
                dx = (fl.x - (sx - left)) * rest / s
                dy = (fl.y - (sy - bottom)) * rest / s
            elseif sl and sx and left then
                local p = math.max(0, math.min(1, sl.t / TIMING.SLIDE_TIME))
                local eased = (p < 0.5) and (4 * p ^ 3) or (1 - (2 - 2 * p) ^ 3 / 2)   -- ease in-out
                local s = f:GetScale()
                dx = (sl.x - (sx - left)) * (1 - eased) / s
                dy = ((sl.y - (sy - bottom)) * (1 - eased) + math.sin(math.pi * p) * LAYOUT.SLIDE_ARC * sl.dir * (sl.arc or 1)) / s
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
    if not next(flights) and not next(slides) then return end
    for perm, fl in pairs(flights) do
        fl.t = fl.t + dt
        if fl.t >= TIMING.FLY_TIME then flights[perm] = nil end
    end
    for f, sl in pairs(slides) do
        sl.t = sl.t + dt
        if sl.t >= TIMING.SLIDE_TIME then slides[f] = nil end
    end
    ApplyFlights()
end)

-- A card still flying in, sliding to a new slot or spawning (CardFX.lua waits for it to settle)
function B.IsMoving(f)
    return (f.perm and flights[f.perm] or slides[f] or f.spawning) and true or false
end

-- Any card on the board still flying in, sliding or spawning
function B.AnyMoving()
    return (next(flights) or next(slides) or next(spawns)) and true or false
end

-- =========================================================================
-- DRAW ANIMATIONS
-- A card drawn from a library flies from the deck to its place in the hand. Yours turns
-- over on the way: a stand-in card shows its back while it turns away and its face as it
-- turns back, then the hand card itself takes its place. The opponent's stays a card back.
-- Draws are counted off the deck getting smaller, so a card returned to a hand (or put
-- back by an undo) never flies. Cards drawn together leave the deck one after another.
-- Turned off with "Animate played cards" too.
-- =========================================================================
TIMING.DRAW_TIME = 0.45
TIMING.DRAW_STAGGER = 0.12

do   -- its own block: the file is at Lua's 200 locals

local draws = setmetatable({}, { __mode = "k" })      -- your hand frame -> { t, cardId, proxy } (t < 0 while it waits its turn)
local oppDraws = setmetatable({}, { __mode = "k" })   -- opponent's hand frame -> { t, x } (x: its usual left offset)
local lastDeck, lastOppHand, lastDrawState = {}, 0, nil   -- lastDrawState: the match's deck table (new each match)
local proxyPool = {}

local function GetProxy()
    local p = table.remove(proxyPool)
    if p then
        p.faceShown = nil
        return p
    end
    p = CreateFrame("Frame", nil, B)
    p:SetFrameLevel((B:GetFrameLevel() or 10) + 30)   -- over the hand, under the card preview
    p.bg = p:CreateTexture(nil, "BACKGROUND")
    p.bg:SetAllPoints(p)
    p.bg:SetColorTexture(0.08, 0.08, 0.08, 0.95)
    p.art = p:CreateTexture(nil, "ARTWORK")
    p.border = p:CreateTexture(nil, "OVERLAY")
    p.border:SetAllPoints(p)
    p.back = p:CreateTexture(nil, "OVERLAY", nil, 1)
    p.back:SetAllPoints(p)
    ApplyBackTexture(p.back)
    return p
end

local function EndDraw(f, d)
    if d.proxy then
        d.proxy:Hide()
        table.insert(proxyPool, d.proxy)
    end
    f:SetAlpha(1)
    if f.model then f.model:SetAlpha(f.modelAlpha or 1) end
end

local function EndOppDraw(f, d)
    f:SetAlpha(1)
    f:ClearAllPoints()
    f:SetPoint("TOPLEFT", d.x, -46)
end

-- After a redraw: a draw for each card that came out of a deck since the last one
function B.StartDraws(E)
    local animate = not TTS.Options or TTS.Options:Get("animateCards") ~= false
    local deckNow, oppDeckNow = #E.localState.deck, E:RemoteDeckCount()
    local oppHandNow = math.min(10, E.remoteState.handCount or 0)
    local fresh = lastDrawState ~= E.localState.deck   -- a new match: nothing to compare with yet
    local myDrawn = (not fresh and lastDeck[false]) and (lastDeck[false] - deckNow) or 0
    -- The opening hand is drawn too (not a board reopened later in the game), and a mulligan's
    local opening = (fresh and (E.turn or 1) <= 1) or E.handRedrawn
    E.handRedrawn = nil
    if opening then myDrawn = #E.localState.hand end
    local oppDrawn
    if fresh then
        oppDrawn = 0
    elseif type(oppDeckNow) == "number" and lastDeck[true] then
        oppDrawn = lastDeck[true] - oppDeckNow
    else
        oppDrawn = oppHandNow - lastOppHand   -- deck size unknown: count the hand growing
    end
    lastDrawState, lastDeck[false], lastDeck[true], lastOppHand = E.localState.deck, deckNow, tonumber(oppDeckNow), oppHandNow

    -- A draw still under way carries on while its frame holds the same card (in the same
    -- match: one cut short by the board closing never finishes)
    for f, d in pairs(draws) do
        if fresh or not f:IsShown() or f.cardId ~= d.cardId then
            EndDraw(f, d)
            draws[f] = nil
        end
    end
    for f, d in pairs(oppDraws) do
        if fresh or not f:IsShown() then
            EndOppDraw(f, d)
            oppDraws[f] = nil
        end
    end
    if not animate then return end

    -- Your new cards: those not in the hand before the redraw (matched in order, as the
    -- slides are), the last ones being the cards drawn
    local used, new = {}, {}
    for i = 1, 10 do
        local f, id = myHandFrames[i], E.localState.hand[i]
        if f:IsShown() and id then
            local found
            for k, h in ipairs(opening and {} or oldHand) do
                if not used[k] and h.id == id then
                    used[k], found = true, true
                    break
                end
            end
            if not found and not draws[f] then table.insert(new, f) end
        end
    end
    local first = math.max(1, #new - myDrawn + 1)
    for k = first, #new do
        local f = new[k]
        draws[f] = { t = -(k - first) * TIMING.DRAW_STAGGER, cardId = f.cardId, card = TTS.Cards[f.cardId], proxy = GetProxy() }
    end

    -- The opponent's: the last card backs in their row
    oppDrawn = math.min(oppDrawn, oppHandNow)
    for k = 1, oppDrawn do
        local i = oppHandNow - oppDrawn + k
        local f = oppHandFrames[i]
        if not oppDraws[f] then oppDraws[f] = { t = -(k - 1) * TIMING.DRAW_STAGGER, x = 35 + (i - 1) * 64 } end
    end
end

-- Moves each drawn card along its way from the deck
local function ApplyDraws()
    local left, bottom = B:GetLeft(), B:GetBottom()
    if not left then return end
    local dx0, dy0 = BoardXY(myDeckFrame)
    for f, d in pairs(draws) do
        f:SetAlpha(0)
        if f.model then f.model:SetAlpha(0) end
        local p, proxy = math.max(0, math.min(1, d.t / TIMING.DRAW_TIME)), d.proxy
        local sx, sy = f.slot:GetCenter()
        if d.t < 0 or not (sx and dx0) then
            proxy:Hide()
        else
            local e = 1 - (1 - p) ^ 3   -- ease out
            local s = f:GetScale()
            local w = LAYOUT.HAND_W + (LAYOUT.HAND_W * s - LAYOUT.HAND_W) * e
            local h = LAYOUT.HAND_H + (LAYOUT.HAND_H * s - LAYOUT.HAND_H) * e
            local turn = math.abs(math.cos(math.pi * p))   -- edge-on half way, as it turns over
            local face = p >= 0.5
            if face and not proxy.faceShown then
                ApplyFrameTexture(proxy.border, d.card)
                proxy.art:SetTexture(d.card and d.card.art)
                proxy.art:SetShown(d.card and d.card.art and true or false)
            end
            proxy.faceShown = face
            proxy.back:SetShown(not face)
            proxy.border:SetShown(face)
            proxy.art:SetShown(face and d.card and d.card.art and true or false)
            w = math.max(1, w * turn)
            proxy:SetSize(w, h)
            proxy.art:ClearAllPoints()
            proxy.art:SetPoint("TOPLEFT", proxy, "TOPLEFT", w * ART_BOX.left, -h * ART_BOX.top)
            proxy.art:SetPoint("BOTTOMRIGHT", proxy, "BOTTOMRIGHT", -w * ART_BOX.right, h * ART_BOX.bottom)
            proxy:ClearAllPoints()
            proxy:SetPoint("CENTER", B, "BOTTOMLEFT", dx0 + (sx - left - dx0) * e, dy0 + (sy - bottom - dy0) * e)
            proxy:Show()
        end
    end
    local ox, oy = BoardXY(oppDeckFrame)
    for f, d in pairs(oppDraws) do
        f:SetAlpha(d.t < 0 and 0 or 1)
        if ox then
            local rest = (1 - math.max(0, math.min(1, d.t / TIMING.DRAW_TIME))) ^ 3
            -- The card back's centre, at its usual place
            local cx, cy = d.x + 26, B:GetHeight() - 46 - 35
            f:ClearAllPoints()
            f:SetPoint("TOPLEFT", d.x + (ox - cx) * rest, -46 + (oy - cy) * rest)
        end
    end
end

local drawTicker = CreateFrame("Frame", nil, B)
drawTicker:SetScript("OnUpdate", function(_, dt)
    if not next(draws) and not next(oppDraws) then return end
    ApplyDraws()
    -- Each card makes its sound as it lands in the hand (Sound.lua's "draw")
    local function Landed()
        if TTS.Sound then TTS.Sound:PlayUI("draw") end
    end
    for f, d in pairs(draws) do
        d.t = d.t + dt
        if d.t >= TIMING.DRAW_TIME then
            Landed()
            EndDraw(f, d)
            draws[f] = nil
        end
    end
    for f, d in pairs(oppDraws) do
        d.t = d.t + dt
        if d.t >= TIMING.DRAW_TIME then
            Landed()
            EndOppDraw(f, d)
            oppDraws[f] = nil
        end
    end
end)
B.ApplyDraws = ApplyDraws
end

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
        table.insert(pendingFloats, { f, "-" .. shown, "FLOAT_DAMAGE", perm, shown })
    else
        table.insert(pendingFloats, { f, "+" .. (prev - dmg), "FLOAT_HEAL" })
    end
end

local function EmitFloats()
    if TTS.FloatText then
        for _, p in ipairs(pendingFloats) do
            -- Damage flies in from whatever dealt it (TargetFX.lua)
            if p[4] and TTS.FlyCreatureDamage then
                TTS.FlyCreatureDamage(p[1], p[5], p[4])
            else
                TTS.FloatText(p[2], TTS[p[3]], p[1])
            end
        end
    end
    wipe(pendingFloats)
end

local function TrackLife(E, isRemote, plate)
    local life = (isRemote and E.remoteState or E.localState).life
    local prev = lastLife[isRemote]
    lastLife[isRemote] = life
    if prev and life > prev and TTS.FloatText then
        -- A drain flies from the other player's plate instead (TargetFX.lua)
        if not (TTS.FlyLifeGain and TTS.FlyLifeGain(isRemote, life - prev)) then
            TTS.FloatText("+" .. (life - prev), TTS.FLOAT_HEAL, plate, true)
        end
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
            local kind = diedPerms[p] and "died" or "returned"
            -- With card effects on, a death stays long enough for its animation (CardFX.lua)
            local stay = (kind == "died" and TTS.CardFX and TTS.CardFX:Enabled()) and TIMING.DIED_LEAVE_TIME or TIMING.LEAVE_TIME
            table.insert(leaving[isRemote], { perm = p, kind = kind, untilT = now + stay, slot = slot })
            TTS:SafeAfter(stay + 0.05, function() E:RefreshUI() end)
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
    B.RememberField()
    concedeBtn:Enable()

    B.oppLifeText:SetText(L("board.oppLife", E.opponent or L("side.opponentCap"), E.remoteState.life))
    -- The plate grows to fit a long "Firstname Surname" (the rules / score text follows it)
    B.oppLifeBtn:SetWidth(math.max(B.oppLifeBtn.minWidth, B.oppLifeText:GetStringWidth() + 18))
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
    -- Health bars: full is 20, or a solo encounter's own starting life for the opponent
    local oppFull = (E.isSolo and E.encounter and E.encounter.life) or 20
    B.SetLifeBar(B.myLifeBtn, E.localState.life, 20)
    B.SetLifeBar(B.oppLifeBtn, E.remoteState.life, oppFull)
    UpdateEffectBar(B.oppEffectBar, E:GetPlayerEffects(true))
    UpdateEffectBar(B.myEffectBar, E:GetPlayerEffects(false))

    local m = E.localState.mana
    for _, key in ipairs(MANA_ORDER) do
        local slot = B.manaSlots[key]
        slot.text:SetText(string.format("%s |cFFFFFFFF%d|r", TTS:FormatSymbols("{" .. key .. "}", 22), m[key] or 0))
        slot:SetWidth(math.max(1, slot.text:GetStringWidth()))
    end

    -- Only the players the targeting can choose light up (PaintPlate)
    PaintPlate(B.oppLifeBtn)
    PaintPlate(B.myLifeBtn)

    -- =====================================================================
    -- PHASE & COMBAT BUTTON STATE
    -- =====================================================================
    -- With attackers declared, End Turn becomes "Commit to Attacks & End Turn"
    -- (E:CommitAttacksAndEndTurn); while our attack waits on blocks or on Resolve, "End Turn
    -- After Combat" (a toggle, see E:ToggleEndAfterCombat); otherwise it's the normal button
    local attackingCombat = E.phase == "COMBAT_BLOCK" and E.blockingState and not E.blockingState.isRemoteAttacking
    local committing = E.isMyTurn and E.phase == "COMBAT_ATTACK" and E.blockingState and #E.blockingState.attackers > 0
    if attackingCombat or committing then
        B.endTurnBtn:SetText(L(committing and "board.btn.attackAndEnd"
            or (E.endAfterCombat and "board.btn.endingAfterCombat" or "board.btn.endAfterCombat")))
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
        -- Until an attacker is declared the turn can still end (or skip on to Main 2); after
        -- that End Turn commits the attack and ends the turn once combat is over
        local hasAttackers = E.blockingState and #E.blockingState.attackers > 0
        B.nextPhaseBtn:SetText(L(hasAttackers and "board.btn.declareBlocks" or "board.btn.toMain2"))
        B.endTurnBtn:Enable()
    elseif not E.isMyTurn or E.phase == "WAITING" or E.phase == E.AI_TURN_PHASE or E.phase == "PREGAME" then
        -- After accepting a challenge, until the challenger has chosen their deck (Network.lua)
        B.nextPhaseBtn:SetText(L(E.awaitingDeckPick and "board.btn.oppPickingDeck" or "board.btn.opponentTurn"))
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
    B.SetDeckStack(myDeckFrame, #E.localState.deck)
    B.SetDeckStack(oppDeckFrame, E:RemoteDeckCount())
    B:UpdateGraveyards()

    local oppCount = math.min(10, E.remoteState.handCount or 0)
    for i = 1, 10 do
        if i <= oppCount then
            ApplyBackTexture(oppHandFrames[i].back)
            oppHandFrames[i]:Show()
        else
            oppHandFrames[i]:Hide()
        end
    end
    oppHandCount:ClearAllPoints()
    if oppCount > 0 then
        oppHandCount:SetPoint("LEFT", oppHandFrames[oppCount], "RIGHT", 8, 0)
    else
        oppHandCount:SetPoint("LEFT", oppHandFrames[1], "LEFT", 0, 0)
    end
    oppHandCount:SetText(E.remoteState.handCount or 0)

    local handScale = FitScale(math.min(10, #E.localState.hand), LAYOUT.HAND_W, LAYOUT.HAND_STEP, LAYOUT.HAND_LEFT, LAYOUT.HAND_RIGHT, LAYOUT.HAND_MAX_SCALE)
    for i = 1, 10 do
        local cardId = E.localState.hand[i]
        if cardId then
            local card = TTS.Cards[cardId]
            local f = myHandFrames[i]
            f.cardId = cardId
            SetupCardVisual(f, card, E:IsFoil(cardId, false))
            ApplyFrameTexture(f.border, card)
            f.title:SetText(TTS:CardName(card))

            if card.cost and card.cost ~= "" then
                f.cost:SetText(TTS:FormatCost(card.cost, 16))
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
            PlaceCard(f, i, handScale, LAYOUT.HAND_LEFT, LAYOUT.HAND_BOTTOM + LAYOUT.HAND_H * handScale / 2, LAYOUT.HAND_W, LAYOUT.HAND_STEP)
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
                f = FieldFrame(myLandFrames, myLandIdx)
            else
                myNonLandIdx = myNonLandIdx + 1
                f = FieldFrame(myNonLandFrames, myNonLandIdx)
            end

            if f then
                f.fieldIndex = i
                f.perm = perm
                f.cardId = perm.id
                SetupCardVisual(f, card, E:IsPermFoil(perm, false))
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
                    shade = TIMING.SICK_SHADE
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
                SetCardFoil(f, f.isFoil, card, shade)
                f.modelAlpha = ModelAlpha(shade)   -- kept for the token fade-in (ApplySpawns)
                f.model:SetAlpha(f.modelInFront and 1 or f.modelAlpha)   -- (an effect playing shows it unshaded)
                if perm.tapped then f.tapIcon:Show() else f.tapIcon:Hide() end
                PaintLeaving(f, leavingKind)
                f.leavingKind = leavingKind   -- read by CardFX.lua (death animation)
                f:Show()
                if card.type == "Creature" then TrackDamage(perm, false, f) end
            end
        end
    end

    local boardResized = false
    local function LayoutRow(frames, count, centerY, maxScale)
        count = math.min(count, #frames)
        local s = FitScale(count, LAYOUT.BF_CARD_W, LAYOUT.BF_STEP_X, LAYOUT.BF_START_X, LAYOUT.BF_RIGHT, maxScale, LAYOUT.BF_MIN_SCALE)
        -- Centre the row so it grows outwards from the middle of the battlefield
        local rowW = ((count - 1) * LAYOUT.BF_STEP_X + LAYOUT.BF_CARD_W) * s
        local left = math.max(LAYOUT.BF_START_X, (LAYOUT.BF_START_X + LAYOUT.BF_RIGHT - rowW) / 2)
        for k = 1, count do
            if PlaceCard(frames[k], k, s, left, centerY, LAYOUT.BF_CARD_W, LAYOUT.BF_STEP_X) then boardResized = true end
            UpdateCardRules(frames[k])
        end
    end
    LayoutRow(myLandFrames, myLandIdx, ROW_Y.myLand, LAYOUT.LAND_MAX_SCALE)
    LayoutRow(myNonLandFrames, myNonLandIdx, ROW_Y.myNonLand, LAYOUT.CREATURE_MAX_SCALE)

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
                f = FieldFrame(oppLandFrames, oppLandIdx)
            else
                oppNonLandIdx = oppNonLandIdx + 1
                f = FieldFrame(oppNonLandFrames, oppNonLandIdx)
            end

            if f then
                f.fieldIndex = i
                f.perm = perm
                f.cardId = perm.id
                SetupCardVisual(f, card, E:IsPermFoil(perm, true))
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
                SetCardFoil(f, f.isFoil, card, shade)
                f.modelAlpha = ModelAlpha(shade)   -- kept for the token fade-in (ApplySpawns)
                f.model:SetAlpha(f.modelInFront and 1 or f.modelAlpha)   -- (an effect playing shows it unshaded)
                if perm.tapped then f.tapIcon:Show() else f.tapIcon:Hide() end
                PaintLeaving(f, leavingKind)
                f.leavingKind = leavingKind   -- read by CardFX.lua (death animation)
                f:Show()
                if card.type == "Creature" then TrackDamage(perm, true, f) end
            end
        end
    end

    LayoutRow(oppLandFrames, oppLandIdx, ROW_Y.oppLand, LAYOUT.LAND_MAX_SCALE)
    LayoutRow(oppNonLandFrames, oppNonLandIdx, ROW_Y.oppNonLand, LAYOUT.CREATURE_MAX_SCALE)
    if boardResized then QueueBoardModelReload() end

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

    B.StartSlides(E)
    B.StartDraws(E)
    StartFlights(E)
    ApplyFlights()
    B.ApplyDraws()
    B.ApplySpawns()
    if TTS.CardFX then TTS.CardFX:SyncBoard() end
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
-- Re-aims a card's model (its window was rescaled, e.g. the Deckbuilder's)
TTS.RefitModelCamera    = function(f)
    if f.currentCard and f.model and f.model:IsShown() then ApplyModelCamera(f, f.currentCard) end
end
TTS.SetCardFoil         = SetCardFoil      -- foil glow on any card made by CreateCardFrame
TTS.FoilColors          = FoilColors       -- a card's foil colours, { { r, g, b }, ... } (card links, tooltips)
TTS.ApplyFrameTexture   = ApplyFrameTexture
TTS.GetCardFrameTexture = GetCardFrameTexture
TTS.CARD_FRAME_DEF      = CARD_FRAME_DEF
TTS.UpdateCardRules     = UpdateCardRules  -- prints rules text on any card made by CreateCardFrame
TTS.FormatPT            = FormatPT         -- P/T with damage shown, used by the card tooltips
TTS.PaintPreviewCard    = PaintPreviewCard -- full-size preview card in the board's design
TTS.PREVIEW_W, TTS.PREVIEW_H = LAYOUT.PREVIEW_W, LAYOUT.PREVIEW_H
B.myHandFrames          = myHandFrames  -- read by TargetFX.lua (targeting arrow source)
-- Read by CardDrag.lua (drag sources and drop targets)
B.oppHandFrames         = oppHandFrames
B.myLandFrames          = myLandFrames
B.myNonLandFrames       = myNonLandFrames
B.oppLandFrames         = oppLandFrames
B.oppNonLandFrames      = oppNonLandFrames
B.QueueModelReload      = QueueModelReload  -- CardFX.lua: a model loads again to drop its spell visuals
B.HAND_W, B.HAND_H      = LAYOUT.HAND_W, LAYOUT.HAND_H
B.HAND_TOP              = LAYOUT.HAND_BOTTOM + LAYOUT.HAND_H * LAYOUT.HAND_MAX_SCALE   -- top of the hand row, in board coordinates
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
        B:SetScale(math.max(LAYOUT.BOARD_MIN_SCALE, math.min(LAYOUT.BOARD_MAX_SCALE, saved)))
    end
end)
