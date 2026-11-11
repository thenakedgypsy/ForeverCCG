--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
local L = TTS.L

-- =========================================================================
-- PROFESSION CARDS: HOW THEY ARE EARNED (the cards: Cards\Professions.lua)
-- Doing a profession rolls for its cards: each craft (Cooking and First Aid too), each node
-- gathered, each corpse skinned and each fish caught. A roll goes through the cards the
-- skill has unlocked and that aren't complete, highest tier first, and stops at the first
-- success, so one action gives one card at most. No bad-luck protection.
--
-- Starter cards (per account, TTS_NpcGifts.profPicked): learning a profession for the first
-- time gives 1 copy of its skill-1 card, for the first 2 primary professions ever and all
-- 3 secondaries. Those slots never refill.
-- Install credit (per character, TTS_Hero.professions = { [key] = highest skill seen}): the
-- first time a character's profession is seen, each card gives floor((skill - skillReq) / 75)
-- copies, up to 4. A first-seen profession that takes a starter slot gets at least 1.
-- Trainers: once 2 primary professions are finished, trainers of a primary profession the
-- character doesn't know hand out its cards (UI\NpcGossip.lua).
-- =========================================================================
local Prof = {}
TTS.Professions = Prof

-- Chance (in %) of the next copy of a card, by the copy being rolled for
local COPY_CHANCE = { 8, 3, 1.5, 0.75 }
-- Multiplier by how the action looks to the player's skill (grey only rolls at MAX_SKILL)
local COLOR_MULT = { orange = 1.5, yellow = 1, green = 0.5 }
local GREY_MULT = 0.25
local FISHING_MULT = 0.4       -- fishing has no colours: every catch rolls at this
local MAX_SKILL = 300
local MAX_COPIES = 4
local STARTER_PRIMARIES = 2    -- how many primary professions ever give a starter card
local CREDIT_STEP = 75         -- install credit: one copy per this much skill above the card's
local TRAINER_UNLOCK = 2       -- finished primary professions that open the trainers
local LOOT_WINDOW = 5          -- seconds a gather or cast can wait for its loot window

local CARD_BACK_ICON = "Interface\\AddOns\\ForeverCCG\\Textures\\Symbols\\tracker_small.png"   -- (the tracker emblem, in tooltip lines)

-- Gathering nodes: the skill they need, their name (English clients, when the loot source
-- can't be read) and their game object ids. A node not listed counts as yellow.
local NODES = {
    mining = {
        { 1, "Copper Vein", 1731, 3763, 103713, 2055 }, { 65, "Tin Vein", 1732, 3764, 103711, 2054 },
        { 65, "Incendicite Mineral Vein", 1610, 1667 }, { 75, "Silver Vein", 1733, 105569 },
        { 75, "Lesser Bloodstone Deposit", 2653 }, { 75, "Ooze Covered Silver Vein", 73940 },
        { 125, "Iron Deposit", 1735 }, { 150, "Indurium Mineral Vein", 19903 },
        { 155, "Gold Vein", 1734, 150080 }, { 155, "Ooze Covered Gold Vein", 73941 },
        { 175, "Mithril Deposit", 2040, 150079 }, { 175, "Ooze Covered Mithril Deposit", 123310 },
        { 230, "Truesilver Deposit", 2047, 150081 }, { 230, "Ooze Covered Truesilver Deposit", 123309 },
        { 230, "Dark Iron Deposit", 165658 }, { 245, "Small Thorium Vein", 324, 150082 },
        { 245, "Ooze Covered Thorium Vein", 123848 }, { 250, "Hakkari Thorium Vein", 180215 },
        { 275, "Rich Thorium Vein", 175404 }, { 275, "Ooze Covered Rich Thorium Vein", 177388 },
    },
    herbalism = {
        { 1, "Peacebloom", 1618, 3724 }, { 1, "Silverleaf", 1617, 3725 }, { 15, "Earthroot", 1619, 3726 },
        { 50, "Mageroyal", 1620, 3727 }, { 70, "Briarthorn", 1621, 3729 }, { 85, "Stranglekelp", 2045 },
        { 100, "Bruiseweed", 1622, 3730 }, { 115, "Wild Steelbloom", 1623 }, { 120, "Grave Moss", 1628 },
        { 125, "Kingsblood", 1624 }, { 150, "Liferoot", 2041 }, { 160, "Fadeleaf", 2042 },
        { 170, "Goldthorn", 2046 }, { 185, "Khadgar's Whisker", 2043 }, { 195, "Wintersbite", 2044 },
        { 205, "Firebloom", 2866 }, { 210, "Purple Lotus", 142140 }, { 220, "Arthas' Tears", 142141 },
        { 230, "Sungrass", 142142 }, { 235, "Blindweed", 142143 }, { 245, "Ghost Mushroom", 142144 },
        { 250, "Gromsblood", 142145 }, { 260, "Golden Sansam", 176583, 176638 }, { 270, "Dreamfoil", 176584, 176639 },
        { 280, "Mountain Silversage", 176586, 176640 }, { 285, "Plaguebloom", 176587, 176641 },
        { 290, "Icecap", 176588, 176642 }, { 300, "Black Lotus", 176589 },
    },
}

local defs, cardsOf              -- key -> definition; key -> its cards, lowest tier first
local nodeByObject, nodeByName   -- id / English name -> { req, prof }

local function IsSecret(v) return issecretvalue and issecretvalue(v) or false end

local function Build()
    if defs then return end
    defs, cardsOf, nodeByObject, nodeByName = {}, {}, {}, {}
    for _, def in ipairs(TTS.PROFESSIONS or {}) do
        defs[def.key] = def
        cardsOf[def.key] = {}
    end
    for _, card in pairs(TTS.Cards or {}) do
        if card.isProfession and cardsOf[card.profession] then table.insert(cardsOf[card.profession], card) end
    end
    for _, list in pairs(cardsOf) do
        table.sort(list, function(a, b) return a.skillReq < b.skillReq end)
    end
    for prof, nodes in pairs(NODES) do
        for _, node in ipairs(nodes) do
            local info = { req = node[1], prof = prof }
            nodeByName[node[2]] = info
            for i = 3, #node do nodeByObject[node[i]] = info end
        end
    end
end

local function SpellName(id)
    if C_Spell and C_Spell.GetSpellName then
        local ok, name = pcall(C_Spell.GetSpellName, id)
        if ok and name and not IsSecret(name) then return name end
    end
    if GetSpellInfo then
        local ok, name = pcall(GetSpellInfo, id)
        if ok and name and not IsSecret(name) then return name end
    end
end

-- The profession's name in the player's language
function Prof:Name(key)
    Build()
    local def = defs[key]
    return def and (SpellName(def.spell) or def.name) or key
end

-- The player's current skill in a profession, or nil if they don't know it (or it can't be
-- read). Forever runs on the Mainline client, where skill lines are asked for by id; older
-- clients list them under headers, a collapsed one hiding its lines.
function Prof:Skill(key)
    Build()
    local def = defs[key]
    if not def then return nil end
    if C_SkillInfo and C_SkillInfo.GetSkillLineInfoByID then
        local ok, info = pcall(C_SkillInfo.GetSkillLineInfoByID, def.skillLine)
        local rank = ok and info and (info.rank or info.skillRank)
        if rank and not IsSecret(rank) and rank > 0 then return rank end
        return nil
    end
    if GetNumSkillLines and GetSkillLineInfo then
        local name = SpellName(def.spell)
        for i = 1, GetNumSkillLines() do
            local line, isHeader, _, rank = GetSkillLineInfo(i)
            if not isHeader and line == name and (rank or 0) > 0 then return rank end
        end
    end
    return nil
end

local function Copies(card) return TTS:GetOwnedCopies(card) or 0 end

-- Whether the player still has cards of this profession to collect
local function HasIncomplete(key)
    for _, card in ipairs(cardsOf[key] or {}) do
        if Copies(card) < MAX_COPIES then return true end
    end
    return false
end

-- =========================================================================
-- ROLLS
-- =========================================================================
-- The multiplier for a colour at this skill (0 = no roll)
function Prof:Multiplier(color, skill)
    if color == "grey" then return skill >= MAX_SKILL and GREY_MULT or 0 end
    return COLOR_MULT[color] or 1
end

-- How a node or corpse needing `req` skill looks at `skill`
function Prof:ColorFor(req, skill)
    if skill < req + 25 then return "orange" end
    if skill < req + 50 then return "yellow" end
    if skill < req + 100 then return "green" end
    return "grey"
end

-- One action's roll: the card earned, or nil
function Prof:Roll(key, mult)
    Build()
    local skill = self:Skill(key)
    if not skill or not mult or mult <= 0 then return nil end
    local cards = cardsOf[key] or {}
    for i = #cards, 1, -1 do   -- highest tier first
        local card = cards[i]
        local copies = Copies(card)
        if card.skillReq <= skill and copies < MAX_COPIES then
            if math.random() * 100 < COPY_CHANCE[copies + 1] * mult then
                TTS:AddGiftCopy(card, "prof.gotCard")
                return card
            end
        end
    end
    return nil
end

-- A roll for an action of this colour
local function RollColor(key, color)
    local skill = Prof:Skill(key)
    if skill then return Prof:Roll(key, Prof:Multiplier(color, skill)) end
end

-- =========================================================================
-- RECIPES
-- Which profession a craft belongs to and how it looks to the player's skill: asked of the
-- client by the spell just cast when it can say, else from what the trade skill window
-- listed while it was open (by name).
-- =========================================================================
local DIFFICULTY = { optimal = "orange", medium = "yellow", easy = "green", trivial = "grey",
    [0] = "orange", [1] = "yellow", [2] = "green", [3] = "grey" }
local recipes = {}   -- recipe name -> { key = profession, color = "orange"... }

local function ProfOfSkillName(name)
    for key, def in pairs(defs) do
        if def.craft and SpellName(def.spell) == name then return key end
    end
end

local function CacheTradeSkill()
    Build()
    if GetTradeSkillLine and GetNumTradeSkills and GetTradeSkillInfo then
        local key = ProfOfSkillName(GetTradeSkillLine())
        for i = 1, (key and GetNumTradeSkills()) or 0 do
            local name, kind = GetTradeSkillInfo(i)
            if name and DIFFICULTY[kind] then recipes[name] = { key = key, color = DIFFICULTY[kind] } end
        end
    end
    -- Enchanting keeps its recipes in the craft window on old clients
    if GetCraftDisplaySkillLine and GetNumCrafts and GetCraftInfo then
        local key = ProfOfSkillName((GetCraftDisplaySkillLine()))
        for i = 1, (key and GetNumCrafts()) or 0 do
            local name, _, kind = GetCraftInfo(i)
            if name and DIFFICULTY[kind] then recipes[name] = { key = key, color = DIFFICULTY[kind] } end
        end
    end
end

-- The craft a spell is, as { key, color }, or nil if it isn't one
local function RecipeOf(spellId)
    Build()
    if C_TradeSkillUI and C_TradeSkillUI.IsRecipeInSkillLine and C_TradeSkillUI.GetRecipeInfo then
        for key, def in pairs(defs) do
            if def.craft then
                local ok, found = pcall(C_TradeSkillUI.IsRecipeInSkillLine, spellId, def.skillLine)
                if ok and found then
                    local okInfo, info = pcall(C_TradeSkillUI.GetRecipeInfo, spellId)
                    local level = okInfo and info and (info.difficulty or info.relativeDifficulty)
                    return { key = key, color = DIFFICULTY[level] or "yellow" }
                end
            end
        end
    end
    local name = SpellName(spellId)
    return name and recipes[name] or nil
end

-- =========================================================================
-- GATHERING
-- =========================================================================
local GATHER_SPELLS = { [2575] = "mining", [2366] = "herbalism", [8613] = "skinning" }
local FISHING_SPELL = 7620
local gatherNames, fishingName   -- spell name -> profession, every rank casts under one name
local pending                    -- the gather waiting for its loot: { key, at, level, node }
local sentNode                   -- the name of the node a gather has just been started on
local fishedAt

local function GatherOf(spellId)
    if not gatherNames then
        gatherNames = {}
        for id, key in pairs(GATHER_SPELLS) do
            local name = SpellName(id)
            if name then gatherNames[name] = key end
        end
        fishingName = SpellName(FISHING_SPELL)
    end
    if GATHER_SPELLS[spellId] then return GATHER_SPELLS[spellId] end
    local name = SpellName(spellId)
    return name and gatherNames[name] or nil
end

-- The game object a loot window came from, by the loot source's id, or nil
local function NodeFromLoot()
    if not (GetLootSourceInfo and GetNumLootItems) then return nil end
    local ok, guid = pcall(GetLootSourceInfo, 1)
    if not ok or not guid or IsSecret(guid) or type(guid) ~= "string" then return nil end
    local id = guid:match("^GameObject%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
    return id and nodeByObject[tonumber(id)] or nil
end

local function SkinningRequired(level)
    if level <= 10 then return 1 end
    if level <= 20 then return (level - 10) * 10 end
    return level * 5
end

local function GatherColor(gather, skill)
    if gather.key == "skinning" then
        return gather.level and Prof:ColorFor(SkinningRequired(gather.level), skill) or "yellow"
    end
    local node = NodeFromLoot() or (gather.node and nodeByName[gather.node])
    return node and Prof:ColorFor(node.req, skill) or "yellow"
end

local function OnLootOpened()
    local now = GetTime()
    if pending then
        local gather = pending
        pending = nil
        if now - gather.at <= LOOT_WINDOW then
            local skill = Prof:Skill(gather.key)
            if skill then RollColor(gather.key, GatherColor(gather, skill)) end
            return
        end
    end
    -- The client's own answer when it has one; else a fishing channel that only just ended
    local caught
    local ok, fishing = false, nil
    if IsFishingLoot then ok, fishing = pcall(IsFishingLoot) end
    if ok and not IsSecret(fishing) then
        caught = fishing
    else
        caught = fishedAt and now - fishedAt <= LOOT_WINDOW
    end
    if caught then
        fishedAt = nil
        Prof:Roll("fishing", FISHING_MULT)
    end
end

local function OnSpellSucceeded(unit, spellId)
    if unit ~= "player" or not spellId or IsSecret(spellId) then return end
    Build()
    local key = GatherOf(spellId)
    if key then
        pending = { key = key, at = GetTime(), node = sentNode }
        sentNode = nil
        if key == "skinning" then
            local ok, level = pcall(UnitLevel, "target")
            if ok and level and not IsSecret(level) and level > 0 then pending.level = level end
        end
        return
    end
    local recipe = RecipeOf(spellId)
    if recipe then RollColor(recipe.key, recipe.color) end
end

-- =========================================================================
-- FIRST TIME A PROFESSION IS SEEN: starter cards and install credit
-- =========================================================================
local creditPaid = 0   -- copies given by the current scan, for its popup

local function Hero()
    TTS_Hero = TTS_Hero or {}
    TTS_Hero.professions = TTS_Hero.professions or {}
    return TTS_Hero.professions
end

local function Picked()
    TTS_NpcGifts = TTS_NpcGifts or {}
    TTS_NpcGifts.profPicked = TTS_NpcGifts.profPicked or {}
    return TTS_NpcGifts.profPicked
end

-- Takes a starter slot for a profession seen for the first time on this account
local function TakeStarterSlot(def)
    local picked = Picked()
    if picked[def.key] then return false end
    if def.primary then
        local used = 0
        for key in pairs(picked) do
            if defs[key] and defs[key].primary then used = used + 1 end
        end
        if used >= STARTER_PRIMARIES then return false end
    end
    picked[def.key] = true
    return true
end

-- How many copies of a card a character's skill is owed
function Prof:CreditFor(card, skill)
    if card.skillReq > skill then return 0 end
    return math.min(MAX_COPIES, math.floor((skill - card.skillReq) / CREDIT_STEP))
end

local function PayFirstSeen(def, skill)
    local starter = TakeStarterSlot(def)
    for _, card in ipairs(cardsOf[def.key] or {}) do
        local owed = Prof:CreditFor(card, skill)
        if starter and card.skillReq == 1 then owed = math.max(owed, 1) end
        for _ = 1, owed do
            if TTS:AddGiftCopy(card, false) then creditPaid = creditPaid + 1 end
        end
    end
end

-- Looks at every profession the character has; new ones pay out once
function Prof:Scan()
    Build()
    local seen = Hero()
    for _, def in ipairs(TTS.PROFESSIONS or {}) do
        local skill = self:Skill(def.key)
        if skill then
            if seen[def.key] == nil then PayFirstSeen(def, skill) end
            seen[def.key] = math.max(seen[def.key] or 0, skill)
        end
    end
    if creditPaid > 0 then
        local paid = creditPaid
        creditPaid = 0
        StaticPopup_Show("TTS_PROFESSION_CREDIT", paid)
    end
end

StaticPopupDialogs["TTS_PROFESSION_CREDIT"] = {
    text = L("prof.creditPopup"),
    button1 = OKAY or "OK",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
-- The popup reads this when it shows: set it again once the chosen language has loaded
TTS.Locale:OnReady(function() StaticPopupDialogs["TTS_PROFESSION_CREDIT"].text = L("prof.creditPopup") end)

-- =========================================================================
-- TRAINERS
-- =========================================================================
-- How many primary professions have every card complete
function Prof:FinishedPrimaries()
    Build()
    local n = 0
    for _, def in ipairs(TTS.PROFESSIONS or {}) do
        if def.primary and not HasIncomplete(def.key) and #cardsOf[def.key] > 0 then n = n + 1 end
    end
    return n
end

function Prof:TrainersUnlocked() return self:FinishedPrimaries() >= TRAINER_UNLOCK end

-- A trainer's cards for this character, lowest tier first, or nil if it hands out none
function Prof:TrainerCards(key)
    Build()
    if not self:TrainersUnlocked() or self:Skill(key) then return nil end
    return cardsOf[key]
end

-- How to earn a card (collection hints)
function Prof:HowToEarn(card)
    return L("prof.how", self:Name(card.profession), card.skillReq)
end

-- =========================================================================
-- TOOLTIP
-- A gathering node (by its English name) and a recipe say they can give cards while the
-- player has some of that profession still to collect.
-- =========================================================================
local function AddCardLine(tooltip, key)
    tooltip:AddLine(string.format("|T%s:16:16|t %s", CARD_BACK_ICON, L("prof.tooltip", Prof:Name(key))), 0.1, 1, 0.1)
    tooltip:Show()
end

local function OnTooltipShow(tooltip)
    if tooltip ~= GameTooltip then return end
    Build()
    local left = _G["GameTooltipTextLeft1"]
    local ok, name = pcall(left and left.GetText or function() end, left)
    if not ok or not name or IsSecret(name) then return end
    local node = nodeByName[name]
    if node and Prof:Skill(node.prof) and HasIncomplete(node.prof) then AddCardLine(tooltip, node.prof) end
end

local function OnRecipeTooltip(tooltip, name)
    if not name or IsSecret(name) then return end
    local recipe = recipes[name]
    if recipe and HasIncomplete(recipe.key) then AddCardLine(tooltip, recipe.key) end
end

-- =========================================================================
-- EVENTS
-- =========================================================================
local frame = CreateFrame("Frame")
local function Register(event) pcall(frame.RegisterEvent, frame, event) end
for _, event in ipairs({ "PLAYER_LOGIN", "SKILL_LINES_CHANGED", "TRAINER_CLOSED", "LOOT_OPENED",
    "TRADE_SKILL_SHOW", "TRADE_SKILL_UPDATE", "CRAFT_SHOW", "CRAFT_UPDATE",
    "UNIT_SPELLCAST_SENT", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_CHANNEL_STOP" }) do
    Register(event)
end

-- Several skill-line events can land together: one look shortly after the last
local scanQueued
local function QueueScan(delay)
    if scanQueued then return end
    scanQueued = true
    C_Timer.After(delay or 1, function()
        scanQueued = false
        Prof:Scan()
    end)
end

frame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        GameTooltip:HookScript("OnShow", OnTooltipShow)
        QueueScan(3)   -- the skill lines arrive a moment after login
    elseif event == "SKILL_LINES_CHANGED" or event == "TRAINER_CLOSED" then
        QueueScan()
    elseif event == "LOOT_OPENED" then
        OnLootOpened()
    elseif event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_UPDATE"
        or event == "CRAFT_SHOW" or event == "CRAFT_UPDATE" then
        pcall(CacheTradeSkill)
    elseif event == "UNIT_SPELLCAST_SENT" then
        -- The node's name, for when the loot window can't say which node it was
        local unit, target, _, spellId = ...
        if unit == "player" and spellId and not IsSecret(spellId) and not IsSecret(target) then
            Build()
            if GatherOf(spellId) then sentNode = target end
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellId = ...
        OnSpellSucceeded(unit, spellId)
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        local unit, _, spellId = ...
        if unit ~= "player" or not spellId or IsSecret(spellId) then return end
        Build()
        GatherOf(spellId)   -- (fills fishingName)
        if spellId == FISHING_SPELL or (fishingName and SpellName(spellId) == fishingName) then
            fishedAt = GetTime()
        end
    end
end)

if hooksecurefunc and GameTooltip.SetTradeSkillItem then
    hooksecurefunc(GameTooltip, "SetTradeSkillItem", function(tooltip, index)
        if GetTradeSkillInfo then OnRecipeTooltip(tooltip, (GetTradeSkillInfo(index))) end
    end)
end
if hooksecurefunc and GameTooltip.SetCraftItem then
    hooksecurefunc(GameTooltip, "SetCraftItem", function(tooltip, index)
        if GetCraftInfo then OnRecipeTooltip(tooltip, (GetCraftInfo(index))) end
    end)
end
