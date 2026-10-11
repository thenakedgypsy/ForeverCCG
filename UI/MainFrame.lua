--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
TTS.MainFrame = CreateFrame("Frame", "TTS_MainDialog", UIParent, backdropTemplate)
local M = TTS.MainFrame

M:SetSize(400, 280)
M:SetPoint("CENTER")
M:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
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
local title = M:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", 0, -18)
title:SetText("Forever: CCG")

local closeBtn = CreateFrame("Button", nil, M, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -5, -5)

local content = CreateFrame("Frame", nil, M)
content:SetAllPoints(M)

-- =========================================================================
-- SECTION 1: DECK MANAGEMENT, RULES & STATUS BANNER
-- =========================================================================
local deckBtn = CreateFrame("Button", "TTS_DeckBuilderBtn", content, "UIPanelButtonTemplate")
deckBtn:SetSize(170, 24)
deckBtn:SetPoint("TOP", 0, -46)
deckBtn:SetText("Open Deckbuilder")
deckBtn:SetScript("OnClick", function()
    if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame.TryOpen then
        TTS.DeckBuilderFrame:TryOpen()
    end
end)

local rulesBtn = CreateFrame("Button", "TTS_RulesBtn", content, "UIPanelButtonTemplate")
rulesBtn:SetSize(170, 24)
rulesBtn:SetPoint("TOP", deckBtn, "BOTTOM", 0, -6)
rulesBtn:SetText("Official Rules")
rulesBtn:SetScript("OnClick", function()
    if TTS.RulesFrame then
        if TTS.RulesFrame:IsShown() then
            TTS.RulesFrame:Hide()
        else
            TTS.RulesFrame:Show()
        end
    end
end)

local statusLabel = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
statusLabel:SetPoint("TOP", rulesBtn, "BOTTOM", 0, -8)
statusLabel:SetWidth(340)
statusLabel:SetJustifyH("CENTER")
statusLabel:SetWordWrap(true)

local div1 = content:CreateTexture(nil, "ARTWORK")
div1:SetSize(340, 1)
div1:SetPoint("TOP", 0, -145)
div1:SetColorTexture(1, 1, 1, 0.15)

-- =========================================================================
-- SECTION 2: SOLO PRACTICE
-- =========================================================================
local soloBtn = CreateFrame("Button", "TTS_SoloBtn", content, "UIPanelButtonTemplate")
soloBtn:SetSize(180, 26)
soloBtn:SetPoint("TOP", 0, -158)
soloBtn:SetText("Practice vs Dummy")
soloBtn:SetScript("OnClick", function()
    if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222[TTSE]|r Close the Deckbuilder before starting a match.")
        return
    end
    TTS.Engine:StartMatch("Target Dummy", true, true)
end)

local div2 = content:CreateTexture(nil, "ARTWORK")
div2:SetSize(340, 1)
div2:SetPoint("TOP", 0, -196)
div2:SetColorTexture(1, 1, 1, 0.15)

-- =========================================================================
-- SECTION 3: PVP WAITING ROOM (the only way to challenge other players)
-- =========================================================================
local waitingRoomBtn = CreateFrame("Button", "TTS_WaitingRoomBtn", content, "UIPanelButtonTemplate")
waitingRoomBtn:SetSize(180, 24)
waitingRoomBtn:SetPoint("TOP", 0, -210)
waitingRoomBtn:SetText("Open Waiting Room")
waitingRoomBtn:SetScript("OnClick", function()
    if TTS.WaitingRoom and TTS.WaitingRoom.frame then
        if TTS.WaitingRoom.frame:IsShown() then
            TTS.WaitingRoom.frame:Hide()
        else
            TTS.WaitingRoom.frame:Show()
        end
    end
end)

-- =========================================================================
-- STATE UPDATER & LIFECYCLE (ENFORCING 40-50 CARDS)
-- =========================================================================
function M:UpdatePlayState()
    -- The Deckbuilder cannot be opened while a game is in progress
    if TTS.Engine and TTS.Engine.inMatch then
        deckBtn:Disable()
    else
        deckBtn:Enable()
    end

    if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() then
        soloBtn:Disable()
        waitingRoomBtn:Disable()
        statusLabel:SetText("|cFFFF4444Deckbuilder is open — close it to start a game.|r")
        return
    end

    local activeDeck = TTS_SavedDecks and TTS_SavedDecks[TTS_ActiveDeckIndex]
    local cardCount = 0
    if activeDeck and activeDeck.cards then
        for _, count in pairs(activeDeck.cards) do
            cardCount = cardCount + count
        end
    end

    local deckName = (activeDeck and activeDeck.name) or "Default Deck"

    if cardCount >= 40 and cardCount <= 50 then
        soloBtn:Enable()
        waitingRoomBtn:Enable()
        statusLabel:SetText(string.format("|cFF00FF00Deck valid: %s (%d/50 cards)|r", deckName, cardCount))
    elseif cardCount > 50 then
        soloBtn:Disable()
        waitingRoomBtn:Disable()
        statusLabel:SetText(string.format("|cFFFF2222Deck invalid: %s (%d cards - Max 50 cards allowed)|r", deckName, cardCount))
    else
        soloBtn:Disable()
        waitingRoomBtn:Disable()
        statusLabel:SetText(string.format("|cFFFF2222Deck invalid: %s (%d/40 cards minimum)|r", deckName, cardCount))
    end
end

M:SetScript("OnShow", function()
    M:UpdatePlayState()
end)

-- =========================================================================
-- FOOTER
-- =========================================================================
local footer = content:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
footer:SetPoint("BOTTOM", content, "BOTTOM", 0, 12)
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
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[TTSE]|r Deckbuilder frame not initialized.")
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
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[TTSE]|r Rules frame not initialized.")
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
