--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- KEY BINDINGS
-- Bindings.xml declares the bindings (none has a key to start with); this file names them,
-- runs them, and makes the Key Bindings window opened from Options. They're the game's own
-- bindings, so they're saved with the player's other keys and also show in the game's Key
-- Bindings under AddOns. One key per action here; a key taken from another action says so.
-- =========================================================================
TTS = TTS or {}
TTS.Keybinds = TTS.Keybinds or {}
local K = TTS.Keybinds
local L = TTS.L
local Loc = TTS.Locale

local function Print(msg) DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD200[TTSE]|r " .. msg) end

-- In order, under their group's heading (label: keybinds.<id>, tooltip: keybinds.<id>.desc)
K.GROUPS = {
    { key = "keybinds.windows", actions = {
        { id = "main",        binding = "FCCG_TOGGLE_MAIN" },
        { id = "guide",       binding = "FCCG_TOGGLE_GUIDE" },
        { id = "deckbuilder", binding = "FCCG_TOGGLE_DECKBUILDER" },
        { id = "rules",       binding = "FCCG_TOGGLE_RULES" },
        { id = "waiting",     binding = "FCCG_TOGGLE_WAITING" },
        { id = "options",     binding = "FCCG_TOGGLE_OPTIONS" },
    } },
    { key = "keybinds.game", actions = {
        { id = "minimize",    binding = "FCCG_BOARD_MINIMIZE" },
        { id = "restore",     binding = "FCCG_BOARD_RESTORE" },
        { id = "boardToggle", binding = "FCCG_BOARD_TOGGLE" },
        { id = "endTurn",     binding = "FCCG_END_TURN" },
        { id = "nextPhase",   binding = "FCCG_NEXT_PHASE" },
        { id = "undo",        binding = "FCCG_UNDO" },
    } },
}

-- The names the game's Key Bindings shows (again once the chosen language has loaded)
local function NameBindings()
    _G.BINDING_HEADER_FCCG = "Forever: CCG"
    for _, g in ipairs(K.GROUPS) do
        for _, a in ipairs(g.actions) do _G["BINDING_NAME_" .. a.binding] = L("keybinds." .. a.id) end
    end
end
NameBindings()
Loc:OnReady(NameBindings)

-- =========================================================================
-- ACTIONS
-- The windows toggle as their slash commands and the minimap button do; the game's keys
-- press the board's own buttons, so they do nothing while those are hidden or greyed out.
-- =========================================================================
local function Toggle(f)
    if f then f:SetShown(not f:IsShown()) end
end

local function InMatch() return TTS.Engine and TTS.Engine.inMatch end

local function PressBoardButton(field)
    local B, btn = TTS.BoardFrame, TTS.BoardFrame and TTS.BoardFrame[field]
    if InMatch() and B:IsShown() and btn and btn:IsVisible() and btn:IsEnabled() then btn:Click() end
end

local RUN = {
    main = function() Toggle(TTS.MainFrame) end,
    guide = function()
        local G = TTS.CollectionGuide
        if not G then return end
        if G.frame and G.frame:IsShown() then G.frame:Hide() else G:Open() end
    end,
    deckbuilder = function()
        local D = TTS.DeckBuilderFrame
        if not D then return end
        if D:IsShown() then D:Hide()
        elseif D.TryOpen and D:TryOpen() and TTS.MainFrame and TTS.MainFrame:IsShown() then TTS.MainFrame:Hide() end
    end,
    rules = function() Toggle(TTS.RulesFrame) end,
    waiting = function() if TTS.ToggleWaitingRoom then TTS.ToggleWaitingRoom() end end,
    options = function() Toggle(TTS.OptionsFrame) end,
    minimize = function()
        local B = TTS.BoardFrame
        if InMatch() and B and B:IsShown() then B:Minimize() end
    end,
    restore = function()
        local B = TTS.BoardFrame
        if InMatch() and B and not B:IsShown() then B:Show() end
    end,
    boardToggle = function()
        local B = TTS.BoardFrame
        if not (InMatch() and B) then return end
        if B:IsShown() then B:Minimize() else B:Show() end
    end,
    endTurn = function() PressBoardButton("endTurnBtn") end,
    nextPhase = function() PressBoardButton("nextPhaseBtn") end,
    undo = function() PressBoardButton("undoBtn") end,
}

function K:Run(id)
    local fn = RUN[id]
    if fn then fn() end
end

-- =========================================================================
-- BINDING
-- =========================================================================
-- What a key shows as ("Not bound" for none)
local function KeyText(key)
    if not key then return "|cFF808080" .. L("keybinds.notBound") .. "|r" end
    return GetBindingText and GetBindingText(key) or key
end

local function Save()
    if SaveBindings and GetCurrentBindingSet then SaveBindings(GetCurrentBindingSet()) end
end

local function ClearAction(binding)
    for _, key in ipairs({ GetBindingKey(binding) }) do SetBinding(key, nil) end
end

-- Puts key on the action alone, taking it from whatever had it
function K:Bind(binding, key)
    if InCombatLockdown() then Print(L("keybinds.combat")); return end
    local prev = GetBindingAction(key)
    ClearAction(binding)
    if SetBinding(key, binding) then
        if prev and prev ~= "" and prev ~= binding then
            Print(L("keybinds.replaced", KeyText(key), _G["BINDING_NAME_" .. prev] or prev))
        end
        Save()
    end
end

function K:Clear(binding)
    if InCombatLockdown() then Print(L("keybinds.combat")); return end
    ClearAction(binding)
    Save()
end

function K:ClearAll()
    if InCombatLockdown() then Print(L("keybinds.combat")); return end
    for _, g in ipairs(self.GROUPS) do
        for _, a in ipairs(g.actions) do ClearAction(a.binding) end
    end
    Save()
end

-- =========================================================================
-- KEY BINDINGS WINDOW
-- A popout beside Options, in its look: each action with a button showing its key. Click a
-- button then press a key (or a mouse's middle or side button) to set it; Escape gives up,
-- right-click clears it.
-- =========================================================================
local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local ROW_H, HEADER_H, TOP, BOTTOM = 24, 22, 44, 84
local MODIFIERS = { LSHIFT = true, RSHIFT = true, LCTRL = true, RCTRL = true, LALT = true, RALT = true,
    LMETA = true, RMETA = true, UNKNOWN = true }
local MOUSE = { MiddleButton = "BUTTON3", Button4 = "BUTTON4", Button5 = "BUTTON5" }

local F = CreateFrame("Frame", "TTS_KeybindFrame", UIParent, backdropTemplate)
K.frame = F
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
F:SetClampedToScreen(true)
F:RegisterForDrag("LeftButton")
F:SetScript("OnDragStart", F.StartMoving)
F:SetScript("OnDragStop", F.StopMovingOrSizing)
F:Hide()
tinsert(UISpecialFrames, "TTS_KeybindFrame")   -- Escape closes it (not while a key is being set)

do
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
    Loc:Bind(title, "keybinds.title")
    local closeBtn = CreateFrame("Button", nil, F, "UIPanelCloseButton")
    closeBtn:SetScript("OnClick", TTS.CloseParent)
    closeBtn:SetPoint("TOPRIGHT", -2, -2)
end

local rows = {}
local capturing   -- the row whose key is being set

local function RefreshRows()
    for _, row in ipairs(rows) do
        if row == capturing then
            row.btn:SetText("|cFFFFD200" .. L("keybinds.pressKey") .. "|r")
        else
            row.btn:SetText(KeyText((GetBindingKey(row.binding))))
        end
    end
end

local function StopCapture()
    capturing = nil
    F:EnableKeyboard(false)
    RefreshRows()
end

local function StartCapture(row)
    if InCombatLockdown() then Print(L("keybinds.combat")); return end
    capturing = row
    F:EnableKeyboard(true)
    if F.SetPropagateKeyboardInput then F:SetPropagateKeyboardInput(false) end
    RefreshRows()
end

local function KeyWithModifiers(key)
    local s = ""
    if IsAltKeyDown() then s = s .. "ALT-" end
    if IsControlKeyDown() then s = s .. "CTRL-" end
    if IsShiftKeyDown() then s = s .. "SHIFT-" end
    if IsMetaKeyDown and IsMetaKeyDown() then s = s .. "META-" end
    return s .. key
end

F:SetScript("OnKeyDown", function(_, key)
    if not capturing then return end
    if MODIFIERS[key] then return end   -- (waits for the key they go with)
    if key == "ESCAPE" then StopCapture(); return end
    local row = capturing
    StopCapture()
    K:Bind(row.binding, KeyWithModifiers(key))
    RefreshRows()
end)

-- The rows, under their group headings
local y = -TOP
for _, g in ipairs(K.GROUPS) do
    local header = F:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header:SetPoint("TOPLEFT", F, "TOPLEFT", 20, y - 4)
    Loc:Bind(header, g.key)
    local line = F:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", F, "TOPLEFT", 18, y - 18)
    line:SetPoint("TOPRIGHT", F, "TOPRIGHT", -18, y - 18)
    line:SetHeight(1)
    line:SetColorTexture(1, 0.82, 0, 0.30)
    y = y - HEADER_H
    for _, a in ipairs(g.actions) do
        local row = { binding = a.binding, id = a.id }
        local label = F:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("TOPLEFT", F, "TOPLEFT", 24, y - 6)
        Loc:Bind(label, "keybinds." .. a.id)

        local btn = CreateFrame("Button", nil, F, "UIPanelButtonTemplate")
        btn:SetSize(130, 22)
        btn:SetPoint("TOPRIGHT", F, "TOPRIGHT", -20, y)
        btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        btn:SetScript("OnClick", function(_, mouse)
            if mouse == "RightButton" then
                if capturing then StopCapture() end
                K:Clear(row.binding)
                RefreshRows()
            elseif capturing == row then
                StopCapture()
            else
                StartCapture(row)
            end
        end)
        -- A mouse's middle and side buttons can be bound by clicking them on the button
        btn:SetScript("OnMouseDown", function(_, mouse)
            if capturing == row and MOUSE[mouse] then
                local key = KeyWithModifiers(MOUSE[mouse])
                StopCapture()
                K:Bind(row.binding, key)
                RefreshRows()
            end
        end)
        btn:SetScript("OnEnter", function(self)
            if TTS.Tooltip then
                TTS.Tooltip:ShowText(self, "ANCHOR_RIGHT", L("keybinds." .. a.id), L("keybinds." .. a.id .. ".desc") .. "\n\n|cFF808080" .. L("keybinds.hint") .. "|r")
            end
        end)
        btn:SetScript("OnLeave", function(self) if TTS.Tooltip then TTS.Tooltip:Hide(self) end end)
        row.btn = btn
        rows[#rows + 1] = row
        y = y - ROW_H
    end
    y = y - 6
end

do
    local note = F:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    note:SetPoint("BOTTOMLEFT", F, "BOTTOMLEFT", 20, 44)
    note:SetPoint("BOTTOMRIGHT", F, "BOTTOMRIGHT", -20, 44)
    note:SetJustifyH("LEFT")
    Loc:Bind(note, "keybinds.note")

    local clearAll = CreateFrame("Button", nil, F, "UIPanelButtonTemplate")
    clearAll:SetSize(110, 22)
    clearAll:SetPoint("BOTTOMLEFT", F, "BOTTOMLEFT", 18, 16)
    Loc:Bind(clearAll, "keybinds.clearAll")
    clearAll:SetScript("OnClick", function()
        if capturing then StopCapture() end
        K:ClearAll()
        RefreshRows()
    end)

    local done = CreateFrame("Button", nil, F, "UIPanelButtonTemplate")
    done:SetSize(90, 22)
    done:SetPoint("BOTTOMRIGHT", F, "BOTTOMRIGHT", -18, 16)
    Loc:Bind(done, "keybinds.done")
    done:SetScript("OnClick", function() F:Hide() end)
end

F:SetSize(330, -y + BOTTOM)

F:SetScript("OnShow", RefreshRows)
F:SetScript("OnHide", function()
    if capturing then StopCapture() end
    if TTS.Tooltip then TTS.Tooltip:Hide() end
end)

-- Opens beside Options (at its size), or closes
function K:Toggle(anchor)
    if F:IsShown() then F:Hide(); return end
    F:ClearAllPoints()
    if anchor and anchor:IsShown() then
        F:SetScale(anchor:GetScale())
        F:SetPoint("TOPLEFT", anchor, "TOPRIGHT", -4, 0)
    else
        F:SetPoint("CENTER")
    end
    F:Show()
end

local events = CreateFrame("Frame")
events:RegisterEvent("UPDATE_BINDINGS")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        if TTS.Sound and TTS.Sound.HookButtons then TTS.Sound:HookButtons(F) end
        -- Closes along with Options
        if TTS.OptionsFrame then TTS.OptionsFrame:HookScript("OnHide", function() F:Hide() end) end
    elseif event == "PLAYER_REGEN_DISABLED" then
        if capturing then StopCapture() end   -- (bindings can't change in combat)
    elseif F:IsShown() then
        RefreshRows()
    end
end)
