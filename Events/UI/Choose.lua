--[[
    ForeverCCG Events
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.
]]
local _, ns = ...
local UI, H, P = ns.UI, ns.Host, ns.Player

-- =========================================================================
-- JOIN OR HOST
-- What the main window's Tournaments button opens first: Join an Event (the player's
-- window) or Host an Event (the organizer's). Someone already in an event, or running one,
-- goes straight to that window instead. Built the first time it opens.
-- Opened from the main window, whichever window is picked takes its place, so closing that
-- one brings the main window back (UI\MainFrame.lua's ttsOpenedFromMain).
-- =========================================================================
local F

-- Hides this window and opens `target` (a frame) in its place
local function Pick(open, target)
    local fromMain = F.ttsOpenedFromMain
    F.ttsOpenedFromMain = nil   -- (so hiding this doesn't bring the main window back)
    F:Hide()
    open()
    local win = _G[target]
    if fromMain and win and win:IsShown() and TTS.MainFrame and TTS.MainFrame.OpenChild then
        TTS.MainFrame:OpenChild(win)
    end
end

local function Build()
    F = UI.Window("FCCGE_ChooseFrame", 300, 168, "Tournaments")

    local intro = UI.Label(F, "GameFontHighlightSmall", 20, -48, 260)
    intro:SetJustifyH("CENTER")
    intro:SetText("Join an event with the organizer's code, or run one of your own.")

    local join = UI.Button(F, "Join an Event", 200, 26, function()
        Pick(UI.OpenPlayer, "FCCGE_PlayerFrame")
    end)
    join:SetPoint("TOP", 0, -84)
    local host = UI.Button(F, "Host an Event", 200, 26, function()
        Pick(UI.OpenOrganizer, "FCCGE_OrganizerFrame")
    end)
    host:SetPoint("TOP", join, "BOTTOM", 0, -6)
end

-- Opens the right window and returns it: the event's, if there is one, or this one
function UI.OpenTournaments()
    if H:Event() then
        UI.OpenOrganizer()
        return _G.FCCGE_OrganizerFrame
    end
    if P:Joined() then
        UI.OpenPlayer()
        return _G.FCCGE_PlayerFrame
    end
    if not F then Build() end
    F:Show()
    return F
end
