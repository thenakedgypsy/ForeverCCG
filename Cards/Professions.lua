--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- PROFESSION CARDS
-- Twelve professions with four cards each, earned by doing the profession (Professions.lua).
-- isProfession, profession = its key in TTS.PROFESSIONS, skillReq = the skill that unlocks
-- rolling for it. Never dealt to solo opponents and never foil. Copies are kept with the NPC
-- gifts (TTS_NpcGifts.copies).
--
-- Prayers may also have:
--   deplete = N       (keyword) goes to the graveyard after making mana N times
--   workshop = true   (keyword) a Gear Card cast Recovers it, once each turn
--   anyColor = true   colors holds every colour; a click asks which (UI\Board.lua)
--   manaBurst = N     makes N mana of the colour picked, and destroying it is the cost.
--                     It is only ever tapped by hand (never by auto-pay)
--   etb               its Arrival: untargeted ops only (E:OnPrayerArrive)
-- makesBoth + noPartner make both colours of colors at once (a Deplete prayer's two mana).
-- =========================================================================
TTS.PROFESSIONS = {
    -- spell: a spell named after the profession, for its name in the player's language;
    -- skillLine: the id the client's skill lines know it by
    { key = "mining",         name = "Mining",         spell = 2575, skillLine = 186, primary = true, gather = true },
    { key = "herbalism",      name = "Herbalism",      spell = 2366, skillLine = 182, primary = true, gather = true },
    { key = "skinning",       name = "Skinning",       spell = 8613, skillLine = 393, primary = true, gather = true },
    { key = "blacksmithing",  name = "Blacksmithing",  spell = 2018, skillLine = 164, primary = true, craft = true },
    { key = "leatherworking", name = "Leatherworking", spell = 2108, skillLine = 165, primary = true, craft = true },
    { key = "tailoring",      name = "Tailoring",      spell = 3908, skillLine = 197, primary = true, craft = true },
    { key = "engineering",    name = "Engineering",    spell = 4036, skillLine = 202, primary = true, craft = true },
    { key = "enchanting",     name = "Enchanting",     spell = 7411, skillLine = 333, primary = true, craft = true },
    { key = "alchemy",        name = "Alchemy",        spell = 2259, skillLine = 171, primary = true, craft = true },
    { key = "cooking",        name = "Cooking",        spell = 2550, skillLine = 185, craft = true },
    { key = "firstaid",       name = "First Aid",      spell = 3273, skillLine = 129, craft = true },
    { key = "fishing",        name = "Fishing",        spell = 7620, skillLine = 356 },
}

local ICON = "Interface\\Icons\\"
local SHIELDED = { op = "shielded", to = "target" }
local SOULSTONE = { op = "regen", to = "target" }
local DRAW = { op = "draw", n = 1 }

local function Prof(card, id, prof, req)
    card.id, card.profession, card.skillReq, card.isProfession = id, prof, req, true
    return card
end

-- A Gear Card: extraOps as in Cards\Gear.lua, wear = { slot, itemId } what a humanoid puts on
local function Gear(id, prof, req, name, cmc, p, t, kw, art, text, extraOps, wear)
    local ops = { { op = "buff", to = "target", p = p, t = t, kw = kw, perm = true } }
    for _, op in ipairs(extraOps or {}) do table.insert(ops, op) end
    local card = Prof({
        name = name, cost = "{" .. cmc .. "}", cmc = cmc, color = "C", type = "Sorcery", subType = "Gear",
        text = text, art = ICON .. art,
        effect = { target = "friendly_creature", ops = ops },
    }, id, prof, req)
    if wear then card.wearSlot, card.wear = wear[1], wear[2] end
    return card
end

-- A Prayer: extra = the fields that make it what it is
local function Prayer(id, prof, req, name, color, art, text, extra)
    local card = Prof({
        name = name, cost = "", cmc = 0, color = color, type = "Land", text = text, art = ICON .. art,
    }, id, prof, req)
    for k, v in pairs(extra or {}) do card[k] = v end
    return card
end

-- Deplete N: makes both colours at once, N times
local function Deplete(n, a, b)
    return { colors = { a, b }, makesBoth = true, noPartner = true, deplete = n }
end

-- A prayer of two colours that Recovers when Gear is cast
local function Workshop(a, b)
    return { colors = { a, b }, workshop = true }
end

local ALL_COLORS = { "W", "U", "B", "R", "G" }
local function Heal(n) return { ops = { { op = "heal", to = "self_player", n = n } } } end

local CARDS = {
    -- MINING
    Prayer("MNG01", "mining", 1, "Copper Vein", "R", "INV_Ore_Copper_01",
        "Deplete 2. {T}: Add {R}{R}.", Deplete(2, "R", "R")),
    Gear("MNG02", "mining", 75, "Miner's Pick", 2, 2, 0, { "trample" }, "INV_Pick_02",
        "Equip: +2/+0 and Brutish.", nil, { "weapon", 2901 }),
    Prayer("MNG03", "mining", 150, "Mithril Deposit", "R", "INV_Ore_Mithril_02",
        "Deplete 3. {T}: Add {R}{W}.", Deplete(3, "R", "W")),
    Prayer("MNG04", "mining", 225, "Rich Thorium Vein", "R", "INV_Ore_Thorium_02",
        "Deplete 4. {T}: Add {R}{B}.", Deplete(4, "R", "B")),

    -- HERBALISM
    Prayer("HRB01", "herbalism", 1, "Peacebloom Patch", "G", "INV_Misc_Flower_02",
        "Arrival: Gain 2 life. {T}: Add {G} or {W}.", { colors = { "G", "W" }, etb = Heal(2) }),
    Gear("HRB02", "herbalism", 75, "Swiftthistle Sprig", 1, 1, 1, { "haste" }, "INV_Misc_Herb_04",
        "Equip: +1/+1 and Quick."),
    Prayer("HRB03", "herbalism", 150, "Kingsblood Patch", "G", "INV_Misc_Herb_03",
        "Deplete 3. {T}: Add {G}{R}.", Deplete(3, "G", "R")),
    Prayer("HRB04", "herbalism", 225, "Black Lotus", "C", "INV_Misc_Herb_BlackLotus",
        "{T}, destroy this Prayer: Add three mana of any one colour.",
        { colors = ALL_COLORS, anyColor = true, manaBurst = 3 }),

    -- SKINNING
    Gear("SKN01", "skinning", 1, "Skinning Knife", 1, 1, 0, { "firstStrike" }, "INV_Weapon_ShortBlade_01",
        "Equip: +1/+0 and Strikes-First.", nil, { "weapon", 7005 }),
    Prayer("SKN02", "skinning", 75, "Rugged Leather Cache", "G", "INV_Misc_LeatherScrap_02",
        "Arrives Exhausted. Arrival: Draw 1. {T}: Add {G}.", { entersTapped = true, etb = { ops = { DRAW } } }),
    Prayer("SKN03", "skinning", 150, "Thick Hide Rack", "G", "INV_Misc_Pelt_Bear_Ruin_01",
        "Deplete 3. {T}: Add {G}{B}.", Deplete(3, "G", "B")),
    Gear("SKN04", "skinning", 225, "Pip's Skinner", 4, 3, 1, { "deathtouch" }, "INV_Sword_33",
        "Equip: +3/+1 and Fatal.", nil, { "weapon", 12709 }),

    -- BLACKSMITHING
    Gear("BSM01", "blacksmithing", 1, "Copper Claymore", 2, 2, 1, { "trample" }, "INV_Sword_21",
        "Equip: +2/+1 and Brutish.", nil, { "weapon", 7955 }),
    Prayer("BSM02", "blacksmithing", 75, "Ironforge Anvil", "R", "Trade_BlackSmithing",
        "Workshop. {T}: Add {R} or {W}.", Workshop("R", "W")),
    Gear("BSM03", "blacksmithing", 150, "Hardened Iron Shortsword", 3, 2, 2, { "firstStrike" }, "INV_Sword_20",
        "Equip: +2/+2 and Strikes-First.", nil, { "weapon", 3849 }),
    Gear("BSM04", "blacksmithing", 225, "Arcanite Reaper", 6, 5, 1, { "trample", "haste" }, "INV_Axe_09",
        "Equip: +5/+1, Brutish and Quick.", nil, { "weapon", 12784 }),

    -- LEATHERWORKING
    Gear("LTW01", "leatherworking", 1, "Embossed Leather Vest", 1, 0, 2, { "vigilance" }, "INV_Chest_Leather_09",
        "Equip: +0/+2 and Vigilant."),
    Prayer("LTW02", "leatherworking", 75, "Tanning Rack", "G", "INV_Misc_ArmorKit_17",
        "Workshop. {T}: Add {G} or {B}.", Workshop("G", "B")),
    Gear("LTW03", "leatherworking", 150, "Barbaric Shoulders", 3, 1, 3, { "vigilance" }, "INV_Shoulder_08",
        "Equip: +1/+3 and Vigilant.", nil, { "shoulder", 5964 }),
    Gear("LTW04", "leatherworking", 225, "Devilsaur Gauntlets", 4, 2, 2, { "haste", "firstStrike" }, "INV_Gauntlets_26",
        "Equip: +2/+2, Quick and Strikes-First."),

    -- TAILORING
    Gear("TLR01", "tailoring", 1, "Brown Linen Robe", 1, 0, 2, { "hexproof" }, "INV_Chest_Cloth_21",
        "Equip: +0/+2 and Warded."),
    Prayer("TLR02", "tailoring", 75, "Tailor's Loom", "U", "Trade_Tailoring",
        "Workshop. {T}: Add {U} or {W}.", Workshop("U", "W")),
    Gear("TLR03", "tailoring", 150, "Shadoweave Mask", 3, 2, 1, { "lifelink" }, "INV_Helmet_27",
        "Equip: +2/+1 and Drain.", nil, { "head", 10025 }),
    Gear("TLR04", "tailoring", 225, "Robe of the Archmage", 5, 1, 3, { "hexproof" }, "INV_Chest_Cloth_38",
        "Equip: +1/+3 and Warded. Draw 1.", { DRAW }),

    -- ENGINEERING
    Gear("EGR01", "engineering", 1, "Rough Boomstick", 1, 1, 0, { "firstStrike" }, "INV_Weapon_Rifle_03",
        "Equip: +1/+0 and Strikes-First.", nil, { "weapon", 4362 }),
    Prayer("EGR02", "engineering", 75, "Engineer's Workbench", "U", "Trade_Engineering",
        "Workshop. {T}: Add {U} or {R}.", Workshop("U", "R")),
    Gear("EGR03", "engineering", 150, "Goblin Rocket Helmet", 3, 1, 2, { "haste" }, "INV_Helmet_49",
        "Equip: +1/+2 and Quick.", nil, { "head", 10588 }),
    Gear("EGR04", "engineering", 225, "Arcanite Dragonling", 6, 2, 2, nil, "INV_Misc_Head_Dragon_01",
        "Equip: +2/+2. Spawn: 1 Arcanite Dragonling Add (3/3, Airborne).", { { op = "token", id = "TOK08", n = 1 } }),

    -- ENCHANTING
    Gear("ENC01", "enchanting", 1, "Enchant Weapon - Minor Striking", 1, 1, 1, nil, "Spell_Holy_GreaterHeal",
        "Equip: +1/+1."),
    Prayer("ENC02", "enchanting", 75, "Enchanter's Altar", "U", "Trade_Engraving",
        "Workshop. {T}: Add {U} or {B}.", Workshop("U", "B")),
    Gear("ENC03", "enchanting", 150, "Enchant Weapon - Fiery Weapon", 3, 3, 0, { "haste" }, "Spell_Holy_GreaterHeal",
        "Equip: +3/+0 and Quick."),
    Gear("ENC04", "enchanting", 225, "Enchant Weapon - Crusader", 4, 2, 2, { "lifelink" }, "Spell_Holy_GreaterHeal",
        "Equip: +2/+2, Drain and Shielded.", { SHIELDED }),

    -- ALCHEMY
    Gear("ALC01", "alchemy", 1, "Elixir of Minor Fortitude", 2, 0, 4, nil, "INV_Potion_42",
        "Equip: +0/+4."),
    Prayer("ALC02", "alchemy", 75, "Alchemy Lab", "C", "Trade_Alchemy",
        "Arrives Exhausted. {T}: Add one mana of any colour.",
        { colors = ALL_COLORS, anyColor = true, entersTapped = true }),
    Gear("ALC03", "alchemy", 150, "Elixir of the Mongoose", 3, 2, 1, { "haste", "firstStrike" }, "INV_Potion_32",
        "Equip: +2/+1, Quick and Strikes-First."),
    Gear("ALC04", "alchemy", 225, "Flask of the Titans", 5, 2, 4, nil, "INV_Potion_62",
        "Equip: +2/+4 and Shielded.", { SHIELDED }),

    -- COOKING
    Prayer("COK01", "cooking", 1, "Cooking Fire", "R", "Spell_Fire_Fire",
        "Arrival: Gain 1 life. {T}: Add {R} or {G}.", { colors = { "R", "G" }, etb = Heal(1) }),
    Gear("COK02", "cooking", 75, "Herb Baked Egg", 1, 1, 2, nil, "INV_Egg_03",
        "Equip: +1/+2."),
    Gear("COK03", "cooking", 150, "Dragonbreath Chili", 3, 2, 1, { "haste" }, "INV_Drink_17",
        "Equip: +2/+1 and Quick."),
    Gear("COK04", "cooking", 225, "Smoked Desert Dumplings", 4, 3, 3, nil, "INV_Misc_Food_64",
        "Equip: +3/+3."),

    -- FIRST AID
    Gear("AID01", "firstaid", 1, "Linen Bandage", 1, 0, 3, nil, "INV_Misc_Bandage_15",
        "Equip: +0/+3."),
    Prayer("AID02", "firstaid", 75, "Field Medic's Tent", "W", "Spell_Holy_SealOfSacrifice",
        "Arrives Exhausted. Arrival: Gain 3 life. {T}: Add {W}.", { entersTapped = true, etb = Heal(3) }),
    Gear("AID03", "firstaid", 150, "Heavy Silk Bandage", 2, 0, 3, nil, "INV_Misc_Bandage_02",
        "Equip: +0/+3 and Shielded.", { SHIELDED }),
    Gear("AID04", "firstaid", 225, "Heavy Runecloth Bandage", 3, 1, 5, nil, "INV_Misc_Bandage_12",
        "Equip: +1/+5, Shielded and Soulstone.", { SHIELDED, SOULSTONE }),

    -- FISHING
    Gear("FSH01", "fishing", 1, "Fishing Pole", 1, 1, 0, { "reach" }, "INV_FishingPole_02",
        "Equip: +1/+0 and Anti-Air.", nil, { "weapon", 6256 }),
    Prayer("FSH02", "fishing", 75, "Oily Blackmouth School", "U", "INV_Misc_MonsterHead_04",
        "Deplete 3. {T}: Add {U}{B}.", Deplete(3, "U", "B")),
    Prayer("FSH03", "fishing", 150, "Stonescale Eel Swarm", "U", "INV_Misc_Fish_11",
        "Deplete 3. {T}: Add {U}{G}.", Deplete(3, "U", "G")),
    Gear("FSH04", "fishing", 225, "Arcanite Fishing Pole", 3, 2, 2, { "reach" }, "INV_FishingPole_01",
        "Equip: +2/+2 and Anti-Air. Draw 1.", { DRAW }, { "weapon", 19970 }),
}

do
    local byId = {}
    for _, card in ipairs(CARDS) do byId[card.id] = card end
    TTS:AddCards(byId)
end

-- =========================================================================
-- TRAINERS
-- Once the player has finished the cards of two primary professions, trainers of a primary
-- profession the character doesn't know hand out its cards (UI\NpcGossip.lua). One pool per
-- profession, each with one wait. Trainers of every rank, by Wowhead's listings and the
-- client's creature cache, Forever's own Junior trainers included. A faction only ever meets
-- its own trainers, so one flat list serves both.
-- =========================================================================
local TRAINERS = {
    mining = { 1681, 1701, 2222, 3001, 3137, 3357, 4254, 4598, 5392, 5513, 6297, 247226, 252388, 267325,
        267328, 267331, 267334, 267337 },
    herbalism = { 812, 1218, 1458, 3013, 3404, 4204, 4614, 5137, 5502, 5566, 8146, 247223, 252381, 267326,
        267329, 267332, 267335, 267338 },
    skinning = { 1292, 6291, 6292, 6295, 7087, 7088, 7089, 8144, 8777, 12030, 247227, 252472, 267324, 267327,
        267330, 267333, 267336 },
    blacksmithing = { 514, 957, 1241, 1383, 2836, 2998, 3136, 3174, 3355, 3478, 3557, 4258, 4596, 4605, 5511,
        6299, 7802, 10266, 10276, 10277, 10278, 247216, 256658, 259250 },
    leatherworking = { 223, 1385, 1466, 1632, 3007, 3008, 3069, 3365, 3549, 3605, 3703, 3967, 4212, 4588, 5127,
        5564, 5784, 5811, 7870, 11081, 11083, 11084, 11096, 11097, 247224 },
    tailoring = { 1103, 1300, 1346, 1703, 2627, 2855, 3004, 3363, 3484, 3523, 3704, 4159, 4193, 4576, 5153, 5567,
        11048, 11049, 11050, 11051, 247228, 251972 },
    engineering = { 1676, 1702, 2857, 3290, 3412, 3494, 4586, 5174, 5518, 10993, 11017, 11025, 11026, 11028,
        11029, 11031, 11037, 219663, 247219 },
    enchanting = { 1317, 3011, 3345, 3606, 4213, 4616, 5157, 5695, 7949, 11065, 11066, 11067, 11068, 11070,
        11071, 11072, 11074, 247218, 251978, 259287, 266881 },
    alchemy = { 1215, 1246, 1470, 2132, 2391, 2837, 3009, 3184, 3347, 3603, 3964, 4160, 4609, 4611, 4900, 5177,
        5499, 5500, 11041, 11042, 11044, 11046, 11047, 12020, 247215 },
}
for prof, npcs in pairs(TRAINERS) do
    TTS.GIFT_POOLS["prof_" .. prof] = { npcs = npcs, profession = prof }
end
