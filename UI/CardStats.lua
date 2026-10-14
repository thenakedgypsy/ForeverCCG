--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

-- =========================================================================
-- POWER & TOUGHNESS
-- Shown along a card's bottom edge as "3 [sword]  [divider]  [shield] 5", centred on the
-- divider; tooltips use the same symbols. Sizes grow with the card.
-- Damage taken this turn lowers the toughness shown (in red) until it wears off.
-- Card frames keep toughness in f.pt (as before) and gain f.power for the power.
-- =========================================================================
local SYMBOLS = "Interface\\AddOns\\ForeverCCG\\Textures\\Symbols\\"
TTS.POWER_ICON     = SYMBOLS .. "Sword.png"
TTS.TOUGHNESS_ICON = SYMBOLS .. "Shield.png"
TTS.STATS_DIVIDER  = SYMBOLS .. "Divider.png"   -- 1:2 gold ornament between the two numbers

local GOLD = "|cFFFFD200"
local CORNER_Y = 0.05          -- stat line's height above the card's bottom edge, as a share of its height
local DIVIDER_SCALE = 1.6      -- divider height relative to the stat font size
local ICON_SCALE = 0.85        -- sword / shield size on cards, relative to the numbers

local function Icon(path, size)
    return string.format("|T%s:%d:%d|t", path, size, size)
end

-- The divider in text: as tall as DIVIDER_SCALE font heights, half as wide
local function DividerIcon(size)
    local h = math.floor(size * DIVIDER_SCALE + 0.5)
    return string.format("|T%s:%d:%d|t", TTS.STATS_DIVIDER, h, math.floor(h / 2 + 0.5))
end

-- "3 [sword]"
function TTS.PowerText(power, colorCode, size)
    return (colorCode or GOLD) .. tostring(power) .. "|r" .. Icon(TTS.POWER_ICON, size or 14)
end

-- "[shield] 5", red when damage has lowered it
function TTS.ToughnessText(toughness, damage, colorCode, size)
    damage = damage or 0
    local shown = (damage > 0) and ("|cFFFF4444" .. (toughness - damage) .. "|r")
        or ((colorCode or GOLD) .. tostring(toughness) .. "|r")
    return Icon(TTS.TOUGHNESS_ICON, size or 14) .. shown
end

-- One line for tooltips: "3 [sword]  [divider]  [shield] 5"
function TTS.FormatStats(power, toughness, damage, colorCode, size)
    size = size or 14
    return TTS.PowerText(power, colorCode, size) .. "  " .. DividerIcon(size) .. "  "
        .. TTS.ToughnessText(toughness, damage, colorCode, size)
end

-- The power string of a card frame, made to match its toughness string (f.pt)
local function PowerString(f)
    if f.power then return f.power end
    local parent = f.overlay or f
    local p = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    local font, size, flags = f.pt:GetFont()
    if font then p:SetFont(font, size, flags) end
    p:SetShadowOffset(1.5, -1.5)
    p:SetShadowColor(0, 0, 0, 1)
    p:SetJustifyH("LEFT")
    p:Hide()
    f.power = p
    return p
end

-- The divider between the two numbers on a card frame
local function DividerTexture(f)
    if f.ptDivider then return f.ptDivider end
    local d = (f.overlay or f):CreateTexture(nil, "OVERLAY", nil, 5)
    d:SetTexture(TTS.STATS_DIVIDER)
    d:Hide()
    f.ptDivider = d
    return d
end

-- The divider centred on the card's bottom edge, power just to its left and toughness just
-- to its right, all on one line
local DIVIDER_GAP = -0.08  -- space between the divider and each number, as a share of the font size
                           -- (negative: the divider art has empty margins either side of the ornament)

function TTS.PlaceCardStats(f)
    if not f.pt then return end
    local parent = f.overlay or f
    local h = f:GetHeight() or 0
    local _, size = f.pt:GetFont()
    size = size or 14
    local d = DividerTexture(f)
    local dh = size * DIVIDER_SCALE
    d:SetSize(dh / 2, dh)
    d:ClearAllPoints()
    d:SetPoint("CENTER", parent, "BOTTOM", 0, h * CORNER_Y + size / 2)
    local gap = size * DIVIDER_GAP
    local p = PowerString(f)
    p:ClearAllPoints()
    p:SetPoint("RIGHT", d, "LEFT", -gap, 0)
    p:SetJustifyH("RIGHT")
    f.pt:ClearAllPoints()
    f.pt:SetPoint("LEFT", d, "RIGHT", gap, 0)
    f.pt:SetJustifyH("LEFT")
end

-- Stat text size for a card frame: grows with the card (large previews get large numbers,
-- symbols and divider), never smaller than the size the frame was built with
local STAT_SIZE_SHARE = 0.14

local function StatSize(f)
    if not f.ptBaseSize then
        local _, built = f.pt:GetFont()
        f.ptBaseSize = math.floor((built or 14) * 0.95)
    end
    return math.max(f.ptBaseSize, math.floor((f:GetWidth() or 0) * STAT_SIZE_SHARE + 0.5))
end

-- Shows a creature's stats on a card frame
function TTS.SetCardStats(f, power, toughness, damage, colorCode)
    if not f.pt then return end
    local size = StatSize(f)
    local font, _, flags = f.pt:GetFont()
    if font then f.pt:SetFont(font, size, flags or "OUTLINE") end
    local p = PowerString(f)
    if font then p:SetFont(font, size, flags or "OUTLINE") end
    local iconSize = math.floor(size * ICON_SCALE + 0.5)
    p:SetText(TTS.PowerText(power, colorCode, iconSize))
    f.pt:SetText(TTS.ToughnessText(toughness, damage, colorCode, iconSize))
    TTS.PlaceCardStats(f)
    p:Show()
    f.pt:Show()
    DividerTexture(f):Show()
end

function TTS.HideCardStats(f)
    if f.pt then f.pt:Hide() end
    if f.power then f.power:Hide() end
    if f.ptDivider then f.ptDivider:Hide() end
end

-- Stats for a card's printed values (or hidden when it isn't a creature)
function TTS.ShowPrintedStats(f, card)
    if card and card.type == "Creature" and card.power and card.toughness then
        TTS.SetCardStats(f, card.power, card.toughness, 0, GOLD)
    else
        TTS.HideCardStats(f)
    end
end
