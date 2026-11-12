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
-- carries for it) and has one effect: either an ability ({T} and some generic mana, so once
-- a turn) or a passive one (an aura on your denizens or the opponent's, or a start-of-turn
-- trigger; see the SETTLEMENTS section for the fields).
-- An ability's target: ability.target, with each op's `only` conditions (CardLogic.lua
-- E:IsValidAbilityTarget). A sacrifice is the target of a "destroy" op (Agamand Mills).
-- The Adds they spawn are in Cards\Tokens.lua (TOK09 on).
-- =========================================================================
local function Settlement(code, name, sphere, zone, effect, text)
    local id = "STL_" .. code
    local card = {
        id = id, name = name, cost = "{2}{" .. sphere .. "}", cmc = 3, color = sphere, type = "Settlement",
        isReward = true, zone = zone, text = text,
    }
    if effect.tap then
        card.ability = effect
    else
        card.anthem, card.enemyAnthem, card.onTurnStart = effect.anthem, effect.enemyAnthem, effect.onTurnStart
    end
    return id, card
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
-- Passive: an aura on your denizens with the tag (tag "any": all of them), or on the opponent's
local function Aura(tag, value, p, t, kw) return { anthem = { tag = tag, value = value, p = p, t = t, kw = kw } } end
local function EnemyAura(tag, value, p, t) return { enemyAnthem = { tag = tag, value = value, p = p, t = t } } end

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
    Aura("faction", "Defias", 1, 1),
    "Defias you control get +1/+1.")
Add("LOC", "Thelsamar", "R", "Loch Modan",
    Aura("any", nil, 0, 2),
    "Denizens you control get +0/+2.")
Add("SIL", "Pyrewood Village", "B", "Silverpine Forest",
    Tap("{2}", Buff(2, 0, { "trample" }), "friendly_creature"),
    "{T}, {2}: Target denizen you control gets +2/+0 and Brutish until end of turn.")
Add("RED", "Lakeshire", "G", "Redridge Mountains",
    Aura("type", "Humanoid", 1, 1),
    "Humanoids you control get +1/+1.")
Add("DSK", "Raven Hill", "B", "Duskwood",
    Aura("type", "Undead", 1, 1),
    "Undead you control get +1/+1.")
Add("WET", "Menethil Harbor", "G", "Wetlands",
    Aura("any", nil, 1, 0),
    "Denizens you control get +1/+0.")
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
    EnemyAura("type", "Beast", -1, -1),
    "Enemy Beasts get -1/-1.")
Add("BAD", "Kargath", "R", "Badlands",
    Tap("{2}", { { op = "damage", to = "target", n = 1 } }, "creature_or_enemy"),
    "{T}, {2}: Deal 1 damage to target denizen or the opponent.")
Add("SWA", "Stonard", "G", "Swamp of Sorrows",
    Tap("{4}", Spawn("TOK12")),
    "{T}, {4}: Spawn: 1 Sawtooth Crocolisk Add (3/3).")
Add("HIN", "Revantusk Village", "R", "The Hinterlands",
    Aura("faction", "Troll", 1, 0, { "haste" }),
    "Trolls you control get +1/+0 and Quick.")
Add("SEA", "Thorium Point", "R", "Searing Gorge",
    Aura("type", "Elemental", 1, 1),
    "Elementals you control get +1/+1.")
Add("BLA", "Nethergarde Keep", "B", "Blasted Lands",
    EnemyAura("type", "Demon", -1, -1),
    "Enemy Demons get -1/-1.")
Add("BUR", "Flame Crest", "R", "Burning Steppes",
    Aura("type", "Dragonkin", 2, 1),
    "Dragonkin you control get +2/+1.")
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
    Aura("any", nil, 0, 1, { "reach" }),
    "Denizens you control get +0/+1 and Anti-Air.")
Add("THO", "Mirage Raceway", "R", "Thousand Needles",
    Aura("any", nil, 0, 0, { "haste" }),
    "Denizens you control have Quick.")
Add("DES", "Shadowprey Village", "B", "Desolace",
    Tap("{2}", Spawn("TOK03")),
    "{T}, {2}: Spawn: 1 Skeleton Add (1/1).")
Add("DUS", "Theramore Isle", "U", "Dustwallow Marsh",
    EnemyAura("any", nil, -1, 0),
    "Enemy denizens get -1/-0.")
Add("FER", "Camp Mojache", "R", "Feralas",
    Aura("faction", "Ogre", 1, 1, { "trample" }),
    "Ogres you control get +1/+1 and Brutish.")
Add("TAN", "Gadgetzan", "W", "Tanaris",
    Aura("type", "Mechanical", 2, 1),
    "Mechanicals you control get +2/+1.")
Add("AZS", "Ruins of Eldarath", "B", "Azshara",
    Aura("type", "Demon", 1, 1),
    "Demons you control get +1/+1.")
Add("FEL", "Emerald Sanctuary", "G", "Felwood",
    Aura("type", "Beast", 1, 1),
    "Beasts you control get +1/+1.")
Add("UNG", "Marshal's Refuge", "G", "Un'Goro Crater",
    Aura("type", "Beast", 1, 0, { "trample" }),
    "Beasts you control get +1/+0 and Brutish.")
Add("SLI", "Twilight Post", "B", "Silithus",
    { onTurnStart = { ops = { { op = "damage", to = "enemy_player", n = 1 }, { op = "heal", to = "self_player", n = 1 } } } },
    "At the start of your turn, deal 1 damage to the opponent. You regain 1 life.")
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
