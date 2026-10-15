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
-- SOLO ENCOUNTER MAP
-- The continent maps with a button on every zone and dungeon entrance. Hovering a
-- button shows the encounter and its reward card; clicking it starts the encounter.
-- Lines join connected zones: clearing a zone opens everything connected to it.
-- Same look as the main window and the Deckbuilder.
-- =========================================================================
local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil

local GOLD   = "|cFFFFD200"
local GREY   = "|cFF8A8A8A"
local GREEN  = "|cFF33DD33"
local RED    = "|cFFFF4444"
local ORANGE = "|cFFFF8040"

-- AI difficulty shown as solo.ai.<profile>
local AI_LABEL = setmetatable({}, { __index = function(_, ai) return Loc:Data("solo.ai." .. tostring(ai), ai) end })

-- The continent maps: 12 tiles of 256 px (4 x 3) holding one 1002 x 668 map
local CONTINENTS = {
    { id = "KAL", name = "solo.continent.KAL", folder = "Kalimdor" },
    { id = "EK",  name = "solo.continent.EK",  folder = "Azeroth" },
}
local MAP_W, MAP_H, MAP_TILE = 1002, 668, 256
local WIN_W, WIN_H = MAP_W + 34, MAP_H + 128

local ZONE_SIZE, DUNGEON_SIZE = 26, 24
local ZONE_ICON    = "Interface\\Icons\\INV_Misc_Map_01"
local DUNGEON_ICON = "Interface\\Icons\\INV_Misc_Bone_HumanSkull_01"
local CHECK_ICON   = "Interface\\RaidFrame\\ReadyCheck-Ready"
local GLOW_TEX     = "Interface\\Buttons\\UI-ActionButton-Border"

local TT = TTS.Tooltip

local S = CreateFrame("Frame", "TTS_SoloSelectFrame", UIParent, backdropTemplate)
TTS.SoloSelectFrame = S
S:SetSize(WIN_W, WIN_H)
S:SetPoint("CENTER")
S:SetClampedToScreen(true)
S:SetFrameStrata("DIALOG")
S:SetToplevel(true)
S:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
S:EnableMouse(true)
S:SetMovable(true)
S:RegisterForDrag("LeftButton")
S:SetScript("OnDragStart", S.StartMoving)
S:SetScript("OnDragStop", S.StopMovingOrSizing)
S:Hide()
tinsert(UISpecialFrames, "TTS_SoloSelectFrame")

local titleBar = S:CreateTexture(nil, "ARTWORK")
titleBar:SetPoint("TOPLEFT", 12, -12)
titleBar:SetPoint("TOPRIGHT", -12, -12)
titleBar:SetHeight(25)
titleBar:SetColorTexture(0, 0, 0, 0.35)

local titleLine = S:CreateTexture(nil, "ARTWORK")
titleLine:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 0)
titleLine:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
titleLine:SetHeight(1)
titleLine:SetColorTexture(1, 0.82, 0, 0.55)

local title = S:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -11)
Loc:Bind(title, "main.soloEncounters")

local closeBtn = CreateFrame("Button", nil, S, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -2, -2)

local footer = S:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
footer:SetPoint("BOTTOMRIGHT", S, "BOTTOMRIGHT", -20, 14)
footer:SetText("Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy")

-- Red panel button with the Deckbuilder's small fonts
local function CreatePanelButton(parent, w, h, text)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(w, h)
    b:SetNormalFontObject("GameFontNormalSmall")
    b:SetHighlightFontObject("GameFontHighlightSmall")
    b:SetDisabledFontObject("GameFontDisableSmall")
    Loc:Bind(b, text)
    return b
end

-- =========================================================================
-- STATUS
-- =========================================================================
-- Why a game can't start right now (nil = it can)
local function StartBlocker(enc)
    local E = TTS.Engine
    if not enc then return L("solo.chooseEncounter") end
    if E and E.inMatch then return L("solo.inProgress") end
    if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() then return L("solo.closeDeckbuilder") end
    if TTS.WaitingRoom and TTS.WaitingRoom.isQueued then return L("solo.leaveQueue") end
    if E and not E:ValidateDeck() then return L("solo.deckSize") end
    local unlocked, reason = TTS:IsEncounterUnlocked(enc)
    if not unlocked then return reason end
    return nil
end

-- "locked", "open" or "cleared"
local function EncounterState(enc)
    if not TTS:IsEncounterUnlocked(enc) then return "locked" end
    if TTS:GetEncounterWins(enc.id) > 0 then return "cleared" end
    return "open"
end

-- =========================================================================
-- TOP BAR: continent tabs, active deck, hint
-- =========================================================================
local tabs = {}
for i, cont in ipairs(CONTINENTS) do
    local b = CreatePanelButton(S, 140, 22, cont.name)
    b:SetPoint("TOPLEFT", S, "TOPLEFT", 16 + (i - 1) * 144, -46)
    tabs[cont.id] = b
end

-- =========================================================================
-- DECK SELECTOR (top right): picks the active deck, like the Deckbuilder's deck tabs
-- =========================================================================
local DECK_PICKER_W, DECK_ROW_H = 240, 20

local function DeckCount(deck)
    local count = 0
    for _, n in pairs(deck and deck.cards or {}) do count = count + n end
    return count
end

-- "Name (40)" with the count green when the deck is legal, red when it isn't
local function DeckLabel(deck)
    local count = DeckCount(deck)
    local ok = count >= 40 and count <= 50
    return string.format("%s%s|r (%s%d|r)", GOLD, deck and deck.name or L("solo.noDeck"), ok and GREEN or RED, count)
end

local function Skin(f, bg, border, edge)
    f:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = edge or 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    f:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
    f:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
end

local deckPicker = CreateFrame("Button", nil, S, backdropTemplate)
deckPicker:SetSize(DECK_PICKER_W, 22)
deckPicker:SetPoint("TOPRIGHT", S, "TOPRIGHT", -16, -46)
Skin(deckPicker, { 0.10, 0.08, 0.06, 0.95 }, { 0.55, 0.50, 0.40, 1 })

local deckPickerLabel = deckPicker:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
deckPickerLabel:SetPoint("RIGHT", deckPicker, "LEFT", -6, 0)
Loc:Bind(deckPickerLabel, "solo.deck")

deckPicker.text = deckPicker:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
deckPicker.text:SetPoint("LEFT", 8, 0)
deckPicker.text:SetPoint("RIGHT", -22, 0)
deckPicker.text:SetJustifyH("LEFT")
deckPicker.text:SetWordWrap(false)

local arrow = deckPicker:CreateTexture(nil, "OVERLAY")
arrow:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
arrow:SetSize(14, 14)
arrow:SetPoint("RIGHT", -5, 0)
arrow:SetRotation(-math.pi / 2)

local pickerHl = deckPicker:CreateTexture(nil, "HIGHLIGHT")
pickerHl:SetPoint("TOPLEFT", 3, -3)
pickerHl:SetPoint("BOTTOMRIGHT", -3, 3)
pickerHl:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
pickerHl:SetBlendMode("ADD")

-- The list of decks under the selector
local deckMenu = CreateFrame("Frame", nil, deckPicker, backdropTemplate)
deckMenu:SetPoint("TOPRIGHT", deckPicker, "BOTTOMRIGHT", 0, -2)
deckMenu:SetFrameStrata("FULLSCREEN_DIALOG")
Skin(deckMenu, { 0.02, 0.02, 0.02, 0.95 }, { 0.85, 0.75, 0.45, 1 })
deckMenu:Hide()

local deckRows = {}

local function PickDeck(i)
    if TTS.EnsureDeckSlots then TTS:EnsureDeckSlots() end
    if TTS_SavedDecks and TTS_SavedDecks[i] then
        TTS_ActiveDeckIndex = i
        DEFAULT_CHAT_FRAME:AddMessage(L("db.loadedDeck", TTS_SavedDecks[i].name))
    end
    deckMenu:Hide()
    S:Refresh()
end

local function BuildDeckMenu()
    if TTS.EnsureDeckSlots then TTS:EnsureDeckSlots() end
    local slots = TTS.MAX_DECK_SLOTS or #(TTS_SavedDecks or {})
    for i = 1, slots do
        local row = deckRows[i]
        if not row then
            row = CreateFrame("Button", nil, deckMenu)
            row:SetSize(DECK_PICKER_W - 8, DECK_ROW_H)
            row:SetPoint("TOPLEFT", deckMenu, "TOPLEFT", 4, -4 - (i - 1) * DECK_ROW_H)
            row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.text:SetPoint("LEFT", 6, 0)
            row.text:SetPoint("RIGHT", -6, 0)
            row.text:SetJustifyH("LEFT")
            row.text:SetWordWrap(false)
            row.sel = row:CreateTexture(nil, "BACKGROUND")
            row.sel:SetAllPoints(row)
            row.sel:SetColorTexture(1, 0.82, 0, 0.18)
            local hl = row:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints(row)
            hl:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
            hl:SetBlendMode("ADD")
            row:SetScript("OnClick", function(self) PickDeck(self.index) end)
            deckRows[i] = row
        end
        row.index = i
        row.text:SetText(DeckLabel(TTS_SavedDecks and TTS_SavedDecks[i]))
        if i == TTS_ActiveDeckIndex then row.sel:Show() else row.sel:Hide() end
        row:Show()
    end
    for i = slots + 1, #deckRows do deckRows[i]:Hide() end
    deckMenu:SetSize(DECK_PICKER_W, slots * DECK_ROW_H + 8)
end

deckPicker:SetScript("OnClick", function()
    if deckMenu:IsShown() then
        deckMenu:Hide()
    else
        BuildDeckMenu()
        deckMenu:Show()
    end
end)
deckPicker:SetScript("OnEnter", function(self)
    if TT then TT:ShowText(self, "ANCHOR_BOTTOM", L("solo.activeDeck"), L("solo.activeDeck.desc")) end
end)
deckPicker:SetScript("OnLeave", function(self) if TT then TT:Hide(self) end end)

local hint = S:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
hint:SetPoint("BOTTOMLEFT", S, "BOTTOMLEFT", 20, 16)
hint:SetJustifyH("LEFT")
local HINT_TEXT = "solo.hint"

-- =========================================================================
-- MAP
-- =========================================================================
local map = CreateFrame("Frame", nil, S, backdropTemplate)
map:SetSize(MAP_W + 8, MAP_H + 8)
map:SetPoint("TOPLEFT", S, "TOPLEFT", 13, -74)
map:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
map:SetBackdropColor(0, 0, 0, 1)
map:SetBackdropBorderColor(0.60, 0.56, 0.48, 1)

local canvas = CreateFrame("Frame", nil, map)
canvas:SetPoint("TOPLEFT", map, "TOPLEFT", 4, -4)
canvas:SetSize(MAP_W, MAP_H)

-- Map tiles; the last column and row are cut to the map's 1002 x 668
local tiles = {}
for row = 0, 2 do
    for col = 0, 3 do
        local t = canvas:CreateTexture(nil, "BACKGROUND")
        local w = math.min(MAP_TILE, MAP_W - col * MAP_TILE)
        local h = math.min(MAP_TILE, MAP_H - row * MAP_TILE)
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", col * MAP_TILE, -row * MAP_TILE)
        t:SetSize(w, h)
        t:SetTexCoord(0, w / MAP_TILE, 0, h / MAP_TILE)
        tiles[row * 4 + col + 1] = t
    end
end

-- Slightly darkened so the buttons and names stand out
local shade = canvas:CreateTexture(nil, "BORDER")
shade:SetAllPoints(canvas)
shade:SetColorTexture(0, 0, 0, 0.25)

-- Lines and buttons sit on their own layers above the map
local lineLayer = CreateFrame("Frame", nil, canvas)
lineLayer:SetAllPoints(canvas)
local buttonLayer = CreateFrame("Frame", nil, canvas)
buttonLayer:SetAllPoints(canvas)
buttonLayer:SetFrameLevel(lineLayer:GetFrameLevel() + 5)

-- =========================================================================
-- BUTTON PLACEMENT
-- Zones sit at their centre and dungeons at their entrance. Dungeon buttons that would
-- cover another button are nudged clear of it.
-- =========================================================================
local placed = {}   -- [continent] = { [id] = { x, y } } in map pixels

-- Hand-placed zones (map pixels) where the zone centres sit too close for their names
local ZONE_PLACEMENT = {
    DUN = { 470, 362 }, LOC = { 562, 350 }, SEA = { 466, 398 }, BAD = { 574, 404 },
    BUR = { 510, 456 }, ELW = { 446, 472 }, RED = { 542, 484 }, WES = { 402, 512 },
    DSK = { 472, 522 }, SIL = { 404, 192 },
}

-- Each button takes up its square, and a zone also takes up the strip of its name below it.
-- Anything that touches is pushed apart along the shorter way out: a dungeon moves out of a
-- zone's way, two zones or two dungeons share the move. Zones stay within ZONE_DRIFT of
-- their place and dungeons within DUNGEON_DRIFT of their entrance.
local LABEL_CHAR_W, LABEL_H = 5.6, 11
local LAYOUT_GAP = 3
local ZONE_DRIFT, DUNGEON_DRIFT = 24, 50

local function Boxes(it)
    local half = it.size / 2
    local list = { { it.x - half, it.y - half, it.x + half, it.y + half } }
    if it.labelW then
        local top = it.y + half + 1
        table.insert(list, { it.x - it.labelW / 2, top, it.x + it.labelW / 2, top + LABEL_H })
    end
    return list
end

local function Clamp(it)
    local dx, dy = it.x - it.ax, it.y - it.ay
    local d = math.sqrt(dx * dx + dy * dy)
    local maxD = it.isDungeon and DUNGEON_DRIFT or ZONE_DRIFT
    if d > maxD then
        it.x, it.y = it.ax + dx / d * maxD, it.ay + dy / d * maxD
    end
    local half = it.size / 2
    it.x = math.max(half + 2, math.min(MAP_W - half - 2, it.x))
    it.y = math.max(half + 2, math.min(MAP_H - half - 2 - (it.labelW and LABEL_H or 0), it.y))
end

local function Layout(contId)
    if placed[contId] then return placed[contId] end
    local items = {}
    for id, p in pairs(TTS.SoloMapPositions or {}) do
        local enc = TTS.SoloEncounters[id]
        if enc and p[1] == contId then
            local fixed = ZONE_PLACEMENT[id]
            local x, y = fixed and fixed[1] or p[2] * MAP_W, fixed and fixed[2] or p[3] * MAP_H
            local isDungeon = enc.kind == "dungeon"
            table.insert(items, {
                id = id, isDungeon = isDungeon, x = x, y = y, ax = x, ay = y,
                size = isDungeon and DUNGEON_SIZE or ZONE_SIZE,
                labelW = (not isDungeon) and #TTS:EncounterName(enc) * LABEL_CHAR_W or nil,
            })
        end
    end
    table.sort(items, function(a, b) return a.id < b.id end)

    for _ = 1, 200 do
        local moved = false
        for i = 1, #items do
            for j = i + 1, #items do
                local a, b = items[i], items[j]
                for _, ba in ipairs(Boxes(a)) do
                    for _, bb in ipairs(Boxes(b)) do
                        local ox = math.min(ba[3], bb[3]) - math.max(ba[1], bb[1]) + LAYOUT_GAP
                        local oy = math.min(ba[4], bb[4]) - math.max(ba[2], bb[2]) + LAYOUT_GAP
                        if ox > LAYOUT_GAP and oy > LAYOUT_GAP then
                            -- Which way b goes relative to a, along the shorter way out
                            local mx, my = 0, 0
                            if ox < oy then
                                mx = ((bb[1] + bb[3]) >= (ba[1] + ba[3])) and ox or -ox
                            else
                                my = ((bb[2] + bb[4]) >= (ba[2] + ba[4])) and oy or -oy
                            end
                            local shareA, shareB = 0.5, 0.5
                            if a.isDungeon ~= b.isDungeon then
                                shareA, shareB = a.isDungeon and 1 or 0, b.isDungeon and 1 or 0
                            end
                            a.x, a.y = a.x - mx * shareA, a.y - my * shareA
                            b.x, b.y = b.x + mx * shareB, b.y + my * shareB
                            Clamp(a)
                            Clamp(b)
                            moved = true
                        end
                    end
                end
            end
        end
        if not moved then break end
    end

    local pos = {}
    for _, it in ipairs(items) do pos[it.id] = { it.x, it.y } end
    placed[contId] = pos
    return pos
end
TTS.SoloMapLayout = Layout

-- =========================================================================
-- REWARD PREVIEW (docked to the left of the window, like the Deckbuilder's)
-- =========================================================================
local preview
local function ShowRewardPreview(enc)
    local card = enc and enc.reward and TTS.Cards[enc.reward]
    if not card or not TTS.CreateCardFrame or not TTS.PaintPreviewCard then
        if preview then preview:Hide() end
        return
    end
    if not preview then
        preview = TTS.CreateCardFrame(S, TTS.PREVIEW_W, TTS.PREVIEW_H)
        preview:SetFrameStrata("DIALOG")
        preview:SetFrameLevel((S:GetFrameLevel() or 10) + 40)
        preview:SetClampedToScreen(true)
        preview:EnableMouse(false)
        preview:SetScript("OnEnter", nil)
        preview:SetScript("OnLeave", nil)
        preview:ClearAllPoints()
        preview:SetPoint("TOPRIGHT", S, "TOPLEFT", -12, -76)
    end
    TTS.PaintPreviewCard(preview, card)
    -- Not yet earned: shown dimmed
    local owned = TTS:GetOwnedCopies(card) or 0
    local tone = owned > 0 and 1 or 0.45
    preview.art:SetVertexColor(tone, tone, tone)
    if preview.model and preview.model.SetAlpha then preview.model:SetAlpha(owned > 0 and 1 or 0.6) end
end

local function HideRewardPreview()
    if preview then preview:Hide() end
end

-- =========================================================================
-- ENCOUNTER BREAKDOWN (the button's tooltip)
-- =========================================================================
local function AddBreakdown(tip, enc)
    local state = EncounterState(enc)
    tip:AddLine(TTS:EncounterName(enc), 1, 0.82, 0)
    tip:AddLine(enc.kind == "dungeon" and L("solo.dungeon") or L("solo.zoneGauntlet"), 0.7, 0.7, 0.7)
    tip:AddLine(" ")
    tip:AddLine(L("solo.opponent", GOLD .. TTS:EncounterOpponent(enc) .. "|r"), 1, 1, 1)
    tip:AddLine(L("solo.lifeAi", GOLD .. (enc.life or 20) .. "|r", GOLD .. AI_LABEL[enc.ai] .. "|r"), 1, 1, 1)
    if enc.kind == "dungeon" then
        local names = {}
        for _, b in ipairs(enc.bosses or {}) do table.insert(names, TTS.Cards[b] and TTS:CardName(b) or b) end
        tip:AddLine(L("solo.bosses", table.concat(names, ", ")), 1, 1, 1, true)
        for _, rule in ipairs(TTS:GetEncounterRuleLines(enc)) do
            tip:AddLine(string.format("%s%s:|r %s", ORANGE, rule.name, rule.text), 1, 1, 1, true)
        end
    else
        tip:AddLine(L("solo.deckOf", Loc:Term("zone", enc.zone)), 1, 1, 1, true)
    end

    local card = enc.reward and TTS.Cards[enc.reward]
    if card then
        local owned = TTS:GetOwnedCopies(card) or 0
        tip:AddLine(" ")
        tip:AddLine(L("solo.reward", GOLD .. TTS:CardName(card) .. "|r", owned), 1, 1, 1)
        tip:AddLine(L("solo.onePerWin"), 0.7, 0.7, 0.7)
    end

    local wins = TTS:GetEncounterWins(enc.id)
    if wins > 0 then tip:AddLine(L(wins == 1 and "solo.clearedTimes.one" or "solo.clearedTimes.other", wins), 0.2, 0.87, 0.2) end

    tip:AddLine(" ")
    local blocker = StartBlocker(enc)
    if state == "locked" then
        tip:AddLine(L("solo.locked", select(2, TTS:IsEncounterUnlocked(enc)) or ""), 1, 0.27, 0.27, true)
    elseif blocker then
        tip:AddLine(blocker, 1, 0.27, 0.27, true)
    else
        tip:AddLine(L("solo.clickToStart"), 0.2, 1, 0.2)
    end
end

-- =========================================================================
-- BUTTONS
-- =========================================================================
local buttons = {}   -- [id] = button

local function CreateEncounterButton(enc)
    local isDungeon = enc.kind == "dungeon"
    local size = isDungeon and DUNGEON_SIZE or ZONE_SIZE
    local b = CreateFrame("Button", nil, buttonLayer)
    b:SetSize(size, size)
    b.enc = enc

    -- Gold glow behind encounters that are open but not yet cleared
    b.glow = b:CreateTexture(nil, "BACKGROUND")
    b.glow:SetTexture(GLOW_TEX)
    b.glow:SetBlendMode("ADD")
    b.glow:SetPoint("CENTER")
    b.glow:SetSize(size * 1.9, size * 1.9)

    b.bg = b:CreateTexture(nil, "BORDER")
    b.bg:SetAllPoints(b)
    b.bg:SetColorTexture(0, 0, 0, 0.85)

    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetPoint("TOPLEFT", 2, -2)
    b.icon:SetPoint("BOTTOMRIGHT", -2, 2)
    b.icon:SetTexture(isDungeon and DUNGEON_ICON or ZONE_ICON)
    b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    b.check = b:CreateTexture(nil, "OVERLAY")
    b.check:SetTexture(CHECK_ICON)
    b.check:SetSize(14, 14)
    b.check:SetPoint("BOTTOMRIGHT", 4, -4)

    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(b)
    hl:SetColorTexture(1, 1, 1, 0.25)

    -- Zone names are always shown; dungeon names appear on hover
    if not isDungeon then
        b.label = buttonLayer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        b.label:SetPoint("TOP", b, "BOTTOM", 0, -1)
        b.label:SetText(TTS:EncounterName(enc))
        local font, fsize = b.label:GetFont()
        if font then b.label:SetFont(font, fsize or 10, "OUTLINE") end
    end

    b:SetScript("OnEnter", function(self)
        ShowRewardPreview(self.enc)
        if TT then
            TT:Show(self, "ANCHOR_RIGHT", { main = function(tip) AddBreakdown(tip, self.enc) end })
        end
    end)
    b:SetScript("OnLeave", function(self)
        if TT then TT:Hide(self) end
        HideRewardPreview()
    end)
    b:SetScript("OnClick", function(self)
        local blocker = StartBlocker(self.enc)
        if blocker then
            hint:SetText(RED .. TTS:EncounterName(self.enc) .. ": " .. blocker .. "|r")
            return
        end
        S:Hide()
        TTS.Engine:StartMatch(TTS:EncounterOpponent(self.enc), true, true, self.enc)
    end)
    return b
end

local function PaintButton(b)
    local state = EncounterState(b.enc)
    local locked = state == "locked"
    if b.icon.SetDesaturated then b.icon:SetDesaturated(locked) end
    b.icon:SetVertexColor(locked and 0.55 or 1, locked and 0.55 or 1, locked and 0.55 or 1)
    b:SetAlpha(locked and 0.75 or 1)
    if state == "open" then b.glow:Show() else b.glow:Hide() end
    if state == "cleared" then b.check:Show() else b.check:Hide() end
    if b.label then
        if locked then b.label:SetTextColor(0.6, 0.6, 0.6)
        elseif state == "cleared" then b.label:SetTextColor(0.6, 1, 0.6)
        else b.label:SetTextColor(1, 0.82, 0) end
    end
end

-- =========================================================================
-- CONNECTION LINES
-- =========================================================================
local lines = {}

local function DrawLine(i, x1, y1, x2, y2, r, g, bl, a)
    if not lineLayer.CreateLine then return end
    local l = lines[i]
    if not l then
        l = lineLayer:CreateLine(nil, "ARTWORK")
        l:SetThickness(2)
        lines[i] = l
    end
    l:SetStartPoint("TOPLEFT", lineLayer, x1, -y1)
    l:SetEndPoint("TOPLEFT", lineLayer, x2, -y2)
    l:SetColorTexture(r, g, bl, a)
    l:Show()
end

local function DrawConnections(contId, pos)
    local n = 0
    local function Link(a, b, dungeonLink)
        local pa, pb = pos[a], pos[b]
        if not (pa and pb) then return end
        local ca, cb = TTS:GetEncounterWins(a) > 0, TTS:GetEncounterWins(b) > 0
        n = n + 1
        if ca or cb then
            DrawLine(n, pa[1], pa[2], pb[1], pb[2], 1, 0.82, 0, dungeonLink and 0.45 or 0.75)
        else
            DrawLine(n, pa[1], pa[2], pb[1], pb[2], 0.75, 0.75, 0.75, dungeonLink and 0.25 or 0.4)
        end
    end
    for _, link in ipairs(TTS.SoloConnections or {}) do Link(link[1], link[2], false) end
    for dungeon, zone in pairs(TTS.SoloDungeonZone or {}) do Link(zone, dungeon, true) end
    for i = n + 1, #lines do lines[i]:Hide() end
end

-- =========================================================================
-- SHOWING A CONTINENT
-- =========================================================================
local currentContinent = "EK"

local function ShowContinent(contId)
    currentContinent = contId
    local cont
    for _, c in ipairs(CONTINENTS) do if c.id == contId then cont = c end end
    for i, t in ipairs(tiles) do
        t:SetTexture(string.format("Interface\\WorldMap\\%s\\%s%d", cont.folder, cont.folder, i))
    end
    for id, b in pairs(tabs) do
        if id == contId then b:Disable() else b:Enable() end
    end

    local pos = Layout(contId)
    for id, enc in pairs(TTS.SoloEncounters) do
        local p = pos[id]
        if p then
            local b = buttons[id] or CreateEncounterButton(enc)
            buttons[id] = b
            b:ClearAllPoints()
            b:SetPoint("CENTER", buttonLayer, "TOPLEFT", p[1], -p[2])
            b:Show()
            if b.label then b.label:Show() end
            PaintButton(b)
        elseif buttons[id] then
            buttons[id]:Hide()
            if buttons[id].label then buttons[id].label:Hide() end
        end
    end
    DrawConnections(contId, pos)
end

for id, b in pairs(tabs) do
    b:SetScript("OnClick", function() ShowContinent(id) end)
end

-- Refreshes everything (called when progress or the deck changes)
function S:Refresh()
    if not self:IsShown() then return end
    if TTS.EnsureDeckSlots then TTS:EnsureDeckSlots() end
    deckPicker.text:SetText(DeckLabel(TTS_SavedDecks and TTS_SavedDecks[TTS_ActiveDeckIndex]))
    if deckMenu:IsShown() then BuildDeckMenu() end
    hint:SetText(L(HINT_TEXT))
    ShowContinent(currentContinent)
end

S:SetScript("OnShow", function(self)
    if TTS.Engine and TTS.Engine.inMatch then
        self:Hide()
        return
    end
    self:Refresh()
end)

S:SetScript("OnHide", function()
    if TT then TT:Hide() end
    HideRewardPreview()
    deckMenu:Hide()
end)

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    if TTS.Sound and TTS.Sound.HookButtons then TTS.Sound:HookButtons(S) end
    self:UnregisterAllEvents()
end)
