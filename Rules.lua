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
-- Same look as the Deckbuilder: dialog window, dark title strip, tooltip-bordered panel
R:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
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
        W = SYMBOL_PATH .. "W.png",
        U = SYMBOL_PATH .. "U.png",
        B = SYMBOL_PATH .. "B.png",
        R = SYMBOL_PATH .. "R.png",
        G = SYMBOL_PATH .. "G.png",
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

-- Header: darkened strip with a gold line, title on the left
local titleBar = R:CreateTexture(nil, "ARTWORK")
titleBar:SetPoint("TOPLEFT", 12, -12)
titleBar:SetPoint("TOPRIGHT", -12, -12)
titleBar:SetHeight(25)
titleBar:SetColorTexture(0, 0, 0, 0.35)

local titleLine = R:CreateTexture(nil, "ARTWORK")
titleLine:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 0)
titleLine:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
titleLine:SetHeight(1)
titleLine:SetColorTexture(1, 0.82, 0, 0.55)

local title = R:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -11)
title:SetText("Rules & Guide")

local subtitle = R:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
subtitle:SetPoint("LEFT", title, "RIGHT", 10, -1)
subtitle:SetText("Forever: CCG")

-- Close Button
local closeBtn = CreateFrame("Button", nil, R, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -2, -2)
closeBtn:SetScript("OnClick", function() R:Hide() end)

-- Panel holding the scrolling rules
local rulesPanel = CreateFrame("Frame", nil, R, backdropTemplate)
rulesPanel:SetPoint("TOPLEFT", 14, -46)
rulesPanel:SetPoint("BOTTOMRIGHT", -14, 34)
rulesPanel:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
rulesPanel:SetBackdropColor(0.04, 0.04, 0.04, 0.70)
rulesPanel:SetBackdropBorderColor(0.60, 0.56, 0.48, 1)

-- Scroll Frame & Content Container
local scrollFrame = CreateFrame("ScrollFrame", "TTS_RulesScrollFrame", rulesPanel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", rulesPanel, "TOPLEFT", 6, -8)
scrollFrame:SetPoint("BOTTOMRIGHT", rulesPanel, "BOTTOMRIGHT", -28, 8)

local content = CreateFrame("Frame", "TTS_RulesContent", scrollFrame)
local CONTENT_W = 550
content:SetWidth(CONTENT_W)
content:SetHeight(100)
scrollFrame:SetScrollChild(content)

-- =========================================================================
-- EXACT IN-GAME CARD BUILDER (Matching Board.lua & DeckBuilder.lua)
-- =========================================================================
local function SetupRuleCard(f, cardId)
    local card = TTS.Cards and TTS.Cards[cardId]
    if not card then return end

    f.cardId = cardId
    f.currentCard = card

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
            f.cost:SetText(FormatTextWithSymbols(card.cost, 16))
            f.cost:Show()
        else
            f.cost:Hide()
        end
    end

    -- 5. Power / Toughness
    if f.pt then TTS.ShowPrintedStats(f, card) end

    f:Show()

    -- 6. Rules text printed on the card, same as on the board
    if f.rules and TTS.UpdateCardRules then
        TTS.UpdateCardRules(f)
    end
end

-- =========================================================================
-- CARD PREVIEW
-- Full-size copy of the hovered example card, docked outside the left edge
-- of the window (same as the Deckbuilder and the board).
-- =========================================================================
local PREVIEW_W, PREVIEW_H = 150, 212
local PREVIEW_RULES = {
    fontMax = 11,
    fontMin = 8,
    offsetX = 3,   -- pixels right
    offsetY = 3,   -- pixels down
}

local previewCard

local function ShowRulesPreview(card)
    if not TTS.CreateCardFrame then return end
    if not previewCard then
        previewCard = TTS.CreateCardFrame(R, PREVIEW_W, PREVIEW_H)
        previewCard:SetFrameStrata("DIALOG")
        previewCard:SetFrameLevel((R:GetFrameLevel() or 10) + 40)
        previewCard:SetClampedToScreen(true)
        previewCard:EnableMouse(false)
        previewCard:SetScript("OnEnter", nil)
        previewCard:SetScript("OnLeave", nil)
    end
    local f = previewCard

    -- Card name and cost sit above the frame, so leave room for them
    f:ClearAllPoints()
    f:SetPoint("TOPRIGHT", R, "TOPLEFT", -12, -76)

    if TTS.SetupCardVisual then TTS.SetupCardVisual(f, card) end
    f.currentCard = card
    if TTS.ApplyFrameTexture then TTS.ApplyFrameTexture(f.border, card) end
    f.border:SetVertexColor(1, 1, 1, 1)
    f.title:SetText(card.name or "")

    if card.cost and card.cost ~= "" then
        f.cost:SetText(FormatTextWithSymbols(card.cost, 18))
        f.cost:Show()
    else
        f.cost:Hide()
    end

    TTS.ShowPrintedStats(f, card)

    f:Show()
    if TTS.UpdateCardRules then TTS.UpdateCardRules(f, PREVIEW_RULES) end
end

local function HideRulesPreview()
    if previewCard then previewCard:Hide() end
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
    -- The shared card frame hides its cost whenever the card is hidden (for the board's hand);
    -- rule example cards keep their cost, so drop that handler here
    f:SetScript("OnHide", nil)
    f:EnableMouse(true)
    f:RegisterForClicks("LeftButtonUp")

    -- Preview and tooltip (UI\Tooltips.lua) when hovering over rule examples
    f:SetScript("OnEnter", function(self)
        local card = TTS.Cards and TTS.Cards[self.cardId]
        if not card then return end
        ShowRulesPreview(card)
        if TTS.Tooltip then TTS.Tooltip:ShowCard(self, "ANCHOR_TOP", self.cardId) end
    end)
    f:SetScript("OnLeave", function(self)
        if TTS.Tooltip then TTS.Tooltip:Hide(self) end
        HideRulesPreview()
    end)

    SetupRuleCard(f, cardId)
    return f
end

-- =========================================================================
-- TEXT ELEMENTS
-- =========================================================================
-- Section heading with a thin gold divider underneath
local function MakeHeading(text)
    local h = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    h:SetText(text)
    h.rule = content:CreateTexture(nil, "ARTWORK")
    h.rule:SetHeight(1)
    h.rule:SetColorTexture(1, 0.82, 0, 0.30)
    return h
end

local h1 = MakeHeading("Overview & Deck Building")

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

local hU = MakeHeading("Unlocking Cards")

local pU = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
pU:SetWidth(540)
pU:SetJustifyH("LEFT")
pU:SetWordWrap(true)
pU.rawText = "You build your collection by playing World of Warcraft. Some cards are free, the rest are earned.\n\n" ..
    "|cFFFFD200Always available:|r Prayers.\n\n" ..
    "|cFFFFD200Class Spells unlock as you level.|r Each of the nine classes (Warrior, Paladin, Hunter, Rogue, Priest, Shaman, Mage, Warlock and Druid) has 10 spells. You unlock |cFFFFFFFF1 spell from every class|r at level 6 and again every |cFFFFFFFF6 levels|r (12, 18, 24 ... 60), so all 90 are available by level 60. Each set of new spells is spread across all five colours.\n\n" ..
    "|cFFFFD200Creature cards start locked.|r Every zone has 10 creatures to collect. Defeat the creature in the world for a |cFFFFD200chance|r to unlock its card:\n" ..
    "• Each card drop adds |cFFFFFFFF1 copy|r to your collection, up to |cFFFFFFFF4 copies|r.\n" ..
    "• The chance falls with each copy you own: 1st copy |cFF00FF00100%|r, 2nd |cFFFFFFFF25%|r, 3rd |cFFFFFFFF12%|r, 4th |cFFFFFFFF6%|r.\n" ..
    "• Kills count when you, your party or your raid (including pets) defeat the creature.\n" ..
    "• A tooltip icon shows if a creature has a card that can drop, the icon currently does not show in dungeons.\n" ..
    "• |cFFFFD200Dungeon bosses|r that aren't the final boss drop their card with the |cFFFFFFFFsame chance|r as normal creatures.\n" ..
    "• |cFFFFD200Final bosses|r (the last boss of each dungeon) |cFF00FF00always|r drop their card: 1 copy per defeat, up to 4. These come from the boss kills recorded on your character and update when you log in, reload, or leave an instance.\n\n" ..
    "|cFFFFD200In the Deckbuilder:|r only cards you have unlocked are shown; hover a card to see your number of copies. Spell unlocks follow the level of the character you are playing.\n\n"

local h2 = MakeHeading("Colours of Mana")

local p2 = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
p2:SetWidth(540)
p2:SetJustifyH("LEFT")
p2:SetWordWrap(true)
p2.rawText = "Prayers produce mana when tapped {T}. Colored costs demand their respective colour:\n\n" ..
    "  {W} |cFFFFD200Holy (White)|r: Life gain, shielding, vigilant guards, board wipes.\n" ..
    "  {U} |cFF66BBFFArcane (Blue)|r: Card draw, tempo manipulation, freezing {T}, bounce.\n" ..
    "  {B} |cFF9966FFShadow (Black)|r: Targeted removal, sacrifice, hand disruption, drain.\n" ..
    "  {R} |cFFFF4444Fire (Red)|r: Aggression, direct burn, haste, burst damage.\n" ..
    "  {G} |cFF44FF44Nature (Green)|r: Mana ramp, reach blockers, massive behemoths."

local h3 = MakeHeading("Turn Sequence")

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

local h4 = MakeHeading("Keywords & Mechanics")

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

local hS = MakeHeading("Solo Mode")

local pS = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
pS:SetWidth(540)
pS:SetJustifyH("LEFT")
pS:SetWordWrap(true)
pS.rawText = "Open |cFFFFD200Solo Encounters|r from the main window (or type |cFFFFFFFF/tragic solo|r) to see the world map, with a button on every zone and dungeon entrance. Hover a button for the encounter's details and reward; click it to play against the computer with your active deck. Beat an encounter to earn its |cFFFFD200reward card|r, which can't drop from world kills.\n\n" ..
    "|cFFFFD200Zone Gauntlet:|r one opponent per zone, playing that zone's 10 creatures. Elwynn Forest, Tirisfal Glades, Durotar, Mulgore and Teldrassil are open from the start; clearing a zone opens every zone it connects to on the map. The reward is a famous friend of that zone, and it strengthens the zone's own creatures.\n\n" ..
    "|cFFFFD200Dungeons:|r one opponent per dungeon, playing its creatures and its boss under one or two |cFFFF8040boss rules|r (shown beside the opponent's name; hover it for details). A dungeon opens once you clear the zone its entrance is in. Its reward is one of the dungeon's strongest denizens.\n\n" ..
    "|cFFFFD200Rewards:|r each win adds |cFFFFFFFF1 copy|r of the encounter's reward card, up to |cFFFFFFFF4 copies|r. Reward cards follow the normal deck rules and can be played anywhere, including against other players.\n\n" ..
    "|cFFFFD200Opponents:|r early encounters play a simple game; later zones and dungeons cast spells, use their abilities, block well and hold removal for your best creature. |cFFFFD200Practice vs Dummy|r is still there to try a deck out."

local h5 = MakeHeading("Challenging Players")

local p5 = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
p5:SetWidth(540)
p5:SetJustifyH("LEFT")
p5:SetWordWrap(true)
p5.rawText = "Both players must be on the |cFFFFD200same major & minor version|r of Forever: CCG. Only the first two numbers of the version need to match; the last number (the patch) can differ. For example, |cFFFFFFFF1.4.0|r can play |cFFFFFFFF1.4.7|r, but not |cFFFFFFFF1.5.0|r.\n\n" ..
    "|cFFFFD200Connection:|r Challenges and matches are sent over the |cFFFFFFFFFCCGTTSE|r chat channel, which the addon joins for you a few seconds after you log in. The channel is always tried first.\n\n" ..
    "|cFFFFD200Fallback:|r If your opponent doesn't respond within |cFFFFFFFF8 seconds|r, the challenge is retried on the next route in this order:\n" ..
    "   |cFFFFFFFFwhisper|r -> |cFFFFFFFFparty chat|r -> |cFFFFFFFFraid chat|r -> |cFFFFFFFFguild chat|r -> |cFFFFFFFFyell|r\n" ..
    "• Routes that can't reach your opponent are skipped (party and raid only if you're grouped with them, guild only if you're in one).\n" ..
    "• Yell only reaches players |cFFFFD200near you|r.\n" ..
    "• Once a route works, the rest of that match uses it.\n" ..
    "• If every route fails, the challenge is cancelled. Inviting your opponent to |cFFFFD200your party|r is the most reliable way to play.\n\n" ..
    "|cFFFFD200Accepting:|r Your opponent has |cFFFFFFFF60 seconds|r to accept a challenge."

-- Footer is pinned to the bottom of the window (outside the scroll area), like the title at the top
local footer = R:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
footer:SetPoint("BOTTOMRIGHT", R, "BOTTOMRIGHT", -20, 15)
footer:SetText("Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy")

-- Card Frame containers
local landFrames = {}
local unlockFrames = {}
local kwFrames = {}
local soloFrames = {}

-- =========================================================================
-- DYNAMIC LAYOUT & VISUAL REFRESH
-- =========================================================================
local CARD_W, CARD_H  = 72, 102
local CARD_GAP        = 40  -- space between example cards in a row
local CARD_HEADROOM   = 32  -- room for the name and cost shown above each card
local SECTION_GAP     = 22  -- space before the next heading

local function PlaceHeading(h, y)
    h:ClearAllPoints()
    h:SetPoint("TOPLEFT", content, "TOPLEFT", 10, y)
    y = y - (h:GetStringHeight() + 4)
    h.rule:ClearAllPoints()
    h.rule:SetPoint("TOPLEFT", content, "TOPLEFT", 10, y)
    h.rule:SetPoint("TOPRIGHT", content, "TOPRIGHT", -10, y)
    return y - 8
end

local function PlaceParagraph(p, y)
    p:ClearAllPoints()
    p:SetPoint("TOPLEFT", content, "TOPLEFT", 10, y)
    return y - p:GetStringHeight()
end

-- A row of example cards, centred across the content width
local function PlaceCardRow(frames, ids, y)
    y = y - CARD_HEADROOM
    local n = #ids
    local x = (CONTENT_W - (n * CARD_W + (n - 1) * CARD_GAP)) / 2
    for i, id in ipairs(ids) do
        if not frames[i] then
            frames[i] = CreateExampleCard(content, id)
        else
            SetupRuleCard(frames[i], id)
        end
        frames[i]:ClearAllPoints()
        frames[i]:SetPoint("TOPLEFT", content, "TOPLEFT", x + (i - 1) * (CARD_W + CARD_GAP), y)
    end
    return y - CARD_H
end

local function LayoutRules()
    p1:SetText(FormatTextWithSymbols(p1.rawText, 16))
    p2:SetText(FormatTextWithSymbols(p2.rawText, 16))
    p3:SetText(FormatTextWithSymbols(p3.rawText, 16))
    p4:SetText(FormatTextWithSymbols(p4.rawText, 16))
    pU:SetText(FormatTextWithSymbols(pU.rawText, 16))
    p5:SetText(FormatTextWithSymbols(p5.rawText, 16))
    pS:SetText(FormatTextWithSymbols(pS.rawText, 16))

    local y = -10

    -- Section 1: Overview
    y = PlaceHeading(h1, y)
    y = PlaceParagraph(p1, y) - SECTION_GAP

    -- Section 1b: Unlocking Cards, with a zone creature, a dungeon boss and a class spell
    y = PlaceHeading(hU, y)
    y = PlaceParagraph(pU, y)
    y = PlaceCardRow(unlockFrames, { "WES01", "BOSS01", "WAR01" }, y) - SECTION_GAP

    -- Section 2: Colours of Mana, with one Prayer of each colour
    y = PlaceHeading(h2, y)
    y = PlaceParagraph(p2, y)
    y = PlaceCardRow(landFrames, { "W01", "U01", "B01", "R01", "G01" }, y) - SECTION_GAP

    -- Section 3: Turn Sequence
    y = PlaceHeading(h3, y)
    y = PlaceParagraph(p3, y) - SECTION_GAP

    -- Section 4: Keywords & Mechanics, with keyword creatures
    y = PlaceHeading(h4, y)
    y = PlaceParagraph(p4, y)
    y = PlaceCardRow(kwFrames, { "WES04", "WES02", "DSK06", "WES05" }, y) - SECTION_GAP

    -- Section 5: Solo Mode, with a zone reward and a dungeon reward
    y = PlaceHeading(hS, y)
    y = PlaceParagraph(pS, y)
    y = PlaceCardRow(soloFrames, { "ELW11", "DMS12" }, y) - SECTION_GAP

    -- Section 6: Challenging Players
    y = PlaceHeading(h5, y)
    y = PlaceParagraph(p5, y) - 16

    content:SetHeight(math.abs(y))
end

R:SetScript("OnShow", function()
    LayoutRules()
end)