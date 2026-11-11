--[[
    ForeverCCG Events
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.
]]
local _, ns = ...
local UI, B, Comm, H, P = ns.UI, ns.Bridge, ns.Comm, ns.Host, ns.Player

-- =========================================================================
-- START-UP AND SLASH COMMANDS
--   /fccgevents                       the player's window
--   /fccgevents host                  the organizer's window
--   /fccgevents join <code> <name>    join the event <name> is running
--   /fccgevents leave                 leave the current event
-- Part of ForeverCCG (Events\, loaded after the rest in ForeverCCG.toc); the main window's
-- Tournaments button opens it.
-- =========================================================================
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    if not B.Ready() then
        ns.Print("ForeverCCG isn't loaded, so results can't be reported.")
        return
    end
    B.Install(function(info) P:OnGameStart(info) end, function(info, outcome) P:OnGameEnd(info, outcome) end)
    Comm:Start()
    H:OnLogin()
    P:OnLogin()
end)

local function Toggle()
    if UI.IsPlayerOpen() then
        UI.ClosePlayer()
    else
        UI.OpenPlayer()
    end
end

-- The main window's Tournaments button (UI\MainFrame.lua): Join or Host first (UI\Choose.lua),
-- or straight to the event's window when there is one. Returns the window opened, for the
-- main window to come back to when it closes.
TTS = TTS or {}
function TTS:OpenTournaments()
    return UI.OpenTournaments()
end

SLASH_FCCGEVENTS1 = "/fccgevents"
SLASH_FCCGEVENTS2 = "/fccge"
SlashCmdList["FCCGEVENTS"] = function(msg)
    msg = (msg or ""):trim()
    local command = (msg:match("^(%S+)") or ""):lower()
    if command == "host" then
        UI.OpenOrganizer()
    elseif command == "join" then
        local code, organizer = msg:match("^%S+%s+(%S+)%s+(.+)$")
        if code then
            P:Join(code, organizer)
        else
            ns.Print("Usage: /fccgevents join <code> <organizer's name>")
        end
    elseif command == "leave" then
        P:Leave()
    else
        Toggle()
    end
end
