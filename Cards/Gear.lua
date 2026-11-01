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
-- wear = itemId, wearSlot = "weapon" / "head" / "shoulder": what a humanoid denizen's model
-- puts on while equipped (UI\Board.lua DressGear); the latest weapon, helm and shoulders show.
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

-- The weapon each one puts in a humanoid's hand: a classic item that looks the part
local WEAPONS = {
    GEAR01 = 1161,     -- Militia Shortsword
    GEAR02 = 2047,     -- Anvilmar Hand Axe
    GEAR03 = 15810,    -- Short Spear
    GEAR04 = 2029,     -- Cleaver
    GEAR05 = 4924,     -- Primitive Club
    GEAR06 = 2139,     -- Dirk
    GEAR07 = 11304,    -- Fine Longbow
    GEAR08 = 2509,     -- Ornate Blunderbuss
    GEAR09 = 6967,     -- Elunite Sword
    GEAR10 = 4763,     -- Blackwood Recurve Bow
    GEAR11 = 4560,     -- Fine Scimitar
    GEAR12 = 8181,     -- Hunting Rifle
    GEAR13 = 11303,    -- Fine Shortbow
    GEAR14 = 250605,   -- Steel Spear
    GEAR15 = 935,      -- Night Watch Shortsword
    GEAR16 = 3489,     -- Thick War Axe
    GEAR17 = 15811,    -- Heavy Spear
    GEAR18 = 4372,     -- Lovingly Crafted Boomstick
    GEAR19 = 7944,     -- Dazzling Mithril Rapier
    GEAR20 = 2525,     -- War Hammer
    GEAR21 = 3440,     -- Bonecracker
    GEAR22 = 16890,    -- Slatemetal Cutlass
    GEAR23 = 274963,   -- Rot-Covered Harpoon
    GEAR24 = 10744,    -- Axe of the Ebon Drake
    GEAR25 = 2236,     -- Blackfang
    GEAR26 = 11307,    -- Massive Longbow
    GEAR27 = 10510,    -- Mithril Heavy-bore Rifle
    GEAR28 = 9651,     -- Gryphon Rider's Stormhammer
    GEAR29 = 12775,    -- Huge Thorium Battleaxe
    GEAR30 = 10696,    -- Enchanted Azsharite Felbane Sword
    GEAR31 = 10697,    -- Enchanted Azsharite Felbane Dagger
    GEAR32 = 281314,   -- Subdued Dragon's Fang
    GEAR33 = 9683,     -- Strength of the Treant
    GEAR34 = 12764,    -- Thorium Greatsword
    GEAR35 = 7946,     -- Runed Mithril Hammer
    GEAR36 = 15809,    -- Heavy Crossbow
    GEAR37 = 9718,     -- Reforged Blade of Heroes
    GEAR38 = 12802,    -- Darkspear
}
for id, item in pairs(WEAPONS) do
    TTS.Cards[id].wear, TTS.Cards[id].wearSlot = item, "weapon"
end

-- =========================================================================
-- ARMOUR (Gear too, handed out by the zones' armourers)
-- Mostly toughness and defensive keywords. Each puts a helm or shoulders on a humanoid.
-- =========================================================================
local function Armor(id, name, cost, cmc, zone, npcs, slot, item, p, t, kw, art, text, extraOps)
    local card = Gear(id, name, cost, cmc, "C", zone, npcs, p, t, kw, art, text, extraOps)
    card.wear, card.wearSlot = item, slot
    return card
end
local SHIELDED = { { op = "shielded", to = "target" } }

TTS:AddCards({
    -- Levels 1-10
    ["ARMR01"] = Armor("ARMR01", "Goldshire Footman's Helm", "{1}", 1, "Elwynn Forest",
        { Alliance = 2046 },   -- Andrew Krighton, Goldshire
        "head", 8092, 0, 2, nil, "INV_Helmet_03", "Equip: +0/+2."),   -- Platemail Helm
    ["ARMR02"] = Armor("ARMR02", "Kharanos Iron Pauldrons", "{1}", 1, "Dun Morogh",
        { Alliance = 1240 },   -- Boran Ironclink, Kharanos
        "shoulder", 4694, 0, 1, { "vigilance" }, "INV_Shoulder_28", "Equip: +0/+1 and Vigilant."),   -- Burnished Pauldrons
    ["ARMR03"] = Armor("ARMR03", "Dolanaar Leafweave Mantle", "{1}", 1, "Teldrassil",
        { Alliance = 3613 },   -- Meri Ironweave, Dolanaar
        "shoulder", 10745, 0, 1, { "hexproof" }, "INV_Shoulder_18", "Equip: +0/+1 and Warded."),   -- Kaylari Shoulders
    ["ARMR04"] = Armor("ARMR04", "Razor Hill War Paint Pads", "{1}", 1, "Durotar",
        { Horde = 3167 },   -- Wuark, Razor Hill
        "shoulder", 14728, 0, 2, nil, "INV_Shoulder_07", "Equip: +0/+2."),   -- War Paint Shoulder Pads
    ["ARMR05"] = Armor("ARMR05", "Bloodhoof Spirit Headdress", "{1}", 1, "Mulgore",
        { Horde = 3080 },   -- Harant Ironbrace, Bloodhoof Village
        "head", 6720, 0, 1, { "vigilance" }, "INV_Helmet_17", "Equip: +0/+1 and Vigilant."),   -- Spirit Hunter Headdress
    ["ARMR06"] = Armor("ARMR06", "Brill Reservist's Cap", "{1}", 1, "Tirisfal Glades",
        { Horde = 2135 },   -- Abe Winters, Brill
        "head", 20643, 0, 1, { "hexproof" }, "INV_Helmet_15", "Equip: +0/+1 and Warded."),   -- Undercity Reservist's Cap

    -- Levels 10-20
    ["ARMR07"] = Armor("ARMR07", "Algaz Mining Helmet", "{2}", 2, "Loch Modan",
        { Alliance = 1362 },   -- Gothor Brumn, Algaz Station
        "head", 10542, 0, 3, nil, "INV_Helmet_25", "Equip: +0/+3."),   -- Goblin Mining Helmet
    ["ARMR08"] = Armor("ARMR08", "Auberdine Sentinel's Guard", "{2}", 2, "Darkshore",
        { Alliance = 4187 },   -- Harlon Thornguard, Auberdine
        "head", 9664, 0, 2, { "support" }, "INV_Helmet_19", "Equip: +0/+2 and Support."),   -- Sentinel's Guard
    ["ARMR09"] = Armor("ARMR09", "Sepulcher Grim Pauldrons", "{2}", 2, "Silverpine Forest",
        { Horde = 3553 },   -- Sebastian Meloche, the Sepulcher
        "shoulder", 4443, 0, 2, { "vigilance" }, "INV_Shoulder_07", "Equip: +0/+2 and Vigilant."),   -- Grim Pauldrons
    ["ARMR10"] = Armor("ARMR10", "Ratchet Raider's Shoulderpads", "{2}", 2, "The Barrens",
        { Neutral = 3493 },   -- Grazlix, Ratchet
        "shoulder", 10407, 0, 2, { "support" }, "INV_Shoulder_23", "Equip: +0/+2 and Support."),   -- Raider's Shoulderpads
    ["ARMR11"] = Armor("ARMR11", "Lakeshire Guard's Coif", "{2}", 2, "Redridge Mountains",
        { Alliance = 956 },   -- Dorin Songblade, Lakeshire
        "head", 1282, 0, 2, nil, "INV_Helmet_02", "Equip: +0/+2 and Shielded.", SHIELDED),   -- Sparkmetal Coif

    -- Levels 20-30
    ["ARMR12"] = Armor("ARMR12", "Darkshire Watch Spaulders", "{3}", 3, "Duskwood",
        { Alliance = 226 },   -- Morg Gnarltree, Darkshire
        "shoulder", 6579, 0, 3, { "vigilance" }, "INV_Shoulder_27", "Equip: +0/+3 and Vigilant."),   -- Defender Spaulders
    ["ARMR13"] = Armor("ARMR13", "Astranaar Feathered Mantle", "{3}", 3, "Ashenvale",
        { Alliance = 3953 },   -- Tandaan Lightmane, Astranaar
        "shoulder", 4196, 0, 3, { "reach" }, "INV_Shoulder_05", "Equip: +0/+3 and Anti-Air."),   -- Feathered Mantle
    ["ARMR14"] = Armor("ARMR14", "Menethil Marine's Helm", "{3}", 3, "Wetlands",
        { Alliance = 1450 },   -- Brahnmar, Menethil Harbor
        "head", 3894, 1, 2, nil, "INV_Helmet_03", "Equip: +1/+2 and Shielded.", SHIELDED),   -- Brigandine Helm

    -- Levels 30-50
    ["ARMR15"] = Armor("ARMR15", "Dustwallow Mithril Pauldrons", "{4}", 4, "Dustwallow Marsh",
        { Alliance = 4886, Horde = 4883 },   -- Hans Weston, Theramore / Krak, Brackenwall Village
        "shoulder", 7918, 0, 4, { "support" }, "INV_Shoulder_22", "Equip: +0/+4 and Support."),   -- Heavy Mithril Shoulder
    ["ARMR16"] = Armor("ARMR16", "Stranglethorn Brutal Helm", "{4}", 4, "Stranglethorn Vale",
        { Horde = 1381, Neutral = 2845 },   -- Krakk, Grom'gol / Fargon Mortalak, Booty Bay
        "head", 7130, 0, 3, { "bulwark" }, "INV_Helmet_02", "Equip: +0/+3 and Bulwark 2."),   -- Brutal Helm
    ["ARMR17"] = Armor("ARMR17", "Mojache Wolfshead Helm", "{4}", 4, "Feralas",
        { Horde = 8159 },   -- Worb Strongstitch, Camp Mojache
        "head", 8345, 1, 3, { "vigilance" }, "INV_Helmet_04", "Equip: +1/+3 and Vigilant."),   -- Wolfshead Helm

    -- Levels 55-60
    ["ARMR18"] = Armor("ARMR18", "Everlook Imperial Pauldrons", "{6}", 6, "Winterspring",
        { Neutral = 11182 },   -- Nixxrak, Everlook
        "shoulder", 12428, 1, 5, { "bulwark" }, "INV_Shoulder_02", "Equip: +1/+5, Bulwark 2 and Shielded.", SHIELDED),   -- Imperial Plate Shoulders
})

-- The gear trail (see TTS.GIFT_TRAILS in Cards\Core.lua): every weapon merchant and armourer
-- a faction can ask, by level, Neutral ones on both trails
TTS.GIFT_TRAILS.gear = {
    Alliance = { 54, 2046, 1273, 1240, 3609, 3613, 1668, 1469, 1362, 4183, 4187, 3491, 3493, 3088, 956,
        11137, 3953, 225, 226, 1441, 1450, 3543, 3053, 275623, 1471, 1322, 2482, 2845, 4888, 4886, 9179,
        1695, 8131, 8161, 11703, 14301, 5508, 3000, 15315, 1296, 10857, 11184, 11182, 11536, 15176 },
    Horde = { 3163, 3167, 3077, 3080, 2136, 2135, 9553, 3553, 3479, 3493, 9549, 6028, 3539, 9551, 32334,
        9555, 12045, 1146, 1381, 2845, 4884, 4883, 1407, 981, 9548, 8159, 8131, 14737, 10361, 3000,
        10379, 10856, 11184, 11182, 11536, 15176 },
}
