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
-- DAILY CHALLENGE
-- Every player gets the same opponent and mutators each UTC day (seeded from the UTC date, so
-- the server's clock decides, not the computer's), plays it with their own deck as often as
-- they like, and earns one Dungeons pack for the day's first win.
-- The reward resets at local midnight, as the campfire and the daily dungeon pack do, so the
-- seed day (UTC) and the reward day (local) can differ by a few hours; the panel shows both.
-- TTS_Daily = { wonDay = "<local date of the last rewarded win>" }
-- The window is UI\DailyPanel.lua; the win itself comes through CoreEngine.lua's EndMatch.
-- =========================================================================
local D = {}
TTS.Daily = D

D.LIFE_BONUS = 5           -- on top of the encounter's own life
D.DUNGEON_CHANCE = 1 / 3   -- how often the day's opponent is a dungeon rather than a zone
D.PACK = "dungeon"

local function Now() return (GetServerTime and GetServerTime()) or time() end

local function Store()
    if type(TTS_Daily) ~= "table" then TTS_Daily = {} end
    return TTS_Daily
end

-- The UTC date the challenge is seeded from, and the local date its reward counts on
function D:SeedDay() return date("!%Y-%m-%d", Now()) end
function D:RewardDay() return date("%Y-%m-%d", Now()) end

-- Seconds until a new challenge (UTC midnight)
function D:NextChallengeWait()
    return 86400 - (Now() % 86400)
end

-- Seconds until the reward can be won again (local midnight), or nil while it's still to be won
function D:RewardWait()
    if not self:RewardClaimed() then return nil end
    local now = Now()
    local t = date("*t", now)
    t.day, t.hour, t.min, t.sec = t.day + 1, 0, 0, 0
    return math.max(0, time(t) - now)
end

function D:RewardClaimed()
    return Store().wonDay == self:RewardDay()
end

-- =========================================================================
-- TODAY'S ENCOUNTER: a pure function of the UTC date
-- =========================================================================
local function Copy(list)
    local out = {}
    for i, v in ipairs(list or {}) do out[i] = v end
    return out
end

local cache   -- { day = "<seed day>", enc = encounter }

function D:GetEncounter()
    local day = self:SeedDay()
    if cache and cache.day == day then return cache.enc end
    local rng = TTS.NewRng(TTS.StableHash("daily:" .. day))

    -- Every zone and dungeon, locked ones included: the Daily is open to all
    local zones, dungeons = TTS:GetSoloEncounters("zone"), TTS:GetSoloEncounters("dungeon")
    local isDungeon = #dungeons > 0 and rng() < self.DUNGEON_CHANCE
    local list = isDungeon and dungeons or zones
    local src = list[rng(#list)]

    local ai = isDungeon and "expert" or (rng(2) == 1 and "tactical" or "expert")

    -- 1 curse (Tyrannical only against a dungeon: zones have no bosses) and 1 twist
    local curses = {}
    for _, id in ipairs(TTS.MUTATOR_CURSES) do
        local rule = TTS.EncounterRules[id]
        if isDungeon or not (rule and rule.milestoneOnly) then table.insert(curses, id) end
    end
    local curse = curses[rng(#curses)]
    local twist = TTS.MUTATOR_TWISTS[rng(#TTS.MUTATOR_TWISTS)]

    local rules = Copy(src.rules)
    table.insert(rules, curse)
    table.insert(rules, twist)

    local enc = {
        id = "DAILY", kind = "daily", order = 0,
        name = src.name, zone = src.zone, opponent = src.opponent, bosses = src.bosses,
        life = (src.life or 20) + self.LIFE_BONUS, ai = ai, rules = rules,
        background = src.background,
        -- The encounter's own 40-card deck (built as the source would build it)
        deck = TTS.Engine:BuildEncounterDeck(src),
        source = src.id, curse = curse, twist = twist, day = day,
    }
    cache = { day = day, enc = enc }
    return enc
end

-- The day's mutators (curse, twist) as display lines: { name, text, kind }
function D:MutatorLines(enc)
    enc = enc or self:GetEncounter()
    local lines = {}
    for _, id in ipairs({ enc.curse, enc.twist }) do
        local rule = TTS.EncounterRules[id]
        if rule then
            table.insert(lines, {
                name = TTS.Locale:Data("rule." .. id .. ".name", rule.name),
                text = TTS.Locale:Data("rule." .. id .. ".text", rule.text),
                kind = rule.mutator,
            })
        end
    end
    return lines
end

-- =========================================================================
-- PLAYING IT
-- =========================================================================
-- Why the Daily can't be started now, or nil
function D:StartBlocker()
    return TTS:SoloStartBlocker(self:GetEncounter())
end

-- The deck picker, then the match. onCancel: the picker was closed (the panel comes back).
function D:Start(onCancel)
    local enc = self:GetEncounter()
    local blocker = self:StartBlocker()
    if blocker then return false, blocker end
    local opponent = TTS:EncounterOpponent(enc)
    TTS.DeckPicker:Open({
        opponent = opponent,
        onPick = function()
            if TTS.Engine.inMatch then return end
            TTS.Engine:StartMatch(opponent, true, true, enc)
        end,
        onCancel = function()
            if not TTS.Engine.inMatch and onCancel then onCancel() end
        end,
    })
    return true
end

-- From CoreEngine.lua EndMatch: the result line for the popup (nil for none)
function D:OnMatchEnd(enc, outcome)
    local line
    if outcome == "won" then
        if self:RewardClaimed() then
            line = L("daily.result.already")
        else
            Store().wonDay = self:RewardDay()
            if TTS.Packs then TTS.Packs:Give(self.PACK, L("daily.from")) end
            line = L("daily.result.pack", TTS.Packs and TTS.Packs:Name(self.PACK) or "")
        end
    elseif outcome == "lost" or outcome == "conceded" then
        line = L("daily.result.lost")
    end
    return line
end

do
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(self, event, name)
        if name ~= "ForeverCCG" then return end
        self:UnregisterAllEvents()
        Store()
    end)
end
