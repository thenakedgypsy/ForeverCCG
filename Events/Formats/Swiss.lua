--[[
    ForeverCCG Events
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.
]]
local _, ns = ...
local T = ns.Tournament

-- =========================================================================
-- SWISS
-- Everyone plays every round, paired with someone on the same record and never the same
-- opponent twice. With an odd number of players, the lowest-ranked player without a bye gets
-- one. If nobody can be paired without a rematch (a small event played for many rounds), a
-- rematch is allowed rather than leaving the round unpaired.
-- =========================================================================
local Swiss = { allowDraw = true }
T.FORMATS.swiss = Swiss

local SEARCH_LIMIT = 20000   -- steps of the pairing search before settling for a rematch

function Swiss.TotalRounds(ev, n)
    local chosen = ev.settings.rounds
    if chosen and chosen > 0 then return chosen end
    return T.Log2Ceil(n)
end

function Swiss.IsOver(ev)
    return #ev.rounds >= ev.totalRounds or #T.Active(ev) < T.MIN_PLAYERS
end

-- Pairs everyone in list, each with the nearest player they may meet. Returns the pairs, or nil.
local function Solve(list, stats, allowRematch)
    local used, found, steps = {}, {}, 0

    local function Step(i)
        while i <= #list and used[list[i]] do i = i + 1 end
        if i > #list then return true end
        local a = list[i]
        used[a] = true
        for j = i + 1, #list do
            local b = list[j]
            if not used[b] and (allowRematch or not stats[a].played[b]) then
                steps = steps + 1
                if steps > SEARCH_LIMIT then break end
                used[b] = true
                found[#found + 1] = { a = a, b = b }
                if Step(i + 1) then return true end
                found[#found] = nil
                used[b] = nil
            end
        end
        used[a] = nil
        return false
    end

    if Step(1) then return found end
    return nil
end

-- list without the player at index skip
local function Without(list, skip)
    local out = {}
    for i, key in ipairs(list) do
        if i ~= skip then out[#out + 1] = key end
    end
    return out
end

local function PairOdd(ranked, stats)
    for _, allowRematch in ipairs({ false, true }) do
        for _, needNoBye in ipairs({ true, false }) do
            for i = #ranked, 1, -1 do
                if not needNoBye or stats[ranked[i]].byes == 0 then
                    local found = Solve(Without(ranked, i), stats, allowRematch)
                    if found then
                        found[#found + 1] = { a = ranked[i] }
                        return found
                    end
                end
            end
        end
    end
    return {}
end

function Swiss.Pair(ev)
    local stats = T.Stats(ev)
    local ranked, tie = {}, {}
    for _, p in ipairs(T.Active(ev)) do
        ranked[#ranked + 1] = p.key
        tie[p.key] = math.random()   -- players on the same points meet at random
    end
    table.sort(ranked, function(a, b)
        if stats[a].points ~= stats[b].points then return stats[a].points > stats[b].points end
        return tie[a] < tie[b]
    end)
    if #ranked % 2 == 1 then return PairOdd(ranked, stats) end
    return Solve(ranked, stats, false) or Solve(ranked, stats, true) or {}
end

function Swiss.Standings(ev, stats)
    local rows = T.BaseRows(ev, stats)
    table.sort(rows, function(a, b)
        if a.points ~= b.points then return a.points > b.points end
        if a.omw ~= b.omw then return a.omw > b.omw end
        if a.gwp ~= b.gwp then return a.gwp > b.gwp end
        if a.seed ~= b.seed then return a.seed < b.seed end
        return a.key < b.key
    end)
    return rows
end
