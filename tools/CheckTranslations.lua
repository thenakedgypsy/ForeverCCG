--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
]]
-- =========================================================================
-- TRANSLATION CHECK (not part of the addon; run outside the game)
--   lua5.1 tools/CheckTranslations.lua [addonDir]
-- For every language file in ForeverCCG_Languages, compares each string with
-- its English (from the generated _Template.lua, so run MakeLocaleTemplate
-- first) and reports keys that don't exist, format specifiers (%s, %d, %.1f)
-- that differ in number or kind, and {X} symbols or colour codes (|c / |r)
-- that went missing. Also lists how much of each language is translated.
-- =========================================================================
local dir = arg[1] or "."
-- The language pack is its own addon, beside ForeverCCG in AddOns
local packDir = dir .. "/../ForeverCCG_Languages"

-- English reference: the template returns its table through Register
local english
TTS = { Locale = { wanted = "xxXX", Register = function(_, _, t) english = t end } }
assert(loadfile(packDir .. "/_Template.lua"))()

local function Specs(s)
    local list = {}
    for spec in s:gmatch("%%[%d%$]*[%-%.%d]*[sdf]") do
        list[#list + 1] = spec:gsub("^%%%d+%$", "%%")  -- %2$s counts as %s
    end
    table.sort(list)
    return table.concat(list, " ")
end
-- Positional specifiers (%2$d) must not be mixed with plain ones, and each must
-- name an argument of the same kind as the English string has in that position
local function PositionProblem(v, en)
    local plain, numbered = 0, 0
    for spec in v:gmatch("%%[%d%$]*[%-%.%d]*[sdf]") do
        if spec:match("^%%%d+%$") then numbered = numbered + 1 else plain = plain + 1 end
    end
    if numbered == 0 then return nil end
    if plain > 0 then return "mixes %n$ with plain specifiers" end
    local kinds = {}
    for spec in en:gmatch("%%[%-%.%d]*([sdf])") do kinds[#kinds + 1] = spec end
    for n, kind in v:gmatch("%%(%d+)%$[%-%.%d]*([sdf])") do
        if kinds[tonumber(n)] ~= kind then return "%" .. n .. "$" .. kind .. " does not match English argument " .. n end
    end
    return nil
end

local function Symbols(s)
    local list = {}
    for sym in s:gmatch("{%w+}") do list[#list + 1] = sym end
    table.sort(list)
    return table.concat(list, " ")
end
local function Count(s, pat) local n = 0 for _ in s:gmatch(pat) do n = n + 1 end return n end

-- Language files, from the pack's toc
local files = {}
for line in io.lines(packDir .. "/ForeverCCG_Languages.toc") do
    line = line:gsub("\r", "")
    if line:match("%.lua$") then files[#files + 1] = line end
end

local byCode, problems = {}, 0
for _, file in ipairs(files) do
    local code = file:match("^(%a%a%a%a)")
    local got
    TTS = { Locale = { wanted = code, Register = function(_, c, t) got = t end } }
    local chunk, err = loadfile(packDir .. "/" .. file)
    if not chunk then print("SYNTAX " .. err); problems = problems + 1 else chunk() end
    byCode[code] = byCode[code] or {}
    for k, v in pairs(got or {}) do
        byCode[code][k] = v
        local en = english[k]
        local where = file .. "  " .. k
        if en == nil then
            print("UNKNOWN KEY  " .. where); problems = problems + 1
        elseif type(v) ~= "string" then
            print("NOT TEXT     " .. where); problems = problems + 1
        else
            if Specs(v) ~= Specs(en) then
                print(string.format("FORMAT       %s  (%s / English %s)", where, Specs(v), Specs(en))); problems = problems + 1
            end
            local pos = PositionProblem(v, en)
            if pos then print("POSITION     " .. where .. "  (" .. pos .. ")"); problems = problems + 1 end
            if Symbols(v) ~= Symbols(en) then
                print(string.format("SYMBOLS      %s  (%s / English %s)", where, Symbols(v), Symbols(en))); problems = problems + 1
            end
            if Count(v, "|c%x%x%x%x%x%x%x%x") ~= Count(en, "|c%x%x%x%x%x%x%x%x") or Count(v, "|r") ~= Count(en, "|r") then
                print("COLOURS      " .. where); problems = problems + 1
            end
        end
    end
end

local total = 0
for _ in pairs(english) do total = total + 1 end
local codes = {}
for code in pairs(byCode) do codes[#codes + 1] = code end
table.sort(codes)
for _, code in ipairs(codes) do
    local n, ui, uiDone = 0, 0, 0
    for k in pairs(english) do
        if not k:match("^card%.") then
            ui = ui + 1
            if byCode[code][k] then uiDone = uiDone + 1
            elseif arg[2] == "missing" then print("MISSING  " .. code .. "  " .. k) end
        end
    end
    for _ in pairs(byCode[code]) do n = n + 1 end
    print(string.format("%s: %d of %d keys (%d of %d outside card names/text)", code, n, total, uiDone, ui))
end
print(problems == 0 and "no problems" or (problems .. " problem(s)"))
