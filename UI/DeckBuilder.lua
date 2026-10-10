TTS = TTS or {}

-- =========================================================================
-- DECK SLOTS (up to 3 saved decks, switchable from the Deckbuilder)
-- =========================================================================
TTS.MAX_DECK_SLOTS = 3

local function DefaultDeckName(i)
    return (i == 1) and "Default Deck" or ("Deck " .. i)
end

function TTS:EnsureDeckSlots()
    TTS_SavedDecks = TTS_SavedDecks or {}
    for i = 1, TTS.MAX_DECK_SLOTS do
        local deck = TTS_SavedDecks[i]
        if type(deck) ~= "table" then
            TTS_SavedDecks[i] = { name = DefaultDeckName(i), cards = {} }
        else
            deck.cards = deck.cards or {}
            deck.name = deck.name or DefaultDeckName(i)
        end
    end
    TTS_ActiveDeckIndex = tonumber(TTS_ActiveDeckIndex) or 1
    if TTS_ActiveDeckIndex < 1 or TTS_ActiveDeckIndex > TTS.MAX_DECK_SLOTS then
        TTS_ActiveDeckIndex = 1
    end
end

local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local D = CreateFrame("Frame", "TTS_DeckBuilderFrame", UIParent, backdropTemplate)
TTS.DeckBuilderFrame = D
D:SetSize(720, 611)
D:SetPoint("CENTER")
D:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
D:EnableMouse(true)
D:SetMovable(true)
D:RegisterForDrag("LeftButton")
D:SetScript("OnDragStart", D.StartMoving)
D:SetScript("OnDragStop", D.StopMovingOrSizing)
D:Hide()
local footer = D:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
footer:SetPoint("BOTTOM", D, "BOTTOM", 0, 12)
footer:SetText("Tragic: The Saddening Engine")

local title = D:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", 0, -16)
title:SetText("Deckbuilder")

local close = CreateFrame("Button", nil, D, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -5, -5)

local onlyUnlocked = false
local colorOn = { W = true, U = true, B = true, R = true, G = true }
local typeOn  = { Prayer = true, Creature = true, Spell = true }
local classFilter = nil      -- nil = all classes; otherwise only spells of this class are shown
local zoneFilter = nil       -- nil = all zones; otherwise only creatures from this zone are shown
local factionFilter = nil    -- nil = all factions; otherwise only creatures of this faction are shown
local creatureTypeFilter = nil -- nil = all creature types; otherwise only creatures of this type are shown
local sortMode = "COST"      -- "COST" or "ZONE"
local cardPoolKeys = {}
local deckListKeys = {}

-- =========================================================================
-- UNLOCK HELPERS
-- Cards flagged isBoss are unlocked by killing the creature; kills = copies allowed (max 4).
-- =========================================================================
local function GetKillCount(cardId, card)
    if not (card and card.isBoss) then return 0 end
    local rawKills = TTS_KilledBosses and TTS_KilledBosses[cardId]
    if rawKills == true then
        return 4
    elseif type(rawKills) == "number" then
        return rawKills
    end
    return 0
end

local function IsCardUnlocked(cardId, card)
    return (not card.isBoss) or GetKillCount(cardId, card) > 0
end

-- Land = Prayer, Creature = Creature, everything else (Sorcery, ...) = Spell
local function GetTypeGroup(card)
    if card.type == "Land" then return "Prayer" end
    if card.type == "Creature" then return "Creature" end
    return "Spell"
end

local function CardPassesFilters(cardId, card)
    if not typeOn[GetTypeGroup(card)] then return false end
    if card.color and colorOn[card.color] == false then return false end
    if onlyUnlocked and not IsCardUnlocked(cardId, card) then return false end
    if classFilter and GetTypeGroup(card) == "Spell" and card.class ~= classFilter then return false end
    if zoneFilter and GetTypeGroup(card) == "Creature" and card.zone ~= zoneFilter then return false end
    if factionFilter and GetTypeGroup(card) == "Creature" and card.faction ~= factionFilter then return false end
    if creatureTypeFilter and GetTypeGroup(card) == "Creature" and card.creatureType ~= creatureTypeFilter then return false end
    return true
end

-- =========================================================================
-- SORTING (by mana cost, or grouped by zone)
-- Zone order: zone creatures (A-Z by zone), then class spells (by class), then everything else.
-- =========================================================================
local function ZoneGroup(card)
    if card.zone then return 1, card.zone end
    if card.class then return 2, card.class end
    return 3, ""
end

local function CompareCards(a, b)
    local ca, cb = TTS.Cards[a], TTS.Cards[b]
    if sortMode == "ZONE" then
        local ga, za = ZoneGroup(ca)
        local gb, zb = ZoneGroup(cb)
        if ga ~= gb then return ga < gb end
        if za ~= zb then return za < zb end
    end
    local ma, mb = ca.cmc or 0, cb.cmc or 0
    if ma ~= mb then return ma < mb end
    local na, nb = ca.name or "", cb.name or ""
    if na ~= nb then return na < nb end
    return a < b
end

-- Grey zone (or class) label shown after a card's name while sorting by zone
local function ZoneSuffix(card)
    if sortMode ~= "ZONE" then return "" end
    local label = card.zone or card.class
    return label and ("  |cFF888888" .. label .. "|r") or ""
end

-- =========================================================================
-- PREVIEW CARD FRAME (Built identically to Board.lua)
-- =========================================================================
local previewCard = nil

local function BuildStandaloneCardPreview(parent, sizeX, sizeY)
    local f = CreateFrame("Frame", "TTS_DeckBuilder_PreviewCard", parent)
    f:SetSize(sizeX, sizeY)
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel((parent:GetFrameLevel() or 10) + 10)

    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetAllPoints(f)
    f.bg:SetColorTexture(0.08, 0.08, 0.08, 0.95)

    -- Art dimensions matching ART_BOX ratios from Board.lua
    local artLeft   = math.floor(sizeX * 0.06)
    local artRight  = math.floor(sizeX * 0.06)
    local artTop    = math.floor(sizeY * 0.06)
    local artBottom = math.floor(sizeY * 0.44)

    f.art = f:CreateTexture(nil, "ARTWORK")
    f.art:SetPoint("TOPLEFT", f, "TOPLEFT", artLeft, -artTop)
    f.art:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -artRight, artBottom)
    f.art:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

    f.model = CreateFrame("PlayerModel", nil, f)
    f.model:SetPoint("TOPLEFT", f, "TOPLEFT", artLeft, -artTop)
    f.model:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -artRight, artBottom)
    f.model:EnableMouse(false)
    f.model:Hide()

    f.overlay = CreateFrame("Frame", nil, f)
    f.overlay:SetAllPoints(f)
    f.overlay:EnableMouse(false)

    f.border = f.overlay:CreateTexture(nil, "OVERLAY")
    f.border:SetAllPoints(f.overlay)

    f.title = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.title:SetPoint("BOTTOMLEFT", f.overlay, "TOPLEFT", -6, 3)
    f.title:SetPoint("BOTTOMRIGHT", f.overlay, "TOPRIGHT", 6, 3)
    f.title:SetJustifyH("CENTER")

    f.cost = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.cost:SetPoint("BOTTOM", f.title, "TOP", 0, 2)
    f.cost:SetJustifyH("CENTER")

    local ptOffsetY = math.floor(sizeY * 0.18)
    f.pt = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    local fontPath = f.pt:GetFont()
    if fontPath then f.pt:SetFont(fontPath, 15, "OUTLINE") end
    f.pt:SetPoint("BOTTOM", f.overlay, "BOTTOM", 0, ptOffsetY)
    f.pt:SetJustifyH("CENTER")
    f.pt:SetShadowOffset(1.5, -1.5)
    f.pt:SetShadowColor(0, 0, 0, 1)

    f:Hide()
    return f
end

local function EnsurePreviewFrame()
    if previewCard then return previewCard end

    if TTS.CreateCardFrame then
        previewCard = TTS.CreateCardFrame(D, 120, 170)
    else
        previewCard = BuildStandaloneCardPreview(D, 120, 170)
    end

    previewCard:SetSize(120, 170)
    previewCard:ClearAllPoints()
    previewCard:SetPoint("TOPLEFT", D, "TOPRIGHT", 12, -20)
    previewCard:SetFrameStrata("DIALOG")
    previewCard:SetFrameLevel((D:GetFrameLevel() or 10) + 15)
    previewCard:EnableMouse(false)

    return previewCard
end

local function UpdateCardPreview(cardId)
    local f = EnsurePreviewFrame()
    if not f then return end

    if not cardId or not TTS.Cards or not TTS.Cards[cardId] then
        f:Hide()
        return
    end

    local card = TTS.Cards[cardId]
    f.cardId = cardId

    if TTS.SetupCardVisual then
        TTS.SetupCardVisual(f, card)
    else
        if card.displayId and f.model then
            f.art:Hide()
            f.model:Show()
            f.model:ClearModel()
            f.model:SetDisplayInfo(card.displayId)
        else
            if f.model then f.model:Hide() end
            f.art:Show()
            f.art:SetTexture(card.art or "Interface\\Icons\\INV_Misc_QuestionMark")
        end
    end

    if TTS.ApplyFrameTexture then
        TTS.ApplyFrameTexture(f.border, card)
    else
        f.border:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    end

    f.title:SetText(card.name or "")

    if card.cost and card.cost ~= "" then
        f.cost:SetText(TTS.FormatSymbols and TTS:FormatSymbols(card.cost, 14) or card.cost)
        f.cost:Show()
    else
        f.cost:Hide()
    end

    if card.type == "Creature" and card.power and card.toughness then
        f.pt:SetText(string.format("|cFFFFD200%d/%d|r", card.power, card.toughness))
        f.pt:Show()
    else
        f.pt:Hide()
    end

    f:Show()
end

-- =========================================================================
-- MOUSEOVER HANDLERS (Preview Card + Tooltip)
-- =========================================================================
local function CardTooltip_OnEnter(self)
    if not self.cardId then return end
    local card = TTS.Cards and TTS.Cards[self.cardId]
    if not card then return end

    -- 1. Display preview card frame docked to the side of the deckbuilder
    UpdateCardPreview(self.cardId)

    -- 2. Display the original tooltip anchored directly at the mouse cursor
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:AddLine(card.name, 1, 1, 1)

    if card.isBoss then
        local kills = GetKillCount(self.cardId, card)

        if kills == 0 then
            GameTooltip:AddLine("|cFFFF2222Locked: Defeat this creature to unlock!|r", 1, 0.2, 0.2)
        else
            local maxAllowed = math.min(4, kills)
            GameTooltip:AddLine(string.format("|cFF00FF00Kills: %d (Max %d copies in deck)|r", kills, maxAllowed), 0.2, 1.0, 0.2)
        end
    end

    local costStr = (card.cost and card.cost ~= "") and (TTS.FormatSymbols and TTS:FormatSymbols(card.cost, 18) or card.cost) or "0"
    local displayType = card.type
    if displayType == "Land" then
        displayType = "Prayer"
    end
    GameTooltip:AddLine("Cost: " .. costStr .. "  |  Type: " .. displayType, 0.8, 0.8, 0.8)
    local tagLine = TTS.GetCardTagLine and TTS:GetCardTagLine(card)
    if tagLine then
        GameTooltip:AddLine(tagLine, 1, 1, 1)
    end

    if card.power and card.toughness then
        GameTooltip:AddLine("Stats: " .. card.power .. "/" .. card.toughness, 1, 0.8, 0)
    end
    if card.text and card.text ~= "" then
        local textStr = TTS.FormatSymbols and TTS:FormatSymbols(card.text, 16) or card.text
        GameTooltip:AddLine(textStr, 0.9, 0.9, 0.5, true)
    end
    GameTooltip:Show()
end

local function CardTooltip_OnLeave()
    GameTooltip:Hide()
    if previewCard then
        previewCard:Hide()
    end
end

-- =========================================================================
-- FILTER CHECKBOXES
-- Card type and sphere checkboxes combine (a card must pass all of them).
-- =========================================================================
local filterChecks = {}

local function MakeCheck(x, y, labelText, getter, setter)
    local cb = CreateFrame("CheckButton", nil, D, "UICheckButtonTemplate")
    cb:SetSize(22, 22)
    cb:SetPoint("TOPLEFT", D, "TOPLEFT", x, y)

    local lbl = D:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    lbl:SetPoint("LEFT", cb, "RIGHT", 0, 1)
    lbl:SetText(labelText)
    cb:SetHitRectInsets(0, -(lbl:GetStringWidth() + 4), 0, 0)

    cb:SetScript("OnClick", function(self)
        setter(self:GetChecked() and true or false)
        D:RefreshPool()
    end)
    cb.Sync = function() cb:SetChecked(getter()) end
    cb:Sync()
    table.insert(filterChecks, cb)
    return cb
end

local typeLabel = D:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
typeLabel:SetPoint("TOPLEFT", D, "TOPLEFT", 22, -46)
typeLabel:SetText("Type:")

local typeDefs = {
    { key = "Prayer",   label = "Prayers" },
    { key = "Creature", label = "Creatures" },
    { key = "Spell",    label = "Spells" },
}
for n, def in ipairs(typeDefs) do
    MakeCheck(66 + (n - 1) * 95, -41, def.label,
        function() return typeOn[def.key] end,
        function(v) typeOn[def.key] = v end)
end

MakeCheck(360, -41, "|cFF00FF00Unlocked only|r",
    function() return onlyUnlocked end,
    function(v) onlyUnlocked = v end)

local sphereLabel = D:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
sphereLabel:SetPoint("TOPLEFT", D, "TOPLEFT", 22, -72)
sphereLabel:SetText("Sphere:")

local sphereDefs = {
    { key = "W", label = "|cFFFFD200Holy|r" },
    { key = "U", label = "|cFF66BBFFArcane|r" },
    { key = "B", label = "|cFF9966FFShadow|r" },
    { key = "R", label = "|cFFFF4444Fire|r" },
    { key = "G", label = "|cFF44FF44Nature|r" },
}
for n, def in ipairs(sphereDefs) do
    MakeCheck(66 + (n - 1) * 85, -67, def.label,
        function() return colorOn[def.key] end,
        function(v) colorOn[def.key] = v end)
end

-- =========================================================================
-- CLASS FILTER (applies to spells only) & SORT TOGGLE
-- =========================================================================
local CLASS_ORDER = { "Warrior", "Paladin", "Hunter", "Rogue", "Priest", "Shaman", "Mage", "Warlock", "Druid" }

local function ClassColored(className)
    local c = RAID_CLASS_COLORS and RAID_CLASS_COLORS[string.upper(className)]
    if c then
        return string.format("|cFF%02X%02X%02X%s|r", math.floor(c.r * 255), math.floor(c.g * 255), math.floor(c.b * 255), className)
    end
    return className
end

-- Every class that has at least one spell in the card database, in CLASS_ORDER first
local function BuildClassList()
    local present, list, seen = {}, {}, {}
    for _, card in pairs(TTS.Cards or {}) do
        if card.class then present[card.class] = true end
    end
    for _, cls in ipairs(CLASS_ORDER) do
        if present[cls] then
            table.insert(list, cls)
            seen[cls] = true
        end
    end
    local extras = {}
    for cls in pairs(present) do
        if not seen[cls] then table.insert(extras, cls) end
    end
    table.sort(extras)
    for _, cls in ipairs(extras) do table.insert(list, cls) end
    return list
end

local classLabel = D:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
classLabel:SetPoint("TOPLEFT", D, "TOPLEFT", 22, -100)
classLabel:SetText("Class:")

local classBtn = CreateFrame("Button", nil, D, "UIPanelButtonTemplate")
classBtn:SetSize(120, 22)
classBtn:SetPoint("TOPLEFT", D, "TOPLEFT", 66, -95)

local function UpdateClassButton()
    classBtn:SetText(classFilter and ClassColored(classFilter) or "All Classes")
end
UpdateClassButton()

local classMenu = CreateFrame("Frame", nil, D, backdropTemplate)
classMenu:SetPoint("TOPLEFT", classBtn, "BOTTOMLEFT", 0, -2)
classMenu:SetFrameStrata("DIALOG")
classMenu:EnableMouse(true)
if classMenu.SetBackdrop then
    classMenu:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    classMenu:SetBackdropColor(0, 0, 0, 0.95)
end
classMenu:Hide()

local function SetClassFilter(cls)
    classFilter = cls
    UpdateClassButton()
    classMenu:Hide()
    D:RefreshPool()
end

do
    local entries = { false }  -- false = "All Classes"
    for _, cls in ipairs(BuildClassList()) do table.insert(entries, cls) end

    local ROW_H = 18
    for i, cls in ipairs(entries) do
        local row = CreateFrame("Button", nil, classMenu)
        row:SetSize(112, ROW_H)
        row:SetPoint("TOPLEFT", classMenu, "TOPLEFT", 6, -6 - (i - 1) * ROW_H)
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.text:SetPoint("LEFT", 4, 0)
        row.text:SetText(cls and ClassColored(cls) or "All Classes")
        row:SetScript("OnClick", function() SetClassFilter(cls or nil) end)
    end
    classMenu:SetSize(124, 12 + #entries * ROW_H)
end

classBtn:SetScript("OnClick", function()
    if classMenu:IsShown() then classMenu:Hide() else classMenu:Show() end
end)

local sortLabel = D:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
sortLabel:SetPoint("TOPLEFT", D, "TOPLEFT", 200, -100)
sortLabel:SetText("Sort:")

local sortBtn = CreateFrame("Button", nil, D, "UIPanelButtonTemplate")
sortBtn:SetSize(90, 22)
sortBtn:SetPoint("TOPLEFT", D, "TOPLEFT", 236, -95)

local function UpdateSortButton()
    sortBtn:SetText(sortMode == "ZONE" and "Zone" or "Cost")
end
UpdateSortButton()

sortBtn:SetScript("OnClick", function()
    sortMode = (sortMode == "COST") and "ZONE" or "COST"
    UpdateSortButton()
    D:RefreshAll()
end)

-- =========================================================================
-- ZONE FILTER (applies to creatures only)
-- =========================================================================
local function BuildZoneList()
    local present, list = {}, {}
    for _, card in pairs(TTS.Cards or {}) do
        if card.zone and not present[card.zone] then
            present[card.zone] = true
            table.insert(list, card.zone)
        end
    end
    table.sort(list)
    return list
end

local zoneLabel = D:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
zoneLabel:SetPoint("TOPLEFT", D, "TOPLEFT", 500, -46)
zoneLabel:SetText("Zone:")

local zoneBtn = CreateFrame("Button", nil, D, "UIPanelButtonTemplate")
zoneBtn:SetSize(150, 22)
zoneBtn:SetPoint("TOPLEFT", D, "TOPLEFT", 540, -41)
zoneBtn:SetNormalFontObject("GameFontNormalSmall")
zoneBtn:SetHighlightFontObject("GameFontHighlightSmall")

local function UpdateZoneButton()
    zoneBtn:SetText(zoneFilter or "All Zones")
end
UpdateZoneButton()

local zoneMenu = CreateFrame("Frame", nil, D, backdropTemplate)
zoneMenu:SetPoint("TOPRIGHT", zoneBtn, "BOTTOMRIGHT", 0, -2)
zoneMenu:SetFrameStrata("DIALOG")
zoneMenu:EnableMouse(true)
if zoneMenu.SetBackdrop then
    zoneMenu:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    zoneMenu:SetBackdropColor(0, 0, 0, 0.95)
end
zoneMenu:Hide()

local function SetZoneFilter(zone)
    zoneFilter = zone
    UpdateZoneButton()
    zoneMenu:Hide()
    D:RefreshPool()
end

do
    local entries = { false }  -- false = "All Zones"
    for _, z in ipairs(BuildZoneList()) do table.insert(entries, z) end

    local ROW_H, COL_W, COLS = 18, 130, 3
    local rowsPerCol = math.ceil(#entries / COLS)
    for i, zone in ipairs(entries) do
        local col = math.floor((i - 1) / rowsPerCol)
        local rowIdx = (i - 1) % rowsPerCol
        local row = CreateFrame("Button", nil, zoneMenu)
        row:SetSize(COL_W - 4, ROW_H)
        row:SetPoint("TOPLEFT", zoneMenu, "TOPLEFT", 6 + col * COL_W, -6 - rowIdx * ROW_H)
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.text:SetPoint("LEFT", 4, 0)
        row.text:SetWidth(COL_W - 10)
        row.text:SetJustifyH("LEFT")
        row.text:SetWordWrap(false)
        row.text:SetText(zone or "All Zones")
        row:SetScript("OnClick", function() SetZoneFilter(zone or nil) end)
    end
    local usedCols = math.ceil(#entries / rowsPerCol)
    zoneMenu:SetSize(12 + usedCols * COL_W, 12 + rowsPerCol * ROW_H)
end

zoneBtn:SetScript("OnClick", function()
    if zoneMenu:IsShown() then zoneMenu:Hide() else zoneMenu:Show() end
end)

-- =========================================================================
-- FACTION & CREATURE TYPE FILTERS (apply to creatures only)
-- =========================================================================
local function BuildFieldList(field)
    local present, list = {}, {}
    for _, card in pairs(TTS.Cards or {}) do
        local v = card[field]
        if v and not present[v] then
            present[v] = true
            table.insert(list, v)
        end
    end
    table.sort(list)
    return list
end

-- Label + button + popup list on the row under Class/Sort. onSelect receives the value, or nil for "All".
-- Returns the popup menu and a function that sets the button text.
local function MakeListDropdown(labelText, labelX, buttonX, allText, values, cols, onSelect)
    local lbl = D:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("TOPLEFT", D, "TOPLEFT", labelX, -126)
    lbl:SetText(labelText)

    local btn = CreateFrame("Button", nil, D, "UIPanelButtonTemplate")
    btn:SetSize(150, 22)
    btn:SetPoint("TOPLEFT", D, "TOPLEFT", buttonX, -121)
    btn:SetNormalFontObject("GameFontNormalSmall")
    btn:SetHighlightFontObject("GameFontHighlightSmall")

    local function UpdateButton(value)
        btn:SetText(value or allText)
    end
    UpdateButton(nil)

    local menu = CreateFrame("Frame", nil, D, backdropTemplate)
    menu:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -2)
    menu:SetFrameStrata("DIALOG")
    menu:EnableMouse(true)
    if menu.SetBackdrop then
        menu:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        menu:SetBackdropColor(0, 0, 0, 0.95)
    end
    menu:Hide()

    local entries = { false }  -- false = "All"
    for _, v in ipairs(values) do table.insert(entries, v) end

    local ROW_H, COL_W = 18, 130
    local rowsPerCol = math.ceil(#entries / cols)
    for i, value in ipairs(entries) do
        local col = math.floor((i - 1) / rowsPerCol)
        local rowIdx = (i - 1) % rowsPerCol
        local row = CreateFrame("Button", nil, menu)
        row:SetSize(COL_W - 4, ROW_H)
        row:SetPoint("TOPLEFT", menu, "TOPLEFT", 6 + col * COL_W, -6 - rowIdx * ROW_H)
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.text:SetPoint("LEFT", 4, 0)
        row.text:SetWidth(COL_W - 10)
        row.text:SetJustifyH("LEFT")
        row.text:SetWordWrap(false)
        row.text:SetText(value or allText)
        row:SetScript("OnClick", function()
            UpdateButton(value or nil)
            menu:Hide()
            onSelect(value or nil)
        end)
    end
    local usedCols = math.ceil(#entries / rowsPerCol)
    menu:SetSize(12 + usedCols * COL_W, 12 + rowsPerCol * ROW_H)

    btn:SetScript("OnClick", function()
        if menu:IsShown() then menu:Hide() else menu:Show() end
    end)

    return menu, UpdateButton
end

local factionMenu, UpdateFactionButton = MakeListDropdown("Faction:", 22, 70, "All Factions",
    BuildFieldList("faction"), 2, function(value)
        factionFilter = value
        D:RefreshPool()
    end)

local creatureTypeMenu, UpdateCreatureTypeButton = MakeListDropdown("Creature:", 236, 290, "All Creature Types",
    BuildFieldList("creatureType"), 1, function(value)
        creatureTypeFilter = value
        D:RefreshPool()
    end)

local resetFiltersBtn = CreateFrame("Button", nil, D, "UIPanelButtonTemplate")
resetFiltersBtn:SetSize(110, 22)
resetFiltersBtn:SetPoint("TOPLEFT", D, "TOPLEFT", 500, -68)
resetFiltersBtn:SetText("Reset Filters")
resetFiltersBtn:SetScript("OnClick", function()
    for k in pairs(colorOn) do colorOn[k] = true end
    for k in pairs(typeOn) do typeOn[k] = true end
    onlyUnlocked = false
    classFilter = nil
    UpdateClassButton()
    classMenu:Hide()
    zoneFilter = nil
    UpdateZoneButton()
    zoneMenu:Hide()
    factionFilter = nil
    UpdateFactionButton(nil)
    factionMenu:Hide()
    creatureTypeFilter = nil
    UpdateCreatureTypeButton(nil)
    creatureTypeMenu:Hide()
    for _, cb in ipairs(filterChecks) do cb:Sync() end
    D:RefreshPool()
end)

-- =========================================================================
-- SCROLL FRAMES & ROW BUTTONS
-- =========================================================================
local poolScroll = CreateFrame("ScrollFrame", "TTS_PoolScroll", D, "FauxScrollFrameTemplate")
poolScroll:SetSize(320, 380)
poolScroll:SetPoint("TOPLEFT", 20, -152)

local deckScroll = CreateFrame("ScrollFrame", "TTS_DeckScroll", D, "FauxScrollFrameTemplate")
deckScroll:SetSize(320, 380)
deckScroll:SetPoint("TOPRIGHT", -35, -152)

local poolButtons = {}
local deckButtons = {}

for i = 1, 15 do
    local pBtn = CreateFrame("Button", nil, D)
    pBtn:SetSize(310, 24)
    pBtn:SetPoint("TOPLEFT", poolScroll, "TOPLEFT", 0, -((i - 1) * 25))
    pBtn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    pBtn.text = pBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    pBtn.text:SetPoint("LEFT", 5, 0)
    pBtn.text:SetWidth(300)
    pBtn.text:SetJustifyH("LEFT")
    pBtn.text:SetWordWrap(false)
    pBtn:SetScript("OnEnter", CardTooltip_OnEnter)
    pBtn:SetScript("OnLeave", CardTooltip_OnLeave)
    pBtn:SetScript("OnClick", function(self)
        if self.cardId then D:AddCardToDeck(self.cardId) end
    end)
    poolButtons[i] = pBtn

    local dBtn = CreateFrame("Button", nil, D)
    dBtn:SetSize(310, 24)
    dBtn:SetPoint("TOPLEFT", deckScroll, "TOPLEFT", 0, -((i - 1) * 25))
    dBtn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    dBtn.text = dBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    dBtn.text:SetPoint("LEFT", 5, 0)
    dBtn.text:SetWidth(300)
    dBtn.text:SetJustifyH("LEFT")
    dBtn.text:SetWordWrap(false)
    dBtn:SetScript("OnEnter", CardTooltip_OnEnter)
    dBtn:SetScript("OnLeave", CardTooltip_OnLeave)
    dBtn:SetScript("OnClick", function(self)
        if self.cardId then D:RemoveCardFromDeck(self.cardId) end
    end)
    deckButtons[i] = dBtn
end

-- =========================================================================
-- DECK SLOT BUTTONS (above the deck list)
-- =========================================================================
local deckSlotButtons = {}

local function UpdateDeckSlotButtons()
    for i, b in ipairs(deckSlotButtons) do
        local deck = TTS_SavedDecks and TTS_SavedDecks[i]
        local count = 0
        if deck and deck.cards then
            for _, qty in pairs(deck.cards) do count = count + qty end
        end
        b:SetText(string.format("%s (%d)", (deck and deck.name) or DefaultDeckName(i), count))
        if i == TTS_ActiveDeckIndex then
            b:LockHighlight()
        else
            b:UnlockHighlight()
        end
    end
end

for i = 1, TTS.MAX_DECK_SLOTS do
    local b = CreateFrame("Button", nil, D, "UIPanelButtonTemplate")
    b:SetSize(102, 22)
    b:SetPoint("TOPLEFT", D, "TOPLEFT", 375 + (i - 1) * 106, -95)
    b:SetNormalFontObject("GameFontNormalSmall")
    b:SetHighlightFontObject("GameFontHighlightSmall")
    b:SetScript("OnClick", function()
        TTS:EnsureDeckSlots()
        if TTS_ActiveDeckIndex == i then return end
        TTS_ActiveDeckIndex = i
        CardTooltip_OnLeave()
        D:RefreshDeck()
        DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF00FF00[TTS]|r Loaded deck: |cFFFFD200%s|r.", TTS_SavedDecks[i].name))
    end)
    deckSlotButtons[i] = b
end

-- =========================================================================
-- BOTTOM CONTROLS (DEV UNLOCK, RESET & SCAN, CLEAR DECK)
-- =========================================================================
local devBtn = CreateFrame("Button", nil, D, "UIPanelButtonTemplate")
devBtn:SetSize(115, 24)
devBtn:SetPoint("BOTTOMLEFT", 20, 18)
devBtn:SetText("|cFFFF4444Dev: Unlock|r")
devBtn:SetScript("OnClick", function()
    if TTS.BossTracker and TTS.BossTracker.UnlockAllBosses then
        TTS.BossTracker:UnlockAllBosses()
    else
        TTS_KilledBosses = TTS_KilledBosses or {}
        for cardId, card in pairs(TTS.Cards or {}) do
            if card.isBoss then TTS_KilledBosses[cardId] = 4 end
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[TTS DEVMODE]|r All boss cards unlocked (4 copies)!")
        D:RefreshAll()
    end
end)

local resetBtn = CreateFrame("Button", nil, D, "UIPanelButtonTemplate")
resetBtn:SetSize(115, 24)
resetBtn:SetPoint("LEFT", devBtn, "RIGHT", 6, 0)
resetBtn:SetText("Reset / Scan")
resetBtn:SetScript("OnClick", function()
    if TTS.BossTracker and TTS.BossTracker.ResetBosses then
        TTS.BossTracker:ResetBosses()
    else
        TTS_DevModeActive = false
        if TTS.BossTracker and TTS.BossTracker.ScanAllBosses then
            TTS_KilledBosses = {}
            TTS.BossTracker:ScanAllBosses()
        end
        D:RefreshAll()
    end
end)

local countLabel = D:CreateFontString(nil, "OVERLAY", "GameFontNormal")
countLabel:SetPoint("BOTTOMRIGHT", -40, 20)

local clearBtn = CreateFrame("Button", nil, D, "UIPanelButtonTemplate")
clearBtn:SetSize(90, 22)
clearBtn:SetPoint("BOTTOMRIGHT", countLabel, "BOTTOMLEFT", -15, -2)
clearBtn:SetText("Clear Deck")
clearBtn:SetScript("OnClick", function()
    D:ClearDeck()
end)

-- =========================================================================
-- MANA CURVE WINDOW (docked to the left of the deckbuilder)
-- Counts every non-Prayer card in the active deck by mana value (7 = 7+).
-- =========================================================================
local CURVE_COLUMNS = 8      -- mana values 0..7+
local CURVE_BAR_W   = 22
local CURVE_BAR_GAP = 6
local CURVE_BAR_MAX = 80

local curveFrame = CreateFrame("Frame", "TTS_ManaCurveFrame", D, backdropTemplate)
curveFrame:SetSize(236, 176)
curveFrame:SetPoint("TOPRIGHT", D, "TOPLEFT", -6, -20)
if curveFrame.SetBackdrop then
    curveFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    curveFrame:SetBackdropColor(0, 0, 0, 0.85)
end

local curveTitle = curveFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
curveTitle:SetPoint("TOP", curveFrame, "TOP", 0, -10)
curveTitle:SetText("Mana Curve")

local curveBars, curveCounts = {}, {}
for m = 0, CURVE_COLUMNS - 1 do
    local x = 12 + m * (CURVE_BAR_W + CURVE_BAR_GAP)

    local bar = curveFrame:CreateTexture(nil, "ARTWORK")
    bar:SetColorTexture(0.30, 0.60, 1.00, 0.90)
    bar:SetSize(CURVE_BAR_W, 1)
    bar:SetPoint("BOTTOMLEFT", curveFrame, "BOTTOMLEFT", x, 62)
    curveBars[m] = bar

    local cnt = curveFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    cnt:SetPoint("BOTTOM", bar, "TOP", 0, 1)
    curveCounts[m] = cnt

    local lbl = curveFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("TOP", bar, "BOTTOM", 0, -2)
    lbl:SetText(m == CURVE_COLUMNS - 1 and (m .. "+") or tostring(m))
end

local curveSummary = curveFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
curveSummary:SetPoint("BOTTOMLEFT", curveFrame, "BOTTOMLEFT", 12, 10)
curveSummary:SetWidth(212)
curveSummary:SetJustifyH("LEFT")

function D:UpdateManaCurve(deck)
    local buckets = {}
    for m = 0, CURVE_COLUMNS - 1 do buckets[m] = 0 end
    local spellCount, cmcSum = 0, 0
    local nCreature, nSpell, nPrayer = 0, 0, 0

    if deck and deck.cards then
        for id, count in pairs(deck.cards) do
            local c = TTS.Cards and TTS.Cards[id]
            if c and count > 0 then
                local group = GetTypeGroup(c)
                if group == "Prayer" then
                    nPrayer = nPrayer + count
                else
                    if group == "Creature" then nCreature = nCreature + count else nSpell = nSpell + count end
                    local cmc = c.cmc or 0
                    local m = math.min(CURVE_COLUMNS - 1, cmc)
                    buckets[m] = buckets[m] + count
                    spellCount = spellCount + count
                    cmcSum = cmcSum + cmc * count
                end
            end
        end
    end

    local maxCount = 1
    for m = 0, CURVE_COLUMNS - 1 do
        if buckets[m] > maxCount then maxCount = buckets[m] end
    end
    for m = 0, CURVE_COLUMNS - 1 do
        local n = buckets[m]
        if n > 0 then
            curveBars[m]:SetHeight(math.max(2, math.floor(n / maxCount * CURVE_BAR_MAX)))
            curveBars[m]:Show()
            curveCounts[m]:SetText(n)
        else
            curveBars[m]:SetHeight(1)
            curveBars[m]:Hide()
            curveCounts[m]:SetText("")
        end
    end

    local avg = spellCount > 0 and (cmcSum / spellCount) or 0
    curveSummary:SetText(string.format("Avg cost: %.1f   (Prayers not counted)\n%d Creatures | %d Spells | %d Prayers",
        avg, nCreature, nSpell, nPrayer))
end

-- =========================================================================
-- COLOUR DISTRIBUTION WINDOW (docked below the mana curve)
-- Counts every non-Prayer card in the active deck by sphere.
-- =========================================================================
local COLOR_ORDER = { "W", "U", "B", "R", "G" }
local COLOR_RGB = {
    W = { 1.00, 0.82, 0.00 },  -- Holy
    U = { 0.40, 0.73, 1.00 },  -- Arcane
    B = { 0.60, 0.40, 1.00 },  -- Shadow
    R = { 1.00, 0.27, 0.27 },  -- Fire
    G = { 0.27, 1.00, 0.27 },  -- Nature
}
local COLOR_BAR_W   = 28
local COLOR_BAR_GAP = 18
local COLOR_BAR_MAX = 80

local colorFrame = CreateFrame("Frame", "TTS_ColorDistFrame", D, backdropTemplate)
colorFrame:SetSize(236, 176)
colorFrame:SetPoint("TOPRIGHT", curveFrame, "BOTTOMRIGHT", 0, -6)
if colorFrame.SetBackdrop then
    colorFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    colorFrame:SetBackdropColor(0, 0, 0, 0.85)
end

local colorTitle = colorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
colorTitle:SetPoint("TOP", colorFrame, "TOP", 0, -10)
colorTitle:SetText("Colour Distribution")

local colorBars, colorCounts, colorLabels = {}, {}, {}
for i, col in ipairs(COLOR_ORDER) do
    local x = 12 + (i - 1) * (COLOR_BAR_W + COLOR_BAR_GAP)
    local rgb = COLOR_RGB[col]

    local bar = colorFrame:CreateTexture(nil, "ARTWORK")
    bar:SetColorTexture(rgb[1], rgb[2], rgb[3], 0.90)
    bar:SetSize(COLOR_BAR_W, 1)
    bar:SetPoint("BOTTOMLEFT", colorFrame, "BOTTOMLEFT", x, 62)
    colorBars[col] = bar

    local cnt = colorFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    cnt:SetPoint("BOTTOM", bar, "TOP", 0, 1)
    colorCounts[col] = cnt

    local lbl = colorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("TOP", bar, "BOTTOM", 0, -2)
    lbl:SetText(col)
    colorLabels[col] = lbl
end

local colorSummary = colorFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
colorSummary:SetPoint("BOTTOMLEFT", colorFrame, "BOTTOMLEFT", 12, 10)
colorSummary:SetWidth(212)
colorSummary:SetJustifyH("LEFT")

function D:UpdateColorDistribution(deck)
    local counts = { W = 0, U = 0, B = 0, R = 0, G = 0 }
    local total = 0

    if deck and deck.cards then
        for id, count in pairs(deck.cards) do
            local c = TTS.Cards and TTS.Cards[id]
            if c and count > 0 and GetTypeGroup(c) ~= "Prayer" and counts[c.color] then
                counts[c.color] = counts[c.color] + count
                total = total + count
            end
        end
    end

    local maxCount = 1
    for _, col in ipairs(COLOR_ORDER) do
        if counts[col] > maxCount then maxCount = counts[col] end
    end

    for _, col in ipairs(COLOR_ORDER) do
        local n = counts[col]
        -- Sphere icons come from Board.lua, which loads after this file
        if TTS.FormatSymbols then
            colorLabels[col]:SetText(TTS:FormatSymbols("{" .. col .. "}", 14))
        end
        if n > 0 then
            colorBars[col]:SetHeight(math.max(2, math.floor(n / maxCount * COLOR_BAR_MAX)))
            colorBars[col]:Show()
            colorCounts[col]:SetText(n)
        else
            colorBars[col]:SetHeight(1)
            colorBars[col]:Hide()
            colorCounts[col]:SetText("")
        end
    end

    colorSummary:SetText(string.format("%d cards   (Prayers not counted)", total))
end

-- =========================================================================
-- POOL & DECK LOGIC
-- =========================================================================
function D:RefreshAll()
    D:RefreshPool()
    D:RefreshDeck()
end

function D:RefreshPool()
    cardPoolKeys = {}
    for id, card in pairs(TTS.Cards or {}) do
        local matches = CardPassesFilters(id, card)

        if matches then
            table.insert(cardPoolKeys, id)
        end
    end
    table.sort(cardPoolKeys, CompareCards)

    FauxScrollFrame_Update(poolScroll, #cardPoolKeys, 15, 25)
    local offset = FauxScrollFrame_GetOffset(poolScroll)
    for i = 1, 15 do
        local index = offset + i
        if index <= #cardPoolKeys then
            local cId = cardPoolKeys[index]
            local c = TTS.Cards[cId]
            local costStr = (c.cost and c.cost ~= "") and (TTS.FormatSymbols and TTS:FormatSymbols(c.cost, 16) or c.cost) or "0"

            local kills = GetKillCount(cId, c)
            local isUnlocked = IsCardUnlocked(cId, c)
            local suffix = ZoneSuffix(c)

            poolButtons[i].cardId = cId
            if isUnlocked then
                if c.isBoss then
                    poolButtons[i].text:SetText(string.format("[%s] %s (%d kills)  %s%s", cId, c.name, kills, costStr, suffix))
                else
                    poolButtons[i].text:SetText(string.format("[%s] %s  %s%s", cId, c.name, costStr, suffix))
                end
            else
                poolButtons[i].text:SetText(string.format("|cFF777777[%s] %s (Locked)|r%s", cId, c.name, suffix))
            end
            poolButtons[i]:Show()
        else
            poolButtons[i]:Hide()
        end
    end
end

local function GetActiveDeck()
    TTS:EnsureDeckSlots()
    return TTS_SavedDecks[TTS_ActiveDeckIndex]
end

function D:RefreshDeck()
    local deck = GetActiveDeck()
    deckListKeys = {}
    local totalCards = 0
    if deck and deck.cards then
        for id, count in pairs(deck.cards) do
            if count > 0 and TTS.Cards[id] then
                table.insert(deckListKeys, id)
                totalCards = totalCards + count
            end
        end
    end
    table.sort(deckListKeys, CompareCards)

    D:UpdateManaCurve(deck)
    D:UpdateColorDistribution(deck)
    UpdateDeckSlotButtons()

    FauxScrollFrame_Update(deckScroll, #deckListKeys, 15, 25)
    local offset = FauxScrollFrame_GetOffset(deckScroll)
    for i = 1, 15 do
        local index = offset + i
        if index <= #deckListKeys then
            local cId = deckListKeys[index]
            local c = TTS.Cards[cId]
            local count = deck.cards[cId]
            deckButtons[i].cardId = cId
            deckButtons[i].text:SetText(string.format("%dx %s%s", count, c.name, ZoneSuffix(c)))
            deckButtons[i]:Show()
        else
            deckButtons[i]:Hide()
        end
    end

    if totalCards >= 40 and totalCards <= 50 then
        countLabel:SetText(string.format("|cFF00FF00Deck: %d/50 cards|r", totalCards))
    elseif totalCards > 50 then
        countLabel:SetText(string.format("|cFFFF2222Deck: %d/50 (Max exceeded)|r", totalCards))
    else
        countLabel:SetText(string.format("|cFFFF2222Deck: %d cards (Min 40, Max 50)|r", totalCards))
    end

    if TTS.MainFrame and TTS.MainFrame.UpdatePlayState then
        TTS.MainFrame:UpdatePlayState()
    end
end

function D:AddCardToDeck(cardId)
    local card = TTS.Cards and TTS.Cards[cardId]
    if not card then return end

    local deck = GetActiveDeck()
    deck.cards = deck.cards or {}

    -- Check total deck size cap (50 cards maximum)
    local totalCards = 0
    for _, qty in pairs(deck.cards) do
        totalCards = totalCards + qty
    end
    if totalCards >= 50 then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222[TTS]|r Maximum deck size reached (50 cards).")
        return
    end

    local current = deck.cards[cardId] or 0

    if card.isBoss then
        local kills = GetKillCount(cardId, card)

        if kills <= 0 then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222[TTS]|r Defeat " .. card.name .. " to unlock this card!")
            return
        end

        local maxAllowed = math.min(4, kills)
        if current >= maxAllowed then
            if maxAllowed >= 4 then
                DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFFFF2222[TTS]|r Maximum 4 copies reached for %s.", card.name))
            else
                DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFFFF2222[TTS]|r You have %d kill(s) for %s. Defeat them again to add more copies (max 4).", kills, card.name))
            end
            return
        end
    else
        if card.type ~= "Land" and current >= 4 then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222[TTS]|r Maximum 4 copies allowed for " .. card.name)
            return
        end
    end

    deck.cards[cardId] = current + 1
    D:RefreshDeck()
end

function D:RemoveCardFromDeck(cardId)
    local deck = GetActiveDeck()
    if not deck or not deck.cards or not deck.cards[cardId] then return end
    deck.cards[cardId] = deck.cards[cardId] - 1
    if deck.cards[cardId] <= 0 then
        deck.cards[cardId] = nil
    end
    D:RefreshDeck()
end

function D:ClearDeck()
    local deck = GetActiveDeck()
    if not deck then return end
    deck.cards = {}
    D:RefreshDeck()
end

-- =========================================================================
-- OPENING (blocked while a game is in progress)
-- =========================================================================
local function InMatch()
    return TTS.Engine and TTS.Engine.inMatch
end

local function PrintInMatchWarning()
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222[TTS]|r The Deckbuilder can't be opened during a game.")
end

-- Use this instead of :Show(). Returns true if the Deckbuilder opened.
function D:TryOpen()
    if InMatch() then
        PrintInMatchWarning()
        return false
    end
    self:Show()
    return true
end

-- =========================================================================
-- EVENT HOOKS
-- =========================================================================
poolScroll:SetScript("OnVerticalScroll", function(self, offset)
    CardTooltip_OnLeave()
    FauxScrollFrame_OnVerticalScroll(self, offset, 25, function() D:RefreshPool() end)
end)

deckScroll:SetScript("OnVerticalScroll", function(self, offset)
    CardTooltip_OnLeave()
    FauxScrollFrame_OnVerticalScroll(self, offset, 25, function() D:RefreshDeck() end)
end)

D:SetScript("OnShow", function()
    -- Safety net for any path that calls :Show() directly
    if InMatch() then
        PrintInMatchWarning()
        D:Hide()
        return
    end
    D:RefreshPool()
    D:RefreshDeck()
end)

D:SetScript("OnHide", function()
    CardTooltip_OnLeave()
    classMenu:Hide()
    zoneMenu:Hide()
    factionMenu:Hide()
    creatureTypeMenu:Hide()
    if TTS.MainFrame and TTS.MainFrame.UpdatePlayState then
        TTS.MainFrame:UpdatePlayState()
    end
end)