--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
TTS.BossTracker = {}

local tracker = CreateFrame("Frame")
tracker:RegisterEvent("ADDON_LOADED")

local buildNum = select(4, GetBuildInfo()) or 0
local isMainlineProject = WOW_PROJECT_ID ~= nil and WOW_PROJECT_MAINLINE ~= nil
                          and WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local isMidnight = buildNum >= 120000
                   or isMainlineProject
                   or type(CombatLogGetCurrentEventInfo) ~= "function"

local wasInInstance = false
local achievementUIPatched = false

-- Recent processed GUID cache to prevent multiple credit triggers per single kill
local recentKilledGUIDs = {}
local recentKilledCount = 0

local KILL_DEDUPE_SECONDS = 15    -- same kill reported by several events
local LOOT_DEDUPE_SECONDS = 600   -- looting a corpse that was already credited

-- Chance (in %) that a creature kill awards the next copy of its card, indexed by
-- the copy being rolled for: 1st copy is guaranteed, then 25%, 12% and 6%.
local COPY_DROP_CHANCE = { 100, 25, 12, 6 }

-- Fast lookup maps for open-world mob cards
local mobCardsByNpcID = {}
local mobCardsByName = {}

-- =========================================================================
-- MODERN / WOW FOREVER SECRET VALUES & SAFETY HELPERS
-- =========================================================================
local function IsSecret(v)
    if issecretvalue and issecretvalue(v) then
        return true
    end
    return false
end

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d, e = pcall(fn, ...)
    if ok then return a, b, c, d, e end
    return nil
end

local function SafeCompare(a, b)
    if IsSecret(a) or IsSecret(b) then return false end
    local ok, res = pcall(function() return a == b end)
    return ok and res
end

local function SafeString(v)
    if v == nil or IsSecret(v) then return "" end
    local ok, res = pcall(tostring, v)
    if ok and type(res) == "string" then return res end
    return ""
end

local function Normalize(v)
    if v == nil or IsSecret(v) then return "" end
    local ok, s = pcall(function()
        local str = tostring(v):lower()
        str = str:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
        str = str:gsub("[%p]", " ")
        str = str:gsub("%s+", " ")
        return str:match("^%s*(.-)%s*$") or ""
    end)
    if ok and type(s) == "string" then return s end
    return ""
end

local function SanitizeKillCount(val)
    if IsSecret(val) then return 0 end
    if val == true then return 1 end
    if type(val) == "number" then return val end
    return 0
end

local function ExtractNpcID(guid)
    if not guid or IsSecret(guid) or type(guid) ~= "string" then return nil end
    local idStr = guid:match("Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
    if idStr then return tonumber(idStr) end
    idStr = guid:match("Vehicle%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
    if idStr then return tonumber(idStr) end
    if guid:find("^0x") then
        local entryHex = guid:sub(6, 10)
        return tonumber(entryHex, 16)
    end
    return nil
end

local function EnsureAchievementUI()
    if achievementUIPatched then return end
    if C_AddOns and C_AddOns.LoadAddOn then
        pcall(C_AddOns.LoadAddOn, "Blizzard_AchievementUI")
    elseif LoadAddOn then
        pcall(LoadAddOn, "Blizzard_AchievementUI")
    end
    achievementUIPatched = true
end

-- =========================================================================
-- CACHING & STATS
-- =========================================================================
local cachedStatisticsByName = {}
local cachedStatisticsByID = {}

local function RefreshClientStatisticsCache()
    EnsureAchievementUI()
    local cats = SafeCall(GetStatisticsCategoryList)
    if type(cats) ~= "table" then return end

    for _, categoryID in ipairs(cats) do
        local count = SafeCall(GetCategoryNumAchievements, categoryID) or 0
        for index = 1, count do
            local id, name = SafeCall(GetAchievementInfo, categoryID, index)
            if id and not IsSecret(id) and name and not IsSecret(name) and name ~= "" then
                local rawVal = SafeCall(GetStatistic, id)
                if rawVal ~= nil and not IsSecret(rawVal) then
                    local parsed = tonumber(rawVal)
                    if not parsed and type(rawVal) == "string" then
                        local digits = rawVal:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("[,%.%s]", ""):match("^%d+$")
                        parsed = tonumber(digits)
                    end
                    if parsed then
                        cachedStatisticsByID[id] = parsed
                        cachedStatisticsByName[Normalize(name)] = parsed
                    end
                end
            end
        end
    end
end

function TTS.BossTracker:BuildMobCardCache()
    mobCardsByNpcID = {}
    mobCardsByName = {}

    for cardId, card in pairs(TTS.Cards or {}) do
        if card.isMob then
            if card.npcId then
                mobCardsByNpcID[card.npcId] = card
            end
            if card.name then
                mobCardsByName[Normalize(card.name)] = card
            end
        end
    end
end

-- =========================================================================
-- INSTANCE CARD NOTICE
-- On entering a dungeon or raid, tell the player if it still has cards they
-- haven't collected 4/4. Dungeon creature cards carry their instance in
-- card.zone; the final boss cards have no zone, so they are listed here.
-- =========================================================================
local BOSS_CARD_INSTANCES = {
    BOSS01 = "Ragefire Chasm",
    BOSS02 = "The Deadmines",
    BOSS03 = "Wailing Caverns",
    BOSS04 = "Shadowfang Keep",
    BOSS05 = "Blackfathom Deeps",
    BOSS06 = "The Stockade",
    BOSS07 = "Gnomeregan",
    BOSS08 = "Razorfen Kraul",
    BOSS09 = "Scarlet Monastery",
    BOSS10 = "Scarlet Monastery",
    BOSS11 = "Scarlet Monastery",
    BOSS12 = "Scarlet Monastery",
    BOSS13 = "Razorfen Downs",
    BOSS14 = "Uldaman",
    BOSS15 = "Zul'Farrak",
    BOSS16 = "Maraudon",
    BOSS17 = "Sunken Temple",
    BOSS18 = "Blackrock Depths",
    BOSS19 = "Blackrock Spire",
    BOSS20 = "Blackrock Spire",
    BOSS21 = "Dire Maul",
    BOSS22 = "Dire Maul",
    BOSS23 = "Dire Maul",
    BOSS24 = "Scholomance",
    BOSS25 = "Stratholme",
    BOSS26 = "Stratholme",
}

-- Other names the client may report for the same instance (normalized form)
local INSTANCE_ALIASES = {
    ["stormwind stockade"]          = "stockade",
    ["temple of atal hakkar"]       = "sunken temple",
    ["lower blackrock spire"]       = "blackrock spire",
    ["upper blackrock spire"]       = "blackrock spire",
    ["dire maul east"]              = "dire maul",
    ["dire maul west"]              = "dire maul",
    ["dire maul north"]             = "dire maul",
    ["scarlet monastery graveyard"] = "scarlet monastery",
    ["scarlet monastery library"]   = "scarlet monastery",
    ["scarlet monastery armory"]    = "scarlet monastery",
    ["scarlet monastery cathedral"] = "scarlet monastery",
}

local function InstanceKey(name)
    local key = (Normalize(name):gsub("^the ", ""))
    return INSTANCE_ALIASES[key] or key
end

function TTS.BossTracker:InstanceHasLockedCards(instanceName)
    local key = InstanceKey(instanceName)
    if key == "" then return false end

    for cardId, card in pairs(TTS.Cards or {}) do
        local cardInstance = card.zone or BOSS_CARD_INSTANCES[cardId]
        if card.isBoss and cardInstance and InstanceKey(cardInstance) == key then
            if SanitizeKillCount(TTS_KilledBosses and TTS_KilledBosses[cardId]) < 4 then
                return true
            end
        end
    end
    return false
end

local function AnnounceInstanceCards()
    local name, instanceType = SafeCall(GetInstanceInfo)
    if not name or IsSecret(name) or IsSecret(instanceType) then return end
    if instanceType ~= "party" and instanceType ~= "raid" then return end

    if TTS.BossTracker:InstanceHasLockedCards(name) then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[TTS]|r |cFFFFD200This instance has cards you are yet to unlock!|r")
    end
end

-- =========================================================================
-- KILL EVALUATION & REWARD
-- =========================================================================
function TTS.BossTracker:RecordMobKill(card)
    if not card or not card.id then return end
    TTS_KilledBosses = TTS_KilledBosses or {}

    local currentKills = SanitizeKillCount(TTS_KilledBosses[card.id])
    if currentKills < 4 then
        local newKills = currentKills + 1
        if math.random(100) > COPY_DROP_CHANCE[newKills] then return end
        TTS_KilledBosses[card.id] = newKills
        local zoneText = card.zone and string.format(" (%s)", card.zone) or ""
        DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF00FF00[TTS]|r Mob Slain: |cFFFFD200%s|r%s! Card Unlocked: |cFF00FFFF(%d/4 copies)|r.", card.name, zoneText, newKills))

        -- Final copy: raid-warning style announcement in the middle of the screen
        if newKills == 4 then
            ShowCardCompletePopup(card)
        end

        if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() and TTS.DeckBuilderFrame.RefreshAll then
            TTS.DeckBuilderFrame:RefreshAll()
        end
    end
end

function TTS.BossTracker:RecordMobKillByGUIDOrName(guid, name, dedupeSeconds)
    local window = dedupeSeconds or KILL_DEDUPE_SECONDS
    if guid and not IsSecret(guid) then
        if recentKilledGUIDs[guid] and (GetTime() - recentKilledGUIDs[guid]) < window then
            return
        end
        recentKilledGUIDs[guid] = GetTime()
        recentKilledCount = recentKilledCount + 1
        if recentKilledCount > 1000 then
            local now = GetTime()
            for g, t in pairs(recentKilledGUIDs) do
                if (now - t) > LOOT_DEDUPE_SECONDS then recentKilledGUIDs[g] = nil end
            end
            recentKilledCount = 0
        end

        local npcId = ExtractNpcID(guid)
        if npcId and mobCardsByNpcID[npcId] then
            self:RecordMobKill(mobCardsByNpcID[npcId])
            return
        end
    end

    if name and not IsSecret(name) then
        local norm = Normalize(name)
        if norm ~= "" and mobCardsByName[norm] then
            self:RecordMobKill(mobCardsByName[norm])
        end
    end
end

function TTS.BossTracker:GetBossKills(card)
    if not card then return 0 end
    if TTS_DevModeActive then return 4 end

    if card.isMob then
        return SanitizeKillCount(TTS_KilledBosses and TTS_KilledBosses[card.id])
    end

    EnsureAchievementUI()
    local kills = 0

    if card.statisticId then
        if cachedStatisticsByID[card.statisticId] then
            kills = cachedStatisticsByID[card.statisticId]
        else
            local statVal = SafeCall(GetStatistic, card.statisticId)
            if statVal and not IsSecret(statVal) then
                local parsed = tonumber(statVal)
                if not parsed and type(statVal) == "string" then
                    local digits = statVal:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("[,%.%s]", ""):match("^%d+$")
                    parsed = tonumber(digits)
                end
                if parsed and parsed > 0 then kills = parsed end
            end
        end
    end

    if kills == 0 and card.name then
        local targetName = Normalize(card.name)
        for statName, val in pairs(cachedStatisticsByName) do
            if statName:find(targetName, 1, true) and val > kills then
                kills = val
            end
        end
    end

    if kills == 0 and card.metaAchievementId and card.criteriaIndex and GetAchievementCriteriaInfo then
        local _, _, completed, quantity = SafeCall(GetAchievementCriteriaInfo, card.metaAchievementId, card.criteriaIndex)
        if quantity and not IsSecret(quantity) and quantity > 0 then
            kills = quantity
        elseif completed and not IsSecret(completed) and completed == true then
            kills = 1
        end
    end

    if kills == 0 and card.achievementId and GetAchievementInfo then
        local _, _, completed = SafeCall(GetAchievementInfo, card.achievementId)
        if completed and not IsSecret(completed) and completed == true then
            kills = 1
        end
    end

    return kills
end

function TTS.BossTracker:UnlockAllBosses()
    TTS_DevModeActive = true
    TTS_KilledBosses = TTS_KilledBosses or {}

    for cardId, card in pairs(TTS.Cards or {}) do
        if card.isBoss or card.isMob then
            TTS_KilledBosses[cardId] = 4
        end
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[TTS DEVMODE]|r Dev mode ENABLED: All boss and mob cards unlocked (4x copies)!")

    if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() and TTS.DeckBuilderFrame.RefreshAll then
        TTS.DeckBuilderFrame:RefreshAll()
    end
end

function TTS.BossTracker:ResetBosses()
    TTS_DevModeActive = false
    TTS_KilledBosses = {}
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD200[TTS]|r Dev mode DISABLED. Rescanning character statistics and mob progress...")

    self:ScanAllBosses()

    if TTS_SavedDecks and TTS_ActiveDeckIndex and TTS_SavedDecks[TTS_ActiveDeckIndex] then
        local deck = TTS_SavedDecks[TTS_ActiveDeckIndex]
        if deck.cards then
            for cardId, count in pairs(deck.cards) do
                local card = TTS.Cards and TTS.Cards[cardId]
                if card and (card.isBoss or card.isMob) then
                    local allowed = math.min(4, SanitizeKillCount(TTS_KilledBosses[cardId]))
                    if allowed == 0 then
                        deck.cards[cardId] = nil
                    elseif count > allowed then
                        deck.cards[cardId] = allowed
                    end
                end
            end
        end
    end

    if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() and TTS.DeckBuilderFrame.RefreshAll then
        TTS.DeckBuilderFrame:RefreshAll()
    end
end

function TTS.BossTracker:ScanAllBosses()
    EnsureAchievementUI()
    RefreshClientStatisticsCache()
    self:BuildMobCardCache()

    TTS_KilledBosses = TTS_KilledBosses or {}
    local anyChange = false

    for cardId, card in pairs(TTS.Cards or {}) do
        if card.isBoss and not card.isMob then
            local kills = self:GetBossKills(card)
            local oldKills = SanitizeKillCount(TTS_KilledBosses[cardId])

            if kills > oldKills then
                TTS_KilledBosses[cardId] = kills
                anyChange = true
                DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF00FF00[TTS]|r Boss Tracked: |cFFFFD200%s|r (%d kills recorded).", card.name, kills))
            elseif TTS_KilledBosses[cardId] == nil then
                TTS_KilledBosses[cardId] = oldKills
            end
        end
    end

    if anyChange and TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() and TTS.DeckBuilderFrame.RefreshAll then
        TTS.DeckBuilderFrame:RefreshAll()
    end
end

-- =========================================================================
-- EVENT REGISTRATION & HANDLERS (KILLDEX LOGIC)
-- =========================================================================
local function SafeRegister(event)
    local ok, registered = pcall(tracker.RegisterEvent, tracker, event)
    return ok and registered ~= false
end

local function RegisterEvents()
    tracker:RegisterEvent("PLAYER_ENTERING_WORLD")
    tracker:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
    tracker:RegisterEvent("LOOT_OPENED")

    if not isMidnight then
        if not SafeRegister("COMBAT_LOG_EVENT_UNFILTERED") then
            SafeRegister("PARTY_KILL")
            SafeRegister("UNIT_DIED")
        end
    else
        SafeRegister("PARTY_KILL")
        SafeRegister("UNIT_DIED")
        if type(CombatLogGetCurrentEventInfo) == "function" then
            SafeRegister("COMBAT_LOG_EVENT_UNFILTERED")
        end
    end
end

local GROUP_AFFILIATION_MASK = 0x7 -- MINE (1) | PARTY (2) | RAID (4)

local function InRestrictedInstance()
    if IsInInstance then
        local _, instanceType = IsInInstance()
        return instanceType ~= "none"
    end
    return false
end

tracker:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local arg1 = ...
        if SafeCompare(arg1, "ForeverCCG") then
            TTS_KilledBosses = TTS_KilledBosses or {}
            TTS_DevModeActive = TTS_DevModeActive or false

            for k, v in pairs(TTS_KilledBosses) do
                if type(v) == "boolean" then
                    TTS_KilledBosses[k] = v and 1 or 0
                end
            end
            EnsureAchievementUI()
            TTS.BossTracker:BuildMobCardCache()
            RegisterEvents()
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        local isInitialLogin, isReloadingUI = ...
        local inInstance = SafeCall(IsInInstance) or false

        TTS.BossTracker:BuildMobCardCache()

        if isInitialLogin or isReloadingUI or (wasInInstance and not inInstance) then
            if not TTS_DevModeActive then
                local function scan()
                    if not TTS_DevModeActive then TTS.BossTracker:ScanAllBosses() end
                end
                if C_Timer and C_Timer.After then
                    C_Timer.After(1, scan)
                    C_Timer.After(3, scan)
                    C_Timer.After(7, scan)
                else
                    scan()
                end
            end
        end

        -- Entering a dungeon or raid: mention any cards still to unlock there
        if inInstance and not wasInInstance then
            if C_Timer and C_Timer.After then
                C_Timer.After(2, AnnounceInstanceCards)
            else
                AnnounceInstanceCards()
            end
        end
        wasInInstance = inInstance

    elseif event == "PARTY_KILL" then
        -- KillDex approach: Bail immediately in instances to avoid security/secret taint violations
        if InRestrictedInstance() then return end
        local attackerGUID, targetGUID = ...
        if IsSecret(attackerGUID) or IsSecret(targetGUID) then return end
        if targetGUID then
            TTS.BossTracker:RecordMobKillByGUIDOrName(targetGUID, nil)
        end

    elseif event == "UNIT_DIED" then
        if InRestrictedInstance() then return end
        -- UNIT_DIED does not say who made the kill (it fires for anyone nearby), so it never grants credit
        return

    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if not CombatLogGetCurrentEventInfo then return end
        -- info[n+1] = event argument n (info[1] is the pcall status)
        local info = { pcall(CombatLogGetCurrentEventInfo) }
        if not info[1] then return end
        local subevent, sourceFlags, destGUID, destName = info[3], info[7], info[9], info[10]
        if not subevent or IsSecret(subevent) then return end
        if IsSecret(sourceFlags) or type(sourceFlags) ~= "number" then return end
        if not destGUID or IsSecret(destGUID) then return end

        -- Only kills by you / your party / raid (or their pets) may count
        local okMask, groupBits = pcall(bit.band, sourceFlags, GROUP_AFFILIATION_MASK)
        if not okMask or groupBits == 0 then return end

        if subevent == "PARTY_KILL" then
            TTS.BossTracker:RecordMobKillByGUIDOrName(destGUID, destName)
        else
            local overkill
            if subevent == "SWING_DAMAGE" then
                overkill = info[14]
            elseif subevent == "SPELL_DAMAGE" or subevent == "RANGE_DAMAGE" then
                overkill = info[17]
            end
            if overkill and not IsSecret(overkill) and type(overkill) == "number" and overkill > 0 then
                TTS.BossTracker:RecordMobKillByGUIDOrName(destGUID, destName)
            end
        end

    elseif event == "LOOT_OPENED" then
        if UnitExists("target") then
            local guid = SafeCall(UnitGUID, "target")
            local name = SafeCall(UnitName, "target")
            if guid and not IsSecret(guid) then
                                TTS.BossTracker:RecordMobKillByGUIDOrName(guid, name, LOOT_DEDUPE_SECONDS)
            end
        end

    elseif event == "CHAT_MSG_COMBAT_XP_GAIN" then
        local msg = ...
        if msg and not IsSecret(msg) and type(msg) == "string" then
            local mobName = msg:match("^(.-) dies, you gain")
            if mobName then
                local guid
                if SafeCall(UnitIsDead, "target") and SafeCompare(SafeCall(UnitName, "target"), mobName) then
                    guid = SafeCall(UnitGUID, "target")
                end
                TTS.BossTracker:RecordMobKillByGUIDOrName(guid, mobName)
            end
        end
    end
end)

SLASH_TTSDEV1 = "/ttsdev"
SlashCmdList["TTSDEV"] = function()
    if TTS_DevModeActive then
        TTS.BossTracker:ResetBosses()
    else
        TTS.BossTracker:UnlockAllBosses()
    end
end