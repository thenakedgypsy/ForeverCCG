--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
TTS.Tooltip = TTS.Tooltip or {}
local TT = TTS.Tooltip
local L = TTS.L
local Loc = TTS.Locale

-- =========================================================================
-- TOOLTIP MANAGER
-- Every tooltip the addon shows goes through here, so the delay from the
-- options menu applies everywhere and only one tooltip is ever up.
--
--   TT:Show(owner, anchor, opts)       any tooltip; opts.main(tip) adds its lines
--   TT:ShowText(owner, anchor, title, text, opts)
--   TT:ShowCard(owner, anchor, cardId, ctx)
--   TT:ShowPlayerEffect(owner, anchor, effect)
--   TT:ShowManaSymbol(owner, anchor, key, amount)
--   TT:Hide(owner)                     owner (optional): only if it owns the tooltip
--
-- STACKING: a tooltip can have stages. Each stage is a set of small panels
-- that appear beside the main tooltip, one stage every extended-delay seconds
-- while the cursor stays put. Cards stack keywords, then effects, then
-- symbols. Stages with nothing to show are skipped.
-- =========================================================================
local PANEL_GAP   = 3     -- pixels between panels
local SIDE_ROOM   = 260   -- pixels a column of panels needs beside the main tooltip

local TEXTURE_ROOT = "Interface\\AddOns\\ForeverCCG\\Textures\\"
local SKULL_TEX    = TEXTURE_ROOT .. "Symbols\\Skull.png"
local SKULL_MAYBE_TEX = TEXTURE_ROOT .. "Symbols\\Skull_maybe.png"

local TAG_COLORS = {
    Keyword = { 1.00, 0.82, 0.00 },
    Effect  = { 0.69, 0.50, 1.00 },
    Ability = { 0.69, 0.50, 1.00 },
    Status  = { 0.40, 0.90, 1.00 },
    Symbol  = { 1.00, 1.00, 1.00 },
    Card    = { 1.00, 1.00, 1.00 },
}

local function Sym(str, size)
    if TTS.FormatSymbols then return TTS:FormatSymbols(str, size) end
    return str
end

-- "1 turn" / "3 turns": the language's <key>.one / <key>.other form, filled with n
local function Plural(n, key)
    return L(key .. (n == 1 and ".one" or ".other"), n)
end

local function Signed(n)
    n = n or 0
    return (n >= 0 and "+" or "") .. n
end

-- =========================================================================
-- KEYWORDS
-- Keys are the card fields the Cards files and CardLogic.lua use.
-- The English below is the reference text; other languages translate
-- keyword.<key>.name / .text, symbol.<key>.name / .text and effect.<id>.name / .text
-- (read through TT:Def).
-- =========================================================================
TT.KEYWORD_ORDER = {
    "flying", "reach", "haste", "vigilance", "firstStrike", "deathtouch",
    "lifelink", "trample", "hexproof", "shielded", "defender", "unblockable", "bulwark", "support",
    "kinsmanship", "unique",
}

TT.KEYWORDS = {
    flying      = { name = "Airborne",      text = "Can only be blocked by denizens with Airborne or Anti-Air." },
    reach       = { name = "Anti-Air",      text = "Can block denizens with Airborne." },
    haste       = { name = "Quick",         text = "No Rez Sickness: it can attack and use {T} abilities the turn it enters the battlefield." },
    vigilance   = { name = "Vigilant",      text = "Attacking doesn't Exhaust this denizen, so it is still ready to block on your opponent's turn." },
    firstStrike = { name = "Strikes-First", text = "Deals its combat damage before denizens without Strikes-First. If that damage is lethal, the other denizen dies before it can strike back." },
    deathtouch  = { name = "Fatal",         text = "Any combat damage this denizen deals to a denizen is lethal." },
    lifelink    = { name = "Drain",         text = "Combat damage this denizen deals also restores that much life to its controller." },
    trample     = { name = "Brutish",       text = "When blocked, combat damage beyond the blocker's toughness carries over to the defending player." },
    hexproof    = { name = "Warded",        text = "Can't be the target of your opponent's spells or abilities." },
    shielded    = { name = "Shielded",      text = "The next instance of damage this denizen would take is negated, and it loses Shielded." },
    defender    = { name = "Blocker",       text = "Can't attack. It can still block." },
    unblockable = { name = "Invisible",     text = "Can't be blocked." },
    bulwark     = { name = "Bulwark",       text = "Bulwark X: can block up to X attackers each combat, dealing its full combat damage to each of them." },
    support     = { name = "Support",       text = "Can block an attacker alongside other blockers. Each blocker deals its full combat damage to the attacker, while the attacker picks the order it hits them in: each takes enough to kill it before the next takes any." },
    -- Shown for cards with a rally (card.rally); on the card it reads "Defias Kinsmanship:" over "+1/+1"
    kinsmanship = { name = "Kinsmanship",   text = "Gets the bonus once for each other denizen you control that shares its tag." },
    unique      = { name = "Unique",        text = "You can have only one copy of it on your battlefield. You can't cast another while it's there, and if another arrives by an effect, the one already there is destroyed." },
}

-- =========================================================================
-- SYMBOLS
-- The {X} tokens in costs and rules text, plus the skull drawn on creatures
-- that die if the current blocks are accepted.
-- =========================================================================
TT.SYMBOLS = {
    W       = { name = "Holy",          text = "One Holy mana, made by Exhausting a Holy Prayer. Holy cards bring life gain, shielding, supporting guards and board wipes." },
    U       = { name = "Arcane",        text = "One Arcane mana, made by Exhausting an Arcane Prayer. Arcane cards bring card draw, tempo, freezing and bounce." },
    B       = { name = "Shadow",        text = "One Shadow mana, made by Exhausting a Shadow Prayer. Shadow cards bring targeted removal, sacrifice, hand disruption and drain." },
    R       = { name = "Fire",          text = "One Fire mana, made by Exhausting a Fire Prayer. Fire cards bring aggression, direct burn, Quick denizens and burst damage." },
    G       = { name = "Nature",        text = "One Nature mana, made by Exhausting a Nature Prayer. Nature cards bring mana ramp, Anti-Air blockers and massive behemoths." },
    T       = { name = "Exhaust",           text = "Exhaust the card (it turns grey and shows this symbol) to use the ability. An Exhausted card stays Exhausted until it Recovers at the start of its controller's turn. Attacking also Exhausts denizens that aren't Vigilant." },
    -- {T}(1) in rules text (the Cracked Hearths)
    TAP1    = { name = "Exhaust (1)",       text = "Exhaust this card and one other ready Prayer you control to use the ability. Both Recover at the start of your turn as usual." },
    GENERIC = { name = "Generic Mana",  text = "A number in brackets is generic mana: pay it with mana of any colour." },
    X       = { name = "X",             text = "X stands for a number chosen when the card is played." },
    SKULL   = { name = "Lethal",        text = "This denizen dies if the current blocks are accepted." },
    SKULL_MAYBE = { name = "Possibly Lethal", text = "This denizen may die if the current blocks are accepted: it depends on the order the attacker deals its damage to its blockers in, picked when combat resolves." },
}

local function SymbolIcon(key, size)
    size = size or 16
    if key == "SKULL" then return string.format("|T%s:%d:%d:0:0|t", SKULL_TEX, size, size) end
    if key == "SKULL_MAYBE" then return string.format("|T%s:%d:%d:0:0|t", SKULL_MAYBE_TEX, size, size) end
    if key == "GENERIC" then return Sym("{1}", size) end
    if key == "TAP1" then return Sym("{T}", size) .. "(1)" end
    return Sym("{" .. key .. "}", size)
end

-- =========================================================================
-- EFFECTS
-- Spell effect ops (CardLogic.lua SPELL_OPS), creature abilities, the
-- states a permanent can be in, and player effects (effect bars).
-- =========================================================================
TT.EFFECTS = {
    -- Spell effects
    damage     = { name = "Damage",            tag = "Effect", text = "Damage to a denizen stays marked on it until the end of the turn; it dies once that damage reaches its toughness. Damage to a player lowers their life, after any Damage Shield." },
    heal       = { name = "Healing",           tag = "Effect", text = "Restores life to a player, or removes damage marked on a denizen." },
    buff_temp  = { name = "Empower",           tag = "Effect", text = "Raises power and toughness (and may grant keywords) until the end of the turn." },
    buff_perm  = { name = "Lasting Empower",   tag = "Effect", text = "Raises power and toughness for as long as the denizen stays on the battlefield." },
    weaken     = { name = "Weaken",            tag = "Effect", text = "Lowers power and toughness. A denizen whose toughness drops to 0 dies. Dispel on your own denizen removes it." },
    tap        = { name = "Exhaust",          tag = "Effect", text = "Exhausts the denizen. An Exhausted denizen can't attack or block until it Recovers at the start of its controller's turn." },
    freeze     = { name = "Freeze",            tag = "Effect", text = "Exhausts the denizen, and it doesn't Recover during its controller's next Recover step." },
    destroy    = { name = "Destroy",           tag = "Effect", text = "Puts the denizen straight into its owner's graveyard, whatever its toughness." },
    tuck       = { name = "Return to Deck",    tag = "Effect", text = "Puts the denizen on top of its owner's deck, so they draw it again next. Anything attached to it falls off." },
    steal      = { name = "Mind Control",      tag = "Effect", text = "You take control of the enemy denizen. It can't attack this turn unless it is only borrowed until end of turn." },
    dot        = { name = "DoT (Damage over Turns)",  tag = "Effect", text = "At the start of each of the caster's turns for a number of turns: on a player, deals damage; on a denizen, it permanently gets -0/-1, and it dies at 0 toughness." },
    hot        = { name = "HoT (Heal over Turns)", tag = "Effect", text = "At the start of each of the caster's turns for a number of turns: on a player, restores life; on a denizen, it permanently gets +0/+1." },
    shield     = { name = "Damage Shield",     tag = "Effect", text = "On a player: prevents the next points of damage they would take. On a denizen: extra toughness until the end of the turn." },
    regen      = { name = "Soulstone",         tag = "Effect", text = "The next time the denizen would die from damage it survives instead: its damage is removed and it becomes Exhausted. Destroy effects ignore this." },
    dispel     = { name = "Dispel",            tag = "Effect", text = "On an enemy denizen: removes its buffs, granted keywords, Soulstones and HoT. On your own denizen: removes weakening, DoT and freeze." },
    draw       = { name = "Draw",              tag = "Effect", text = "Draw X: draw X cards from your deck. With 10 cards in hand you discard one first. Drawing from an empty deck loses the game." },
    mana       = { name = "Mana Gain",         tag = "Effect", text = "Adds mana straight to your pool. Unspent mana empties at the end of your turn." },
    token      = { name = "Add",               tag = "Effect", text = "A denizen made by an effect, not played from a card. It is never in a deck or a collection, and if it would leave the battlefield it disappears instead." },
    raise      = { name = "Raise Dead",        tag = "Effect", text = "Returns the most recent denizen card in a graveyard to the battlefield under your control." },
    targeting  = { name = "Targeting",         tag = "Effect", text = "After clicking the card, click a target. Right-click cancels. Warded enemy denizens can't be chosen." },
    gear       = { name = "Gear Card",         tag = "Effect", text = "Equips a denizen you control. Its bonus and keywords last for as long as the denizen stays on the battlefield. An enemy Dispel strips them. Weapon merchants hand out Gear Cards to travellers who ask." },

    -- Creature and Prayer abilities
    prayer     = { name = "Prayer",            tag = "Ability", text = "Click a ready Prayer to Exhaust it for one mana of its colour. You can play one Prayer per turn, during a main phase." },
    anthem     = { name = "Aura",            tag = "Ability", text = "While this denizen is on the battlefield, your other denizens that share the tag get the bonus." },
    rally      = { name = "Rally",             tag = "Ability", text = "This denizen grows for each other denizen you control that shares the tag." },
    activated  = { name = "Activated Ability", tag = "Ability", text = "Click this card during your main phase to use it. If the cost includes {T}, the card must be ready and free of Rez Sickness." },
    triggered  = { name = "Triggered Ability", tag = "Ability", text = "Happens on its own whenever its condition is met." },
    arrival    = { name = "Arrival",           tag = "Ability", text = "Happens when this denizen enters the battlefield." },
    aggro      = { name = "Aggro",             tag = "Ability", text = "Happens each time this denizen attacks." },
    martyrdom  = { name = "Martyrdom",         tag = "Ability", text = "Happens when this denizen dies." },
    spawn      = { name = "Spawn",             tag = "Ability", text = "Puts Adds onto the battlefield under your control. An Add is a denizen made by an effect: it is never in a deck or a collection, and if it would leave the battlefield it disappears instead." },

    -- States of a card on the battlefield
    sick       = { name = "Rez Sickness",       tag = "Status", text = "Entered the battlefield this turn: it can't attack or use {T} abilities until its controller's next turn." },
    tapped     = { name = "Exhausted",            tag = "Status", text = "Can't attack, block or be Exhausted again until it Recovers at the start of its controller's turn." },
    frozen     = { name = "Frozen",            tag = "Status", text = "Won't Recover during its controller's next Recover step." },
    regenerating = { name = "Soulstoned",      tag = "Status", text = "Survives the next lethal damage: its damage is removed and it becomes Exhausted instead." },
    damaged    = { name = "Damaged",           tag = "Status", text = "It dies if the marked damage reaches its toughness. All damage wears off at the end of the turn." },
    attacking  = { name = "Attacking",         tag = "Status", text = "Declared as an attacker this combat." },
    blocking   = { name = "Blocking",          tag = "Status", text = "Assigned to block an attacker this combat." },
    blocked    = { name = "Blocked",           tag = "Status", text = "A denizen is blocking this attacker. Combat damage goes to the blocker instead of the player (unless it is Brutish)." },
    selected   = { name = "Choosing Block",    tag = "Status", text = "Selected as a blocker: click an attacking denizen to assign it. Right-click to deselect." },
    modified   = { name = "Modified Stats",    tag = "Status", text = "Its power and toughness differ from the printed card." },
    borrowed   = { name = "Borrowed",          tag = "Status", text = "Under your control until the end of the turn, then it returns to its owner." },
}

-- Who an area effect reaches
local AREA_TEXT = {
    enemy_creatures    = "every enemy denizen",
    friendly_creatures = "every denizen you control",
    all_creatures      = "every denizen",
    self_player        = "you",
    enemy_player       = "the opponent",
}

local TARGET_TEXT = {
    enemy_creature    = "an enemy denizen",
    friendly_creature = "a denizen you control",
    creature          = "any denizen",
    enemy_any         = "an enemy denizen or the opponent",
    friendly_any      = "yourself or a denizen you control",
    any               = "any denizen or player",
    enemy_player      = "the opponent",
    player            = "a player",
}

-- Translated name / text of a KEYWORDS / SYMBOLS / EFFECTS entry: TT:Def("keyword", key, "name")
local DEF_TABLES = { keyword = TT.KEYWORDS, symbol = TT.SYMBOLS, effect = TT.EFFECTS }
function TT:Def(group, key, field)
    local def = DEF_TABLES[group][key]
    return def and Loc:Data(group .. "." .. key .. "." .. field, def[field])
end

local function Area(to) return AREA_TEXT[to] and Loc:Data("tt.area." .. to, AREA_TEXT[to]) end
local function Target(t) return TARGET_TEXT[t] and Loc:Data("tt.target." .. t, TARGET_TEXT[t]) end
local function SphereName(c) return TT.SYMBOLS[c] and TT:Def("symbol", c, "name") or c end
-- Card tag fields (anthem / rally) and the label group their values translate under
local TAG_GROUP = { faction = "faction", zone = "zone", type = "creatureType" }
local function TagFieldLabel(tag) return L("tt.tagField." .. tostring(tag)) end
local function TagValue(tag, value) return Loc:Term(TAG_GROUP[tag] or tag, value) end

-- Rules text in the language's sentences ("Brutish. Other X you control get +1/+1.")
local function Sentences(text)
    local list, pos = {}, 1
    while pos <= #text do
        -- a sentence ends at "." before a capital or a non-ASCII letter (so "Venture Co. you" stays whole), or at "。"
        local a, b = text:find("%. [%u\128-\255]", pos)
        local c, d = text:find("。", pos, true)
        if c and (not a or c < a) then a, b = c, d else b = a and b - 1 end
        if not a then list[#list + 1] = text:sub(pos); break end
        list[#list + 1] = text:sub(pos, b):gsub("%s+$", "")
        pos = b + 1
        while text:sub(pos, pos) == " " do pos = pos + 1 end
    end
    return list
end

-- "Undead Aura:\n+1{PT}+1, Quick": a tagged bonus as printed on the card
local function BonusLine(bonus, name)
    local parts = {}
    if (bonus.p or 0) ~= 0 or (bonus.t or 0) ~= 0 then parts[1] = Signed(bonus.p) .. "{PT}" .. Signed(bonus.t) end
    for _, kw in ipairs(bonus.kw or {}) do
        if TT.KEYWORDS[kw] then parts[#parts + 1] = TT:Def("keyword", kw, "name") end
    end
    local prefix = TagValue(bonus.tag, bonus.value)
    -- keywords are never separated by commas: "+1{PT}+1. Quick"
    return (prefix ~= "" and (prefix .. " ") or "") .. name .. ":\n" .. table.concat(parts, Loc.code == "zhCN" and "。" or ". ")
end

-- Rules text as printed on the card: an anthem's sentence ("Other Undead you control get +1/+1.")
-- becomes a line of its own, "Undead Aura:\n+1{PT}+1", and a rally's ("Gets +1/+1 for each other
-- Defias you control.") "Defias Kinsmanship:\n+1{PT}+1", {PT} being the power/toughness emblem.
-- The sentences are found in the English text and taken out at the same place in the translation;
-- if the two don't split alike, the text is left as it is.
local function PlainRulesText(card)
    if type(card) == "string" then card = TTS.Cards and TTS.Cards[card] end
    local text = TTS:CardText(card)
    if not (text and card.text and (card.anthem or card.rally)) then return text end
    local en, shown = Sentences(card.text), Sentences(text)
    if #en ~= #shown then return text end
    local anthemAt, rallyAt
    for i, s in ipairs(en) do
        if s:find("for each other") then rallyAt = i
        elseif s:find("you control get") or s:find("you control gain") or s:find("you control have") then anthemAt = i end
    end
    if not card.anthem then anthemAt = nil end
    if not card.rally then rallyAt = nil end
    if not (anthemAt or rallyAt) then return text end

    local lines = {}
    if rallyAt then lines[#lines + 1] = BonusLine(card.rally, TT:Def("keyword", "kinsmanship", "name")) end
    if anthemAt then lines[#lines + 1] = BonusLine(card.anthem, TT:Def("effect", "anthem", "name")) end
    -- the later sentence first, so the earlier one keeps its place
    if (anthemAt or 0) > (rallyAt or 0) then table.remove(shown, anthemAt); anthemAt = nil end
    if rallyAt then table.remove(shown, rallyAt) end
    if anthemAt then table.remove(shown, anthemAt) end
    local rest = table.concat(shown, text:find("。", 1, true) and "" or " ")
    if rest ~= "" then table.insert(lines, 1, rest) end
    return table.concat(lines, "\n")
end

-- =========================================================================
-- COLOURED KEYWORDS (readability test; false shows rules text as before)
-- Keyword and card-term names in rules text take a colour. In an Aura or Kinsmanship line
-- ("Undead Aura:") the type before it shares that colour; types elsewhere stay plain.
-- Dark on the printed card face, light in tooltips (TTS:CardRulesText's onCard).
-- =========================================================================
TTS.COLOR_KEYWORDS = true
TT.TEXT_COLORS = {
    card = "|cFF8A2A00",   -- dark rust, on the card's light face
    tip  = "|cFF80D0FF",   -- light blue, on the dark tooltip
}

-- { name, kind } to colour, longest first (so "Anti-Air" wins over a shorter name inside it).
-- Built once per language (the language is fixed until a /reload).
local coloredNames, coloredFor
local function ColoredNames()
    if coloredNames and coloredFor == Loc.code then return coloredNames end
    local list, seen = {}, {}
    local function add(name, kind)
        if name and name ~= "" and not seen[name] then seen[name] = true; list[#list + 1] = { name = name, kind = kind } end
    end
    -- the two bonus-line names first, so they are the ones marked as "bonus"
    add(TT:Def("effect", "anthem", "name"), "bonus")
    add(TT:Def("keyword", "kinsmanship", "name"), "bonus")
    for _, kw in ipairs(TT.KEYWORD_ORDER) do add(TT:Def("keyword", kw, "name"), "kw") end
    for _, id in ipairs({ "arrival", "aggro", "martyrdom", "spawn", "freeze", "draw" }) do add(TT:Def("effect", id, "name"), "kw") end
    add("DoT", "kw"); add("HoT", "kw")
    table.sort(list, function(a, b) return #a.name > #b.name end)
    coloredNames, coloredFor = list, Loc.code
    return list
end

local function ColorNames(text, color)
    local names, found = ColoredNames(), {}
    -- First mark every match, so a shorter name can't match inside one already found
    for _, e in ipairs(names) do
        local pat = e.name:gsub("[%.%-%(%)%[%]%*%+%?%^%$%%]", "%%%0")
        if e.name:match("^%w") then pat = "%f[%w]" .. pat end        -- whole words where the name starts with a letter
        if e.name:match("%w$") then pat = pat .. "%f[%W]" end
        text = text:gsub(pat, function(m)
            found[#found + 1] = { text = m, kind = e.kind }
            return "\1" .. #found .. "\2"
        end)
    end
    -- An Aura / Kinsmanship line ("Undead Aura:") takes its type into the same colour
    local lines = {}
    for line in (text .. "\n"):gmatch("(.-)\n") do
        local prefix, i = line:match("^([^\1\2]+) \1(%d+)\2:$")
        local m = i and found[tonumber(i)]
        if m and m.kind == "bonus" then
            m.text = prefix .. " " .. m.text
            line = "\1" .. i .. "\2:"
        end
        lines[#lines + 1] = line
    end
    text = table.concat(lines, "\n")
    -- Then colour them
    return (text:gsub("\1(%d+)\2", function(i) return color .. found[tonumber(i)].text .. "|r" end))
end

-- Rules text as the card shows it (see PlainRulesText), keywords coloured.
-- onCard: the printed card face (dark colours) rather than a tooltip (light colours).
function TTS:CardRulesText(card, onCard)
    local text = PlainRulesText(card)
    if not text or text == "" then return text end
    -- A signed stat change ("+1/+0", "-2/-1") always starts a line of its own
    text = text:gsub("[ \t]+([%+%-]%d+/[%+%-]?%d+)", "\n%1")
    text = text:gsub("([^\n])([%+%-]%d+/[%+%-]?%d+)", "%1\n%2")
    text = text:gsub("([%+%-]?%d+)/([%+%-]?%d+)", "%1{PT}%2")
    if not TTS.COLOR_KEYWORDS then return text end
    return ColorNames(text, onCard and TT.TEXT_COLORS.card or TT.TEXT_COLORS.tip)
end

-- =========================================================================
-- PANEL SPECS
-- A spec is { title, tag, color, lines }. lines: strings (wrapped, light
-- grey) or { text, r, g, b }.
-- =========================================================================
-- amount: the X of a numbered keyword (Bulwark 2), shown after its name
function TT:KeywordPanel(key, note, amount)
    local def = TT.KEYWORDS[key]
    if not def then return nil end
    local lines = { Sym(TT:Def("keyword", key, "text"), 14) }
    if note then table.insert(lines, { note, 0.6, 0.9, 0.6 }) end
    local title = TT:Def("keyword", key, "name")
    if type(amount) == "number" then title = title .. " " .. amount end
    return { title = title, tag = "Keyword", lines = lines }
end

function TT:SymbolPanel(key, note)
    local def = TT.SYMBOLS[key]
    if not def then return nil end
    local lines = { TT:Def("symbol", key, "text") }
    if note then table.insert(lines, { note, 0.6, 0.9, 0.6 }) end
    return { title = SymbolIcon(key, 16) .. "  " .. TT:Def("symbol", key, "name"), tag = "Symbol", lines = lines }
end

-- extra (optional): more lines under the description, e.g. the numbers on this card
function TT:EffectPanel(id, extra, titleOverride)
    local def = TT.EFFECTS[id]
    if not def then return nil end
    local lines = { Sym(TT:Def("effect", id, "text"), 14) }
    for _, l in ipairs(extra or {}) do table.insert(lines, l) end
    return { title = titleOverride or TT:Def("effect", id, "name"), tag = def.tag, lines = lines }
end

-- =========================================================================
-- FRAMES
-- =========================================================================
local mainTip = CreateFrame("GameTooltip", "TTS_Tooltip", UIParent, "GameTooltipTemplate")
mainTip:Hide()

local panels, freePanels, usedPanels = {}, {}, {}

local function AcquirePanel()
    local p = table.remove(freePanels)
    if not p then
        p = CreateFrame("GameTooltip", "TTS_TooltipPanel" .. (#panels + 1), UIParent, "GameTooltipTemplate")
        table.insert(panels, p)
    end
    table.insert(usedPanels, p)
    return p
end

local function ReleasePanels()
    for i = #usedPanels, 1, -1 do
        local p = usedPanels[i]
        p:Hide()
        p:ClearLines()
        table.insert(freePanels, p)
        usedPanels[i] = nil
    end
end

local function RenderPanel(spec)
    local p = AcquirePanel()
    p:SetOwner(UIParent, "ANCHOR_NONE")
    p:ClearLines()
    local c = spec.color or TAG_COLORS[spec.tag] or TAG_COLORS.Card
    if spec.tag then
        p:AddDoubleLine(spec.title, Loc:Data("tt.tag." .. spec.tag, spec.tag), c[1], c[2], c[3], 0.55, 0.55, 0.55)
    else
        p:AddLine(spec.title, c[1], c[2], c[3])
    end
    for _, line in ipairs(spec.lines or {}) do
        if type(line) == "table" then
            p:AddLine(Sym(line[1], 14), line[2] or 0.9, line[3] or 0.9, line[4] or 0.9, true)
        else
            p:AddLine(Sym(line, 14), 0.9, 0.9, 0.9, true)
        end
    end
    p:Show()
    return p
end

-- Panels form columns beside the main tooltip, on whichever side has room.
-- A panel that would run off the bottom of the screen starts a new column.
local function LayoutPanels()
    if #usedPanels == 0 then return end
    local left, right = mainTip:GetLeft(), mainTip:GetRight()
    local screenRight, screenBottom = UIParent:GetRight() or 0, UIParent:GetBottom() or 0
    local toRight = true
    if left and right then
        local roomRight, roomLeft = screenRight - right, left
        toRight = roomRight >= SIDE_ROOM or roomRight >= roomLeft
    end
    local near, far = "TOPLEFT", "TOPRIGHT"
    local dir = PANEL_GAP
    if not toRight then near, far, dir = "TOPRIGHT", "TOPLEFT", -PANEL_GAP end
    local below = toRight and "BOTTOMLEFT" or "BOTTOMRIGHT"

    local prev, colHead, widest
    for _, p in ipairs(usedPanels) do
        p:ClearAllPoints()
        if not prev then
            p:SetPoint(near, mainTip, far, dir, 0)
            colHead, widest = p, p
        else
            p:SetPoint(near, prev, below, 0, -PANEL_GAP)
            local bottom = p:GetBottom()
            if bottom and bottom < screenBottom + 4 then
                -- New column beside the widest panel of the last one, level with its top
                p:ClearAllPoints()
                local dy = (colHead:GetTop() or 0) - (widest:GetTop() or 0)
                p:SetPoint(near, widest, far, dir, dy)
                colHead, widest = p, p
            end
        end
        if (p:GetWidth() or 0) > (widest:GetWidth() or 0) then widest = p end
        prev = p
    end
end

-- =========================================================================
-- STATE & TIMING
-- =========================================================================
local driver = CreateFrame("Frame")
driver:Hide()

local state   -- the tooltip currently pending or shown
local rendering = false   -- set while the manager itself redraws the main tooltip

function TT:GetDelay()
    local d = TTS.Options and TTS.Options.Get and TTS.Options:Get("tooltipDelay")
    return tonumber(d) or 0
end

-- Seconds between each extra layer of detail (options menu: extended tooltip delay)
function TT:GetExtendedDelay()
    local d = TTS.Options and TTS.Options.Get and TTS.Options:Get("extendedTooltipDelay")
    return tonumber(d) or 0.8
end

local function RenderMain()
    local st = state
    -- Owner and anchor are set once; later stages only redraw the lines
    if not st.anchored then
        mainTip:SetOwner(st.owner, st.anchor)
        st.anchored = true
    end
    mainTip:ClearLines()
    st.opts.main(mainTip)

    -- Say what more is coming while the cursor stays
    local remaining = {}
    for i = st.stageShown + 1, #st.stages do
        table.insert(remaining, Loc:Data("tt.stage." .. st.stages[i].label, st.stages[i].label))
    end
    if #remaining > 0 then
        mainTip:AddLine(" ")
        mainTip:AddLine(L("tt.keepHovering", table.concat(remaining, ", ")), 0.5, 0.5, 0.5)
    end
    mainTip:Show()
end

-- Shows the main tooltip, its base panels and every stage up to st.stageShown
local function RenderAll()
    local st = state
    rendering = true
    ReleasePanels()
    RenderMain()
    for _, spec in ipairs(st.base) do RenderPanel(spec) end
    for i = 1, st.stageShown do
        for _, spec in ipairs(st.stages[i].panels) do RenderPanel(spec) end
    end
    LayoutPanels()
    rendering = false
end

-- Panel tag -> the options menu switch that hides it (Options.lua, tooltipPanels)
local PANEL_SWITCH = {
    Keyword = "keyword", Ability = "ability", Effect = "effect", Status = "status", Symbol = "symbol",
    Equipment = "attached", Enchantment = "attached", ["Affected by"] = "attached",
}

local function PanelAllowed(spec)
    local switch = PANEL_SWITCH[spec.tag]
    local on = switch and TTS.Options and TTS.Options.Get and TTS.Options:Get("tooltipPanels")
    return not (type(on) == "table" and on[switch] == false)
end

-- Builds every stage now (so empty ones can be skipped and the hint is right)
local function Prepare(st)
    st.base = {}
    for _, spec in ipairs((st.opts.base and st.opts.base()) or {}) do
        if PanelAllowed(spec) then table.insert(st.base, spec) end
    end
    st.stages = {}
    for _, stage in ipairs(st.opts.stages or {}) do
        local list = {}
        for _, spec in ipairs(stage.build() or {}) do
            if spec and PanelAllowed(spec) then table.insert(list, spec) end
        end
        if #list > 0 then
            table.insert(st.stages, { label = stage.label, panels = list })
        end
    end
    st.stageShown = math.min(st.stageShown, #st.stages)
end

local function Reveal(st, stageShown)
    st.stageShown = stageShown or 0
    Prepare(st)
    st.shown = true
    st.nextAt = st.elapsed + TT:GetExtendedDelay()
    RenderAll()
end

driver:SetScript("OnUpdate", function(self, dt)
    local st = state
    if not st then
        self:Hide()
        return
    end
    if not st.owner:IsVisible() then
        TT:Hide()
        return
    end
    st.elapsed = st.elapsed + dt
    if not st.shown then
        if st.elapsed >= TT:GetDelay() then Reveal(st, 0) end
    elseif st.stageShown < #st.stages and st.elapsed >= st.nextAt then
        st.stageShown = st.stageShown + 1
        st.nextAt = st.elapsed + TT:GetExtendedDelay()
        RenderAll()
    end
end)

-- opts.main(tip)  adds the main tooltip's lines
-- opts.base()     (optional) panel specs shown with the main tooltip
-- opts.stages     (optional) { { label = "keywords", build = function() return specs end }, ... }
function TT:Show(owner, anchor, opts)
    if not owner or not opts or not opts.main then return end
    -- Re-showing for the owner already on screen (e.g. its card changed after a click)
    -- skips the delay and keeps the stages already revealed
    local keepStages = state and state.owner == owner and state.shown and state.stageShown
    self:Hide()
    state = {
        owner = owner,
        anchor = anchor or "ANCHOR_TOP",
        opts = opts,
        elapsed = 0,
        shown = false,
        stageShown = 0,
    }
    if keepStages or self:GetDelay() <= 0 then
        Reveal(state, keepStages or 0)
    end
    driver:Show()
end

function TT:Hide(owner)
    if owner and state and state.owner ~= owner then return end
    state = nil
    driver:Hide()
    ReleasePanels()
    mainTip:Hide()
end

function TT:IsShownFor(owner)
    return state ~= nil and state.owner == owner and state.shown
end

-- Anything else that hides the main tooltip takes its panels with it
mainTip:HookScript("OnHide", function()
    if not rendering and state and state.shown then TT:Hide() end
end)

-- =========================================================================
-- SIMPLE TOOLTIPS
-- opts (optional): lines = { {text, r, g, b} | "text", ... } after the text,
-- symbol = key to stack that symbol's explanation.
-- =========================================================================
function TT:ShowText(owner, anchor, title, text, opts)
    if not title then return end
    opts = opts or {}
    local stages
    if opts.symbol then
        stages = { { label = "the symbol", build = function() return { TT:SymbolPanel(opts.symbol) } end } }
    end
    self:Show(owner, anchor, {
        main = function(tip)
            tip:AddLine(title, opts.r or 1, opts.g or 1, opts.b or 1)
            if text and text ~= "" then tip:AddLine(text, 0.7, 0.7, 0.7, true) end
            for _, l in ipairs(opts.lines or {}) do
                if type(l) == "table" then
                    tip:AddLine(l[1], l[2] or 1, l[3] or 1, l[4] or 1, l[5])
                else
                    tip:AddLine(l, 1, 1, 1)
                end
            end
        end,
        stages = stages,
    })
end

-- =========================================================================
-- CARD TOOLTIPS
-- ctx (optional):
--   perm, isRemote, fieldIndex  the card is on the battlefield (live stats and states)
--   header(tip)                 extra lines under the name (e.g. collection status)
--   hint                        grey line at the bottom (e.g. click instructions)
-- =========================================================================
local function DisplayType(card)
    if not card.type then return L("tt.card") end
    -- A Gear Card is a spell underneath, but only ever shown as a Gear Card
    if card.subType == "Gear" then return TTS:CardTypeName(card) end
    -- e.g. "Creature - Hero" (Equipment's subtype is shown as its own type elsewhere)
    if card.subType and card.subType ~= "Equipment" then
        return Loc:Term("type", card.type) .. " - " .. Loc:Term("type", card.subType)
    end
    return Loc:Term("type", card.type)
end

local function FormatPT(power, toughness, damage, colorCode)
    return TTS.FormatStats(power, toughness, damage, colorCode)
end

local function BuildCardMain(tip, card, ctx)
    tip:AddLine(TTS:CardName(card), 1, 1, 1)
    if ctx.header then ctx.header(tip) end

    local costStr = (card.cost and card.cost ~= "") and Sym(card.cost, 18) or "0"
    tip:AddLine(L("tt.cost", costStr) .. "  |  " .. DisplayType(card), 0.8, 0.8, 0.8)
    local tagLine = TTS.GetCardTagLine and TTS:GetCardTagLine(card)
    if tagLine then tip:AddLine(tagLine, 1, 1, 1) end

    if card.power and card.toughness then
        local p, t, damage = card.power, card.toughness, 0
        if ctx.perm and TTS.Engine then
            p, t = TTS.Engine:GetCreatureStats(ctx.perm, ctx.isRemote)
            damage = ctx.perm.damage or 0
        end
        tip:AddLine(FormatPT(p, t, damage, "|cFFFFCC00"), 1, 0.8, 0)
    end

    if card.text and card.text ~= "" then
        tip:AddLine(Sym(TTS:CardRulesText(card), 16), 0.9, 0.9, 0.5, true)
    end

    tip:AddLine(" ")
    if ctx.hint then
        tip:AddLine(ctx.hint, 0.5, 0.5, 0.5)
    end
    -- Every card tooltip belongs to a card that can be linked (UI\CardLinks.lua)
    tip:AddLine(L("tt.linkHint"), 0.5, 0.5, 0.5)
end

-- Cards attached to a permanent and cards whose effects are on it
-- (the old side tooltip), shown with the main tooltip
local function AttachedPanels(perm)
    local specs = {}
    if not perm then return specs end
    for _, att in ipairs(perm.attachments or {}) do
        local attId = type(att) == "table" and att.id or att
        local aCard = TTS.Cards[attId]
        if aCard then
            local isEquip = type(att) == "table" and att.isEquipment or (aCard.type == "Equipment" or aCard.isEquipment or aCard.subType == "Equipment")
            local aCost = (aCard.cost and aCard.cost ~= "") and Sym(aCard.cost, 16) or "0"
            local lines = { { L("tt.cost", aCost), 0.8, 0.8, 0.8 } }
            if aCard.text and aCard.text ~= "" then table.insert(lines, { Sym(TTS:CardRulesText(aCard), 14), 0.9, 0.9, 0.6 }) end
            table.insert(specs, {
                title = TTS:CardName(aCard),
                tag = isEquip and "Equipment" or "Enchantment",
                color = isEquip and { 0.4, 0.73, 1.0 } or { 1.0, 0.82, 0.0 },
                lines = lines,
            })
        end
    end
    if TTS.Engine and TTS.Engine.GetPermEffectCards then
        for _, effId in ipairs(TTS.Engine:GetPermEffectCards(perm)) do
            local eCard = TTS.Cards[effId]
            local eCost = (eCard.cost and eCard.cost ~= "") and Sym(eCard.cost, 16) or "0"
            local lines = { { L("tt.cost", eCost) .. "  |  " .. (eCard.type and DisplayType(eCard) or L("type.Spell")), 0.8, 0.8, 0.8 } }
            if eCard.text and eCard.text ~= "" then table.insert(lines, { Sym(TTS:CardRulesText(eCard), 14), 0.9, 0.9, 0.6 }) end
            table.insert(specs, { title = TTS:CardName(eCard), tag = "Affected by", color = { 0.69, 0.5, 1.0 }, lines = lines })
        end
    end
    return specs
end

local function KeywordPanels(card, ctx)
    local specs, seen = {}, {}
    local E = TTS.Engine
    local function add(kw, note)
        if seen[kw] then return end
        local spec = TT:KeywordPanel(kw, note, card[kw])
        if spec then
            seen[kw] = true
            table.insert(specs, spec)
        end
    end

    for _, kw in ipairs(TT.KEYWORD_ORDER) do
        if kw == "kinsmanship" then
            -- a card ability (card.rally), not a keyword the engine tracks
            local r = card.rally
            if r then add(kw, L("tt.rally", Signed(r.p) .. "/" .. Signed(r.t), TagValue(r.tag, r.value))) end
        elseif ctx.perm and E and E.HasKeyword then
            if E:HasKeyword(ctx.perm, ctx.isRemote, kw) then
                add(kw, (not card[kw]) and L("tt.kwGranted") or nil)
            elseif card[kw] then
                add(kw, L(kw == "shielded" and "tt.kwShieldUsed" or "tt.kwSwitchedOff"))
            end
        elseif card[kw] then
            add(kw)
        end
    end

    -- Keywords this card hands out
    for _, op in ipairs((card.effect and card.effect.ops) or {}) do
        for _, kw in ipairs(op.kw or {}) do add(kw, L(op.perm and "tt.kwGearGrants" or "tt.kwSpellGrants")) end
        if op.op == "shielded" then add("shielded", L("tt.kwSpellGrantsShield")) end
    end
    local a = card.anthem
    for _, kw in ipairs((a and a.kw) or {}) do
        add(kw, L("tt.kwAnthem", TagValue(a.tag, a.value)))
    end
    return specs
end

-- Live states of a card on the battlefield
local function StatusPanels(card, ctx)
    local specs = {}
    local perm, E = ctx.perm, TTS.Engine
    if not (perm and E) then return specs end
    local isCreature = card.type == "Creature"

    if isCreature and perm.sick and not E:HasKeyword(perm, ctx.isRemote, "haste") then
        table.insert(specs, TT:EffectPanel("sick"))
    end
    if perm.tapped then table.insert(specs, TT:EffectPanel("tapped")) end
    if perm.freezeUntap then table.insert(specs, TT:EffectPanel("frozen")) end
    if perm.regenerateShield then table.insert(specs, TT:EffectPanel("regenerating")) end
    if (perm.damage or 0) > 0 then
        table.insert(specs, TT:EffectPanel("damaged", { { L("tt.damageMarked", Plural(perm.damage, "tt.n.damage")), 1, 0.3, 0.3 } }))
    end

    -- Combat
    local bs = E.blockingState
    if perm.isAttacking then table.insert(specs, TT:EffectPanel("attacking")) end
    if bs and ctx.fieldIndex then
        local blockerRemote = not bs.isRemoteAttacking
        local otherField = ctx.isRemote and E.localState.field or E.remoteState.field
        if (ctx.isRemote and true or false) == blockerRemote then
            local names = {}
            for _, p in ipairs(E:BlockPairs(bs)) do
                local atk = p[1] == ctx.fieldIndex and otherField[p[2]]
                if atk and TTS.Cards[atk.id] then table.insert(names, TTS:CardName(atk.id)) end
            end
            if #names > 0 then
                table.insert(specs, TT:EffectPanel("blocking", { { L("tt.blockingX", table.concat(names, ", ")), 0.6, 0.9, 0.6 } }))
            end
            if not ctx.isRemote and bs.selectedBlocker == ctx.fieldIndex then
                table.insert(specs, TT:EffectPanel("selected"))
            end
        elseif perm.isAttacking then
            local names = {}
            for _, p in ipairs(E:BlockPairs(bs)) do
                local b = p[2] == ctx.fieldIndex and otherField[p[1]]
                if b and TTS.Cards[b.id] then table.insert(names, TTS:CardName(b.id)) end
            end
            if #names > 0 then
                table.insert(specs, TT:EffectPanel("blocked", { { L("tt.blockedBy", table.concat(names, ", ")), 1, 0.5, 0.5 } }))
            end
        end
    end

    -- Power / toughness changes
    if isCreature and card.power and card.toughness then
        local p, t = E:GetCreatureStats(perm, ctx.isRemote)
        local tp, tt = perm.tempPower or 0, perm.tempToughness or 0
        local pp, pt = perm.permPower or 0, perm.permToughness or 0
        local op, ot = p - card.power - tp - pp, t - card.toughness - tt - pt
        if p ~= card.power or t ~= card.toughness or tp ~= 0 or tt ~= 0 or pp ~= 0 or pt ~= 0 then
            local function Stats(a, b) return TTS.FormatStats(a, b, 0, "|cFFFFFFFF", 12) end
            local lines = { { L("tt.printedNow", Stats(card.power, card.toughness), Stats(p, t)), 1, 0.82, 0 } }
            if tp ~= 0 or tt ~= 0 then table.insert(lines, L("tt.modTemp", Stats(Signed(tp), Signed(tt)))) end
            if pp ~= 0 or pt ~= 0 then table.insert(lines, L("tt.modPerm", Stats(Signed(pp), Signed(pt)))) end
            if op ~= 0 or ot ~= 0 then table.insert(lines, L("tt.modOther", Stats(Signed(op), Signed(ot)))) end
            table.insert(specs, TT:EffectPanel("modified", lines))
        end
    end

    -- Over-time effects sitting on the creature
    for _, kind in ipairs({ "dot", "hot" }) do
        local list = perm[kind .. "s"]
        if list and #list > 0 then
            local lines = {}
            for _, e in ipairs(list) do
                local src = TTS:ReasonText(e.src) or L("reason.effect")
                local line = L(kind == "dot" and "tt.dotLineCreature" or "tt.hotLineCreature", src, Plural(e.turns, "tt.n.turn"))
                table.insert(lines, { line, 1, 1, 1 })
            end
            table.insert(specs, TT:EffectPanel(kind, lines))
        end
    end

    for _, entry in ipairs(E.stolenCreatures or {}) do
        if entry.perm == perm then table.insert(specs, TT:EffectPanel("borrowed")) end
    end
    return specs
end

-- What one spell op does, with this card's numbers
local function OpPanel(op, eff)
    local id = op.op
    local extra = {}
    local area = op.to and Area(op.to)

    if id == "buff" then
        if (op.p or 0) < 0 or (op.t or 0) < 0 then
            id = "weaken"
        else
            id = op.perm and "buff_perm" or "buff_temp"
        end
        if (op.p or 0) ~= 0 or (op.t or 0) ~= 0 then
            table.insert(extra, L(op.perm and "tt.buffPerm" or "tt.buffTemp", Signed(op.p) .. "/" .. Signed(op.t)))
        end
    elseif id == "damage" then
        table.insert(extra, L("tt.sentence", Plural(op.n or 0, "tt.n.damage")))
        if op.bonusIfTapped then table.insert(extra, L("tt.bonusIfTapped", op.bonusIfTapped)) end
    elseif id == "heal" then
        table.insert(extra, L("tt.restores", op.n or 0))
    elseif id == "dot" or id == "hot" then
        table.insert(extra, L("tt.eachTurnFor", op.n or 0, Plural(op.turns or 0, "tt.n.turn")))
    elseif id == "shield" then
        table.insert(extra, L("tt.absorbs", op.n or 0))
    elseif id == "draw" then
        table.insert(extra, L("tt.draws", Plural(op.n or 0, "tt.n.card")))
    elseif id == "mana" then
        table.insert(extra, L("tt.adds", Sym(string.rep("{" .. (op.color or "C") .. "}", op.n or 0), 14)))
    elseif id == "destroy" then
        if op.damaged then table.insert(extra, L("tt.onlyDamaged")) end
        if op.nonColor then table.insert(extra, L("tt.nonColor", SphereName(op.nonColor))) end
    elseif id == "steal" then
        if op.maxPower then table.insert(extra, L("tt.maxPower", op.maxPower)) end
        table.insert(extra, op.untilEnd and L("tt.stealTemp") or L("tt.stealPerm"))
    elseif id == "raise" then
        table.insert(extra, op.src == "any" and L("tt.raiseAny") or L("tt.raiseOwn"))
    elseif id == "token" then
        local tok = TTS.Cards[op.id]
        if tok then table.insert(extra, L("tt.creates", op.n or 1, TTS:CardName(tok), tok.power or 0, tok.toughness or 0)) end
    end

    if area then table.insert(extra, { L("tt.affects", area), 0.6, 0.9, 0.6 }) end

    local panel = TT:EffectPanel(id, extra)
    if panel then panel.key = id .. (area or "") end
    return panel
end

local function AbilityPanels(card)
    local specs = {}
    if card.type == "Land" then table.insert(specs, TT:EffectPanel("prayer")) end
    if card.subType == "Gear" then table.insert(specs, TT:EffectPanel("gear")) end

    -- The English rules text is the data here (it is the same whatever the language)
    local text = card.text or ""
    if card.type == "Creature" and text ~= "" then
        if text:match("^{[^:]*}:") then table.insert(specs, TT:EffectPanel("activated")) end
        for _, term in ipairs({ { "arrival", "Arrival:" }, { "aggro", "Aggro:" }, { "martyrdom", "Martyrdom:" } }) do
            if text:find(term[2], 1, true) then table.insert(specs, TT:EffectPanel(term[1])) end
        end
        if text:find("Whenever") then table.insert(specs, TT:EffectPanel("triggered")) end
    end

    -- Adds: what this card is, or the Adds its abilities spawn
    if card.isToken then table.insert(specs, TT:EffectPanel("token")) end
    for _, key in ipairs({ "etb", "onDeath", "onAttack" }) do
        for _, op in ipairs((card[key] and card[key].ops) or {}) do
            local tok = op.op == "token" and TTS.Cards[op.id]
            if tok then
                table.insert(specs, TT:EffectPanel("spawn",
                    { { (L("tt.creates", op.n or 1, TTS:CardName(tok), tok.power or 0, tok.toughness or 0):gsub("%((%d+)/(%d+)%)", "(%1{PT}%2)")), 0.6, 0.9, 0.6 } }))
            end
        end
    end

    local seen = {}
    local eff = card.effect
    if eff then
        if eff.target and TARGET_TEXT[eff.target] then
            table.insert(specs, TT:EffectPanel("targeting", { { L("tt.choose", Target(eff.target)), 0.6, 0.9, 0.6 } }))
        end
        for _, op in ipairs(eff.ops or {}) do
            local panel = OpPanel(op, eff)
            if panel and not seen[panel.key] then
                seen[panel.key] = true
                table.insert(specs, panel)
            end
            seen[op.op] = true
        end
    end
    -- Terms the rules text uses that no effect above explained yet
    for _, term in ipairs({ { "dot", "%f[%a]DoT%f[%A]" }, { "hot", "%f[%a]HoT%f[%A]" }, { "freeze", "%f[%a]Freeze" }, { "frozen", "%f[%a]Frozen" }, { "draw", "%f[%a]Draw %d" } }) do
        local key = term[1]
        if not seen[key] and not (key == "frozen" and seen.freeze) and text:find(term[2]) then
            seen[key] = true
            table.insert(specs, TT:EffectPanel(key))
        end
    end

    -- The Aura always comes last, as it does on the card
    local a = card.anthem
    if a then
        local bonus = string.format("%s/%s", Signed(a.p), Signed(a.t))
        local kws = {}
        for _, kw in ipairs(a.kw or {}) do
            if TT.KEYWORDS[kw] then table.insert(kws, TT:Def("keyword", kw, "name")) end
        end
        local line = #kws > 0 and L("tt.anthemKw", TagValue(a.tag, a.value), bonus, table.concat(kws, ", "))
            or L("tt.anthem", TagValue(a.tag, a.value), bonus)
        table.insert(specs, TT:EffectPanel("anthem", { { line, 1, 0.82, 0 }, { L("tt.matchesBy", TagFieldLabel(a.tag)), 0.6, 0.6, 0.6 } }))
    end
    return specs
end

local function SymbolPanels(card, ctx)
    local specs, seen = {}, {}
    local function add(key, note)
        if seen[key] then return end
        local spec = TT:SymbolPanel(key, note)
        if spec then
            seen[key] = true
            table.insert(specs, spec)
        end
    end

    -- {T}(1): its own panel, in place of plain Exhaust
    local tapOne = (card.text or ""):find("{T}(1)", 1, true)
    if tapOne then add("TAP1") end
    for token in ((card.cost or "") .. " " .. (card.text or "")):gmatch("{(%w+)}") do
        local key = token:upper()
        if tonumber(token) then key = "GENERIC" end
        if key == "TAP" then key = "T" end
        if not (tapOne and key == "T") then add(key) end
    end

    -- Symbols drawn on the card itself on the board
    if ctx.perm then
        if ctx.perm.tapped then add("T", L("tt.tappedSymbol")) end
        local deaths = TTS.BoardFrame and TTS.BoardFrame.predictedDeaths
        if deaths and deaths[ctx.perm] then add(deaths[ctx.perm] == "maybe" and "SKULL_MAYBE" or "SKULL") end
    end
    return specs
end

function TT:ShowCard(owner, anchor, cardId, ctx)
    local card = TTS.Cards and TTS.Cards[cardId]
    if not card then return end
    ctx = ctx or {}
    self:Show(owner, anchor, {
        main = function(tip) BuildCardMain(tip, card, ctx) end,
        base = function() return AttachedPanels(ctx.perm) end,
        stages = {
            { label = "keywords", build = function() return KeywordPanels(card, ctx) end },
            { label = "effects", build = function()
                local specs = StatusPanels(card, ctx)
                for _, s in ipairs(AbilityPanels(card)) do table.insert(specs, s) end
                return specs
            end },
            { label = "symbols", build = function() return SymbolPanels(card, ctx) end },
        },
    })
end

-- =========================================================================
-- BOARD EXTRAS
-- =========================================================================
local PLAYER_EFFECT_COLORS = {
    dot    = { 1.0, 0.2, 0.2 },
    hot    = { 0.2, 1.0, 0.2 },
    shield = { 1.0, 0.82, 0.0 },
}

-- An icon on a player's effect bar: { kind = "dot"|"hot"|"shield", n, turns, src, srcId }
function TT:ShowPlayerEffect(owner, anchor, e)
    if not e then return end
    local c = PLAYER_EFFECT_COLORS[e.kind] or TAG_COLORS.Card
    self:Show(owner, anchor, {
        main = function(tip)
            if e.kind == "shield" then
                tip:AddLine(TT:Def("effect", "shield", "name"), c[1], c[2], c[3])
                tip:AddLine(L("tt.shieldPrevents", e.n), 1, 1, 1, true)
            else
                tip:AddLine(TTS:ReasonText(e.src) or L("reason.effect"), c[1], c[2], c[3])
                if e.kind == "dot" then
                    tip:AddLine(L("tt.takesEachTurn", e.n), 1, 1, 1, true)
                else
                    tip:AddLine(L("tt.restoresEachTurn", e.n), 1, 1, 1, true)
                end
                tip:AddLine(L("tt.remaining", Plural(e.turns, "tt.n.turn")), 0.8, 0.8, 0.8)
            end
        end,
        stages = {
            { label = "the effect", build = function() return { TT:EffectPanel(e.kind) } end },
        },
    })
end

-- One sphere of the mana counter under the board
function TT:ShowManaSymbol(owner, anchor, key, amount)
    local def = TT.SYMBOLS[key]
    if not def then return end
    self:Show(owner, anchor, {
        main = function(tip)
            tip:AddLine(SymbolIcon(key, 18) .. "  " .. L("tt.manaName", TT:Def("symbol", key, "name")), 1, 1, 1)
            tip:AddLine(L("tt.inPool", amount or 0), 1, 0.82, 0)
            tip:AddLine(TT:Def("symbol", key, "text"), 0.7, 0.7, 0.7, true)
        end,
    })
end