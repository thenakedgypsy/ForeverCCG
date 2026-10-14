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
-- Shown along a card's bottom edge as "3 [sword | divider | shield] 5": one emblem
-- (Textures\Symbols\Sword_Divider_Shield.png) centred on the edge, power just to its left
-- and toughness just to its right. Tooltips and the log use the same emblem inline.
-- Sizes grow with the card. Damage taken this turn lowers the toughness shown (in red)
-- until it wears off. Card frames keep toughness in f.pt (as before) and gain f.power.
-- =========================================================================
local SYMBOLS = "Interface\\AddOns\\ForeverCCG\\Textures\\Symbols\\"
TTS.STATS_EMBLEM = SYMBOLS .. "Sword_Divider_Shield.png"
local EMBLEM_ASPECT = 158 / 64       -- the emblem image's width / height

local GOLD = "|cFFFFD200"
local CORNER_Y = 0.05                -- stat line's height above the card's bottom edge, as a share of its height
local EMBLEM_SCALE = 1.1             -- emblem height on cards, relative to the numbers
local EMBLEM_SCALE_LARGE = 0.87      -- the same on large previews (cards whose stats grew past their frame's size)
local EMBLEM_GAP = 0.12              -- space between the emblem and each number, as a share of the font size

-- The emblem as an inline texture, height h
local function EmblemIcon(h)
    h = math.floor(h + 0.5)
    return string.format("|T%s:%d:%d|t", TTS.STATS_EMBLEM, h, math.floor(h * EMBLEM_ASPECT + 0.5))
end

-- "3"
function TTS.PowerText(power, colorCode)
    return (colorCode or GOLD) .. tostring(power) .. "|r"
end

-- "5", red when damage has lowered it
function TTS.ToughnessText(toughness, damage, colorCode)
    damage = damage or 0
    if damage > 0 then return "|cFFFF4444" .. (toughness - damage) .. "|r" end
    return (colorCode or GOLD) .. tostring(toughness) .. "|r"
end

-- One line for tooltips and the log: "3 [sword | divider | shield] 5"
function TTS.FormatStats(power, toughness, damage, colorCode, size)
    size = size or 14
    return TTS.PowerText(power, colorCode) .. " " .. EmblemIcon(size * 1.25) .. " "
        .. TTS.ToughnessText(toughness, damage, colorCode)
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
    p:SetJustifyH("RIGHT")
    p:Hide()
    f.power = p
    return p
end

-- The emblem between the two numbers on a card frame
local function EmblemTexture(f)
    if f.ptEmblem then return f.ptEmblem end
    local e = (f.overlay or f):CreateTexture(nil, "OVERLAY", nil, 5)
    e:SetTexture(TTS.STATS_EMBLEM)
    e:Hide()
    f.ptEmblem = e
    return e
end

-- Stat text size for a card frame: grows with the card (large previews get large stats),
-- never smaller than the size the frame was built with
local STAT_SIZE_SHARE = 0.14

local function StatSize(f)
    if not f.ptBaseSize then
        local _, built = f.pt:GetFont()
        f.ptBaseSize = math.floor((built or 14) * 0.95)
    end
    return math.max(f.ptBaseSize, math.floor((f:GetWidth() or 0) * STAT_SIZE_SHARE + 0.5))
end

-- The emblem centred on the card's bottom edge, power to its left, toughness to its right
function TTS.PlaceCardStats(f)
    if not f.pt then return end
    local parent = f.overlay or f
    local h = f:GetHeight() or 0
    local _, size = f.pt:GetFont()
    size = size or 14
    local large = f.ptBaseSize and size > f.ptBaseSize
    local eh = size * (large and EMBLEM_SCALE_LARGE or EMBLEM_SCALE)
    local e = EmblemTexture(f)
    e:SetSize(eh * EMBLEM_ASPECT, eh)
    e:ClearAllPoints()
    e:SetPoint("CENTER", parent, "BOTTOM", 0, h * CORNER_Y + size / 2)
    local gap = size * EMBLEM_GAP
    local p = PowerString(f)
    p:ClearAllPoints()
    p:SetPoint("RIGHT", e, "LEFT", -gap, 0)
    p:SetJustifyH("RIGHT")
    f.pt:ClearAllPoints()
    f.pt:SetPoint("LEFT", e, "RIGHT", gap, 0)
    f.pt:SetJustifyH("LEFT")
end

-- Shows a creature's stats on a card frame
function TTS.SetCardStats(f, power, toughness, damage, colorCode)
    if not f.pt then return end
    local size = StatSize(f)
    local font, _, flags = f.pt:GetFont()
    if font then f.pt:SetFont(font, size, flags or "OUTLINE") end
    local p = PowerString(f)
    if font then p:SetFont(font, size, flags or "OUTLINE") end
    p:SetText(TTS.PowerText(power, colorCode))
    f.pt:SetText(TTS.ToughnessText(toughness, damage, colorCode))
    TTS.PlaceCardStats(f)
    p:Show()
    f.pt:Show()
    EmblemTexture(f):Show()
end

function TTS.HideCardStats(f)
    if f.pt then f.pt:Hide() end
    if f.power then f.power:Hide() end
    if f.ptEmblem then f.ptEmblem:Hide() end
end

-- Stats for a card's printed values (or hidden when it isn't a creature)
function TTS.ShowPrintedStats(f, card)
    if card and card.type == "Creature" and card.power and card.toughness then
        TTS.SetCardStats(f, card.power, card.toughness, 0, GOLD)
    else
        TTS.HideCardStats(f)
    end
end
