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
-- DECK PICKER
-- Shown as a game is about to start: after accepting a challenge, when our
-- challenge is accepted, and for Practice vs Dummy. The picked deck becomes
-- the active deck, which E:StartMatch plays with. Nothing is sent over the
-- network, so builds without the picker play the same as before.
--
--   TTS.DeckPicker:Open({ opponent = name, timeout = seconds or nil,
--                         checks = { { key, label, value }, ... } or nil,
--                         onPick = function(deckIndex, checked) end, onCancel = function() end })
-- With a timeout the selected deck is played when it runs out, and there is no Cancel.
-- checks: tick boxes shown under the decks (label: a string key; value: ticked to start);
-- onPick gets checked = { [key] = true / false }.
-- =========================================================================
local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local GOLD, GREEN, RED = "|cFFFFD200", "|cFF00FF00", "|cFFFF4444"

local P = CreateFrame("Frame", "TTS_DeckPicker", UIParent, backdropTemplate)
TTS.DeckPicker = P

local ROW_H = 28
local CHECK_H = 24          -- each tick box under the decks (Open's checks)
local MAX_CHECKS = 4
local slots = TTS.MAX_DECK_SLOTS or 3
local BASE_H = 126 + slots * ROW_H

P:SetSize(320, BASE_H)
P:SetPoint("CENTER", 0, 60)
P:SetFrameStrata("DIALOG")
P:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
P:EnableMouse(true)
P:SetMovable(true)
P:RegisterForDrag("LeftButton")
P:SetScript("OnDragStart", P.StartMoving)
P:SetScript("OnDragStop", P.StopMovingOrSizing)
P:Hide()

local title = P:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -18)
Loc:Bind(title, "picker.title")

local subtitle = P:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
subtitle:SetPoint("TOP", title, "BOTTOM", 0, -4)

local rows = {}
local selected = nil
local request = nil      -- the options passed to Open
local deadline = nil

local function Refresh()
    for i, row in ipairs(rows) do
        local deck = TTS_SavedDecks and TTS_SavedDecks[i]
        local count = TTS:DeckCardCount(deck)
        local ok = TTS:IsDeckPlayable(deck)
        row.name:SetText((ok and GOLD or "|cFF888888") .. ((deck and deck.name) or "?") .. "|r")
        row.count:SetText(ok and (GREEN .. count .. "|r") or (RED .. L("picker.notPlayable", count) .. "|r"))
        row:SetEnabled(ok)
        row.sel:SetShown(i == selected)
    end
end

for i = 1, slots do
    local row = CreateFrame("Button", nil, P, backdropTemplate)
    row:SetSize(276, ROW_H - 4)
    row:SetPoint("TOP", P, "TOP", 0, -56 - (i - 1) * ROW_H)
    row:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    row:SetBackdropColor(0.04, 0.04, 0.04, 0.8)
    row:SetBackdropBorderColor(0.60, 0.56, 0.48, 1)

    row.sel = row:CreateTexture(nil, "BACKGROUND", nil, 1)
    row.sel:SetPoint("TOPLEFT", 3, -3)
    row.sel:SetPoint("BOTTOMRIGHT", -3, 3)
    row.sel:SetColorTexture(1, 0.82, 0, 0.25)

    local hl = row:CreateTexture(nil, "HIGHLIGHT")
    hl:SetPoint("TOPLEFT", 3, -3)
    hl:SetPoint("BOTTOMRIGHT", -3, 3)
    hl:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    hl:SetBlendMode("ADD")

    row.count = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.count:SetPoint("RIGHT", -10, 0)

    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.name:SetPoint("LEFT", 10, 0)
    row.name:SetPoint("RIGHT", row.count, "LEFT", -6, 0)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)

    row:SetScript("OnClick", function()
        selected = i
        Refresh()
    end)
    row:SetScript("OnDoubleClick", function()
        selected = i
        P:Confirm()
    end)
    rows[i] = row
end

-- Tick boxes under the decks, for the options a game starts with (Open's checks)
local checks = {}
for i = 1, MAX_CHECKS do
    local cb = CreateFrame("CheckButton", nil, P, "UICheckButtonTemplate")
    cb:SetSize(24, 24)
    cb:SetPoint("TOPLEFT", P, "TOPLEFT", 26, -56 - slots * ROW_H - 4 - (i - 1) * CHECK_H)
    cb.label = P:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    cb.label:SetPoint("LEFT", cb, "RIGHT", 2, 1)
    cb:Hide()
    cb.label:Hide()
    checks[i] = cb
end

local function CreateButton(textKey, x)
    local b = CreateFrame("Button", nil, P, "UIPanelButtonTemplate")
    b:SetSize(110, 24)
    b:SetPoint("BOTTOM", P, "BOTTOM", x, 36)
    Loc:Bind(b, textKey)
    return b
end

local playBtn = CreateButton("picker.play", -60)
local cancelBtn = CreateButton("picker.cancel", 60)

local countdown = P:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
countdown:SetPoint("BOTTOM", P, "BOTTOM", 0, 18)

-- Hides the window; returns the request it was showing (nil if none)
local function Finish()
    local req = request
    request, deadline = nil, nil
    P:Hide()
    return req
end

function P:Confirm()
    if not (selected and TTS:IsDeckPlayable(TTS_SavedDecks and TTS_SavedDecks[selected])) then return end
    local checked = {}
    for i, spec in ipairs(request and request.checks or {}) do
        if checks[i] then checked[spec.key] = checks[i]:GetChecked() and true or false end
    end
    local req = Finish()
    if not req then return end
    TTS_ActiveDeckIndex = selected
    if req.onPick then req.onPick(selected, checked) end
end

function P:Cancel()
    local req = Finish()
    if req and req.onCancel then req.onCancel() end
end

-- Closed without a pick or a cancel being sent (the other player is already gone)
function P:Abort()
    Finish()
end

-- The game waiting on a pick is against this player
function P:IsPendingWith(name)
    return request ~= nil and request.opponent ~= nil and name ~= nil
        and request.opponent:lower() == name:lower()
end

function P:IsPending()
    return request ~= nil
end

function P:Open(opts)
    -- One game at a time: a picker still open for another game is cancelled
    if request then self:Cancel() end
    if TTS.EnsureDeckSlots then TTS:EnsureDeckSlots() end

    -- Games can't start with the Deckbuilder open (its edits are already saved)
    if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() then
        TTS.DeckBuilderFrame:Hide()
    end

    -- The active deck if it's playable, otherwise the first one that is
    selected = nil
    if TTS:IsDeckPlayable(TTS_SavedDecks and TTS_SavedDecks[TTS_ActiveDeckIndex]) then
        selected = TTS_ActiveDeckIndex
    else
        for i = 1, slots do
            if TTS:IsDeckPlayable(TTS_SavedDecks and TTS_SavedDecks[i]) then selected = i break end
        end
    end

    request = opts or {}
    deadline = request.timeout and (GetTime() + request.timeout) or nil
    -- A game with a timeout (PvP) can't be backed out of: the selected deck plays when it runs out
    cancelBtn:SetShown(not deadline)
    playBtn:ClearAllPoints()
    playBtn:SetPoint("BOTTOM", P, "BOTTOM", deadline and 0 or -60, 36)
    subtitle:SetText(request.opponent and L("picker.vs", request.opponent) or "")
    countdown:SetText("")
    -- Its tick boxes, the window growing to fit them
    local specs = request.checks or {}
    for i, cb in ipairs(checks) do
        local spec = specs[i]
        cb:SetShown(spec ~= nil)
        cb.label:SetShown(spec ~= nil)
        if spec then
            cb.label:SetText(L(spec.label))
            cb:SetChecked(spec.value and true or false)
            cb:SetHitRectInsets(0, -(cb.label:GetStringWidth() + 4), 0, 0)
        end
    end
    self:SetHeight(BASE_H + math.min(#specs, MAX_CHECKS) * CHECK_H + (#specs > 0 and 4 or 0))
    Refresh()
    self:Show()
    self:Raise()
end

playBtn:SetScript("OnClick", function() P:Confirm() end)
cancelBtn:SetScript("OnClick", function() P:Cancel() end)

local tick = 0
P:SetScript("OnUpdate", function(self, elapsed)
    tick = tick + elapsed
    if tick < 0.2 then return end
    tick = 0
    playBtn:SetEnabled(selected ~= nil and TTS:IsDeckPlayable(TTS_SavedDecks and TTS_SavedDecks[selected]))
    if not deadline then return end
    local left = math.ceil(deadline - GetTime())
    if left <= 0 then
        if playBtn:IsEnabled() then P:Confirm() else P:Cancel() end
        return
    end
    countdown:SetText(L("picker.countdown", left))
end)
