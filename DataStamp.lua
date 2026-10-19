--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
]]
TTS = TTS or {}

-- =========================================================================
-- LAUNCH STAMP
-- Saved data from the beta doesn't carry over into launch. The launch build stamps the
-- saved data (TTS_DataStamp.launch = true); data without the stamp (the beta's, or a beta
-- file copied back in) is cleared once and stamped, so the collection starts afresh.
-- Every saved variable is in the one ForeverCCG.lua file, so copying an old file over a
-- new one brings back its missing stamp too.
--
-- This file loads before the others that use the data, so its ADDON_LOADED runs before
-- any of them reads it.
-- =========================================================================

-- Cleared when the stamp is missing
local CLEARED = {
    "TTS_KilledBosses", "TTS_SoloProgress", "TTS_NpcGifts", "TTS_HeroChoices",
    "TTS_SavedDecks", "TTS_ActiveDeckIndex", "TTS_NewCards",
}

-- Given to every player whose beta collection was cleared (Cards\Special.lua)
local BETA_CARD = "BUGREPORTER"

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
    if addon ~= "ForeverCCG" then return end
    self:UnregisterEvent("ADDON_LOADED")
    if type(TTS_DataStamp) == "table" and TTS_DataStamp.launch == true then return end

    -- A new player has nothing to lose; anyone else is told why their collection is empty
    local had = false
    for _, name in ipairs(CLEARED) do
        local v = _G[name]
        if type(v) == "table" and next(v) ~= nil then had = true end
        _G[name] = nil
    end
    -- beta = true: the player gets the beta card (isBeta, Cards\Special.lua). It's a flag rather
    -- than a copy count, so the stamp being restored again can't grant it twice.
    TTS_DataStamp = { launch = true, beta = had or nil }
    if had then
        if TTS.MarkCardNew then TTS:MarkCardNew(BETA_CARD) end
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
    end
end)

-- =========================================================================
-- BETA WELCOME
-- A static popup (the message and OK) with the beta card, painted as in a card link's
-- preview (UI\CardLinks.lua), set in below the message. The emote is sent from OK as the
-- match result popup's is (CoreEngine.lua): from the addon's own button the client blocks it.
-- =========================================================================
local CARD_HEAD = 62   -- the card's name and cost are drawn above its frame
local CARD_GAP = 10    -- between the card and the OK button
local welcomeCard

StaticPopupDialogs["TTS_BETA_WELCOME"] = {
    text = "%s",
    button1 = OKAY or "Okay",
    -- "/e received [The Bug Reporter] for testing the Forever: CCG beta!" (a card link,
    -- UI\CardLinks.lua), then a /cheer (OK only: Escape closes it without them)
    OnAccept = function()
        local card = TTS.Cards and TTS.Cards[BETA_CARD]
        if not card then return end
        local tag = TTS.CardTag and TTS:CardTag(BETA_CARD) or TTS:CardName(card)
        SendChatMessage((TTS.L or tostring)("emote.beta", tag), "EMOTE")
        TTS:SafeAfter(0.5, function() DoEmote("CHEER") end)
    end,
    OnHide = function()
        if welcomeCard then welcomeCard:Hide() end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Built on first show: the card frame code (UI\Board.lua) loads after this file
local function WelcomeCard()
    if welcomeCard then return welcomeCard end
    local f = TTS.CreateCardFrame(UIParent, TTS.PREVIEW_W, TTS.PREVIEW_H)
    f:EnableMouse(true)
    f:SetScript("OnEnter", function(self)
        if TTS.Tooltip then TTS.Tooltip:ShowCard(self, "ANCHOR_RIGHT", BETA_CARD) end
    end)
    f:SetScript("OnLeave", function(self)
        if TTS.Tooltip then TTS.Tooltip:Hide(self) end
    end)
    f:SetScript("OnClick", nil)
    welcomeCard = f
    return f
end

function TTS:ShowBetaWelcome()
    local card = TTS.Cards and TTS.Cards[BETA_CARD]
    if not card then return end
    local text = (TTS.L or tostring)("stamp.betaPopup", TTS:CardName(card))
    local dialog = StaticPopup_Show("TTS_BETA_WELCOME", text)
    if not (dialog and TTS.CreateCardFrame and TTS.PaintPreviewCard) then return end

    -- The popup has sized itself to the message and OK (anchored to its bottom): make room
    -- below the message for the card
    local f = WelcomeCard()
    local textFS = dialog.text or _G[dialog:GetName() .. "Text"]
    f:SetParent(dialog)
    f:SetFrameLevel(dialog:GetFrameLevel() + 5)
    f:ClearAllPoints()
    f:SetPoint("TOP", textFS or dialog, "BOTTOM", 0, -CARD_HEAD)
    dialog:SetHeight(dialog:GetHeight() + CARD_HEAD + TTS.PREVIEW_H + CARD_GAP)
    f:Show()
    TTS.PaintPreviewCard(f, card)
end

-- The welcome waits until the world is loaded, so the chosen language is ready
frame:HookScript("OnEvent", function(self, event)
    if event ~= "PLAYER_ENTERING_WORLD" then return end
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    C_Timer.After(2, function() TTS:ShowBetaWelcome() end)
end)
