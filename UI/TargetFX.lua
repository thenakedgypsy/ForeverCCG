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
-- Sounds respect the board's Sounds checkbox. Load after UI\Board.lua.
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
local HIT_TIME        = 1.0    -- seconds the life-plate flash and damage number last
local HIT_RISE        = 36     -- pixels the damage number floats up

local layer = CreateFrame("Frame", nil, B)
layer:SetAllPoints(B)
layer:SetFrameLevel(B:GetFrameLevel() + 45)   -- above the block arrows
layer:EnableMouse(false)

local canDrawLines = layer.CreateLine ~= nil
local atan2 = math.atan2 or math.atan

local function PlayFX(soundId)
    if not (TTS.Sound and TTS.Sound.enabled) then return end
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

local function FlashArrow(s, t, color)
    if not (canDrawLines and s and t) then return end
    local a = table.remove(freeArrows) or NewArrow()
    local sx, sy, ex, ey = EdgeToEdge(s, t)
    DrawArrow(a, sx, sy, ex, ey, color)
    table.insert(flashes, { arrow = a, t = 0 })
end

-- The card a pending spell is being cast from
local function AimSourceFrame(targeting)
    if targeting and targeting.handIndex and B.myHandFrames then
        return B.myHandFrames[targeting.handIndex]
    end
end

local aimArrow
local function UpdateAim()
    if not canDrawLines then return end
    local E = TTS.Engine
    local src = E and E.inMatch and Pos(AimSourceFrame(E.targeting))
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
    DrawArrow(aimArrow, sx, sy, cx, cy, AIM_COLOR)
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

layer:SetScript("OnUpdate", function(_, dt)
    UpdateAim()
    for i = #flashes, 1, -1 do
        local fl = flashes[i]
        fl.t = fl.t + dt
        local alpha = 1 - fl.t / FLASH_TIME
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

    if E.ResolveTarget then
        local origResolve = E.ResolveTarget
        E.ResolveTarget = function(self, targetType, isRemote, fieldIndex, ...)
            local targeting = self.targeting
            local src, dst
            if targeting then
                src = Pos(AimSourceFrame(targeting))
                if targetType == "PLAYER" then
                    dst = Pos(isRemote and B.oppLifeBtn or B.myLifeBtn)
                else
                    dst = Pos(FindFieldFrame(isRemote and true or false, fieldIndex))
                end
            end
            local results = { origResolve(self, targetType, isRemote, fieldIndex, ...) }
            -- Targeting cleared or replaced: the target was accepted
            if targeting and self.targeting ~= targeting then
                FlashArrow(src, dst, TARGET_COLOR)
                PlayFX(SOUND_TARGET)
            end
            return unpack(results)
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
                for _, pair in ipairs(arrows) do FlashArrow(pair[1], pair[2], HIT_COLOR) end
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