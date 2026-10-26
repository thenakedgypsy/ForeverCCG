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

-- Looping kits shown while a state lasts (Snapshot's fields)
FX.LASTING = {
    { state = "shielded", kit = 847 },    -- Power Word: Shield (or Divine Shield, 252)
    { state = "soul",     kit = 3769 },   -- Power Infusion: a stand-in for Soulstone (or Banish, 1286)
    { state = "frozen",   kit = 285 },    -- Frost Nova's root
    { state = "dots",     kit = 535 },    -- Corruption
    { state = "hots",     kit = 436 },    -- Renew
    { state = "borrowed", kit = 325 },    -- Mind Control
}

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
FX.EVENTS = {
    died      = { anim = ANIM.DEATH, hold = ANIM.DEAD },
    returned  = { kit = 3394 },                          -- Blink
    soulSave  = { anim = ANIM.CRIT, kit = 4212 },        -- Soulstone Resurrection
    crit      = { anim = ANIM.CRIT },                    -- half its toughness or more (+ FX.IMPACT)
    hit       = { anim = ANIM.WOUND },                   -- (+ FX.IMPACT)
    shieldPop = { anim = ANIM.SHIELD_BLOCK },
    freeze    = { anim = ANIM.STUN, time = 0.3 },        -- then the model pauses
    weaken    = { kit = 719 },                           -- Curse of Weakness
    buff      = { anim = ANIM.ROAR, kit = 456 },         -- Blessing of Might
    empower   = { anim = ANIM.ROAR, kit = 388 },         -- Battle Shout (a keyword gained)
    heal      = { kit = 232 },                           -- Heal
    dispel    = { kit = 226 },                           -- Dispel Magic
    cast      = { anim = ANIM.CAST },                    -- an activated ability
}
FX.EVENT_ORDER = { "died", "returned", "soulSave", "crit", "hit", "shieldPop", "freeze",
    "weaken", "buff", "empower", "heal", "dispel", "cast" }
FX.STRIKE_ANIM = ANIM.ATTACK   -- combat: plays first, the rest of that redraw's effects after STRIKE_LEAD

FX.STAGGER = 0.08          -- seconds between denizens whose effects start in the same redraw
FX.STRIKE_LEAD = 0.35      -- a combat swing lands before the wounds it deals
FX.ONESHOT_TIME = 1.2      -- back to standing after a one-shot animation, if OnAnimFinished never comes
FX.LOAD_WAIT = 0.5         -- lasting kits go on when the model has loaded, or after this long
FX.FRONT_TIME = 1.2        -- a one-shot effect brings the model in front of the card frame and tap symbol this long

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
        frozen = perm.freezeUntap and true or false,
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

do
    local origApply = E.ApplySpellOp
    E.ApplySpellOp = function(self, op, tgt, card, casterIsRemote, ...)
        if not FX:Enabled() then return origApply(self, op, tgt, card, casterIsRemote, ...) end
        local was = castColor
        castColor = card and type(card.color) == "string" and card.color:sub(1, 1) or nil
        local before = op and op.op == "dispel" and DispelMarks(self)
        local results = { origApply(self, op, tgt, card, casterIsRemote, ...) }
        castColor = was
        if before then
            for p, mark in pairs(DispelMarks(self)) do
                if before[p] and before[p] ~= mark then Cause(p).dispelled = true end
            end
        end
        return unpack(results)
    end

    local origDamage = E.DamageCreature
    E.DamageCreature = function(self, perm, n, ...)
        local dealt = origDamage(self, perm, n, ...)
        if castColor and perm and (dealt or 0) > 0 then Cause(perm).color = castColor end
        return dealt
    end

    -- Everyone in the fight swings
    local origCombat = E.ResolveCombatDamage
    E.ResolveCombatDamage = function(self, ...)
        local bs = self.blockingState
        if bs and FX:Enabled() then
            local atkField = (bs.isRemoteAttacking and self.remoteState or self.localState).field
            local blkField = (bs.isRemoteAttacking and self.localState or self.remoteState).field
            for _, i in ipairs(bs.attackers or {}) do
                if atkField[i] then Cause(atkField[i]).strike = true end
            end
            for _, pair in ipairs(self:BlockPairs(bs)) do
                if blkField[pair[1]] then Cause(blkField[pair[1]]).strike = true end
            end
        end
        return origCombat(self, ...)
    end

    local origAbility = E.ActivateAbility
    E.ActivateAbility = function(self, perm, ...)
        local ok = origAbility(self, perm, ...)
        if ok and perm and FX:Enabled() then Cause(perm).cast = true end
        return ok
    end

    -- "Until end of turn" wearing off, and damage wiped, are not weakening or healing
    local origCleanup = E.EndTurnCleanup
    E.EndTurnCleanup = function(self, ...)
        local results = { origCleanup(self, ...) }
        Resnap(self)
        return unpack(results)
    end
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

-- Puts the wanted lasting kits on the model, and pauses or wakes it for Frozen
function FX:ApplyLasting(f)
    if f.fxReloading or f.fxLoaded == false then return end
    local want, have = f.fxWant or {}, f.fxKits or {}
    for kit in pairs(have) do
        if not want[kit] then
            f.fxReloading = true
            B.QueueModelReload(f)
            return
        end
    end
    for kit in pairs(want) do
        if not have[kit] and self:Call(f.model, "ApplySpellVisualKit", kit, false) then have[kit] = true end
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
-- animations are gone with the old model; lasting kits go back on once it has loaded.
function FX:ModelReset(f)
    local m = f.model
    if not m then return end
    if not m.fxHooked then
        m.fxHooked = true
        if m.HasScript and m:HasScript("OnModelLoaded") then
            m:HookScript("OnModelLoaded", function()
                if f.fxLoaded == false then
                    f.fxLoaded = true
                    if f.fxPerm and FX:Enabled() then FX:ApplyLasting(f) end
                end
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
    self:Behind(f)
    if f.fxBase ~= ANIM.DEAD then f.fxBase = nil end
    if not self:Enabled() then return end
    f.fxLoaded = false
    local token = {}
    f.fxLoadToken = token
    TTS:SafeAfter(FX.LOAD_WAIT, function()
        if f.fxLoadToken == token and f.fxLoaded == false then
            f.fxLoaded = true
            if f.fxPerm then FX:ApplyLasting(f) end
        end
    end)
end

-- The frame no longer shows a denizen with effects
function FX:Release(f)
    f.fxPerm, f.fxWant, f.fxWantPause, f.fxDying = nil, nil, nil, nil
    if f.fxPaused then self:Call(f.model, "SetPaused", false); f.fxPaused = false end
    if f.fxBase and f.fxBase ~= ANIM.STAND then self:Call(f.model, "SetAnimation", ANIM.STAND) end
    f.fxBase, f.fxOneShot = nil, nil
    self:Behind(f)
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
    frameOf[perm] = f
    if f.leavingKind then
        if not seenLeaving[perm] then
            seenLeaving[perm] = true
            batch[#batch + 1] = { perm = perm, events = { f.leavingKind } }
        end
        return
    end
    local cur = FX:Snapshot(E, perm, isRemote)
    local cause = causes[perm]
    causes[perm] = nil
    local events = FX.Diff(snaps[perm], cur, cause)
    snaps[perm] = cur

    f.fxWant = {}
    for _, l in ipairs(FX.LASTING) do
        if cur[l.state] then f.fxWant[l.kit] = true end
    end
    f.fxWantPause = cur.frozen
    FX:ApplyLasting(f)

    if #events > 0 or (cause and cause.strike) then
        batch[#batch + 1] = { perm = perm, events = events, strike = cause and cause.strike, color = cause and cause.color }
    end
end

-- Plays one denizen's events on whichever frame shows it by then
local function PlayEvents(perm, events, color)
    local f = frameOf[perm]
    if not Valid(f, perm) then return end
    for _, name in ipairs(events) do
        local def = FX.EVENTS[name]
        local kit = def.kit or ((name == "hit" or name == "crit") and color and FX.IMPACT[color])
        if kit and FX:Call(f.model, "ApplySpellVisualKit", kit, true) then FX:InFront(f) end
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

function FX:SyncBoard()
    if not self:Enabled() then
        if self.wasEnabled then self:TurnOff() end
        return
    end
    self.wasEnabled = true
    local batch = {}
    for _, f in ipairs(B.myNonLandFrames) do SyncFrame(f, false, batch) end
    for _, f in ipairs(B.oppNonLandFrames) do SyncFrame(f, true, batch) end

    local lead = 0
    for _, b in ipairs(batch) do
        if b.strike then lead = FX.STRIKE_LEAD end
    end
    for i, b in ipairs(batch) do
        local delay = (i - 1) * FX.STAGGER
        if b.strike then
            Later(delay, function()
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
            local dirty = (f.fxKits and next(f.fxKits)) or f.fxPaused or (f.fxBase and f.fxBase ~= ANIM.STAND)
            self:Release(f)
            f.fxLoaded, f.fxReloading = nil, nil
            if dirty then B.QueueModelReload(f) end
        end
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
-- /tragic fx [kit <id> | anim <id>]
-- =========================================================================
local PROBE_METHODS = { "SetAnimation", "HasAnimation", "FreezeAnimation", "SetPaused",
    "PlayAnimKit", "StopAnimKit", "ApplySpellVisualKit" }

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
    local what, id = (args or ""):match("^(%a+)%s+(%d+)")
    if what == "kit" or what == "anim" then
        local f = TestFrame()
        if not f then Say(L("fx.noModel")); return end
        id = tonumber(id)
        local ok
        if what == "kit" then
            ok = self:Call(f.model, "ApplySpellVisualKit", id, true)
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
