--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

-- =========================================================================
-- CARD LINKS IN CHAT
-- Shift-click a card while typing in chat to insert "[Forever CCG: <card name>]".
-- The server won't pass custom hyperlinks, so it travels as plain text: players
-- without the addon see exactly that. With the addon, a chat filter turns it into
-- a gold [Card Name] link (|Hgarrmission:ForeverCCG:card:<id>|h) that shows the card tooltip on hover and opens a card
-- preview window on click. Card names are unique, so the name alone identifies it.
-- =========================================================================
local TAG_PATTERN = "%[Forever CCG: ([^%]]+)%]"
-- Borrowed "garrmission" link type (as WeakAuras does): Blizzard's handler finds no valid
-- mission id in it and quietly does nothing, so we only need to react after it
local LINK_PREFIX = "garrmission:ForeverCCG:card:"
local LINK_COLOR = "|cFFFFD200"

local cardIdByName -- [lower name] = card id, built on first use (all card files are loaded by then)

local function FindCardByName(name)
    if not cardIdByName then
        cardIdByName = {}
        for id, card in pairs(TTS.Cards or {}) do
            if card.name then cardIdByName[card.name:lower()] = id end
        end
    end
    return cardIdByName[name:lower()]
end

local function CardTag(card)
    return "[Forever CCG: " .. card.name .. "]"
end

-- Shift-clicking a card while a chat box is open inserts its tag. Returns true when it did,
-- so click handlers can stop there instead of also playing / adding the card.
function TTS:TryLinkCard(cardId)
    if not (cardId and IsShiftKeyDown and IsShiftKeyDown()) then return false end
    local card = TTS.Cards and TTS.Cards[cardId]
    if not (card and card.name) then return false end
    local editBox = ChatEdit_GetActiveWindow and ChatEdit_GetActiveWindow()
    if not editBox then return false end
    editBox:Insert(CardTag(card))
    return true
end

-- =========================================================================
-- INCOMING CHAT: tag -> clickable link
-- =========================================================================
local function ReplaceTag(name)
    local id = FindCardByName(name)
    if not id then return nil end -- not a card we know: leave the text as it is
    return LINK_COLOR .. "|H" .. LINK_PREFIX .. id .. "|h[" .. TTS.Cards[id].name .. "]|h|r"
end

local function ChatFilter(self, event, msg, ...)
    if type(msg) ~= "string" or not msg:find("[Forever CCG: ", 1, true) then return false end
    return false, msg:gsub(TAG_PATTERN, ReplaceTag), ...
end

local CHAT_EVENTS = {
    "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_EMOTE",
    "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_WHISPER_INFORM",
    "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_CHANNEL", "CHAT_MSG_COMMUNITIES_CHANNEL",
}
if ChatFrame_AddMessageEventFilter then
    for _, event in ipairs(CHAT_EVENTS) do
        ChatFrame_AddMessageEventFilter(event, ChatFilter)
    end
end

local function LinkCardId(link)
    if type(link) ~= "string" then return nil end
    local id = link:match("^" .. LINK_PREFIX:gsub("%p", "%%%0") .. "([%w_]+)")
    return id and TTS.Cards and TTS.Cards[id] and id or nil
end

-- =========================================================================
-- PREVIEW WINDOW (opened by clicking a link)
-- =========================================================================
local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local CARD_TOP = -78 -- the card's name and cost are drawn above its frame

local P = CreateFrame("Frame", "TTS_CardLinkPreview", UIParent, backdropTemplate)
P:SetSize(190, 360)
P:SetPoint("CENTER", 0, 60)
P:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
P:SetFrameStrata("DIALOG")
P:SetClampedToScreen(true)
P:EnableMouse(true)
P:SetMovable(true)
P:RegisterForDrag("LeftButton")
P:SetScript("OnDragStart", P.StartMoving)
P:SetScript("OnDragStop", P.StopMovingOrSizing)
P:Hide()
tinsert(UISpecialFrames, "TTS_CardLinkPreview") -- Escape closes it
TTS.CardLinkPreview = P

local title = P:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Forever CCG")

local closeBtn = CreateFrame("Button", nil, P, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -4, -4)

local statusText = P:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
statusText:SetPoint("BOTTOMLEFT", 18, 18)
statusText:SetPoint("BOTTOMRIGHT", -18, 18)
statusText:SetJustifyH("CENTER")
statusText:SetWordWrap(true)

local previewCard

-- How the player stands with this card: owned copies, or how to get it
local function CollectionStatus(card)
    if card.type == "Land" then
        return "|cFF00FF00Always available|r"
    end
    if card.isBoss or card.isReward then
        local copies = TTS:GetOwnedCopies(card) or 0
        if copies >= 4 then
            return "|cFF00FF00You own 4/4 copies (Mastered)|r"
        elseif copies > 0 then
            return string.format("|cFFFFFFFFYou own %d/4 copies|r", copies)
        end
        local how
        if card.isReward then
            local enc = TTS.GetRewardEncounter and TTS:GetRewardEncounter(card.id)
            how = "Win " .. (enc and enc.name or "its encounter") .. " in Solo mode"
        elseif card.zone then
            how = "Defeat " .. card.name .. " (" .. card.zone .. ")"
        else
            how = "Defeat " .. card.name
        end
        return "|cFFFF4444Not collected yet|r\n|cFFBBBBBB" .. how .. "|r"
    end
    if TTS.IsSpellUnlocked and not TTS:IsSpellUnlocked(card.id) then
        return string.format("|cFFFF4444Unlocks at level %d|r", TTS:GetSpellUnlockLevel(card.id))
    end
    return "|cFF00FF00Unlocked|r"
end

function TTS:ShowCardPreview(cardId)
    local card = TTS.Cards and TTS.Cards[cardId]
    if not (card and TTS.CreateCardFrame and TTS.PaintPreviewCard) then return end
    if not previewCard then
        previewCard = TTS.CreateCardFrame(P, TTS.PREVIEW_W, TTS.PREVIEW_H)
        previewCard:SetPoint("TOP", P, "TOP", 0, CARD_TOP)
        previewCard:EnableMouse(true)
        previewCard:SetScript("OnClick", function(self) TTS:TryLinkCard(self.cardId) end)
        previewCard:SetScript("OnEnter", function(self)
            if TTS.Tooltip then TTS.Tooltip:ShowCard(self, "ANCHOR_RIGHT", self.cardId) end
        end)
        previewCard:SetScript("OnLeave", function(self)
            if TTS.Tooltip then TTS.Tooltip:Hide(self) end
        end)
    end
    previewCard.cardId = cardId
    P:Show()
    TTS.PaintPreviewCard(previewCard, card)
    statusText:SetText(CollectionStatus(card))
end

-- =========================================================================
-- CLICK & HOVER
-- A secure post-hook on SetItemRef: Blizzard's handler runs untouched (no taint for
-- any other link), then we act on our own links.
-- =========================================================================
local function OnLinkClicked(link)
    local id = LinkCardId(link)
    if not id then return end
    -- Shift-click a link while typing: pass the card on, like an item link
    if TTS:TryLinkCard(id) then return end
    if P:IsShown() and previewCard and previewCard.cardId == id then
        P:Hide()
    else
        TTS:ShowCardPreview(id)
    end
end

if hooksecurefunc and SetItemRef then
    hooksecurefunc("SetItemRef", OnLinkClicked)
end

local function OnHyperlinkEnter(frame, link)
    local id = LinkCardId(link)
    if id and TTS.Tooltip then TTS.Tooltip:ShowCard(frame, "ANCHOR_CURSOR", id) end
end

local function OnHyperlinkLeave(frame)
    if TTS.Tooltip then TTS.Tooltip:Hide(frame) end
end

local hooker = CreateFrame("Frame")
hooker:RegisterEvent("PLAYER_LOGIN")
hooker:SetScript("OnEvent", function()
    for i = 1, (NUM_CHAT_WINDOWS or 10) do
        local cf = _G["ChatFrame" .. i]
        if cf and cf.HookScript then
            cf:HookScript("OnHyperlinkEnter", OnHyperlinkEnter)
            cf:HookScript("OnHyperlinkLeave", OnHyperlinkLeave)
        end
    end
end)
