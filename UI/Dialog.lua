--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

-- =========================================================================
-- DIALOG
-- The addon's popups, which work with the controller UI on.
--
-- A StaticPopup shown by an addon is fine normally. With the controller UI on, though,
-- Blizzard's gamepad code (StaticPopupGamepad.lua, FrameControlsManager.lua) runs inside
-- StaticPopup_Show and saves its state while the addon's call is in progress, so that
-- state is tainted. When the popup is clicked or hidden, Blizzard reads it back and its
-- SetPreferredGamepadInteractTarget() is blocked: "ForeverCCG has been blocked from an
-- action only available to the Blizzard UI" (seen in taint.log).
--
-- Edit Mode does the same: a layout update after one of our StaticPopups ran tainted and
-- had its secret aura reads blocked in combat ("Auras cannot be accessed when secret while
-- tainted by 'ForeverCCG'"). So a popup registered here is always the addon's own dialog
-- (below), which no Blizzard code touches.
--
-- TTS.Dialog:Register("TTS_SOMETHING", {
--     -- StaticPopupDialogs' fields; the dialog uses these:
--     text = "%s",                      -- formatted with text1, text2
--     button1 = YES, button2 = NO,      -- button2: optional
--     OnAccept = function(self, data) end,
--     OnCancel = function(self, data, reason) end,   -- reason "clicked" or "timeout"
--     OnShow = function(self) end, OnHide = function(self) end,
--     hideOnEscape = true,              -- false: Escape leaves it up
--     timeout = 0,                      -- seconds until it cancels itself (0: never)
--     showAlert = true,                 -- the alert icon
--     hasEditBox = true, editBoxWidth = 260, maxLetters = 24,   -- self.editBox
--     EditBoxOnEnterPressed = function(editBox, data) end,    -- (default: accept)
--     EditBoxOnEscapePressed = function(editBox, data) end,   -- (default: hide, a cancel)
--     EditBoxOnTextChanged = function(editBox, userInput) end,
--     -- Optional: the chat emote the first button sends ("/e <text>"), or nil for none
--     emote = function(data) return text end,
-- })
-- TTS.Dialog:Popup("TTS_SOMETHING", text1, text2, data)   -- returns the popup frame
-- TTS.Dialog:HidePopup("TTS_SOMETHING"); TTS.Dialog:VisiblePopup("TTS_SOMETHING")
--
-- Up to MAX_SHOWN dialogs are open at once, each under the last (as StaticPopups stack).
-- Showing one whose kind is already open replaces it (its OnHide runs, not its OnCancel).
--
-- An emote from the first button: a chat emote sent by addon code is blocked unless a
-- Blizzard button is behind it, so the first button gets a secure macro button
-- (SecureActionButtonTemplate, "/e <text>") laid over it, which sends it as clicking a
-- macro would. OnAccept asks TTS.Dialog:EmoteSent(self), and sends the emote itself only
-- when that's false (a StaticPopup, or in combat, when the secure button can't be set up).
-- =========================================================================
local D = {}
TTS.Dialog = D

-- OnClick for every window's UIPanelCloseButton. The template's own handler goes through
-- HideUIPanel, which the client blocks for add-on code in combat, so the windows couldn't
-- be closed then; a plain Hide() of an ordinary frame always works.
function TTS.CloseParent(self)
    local parent = self and self:GetParent()
    if parent then parent:Hide() end
end

local WIDTH = 320
local PAD = 16
local BTN_W, BTN_H = 128, 22
local BTN_GAP = 12
local ALERT = 36       -- the alert icon's size
local EDIT_H = 20
local STACK_GAP = 4    -- between stacked dialogs
local MAX_SHOWN = 4

local defs = {}
local pool = {}        -- the dialog frames, made as needed
local showCount = 0    -- for which dialog was shown last

-- Whether the controller UI is on: its action bar is up, or a gamepad is enabled
function D:ControllerUI()
    local bar = _G.GamepadMainActionBarFrame
    if bar and bar.IsShown then
        local ok, shown = pcall(bar.IsShown, bar)
        if ok and shown then return true end
    end
    if C_GamePad and C_GamePad.IsEnabled then
        local ok, on = pcall(C_GamePad.IsEnabled)
        if ok and on then return true end
    end
    return false
end

local function PlayClick()
    if TTS.Sound and TTS.Sound.PlayUI then TTS.Sound:PlayUI("button") end
end

-- Ends a dialog: "accept" or "cancel" runs its handler first (as a StaticPopup does), then
-- it hides. finished stops OnHide treating the hide as a cancel.
local function Finish(f, how, reason)
    local def = f.def
    if not def or f.finished then return end
    f.finished = true
    local data = f.data
    if how == "accept" and def.OnAccept then
        def.OnAccept(f, data)
    elseif how == "cancel" and def.OnCancel then
        def.OnCancel(f, data, reason or "clicked")
    end
    if f.def == def then
        -- (Hidden already: Escape, coming straight back next frame. OnHide won't run again.)
        if f:IsShown() then f:Hide() else f:GetScript("OnHide")(f) end
    end
end

-- The shown dialogs, the first shown first
local function Shown()
    local list = {}
    for _, f in ipairs(pool) do
        if f:IsShown() and f.def then list[#list + 1] = f end
    end
    table.sort(list, function(a, b) return a.shownAt < b.shownAt end)
    return list
end

-- =========================================================================
-- THE EMOTE BUTTON
-- Over the first button of the newest dialog with an emote. Parented to UIParent rather
-- than a dialog, so the dialogs stay ordinary frames (a protected child would stop them
-- being shown or hidden in combat), and a strata above theirs, since a top-level dialog
-- is raised whenever it's shown or clicked and would cover it. It can't be changed in
-- combat, so it is taken down as combat starts (PLAYER_REGEN_DISABLED comes just before
-- the lockdown) and the button under it takes over until combat ends.
-- =========================================================================
local emoteBtn = CreateFrame("Button", "TTS_DialogEmoteButton", UIParent, "SecureActionButtonTemplate,UIPanelButtonTemplate")
emoteBtn:SetSize(BTN_W, BTN_H)
emoteBtn:SetFrameStrata("TOOLTIP")
emoteBtn:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
emoteBtn:SetAttribute("type", "macro")
emoteBtn:Hide()
D.emoteButton = emoteBtn

local emoteFrame       -- the dialog the emote button is over
local emoteSentFrame   -- the dialog being accepted from the emote button, during its OnAccept

local function Disarm()
    if not emoteFrame or InCombatLockdown() then return end
    local f = emoteFrame
    emoteFrame = nil
    emoteBtn:Hide()
    emoteBtn:ClearAllPoints()   -- (no secure button left anchored to a dialog through combat)
    emoteBtn:SetAttribute("macrotext", nil)
    f.button1:SetAlpha(1)
    f.button1:EnableMouse(true)
end

local function Arm(f)
    if InCombatLockdown() then return end
    Disarm()
    local def = f.def
    if not (def and def.emote) then return end
    local ok, line = pcall(def.emote, f.data)
    if not (ok and type(line) == "string" and line ~= "") then return end
    line = line:gsub("[\r\n]+", " ")
    emoteBtn:SetAttribute("macrotext", "/e " .. line)
    emoteBtn:SetText(f.button1:GetText())
    emoteBtn:SetScale(f:GetScale())
    emoteBtn:ClearAllPoints()
    emoteBtn:SetAllPoints(f.button1)
    emoteBtn:Enable()
    emoteBtn:Show()
    emoteBtn:Raise()
    f.button1:SetAlpha(0)
    f.button1:EnableMouse(false)
    emoteFrame = f
end

-- The emote button goes to the newest shown dialog with an emote (if any)
local function ArmNewest()
    if InCombatLockdown() then return end
    local list = Shown()
    for i = #list, 1, -1 do
        local f = list[i]
        if f.def.emote then
            if emoteFrame ~= f then Arm(f) end
            return
        end
    end
    Disarm()
end

local regen = CreateFrame("Frame")
regen:RegisterEvent("PLAYER_REGEN_DISABLED")
regen:RegisterEvent("PLAYER_REGEN_ENABLED")
regen:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then Disarm() else ArmNewest() end
end)

-- Whether the emote button sent this accept's emote already
function D:EmoteSent(frame)
    return frame ~= nil and frame == emoteSentFrame
end

-- Every chat emote the addon sends goes through these. In combat they are skipped: the
-- client may block an emote sent by addon code then, which reports a blocked action.
-- frame: the dialog being accepted, if any (the emote button may have sent it already)
function D:SendEmote(text, frame)
    if not text or text == "" or self:EmoteSent(frame) then return end
    if InCombatLockdown() or not SendChatMessage then return end
    pcall(SendChatMessage, text, "EMOTE")
end

-- A built-in emote token ("CHEER", "THANK", ...), delay seconds from now (checked for
-- combat when it plays)
function D:DoEmote(token, delay)
    if not token then return end
    local function Play()
        if InCombatLockdown() or not DoEmote then return end
        pcall(DoEmote, token)
    end
    if delay and delay > 0 then TTS:SafeAfter(delay, Play) else Play() end
end

-- Whether a frame is one of these dialogs (not a StaticPopup)
function D:IsDialog(frame)
    for _, f in ipairs(pool) do
        if f == frame then return true end
    end
    return false
end

-- Whether action buttons act on the key/button going down (the ActionButtonUseKeyDown option)
local function UseKeyDown()
    local get = (C_CVar and C_CVar.GetCVarBool) or GetCVarBool
    if not get then return false end
    local ok, on = pcall(get, "ActionButtonUseKeyDown")
    return ok and on and true or false
end

-- The secure button has sent "/e ..." by now (its click runs first): the rest is OnAccept's.
-- Registered for both up and down, it acts on the one the client's action buttons use.
emoteBtn:SetScript("PostClick", function(_, _, down)
    if (down and true or false) ~= UseKeyDown() then return end
    local f = emoteFrame
    if not f then return end
    PlayClick()
    emoteSentFrame = f
    Finish(f, "accept")
    emoteSentFrame = nil
end)

-- =========================================================================
-- THE DIALOG FRAMES
-- =========================================================================
local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil

local function OnHide(f)
    local def = f.def
    if def and not f.finished then
        -- Hidden while still open: Escape (or something closing every window)
        if def.hideOnEscape ~= false then
            f.finished = true
            if def.OnCancel then def.OnCancel(f, f.data, "clicked") end
        else
            C_Timer.After(0, function() if f.def == def and not f.finished then f:Show() end end)
            return   -- (straight back next frame, emote button and all)
        end
    end
    f.def, f.which, f.timer = nil, nil, nil
    if f.editBox then f.editBox:ClearFocus() end
    if emoteFrame == f then Disarm() end
    if def and def.OnHide then def.OnHide(f) end
    ArmNewest()
end

local function NewDialog(i)
    local name = "TTS_Dialog" .. i
    local f = CreateFrame("Frame", name, UIParent, backdropTemplate)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    f:SetWidth(WIDTH)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    f:Hide()
    tinsert(UISpecialFrames, name)   -- Escape hides it (a cancel, or straight back)
    f.shownAt = 0

    f.alert = f:CreateTexture(nil, "ARTWORK")
    f.alert:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
    f.alert:SetSize(ALERT, ALERT)
    f.alert:SetPoint("TOPLEFT", f, "TOPLEFT", 24, -PAD - 2)

    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.text:SetJustifyH("CENTER")

    local eb = CreateFrame("EditBox", name .. "EditBox", f, "InputBoxTemplate")
    eb:SetHeight(EDIT_H)
    eb:SetAutoFocus(false)
    eb:SetScript("OnEnterPressed", function(self)
        local def = f.def
        if def and def.EditBoxOnEnterPressed then def.EditBoxOnEnterPressed(self, f.data) else Finish(f, "accept") end
    end)
    eb:SetScript("OnEscapePressed", function(self)
        local def = f.def
        if def and def.EditBoxOnEscapePressed then def.EditBoxOnEscapePressed(self, f.data) else f:Hide() end
    end)
    eb:SetScript("OnTextChanged", function(self, userInput)
        local def = f.def
        if def and def.EditBoxOnTextChanged then def.EditBoxOnTextChanged(self, userInput) end
    end)
    eb:Hide()
    f.editBox, f.EditBox = eb, eb

    local function Button(how)
        local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        b:SetSize(BTN_W, BTN_H)
        b:SetScript("OnClick", function() Finish(f, how) end)
        b:HookScript("PostClick", PlayClick)
        return b
    end
    f.button1, f.button2 = Button("accept"), Button("cancel")

    f:SetScript("OnHide", OnHide)
    return f
end

-- A free dialog frame: one not showing (nil when MAX_SHOWN are up)
local function FreeDialog()
    for _, f in ipairs(pool) do
        if not f:IsShown() and not f.def then return f end
    end
    if #pool >= MAX_SHOWN then return nil end
    local f = NewDialog(#pool + 1)
    pool[#pool + 1] = f
    return f
end

local function Layout(f, def)
    local width = WIDTH
    if def.hasEditBox and def.editBoxWidth then width = math.max(WIDTH, def.editBoxWidth + 60) end
    f:SetWidth(width)

    local alert = def.showAlert and true or false
    f.alert:SetShown(alert)
    local textW = width - 2 * PAD - 8 - (alert and (ALERT + 8) or 0)
    f.text:SetWidth(textW)
    f.text:ClearAllPoints()
    f.text:SetPoint("TOP", f, "TOP", alert and ((ALERT + 8) / 2) or 0, -PAD - 4)

    local h = PAD + 4 + (f.text:GetStringHeight() or 0)
    if alert then h = math.max(h, PAD + 2 + ALERT) end

    local eb = f.editBox
    eb:SetText("")
    if def.hasEditBox then
        eb:SetWidth(def.editBoxWidth or 240)
        eb:SetMaxLetters(def.maxLetters or 0)
        eb:ClearAllPoints()
        eb:SetPoint("TOP", f, "TOP", 0, -h - 10)
        eb:Show()
        h = h + 10 + EDIT_H
    else
        eb:Hide()
    end

    local b1, b2 = f.button1, f.button2
    b1:SetText(def.button1 or ACCEPT or "Accept")
    b1:ClearAllPoints()
    b2:ClearAllPoints()
    if def.button2 then
        b2:SetText(def.button2)
        b1:SetPoint("BOTTOMRIGHT", f, "BOTTOM", -BTN_GAP / 2, PAD)
        b2:SetPoint("BOTTOMLEFT", f, "BOTTOM", BTN_GAP / 2, PAD)
        b2:Show()
    else
        b1:SetPoint("BOTTOM", f, "BOTTOM", 0, PAD)
        b2:Hide()
    end
    f:SetHeight(h + 14 + BTN_H + PAD)
end

-- Under the lowest dialog already up, or where StaticPopups go
local function Place(f)
    f:ClearAllPoints()
    local below
    for _, o in ipairs(Shown()) do
        if o ~= f and (not below or (o:GetBottom() or 0) < (below:GetBottom() or 0)) then below = o end
    end
    if below then
        f:SetPoint("TOP", below, "BOTTOM", 0, -STACK_GAP)
    else
        f:SetPoint("TOP", UIParent, "TOP", 0, -135)
    end
end

-- =========================================================================
-- API
-- =========================================================================
-- def is also put in StaticPopupDialogs, so StaticPopup_Show (and code that changes the
-- def's text or buttons) works on it too
function D:Register(which, def)
    defs[which] = def
    StaticPopupDialogs[which] = def
    return def
end

function D:Get(which)
    return defs[which]
end

function D:Visible(which)
    for _, f in ipairs(pool) do
        if f:IsShown() and f.which == which then return f end
    end
    return nil
end

function D:Hide(which)
    for _, f in ipairs(pool) do
        if f.def and f.which == which then
            f.finished = true   -- just hidden: its OnHide runs, its OnCancel doesn't
            if f:IsShown() then f:Hide() else OnHide(f) end
        end
    end
end

-- The addon's own dialog, whatever the controller UI's state
function D:Show(which, text1, text2, data)
    local def = defs[which]
    if not def then return nil end
    self:Hide(which)   -- one of each kind, as with StaticPopups
    local f = FreeDialog()
    if not f then return nil end

    local body = def.text or ""
    local ok, formatted = pcall(string.format, body, text1 or "", text2 or "")
    f.text:SetText(ok and formatted or body)
    Layout(f, def)

    showCount = showCount + 1
    f.which, f.def, f.data, f.finished, f.shownAt = which, def, data, false, showCount
    f:SetScale(1)
    Place(f)
    f:Show()
    f:Raise()
    if def.OnShow then def.OnShow(f) end

    -- Cancels itself after timeout seconds, as a StaticPopup does
    if def.timeout and def.timeout > 0 then
        local timer = {}
        f.timer = timer
        C_Timer.After(def.timeout, function()
            if f.timer == timer and f.def == def then Finish(f, "cancel", "timeout") end
        end)
    end

    ArmNewest()   -- after OnShow, which may scale the dialog
    return f
end

-- A registered popup: always the addon's own dialog. StaticPopup_Show from addon code
-- taints whatever Blizzard code runs inside it and saves state (the gamepad code above, and
-- seen with Edit Mode too: a later layout update read secret auras "tainted by ForeverCCG"
-- in combat). Only a popup that was never registered falls back to a StaticPopup.
function D:Popup(which, text1, text2, data)
    if defs[which] then
        return self:Show(which, text1, text2, data)
    end
    return StaticPopup_Show(which, text1, text2, data)
end

function D:VisiblePopup(which)
    return self:Visible(which) or (StaticPopup_Visible and StaticPopup_Visible(which)) or nil
end

function D:HidePopup(which)
    self:Hide(which)
    if StaticPopup_Hide then StaticPopup_Hide(which) end
end
