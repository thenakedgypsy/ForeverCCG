--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
]]
-- =========================================================================
-- TRANSLATED GAME NAMES (not part of the addon; run outside the game)
--   lua5.1 tools/GameNames.lua <addonDir> ids            what to fetch: "npc <id>" / "zone <id>" lines
--   lua5.1 tools/GameNames.lua <addonDir> build <cache>  write the language files
-- (tools/FetchGameNames.sh runs both and does the fetching in between.)
--
-- Creature cards are named after a creature (its npcId, else tools/CreatureIds.lua),
-- class spell cards after a spell (tools/SpellIds.lua), zones after an area (ZONE_IDS
-- below). cache/<site>/<id>.json (creatures), cache/<site>/spell-<id>.json and
-- cache/<site>/zone-<id>.json hold Wowhead's tooltip JSON, which carries the name.
-- Writes ForeverCCG_Languages/<code>_GameNames.lua with card.<ID>.name and
-- zone.<English> keys. A card is only given the creature's name when its English
-- card name is that creature's real name; the rest are listed to translate by hand.
-- =========================================================================
local dir, mode, cache = arg[1], arg[2], arg[3]

-- Wowhead site per language. Classic has no Italian client, so Italian names come
-- from the retail site (same creature and area ids).
local SITES = {
    { site = "de", code = "deDE" }, { site = "fr", code = "frFR" }, { site = "es", code = "esES" },
    { site = "cn", code = "zhCN" }, { site = "it", code = "itIT" },
}

-- Area ids of every zone / dungeon the cards and solo encounters name
local ZONE_IDS = {
    ["Alterac Mountains"] = 36, ["Arathi Highlands"] = 45, ["Ashenvale"] = 331, ["Azshara"] = 16,
    ["Badlands"] = 3, ["Blackfathom Deeps"] = 719, ["Blackrock Depths"] = 1584, ["Blackrock Spire"] = 1583,
    ["Blasted Lands"] = 4, ["Burning Steppes"] = 46, ["Darkshore"] = 148, ["Desolace"] = 405,
    ["Dire Maul"] = 2557, ["Dun Morogh"] = 1, ["Durotar"] = 14, ["Duskwood"] = 10,
    ["Dustwallow Marsh"] = 15, ["Eastern Plaguelands"] = 139, ["Elwynn Forest"] = 12, ["Felwood"] = 361,
    ["Feralas"] = 357, ["Gnomeregan"] = 721, ["Hillsbrad Foothills"] = 267, ["Loch Modan"] = 38,
    ["Maraudon"] = 2100, ["Mulgore"] = 215, ["Ragefire Chasm"] = 2437, ["Razorfen Downs"] = 722,
    ["Razorfen Kraul"] = 491, ["Redridge Mountains"] = 44, ["Scarlet Monastery"] = 796, ["Scholomance"] = 2057,
    ["Searing Gorge"] = 51, ["Shadowfang Keep"] = 209, ["Silithus"] = 1377, ["Silverpine Forest"] = 130,
    ["Stonetalon Mountains"] = 406, ["Stranglethorn Vale"] = 33, ["Stratholme"] = 2017, ["Sunken Temple"] = 1477,
    ["Swamp of Sorrows"] = 8, ["Tanaris"] = 440, ["Teldrassil"] = 141, ["The Barrens"] = 17,
    ["The Deadmines"] = 1581, ["The Hinterlands"] = 47, ["The Stockade"] = 717, ["Thousand Needles"] = 400,
    ["Tirisfal Glades"] = 85, ["Uldaman"] = 1337, ["Un'Goro Crater"] = 490, ["Wailing Caverns"] = 718,
    ["Western Plaguelands"] = 28, ["Westfall"] = 40, ["Wetlands"] = 11, ["Winterspring"] = 618,
    ["Zul'Farrak"] = 1176,
}

-- WoW Forever's new dungeons exist only on Wowhead's Forever pages: their zones, and the
-- creatures of cards in them, are fetched from there (cache files fv-<id> / fvzone-<id>)
local FOREVER_ZONE_IDS = {
    ["The Hall of Thanes"] = 16919, ["Ruins of Lordaeron"] = 16611, ["Excavation Site"] = 16732,
}

TTS = {}
function TTS:AddCards(t) for id, c in pairs(t) do TTS.Cards[id] = c end end
CreateFrame = function() return setmetatable({}, { __index = function() return function() end end }) end
for line in io.lines(dir .. "/ForeverCCG.toc") do
    line = line:gsub("\r", "")
    if line:match("^Cards\\") then assert(loadfile(dir .. "/" .. line:gsub("\\", "/")))() end
end

-- "name" field of the tooltip JSON, with \uXXXX escapes turned into UTF-8
local function Utf8(cp)
    if cp < 0x80 then return string.char(cp) end
    if cp < 0x800 then return string.char(0xC0 + math.floor(cp / 64), 0x80 + cp % 64) end
    return string.char(0xE0 + math.floor(cp / 4096), 0x80 + math.floor(cp / 64) % 64, 0x80 + cp % 64)
end
local function ReadName(site, file)
    local f = io.open(cache .. "/" .. site .. "/" .. file .. ".json", "rb")
    if not f then return nil end
    local s = f:read("*a"); f:close()
    local raw = s:match('^{"name":"(.-[^\\])"')
    -- Wowhead shows an untranslated name as "[English Name]"
    if not raw or raw:match("^%[.*%]$") then return nil end
    raw = raw:gsub("\\u(%x%x%x%x)", function(h) return Utf8(tonumber(h, 16)) end)
    raw = raw:gsub('\\(["\\/])', "%1")
    -- Some translated zones carry the English name as a hint: "Les Paluns (Wetlands)"
    raw = raw:gsub(" %([%w%s'%.%-]+%)$", "")
    return raw
end

-- Every creature card with the creature it is named after
local extraIds = dofile(dir .. "/tools/CreatureIds.lua")
local cards, unmapped = {}, {}
for id, card in pairs(TTS.Cards) do
    if card.type == "Creature" then
        local npc = card.npcId or card.npcEntry or extraIds[id]
        if not npc then
            unmapped[#unmapped + 1] = id
        elseif FOREVER_ZONE_IDS[card.zone] then
            cards[#cards + 1] = { card = id, file = "fv-" .. npc, kind = "fvnpc", id = npc }
        else
            cards[#cards + 1] = { card = id, file = tostring(npc), kind = "npc", id = npc }
        end
    end
end
table.sort(cards, function(a, b) return a.card < b.card end)

-- Every zone a card names, plus any listed above (solo encounters)
local zones = {}
do
    local seen = {}
    for _, card in pairs(TTS.Cards) do
        if card.zone and not seen[card.zone] then seen[card.zone] = true end
    end
    for name in pairs(ZONE_IDS) do seen[name] = true end
    for name in pairs(seen) do
        if ZONE_IDS[name] then
            zones[#zones + 1] = { zone = name, file = "zone-" .. ZONE_IDS[name], kind = "zone", id = ZONE_IDS[name] }
        elseif FOREVER_ZONE_IDS[name] then
            zones[#zones + 1] = { zone = name, file = "fvzone-" .. FOREVER_ZONE_IDS[name], kind = "fvzone", id = FOREVER_ZONE_IDS[name] }
        else
            io.stderr:write("no area id for zone \"" .. name .. "\" (add it to ZONE_IDS)\n")
        end
    end
    table.sort(zones, function(a, b) return a.zone < b.zone end)
end

-- Class spell cards, named after the WoW spell in tools/SpellIds.lua
local spellIds = dofile(dir .. "/tools/SpellIds.lua")
local retailIds = spellIds.RETAIL or {}
local spells = {}
for id, card in pairs(TTS.Cards) do
    if card.class then
        local sid = spellIds[id]
        if sid then spells[#spells + 1] = { card = id, file = "spell-" .. sid, retail = retailIds[sid] and "rtspell-" .. retailIds[sid] }
        else io.stderr:write("no spell id for " .. id .. " (add it to tools/SpellIds.lua)\n") end
    end
end
table.sort(spells, function(a, b) return a.card < b.card end)

if mode == "ids" then
    local seen = {}
    for _, c in ipairs(cards) do
        if not seen[c.file] then seen[c.file] = true; print(c.kind .. " " .. c.id) end
    end
    for _, z in ipairs(zones) do print(z.kind .. " " .. z.id) end
    for _, s in ipairs(spells) do
        print("spell " .. s.file:sub(7))
        if s.retail then print("rtspell " .. s.retail:sub(9)) end
    end
    for _, id in ipairs(unmapped) do io.stderr:write("no npc id for " .. id .. " (add it to tools/CreatureIds.lua)\n") end
    return
end
assert(mode == "build" and cache, "usage: GameNames.lua <addonDir> ids | build <cacheDir>")

local results = {}
for _, s in ipairs(SITES) do results[s.code] = {} end
local renamed, missing, zoneNotes = {}, {}, {}
for _, c in ipairs(cards) do
    local card = TTS.Cards[c.card]
    local en = ReadName("en", c.file)
    if not en then
        missing[#missing + 1] = c.card .. " (npc " .. c.file .. ")"
    elseif en ~= card.name then
        renamed[#renamed + 1] = string.format("%s  card \"%s\"  npc %s \"%s\"", c.card, card.name, c.file, en)
    else
        for _, s in ipairs(SITES) do
            local name = ReadName(s.site, c.file)
            if name and name ~= "" and name ~= en then
                table.insert(results[s.code], { key = "card." .. c.card .. ".name", name = name })
            end
        end
    end
end
-- Zone ids are chosen by hand, so a differently worded English name (e.g. Sunken Temple
-- vs The Temple of Atal'Hakkar) still takes that area's translated name
for _, z in ipairs(zones) do
    local en = ReadName("en", z.file)
    if not en then
        missing[#missing + 1] = z.zone .. " (" .. z.file .. ")"
    else
        if en ~= z.zone then zoneNotes[#zoneNotes + 1] = string.format("\"%s\" is \"%s\" on Wowhead", z.zone, en) end
        for _, s in ipairs(SITES) do
            local name = ReadName(s.site, z.file)
            if name and name ~= "" and name ~= en then
                table.insert(results[s.code], { key = "zone." .. z.zone, name = name })
            end
        end
    end
end

-- Spell ids were matched by name and class, so a renamed spell (Enslave Demon is now
-- Subjugate Demon) still takes that spell's translated name
for _, sp in ipairs(spells) do
    local card = TTS.Cards[sp.card]
    local en = ReadName("en", sp.file)
    if not en then
        missing[#missing + 1] = sp.card .. " (" .. sp.file .. ")"
    else
        if en ~= card.name then zoneNotes[#zoneNotes + 1] = string.format("spell card \"%s\" is \"%s\" on Wowhead", card.name, en) end
        for _, s in ipairs(SITES) do
            local name = ReadName(s.site, sp.file) or (sp.retail and ReadName(s.site, sp.retail))
            if name and name ~= "" and name ~= card.name then
                table.insert(results[s.code], { key = "card." .. sp.card .. ".name", name = name })
            end
        end
    end
end

local function Quote(s) return '"' .. s:gsub("\\", "\\\\"):gsub('"', '\\"') .. '"' end
for _, s in ipairs(SITES) do
    local list = results[s.code]
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
        "-- CREATURE AND ZONE NAMES (generated by tools\\GameNames.lua; do not edit,",
        "-- put corrections in " .. s.code .. ".lua, which is loaded after this file)",
        "-- The game's own names in this language, so cards match the game world.",
        "-- =========================================================================",
        'local CODE = "' .. s.code .. '"',
        "if TTS.Locale.wanted ~= CODE then return end",
        "",
        "TTS.Locale:Register(CODE, {",
    }
    for _, e in ipairs(list) do
        out[#out + 1] = "    [" .. Quote(e.key) .. "] = " .. Quote(e.name) .. ","
    end
    out[#out + 1] = "})"
    out[#out + 1] = ""
    local path = dir .. "/../ForeverCCG_Languages/" .. s.code .. "_GameNames.lua"
    local f = assert(io.open(path, "wb")); f:write(table.concat(out, "\n")); f:close()
    print(string.format("%s: %d names", s.code, #list))
end
print(string.format("cards named differently from their creature: %d", #renamed))
for _, r in ipairs(renamed) do print("  RENAMED " .. r) end
for _, r in ipairs(zoneNotes) do print("  ZONE " .. r) end
print(string.format("no data: %d", #missing))
for _, r in ipairs(missing) do print("  MISSING " .. r) end
