--[[
    ForeverCCG Events
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.
]]
local _, ns = ...
local UI, B, P = ns.UI, ns.Bridge, ns.Player

-- =========================================================================
-- PLAYER WINDOW
-- Before joining: the code, the organizer's name. After: the event, this round's pairing, the
-- standings. Built the first time it opens.
-- =========================================================================
local GREY, GREEN, RED, ORANGE = UI.GREY, UI.GREEN, UI.RED, UI.ORANGE
local F

local FORMAT_TEXT = { swiss = "Swiss", single = "Single elimination" }

local function RefreshClock()
    local j = P:Joined()
    if not (F and j) then return end
    if j.status == "running" and j.endsAt then
        local left = j.endsAt - ns.Now()
        F.clock:SetText(left > 0 and ("Round time: " .. UI.Clock(left)) or (ORANGE .. "Time's up|r"))
    else
        F.clock:SetText("")
    end
end

local function PairingText(j)
    if j.status == "finished" then
        return j.champion ~= "" and ("Champion: |cFFFFFFFF" .. tostring(j.champion) .. "|r") or "The event has finished."
    end
    if j.status ~= "running" then
        if j.myStatus == "checkedin" then return GREEN .. "You're checked in.|r Waiting for the first round." end
        if j.status == "checkin" then return ORANGE .. "Check-in is open.|r Pick your deck and check in." end
        return "Waiting for the organizer to open check-in."
    end
    if j.myStatus == "dropped" then return GREY .. "You've dropped from this event.|r" end
    if j.tableNo == 0 then return GREY .. "You aren't in this round.|r" end
    if j.matchStatus == "bye" then return "Round " .. j.round .. ": you have a bye." end
    return "Round " .. j.round .. " of " .. j.rounds .. ", table " .. j.tableNo .. ": |cFFFFFFFF" .. j.opponent .. "|r"
end

local function MatchText(j)
    if j.status ~= "running" or j.tableNo == 0 or j.matchStatus == "bye" then return "" end
    local score = "Games " .. (j.myWins or 0) .. "-" .. (j.theirWins or 0)
    local state
    if j.result == "win" then
        state = GREEN .. "You won the match.|r"
    elseif j.result == "loss" then
        state = RED .. "You lost the match.|r"
    elseif j.result == "draw" then
        state = "The match was a draw."
    elseif j.matchStatus == "disputed" then
        state = RED .. "Disputed: the organizer will decide.|r"
    else
        state = "Use Challenge to start your game."
    end
    return score .. "   " .. state .. ((j.note and j.note ~= "") and (GREY .. "   " .. j.note .. "|r") or "")
end

local function RefreshJoined(j)
    F.eventName:SetText(j.name or "Tournament")
    local details = (FORMAT_TEXT[j.format] or "") .. ", best of " .. tostring(j.bestOf or 1)
    if j.deckLock then details = details .. ", deck lock" end
    if j.prizes then
        -- Whether this player could take the prize (ForeverCCG's prize cooldown). Once the event
        -- has begun, playing in it has started a new cooldown, so it's only shown before then.
        local wait = not j.prizeEntered and B.PrizeCooldown()
        if wait and wait <= 0 then
            details = details .. ", prize card (" .. GREEN .. "you're eligible|r" .. GREY .. ")"
        elseif wait then
            local days = math.ceil(wait / 86400)
            details = details .. ", prize card (" .. ORANGE .. "cooldown " .. days .. (days == 1 and " day" or " days") .. "|r" .. GREY .. ")"
        else
            details = details .. ", prize card"
        end
    end
    F.details:SetText(GREY .. details .. "   " .. (UI.STATUS_TEXT[j.status] or "") .. "|r")
    F.pairing:SetText(PairingText(j))
    F.match:SetText(MatchText(j))

    local deck = B.ActiveDeck()
    F.deck:SetText("Active deck: " .. ((deck and deck.name) or "none"))
    F.deck:SetShown(j.status == "checkin" or j.status == "open")

    F.checkIn:SetShown(j.status == "checkin" and j.myStatus == "registered")
    local canChallenge = j.status == "running" and j.tableNo > 0 and j.matchStatus ~= "bye" and j.result == ""
        and j.myStatus == "active" and not B.InMatch()
    F.challenge:SetShown(j.status == "running" and j.tableNo > 0 and j.matchStatus ~= "bye")
    F.challenge:SetEnabled(canChallenge and true or false)
    F.leave:SetText(j.status == "finished" and "Close" or "Drop Out")
    F.list:SetData(j.standings or {})
    RefreshClock()
end

local function Refresh()
    if not (F and F:IsShown()) then return end
    local j = P:Joined()
    F.joinPanel:SetShown(not j)
    F.eventPanel:SetShown(j and true or false)
    if j then RefreshJoined(j) end
end

local function Build()
    F = UI.Window("FCCGE_PlayerFrame", 420, 470, "Tournaments")

    -- Not in an event
    local J = CreateFrame("Frame", nil, F)
    J:SetPoint("TOPLEFT", 12, -44)
    J:SetPoint("BOTTOMRIGHT", -12, 14)
    F.joinPanel = J

    local intro = UI.Label(J, "GameFontHighlight", 12, -8)
    intro:SetWidth(370)
    intro:SetJustifyH("LEFT")
    intro:SetText("Ask the organizer for their join code and their character's full name.")

    local function DoJoin()
        P:Join(F.codeBox:GetText(), F.organizerBox:GetText())
    end
    UI.Label(J, "GameFontNormalSmall", 12, -56):SetText("Join code")
    F.codeBox = UI.Edit(J, 120, DoJoin)
    F.codeBox:SetPoint("TOPLEFT", 110, -50)
    UI.Label(J, "GameFontNormalSmall", 12, -86):SetText("Organizer")
    F.organizerBox = UI.Edit(J, 200, DoJoin)
    F.organizerBox:SetPoint("TOPLEFT", 110, -80)
    local join = UI.Button(J, "Join Event", 130, 24, DoJoin)
    join:SetPoint("TOPLEFT", 110, -114)
    -- Back to Join or Host (UI\Choose.lua), which hosting is picked from
    local back = UI.Button(J, "Back", 100, 24, function() UI.BackToTournaments(F) end)
    back:SetPoint("BOTTOMLEFT", 12, 8)

    -- In an event
    local V = CreateFrame("Frame", nil, F)
    V:SetPoint("TOPLEFT", 12, -44)
    V:SetPoint("BOTTOMRIGHT", -12, 14)
    F.eventPanel = V

    F.eventName = UI.Label(V, "GameFontNormalLarge", 12, -6, 370)
    F.details = UI.Label(V, "GameFontHighlightSmall", 12, -28, 370)
    F.pairing = UI.Label(V, "GameFontHighlight", 12, -52, 370)
    F.match = UI.Label(V, "GameFontHighlightSmall", 12, -74, 370)
    F.clock = UI.Label(V, "GameFontHighlightSmall", 12, -92, 370)
    F.deck = UI.Label(V, "GameFontHighlightSmall", 12, -92, 370)

    F.checkIn = UI.Button(V, "Check In", 110, 24, function() P:CheckIn() end)
    F.checkIn:SetPoint("TOPLEFT", 12, -112)
    F.challenge = UI.Button(V, "Challenge", 110, 24, function() P:Challenge() end)
    F.challenge:SetPoint("TOPLEFT", 12, -112)
    local refresh = UI.Button(V, "Refresh", 80, 24, function() P:RequestUpdate(true) end)
    refresh:SetPoint("TOPLEFT", 130, -112)
    F.leave = UI.Button(V, "Drop Out", 90, 24, function()
        local j = P:Joined()
        if j and j.status == "finished" then
            P:Leave()
        else
            UI.Confirm("Drop out of this event? During a round you forfeit your match.", function() P:Leave() end)
        end
    end)
    F.leave:SetPoint("TOPRIGHT", -14, -112)

    UI.Label(V, "GameFontNormalSmall", 16, -146):SetText("#")
    UI.Label(V, "GameFontNormalSmall", 46, -146):SetText("Player")
    UI.Label(V, "GameFontNormalSmall", 256, -146):SetText("Pts")
    UI.Label(V, "GameFontNormalSmall", 306, -146):SetText("W-L-D")
    F.list = UI.List(V, 12, -162, 370, 20, 11, function(row)
        row.rank = UI.Label(row, "GameFontNormalSmall", 4, -4, 28)
        row.name = UI.Label(row, "GameFontHighlightSmall", 34, -4, 205)
        row.points = UI.Label(row, "GameFontHighlightSmall", 244, -4, 45)
        row.record = UI.Label(row, "GameFontHighlightSmall", 294, -4, 70)
    end, function(row, r)
        row.rank:SetText(r.rank)
        row.name:SetText(r.dropped and (GREY .. r.name .. " (dropped)|r") or r.name)
        row.points:SetText(r.points)
        row.record:SetText(r.wins .. "-" .. r.losses .. "-" .. r.draws)
    end)

    F.elapsed = 0
    F:SetScript("OnUpdate", function(self, delta)
        self.elapsed = self.elapsed + delta
        if self.elapsed >= 1 then
            self.elapsed = 0
            RefreshClock()
        end
    end)
    F:SetScript("OnShow", function()
        Refresh()
        P:RequestUpdate(true)
    end)
end

function UI.OpenPlayer()
    if not F then Build() end
    F:Show()
    Refresh()
end

function UI.IsPlayerOpen()
    return F and F:IsShown() or false
end

function UI.ClosePlayer()
    if F then F:Hide() end
end

UI.AddRefresher(Refresh)
