--[[
    ForeverCCG Events
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.
]]
local _, ns = ...

-- =========================================================================
-- BRIDGE
-- The only file that touches ForeverCCG (TTS.*). If an update to the main addon moves
-- something, this is the one place to change.
-- =========================================================================
local B = {}
ns.Bridge = B

function ns.Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD200[Events]|r " .. tostring(msg))
end

function ns.RefreshUI()
    if ns.UI then ns.UI.Refresh() end
end

function ns.DB()
    if type(FCCGE_DB) ~= "table" then FCCGE_DB = {} end
    return FCCGE_DB
end

function ns.Now()
    return time()
end

-- "Firstname Surname-Realm" -> "Firstname Surname"
function B.NormalizeName(name)
    if type(name) ~= "string" then return "" end
    if Ambiguate then name = Ambiguate(name, "none") end
    return (name:match("^([^%-]+)") or name):trim()
end

function B.Key(name)
    return B.NormalizeName(name):lower()
end

-- On Forever the same character can show as "Firstname Surname" or just "Firstname"
function B.SameName(a, b)
    a, b = B.Key(a), B.Key(b)
    if a == "" or b == "" then return false end
    return a == b or a:sub(1, #b + 1) == b .. " " or b:sub(1, #a + 1) == a .. " "
end

function B.MyName()
    if TTS and TTS.GetPlayerFullName then return B.NormalizeName(TTS.GetPlayerFullName()) end
    return B.NormalizeName(UnitName("player"))
end

function B.Ready()
    return TTS and TTS.Engine and TTS.Engine.HookDisplay and TTS.Net and true or false
end

function B.Version()
    return TTS and TTS.VERSION or "unknown"
end

-- ForeverCCG only lets players on the same major.minor version play each other
function B.CompatibleVersions(a, b)
    if not a or not b then return false end
    local aMajor, aMinor = a:match("^(%d+)%.(%d+)")
    local bMajor, bMinor = b:match("^(%d+)%.(%d+)")
    if not aMajor or not bMajor then return a == b end
    return tonumber(aMajor) == tonumber(bMajor) and tonumber(aMinor) == tonumber(bMinor)
end

-- rating, wins, losses
function B.Rating()
    if TTS and TTS.PvP then return TTS.PvP:Get() end
    return 1000, 0, 0
end

function B.CollectionScore()
    if TTS and TTS.GetCollectionScore then return (TTS:GetCollectionScore()) or 0 end
    return 0
end

-- A prize card for winning an event (ForeverCCG AdminGrants.lua TTS:AwardTournamentPrize, which
-- holds the rules). Returns the card, or nil, a reason and (for "cooldown") the seconds left.
function B.AwardPrize(info)
    if not (TTS and TTS.AwardTournamentPrize) then return nil, "unsupported" end
    return TTS:AwardTournamentPrize(info)
end

-- Seconds until this account can win a prize again (0 = eligible), or nil if this copy of
-- ForeverCCG can't say
function B.PrizeCooldown()
    if not (TTS and TTS.TournamentPrizeCooldown) then return nil end
    return TTS:TournamentPrizeCooldown()
end

-- Playing in a prize event starts this account's prize cooldown (info: { organizer, event, name })
function B.EnterPrizeEvent(info)
    if TTS and TTS.EnterPrizeEvent then TTS:EnterPrizeEvent(info) end
end

function B.PrizeRules()
    return TTS and TTS.PRIZE_MIN_PLAYERS or 4, TTS and TTS.PRIZE_MIN_BEATEN or 2
end

function B.InMatch()
    local E = TTS and TTS.Engine
    return E and E.inMatch and true or false
end

function B.Challenge(name)
    if TTS and TTS.Net then TTS.Net:InvitePlayer(name) end
end

-- =========================================================================
-- DECKS
-- =========================================================================
function B.ActiveDeck()
    return TTS_SavedDecks and TTS_SavedDecks[TTS_ActiveDeckIndex] or nil
end

-- The saved decks for the player's window to choose from: { index, name, cards, playable },
-- and which is active
function B.Decks()
    local list = {}
    for i, deck in ipairs(TTS_SavedDecks or {}) do
        local n = 0
        for _, qty in pairs(deck.cards or {}) do n = n + (tonumber(qty) or 0) end
        list[#list + 1] = { index = i, name = deck.name or ("Deck " .. i), cards = n,
            playable = (TTS and TTS.IsDeckPlayable and TTS:IsDeckPlayable(deck)) and true or false }
    end
    return list, TTS_ActiveDeckIndex
end

-- Makes a saved deck the one games are played with
function B.SetActiveDeck(index)
    if not (TTS_SavedDecks and TTS_SavedDecks[index]) then return false end
    TTS_ActiveDeckIndex = index
    if TTS and TTS.MainFrame and TTS.MainFrame.UpdatePlayState then pcall(TTS.MainFrame.UpdatePlayState, TTS.MainFrame) end
    return true
end

function B.DeckPlayable(deck)
    return TTS and TTS.IsDeckPlayable and TTS:IsDeckPlayable(deck) or false
end

-- A short code that changes if the deck's cards change
function B.Fingerprint(deck)
    local ids = {}
    for id, qty in pairs(deck and deck.cards or {}) do
        if qty > 0 then ids[#ids + 1] = tostring(id) end
    end
    table.sort(ids)
    local hash = 5381
    for _, id in ipairs(ids) do
        local text = id .. "=" .. tostring(deck.cards[id]) .. ";"
        for i = 1, #text do
            hash = (hash * 33 + text:byte(i)) % 4294967296
        end
    end
    return string.format("%08x", hash)
end

-- The name of the first banned card in the deck, or nil. banned: { [card id] = true }
function B.BannedCardIn(deck, banned)
    for id, qty in pairs(deck and deck.cards or {}) do
        if qty > 0 and banned and banned[tostring(id)] then
            return (TTS and TTS.CardName and TTS:CardName(id)) or tostring(id)
        end
    end
    return nil
end

-- Comma-separated card names or ids -> a list of ids, and a list of what wasn't recognised
function B.ResolveCards(text)
    local ids, unknown = {}, {}
    local byName = {}
    for id, card in pairs(TTS and TTS.Cards or {}) do
        if card.name then byName[card.name:lower()] = id end
        local shown = TTS.CardName and TTS:CardName(card)
        if shown then byName[shown:lower()] = id end
    end
    for item in (text or ""):gmatch("[^,]+") do
        item = item:trim()
        if item ~= "" then
            local id = (TTS.Cards and TTS.Cards[item]) and item or byName[item:lower()]
            if id then ids[#ids + 1] = tostring(id) else unknown[#unknown + 1] = item end
        end
    end
    return ids, unknown
end

-- =========================================================================
-- GAMES
-- The hooks go through E:HookDisplay, so an error in this addon can never reach a game.
-- onStart({ opponent, gameId })
-- onEnd({ opponent, gameId, quiet, turns }, outcome): won, lost, conceded or cancelled
-- =========================================================================
local installed = false

function B.Install(onStart, onEnd)
    if installed or not B.Ready() then return end
    installed = true
    local E = TTS.Engine

    E:HookDisplay("StartMatch", nil, function(_, self)
        if not self.inMatch or self.isSolo or self.viewing then return end
        onStart({ opponent = self.opponent, gameId = TTS.Net.matchId })
    end)

    -- EndMatch also runs when no game is on (it returns at once), so whether a game was really
    -- on is read before it, while inMatch still says so
    E:HookDisplay("EndMatch", function(self)
        if not self.inMatch or self.isSolo or self.viewing then return nil end
        local quietAfter = TTS.PvP and TTS.PvP.QUIET_SECONDS or 180
        return {
            opponent = self.opponent,
            gameId = TTS.Net.matchId,
            quiet = (GetTime() - (self.opponentHeardAt or 0)) >= quietAfter,
            turns = (self.turn or 0) + (self.remoteTurns or 0),
        }
    end, function(state, _, _, outcome)
        if state then onEnd(state, outcome) end
    end)
end
