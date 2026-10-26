--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- GEAR (one per zone)
-- Colourless (color "C", generic cost only, the neutral card frame).
-- Spells (subType "Gear") that equip a denizen you control: a lasting buff (op.perm), so
-- the bonus and keywords stay for as long as the denizen does (CardLogic.lua SPELL_OPS.buff,
-- perm.permKw). An enemy Dispel strips them like any lasting buff.
-- Handed out by the zone's weapon merchants like the innkeepers' Hearthstones
-- (isGift, giftNpcs; UI\NpcGossip.lua): Alliance / Horde / Neutral npcIds. Zones without a
-- weapon merchant use the nearest smith, armourer or quartermaster. Their lines are
-- npc.<npcId>.* in Languages\enUS.lua. Never dealt to solo opponents (SoloEncounters.lua).
-- =========================================================================
local function Gear(id, name, cost, cmc, color, zone, npcs, p, t, kw, art, text, extraOps)
    local ops = { { op = "buff", to = "target", p = p, t = t, kw = kw, perm = true } }
    for _, op in ipairs(extraOps or {}) do table.insert(ops, op) end
    return {
        id = id, name = name, cost = cost, cmc = cmc, color = color, type = "Sorcery", subType = "Gear",
        zone = zone, isGift = true, giftNpcs = npcs,
        text = text,
        art = "Interface\\Icons\\" .. art,
        effect = { target = "friendly_creature", ops = ops },
    }
end

TTS:AddCards({
    -- Levels 1-10
    ["GEAR01"] = Gear("GEAR01", "Goldshire Shortsword", "{1}", 1, "C", "Elwynn Forest",
        { Alliance = 54 },   -- Corina Steele, Goldshire
        1, 0, { "support" }, "INV_Sword_04", "Equip: +1/+0 and Support."),
    ["GEAR02"] = Gear("GEAR02", "Kharanos Hand Axe", "{1}", 1, "C", "Dun Morogh",
        { Alliance = 1273 },   -- Grawn Thromwyn, Kharanos
        1, 0, { "haste" }, "INV_Axe_04", "Equip: +1/+0 and Quick."),
    ["GEAR03"] = Gear("GEAR03", "Dolanaar Hunting Spear", "{1}", 1, "C", "Teldrassil",
        { Alliance = 3609 },   -- Shalomon, Dolanaar
        1, 0, { "reach" }, "INV_Spear_02", "Equip: +1/+0 and Anti-Air."),
    ["GEAR04"] = Gear("GEAR04", "Razor Hill Cleaver", "{1}", 1, "C", "Durotar",
        { Horde = 3163 },   -- Uhgar, Razor Hill
        1, 0, { "trample" }, "INV_Axe_09", "Equip: +1/+0 and Brutish."),
    ["GEAR05"] = Gear("GEAR05", "Bloodhoof Totem Club", "{1}", 1, "C", "Mulgore",
        { Horde = 3077 },   -- Mahnott Roughwound, Bloodhoof Village
        0, 1, { "support" }, "INV_Mace_01", "Equip: +0/+1 and Support."),
    ["GEAR06"] = Gear("GEAR06", "Deathguard Dirk", "{1}", 1, "C", "Tirisfal Glades",
        { Horde = 2136 },   -- Oliver Dwor, Brill
        1, 0, { "lifelink" }, "INV_Weapon_ShortBlade_05", "Equip: +1/+0 and Drain."),

    -- Levels 10-20
    ["GEAR07"] = Gear("GEAR07", "Sentinel Hill Longbow", "{2}", 2, "C", "Westfall",
        { Alliance = 1668 },   -- William MacGregor, Sentinel Hill
        1, 1, { "reach" }, "INV_Weapon_Bow_02", "Equip: +1/+1 and Anti-Air."),
    ["GEAR08"] = Gear("GEAR08", "Thelsamar Blunderbuss", "{2}", 2, "C", "Loch Modan",
        { Alliance = 1469 },   -- Vrok Blunderblast, Thelsamar
        2, 0, { "firstStrike" }, "INV_Weapon_Rifle_01", "Equip: +2/+0 and Strikes-First."),
    ["GEAR09"] = Gear("GEAR09", "Auberdine Moonblade", "{2}", 2, "C", "Darkshore",
        { Alliance = 4183 },   -- Naram Longclaw, Auberdine
        1, 1, { "support" }, "INV_Sword_27", "Equip: +1/+1 and Support."),
    ["GEAR10"] = Gear("GEAR10", "Sepulcher Recurve Bow", "{2}", 2, "C", "Silverpine Forest",
        { Horde = 9553 },   -- Nadia Vernon, the Sepulcher
        2, 0, { "reach" }, "INV_Weapon_Bow_04", "Equip: +2/+0 and Anti-Air."),
    ["GEAR11"] = Gear("GEAR11", "Barrens Scimitar", "{2}", 2, "C", "The Barrens",
        { Horde = 3479, Neutral = 3491 },   -- Nargal Deatheye, the Crossroads / Ironzar, Ratchet
        2, 0, { "haste" }, "INV_Sword_19", "Equip: +2/+0 and Quick."),
    ["GEAR12"] = Gear("GEAR12", "Lakeshire Hunting Rifle", "{2}", 2, "C", "Redridge Mountains",
        { Alliance = 3088 },   -- Henry Chapal, Lakeshire
        1, 1, { "firstStrike" }, "INV_Weapon_Rifle_02", "Equip: +1/+1 and Strikes-First."),
    ["GEAR13"] = Gear("GEAR13", "Sun Rock Shortbow", "{3}", 3, "C", "Stonetalon Mountains",
        { Horde = 9549 },   -- Borand, Sun Rock Retreat
        2, 1, { "reach" }, "INV_Weapon_Bow_07", "Equip: +2/+1 and Anti-Air."),

    -- Levels 20-30
    ["GEAR14"] = Gear("GEAR14", "Ashenvale Warglaive", "{3}", 3, "C", "Ashenvale",
        { Alliance = 11137, Horde = 6028 },   -- Xai'ander, Astranaar / Burkrum, Splintertree Post
        2, 1, { "support" }, "INV_Weapon_Halberd_02", "Equip: +2/+1 and Support."),
    ["GEAR15"] = Gear("GEAR15", "Darkshire Silvered Sword", "{3}", 3, "C", "Duskwood",
        { Alliance = 225 },   -- Gavin Gnarltree, Darkshire
        2, 1, { "firstStrike" }, "INV_Sword_31", "Equip: +2/+1 and Strikes-First."),
    ["GEAR16"] = Gear("GEAR16", "Menethil Boarding Axe", "{3}", 3, "C", "Wetlands",
        { Alliance = 1441 },   -- Brak Durnad, Menethil Harbor
        2, 1, { "trample" }, "INV_Axe_11", "Equip: +2/+1 and Brutish."),
    ["GEAR17"] = Gear("GEAR17", "Hillsbrad Militia Pike", "{3}", 3, "C", "Hillsbrad Foothills",
        { Alliance = 3543, Horde = 3539 },   -- Robert Aebischer, Southshore / Ott, Tarren Mill
        1, 2, { "support" }, "INV_Spear_04", "Equip: +1/+2 and Support."),
    ["GEAR18"] = Gear("GEAR18", "Shimmering Flats Boomstick", "{3}", 3, "C", "Thousand Needles",
        { Horde = 9551, Neutral = 3053 },   -- Starn, Freewind Post / Synge, the Shimmering Flats
        2, 0, { "haste", "firstStrike" }, "INV_Weapon_Rifle_06", "Equip: +2/+0, Quick and Strikes-First."),

    -- Levels 30-40
    ["GEAR19"] = Gear("GEAR19", "Kirin Tor Spellblade", "{3}", 3, "C", "Alterac Mountains",
        { Alliance = 275623, Neutral = 32334 },   -- Valaden Silverblade / Nixi Fireclaw, Dalaran
        2, 1, { "hexproof" }, "INV_Sword_10", "Equip: +2/+1 and Warded."),
    ["GEAR20"] = Gear("GEAR20", "Stromgarde Warhammer", "{4}", 4, "C", "Arathi Highlands",
        { Alliance = 1471, Horde = 9555 },   -- Jannos Ironwill, Refuge Pointe / Mu'uta, Hammerfall
        2, 2, { "support" }, "INV_Hammer_05", "Equip: +2/+2 and Support."),
    ["GEAR21"] = Gear("GEAR21", "Kodo-Bone Maul", "{4}", 4, "C", "Desolace",
        { Alliance = 1322, Horde = 12045 },   -- Maxton Strang, Nijel's Point / Hae'Wilani, Shadowprey Village
        2, 2, { "trample" }, "INV_Mace_04", "Equip: +2/+2 and Brutish."),
    ["GEAR22"] = Gear("GEAR22", "Booty Bay Cutlass", "{3}", 3, "C", "Stranglethorn Vale",
        { Horde = 1146, Neutral = 2482 },   -- Vharr, Grom'gol / Zarena Cromwind, Booty Bay
        2, 1, { "lifelink" }, "INV_Sword_12", "Equip: +2/+1 and Drain."),
    ["GEAR23"] = Gear("GEAR23", "Dustwallow Harpoon", "{3}", 3, "C", "Dustwallow Marsh",
        { Alliance = 4888, Horde = 4884 },   -- Marie Holdston, Theramore / Zulrg, Brackenwall Village
        2, 1, { "reach" }, "INV_Spear_06", "Equip: +2/+1 and Anti-Air."),
    ["GEAR24"] = Gear("GEAR24", "Badlands Dragonbone Axe", "{4}", 4, "C", "Badlands",
        { Horde = 1407, Neutral = 9179 },   -- Sranda, Kargath / Jazzrik
        3, 1, { "haste" }, "INV_Axe_17", "Equip: +3/+1 and Quick."),
    ["GEAR25"] = Gear("GEAR25", "Sorrowmurk Fang", "{3}", 3, "C", "Swamp of Sorrows",
        { Horde = 981 },   -- Hartash, Stonard
        2, 0, { "deathtouch" }, "INV_Weapon_ShortBlade_14", "Equip: +2/+0 and Fatal."),

    -- Levels 40-50
    ["GEAR26"] = Gear("GEAR26", "Feralas Ironwood Bow", "{4}", 4, "C", "Feralas",
        { Alliance = 1695, Horde = 9548 },   -- Rendow, Feathermoon Stronghold / Cawind Trueaim, Camp Mojache
        2, 2, { "reach" }, "INV_Weapon_Bow_08", "Equip: +2/+2 and Anti-Air."),
    ["GEAR27"] = Gear("GEAR27", "Gadgetzan Thunderstick", "{4}", 4, "C", "Tanaris",
        { Neutral = 8131 },   -- Blizrik Buckshot, Gadgetzan
        3, 1, { "firstStrike" }, "INV_Weapon_Rifle_10", "Equip: +3/+1 and Strikes-First."),
    ["GEAR28"] = Gear("GEAR28", "Hinterlands Stormhammer", "{4}", 4, "C", "The Hinterlands",
        { Alliance = 8161, Horde = 14737 },   -- Harggan, Aerie Peak / Smith Slagtree, Revantusk Village
        2, 2, { "flying" }, "INV_Hammer_16", "Equip: +2/+2 and Airborne."),
    ["GEAR29"] = Gear("GEAR29", "Thorium Greataxe", "{4}", 4, "C", "Searing Gorge",
        { Alliance = 11703 },   -- Graw Cornerstone
        3, 1, { "trample" }, "INV_Axe_02", "Equip: +3/+1 and Brutish."),
    ["GEAR30"] = Gear("GEAR30", "Highborne Runeblade", "{4}", 4, "C", "Azshara",
        { Alliance = 14301, Horde = 10361 },   -- Brinna Valanaar, Talrendis Point / Gruul Darkblade, Valormok
        2, 2, { "hexproof" }, "INV_Sword_34", "Equip: +2/+2 and Warded."),
    ["GEAR31"] = Gear("GEAR31", "Nethergarde Felbane Dagger", "{4}", 4, "C", "Blasted Lands",
        { Alliance = 5508 },   -- Strumner Flintheel, Nethergarde Keep
        3, 1, { "lifelink" }, "INV_Weapon_ShortBlade_25", "Equip: +3/+1 and Drain."),

    -- Levels 48-55
    ["GEAR32"] = Gear("GEAR32", "Devilsaur-Tooth Dagger", "{4}", 4, "C", "Un'Goro Crater",
        { Neutral = 3000 },   -- Gibbert, Marshal's Refuge
        2, 2, { "deathtouch" }, "INV_Weapon_ShortBlade_16", "Equip: +2/+2 and Fatal."),
    ["GEAR33"] = Gear("GEAR33", "Felwood Ironbark Staff", "{6}", 6, "C", "Felwood",
        { Alliance = 15315, Horde = 10379 },   -- Mylini Frostmoon, Talonbranch Glade / Altsoba Ragetotem, Bloodvenom Post
        2, 3, { "bulwark" }, "INV_Staff_13", "Equip: +2/+3 and Bulwark 2."),
    ["GEAR34"] = Gear("GEAR34", "Morgan's Vigil Warblade", "{6}", 6, "C", "Burning Steppes",
        { Alliance = 1296 },   -- Felder Stover, Morgan's Vigil
        3, 2, { "firstStrike", "trample" }, "INV_Sword_36", "Equip: +3/+2, Strikes-First and Brutish."),
    ["GEAR35"] = Gear("GEAR35", "Argent Crusader's Hammer", "{6}", 6, "C", "Western Plaguelands",
        { Alliance = 10857, Horde = 10856 },   -- Argent Quartermasters Lightspark, Chillwind Camp / Hasana, the Bulwark
        2, 3, { "support" }, "INV_Hammer_19", "Equip: +2/+3, Support and Shielded.",
        { { op = "shielded", to = "target" } }),

    -- Levels 55-60
    ["GEAR36"] = Gear("GEAR36", "Everlook Frost Crossbow", "{6}", 6, "C", "Winterspring",
        { Neutral = 11184 },   -- Wixxrak, Everlook
        3, 2, { "firstStrike", "reach" }, "INV_Weapon_Crossbow_01", "Equip: +3/+2, Strikes-First and Anti-Air."),
    ["GEAR37"] = Gear("GEAR37", "Light's Hope Runeblade", "{6}", 6, "C", "Eastern Plaguelands",
        { Neutral = 11536 },   -- Quartermaster Miranda Breechlock, Light's Hope Chapel
        3, 3, { "lifelink" }, "INV_Sword_39", "Equip: +3/+3 and Drain."),
    ["GEAR38"] = Gear("GEAR38", "Cenarion Hold Scarab Glaive", "{5}", 5, "C", "Silithus",
        { Neutral = 15176 },   -- Vargus, Cenarion Hold
        3, 3, { "trample", "reach" }, "INV_Weapon_Halberd_10", "Equip: +3/+3, Brutish and Anti-Air."),
})

-- The weapon merchants' trail (see TTS.GIFT_TRAILS in Cards\Core.lua): every merchant a
-- faction can ask, by level, Neutral ones on both trails
TTS.GIFT_TRAILS.gear = {
    Alliance = { 54, 1273, 3609, 1668, 1469, 4183, 3491, 3088, 11137, 225, 1441, 3543, 3053, 275623,
        1471, 1322, 2482, 4888, 9179, 1695, 8131, 8161, 11703, 14301, 5508, 3000, 15315, 1296, 10857,
        11184, 11536, 15176 },
    Horde = { 3163, 3077, 2136, 9553, 3479, 9549, 6028, 3539, 9551, 32334, 9555, 12045, 1146, 4884,
        1407, 981, 9548, 8131, 14737, 10361, 3000, 10379, 10856, 11184, 11536, 15176 },
}
