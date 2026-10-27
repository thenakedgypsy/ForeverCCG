--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

-- =========================================================================
-- CARD EFFECTS (the cardEffects option)
-- Animations and spell visual kits on the 3D models of denizens on the battlefield.
--  * Each board redraw compares every denizen with how it was last time (Snapshot / Diff)
--    and plays what changed: a wound when it takes damage, a heal, a buff, a death...
--  * Lasting states (Shielded, Soulstone, Frozen, DoT / HoT, borrowed) keep a looping kit
--    on the model while they last. No call takes one kit off a model, so a state that ends
--    loads the model again and puts back the kits still wanted.
--  * With FX.ON_FRAME the kits play on the card's FX layer instead: an invisible carrier
--    model over the whole card (see THE FX LAYER). Animations stay on the denizen's model.
--  * A few engine hooks add what the comparison can't tell: the colour of the spell that
--    dealt damage, a Dispel, who fought in combat, an activated ability.
-- Written without the client to hand: every model call goes through FX:Call, which turns a
-- method off for the session the first time it is missing or errors, and "/tragic fx"
-- reports what worked ("/tragic fx kit <id>" / "anim <id>" try one on the hovered card).
-- Kit ids are from the client's SpellVisualKit data (build 1.60.1.70532), each named after
-- the spell it comes from. Load after UI\Board.lua.
-- =========================================================================
local B = TTS.BoardFrame
local E = TTS.Engine
if not (B and E) then return end
local L = TTS.L

TTS.CardFX = TTS.CardFX or {}
local FX = TTS.CardFX

-- AnimationData ids (a model without one falls back along the client's own chain)
local ANIM = {
    STAND = 0, DEATH = 1, DEAD = 6, WOUND = 9, CRIT = 10, STUN = 14,
    ATTACK = 17, SHIELD_BLOCK = 24, CAST = 54, ROAR = 55,
}
FX.ANIM = ANIM

-- Looping kits shown while a state lasts (Snapshot's fields); onModel: on the denizen's own
-- model even with the FX layer on (dropping it loads the model again)
FX.LASTING = {
    { state = "shielded", kit = 847 },    -- Power Word: Shield (or Divine Shield, 252)
    { state = "soul",     kit = 3769 },   -- Power Infusion: a stand-in for Soulstone (or Banish, 1286)
    { state = "frozen",   kit = 3709, onModel = true },   -- Ice Block / Freezing Trap's ice, until it untaps
    { state = "borrowed", kit = 325 },    -- Mind Control
}

-- Each DoT / HoT keeps a looping kit by the colour of the card that cast it (its srcId);
-- default: one whose card isn't known, or a colour without its own
FX.DOT_KITS = {
    B = 535,     -- Corruption
    R = 76,      -- Immolate's burn (its aura kit, 235, doesn't show on the FX layer's carrier)
    W = 76,      -- Immolate's burn (Holy Fire has no looping kit)
    U = 360,     -- Slow's arcane (Moonfire, Arcane Shot)
    G = 6556,    -- Insect Swarm (Serpent Sting)
    default = 535,
}
FX.HOT_KITS = {
    W = 436,     -- Renew
    G = 6966,    -- Lifebloom (Rejuvenation and Regrowth have no looping kit)
    default = 436,
}

-- Adds to want the kit of each DoT / HoT in list (kits: FX.DOT_KITS / FX.HOT_KITS)
local function OverTimeKits(want, list, kits)
    for _, e in ipairs(list or {}) do
        local card = e.srcId and TTS.Cards[e.srcId]
        local color = card and type(card.color) == "string" and card.color:sub(1, 1)
        want[kits[color] or kits.default] = true
    end
end

-- Impact kit on damage from a spell or ability, by the card's colour
FX.IMPACT = {
    R = 286,    -- Fireball
    B = 219,    -- Shadow Bolt
    U = 4991,   -- Frostbolt
    G = 283,    -- Lightning Bolt
    W = 291,    -- Smite
}

-- What each event plays: an animation (time: how long it runs before the model goes back
-- to standing; hold: the animation it stays on after) and / or a one-shot kit. When several
-- happen at once every kit plays, and the first of them in EVENT_ORDER gets the animation.
-- onModel: the kit plays on the denizen's own model, not the FX layer (gear and aura buffs).
-- settleBoard: the event waits for every card on the board to settle (FX:AfterBoardSettled),
-- not just its own: an Aura's or Kinsmanship's bonus plays once the card giving it has landed.
FX.EVENTS = {
    died      = { anim = ANIM.DEATH, hold = ANIM.DEAD },
    returned  = { kit = 3394 },                          -- Blink
    soulSave  = { anim = ANIM.CRIT, kit = 4212 },        -- Soulstone Resurrection
    crit      = { anim = ANIM.CRIT },                    -- half its toughness or more (+ FX.IMPACT)
    hit       = { anim = ANIM.WOUND },                   -- (+ FX.IMPACT)
    shieldPop = { anim = ANIM.SHIELD_BLOCK },
    freeze    = { anim = ANIM.STUN, time = 0.3 },        -- then the model pauses
    weaken    = { kit = 719 },                           -- Curse of Weakness
    buff      = { anim = ANIM.ROAR, kit = 456, onModel = true, settleBoard = true },   -- Blessing of Might
    empower   = { anim = ANIM.ROAR, kit = 388, onModel = true, settleBoard = true },   -- Battle Shout (a keyword gained)
    heal      = { kit = 232 },                           -- Heal
    dispel    = { kit = 226 },                           -- Dispel Magic
    cast      = { anim = ANIM.CAST },                    -- an activated ability
}
FX.EVENT_ORDER = { "died", "returned", "soulSave", "crit", "hit", "shieldPop", "freeze",
    "weaken", "buff", "empower", "heal", "dispel", "cast" }
FX.STRIKE_ANIM = ANIM.ATTACK   -- combat: plays first, the rest of that redraw's effects after STRIKE_LEAD
FX.SWING_SOUND = 3091          -- Heroic Strike's cast: the attackers swinging (with "Targeting & hit sounds")

FX.STAGGER = 0.08          -- seconds between denizens whose effects start in the same redraw
FX.STRIKE_LEAD = 0.35      -- a combat swing lands before the wounds it deals
FX.ONESHOT_TIME = 1.2      -- back to standing after a one-shot animation, if OnAnimFinished never comes
FX.LOAD_WAIT = 0.5         -- lasting kits go on when the model has loaded, or after this long
FX.FRONT_TIME = 1.2        -- a one-shot effect brings the model in front of the card frame and tap symbol this long

-- Kits on the FX layer rather than the denizen's model ("/tragic fx layer" switches it for
-- the session). displayId: the invisible carrier; pad: how far past the card's edges the
-- layer reaches, as a share of its size (kits are cut off at the layer's edges); drop: how
-- far the layer sits below the card's centre, as a share of its height; camScale: the
-- carrier's camera distance, which sets how big its kits look ("/tragic fx carrier <id>" /
-- "drop <share>" / "cam <scale>" try others).
FX.ON_FRAME = true
-- plateDrop / plateScale: the life plates' drop, and how much bigger their kits look than a card's
FX.LAYER = { displayId = 11686, pad = 0.75, drop = 0.5, plateDrop = 0.2, plateScale = 1.3, camScale = 2.0 }

function FX:Enabled()
    return TTS.Options and TTS.Options:Get("cardEffects") and true or false
end

-- =========================================================================
-- GUARDED MODEL CALLS
-- FX.trace (tests): called with (model, method, ...) before every call.
-- =========================================================================
local report, broken = {}, {}

function FX:Call(model, method, ...)
    if FX.trace then FX.trace(model, method, ...) end
    local r = report[method]
    if not r then
        r = { ok = 0, failed = 0, skipped = 0 }
        report[method] = r
    end
    if broken[method] then r.skipped = r.skipped + 1; return false end
    local fn = model and model[method]
    if type(fn) ~= "function" then
        r.missing, broken[method] = true, true
        return false
    end
    local ok, err = pcall(fn, model, ...)
    if ok then r.ok = r.ok + 1; return true end
    r.failed, r.err, broken[method] = r.failed + 1, tostring(err), true
    return false
end

-- =========================================================================
-- WHAT CHANGED
-- =========================================================================
local KW_SKIP = { shielded = true, kinsmanship = true, unique = true }   -- shown by their own effects, or not on a denizen

-- Frozen lasts until the denizen untaps: the engine clears perm.freezeUntap at the untap it
-- skips, leaving it tapped until the next one
local iced = setmetatable({}, { __mode = "k" })
local function Frozen(perm)
    if perm.freezeUntap then
        iced[perm] = true
    elseif not perm.tapped then
        iced[perm] = nil
    end
    return iced[perm] or false
end

function FX:Snapshot(eng, perm, isRemote)
    local p, t = eng:GetCreatureStats(perm, isRemote)
    local kw = {}
    for _, k in ipairs(TTS.Tooltip.KEYWORD_ORDER) do
        if not KW_SKIP[k] and eng:HasKeyword(perm, isRemote, k) then kw[k] = true end
    end
    local borrowed = false
    for _, s in ipairs(eng.stolenCreatures or {}) do
        if s.perm == perm then borrowed = true end
    end
    return {
        damage = perm.damage or 0, p = p, t = t, kw = kw,
        shielded = perm.shielded and true or false,
        soul = perm.regenerateShield and true or false,
        frozen = Frozen(perm),
        dots = (perm.dots and #perm.dots > 0) and true or false,
        hots = (perm.hots and #perm.hots > 0) and true or false,
        borrowed = borrowed,
    }
end

-- The events between two snapshots of a denizen, in EVENT_ORDER. Nothing on first sight.
-- cause (optional): { dispelled, cast } from the engine hooks since the last redraw.
function FX.Diff(prev, cur, cause)
    if not prev then return {} end
    cause = cause or {}
    local on = {}
    if prev.soul and not cur.soul and not cause.dispelled then
        on.soulSave = true      -- its damage was wiped too: not a heal
    elseif cur.damage > prev.damage then
        on[(cur.damage - prev.damage) * 2 >= cur.t and "crit" or "hit"] = true
    elseif cur.damage < prev.damage then
        on.heal = true
    end
    if prev.shielded and not cur.shielded then
        on[cause.dispelled and "dispel" or "shieldPop"] = true
    end
    if cur.frozen and not prev.frozen then on.freeze = true end
    local stats = (cur.p + cur.t) - (prev.p + prev.t)
    if stats > 0 then on.buff = true elseif stats < 0 then on.weaken = true end
    for k in pairs(cur.kw) do
        if not prev.kw[k] and not on.buff then on.empower = true end
    end
    if cause.dispelled then on.dispel = true end
    if cause.cast then on.cast = true end
    local events = {}
    for _, name in ipairs(FX.EVENT_ORDER) do
        if on[name] then events[#events + 1] = name end
    end
    return events
end

-- =========================================================================
-- ENGINE HOOKS
-- =========================================================================
local causes = setmetatable({}, { __mode = "k" })   -- perm -> { color, dispelled, strike, cast }
local snaps = setmetatable({}, { __mode = "k" })    -- perm -> last Snapshot
local castColor                                      -- colour of the spell op resolving now

local function Cause(perm)
    local c = causes[perm]
    if not c then c = {}; causes[perm] = c end
    return c
end

-- What a Dispel can strip, per denizen on the battlefield
local function DispelMarks(eng)
    local marks = {}
    for _, field in ipairs({ eng.localState.field, eng.remoteState.field }) do
        for _, p in ipairs(field) do
            marks[p] = table.concat({ tostring(p.shielded), tostring(p.regenerateShield), tostring(p.tempKw),
                tostring(p.permKw), tostring(p.hots), tostring(p.dots), tostring(p.freezeUntap),
                p.tempPower or 0, p.tempToughness or 0, p.permPower or 0, p.permToughness or 0 }, ",")
        end
    end
    return marks
end

-- Every denizen's snapshot taken again, so what just changed plays nothing
local function Resnap(eng)
    for _, isRemote in ipairs({ false, true }) do
        for _, p in ipairs((isRemote and eng.remoteState or eng.localState).field) do
            if snaps[p] then snaps[p] = FX:Snapshot(eng, p, isRemote) end
        end
    end
end

-- (each through E:HookDisplay, CoreEngine.lua: an error here never stops the game itself)
do
    E:HookDisplay("ApplySpellOp", function(self, op, tgt, card)
        if not FX:Enabled() then return end
        local state = { was = castColor, marks = op and op.op == "dispel" and DispelMarks(self) }
        castColor = card and type(card.color) == "string" and card.color:sub(1, 1) or nil
        return state
    end, function(state, self)
        if not state then return end
        castColor = state.was
        if state.marks then
            for p, mark in pairs(DispelMarks(self)) do
                if state.marks[p] and state.marks[p] ~= mark then Cause(p).dispelled = true end
            end
        end
    end)

    E:HookDisplay("DamageCreature", nil, function(_, self, results, perm)
        if castColor and perm and (results[1] or 0) > 0 then Cause(perm).color = castColor end
    end)

    -- Everyone in the fight swings
    E:HookDisplay("ResolveCombatDamage", function(self)
        local bs = self.blockingState
        if not (bs and FX:Enabled()) then return end
        local atkField = (bs.isRemoteAttacking and self.remoteState or self.localState).field
        local blkField = (bs.isRemoteAttacking and self.localState or self.remoteState).field
        for _, i in ipairs(bs.attackers or {}) do
            if atkField[i] then
                local c = Cause(atkField[i])
                c.strike = true
                c.swing = not self.preventCombatDamage   -- (FX.SWING_SOUND)
            end
        end
        for _, pair in ipairs(self:BlockPairs(bs)) do
            if blkField[pair[1]] then Cause(blkField[pair[1]]).strike = true end
        end
    end)

    E:HookDisplay("ActivateAbility", nil, function(_, self, results, perm)
        if results[1] and perm and FX:Enabled() then Cause(perm).cast = true end
    end)

    -- "Until end of turn" wearing off, and damage wiped, are not weakening or healing
    E:HookDisplay("EndTurnCleanup", nil, function(_, self) Resnap(self) end)
end

-- =========================================================================
-- MODELS
-- Per card frame: f.fxPerm (the denizen it shows), f.fxKits (lasting kits on its model),
-- f.fxWant (kits it should have), f.fxPaused / f.fxWantPause (Frozen), f.fxBase (the
-- animation it rests on: standing, or dead), f.fxOneShot (an animation playing).
-- =========================================================================
local frameOf = setmetatable({}, { __mode = "k" })     -- perm -> the frame showing it
local seenLeaving = setmetatable({}, { __mode = "k" })

local function Valid(f, perm)
    return f and f.fxPerm == perm and f:IsShown() and f.model and f.model:IsShown()
end

function FX:EndOneShot(f)
    f.fxOneShot = nil
    if f.fxHold then f.fxBase, f.fxHold = f.fxHold, nil end
    if f.fxWantPause then
        if self:Call(f.model, "SetPaused", true) then f.fxPaused = true end
    else
        self:Call(f.model, "SetAnimation", f.fxBase or ANIM.STAND)
    end
end

-- The model in front of its card frame and tap symbol for FX.FRONT_TIME (Board.lua
-- SetModelInFront); another effect in that time starts the wait again
function FX:InFront(f)
    if not f.SetModelInFront then return end
    f:SetModelInFront(true)
    local token = {}
    f.fxFrontToken = token
    TTS:SafeAfter(FX.FRONT_TIME, function()
        if f.fxFrontToken == token then FX:Behind(f) end
    end)
end

function FX:Behind(f)
    f.fxFrontToken = nil
    if f.SetModelInFront then f:SetModelInFront(false) end
end

-- A death outranks everything: once it plays, a swing or wound still on its way (a combat
-- swing lands STRIKE_LEAD late) is dropped
function FX:OneShot(f, anim, time, hold)
    if f.fxDying and anim ~= ANIM.DEATH then return end
    if anim == ANIM.DEATH then f.fxDying = true end
    if f.fxPaused then
        self:Call(f.model, "SetPaused", false)
        f.fxPaused = false
    end
    if not self:Call(f.model, "SetAnimation", anim) then return end
    self:InFront(f)
    local token = {}
    f.fxOneShot, f.fxOneShotAt, f.fxHold = token, GetTime(), hold
    TTS:SafeAfter(time or FX.ONESHOT_TIME, function()
        if f.fxOneShot == token then FX:EndOneShot(f) end
    end)
end

-- =========================================================================
-- THE FX LAYER
-- f.fxLayer: a model over the whole card (FX.LAYER.pad past its edges), showing only an
-- invisible carrier for kits to play on. Kits there aren't cut off at the art box, and
-- dropping a lasting kit reloads just the carrier. It sits a strata above the board, so
-- nothing on a card covers it (not even a model brought in front for a death); dialogs and
-- card previews still do. The life plates have one too (see PLAYERS), sized like a card's
-- (f.fxAsCard: { width, height }) so their kits look the same size.
-- =========================================================================
-- size (optional): how big its kits look, as a share of the usual (the camera stands back)
local function LayerCamera(m, size)
    FX:Call(m, "SetPortraitZoom", 0)
    FX:Call(m, "SetCamDistanceScale", FX.LAYER.camScale / (size or 1))
    FX:Call(m, "SetPosition", 0, 0, 0)
end

-- A frame without a model of its own (a life plate) always has its kits on its FX layer
local function OnLayer(f)
    return FX.ON_FRAME or not f.model
end

-- The model kits go on
function FX:KitModel(f)
    if OnLayer(f) then return f.fxLayer end
    return f.model
end

function FX:Layer(f)
    local m = f.fxLayer
    if m then return m end
    m = CreateFrame("PlayerModel", nil, f)
    m:EnableMouse(false)
    m:SetFrameStrata("HIGH")
    m:SetFrameLevel(f:GetFrameLevel() + 5)   -- (kept there by Board.lua's SyncFrameLevels)
    m:Hide()
    if m.HasScript and m:HasScript("OnModelLoaded") then
        m:HookScript("OnModelLoaded", function()
            LayerCamera(m)
            if OnLayer(f) then FX:Loaded(f) end
        end)
    end
    f.fxLayer = m
    return m
end

-- The carrier loaded again with no kits on it; the lasting ones go back once it has loaded
-- Sizes and places a carrier model over f; raise: a share of f's height to move it up
local function PlaceLayer(f, m, raise)
    local w, h = f:GetWidth(), f:GetHeight()
    if f.fxAsCard then w, h = f.fxAsCard[1] * FX.LAYER.plateScale, f.fxAsCard[2] * FX.LAYER.plateScale end
    m:ClearAllPoints()
    m:SetSize(w * (1 + 2 * FX.LAYER.pad), h * (1 + 2 * FX.LAYER.pad))
    m:SetPoint("CENTER", f, "CENTER", 0, h * ((raise or 0) - (f.fxAsCard and FX.LAYER.plateDrop or FX.LAYER.drop)))
end

function FX:LoadLayer(f)
    local m = self:Layer(f)
    PlaceLayer(f, m)
    m:Show()
    m:ClearModel()
    m:SetDisplayInfo(FX.LAYER.displayId)
    LayerCamera(m)
    f.fxKits, f.fxReloading = {}, nil
    self:HideRaised(f)   -- (shown again with the lasting kits)
    self:WaitForLoad(f)
end

function FX:HideLayer(f)
    if not f.fxLayer then return end
    f.fxLayer:ClearModel()
    f.fxLayer:Hide()
    f.fxPending = nil
    self:HideRaised(f)
    if OnLayer(f) then f.fxKits = {} end
end

-- Lasting kits placed on a card apart from the FX layer's (FX.KIT_PLACE: raise, a share of
-- the card's height to move it up; size, how big it looks as a share of the usual) each
-- have a carrier of their own (f.fxRaised[kit]), shown while wanted.
-- "/tragic fx place <kit> <raise> [size]" tries others.
FX.KIT_PLACE = {
    [847]  = { raise = 0.5 },                 -- Power Word: Shield
}

local function Raised(f, kit)
    return OnLayer(f) and not f.fxAsCard and FX.KIT_PLACE[kit]
end

function FX:ShowRaised(f, kit, on)
    f.fxRaised = f.fxRaised or {}
    local m = f.fxRaised[kit]
    if not on then
        if m and m:IsShown() then m:ClearModel(); m:Hide() end
        return
    end
    if m and m:IsShown() then return end
    if not m then
        m = CreateFrame("PlayerModel", nil, f)
        m:EnableMouse(false)
        m:SetFrameStrata("HIGH")
        m:SetFrameLevel(f:GetFrameLevel() + 5)
        f.fxRaised[kit] = m
    end
    local place = FX.KIT_PLACE[kit]
    PlaceLayer(f, m, place.raise)
    m:Show()
    m:ClearModel()
    m:SetDisplayInfo(FX.LAYER.displayId)
    LayerCamera(m, place.size)
    -- (its kit goes on once the carrier has loaded)
    local token = {}
    m.fxToken = token
    TTS:SafeAfter(FX.LOAD_WAIT, function()
        if m.fxToken == token and m:IsShown() then
            LayerCamera(m, place.size)
            FX:Call(m, "ApplySpellVisualKit", kit, false)
        end
    end)
end

function FX:HideRaised(f)
    for kit in pairs(f.fxRaised or {}) do self:ShowRaised(f, kit, false) end
end

-- Kits wait for their card to settle (Board.lua's B.IsMoving: flying in, sliding to a new
-- slot, spawning), checking every FX.SETTLE_POLL; after FX.SETTLE_MAX they play anyway
FX.SETTLE_POLL = 0.05
FX.SETTLE_MAX = 2

local function Moving(f)
    return B.IsMoving and B.IsMoving(f)
end

function FX:AfterSettled(f, fn, waited)
    waited = waited or 0
    if not Moving(f) or waited >= FX.SETTLE_MAX then return fn() end
    TTS:SafeAfter(FX.SETTLE_POLL, function() FX:AfterSettled(f, fn, waited + FX.SETTLE_POLL) end)
end

-- The same for every card on the board (an event's settleBoard: a bonus another card's
-- arrival gave, which plays once that card has landed even if this one never moved)
local function BoardMoving()
    return B.AnyMoving and B.AnyMoving()
end

function FX:AfterBoardSettled(fn, waited)
    waited = waited or 0
    if not BoardMoving() or waited >= FX.SETTLE_MAX then return fn() end
    TTS:SafeAfter(FX.SETTLE_POLL, function() FX:AfterBoardSettled(fn, waited + FX.SETTLE_POLL) end)
end

-- A one-shot kit, once the card has settled; on an FX layer still loading it waits for the
-- carrier too (a dying denizen often moves to another frame, whose layer has only just
-- started loading). A kit for a denizen that has gone from the frame by then is dropped.
-- onModel: on the denizen's own model even with the FX layer on (an event's onModel).
function FX:PlayKit(f, kit, onModel)
    if Moving(f) then
        local perm = f.fxPerm
        self:AfterSettled(f, function()
            if f.fxPerm == perm then FX:PlayKit(f, kit, onModel) end
        end)
        return true
    end
    if onModel and f.model then return self:Call(f.model, "ApplySpellVisualKit", kit, true) end
    if OnLayer(f) and f.fxLoaded == false then
        f.fxPending = f.fxPending or {}
        table.insert(f.fxPending, kit)
        return true
    end
    return self:Call(self:KitModel(f), "ApplySpellVisualKit", kit, true)
end

-- Lasting kits go on when the kit model has loaded, or after FX.LOAD_WAIT
function FX:WaitForLoad(f)
    f.fxLoaded = false
    local token = {}
    f.fxLoadToken = token
    TTS:SafeAfter(FX.LOAD_WAIT, function()
        if f.fxLoadToken == token then FX:Loaded(f) end
    end)
end

function FX:Loaded(f)
    if f.fxLoaded ~= false then return end
    f.fxLoaded = true
    if not (f.fxPerm and FX:Enabled()) then return end
    FX:ApplyLasting(f)
    local pending = f.fxPending
    f.fxPending = nil
    for _, kit in ipairs(pending or {}) do FX:PlayKit(f, kit) end
end

-- Puts the wanted lasting kits on the kit model, and pauses or wakes the model for Frozen
function FX:ApplyLasting(f)
    if f.fxReloading or f.fxLoaded == false then return end
    if Moving(f) then
        if not f.fxSettling then
            f.fxSettling = true
            self:AfterSettled(f, function()
                f.fxSettling = nil
                if f.fxPerm and FX:Enabled() then FX:ApplyLasting(f) end
            end)
        end
        return
    end
    -- Lasting kits on the denizen's own model (FX.LASTING's onModel, f.fxWantModel), once it
    -- has loaded; one no longer wanted loads the model again (ModelReset puts the rest back)
    if f.model and f.fxModelLoaded ~= false then
        local wantM, haveM = f.fxWantModel or {}, f.fxModelKits or {}
        for kit in pairs(haveM) do
            if not wantM[kit] then
                f.fxReloading = true
                B.QueueModelReload(f)
                return
            end
        end
        for kit in pairs(wantM) do
            if not haveM[kit] and self:Call(f.model, "ApplySpellVisualKit", kit, false) then haveM[kit] = true end
        end
        f.fxModelKits = haveM
    end
    local km = self:KitModel(f)
    if not km then return end
    local want, have = {}, f.fxKits or {}
    for kit in pairs(f.fxWant or {}) do
        if not Raised(f, kit) then want[kit] = true end
    end
    for kit in pairs(FX.KIT_PLACE) do
        if Raised(f, kit) then self:ShowRaised(f, kit, (f.fxWant or {})[kit] and true or false) end
    end
    for kit in pairs(have) do
        if not want[kit] then
            if OnLayer(f) then
                self:LoadLayer(f)
            else
                f.fxReloading = true
                B.QueueModelReload(f)
            end
            return
        end
    end
    for kit in pairs(want) do
        if not have[kit] and self:Call(km, "ApplySpellVisualKit", kit, false) then have[kit] = true end
    end
    f.fxKits = have
    if not f.fxOneShot and (f.fxPaused or false) ~= (f.fxWantPause or false) then
        if f.fxWantPause then
            if self:Call(f.model, "SetPaused", true) then f.fxPaused = true end
        else
            self:Call(f.model, "SetPaused", false)
            f.fxPaused = false
            self:Call(f.model, "SetAnimation", f.fxBase or ANIM.STAND)
        end
    end
end

-- Board.lua: the frame's model was just set again (a new card, or reloaded). Kits, pauses and
-- animations are gone with the old model; lasting kits go back on once it has loaded. The FX
-- layer loads again with it (a model reloaded for a resize would otherwise drift).
function FX:ModelReset(f)
    local m = f.model
    if not m then return end
    if not m.fxHooked then
        m.fxHooked = true
        if m.HasScript and m:HasScript("OnModelLoaded") then
            m:HookScript("OnModelLoaded", function()
                if FX.ON_FRAME then FX:ModelLoaded(f) else FX:Loaded(f) end
            end)
        end
        if m.HasScript and m:HasScript("OnAnimFinished") then
            -- (one that ends just as ours starts is the animation we replaced)
            m:HookScript("OnAnimFinished", function()
                if f.fxOneShot and GetTime() - (f.fxOneShotAt or 0) > 0.2 then FX:EndOneShot(f) end
            end)
        end
    end
    -- (pausing belongs to the frame, not the model, so it may outlast a reload)
    if f.fxPaused then self:Call(m, "SetPaused", false) end
    f.fxKits, f.fxPaused, f.fxOneShot, f.fxHold, f.fxReloading = {}, nil, nil, nil, nil
    f.fxModelKits = {}
    self:Behind(f)
    if f.fxBase ~= ANIM.DEAD then f.fxBase = nil end
    if not self:Enabled() then return end
    if not FX.ON_FRAME then
        self:WaitForLoad(f)
        return
    end
    -- The model's own lasting kits go back once it has loaded (or after FX.LOAD_WAIT)
    f.fxModelLoaded = false
    local token = {}
    f.fxModelToken = token
    TTS:SafeAfter(FX.LOAD_WAIT, function()
        if f.fxModelToken == token then FX:ModelLoaded(f) end
    end)
    if f.fxLayer and f.fxLayer:IsShown() then self:LoadLayer(f) end
end

function FX:ModelLoaded(f)
    if f.fxModelLoaded ~= false then return end
    f.fxModelLoaded = true
    if f.fxPerm and FX:Enabled() then FX:ApplyLasting(f) end
end

-- The frame no longer shows a denizen with effects
function FX:Release(f)
    f.fxPerm, f.fxWant, f.fxWantModel, f.fxWantPause, f.fxDying = nil, nil, nil, nil, nil
    if f.fxPaused then self:Call(f.model, "SetPaused", false); f.fxPaused = false end
    if f.fxBase and f.fxBase ~= ANIM.STAND then self:Call(f.model, "SetAnimation", ANIM.STAND) end
    f.fxBase, f.fxOneShot = nil, nil
    self:Behind(f)
    self:HideLayer(f)
end

-- =========================================================================
-- EACH REDRAW (Board.lua's UpdateDisplay)
-- =========================================================================
local function SyncFrame(f, isRemote, batch)
    local perm = f:IsShown() and f.perm
    local card = perm and TTS.Cards[perm.id]
    if not (card and card.type == "Creature" and f.model and f.model:IsShown()) then
        if f.fxPerm then FX:Release(f) end
        return
    end
    if f.fxPerm ~= perm then
        if f.fxPerm then FX:Release(f) end
        f.fxPerm = perm
    end
    if FX.ON_FRAME and not (f.fxLayer and f.fxLayer:IsShown()) then FX:LoadLayer(f) end
    frameOf[perm] = f
    if f.leavingKind then
        if not seenLeaving[perm] then
            seenLeaving[perm] = true
            -- (a spell that killed it still lands with its impact)
            local cause = causes[perm]
            causes[perm] = nil
            batch[#batch + 1] = { perm = perm, events = { f.leavingKind }, color = cause and cause.color }
        end
        return
    end
    local cur = FX:Snapshot(E, perm, isRemote)
    local cause = causes[perm]
    causes[perm] = nil
    local events = FX.Diff(snaps[perm], cur, cause)
    snaps[perm] = cur

    f.fxWant, f.fxWantModel = {}, {}
    for _, l in ipairs(FX.LASTING) do
        -- (with the FX layer off, every kit is on the model anyway)
        if cur[l.state] then
            if l.onModel and FX.ON_FRAME then f.fxWantModel[l.kit] = true else f.fxWant[l.kit] = true end
        end
    end
    OverTimeKits(f.fxWant, perm.dots, FX.DOT_KITS)
    OverTimeKits(f.fxWant, perm.hots, FX.HOT_KITS)
    f.fxWantPause = cur.frozen
    FX:ApplyLasting(f)

    if #events > 0 or (cause and cause.strike) then
        batch[#batch + 1] = { perm = perm, events = events, strike = cause and cause.strike,
            swing = cause and cause.swing, color = cause and cause.color }
    end
end

-- Plays one denizen's events on whichever frame shows it by then (settled: the board has
-- been waited for already)
local function PlayEvents(perm, events, color, settled)
    if not settled then
        for _, name in ipairs(events) do
            if FX.EVENTS[name].settleBoard and BoardMoving() then
                FX:AfterBoardSettled(function() PlayEvents(perm, events, color, true) end)
                return
            end
        end
    end
    local f = frameOf[perm]
    if not Valid(f, perm) then return end
    for _, name in ipairs(events) do
        local def = FX.EVENTS[name]
        local kit = def.kit or ((name == "hit" or name == "crit" or name == "died") and color and FX.IMPACT[color])
        -- (on the FX layer a kit needs no room in front of the card frame)
        if kit and FX:PlayKit(f, kit, def.onModel) and not FX.ON_FRAME then FX:InFront(f) end
    end
    for _, name in ipairs(events) do
        local def = FX.EVENTS[name]
        if def.anim then
            FX:OneShot(f, def.anim, def.time, def.hold)
            break
        end
    end
end

local function Later(delay, fn)
    if delay <= 0 then fn() else TTS:SafeAfter(delay, fn) end
end

-- =========================================================================
-- PLAYERS
-- Each life plate has an FX layer too (plate.fxPerm marks it as in use). A damage shield,
-- DoTs and HoTs on a player keep their looping kits there; gaining life plays the heal, and
-- a spell's damage plays its colour's impact as its number lands (UI\TargetFX.lua calls
-- FX:PlayerHit).
-- =========================================================================
FX.PLAYER_SHIELD = 847                  -- Power Word: Shield
FX.PLAYER_HEAL = 232                    -- Heal
FX.PLATE_AS_CARD = { 64, 84 }           -- a battlefield card's size (Board.lua's LAYOUT.BF_CARD_W / H)

local playerSnaps = {}   -- isRemote -> { life }; cleared when a match starts

local function Plate(isRemote)
    local plate = isRemote and B.oppLifeBtn or B.myLifeBtn
    plate.fxAsCard = FX.PLATE_AS_CARD
    return plate
end

-- A player's damage shield as this client sees it (the PvP opponent's is our copy of theirs)
local function PlayerShield(isRemote)
    if isRemote and not E.isSolo then
        local m = E.remoteState.mirror
        return m and m.shield or 0
    end
    return (isRemote and E.remoteState or E.localState).damageShield or 0
end

function FX:SyncPlayers()
    for _, isRemote in ipairs({ false, true }) do
        local plate = Plate(isRemote)
        local state = isRemote and E.remoteState or E.localState
        plate.fxPerm = true
        if not (plate.fxLayer and plate.fxLayer:IsShown()) then self:LoadLayer(plate) end
        local cur = { life = state.life or 0 }
        plate.fxWant = {}
        if PlayerShield(isRemote) > 0 then plate.fxWant[FX.PLAYER_SHIELD] = true end
        -- Ours and, in PvP, the opponent's copy of the ones they put on this player (st.mirror)
        for _, holder in ipairs({ state, state.mirror or {} }) do
            OverTimeKits(plate.fxWant, holder.dots, FX.DOT_KITS)
            OverTimeKits(plate.fxWant, holder.hots, FX.HOT_KITS)
        end
        self:ApplyLasting(plate)
        local prev = playerSnaps[isRemote]
        playerSnaps[isRemote] = cur
        if prev and cur.life > prev.life then
            -- (a drain's heal waits for its life to land: FX:PlayerHeal)
            if plate.fxDrainComing then plate.fxDrainComing = nil else self:PlayKit(plate, FX.PLAYER_HEAL) end
        end
    end
end

-- TargetFX.lua: life drained to this player is on its way (its heal plays as it lands, not
-- with the redraw that gave it), then landing with its sound
function FX:DrainComing(isRemote)
    Plate(isRemote).fxDrainComing = true
end

function FX:PlayerHeal(isRemote)
    if not self:Enabled() then return end
    local plate = Plate(isRemote)
    if plate.fxLayer and plate.fxLayer:IsShown() then self:PlayKit(plate, FX.PLAYER_HEAL) end
end

-- TargetFX.lua: a spell's damage landing on a player (color: its colour key, "R" ...)
function FX:PlayerHit(isRemote, color)
    local kit = color and FX.IMPACT[color]
    if not (kit and self:Enabled()) then return end
    local plate = Plate(isRemote)
    if plate.fxLayer and plate.fxLayer:IsShown() then self:PlayKit(plate, kit) end
end

-- A new match: its starting life is no heal
E:HookDisplay("StartMatch", function()
    playerSnaps[false], playerSnaps[true] = nil, nil
end)

function FX:SyncBoard()
    if not self:Enabled() then
        if self.wasEnabled then self:TurnOff() end
        return
    end
    self.wasEnabled = true
    local batch = {}
    for _, f in ipairs(B.myNonLandFrames) do SyncFrame(f, false, batch) end
    for _, f in ipairs(B.oppNonLandFrames) do SyncFrame(f, true, batch) end
    self:SyncPlayers()

    local lead = 0
    for _, b in ipairs(batch) do
        if b.strike then lead = FX.STRIKE_LEAD end
    end
    local swung = false
    for i, b in ipairs(batch) do
        local delay = (i - 1) * FX.STAGGER
        if b.strike then
            Later(delay, function()
                -- The attackers (either side's) swing with a sound, once however many there are
                if b.swing and not swung then
                    swung = true
                    if TTS.Sound and TTS.Sound:IsOn("combat") then pcall(PlaySound, FX.SWING_SOUND, "SFX") end
                end
                local f = frameOf[b.perm]
                if Valid(f, b.perm) then FX:OneShot(f, FX.STRIKE_ANIM) end
            end)
        end
        if #b.events > 0 then
            Later(delay + lead, function() PlayEvents(b.perm, b.events, b.color) end)
        end
    end
end

-- The option went off: every model back to plain
function FX:TurnOff()
    self.wasEnabled = false
    for _, group in ipairs({ B.myNonLandFrames, B.oppNonLandFrames }) do
        for _, f in ipairs(group) do
            local dirty = (not FX.ON_FRAME and f.fxKits and next(f.fxKits)) or f.fxPaused
                or (f.fxModelKits and next(f.fxModelKits)) or (f.fxBase and f.fxBase ~= ANIM.STAND)
            self:Release(f)
            f.fxLoaded, f.fxReloading = nil, nil
            if dirty then B.QueueModelReload(f) end
        end
    end
    for _, isRemote in ipairs({ false, true }) do
        local plate = Plate(isRemote)
        self:HideLayer(plate)
        plate.fxWant, plate.fxLoaded = nil, nil
        playerSnaps[isRemote] = nil
    end
    for p in pairs(snaps) do snaps[p] = nil end
    for p in pairs(causes) do causes[p] = nil end
end

function FX:OptionChanged()
    if self:Enabled() then
        if E.inMatch then E:RefreshUI() end
    else
        self:TurnOff()
    end
end

-- =========================================================================
-- /tragic fx [kit <id> | anim <id> | me <kit> | opp <kit> | sound <SoundKit id> | place <kit> <raise> [size] | layer | carrier <displayId> | cam <scale> | drop <share> | pad <share>]
-- (layer, carrier, cam, drop and pad last the session)
-- =========================================================================
local PROBE_METHODS = { "SetAnimation", "HasAnimation", "FreezeAnimation", "SetPaused",
    "PlayAnimKit", "StopAnimKit", "ApplySpellVisualKit" }

-- Every effect cleared, change() made, then every effect put back (with the FX layer
-- switched, or a new carrier or camera for it)
local function Redo(change)
    FX:TurnOff()
    change()
    if FX:Enabled() and E.inMatch then E:RefreshUI() end
end

local function Say(msg) DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD200[TTSE]|r " .. msg) end

-- The hovered battlefield denizen with a model, else the first one showing
local function TestFrame()
    local first
    for _, group in ipairs({ B.myNonLandFrames, B.oppNonLandFrames }) do
        for _, f in ipairs(group) do
            if f:IsShown() and f.model and f.model:IsShown() then
                if f.hovered then return f end
                first = first or f
            end
        end
    end
    return first
end

function FX:Command(args)
    args = args or ""
    if args:match("^layer") then
        Redo(function() FX.ON_FRAME = not FX.ON_FRAME end)
        Say(L(FX.ON_FRAME and "fx.layerOn" or "fx.layerOff"))
        return
    end
    local kit, raise, size = args:match("^place%s+(%d+)%s+(%-?[%d%.]+)%s*([%d%.]*)")
    if kit then
        kit = tonumber(kit)
        Redo(function()
            local place = FX.KIT_PLACE[kit] or {}
            place.raise, place.size = tonumber(raise) or place.raise, tonumber(size) or place.size
            FX.KIT_PLACE[kit] = place
        end)
        Say(L("fx.placeSet", kit, FX.KIT_PLACE[kit].raise or 0, FX.KIT_PLACE[kit].size or 1))
        return
    end
    local what, num = args:match("^(%a+)%s+([%d%.]+)")
    if what == "platedrop" then what = "plateDrop" elseif what == "platescale" then what = "plateScale" end
    if what == "carrier" or what == "cam" or what == "drop" or what == "pad" or what == "plateDrop" or what == "plateScale" then
        Redo(function()
            if what == "carrier" then
                FX.LAYER.displayId = tonumber(num:match("%d+"))
            elseif what == "cam" then
                FX.LAYER.camScale = tonumber(num) or FX.LAYER.camScale
            else
                FX.LAYER[what] = tonumber(num) or FX.LAYER[what]
            end
        end)
        Say(L("fx.layerSet", FX.LAYER.displayId, FX.LAYER.camScale, FX.LAYER.drop, FX.LAYER.pad, FX.LAYER.plateDrop, FX.LAYER.plateScale))
        return
    end
    local id = num and num:match("^%d+$")
    if id and (what == "me" or what == "opp") then
        local plate = Plate(what == "opp")
        plate.fxPerm = true
        if not (plate.fxLayer and plate.fxLayer:IsShown()) then self:LoadLayer(plate) end
        local ok = self:PlayKit(plate, tonumber(id))
        Say(L(ok and "fx.tried" or "fx.failed", "kit", tonumber(id), what))
        return
    end
    if id and what == "sound" then
        local ok = pcall(PlaySound, tonumber(id), "SFX")
        Say(L(ok and "fx.soundPlayed" or "fx.soundFailed", tonumber(id)))
        return
    end
    if id and (what == "kit" or what == "anim") then
        local f = TestFrame()
        if not f then Say(L("fx.noModel")); return end
        id = tonumber(id)
        local ok
        if what == "kit" and Raised(f, id) then
            -- On its own raised carrier for a few seconds, unless the denizen has it anyway
            self:ShowRaised(f, id, true)
            TTS:SafeAfter(4, function()
                if not (f.fxWant and f.fxWant[id]) then FX:ShowRaised(f, id, false) end
            end)
            ok = true
        elseif what == "kit" then
            -- A lasting kit that goes on the model (FX.LASTING's onModel) is tried there
            local onModel = false
            for _, l in ipairs(FX.LASTING) do
                if l.kit == id and l.onModel then onModel = true end
            end
            if FX.ON_FRAME and not onModel and not (f.fxLayer and f.fxLayer:IsShown()) then self:LoadLayer(f) end
            ok = self:Call(onModel and f.model or self:KitModel(f), "ApplySpellVisualKit", id, true)
        else
            ok = self:Call(f.model, "SetAnimation", id)
            if ok then TTS:SafeAfter(3, function() FX:Call(f.model, "SetAnimation", f.fxBase or ANIM.STAND) end) end
        end
        Say(L(ok and "fx.tried" or "fx.failed", what, id, TTS:CardName(f.currentCard) or "?"))
        return
    end
    Say(L(self:Enabled() and "fx.on" or "fx.off"))
    local f = TestFrame()
    local probe = f and f.model or CreateFrame("DressUpModel")
    local have = {}
    for _, m in ipairs(PROBE_METHODS) do
        have[#have + 1] = m .. (type(probe[m]) == "function" and " |cFF40FF40yes|r" or " |cFFFF4040no|r")
    end
    Say(table.concat(have, ", "))
    local names = {}
    for m in pairs(report) do names[#names + 1] = m end
    table.sort(names)
    for _, m in ipairs(names) do
        local r = report[m]
        Say(L("fx.calls", m, r.ok, r.failed, r.skipped) .. (r.missing and (" " .. L("fx.missing")) or "")
            .. (r.err and (" |cFFFF4040" .. r.err .. "|r") or ""))
    end
    if #names == 0 then Say(L("fx.noCalls")) end
end
