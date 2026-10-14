--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

-- =========================================================================
-- SOLO ENCOUNTER SELECT
-- Two tabs (Zones, Dungeons), one row per encounter with its status, the selected
-- encounter's details, and its reward card docked to the left of the window.
-- Same look as the main window and the Deckbuilder.
-- =========================================================================
local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local PANEL_BG     = { 0.04, 0.04, 0.04, 0.70 }
local PANEL_BORDER = { 0.60, 0.56, 0.48, 1 }
local HIGHLIGHT_TEX = "Interface\\QuestFrame\\UI-QuestTitleHighlight"

local GOLD  = "|cFFFFD200"
local GREY  = "|cFF8A8A8A"
local GREEN = "|cFF33DD33"
local RED   = "|cFFFF4444"
local ORANGE = "|cFFFF8040"

local AI_LABEL = { basic = "Basic", tactical = "Tactical", expert = "Expert", dummy = "Dummy" }

local WIN_W, WIN_H = 520, 580
local LIST_H = 300
local ROW_H = 20

local TT = TTS.Tooltip

local S = CreateFrame("Frame", "TTS_SoloSelectFrame", UIParent, backdropTemplate)
TTS.SoloSelectFrame = S
S:SetSize(WIN_W, WIN_H)
S:SetPoint("CENTER")
S:SetClampedToScreen(true)
S:SetFrameStrata("DIALOG")
S:SetToplevel(true)
S:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
S:EnableMouse(true)
S:SetMovable(true)
S:RegisterForDrag("LeftButton")
S:SetScript("OnDragStart", S.StartMoving)
S:SetScript("OnDragStop", S.StopMovingOrSizing)
S:Hide()
tinsert(UISpecialFrames, "TTS_SoloSelectFrame")

local titleBar = S:CreateTexture(nil, "ARTWORK")
titleBar:SetPoint("TOPLEFT", 12, -12)
titleBar:SetPoint("TOPRIGHT", -12, -12)
titleBar:SetHeight(25)
titleBar:SetColorTexture(0, 0, 0, 0.35)

local titleLine = S:CreateTexture(nil, "ARTWORK")
titleLine:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 0)
titleLine:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
titleLine:SetHeight(1)
titleLine:SetColorTexture(1, 0.82, 0, 0.55)

local title = S:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -11)
title:SetText("Solo Encounters")

local closeBtn = CreateFrame("Button", nil, S, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -2, -2)

local footer = S:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
footer:SetPoint("BOTTOMRIGHT", S, "BOTTOMRIGHT", -20, 14)
footer:SetText("Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy")

-- Tooltip-bordered panel with a gold section header and divider
local function CreateSection(label, w, h)
    local p = CreateFrame("Frame", nil, S, backdropTemplate)
    p:SetSize(w, h)
    p:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    p:SetBackdropColor(PANEL_BG[1], PANEL_BG[2], PANEL_BG[3], PANEL_BG[4])
    p:SetBackdropBorderColor(PANEL_BORDER[1], PANEL_BORDER[2], PANEL_BORDER[3], PANEL_BORDER[4])

    p.header = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    p.header:SetPoint("TOPLEFT", 10, -9)
    p.header:SetText(label)

    local line = p:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", 8, -24)
    line:SetPoint("TOPRIGHT", -8, -24)
    line:SetHeight(1)
    line:SetColorTexture(1, 0.82, 0, 0.30)
    return p
end

-- Red panel button with the Deckbuilder's small fonts
local function CreatePanelButton(parent, w, h, text)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(w, h)
    b:SetNormalFontObject("GameFontNormalSmall")
    b:SetHighlightFontObject("GameFontHighlightSmall")
    b:SetDisabledFontObject("GameFontDisableSmall")
    b:SetText(text)
    return b
end

-- =========================================================================
-- STATE
-- =========================================================================
local currentTab = "zone"
local selected = nil          -- encounter table
local rows = {}               -- row buttons
local listData = {}           -- { header = text } or { enc = encounter }

-- Status of an encounter: text, unlocked, reason
local function EncounterStatus(enc)
    local unlocked, reason = TTS:IsEncounterUnlocked(enc)
    local wins = TTS:GetEncounterWins(enc.id)
    if not unlocked then return GREY .. "Locked|r", false, reason end
    if wins > 0 then return string.format("%sCleared x%d|r", GOLD, wins), true end
    return GREEN .. "Available|r", true
end

-- =========================================================================
-- REWARD PREVIEW (docked to the left of the window, like the Deckbuilder's)
-- =========================================================================
local preview
local function ShowRewardPreview(enc)
    local card = enc and enc.reward and TTS.Cards[enc.reward]
    if not card or not TTS.CreateCardFrame or not TTS.PaintPreviewCard then
        if preview then preview:Hide() end
        return
    end
    if not preview then
        preview = TTS.CreateCardFrame(S, TTS.PREVIEW_W, TTS.PREVIEW_H)
        preview:SetFrameStrata("DIALOG")
        preview:SetFrameLevel((S:GetFrameLevel() or 10) + 40)
        preview:SetClampedToScreen(true)
        preview:EnableMouse(false)
        preview:SetScript("OnEnter", nil)
        preview:SetScript("OnLeave", nil)
        preview:ClearAllPoints()
        preview:SetPoint("TOPRIGHT", S, "TOPLEFT", -12, -76)
    end
    TTS.PaintPreviewCard(preview, card)
    -- Not yet earned: show it dimmed
    local owned = TTS:GetOwnedCopies(card) or 0
    local shade = owned > 0 and 1 or 0.45
    preview.art:SetVertexColor(shade, shade, shade)
    if preview.model and preview.model.SetAlpha then preview.model:SetAlpha(owned > 0 and 1 or 0.6) end
end

-- =========================================================================
-- TABS
-- =========================================================================
local zonesTab = CreatePanelButton(S, 110, 22, "Zones")
zonesTab:SetPoint("TOPLEFT", S, "TOPLEFT", 16, -46)
local dungeonsTab = CreatePanelButton(S, 110, 22, "Dungeons")
dungeonsTab:SetPoint("LEFT", zonesTab, "RIGHT", 4, 0)

local deckStatus = S:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
deckStatus:SetPoint("RIGHT", S, "TOPRIGHT", -20, -57)
deckStatus:SetJustifyH("RIGHT")

-- =========================================================================
-- LIST
-- =========================================================================
local listSection = CreateSection("Zone Gauntlet", WIN_W - 28, LIST_H)
listSection:SetPoint("TOPLEFT", S, "TOPLEFT", 14, -74)

local scroll = CreateFrame("ScrollFrame", "TTS_SoloSelectScroll", listSection, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", listSection, "TOPLEFT", 8, -30)
scroll:SetPoint("BOTTOMRIGHT", listSection, "BOTTOMRIGHT", -28, 8)

local content = CreateFrame("Frame", nil, scroll)
content:SetSize(WIN_W - 28 - 36, 10)
scroll:SetScrollChild(content)

local UpdateDetails, RefreshList

local function Row(i)
    if rows[i] then return rows[i] end
    local r = CreateFrame("Button", nil, content)
    r:SetSize(content:GetWidth(), ROW_H)
    r:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(i - 1) * ROW_H)

    r.sel = r:CreateTexture(nil, "BACKGROUND")
    r.sel:SetAllPoints(r)
    r.sel:SetColorTexture(1, 0.82, 0, 0.18)
    r.sel:Hide()

    local hl = r:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(r)
    hl:SetTexture(HIGHLIGHT_TEX)
    hl:SetBlendMode("ADD")
    r.hl = hl

    r.name = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    r.name:SetPoint("LEFT", 6, 0)
    r.name:SetJustifyH("LEFT")
    r.status = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    r.status:SetPoint("RIGHT", -6, 0)
    r.status:SetJustifyH("RIGHT")

    r:SetScript("OnClick", function(self)
        if not self.enc then return end
        selected = self.enc
        RefreshList()
        UpdateDetails()
    end)
    r:SetScript("OnEnter", function(self)
        if not self.enc then return end
        ShowRewardPreview(self.enc)
        local _, unlocked, reason = EncounterStatus(self.enc)
        if TT then
            TT:ShowText(self, "ANCHOR_RIGHT", self.enc.name, unlocked and ("Opponent: " .. self.enc.opponent) or reason)
        end
    end)
    r:SetScript("OnLeave", function(self)
        if TT then TT:Hide(self) end
        ShowRewardPreview(selected)
    end)
    rows[i] = r
    return r
end

local function BuildListData()
    listData = {}
    local list = TTS:GetSoloEncounters(currentTab)
    if currentTab == "zone" then
        for _, chain in ipairs(TTS.SoloZoneChains or {}) do
            table.insert(listData, { header = chain })
            for _, enc in ipairs(list) do
                if enc.chain == chain then table.insert(listData, { enc = enc }) end
            end
        end
    else
        for _, enc in ipairs(list) do table.insert(listData, { enc = enc }) end
    end
end

RefreshList = function()
    BuildListData()
    for i, item in ipairs(listData) do
        local r = Row(i)
        r:Show()
        if item.header then
            r.enc = nil
            r.name:SetText(GOLD .. item.header .. "|r")
            r.status:SetText("")
            r.sel:Hide()
            r.hl:SetAlpha(0)
            r:EnableMouse(false)
        else
            local enc = item.enc
            r.enc = enc
            r:EnableMouse(true)
            r.hl:SetAlpha(1)
            local status, unlocked = EncounterStatus(enc)
            local indent = currentTab == "zone" and "   " or ""
            r.name:SetText(indent .. (unlocked and enc.name or (GREY .. enc.name .. "|r")))
            r.status:SetText(status)
            if selected == enc then r.sel:Show() else r.sel:Hide() end
        end
    end
    for i = #listData + 1, #rows do rows[i]:Hide(); rows[i].enc = nil end
    content:SetHeight(math.max(10, #listData * ROW_H))
end

-- =========================================================================
-- DETAILS & START
-- =========================================================================
local detailSection = CreateSection("Encounter", WIN_W - 28, 150)
detailSection:SetPoint("TOPLEFT", listSection, "BOTTOMLEFT", 0, -8)

local detailText = detailSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
detailText:SetPoint("TOPLEFT", detailSection, "TOPLEFT", 12, -32)
detailText:SetPoint("BOTTOMRIGHT", detailSection, "BOTTOMRIGHT", -12, 8)
detailText:SetJustifyH("LEFT")
detailText:SetJustifyV("TOP")
detailText:SetWordWrap(true)

local startBtn = CreatePanelButton(S, 140, 24, "Start Encounter")
startBtn:SetPoint("TOPRIGHT", detailSection, "BOTTOMRIGHT", 0, -8)

local startHint = S:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
startHint:SetPoint("RIGHT", startBtn, "LEFT", -10, 0)
startHint:SetPoint("LEFT", detailSection, "BOTTOMLEFT", 4, 0)
startHint:SetJustifyH("LEFT")

-- Why a game can't start right now (nil = it can)
local function StartBlocker(enc)
    local E = TTS.Engine
    if not enc then return "Choose an encounter." end
    if E and E.inMatch then return "A game is already in progress." end
    if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() then return "Close the Deckbuilder first." end
    if TTS.WaitingRoom and TTS.WaitingRoom.isQueued then return "Leave the waiting room queue first." end
    if E and not E:ValidateDeck() then return "Your active deck must have 40-50 cards." end
    local unlocked, reason = TTS:IsEncounterUnlocked(enc)
    if not unlocked then return reason end
    return nil
end

UpdateDetails = function()
    local enc = selected
    if not enc then
        detailSection.header:SetText("Encounter")
        detailText:SetText(GREY .. "Choose an encounter from the list.|r")
    else
        detailSection.header:SetText(enc.name)
        local lines = {}
        table.insert(lines, string.format("Opponent: %s%s|r    Life: %s%d|r    AI: %s%s|r",
            GOLD, enc.opponent, GOLD, enc.life or 20, GOLD, AI_LABEL[enc.ai] or enc.ai))
        if enc.kind == "dungeon" then
            local names = {}
            for _, b in ipairs(enc.bosses or {}) do
                table.insert(names, TTS.Cards[b] and TTS.Cards[b].name or b)
            end
            table.insert(lines, "Bosses: " .. table.concat(names, ", "))
            for _, rule in ipairs(TTS:GetEncounterRuleLines(enc)) do
                table.insert(lines, string.format("%s%s:|r %s", ORANGE, rule.name, rule.text))
            end
        else
            table.insert(lines, "Deck: the creatures of " .. enc.zone .. ".")
        end
        local card = enc.reward and TTS.Cards[enc.reward]
        if card then
            local owned = TTS:GetOwnedCopies(card) or 0
            table.insert(lines, string.format("Reward: %s%s|r (%d/4 owned). One copy per win.", GOLD, card.name, owned))
        end
        local unlocked, reason = TTS:IsEncounterUnlocked(enc)
        if not unlocked then table.insert(lines, RED .. "Locked: " .. reason .. "|r") end
        detailText:SetText(table.concat(lines, "\n"))
    end

    local blocker = StartBlocker(enc)
    if blocker then
        startBtn:Disable()
        startHint:SetText(RED .. blocker .. "|r")
    else
        startBtn:Enable()
        startHint:SetText("")
    end
    ShowRewardPreview(enc)
end

startBtn:SetScript("OnClick", function()
    local enc = selected
    if StartBlocker(enc) then return end
    S:Hide()
    TTS.Engine:StartMatch(enc.opponent, true, true, enc)
end)

local function SelectTab(kind)
    currentTab = kind
    listSection.header:SetText(kind == "zone" and "Zone Gauntlet" or "Dungeons")
    if kind == "zone" then
        zonesTab:Disable(); dungeonsTab:Enable()
    else
        dungeonsTab:Disable(); zonesTab:Enable()
    end
    if selected and selected.kind ~= kind then selected = nil end
    -- Default to the first unlocked encounter without a win, else the first one
    if not selected then
        for _, enc in ipairs(TTS:GetSoloEncounters(kind)) do
            if TTS:IsEncounterUnlocked(enc) and TTS:GetEncounterWins(enc.id) == 0 then selected = enc; break end
        end
        selected = selected or TTS:GetSoloEncounters(kind)[1]
    end
    scroll:SetVerticalScroll(0)
    RefreshList()
    UpdateDetails()
end

zonesTab:SetScript("OnClick", function() SelectTab("zone") end)
dungeonsTab:SetScript("OnClick", function() SelectTab("dungeon") end)

-- Refreshes everything (called when progress or the deck changes)
function S:Refresh()
    if not self:IsShown() then return end
    local deck = TTS_SavedDecks and TTS_SavedDecks[TTS_ActiveDeckIndex]
    local count = 0
    for _, n in pairs(deck and deck.cards or {}) do count = count + n end
    deckStatus:SetText(string.format("Active deck: %s%s|r (%d cards)", GOLD, deck and deck.name or "None", count))
    RefreshList()
    UpdateDetails()
end

S:SetScript("OnShow", function(self)
    if TTS.Engine and TTS.Engine.inMatch then
        self:Hide()
        return
    end
    SelectTab(currentTab)
    self:Refresh()
end)

S:SetScript("OnHide", function()
    if TT then TT:Hide() end
    if preview then preview:Hide() end
end)

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    if TTS.Sound and TTS.Sound.HookButtons then TTS.Sound:HookButtons(S) end
    self:UnregisterAllEvents()
end)
