TTS = TTS or {}

-- =========================================================================
-- UNIT TOOLTIP CARD COUNTER
-- Hovering a creature that has a Forever: CCG card adds a line with the card-back
-- icon and how many copies you have unlocked, e.g. "Forever: CCG card: 2/4".
-- =========================================================================
local CARD_BACK_ICON = "Interface\\AddOns\\ForeverCCG\\Textures\\Cards\\card_back.png"
local MAX_COPIES = 4

local cardsByNpcId, cardsByName

-- Secret-value safety (same approach as BossTracker.lua)
local function IsSecret(v)
    return issecretvalue and issecretvalue(v) or false
end

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b = pcall(fn, ...)
    if ok then return a, b end
    return nil
end

local function ExtractNpcID(guid)
    if not guid or IsSecret(guid) or type(guid) ~= "string" then return nil end
    local idStr = guid:match("Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
        or guid:match("Vehicle%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
    if idStr then return tonumber(idStr) end
    if guid:find("^0x") then
        return tonumber(guid:sub(6, 10), 16)
    end
    return nil
end

-- Built on first use so every card file has loaded
local function BuildLookup()
    cardsByNpcId, cardsByName = {}, {}
    for _, card in pairs(TTS.Cards or {}) do
        if card.isBoss or card.isMob then
            if card.npcId then
                cardsByNpcId[card.npcId] = card
            end
            if card.name then
                cardsByName[card.name:lower()] = card
            end
        end
    end
end

local function FindCardForUnit(unit)
    if not cardsByNpcId then BuildLookup() end

    local guid = SafeCall(UnitGUID, unit)
    local npcId = ExtractNpcID(guid)
    if npcId and cardsByNpcId[npcId] then
        return cardsByNpcId[npcId]
    end

    local name = SafeCall(UnitName, unit)
    if name and not IsSecret(name) and type(name) == "string" then
        return cardsByName[name:lower()]
    end
    return nil
end

local function GetUnlockedCopies(card)
    local raw = TTS_KilledBosses and TTS_KilledBosses[card.id]
    local kills = 0
    if raw == true then
        kills = MAX_COPIES
    elseif type(raw) == "number" then
        kills = raw
    end
    return math.min(MAX_COPIES, kills)
end

local function AddCardLine(tooltip)
    if tooltip ~= GameTooltip then return end

    local _, unit = SafeCall(tooltip.GetUnit, tooltip)
    if not unit or IsSecret(unit) then return end

    local isPlayer = SafeCall(UnitIsPlayer, unit)
    if isPlayer == nil or IsSecret(isPlayer) or isPlayer then return end

    local card = FindCardForUnit(unit)
    if not card then return end

    local copies = GetUnlockedCopies(card)
    local color = (copies >= MAX_COPIES) and "|cFF00FF00" or (copies == 0 and "|cFF888888" or "|cFFFFFFFF")

    tooltip:AddLine(string.format("|T%s:20:10|t |cFFFFD200Forever: CCG card:|r %s%d/%d|r",
        CARD_BACK_ICON, color, copies, MAX_COPIES))
    tooltip:Show()
end

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Unit then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, AddCardLine)
else
    GameTooltip:HookScript("OnTooltipSetUnit", AddCardLine)
end
