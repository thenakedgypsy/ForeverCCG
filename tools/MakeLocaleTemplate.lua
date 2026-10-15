--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
]]
-- =========================================================================
-- LANGUAGE TEMPLATE GENERATOR (not part of the addon; run outside the game)
--   lua5.1 tools/MakeLocaleTemplate.lua [addonDir] [outFile]
-- Writes every translatable key with its English text: the UI strings in
-- Languages\enUS.lua plus the English that lives in the data (card names and
-- rules text, keywords, effects, symbols, zones, factions, creature types,
-- solo opponents and boss rules). Copy the output to <code>.lua in
-- ForeverCCG_Languages, set CODE and translate the values; lines left in
-- English (or deleted) simply show in English.
-- =========================================================================
local dir = arg[1] or "."
local outPath = arg[2] or (dir .. "/../ForeverCCG_Languages/_Template.lua")

-- Minimal WoW stand-ins: every frame / API call returns something harmless
local M = {}
local function Stub() return setmetatable({}, M) end
M.__index = function(t, k)
    if type(k) == "string" and (k:match("^Get") or k:match("^Is")) then return function() return 0 end end
    return function() return Stub() end
end
M.__call = function() return Stub() end
M.__concat = function(a, b) return tostring(a) .. tostring(b) end
for _, op in ipairs({ "__add", "__sub", "__mul", "__div", "__unm", "__lt", "__le" }) do M[op] = function() return 0 end end
setmetatable(_G, { __index = function(_, k)
    -- Blizzard globals become stand-ins; the addon's own (TTS...) start out empty
    if type(k) == "string" and k:match("^[A-Z]") and not k:match("^TTS") then return Stub() end
end })
CreateFrame = function() return Stub() end
GetLocale = function() return "enUS" end
C_AddOns = { GetAddOnMetadata = function() return nil end }
StaticPopupDialogs = {}
SlashCmdList = {}
UISpecialFrames = {}
tinsert = table.insert
hooksecurefunc = function() end
string.trim = function(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end

-- Load the addon's files as the .toc lists them (UI files only for their tables)
for line in io.lines(dir .. "/ForeverCCG.toc") do
    line = line:gsub("\r", "")
    if line ~= "" and not line:match("^#") then
        local chunk = loadfile(dir .. "/" .. line:gsub("\\", "/"))
        if chunk then pcall(chunk) end
    end
end

local entries, seen = {}, {}
local function Add(section, key, english)
    if english == nil or english == "" or seen[key] then return end
    seen[key] = true
    entries[#entries + 1] = { section = section, key = key, text = english }
end

-- 1. UI strings, in enUS.lua's own order
local order = {}
for line in io.lines(dir .. "/Languages/enUS.lua") do
    local key = line:match('^S%["([^"]+)"%]')
    if key then order[#order + 1] = key end
end
for _, key in ipairs(order) do Add("Interface", key, TTS.Locale.enUS[key]) end

-- 2. Cards, by id
local ids = {}
for id in pairs(TTS.Cards) do ids[#ids + 1] = id end
table.sort(ids)
for _, id in ipairs(ids) do
    local c = TTS.Cards[id]
    Add("Cards", "card." .. id .. ".name", c.name)
    Add("Cards", "card." .. id .. ".text", c.text)
end

-- 3. Labels taken from card data
local groups = { creatureType = "creatureType", faction = "faction", zone = "zone" }
for _, field in ipairs({ "zone", "faction", "creatureType" }) do
    local values = {}
    for _, c in pairs(TTS.Cards) do if c[field] then values[c[field]] = true end end
    local list = {}
    for v in pairs(values) do list[#list + 1] = v end
    table.sort(list)
    for _, v in ipairs(list) do Add("Card labels", groups[field] .. "." .. v, v) end
end

-- Class names: the game client supplies these in its own language, so only a language
-- the client doesn't have (e.g. Italian on Classic) needs them
do
    local classes = {}
    for _, c in pairs(TTS.Cards) do if c.class then classes[c.class] = true end end
    local list = {}
    for v in pairs(classes) do list[#list + 1] = v end
    table.sort(list)
    for _, v in ipairs(list) do Add("Card labels", "class." .. v, v) end
end

-- 4. Keywords, symbols and effects (UI\Tooltips.lua)
local TT = TTS.Tooltip or {}
for _, g in ipairs({ { "keyword", TT.KEYWORDS }, { "symbol", TT.SYMBOLS }, { "effect", TT.EFFECTS } }) do
    local keys = {}
    for k in pairs(g[2] or {}) do keys[#keys + 1] = k end
    table.sort(keys)
    for _, k in ipairs(keys) do
        Add("Keywords & effects", g[1] .. "." .. k .. ".name", g[2][k].name)
        Add("Keywords & effects", g[1] .. "." .. k .. ".text", g[2][k].text)
    end
end
for _, tag in ipairs({ "Keyword", "Effect", "Ability", "Status", "Symbol", "Equipment", "Enchantment", "Affected by" }) do
    Add("Keywords & effects", "tt.tag." .. tag, tag)
end
for _, stage in ipairs({ "keywords", "effects", "symbols", "the symbol", "the effect" }) do
    Add("Keywords & effects", "tt.stage." .. stage, stage)
end

-- 5. Solo mode: zone teams and boss rules
local encIds = {}
for id, enc in pairs(TTS.SoloEncounters or {}) do
    if enc.kind == "zone" then encIds[#encIds + 1] = id end
end
table.sort(encIds)
for _, id in ipairs(encIds) do Add("Solo", "encounter." .. id .. ".opponent", TTS.SoloEncounters[id].opponent) end
local rules = {}
for id in pairs(TTS.EncounterRules or {}) do rules[#rules + 1] = id end
table.sort(rules)
for _, id in ipairs(rules) do
    Add("Solo", "rule." .. id .. ".name", TTS.EncounterRules[id].name)
    Add("Solo", "rule." .. id .. ".text", TTS.EncounterRules[id].text)
end

-- Write the template
local function Quote(s)
    return '"' .. s:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n") .. '"'
end
local out = {
    "--[[",
    "    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy",
    "    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.",
    "",
    "    This file is part of ForeverCCG. See LICENSE.txt for terms.",
    "    World of Warcraft names, creatures, icons and models are the property of",
    "    Blizzard Entertainment, Inc. and are not claimed by this notice.",
    "]]",
    "-- =========================================================================",
    "-- LANGUAGE TEMPLATE (not loaded; generated by tools\\MakeLocaleTemplate.lua)",
    "-- Copy to <code>.lua (e.g. deDE.lua), set CODE, list the file in",
    "-- ForeverCCG_Languages.toc and add the code to its ## X-Languages line.",
    "-- Translate the values; anything left out shows in English.",
    "-- Keep {T}, {W}, {2} etc., colour codes (|cFF......|r) and %s / %d as they",
    "-- are; %1$s, %2$s change their order. Keys ending .one / .other are the",
    "-- singular and plural forms.",
    "-- =========================================================================",
    'local CODE = "xxXX"',
    "if TTS.Locale.wanted ~= CODE then return end",
    "",
    "TTS.Locale:Register(CODE, {",
}
local section
for _, e in ipairs(entries) do
    if e.section ~= section then
        section = e.section
        out[#out + 1] = ""
        out[#out + 1] = "    -- " .. section:upper()
    end
    out[#out + 1] = "    [" .. Quote(e.key) .. "] = " .. Quote(e.text) .. ","
end
out[#out + 1] = "})"
out[#out + 1] = ""

local f = assert(io.open(outPath, "wb"))
f:write(table.concat(out, "\n"))
f:close()
print(string.format("%d keys written to %s", #entries, outPath))
