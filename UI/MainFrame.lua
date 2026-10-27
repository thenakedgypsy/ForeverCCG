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

local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
TTS.MainFrame = CreateFrame("Frame", "TTS_MainDialog", UIParent, backdropTemplate)
local M = TTS.MainFrame

-- =========================================================================
-- STYLE (matches the Deckbuilder: dialog window, dark title strip with a gold
-- line, tooltip-bordered panels with gold section headers, small-font buttons)
-- =========================================================================
local PANEL_BG     = { 0.04, 0.04, 0.04, 0.70 }
local PANEL_BORDER = { 0.60, 0.56, 0.48, 1 }

M:SetSize(400, 288)
M:SetPoint("CENTER")
M:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
M:EnableMouse(true)
M:SetMovable(true)
M:RegisterForDrag("LeftButton")
M:SetScript("OnDragStart", M.StartMoving)
M:SetScript("OnDragStop", M.StopMovingOrSizing)
M:Hide()

-- =========================================================================
-- TITLE & CLOSE
-- =========================================================================
local titleBar = M:CreateTexture(nil, "ARTWORK")
titleBar:SetPoint("TOPLEFT", 12, -12)
titleBar:SetPoint("TOPRIGHT", -12, -12)
titleBar:SetHeight(25)
titleBar:SetColorTexture(0, 0, 0, 0.35)

local titleLine = M:CreateTexture(nil, "ARTWORK")
titleLine:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 0)
titleLine:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
titleLine:SetHeight(1)
titleLine:SetColorTexture(1, 0.82, 0, 0.55)

local title = M:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -11)
title:SetText("Forever: CCG")

local closeBtn = CreateFrame("Button", nil, M, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -2, -2)

local content = CreateFrame("Frame", nil, M)
content:SetAllPoints(M)

-- Tooltip-bordered panel with a gold section header (locale key) and divider
local function CreateSection(labelKey, w, h)
    local p = CreateFrame("Frame", nil, content, backdropTemplate)
    p:SetSize(w, h)
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

-- Red panel button with the Deckbuilder's small fonts, labelled with locale key textKey
local function CreatePanelButton(name, parent, w, h, textKey)
    local b = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    b:SetSize(w, h)
    b:SetNormalFontObject("GameFontNormalSmall")
    b:SetHighlightFontObject("GameFontHighlightSmall")
    b:SetDisabledFontObject("GameFontDisableSmall")
    Loc:Bind(b, textKey)
    return b
end

-- =========================================================================
-- OPENING WINDOWS FROM HERE
-- Picking an option closes this window; closing the window it opened brings
-- this one back (unless a match has started in the meantime).
-- =========================================================================
local function OnChildHidden(child)
    if not child.ttsOpenedFromMain then return end
    child.ttsOpenedFromMain = nil
    -- Wait a frame: a window closed by a match starting should not bring this back
    TTS:SafeAfter(0, function()
        if child:IsShown() or M:IsShown() then return end
        if TTS.Engine and TTS.Engine.inMatch then return end
        -- Hidden for the deck picker: cancelling it may bring the window back, still ours
        if TTS.DeckPicker and TTS.DeckPicker:IsPending() then
            child.ttsOpenedFromMain = true
            return
        end
        -- Hidden behind a dialog of its own (the solo map's dungeon entry), which brings it back
        if child.ttsIsCovered and child.ttsIsCovered() then
            child.ttsOpenedFromMain = true
            return
        end
        M:Show()
    end)
end

local function OpenFromMain(child)
    if not child:IsShown() then return end   -- it refused to open
    if not child.ttsMainHooked then
        child.ttsMainHooked = true
        child:HookScript("OnHide", OnChildHidden)
    end
    child.ttsOpenedFromMain = true
    M:Hide()
end

-- Opens a window as if from the main window, so closing it comes back here (Board.lua: the
-- solo map after a solo encounter)
function M:OpenChild(child)
    child:Show()
    OpenFromMain(child)
end

-- =========================================================================
-- OPTIONS (title bar, left of the close button)
-- =========================================================================
local optionsBtn = CreatePanelButton("TTS_OptionsBtn", M, 64, 20, "options.title")
optionsBtn:SetPoint("TOPRIGHT", M, "TOPRIGHT", -32, -15)
optionsBtn:SetScript("OnClick", function()
    if TTS.OptionsFrame then
        TTS.OptionsFrame:Show()
        OpenFromMain(TTS.OptionsFrame)
    end
end)

-- =========================================================================
-- SECTION 1: DECK MANAGEMENT, RULES & STATUS BANNER
-- =========================================================================
local deckSection = CreateSection("main.yourDeck", 372, 104)
deckSection:SetPoint("TOPLEFT", M, "TOPLEFT", 14, -46)

local deckBtn = CreatePanelButton("TTS_DeckBuilderBtn", deckSection, 170, 24, "main.openDeckbuilder")
deckBtn:SetPoint("TOPLEFT", deckSection, "TOPLEFT", 10, -32)
deckBtn:SetScript("OnClick", function()
    if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame.TryOpen then
        TTS.DeckBuilderFrame:TryOpen()
        OpenFromMain(TTS.DeckBuilderFrame)
    end
end)

local rulesBtn = CreatePanelButton("TTS_RulesBtn", deckSection, 170, 24, "main.rules")
rulesBtn:SetPoint("TOPRIGHT", deckSection, "TOPRIGHT", -10, -32)
rulesBtn:SetScript("OnClick", function()
    if TTS.RulesFrame then
        TTS.RulesFrame:Show()
        OpenFromMain(TTS.RulesFrame)
    end
end)

-- Collection score, right side of the section header
local scoreLabel = deckSection:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
scoreLabel:SetPoint("TOPRIGHT", deckSection, "TOPRIGHT", -10, -9)
scoreLabel:SetJustifyH("RIGHT")

local statusLabel = deckSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
statusLabel:SetPoint("TOP", deckSection, "TOP", 0, -66)
statusLabel:SetWidth(340)
statusLabel:SetJustifyH("CENTER")
statusLabel:SetWordWrap(true)

-- =========================================================================
-- SECTION 2: SOLO (encounters and the practice dummy)
-- =========================================================================
local practiceSection = CreateSection("main.solo", 180, 96)
practiceSection:SetPoint("TOPLEFT", deckSection, "BOTTOMLEFT", 0, -8)

local encountersBtn = CreatePanelButton("TTS_SoloEncountersBtn", practiceSection, 160, 24, "main.soloEncounters")
encountersBtn:SetPoint("TOP", practiceSection, "TOP", 0, -32)
encountersBtn:SetScript("OnClick", function()
    if TTS.SoloSelectFrame then
        TTS.SoloSelectFrame:Show()
        OpenFromMain(TTS.SoloSelectFrame)
    end
end)

local soloBtn = CreatePanelButton("TTS_SoloBtn", practiceSection, 160, 24, "main.practice")
soloBtn:SetPoint("TOP", encountersBtn, "BOTTOM", 0, -4)
soloBtn:SetScript("OnClick", function()
    if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() then
        DEFAULT_CHAT_FRAME:AddMessage(L("main.closeDeckbuilderFirst"))
        return
    end
    local dummy = L("solo.dummy")
    TTS.DeckPicker:Open({
        opponent = dummy,
        onPick = function()
            if TTS.Engine.inMatch then return end
            TTS.Engine:StartMatch(dummy, true, true)
        end,
    })
end)

-- =========================================================================
-- SECTION 3: PVP WAITING ROOM (the only way to challenge other players)
-- =========================================================================
local pvpSection = CreateSection("main.playOthers", 180, 96)
pvpSection:SetPoint("TOPRIGHT", deckSection, "BOTTOMRIGHT", 0, -8)

local waitingRoomBtn = CreatePanelButton("TTS_WaitingRoomBtn", pvpSection, 160, 24, "main.openWaitingRoom")
waitingRoomBtn:SetPoint("TOP", pvpSection, "TOP", 0, -34)
waitingRoomBtn:SetScript("OnClick", function()
    if TTS.WaitingRoom and TTS.WaitingRoom.frame then
        TTS.WaitingRoom.frame:Show()
        OpenFromMain(TTS.WaitingRoom.frame)
    end
end)

-- =========================================================================
-- STATE UPDATER & LIFECYCLE (ENFORCING 40-50 CARDS)
-- =========================================================================
function M:UpdatePlayState()
    if TTS.GetCollectionScore then
        scoreLabel:SetText(L("main.score", TTS:ColoredScore((TTS:GetCollectionScore()))))
    end

    local inMatch = TTS.Engine and TTS.Engine.inMatch
    local isQueued = TTS.WaitingRoom and TTS.WaitingRoom.isQueued
    local playable = TTS:PlayableDeckCount()

    -- The Deckbuilder cannot be opened while a game is in progress (it can while queued)
    deckBtn:SetEnabled(not inMatch)
    -- Solo encounters open whenever no game is running (the window explains anything else in the way)
    encountersBtn:SetEnabled(not inMatch)
    -- Decks are picked as a game starts, so one playable deck is enough. Once queued the
    -- waiting room always reopens, so the player can leave.
    waitingRoomBtn:SetEnabled(not inMatch and (isQueued or playable > 0))
    -- Practice vs Dummy is unavailable during a game or while queued in the waiting room
    soloBtn:SetEnabled(not inMatch and not isQueued and playable > 0
        and not (TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown()))

    if isQueued then
        statusLabel:SetText(L("main.inWaitingRoom"))
    elseif TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() then
        statusLabel:SetText(L("main.deckbuilderOpen"))
    elseif playable > 0 then
        statusLabel:SetText(L("main.decksReady", playable))
    else
        statusLabel:SetText(L("main.noDeckReady"))
    end
end

M:SetScript("OnShow", function()
    M:UpdatePlayState()
end)

-- =========================================================================
-- FOOTER
-- =========================================================================
local footer = content:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
footer:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -20, 14)
footer:SetText("Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy")

-- =========================================================================
-- SLASH COMMAND
-- =========================================================================
SLASH_TRAGIC1 = "/tragic"

SlashCmdList["TRAGIC"] = function(msg)
    local cmd = (msg or ""):trim():lower()

    if cmd == "build" or cmd == "builder" or cmd == "deck" then
        if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame.TryOpen then
            if TTS.DeckBuilderFrame:TryOpen() and TTS.MainFrame and TTS.MainFrame:IsShown() then
                TTS.MainFrame:Hide()
            end
        else
            DEFAULT_CHAT_FRAME:AddMessage(L("main.noDeckbuilder"))
        end
    elseif cmd == "board" or cmd == "game" then
        if TTS.BoardFrame then
            if TTS.BoardFrame:IsShown() then
                TTS.BoardFrame:Hide()
            else
                TTS.BoardFrame:Show()
            end
        end
    elseif cmd == "rules" or cmd == "rule" or cmd == "guide" then
        if TTS.RulesFrame then
            if TTS.RulesFrame:IsShown() then
                TTS.RulesFrame:Hide()
            else
                TTS.RulesFrame:Show()
            end
        else
            DEFAULT_CHAT_FRAME:AddMessage(L("main.noRules"))
        end
    elseif cmd:match("^lang") then
        -- /tragic lang [auto|enUS|deDE|...|pseudo]: choose a language (pseudo marks untranslated text)
        local choice = msg:trim():match("^%S+%s+(%S+)")
        if choice then
            if choice:lower() == "auto" or choice:lower() == "pseudo" then choice = choice:lower() end
            Loc:SetChoice(choice)
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD200[TTSE]|r " .. choice .. " - " .. L("locale.reload"))
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD200[TTSE]|r " .. L("options.language") .. ": " .. Loc:GetChoice() .. " (" .. Loc.code .. ")")
        end
    elseif cmd:match("^fx") then
        -- /tragic fx [kit <id> | anim <id>]: what card effects worked, or try one (CardFX.lua)
        if TTS.CardFX and TTS.CardFX.Command then TTS.CardFX:Command(msg:trim():match("^%S+%s*(.*)$")) end
    elseif cmd == "tutorial" then
        if TTS.StartTutorial then TTS:StartTutorial() end
    elseif cmd == "solo" or cmd == "encounters" then
        if TTS.SoloSelectFrame then
            if TTS.SoloSelectFrame:IsShown() then
                TTS.SoloSelectFrame:Hide()
            else
                TTS.SoloSelectFrame:Show()
            end
        end
    elseif cmd == "queue" or cmd == "lfm" or cmd == "waiting" then
        if TTS.WaitingRoom and TTS.WaitingRoom.frame then
            if TTS.WaitingRoom.frame:IsShown() then
                TTS.WaitingRoom.frame:Hide()
            else
                TTS.WaitingRoom.frame:Show()
            end
        end
    else
        if TTS.MainFrame then
            if TTS.MainFrame:IsShown() then
                TTS.MainFrame:Hide()
            else
                TTS.MainFrame:Show()
            end
        end
    end
end