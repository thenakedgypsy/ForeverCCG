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
-- Shown as a number and a sword (power) in a card's bottom-left corner and a number and
-- a shield (toughness) in its bottom-right corner; tooltips use the same two symbols.
-- The symbols are gold and bronze metalwork to match the card frames.
-- Damage taken this turn lowers the toughness shown (in red) until it wears off.
-- Card frames keep toughness in f.pt (as before) and gain f.power for the power.
-- =========================================================================
local SYMBOLS = "Interface\\AddOns\\ForeverCCG\\Textures\\Symbols\\"
TTS.POWER_ICON     = SYMBOLS .. "Sword.png"
TTS.TOUGHNESS_ICON = SYMBOLS .. "Shield.png"

local GOLD = "|cFFFFD200"
local CORNER_X, CORNER_Y = 0.08, 0.05   -- corner inset, as a share of the card's width / height

local function Icon(path, size)
    return string.format("|T%s:%d:%d|t", path, size, size)
end

-- "3 [sword]"
function TTS.PowerText(power, colorCode, size)
    return (colorCode or GOLD) .. tostring(power) .. "|r" .. Icon(TTS.POWER_ICON, size or 14)
end

-- "5 [shield]", red when damage has lowered it
function TTS.ToughnessText(toughness, damage, colorCode, size)
    damage = damage or 0
    local shown = (damage > 0) and ("|cFFFF4444" .. (toughness - damage) .. "|r")
        or ((colorCode or GOLD) .. tostring(toughness) .. "|r")
    return shown .. Icon(TTS.TOUGHNESS_ICON, size or 14)
end

-- One line for tooltips: "3 [sword]    5 [shield]"
function TTS.FormatStats(power, toughness, damage, colorCode, size)
    return TTS.PowerText(power, colorCode, size) .. "    " .. TTS.ToughnessText(toughness, damage, colorCode, size)
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

-- Anchors power to the bottom-left corner and toughness to the bottom-right corner
function TTS.PlaceCardStats(f)
    if not f.pt then return end
    local parent = f.overlay or f
    local w, h = f:GetWidth() or 0, f:GetHeight() or 0
    f.pt:ClearAllPoints()
    f.pt:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -w * CORNER_X, h * CORNER_Y)
    f.pt:SetJustifyH("RIGHT")
    local p = PowerString(f)
    p:ClearAllPoints()
    p:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", w * CORNER_X, h * CORNER_Y)
end

-- Shows a creature's stats on a card frame
function TTS.SetCardStats(f, power, toughness, damage, colorCode)
    if not f.pt then return end
    local _, size = f.pt:GetFont()
    size = math.floor((size or 14) * 0.95)
    local p = PowerString(f)
    p:SetText(TTS.PowerText(power, colorCode, size))
    f.pt:SetText(TTS.ToughnessText(toughness, damage, colorCode, size))
    TTS.PlaceCardStats(f)
    p:Show()
    f.pt:Show()
end

function TTS.HideCardStats(f)
    if f.pt then f.pt:Hide() end
    if f.power then f.power:Hide() end
end

-- Stats for a card's printed values (or hidden when it isn't a creature)
function TTS.ShowPrintedStats(f, card)
    if card and card.type == "Creature" and card.power and card.toughness then
        TTS.SetCardStats(f, card.power, card.toughness, 0, GOLD)
    else
        TTS.HideCardStats(f)
    end
end
