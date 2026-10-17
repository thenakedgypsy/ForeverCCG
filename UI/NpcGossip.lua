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

-- What an NPC hands out, or nil: { key, cards }. Either its own card (card.giftNpcs; the
-- wait is the card's, key = card id) or a random card of a pool it belongs to
-- (TTS.GIFT_POOLS, cards with giftPool = <pool>; one wait for the whole pool,
-- key = "pool:<pool>"). Cards are in id order.
local function GiftSource(npcId)
    if not npcId then return nil end
    for pool, def in pairs(TTS.GIFT_POOLS or {}) do
        for _, id in pairs(def.npcs) do
            if id == npcId then
                local cards = {}
                for _, card in pairs(TTS.Cards or {}) do
                    if card.isGift and card.giftPool == pool then table.insert(cards, card) end
                end
                table.sort(cards, function(a, b) return a.id < b.id end)
                return { key = "pool:" .. pool, cards = cards }
            end
        end
    end
    for _, card in pairs(TTS.Cards or {}) do
        if card.isGift and card.giftNpcs then
            for _, id in pairs(card.giftNpcs) do
                if id == npcId then return { key = card.id, cards = { card } } end
            end
        end
    end
end
local function GiftCardOf(npcId) return GiftSource(npcId) ~= nil end

-- The NPC that hands out a gift card to the player's faction, or nil for a pool card
function TTS:GiftNpcFor(card)
    local npcs = card and card.giftNpcs
    if not npcs then return nil end
    local faction = UnitFactionGroup and UnitFactionGroup("player")
    return npcs[faction] or npcs.Alliance or npcs.Horde
end

-- How to get a gift card (collection hints): "Ask Innkeeper ... for spare cards"
function TTS:GiftHow(card)
    if card and card.giftPool then return L("gift." .. card.giftPool .. ".how") end
    return L("npc." .. tostring(TTS:GiftNpcFor(card)) .. ".giftHow")
end

-- When the next gift from a source can be handed out (server time), or nil if it can now.
-- Older saves only kept when a card was last given (per card, or per NPC before that): 24 hours on.
local function NextGift(g, source)
    local nextAt = tonumber(g.next[source.key])
    if nextAt then return nextAt end
    local card = source.cards[1]
    if #source.cards ~= 1 or not card then return nil end
    local last = tonumber(g.last[card.id])
    for _, id in pairs(card.giftNpcs or {}) do
        local old = tonumber(g.last[id])
        if old and (not last or old > last) then last = old end
    end
    return last and last + MIN_WAIT_HOURS * HOUR
end

-- Gives the player a copy of the NPC's card (a random one not yet complete, for a pool)
-- once its wait is over. Returns which line the NPC answers with: "give", "comeBack" or
-- "allOut", and for "comeBack" the npc.wait.<key> hint at how long is left.
function TTS:AskNpcForCard(npcId)
    local source = GiftSource(npcId)
    if not source then return "allOut" end
    local open = {}
    for _, c in ipairs(source.cards) do
        if (TTS:GetOwnedCopies(c) or 0) < MAX_GIFT_COPIES then table.insert(open, c) end
    end
    if #open == 0 then return "allOut" end

    local g = Gifts()
    local nextAt = NextGift(g, source)
    if nextAt and Now() < nextAt then
        local hoursLeft = (nextAt - Now()) / HOUR
        for _, h in ipairs(WAIT_HINTS) do
            if hoursLeft <= h.hours then return "comeBack", h.key end
        end
    end

    local card = open[math.random(#open)]
    local copies = (TTS:GetOwnedCopies(card) or 0) + 1
    g.copies[card.id] = copies
    g.next[source.key] = Now() + math.random(MIN_WAIT_HOURS, MAX_WAIT_HOURS) * HOUR
    g.last[card.id] = nil
    for _, id in pairs(card.giftNpcs or {}) do g.last[id] = nil end   -- older saves' entries
    TTS:MarkCardNew(card.id)
    local link = TTS.CardLink and TTS:CardLink(card.id) or ("|cFFFFD200" .. TTS:CardName(card) .. "|r")
    DEFAULT_CHAT_FRAME:AddMessage(L("npc.gotCard", link, copies))
    -- "/e was gifted a Forever: CCG card by Innkeeper Brianna!" (sent from the gossip click)
    local npcName = UnitName("npc")
    if npcName and not IsSecret(npcName) and npcName ~= "" then
        pcall(SendChatMessage, L("emote.gifted", npcName), "EMOTE")
        -- then a thank-you /bow, a moment later so it doesn't collide with the text above
        TTS:SafeAfter(0.5, function() DoEmote("BOW") end)
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
-- Whether the player still has copies to collect from an NPC's gifts; ready = and its
-- wait is over, so it would give one right now
local function HasMoreToGive(npcId, ready)
    local source = GiftSource(npcId)
    local open = false
    for _, c in ipairs(source and source.cards or {}) do
        if (TTS:GetOwnedCopies(c) or 0) < MAX_GIFT_COPIES then open = true; break end
    end
    if not open or not ready then return open end
    local nextAt = NextGift(Gifts(), source)
    return not nextAt or Now() >= nextAt
end

-- Where an all-out town innkeeper sends the player next (TTS.GIFT_TRAIL): the next inn
-- on its faction's trail that still has cards for them (going round to the start for
-- any skipped), else the capitals. A capital innkeeper sends them to the first inn on
-- their own faction's trail that still has cards. Only places with a card ready right now
-- are named (so the player isn't sent round in circles): with cards left but none ready
-- anywhere the NPC says so (npc.trail.none), and with nothing left at all, that the player
-- has them all (npc.trail.done, only once the NPC itself is all out).
local function TrailHint(npcId)
    local capital = TTS.GIFT_POOLS and TTS.GIFT_POOLS.capital
    -- Where this NPC could send the player, in order: npc ids, "capital" for the rumour
    local places
    for _, id in ipairs(capital and capital.npcs or {}) do
        if id == npcId then
            local faction = UnitFactionGroup and UnitFactionGroup("player")
            places = { unpack(TTS.GIFT_TRAIL and TTS.GIFT_TRAIL[faction] or {}) }
        end
    end
    if not places then
        for _, trail in pairs(TTS.GIFT_TRAIL or {}) do
            for i, id in ipairs(trail) do
                if id == npcId then
                    places = {}
                    for step = 1, #trail - 1 do table.insert(places, trail[(i - 1 + step) % #trail + 1]) end
                    if capital then table.insert(places, "capital") end
                end
            end
        end
    end

    local anyLeft = HasMoreToGive(npcId)
    for _, p in ipairs(places or {}) do
        local id = (p == "capital") and capital.npcs[1] or p
        if HasMoreToGive(id, true) then
            if p == "capital" then return L("npc.trail.capital") end
            return L("npc.trail", L("place." .. p))
        end
        anyLeft = anyLeft or HasMoreToGive(id)
    end
    if not places then return nil end
    return L(anyLeft and "npc.trail.none" or "npc.trail.done")
end

-- The NPC's answer, then (when it has nothing for the player) where else to try
local function Said(npcId)
    if not (replyNpc == npcId and reply) then return nil end
    local said = L("npc." .. npcId .. "." .. reply)
    if reply == "comeBack" and waitHint then said = said .. " " .. L("npc.wait." .. waitHint) end
    if reply == "comeBack" or reply == "allOut" then
        local hint = TrailHint(npcId)
        if hint then said = said .. " " .. hint end
    end
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
