--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- SETTLEMENT CARDS
-- Won by beating a zone's notable NPC at cards (Duels.lua). How a Settlement plays: Engine\
-- CardLogic.lua's SETTLEMENTS section. Up to 4 copies (SoloEncounters.lua TTS:CardMaxCopies).
-- In the hand it's an ordinary card; on the battlefield it turns into a landscape card
-- (UI\Board.lua, the frames' <frame>_landscape.png).
-- A Settlement with a zone and no art of its own shows that zone's map as its picture
-- (UI\Board.lua PaintZoneArt).
--
-- Every Settlement costs {2} and one sphere (its duel deck's main colour, or a splash it
-- carries for it) and has one ability: {T} and some generic mana, so once a turn.
-- An ability's target: ability.target, with each op's `only` conditions (CardLogic.lua
-- E:IsValidAbilityTarget). A sacrifice is the target of a "destroy" op (Agamand Mills).
-- The Adds they spawn are in Cards\Tokens.lua (TOK09 on).
-- =========================================================================
local function Settlement(code, name, sphere, zone, ability, text)
    local id = "STL_" .. code
    return id, {
        id = id, name = name, cost = "{2}{" .. sphere .. "}", cmc = 3, color = sphere, type = "Settlement",
        isReward = true, zone = zone, ability = ability, text = text,
    }
end

local CARDS = {}
local function Add(...)
    local id, card = Settlement(...)
    CARDS[id] = card
end

-- Abilities, cheapest first within each kind
local function Tap(cost, ops, target) return { tap = true, cost = cost, target = target, ops = ops } end
local function Spawn(id) return { { op = "token", id = id, n = 1 } } end
local function Buff(p, t, kw, perm) return { { op = "buff", to = "target", p = p, t = t, kw = kw, perm = perm } } end

-- ---- Eastern Kingdoms ----------------------------------------------------
Add("ELW", "Goldshire", "W", "Elwynn Forest",
    Tap("{2}", Spawn("TOK09")),
    "{T}, {2}: Spawn: 1 Peasant Add (1/2, Support).")
Add("DUN", "Kharanos", "U", "Dun Morogh",
    Tap("{3}", { { op = "freeze", to = "target" } }, "enemy_creature"),
    "{T}, {3}: Freeze target enemy denizen.")
Add("TIR", "Agamand Mills", "B", "Tirisfal Glades",
    Tap("{3}", { { op = "destroy", to = "target" }, { op = "token", id = "TOK11", n = 1 } }, "friendly_creature"),
    "{T}, {3}, sacrifice a denizen you control: Spawn: 1 Rattlecage Soldier Add (3/3).")
Add("WES", "Moonbrook", "B", "Westfall",
    Tap("{2}", Buff(-2, 0), "enemy_creature"),
    "{T}, {2}: Target enemy denizen gets -2/-0 until end of turn.")
Add("LOC", "Thelsamar", "R", "Loch Modan",
    Tap("{4}", { { op = "damage", to = "enemy_creatures", n = 1 } }),
    "{T}, {4}: Deal 1 damage to each enemy denizen.")
Add("SIL", "Pyrewood Village", "B", "Silverpine Forest",
    Tap("{2}", Buff(2, 0, { "trample" }), "friendly_creature"),
    "{T}, {2}: Target denizen you control gets +2/+0 and Brutish until end of turn.")
Add("RED", "Lakeshire", "G", "Redridge Mountains",
    Tap("{2}", Buff(1, 2), "friendly_creature"),
    "{T}, {2}: Target denizen you control gets +1/+2 until end of turn.")
Add("DSK", "Raven Hill", "B", "Duskwood",
    Tap("{5}", { { op = "raise" } }),
    "{T}, {5}: Return a denizen card from your graveyard to the battlefield.")
Add("WET", "Menethil Harbor", "G", "Wetlands",
    Tap("{3}", Buff(3, 3), "friendly_creature"),
    "{T}, {3}: Target denizen you control gets +3/+3 until end of turn.")
Add("HIL", "Durnholde Keep", "U", "Hillsbrad Foothills",
    Tap("{4}", { { op = "bounce", to = "target" } }, "enemy_creature"),
    "{T}, {4}: Return target enemy denizen to its owner's hand.")
Add("ALT", "Strahnbrad", "B", "Alterac Mountains",
    Tap("{4}", { { op = "destroy", to = "target", only = { maxPower = 2 } } }, "enemy_creature"),
    "{T}, {4}: Destroy target enemy denizen with power 2 or less.")
Add("ARA", "Faldir's Cove", "U", "Arathi Highlands",
    Tap("{2}", Buff(0, 0, { "unblockable" }), "friendly_creature"),
    "{T}, {2}: Target denizen you control gains Invisible until end of turn.")
Add("STV", "Nesingwary's Expedition", "G", "Stranglethorn Vale",
    Tap("{5}", { { op = "destroy", to = "target", only = { type = "Beast" } } }, "enemy_creature"),
    "{T}, {5}: Destroy target enemy Beast.")
Add("BAD", "Kargath", "R", "Badlands",
    Tap("{2}", { { op = "damage", to = "target", n = 1 } }, "creature_or_enemy"),
    "{T}, {2}: Deal 1 damage to target denizen or the opponent.")
Add("SWA", "Stonard", "G", "Swamp of Sorrows",
    Tap("{4}", Spawn("TOK12")),
    "{T}, {4}: Spawn: 1 Sawtooth Crocolisk Add (3/3).")
Add("HIN", "Revantusk Village", "R", "The Hinterlands",
    Tap("{3}", { { op = "damage", to = "target", n = 2 } }, "creature"),
    "{T}, {3}: Deal 2 damage to target denizen.")
Add("SEA", "Thorium Point", "R", "Searing Gorge",
    Tap("{3}", Buff(1, 0, nil, true), "friendly_creature"),
    "{T}, {3}: Target denizen you control permanently gets +1/+0.")
Add("BLA", "Nethergarde Keep", "B", "Blasted Lands",
    Tap("{4}", Buff(-1, -1, nil, true), "enemy_creature"),
    "{T}, {4}: Target enemy denizen permanently gets -1/-1.")
Add("BUR", "Flame Crest", "R", "Burning Steppes",
    Tap("{3}", Spawn("TOK05")),
    "{T}, {3}: Spawn: 1 Rookery Whelp Add (1/1, Airborne).")
Add("WPL", "Andorhal", "B", "Western Plaguelands",
    Tap("{4}", { { op = "steal", to = "target", untilEnd = true, only = { maxPower = 3 } } }, "enemy_creature"),
    "{T}, {4}: Gain control of target enemy denizen with power 3 or less until end of turn. Recover it. It gains Quick.")
Add("EPL", "Terrordale", "B", "Eastern Plaguelands",
    Tap("{3}", { { op = "dot", to = "enemy_player", n = 1, turns = 2 } }),
    "{T}, {3}: The opponent takes 1 damage at the start of each of your next 2 turns.")

-- ---- Kalimdor ------------------------------------------------------------
Add("DUR", "Razor Hill", "R", "Durotar",
    Tap("{3}", Spawn("TOK10")),
    "{T}, {3}: Spawn: 1 Peon Add (2/1, Quick).")
Add("MUL", "Bloodhoof Village", "G", "Mulgore",
    Tap(nil, { { op = "mana", color = "G", n = 1 } }),
    "{T}: Add {G} to your mana pool.")
Add("TEL", "Ban'ethil Barrow Den", "G", "Teldrassil",
    Tap("{3}", Buff(1, 1, nil, true), "friendly_creature"),
    "{T}, {3}: Target denizen you control permanently gets +1/+1.")
Add("DAR", "Auberdine", "U", "Darkshore",
    Tap("{2}", { { op = "tap", to = "target" } }, "enemy_creature"),
    "{T}, {2}: Exhaust target enemy denizen.")
Add("BRN", "Ratchet", "U", "The Barrens",
    Tap("{2}", Spawn("TOK01")),
    "{T}, {2}: Spawn: 1 Murloc Tadpole Add (1/1).")
Add("STO", "Sun Rock Retreat", "U", "Stonetalon Mountains",
    Tap("{4}", { { op = "tuck", to = "target", only = { maxCmc = 3 } } }, "enemy_creature"),
    "{T}, {4}: Put target enemy denizen that costs 3 or less on top of its owner's deck.")
Add("ASH", "Astranaar", "G", "Ashenvale",
    Tap("{1}", Buff(1, 1, { "reach" }), "friendly_creature"),
    "{T}, {1}: Target denizen you control gets +1/+1 and Anti-Air until end of turn.")
Add("THO", "Mirage Raceway", "R", "Thousand Needles",
    Tap("{2}", Buff(2, 0, { "haste" }), "friendly_creature"),
    "{T}, {2}: Target denizen you control gets +2/+0 and Quick until end of turn.")
Add("DES", "Shadowprey Village", "B", "Desolace",
    Tap("{2}", Spawn("TOK03")),
    "{T}, {2}: Spawn: 1 Skeleton Add (1/1).")
Add("DUS", "Theramore Isle", "U", "Dustwallow Marsh",
    Tap("{3}", { { op = "draw", n = 1 } }),
    "{T}, {3}: Draw 1.")
Add("FER", "Camp Mojache", "R", "Feralas",
    Tap("{3}", { { op = "damage", to = "all_creatures", n = 1 } }),
    "{T}, {3}: Deal 1 damage to each denizen.")
Add("TAN", "Gadgetzan", "W", "Tanaris",
    Tap("{2}", { { op = "shielded", to = "target" } }, "friendly_creature"),
    "{T}, {2}: Target denizen you control gains Shielded.")
Add("AZS", "Ruins of Eldarath", "B", "Azshara",
    Tap("{6}", { { op = "destroy", to = "target" }, { op = "damage", to = "self_player", n = 2 } }, "enemy_creature"),
    "{T}, {6}: Destroy target enemy denizen. You take 2 damage.")
Add("FEL", "Emerald Sanctuary", "G", "Felwood",
    Tap("{2}", { { op = "dispel", to = "target" } }, "creature"),
    "{T}, {2}: Remove beneficial effects from target enemy denizen, or harmful effects from target denizen you control.")
Add("UNG", "Marshal's Refuge", "G", "Un'Goro Crater",
    Tap("{5}", Spawn("TOK13")),
    "{T}, {5}: Spawn: 1 Diemetradon Bull Add (4/4, Brutish).")
Add("SLI", "Twilight Post", "B", "Silithus",
    Tap("{3}", { { op = "damage", to = "enemy_player", n = 1 }, { op = "heal", to = "self_player", n = 1 } }),
    "{T}, {3}: Deal 1 damage to the opponent. You regain 1 life.")
Add("WIN", "Everlook", "U", "Winterspring",
    Tap("{2}", { { op = "bounce", to = "target", only = { maxCmc = 2 } } }, "enemy_creature"),
    "{T}, {2}: Return target enemy denizen that costs 2 or less to its owner's hand.")
Add("ZEP", "Zephras Heights", "U", "Zephras Isle",
    Tap("{2}", Buff(0, 0, { "flying" }), "friendly_creature"),
    "{T}, {2}: Target denizen you control gains Airborne until end of turn.")

-- The tutorial's (UI\Tutorial.lua; Systems\SoloEncounters.lua TUTORIAL): cheap enough to
-- play on its last turn, and never collected (notCollectible: not in the Deckbuilder,
-- the collection or a ban list). Shows Elwynn Forest's map as its picture.
CARDS["STL_TUT"] = {
    id = "STL_TUT", name = "Training Grounds", cost = "{W}", cmc = 1, color = "W", type = "Settlement",
    notCollectible = true, zone = "Elwynn Forest",
    anthem = { tag = "any", p = 1, t = 0 },
    text = "Your denizens get +1/+0."
}

TTS:AddCards(CARDS)
