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

    -- =========================================================================
    -- NON-BASIC PRAYERS
    -- nameHorde = the name Horde players see; colors = the colours it can make;
    -- isGift = handed out by NPCs (giftNpcs = the npcId
    -- in each faction; they share one cooldown per card, see
    -- UI\NpcGossip.lua), one copy a day up to 4
    -- =========================================================================
    ["PRY01"] = {
        id = "PRY01", name = "Lakeshire Hearth", nameHorde = "Sun Rock Hearth", cost = "", cmc = 0, color = "W", colors = { "W", "R" }, type = "Land",
        isGift = true, giftNpcs = { Alliance = 6727, Horde = 7731 },   -- Brianna, Lakeshire / Jayka, Sun Rock Retreat
        text = "{T}: Add {W} or {R}.",
        art = "Interface\\Icons\\INV_Misc_Rune_01"
    },
    ["PRY02"] = {
        id = "PRY02", name = "Thelsamar Hearth", nameHorde = "Crossroads Hearth", cost = "", cmc = 0, color = "G", colors = { "G", "R" }, type = "Land",
        isGift = true, giftNpcs = { Alliance = 6734, Horde = 3934 },   -- Hearthstove, Thelsamar / Boorand Plainswind, Crossroads
        text = "{T}: Add {G} or {R}.",
        art = "Interface\\Icons\\INV_Misc_Rune_01"
    },
    ["PRY03"] = {
        id = "PRY03", name = "Auberdine Hearth", nameHorde = "Sepulcher Hearth", cost = "", cmc = 0, color = "U", colors = { "U", "G" }, type = "Land",
        isGift = true, giftNpcs = { Alliance = 6737, Horde = 6739 },   -- Shaussiy, Auberdine / Bates, The Sepulcher
        text = "{T}: Add {U} or {G}.",
        art = "Interface\\Icons\\INV_Misc_Rune_01"
    },
    -- Levels 1-10
    ["PRY04"] = {
        id = "PRY04", name = "Dolanaar Hearth", nameHorde = "Bloodhoof Hearth", cost = "", cmc = 0, color = "W", colors = { "W", "G" }, type = "Land",
        isGift = true, giftNpcs = { Alliance = 6736, Horde = 6747 },   -- Keldamyr, Dolanaar / Kauth, Bloodhoof Village
        text = "{T}: Add {W} or {G}.",
        art = "Interface\\Icons\\INV_Misc_Rune_01"
    },
    ["PRY05"] = {
        id = "PRY05", name = "Kharanos Hearth", nameHorde = "Brill Hearth", cost = "", cmc = 0, color = "U", colors = { "U", "B" }, type = "Land",
        isGift = true, giftNpcs = { Alliance = 1247, Horde = 5688 },   -- Belm, Kharanos / Renee, Brill
        text = "{T}: Add {U} or {B}.",
        art = "Interface\\Icons\\INV_Misc_Rune_01"
    },
    ["PRY06"] = {
        id = "PRY06", name = "Goldshire Hearth", nameHorde = "Razor Hill Hearth", cost = "", cmc = 0, color = "B", colors = { "B", "R" }, type = "Land",
        isGift = true, giftNpcs = { Alliance = 295, Horde = 6928 },   -- Farley, Goldshire / Grosk, Razor Hill
        text = "{T}: Add {B} or {R}.",
        art = "Interface\\Icons\\INV_Misc_Rune_01"
    },
    -- Levels 18-30
    ["PRY07"] = {
        id = "PRY07", name = "Southshore Hearth", nameHorde = "Tarren Mill Hearth", cost = "", cmc = 0, color = "W", colors = { "W", "B" }, type = "Land",
        isGift = true, giftNpcs = { Alliance = 2352, Horde = 2388 },   -- Anderson, Southshore / Shay, Tarren Mill
        text = "{T}: Add {W} or {B}.",
        art = "Interface\\Icons\\INV_Misc_Rune_01"
    },
    ["PRY08"] = {
        id = "PRY08", name = "Darkshire Hearth", nameHorde = "Splintertree Hearth", cost = "", cmc = 0, color = "B", colors = { "B", "G" }, type = "Land",
        isGift = true, giftNpcs = { Alliance = 6790, Horde = 12196 },   -- Trelayne, Darkshire / Kaylisk, Splintertree Post
        text = "{T}: Add {B} or {G}.",
        art = "Interface\\Icons\\INV_Misc_Rune_01"
    },
    -- Levels 35-50
    ["PRY09"] = {
        id = "PRY09", name = "Aerie Peak Hearth", nameHorde = "Revantusk Hearth", cost = "", cmc = 0, color = "W", colors = { "W", "U" }, type = "Land",
        isGift = true, giftNpcs = { Alliance = 7744, Horde = 14731 },   -- Thulfram, Aerie Peak / Lard, Revantusk Village
        text = "{T}: Add {W} or {U}.",
        art = "Interface\\Icons\\INV_Misc_Rune_01"
    },
    ["PRY10"] = {
        id = "PRY10", name = "Theramore Hearth", nameHorde = "Kargath Hearth", cost = "", cmc = 0, color = "U", colors = { "U", "R" }, type = "Land",
        isGift = true, giftNpcs = { Alliance = 6272, Horde = 9356 },   -- Janene, Theramore / Shul'kar, Kargath
        text = "{T}: Add {U} or {R}.",
        art = "Interface\\Icons\\INV_Misc_Rune_01"
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
