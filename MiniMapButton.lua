--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

local ADDON_NAME = "ForeverCCG"
local DEFAULT_MINIMAP_POS = 205
local RADIUS = 93

local btn = CreateFrame("Button", "TTS_MinimapButton", Minimap)
btn:SetSize(31, 31)
btn:SetFrameStrata("MEDIUM")
btn:SetFrameLevel(8)

-- Icon (Tarot Card)
local icon = btn:CreateTexture(nil, "BACKGROUND")
icon:SetTexture("Interface\\Icons\\INV_Misc_Ticket_Tarot_TwistingNether_01")
icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
icon:SetSize(20, 20)
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
    GameTooltip:Hide()
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
    if C_Timer and C_Timer.After then
        C_Timer.After(0.1, function() isDragging = false end)
    else
        isDragging = false
    end
end)

-- =========================================================================
-- CLICKS & TOOLTIP
-- =========================================================================
btn:RegisterForClicks("LeftButtonUp")
btn:SetScript("OnClick", function()
    if isDragging then return end

    if IsShiftKeyDown() then
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

btn:SetScript("OnEnter", function(self)
    if isDragging then return end

    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("Forever: CCG", 1, 0.82, 0)
    GameTooltip:AddLine(" ")

    local activeDeck = TTS_SavedDecks and TTS_SavedDecks[TTS_ActiveDeckIndex]
    local count = 0
    if activeDeck and activeDeck.cards then
        for _, qty in pairs(activeDeck.cards) do
            count = count + qty
        end
    end
    local deckName = (activeDeck and activeDeck.name) or "Default Deck"

    GameTooltip:AddDoubleLine("Active Deck:", deckName, 1, 1, 1, 0.9, 0.9, 0.6)
    GameTooltip:AddDoubleLine(
        "Card Count:",
        string.format("%d / 40", count),
        1, 1, 1,
        (count >= 40 and 0 or 1),
        (count >= 40 and 1 or 0.2),
        0.2
    )

    if TTS.Engine and TTS.Engine.inMatch then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cFF00FF00Match in Progress!|r")
    end

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("|cFF808080Left-Click: Toggle Main Window|r")
    GameTooltip:AddLine("|cFF808080Shift + Left-Click: Toggle Deckbuilder|r")
    GameTooltip:AddLine("|cFF808080Left-Click & Drag: Move Button|r")
    GameTooltip:Show()
end)

btn:SetScript("OnLeave", function()
    GameTooltip:Hide()
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
