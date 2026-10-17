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
-- CHOICE POPUP
-- Asks the player to pick one of several options: a mana colour, a card from a
-- graveyard, ... Only one choice is open at a time.
--
-- TTS.Choice:Show({
--     title    = "Choose a mana",            -- shown at the top
--     options  = { { value = "W", text = "Holy", icon = <texture> },
--                  { value = "B01", cardId = "B01" }, ... },
--                  -- cardId: the card's name, art and (on hover) its tooltip;
--                  -- disabled = true: shown greyed out, can't be picked
--     anchor   = frame,                      -- shown above it (screen centre if nil)
--     onChoose = function(value, option) end,
--     onCancel = function() end,             -- Escape, right-click, Cancel or another choice
--     required = true,                       -- no Cancel: it stays until answered, and no
--                                            -- other choice opens over it (E:AskChoice)
-- })
-- =========================================================================
local C = {}
TTS.Choice = C

local BTN_W, BTN_H = 120, 40
local ICON = 32
local GAP = 6
local PAD = 16
local MAX_COLUMNS = 5

local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local F = CreateFrame("Frame", "TTS_ChoicePopup", UIParent, backdropTemplate)
C.frame = F
F:SetFrameStrata("FULLSCREEN_DIALOG")
F:SetToplevel(true)
F:SetClampedToScreen(true)
F:EnableMouse(true)
F:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
F:Hide()
tinsert(UISpecialFrames, "TTS_ChoicePopup")   -- Escape closes it (as a cancel)

local title = F:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", F, "TOP", 0, -PAD)

local cancelBtn = CreateFrame("Button", nil, F, "UIPanelButtonTemplate")
cancelBtn:SetSize(100, 22)
cancelBtn:SetPoint("BOTTOM", F, "BOTTOM", 0, PAD - 2)
cancelBtn:SetText(CANCEL or "Cancel")

local current      -- the open choice's spec
local buttons = {}

local function Finish(chosen, option)
    local spec = current
    current = nil
    F:Hide()
    if not spec then return end
    if chosen ~= nil then
        if spec.onChoose then spec.onChoose(chosen, option) end
    elseif spec.onCancel then
        spec.onCancel()
    end
end

-- force: closes a required choice too (the match is over)
function C:Cancel(force)
    if current and current.required and not force then return end
    Finish(nil)
end
function C:IsOpen() return current ~= nil end

cancelBtn:SetScript("OnClick", function() C:Cancel() end)
-- Hidden by Escape (or anything else) while still open: a cancel, or back it comes if required
F:SetScript("OnHide", function()
    if not current then return end
    if current.required then
        local spec = current
        C_Timer.After(0, function() if current == spec then F:Show() end end)
    else
        Finish(nil)
    end
end)

local function OptionButton(i)
    local b = buttons[i]
    if b then return b end
    b = CreateFrame("Button", nil, F, backdropTemplate)
    b:SetSize(BTN_W, BTN_H)
    b:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    b:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    b:SetBackdropBorderColor(0.6, 0.6, 0.6)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetSize(ICON, ICON)
    b.icon:SetPoint("LEFT", b, "LEFT", 4, 0)
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    b.text:SetPoint("LEFT", b.icon, "RIGHT", 6, 0)
    b.text:SetPoint("RIGHT", b, "RIGHT", -4, 0)
    b.text:SetJustifyH("LEFT")
    b.text:SetWordWrap(true)

    b:SetScript("OnClick", function(self, btn)
        if btn == "RightButton" then C:Cancel(); return end
        if self.option and not self.option.disabled then Finish(self.option.value, self.option) end
    end)
    b:SetScript("OnEnter", function(self)
        local o = self.option
        if o and o.cardId and TTS.Tooltip then TTS.Tooltip:ShowCard(self, "ANCHOR_RIGHT", o.cardId, {}) end
    end)
    b:SetScript("OnLeave", function(self) if TTS.Tooltip then TTS.Tooltip:Hide(self) end end)
    buttons[i] = b
    return b
end

-- Opens a choice (an open one is cancelled first). Returns false if there is nothing to
-- pick, or a required choice is waiting (it has to be answered first).
function C:Show(spec)
    local options = spec and spec.options or {}
    if #options == 0 then return false end
    if current and current.required then return false end
    if current then Finish(nil) end
    current = spec
    cancelBtn:SetShown(not spec.required)

    title:SetText(spec.title or "")
    local cols = math.min(#options, MAX_COLUMNS)
    local rows = math.ceil(#options / cols)
    local top = PAD + (spec.title and spec.title ~= "" and 20 or 0)

    for i, o in ipairs(options) do
        local b = OptionButton(i)
        b.option = o
        local card = o.cardId and TTS.Cards and TTS.Cards[o.cardId]
        b.icon:SetTexture(o.icon or (card and card.art) or "Interface\\Icons\\INV_Misc_QuestionMark")
        if TTS.TintArt then TTS.TintArt(b.icon, not o.icon and card or nil) end   -- a card's own art keeps its tint
        b.text:SetText(o.text or (card and TTS:CardName(card)) or tostring(o.value))
        b.icon:SetDesaturated(o.disabled and true or false)
        b.text:SetTextColor(o.disabled and 0.5 or 1, o.disabled and 0.5 or 1, o.disabled and 0.5 or 1)
        local col, row = (i - 1) % cols, math.floor((i - 1) / cols)
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", F, "TOPLEFT", PAD + col * (BTN_W + GAP), -(top + row * (BTN_H + GAP)))
        b:Show()
    end
    for i = #options + 1, #buttons do buttons[i]:Hide(); buttons[i].option = nil end

    F:SetSize(PAD * 2 + cols * BTN_W + (cols - 1) * GAP,
        top + rows * BTN_H + (rows - 1) * GAP + PAD + (spec.required and 0 or GAP * 2 + cancelBtn:GetHeight()))
    F:ClearAllPoints()
    if spec.anchor then
        F:SetPoint("BOTTOM", spec.anchor, "TOP", 0, 8)
    else
        F:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
    end
    F:Show()
    return true
end

-- A dual prayer: which colour to tap it for. onChoose gets the colour ("W", "R", ...).
function C:ChooseMana(colors, anchor, onChoose)
    local options = {}
    for _, col in ipairs(colors) do
        table.insert(options, {
            value = col,
            text = TTS.Tooltip and TTS.Tooltip:Def("symbol", col, "name") or col,
            icon = "Interface\\AddOns\\ForeverCCG\\Textures\\Symbols\\" .. col .. ".png",
        })
    end
    return self:Show({ title = L("choice.mana"), options = options, anchor = anchor, onChoose = onChoose })
end
