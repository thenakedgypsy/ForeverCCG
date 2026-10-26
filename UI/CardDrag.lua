--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
local L = TTS.L

-- =========================================================================
-- DRAGGING CARDS
-- With "Card controls" set to Drag or Both (Options):
--  * A card from your hand dropped on the battlefield is played. A spell that
--    needs a target is dropped on the target (an arrow follows the cursor);
--    dropped on empty board it waits for a target to be clicked as usual.
--  * Your creature dragged at the opponent attacks (from Main 1 it moves to combat first).
--  * Your creature dropped on an attacker blocks it; dragged off into empty board
--    it stops blocking.
--  * A creature with a targeted ability dropped on a target uses it.
-- Each drop calls the same engine functions a click does, so the rules and the
-- network messages are the same. Load after UI\TargetFX.lua.
-- =========================================================================
local B = TTS.BoardFrame
if not B then return end

local AIM_TARGET = { 1.0, 0.82, 0.0, 0.85 }
local AIM_ATTACK = { 1.0, 0.2, 0.2, 0.85 }
local AIM_BLOCK  = { 0.25, 0.55, 1.0, 0.85 }   -- the block arrows' blue

-- The drag in progress: { kind = "card"|"spell"|"field"|"block", frame, ... }
local drag

local function Warn(msg)
    if TTS.FloatText then TTS.FloatText(msg, TTS.FLOAT_WARN, nil) end
end

-- The cursor in the board's coordinates
local function Cursor()
    local s = B:GetEffectiveScale()
    local cx, cy = GetCursorPosition()
    return cx / s - B:GetLeft(), cy / s - B:GetBottom()
end

-- =========================================================================
-- THE DRAGGED CARD
-- =========================================================================
local ghost

local function Ghost()
    if ghost then return ghost end
    ghost = TTS.CreateCardFrame(B, B.HAND_W, B.HAND_H)
    ghost:EnableMouse(false)
    ghost:SetScript("OnEnter", nil)
    ghost:SetScript("OnLeave", nil)
    ghost:SetScript("OnClick", nil)
    ghost:SetFrameLevel(B:GetFrameLevel() + 60)   -- above the arrows
    ghost:SetAlpha(0.9)
    return ghost
end

local function ShowGhost(card, scale, foil)
    local g = Ghost()
    TTS.SetupCardVisual(g, card, foil)
    TTS.ApplyFrameTexture(g.border, card)
    g.border:SetVertexColor(1, 1, 1)
    g.title:SetText(TTS:CardName(card) or "")
    if card.cost and card.cost ~= "" then
        g.cost:SetText(TTS:FormatCost(card.cost, 16))
        g.cost:Show()
    else
        g.cost:Hide()
    end
    TTS.ShowPrintedStats(g, card)
    g:SetScale(scale)
    g:Show()
    TTS.UpdateCardRules(g)
end

local function MoveGhost()
    local x, y = Cursor()
    local s = ghost:GetScale()
    ghost:ClearAllPoints()
    ghost:SetPoint("CENTER", B, "BOTTOMLEFT", x / s, y / s)
end

local function SetAim(frame, color)
    B.dragAim = frame and { frame = frame, color = color } or nil
end

-- =========================================================================
-- WHAT IS UNDER THE CURSOR
-- { kind = "CREATURE"|"PLAYER", isRemote, fieldIndex, perm }, or nil
-- =========================================================================
local function DropTarget(d)
    local E = TTS.Engine
    for _, side in ipairs({ { B.oppNonLandFrames, true }, { B.myNonLandFrames, false } }) do
        for _, f in ipairs(side[1]) do
            if f ~= d.frame and f:IsShown() and f.fieldIndex and f:IsMouseOver() then
                local field = side[2] and E.remoteState.field or E.localState.field
                return { kind = "CREATURE", isRemote = side[2], fieldIndex = f.fieldIndex, perm = field[f.fieldIndex] }
            end
        end
    end
    if B.oppLifeBtn:IsMouseOver() then return { kind = "PLAYER", isRemote = true, fieldIndex = 0 } end
    if B.myLifeBtn:IsMouseOver() then return { kind = "PLAYER", isRemote = false, fieldIndex = 0 } end
end

-- Why this creature cannot attack right now, or nil if it can
local function AttackRefusal(E, perm, card)
    if perm.isAttacking then return L("err.alreadyAttacking", TTS:CardName(card)) end
    if perm.tapped then return L("err.tappedCantAttack", TTS:CardName(card)) end
    if perm.sick and not E:HasKeyword(perm, false, "haste") then return L("err.summoningSick", TTS:CardName(card)) end
    if card.defender then return L("err.blockerCantAttack", TTS:CardName(card)) end
end

-- =========================================================================
-- STARTING A DRAG
-- =========================================================================
local function BeginHandDrag(f)
    local E = TTS.Engine
    local card = f.cardId and TTS.Cards[f.cardId]
    if not card then return end
    if E.pendingDiscard then Warn(L("err.discardFirst")); return end
    if not E.isMyTurn then Warn(L("err.notYourTurnPlay")); return end
    -- A target being chosen for another card is dropped quietly
    E.targeting = nil

    drag = { kind = "card", frame = f, handIndex = f.handIndex, cardId = f.cardId }
    local targetType = E:GetSpellTargetType(card)
    if targetType then
        drag.kind = "spell"
        B.dragTargeting = { targetMode = "SPELL", cardId = f.cardId, handIndex = f.handIndex,
            targetType = targetType, cardName = TTS:CardName(card) }
        SetAim(f, AIM_TARGET)
    else
        ShowGhost(card, f.baseScale or 1, f.isFoil)
        MoveGhost()
        f:SetAlpha(0.3)
    end
    E:RefreshUI()
end

local function BeginFieldDrag(f)
    local E = TTS.Engine
    local idx = f.fieldIndex
    local perm = idx and E.localState.field[idx]
    local card = perm and TTS.Cards[perm.id]
    if not (card and card.type == "Creature") then return end
    E.targeting = nil

    local bs = E.blockingState
    local d = { frame = f, fieldIndex = idx, perm = perm }
    if E.phase == "COMBAT_BLOCK" and bs and bs.isRemoteAttacking then
        if bs.blocksDeclared then Warn(L("err.blocksDeclared")); return end
        if perm.tapped then Warn(L("err.tappedCantBlock")); return end
        if E.cantBlockThisTurn then Warn(L("err.cantBlockThisTurn")); return end
        d.kind = "block"
        SetAim(f, AIM_BLOCK)
    elseif not E.isMyTurn then
        Warn(L("err.notYourTurnAct"))
        return
    else
        local ab = E:GetAbility(perm.id)
        if ab and ab.target and (E.phase == "MAIN1" or E.phase == "MAIN2") and E:CanActivateAbility(perm, false) then
            d.ability = { targetMode = "ABILITY", sourceIndex = idx, sourcePerm = perm, cardName = TTS:CardName(card),
                targetType = (ab.target == "enemy_player") and "PLAYER" or "CREATURE" }
            B.dragTargeting = d.ability
        end
        if E.phase == "MAIN1" or E.phase == "COMBAT_ATTACK" then
            d.attackRefusal = AttackRefusal(E, perm, card)
            d.attack = not d.attackRefusal
        end
        if not (d.ability or d.attack) then
            Warn(d.attackRefusal or (E.phase == "MAIN2" and L("err.combatOver"))
                or L("err.nothingToDrag"))
            B.dragTargeting = nil
            return
        end
        d.kind = "field"
        SetAim(f, d.attack and AIM_ATTACK or AIM_TARGET)
    end
    drag = d
    E:RefreshUI()
end

-- =========================================================================
-- DROPPING
-- =========================================================================

-- Starts the targeting (by the same call a click makes), then hands it the target.
-- A refused target is not kept waiting: the drag is over, and the reason has floated up.
local function TargetWith(E, start, target, matches)
    start()
    local t = E.targeting
    if t and matches(t) then
        E:ResolveTarget(target.kind, target.isRemote, target.fieldIndex)
        if E.targeting == t then E.targeting = nil end
    end
end

local function DropHandCard(E, d, target, x, y)
    if E.localState.hand[d.handIndex] ~= d.cardId then return end
    local onBoard = y > B.HAND_TOP
    if d.kind == "spell" then
        if target then
            TargetWith(E, function() E:PlayCard(d.handIndex) end, target,
                function(t) return t.handIndex == d.handIndex end)
        elseif onBoard then
            E:PlayCard(d.handIndex)   -- no target under it: choose one by clicking
        end
    elseif onBoard then
        B.launchFrom = { cardId = d.cardId, x = x, y = y }   -- flies to its slot from here
        E:PlayCard(d.handIndex)
        B.launchFrom = nil
    end
end

local function DropBlocker(E, d, target)
    local bs = E.blockingState
    local idx = d.fieldIndex
    if not (bs and E.localState.field[idx] == d.perm) then return end
    if target and target.kind == "CREATURE" and target.isRemote then
        -- Selecting it by click would take back a block it already has
        if bs.selectedBlocker == idx or bs.blocks[idx] then
            bs.selectedBlocker = idx
        else
            E:TapCard(idx)
        end
        if bs.selectedBlocker == idx then E:ClickOpponentCard(target.fieldIndex) end
        if bs.selectedBlocker == idx then bs.selectedBlocker = nil end   -- refused
    elseif bs.blocks[idx] then
        E:ClearBlocks(bs, idx)
        local card = TTS.Cards[d.perm.id]
        E:Log(L("log.unblocked", card and TTS:CardName(card) or L("type.Creature")), "COMBAT")
    end
end

local function DropFieldCreature(E, d, target, y)
    local idx = d.fieldIndex
    if E.localState.field[idx] ~= d.perm then return end
    local useAbility = function()
        TargetWith(E, function() E:TapCard(idx) end, target,
            function(t) return t.targetMode == "ABILITY" and t.sourceIndex == idx end)
    end
    local onEnemy = (target and target.isRemote) or y > B.MIDLINE

    if d.ability and target and E:IsValidTargetNow(target.kind, target.isRemote, target.perm, d.ability) then
        useAbility()
    elseif d.attack and onEnemy then
        E.dragAttack = true   -- the tutorial tells this apart from pressing To Combat
        if E.phase == "MAIN1" then E:NextPhase() end
        E.dragAttack = nil
        if E.phase == "COMBAT_ATTACK" then E:TapCard(idx) end
    elseif d.ability and target then
        useAbility()   -- not a legal target: the engine says why
    elseif onEnemy and d.attackRefusal then
        Warn(d.attackRefusal)
    end
end

local function EndDrag(cancelled)
    local d = drag
    drag = nil
    if not d then return end
    d.frame.dragEnded = GetTime()   -- its click handler skips the mouse-up that ends the drag
    d.frame:SetAlpha(1)
    B.dragAim, B.dragTargeting = nil, nil
    if ghost then ghost:Hide() end

    local E = TTS.Engine
    if not cancelled and E.inMatch then
        local x, y = Cursor()
        local target = DropTarget(d)
        if d.kind == "card" or d.kind == "spell" then
            DropHandCard(E, d, target, x, y)
        elseif d.kind == "block" then
            DropBlocker(E, d, target)
        else
            DropFieldCreature(E, d, target, y)
        end
    end
    E:RefreshUI()
end

-- =========================================================================
-- FRAME SCRIPTS
-- =========================================================================
local function OnDragStart(self)
    if drag or TTS.CardControls() == "click" or not TTS.Engine.inMatch then return end
    if TTS.Tooltip then TTS.Tooltip:Hide() end
    if self.isHand then BeginHandDrag(self) else BeginFieldDrag(self) end
end

local function OnDragStop(self)
    if drag and drag.frame == self then EndDrag(false) end
end

for _, list in ipairs({ B.myHandFrames, B.myNonLandFrames }) do
    for _, f in ipairs(list) do
        f:SetScript("OnDragStart", OnDragStart)
        f:SetScript("OnDragStop", OnDragStop)
    end
end

-- Denizen frames the board makes later, for a crowded battlefield (Board.lua's FieldFrame)
if B.fieldFrameHooks then
    table.insert(B.fieldFrameHooks, function(f, group)
        if group ~= B.myNonLandFrames then return end
        f:SetScript("OnDragStart", OnDragStart)
        f:SetScript("OnDragStop", OnDragStop)
        if TTS.CardControls and TTS.CardControls() ~= "click" then f:RegisterForDrag("LeftButton") end
    end)
end

-- Cards only start drags when the controls allow it, so in Click mode a
-- slightly moving click is still a click
function TTS.ApplyCardControls()
    local on = TTS.CardControls() ~= "click"
    for _, list in ipairs({ B.myHandFrames, B.myNonLandFrames }) do
        for _, f in ipairs(list) do
            if on then f:RegisterForDrag("LeftButton") else f:RegisterForDrag() end
        end
    end
    if not on and drag then EndDrag(true) end
end

-- Follows the cursor; also ends a drag whose card was hidden under it (no OnDragStop then)
local driver = CreateFrame("Frame", nil, B)
driver:SetScript("OnUpdate", function()
    if not drag then return end
    if not (TTS.Engine.inMatch and B:IsShown()) then EndDrag(true); return end
    if not IsMouseButtonDown("LeftButton") then EndDrag(false); return end
    if ghost and ghost:IsShown() then MoveGhost() end
    -- A creature that could attack or use its ability: the arrow says which a drop here would do
    if drag.kind == "field" and drag.ability and drag.attack and B.dragAim then
        local t = DropTarget(drag)
        local valid = t and TTS.Engine:IsValidTargetNow(t.kind, t.isRemote, t.perm, drag.ability)
        B.dragAim.color = valid and AIM_TARGET or AIM_ATTACK
    end
end)
driver:SetScript("OnHide", function() if drag then EndDrag(true) end end)

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addon)
    if addon ~= "ForeverCCG" then return end
    self:UnregisterAllEvents()
    TTS.ApplyCardControls()
end)
