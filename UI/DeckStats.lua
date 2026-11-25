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
-- DECK STATS: the mana curve and the sphere distribution, with a line of card counts
-- (Denizens, Spells, Prayers). Both charts count every non-Prayer card. Used under the
-- Deckbuilder's deck list (UI\DeckBuilder.lua) and in Endless's deck panel (UI\Endless.lua).
--   local stats = TTS.CreateDeckStats(parent, width, stacked)
--   stats:Update(cards)   -- cards = { [cardId] = count }
--   stats.frame           -- the panel, to anchor
-- stacked: the curve above the colours (a narrow panel); otherwise side by side, as wide
-- as `width` (the Deckbuilder's 344).
-- =========================================================================
local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local BAR_TEX = "Interface\\TargetingFrame\\UI-StatusBar"

local SPHERE_ORDER = { "W", "U", "B", "R", "G" }
local SPHERE_RGB = {
    W = { 1.00, 0.82, 0.00 },  -- Holy
    U = { 0.40, 0.73, 1.00 },  -- Arcane
    B = { 0.60, 0.40, 1.00 },  -- Shadow
    R = { 1.00, 0.27, 0.27 },  -- Fire
    G = { 0.27, 1.00, 0.27 },  -- Nature
}

local CURVE_COLUMNS = 8      -- mana values 0..7+
local CURVE_BAR_W, CURVE_BAR_GAP = 16, 7
local COLOR_BAR_W, COLOR_BAR_GAP = 18, 8
local BAR_BASE_Y, BAR_MAX_H = 36, 48     -- side by side (the Deckbuilder)
local STACKED_BASE_Y, STACKED_MAX_H = 18, 26   -- stacked: shorter bars, clear of the titles
local CHART_W, CHART_H = 200, 118     -- one chart's area (side by side: the curve's width)
local STACKED_CHART_H = 76            -- each chart's height when stacked (no summary under it)

local function Sym(str, size)
    if TTS.FormatSymbols then return TTS:FormatSymbols(str, size) end
    return str
end

local function RGBHex(rgb)
    return string.format("|cFF%02X%02X%02X", math.floor(rgb[1] * 255), math.floor(rgb[2] * 255), math.floor(rgb[3] * 255))
end

-- A hero's colour is its class's, but its cost is generic: it counts as colourless
local function CardColor(card)
    if card.isHero then return nil end
    return card.color
end

local function IsPrayer(card) return card.type == "Land" end

-- One chart: a title, a note on the right, and a bar per column
local function Chart(parent, titleKey, columns, barW, gap, labelOf, rgbOf, baseY, maxH)
    local f = CreateFrame("Frame", nil, parent)
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -8)
    Loc:Bind(title, titleKey)
    f.note = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    f.note:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -8)
    f.bars, f.counts, f.labels = {}, {}, {}
    for i, key in ipairs(columns) do
        local x = 10 + (i - 1) * (barW + gap)
        local track = f:CreateTexture(nil, "BACKGROUND", nil, 1)
        track:SetColorTexture(0, 0, 0, 0.35)
        track:SetSize(barW, maxH)
        track:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", x, baseY)
        local bar = f:CreateTexture(nil, "ARTWORK")
        bar:SetTexture(BAR_TEX)
        local rgb = rgbOf(key)
        bar:SetVertexColor(rgb[1], rgb[2], rgb[3], 0.95)
        bar:SetSize(barW, 1)
        bar:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", x, baseY)
        f.bars[key] = bar
        local cnt = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        cnt:SetPoint("BOTTOM", bar, "TOP", 0, 1)
        f.counts[key] = cnt
        local lbl = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        lbl:SetPoint("TOP", track, "BOTTOM", 0, -3)
        lbl:SetText(labelOf(key))
        f.labels[key] = lbl
    end
    function f:SetValues(values)
        local maxCount = 1
        for _, key in ipairs(columns) do
            if values[key] > maxCount then maxCount = values[key] end
        end
        for _, key in ipairs(columns) do
            local n = values[key]
            if n > 0 then
                self.bars[key]:SetHeight(math.max(2, math.floor(n / maxCount * maxH)))
                self.bars[key]:Show()
                self.counts[key]:SetText(n)
            else
                self.bars[key]:SetHeight(1)
                self.bars[key]:Hide()
                self.counts[key]:SetText("")
            end
        end
    end
    return f
end

function TTS.CreateDeckStats(parent, width, stacked)
    local S = {}
    local panel = CreateFrame("Frame", nil, parent, backdropTemplate)
    S.frame = panel
    panel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    panel:SetBackdropColor(0.02, 0.02, 0.02, 0.6)
    panel:SetBackdropBorderColor(0.60, 0.56, 0.48, 1)

    local baseY = stacked and STACKED_BASE_Y or BAR_BASE_Y
    local maxH = stacked and STACKED_MAX_H or BAR_MAX_H
    local curveCols = {}
    for m = 0, CURVE_COLUMNS - 1 do curveCols[#curveCols + 1] = m end
    local curve = Chart(panel, "db.manaCurve", curveCols, CURVE_BAR_W, CURVE_BAR_GAP,
        function(m) return m == CURVE_COLUMNS - 1 and (m .. "+") or tostring(m) end,
        function() return { 0.30, 0.60, 1.00 } end, baseY, maxH)
    local colors = Chart(panel, "db.colours", SPHERE_ORDER, COLOR_BAR_W, COLOR_BAR_GAP,
        function(col) return RGBHex(SPHERE_RGB[col]) .. col .. "|r" end,
        function(col) return SPHERE_RGB[col] end, baseY, maxH)

    local divider = panel:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(1, 0.82, 0, 0.25)
    local summary = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    local note = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    Loc:Bind(note, "db.prayersNotCharted")

    if stacked then
        -- Curve on top, colours under it, then the counts and the note
        panel:SetSize(width, 2 * STACKED_CHART_H + 38)
        curve:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
        curve:SetSize(width, STACKED_CHART_H)
        colors:SetPoint("TOPLEFT", curve, "BOTTOMLEFT", 0, 0)
        colors:SetSize(width, STACKED_CHART_H)
        divider:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, -STACKED_CHART_H)
        divider:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -8, -STACKED_CHART_H)
        divider:SetHeight(1)
        summary:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 22)
        note:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 8)
    else
        panel:SetSize(width, CHART_H)
        curve:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
        curve:SetSize(CHART_W, CHART_H)
        colors:SetPoint("TOPLEFT", panel, "TOPLEFT", CHART_W, 0)
        colors:SetSize(width - CHART_W, CHART_H)
        divider:SetPoint("TOPLEFT", panel, "TOPLEFT", CHART_W, -8)
        divider:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", CHART_W, 24)
        divider:SetWidth(1)
        summary:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 7)
        note:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -8, 7)
    end

    function S:Update(cards)
        local buckets, sphere = {}, { W = 0, U = 0, B = 0, R = 0, G = 0 }
        for m = 0, CURVE_COLUMNS - 1 do buckets[m] = 0 end
        local spellCount, cmcSum, sphereTotal = 0, 0, 0
        local nCreature, nSpell, nPrayer = 0, 0, 0
        for id, count in pairs(cards or {}) do
            local c = TTS.Cards and TTS.Cards[id]
            if c and count > 0 then
                if IsPrayer(c) then
                    nPrayer = nPrayer + count
                else
                    if c.type == "Creature" then nCreature = nCreature + count else nSpell = nSpell + count end
                    local cmc = c.cmc or 0
                    local m = math.min(CURVE_COLUMNS - 1, cmc)
                    buckets[m] = buckets[m] + count
                    spellCount = spellCount + count
                    cmcSum = cmcSum + cmc * count
                    local col = CardColor(c)
                    if col and sphere[col] then
                        sphere[col] = sphere[col] + count
                        sphereTotal = sphereTotal + count
                    end
                end
            end
        end
        curve:SetValues(buckets)
        curve.note:SetText(L("db.avg", spellCount > 0 and (cmcSum / spellCount) or 0))
        colors:SetValues(sphere)
        colors.note:SetText(L("db.nCards", sphereTotal))
        for _, col in ipairs(SPHERE_ORDER) do
            if TTS.FormatSymbols then colors.labels[col]:SetText(Sym("{" .. col .. "}", 12)) end
        end
        summary:SetText(L("db.summary", nCreature, nSpell, nPrayer))
    end

    -- From a list of card ids (Endless's run deck)
    function S:UpdateList(list)
        local cards = {}
        for _, id in ipairs(list or {}) do cards[id] = (cards[id] or 0) + 1 end
        self:Update(cards)
    end

    return S
end
