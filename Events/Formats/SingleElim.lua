--[[
    ForeverCCG Events
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.
]]
local _, ns = ...
local T = ns.Tournament

-- =========================================================================
-- SINGLE ELIMINATION
-- Seeded by rating at check-in. The bracket is the next power of two, so the top seeds get any
-- byes. Round 1 fills every slot of the bracket (byes included), which keeps each later round
-- at exactly half the tables of the one before it. A winner who has since dropped gives their
-- next opponent a bye; if both players due at a table are gone, the table is left empty.
-- =========================================================================
local Single = { allowDraw = false }
T.FORMATS.single = Single

function Single.TotalRounds(_, n)
    return T.Log2Ceil(n)
end

function Single.IsOver(ev)
    return #ev.rounds >= ev.totalRounds
end

-- Seed numbers in bracket order: 8 gives 1,8,4,5,2,7,3,6, so 1 and 2 can only meet in the final
local function SeedOrder(size)
    local order, n = { 1 }, 1
    while n < size do
        n = n * 2
        local nextOrder = {}
        for _, seed in ipairs(order) do
            nextOrder[#nextOrder + 1] = seed
            nextOrder[#nextOrder + 1] = n + 1 - seed
        end
        order = nextOrder
    end
    return order
end

local function FirstRound(ev)
    local bySeed = {}
    for _, p in ipairs(T.Active(ev)) do bySeed[p.seed] = p.key end
    local size = 2 ^ ev.totalRounds
    local order = SeedOrder(size)
    local pairings = {}
    for i = 1, size, 2 do
        local a, b = bySeed[order[i]], bySeed[order[i + 1]]
        if a or b then
            pairings[#pairings + 1] = { a = a or b, b = a and b or nil }
        else
            pairings[#pairings + 1] = { empty = true }
        end
    end
    return pairings
end

-- The winner of a match, if they are still in the event
local function Advancing(ev, m)
    if not m or (m.result ~= "a" and m.result ~= "b") then return nil end
    local key = m[m.result]
    local p = key and ev.players[key]
    if not p or p.status ~= "active" then return nil end
    return key
end

function Single.Pair(ev, number)
    if number == 1 then return FirstRound(ev) end
    local previous = ev.rounds[number - 1].matches
    local pairings = {}
    for i = 1, #previous, 2 do
        local x, y = Advancing(ev, previous[i]), Advancing(ev, previous[i + 1])
        if x or y then
            pairings[#pairings + 1] = { a = x or y, b = x and y or nil }
        else
            pairings[#pairings + 1] = { empty = true }
        end
    end
    return pairings
end

-- Furthest in the bracket first; the same round lost goes by seed
function Single.Standings(ev, stats)
    local rows = T.BaseRows(ev, stats)
    local reached = {}
    for _, round in ipairs(ev.rounds) do
        for _, m in ipairs(round.matches) do
            for _, side in ipairs({ "a", "b" }) do
                local key = m[side]
                if key then
                    local progress = round.number * 2 + (m.result == side and 1 or 0)
                    reached[key] = math.max(reached[key] or 0, progress)
                end
            end
        end
    end
    table.sort(rows, function(a, b)
        local ra, rb = reached[a.key] or 0, reached[b.key] or 0
        if ra ~= rb then return ra > rb end
        if a.seed ~= b.seed then return a.seed < b.seed end
        return a.key < b.key
    end)
    return rows
end
