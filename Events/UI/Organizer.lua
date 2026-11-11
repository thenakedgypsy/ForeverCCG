--[[
    ForeverCCG Events
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.
]]
local _, ns = ...
local UI, T, B, H = ns.UI, ns.Tournament, ns.Bridge, ns.Host

-- =========================================================================
-- ORGANIZER WINDOW
-- Setup (the settings, the join code), Players, Round (pairings, results, disputes),
-- Standings and Log. Built the first time it opens.
-- =========================================================================
local GREY, RED, ORANGE, GREEN = UI.GREY, UI.RED, UI.ORANGE, UI.GREEN

local F
local panels, tabs = {}, {}
local shownPanel = "setup"
local selectedTable
local ANNOUNCE_CHANNELS = { { "SAY", "Say" }, { "YELL", "Yell" }, { "GUILD", "Guild" }, { "PARTY", "Party" }, { "RAID", "Raid" } }

local form = {}

-- =========================================================================
-- SETUP
-- =========================================================================
local function Options(list, labelFor)
    local out = {}
    for _, value in ipairs(list) do out[#out + 1] = { value, labelFor(value) } end
    return out
end

local function Minutes(v) return v == 0 and "None" or (v .. " min") end

-- The cards banned in the event being set up (ids), and the button's count of them
local bannedIds = {}
local function ShowBannedCount()
    local n = #bannedIds
    form.banned:SetText(n == 0 and "Choose cards (none banned)" or ("Choose cards (" .. n .. " banned)"))
end

local function BuildSetup(P)
    local rowY = -8
    local function Row(left, leftWidget, right, rightWidget)
        local a = UI.Label(P, "GameFontNormalSmall", 12, rowY - 5)
        a:SetText(left)
        leftWidget:SetPoint("TOPLEFT", 130, rowY)
        if right then
            local b = UI.Label(P, "GameFontNormalSmall", 312, rowY - 5)
            b:SetText(right)
            rightWidget:SetPoint("TOPLEFT", 440, rowY)
        end
        rowY = rowY - 30
    end

    form.name = UI.Edit(P, 450)
    Row("Event name", form.name)

    form.format = UI.Dropdown(P, 150, { { "swiss", "Swiss" }, { "single", "Single elimination" } })
    form.bestOf = UI.Dropdown(P, 150, { { 1, "Best of 1" }, { 3, "Best of 3" }, { 5, "Best of 5" } })
    Row("Format", form.format, "Games", form.bestOf)

    local roundChoices = { { 0, "Automatic" } }
    for i = 1, 12 do roundChoices[#roundChoices + 1] = { i, i .. " rounds" } end
    form.rounds = UI.Dropdown(P, 150, roundChoices, function(value)
        if H:Event() then H:SetRounds(value) end
    end)
    form.roundMinutes = UI.Dropdown(P, 150, Options({ 0, 15, 20, 25, 30, 40, 50, 60, 90 }, Minutes))
    Row("Swiss rounds", form.rounds, "Round time", form.roundMinutes)
    form.roundMinutes:SetValue(T.DEFAULTS.roundMinutes)

    form.maxPlayers = UI.Dropdown(P, 150, Options({ 4, 6, 8, 16, 32, 64 }, function(v) return v .. " players" end))
    form.maxPlayers:SetValue(T.DEFAULTS.maxPlayers)
    form.deckLock = UI.Dropdown(P, 150, { { false, "Off" }, { true, "On" } })
    Row("Player limit", form.maxPlayers, "Deck lock", form.deckLock)

    form.minRating = UI.Edit(P, 140)
    form.maxRating = UI.Edit(P, 140)
    Row("Minimum rating", form.minRating, "Maximum rating", form.maxRating)

    form.maxScore = UI.Edit(P, 140)
    form.noShowMinutes = UI.Dropdown(P, 150, Options({ 0, 5, 10, 15, 20 }, function(v) return v == 0 and "Off" or (v .. " min") end))
    form.noShowMinutes:SetValue(T.DEFAULTS.noShowMinutes)
    Row("Max collection score", form.maxScore, "No-show forfeit", form.noShowMinutes)

    form.disconnect = UI.Dropdown(P, 150, { { "rematch", "Replay the game" }, { "award", "Award the game" } })
    form.disconnectMinutes = UI.Dropdown(P, 150, Options({ 3, 5, 10, 15 }, Minutes))
    form.disconnectMinutes:SetValue(T.DEFAULTS.disconnectMinutes)
    Row("On a disconnect", form.disconnect, "Award after", form.disconnectMinutes)

    -- Prizes: the champion's own client claims a prize card (ForeverCCG AdminGrants.lua), and
    -- everyone who plays starts the week's prize cooldown
    form.prizes = UI.Dropdown(P, 150, { { false, "Off" }, { true, "On" } })
    Row("Prizes", form.prizes)
    -- Two lines beside the dropdown, inside the panel's right edge
    local prizeHint = UI.Label(P, "GameFontDisableSmall", 290, rowY + 30 + 1, 310)
    prizeHint:SetWordWrap(true)
    prizeHint:SetText("Champion wins a prize card; all players start a week's cooldown.")

    -- Banned cards: picked in their own window (UI\BanPicker.lua); the button says how many
    bannedIds = {}
    form.banned = UI.Button(P, "", 200, 22, function()
        UI.OpenBanPicker(bannedIds, function(ids)
            bannedIds = ids
            ShowBannedCount()
        end)
    end)
    ShowBannedCount()
    Row("Banned cards", form.banned)
    local hint = UI.Label(P, "GameFontDisableSmall", 130, rowY + 6)
    hint:SetText("Leave number boxes empty for no limit.")
    rowY = rowY - 12

    P.create = UI.Button(P, "Create Event", 130, 24, function()
        local ids = {}
        for i, id in ipairs(bannedIds) do ids[i] = id end
        H:Create(form.name:GetText(), {
            format = form.format:GetValue(), bestOf = form.bestOf:GetValue(), rounds = form.rounds:GetValue(),
            roundMinutes = form.roundMinutes:GetValue(), maxPlayers = form.maxPlayers:GetValue(),
            deckLock = form.deckLock:GetValue(), noShowMinutes = form.noShowMinutes:GetValue(),
            disconnect = form.disconnect:GetValue(), disconnectMinutes = form.disconnectMinutes:GetValue(),
            minRating = tonumber(form.minRating:GetText()) or 0, maxRating = tonumber(form.maxRating:GetText()) or 0,
            maxScore = tonumber(form.maxScore:GetText()) or 0, banned = ids,
            prizes = form.prizes:GetValue(),
        })
    end)
    P.create:SetPoint("TOPLEFT", 12, rowY)

    P.close = UI.Button(P, "Close Event", 130, 24, function()
        local ev = H:Event()
        local unfinished = ev and ev.status ~= "finished"
        UI.Confirm(unfinished and "Close this event? It hasn't finished, and players will be told it's over."
            or "Close this event? It stays in your saved history.", function() H:Close() end)
    end)
    P.close:SetPoint("TOPLEFT", 12, rowY)

    P.code = UI.Label(P, "GameFontNormalHuge", 160, rowY - 2)
    P.announceChannel = UI.Dropdown(P, 80, ANNOUNCE_CHANNELS)
    P.announceChannel:SetPoint("TOPLEFT", 376, rowY)
    P.announce = UI.Button(P, "Announce", 100, 22, function()
        H:Announce(P.announceChannel:GetValue())
    end)
    P.announce:SetPoint("LEFT", P.announceChannel, "RIGHT", 6, 0)
end

local function SetFormEnabled(on)
    for key, widget in pairs(form) do
        if key ~= "rounds" then
            if widget.SetEnabled then widget:SetEnabled(on) end
        end
    end
end

local function RefreshSetup(P)
    local ev = H:Event()
    P.create:SetShown(not ev)
    P.close:SetShown(ev and true or false)
    P.code:SetShown(ev and true or false)
    P.announce:SetEnabled(ev and true or false)
    P.announceChannel:SetEnabled(ev and true or false)
    SetFormEnabled(not ev)
    form.rounds:SetEnabled(not ev or (ev.settings.format == "swiss" and ev.status ~= "finished"))
    if not ev then return end

    local s = ev.settings
    P.code:SetText("Code: |cFFFFFFFF" .. ev.code .. "|r")
    form.name:SetText(ev.name)
    form.format:SetValue(s.format)
    form.bestOf:SetValue(s.bestOf)
    form.rounds:SetValue(s.rounds)
    form.roundMinutes:SetValue(s.roundMinutes)
    form.maxPlayers:SetValue(s.maxPlayers)
    form.deckLock:SetValue(s.deckLock)
    form.noShowMinutes:SetValue(s.noShowMinutes)
    form.disconnect:SetValue(s.disconnect)
    form.disconnectMinutes:SetValue(s.disconnectMinutes)
    form.prizes:SetValue(s.prizes and true or false)
    form.minRating:SetText(s.minRating > 0 and s.minRating or "")
    form.maxRating:SetText(s.maxRating > 0 and s.maxRating or "")
    form.maxScore:SetText(s.maxScore > 0 and s.maxScore or "")
    bannedIds = {}
    for i, id in ipairs(s.banned) do bannedIds[i] = id end
    ShowBannedCount()
end

-- =========================================================================
-- PLAYERS
-- =========================================================================
local function BuildPlayers(P)
    P.count = UI.Label(P, "GameFontNormal", 12, -8)
    -- The organizer can play in their own event: joined like anyone else, with the code
    -- (the player's window opens as the organizer's addon answers; they can't win its prize)
    P.joinSelf = UI.Button(P, "Join as a Player", 130, 22, function()
        local ev = H:Event()
        if ev and ns.Player then ns.Player:Join(ev.code, B.MyName()) end
    end)
    P.joinSelf:SetPoint("TOPRIGHT", -14, -4)
    P.list = UI.List(P, 12, -30, 590, 22, 16, function(row)
        row.name = UI.Label(row, "GameFontHighlightSmall", 4, -5, 190)
        row.rating = UI.Label(row, "GameFontHighlightSmall", 198, -5, 45)
        row.status = UI.Label(row, "GameFontHighlightSmall", 246, -5, 80)
        row.prize = UI.Label(row, "GameFontHighlightSmall", 330, -5, 110)
        row.seen = UI.Label(row, "GameFontDisableSmall", 444, -5, 80)
        row.drop = UI.Button(row, "Drop", 60, 18, function()
            local item = row.item
            if item then
                UI.Confirm("Drop " .. item.name .. " from the event?", function() H:DropPlayer(item.key) end)
            end
        end)
        row.drop:SetPoint("RIGHT", -2, 0)
    end, function(row, p)
        row.name:SetText(p.name .. (p.manual and (GREY .. " (no addon)|r") or ""))
        row.rating:SetText(p.rating or "-")
        row.status:SetText(UI.PLAYER_TEXT[p.status] or p.status)
        row.prize:SetText(H:Event().settings.prizes and UI.PrizeText(p) or "")
        row.seen:SetText(p.lastSeen and date("heard %H:%M", p.lastSeen) or "")
        row.drop:SetEnabled(p.status ~= "dropped" and p.status ~= "noshow" and H:Event().status ~= "finished")
    end)
    local label = UI.Label(P, "GameFontNormalSmall", 12, -392)
    label:SetText("Add a player without the addon:")
    local function AddPlayer()
        H:AddManual(P.manualName:GetText(), tonumber(P.manualRating:GetText()))
        P.manualName:SetText("")
        P.manualRating:SetText("")
    end
    P.manualName = UI.Edit(P, 180, AddPlayer)
    P.manualName:SetPoint("TOPLEFT", 205, -388)
    P.manualRating = UI.Edit(P, 60, AddPlayer)
    P.manualRating:SetPoint("LEFT", P.manualName, "RIGHT", 10, 0)
    P.manualAdd = UI.Button(P, "Add", 60, 22, AddPlayer)
    P.manualAdd:SetPoint("LEFT", P.manualRating, "RIGHT", 8, 0)
end

local function RefreshPlayers(P)
    local ev = H:Event()
    local data, checkedIn = {}, 0
    for _, key in ipairs(ev and ev.order or {}) do
        local p = ev.players[key]
        data[#data + 1] = p
        if p.status == "checkedin" or p.status == "active" then checkedIn = checkedIn + 1 end
    end
    local count = #data .. " entered, " .. checkedIn .. " checked in"
    if ev and ev.settings.prizes then
        local eligible = 0
        for _, p in ipairs(data) do
            if not p.manual and p.prizeWait and p.prizeWait - (ns.Now() - (p.prizeHeard or ns.Now())) <= 0 then
                eligible = eligible + 1
            end
        end
        count = count .. ", " .. eligible .. " prize eligible"
    end
    P.count:SetText(count)
    P.list:SetData(data)
    local joined = ns.Player and ns.Player:Joined()
    local playing = ev and ev.players[B.Key(B.MyName())] and true or false
    P.joinSelf:SetShown(ev and (ev.status == "open" or ev.status == "checkin") and true or false)
    P.joinSelf:SetEnabled(not playing and not (joined and ev and joined.id == ev.id))
    local canAdd = ev and (ev.status == "open" or ev.status == "checkin") and true or false
    P.manualAdd:SetEnabled(canAdd)
end

-- =========================================================================
-- ROUND
-- =========================================================================
local function Short(name)
    name = (name or "?"):match("^(%S+)") or "?"
    return name:sub(1, 10)
end

local function MatchStatus(ev, m)
    if m.empty then return GREY .. "Empty|r" end
    if m.bye then return GREY .. "Bye|r" end
    local text
    if m.result == "draw" then
        text = "Draw"
    elseif m.result then
        text = GREEN .. Short(T.NameOf(ev, m[m.result])) .. " wins|r"
    elseif m.status == "disputed" then
        text = RED .. "DISPUTED|r"
    elseif m.overtime then
        text = ORANGE .. "OUT OF TIME|r"
    elseif m.noShow then
        text = ORANGE .. "NO ANSWER|r"
    elseif m.status == "playing" then
        text = "Playing"
    else
        text = GREY .. "Waiting|r"
    end
    local f = m.flags or {}
    if f.decka or f.deckb then text = text .. RED .. " deck!|r" end
    if f.illegala or f.illegalb then text = text .. RED .. " banned!|r" end
    return text
end

local function SelectedMatch(ev)
    local round = ev and T.CurrentRound(ev)
    return round and selectedTable and round.matches[selectedTable] or nil
end

local function RefreshClock(P)
    local ev = H:Event()
    if not ev then
        P.header:SetText("No event yet")
        return
    end
    local text = UI.STATUS_TEXT[ev.status] or ev.status
    local round = T.CurrentRound(ev)
    if ev.status == "running" and round then
        text = "Round " .. round.number .. " of " .. ev.totalRounds
        if round.endsAt then
            local left = round.endsAt - ns.Now()
            text = text .. "   " .. (left > 0 and UI.Clock(left) or (ORANGE .. "time's up|r"))
        end
    end
    P.header:SetText(text)
end

local function RefreshActions(P)
    local ev = H:Event()
    local running = ev and ev.status == "running"
    local m = running and SelectedMatch(ev) or nil
    local playable = m and not m.bye and not m.empty

    if playable then
        local a, b = Short(T.NameOf(ev, m.a)), Short(T.NameOf(ev, m.b))
        P.selected:SetText("Table " .. m.table .. ": " .. T.NameOf(ev, m.a) .. " vs " .. T.NameOf(ev, m.b)
            .. (m.note and (GREY .. "   " .. m.note .. "|r") or ""))
        P.gameA:SetText("Game: " .. a)
        P.gameB:SetText("Game: " .. b)
        P.winA:SetText("Match: " .. a)
        P.winB:SetText("Match: " .. b)
    else
        P.selected:SetText(GREY .. "Click a table to decide or change its result.|r")
    end
    local open = playable and not m.result
    P.gameA:SetEnabled(open and true or false)
    P.gameB:SetEnabled(open and true or false)
    P.winA:SetEnabled(playable and true or false)
    P.winB:SetEnabled(playable and true or false)
    P.draw:SetEnabled((playable and T.Format(ev).allowDraw) and true or false)
    P.void:SetEnabled((playable and m.status == "disputed") and true or false)
    P.reset:SetEnabled(playable and true or false)
    P.watch:SetEnabled((playable and m.status == "playing" and not B.InMatch()) and true or false)
end

local function RefreshRound(P)
    local ev = H:Event()
    RefreshClock(P)
    local round = ev and T.CurrentRound(ev)
    P.list:SetData(round and round.matches or {})

    local advance = P.advance
    advance:Show()
    advance:SetEnabled(true)
    P.endRound:SetEnabled(false)
    if not ev then
        advance:Hide()
    elseif ev.status == "open" then
        advance:SetText("Open Check-In")
    elseif ev.status == "checkin" then
        advance:SetText("Start Event")
    elseif ev.status == "running" then
        local complete = T.RoundComplete(round)
        advance:SetEnabled(complete)
        advance:SetText((complete and T.IsLastRound(ev)) and "Finish Event" or "Next Round")
        P.endRound:SetEnabled(not complete and T.Format(ev).allowDraw and true or false)
    else
        advance:SetText("Finished")
        advance:SetEnabled(false)
    end
    RefreshActions(P)
end

local function BuildRound(P)
    P.header = UI.Label(P, "GameFontNormalLarge", 12, -8, 330)
    P.advance = UI.Button(P, "", 120, 24, function()
        local ev = H:Event()
        if not ev then return end
        if ev.status == "open" then
            H:OpenCheckIn()
        elseif ev.status == "checkin" then
            local waiting = 0
            for _, key in ipairs(ev.order) do
                if ev.players[key].status == "registered" then waiting = waiting + 1 end
            end
            if waiting > 0 then
                UI.Confirm(waiting .. " player(s) haven't checked in and will be left out. Start anyway?", function() H:Start() end)
            else
                H:Start()
            end
        else
            selectedTable = nil
            H:Advance()
        end
    end)
    P.advance:SetPoint("TOPRIGHT", -14, -6)
    P.endRound = UI.Button(P, "End Round", 100, 24, function()
        UI.Confirm("End the round now? Every undecided match becomes a draw.", function() H:EndRound() end)
    end)
    P.endRound:SetPoint("RIGHT", P.advance, "LEFT", -6, 0)

    P.list = UI.List(P, 12, -38, 590, 22, 14, function(row)
        row.number = UI.Label(row, "GameFontNormalSmall", 4, -5, 30)
        row.a = UI.Label(row, "GameFontHighlightSmall", 36, -5, 165)
        row.score = UI.Label(row, "GameFontNormalSmall", 205, -5, 40)
        row.b = UI.Label(row, "GameFontHighlightSmall", 250, -5, 165)
        row.status = UI.Label(row, "GameFontHighlightSmall", 420, -5, 165)
        row:SetScript("OnClick", function()
            if row.item then
                selectedTable = row.item.table
                RefreshActions(P)
            end
        end)
    end, function(row, m)
        local ev = H:Event()
        row.number:SetText(m.table)
        row.a:SetText(m.a and T.NameOf(ev, m.a) or "-")
        row.b:SetText(m.b and T.NameOf(ev, m.b) or "-")
        row.score:SetText((m.bye or m.empty) and "" or (m.wins.a .. " - " .. m.wins.b))
        row.status:SetText(MatchStatus(ev, m))
    end)

    P.selected = UI.Label(P, "GameFontHighlightSmall", 12, -356, 520)
    -- Watch the selected table's game while it's being played (Spectate.lua: the organizer
    -- may always watch an event game, Spectatable or not)
    P.watch = UI.Button(P, "Watch", 70, 20, function()
        local ev = H:Event()
        local m = ev and SelectedMatch(ev)
        if not (m and m.status == "playing" and TTS.Spectate) then return end
        local a, b = ev.players[m.a], m.b and ev.players[m.b]
        local who = (a and not a.manual) and a or b
        if who then TTS.Spectate:Watch(who.name) end
    end)
    P.watch:SetPoint("TOPRIGHT", -14, -352)
    local function OnTable(fn)
        return function()
            if selectedTable then fn(selectedTable) end
        end
    end
    local x = 12
    local function Action(key, text, width, fn)
        local b = UI.Button(P, text, width, 22, OnTable(fn))
        b:SetPoint("TOPLEFT", x, -376)
        x = x + width + 3
        P[key] = b
    end
    Action("gameA", "Game", 104, function(t) H:AwardGame(t, "a") end)
    Action("gameB", "Game", 104, function(t) H:AwardGame(t, "b") end)
    Action("winA", "Match", 104, function(t) H:SetResult(t, "a") end)
    Action("winB", "Match", 104, function(t) H:SetResult(t, "b") end)
    Action("draw", "Draw", 48, function(t) H:SetResult(t, "draw") end)
    Action("void", "Void", 48, function(t) H:VoidDisputes(t) end)
    Action("reset", "Reset", 48, function(t) H:ResetMatch(t) end)

    P.elapsed = 0
    P:SetScript("OnUpdate", function(self, delta)
        self.elapsed = self.elapsed + delta
        if self.elapsed >= 1 then
            self.elapsed = 0
            RefreshClock(self)
        end
    end)
end

-- =========================================================================
-- STANDINGS AND LOG
-- =========================================================================
local function BuildStandings(P)
    local head = UI.Label(P, "GameFontNormalSmall", 16, -8)
    head:SetText("#")
    local columns = { { "Player", 44 }, { "Pts", 280 }, { "W-L-D", 330 }, { "Opp %", 410 }, { "Game %", 470 } }
    for _, c in ipairs(columns) do
        UI.Label(P, "GameFontNormalSmall", c[2] + 12, -8):SetText(c[1])
    end
    P.list = UI.List(P, 12, -26, 590, 22, 17, function(row)
        row.rank = UI.Label(row, "GameFontNormalSmall", 4, -5, 30)
        row.name = UI.Label(row, "GameFontHighlightSmall", 44, -5, 230)
        row.points = UI.Label(row, "GameFontHighlightSmall", 280, -5, 45)
        row.record = UI.Label(row, "GameFontHighlightSmall", 330, -5, 75)
        row.omw = UI.Label(row, "GameFontHighlightSmall", 410, -5, 55)
        row.gwp = UI.Label(row, "GameFontHighlightSmall", 470, -5, 55)
    end, function(row, r)
        row.rank:SetText(r.rank)
        row.name:SetText(r.status == "dropped" and (GREY .. r.name .. " (dropped)|r") or r.name)
        row.points:SetText(r.points)
        row.record:SetText(r.wins .. "-" .. r.losses .. "-" .. r.draws)
        row.omw:SetText(math.floor(r.omw * 100 + 0.5) .. "%")
        row.gwp:SetText(math.floor(r.gwp * 100 + 0.5) .. "%")
    end)
end

local function RefreshStandings(P)
    local ev = H:Event()
    P.list:SetData(ev and T.Standings(ev) or {})
end

local function BuildLog(P)
    P.list = UI.List(P, 12, -8, 590, 20, 20, function(row)
        row.time = UI.Label(row, "GameFontDisableSmall", 4, -4, 44)
        row.text = UI.Label(row, "GameFontHighlightSmall", 50, -4, 535)
    end, function(row, entry)
        row.time:SetText(date("%H:%M", entry.at))
        row.text:SetText(entry.text)
    end)
end

local function RefreshLog(P)
    local ev = H:Event()
    local data = {}
    local log = ev and ev.log or {}
    for i = #log, 1, -1 do data[#data + 1] = log[i] end   -- newest first
    P.list:SetData(data)
end

-- =========================================================================
-- THE WINDOW
-- =========================================================================
local PANELS = {
    { key = "setup", label = "Setup", build = BuildSetup, refresh = RefreshSetup },
    { key = "players", label = "Players", build = BuildPlayers, refresh = RefreshPlayers },
    { key = "round", label = "Round", build = BuildRound, refresh = RefreshRound },
    { key = "standings", label = "Standings", build = BuildStandings, refresh = RefreshStandings },
    { key = "log", label = "Log", build = BuildLog, refresh = RefreshLog },
}

local function RefreshAll()
    if not (F and F:IsShown()) then return end
    local ev = H:Event()
    F.subtitle:SetText(ev and (ev.name .. "  " .. GREY .. (UI.STATUS_TEXT[ev.status] or "") .. "|r") or "")
    local attention = H:AttentionCount()
    tabs.round:SetText(attention > 0 and ("Round " .. RED .. "(" .. attention .. ")|r") or "Round")
    for _, info in ipairs(PANELS) do
        local isShown = info.key == shownPanel
        tabs[info.key]:SetEnabled(not isShown)
        panels[info.key]:SetShown(isShown)
        if isShown then info.refresh(panels[info.key]) end
    end
end

local function Build()
    F = UI.Window("FCCGE_OrganizerFrame", 640, 520, "Tournaments: Organizer")
    F.subtitle = UI.Label(F, "GameFontHighlightSmall", 300, -19, 300)
    F.subtitle:SetJustifyH("RIGHT")
    for i, info in ipairs(PANELS) do
        local tab = UI.Button(F, info.label, 96, 22, function()
            shownPanel = info.key
            RefreshAll()
        end)
        tab:SetPoint("TOPLEFT", 16 + (i - 1) * 100, -44)
        tabs[info.key] = tab
        local panel = CreateFrame("Frame", nil, F)
        panel:SetPoint("TOPLEFT", 12, -70)
        panel:SetPoint("BOTTOMRIGHT", -12, 14)
        panel:Hide()
        info.build(panel)
        panels[info.key] = panel
    end
    F:SetScript("OnShow", RefreshAll)
end

function UI.OpenOrganizer()
    if not F then Build() end
    F:Show()
    RefreshAll()
end

UI.AddRefresher(RefreshAll)
