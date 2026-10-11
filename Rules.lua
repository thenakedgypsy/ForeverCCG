--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local R = CreateFrame("Frame", "TTS_RulesFrame", UIParent, backdropTemplate)
TTS.RulesFrame = R

R:SetSize(620, 640)
R:SetPoint("CENTER")
R:SetFrameStrata("DIALOG")
R:SetToplevel(true)
R:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
R:EnableMouse(true)
R:SetMovable(true)
R:RegisterForDrag("LeftButton")
R:SetScript("OnDragStart", R.StartMoving)
R:SetScript("OnDragStop", R.StopMovingOrSizing)
R:Hide()

local SYMBOL_PATH = "Interface\\AddOns\\ForeverCCG\\Textures\\Symbols\\"
-- If your file is T.tga, change ".png" to ".tga" below:
local TAP_TEX = SYMBOL_PATH .. "T.png"

local function FormatTextWithSymbols(str, size)
    if not str or str == "" then return "" end
    local s = size or 16

    -- Format Tap directly using your disk symbol
    local tapTexture = string.format("|T%s:%d:%d:0:0|t", TAP_TEX, s, s)
    str = str:gsub("{[tT]}", tapTexture)
    str = str:gsub("{[tT][aA][pP]}", tapTexture)

    if TTS.FormatSymbols then
        return TTS:FormatSymbols(str, s)
    end

    local defaultIcons = {
        W = "Interface\\Icons\\Spell_Holy_Aspiration",
        U = "Interface\\Icons\\Spell_Frost_FrostArmor",
        B = "Interface\\Icons\\Spell_Shadow_AntiShadow",
        R = "Interface\\Icons\\Spell_Fire_Incinerate",
        G = "Interface\\Icons\\Spell_Nature_HealingTouch",
    }

    return str:gsub("{(%w+)}", function(key)
        local upperKey = string.upper(key)
        if tonumber(key) or upperKey == "X" then
            return string.format("|cFF8E939B(|r|cFFFFFFFF%s|r|cFF8E939B)|r", upperKey)
        end
        local icon = defaultIcons[upperKey]
        if icon then
            return string.format("|T%s:%d:%d:0:0|t", icon, s, s)
        end
        return "(" .. upperKey .. ")"
    end)
end

-- Header
local title = R:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", 0, -16)
title:SetText("Forever: CCG — Rules & Guide")

-- Close Button
local closeBtn = CreateFrame("Button", nil, R, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -5, -5)
closeBtn:SetScript("OnClick", function() R:Hide() end)

-- Scroll Frame & Content Container
local scrollFrame = CreateFrame("ScrollFrame", "TTS_RulesScrollFrame", R, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 18, -48)
scrollFrame:SetPoint("BOTTOMRIGHT", -36, 32)

local content = CreateFrame("Frame", "TTS_RulesContent", scrollFrame)
content:SetWidth(550)
content:SetHeight(100)
scrollFrame:SetScrollChild(content)

-- =========================================================================
-- EXACT IN-GAME CARD BUILDER (Matching Board.lua & DeckBuilder.lua)
-- =========================================================================
local function SetupRuleCard(f, cardId)
    local card = TTS.Cards and TTS.Cards[cardId]
    if not card then return end

    f.cardId = cardId

    -- 1. Setup Artwork or 3D Model exactly like Board.lua
    if TTS.SetupCardVisual then
        TTS.SetupCardVisual(f, card)
    else
        if card.displayId and f.model then
            f.art:Hide()
            f.model:Show()
            f.model:ClearModel()
            f.model:SetDisplayInfo(card.displayId)
            local cam = card.modelCam or {}
            if f.model.SetPortraitZoom then f.model:SetPortraitZoom(cam.zoom or 0.75) end
            if f.model.SetCamDistanceScale then f.model:SetCamDistanceScale(cam.camScale or 1.0) end
            if f.model.SetPosition then f.model:SetPosition(cam.x or 0, cam.y or 0, cam.z or -0.10) end
            if f.model.SetRotation then f.model:SetRotation(cam.rotation or 0.15) end
        else
            if f.model then f.model:Hide() end
            f.art:Show()
            f.art:SetTexture(card.art or "Interface\\Icons\\INV_Misc_QuestionMark")
        end
    end

    -- 2. Apply Colored Outer Frame
    if TTS.ApplyFrameTexture then
        TTS.ApplyFrameTexture(f.border, card)
    elseif TTS.GetCardFrameTexture then
        f.border:SetTexture(TTS.GetCardFrameTexture(card))
    end
    f.border:SetVertexColor(1, 1, 1, 1)

    -- 3. Card Title
    if f.title then
        f.title:SetText(card.name or "")
    end

    -- 4. Cost String
    if f.cost then
        if card.cost and card.cost ~= "" then
            f.cost:SetText(FormatTextWithSymbols(card.cost, 11))
            f.cost:Show()
        else
            f.cost:Hide()
        end
    end

    -- 5. Power / Toughness
    if f.pt then
        if card.type == "Creature" and card.power and card.toughness then
            f.pt:SetText(string.format("|cFFFFD200%d/%d|r", card.power, card.toughness))
            f.pt:Show()
        else
            f.pt:Hide()
        end
    end

    f:Show()
end

local function CreateExampleCard(parent, cardId)
    local cardW, cardH = 72, 102
    local f = nil

    if TTS.CreateCardFrame then
        f = TTS.CreateCardFrame(parent, cardW, cardH)
    else
        f = CreateFrame("Button", nil, parent)
        f:SetSize(cardW, cardH)

        f.bg = f:CreateTexture(nil, "BACKGROUND")
        f.bg:SetAllPoints(f)
        f.bg:SetColorTexture(0.08, 0.08, 0.08, 0.95)

        f.art = f:CreateTexture(nil, "ARTWORK")
        f.art:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -6)
        f.art:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -4, 45)

        f.model = CreateFrame("PlayerModel", nil, f)
        f.model:SetAllPoints(f.art)
        f.model:EnableMouse(false)
        f.model:Hide()

        f.overlay = CreateFrame("Frame", nil, f)
        f.overlay:SetAllPoints(f)
        f.overlay:EnableMouse(false)

        f.border = f.overlay:CreateTexture(nil, "OVERLAY")
        f.border:SetAllPoints(f.overlay)

        f.title = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        f.title:SetPoint("BOTTOMLEFT", f.overlay, "TOPLEFT", -6, 2)
        f.title:SetPoint("BOTTOMRIGHT", f.overlay, "TOPRIGHT", 6, 2)
        f.title:SetJustifyH("CENTER")

        f.cost = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        f.cost:SetPoint("BOTTOM", f.title, "TOP", 0, 1)
        f.cost:SetJustifyH("CENTER")

        f.pt = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        f.pt:SetPoint("BOTTOM", f.overlay, "BOTTOM", 0, 16)
        f.pt:SetJustifyH("CENTER")
    end

    f:SetFrameLevel(parent:GetFrameLevel() + 2)
    f:EnableMouse(true)
    f:RegisterForClicks("LeftButtonUp")

    -- Tooltip preview when hovering over rule examples
    f:SetScript("OnEnter", function(self)
        local card = TTS.Cards and TTS.Cards[self.cardId]
        if not card then return end
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(card.name, 1, 1, 1)
        local cStr = (card.cost and card.cost ~= "") and FormatTextWithSymbols(card.cost, 18) or "0"
        local displayType = card.type
        if displayType == "Land" then
            displayType = "Prayer"
        end
        GameTooltip:AddLine("Cost: " .. cStr .. "  |  " .. displayType, 0.8, 0.8, 0.8)
        local tagLine = TTS.GetCardTagLine and TTS:GetCardTagLine(card)
        if tagLine then
            GameTooltip:AddLine(tagLine, 1, 1, 1)
        end
        if card.power and card.toughness then
            GameTooltip:AddLine(string.format("P/T: %d/%d", card.power, card.toughness), 1, 0.8, 0)
        end
        if card.text and card.text ~= "" then
            GameTooltip:AddLine(FormatTextWithSymbols(card.text, 16), 0.9, 0.9, 0.5, true)
        end
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function() GameTooltip:Hide() end)

    SetupRuleCard(f, cardId)
    return f
end

-- =========================================================================
-- TEXT ELEMENTS
-- =========================================================================
local h1 = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
h1:SetText("Overview & Deck Building")

local p1 = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
p1:SetWidth(540)
p1:SetJustifyH("LEFT")
p1:SetWordWrap(true)
p1.rawText = "Both players begin at |cFFFFD20020 Life|r. Victory is achieved by reducing the enemy's life to 0 or forcing them to draw from an empty library.\n\n" ..
    "|cFFFFD200Deck Rules:|r\n" ..
    "• Minimum deck size: |cFFFFFFFF40 cards|r.\n" ..
    "• Maximum deck size: |cFFFFFFFF50 cards|r.\n" ..
    "• Max copies per non-Prayer card: |cFFFFFFFF4 copies|r (Basic Prayers have no limit).\n" ..
    "• Max spells per deck: |cFFFFFFFF12 spells|r (all non-Prayer, non-Creature cards count).\n" ..
    "• Creature cards must be |cFFFFD200unlocked|r by defeating them (see |cFFFFD200Unlocking Cards|r below)."

local hU = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
hU:SetText("Unlocking Cards")

local pU = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
pU:SetWidth(540)
pU:SetJustifyH("LEFT")
pU:SetWordWrap(true)
pU.rawText = "You build your collection by playing World of Warcraft. Some cards are free, the rest are earned.\n\n" ..
    "|cFFFFD200Always available:|r Prayers.\n\n" ..
    "|cFFFFD200Class Spells unlock as you level.|r Each of the nine classes (Warrior, Paladin, Hunter, Rogue, Priest, Shaman, Mage, Warlock and Druid) has 10 spells. You unlock |cFFFFFFFF1 spell from every class|r at level 6 and again every |cFFFFFFFF6 levels|r (12, 18, 24 ... 60), so all 90 are available by level 60. Each set of new spells is spread across all five spheres.\n\n" ..
    "|cFFFFD200Creature cards start locked.|r Every zone has 10 creatures to collect. Defeat the creature in the world for a |cFFFFD200chance|r to unlock its card:\n" ..
    "• Each card drop adds |cFFFFFFFF1 copy|r to your collection, up to |cFFFFFFFF4 copies|r.\n" ..
    "• The chance falls with each copy you own: 1st copy |cFF00FF00100%|r, 2nd |cFFFFFFFF25%|r, 3rd |cFFFFFFFF12%|r, 4th |cFFFFFFFF6%|r.\n" ..
    "• Kills count when you, your party or your raid (including pets) defeat the creature.\n" ..
    "• A tooltip icon shows if a creature has a card that can drop, the icon currently does not show in dungeons.\n" ..
    "• |cFFFFD200Dungeon bosses|r that aren't the final boss drop their card with the |cFFFFFFFFsame chance|r as normal creatures.\n" ..
    "• |cFFFFD200Final bosses|r (the last boss of each dungeon) |cFF00FF00always|r drop their card: 1 copy per defeat, up to 4. These come from the boss kills recorded on your character and update when you log in, reload, or leave an instance.\n\n" ..
    "|cFFFFD200In the Deckbuilder:|r only cards you have unlocked are shown; hover a card to see your number of copies. Spell unlocks follow the level of the character you are playing.\n\n"

local h2 = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
h2:SetText("Spheres of Mana")

local p2 = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
p2:SetWidth(540)
p2:SetJustifyH("LEFT")
p2:SetWordWrap(true)
p2.rawText = "Prayers produce mana when tapped {T}. Colored costs demand their respective sphere:\n\n" ..
    "  {W} |cFFFFD200Holy (White)|r: Life gain, shielding, vigilant guards, board wipes.\n" ..
    "  {U} |cFF66BBFFArcane (Blue)|r: Card draw, tempo manipulation, freezing {T}, bounce.\n" ..
    "  {B} |cFF9966FFShadow (Black)|r: Targeted removal, sacrifice, hand disruption, drain.\n" ..
    "  {R} |cFFFF4444Fire (Red)|r: Aggression, direct burn, haste, burst damage.\n" ..
    "  {G} |cFF44FF44Nature (Green)|r: Mana ramp, reach blockers, massive behemoths."

local h3 = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
h3:SetText("Turn Sequence")

local p3 = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
p3:SetWidth(540)
p3:SetJustifyH("LEFT")
p3:SetWordWrap(true)
p3.rawText = "|cFFFFD2001. Untap & Draw:|r All permanents untap (unless frozen), and you draw 1 card.\n" ..
    "|cFFFFD2002. Main Phase 1:|r Play up to 1 Prayer, tap Prayers for mana, summon creatures, cast sorceries, or equip gear.\n" ..
    "|cFFFFD2003. Combat Phase:|r\n" ..
    "   • |cFFFFFF00Declare Attackers:|r Click untapped creatures (without summoning sickness) to attack.\n" ..
    "   • |cFFFFFF00Declare Blockers:|r The defending player chooses untapped creatures to block incoming attackers.\n" ..
    "   • |cFFFFFF00Resolve Combat:|r Damage is dealt simultaneously. A creature dies when the damage it has taken this turn equals or exceeds its toughness. Excess damage is absorbed unless the attacker has Trample.\n" ..
    "|cFFFFD2004. Main Phase 2:|r Cast remaining spells and play your Prayer if unused.\n" ..
    "|cFFFFD2005. End Turn:|r Floating mana pool empties, temporary buffs expire, and all damage on creatures (both players') is removed."

local h4 = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
h4:SetText("Keywords & Mechanics")

local p4 = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
p4:SetWidth(540)
p4:SetJustifyH("LEFT")
p4:SetWordWrap(true)
p4.rawText = "• |cFFFFD200Haste:|r Can attack and tap the turn it enters the battlefield without summoning sickness.\n" ..
    "• |cFFFFD200Flying:|r Can only be blocked by creatures that also have Flying or Reach.\n" ..
    "• |cFFFFD200Reach:|r Can block Flying creatures while staying grounded.\n" ..
    "• |cFFFFD200First Strike:|r Deals combat damage before non-first strikers. If lethal, the foe dies before striking back.\n" ..
    "• |cFFFFD200Deathtouch:|r Any combat damage dealt by this creature is immediately lethal.\n" ..
    "• |cFFFFD200Lifelink:|r Damage dealt by this creature restores that much life to its controller.\n" ..
    "• |cFFFFD200Trample:|r Excess combat damage beyond the blocker's toughness carries over to the defending player.\n" ..
    "• |cFFFFD200Vigilance:|r Attacking does not cause the creature to tap.\n" ..
    "• |cFFFFD200Hexproof:|r Cannot be targeted by opponent spells or abilities."

-- Footer is pinned to the bottom of the window (outside the scroll area), like the title at the top
local footer = R:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
footer:SetPoint("BOTTOM", R, "BOTTOM", 0, 14)
footer:SetText("Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy")

-- Card Frame containers
local landFrames = {}
local unlockFrames = {}
local kwFrames = {}

-- =========================================================================
-- DYNAMIC LAYOUT & VISUAL REFRESH
-- =========================================================================
local function LayoutRules()
    p1:SetText(FormatTextWithSymbols(p1.rawText, 16))
    p2:SetText(FormatTextWithSymbols(p2.rawText, 16))
    p3:SetText(FormatTextWithSymbols(p3.rawText, 16))
    p4:SetText(FormatTextWithSymbols(p4.rawText, 16))
    pU:SetText(FormatTextWithSymbols(pU.rawText, 16))

    local y = -10

    -- Section 1: Overview
    h1:ClearAllPoints()
    h1:SetPoint("TOPLEFT", content, "TOPLEFT", 10, y)
    y = y - (h1:GetStringHeight() + 6)

    p1:ClearAllPoints()
    p1:SetPoint("TOPLEFT", content, "TOPLEFT", 10, y)
    y = y - (p1:GetStringHeight() + 18)

    -- Section 1b: Unlocking Cards
    hU:ClearAllPoints()
    hU:SetPoint("TOPLEFT", content, "TOPLEFT", 10, y)
    y = y - (hU:GetStringHeight() + 6)

    pU:ClearAllPoints()
    pU:SetPoint("TOPLEFT", content, "TOPLEFT", 10, y)
    y = y - (pU:GetStringHeight() + 12)

    -- Examples: a zone creature, a dungeon boss, a class spell
    local unlockCardIds = { "WES01", "BOSS01", "WAR01" }
    local unlockX = { 112, 238, 364 }
    for i, id in ipairs(unlockCardIds) do
        if not unlockFrames[i] then
            unlockFrames[i] = CreateExampleCard(content, id)
        else
            SetupRuleCard(unlockFrames[i], id)
        end
        unlockFrames[i]:ClearAllPoints()
        unlockFrames[i]:SetPoint("TOPLEFT", content, "TOPLEFT", unlockX[i], y)
    end
    y = y - (102 + 18)

    -- Section 2: Spheres of Mana
    h2:ClearAllPoints()
    h2:SetPoint("TOPLEFT", content, "TOPLEFT", 10, y)
    y = y - (h2:GetStringHeight() + 6)

    p2:ClearAllPoints()
    p2:SetPoint("TOPLEFT", content, "TOPLEFT", 10, y)
    y = y - (p2:GetStringHeight() + 12)

    -- Lazy instantiate Land Cards
    local landCardIds = { "W01", "U01", "B01", "R01", "G01" }
    local landX = { 12, 118, 224, 330, 436 }
    for i, id in ipairs(landCardIds) do
        if not landFrames[i] then
            landFrames[i] = CreateExampleCard(content, id)
        else
            SetupRuleCard(landFrames[i], id)
        end
        landFrames[i]:ClearAllPoints()
        landFrames[i]:SetPoint("TOPLEFT", content, "TOPLEFT", landX[i], y)
    end
    y = y - (102 + 18)

    -- Section 3: Turn Sequence
    h3:ClearAllPoints()
    h3:SetPoint("TOPLEFT", content, "TOPLEFT", 10, y)
    y = y - (h3:GetStringHeight() + 6)

    p3:ClearAllPoints()
    p3:SetPoint("TOPLEFT", content, "TOPLEFT", 10, y)
    y = y - (p3:GetStringHeight() + 18)

    -- Section 4: Keywords & Mechanics
    h4:ClearAllPoints()
    h4:SetPoint("TOPLEFT", content, "TOPLEFT", 10, y)
    y = y - (h4:GetStringHeight() + 6)

    p4:ClearAllPoints()
    p4:SetPoint("TOPLEFT", content, "TOPLEFT", 10, y)
    y = y - (p4:GetStringHeight() + 20)

    -- Lazy instantiate Keyword Cards
    local kwCardIds = { "WES04", "WES02", "DSK06", "WES05" }
    local kwX = { 40, 165, 290, 415 }
    for i, id in ipairs(kwCardIds) do
        if not kwFrames[i] then
            kwFrames[i] = CreateExampleCard(content, id)
        else
            SetupRuleCard(kwFrames[i], id)
        end
        kwFrames[i]:ClearAllPoints()
        kwFrames[i]:SetPoint("TOPLEFT", content, "TOPLEFT", kwX[i], y)
    end
    y = y - (102 + 16)

    content:SetHeight(math.abs(y))
end

R:SetScript("OnShow", function()
    LayoutRules()
end)