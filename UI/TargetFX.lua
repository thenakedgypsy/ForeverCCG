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
--    arrow to the player they hit: blue, with the hit sound, when the player's
--    damage shield soaks all of it.
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
local SOAK_COLOR   = { 0.25, 0.55, 1.0, 1.0 }   -- an attack the player's damage shield soaked up

local ARROW_THICKNESS = 4
local ARROW_HEAD_LEN  = 16
local ARROW_HEAD_ANG  = 0.45   -- radians either side of the shaft
local FLASH_TIME      = 0.7    -- seconds a resolved-target / hit arrow takes to fade
local HIT_ARROW_HOLD  = 0.4    -- seconds an attack arrow stays fully visible before it fades
local HIT_TRAVEL      = 0.5    -- seconds a damage number takes to fly from its source to what it hits
local HIT_TIME        = 0.9    -- seconds the merged number (and a life plate's flash) last once landed
local HIT_JOIN        = 0.25   -- seconds after a hit starts that more damage still joins it
local PLAYER_HIT_SIZES   = { 40, 96, 64 }   -- font size in flight, as it lands, settled
local CREATURE_HIT_SIZES = { 24, 56, 36 }
local HIT_TRAVEL_COLOR = { 1.0, 0.85, 0.3 }   -- in flight, when no card is known to be dealing it
local HIT_FIRE_COLOR   = { 1.0, 0.55, 0.1 }   -- in flight from a red (Fire) card
local HIT_AFTER_BLOCKS = 0.2   -- seconds after combat's blocks land that the damage getting through sets off
local HIT_SOURCE_LINGER = 3    -- seconds a source still applies to damage arriving later (PvP, redraws)

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
local REVEAL_Y = { [true] = 170, [false] = -20 }   -- card centre above the board's centre, by caster
local REVEAL_GAP = 10      -- shown in the middle; over a card it moves right until clear of it by this much

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

-- A frame's rectangle on screen (left, right, bottom, top), or nil when it isn't laid out
local function ScreenRect(fr)
    local l, r, b, t = fr:GetLeft(), fr:GetRight(), fr:GetBottom(), fr:GetTop()
    if not (l and r and b and t) then return end
    local s = fr:GetEffectiveScale()
    return l * s, r * s, b * s, t * s
end

-- The card the reveal's rectangle overlaps that reaches furthest right (its right edge on
-- screen), or nil when it is clear of every card on the board
local function OverlappedRight(f)
    local l, r, b, t = ScreenRect(f)
    if not l then return end
    local right
    for _, group in ipairs({ B.myHandFrames, B.oppHandFrames, B.myLandFrames, B.myNonLandFrames,
        B.oppLandFrames, B.oppNonLandFrames }) do
        for _, c in ipairs(group or {}) do
            if c:IsVisible() then
                local cl, cr, cb, ct = ScreenRect(c)
                if cl and cl < r and cr > l and cb < t and ct > b and (not right or cr > right) then right = cr end
            end
        end
    end
    return right
end

-- Shows a cast card (and arrows to its targets' positions) on the caster's side
local function RevealSpell(card, casterIsRemote, targets)
    local f = RevealFrame()
    if not (f and card and TTS.PaintPreviewCard) then return end
    -- Scaled as a whole so the printed rules keep their layout; offsets are in the card's scale
    f:SetScale(REVEAL_SCALE)
    local y = REVEAL_Y[casterIsRemote and true or false] / REVEAL_SCALE
    -- In the middle, then moved right past any card it would cover (never off the board)
    local x, maxX = 0, (B:GetWidth() / 2 - REVEAL_GAP) / REVEAL_SCALE - f:GetWidth() / 2
    for _ = 1, 20 do
        f:ClearAllPoints()
        f:SetPoint("CENTER", B, "CENTER", x, y)
        local right = OverlappedRight(f)
        if not right or x >= maxX then break end
        local left = ScreenRect(f)
        x = math.min(maxX, x + (right - left) / f:GetEffectiveScale() + REVEAL_GAP / REVEAL_SCALE)
    end
    TTS.PaintPreviewCard(f, card, TTS.Engine:IsFoil(card.id, casterIsRemote and true or false))
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
    -- A card being dragged at something (UI\CardDrag.lua) aims from itself
    local drag = E and E.inMatch and B.dragAim
    local src = drag and Pos(drag.frame)
    if src then
        color = drag.color or AIM_COLOR
    else
        src = E and E.inMatch and Pos(AimSourceFrame(E.targeting))
    end
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
-- DAMAGE NUMBERS
-- Damage flies from each card dealing it (its spell reveal, or the creature) to whatever it
-- hits, as the amount in the card's colour. Numbers arriving together merge on landing into
-- one red "-N" that pops up big with a white flash (on a player, with the life plate's red
-- flash and the hit sound). A player's damage from no known source flies from the board's
-- centre; a creature's pops up where it lands.
-- =========================================================================
local freeStrings = {}
local function NewString()
    local fs = table.remove(freeStrings) or layer:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    fs.fontPath = fs.fontPath or fs:GetFont()
    fs:SetShadowOffset(2, -2)
    fs:SetShadowColor(0, 0, 0, 1)
    fs:SetTextColor(1, 1, 1)
    fs:SetAlpha(0)
    fs:Show()
    return fs
end

local function FreeString(fs)
    fs:Hide()
    table.insert(freeStrings, fs)
end

local function SetFontSize(fs, size)
    size = math.floor(size + 0.5)
    if fs.fontPath and fs.fontSize ~= size then
        fs.fontSize = size
        fs:SetFont(fs.fontPath, size, "THICKOUTLINE")
    end
end

local function CardColor(card)
    local c = card and TTS.CardColors and TTS.CardColors(card)[1]
    -- Fire's red would read as the landed "-N": its numbers fly in orange
    if c and TTS.SPHERE_RGB and c == TTS.SPHERE_RGB.R then return HIT_FIRE_COLOR end
    return c
end

local function Centroid(points)
    local x, y, n = 0, 0, 0
    for _, p in ipairs(points) do x, y, n = x + p.x, y + p.y, n + 1 end
    if n > 0 then return { x = x / n, y = y / n } end
end

-- Hits on their way or landed, by what they hit (true / false = a player, else the creature's perm):
-- { posFn, sizes, glow, sound, shards = { { fs, src } }, amount, t, landed, num }
local activeHits = {}

local function FinishHit(key, hit)
    for _, s in ipairs(hit.shards) do FreeString(s.fs) end
    if hit.num then FreeString(hit.num) end
    if hit.glow then hit.glow:SetAlpha(0) end
    activeHits[key] = nil
end

-- Adds damage to the hit on key, starting a new one unless one has only just set off.
-- src = where this part flies from (nil = none: the hit lands at once); label = the number
-- it shows in flight (default amount); delay = seconds a new hit waits before it sets off.
local function AddHitDamage(key, posFn, sizes, amount, src, color, label, delay)
    local hit = activeHits[key]
    if not (hit and not hit.landed and hit.t < HIT_JOIN) then
        if hit then FinishHit(key, hit) end
        hit = { posFn = posFn, sizes = sizes, shards = {}, amount = 0,
            t = src and -(delay or 0) or HIT_TRAVEL }
        hit.last = posFn()
        activeHits[key] = hit
    end
    hit.amount = hit.amount + amount
    if src then
        local fs = NewString()
        SetFontSize(fs, sizes[1])
        color = color or HIT_TRAVEL_COLOR
        fs:SetTextColor(color[1], color[2], color[3])
        fs:SetText(label or amount)
        table.insert(hit.shards, { fs = fs, src = src })
    end
    return hit
end

local function UpdateHitFX(key, hit, dt)
    hit.t = hit.t + dt
    local dest = hit.posFn()
    if dest then hit.last = dest else dest = hit.last end
    if not dest or hit.t >= HIT_TRAVEL + HIT_TIME then
        FinishHit(key, hit)
        return
    end

    -- In flight: each part from its own source (hidden at it while the hit waits)
    if hit.t < HIT_TRAVEL then
        local p = math.max(0, hit.t) / HIT_TRAVEL
        local m = p * p * (3 - 2 * p)
        for _, s in ipairs(hit.shards) do
            s.fs:ClearAllPoints()
            s.fs:SetPoint("CENTER", layer, "BOTTOMLEFT",
                s.src.x + (dest.x - s.src.x) * m, s.src.y + (dest.y - s.src.y) * m)
            s.fs:SetAlpha(math.min(1, p * 8))
        end
        return
    end

    -- Landed: the parts merge into one "-N"
    if not hit.landed then
        hit.landed = true
        for _, s in ipairs(hit.shards) do FreeString(s.fs) end
        wipe(hit.shards)
        hit.num = NewString()
        hit.num:SetText("-" .. hit.amount)
        if hit.sound then PlayFX(SOUND_HIT) end
    end
    local q = (hit.t - HIT_TRAVEL) / HIT_TIME
    local sizes, num = hit.sizes, hit.num
    if q < 0.1 then
        SetFontSize(num, sizes[1] + (sizes[2] - sizes[1]) * q / 0.1)
    elseif q < 0.3 then
        SetFontSize(num, sizes[2] + (sizes[3] - sizes[2]) * (q - 0.1) / 0.2)
    else
        SetFontSize(num, sizes[3])
    end
    local w = math.max(0, 1 - q / 0.25)
    num:SetTextColor(1, 0.2 + 0.8 * w, 0.2 + 0.8 * w)
    num:ClearAllPoints()
    num:SetPoint("CENTER", layer, "BOTTOMLEFT", dest.x, dest.y)
    num:SetAlpha(math.min(1, (1 - q) * 3))
    if hit.glow then hit.glow:SetAlpha(0.8 * (1 - q)) end
end

-- ----- Players -----
-- The red flash covers only the filled part of the life bar (Board.lua's MakeLifeBar)
local function NewPlateGlow(plate)
    local fill = plate.lifeBar and plate.lifeBar.fill
    local glow = plate:CreateTexture(nil, "ARTWORK", nil, 3)
    if fill then
        glow:SetPoint("TOPLEFT", fill, "TOPLEFT")
        glow:SetPoint("BOTTOMRIGHT", fill, "BOTTOMRIGHT")
    else
        glow:SetPoint("TOPLEFT", plate, "TOPLEFT", 3, -3)
        glow:SetPoint("BOTTOMRIGHT", plate, "BOTTOMRIGHT", -3, 3)
    end
    glow:SetColorTexture(1, 0.1, 0.1, 1)
    glow:SetAlpha(0)
    return glow
end

local plates = { [true] = B.oppLifeBtn, [false] = B.myLifeBtn }
local plateGlows = { [true] = NewPlateGlow(B.oppLifeBtn), [false] = NewPlateGlow(B.myLifeBtn) }
local platePos = {
    [true]  = function() return Pos(plates[true]) end,
    [false] = function() return Pos(plates[false]) end,
}
local hitShown = false   -- set when a hit plays, so combat doesn't play a second one

-- Where damage is coming from, set by the engine hooks around the calls that deal it: one
-- source (a spell or ability), or a queue with one per damage to a player in order (combat:
-- each attacker's, set off once the blocks have landed). Each flies in its card's colour (a
-- two-colour card's first).
local hitSrc, hitSrcUntil, hitSrcColor
local function SetHitSource(pos, linger, card)
    hitSrc, hitSrcUntil = pos, linger and GetTime() + linger or math.huge
    hitSrcColor = CardColor(card)
end

local hitQueue, hitQueueUntil = {}, 0
local function SetHitQueue(list, linger)
    hitQueue, hitQueueUntil = list, linger and GetTime() + linger or math.huge
end

local function NextHitSource()
    local now = GetTime()
    if now <= hitQueueUntil and hitQueue[1] then
        local s = table.remove(hitQueue, 1)
        return s.pos, s.color, s.at
    end
    if hitSrc and now <= hitSrcUntil then return hitSrc, hitSrcColor end
end

-- at = the time it sets off (nil = now)
local function ShowHit(isRemote, amount, src, color, at)
    local side = isRemote and true or false
    hitShown = true
    src = src or { x = layer:GetWidth() / 2, y = layer:GetHeight() / 2 }
    local delay = at and math.max(0, at - GetTime()) or 0
    local hit = AddHitDamage(side, platePos[side], PLAYER_HIT_SIZES, amount, src, color, nil, delay)
    hit.glow, hit.sound = plateGlows[side], true
end

-- Damage a player's shield soaked up entirely: the hit sound, without the red flash
local soakAt = {}
local function ShowSoak(isRemote)
    local side = isRemote and true or false
    hitShown = true
    local now, hit = GetTime(), activeHits[side]
    if not (soakAt[side] and now - soakAt[side] < HIT_JOIN) and not (hit and hit.t < HIT_JOIN) then
        PlayFX(SOUND_HIT)
    end
    soakAt[side] = now
end

-- A player's damage shield as this client sees it (the PvP opponent's is our copy of theirs)
local function ShieldOf(E, isRemote)
    if isRemote and not E.isSolo then
        local m = E.remoteState.mirror
        return m and m.shield or 0
    end
    return (isRemote and E.remoteState or E.localState).damageShield or 0
end

-- ----- Creatures -----
-- The parts of a creature's damage noted as it's dealt (perm -> { at, list = { pos, color, n } });
-- Board.lua's redraw sees the damage and calls TTS.FlyCreatureDamage, which sends them
local creatureShards = setmetatable({}, { __mode = "k" })

local function AddCreatureShard(perm, pos, color, n)
    local now, c = GetTime(), creatureShards[perm]
    if not c or now - c.at > HIT_SOURCE_LINGER then
        c = { list = {} }
        creatureShards[perm] = c
    end
    c.at = now
    table.insert(c.list, { pos = pos, color = color, n = n })
end

-- total = the damage the creature took (Fatal shows no more than it could take)
function TTS.FlyCreatureDamage(frame, total, perm)
    local posFn = function() return Pos(frame) end
    if not posFn() then return end
    local c = creatureShards[perm]
    creatureShards[perm] = nil
    if not c or GetTime() - c.at > HIT_SOURCE_LINGER then
        AddHitDamage(perm, posFn, CREATURE_HIT_SIZES, total)
        return
    end
    for i, s in ipairs(c.list) do
        AddHitDamage(perm, posFn, CREATURE_HIT_SIZES, i == 1 and total or 0, s.pos, s.color, s.n)
    end
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
    for key, hit in pairs(activeHits) do UpdateHitFX(key, hit, dt) end
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
        local hint = TTS.L("log.cancelHint")
        local at = s:find(hint, 1, true)
        if at then s = (s:sub(1, at - 1) .. s:sub(at + #hint)):gsub("%s+$", "") end
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

    -- A pointer for the player at the cursor, not written to the log (only during their own clicks)
    function E:Hint(msg)
        if userDepth > 0 and quietDepth == 0 and self.inMatch then
            TTS.FloatText(ShortMessage(msg), TTS.FLOAT_WARN, nil)
        end
    end

    if E.ResolveTarget then
        -- Refusals float their reason at the cursor (from the log line)
        local origResolve = Counted(E.ResolveTarget)
        E.ResolveTarget = function(self, targetType, isRemote, fieldIndex, ...)
            local targeting = self.targeting
            local results = { origResolve(self, targetType, isRemote, fieldIndex, ...) }
            -- Targeting cleared or replaced: the target was accepted (the spell reveal or
            -- the ability arrow below draws the arrow)
            if targeting and self.targeting ~= targeting then
                PlayFX(SOUND_TARGET)
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
            SetHitSource(Pos(reveal), nil, card)
            local results = { origSpell(self, card, tgt, casterIsRemote, ...) }
            SetHitSource(nil)
            return unpack(results)
        end
    end

    -- The PvP opponent's spell: its damage arrives afterwards, from their client
    if E.ShowRemoteSpell then
        local origRemoteSpell = E.ShowRemoteSpell
        E.ShowRemoteSpell = function(self, cardId, ...)
            local results = { origRemoteSpell(self, cardId, ...) }
            SetHitSource(Pos(reveal), HIT_SOURCE_LINGER, TTS.Cards[cardId])
            return unpack(results)
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
            SetHitSource(src, nil, perm and TTS.Cards[perm.id])
            local ok = origAbility(self, perm, isRemote, tgt, ...)
            SetHitSource(nil)
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
            local before, shield = state.life, ShieldOf(self, isRemote)
            local src, color, at
            if (tonumber(amount) or 0) > 0 then src, color, at = NextHitSource() end
            local results = { origDamage(self, isRemote, amount, reason, ...) }
            if state.life < before then
                ShowHit(isRemote, before - state.life, src, color, at)
            elseif ShieldOf(self, isRemote) < shield then
                ShowSoak(isRemote)
            end
            return unpack(results)
        end
    end

    -- Damage to creatures from spells and abilities: noted with its source for the redraw
    if E.DamageCreature then
        local origDamageCreature = E.DamageCreature
        E.DamageCreature = function(self, perm, ...)
            local marked = origDamageCreature(self, perm, ...)
            if perm and (marked or 0) > 0 and hitSrc and GetTime() <= hitSrcUntil then
                AddCreatureShard(perm, hitSrc, hitSrcColor, marked)
            end
            return marked
        end
    end

    if E.ResolveCombatDamage then
        local origCombat = E.ResolveCombatDamage
        E.ResolveCombatDamage = function(self, ...)
            local bs = self.blockingState
            local arrows, state, before, shield, defRemote = {}, nil, nil, nil, nil
            local queue = {}   -- each damage to the defending player in the order combat deals it
            local combatSrc, firstColor, afterBlocks
            -- PvP, defending: the attacker's client sends the damage to us afterwards
            -- (ACTION:DAMAGE), so our life doesn't change here; arrow every unblocked
            -- attacker that will hit (the hit itself plays when that damage arrives), in
            -- blue if our damage shield will soak all of it
            local damageArrives, incoming = false, 0
            if bs then
                local atkRemote = bs.isRemoteAttacking and true or false
                defRemote = not atkRemote
                damageArrives = atkRemote and not self.isSolo and not self.preventCombatDamage
                state = defRemote and self.remoteState or self.localState
                before, shield = state.life, ShieldOf(self, defRemote)
                local plan = self:PlanCombatDamage(bs)
                -- Blocks resolve first: the damage getting through sets off once they've landed
                if plan.hits and #plan.hits > 0 and not self.preventCombatDamage then
                    afterBlocks = GetTime() + HIT_TRAVEL + HIT_AFTER_BLOCKS
                end

                local blocked = {}
                for _, p in ipairs(self:BlockPairs(bs)) do blocked[p[2]] = true end
                local atkField = (atkRemote and self.remoteState or self.localState).field
                local dst = Pos(defRemote and B.oppLifeBtn or B.myLifeBtn)
                local srcs = {}
                for _, atkIdx in ipairs(bs.attackers or {}) do
                    local perm = atkField[atkIdx]
                    local src = perm and Pos(FindFieldFrame(atkRemote, atkIdx))
                    local color = perm and CardColor(TTS.Cards[perm.id])
                    local power = perm and (self:GetCreatureStats(perm, atkRemote) or 0) or 0
                    if perm and not blocked[atkIdx] and power > 0 then
                        incoming = incoming + power
                        table.insert(queue, { pos = src, color = color, at = afterBlocks })
                        if src then table.insert(srcs, src) end
                        firstColor = firstColor or color
                        if src and dst then table.insert(arrows, { src, dst }) end
                    elseif perm and blocked[atkIdx] and plan.trample[perm] then
                        table.insert(queue, { pos = src, color = color, at = afterBlocks })
                    end
                end
                if damageArrives then
                    for _, n in pairs(plan.trample) do incoming = incoming + n end
                end
                combatSrc = Centroid(srcs)

                -- Each blow between attackers and blockers flies from the creature striking it
                if not self.preventCombatDamage then
                    for _, h in ipairs(plan.hits or {}) do
                        local r, idx = self:FindPerm(h.src)
                        local pos = idx and Pos(FindFieldFrame(r and true or false, idx))
                        if pos then AddCreatureShard(h.dst, pos, CardColor(TTS.Cards[h.src.id]), h.n) end
                    end
                end
            end

            hitShown = false
            SetHitQueue(queue)
            local results = { origCombat(self, ...) }
            SetHitQueue(queue, damageArrives and HIT_SOURCE_LINGER or 0)
            if damageArrives then
                local color = (incoming > 0 and shield >= incoming) and SOAK_COLOR or HIT_COLOR
                for _, pair in ipairs(arrows) do FlashArrow(pair[1], pair[2], color, HIT_ARROW_HOLD) end
            elseif state and state.life < before then
                for _, pair in ipairs(arrows) do FlashArrow(pair[1], pair[2], HIT_COLOR, HIT_ARROW_HOLD) end
                -- Combat that changes life without going through DamagePlayer still gets a hit
                if not hitShown then ShowHit(defRemote, before - state.life, combatSrc, firstColor, afterBlocks) end
            elseif state and ShieldOf(self, defRemote) < shield then
                -- The damage shield soaked up every point
                for _, pair in ipairs(arrows) do FlashArrow(pair[1], pair[2], SOAK_COLOR, HIT_ARROW_HOLD) end
                if not hitShown then ShowSoak(defRemote) end
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