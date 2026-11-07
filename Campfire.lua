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
-- CAMPFIRE WARMTH
-- Two players who finish a PvP game against each other at the same campfire each get an
-- hour of better card-copy drops (BossTracker.lua RecordMobKill), once a day per account.
--
-- At the start of a game (E:StartMatch) each client looks for a campfire aura on itself
-- and, if it has one, sends ACTION:CAMPFIRE:<map>:<x>:<y> (UnitPosition, in yards). The other
-- compares it with its own: both at a fire, on the same map, within RANGE yards. Only the
-- start counts; the game then has to finish (won, lost or conceded, not a disconnect).
--
-- The bonus is rolled when it is given (+MIN_BONUS% to +MAX_BONUS%, relative: chance *
-- (1 + bonus/100)) and never shown. That it is running is: chat lines when it starts, at
-- REMINDERS minutes left and when it fades, plus a line in the minimap button's tooltip.
-- The hour runs on the real clock (the server's), logged in or not. The day resets at local
-- midnight. Saved account-wide in TTS_Campfire.
-- =========================================================================
TTS.Campfire = {}
local C = TTS.Campfire

-- Welcoming Campfire (1229739) is what a Forever campfire gives: 60 s, put back on while
-- near the fire; Campfire Nearby (1283391) is Forever's other one. The Cozy Fire auras
-- (7353, 7358, 1232234) are the classic ones, from a Basic Campfire. Camp Benefits
-- (1229741, 2 h) lingers after leaving, so doesn't count.
local FIRE_AURAS = { 1229739, 1283391, 7353, 7358, 1232234 }
local RANGE = 15             -- yards between the two players
local DURATION = 3600        -- seconds
local MIN_BONUS, MAX_BONUS = 10, 69
local REMINDERS = { 50, 40, 30, 20, 10, 5, 4, 3, 2, 1 }   -- minutes left
C.RANGE = RANGE

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end

local function IsSecret(v) return issecretvalue and issecretvalue(v) or false end

local function DB()
    if type(TTS_Campfire) ~= "table" then TTS_Campfire = {} end
    return TTS_Campfire
end

-- The server clock, as SoloEncounters.lua and NpcGossip.lua use: changing the PC clock
-- neither restarts the day nor stretches the hour
local function Now() return (GetServerTime and GetServerTime()) or time() end
local function Today() return date("%Y-%m-%d", Now()) end

-- =========================================================================
-- WHERE WE ARE
-- =========================================================================
local function HasFireAura()
    local U = C_UnitAuras
    if not U then return false end
    if U.GetPlayerAuraBySpellID then
        for _, id in ipairs(FIRE_AURAS) do
            local ok, aura = pcall(U.GetPlayerAuraBySpellID, id)
            if ok and aura then return true end
        end
    end
    if U.GetAuraDataByIndex then
        local wanted = {}
        for _, id in ipairs(FIRE_AURAS) do wanted[id] = true end
        for i = 1, 40 do
            local ok, aura = pcall(U.GetAuraDataByIndex, "player", i, "HELPFUL")
            if not ok or not aura then break end
            local id = aura.spellId
            if id and not IsSecret(id) and wanted[id] then return true end
        end
    end
    return false
end

-- map (instance id), x, y in yards; nil where the client won't say (e.g. inside instances)
local function MyPosition()
    if not UnitPosition then return nil end
    local ok, y, x, _, map = pcall(UnitPosition, "player")
    if not ok or not (x and y and map) or IsSecret(x) or IsSecret(y) or IsSecret(map) then return nil end
    return map, x, y
end

-- Ours at the start of this game: { map, x, y }, or nil when not at a fire
local function Snapshot()
    if not HasFireAura() then return nil end
    local map, x, y = MyPosition()
    if not map then return nil end
    return { map = map, x = x, y = y }
end

-- =========================================================================
-- THE BONUS
-- =========================================================================
-- Seconds left, or nil when no bonus is running
function C:Remaining()
    local db = DB()
    local left = db.endsAt and (db.endsAt - Now())
    if left and left > 0 then return left end
    return nil
end

-- What copy-drop chances are multiplied by (BossTracker.lua)
function C:DropMultiplier()
    if not self:Remaining() then return 1 end
    return 1 + (tonumber(DB().bonus) or 0) / 100
end

-- Can this account still get today's bonus?
local function CanEarn()
    local db = DB()
    return db.day ~= Today() and not C:Remaining()
end

local function MinutesText(m)
    return L(m == 1 and "campfire.minute" or "campfire.minutes", m)
end

-- Reminders: db.mark is the index in REMINDERS of the next one to say
local ticker
local function StopTicker()
    if ticker then ticker:Cancel() end
    ticker = nil
end

local function Tick()
    local db = DB()
    local left = db.endsAt and (db.endsAt - Now())
    if not left then StopTicker() return end
    if left <= 0 then
        db.endsAt, db.bonus, db.mark = nil, nil, nil
        StopTicker()
        Print(L("campfire.faded"))
        return
    end
    local i, said = db.mark or 1, nil
    while REMINDERS[i] and left <= REMINDERS[i] * 60 do
        said = REMINDERS[i]
        i = i + 1
    end
    db.mark = i
    if said then Print(L("campfire.left", MinutesText(said))) end
end

local function StartTicker()
    if ticker or not (C_Timer and C_Timer.NewTicker) then return end
    ticker = C_Timer.NewTicker(1, Tick)
end

local function Grant()
    local db = DB()
    db.day = Today()
    db.endsAt = Now() + DURATION
    db.bonus = math.random(MIN_BONUS, MAX_BONUS)
    db.mark = 1
    Print(L("campfire.granted"))
    StartTicker()
end

-- =========================================================================
-- DURING A GAME
-- =========================================================================
-- E:StartMatch, every game: look for a fire and tell a PvP opponent where ours is
function C:BeginMatch(isSolo, opponent)
    self.mine, self.shared = nil, false
    if isSolo or not opponent then return end
    self.mine = Snapshot()
    local m = self.mine
    if m and TTS.Net then
        TTS.Net:Send(opponent, string.format("ACTION:CAMPFIRE:%s:%d:%d", tostring(m.map), math.floor(m.x + 0.5), math.floor(m.y + 0.5)))
    end
end

-- Their ACTION:CAMPFIRE (Network.lua): at a fire, here
function C:SetTheirs(map, x, y)
    local m = self.mine
    x, y = tonumber(x), tonumber(y)
    if not (m and x and y) or tostring(m.map) ~= tostring(map) then return end
    local dx, dy = m.x - x, m.y - y
    if dx * dx + dy * dy > RANGE * RANGE then return end
    if self.shared then return end
    self.shared = true
    -- Said only when finishing the game would give the bonus
    local E = TTS.Engine
    if E and CanEarn() then E:Log(L("campfire.sharing", E.opponent or ""), "SYSTEM") end
end

-- E:EndMatch, after a finished PvP game (not a disconnect)
function C:MatchFinished()
    local shared = self.shared
    self.mine, self.shared = nil, false
    if not shared then return end
    if CanEarn() then
        Grant()
    else
        Print(L("campfire.usedToday"))
    end
end

-- =========================================================================
-- LOGIN: one line with the time left, then the reminders carry on
-- =========================================================================
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    local db = DB()
    local left = C:Remaining()
    if not left then
        db.endsAt, db.bonus, db.mark = nil, nil, nil
        return
    end
    -- Reminders already due are skipped, not said late
    local i = 1
    while REMINDERS[i] and left <= REMINDERS[i] * 60 do i = i + 1 end
    db.mark = i
    Print(L("campfire.left", MinutesText(math.ceil(left / 60))))
    StartTicker()
end)
