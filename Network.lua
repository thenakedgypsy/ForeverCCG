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

-- Custom chat channel used for waiting-room broadcasts
local LFM_CHANNEL = "FCCGTTSE"

-- Seconds an outgoing challenge stays valid (the receiving popup times out after 30)
local INVITE_EXPIRY = 45

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

TTS.Net.pendingInvites = {}   -- [lowerName] = name : waiting for INVITE_ACK (addon-installed check)
TTS.Net.outgoingInvites = {}  -- [lowerName] = time() : challenges we sent that may still be accepted
TTS.Net.incomingChallenge = nil -- name of the player whose challenge popup is currently open

function TTS.Net:BroadcastLFM(msg)
    local function SendToChannel(channelId)
        if C_ChatInfo and C_ChatInfo.SendAddonMessage then
            C_ChatInfo.SendAddonMessage(PREFIX, msg, "CHANNEL", channelId)
        else
            SendAddonMessage(PREFIX, msg, "CHANNEL", channelId)
        end
    end

    local id = GetLFMChannelId()
    if id then
        SendToChannel(id)
        return
    end

    -- Not in the channel yet: join it, then send once it is available
    JoinLFMChannel()
    TTS:SafeAfter(1, function()
        local retryId = GetLFMChannelId()
        if retryId then
            SendToChannel(retryId)
        end
    end)
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
    self.outgoingInvites[inviteKey] = time()
    self.pendingInvites[inviteKey] = target

    self:Send(target, "INVITE:" .. TTS.VERSION)
    Print("|cFF00FF00[TTSE]|r Invitation sent to " .. target .. ". Checking for addon...")

    TTS:SafeAfter(2.5, function()
        if TTS.Net.pendingInvites[inviteKey] then
            local originalTarget = TTS.Net.pendingInvites[inviteKey]
            TTS.Net.pendingInvites[inviteKey] = nil
            TTS.Net.outgoingInvites[inviteKey] = nil
            local whisperMsg = string.format("I tried to invite you to a game of Forever: CCG, but you dont have it installed! Visit: %s to download!", TTS.DOWNLOAD_URL)
            SendChatMessage(whisperMsg, "WHISPER", nil, originalTarget)
            Print(string.format("|cFFFF4444[TTSE]|r %s does not have the addon installed. Whisper sent!", originalTarget))
        end
    end)
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
            TTS.Net:OnReceive(message, cleanSender)
        end
    end
end)

function TTS.Net:Send(target, msg)
    if not target or target == "" or target == "Target Dummy" or (TTS.Engine and TTS.Engine.isSolo) then
        return
    end
    target = NormalizeName(target)
    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        C_ChatInfo.SendAddonMessage(PREFIX, msg, "WHISPER", target)
    else
        SendAddonMessage(PREFIX, msg, "WHISPER", target)
    end
end

-- Older builds sent "INVITE" / "ACCEPT" with no version at all
local function VersionText(v)
    return (v and v ~= "") and v or "an older version"
end

local function ReportVersionMismatch(otherName, otherVersion)
    Print(string.format("|cFFFF2222[TTSE]|r Version mismatch: %s is on %s, you are on %s. Both players must use the same version of Forever: CCG.",
        otherName, VersionText(otherVersion), TTS.VERSION))
end

local function IsMatchOpponent(sender)
    local E = TTS.Engine
    return E and E.inMatch and not E.isSolo and SameName(E.opponent, sender)
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
        if theirVersion ~= TTS.VERSION then
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
                    TTS.Net:Send(sender, "ACCEPT:" .. TTS.VERSION)
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
            timeout = 30,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("TTS_CHALLENGE")

    elseif cmd == "INVITE_ACK" then
        TTS.Net.pendingInvites[sender:lower()] = nil
        Print("|cFF00FF00[TTSE]|r " .. sender .. " has Forever: CCG installed. Awaiting their response...")

    elseif cmd == "ACCEPT" then
        local key = sender:lower()
        local sentAt = TTS.Net.outgoingInvites[key]
        TTS.Net.pendingInvites[key] = nil
        TTS.Net.outgoingInvites[key] = nil

        -- Ignore accepts for challenges we never sent (or that have expired)
        if not sentAt or (time() - sentAt) > INVITE_EXPIRY then
            TTS.Net:Send(sender, "CANCEL:NOT_INVITED")
            return
        end

        local theirVersion = parts[2]
        if theirVersion ~= TTS.VERSION then
            TTS.Net:Send(sender, "CANCEL:VERSION:" .. TTS.VERSION)
            ReportVersionMismatch(sender, theirVersion)
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
            E:RefreshUI()

        elseif actionType == "PLAY_PERM" then
            local cardId = parts[3]
            local card = TTS.Cards[cardId]
            E.remoteState.handCount = math.max(0, (E.remoteState.handCount or 0) - 1)
            local entersTapped = (cardId == "B10" or cardId == "G09")
            table.insert(E.remoteState.field, {
                id = cardId,
                tapped = entersTapped,
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
                if cardId == "G03" then
                    perm.wildOvergrowth = true
                end
                E.remoteState.handCount = math.max(0, (E.remoteState.handCount or 0) - 1)
                E:Log(string.format("%s attached |cFFFFD200%s|r to %s.", sender, card and card.name or cardId, TTS.Cards[perm.id] and TTS.Cards[perm.id].name or "card"), "ACTION")
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
            if E.blockingState and blockerIdx and attackerIdx then
                E.blockingState.blocks[blockerIdx] = attackerIdx
                local blockerCard = E.remoteState.field[blockerIdx] and TTS.Cards[E.remoteState.field[blockerIdx].id]
                local attackerCard = E.localState.field[attackerIdx] and TTS.Cards[E.localState.field[attackerIdx].id]
                E:Log(string.format("%s assigned %s to block %s.", sender, blockerCard and blockerCard.name or "Creature", attackerCard and attackerCard.name or "Creature"), "COMBAT")
                E:RefreshUI()
            end

        elseif actionType == "RESOLVE_COMBAT" then
            if E.blockingState then
                E:ResolveCombatDamage()
            end

        elseif actionType == "END_TURN" then
            for _, perm in ipairs(E.remoteState.field) do
                perm.sick = false
                perm.isAttacking = nil
                perm.hasAttackedThisTurn = nil
                local canUntap = true
                if perm.freezeUntap then
                    canUntap = false
                    perm.freezeUntap = false
                end
                if perm.attachments then
                    for _, att in ipairs(perm.attachments) do
                        local attId = type(att) == "table" and att.id or att
                        if attId == "U10" then canUntap = false end
                    end
                end
                if canUntap then perm.tapped = false end
            end

            E:Log(sender .. " ended their turn.", "SYSTEM")
            E:OnRemoteEndTurn()
        end
    end
end