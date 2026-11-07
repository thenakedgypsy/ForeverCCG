--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
local L = TTS.L

local ADDON_NAME = "ForeverCCG"
local DEFAULT_MINIMAP_POS = 205
local RADIUS = 93

local btn = CreateFrame("Button", "TTS_MinimapButton", Minimap)
btn:SetSize(31, 31)
btn:SetFrameStrata("MEDIUM")
btn:SetFrameLevel(8)

-- Icon: the game's card back, upright at its own shape (512 x 717)
local icon = btn:CreateTexture(nil, "BACKGROUND")
icon:SetTexture("Interface\\AddOns\\ForeverCCG\\Textures\\Cards\\card_back.png")
icon:SetSize(14, 20)
icon:SetPoint("CENTER", btn, "CENTER", 0, 0)

-- Classic WoW Minimap Border
local border = btn:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetSize(52, 52)
border:SetPoint("CENTER", btn, "CENTER", 10, -10)

btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

local function UpdateMinimapButtonPosition()
    local angle = math.rad(TTS_MinimapPos or DEFAULT_MINIMAP_POS)
    btn:ClearAllPoints()
    btn:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * RADIUS, math.sin(angle) * RADIUS)
end

-- =========================================================================
-- DRAG MOVEMENT HANDLER
-- =========================================================================
local isDragging = false

btn:RegisterForDrag("LeftButton")
btn:SetScript("OnDragStart", function(self)
    isDragging = true
    if TTS.Tooltip then TTS.Tooltip:Hide() end
    self:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter()
        local cx, cy = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        cx, cy = cx / scale, cy / scale

        TTS_MinimapPos = math.deg(math.atan2(cy - my, cx - mx))
        UpdateMinimapButtonPosition()
    end)
end)

btn:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
    C_Timer.After(0.1, function() isDragging = false end)
end)

-- =========================================================================
-- QUICK-OPEN HELPERS
-- =========================================================================
local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end

local function ToggleRules()
    local R = TTS.RulesFrame
    if not R then return end
    if R:IsShown() then R:Hide() else R:Show() end
end

-- Same restrictions as the main window's "Open Waiting Room" button
local function ToggleWaitingRoom()
    local F = TTS.WaitingRoom and TTS.WaitingRoom.frame
    if not F then return end
    if F:IsShown() then
        F:Hide()
        return
    end
    if TTS.Engine and TTS.Engine.inMatch then
        Print(L("minimap.wrInMatch"))
        return
    end
    -- Already queued: always reopens, so the player can leave
    local queued = TTS.WaitingRoom.isQueued
    if not queued and TTS.Engine and not TTS.Engine:HasPlayableDeck() then
        Print(L("minimap.wrDeckSize"))
        return
    end
    F:Show()
end

-- =========================================================================
-- CLICKS & TOOLTIP
-- =========================================================================
btn:RegisterForClicks("LeftButtonUp")
btn:SetScript("OnClick", function()
    if isDragging then return end

    -- During a game the button only minimises or restores the board, whatever key is held
    -- (Options is on the board's cog); everything else waits until the game is over
    local B = TTS.BoardFrame
    if TTS.Engine and TTS.Engine.inMatch and B then
        if B:IsShown() then
            if B.Minimize then B:Minimize() end
        else
            B:Show()
        end
        return
    end

    if IsAltKeyDown() then
        -- Alt-Click: Open / Toggle Rules
        ToggleRules()
    elseif IsControlKeyDown() then
        -- Ctrl-Click: Open / Toggle Waiting Room
        ToggleWaitingRoom()
    elseif IsShiftKeyDown() then
        -- Shift-Click: Open / Toggle Deckbuilder (blocked while a game is in progress)
        local D = TTS.DeckBuilderFrame
        if D then
            if D:IsShown() then
                D:Hide()
            elseif D.TryOpen and D:TryOpen() then
                if TTS.MainFrame and TTS.MainFrame:IsShown() then
                    TTS.MainFrame:Hide()
                end
            end
        end
    elseif TTS.BoardRestoreFrame and TTS.BoardRestoreFrame:IsShown() and TTS.BoardFrame then
        -- Regular Click with the match minimised: bring the board back
        TTS.BoardFrame:Show()
    else
        -- Regular Click: Open / Toggle Main Window
        if TTS.MainFrame then
            if TTS.MainFrame:IsShown() then
                TTS.MainFrame:Hide()
            else
                TTS.MainFrame:Show()
            end
        end
    end
end)

local function BuildMinimapTooltip(tip)
    tip:AddLine("Forever: CCG", 1, 0.82, 0)
    tip:AddLine(" ")

    if TTS.GetCollectionScore then
        tip:AddDoubleLine(L("minimap.score"), TTS:ColoredScore((TTS:GetCollectionScore())), 1, 1, 1, 1, 0.82, 0)
    end
    if TTS.PvP then
        tip:AddDoubleLine(L("minimap.rating"), TTS.PvP.ColoredRating((TTS.PvP:Get())), 1, 1, 1, 1, 0.82, 0)
    end
    -- Campfire warmth running (Campfire.lua): the time left, never the size
    local warmth = TTS.Campfire and TTS.Campfire:Remaining()
    if warmth then
        local m = math.ceil(warmth / 60)
        tip:AddDoubleLine(L("minimap.campfire"), L(m == 1 and "campfire.minute" or "campfire.minutes", m), 1, 0.6, 0.2, 1, 1, 1)
    end

    if TTS.Engine and TTS.Engine.inMatch then
        tip:AddLine(" ")
        tip:AddLine("|cFF00FF00" .. L("minimap.inMatch") .. "|r")
    elseif TTS.WaitingRoom and TTS.WaitingRoom.isQueued then
        tip:AddLine(" ")
        tip:AddLine("|cFF00FF00" .. L("minimap.inWaitingRoom") .. "|r")
    end

    tip:AddLine(" ")
    -- During a game a click only minimises or restores the board (OnClick above)
    local hints = (TTS.Engine and TTS.Engine.inMatch) and { "minimap.hintBoard", "minimap.hintMove" }
        or { "minimap.hintMain", "minimap.hintDeck", "minimap.hintRules", "minimap.hintWaiting", "minimap.hintMove" }
    for _, key in ipairs(hints) do
        tip:AddLine("|cFF808080" .. L(key) .. "|r")
    end
end

-- Shown through the tooltip manager (UI\Tooltips.lua)
btn:SetScript("OnEnter", function(self)
    if isDragging then return end
    if TTS.Tooltip then TTS.Tooltip:Show(self, "ANCHOR_LEFT", { main = BuildMinimapTooltip }) end
end)

btn:SetScript("OnLeave", function(self)
    if TTS.Tooltip then TTS.Tooltip:Hide(self) end
end)

-- =========================================================================
-- INITIALIZATION
-- =========================================================================
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, loadedAddon)
    if loadedAddon == ADDON_NAME or loadedAddon == "ForeverCCG" then
        TTS_MinimapPos = TTS_MinimapPos or DEFAULT_MINIMAP_POS
        UpdateMinimapButtonPosition()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)