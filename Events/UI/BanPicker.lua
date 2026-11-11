--[[
    ForeverCCG Events
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.
]]
local _, ns = ...
local UI = ns.UI

-- =========================================================================
-- BANNED CARDS PICKER
-- The organizer's Banned cards button (UI\Organizer.lua) opens this: every card a deck can
-- hold, searchable by name or text and filtered by type and sphere; clicking one bans or
-- unbans it. Done hands the chosen ids back. Built the first time it opens.
-- =========================================================================
local GREY, GREEN, RED = UI.GREY, UI.GREEN, UI.RED
local ROWS, ROW_H = 16, 20
local F
local chosen = {}        -- [card id] = true
local onDone             -- function(ids), from the opener
local filter = { text = "", type = "all", sphere = "all", only = false }

local SPHERE_HEX = { W = "FFE6CC80", U = "FF4FA3FF", B = "FFB07FE0", R = "FFFF5544", G = "FF55DD55" }

-- The type group a card is listed under (as the Deckbuilder's toggles)
local function TypeOf(card)
    if card.type == "Land" then return "Prayer" end
    if card.type == "Creature" then return "Creature" end
    if card.type == "Settlement" then return "Settlement" end
    if card.subType == "Gear" then return "Gear" end
    return "Spell"
end

local function Name(card) return (TTS.CardName and TTS:CardName(card)) or card.name or card.id end

-- The cost with its sphere symbols coloured: "{2}{R}" -> "2R"
local function CostText(card)
    local out = {}
    for sym in (card.cost or ""):gmatch("{(%w+)}") do
        local hex = SPHERE_HEX[sym]
        out[#out + 1] = hex and ("|c" .. hex .. sym .. "|r") or sym
    end
    return table.concat(out)
end

-- Every card a deck can hold, A-Z
local allCards
local function AllCards()
    if allCards then return allCards end
    allCards = {}
    for id, card in pairs(TTS.Cards or {}) do
        if not card.isToken and not card.notCollectible then
            allCards[#allCards + 1] = { id = tostring(id), card = card, name = Name(card), type = TypeOf(card),
                hay = ((card.name or "") .. "\n" .. Name(card) .. "\n" .. (card.text or "") .. "\n"
                    .. ((TTS.CardText and TTS:CardText(card)) or "")):lower() }
        end
    end
    table.sort(allCards, function(a, b) return a.name < b.name end)
    return allCards
end

local function CountChosen()
    local n = 0
    for _ in pairs(chosen) do n = n + 1 end
    return n
end

local function Refresh()
    if not F then return end
    local list = {}
    for _, e in ipairs(AllCards()) do
        local c = e.card
        local ok = (filter.type == "all" or e.type == filter.type)
            and (filter.sphere == "all" or (filter.sphere == "C" and not (c.cost or ""):find("[WUBRG]"))
                or (c.cost or ""):find("{" .. filter.sphere .. "}", 1, true))
            and (not filter.only or chosen[e.id])
            and (filter.text == "" or e.hay:find(filter.text, 1, true))
        if ok then list[#list + 1] = e end
    end
    F.list:SetData(list)
    local n = CountChosen()
    F.count:SetText((n == 0 and GREY or RED) .. n .. (n == 1 and " card banned" or " cards banned") .. "|r"
        .. GREY .. "   (" .. #list .. " shown)|r")
end

local function Build()
    F = UI.Window("FCCGE_BanFrame", 460, 120 + ROWS * ROW_H, "Banned Cards")
    F:SetToplevel(true)   -- (over the organizer's window, which shares its strata)

    F.search = UI.Edit(F, 180, nil)
    F.search:SetPoint("TOPLEFT", 22, -48)
    F.search:SetScript("OnTextChanged", function(self)
        filter.text = (self:GetText() or ""):lower()
        F.list.offset = 0
        Refresh()
    end)
    local hint = UI.Label(F, "GameFontDisableSmall", 26, -52)
    hint:SetText("Search name or text")
    F.search:HookScript("OnEditFocusGained", function() hint:Hide() end)
    F.search:HookScript("OnEditFocusLost", function(self) hint:SetShown(self:GetText() == "") end)

    F.type = UI.Dropdown(F, 100, { { "all", "All types" }, { "Creature", "Denizens" }, { "Spell", "Spells" },
        { "Settlement", "Settlements" }, { "Gear", "Gear" }, { "Prayer", "Prayers" } }, function(v)
        filter.type = v; F.list.offset = 0; Refresh()
    end)
    F.type:SetPoint("TOPLEFT", 214, -46)
    F.sphere = UI.Dropdown(F, 100, { { "all", "All spheres" }, { "W", "Holy" }, { "U", "Arcane" }, { "B", "Shadow" },
        { "R", "Fire" }, { "G", "Nature" }, { "C", "Colourless" } }, function(v)
        filter.sphere = v; F.list.offset = 0; Refresh()
    end)
    F.sphere:SetPoint("TOPLEFT", 322, -46)

    F.list = UI.List(F, 18, -76, 424, ROW_H, ROWS, function(row)
        row.mark = UI.Label(row, "GameFontNormal", 4, -3, 18)
        row.cost = UI.Label(row, "GameFontHighlightSmall", 24, -4, 50)
        row.name = UI.Label(row, "GameFontHighlight", 78, -3, 250)
        row.kind = UI.Label(row, "GameFontDisableSmall", 334, -4, 86)
        row:SetScript("OnClick", function(self)
            local id = self.item and self.item.id
            if not id then return end
            chosen[id] = (not chosen[id]) or nil
            Refresh()
        end)
    end, function(row, e)
        local on = chosen[e.id]
        row.mark:SetText(on and (RED .. "x|r") or (GREY .. "-|r"))
        row.cost:SetText(CostText(e.card))
        row.name:SetText(on and (RED .. e.name .. "|r") or e.name)
        row.kind:SetText(e.type == "Creature" and "Denizen" or e.type)
    end)

    F.count = UI.Label(F, "GameFontHighlightSmall", 22, -(84 + ROWS * ROW_H))
    F.only = UI.Button(F, "Banned only", 96, 22, function()
        filter.only = not filter.only
        F.only:SetText(filter.only and "Show all" or "Banned only")
        F.list.offset = 0
        Refresh()
    end)
    F.only:SetPoint("BOTTOMLEFT", 18, 16)
    local clear = UI.Button(F, "Clear", 70, 22, function()
        chosen = {}
        Refresh()
    end)
    clear:SetPoint("LEFT", F.only, "RIGHT", 6, 0)
    local done = UI.Button(F, "Done", 90, 22, function()
        local ids = {}
        for id in pairs(chosen) do ids[#ids + 1] = id end
        table.sort(ids)
        if onDone then onDone(ids) end
        F:Hide()
    end)
    done:SetPoint("BOTTOMRIGHT", -18, 16)
end

-- Opens the picker on the ids banned so far; done(ids) is called with the new list on Done
-- (closing the window any other way keeps the old list)
function UI.OpenBanPicker(ids, done)
    if not F then Build() end
    chosen = {}
    for _, id in ipairs(ids or {}) do chosen[tostring(id)] = true end
    onDone = done
    F.list.offset = 0
    F:Show()
    F:Raise()
    Refresh()
end
