--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

-- =========================================================================
-- BLOCK ARROWS & DEATH PREVIEW
-- While blocks are assigned, an arrow runs from each blocker to the attacker
-- it blocks, and a skull marks every creature that will die if the blocks
-- are accepted. Reads E.blockingState.blocks ([blockerIdx] = attackerIdx) and
-- redraws every time the board refreshes. Load after UI\Board.lua.
-- =========================================================================
local B = TTS.BoardFrame
if not B then return end

local ARROW_COLOR     = { 0.25, 0.55, 1.0, 0.9 }  -- blue, apart from the red/green/yellow spell arrows
local ARROW_THICKNESS = 3
local ARROW_HEAD_LEN  = 14
local ARROW_HEAD_ANG  = 0.45  -- radians either side of the shaft

local SKULL_TEX  = "Interface\\AddOns\\ForeverCCG\\Textures\\Symbols\\Skull.png"
local SKULL_SIZE = 40

-- Drawn above the cards so arrows and skulls are never hidden behind one
local layer = CreateFrame("Frame", nil, B)
layer:SetAllPoints(B)
layer:SetFrameLevel(B:GetFrameLevel() + 40)
layer:EnableMouse(false)

-- Clients without line textures simply get no arrows (skulls still show)
local canDrawLines = layer.CreateLine ~= nil

local atan2 = math.atan2 or math.atan
local pool = {}
local skullPool = {}

local function NewLine()
    local line = layer:CreateLine(nil, "OVERLAY")
    line:SetThickness(ARROW_THICKNESS)
    line:SetColorTexture(ARROW_COLOR[1], ARROW_COLOR[2], ARROW_COLOR[3], ARROW_COLOR[4])
    line:Hide()
    return line
end

local function GetArrow(n)
    if not pool[n] then
        pool[n] = { NewLine(), NewLine(), NewLine() }  -- shaft, head left, head right
    end
    return pool[n]
end

local function GetSkull(n)
    if not skullPool[n] then
        local tex = layer:CreateTexture(nil, "OVERLAY", nil, 7)
        tex:SetSize(SKULL_SIZE, SKULL_SIZE)
        tex:SetTexture(SKULL_TEX)
        tex:Hide()
        skullPool[n] = tex
    end
    return skullPool[n]
end

local function SetLine(line, x1, y1, x2, y2)
    line:SetStartPoint("BOTTOMLEFT", layer, x1, y1)
    line:SetEndPoint("BOTTOMLEFT", layer, x2, y2)
    line:Show()
end

-- The shown battlefield card for a field index on one side of the board
local function FindFieldFrame(isRemote, fieldIndex)
    for _, child in ipairs({ B:GetChildren() }) do
        if child.fieldIndex == fieldIndex and child.isRemote == isRemote and child:IsShown() then
            return child
        end
    end
end

-- Arrow from the blocker's edge to the attacker's edge (the edges that face each other)
-- Cards are scaled individually, so their positions and sizes are converted into the layer's scale
local function FramePos(f)
    local cx, cy = f:GetCenter()
    if not cx then return end
    local r = f:GetEffectiveScale() / layer:GetEffectiveScale()
    return cx * r, cy * r, f:GetHeight() * r
end

local function DrawArrow(n, fromFrame, toFrame)
    local left, bottom = layer:GetLeft(), layer:GetBottom()
    local fx, fy, fh = FramePos(fromFrame)
    local tx, ty, th = FramePos(toFrame)
    if not (left and bottom and fx and tx) then return false end

    fx, fy, tx, ty = fx - left, fy - bottom, tx - left, ty - bottom
    local dir = (ty > fy) and 1 or -1
    local sx, sy = fx, fy + dir * fh / 2
    local ex, ey = tx, ty - dir * th / 2

    local a = GetArrow(n)
    SetLine(a[1], sx, sy, ex, ey)

    local ang = atan2(ey - sy, ex - sx)
    SetLine(a[2], ex, ey,
        ex - ARROW_HEAD_LEN * math.cos(ang - ARROW_HEAD_ANG),
        ey - ARROW_HEAD_LEN * math.sin(ang - ARROW_HEAD_ANG))
    SetLine(a[3], ex, ey,
        ex - ARROW_HEAD_LEN * math.cos(ang + ARROW_HEAD_ANG),
        ey - ARROW_HEAD_LEN * math.sin(ang + ARROW_HEAD_ANG))
    return true
end

-- =========================================================================
-- DEATH PREVIEW
-- Mirrors the creature damage in E:ResolveCombatDamage (first strike,
-- deathtouch, damage already marked) and the death check in
-- E:CheckStateBasedActions (regeneration saves the creature).
-- Returns a set: dies[perm] = true.
-- =========================================================================
local function WillDie(perm, isRemote, taken)
    if perm.regenerateShield then return false end
    local _, toughness = TTS.Engine:GetCreatureStats(perm, isRemote)
    return ((perm.damage or 0) + taken) >= toughness or toughness <= 0
end

local function PredictDeaths(E, bs)
    local dies = {}
    if E.preventCombatDamage then return dies end

    local atkRemote = bs.isRemoteAttacking and true or false
    local defRemote = not atkRemote
    local atkField = atkRemote and E.remoteState.field or E.localState.field
    local defField = atkRemote and E.localState.field or E.remoteState.field

    for _, atkIdx in ipairs(bs.attackers or {}) do
        local atkPerm = atkField[atkIdx]

        -- Combat pairs each attacker with the first blocker found for it
        local defPerm
        for bIdx, aIdx in pairs(bs.blocks) do
            if aIdx == atkIdx then
                defPerm = defField[bIdx]
                break
            end
        end

        if atkPerm and defPerm then
            local atkPower, atkToughness = E:GetCreatureStats(atkPerm, atkRemote)
            local defPower, defToughness = E:GetCreatureStats(defPerm, defRemote)
            local atkHit = E:HasKeyword(atkPerm, atkRemote, "deathtouch") and 999 or atkPower
            local defHit = E:HasKeyword(defPerm, defRemote, "deathtouch") and 999 or defPower
            local atkFirst = E:HasKeyword(atkPerm, atkRemote, "firstStrike")
            local defFirst = E:HasKeyword(defPerm, defRemote, "firstStrike")

            local atkTaken, defTaken = 0, 0
            if atkFirst and not defFirst then
                defTaken = atkHit
                if (defPerm.damage or 0) + defTaken < defToughness then atkTaken = defHit end
            elseif defFirst and not atkFirst then
                atkTaken = defHit
                if (atkPerm.damage or 0) + atkTaken < atkToughness then defTaken = atkHit end
            else
                atkTaken, defTaken = defHit, atkHit
            end

            if WillDie(atkPerm, atkRemote, atkTaken) then dies[atkPerm] = true end
            if WillDie(defPerm, defRemote, defTaken) then dies[defPerm] = true end
        end
    end
    return dies
end

local function UpdateBlockArrows()
    local E = TTS.Engine
    local n, s = 0, 0
    local bs = E and E.inMatch and E.blockingState
    B.predictedDeaths = nil   -- read by the card tooltips (skull symbol)

    if bs and bs.blocks then
        -- Defending: blockers are ours, attackers theirs. Attacking: the reverse.
        local blockerRemote = not bs.isRemoteAttacking
        if canDrawLines then
            for blockerIdx, attackerIdx in pairs(bs.blocks) do
                local fromFrame = FindFieldFrame(blockerRemote, blockerIdx)
                local toFrame = FindFieldFrame(not blockerRemote, attackerIdx)
                if fromFrame and toFrame and DrawArrow(n + 1, fromFrame, toFrame) then
                    n = n + 1
                end
            end
        end

        -- Skull over every creature that dies if these blocks are accepted
        local dies = PredictDeaths(E, bs)
        B.predictedDeaths = dies
        for _, isRemote in ipairs({ false, true }) do
            local field = isRemote and E.remoteState.field or E.localState.field
            for i, perm in ipairs(field) do
                if dies[perm] then
                    local f = FindFieldFrame(isRemote, i)
                    if f then
                        s = s + 1
                        local skull = GetSkull(s)
                        skull:ClearAllPoints()
                        skull:SetPoint("CENTER", f, "CENTER", 0, 0)
                        skull:Show()
                    end
                end
            end
        end
    end

    for i = n + 1, #pool do
        for _, line in ipairs(pool[i]) do line:Hide() end
    end
    for i = s + 1, #skullPool do
        skullPool[i]:Hide()
    end
end

hooksecurefunc(B, "UpdateDisplay", UpdateBlockArrows)