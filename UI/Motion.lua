--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

-- =========================================================================
-- MOTION
-- A little life across the add-on's windows (not the board, whose models don't take it well):
--   * opening: a window fades in and grows the last few percent into place
--   * buttons: while hovered, their highlight breathes; a click flashes it
--   * section panels (tooltip-bordered, gold header) brighten their border while the mouse
--     is over them
-- Mostly animation groups; a panel's hover is a light check ten times a second while it's
-- shown. Windows with card models only fade (NO_SCALE): a model can keep a wrong size after
-- its window's scale changes under it (UI\Board.lua's model reloads). Frames made
-- after a window first opens (lists that fill later) are picked up the next time it opens.
-- Switched off with the uiMotion option (Options, Windows).
-- =========================================================================
local M = {}
TTS.Motion = M

local WINDOWS = {
    "TTS_MainDialog", "TTS_PvEFrame", "TTS_PvPFrame", "TTS_OptionsFrame", "TTS_DeckBuilderFrame",
    "TTS_DeckPicker", "TTS_RulesFrame", "TTS_SoloSelectFrame", "TTS_DungeonEntryFrame", "TTS_WaitingRoomFrame",
    "TTS_HeroChoice", "TTS_QuickStart", "TTS_PvPRecordFrame", "TTS_PackOpenerFrame", "TTS_CollectionGuideFrame",
    "TTS_DailyPanel", "TTS_EndlessFrame", "TTS_ChoicePopup",
}
local NO_SCALE = { TTS_DeckBuilderFrame = true, TTS_CollectionGuideFrame = true, TTS_HeroChoice = true,
    TTS_PackOpenerFrame = true, TTS_QuickStart = true, TTS_SoloSelectFrame = true, TTS_EndlessFrame = true,
    TTS_DailyPanel = true, TTS_DungeonEntryFrame = true, TTS_ChoicePopup = true }
local OPEN_TIME = 0.18
local OPEN_FROM = 0.94          -- the scale a window grows from
local BREATHE_TIME = 0.7        -- a hovered button's highlight, one way
local CLICK_TIME = 0.25

local function On()
    return not TTS.Options or TTS.Options:Get("uiMotion") ~= false
end

-- =========================================================================
-- WINDOWS
-- =========================================================================
local function OpenAnim(f)
    if f.ttsOpenAnim then return f.ttsOpenAnim end
    local g = f:CreateAnimationGroup()
    local fade = g:CreateAnimation("Alpha")
    fade:SetFromAlpha(0)
    fade:SetToAlpha(1)
    fade:SetDuration(OPEN_TIME)
    fade:SetSmoothing("OUT")
    if NO_SCALE[f:GetName() or ""] then
        f.ttsOpenAnim = g
        return g
    end
    local grow = g:CreateAnimation("Scale")
    if grow.SetScaleFrom then
        grow:SetScaleFrom(OPEN_FROM, OPEN_FROM)
        grow:SetScaleTo(1, 1)
    elseif grow.SetFromScale then
        grow:SetFromScale(OPEN_FROM, OPEN_FROM)
        grow:SetToScale(1, 1)
    end
    grow:SetOrigin("CENTER", 0, 0)
    grow:SetDuration(OPEN_TIME)
    grow:SetSmoothing("OUT")
    f.ttsOpenAnim = g
    return g
end

-- =========================================================================
-- BUTTONS AND PANELS
-- =========================================================================
local function Breathe(tex)
    if tex.ttsBreathe then return tex.ttsBreathe end
    local g = tex:CreateAnimationGroup()
    g:SetLooping("BOUNCE")
    local a = g:CreateAnimation("Alpha")
    a:SetFromAlpha(1)
    a:SetToAlpha(0.45)
    a:SetDuration(BREATHE_TIME)
    a:SetSmoothing("IN_OUT")
    tex.ttsBreathe = g
    return g
end

local function EnlivenButton(b)
    if b.ttsMotion or not b.GetHighlightTexture then return end
    local hl = b:GetHighlightTexture()
    if not hl then return end
    b.ttsMotion = true
    b:HookScript("OnEnter", function(self)
        if On() and self:IsEnabled() then Breathe(hl):Play() end
    end)
    b:HookScript("OnLeave", function() if hl.ttsBreathe then hl.ttsBreathe:Stop() end end)
    -- A click: a quick flash over the button
    b:HookScript("PostClick", function(self)
        if not On() then return end
        if not self.ttsFlash then
            local t = self:CreateTexture(nil, "OVERLAY")
            t:SetAllPoints(hl)
            t:SetTexture(hl:GetTexture())
            local l, r, top, bottom = hl:GetTexCoord()
            if l then t:SetTexCoord(l, r, top, bottom) end
            t:SetBlendMode("ADD")
            t:SetAlpha(0)
            local g = t:CreateAnimationGroup()
            local a = g:CreateAnimation("Alpha")
            a:SetFromAlpha(1)
            a:SetToAlpha(0)
            a:SetDuration(CLICK_TIME)
            a:SetSmoothing("OUT")
            g:SetScript("OnFinished", function() t:SetAlpha(0) end)
            self.ttsFlash = g
        end
        self.ttsFlash:Stop()
        self.ttsFlash:Play()
    end)
end

-- A tooltip-bordered panel (the add-on's sections): its border warms to gold while hovered
local function EnlivenPanel(p)
    if p.ttsMotion or not (p.GetBackdropBorderColor and p.SetBackdropBorderColor) then return end
    if p:IsMouseEnabled() then return end   -- (one that takes the mouse has hover of its own)
    p.ttsMotion = true
    local watcher = CreateFrame("Frame", nil, p)
    local inside, t = false, 0
    watcher:SetScript("OnUpdate", function(self, dt)
        t = t + dt
        if t < 0.1 then return end
        t = 0
        local now = On() and p:IsMouseOver() or false
        if now == inside then return end
        inside = now
        if now then
            local r, g, b, a = p:GetBackdropBorderColor()
            p.ttsBorder = { r, g, b, a }
            p:SetBackdropBorderColor(1, 0.82, 0.25, 1)
        elseif p.ttsBorder then
            local c = p.ttsBorder
            p:SetBackdropBorderColor(c[1], c[2], c[3], c[4])
        end
    end)
end

-- Every button and section panel in a window, however deep
local function Walk(f, depth)
    if depth > 12 then return end
    if f.IsObjectType then
        if f:IsObjectType("Button") and not f.ttsSilent then
            EnlivenButton(f)
        elseif f:IsObjectType("Frame") and depth > 0 and f.GetBackdrop then
            local ok, bd = pcall(f.GetBackdrop, f)
            if ok and type(bd) == "table" and bd.edgeFile and bd.edgeFile:find("Tooltip") then EnlivenPanel(f) end
        end
    end
    for _, child in ipairs({ f:GetChildren() }) do Walk(child, depth + 1) end
end

function M:Hook(f)
    if not f or f.ttsMotionHooked then return end
    f.ttsMotionHooked = true
    f:HookScript("OnShow", function(self)
        Walk(self, 0)
        if On() then
            local g = OpenAnim(self)
            g:Stop()
            g:Play()
        end
    end)
    if f:IsShown() then Walk(f, 0) end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    self:UnregisterAllEvents()
    for _, name in ipairs(WINDOWS) do M:Hook(_G[name]) end
end)
