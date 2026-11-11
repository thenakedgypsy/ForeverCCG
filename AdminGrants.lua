--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
]]
TTS = TTS or {}
local L = TTS.L

-- =========================================================================
-- ADMIN GRANTS
-- The developer's own admin addon (ForeverCCG_Admin, not shipped) whispers these on a
-- prefix of their own, and they are obeyed only from the characters in ADMINS. The server
-- sets the sender of an addon whisper, so it can't be faked (unlike the <from> inside a
-- TTS_NET envelope).
--   GRANT:<cardId>:<n>    REVOKE:<cardId>:<n>    QUERY:<cardId>    WIPE    GRANTALL    BETA    PRIZE
-- answered with  HAS:<cardId>:<copies>:<max>,  WIPED,  GRANTEDALL:<cards that gained copies>,
-- BETAED:<1 = the beta card is new, 0 = they had it>,  PRIZED:<cardId>:<copies>:<max>
-- or  ERR:<reason>[:<cardId>].
-- BETA is the beta welcome a beta player gets at launch (DataStamp.lua): the beta card, then
-- its popup.
-- PRIZE is one copy of a random prize card (Cards\Prizes.lua), drawn here from the ones the
-- player has fewer than 4 of, weighted by prizeWeight, then shown in a popup.
-- Copies are written where the card's own way of being earned keeps them (kills, solo
-- rewards, NPC gifts, the beta flag), so the rest of the addon sees an ordinary collection.
-- =========================================================================
local PREFIX = "TTS_ADM"

-- The developer's characters: full "Firstname Surname" names (any case)
local ADMINS = {}
for _, name in ipairs({
    "Aekku Sekenzen",
    "Aeku Kyuta",
    "Ae Ku",
    "Aekku Skenzen",
    "Aeku Skenzen",
    "Bryek",
    "Hooman"
}) do
    ADMINS[name:lower()] = true
end

local MAX_COPIES = 4

if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
    C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
elseif RegisterAddonMessagePrefix then
    RegisterAddonMessagePrefix(PREFIX)
end

-- "Firstname Surname-Realm" -> "Firstname Surname"
local function NormalizeName(name)
    name = Ambiguate and Ambiguate(name or "", "none") or (name or "")
    return (name:match("^([^%-]+)") or name):trim()
end

local function Reply(target, msg)
    local send = (C_ChatInfo and C_ChatInfo.SendAddonMessage) or SendAddonMessage
    send(PREFIX, msg, "WHISPER", target)
end

-- Collectible cards only: heroes come from level choices, everything else is free to use
local function Grantable(card)
    return card and not card.isHero and TTS:GetOwnedCopies(card) ~= nil
end

local function MaxCopies(card)
    return TTS.CardMaxCopies and TTS:CardMaxCopies(card) or (card.isBeta and 1 or MAX_COPIES)
end

-- Same order as TTS:GetOwnedCopies (SoloEncounters.lua), so the copies land where it reads them
local function SetCopies(card, n)
    local id = card.id
    if card.isReward then
        TTS_SoloProgress = TTS_SoloProgress or {}
        TTS_SoloProgress.rewards = TTS_SoloProgress.rewards or {}
        TTS_SoloProgress.rewards[id] = n > 0 and n or nil
    elseif card.isBoss then
        TTS_KilledBosses = TTS_KilledBosses or {}
        TTS_KilledBosses[id] = n
    elseif card.isGift or card.isProfession then
        TTS_NpcGifts = TTS_NpcGifts or {}
        TTS_NpcGifts.copies = TTS_NpcGifts.copies or {}
        TTS_NpcGifts.copies[id] = n > 0 and n or nil
    elseif card.isBeta then
        TTS_DataStamp = TTS_DataStamp or { launch = true }
        TTS_DataStamp.beta = n > 0 or nil
    elseif card.isPrize then
        TTS_NpcGifts = TTS_NpcGifts or {}
        TTS_NpcGifts.prizes = TTS_NpcGifts.prizes or {}
        TTS_NpcGifts.prizes[id] = n > 0 and n or nil
    end
end

local function RefreshCollection()
    local DB = TTS.DeckBuilderFrame
    if DB and DB:IsShown() and DB.RefreshAll then DB:RefreshAll() end
end

local function CardText(card)
    return TTS.CardLink and TTS:CardLink(card.id) or ("|cFFFFD200" .. TTS:CardName(card) .. "|r")
end

local function Wipe()
    for _, name in ipairs(TTS.COLLECTION_VARS or {}) do
        -- Emptied in place, in case anything kept a reference to the table
        if type(_G[name]) == "table" then wipe(_G[name]) else _G[name] = nil end
    end
    if type(TTS_DataStamp) == "table" then TTS_DataStamp.beta = nil end
    if TTS.EnsureDeckSlots then TTS:EnsureDeckSlots() end
    RefreshCollection()
    DEFAULT_CHAT_FRAME:AddMessage(L("admin.wiped"))
end

-- Every collectible card up to its most copies. Returns how many cards gained copies.
local function GrantAll()
    local changed = 0
    for _, card in pairs(TTS.Cards or {}) do
        if Grantable(card) then
            local max = MaxCopies(card)
            if (TTS:GetOwnedCopies(card) or 0) < max then
                SetCopies(card, max)
                TTS:MarkCardNew(card.id)
                changed = changed + 1
            end
        end
    end
    RefreshCollection()
    DEFAULT_CHAT_FRAME:AddMessage(L("admin.grantedAll", changed))
    return changed
end

-- The beta card (shown again even when they already have it), then the welcome popup.
-- Returns whether the card is new, or nil if this build has no beta card.
local function BetaWelcome()
    local card = TTS.BETA_CARD and TTS.Cards and TTS.Cards[TTS.BETA_CARD]
    if not (card and TTS.ShowBetaWelcome) then return nil end
    local isNew = (TTS:GetOwnedCopies(card) or 0) < 1
    if isNew then
        SetCopies(card, 1)
        TTS:MarkCardNew(card.id)
        RefreshCollection()
    end
    TTS:ShowBetaWelcome()
    return isNew
end

-- =========================================================================
-- PRIZE
-- A static popup with the card set in below the message, as the beta welcome's (DataStamp.lua).
-- OK sends the emote, from the popup's own button so the client allows it.
-- =========================================================================
local CARD_HEAD = 62   -- the card's name and cost are drawn above its frame
local CARD_GAP = 10    -- between the card and the OK button
local prizeCard        -- the card frame, built on first show
local prizeShown       -- the card id the popup is showing

StaticPopupDialogs["TTS_PRIZE"] = {
    text = "%s",
    button1 = OKAY or "Okay",
    -- "/e won [Thrall], a Forever: CCG prize card!" then a /cheer (OK only: Escape skips them)
    OnAccept = function()
        local card = prizeShown and TTS.Cards and TTS.Cards[prizeShown]
        if not card then return end
        local tag = TTS.CardTag and TTS:CardTag(card.id) or TTS:CardName(card)
        SendChatMessage(L("emote.prize", tag), "EMOTE")
        TTS:SafeAfter(0.5, function() DoEmote("CHEER") end)
    end,
    OnHide = function()
        if prizeCard then prizeCard:Hide() end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local function PrizeCardFrame()
    if prizeCard then return prizeCard end
    local f = TTS.CreateCardFrame(UIParent, TTS.PREVIEW_W, TTS.PREVIEW_H)
    f:EnableMouse(true)
    f:SetScript("OnEnter", function(self)
        if prizeShown and TTS.Tooltip then TTS.Tooltip:ShowCard(self, "ANCHOR_RIGHT", prizeShown) end
    end)
    f:SetScript("OnLeave", function(self)
        if TTS.Tooltip then TTS.Tooltip:Hide(self) end
    end)
    f:SetScript("OnClick", nil)
    prizeCard = f
    return f
end

local function ShowPrize(card)
    -- A popup already open is replaced, its card with it
    StaticPopup_Hide("TTS_PRIZE")
    prizeShown = card.id
    local dialog = StaticPopup_Show("TTS_PRIZE", L("admin.prizePopup", TTS:CardName(card)))
    if not (dialog and TTS.CreateCardFrame and TTS.PaintPreviewCard) then return end
    local f = PrizeCardFrame()
    local textFS = dialog.text or _G[dialog:GetName() .. "Text"]
    f:SetParent(dialog)
    f:SetFrameLevel(dialog:GetFrameLevel() + 5)
    f:ClearAllPoints()
    f:SetPoint("TOP", textFS or dialog, "BOTTOM", 0, -CARD_HEAD)
    dialog:SetHeight(dialog:GetHeight() + CARD_HEAD + TTS.PREVIEW_H + CARD_GAP)
    f:Show()
    TTS.PaintPreviewCard(f, card)
end

-- One more copy of a random prize the player can still take copies of, weighted by
-- prizeWeight. Returns the card and its new copy count, or nil if every prize is at its most.
local function GivePrize()
    local open, total = {}, 0
    for _, card in pairs(TTS.Cards or {}) do
        local w = card.isPrize and (tonumber(card.prizeWeight) or 1) or 0
        if w > 0 and (TTS:GetOwnedCopies(card) or 0) < MaxCopies(card) then
            table.insert(open, card)
            total = total + w
        end
    end
    if #open == 0 then return nil end
    table.sort(open, function(a, b) return a.id < b.id end)   -- pairs order isn't fixed
    local roll = math.random() * total
    local card = open[#open]
    for _, c in ipairs(open) do
        roll = roll - (tonumber(c.prizeWeight) or 1)
        if roll < 0 then card = c; break end
    end
    local copies = (TTS:GetOwnedCopies(card) or 0) + 1
    SetCopies(card, copies)
    TTS:MarkCardNew(card.id)
    RefreshCollection()
    DEFAULT_CHAT_FRAME:AddMessage(L("admin.prized", CardText(card), copies, MaxCopies(card)))
    ShowPrize(card)
    return card, copies
end

-- Where every prize came from, newest last: { card, at, source = "admin" | "event",
-- by = who sent it / the organizer, event = "<organizer>:<event id>", name = the event's name }
local PRIZE_LOG_MAX = 200

local function LogPrize(entry)
    TTS_NpcGifts = TTS_NpcGifts or {}
    TTS_NpcGifts.prizeLog = TTS_NpcGifts.prizeLog or {}
    local log = TTS_NpcGifts.prizeLog
    entry.at = time()
    log[#log + 1] = entry
    while #log > PRIZE_LOG_MAX do table.remove(log, 1) end
end

-- =========================================================================
-- TOURNAMENT PRIZES
-- Won by finishing first in a ForeverCCG_Events tournament: that addon calls
-- TTS:AwardTournamentPrize on the winner's own client when the event ends. Nobody hands these out,
-- so no organizer needs any power over anyone's collection. The organizer's client still
-- reports the standings, so the rules below are what keep a made-up event from paying out:
--   * at least PRIZE_MIN_PLAYERS in the final standings
--   * this client itself saw the player win games against PRIZE_MIN_BEATEN different opponents
--     during the event (real games, through the engine, not the organizer's word)
--   * one prize per event, and one tournament prize per account every PRIZE_COOLDOWN
-- The collection is saved per account, so alts share the cooldown.
-- =========================================================================
TTS.PRIZE_MIN_PLAYERS = 4
TTS.PRIZE_MIN_BEATEN = 2
TTS.PRIZE_COOLDOWN = 7 * 86400

-- info: { organizer, event (the event id), name, players (in the standings), beaten (opponents
-- beaten) }. Returns the card and its copies, or nil and a reason:
--   "invalid", "players", "beaten", "claimed", "cooldown" (and the seconds left), "full"
function TTS:AwardTournamentPrize(info)
    if type(info) ~= "table" or type(info.organizer) ~= "string" or type(info.event) ~= "string"
        or info.organizer == "" or info.event == "" then
        return nil, "invalid"
    end
    if (tonumber(info.players) or 0) < TTS.PRIZE_MIN_PLAYERS then return nil, "players" end
    if (tonumber(info.beaten) or 0) < TTS.PRIZE_MIN_BEATEN then return nil, "beaten" end

    local key = info.organizer:lower() .. ":" .. info.event
    local now = time()
    local lastWin
    for _, entry in ipairs(TTS_NpcGifts and TTS_NpcGifts.prizeLog or {}) do
        if entry.source == "event" then
            if entry.event == key then return nil, "claimed" end
            if not lastWin or (entry.at or 0) > lastWin then lastWin = entry.at or 0 end
        end
    end
    if lastWin and now - lastWin < TTS.PRIZE_COOLDOWN then
        return nil, "cooldown", TTS.PRIZE_COOLDOWN - (now - lastWin)
    end

    local card, copies = GivePrize()
    if not card then return nil, "full" end
    LogPrize({ card = card.id, source = "event", by = info.organizer, event = key,
        name = type(info.name) == "string" and info.name:sub(1, 60) or nil })
    return card, copies
end

local function OnAdminMessage(msg, sender)
    local cmd, cardId, count = strsplit(":", msg)
    if cmd == "PRIZE" then
        local card, copies = GivePrize()
        if card then
            LogPrize({ card = card.id, source = "admin", by = sender })
            Reply(sender, "PRIZED:" .. card.id .. ":" .. copies .. ":" .. MaxCopies(card))
        else
            Reply(sender, "ERR:NO_PRIZES_LEFT")
        end
        return
    end
    if cmd == "BETA" then
        local isNew = BetaWelcome()
        if isNew == nil then
            Reply(sender, "ERR:UNKNOWN:" .. tostring(TTS.BETA_CARD))
        else
            Reply(sender, "BETAED:" .. (isNew and 1 or 0))
        end
        return
    end
    if cmd == "WIPE" then
        Wipe()
        Reply(sender, "WIPED")
        return
    end
    if cmd == "GRANTALL" then
        Reply(sender, "GRANTEDALL:" .. GrantAll())
        return
    end

    local card = cardId and TTS.Cards and TTS.Cards[cardId]
    if not card then Reply(sender, "ERR:UNKNOWN:" .. tostring(cardId)) return end
    if not Grantable(card) then Reply(sender, "ERR:NOT_COLLECTIBLE:" .. cardId) return end

    local max = MaxCopies(card)
    local have = TTS:GetOwnedCopies(card) or 0
    local n = math.max(1, math.floor(tonumber(count) or 1))
    if cmd == "GRANT" then
        local new = math.min(max, have + n)
        if new > have then
            SetCopies(card, new)
            TTS:MarkCardNew(card.id)
            RefreshCollection()
            DEFAULT_CHAT_FRAME:AddMessage(L("admin.granted", CardText(card), new, max))
        end
        have = new
    elseif cmd == "REVOKE" then
        local new = math.max(0, have - n)
        if new < have then
            SetCopies(card, new)
            RefreshCollection()
            DEFAULT_CHAT_FRAME:AddMessage(L("admin.revoked", CardText(card), new, max))
        end
        have = new
    elseif cmd ~= "QUERY" then
        Reply(sender, "ERR:UNKNOWN_COMMAND:" .. tostring(cmd))
        return
    end
    Reply(sender, "HAS:" .. card.id .. ":" .. have .. ":" .. max)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:SetScript("OnEvent", function(_, _, prefix, msg, channel, sender)
    if issecretvalue and (issecretvalue(prefix) or issecretvalue(msg) or issecretvalue(channel) or issecretvalue(sender)) then return end
    if prefix ~= PREFIX or channel ~= "WHISPER" or type(msg) ~= "string" then return end
    -- Replies are never answered, or two clients (or one whispering itself) would bounce
    -- errors back and forth forever
    if msg:match("^HAS:") or msg:match("^ERR:") or msg == "WIPED" or msg:match("^GRANTEDALL:")
        or msg:match("^BETAED:") or msg:match("^PRIZED:") then return end
    local from = NormalizeName(sender)
    if ADMINS[from:lower()] then
        OnAdminMessage(msg, from)
    else
        -- Refused, with the name as we see it, so a misspelt ADMINS entry is easy to spot
        Reply(sender, "ERR:NOT_ADMIN:" .. from)
    end
end)
