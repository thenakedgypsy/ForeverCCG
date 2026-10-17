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
-- NPC GOSSIP
-- Talking to an NPC that hands out a gift card (card.isGift, card.giftNpcs = its
-- npcId in each faction, see Cards\Core.lua) adds a line it says under its greeting
-- in the gossip window, and an "Any spare cards?" option at the end of its list.
-- Up to 4 copies; after each one the next comes 24 to 168 hours later. The wait belongs
-- to the card, not the NPC, and the saved data is account-wide, so the Alliance and Horde
-- innkeepers of a card (or several characters) can't hand it out early. Its lines
-- (npc.<npcId>.*):
--   give     handing over a copy (shown under the NPC's own greeting); also sends
--            "/e was gifted a Forever: CCG card by <NPC>!" from the player's click
--   comeBack asked too early; followed by a hint at how long is left (npc.wait.*)
--   allOut   the player already has all 4 copies
--   giftHow  how to get the card (collection hints, for the player's faction)
-- Blizzard's list is a ScrollBox: after GossipFrame:Update fills it, we hand it
-- a copy of its data with our line and option added. If the window isn't built
-- that way, a panel under the window says it instead.
--
-- TTS_NpcGifts = { copies = { [cardId] = n }, next = { [cardId] = server time the next copy can be given } }
-- (last = { [cardId or npcId] = time of the last gift } is from older saves, read once then dropped)
-- =========================================================================

-- After each gift the next copy of that card comes 24 to 168 hours later (rolled then)
local HOUR = 60 * 60
local MIN_WAIT_HOURS, MAX_WAIT_HOURS = 24, 168
local MAX_GIFT_COPIES = 4
local CARD_BACK_ICON = "Interface\\AddOns\\ForeverCCG\\Textures\\Cards\\card_back.png"

-- How long is left, as the hint the NPC gives (npc.wait.<key>)
local WAIT_HINTS = {
    { hours = 24, key = "tomorrow" },
    { hours = 72, key = "days" },
    { hours = 120, key = "fewDays" },
    { hours = math.huge, key = "week" },
}

-- What the NPC we are talking to last said back (npc.<npcId>.<reply>); nil = its greeting.
-- waitHint: for "comeBack", the npc.wait.<key> hint at how long is left
local reply, replyNpc, waitHint

local function IsSecret(v) return issecretvalue and issecretvalue(v) or false end

-- The npcId of the creature we are talking to, or nil (secret inside instances)
local function GossipNpcId()
    local guid = UnitGUID("npc")
    if not guid or IsSecret(guid) or type(guid) ~= "string" then return nil end
    local id = guid:match("^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
    return id and tonumber(id)
end

-- Server time, so changing the computer's clock doesn't bring the next gift forward
local function Now() return (GetServerTime and GetServerTime()) or time() end

local function Gifts()
    TTS_NpcGifts = TTS_NpcGifts or {}
    TTS_NpcGifts.copies = TTS_NpcGifts.copies or {}
    TTS_NpcGifts.last = TTS_NpcGifts.last or {}
    TTS_NpcGifts.next = TTS_NpcGifts.next or {}
    return TTS_NpcGifts
end

-- The gift card an NPC hands out, or nil
local function GiftCardOf(npcId)
    if not npcId then return nil end
    for _, card in pairs(TTS.Cards or {}) do
        if card.isGift and card.giftNpcs then
            for _, id in pairs(card.giftNpcs) do
                if id == npcId then return card end
            end
        end
    end
end

-- The NPC that hands out a gift card to the player's faction (for "where to get it")
function TTS:GiftNpcFor(card)
    local npcs = card and card.giftNpcs
    if not npcs then return nil end
    local faction = UnitFactionGroup and UnitFactionGroup("player")
    return npcs[faction] or npcs.Alliance or npcs.Horde
end

-- When the next copy of a card can be handed out (server time), or nil if it can now.
-- Older saves only kept when it was last given (per card, or per NPC before that): 24 hours on.
local function NextGift(g, card)
    local nextAt = tonumber(g.next[card.id])
    if nextAt then return nextAt end
    local last = tonumber(g.last[card.id])
    for _, id in pairs(card.giftNpcs or {}) do
        local old = tonumber(g.last[id])
        if old and (not last or old > last) then last = old end
    end
    return last and last + MIN_WAIT_HOURS * HOUR
end

-- Gives the player a copy of the NPC's card once its wait is over.
-- Returns which line the NPC answers with: "give", "comeBack" or "allOut", and for
-- "comeBack" the npc.wait.<key> hint at how long is left.
function TTS:AskNpcForCard(npcId)
    local card = GiftCardOf(npcId)
    if not card then return "allOut" end
    local copies = TTS:GetOwnedCopies(card) or 0
    if copies >= MAX_GIFT_COPIES then return "allOut" end

    local g = Gifts()
    local nextAt = NextGift(g, card)
    if nextAt and Now() < nextAt then
        local hoursLeft = (nextAt - Now()) / HOUR
        for _, h in ipairs(WAIT_HINTS) do
            if hoursLeft <= h.hours then return "comeBack", h.key end
        end
    end

    copies = copies + 1
    g.copies[card.id] = copies
    g.next[card.id] = Now() + math.random(MIN_WAIT_HOURS, MAX_WAIT_HOURS) * HOUR
    g.last[card.id] = nil
    for _, id in pairs(card.giftNpcs or {}) do g.last[id] = nil end   -- older saves' entries
    TTS:MarkCardNew(card.id)
    local link = TTS.CardLink and TTS:CardLink(card.id) or ("|cFFFFD200" .. TTS:CardName(card) .. "|r")
    DEFAULT_CHAT_FRAME:AddMessage(L("npc.gotCard", link, copies))
    -- "/e was gifted a Forever: CCG card by Innkeeper Brianna!" (sent from the gossip click)
    local npcName = UnitName("npc")
    if npcName and not IsSecret(npcName) and npcName ~= "" then
        pcall(SendChatMessage, L("emote.gifted", npcName), "EMOTE")
    end
    if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() and TTS.DeckBuilderFrame.RefreshAll then
        TTS.DeckBuilderFrame:RefreshAll()
    end
    return "give"
end

-- Once the NPC has answered (a card, or no), the option goes until the next visit
local function CanAsk(npcId)
    return not (replyNpc == npcId and reply)
end

-- The NPC's answer to "Any spare cards?", or nil before the player has asked
-- (until then the window shows only the NPC's own greeting)
local function Said(npcId)
    if not (replyNpc == npcId and reply) then return nil end
    local said = L("npc." .. npcId .. "." .. reply)
    if reply == "comeBack" and waitHint then said = said .. " " .. L("npc.wait." .. waitHint) end
    return said
end

-- =========================================================================
-- FALLBACK PANEL
-- Under the gossip window when we can't add to its list, or on its own when another
-- addon (Immersion, DialogueUI...) shows gossip in its own window instead.
-- =========================================================================
local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local G = CreateFrame("Frame", "TTS_NpcGossipPanel", UIParent, backdropTemplate)
TTS.NpcGossipPanel = G
G:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
G:EnableMouse(true)
G:Hide()

local icon = G:CreateTexture(nil, "ARTWORK")
icon:SetSize(32, 32)
icon:SetPoint("TOPLEFT", 18, -18)
icon:SetTexture(CARD_BACK_ICON)

local text = G:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
text:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, 0)
text:SetPoint("RIGHT", G, "RIGHT", -20, 0)
text:SetJustifyH("LEFT")
text:SetJustifyV("TOP")

local ask = CreateFrame("Button", nil, G, "UIPanelButtonTemplate")
ask:SetSize(150, 24)
Loc:Bind(ask, "npc.ask")

local function ShowPanel(npcId)
    local onBlizzard = GossipFrame and GossipFrame:IsShown()
    G:ClearAllPoints()
    if onBlizzard then
        G:SetPoint("TOPLEFT", GossipFrame, "BOTTOMLEFT", 0, 2)
        G:SetPoint("TOPRIGHT", GossipFrame, "BOTTOMRIGHT", 0, 2)
        G:SetFrameStrata(GossipFrame:GetFrameStrata())
    else
        G:SetPoint("TOP", UIParent, "TOP", 0, -140)
        G:SetWidth(340)
        G:SetFrameStrata("DIALOG")
    end
    local said = Said(npcId)
    text:SetText(said or "")
    ask:ClearAllPoints()
    if said then
        ask:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -10)
    else
        ask:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    end
    ask:SetShown(CanAsk(npcId))
    local body = (said and text:GetStringHeight() or 0) + (ask:IsShown() and (said and 10 or 0) + ask:GetHeight() or 0)
    G:SetHeight(math.max(icon:GetHeight(), body) + 36)
    G:Show()
end

-- =========================================================================
-- IN THE GOSSIP WINDOW
-- =========================================================================
local function GreetingBox()
    local panel = GossipFrame and GossipFrame.GreetingPanel
    local box = panel and panel.ScrollBox
    if box and box.GetDataProvider and box.SetDataProvider and box.ForEachFrame then return box end
end

-- Asks for a card, then shows the NPC's answer where its line was
local function Ask()
    local npcId = GossipNpcId()
    if not GiftCardOf(npcId) then return end
    reply, waitHint = TTS:AskNpcForCard(npcId)
    replyNpc = npcId
    if GossipFrame:IsShown() and type(GossipFrame.Update) == "function" and GreetingBox() then
        GossipFrame:Update()
    else
        ShowPanel(npcId)
    end
end
ask:SetScript("OnClick", Ask)

-- Our option is drawn by Blizzard's option button, but its click asks for a card
-- instead of choosing a gossip option. Buttons are reused, so others get theirs back.
local function FixClicks(box)
    box:ForEachFrame(function(frame, data)
        if data and data.foreverCCG then
            if not frame.foreverOrigClick then
                frame.foreverOrigClick = frame:GetScript("OnClick") or false
                frame:SetScript("OnClick", Ask)
            end
        elseif frame.foreverOrigClick ~= nil then
            frame:SetScript("OnClick", frame.foreverOrigClick or nil)
            frame.foreverOrigClick = nil
        end
    end)
end

-- Returns true once the answer (if any) and option are in the window
local function AddToGossip(npcId)
    local box = GreetingBox()
    local old = box and box:GetDataProvider()
    if not (old and old.ForEach and CreateDataProvider and GOSSIP_BUTTON_TYPE_TITLE and GOSSIP_BUTTON_TYPE_OPTION) then
        return false
    end

    -- A copy in the same order (no sorting), so our option can go last. Once the player
    -- has asked, the NPC's answer goes under its greeting.
    local said = Said(npcId)
    local new, greeted = CreateDataProvider(), false
    old:ForEach(function(e)
        if said and not greeted and e.buttonType == GOSSIP_BUTTON_TYPE_TITLE then
            greeted = true
            local copy = {}
            for k, v in pairs(e) do copy[k] = v end
            copy.text = (e.text and e.text ~= "") and (e.text .. "\n\n" .. said) or said
            new:Insert(copy)
        else
            new:Insert(e)
        end
    end)
    if said and not greeted then return false end

    if CanAsk(npcId) then
        new:Insert({
            buttonType = GOSSIP_BUTTON_TYPE_OPTION,
            foreverCCG = true,
            orderIndex = 9999,
            info = { name = L("npc.ask"), icon = CARD_BACK_ICON, orderIndex = 9999, gossipOptionID = 0, flags = 0 },
        })
    end
    box:SetDataProvider(new, ScrollBoxConstants and ScrollBoxConstants.RetainScrollPosition)
    FixClicks(box)
    return true
end

local function OnGossipUpdate()
    local npcId = GossipNpcId()
    if not GiftCardOf(npcId) then
        local box = GreetingBox()
        if box then FixClicks(box) end   -- give reused buttons their clicks back
        G:Hide()
        return
    end
    local ok, added = pcall(AddToGossip, npcId)
    if ok and added then
        G:Hide()
    else
        ShowPanel(npcId)
    end
end

if GossipFrame then
    -- Next time the NPC greets the player again
    GossipFrame:HookScript("OnHide", function() G:Hide(); reply = nil end)
    local followsUpdate = type(GossipFrame.Update) == "function"
    if followsUpdate then hooksecurefunc(GossipFrame, "Update", OnGossipUpdate) end

    G:RegisterEvent("GOSSIP_SHOW")
    G:RegisterEvent("GOSSIP_CLOSED")
    G:SetScript("OnEvent", function(_, event)
        if event == "GOSSIP_CLOSED" then
            G:Hide()
            reply = nil
            return
        end
        -- Once Blizzard (or another addon) has drawn the gossip: no Update method to
        -- follow, or Blizzard's window was kept hidden because another addon shows gossip
        -- its own way, so our option goes in the panel instead
        C_Timer.After(0, function()
            if not followsUpdate then
                OnGossipUpdate()
            elseif not GossipFrame:IsShown() then
                local npcId = GossipNpcId()
                if GiftCardOf(npcId) then ShowPanel(npcId) end
            end
        end)
    end)
end
