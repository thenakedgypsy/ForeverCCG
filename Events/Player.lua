--[[
    ForeverCCG Events
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.
]]
local _, ns = ...
local B, Comm = ns.Bridge, ns.Comm
local Print = ns.Print

-- =========================================================================
-- PLAYER
-- The entrant's side: joining with a code, checking in, and reporting each game played against
-- the current opponent. Only messages from the event's own organizer are listened to.
-- =========================================================================
local P = {}
ns.Player = P

local JOIN_RETRY, JOIN_TRIES = 8, 3
local STATUS_DELAY = 6

local REJECTIONS = {
    code = "No event with that code. Check the code and the organizer's name.",
    protocol = "Your ForeverCCG version doesn't match the organizer's.",
    closed = "That event has already started.",
    full = "That event is full.",
    rating = "Your PvP rating is outside that event's limits.",
    score = "Your collection score is above that event's limit.",
}

local pendingJoin        -- { organizer, code } until the organizer answers
local currentGame        -- the game in progress, if it is this round's match
local standParts         -- the standings as they arrive: { rev, total, parts }

function P:Joined()
    return ns.DB().joined
end

function P:IsFromOrganizer(from, id)
    local j = self:Joined()
    return j and j.id == id and B.SameName(j.organizer, from)
end

-- =========================================================================
-- ACTIONS
-- =========================================================================
function P:Join(code, organizer)
    if self:Joined() then
        Print("Leave your current event first.")
        return
    end
    code = (code or ""):trim():upper()
    organizer = B.NormalizeName(organizer)
    if code == "" or organizer == "" then
        Print("Enter the join code and the organizer's name.")
        return
    end
    pendingJoin = { organizer = organizer, code = code }
    local rating, wins, losses = B.Rating()
    Comm:SendReliable(organizer, table.concat({ "JOIN", Comm.Clean(code), Comm.PROTOCOL, B.Version(), rating, wins,
        losses, B.CollectionScore(), B.PrizeCooldown() or -1 }, ":"), { key = "join", interval = JOIN_RETRY, max = JOIN_TRIES,
        onFail = function()
            if pendingJoin then
                pendingJoin = nil
                Print("No answer from " .. organizer .. ". They need to be online with ForeverCCG.")
            end
        end })
    Print("Asking " .. organizer .. " to join...")
end

-- Why the active deck can't be entered, or nil if it can
function P:DeckProblem()
    local j = self:Joined()
    local deck = B.ActiveDeck()
    if not deck or not B.DeckPlayable(deck) then
        return "Your active deck isn't playable (it needs 40 to 50 cards)."
    end
    local banned = j and B.BannedCardIn(deck, j.banned)
    if banned then return banned .. " is banned in this event." end
    return nil
end

function P:CheckIn()
    local j = self:Joined()
    if not j then return end
    local problem = self:DeckProblem()
    if problem then
        Print(problem)
        return
    end
    local fp = B.Fingerprint(B.ActiveDeck())
    Comm:SendReliable(j.organizer, "CHECKIN:" .. j.id .. ":" .. fp .. ":" .. (B.PrizeCooldown() or -1), { key = "checkin", max = 6 })
end

function P:Challenge()
    local j = self:Joined()
    if j and j.opponent and j.opponent ~= "" then B.Challenge(j.opponent) end
end

-- Leaves the event. While it is running this forfeits the current match.
function P:Leave()
    local j = self:Joined()
    if not j then return end
    if j.status ~= "finished" then
        Comm:SendReliable(j.organizer, "DROP:" .. j.id, { key = "drop", max = 6 })
    end
    ns.DB().joined = nil
    currentGame = nil
    ns.RefreshUI()
end

function P:RequestUpdate(wantStandings)
    local j = self:Joined()
    if j then Comm:Send(j.organizer, "STATUS:" .. j.id .. ":" .. (wantStandings and 1 or 0)) end
end

-- =========================================================================
-- GAMES
-- =========================================================================
local function DeckFields(j)
    local deck = B.ActiveDeck()
    local fp = deck and B.Fingerprint(deck) or ""
    local legal = (deck and B.BannedCardIn(deck, j.banned)) and 0 or 1
    return fp, legal
end

function P:OnGameStart(info)
    currentGame = nil
    local j = self:Joined()
    if not j or j.status ~= "running" or (j.tableNo or 0) == 0 or not info.gameId then return end
    if j.matchStatus == "done" or j.matchStatus == "bye" then return end
    if not B.SameName(j.opponent, info.opponent) then return end
    local fp, legal = DeckFields(j)
    currentGame = { id = j.id, round = j.round, tableNo = j.tableNo, gameId = info.gameId, deck = fp, legal = legal,
        organizer = j.organizer, opponent = j.opponent }
    Comm:Send(j.organizer, table.concat({ "GAME", j.id, j.round, j.tableNo, info.gameId, fp, legal }, ":"))
end

function P:OnGameEnd(info, outcome)
    local game = currentGame
    currentGame = nil
    if not game or game.gameId ~= info.gameId then return end
    -- Kept for the prize check: games this client saw won, so not the organizer's word
    local j = self:Joined()
    if outcome == "won" and j and j.id == game.id then
        j.beaten = j.beaten or {}
        j.beaten[B.Key(game.opponent)] = true
    end
    Comm:SendReliable(game.organizer, table.concat({ "RESULT", game.id, game.round, game.tableNo, game.gameId, outcome,
        info.quiet and 1 or 0, info.turns or 0, game.deck, game.legal }, ":"), { persist = true, interval = 30 })
end

-- =========================================================================
-- FROM THE ORGANIZER
-- =========================================================================
Comm:On("INFO", function(parts, from)
    local id = parts[2]
    local j = P:Joined()
    if not j then
        if not (pendingJoin and B.SameName(pendingJoin.organizer, from)) then return end
        j = { id = id, organizer = from, code = pendingJoin.code, status = "open", myStatus = "registered",
            round = 0, rounds = 0, tableNo = 0, rev = 0, banned = {} }
        ns.DB().joined = j
        pendingJoin = nil
    elseif not P:IsFromOrganizer(from, id) then
        return
    end
    j.format, j.bestOf, j.deckLock, j.roundMinutes = parts[3], tonumber(parts[4]), parts[5] == "1", tonumber(parts[6])
    j.name = parts[8] or "Tournament"
    j.prizes = parts[9] == "1"
    Print("Joined " .. j.name .. "." .. (j.prizes and " The champion wins a prize card." or ""))
    -- Messages can arrive out of order: a YOU that beat this one was ignored, so ask again
    if j.rev == 0 then P:RequestUpdate(false) end
    ns.RefreshUI()
    if ns.UI and ns.UI.OpenPlayer then ns.UI.OpenPlayer() end
end)

Comm:On("BAN", function(parts, from)
    if not P:IsFromOrganizer(from, parts[2]) then return end
    local j = P:Joined()
    for id in (parts[5] or ""):gmatch("[^,]+") do j.banned[id] = true end
end)

Comm:On("REJECT", function(parts, from)
    if not (pendingJoin and B.SameName(pendingJoin.organizer, from)) then return end
    pendingJoin = nil
    if parts[2] == "version" then
        Print("You need ForeverCCG " .. tostring(parts[3]) .. " to enter this event (you have " .. B.Version() .. ").")
    else
        Print(REJECTIONS[parts[2]] or "The organizer couldn't add you.")
    end
end)

Comm:On("NOTE", function(parts, from)
    if P:IsFromOrganizer(from, parts[2]) then Print(parts[3] or "") end
end)

Comm:On("GONE", function(parts, from)
    if not P:IsFromOrganizer(from, parts[2]) then return end
    local j = P:Joined()
    Print((j.name or "The event") .. " has been closed by its organizer.")
    ns.DB().joined = nil
    currentGame = nil
    ns.RefreshUI()
end)

Comm:On("YOU", function(parts, from)
    if not P:IsFromOrganizer(from, parts[2]) then return end
    local j = P:Joined()
    local rev = tonumber(parts[3]) or 0
    if rev < (j.rev or 0) then return end

    local before = { status = j.status, myStatus = j.myStatus, round = j.round, result = j.result, tableNo = j.tableNo }
    j.rev, j.status, j.round, j.rounds, j.myStatus = rev, parts[4], tonumber(parts[5]) or 0, tonumber(parts[6]) or 0, parts[7]
    j.tableNo, j.opponent, j.matchStatus = tonumber(parts[8]) or 0, parts[9] or "", parts[10]
    j.myWins, j.theirWins = tonumber(parts[11]) or 0, tonumber(parts[12]) or 0
    local secondsLeft = tonumber(parts[13]) or -1
    j.endsAt = secondsLeft >= 0 and (ns.Now() + secondsLeft) or nil
    j.result, j.champion, j.note = parts[14] or "", parts[15] or "", parts[16] or ""

    if j.status == "checkin" and before.status ~= "checkin" then
        Print((j.name or "The event") .. ": check-in is open. /fccgevents")
    end
    if j.myStatus == "checkedin" and before.myStatus ~= "checkedin" then Print("You're checked in.") end
    if j.round ~= before.round and j.status == "running" and j.tableNo > 0 then
        if j.matchStatus == "bye" then
            Print("Round " .. j.round .. ": you have a bye.")
        else
            Print("Round " .. j.round .. ", table " .. j.tableNo .. ": you play |cFFFFFFFF" .. j.opponent .. "|r. /fccgevents")
        end
        if PlaySound and SOUNDKIT and SOUNDKIT.READY_CHECK then pcall(PlaySound, SOUNDKIT.READY_CHECK) end
    elseif j.result ~= "" and j.result ~= before.result and j.round == before.round then
        Print("Match result: " .. j.result .. " (" .. j.myWins .. "-" .. j.theirWins .. ").")
    end
    if j.status == "finished" and before.status ~= "finished" then
        Print((j.name or "The event") .. " has finished." .. (j.champion ~= "" and (" Champion: " .. j.champion .. "!") or ""))
        P:RequestUpdate(true)
    end
    -- A prize event under way with us playing in it: our prize cooldown starts now, win or not
    -- (ForeverCCG AdminGrants.lua TTS:EnterPrizeEvent), the organizer included if they're playing.
    if j.prizes and not j.prizeEntered and j.status ~= "open" and j.status ~= "checkin" and j.myStatus == "active" then
        j.prizeEntered = true
        B.EnterPrizeEvent({ organizer = B.NormalizeName(j.organizer), event = j.id, name = j.name })
    end
    ns.RefreshUI()
end)

Comm:On("STAND", function(parts, from)
    if not P:IsFromOrganizer(from, parts[2]) then return end
    local rev, index, total = tonumber(parts[3]), tonumber(parts[4]), tonumber(parts[5])
    if not (rev and index and total) then return end
    if not standParts or standParts.rev ~= rev then
        standParts = { rev = rev, total = total, parts = {} }
    end
    standParts.parts[index] = parts[6] or ""
    for i = 1, total do
        if not standParts.parts[i] then return end
    end
    local rows = {}
    for text in table.concat(standParts.parts):gmatch("[^;]+") do
        local name, points, wins, losses, draws, dropped = text:match("^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)$")
        if name then
            rows[#rows + 1] = { rank = #rows + 1, name = name, points = tonumber(points) or 0, wins = tonumber(wins) or 0,
                losses = tonumber(losses) or 0, draws = tonumber(draws) or 0, dropped = dropped == "1" }
        end
    end
    P:Joined().standings = rows
    standParts = nil
    P:CheckPrize()
    ns.RefreshUI()
end)

-- This round's tables (Host.lua SendStandings): j.pairings = { round, rows = { { table, a, b,
-- status, aWins, bWins, result } } }, for the window's This Round list and its Watch buttons
local pairParts
Comm:On("PAIRS", function(parts, from)
    if not P:IsFromOrganizer(from, parts[2]) then return end
    local rev, roundNo, index, total = tonumber(parts[3]), tonumber(parts[4]), tonumber(parts[5]), tonumber(parts[6])
    if not (rev and roundNo and index and total) then return end
    if not pairParts or pairParts.rev ~= rev then
        pairParts = { rev = rev, total = total, parts = {} }
    end
    pairParts.parts[index] = parts[7] or ""
    for i = 1, total do
        if not pairParts.parts[i] then return end
    end
    local rows = {}
    for text in table.concat(pairParts.parts):gmatch("[^;]+") do
        local t, a, b, status, aw, bw, result = text:match("^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)$")
        if t then
            rows[#rows + 1] = { table = tonumber(t) or 0, a = a, b = b, status = status,
                aWins = tonumber(aw) or 0, bWins = tonumber(bw) or 0, result = result }
        end
    end
    P:Joined().pairings = { round = roundNo, rows = rows }
    pairParts = nil
    ns.RefreshUI()
end)

-- Whether this client is playing this event's match right now (Spectate.lua lets the event's
-- organizer watch it even with Spectatable unticked)
function P:InEventGame()
    return currentGame ~= nil
end

if TTS and TTS.Spectate then
    TTS.Spectate.EventAllows = function(name)
        local j = P:Joined()
        return (currentGame and j and B.SameName(j.organizer, name)) and true or false
    end
end

-- =========================================================================
-- PRIZE
-- The champion's own client claims a prize card once the final standings are in. ForeverCCG
-- decides (TTS:AwardTournamentPrize): enough players, enough opponents this client saw beaten,
-- one per event and one a week per account. The organizer has no say in it.
-- =========================================================================
local PRIZE_REFUSED = {
    players = "Prize cards need at least %d players in the event.",
    beaten = "Prize cards need wins against at least %d different opponents, played with this addon running.",
    claimed = "You've already had the prize for this event.",
    full = "You already have every prize card at 4 copies.",
    unsupported = "Your copy of ForeverCCG doesn't give prize cards. Update it to get one.",
}

function P:CheckPrize()
    local j = self:Joined()
    if not j or not j.prizes or j.status ~= "finished" or j.prizeDone or not j.standings then return end
    if not (j.champion and j.champion ~= "" and B.SameName(j.champion, B.MyName())) then return end
    -- (an organizer playing in their own event can win it too: the player count and the wins this
    -- client saw itself are what stop a made-up event paying out, AdminGrants.lua)

    local beaten = 0
    for _ in pairs(j.beaten or {}) do beaten = beaten + 1 end
    local card, reason, secondsLeft = B.AwardPrize({ organizer = B.NormalizeName(j.organizer), event = j.id,
        name = j.name, players = #j.standings, beaten = beaten })
    j.prizeDone = true
    if card then return end
    local minPlayers, minBeaten = B.PrizeRules()
    if reason == "cooldown" then
        local days = math.ceil((secondsLeft or 0) / 86400)
        Print("You've played in another prize event this week, so this one can't pay out. Your next prize can come in " .. days
            .. (days == 1 and " day." or " days."))
    elseif reason ~= "invalid" then
        local text = PRIZE_REFUSED[reason]
        if text then Print(text:format(reason == "players" and minPlayers or minBeaten)) end
    end
end

-- At login: catch up on anything missed
function P:OnLogin()
    C_Timer.After(STATUS_DELAY, function() P:RequestUpdate(true) end)
end
