--[[
    ForeverCCG Events
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.
]]
local _, ns = ...
local UI, B, P = ns.UI, ns.Bridge, ns.Player

-- =========================================================================
-- PLAYER WINDOW
-- Before joining: the code, the organizer's name. After: the event, this round's pairing, the
-- deck to play (locked at check-in with deck lock), your place, and either the standings or
-- this round's tables (Watch on games being played). Built the first time it opens.
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

-- 1st, 2nd, 3rd, 4th ... 11th, 12th, 13th, 21st
local function Ordinal(n)
    local last2, last = n % 100, n % 10
    local suffix = (last2 >= 11 and last2 <= 13) and "th" or (last == 1 and "st") or (last == 2 and "nd")
        or (last == 3 and "rd") or "th"
    return n .. suffix
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

    -- The deck: chosen here, until deck lock fixes it at check-in
    local decks, active = B.Decks()
    wipe(F.deckOptions)
    for _, d in ipairs(decks) do
        if d.playable then F.deckOptions[#F.deckOptions + 1] = { d.index, d.name .. GREY .. " (" .. d.cards .. ")|r" } end
    end
    local locked = j.deckLock and j.myStatus ~= "registered" and j.status ~= "finished"
    if #F.deckOptions == 0 then
        F.deckOptions[1] = { 0, RED .. "No playable deck|r" }
        F.deckDrop.index = 1
        F.deckDrop:SetValue(0)
        F.deckDrop:SetEnabled(false)
    else
        -- (an active deck that isn't playable isn't listed: the first that is is shown)
        local listed = false
        for _, o in ipairs(F.deckOptions) do if o[1] == active then listed = true end end
        F.deckDrop.index = 1
        F.deckDrop:SetValue(listed and active or F.deckOptions[1][1])
        F.deckDrop:SetEnabled((not locked and j.status ~= "finished" and not B.InMatch()) and true or false)
    end
    F.deckNote:SetText(locked and (GREY .. "locked at check-in|r") or "")

    -- You: your place, points and record
    local me
    for _, r in ipairs(j.standings or {}) do
        if B.SameName(r.name, B.MyName()) then me = r end
    end
    if me then
        F.me:SetText("You: |cFFFFFFFF" .. Ordinal(me.rank) .. "|r of " .. #j.standings .. "    " .. me.points
            .. " pts    " .. me.wins .. "-" .. me.losses .. "-" .. me.draws)
    else
        F.me:SetText(GREY .. "Your place in the standings shows once the first round starts.|r")
    end

    F.checkIn:SetShown(j.status == "checkin" and j.myStatus == "registered")
    local canChallenge = j.status == "running" and j.tableNo > 0 and j.matchStatus ~= "bye" and j.result == ""
        and j.myStatus == "active" and not B.InMatch()
    F.challenge:SetShown(j.status == "running" and j.tableNo > 0 and j.matchStatus ~= "bye")
    F.challenge:SetEnabled(canChallenge and true or false)
    F.leave:SetText(j.status == "finished" and "Close" or "Drop Out")
    F.list:SetData(j.standings or {})
    local rows = (j.pairings and j.pairings.round == j.round) and j.pairings.rows or {}
    F.roundList:SetData(rows)
    F.roundEmpty:SetShown((F.showRound and #rows == 0) and true or false)
    F.tabStandings:SetEnabled(F.showRound and true or false)
    F.tabRound:SetEnabled(not F.showRound)
    F.tabRound:SetText((j.round or 0) > 0 and ("Round " .. j.round) or "This Round")
    RefreshClock()
end

-- Shows the standings, or this round's tables (round = true)
local function ShowList(round)
    F.showRound = round
    for _, w in ipairs(F.standingsWidgets) do w:SetShown(not round) end
    for _, w in ipairs(F.roundWidgets) do w:SetShown(round) end
    local j = P:Joined()
    if j then RefreshJoined(j) end
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
    -- The deck you play with (B.Decks: the playable ones), and the round's clock beside it
    UI.Label(V, "GameFontNormalSmall", 12, -97):SetText("Deck")
    F.deckOptions = {}
    F.deckDrop = UI.Dropdown(V, 170, F.deckOptions, function(index)
        if index and index > 0 then B.SetActiveDeck(index) end
    end)
    F.deckDrop:SetPoint("TOPLEFT", 46, -92)
    F.deckNote = UI.Label(V, "GameFontDisableSmall", 222, -97, 100)
    F.clock = UI.Label(V, "GameFontHighlightSmall", 230, -97, 160)
    F.clock:SetJustifyH("RIGHT")
    F.me = UI.Label(V, "GameFontHighlightSmall", 12, -122, 370)

    F.checkIn = UI.Button(V, "Check In", 110, 24, function() P:CheckIn() end)
    F.checkIn:SetPoint("TOPLEFT", 12, -142)
    F.challenge = UI.Button(V, "Challenge", 110, 24, function() P:Challenge() end)
    F.challenge:SetPoint("TOPLEFT", 12, -142)
    local refresh = UI.Button(V, "Refresh", 80, 24, function() P:RequestUpdate(true) end)
    refresh:SetPoint("TOPLEFT", 130, -142)
    F.leave = UI.Button(V, "Drop Out", 90, 24, function()
        local j = P:Joined()
        if j and j.status == "finished" then
            P:Leave()
        else
            UI.Confirm("Drop out of this event? During a round you forfeit your match.", function() P:Leave() end)
        end
    end)
    F.leave:SetPoint("TOPRIGHT", -14, -142)

    -- Standings, or this round's tables (with a Watch button on games being played)
    F.tabStandings = UI.Button(V, "Standings", 100, 22, function() ShowList(false) end)
    F.tabStandings:SetPoint("TOPLEFT", 12, -176)
    F.tabRound = UI.Button(V, "This Round", 100, 22, function() ShowList(true) end)
    F.tabRound:SetPoint("LEFT", F.tabStandings, "RIGHT", 4, 0)

    F.standingsWidgets = {
        UI.Label(V, "GameFontNormalSmall", 16, -206), UI.Label(V, "GameFontNormalSmall", 46, -206),
        UI.Label(V, "GameFontNormalSmall", 256, -206), UI.Label(V, "GameFontNormalSmall", 306, -206) }
    F.standingsWidgets[1]:SetText("#")
    F.standingsWidgets[2]:SetText("Player")
    F.standingsWidgets[3]:SetText("Pts")
    F.standingsWidgets[4]:SetText("W-L-D")
    F.list = UI.List(V, 12, -222, 370, 20, 8, function(row)
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
    F.standingsWidgets[5] = F.list.holder

    F.roundWidgets = {
        UI.Label(V, "GameFontNormalSmall", 16, -206), UI.Label(V, "GameFontNormalSmall", 46, -206),
        UI.Label(V, "GameFontNormalSmall", 236, -206) }
    F.roundWidgets[1]:SetText("T")
    F.roundWidgets[2]:SetText("Match")
    F.roundWidgets[3]:SetText("Games")
    F.roundList = UI.List(V, 12, -222, 370, 20, 8, function(row)
        row.number = UI.Label(row, "GameFontNormalSmall", 4, -4, 28)
        row.players = UI.Label(row, "GameFontHighlightSmall", 34, -4, 190)
        row.score = UI.Label(row, "GameFontHighlightSmall", 226, -4, 76)
        row.watch = UI.Button(row, "Watch", 60, 18, function()
            if row.watchName and TTS.Spectate then TTS.Spectate:Watch(row.watchName) end
        end)
        row.watch:SetPoint("RIGHT", -4, 0)
    end, function(row, m)
        row.number:SetText(m.table)
        local mine = B.SameName(m.a, B.MyName()) or B.SameName(m.b, B.MyName())
        local names = (m.status == "bye") and (m.a .. GREY .. "  (bye)|r") or (m.a .. GREY .. " vs |r" .. m.b)
        row.players:SetText(mine and (UI.GOLD .. (names:gsub("|r", "|r" .. UI.GOLD)) .. "|r") or names)
        local state = (m.status == "bye") and "" or (m.aWins .. "-" .. m.bWins)
        if m.status == "playing" then state = state .. GREEN .. "  live|r"
        elseif m.status == "done" then state = state .. GREY .. "  done|r"
        elseif m.status == "disputed" then state = state .. RED .. "  disputed|r" end
        row.score:SetText(state)
        -- Watch a game being played that isn't ours (Spectate.lua asks one of its players)
        row.watchName = (m.status == "playing" and not mine and m.b ~= "") and m.a or nil
        row.watch:SetShown(row.watchName ~= nil)
        row.watch:SetEnabled(not B.InMatch())
    end)
    F.roundWidgets[4] = F.roundList.holder
    F.roundEmpty = UI.Label(V, "GameFontDisableSmall", 16, -232, 360)
    F.roundEmpty:SetText("No round under way yet.")
    F.roundWidgets[5] = F.roundEmpty
    ShowList(false)

    F.elapsed, F.sincePull = 0, 0
    F:SetScript("OnUpdate", function(self, delta)
        self.elapsed = self.elapsed + delta
        self.sincePull = self.sincePull + delta
        if self.elapsed >= 1 then
            self.elapsed = 0
            RefreshClock()
        end
        -- (the organizer sends them at most every 15 seconds: Host.lua STAND_COOLDOWN)
        local j = P:Joined()
        if self.sincePull >= 20 and j and j.status == "running" then
            self.sincePull = 0
            P:RequestUpdate(true)
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
