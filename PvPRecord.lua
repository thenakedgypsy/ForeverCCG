--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
local L = TTS.L
local Loc = TTS.Locale

-- =========================================================================
-- PVP RATING & RECORD
-- Each PvP game won or lost moves the account's rating (Elo) and its win/loss record,
-- kept in TTS_PvPRecord (account-wide, so alts can't farm each other). Both players
-- send theirs with the collection score in challenges and waiting-room messages
-- (Network.lua: <rating>:<wins>:<losses>), and each works out its own new rating from
-- the other's at the start of the game, so what one gains the other loses.
-- Unrated: cancelled setups, disconnects (a game never finished counts for nobody), a
-- concede once the opponent has gone quiet (they dropped), and games past the daily
-- limit against the same opponent.
-- =========================================================================
local P = {}
TTS.PvP = P

P.START_RATING = 1000
local K_PROVISIONAL, K_SETTLED = 40, 24   -- rating moves faster over a player's first games
local PROVISIONAL_GAMES = 20
local DAILY_RATED_PER_OPPONENT = 5   -- also in the rules (rules.pvp.rating)
local HISTORY_MAX = 50
P.QUIET_SECONDS = 180   -- conceding to an opponent silent this long is a disconnect: unrated

local function DB()
    if type(TTS_PvPRecord) ~= "table" then TTS_PvPRecord = {} end
    local db = TTS_PvPRecord
    db.rating = tonumber(db.rating) or P.START_RATING
    db.wins = tonumber(db.wins) or 0
    db.losses = tonumber(db.losses) or 0
    if type(db.history) ~= "table" then db.history = {} end
    if type(db.daily) ~= "table" then db.daily = {} end
    return db
end

-- rating (whole number), wins, losses
function P:Get()
    local db = DB()
    return math.floor(db.rating + 0.5), db.wins, db.losses
end

-- Ours as sent in network messages: <rating>:<wins>:<losses>
function P:Fields()
    local r, w, l = self:Get()
    return r .. ":" .. w .. ":" .. l
end

-- Theirs from three message parts: { rating, wins, losses }, or nil without a rating
function P.Parse(r, w, l)
    r = tonumber(r)
    if not r then return nil end
    return { rating = r, wins = tonumber(w) or 0, losses = tonumber(l) or 0 }
end

-- A rating in the collection score's item-quality colours (TTS:ColoredScore), by band
-- rather than share of a maximum: there is no top, so no red
local RATING_TIERS = {
    { 900, "9D9D9D" }, { 1100, "FFFFFF" }, { 1300, "1EFF00" },
    { 1500, "0070DD" }, { 1700, "A335EE" }, { math.huge, "FF8000" },
}
function P.ColoredRating(r)
    for _, tier in ipairs(RATING_TIERS) do
        if r < tier[1] then return "|cFF" .. tier[2] .. r .. "|r" end
    end
end

-- "1012 (14-9)", or a grey dash when unknown
function P.Format(info)
    if not info then return "|cFF888888-|r" end
    return L("pvp.short", P.ColoredRating(info.rating), info.wins, info.losses)
end

-- The rating alone (the waiting room), or a grey dash when unknown
function P.FormatRating(info)
    if not info then return "|cFF888888-|r" end
    return P.ColoredRating(info.rating)
end

-- Ours, formatted as Format does
function P:FormatMine()
    local r, w, l = self:Get()
    return P.Format({ rating = r, wins = w, losses = l })
end

local function AddHistory(db, entry)
    table.insert(db.history, 1, entry)
    for i = #db.history, HISTORY_MAX + 1, -1 do db.history[i] = nil end
end

-- A finished PvP game. outcome: "won", "lost" or "conceded" (anything else is ignored);
-- theirs: the opponent's { rating, wins, losses } from the start of the game; quiet: the
-- opponent had gone silent (a concede then is a disconnect).
-- Returns the rating change, or nil and why it was unrated ("limit", "disconnect").
function P:RecordResult(opponent, theirs, outcome, quiet)
    if not opponent or (outcome ~= "won" and outcome ~= "lost" and outcome ~= "conceded") then return nil end
    local db = DB()
    local won = outcome == "won"
    if outcome == "conceded" and quiet then
        AddHistory(db, { name = opponent, won = false, unrated = "disconnect", at = time() })
        return nil, "disconnect"
    end

    local today = date("%Y-%m-%d")
    for key, d in pairs(db.daily) do
        if type(d) ~= "table" or d.day ~= today then db.daily[key] = nil end
    end
    local key = opponent:lower()
    local d = db.daily[key] or { day = today, n = 0 }
    db.daily[key] = d
    if d.n >= DAILY_RATED_PER_OPPONENT then
        AddHistory(db, { name = opponent, won = won, unrated = "limit", at = time() })
        return nil, "limit"
    end
    d.n = d.n + 1

    local theirRating = theirs and theirs.rating or P.START_RATING
    local expected = 1 / (1 + 10 ^ ((theirRating - db.rating) / 400))
    local k = (db.wins + db.losses < PROVISIONAL_GAMES) and K_PROVISIONAL or K_SETTLED
    local delta = math.floor(k * ((won and 1 or 0) - expected) + 0.5)
    db.rating = math.max(0, db.rating + delta)
    if won then db.wins = db.wins + 1 else db.losses = db.losses + 1 end
    AddHistory(db, { name = opponent, won = won, delta = delta, rating = db.rating, opp = theirRating, at = time() })
    if P.frame and P.frame:IsShown() then P:Refresh() end
    return delta
end

-- The line under a PvP result: the new rating and the change, or why it didn't count
function P:ResultText(delta, why)
    if delta then
        local r = self:Get()
        local change = delta >= 0 and ("|cFF33DD33+" .. delta .. "|r") or ("|cFFFF4444" .. delta .. "|r")
        return L("pvp.resultRating", P.ColoredRating(r), change)
    end
    if why then return "|cFF888888" .. L("pvp.unrated." .. why, DAILY_RATED_PER_OPPONENT) .. "|r" end
end

-- =========================================================================
-- RECORD WINDOW
-- The rating, wins and losses, and the latest games. Opened from the main window's
-- Record button (MainFrame.lua); built the first time it opens.
-- =========================================================================
local HISTORY_ROWS = 12
local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil

local function BuildWindow()
    local F = CreateFrame("Frame", "TTS_PvPRecordFrame", UIParent, backdropTemplate)
    F:SetSize(420, 150 + HISTORY_ROWS * 20)
    F:SetPoint("CENTER")
    F:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    F:SetFrameStrata("DIALOG")
    F:EnableMouse(true)
    F:SetMovable(true)
    F:RegisterForDrag("LeftButton")
    F:SetScript("OnDragStart", F.StartMoving)
    F:SetScript("OnDragStop", F.StopMovingOrSizing)
    F:Hide()
    tinsert(UISpecialFrames, "TTS_PvPRecordFrame")

    local bar = F:CreateTexture(nil, "ARTWORK")
    bar:SetPoint("TOPLEFT", 12, -12)
    bar:SetPoint("TOPRIGHT", -12, -12)
    bar:SetHeight(25)
    bar:SetColorTexture(0, 0, 0, 0.35)
    local line = F:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, 0)
    line:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, 0)
    line:SetHeight(1)
    line:SetColorTexture(1, 0.82, 0, 0.55)

    local title = F:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -11)
    Loc:Bind(title, "pvp.title")
    local close = CreateFrame("Button", nil, F, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)

    F.rating = F:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    F.rating:SetPoint("TOP", 0, -48)
    F.record = F:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    F.record:SetPoint("TOP", F.rating, "BOTTOM", 0, -6)

    local header = F:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header:SetPoint("TOPLEFT", 22, -110)
    Loc:Bind(header, "pvp.recent")
    local divider = F:CreateTexture(nil, "ARTWORK")
    divider:SetPoint("TOPLEFT", 20, -124)
    divider:SetPoint("TOPRIGHT", -20, -124)
    divider:SetHeight(1)
    divider:SetColorTexture(1, 0.82, 0, 0.30)

    F.rows = {}
    for i = 1, HISTORY_ROWS do
        local row = CreateFrame("Frame", nil, F)
        row:SetSize(376, 20)
        row:SetPoint("TOPLEFT", 22, -128 - (i - 1) * 20)
        row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.name:SetPoint("LEFT", 0, 0)
        row.name:SetWidth(150)
        row.name:SetJustifyH("LEFT")
        row.name:SetWordWrap(false)
        row.result = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.result:SetPoint("LEFT", 152, 0)
        row.result:SetWidth(50)
        row.result:SetJustifyH("LEFT")
        row.change = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.change:SetPoint("LEFT", 204, 0)
        row.change:SetWidth(100)
        row.change:SetJustifyH("LEFT")
        row.date = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        row.date:SetPoint("RIGHT", 0, 0)
        row.date:SetJustifyH("RIGHT")
        F.rows[i] = row
    end
    F.empty = F:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    F.empty:SetPoint("TOP", divider, "BOTTOM", 0, -16)
    Loc:Bind(F.empty, "pvp.noGames")

    F:SetScript("OnShow", function() P:Refresh() end)
    if TTS.Sound and TTS.Sound.HookButtons then TTS.Sound:HookButtons(F) end
    return F
end

function P:Refresh()
    local F = self.frame
    if not F then return end
    local r, w, l = self:Get()
    F.rating:SetText(L("pvp.rating", P.ColoredRating(r)))
    local games = w + l
    F.record:SetText(L("pvp.record", w, l, games > 0 and math.floor(100 * w / games + 0.5) or 0))
    local history = DB().history
    F.empty:SetShown(#history == 0)
    for i, row in ipairs(F.rows) do
        local h = history[i]
        if h then
            row.name:SetText(h.name or "?")
            row.result:SetText(h.won and ("|cFF33DD33" .. L("pvp.won") .. "|r") or ("|cFFFF4444" .. L("pvp.lost") .. "|r"))
            if h.unrated then
                row.change:SetText("|cFF888888" .. L("pvp.unratedShort." .. h.unrated) .. "|r")
            else
                local d = h.delta or 0
                row.change:SetText((d >= 0 and "|cFF33DD33+" or "|cFFFF4444") .. d .. "|r  " .. P.ColoredRating(math.floor((h.rating or 0) + 0.5)))
            end
            row.date:SetText(h.at and date("%d %b %H:%M", h.at) or "")
            row:Show()
        else
            row:Hide()
        end
    end
end

-- Opens the window (built on first use) and returns it
function P:Open()
    self.frame = self.frame or BuildWindow()
    self.frame:Show()
    return self.frame
end
