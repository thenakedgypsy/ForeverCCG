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
--   GRANT:<cardId>:<n>    REVOKE:<cardId>:<n>    QUERY:<cardId>    WIPE    GRANTALL
-- answered with  HAS:<cardId>:<copies>:<max>,  WIPED,  GRANTEDALL:<cards that gained copies>
-- or  ERR:<reason>[:<cardId>].
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
    "Bryek"
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
    return card.isBeta and 1 or MAX_COPIES
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
    elseif card.isGift then
        TTS_NpcGifts = TTS_NpcGifts or {}
        TTS_NpcGifts.copies = TTS_NpcGifts.copies or {}
        TTS_NpcGifts.copies[id] = n > 0 and n or nil
    elseif card.isBeta then
        TTS_DataStamp = TTS_DataStamp or { launch = true }
        TTS_DataStamp.beta = n > 0 or nil
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

local function OnAdminMessage(msg, sender)
    local cmd, cardId, count = strsplit(":", msg)
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
    if prefix ~= PREFIX or channel ~= "WHISPER" or type(msg) ~= "string" then return end
    -- Replies are never answered, or two clients (or one whispering itself) would bounce
    -- errors back and forth forever
    if msg:match("^HAS:") or msg:match("^ERR:") or msg == "WIPED" or msg:match("^GRANTEDALL:") then return end
    local from = NormalizeName(sender)
    if ADMINS[from:lower()] then
        OnAdminMessage(msg, from)
    else
        -- Refused, with the name as we see it, so a misspelt ADMINS entry is easy to spot
        Reply(sender, "ERR:NOT_ADMIN:" .. from)
    end
end)
