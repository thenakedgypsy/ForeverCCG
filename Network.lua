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

-- Our identity on the network: the same name the waiting room advertises
local function MyName()
    if TTS.GetPlayerFullName then
        return TTS.GetPlayerFullName()
    end
    return NormalizeName(UnitName("player"))
end

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

local function RawChannelSend(channelId, msg)
    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        C_ChatInfo.SendAddonMessage(PREFIX, msg, "CHANNEL", channelId)
    else
        SendAddonMessage(PREFIX, msg, "CHANNEL", channelId)
    end
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
        RawChannelSend(id, channelQueue[i])
    end
    wipe(channelQueue)
end

local function SendChannel(msg)
    local id = GetLFMChannelId()
    if id and #channelQueue == 0 then
        RawChannelSend(id, msg)
        return
    end
    table.insert(channelQueue, msg)
    if not flushScheduled then
        flushScheduled = true
        JoinLFMChannel()
        TTS:SafeAfter(1, FlushChannelQueue)
    end
end

-- chatType is one of the fallback routes; target is only used for "WHISPER"
local function SendDirect(msg, chatType, target)
    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        C_ChatInfo.SendAddonMessage(PREFIX, msg, chatType, target)
    else
        SendAddonMessage(PREFIX, msg, chatType, target)
    end
end

local function NameMatchesUnit(name, unit)
    if not UnitExists(unit) then return false end
    local want = NormalizeName(name):lower()
    local n = NormalizeName(UnitName(unit)):lower()
    -- The waiting-room name may be "Firstname Surname" while UnitName is just "Firstname"
    return n ~= "" and (want == n or want:sub(1, #n + 1) == n .. " ")
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
    SendChannel(msg)
end

-- Challenges can only be issued from the Waiting Room, which calls this.
function TTS.Net:InvitePlayer(target)
    if not target or target == "" then return end
    target = NormalizeName(target)

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
    self.outgoingInvites[inviteKey] = { sentAt = time(), matchId = matchId, tried = { LFM_CHANNEL } }
    self.pendingInvites[inviteKey] = target
    self.routes[inviteKey] = nil -- always try FCCGTTSE first

    self:Send(target, "INVITE:" .. TTS.VERSION .. ":" .. matchId)
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

        local current = Net.routes[inviteKey]
        local nextRoute = NextRoute(current, target)

        if nextRoute then
            Net.routes[inviteKey] = nextRoute
            invite.sentAt = time()
            table.insert(invite.tried, ROUTE_LABELS[nextRoute])
            Print(string.format("|cFFFFD200[TTSE]|r No response from %s on %s. Retrying over %s...",
                target, current and ROUTE_LABELS[current] or LFM_CHANNEL, ROUTE_LABELS[nextRoute]))
            Net:Send(target, "INVITE:" .. TTS.VERSION .. ":" .. matchId)
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
        SendChatMessage(whisperMsg, "WHISPER", nil, target)
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
    if not target or target == "" or target == "Target Dummy" or (TTS.Engine and TTS.Engine.isSolo) then
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
    local route = self.routes[target:lower()]
    if route and RouteAvailable(route, target) then
        SendDirect(envelope, route, route == "WHISPER" and target or nil)
    else
        SendChannel(envelope)
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
        if TTS.WaitingRoom then
            TTS.WaitingRoom.players[pName] = time()
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
    end

    -- =====================================================================
    -- DIRECT GAME MATCH HANDLERS
    -- =====================================================================
    if cmd == "INVITE" then
        -- Always acknowledge so the challenger knows the addon is installed
        TTS.Net:Send(sender, "INVITE_ACK")

        local theirVersion = parts[2]
        local theirMatchId = parts[3]
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
                    TTS.Net:Send(sender, "ACCEPT:" .. TTS.VERSION .. ":" .. theirMatchId)
                    TTS.Net.matchId = theirMatchId
                    TTS.Engine:StartMatch(sender, false, false)
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
        if TTS.Engine then
            TTS.Engine:StartMatch(sender, true, false)
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
            E.remoteState.handCount = math.max(0, (E.remoteState.handCount or 0) - 1)
            table.insert(E.remoteState.field, {
                id = cardId,
                tapped = false,
                sick = not E:HasKeyword({ id = cardId }, true, "haste"),
                damage = 0,
                tempPower = 0,
                tempToughness = 0,
                uid = time() + #E.remoteState.field
            })
            E:Log(string.format("%s cast %s: |cFFFFD200%s|r.", sender, card and card.type or "Permanent", card and card.name or cardId), "ACTION")
            if TTS.Sound then TTS.Sound:QueueCreature("aggro", cardId) end
            E:RefreshUI()

        elseif actionType == "CAST_SPELL" then
            local cardId = parts[3]
            local card = TTS.Cards[cardId]
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
            E:RefreshUI()

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

        elseif actionType == "END_TURN" then
            E:UntapSide(true)

            E:Log(sender .. " ended their turn.", "SYSTEM")
            E:OnRemoteEndTurn()
        end
    end
end