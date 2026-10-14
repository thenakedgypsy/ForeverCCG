--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

-- =========================================================================
-- TARGETING & HIT EFFECTS
--  * While a spell is choosing a target, an arrow runs from the card to the cursor.
--  * When the target is chosen, an arrow flashes from the card to it, with a sound.
--  * When a player takes damage, their life plate flashes red, the amount
--    floats up off it, and a hit sound plays. Unblocked attackers flash an
--    arrow to the player they hit.
-- Sounds respect the Sounds checkbox and the "Targeting & hit sounds" option.
-- Load after UI\Board.lua.
-- =========================================================================
local B = TTS.BoardFrame
if not B then return end

-- Any SOUNDKIT id works here
local SOUND_TARGET = 873    -- IG_CREATURE_AGGRO_SELECT (the "targeted an enemy" click)
local SOUND_HIT    = 8959   -- RAID_WARNING

local AIM_COLOR    = { 1.0, 0.82, 0.0, 0.85 }
local TARGET_COLOR = { 1.0, 0.82, 0.0, 1.0 }
local HIT_COLOR    = { 1.0, 0.15, 0.15, 1.0 }

local ARROW_THICKNESS = 4
local ARROW_HEAD_LEN  = 16
local ARROW_HEAD_ANG  = 0.45   -- radians either side of the shaft
local FLASH_TIME      = 0.7    -- seconds a resolved-target / hit arrow takes to fade
local HIT_ARROW_HOLD  = 0.4    -- seconds an attack arrow stays fully visible before it fades
local HIT_TIME        = 1.0    -- seconds the life-plate flash and damage number last
local HIT_RISE        = 36     -- pixels the damage number floats up

local layer = CreateFrame("Frame", nil, B)
layer:SetAllPoints(B)
layer:SetFrameLevel(B:GetFrameLevel() + 45)   -- above the block arrows
layer:EnableMouse(false)

local canDrawLines = layer.CreateLine ~= nil
local atan2 = math.atan2 or math.atan

local function PlayFX(soundId)
    if not (TTS.Sound and TTS.Sound:IsOn("combat")) then return end
    pcall(PlaySound, soundId, "SFX")
end

-- =========================================================================
-- ARROWS
-- =========================================================================
local function NewArrow()
    local a = {}
    for k = 1, 3 do   -- shaft, head left, head right
        local line = layer:CreateLine(nil, "OVERLAY")
        line:SetThickness(ARROW_THICKNESS)
        line:Hide()
        a[k] = line
    end
    return a
end

local function SetLine(line, x1, y1, x2, y2)
    line:SetStartPoint("BOTTOMLEFT", layer, x1, y1)
    line:SetEndPoint("BOTTOMLEFT", layer, x2, y2)
    line:Show()
end

local function DrawArrow(a, sx, sy, ex, ey, color)
    for _, line in ipairs(a) do
        line:SetColorTexture(color[1], color[2], color[3], color[4])
        line:SetAlpha(1)
    end
    SetLine(a[1], sx, sy, ex, ey)
    local ang = atan2(ey - sy, ex - sx)
    SetLine(a[2], ex, ey,
        ex - ARROW_HEAD_LEN * math.cos(ang - ARROW_HEAD_ANG),
        ey - ARROW_HEAD_LEN * math.sin(ang - ARROW_HEAD_ANG))
    SetLine(a[3], ex, ey,
        ex - ARROW_HEAD_LEN * math.cos(ang + ARROW_HEAD_ANG),
        ey - ARROW_HEAD_LEN * math.sin(ang + ARROW_HEAD_ANG))
end

local function HideArrow(a)
    for _, line in ipairs(a) do line:Hide() end
end

-- A frame's centre and height in the layer's coordinates (cards are scaled individually)
local function Pos(f)
    if not (f and f:IsShown()) then return end
    local cx, cy = f:GetCenter()
    local left, bottom = layer:GetLeft(), layer:GetBottom()
    if not (cx and left) then return end
    local r = f:GetEffectiveScale() / layer:GetEffectiveScale()
    return { x = cx * r - left, y = cy * r - bottom, h = f:GetHeight() * r }
end

-- From the source's edge facing the target to the target's facing edge
local function EdgeToEdge(s, t)
    local dir = (t.y > s.y) and 1 or -1
    return s.x, s.y + dir * s.h / 2, t.x, t.y - dir * t.h / 2
end

local function FindFieldFrame(isRemote, fieldIndex)
    for _, child in ipairs({ B:GetChildren() }) do
        if child.fieldIndex == fieldIndex and child.isRemote == isRemote and child:IsShown() then
            return child
        end
    end
end

local flashes, freeArrows = {}, {}

-- hold (optional): seconds the arrow stays fully visible before it fades
local function FlashArrow(s, t, color, hold)
    if not (canDrawLines and s and t) then return end
    local a = table.remove(freeArrows) or NewArrow()
    local sx, sy, ex, ey = EdgeToEdge(s, t)
    DrawArrow(a, sx, sy, ex, ey, color)
    table.insert(flashes, { arrow = a, t = 0, hold = hold or 0 })
end

-- =========================================================================
-- SPELL REVEAL
-- A cast spell (either player's) is shown face up over the battlefield for a moment,
-- on the caster's side, with an arrow to everything it affects.
-- =========================================================================
local REVEAL_HOLD = 1.0    -- seconds the card stays fully visible
local REVEAL_SCALE = 0.75  -- size of the shown card relative to the full preview card
local REVEAL_FADE = 0.25   -- then fades out over this long
local REVEAL_Y = { [true] = 150, [false] = -40 }   -- card centre above the board's centre, by caster

local reveal
local function RevealFrame()
    if reveal then return reveal end
    if not (TTS.CreateCardFrame and TTS.PREVIEW_W) then return end
    reveal = TTS.CreateCardFrame(layer, TTS.PREVIEW_W, TTS.PREVIEW_H)
    reveal:SetFrameLevel(layer:GetFrameLevel() + 5)
    reveal:EnableMouse(false)
    reveal:SetScript("OnEnter", nil)
    reveal:SetScript("OnLeave", nil)
    reveal:SetScript("OnClick", nil)
    reveal:Hide()
    return reveal
end

-- The frame a target descriptor ({ kind, isRemote, perm }) is drawn on, right now
local function TargetFrame(d)
    if d.kind == "PLAYER" then return d.isRemote and B.oppLifeBtn or B.myLifeBtn end
    local E = TTS.Engine
    local isRemote, idx = E:FindPerm(d.perm)
    if idx then return FindFieldFrame(isRemote and true or false, idx) end
end

-- Arrow colour by what an effect does to a target: damage beats healing beats anything else
local EFFECT_COLORS = {
    damage = { 1.0, 0.15, 0.15, 1.0 },
    heal   = { 0.2, 1.0, 0.2, 1.0 },
    other  = { 1.0, 0.82, 0.0, 1.0 },
}
local OP_KIND = { damage = "damage", dot = "damage", destroy = "damage", heal = "heal", hot = "heal" }
local KIND_RANK = { damage = 3, heal = 2, other = 1 }

-- Everything an effect will touch, with the arrow colour for each: { { pos, color }, ... }
-- (positions are taken before it resolves: creatures may die)
local function EffectTargets(eff, tgt, casterIsRemote)
    local E = TTS.Engine
    local list, byFrame = {}, {}
    local function Add(d, op)
        local f = d and TargetFrame(d)
        if not f then return end
        local kind = OP_KIND[op and op.op] or "other"
        local entry = byFrame[f]
        if not entry then
            local p = Pos(f)
            if not p then return end
            entry = { pos = p, kind = kind }
            byFrame[f] = entry
            table.insert(list, entry)
        elseif KIND_RANK[kind] > KIND_RANK[entry.kind] then
            entry.kind = kind
        end
    end
    local targetedOps = 0
    for _, op in ipairs(eff and eff.ops or {}) do
        if op.to == "target" then
            if tgt then Add(tgt, op) end
            targetedOps = targetedOps + 1
        elseif op.to then
            for _, d in ipairs(E:CollectSpellTargets(op.to, nil, casterIsRemote, op.filter)) do Add(d, op) end
        end
    end
    -- A target with no op naming it (e.g. an ability without effect data) still gets an arrow
    if tgt and targetedOps == 0 then Add(tgt, nil) end
    for _, entry in ipairs(list) do entry.color = EFFECT_COLORS[entry.kind] end
    return list
end

-- Shows a cast card (and arrows to its targets' positions) on the caster's side
local function RevealSpell(card, casterIsRemote, targets)
    local f = RevealFrame()
    if not (f and card and TTS.PaintPreviewCard) then return end
    f:ClearAllPoints()
    -- Scaled as a whole so the printed rules keep their layout; offsets are in the card's scale
    f:SetScale(REVEAL_SCALE)
    f:SetPoint("CENTER", B, "CENTER", 0, REVEAL_Y[casterIsRemote and true or false] / REVEAL_SCALE)
    TTS.PaintPreviewCard(f, card)
    f:SetAlpha(1)
    f.t = 0
    local src = Pos(f)
    for _, t in ipairs(targets or {}) do
        FlashArrow(src, t.pos, t.color, REVEAL_HOLD)
    end
end

local function UpdateReveal(dt)
    if not (reveal and reveal.t) then return end
    reveal.t = reveal.t + dt
    if reveal.t >= REVEAL_HOLD + REVEAL_FADE then
        reveal.t = nil
        reveal:Hide()
    elseif reveal.t > REVEAL_HOLD then
        reveal:SetAlpha(1 - (reveal.t - REVEAL_HOLD) / REVEAL_FADE)
    end
end

-- A card the opponent cast in PvP. tgt is the target their client sent (nil for an
-- untargeted spell, whose area targets are worked out here from the card).
function TTS.Engine:ShowRemoteSpell(cardId, tgt)
    local card = TTS.Cards[cardId]
    if not card then return end
    local targets = EffectTargets(card.effect, tgt, true)
    RevealSpell(card, true, targets)
    if #targets > 0 then PlayFX(SOUND_TARGET) end
end

-- The card a pending spell is being cast from
local function AimSourceFrame(targeting)
    if targeting and targeting.handIndex and B.myHandFrames then
        return B.myHandFrames[targeting.handIndex]
    end
end

-- While choosing what to block: the selected blocker (ours, while we defend)
local BLOCK_AIM_COLOR = { 0.25, 0.55, 1.0, 0.85 }   -- the block arrows' blue
local function BlockAimSourceFrame(E)
    local bs = E.blockingState
    if E.phase == "COMBAT_BLOCK" and bs and bs.isRemoteAttacking and not bs.blocksDeclared and bs.selectedBlocker then
        return FindFieldFrame(false, bs.selectedBlocker)
    end
end

local aimArrow
local function UpdateAim()
    if not canDrawLines then return end
    local E = TTS.Engine
    local color = AIM_COLOR
    local src = E and E.inMatch and Pos(AimSourceFrame(E.targeting))
    if E and E.inMatch and not src and not E.targeting then
        src = Pos(BlockAimSourceFrame(E))
        color = BLOCK_AIM_COLOR
    end
    if not src then
        if aimArrow then HideArrow(aimArrow) end
        return
    end

    local scale = layer:GetEffectiveScale()
    local cx, cy = GetCursorPosition()
    cx, cy = cx / scale - layer:GetLeft(), cy / scale - layer:GetBottom()

    local dir = (cy > src.y) and 1 or -1
    local sx, sy = src.x, src.y + dir * src.h / 2
    if (cx - sx) ^ 2 + (cy - sy) ^ 2 < 20 * 20 then
        if aimArrow then HideArrow(aimArrow) end
        return
    end
    aimArrow = aimArrow or NewArrow()
    DrawArrow(aimArrow, sx, sy, cx, cy, color)
end

-- =========================================================================
-- HITS ON PLAYERS
-- =========================================================================
local function NewHitFX(plate)
    local h = { plate = plate }
    h.glow = plate:CreateTexture(nil, "ARTWORK")
    h.glow:SetPoint("TOPLEFT", plate, "TOPLEFT", 3, -3)
    h.glow:SetPoint("BOTTOMRIGHT", plate, "BOTTOMRIGHT", -3, 3)
    h.glow:SetColorTexture(1, 0.1, 0.1, 1)
    h.glow:SetAlpha(0)

    h.num = layer:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    h.num:SetTextColor(1, 0.2, 0.2)
    h.num:SetShadowOffset(2, -2)
    h.num:SetShadowColor(0, 0, 0, 1)
    h.num:Hide()
    return h
end

local hits = {
    [true]  = NewHitFX(B.oppLifeBtn),
    [false] = NewHitFX(B.myLifeBtn),
}
local hitShown = false   -- set when a hit plays, so combat doesn't play a second one

local function ShowHit(isRemote, amount)
    local h = hits[isRemote and true or false]
    hitShown = true
    -- Several hits landing together (e.g. multiple attackers) add up into one number and one sound
    if h.t and h.t < 0.25 then
        h.amount = h.amount + amount
    else
        h.amount = amount
        PlayFX(SOUND_HIT)
    end
    h.t = 0
    h.num:SetText("-" .. h.amount)
    h.num:Show()
end

local function UpdateHit(h, dt)
    if not h.t then return end
    h.t = h.t + dt
    local p = h.t / HIT_TIME
    if p >= 1 then
        h.t = nil
        h.glow:SetAlpha(0)
        h.num:Hide()
        return
    end
    h.glow:SetAlpha(0.6 * (1 - p))
    h.num:ClearAllPoints()
    h.num:SetPoint("CENTER", h.plate, "CENTER", 0, HIT_RISE * p)
    h.num:SetAlpha(1 - p * p)
end

-- =========================================================================
-- FLOATING TEXT
-- Numbers and messages that rise and fade like the damage numbers on the life plates:
-- damage and healing on creatures and players, and "Invalid target" at the cursor.
-- =========================================================================
local FLOAT_TIME, FLOAT_RISE, FLOAT_STACK = 1.0, 36, 14
TTS.FLOAT_DAMAGE = { 1, 0.2, 0.2 }
TTS.FLOAT_HEAL   = { 0.2, 1, 0.2 }
TTS.FLOAT_WARN   = { 1, 0.25, 0.25 }

local floats, freeFloats = {}, {}

-- text at a frame's centre (frame nil = at the cursor); big = the life plates' size
function TTS.FloatText(text, color, frame, big)
    local x, y
    if frame then
        local p = Pos(frame)
        if not p then return end
        x, y = p.x, p.y
    else
        local scale = layer:GetEffectiveScale()
        local cx, cy = GetCursorPosition()
        local left, bottom = layer:GetLeft(), layer:GetBottom()
        if not (cx and left) then return end
        x, y = cx / scale - left, cy / scale - bottom + 12
    end
    -- Several at once on the same spot stack upwards instead of overlapping
    local stack = 0
    for _, fl in ipairs(floats) do
        if fl.frame == frame and fl.t < 0.3 then stack = stack + 1 end
    end
    local fs = table.remove(freeFloats) or layer:CreateFontString(nil, "OVERLAY")
    fs:SetFontObject(big and "GameFontNormalHuge" or "GameFontNormalLarge")
    fs:SetShadowOffset(2, -2)
    fs:SetShadowColor(0, 0, 0, 1)
    fs:SetTextColor(color[1], color[2], color[3])
    fs:SetText(text)
    fs:SetAlpha(1)
    fs:Show()
    table.insert(floats, { fs = fs, frame = frame, x = x, y = y + stack * FLOAT_STACK, t = 0 })
end

local function UpdateFloats(dt)
    for i = #floats, 1, -1 do
        local fl = floats[i]
        fl.t = fl.t + dt
        local p = fl.t / FLOAT_TIME
        if p >= 1 then
            fl.fs:Hide()
            table.insert(freeFloats, fl.fs)
            table.remove(floats, i)
        else
            fl.fs:ClearAllPoints()
            fl.fs:SetPoint("CENTER", layer, "BOTTOMLEFT", fl.x, fl.y + FLOAT_RISE * p)
            fl.fs:SetAlpha(1 - p * p)
        end
    end
end

layer:SetScript("OnUpdate", function(_, dt)
    UpdateAim()
    UpdateFloats(dt)
    UpdateReveal(dt)
    for i = #flashes, 1, -1 do
        local fl = flashes[i]
        fl.t = fl.t + dt
        local alpha = math.min(1, 1 - (fl.t - (fl.hold or 0)) / FLASH_TIME)
        if alpha <= 0 then
            HideArrow(fl.arrow)
            table.insert(freeArrows, fl.arrow)
            table.remove(flashes, i)
        else
            for _, line in ipairs(fl.arrow) do line:SetAlpha(alpha) end
        end
    end
    UpdateHit(hits[true], dt)
    UpdateHit(hits[false], dt)
end)

-- =========================================================================
-- ENGINE HOOKS (installed at login, once every file has loaded)
-- Positions are read before the engine runs, since resolving moves cards around.
-- =========================================================================
local function InstallHooks()
    local E = TTS.Engine
    if not E then return end

    -- Errors from the player's own actions also float at the cursor in red: only while one of
    -- the board's click handlers is running, so the AI's fizzles never appear under the mouse.
    local userDepth, quietDepth = 0, 0
    local function Counted(fn, isQuiet)
        return function(self, ...)
            userDepth = userDepth + 1
            if isQuiet then quietDepth = quietDepth + 1 end
            local results = { pcall(fn, self, ...) }
            userDepth = userDepth - 1
            if isQuiet then quietDepth = quietDepth - 1 end
            if not results[1] then error(results[2], 0) end
            return unpack(results, 2)
        end
    end
    for _, name in ipairs({ "PlayCard", "TapCard", "ClickOpponentCard", "NextPhase", "EndTurn" }) do
        if E[name] then E[name] = Counted(E[name]) end
    end

    -- First sentence of a log line, without colour codes or the right-click hint
    local function ShortMessage(msg)
        local s = tostring(msg or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
        s = s:gsub("%s*%(Right%-click to cancel%)", "")
        local cut = s:find("[%.!]%s")
        if cut then s = s:sub(1, cut) end
        return TTS.FormatSymbols and TTS:FormatSymbols(s, 16) or s
    end

    if E.Log then
        local origLog = E.Log
        E.Log = function(self, msg, category, ...)
            if category == "ERROR" and userDepth > 0 and quietDepth == 0 and self.inMatch then
                TTS.FloatText(ShortMessage(msg), TTS.FLOAT_WARN, nil)
            end
            return origLog(self, msg, category, ...)
        end
    end

    if E.ResolveTarget then
        -- Its own refusals float "Invalid target" below, so its log lines stay quiet
        local origResolve = Counted(E.ResolveTarget, true)
        E.ResolveTarget = function(self, targetType, isRemote, fieldIndex, ...)
            local targeting = self.targeting
            local results = { origResolve(self, targetType, isRemote, fieldIndex, ...) }
            -- Targeting cleared or replaced: the target was accepted (the spell reveal or
            -- the ability arrow below draws the arrow). Still targeting: it was refused.
            if targeting and self.targeting ~= targeting then
                PlayFX(SOUND_TARGET)
            elseif targeting and self.targeting == targeting then
                TTS.FloatText("Invalid target", TTS.FLOAT_WARN, nil)
            end
            return unpack(results)
        end
    end

    -- Every spell, from either side: the card shows for a moment with arrows to its targets
    if E.ResolveSpell then
        local origSpell = E.ResolveSpell
        E.ResolveSpell = function(self, card, tgt, casterIsRemote, ...)
            local targets = EffectTargets(card and card.effect, tgt, casterIsRemote)
            RevealSpell(card, casterIsRemote, targets)
            if casterIsRemote and #targets > 0 then PlayFX(SOUND_TARGET) end
            return origSpell(self, card, tgt, casterIsRemote, ...)
        end
    end

    -- Activated abilities: an arrow from the creature to what it hits
    if E.ActivateAbility then
        -- What each ability does, in spell-effect shape, for its arrows and their colours
        local ABILITY_EFFECTS = {
            BOSS01 = { ops = { { op = "damage", to = "target" } } },
            BOSS04 = { ops = { { op = "tuck", to = "target" } } },
            BOSS07 = { ops = { { op = "damage", to = "enemy_creatures" } } },
            BOSS08 = { ops = { { op = "freeze", to = "target" } } },
            BOSS10 = { ops = { { op = "damage", to = "enemy_creatures" } } },
        }
        local origAbility = E.ActivateAbility
        E.ActivateAbility = function(self, perm, isRemote, tgt, ...)
            local srcRemote, srcIdx = self:FindPerm(perm)
            local src = srcIdx and Pos(FindFieldFrame(srcRemote and true or false, srcIdx))
            local targets = EffectTargets(ABILITY_EFFECTS[perm.id], tgt, isRemote)
            local ok = origAbility(self, perm, isRemote, tgt, ...)
            if ok then
                for _, t in ipairs(targets) do FlashArrow(src, t.pos, t.color, REVEAL_HOLD) end
                if isRemote and #targets > 0 then PlayFX(SOUND_TARGET) end
            end
            return ok
        end
    end

    if E.DamagePlayer then
        local origDamage = E.DamagePlayer
        E.DamagePlayer = function(self, isRemote, amount, reason, ...)
            local state = isRemote and self.remoteState or self.localState
            local before = state.life
            local results = { origDamage(self, isRemote, amount, reason, ...) }
            if state.life < before then ShowHit(isRemote, before - state.life) end
            return unpack(results)
        end
    end

    if E.ResolveCombatDamage then
        local origCombat = E.ResolveCombatDamage
        E.ResolveCombatDamage = function(self, ...)
            local bs = self.blockingState
            local arrows, state, before, defRemote = {}, nil, nil, nil
            if bs then
                local atkRemote = bs.isRemoteAttacking and true or false
                defRemote = not atkRemote
                state = defRemote and self.remoteState or self.localState
                before = state.life

                local blocked = {}
                for _, atkIdx in pairs(bs.blocks or {}) do blocked[atkIdx] = true end
                local dst = Pos(defRemote and B.oppLifeBtn or B.myLifeBtn)
                for _, atkIdx in ipairs(bs.attackers or {}) do
                    if not blocked[atkIdx] then
                        local src = Pos(FindFieldFrame(atkRemote, atkIdx))
                        if src and dst then table.insert(arrows, { src, dst }) end
                    end
                end
            end

            hitShown = false
            local results = { origCombat(self, ...) }
            if state and state.life < before then
                for _, pair in ipairs(arrows) do FlashArrow(pair[1], pair[2], HIT_COLOR, HIT_ARROW_HOLD) end
                -- Combat that changes life without going through DamagePlayer still gets a hit
                if not hitShown then ShowHit(defRemote, before - state.life) end
            end
            return unpack(results)
        end
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    self:UnregisterAllEvents()
    InstallHooks()
end)