--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
TTS.MatchRecorder = TTS.MatchRecorder or {}
local R = TTS.MatchRecorder
local E = TTS.Engine
local L = TTS.L
local Loc = TTS.Locale

-- =========================================================================
-- MATCH RECORDER
-- A plain-text log of the latest game for bug reports: every game log line, the addon
-- messages exchanged with the opponent, a board snapshot at the start of each turn and
-- at the end, and any Lua error raised during play. Saved in TTS_LastMatchLog (replaced
-- when the next game starts, so it survives a /reload or a crash) and shown ready to
-- copy from Options > Developer. The format is for developers, so it is not translated.
--
-- Event lines:  [mm:ss <me|op><turn> <phase>] <tag> <text>
--   ACT / CMB / MNA / SYS / ERR / LOG   game log line (by category)
--   >> / <<                             addon message sent to / received from the opponent
--   LUA                                 Lua error (first lines of the stack)
--   ==                                  board snapshot; permanents are <index>:<card id>
--                                       [P/T] [flags: T exhausted, S sick, Z frozen,
--                                       A attacking, dmgN damage marked]
-- Loaded last, so its hooks wrap every other wrapper of the same functions.
-- =========================================================================
local FORMAT_VERSION = 1
local MAX_LINES = 5000      -- a long game is ~1500; past this the log stops growing
local MAX_NET_LEN = 240     -- longer addon messages are cut (EFFECTS payloads)
local MAX_SAME_ERROR = 3    -- an error raised every frame is only written this often

local log          -- the game being recorded (TTS_LastMatchLog once its setup has worked)
local active = false
local startedAt = 0
local errorCounts = {}

-- Runs fn without letting a recorder fault reach the game
local function Safe(fn, ...)
    pcall(fn, ...)
end

-- Text without colour codes, links or textures, on one line
local function Clean(s)
    s = tostring(s or "")
    s = s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    s = s:gsub("|H.-|h(.-)|h", "%1"):gsub("|T.-|t", ""):gsub("|A.-|a", "")
    s = s:gsub("\r?\n", " / ")
    return s
end

local PHASES = {
    MAIN1 = "M1", MAIN2 = "M2", COMBAT_ATTACK = "ATK", COMBAT_BLOCK = "BLK",
    WAITING = "WAIT", PREGAME = "PRE",
}

local function Stamp()
    -- Turn and phase are still the last game's while the new one is being set up
    if log.inSetup then return "[setup]" end
    local t = math.floor(GetTime() - startedAt)
    local turn = E.isMyTurn and ("me" .. (E.turn or 0)) or ("op" .. (E.remoteTurns or 0))
    local phase = E.phase == E.AI_TURN_PHASE and "AI" or PHASES[E.phase] or tostring(E.phase)
    return string.format("[%02d:%02d %s %s]", math.floor(t / 60), t % 60, turn, phase)
end

-- The same line again (spam clicks, a repeated warning) only counts up the one before it
local lastText, lastLine, repeats

local function Raw(text)
    lastText = nil
    local lines = log.lines
    if #lines >= MAX_LINES then
        if not log.truncated then
            log.truncated = true
            table.insert(lines, "... log full (" .. MAX_LINES .. " lines), later events not recorded")
        end
        return
    end
    table.insert(lines, text)
end

local function Add(tag, text)
    text = tag .. " " .. text
    if text == lastText and log.lines[lastLine] then
        repeats = repeats + 1
        log.lines[lastLine] = log.lines[lastLine]:gsub(" %(x%d+%)$", "") .. " (x" .. repeats .. ")"
        return
    end
    Raw(Stamp() .. " " .. text)
    lastText, lastLine, repeats = text, #log.lines, 1
end

local function SameName(a, b)
    if not a or not b then return false end
    return a:gsub("%-.*$", ""):lower() == b:gsub("%-.*$", ""):lower()
end

-- =========================================================================
-- SNAPSHOTS
-- =========================================================================
local function ManaText(mana)
    local s = ""
    for _, col in ipairs({ "W", "U", "B", "R", "G", "C" }) do
        if (mana and mana[col] or 0) > 0 then s = s .. col .. mana[col] end
    end
    return s ~= "" and s or "-"
end

local function PermText(i, perm, isRemote)
    local card = TTS.Cards[perm.id]
    local s = i .. ":" .. tostring(perm.id)
    if card and card.type == "Creature" then
        local p, t = E:GetCreatureStats(perm, isRemote)
        s = s .. " " .. p .. "/" .. t
    end
    local flags = (perm.tapped and "T" or "") .. (perm.sick and "S" or "")
        .. (perm.freezeUntap and "Z" or "") .. (perm.isAttacking and "A" or "")
    if flags ~= "" then s = s .. " " .. flags end
    if (perm.damage or 0) > 0 then s = s .. " dmg" .. perm.damage end
    return s
end

local function SideLines(label, isRemote)
    local st = isRemote and E.remoteState or E.localState
    local hand = isRemote and not E.isSolo and (st.handCount or 0) or #st.hand
    local deck = isRemote and not E.isSolo and (st.deckCount or "?") or #st.deck
    local s = string.format("   %s L%d H%s D%s G%d mana %s", label, st.life or 0, tostring(hand),
        tostring(deck), #st.graveyard, ManaText(st.mana))
    if (st.damageShield or 0) > 0 then s = s .. " shield" .. st.damageShield end
    if #(st.dots or {}) > 0 then s = s .. " dots" .. #st.dots end
    if #(st.hots or {}) > 0 then s = s .. " hots" .. #st.hots end
    Raw(s)
    local perms = {}
    for i, perm in ipairs(st.field) do table.insert(perms, PermText(i, perm, isRemote)) end
    Raw("     field: " .. (#perms > 0 and table.concat(perms, ", ") or "-"))
    -- The opponent's hand is only known against the AI
    if not isRemote or E.isSolo then
        Raw("     hand: " .. (#st.hand > 0 and table.concat(st.hand, ", ") or "-"))
    end
end

local function Snapshot(label)
    Add("==", label)
    SideLines("me", false)
    SideLines("op", true)
end

-- =========================================================================
-- RECORDING
-- =========================================================================
local function DeckOrder()
    return #E.localState.deck > 0 and table.concat(E.localState.deck, ",") or "-"
end

local function Begin(opponentName, isHost, isSolo, encounter)
    startedAt = GetTime()
    errorCounts = {}
    log = { version = FORMAT_VERSION, lines = {} }
    local version, build = GetBuildInfo()
    local me = UnitName("player") or "?"
    local realm = GetRealmName and GetRealmName()
    Raw(string.format("ForeverCCG match log v%d | addon %s | client %s.%s | %s", FORMAT_VERSION,
        tostring(TTS.VERSION), tostring(version), tostring(build), date("%Y-%m-%d %H:%M:%S")))
    local hero = "?"
    if TTS.Hero and TTS.Hero.Encode then
        local ok, enc = pcall(TTS.Hero.Encode, TTS.Hero)
        if ok then hero = enc end
    end
    Raw(string.format("me %s%s (hero %s) vs %s | %s | first: %s", me, realm and ("-" .. realm) or "",
        hero, Clean(opponentName), isSolo and "solo" or ("pvp match " .. tostring(TTS.Net and TTS.Net.matchId)),
        isHost and "me" or "op"))
    local enc = isSolo and (encounter or (TTS.SoloEncounters and TTS.SoloEncounters.PRACTICE))
    if enc then
        Raw(string.format("encounter %s (%s) kind %s life %s rules %s", tostring(enc.id),
            Clean(TTS:EncounterName(enc)), tostring(enc.kind), tostring(enc.life or 20),
            enc.rules and table.concat(enc.rules, ",") or "-"))
    end
    local deck = TTS_SavedDecks and TTS_SavedDecks[TTS_ActiveDeckIndex]
    Raw(string.format("deck %s \"%s\"%s", tostring(TTS_ActiveDeckIndex), Clean(deck and deck.name),
        (enc and enc.playerDeck) and " (scripted deck used)" or ""))
    local O = TTS.Options
    if O then
        Raw(string.format("options autoPay=%s autoPass=%s controls=%s", tostring(O:Get("autoPayMana")),
            tostring(O:Get("autoPassBlocks")), tostring(O:Get("cardControls"))))
    end
    log.resultLine = #log.lines + 1
    Raw("result: unfinished (game still running, or ended by a /reload or disconnect)")
    log.inSetup = true
    active = true
end

-- Setup worked: this becomes the saved log. What was recorded during setup goes
-- under the opening hand and deck order.
local function Started()
    TTS_LastMatchLog = log
    local setup = {}
    for i = log.resultLine + 1, #log.lines do setup[#setup + 1] = log.lines[i] end
    for i = #log.lines, log.resultLine + 1, -1 do log.lines[i] = nil end
    log.inSetup = nil
    Raw("opening hand: " .. table.concat(E.localState.hand, ","))
    Raw("deck order (top first): " .. DeckOrder())
    if E.isSolo then
        Raw("op deck order (top first): " .. (#E.remoteState.deck > 0 and table.concat(E.remoteState.deck, ",") or "-"))
    end
    Raw("--- events ---")
    for _, line in ipairs(setup) do Raw(line) end
    Snapshot("start")
end

local function Finish(outcome, reason)
    local t = math.floor(GetTime() - startedAt)
    log.lines[log.resultLine] = string.format("result: %s (%s) | my turns %d, op turns %d | %d:%02d",
        tostring(outcome), Clean(reason), E.turn or 0, E.remoteTurns or 0, math.floor(t / 60), t % 60)
    log.finished = true
    active = false
end

local LOG_TAGS = { ACTION = "ACT", COMBAT = "CMB", MANA = "MNA", ERROR = "ERR", SYSTEM = "SYS" }

local function OnLuaError(err)
    err = Clean(err)
    errorCounts[err] = (errorCounts[err] or 0) + 1
    if errorCounts[err] > MAX_SAME_ERROR then return end
    Add("LUA", err)
    local stack = debugstack and debugstack(3, 6, 0)
    if stack then
        for line in stack:gmatch("[^\n]+") do Raw("      " .. Clean(line)) end
    end
end

-- =========================================================================
-- HOOKS
-- =========================================================================
local origStart = E.StartMatch
E.StartMatch = function(self, opponentName, isHost, isSolo, encounter, ...)
    local prevLog, prevActive = log, active
    Safe(Begin, opponentName, isHost, isSolo, encounter)
    origStart(self, opponentName, isHost, isSolo, encounter, ...)
    if self.inMatch and log then
        Safe(Started)
    else
        -- Didn't start (e.g. the Deckbuilder is open): keep the log we had
        log, active, lastText = prevLog, prevActive, nil
    end
end

local origEnd = E.EndMatch
E.EndMatch = function(self, outcome, reason, ...)
    local recording = active and self.inMatch
    if recording then
        Safe(function()
            Add("SYS", "match ending: " .. tostring(outcome) .. " (" .. Clean(reason) .. ")")
            Snapshot("final")
        end)
    end
    origEnd(self, outcome, reason, ...)
    if recording then Safe(Finish, outcome, reason) end
end

local origLog = E.Log
E.Log = function(self, msg, category, ...)
    if active then Safe(Add, LOG_TAGS[category] or "LOG", Clean(msg)) end
    return origLog(self, msg, category, ...)
end

local origBeginTurn = E.BeginTurn
E.BeginTurn = function(self, isRemote, ...)
    local ok = origBeginTurn(self, isRemote, ...)
    if active and self.inMatch then Safe(Snapshot, (isRemote and "op" or "me") .. " turn start (after untap, ticks, draw)") end
    return ok
end

local origMulligan = E.Mulligan
E.Mulligan = function(self, ...)
    origMulligan(self, ...)
    if active then
        Safe(function()
            Add("SYS", "hand after mulligan: " .. table.concat(E.localState.hand, ","))
            Add("SYS", "deck order after mulligan: " .. DeckOrder())
        end)
    end
end

-- Addon messages to and from the opponent (matchmaking and contact chatter left out)
local function NetText(msg)
    if #msg > MAX_NET_LEN then return msg:sub(1, MAX_NET_LEN) .. "...(" .. #msg .. ")" end
    return msg
end

local function GameMessage(msg)
    return type(msg) == "string" and not msg:match("^LFM_") and not msg:match("^CONTACT_")
end

local Net = TTS.Net
local origSend = Net.Send
Net.Send = function(self, target, msg, ...)
    if active and not E.isSolo and GameMessage(msg) and SameName(target, E.opponent) then
        Safe(Add, ">>", NetText(msg))
    end
    return origSend(self, target, msg, ...)
end

local origReceive = Net.OnReceive
Net.OnReceive = function(self, msg, sender, ...)
    if active and not E.isSolo and GameMessage(msg) and SameName(sender, E.opponent) then
        Safe(Add, "<<", NetText(msg))
    end
    return origReceive(self, msg, sender, ...)
end

-- Lua errors while a game is being recorded (added at login, after error-catching addons)
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    local prev = geterrorhandler and geterrorhandler()
    if not (prev and seterrorhandler) then return end
    seterrorhandler(function(err, ...)
        if active then Safe(OnLuaError, err) end
        return prev(err, ...)
    end)
end)

-- =========================================================================
-- TEXT
-- =========================================================================
function R:HasLog()
    return type(TTS_LastMatchLog) == "table" and type(TTS_LastMatchLog.lines) == "table"
end

-- The saved log as one block of text; a game still running ends with the board as it is now
function R:Text()
    if not self:HasLog() then return nil end
    local text = table.concat(TTS_LastMatchLog.lines, "\n")
    if active and log == TTS_LastMatchLog and E.inMatch then
        local saved = log
        log = { lines = {} }
        Safe(Snapshot, "now (game in progress)")
        text = text .. "\n" .. table.concat(log.lines, "\n")
        log = saved
    end
    return text
end

-- =========================================================================
-- COPY WINDOW
-- The log in a read-only edit box, selected so Ctrl+C copies it.
-- =========================================================================
local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local W

local function SelectAll()
    W.edit:SetFocus()
    W.edit:HighlightText()
end

local function BuildWindow()
    W = CreateFrame("Frame", "TTS_MatchLogCopyFrame", UIParent, backdropTemplate)
    W:SetSize(680, 500)
    W:SetPoint("CENTER")
    W:SetFrameStrata("FULLSCREEN_DIALOG")
    W:SetToplevel(true)
    W:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    W:EnableMouse(true)
    W:SetMovable(true)
    W:RegisterForDrag("LeftButton")
    W:SetScript("OnDragStart", W.StartMoving)
    W:SetScript("OnDragStop", W.StopMovingOrSizing)
    table.insert(UISpecialFrames, "TTS_MatchLogCopyFrame")

    local title = W:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 18, -16)
    Loc:Bind(title, "matchLog.title")

    local close = CreateFrame("Button", nil, W, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    local hint = W:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hint:SetPoint("BOTTOMLEFT", 20, 20)
    Loc:Bind(hint, "matchLog.hint")

    local selectBtn = CreateFrame("Button", nil, W, "UIPanelButtonTemplate")
    selectBtn:SetSize(110, 22)
    selectBtn:SetPoint("BOTTOMRIGHT", -18, 16)
    Loc:Bind(selectBtn, "matchLog.selectAll")
    selectBtn:SetScript("OnClick", SelectAll)

    local scroll = CreateFrame("ScrollFrame", "TTS_MatchLogCopyScroll", W, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 20, -44)
    scroll:SetPoint("BOTTOMRIGHT", -38, 46)

    local edit = CreateFrame("EditBox", nil, scroll)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(0)
    edit:SetFontObject(ChatFontSmall or GameFontHighlightSmall)
    edit:SetWidth(scroll:GetWidth() > 0 and scroll:GetWidth() or 620)
    edit:SetScript("OnEscapePressed", function() W:Hide() end)
    -- Read-only: typing puts the log back
    edit:SetScript("OnTextChanged", function(self, userInput)
        if userInput and W.text then self:SetText(W.text); self:HighlightText() end
    end)
    scroll:SetScrollChild(edit)
    scroll:SetScript("OnSizeChanged", function(self, w) edit:SetWidth(w) end)
    W.edit = edit
    W.scroll = scroll
end

function R:ShowCopyWindow()
    if not W then BuildWindow() end
    W.text = self:Text() or L("matchLog.none")
    W.edit:SetText(W.text)
    W:Show()
    W.edit:SetCursorPosition(0)
    W.scroll:SetVerticalScroll(0)
    SelectAll()
end
