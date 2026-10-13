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

local function Plural(n, word)
    return string.format("%d %s%s", n, word, n == 1 and "" or "s")
end

local function Signed(n)
    n = n or 0
    return (n >= 0 and "+" or "") .. n
end

-- =========================================================================
-- KEYWORDS
-- Keys are the card fields Database.lua and CardLogic.lua use.
-- =========================================================================
TT.KEYWORD_ORDER = {
    "flying", "reach", "haste", "vigilance", "firstStrike", "deathtouch",
    "lifelink", "trample", "hexproof", "defender", "unblockable",
}

TT.KEYWORDS = {
    flying      = { name = "Flying",       text = "Can only be blocked by creatures with Flying or Reach." },
    reach       = { name = "Reach",        text = "Can block creatures with Flying." },
    haste       = { name = "Haste",        text = "No summoning sickness: it can attack and use {T} abilities the turn it enters the battlefield." },
    vigilance   = { name = "Vigilance",    text = "Attacking doesn't tap this creature, so it is still ready to block on your opponent's turn." },
    firstStrike = { name = "First Strike", text = "Deals its combat damage before creatures without First Strike. If that damage is lethal, the other creature dies before it can strike back." },
    deathtouch  = { name = "Deathtouch",   text = "Any combat damage this creature deals to a creature is lethal." },
    lifelink    = { name = "Lifelink",     text = "Combat damage this creature deals also restores that much life to its controller." },
    trample     = { name = "Trample",      text = "When blocked, combat damage beyond the blocker's toughness carries over to the defending player." },
    hexproof    = { name = "Hexproof",     text = "Can't be the target of your opponent's spells or abilities." },
    defender    = { name = "Defender",     text = "Can't attack. It can still block." },
    unblockable = { name = "Unblockable",  text = "Can't be blocked." },
}

-- =========================================================================
-- SYMBOLS
-- The {X} tokens in costs and rules text, plus the skull drawn on creatures
-- that die if the current blocks are accepted.
-- =========================================================================
TT.SYMBOLS = {
    W       = { name = "Holy",          text = "One Holy mana, made by tapping a Holy Prayer. Holy cards bring life gain, shielding, vigilant guards and board wipes." },
    U       = { name = "Arcane",        text = "One Arcane mana, made by tapping an Arcane Prayer. Arcane cards bring card draw, tempo, freezing and bounce." },
    B       = { name = "Shadow",        text = "One Shadow mana, made by tapping a Shadow Prayer. Shadow cards bring targeted removal, sacrifice, hand disruption and drain." },
    R       = { name = "Fire",          text = "One Fire mana, made by tapping a Fire Prayer. Fire cards bring aggression, direct burn, haste and burst damage." },
    G       = { name = "Nature",        text = "One Nature mana, made by tapping a Nature Prayer. Nature cards bring mana ramp, reach blockers and massive behemoths." },
    T       = { name = "Tap",           text = "Tap the card (it turns grey and shows this symbol) to use the ability. A tapped card stays tapped until it untaps at the start of its controller's turn. Attacking also taps creatures without Vigilance." },
    GENERIC = { name = "Generic Mana",  text = "A number in brackets is generic mana: pay it with mana of any colour." },
    X       = { name = "X",             text = "X stands for a number chosen when the card is played." },
    SKULL   = { name = "Lethal",        text = "This creature dies if the current blocks are accepted." },
}

local function SymbolIcon(key, size)
    size = size or 16
    if key == "SKULL" then return string.format("|T%s:%d:%d:0:0|t", SKULL_TEX, size, size) end
    if key == "GENERIC" then return Sym("{1}", size) end
    return Sym("{" .. key .. "}", size)
end

-- =========================================================================
-- EFFECTS
-- Spell effect ops (CardLogic.lua SPELL_OPS), creature abilities, the
-- states a permanent can be in, and player effects (effect bars).
-- =========================================================================
TT.EFFECTS = {
    -- Spell effects
    damage     = { name = "Damage",            tag = "Effect", text = "Damage to a creature stays marked on it until the end of the turn; it dies once that damage reaches its toughness. Damage to a player lowers their life, after any Damage Shield." },
    heal       = { name = "Healing",           tag = "Effect", text = "Restores life to a player, or removes damage marked on a creature." },
    buff_temp  = { name = "Empower",           tag = "Effect", text = "Raises power and toughness (and may grant keywords) until the end of the turn." },
    buff_perm  = { name = "Lasting Empower",   tag = "Effect", text = "Raises power and toughness for as long as the creature stays on the battlefield." },
    weaken     = { name = "Weaken",            tag = "Effect", text = "Lowers power and toughness. A creature whose toughness drops to 0 dies. Dispel on your own creature removes it." },
    tap        = { name = "Tap Down",          tag = "Effect", text = "Taps the creature. A tapped creature can't attack or block until it untaps at the start of its controller's turn." },
    freeze     = { name = "Freeze",            tag = "Effect", text = "Taps the creature, and it doesn't untap during its controller's next untap step." },
    destroy    = { name = "Destroy",           tag = "Effect", text = "Puts the creature straight into its owner's graveyard, whatever its toughness." },
    tuck       = { name = "Return to Library", tag = "Effect", text = "Puts the creature on top of its owner's library, so they draw it again next. Anything attached to it falls off." },
    steal      = { name = "Mind Control",      tag = "Effect", text = "You take control of the enemy creature. It can't attack this turn unless it is only borrowed until end of turn." },
    dot        = { name = "Damage over Time",  tag = "Effect", text = "Deals damage at the start of each of the caster's turns for a number of turns. Effects on players show on the effect bars beside the board." },
    hot        = { name = "Healing over Time", tag = "Effect", text = "Restores health at the start of each of the caster's turns for a number of turns. Effects on players show on the effect bars beside the board." },
    shield     = { name = "Damage Shield",     tag = "Effect", text = "On a player: prevents the next points of damage they would take. On a creature: extra toughness until the end of the turn." },
    regen      = { name = "Regenerate",        tag = "Effect", text = "The next time the creature would die from damage it survives instead: its damage is removed and it becomes tapped. Destroy effects ignore this." },
    dispel     = { name = "Dispel",            tag = "Effect", text = "On an enemy creature: removes its buffs, granted keywords, regeneration and healing over time. On your own creature: removes weakening, damage over time and freeze." },
    draw       = { name = "Card Draw",         tag = "Effect", text = "Draw cards from your library. With 10 cards in hand you discard one first. Drawing from an empty library loses the game." },
    mana       = { name = "Mana Gain",         tag = "Effect", text = "Adds mana straight to your pool. Unspent mana empties at the end of your turn." },
    raise      = { name = "Raise Dead",        tag = "Effect", text = "Returns the most recent creature card in a graveyard to the battlefield under your control." },
    targeting  = { name = "Targeting",         tag = "Effect", text = "After clicking the card, click a target. Right-click cancels. Hexproof enemy creatures can't be chosen." },

    -- Creature and Prayer abilities
    prayer     = { name = "Prayer",            tag = "Ability", text = "Click an untapped Prayer to tap it for one mana of its colour. You can play one Prayer per turn, during a main phase." },
    anthem     = { name = "Anthem",            tag = "Ability", text = "While this creature is on the battlefield, your other creatures that share the tag get the bonus." },
    rally      = { name = "Rally",             tag = "Ability", text = "This creature grows for each other creature you control that shares the tag." },
    activated  = { name = "Activated Ability", tag = "Ability", text = "Click this card during your main phase to use it. If the cost includes {T}, the card must be untapped and free of summoning sickness." },
    triggered  = { name = "Triggered Ability", tag = "Ability", text = "Happens on its own whenever its condition is met." },

    -- States of a card on the battlefield
    sick       = { name = "Summoning Sickness", tag = "Status", text = "Entered the battlefield this turn: it can't attack or use {T} abilities until its controller's next turn." },
    tapped     = { name = "Tapped",            tag = "Status", text = "Can't attack, block or be tapped again until it untaps at the start of its controller's turn." },
    frozen     = { name = "Frozen",            tag = "Status", text = "Won't untap during its controller's next untap step." },
    regenerating = { name = "Regenerating",    tag = "Status", text = "Survives the next lethal damage: its damage is removed and it becomes tapped instead." },
    damaged    = { name = "Damaged",           tag = "Status", text = "It dies if the marked damage reaches its toughness. All damage wears off at the end of the turn." },
    attacking  = { name = "Attacking",         tag = "Status", text = "Declared as an attacker this combat." },
    blocking   = { name = "Blocking",          tag = "Status", text = "Assigned to block an attacker this combat." },
    blocked    = { name = "Blocked",           tag = "Status", text = "A creature is blocking this attacker. Combat damage goes to the blocker instead of the player (unless it has Trample)." },
    selected   = { name = "Choosing Block",    tag = "Status", text = "Selected as a blocker: click an attacking creature to assign it. Right-click to deselect." },
    modified   = { name = "Modified Stats",    tag = "Status", text = "Its power and toughness differ from the printed card." },
    borrowed   = { name = "Borrowed",          tag = "Status", text = "Under your control until the end of the turn, then it returns to its owner." },
}

-- Who an area effect reaches
local AREA_TEXT = {
    enemy_creatures    = "every enemy creature",
    friendly_creatures = "every creature you control",
    all_creatures      = "every creature",
    self_player        = "you",
    enemy_player       = "the opponent",
}

local TARGET_TEXT = {
    enemy_creature    = "an enemy creature",
    friendly_creature = "a creature you control",
    creature          = "any creature",
    enemy_any         = "an enemy creature or the opponent",
    friendly_any      = "yourself or a creature you control",
    any               = "any creature or player",
    enemy_player      = "the opponent",
    player            = "a player",
}

local SPHERE_NAME = { W = "Holy", U = "Arcane", B = "Shadow", R = "Fire", G = "Nature" }
local TAG_FIELD_LABEL = { faction = "faction", zone = "zone", type = "creature type" }

-- =========================================================================
-- PANEL SPECS
-- A spec is { title, tag, color, lines }. lines: strings (wrapped, light
-- grey) or { text, r, g, b }.
-- =========================================================================
function TT:KeywordPanel(key, note)
    local def = TT.KEYWORDS[key]
    if not def then return nil end
    local lines = { Sym(def.text, 14) }
    if note then table.insert(lines, { note, 0.6, 0.9, 0.6 }) end
    return { title = def.name, tag = "Keyword", lines = lines }
end

function TT:SymbolPanel(key, note)
    local def = TT.SYMBOLS[key]
    if not def then return nil end
    local lines = { def.text }
    if note then table.insert(lines, { note, 0.6, 0.9, 0.6 }) end
    return { title = SymbolIcon(key, 16) .. "  " .. def.name, tag = "Symbol", lines = lines }
end

-- extra (optional): more lines under the description, e.g. the numbers on this card
function TT:EffectPanel(id, extra, titleOverride)
    local def = TT.EFFECTS[id]
    if not def then return nil end
    local lines = { Sym(def.text, 14) }
    for _, l in ipairs(extra or {}) do table.insert(lines, l) end
    return { title = titleOverride or def.name, tag = def.tag, lines = lines }
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
        p:AddDoubleLine(spec.title, spec.tag, c[1], c[2], c[3], 0.55, 0.55, 0.55)
    else
        p:AddLine(spec.title, c[1], c[2], c[3])
    end
    for _, line in ipairs(spec.lines or {}) do
        if type(line) == "table" then
            p:AddLine(line[1], line[2] or 0.9, line[3] or 0.9, line[4] or 0.9, true)
        else
            p:AddLine(line, 0.9, 0.9, 0.9, true)
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
        table.insert(remaining, st.stages[i].label)
    end
    if #remaining > 0 then
        mainTip:AddLine(" ")
        mainTip:AddLine("Keep hovering for " .. table.concat(remaining, ", ") .. "...", 0.5, 0.5, 0.5)
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

-- Builds every stage now (so empty ones can be skipped and the hint is right)
local function Prepare(st)
    st.base = (st.opts.base and st.opts.base()) or {}
    st.stages = {}
    for _, stage in ipairs(st.opts.stages or {}) do
        local list = {}
        for _, spec in ipairs(stage.build() or {}) do
            if spec then table.insert(list, spec) end
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
    if card.type == "Land" then return "Prayer" end
    return card.type or "Card"
end

local function FormatPT(power, toughness, damage, colorCode)
    if TTS.FormatPT then return TTS.FormatPT(power, toughness, damage, colorCode) end
    return string.format("%s%d/%d|r", colorCode, power, toughness)
end

local function BuildCardMain(tip, card, ctx)
    tip:AddLine(card.name, 1, 1, 1)
    if ctx.header then ctx.header(tip) end

    local costStr = (card.cost and card.cost ~= "") and Sym(card.cost, 18) or "0"
    tip:AddLine("Cost: " .. costStr .. "  |  " .. DisplayType(card), 0.8, 0.8, 0.8)
    local tagLine = TTS.GetCardTagLine and TTS:GetCardTagLine(card)
    if tagLine then tip:AddLine(tagLine, 1, 1, 1) end

    if card.power and card.toughness then
        local p, t, damage = card.power, card.toughness, 0
        if ctx.perm and TTS.Engine then
            p, t = TTS.Engine:GetCreatureStats(ctx.perm, ctx.isRemote)
            damage = ctx.perm.damage or 0
        end
        tip:AddLine("P/T: " .. FormatPT(p, t, damage, "|cFFFFCC00"), 1, 0.8, 0)
    end

    if card.text and card.text ~= "" then
        tip:AddLine(Sym(card.text, 16), 0.9, 0.9, 0.5, true)
    end

    if ctx.hint then
        tip:AddLine(" ")
        tip:AddLine(ctx.hint, 0.5, 0.5, 0.5)
    end
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
            local lines = { { "Cost: " .. aCost, 0.8, 0.8, 0.8 } }
            if aCard.text and aCard.text ~= "" then table.insert(lines, { Sym(aCard.text, 14), 0.9, 0.9, 0.6 }) end
            table.insert(specs, {
                title = aCard.name,
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
            local lines = { { "Cost: " .. eCost .. "  |  " .. (eCard.type or "Spell"), 0.8, 0.8, 0.8 } }
            if eCard.text and eCard.text ~= "" then table.insert(lines, { Sym(eCard.text, 14), 0.9, 0.9, 0.6 }) end
            table.insert(specs, { title = eCard.name, tag = "Affected by", color = { 0.69, 0.5, 1.0 }, lines = lines })
        end
    end
    return specs
end

local function KeywordPanels(card, ctx)
    local specs, seen = {}, {}
    local E = TTS.Engine
    local function add(kw, note)
        if seen[kw] then return end
        local spec = TT:KeywordPanel(kw, note)
        if spec then
            seen[kw] = true
            table.insert(specs, spec)
        end
    end

    for _, kw in ipairs(TT.KEYWORD_ORDER) do
        if ctx.perm and E and E.HasKeyword then
            if E:HasKeyword(ctx.perm, ctx.isRemote, kw) then
                add(kw, (not card[kw]) and "Granted by another card." or nil)
            elseif card[kw] then
                add(kw, "Currently switched off by another card.")
            end
        elseif card[kw] then
            add(kw)
        end
    end

    -- Keywords this card hands out
    for _, op in ipairs((card.effect and card.effect.ops) or {}) do
        for _, kw in ipairs(op.kw or {}) do add(kw, "This spell grants it until end of turn.") end
    end
    local a = card.anthem
    for _, kw in ipairs((a and a.kw) or {}) do
        add(kw, string.format("Granted to your other %s creatures.", a.value))
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
        table.insert(specs, TT:EffectPanel("damaged", { { Plural(perm.damage, "damage") .. " marked this turn.", 1, 0.3, 0.3 } }))
    end

    -- Combat
    local bs = E.blockingState
    if perm.isAttacking then table.insert(specs, TT:EffectPanel("attacking")) end
    if bs and ctx.fieldIndex then
        local blockerRemote = not bs.isRemoteAttacking
        local otherField = ctx.isRemote and E.localState.field or E.remoteState.field
        if (ctx.isRemote and true or false) == blockerRemote then
            local atkIdx = bs.blocks and bs.blocks[ctx.fieldIndex]
            local atk = atkIdx and otherField[atkIdx]
            if atk and TTS.Cards[atk.id] then
                table.insert(specs, TT:EffectPanel("blocking", { { "Blocking " .. TTS.Cards[atk.id].name .. ".", 0.6, 0.9, 0.6 } }))
            end
            if not ctx.isRemote and bs.selectedBlocker == ctx.fieldIndex then
                table.insert(specs, TT:EffectPanel("selected"))
            end
        elseif perm.isAttacking then
            local names = {}
            for bIdx, aIdx in pairs(bs.blocks or {}) do
                local b = aIdx == ctx.fieldIndex and otherField[bIdx]
                if b and TTS.Cards[b.id] then table.insert(names, TTS.Cards[b.id].name) end
            end
            if #names > 0 then
                table.insert(specs, TT:EffectPanel("blocked", { { "Blocked by " .. table.concat(names, ", ") .. ".", 1, 0.5, 0.5 } }))
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
            local lines = { { string.format("Printed %d/%d, now %d/%d.", card.power, card.toughness, p, t), 1, 0.82, 0 } }
            if tp ~= 0 or tt ~= 0 then table.insert(lines, string.format("%s/%s until end of turn.", Signed(tp), Signed(tt))) end
            if pp ~= 0 or pt ~= 0 then table.insert(lines, string.format("%s/%s permanently.", Signed(pp), Signed(pt))) end
            if op ~= 0 or ot ~= 0 then table.insert(lines, string.format("%s/%s from other cards on the battlefield.", Signed(op), Signed(ot))) end
            table.insert(specs, TT:EffectPanel("modified", lines))
        end
    end

    -- Over-time effects sitting on the creature
    for _, kind in ipairs({ "dot", "hot" }) do
        local list = perm[kind .. "s"]
        if list and #list > 0 then
            local lines = {}
            for _, e in ipairs(list) do
                table.insert(lines, { string.format("%s: %d %s each turn, %s left.", e.src or "Effect", e.n,
                    kind == "dot" and "damage" or "healing", Plural(e.turns, "turn")), 1, 1, 1 })
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
    local area = op.to and AREA_TEXT[op.to]

    if id == "buff" then
        if (op.p or 0) < 0 or (op.t or 0) < 0 then
            id = "weaken"
        else
            id = op.perm and "buff_perm" or "buff_temp"
        end
        if (op.p or 0) ~= 0 or (op.t or 0) ~= 0 then
            table.insert(extra, string.format("%s/%s%s.", Signed(op.p), Signed(op.t), op.perm and "" or " until end of turn"))
        end
    elseif id == "damage" then
        table.insert(extra, string.format("%s.", Plural(op.n or 0, "damage")))
        if op.bonusIfTapped then table.insert(extra, string.format("%d more if the creature is tapped.", op.bonusIfTapped)) end
    elseif id == "heal" then
        table.insert(extra, string.format("Restores %d.", op.n or 0))
    elseif id == "dot" or id == "hot" then
        table.insert(extra, string.format("%d each turn for %s.", op.n or 0, Plural(op.turns or 0, "turn")))
    elseif id == "shield" then
        table.insert(extra, string.format("Absorbs %d.", op.n or 0))
    elseif id == "draw" then
        table.insert(extra, string.format("Draws %s.", Plural(op.n or 0, "card")))
    elseif id == "mana" then
        table.insert(extra, string.format("Adds %s.", Sym(string.rep("{" .. (op.color or "C") .. "}", op.n or 0), 14)))
    elseif id == "destroy" then
        if op.damaged then table.insert(extra, "Only works on a creature that has been dealt damage this turn.") end
        if op.nonColor then table.insert(extra, string.format("Doesn't work on %s creatures.", SPHERE_NAME[op.nonColor] or op.nonColor)) end
    elseif id == "steal" then
        if op.maxPower then table.insert(extra, string.format("Only a creature with %d power or less.", op.maxPower)) end
        table.insert(extra, op.untilEnd and "Until end of turn, then it returns to its owner." or "Permanently.")
    elseif id == "raise" then
        table.insert(extra, op.src == "any" and "From your graveyard or your opponent's." or "From your graveyard.")
    end

    if area then table.insert(extra, { "Affects " .. area .. ".", 0.6, 0.9, 0.6 }) end

    local panel = TT:EffectPanel(id, extra)
    if panel then panel.key = id .. (area or "") end
    return panel
end

local function AbilityPanels(card)
    local specs = {}
    if card.type == "Land" then table.insert(specs, TT:EffectPanel("prayer")) end

    local a = card.anthem
    if a then
        local bonus = string.format("%s/%s", Signed(a.p), Signed(a.t))
        local kws = {}
        for _, kw in ipairs(a.kw or {}) do
            if TT.KEYWORDS[kw] then table.insert(kws, TT.KEYWORDS[kw].name) end
        end
        local line = string.format("Other %s creatures you control get %s", a.value, bonus)
        if #kws > 0 then line = line .. " and " .. table.concat(kws, ", ") end
        table.insert(specs, TT:EffectPanel("anthem", { { line .. ".", 1, 0.82, 0 }, { "Matches by " .. (TAG_FIELD_LABEL[a.tag] or a.tag) .. ".", 0.6, 0.6, 0.6 } }))
    end

    local r = card.rally
    if r then
        table.insert(specs, TT:EffectPanel("rally", {
            { string.format("%s/%s for each other %s creature you control.", Signed(r.p), Signed(r.t), r.value), 1, 0.82, 0 },
            { "Matches by " .. (TAG_FIELD_LABEL[r.tag] or r.tag) .. ".", 0.6, 0.6, 0.6 },
        }))
    end

    local text = card.text or ""
    if card.type == "Creature" and text ~= "" then
        if text:match("^[{%w}]+:") then table.insert(specs, TT:EffectPanel("activated")) end
        if text:find("Whenever") or text:find("%f[%a]When%s") then
            table.insert(specs, TT:EffectPanel("triggered"))
        end
    end

    local eff = card.effect
    if eff then
        if eff.target and TARGET_TEXT[eff.target] then
            table.insert(specs, TT:EffectPanel("targeting", { { "Choose " .. TARGET_TEXT[eff.target] .. ".", 0.6, 0.9, 0.6 } }))
        end
        local seen = {}
        for _, op in ipairs(eff.ops or {}) do
            local panel = OpPanel(op, eff)
            if panel and not seen[panel.key] then
                seen[panel.key] = true
                table.insert(specs, panel)
            end
        end
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

    for token in ((card.cost or "") .. " " .. (card.text or "")):gmatch("{(%w+)}") do
        local key = token:upper()
        if tonumber(token) then key = "GENERIC" end
        if key == "TAP" then key = "T" end
        add(key)
    end

    -- Symbols drawn on the card itself on the board
    if ctx.perm then
        if ctx.perm.tapped then add("T", "Shown over this card because it is tapped.") end
        local deaths = TTS.BoardFrame and TTS.BoardFrame.predictedDeaths
        if deaths and deaths[ctx.perm] then add("SKULL") end
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
                tip:AddLine("Damage Shield", c[1], c[2], c[3])
                tip:AddLine(string.format("Prevents the next %d damage.", e.n), 1, 1, 1, true)
            else
                tip:AddLine(e.src or "Effect", c[1], c[2], c[3])
                if e.kind == "dot" then
                    tip:AddLine(string.format("Takes %d damage each turn.", e.n), 1, 1, 1, true)
                else
                    tip:AddLine(string.format("Restores %d life each turn.", e.n), 1, 1, 1, true)
                end
                tip:AddLine(string.format("%s remaining", Plural(e.turns, "turn")), 0.8, 0.8, 0.8)
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
            tip:AddLine(SymbolIcon(key, 18) .. "  " .. def.name .. " Mana", 1, 1, 1)
            tip:AddLine(string.format("In your mana pool: %d", amount or 0), 1, 0.82, 0)
            tip:AddLine(def.text, 0.7, 0.7, 0.7, true)
        end,
    })
end