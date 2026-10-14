--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

-- =========================================================================
-- CARD DATABASE
-- This is the only file that creates TTS.Cards. Every other file under Cards\
-- adds to it through TTS:AddCards (or `TTS.Cards["ID"] = { ... }`); never
-- reassign the table, or cards from files loaded earlier are lost.
-- =========================================================================
TTS.Cards = {
    -- =========================================================================
    -- PRAYERS (LANDS)
    -- =========================================================================
    ["W01"] = {
        id = "W01", name = "Prayer of Light", cost = "", cmc = 0, color = "W", type = "Land",
        text = "{T}: Add {W}.",
        art = "Interface\\AddOns\\ForeverCCG\\Textures\\Symbols\\W.png"
    },
    ["U01"] = {
        id = "U01", name = "Prayer of Arcane", cost = "", cmc = 0, color = "U", type = "Land",
        text = "{T}: Add {U}.",
        art = "Interface\\AddOns\\ForeverCCG\\Textures\\Symbols\\U.png"
    },
    ["B01"] = {
        id = "B01", name = "Prayer of Shadow", cost = "", cmc = 0, color = "B", type = "Land",
        text = "{T}: Add {B}.",
        art = "Interface\\AddOns\\ForeverCCG\\Textures\\Symbols\\B.png"
    },
    ["R01"] = {
        id = "R01", name = "Prayer of Fire", cost = "", cmc = 0, color = "R", type = "Land",
        text = "{T}: Add {R}.",
        art = "Interface\\AddOns\\ForeverCCG\\Textures\\Symbols\\R.png"
    },
    ["G01"] = {
        id = "G01", name = "Prayer of Nature", cost = "", cmc = 0, color = "G", type = "Land",
        text = "{T}: Add {G}.",
        art = "Interface\\AddOns\\ForeverCCG\\Textures\\Symbols\\G.png"
    },
}

-- Adds a batch of cards; warns in chat when an ID is defined twice.
function TTS:AddCards(cards)
    for id, card in pairs(cards) do
        if TTS.Cards[id] then
            local msg = string.format("|cFFFF2222[TTSE]|r Card %s is defined more than once.", id)
            if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage(msg) else print(msg) end
        end
        TTS.Cards[id] = card
    end
end


-- =========================================================================
-- SAVED DECK CLEANUP
-- Cards from earlier versions of the database no longer exist; drop them from saved decks once saved variables are loaded.
-- =========================================================================
function TTS:PruneRemovedCards()
    if not TTS_SavedDecks then return end
    local removed = 0
    for _, deck in pairs(TTS_SavedDecks) do
        if deck.cards then
            for id, qty in pairs(deck.cards) do
                if not TTS.Cards[id] then
                    deck.cards[id] = nil
                    removed = removed + qty
                end
            end
        end
    end
    if removed > 0 and DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFFFFA500[TTSE]|r Removed %d card(s) that no longer exist from your saved decks.", removed))
    end
end

local pruneFrame = CreateFrame("Frame")
pruneFrame:RegisterEvent("PLAYER_LOGIN")
pruneFrame:SetScript("OnEvent", function(self)
    TTS:PruneRemovedCards()
    self:UnregisterAllEvents()
end)
