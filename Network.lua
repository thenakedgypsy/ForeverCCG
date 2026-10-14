--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
local ADDON_NAME = ...
TTS = TTS or {}
TTS.Net = TTS.Net or {}

TTS.DOWNLOAD_URL = "https://www.curseforge.com/wow/addons/forever-ccg"

-- =========================================================================
-- ADDON VERSION (read from the .toc "## Version:" line)
-- Both players must run the same version to play each other.
-- =========================================================================
local function ReadAddonVersion()
    local getMeta = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
    local v = getMeta and getMeta(ADDON_NAME, "Version")
    if v and v ~= "" then return v end
    return "unknown"
end
TTS.VERSION = ReadAddonVersion()

local PREFIX = "TTS_NET"
if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
    C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
elseif RegisterAddonMessagePrefix then
    RegisterAddonMessagePrefix(PREFIX)
end

-- Custom chat channel used for ALL addon traffic (waiting room, challenges and matches)
local LFM_CHANNEL = "FCCGTTSE"

-- Seconds the receiver has to click Accept/Decline on the challenge popup
local CHALLENGE_POPUP_TIMEOUT = 60

-- Seconds an outgoing challenge stays valid. Longer than the popup so an accept
-- clicked at the last second still has time to travel back over the channel.
local INVITE_EXPIRY = 90

-- Seconds to wait for INVITE_ACK before deciding the target doesn't have the addon
local INVITE_ACK_TIMEOUT = 8

-- Seconds after sending a challenge before the Invite buttons work again
local INVITE_COOLDOWN = 45

-- How many times (1s apart) to retry joining the channel before dropping queued messages
local MAX_JOIN_ATTEMPTS = 5

-- =========================================================================
-- CHANNEL ENVELOPES
--   "LFM_..."                  broadcast to everyone in the channel
--   "T:<recipient>:<from>:<payload>"  addressed to one player (challenges, pre-match)
--   "M:<matchId>:<from>:<payload>"    in-match traffic, only the two players know the id
-- <from> is the sender's waiting-room name, used as the sender everywhere
-- =========================================================================

-- Preserves full "Firstname Surname" while stripping any realm tag
local function NormalizeName(name)
    if not name then return "" end
    name = name:match("^([^%-]+)") or name
    return name:trim()
end

local function SameName(a, b)
    if not a or not b then return false end
    return NormalizeName(a):lower() == NormalizeName(b):lower()
end

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end

-- Waiting-room names can be "Firstname Surname" (or carry a PvP rank title), but whispers
-- and group checks need the character name. Learned from every message that arrives, and
-- kept with saved contacts. [lower waiting-room name] = character name
local charNames = {}

local function RememberCharName(fullName, charName)
    if not fullName or not charName or charName == "" then return end
    local key = NormalizeName(fullName):lower()
    charNames[key] = charName
    local c = type(TTS_Contacts) == "table" and TTS_Contacts[key]
    if type(c) == "table" then c.unit = charName end
end

local function CharName(name)
    local key = NormalizeName(name):lower()
    local c = type(TTS_Contacts) == "table" and TTS_Contacts[key]
    return charNames[key]
        or (TTS.WaitingRoom and TTS.WaitingRoom.unitNames and TTS.WaitingRoom.unitNames[key])
        or (type(c) == "table" and c.unit)
        or NormalizeName(name):match("^(%S+)") or name
end
TTS.Net.CharName = CharName

-- Our identity on the network: the same name the waiting room advertises
local function MyName()
    if TTS.GetPlayerFullName then
        return TTS.GetPlayerFullName()
    end
    return NormalizeName(UnitName("player"))
end

-- Our collection score. Sent as an optional trailing field (INVITE/ACCEPT) or in its own
-- LFM_SCORE message, so builds that don't know about it simply ignore it.
local function MyScore()
    return TTS.GetCollectionScore and (TTS:GetCollectionScore()) or 0
end
TTS.Net.MyScore = MyScore

local function NewMatchId()
    return string.format("%08x%04x%04x", time(), math.random(0, 0xFFFF), math.random(0, 0xFFFF))
end

local function IsMatchOpponent(sender)
    local E = TTS.Engine
    return E and E.inMatch and not E.isSolo and SameName(E.opponent, sender)
end

function TTS:SafeAfter(seconds, callback)
    if C_Timer and C_Timer.After then
        C_Timer.After(seconds, callback)
    else
        local delayFrame = CreateFrame("Frame")
        local elapsed = 0
        delayFrame:SetScript("OnUpdate", function(self, dt)
            elapsed = elapsed + dt
            if elapsed >= seconds then
                self:SetScript("OnUpdate", nil)
                callback()
            end
        end)
    end
end

-- Returns the channel number of FCCGTTSE, or nil if we haven't joined it
local function GetLFMChannelId()
    local id = GetChannelName(LFM_CHANNEL)
    if id and id > 0 then return id end
    return nil
end

local function JoinLFMChannel()
    if GetLFMChannelId() then return end
    if JoinTemporaryChannel then
        JoinTemporaryChannel(LFM_CHANNEL)
    else
        JoinChannelByName(LFM_CHANNEL)
    end
end

-- =========================================================================
-- PACED SENDING
-- The server allows each addon prefix a burst of about 10 messages, then about 1 a second,
-- and silently drops the rest. Waiting-room heartbeats and contact pings alone can use all
-- of that, so every message goes through this queue: game traffic (challenges, matches)
-- first, background traffic (announces, pings, contact lists) only with what is left.
-- =========================================================================
local SEND_BURST = 8        -- kept under the server's burst so a reply never finds it empty
local SEND_RATE = 1         -- messages per second once the burst is used
local LOW_QUEUE_MAX = 15    -- background messages waiting beyond this drop the oldest

local sendQueues = { high = {}, low = {} }
local sendTokens = SEND_BURST
local lastRefill = GetTime and GetTime() or 0
local pumpScheduled = false
local reportedFailures = {}

-- Result codes that mean "too fast, try again": the per-prefix addon limit (3) and the
-- custom channel's own limit (8, hit by bursts like a big attack)
local RESULTS = Enum and Enum.SendAddonMessageResult
local THROTTLE_CODES = {
    [(RESULTS and RESULTS.AddonMessageThrottle) or 3] = true,
    [(RESULTS and RESULTS.ChannelThrottle) or 8] = true,
}

-- Returns "ok", "throttled" or "failed", plus the client's result code
local function RawSend(m)
    local send = (C_ChatInfo and C_ChatInfo.SendAddonMessage) or SendAddonMessage
    local result = send(PREFIX, m.msg, m.chatType, m.target)
    -- Older clients return nothing or true; newer ones a result code (0 = success)
    if result == nil or result == true or result == 0 then return "ok" end
    if THROTTLE_CODES[result] then return "throttled", result end
    return "failed", result
end

local function ReportSendFailure(m, code)
    local key = tostring(m.chatType) .. ":" .. tostring(code)
    if reportedFailures[key] then return end
    reportedFailures[key] = true
    Print(string.format("|cFFFF2222[TTSE]|r A message over %s could not be sent (error %s).",
        m.chatType == "CHANNEL" and LFM_CHANNEL or tostring(m.chatType), tostring(code)))
end

local function PumpSendQueue()
    pumpScheduled = false
    local now = GetTime()
    sendTokens = math.min(SEND_BURST, sendTokens + (now - lastRefill) * SEND_RATE)
    lastRefill = now
    while sendTokens >= 1 do
        local q = (#sendQueues.high > 0) and sendQueues.high or sendQueues.low
        local m = q[1]
        if not m then break end
        local status, code = RawSend(m)
        if status == "throttled" then
            -- Still over the server's limit: keep it and try again shortly
            sendTokens = 0
            break
        end
        table.remove(q, 1)
        sendTokens = sendTokens - 1
        if status == "failed" then ReportSendFailure(m, code) end
    end
    if #sendQueues.high + #sendQueues.low > 0 then
        pumpScheduled = true
        TTS:SafeAfter(1 / SEND_RATE, PumpSendQueue)
    end
end

-- low = background traffic, sent only when no game message is waiting
local function QueueSend(msg, chatType, target, low)
    local q = low and sendQueues.low or sendQueues.high
    if low and #q >= LOW_QUEUE_MAX then table.remove(q, 1) end
    table.insert(q, { msg = msg, chatType = chatType, target = target })
    if not pumpScheduled then PumpSendQueue() end
end

local function RawChannelSend(channelId, msg, low)
    QueueSend(msg, "CHANNEL", channelId, low)
end

-- Messages sent before the channel is joined are queued so they go out in order
local channelQueue = {}
local flushScheduled = false
local joinAttempts = 0

local function FlushChannelQueue()
    flushScheduled = false
    local id = GetLFMChannelId()
    if not id then
        joinAttempts = joinAttempts + 1
        if joinAttempts >= MAX_JOIN_ATTEMPTS then
            joinAttempts = 0
            wipe(channelQueue)
            Print("|cFFFF2222[TTSE]|r Could not join the " .. LFM_CHANNEL .. " channel; messages were not sent.")
            return
        end
        JoinLFMChannel()
        flushScheduled = true
        TTS:SafeAfter(1, FlushChannelQueue)
        return
    end
    joinAttempts = 0
    for i = 1, #channelQueue do
        RawChannelSend(id, channelQueue[i].msg, channelQueue[i].low)
    end
    wipe(channelQueue)
end

local function SendChannel(msg, low)
    local id = GetLFMChannelId()
    if id and #channelQueue == 0 then
        RawChannelSend(id, msg, low)
        return
    end
    table.insert(channelQueue, { msg = msg, low = low })
    if not flushScheduled then
        flushScheduled = true
        JoinLFMChannel()
        TTS:SafeAfter(1, FlushChannelQueue)
    end
end

-- chatType is one of the fallback routes; target (a waiting-room name) is only used for "WHISPER"
local function SendDirect(msg, chatType, target, low)
    QueueSend(msg, chatType, target and CharName(target), low)
end

local function NameMatchesUnit(name, unit)
    if not UnitExists(unit) then return false end
    local want = NormalizeName(name):lower()
    local n = NormalizeName(UnitName(unit)):lower()
    -- The waiting-room name may be "Firstname Surname" while UnitName is just "Firstname"
    return n ~= "" and (want == n or want:sub(1, #n + 1) == n .. " " or CharName(name):lower() == n)
end

-- True if the named player is in our party (or our subgroup, when in a raid)
local function InMyParty(name)
    if not IsInGroup or not IsInGroup(LE_PARTY_CATEGORY_HOME) then return false end
    for i = 1, 4 do
        if NameMatchesUnit(name, "party" .. i) then return true end
    end
    return false
end

-- True if we are in a raid and the named player is in it
local function InMyRaid(name)
    if not IsInRaid or not IsInRaid(LE_PARTY_CATEGORY_HOME) then return false end
    for i = 1, 40 do
        if NameMatchesUnit(name, "raid" .. i) then return true end
    end
    return false
end

-- Fallback order after FCCGTTSE (which is always tried first)
local FALLBACK_ROUTES = { "WHISPER", "PARTY", "RAID", "GUILD", "YELL" }

local ROUTE_LABELS = {
    WHISPER = "whisper",
    PARTY = "party chat",
    RAID = "raid chat",
    GUILD = "guild chat",
    YELL = "yell",
}

-- Whether a route can currently reach the named player
local function RouteAvailable(route, target)
    if route == "WHISPER" or route == "YELL" then return true end
    if route == "PARTY" then return InMyParty(target) end
    if route == "RAID" then return InMyRaid(target) end
    if route == "GUILD" then return IsInGuild and IsInGuild() or false end
    return false
end

-- The next usable route after `current` (nil = FCCGTTSE), or nil when none are left
local function NextRoute(current, target)
    local start = 1
    if current then
        for i, r in ipairs(FALLBACK_ROUTES) do
            if r == current then start = i + 1 end
        end
    end
    for i = start, #FALLBACK_ROUTES do
        if RouteAvailable(FALLBACK_ROUTES[i], target) then
            return FALLBACK_ROUTES[i]
        end
    end
    return nil
end

TTS.Net.pendingInvites = {}   -- [lowerName] = name : waiting for INVITE_ACK (addon-installed check)
TTS.Net.outgoingInvites = {}  -- [lowerName] = { sentAt = time(), matchId = id } : challenges we sent that may still be accepted
TTS.Net.incomingChallenge = nil -- name of the player whose challenge popup is currently open
TTS.Net.matchId = nil         -- id of the current (or most recent) match
-- [lowerName] = one of FALLBACK_ROUTES : fallback route to a player. nil means FCCGTTSE (always tried first)
TTS.Net.routes = {}

function TTS.Net:BroadcastLFM(msg)
    SendChannel(msg, true)
end

-- Seconds until another challenge can be sent (0 = now)
function TTS.Net:InviteCooldownLeft()
    return math.max(0, math.ceil((self.lastInviteAt or -INVITE_COOLDOWN) + INVITE_COOLDOWN - GetTime()))
end

-- True while a challenge to this player is still looking for them (retrying routes)
function TTS.Net:IsInvitePending(target)
    return self.pendingInvites[NormalizeName(target or ""):lower()] ~= nil
end

-- Challenges can only be issued from the Waiting Room, which calls this.
function TTS.Net:InvitePlayer(target)
    if not target or target == "" then return end
    target = NormalizeName(target)

    if self:IsInvitePending(target) then
        Print("|cFFFFD200[TTSE]|r Still trying to reach " .. target .. ". Please wait.")
        return
    end
    local wait = self:InviteCooldownLeft()
    if wait > 0 then
        Print(string.format("|cFFFFD200[TTSE]|r You can send another challenge in %d seconds.", wait))
        return
    end

    local E = TTS.Engine
    if E and E.inMatch then
        Print("|cFFFF2222[TTSE]|r You are already in a match.")
        return
    end
    if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() then
        Print("|cFFFF2222[TTSE]|r Close the Deckbuilder before challenging a player.")
        return
    end
    if E and not E:ValidateDeck() then
        Print("|cFFFF2222[TTSE]|r Your active deck must have 40-50 cards before you can challenge someone.")
        return
    end

    local inviteKey = target:lower()
    local matchId = NewMatchId()
    -- FCCGTTSE first, unless a contact just answered by whisper (likely on another realm's channel)
    local viaWhisper = self.routes[inviteKey] == "WHISPER" and self:ContactRecentlyReached(target)
    if not viaWhisper then self.routes[inviteKey] = nil end
    -- route: the one this challenge is on now (nil = FCCGTTSE). Kept here rather than read back
    -- from self.routes, which any message from them (e.g. a contact ping) changes.
    self.outgoingInvites[inviteKey] = { sentAt = time(), matchId = matchId, route = viaWhisper and "WHISPER" or nil,
        tried = { viaWhisper and ROUTE_LABELS.WHISPER or LFM_CHANNEL } }
    self.pendingInvites[inviteKey] = target
    self.lastInviteAt = GetTime()
    if TTS.WaitingRoom and TTS.WaitingRoom.UpdateUI then TTS.WaitingRoom:UpdateUI() end

    self:Send(target, "INVITE:" .. TTS.VERSION .. ":" .. matchId .. ":" .. MyScore())
    Print("|cFF00FF00[TTSE]|r Invitation sent to " .. target .. ". Checking for addon...")
    self:AwaitInviteAck(inviteKey, matchId)
end

-- If the invite gets no INVITE_ACK, retry on the next route:
-- FCCGTTSE -> whisper -> party -> raid -> guild -> yell -> give up
-- Routes that can't reach the player (not grouped, no guild) are skipped.
function TTS.Net:AwaitInviteAck(inviteKey, matchId)
    TTS:SafeAfter(INVITE_ACK_TIMEOUT, function()
        local Net = TTS.Net
        local target = Net.pendingInvites[inviteKey]
        local invite = Net.outgoingInvites[inviteKey]
        -- Acknowledged, cancelled, or replaced by a newer challenge
        if not target or not invite or invite.matchId ~= matchId then return end

        local current = invite.route
        local nextRoute = NextRoute(current, target)

        if nextRoute then
            invite.route = nextRoute
            Net.routes[inviteKey] = nextRoute
            invite.sentAt = time()
            table.insert(invite.tried, ROUTE_LABELS[nextRoute])
            Print(string.format("|cFFFFD200[TTSE]|r No response from %s on %s. Retrying over %s...",
                target, current and ROUTE_LABELS[current] or LFM_CHANNEL, ROUTE_LABELS[nextRoute]))
            Net:Send(target, "INVITE:" .. TTS.VERSION .. ":" .. matchId .. ":" .. MyScore())
            Net:AwaitInviteAck(inviteKey, matchId)
            return
        end

        Net.pendingInvites[inviteKey] = nil
        Net.outgoingInvites[inviteKey] = nil
        Net.routes[inviteKey] = nil

        local triedGroup = false
        for _, label in ipairs(invite.tried) do
            if label == ROUTE_LABELS.PARTY or label == ROUTE_LABELS.RAID then triedGroup = true end
        end

        local whisperMsg = string.format("I tried to challenge you to a game of Forever: CCG but couldn't reach you. If you have it installed, join my party and I'll challenge you again. If not, visit: %s to download!", TTS.DOWNLOAD_URL)
        SendChatMessage(whisperMsg, "WHISPER", nil, CharName(target))
        local tried = table.concat(invite.tried, ", ")
        if triedGroup then
            Print(string.format("|cFFFF4444[TTSE]|r %s didn't respond (tried: %s). They may not have Forever: CCG installed. Whisper sent!",
                target, tried))
        else
            Print(string.format("|cFFFF4444[TTSE]|r %s didn't respond (tried: %s). If they have Forever: CCG, invite them to your party (or raid) and challenge them again. Whisper sent!",
                target, tried))
        end
    end)
end

-- =========================================================================
-- CONTACTS
-- WoW: Forever splits each realm into several hidden backend realms, and a custom
-- channel only reaches players on your own one; whispers reach all of them. So
-- everyone you play or see in the waiting room is saved as a contact, and while
-- the waiting room is open each one gets an addon-whisper CONTACT_PING (invisible
-- to both players). A contact who is queued shows up in your waiting room.
--   CONTACT_PING:<queued 0/1>:<score>   answered with   CONTACT_PONG:<queued 0/1>:<score>
-- When someone becomes a direct contact (seen, played, or answered a ping) the two of
-- you swap contact lists, so one link across the realm split brings in everyone they
-- know. Shared entries carry how long ago their owner last saw that player:
--   CONTACT_LIST:<1 = send me yours>:<name>=<seconds ago>,<name>=<seconds ago>,...
-- (split over several messages). A shared contact keeps that age instead of being
-- refreshed, so the same expiry and size limit apply and offline players aren't kept
-- alive by passing them around. Shared contacts don't start swaps of their own until
-- they answer a ping. Older builds ignore all of these.
-- =========================================================================
local CONTACT_MAX = 50                  -- most recently seen contacts kept, for direct and shared each
local CONTACT_TTL = 30 * 24 * 60 * 60   -- forgotten after 30 days unseen
local CONTACT_PING_EVERY = 9            -- seconds between pings to one contact (the waiting room ticks every 10)
local CONTACT_PINGS_PER_TICK = 4         -- with the heartbeat, stays under the ~1 message/s addon limit
local CONTACT_REPLY_WAIT = 6            -- no pong by then: treat them as offline
local CONTACT_OFFLINE_BACKOFF = 120     -- seconds an offline contact is left alone
local CONTACT_REACHED_FRESH = 60        -- a pong this recent sends challenges by whisper straight away
local CONTACT_SWAP_COOLDOWN = 600       -- seconds before swapping lists with the same player again
local CONTACT_LIST_CHUNK = 170          -- characters of entries per message (addon messages cap at 255)

-- Runtime state per lower-case name: { lastPing, lastReached, offlineUntil, lastSwap }
local contactState = {}
-- Lower-case names pinged a moment ago, so their "No player named" error can be hidden
local pendingPings = {}

local function ContactDB()
    if type(TTS_Contacts) ~= "table" then TTS_Contacts = {} end
    return TTS_Contacts
end

local function ContactState(key)
    contactState[key] = contactState[key] or {}
    return contactState[key]
end

-- Keeps the lists small: drops anything long unseen, then the oldest past CONTACT_MAX.
-- Direct and shared contacts are capped separately, so a big shared list never
-- pushes out players you reached yourself.
local function PruneContacts()
    local db = ContactDB()
    local direct, shared, cutoff = {}, {}, time() - CONTACT_TTL
    for key, c in pairs(db) do
        if type(c) ~= "table" or not c.name or (c.seen or 0) < cutoff then
            db[key] = nil
        else
            local group = c.shared and shared or direct
            group[#group + 1] = key
        end
    end
    for _, keys in ipairs({ direct, shared }) do
        if #keys > CONTACT_MAX then
            table.sort(keys, function(a, b) return db[a].seen > db[b].seen end)
            for i = CONTACT_MAX + 1, #keys do db[keys[i]] = nil end
        end
    end
end

-- Sends our contact list to name, a few entries per message. wantTheirs asks for theirs back.
local function SendContactList(name, wantTheirs)
    ContactState(name:lower()).lastSwap = time()
    local db, now = ContactDB(), time()
    local list = {}
    for _, c in pairs(db) do
        if type(c) == "table" and c.name and not SameName(c.name, name) then list[#list + 1] = c end
    end
    table.sort(list, function(a, b) return (a.seen or 0) > (b.seen or 0) end)

    local chunks, current = {}, {}
    local length = 0
    for _, c in ipairs(list) do
        local entry = c.name .. "=" .. math.max(0, now - (c.seen or now))
        if length + #entry + 1 > CONTACT_LIST_CHUNK and #current > 0 then
            chunks[#chunks + 1] = table.concat(current, ",")
            current, length = {}, 0
        end
        current[#current + 1] = entry
        length = length + #entry + 1
    end
    -- An empty list still goes out, so a request for theirs is never lost
    if #current > 0 or #chunks == 0 then chunks[#chunks + 1] = table.concat(current, ",") end

    local flag = wantTheirs and "1" or "0"
    for i, entries in ipairs(chunks) do
        -- Only the first message asks for theirs; spaced out so the server doesn't throttle the burst
        local ask = (i == 1) and flag or "0"
        TTS:SafeAfter(0.5 + (i - 1) * 0.2, function()
            TTS.Net:Send(name, "CONTACT_LIST:" .. ask .. ":" .. entries)
        end)
    end
end

-- Adds the players from another contact's list. A newer sighting than ours updates the
-- age; nothing here counts as seeing them ourselves.
local function MergeSharedContacts(entries)
    local db, now = ContactDB(), time()
    for entry in (entries or ""):gmatch("[^,]+") do
        local name, age = entry:match("^(.-)=(%d+)$")
        name = name and NormalizeName(name)
        if name and name ~= "" and name ~= "Target Dummy" and not SameName(name, MyName()) then
            local seen = now - tonumber(age)
            local key = name:lower()
            local existing = db[key]
            if type(existing) ~= "table" then
                db[key] = { name = name, seen = seen, shared = true }
            elseif seen > (existing.seen or 0) then
                existing.seen = seen
            end
        end
    end
    PruneContacts()
end

-- Saves (or refreshes) a contact we reached ourselves, by their waiting-room name
-- ("Firstname Surname"). The first time they become a direct contact, we swap lists.
function TTS.Net:AddContact(name)
    name = NormalizeName(name)
    if name == "" or name == "Target Dummy" or SameName(name, MyName()) then return end
    local db = ContactDB()
    local key = name:lower()
    local before = db[key]
    local becameDirect = type(before) ~= "table" or before.shared
    db[key] = { name = name, seen = time(), unit = charNames[key] or (type(before) == "table" and before.unit or nil) }
    PruneContacts()

    local s = ContactState(key)
    if becameDirect and (time() - (s.lastSwap or 0)) >= CONTACT_SWAP_COOLDOWN then
        SendContactList(name, true)
    end
end

function TTS.Net:ContactRecentlyReached(name)
    local s = contactState[NormalizeName(name):lower()]
    return s and s.lastReached and (time() - s.lastReached) <= CONTACT_REACHED_FRESH or false
end

-- Our waiting-room state, as sent in pings and pongs
local function MyLFMFields()
    local queued = TTS.WaitingRoom and TTS.WaitingRoom.isQueued
    return (queued and "1" or "0") .. ":" .. MyScore()
end

-- A contact reported they are queued: show them like a channel announce would
local function NoteContactWaiting(name, score)
    local WR = TTS.WaitingRoom
    if not WR then return end
    WR.players[name] = time()
    if score then WR.scores[name:lower()] = score end
    if WR.frame and WR.frame:IsShown() then WR:UpdateUI() end
end

-- Pings the contacts that are due: direct before shared, then most recently seen first
-- (the waiting room calls this)
function TTS.Net:PingContacts()
    local E = TTS.Engine
    if E and E.inMatch then return end
    local db, now = ContactDB(), time()
    local due = {}
    for key, c in pairs(db) do
        local s = ContactState(key)
        if type(c) == "table" and c.name and not SameName(c.name, MyName())
            and (s.offlineUntil or 0) <= now and (now - (s.lastPing or 0)) >= CONTACT_PING_EVERY then
            due[#due + 1] = c
        end
    end
    table.sort(due, function(a, b)
        if (a.shared or false) ~= (b.shared or false) then return not a.shared end
        return (a.seen or 0) > (b.seen or 0)
    end)

    local fields = MyLFMFields()
    for i = 1, math.min(#due, CONTACT_PINGS_PER_TICK) do
        local name = due[i].name
        local key = name:lower()
        ContactState(key).lastPing = now
        -- Spaced out so the server doesn't throttle the burst
        TTS:SafeAfter((i - 1) * 0.15, function()
            pendingPings[key] = time() + CONTACT_REPLY_WAIT
            SendDirect("T:" .. name .. ":" .. MyName() .. ":CONTACT_PING:" .. fields, "WHISPER", name, true)
            TTS:SafeAfter(CONTACT_REPLY_WAIT, function()
                local s = ContactState(key)
                if (s.lastReached or 0) < (s.lastPing or 0) then
                    s.offlineUntil = time() + CONTACT_OFFLINE_BACKOFF
                end
                if pendingPings[key] and pendingPings[key] <= time() then pendingPings[key] = nil end
            end)
        end)
    end
end

-- Hides the "No player named ... is currently playing" error for contacts we just pinged
-- (they are offline; nothing the player did). Other such errors still show.
local notFoundPattern
if ERR_CHAT_PLAYER_NOT_FOUND_S then
    notFoundPattern = "^" .. ERR_CHAT_PLAYER_NOT_FOUND_S:gsub("([%(%)%.%+%-%*%?%[%]%^%$])", "%%%1"):gsub("%%s", "(.+)") .. "$"
end

local function OfflinePingFilter(_, _, msg, ...)
    if type(msg) ~= "string" or not next(pendingPings) then return false, msg, ... end
    local lower = msg:lower()
    local named = notFoundPattern and msg:match(notFoundPattern)
    for key, expires in pairs(pendingPings) do
        -- The error names the character we whispered, which may differ from the waiting-room name
        local char = CharName(key):lower()
        local namedKey = named and NormalizeName(named):lower()
        if expires >= time() and ((namedKey and (namedKey == key or namedKey == char))
            or (not named and (lower:find(key, 1, true) or lower:find(char, 1, true)))) then
            pendingPings[key] = nil
            ContactState(key).offlineUntil = time() + CONTACT_OFFLINE_BACKOFF
            return true
        end
    end
    return false, msg, ...
end
if ChatFrame_AddMessageEventFilter then
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", OfflinePingFilter)
end

-- Unwraps a channel message and hands it to OnReceive if it is meant for us.
-- chatType is how it arrived ("CHANNEL" or a fallback route); replies go back the same way.
function TTS.Net:OnChannelMessage(message, sender, chatType)
    local kind = message:sub(1, 2)
    local from, inner
    if kind == "T:" then
        local recipient
        recipient, from, inner = message:match("^T:([^:]+):([^:]+):(.*)$")
        if not (recipient and not SameName(from, MyName()) and SameName(recipient, MyName())) then
            return
        end
    elseif kind == "M:" then
        local matchId
        matchId, from, inner = message:match("^M:([^:]+):([^:]+):(.*)$")
        if not (matchId and not SameName(from, MyName()) and self.matchId and matchId == self.matchId) then
            return
        end
    end

    if from then
        RememberCharName(from, sender)
        local key = NormalizeName(from):lower()
        if ROUTE_LABELS[chatType] then
            self.routes[key] = chatType
        elseif inner:match("^INVITE:") then
            -- A fresh challenge over FCCGTTSE: answer over FCCGTTSE too
            self.routes[key] = nil
        end
        self:OnReceive(inner, from)
    elseif message:match("^LFM_") then
        self:OnReceive(message, sender)
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_ADDON")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

f:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedName = ...
        if loadedName == ADDON_NAME then
            if TTS.EnsureDeckSlots then
                TTS:EnsureDeckSlots()
            else
                TTS_SavedDecks = TTS_SavedDecks or {
                    [1] = { name = "Default Deck", cards = {} }
                }
                TTS_ActiveDeckIndex = TTS_ActiveDeckIndex or 1
            end
            if TTS.MainFrame and TTS.MainFrame.UpdatePlayState then
                TTS.MainFrame:UpdatePlayState()
            end
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Delay so the default channels (General, Trade...) take their usual numbers first
        TTS:SafeAfter(5, JoinLFMChannel)
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, message, channel, sender = ...
        if prefix == PREFIX then
            local cleanSender = NormalizeName(Ambiguate(sender, "none"))
            -- The channel echoes our own messages back to us
            if SameName(cleanSender, UnitName("player")) then return end
            TTS.Net:OnChannelMessage(message, cleanSender, channel)
        end
    end
end)

function TTS.Net:Send(target, msg)
    -- isSolo stays set after a solo game ends, so only a solo game in progress blocks sending
    local E = TTS.Engine
    if not target or target == "" or target == "Target Dummy" or (E and E.inMatch and E.isSolo) then
        return
    end
    target = NormalizeName(target)
    local envelope
    if self.matchId and IsMatchOpponent(target) then
        envelope = "M:" .. self.matchId .. ":" .. MyName() .. ":" .. msg
    else
        envelope = "T:" .. target .. ":" .. MyName() .. ":" .. msg
    end
    -- One route per message: FCCGTTSE unless a fallback route is set for this player
    -- and it can still reach them
    -- Contact upkeep is background traffic; challenges and matches go first
    local low = msg:match("^CONTACT_") and true or false
    local route = self.routes[target:lower()]
    if route and RouteAvailable(route, target) then
        SendDirect(envelope, route, route == "WHISPER" and target or nil, low)
    else
        SendChannel(envelope, low)
    end
end

-- Older builds sent "INVITE" / "ACCEPT" with no version at all
local function VersionText(v)
    return (v and v ~= "") and v or "an older version"
end

-- Only the first two numbers (major.minor) must match; the patch number is ignored.
-- Falls back to an exact match if either version isn't in "x.y..." form.
local function VersionsCompatible(a, b)
    if not a or not b then return false end
    local aMaj, aMin = a:match("^(%d+)%.(%d+)")
    local bMaj, bMin = b:match("^(%d+)%.(%d+)")
    if not aMaj or not bMaj then return a == b end
    return tonumber(aMaj) == tonumber(bMaj) and tonumber(aMin) == tonumber(bMin)
end

local function ReportVersionMismatch(otherName, otherVersion)
    Print(string.format("|cFFFF2222[TTSE]|r Version mismatch: %s is on %s, you are on %s. Both players must use the same version of Forever: CCG.",
        otherName, VersionText(otherVersion), TTS.VERSION))
end

function TTS.Net:OnReceive(msg, sender)
    sender = NormalizeName(sender)
    local parts = { strsplit(":", msg) }
    local cmd = parts[1]

    -- =====================================================================
    -- WAITING ROOM / LFM HANDLERS
    -- =====================================================================
    if cmd == "LFM_ANNOUNCE" then
        -- Extract full text after "LFM_ANNOUNCE:" without splitting internal spaces
        local pName = msg:match("^LFM_ANNOUNCE:(.+)$") or parts[2] or sender
        pName = NormalizeName(pName)
        RememberCharName(pName, sender)
        TTS.Net:AddContact(pName)
        if TTS.WaitingRoom then
            TTS.WaitingRoom.players[pName] = time()
            -- The chat sender is the character name, which is what a party invite needs
            TTS.WaitingRoom.unitNames[pName:lower()] = sender
            if TTS.WaitingRoom.frame and TTS.WaitingRoom.frame:IsShown() then
                TTS.WaitingRoom:UpdateUI()
            end
        end
        return

    elseif cmd == "LFM_SCORE" then
        -- LFM_SCORE:<score>:<name>, sent alongside LFM_ANNOUNCE (older builds don't send it)
        local score, pName = msg:match("^LFM_SCORE:(%d+):(.+)$")
        if score and TTS.WaitingRoom then
            TTS.WaitingRoom.scores[NormalizeName(pName):lower()] = tonumber(score)
            if TTS.WaitingRoom.frame and TTS.WaitingRoom.frame:IsShown() then
                TTS.WaitingRoom:UpdateUI()
            end
        end
        return

    elseif cmd == "LFM_LEAVE" then
        local pName = msg:match("^LFM_LEAVE:(.+)$") or parts[2] or sender
        pName = NormalizeName(pName)
        if TTS.WaitingRoom then
            TTS.WaitingRoom.players[pName] = nil
            if TTS.WaitingRoom.frame and TTS.WaitingRoom.frame:IsShown() then
                TTS.WaitingRoom:UpdateUI()
            end
        end
        return

    elseif cmd == "LFM_QUERY" then
        if TTS.WaitingRoom and TTS.WaitingRoom.isQueued then
            if TTS.WaitingRoom.BroadcastPresence then
                TTS.WaitingRoom:BroadcastPresence()
            end
        end
        return

    elseif cmd == "CONTACT_PING" or cmd == "CONTACT_PONG" then
        -- Arrives by whisper, so OnChannelMessage has already routed replies to them that way
        local key = sender:lower()
        TTS.Net:AddContact(sender)
        if cmd == "CONTACT_PONG" then
            ContactState(key).lastReached = time()
            ContactState(key).offlineUntil = nil
            pendingPings[key] = nil
        else
            TTS.Net:Send(sender, "CONTACT_PONG:" .. MyLFMFields())
        end
        if parts[2] == "1" then NoteContactWaiting(sender, tonumber(parts[3])) end
        return

    elseif cmd == "CONTACT_LIST" then
        local key = sender:lower()
        local s = ContactState(key)
        -- Asked for ours: answer once (AddContact below must not start a second swap)
        local reply = parts[2] == "1" and (time() - (s.lastSwap or 0)) >= CONTACT_SWAP_COOLDOWN
        if parts[2] == "1" then s.lastSwap = time() end
        TTS.Net:AddContact(sender)
        MergeSharedContacts(msg:match("^CONTACT_LIST:%d:(.*)$"))
        if reply then SendContactList(sender, false) end
        return
    end

    -- =====================================================================
    -- DIRECT GAME MATCH HANDLERS
    -- =====================================================================
    if cmd == "INVITE" then
        -- Always acknowledge so the challenger knows the addon is installed
        TTS.Net:Send(sender, "INVITE_ACK")

        local theirVersion = parts[2]
        local theirMatchId = parts[3]
        local theirScore = tonumber(parts[4])   -- nil from builds without collection scores
        if not VersionsCompatible(theirVersion, TTS.VERSION) then
            TTS.Net:Send(sender, "DECLINE:VERSION:" .. TTS.VERSION)
            ReportVersionMismatch(sender, theirVersion)
            return
        end

        if TTS.Engine and TTS.Engine.inMatch then
            TTS.Net:Send(sender, "DECLINE:IN_MATCH")
            Print("|cFFFF0000[TTSE]|r Auto-declined challenge from " .. sender .. ": you are already in a match.")
            return
        end

        if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() then
            TTS.Net:Send(sender, "DECLINE:DECKBUILDER_OPEN")
            Print("|cFFFF0000[TTSE]|r Auto-declined challenge from " .. sender .. ": close Deckbuilder first.")
            return
        end

        -- Only one challenge popup at a time; a second challenger is told we're busy
        if TTS.Net.incomingChallenge and not SameName(TTS.Net.incomingChallenge, sender) then
            TTS.Net:Send(sender, "DECLINE:BUSY")
            Print("|cFFFF0000[TTSE]|r Auto-declined challenge from " .. sender .. ": another challenge is already pending.")
            return
        end
        TTS.Net.incomingChallenge = sender

        StaticPopupDialogs["TTS_CHALLENGE"] = {
            text = sender .. " has challenged you to a game of Forever: CCG!",
            button1 = "Accept",
            button2 = "Decline",
            OnAccept = function()
                if TTS.Engine and TTS.Engine.inMatch then
                    TTS.Net:Send(sender, "DECLINE:IN_MATCH")
                    Print("|cFFFF0000[TTSE]|r Cannot accept challenge while in a match.")
                    return
                end
                if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() then
                    TTS.Net:Send(sender, "DECLINE:BUSY")
                    Print("|cFFFF0000[TTSE]|r Cannot accept challenge while Deckbuilder is open.")
                    return
                end
                if TTS.Engine and TTS.Engine:ValidateDeck() then
                    TTS.Net:Send(sender, "ACCEPT:" .. TTS.VERSION .. ":" .. theirMatchId .. ":" .. MyScore())
                    TTS.Net.matchId = theirMatchId
                    TTS.Net:AddContact(sender)
                    TTS.Engine:StartMatch(sender, false, false)
                    TTS.Engine.opponentScore = theirScore
                    TTS.Engine.remoteState.handCount = 7
                    TTS.Engine:RefreshUI()
                else
                    TTS.Net:Send(sender, "DECLINE:NO_DECK")
                    Print("|cFFFF0000[TTSE]|r Cannot accept challenge: your active deck must have 40-50 cards.")
                end
            end,
            OnCancel = function()
                TTS.Net:Send(sender, "DECLINE:REFUSED")
            end,
            OnHide = function()
                if SameName(TTS.Net.incomingChallenge, sender) then
                    TTS.Net.incomingChallenge = nil
                end
            end,
            timeout = CHALLENGE_POPUP_TIMEOUT,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("TTS_CHALLENGE")

    elseif cmd == "INVITE_ACK" then
        TTS.Net.pendingInvites[sender:lower()] = nil
        Print("|cFF00FF00[TTSE]|r " .. sender .. " has Forever: CCG installed. Awaiting their response...")

    elseif cmd == "ACCEPT" then
        local key = sender:lower()
        local invite = TTS.Net.outgoingInvites[key]
        TTS.Net.pendingInvites[key] = nil
        TTS.Net.outgoingInvites[key] = nil

        -- Ignore accepts for challenges we never sent (or that have expired)
        if not invite or (time() - invite.sentAt) > INVITE_EXPIRY then
            TTS.Net:Send(sender, "CANCEL:NOT_INVITED")
            return
        end

        local theirVersion = parts[2]
        if not VersionsCompatible(theirVersion, TTS.VERSION) then
            TTS.Net:Send(sender, "CANCEL:VERSION:" .. TTS.VERSION)
            ReportVersionMismatch(sender, theirVersion)
            return
        end

        -- The accept must echo the match id we generated for this challenge
        if parts[3] ~= invite.matchId then
            TTS.Net:Send(sender, "CANCEL:NOT_INVITED")
            return
        end

        if TTS.Engine and TTS.Engine.inMatch then
            TTS.Net:Send(sender, "CANCEL:IN_MATCH")
            Print("|cFFFF0000[TTSE]|r " .. sender .. " accepted, but you are already in a match.")
            return
        end
        if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() then
            TTS.Net:Send(sender, "CANCEL:DECKBUILDER_OPEN")
            Print("|cFFFF0000[TTSE]|r Challenge accepted, but match cancelled because Deckbuilder is open.")
            return
        end
        if TTS.Engine and not TTS.Engine:ValidateDeck() then
            TTS.Net:Send(sender, "CANCEL:NO_DECK")
            Print("|cFFFF0000[TTSE]|r Challenge accepted, but match cancelled: your active deck must have 40-50 cards.")
            return
        end

        Print("|cFF00FF00[TTSE]|r Challenge accepted by " .. sender .. "!")
        TTS.Net.matchId = invite.matchId
        TTS.Net:AddContact(sender)
        if TTS.Engine then
            TTS.Engine:StartMatch(sender, true, false)
            TTS.Engine.opponentScore = tonumber(parts[4])   -- nil from builds without collection scores
            TTS.Engine.remoteState.handCount = 7
            TTS.Engine:RefreshUI()
        end

    elseif cmd == "DECLINE" or cmd == "CANCEL" then
        local key = sender:lower()
        local wasInvited = TTS.Net.outgoingInvites[key] ~= nil
        TTS.Net.pendingInvites[key] = nil
        TTS.Net.outgoingInvites[key] = nil

        local reason = parts[2] or "Declined"
        if cmd == "CANCEL" and IsMatchOpponent(sender) then
            TTS.Engine:EndMatch("cancelled", "Opponent cancelled match setup.")
        elseif not wasInvited and cmd == "DECLINE" then
            -- Not a reply to anything we sent
            return
        end

        if reason == "VERSION" then
            ReportVersionMismatch(sender, parts[3])
        else
            Print("|cFFFF0000[TTSE]|r " .. sender .. " declined or cancelled challenge (" .. reason .. ").")
        end

    elseif cmd == "ACTION" then
        local actionType = parts[2]
        local E = TTS.Engine
        if not E then return end

        -- Only the current opponent can change the board
        if not IsMatchOpponent(sender) then return end

        if actionType == "CONCEDE" then
            E:WinMatch(sender .. " conceded the match.")

        elseif actionType == "DEFEATED" then
            E:WinMatch(sender .. " was defeated.")

        elseif actionType == "DRAW" then
            E.remoteState.handCount = (E.remoteState.handCount or 0) + 1
            E:Log(sender .. " drew a card.", "ACTION")
            E:RefreshUI()

        elseif actionType == "DISCARD" then
            E.remoteState.handCount = math.max(0, (E.remoteState.handCount or 0) - 1)
            local cardId = parts[3]
            if cardId then table.insert(E.remoteState.graveyard, cardId) end
            E:Log(sender .. " discarded a card.", "ACTION")
            E:RefreshUI()

        elseif actionType == "PLAY_LAND" then
            local cardId = parts[3]
            local card = TTS.Cards[cardId]
            E:OnRemotePlay()   -- saves the board first, in case they ask to undo this card
            E.remoteState.handCount = math.max(0, (E.remoteState.handCount or 0) - 1)
            table.insert(E.remoteState.field, {
                id = cardId,
                tapped = false,
                damage = 0,
                tempPower = 0,
                tempToughness = 0,
                uid = time() + #E.remoteState.field
            })
            E:Log(string.format("%s played land: |cFFFFD200%s|r.", sender, card and card.name or cardId), "ACTION")
            E:PlayNonCreatureCardSound()
            E:RefreshUI()

        elseif actionType == "PLAY_PERM" then
            local cardId = parts[3]
            local card = TTS.Cards[cardId]
            E:OnRemotePlay()
            E.remoteState.handCount = math.max(0, (E.remoteState.handCount or 0) - 1)
            E:Log(string.format("%s cast %s: |cFFFFD200%s|r.", sender, card and card.type or "Permanent", card and card.name or cardId), "ACTION")
            -- Their client runs its enter trigger too; we mirror it so both boards match
            E:RunMirrored(function() E:PutCreatureOntoBattlefield(cardId, true) end)
            E:RefreshUI()

        elseif actionType == "CAST_SPELL" then
            local cardId = parts[3]
            local card = TTS.Cards[cardId]
            E:OnRemotePlay()
            E.remoteState.handCount = math.max(0, (E.remoteState.handCount or 0) - 1)
            table.insert(E.remoteState.graveyard, cardId)
            E:Log(string.format("%s cast %s: |cFFFFD200%s|r.", sender, card and card.type or "Spell", card and card.name or cardId), "ACTION")
            E:PlaySpellCastSound()
            -- Optional target: PLAYER|CREATURE, MINE|THEIRS from the caster's side, field index
            local tgt
            local kind, side, idx = parts[4], parts[5], tonumber(parts[6])
            if kind == "PLAYER" or kind == "CREATURE" then
                local onOurSide = (side == "THEIRS")   -- the caster's "theirs" is us
                tgt = { kind = kind, isRemote = not onOurSide }
                if kind == "CREATURE" then
                    local field = onOurSide and E.localState.field or E.remoteState.field
                    tgt.perm = idx and field[idx]
                    if not tgt.perm then tgt = nil end
                end
            end
            if E.ShowRemoteSpell then E:ShowRemoteSpell(cardId, tgt) end
            -- Resolve it here as well: their client only tells us about damage to us, so
            -- everything else it does to the board (freeze, tuck, destroy...) is mirrored
            if card and card.effect then
                E:RunMirrored(function() E:ResolveSpell(card, tgt, true) end)
            end
            E:RefreshUI()

        elseif actionType == "ABILITY" then
            -- ABILITY:<their field index>[:PLAYER|CREATURE:MINE|THEIRS from their side:<field index>]
            local perm = E.remoteState.field[tonumber(parts[3]) or 0]
            if perm then
                local tgt
                local kind, side, idx = parts[4], parts[5], tonumber(parts[6])
                if kind == "PLAYER" or kind == "CREATURE" then
                    local onOurSide = (side == "THEIRS")
                    tgt = { kind = kind, isRemote = not onOurSide }
                    if kind == "CREATURE" then
                        tgt.perm = idx and (onOurSide and E.localState.field or E.remoteState.field)[idx]
                    end
                end
                E.remoteUndo = nil   -- an ability locks in their plays so far
                E:RunMirrored(function() E:ActivateAbility(perm, true, tgt) end)
                E:RefreshUI()
            end

        elseif actionType == "HEAL" then
            -- HEAL:<amount>:<MINE|THEIRS from their side>:<source> - a healing-over-time tick
            local amtStr, side, src = msg:match("^ACTION:HEAL:(%d+):(%u+):?(.*)$")
            local amt = tonumber(amtStr)
            if amt then
                local st = (side == "THEIRS") and E.localState or E.remoteState
                st.life = st.life + amt
                E:Log(string.format("%s restored %d life to %s.", (src and src ~= "") and src or "Healing", amt,
                    E:SideName(st == E.remoteState)), "ACTION")
                E:RefreshUI()
            end

        elseif actionType == "ATTACH" then
            local cardId = parts[3]
            local targetSide = parts[4]
            local fieldIdx = tonumber(parts[5])
            local targetField = (targetSide == "LOCAL") and E.remoteState.field or E.localState.field

            if fieldIdx and targetField and targetField[fieldIdx] then
                local perm = targetField[fieldIdx]
                local card = TTS.Cards[cardId]
                local isEquip = card and (card.type == "Equipment" or card.isEquipment or card.subType == "Equipment")
                perm.attachments = perm.attachments or {}
                table.insert(perm.attachments, {
                    id = cardId,
                    isEquipment = isEquip,
                    controllerIsRemote = true
                })
                E.remoteState.handCount = math.max(0, (E.remoteState.handCount or 0) - 1)
                E:Log(string.format("%s attached |cFFFFD200%s|r to %s.", sender, card and card.name or cardId, TTS.Cards[perm.id] and TTS.Cards[perm.id].name or "card"), "ACTION")
                E:PlayNonCreatureCardSound()
                E:RefreshUI()
            end

        elseif actionType == "BOUNCE_PERM" then
            local fieldIdx = tonumber(parts[3])
            local cardId = parts[4]
            if fieldIdx and E.localState.field[fieldIdx] then
                local perm = table.remove(E.localState.field, fieldIdx)
                E:DetachAttachments(perm, false)
                table.insert(E.localState.hand, perm.id or cardId)
                E:Log("Creature was returned to your hand.", "ACTION")
                E:RefreshUI()
            end

        elseif actionType == "TAP_PERM" then
            local idx = tonumber(parts[3])
            if idx and E.remoteState.field[idx] then
                E.remoteState.field[idx].tapped = true
                local card = TTS.Cards[E.remoteState.field[idx].id]
                E:Log(string.format("%s tapped |cFFFFD200%s|r.", sender, card and card.name or "Permanent"), "MANA")
                if TTS.Sound then TTS.Sound:PlayUI("tap") end
                E:RefreshUI()
            end

        elseif actionType == "DAMAGE" then
            -- Reason can itself contain ":" (e.g. "Shadow Word: Pain"), so take everything after the amount
            local amtStr, reason = msg:match("^ACTION:DAMAGE:(%d+):?(.*)$")
            local amt = tonumber(amtStr) or 0
            if not reason or reason == "" then reason = "Damage" end
            -- DamagePlayer applies our own damage shield, logs, and handles defeat
            E:DamagePlayer(false, amt, string.format("%s from %s", reason, sender))

        elseif actionType == "EFFECTS" then
            -- Snapshot of the over-time effects / shields the opponent is tracking (display only)
            E:ReceiveEffects(parts[3], parts[4])

        elseif actionType == "ATTACK" then
            local idx = tonumber(parts[3])
            if idx and E.remoteState.field[idx] then
                local perm = E.remoteState.field[idx]
                local card = TTS.Cards[perm.id]
                if not E:HasKeyword(perm, true, "vigilance") then
                    perm.tapped = true
                end
                perm.isAttacking = true

                E.blockingState = E.blockingState or {
                    attackers = {},
                    blocks = {},
                    isRemoteAttacking = true,
                    selectedBlocker = nil
                }
                table.insert(E.blockingState.attackers, idx)
                E:SetPhase("COMBAT_BLOCK")
                E:Log(string.format("%s declared attacker: |cFFFF2222%s|r.", sender, card and card.name or "Creature"), "COMBAT")
                if TTS.Sound then TTS.Sound:QueueCreature("aggro", perm.id) end
                E:RunMirrored(function() E:OnCreatureAttack(perm, true) end)
                E:RefreshUI()
            end

        elseif actionType == "ASSIGN_BLOCK" then
            local blockerIdx = tonumber(parts[3])
            local attackerIdx = tonumber(parts[4])
            -- One blocker per attacker: a second block on the same attacker is ignored
            local alreadyBlocked = false
            for _, a in pairs(E.blockingState and E.blockingState.blocks or {}) do
                if a == attackerIdx then alreadyBlocked = true end
            end
            if E.blockingState and blockerIdx and attackerIdx and not alreadyBlocked then
                E.blockingState.blocks[blockerIdx] = attackerIdx
                local blockerCard = E.remoteState.field[blockerIdx] and TTS.Cards[E.remoteState.field[blockerIdx].id]
                local attackerCard = E.localState.field[attackerIdx] and TTS.Cards[E.localState.field[attackerIdx].id]
                E:Log(string.format("%s assigned %s to block %s.", sender, blockerCard and blockerCard.name or "Creature", attackerCard and attackerCard.name or "Creature"), "COMBAT")
                E:RefreshUI()
            end

        elseif actionType == "ATTACKS_DONE" then
            -- The attacker has declared every attacker: blocks can be declared now
            if E.blockingState and E.blockingState.isRemoteAttacking then
                E.blockingState.attacksDone = true
                E:Log(string.format("%s finished declaring attackers. Assign blockers, then continue.", sender), "COMBAT")
                E:RefreshUI()
            end

        elseif actionType == "BLOCKS_DECLARED" then
            -- The defender is done: control comes back to us to review the blocks and resolve
            if E.blockingState then
                E.blockingState.blocksDeclared = true
                E:Log(string.format("%s declared blockers. Review the blocks, then click Resolve Combat.", sender), "COMBAT")
                E:RefreshUI()
            end

        elseif actionType == "RESOLVE_COMBAT" then
            if E.blockingState then
                E:ResolveCombatDamage()
            end

        elseif actionType == "UNDO_REQUEST" then
            -- UNDO_REQUEST:<plays this turn>:<cardId>
            E:OnUndoRequest(tonumber(parts[3]), parts[4])

        elseif actionType == "UNDO_ACCEPT" or actionType == "UNDO_DENY" then
            E:OnUndoAnswer(tonumber(parts[3]), actionType == "UNDO_ACCEPT")

        elseif actionType == "DECK" then
            -- DECK:<cards left in their deck>:<1 = they want ours too>
            local n = tonumber(parts[3])
            if n then E:OnRemoteDeckCount(n, parts[4] == "1") end

        elseif actionType == "END_TURN" then
            -- (their side untapped at the start of their turn, in E:EndTurn)
            E:Log(sender .. " ended their turn.", "SYSTEM")
            E:OnRemoteEndTurn()
        end
    end
end