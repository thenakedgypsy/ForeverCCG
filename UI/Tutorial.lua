--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
local L = TTS.L
local Loc = TTS.Locale

-- =========================================================================
-- TUTORIAL GAME
-- A short scripted game against the dummy AI (TTS.SoloEncounters.TUTORIAL: both decks
-- in a fixed order). A coach panel on the board says what to do next (tut.<step>) and
-- moves on as soon as the player has done it, checked every time the board refreshes.
-- Started from the Play Tutorial button in Rules & Guide or /tragic tutorial.
-- =========================================================================
local E = TTS.Engine

local function OnField(isRemote, id)
    for _, p in ipairs((isRemote and E.remoteState or E.localState).field) do
        if p.id == id then return true end
    end
    return false
end

local function Prayers()
    local n = 0
    for _, p in ipairs(E.localState.field) do
        local c = TTS.Cards[p.id]
        if c and c.type == "Land" then n = n + 1 end
    end
    return n
end

local function Attacking()
    for _, p in ipairs(E.localState.field) do
        if p.isAttacking then return true end
    end
    return false
end

local function Defending() return E.phase == "COMBAT_BLOCK" and E.blockingState and E.blockingState.isRemoteAttacking end

-- The steps in order: tut.<key>, done once the player has done what it asks. allow is
-- all the player may do meanwhile (anything else is refused, see the guards below):
--   play = hand cards it may play, tap = its own battlefield cards it may click,
--   opp = the opponent's cards it may click, target = what a spell may target,
--   next = the phase button, endTurn = End Turn
-- (the Auto-pay checkbox is allowed from the autoPay step on, see the end of the file)
local T = { active = false, step = 1, autoPay = false }
TTS.Tutorial = T

local STEPS = {
    { key = "playPrayer",   done = function() return Prayers() >= 1 end,
      allow = { play = { W01 = true } } },
    { key = "tapPrayer",    done = function() return (E.localState.mana.W or 0) >= 1 or OnField(false, "DES01") end,
      allow = { tap = { W01 = true } } },
    { key = "castAugur",    done = function() return OnField(false, "DES01") end,
      allow = { play = { DES01 = true } } },
    { key = "endTurn",      done = function() return not E.isMyTurn end,
      allow = { endTurn = true } },
    { key = "theirTurn",    done = function() return Defending() end, allow = {} },
    { key = "block",        done = function() return Defending() and next(E.blockingState.blocks) ~= nil end,
      allow = { tap = { DES01 = true }, opp = { DUN01 = true } } },
    { key = "confirmBlock", done = function() return not E.blockingState end,
      allow = { next = true, tap = { DES01 = true }, opp = { DUN01 = true } } },
    { key = "blocked",      done = function() return E.isMyTurn and E.phase == "MAIN1" end, allow = {} },
    { key = "playPrayer2",  done = function() return Prayers() >= 2 end,
      allow = { play = { W01 = true } } },
    { key = "autoPay",      done = function() return T.autoPay end, allow = {} },
    { key = "castOwlbeast", done = function() return OnField(false, "HIN04") end,
      allow = { play = { HIN04 = true }, tap = { W01 = true } } },
    { key = "toCombat",     done = function() return E.phase == "COMBAT_ATTACK" end,
      allow = { next = true } },
    { key = "attack",       done = function() return Attacking() end,
      allow = { tap = { DES01 = true } } },
    { key = "declare",      done = function() return E.phase == "MAIN2" end,
      allow = { next = true } },
    { key = "endTurn2",     done = function() return not E.isMyTurn end,
      allow = { endTurn = true, next = true } },
    { key = "theirTurn2",   done = function() return E.isMyTurn and E.phase == "MAIN1" end, allow = {} },
    { key = "playFire",     done = function() return Prayers() >= 3 end,
      allow = { play = { R01 = true } } },
    { key = "fireBlast",    done = function() return not OnField(true, "FER03") end,
      allow = { play = { MAG02 = true }, tap = { R01 = true }, target = { FER03 = true } } },
    { key = "finish",       done = function() return false end,   -- the win ends the tutorial
      -- attack by dragging: To Combat is refused, Declare Blocks isn't
      allow = { next = function() return E.phase ~= "MAIN1" or E.dragAttack end,
                tap = { DES01 = true, HIN04 = true } } },
}

-- =========================================================================
-- COACH PANEL (middle of the screen; draggable)
-- =========================================================================
local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local C = CreateFrame("Frame", "TTS_TutorialCoach", UIParent, backdropTemplate)
T.frame = C
C:SetSize(440, 110)
C:SetFrameStrata("DIALOG")
C:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
    tile = true, tileSize = 32, edgeSize = 24,
    insets = { left = 6, right = 6, top = 6, bottom = 6 }
})
C:EnableMouse(true)
C:SetMovable(true)
C:RegisterForDrag("LeftButton")
C:SetScript("OnDragStart", C.StartMoving)
C:SetScript("OnDragStop", C.StopMovingOrSizing)
C:Hide()

local header = C:CreateFontString(nil, "OVERLAY", "GameFontNormal")
header:SetPoint("TOPLEFT", 16, -14)

local text = C:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
text:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -6)
text:SetPoint("RIGHT", C, "RIGHT", -16, 0)
text:SetJustifyH("LEFT")
text:SetJustifyV("TOP")
text:SetSpacing(2)

local function Paint(key)
    header:SetText(L("tut.header", math.min(T.step, #STEPS), #STEPS))
    local body = L("tut." .. key)
    text:SetText(TTS.FormatSymbols and TTS:FormatSymbols(body, 16) or body)
    C:SetHeight(math.max(72, text:GetStringHeight() + 48))
    if not C:IsShown() then
        C:ClearAllPoints()
        C:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        C:Show()
    end
end

-- Moves on past every step already done, then shows the current one
function T:Check()
    if not self.active then return end
    while self.step <= #STEPS and STEPS[self.step].done() do self.step = self.step + 1 end
    Paint(STEPS[math.min(self.step, #STEPS)].key)
end

function T:Stop()
    self.active = false
    self:ShowAutoPay()
    C:Hide()
end

-- AUTO-PAY: the tutorial starts with it off, so the first mana is tapped by hand, and has
-- the player tick it at the autoPay step. Only the tutorial's own flag changes: the saved
-- option is left as it was, and the checkbox shows it again once the tutorial is over.
function T:ShowAutoPay()
    if TTS.ApplyCardControls then TTS.ApplyCardControls() end   -- card controls too (below)
    local box = TTS.BoardFrame and TTS.BoardFrame.autoPayCheck
    if not box then return end
    if self.active then
        box:SetChecked(self.autoPay)
    else
        box:SetChecked(not TTS.Options or TTS.Options:Get("autoPayMana") ~= false)
    end
end

-- Card controls: the tutorial teaches both clicking and dragging, whatever the option says
local cardControls = TTS.CardControls
TTS.CardControls = function(...)
    if T.active then return "both" end
    return cardControls(...)
end

local autoPayEnabled = E.AutoPayEnabled
E.AutoPayEnabled = function(self, ...)
    if T.active and self.inMatch then return T.autoPay end
    return autoPayEnabled(self, ...)
end

-- Starts the tutorial game (not while another game is on)
function TTS:StartTutorial()
    if E.inMatch then
        E:Log(L("tut.inMatch"), "ERROR")
        return
    end
    local enc = TTS.SoloEncounters and TTS.SoloEncounters.TUTORIAL
    if not enc then return end
    if TTS.RulesFrame then TTS.RulesFrame:Hide() end
    if TTS.QuickStartFrame then TTS.QuickStartFrame:Hide() end
    T.active, T.step, T.autoPay = true, 1, false
    T.savedAutoPay = not TTS.Options or TTS.Options:Get("autoPayMana") ~= false
    T:ShowAutoPay()
    E:StartMatch(enc.opponent, true, true, enc)
    if not E.inMatch then T:Stop() return end   -- e.g. the Deckbuilder was open
    T:Check()
end

-- =========================================================================
-- GUARDS: off-script actions are refused while the tutorial runs. Calls made from
-- inside an allowed action (auto-pay tapping prayers, a click that resolves a
-- target...) pass straight through.
-- =========================================================================
local depth = 0

-- Says no: a red line mid-screen, and the coach flashes its instruction in red
local function Refuse()
    if UIErrorsFrame then UIErrorsFrame:AddMessage(L("tut.no"), 1, 0.2, 0.2) end
    if TTS.Sound and TTS.Sound.PlayUI then pcall(TTS.Sound.PlayUI, TTS.Sound, "error") end
    header:SetText("|cFFFF3333" .. L("tut.no") .. "|r")
    C:SetBackdropBorderColor(1, 0.2, 0.2)
    C_Timer.After(1.5, function()
        C:SetBackdropBorderColor(1, 1, 1)
        if T.active then header:SetText(L("tut.header", math.min(T.step, #STEPS), #STEPS)) end
    end)
end

-- Whether the current step lets the player do this: kind = a key of allow, id = the card
local function Allowed(kind, id)
    local step = STEPS[math.min(T.step, #STEPS)]
    local a = step.allow and step.allow[kind]
    if type(a) == "table" then return id ~= nil and a[id] == true end
    if type(a) == "function" then return a(id) and true or false end
    return a == true
end

-- Wraps E[name]: what(args...) gives the kind and card of the action
local function Guard(name, what)
    local orig = E[name]
    E[name] = function(self, ...)
        if T.active and self.inMatch and depth == 0 then
            local kind, id = what(self, ...)
            if kind and not Allowed(kind, id) then
                Refuse()
                return
            end
        end
        depth = depth + 1
        local ok, a, b, c = pcall(orig, self, ...)
        depth = depth - 1
        if not ok then error(a, 0) end
        return a, b, c
    end
end

local function FieldId(isRemote, idx)
    local p = idx and (isRemote and E.remoteState.field or E.localState.field)[idx]
    return p and p.id
end

Guard("PlayCard", function(self, handIndex) return "play", self.localState.hand[handIndex] end)
Guard("TapCard", function(self, fieldIndex) return "tap", FieldId(false, fieldIndex) end)
Guard("ClickOpponentCard", function(self, fieldIndex)
    -- With a spell waiting for its target, the click is aiming the spell
    if self.targeting then return "target", FieldId(true, fieldIndex) end
    return "opp", FieldId(true, fieldIndex)
end)
Guard("ResolveTarget", function(self, kind, isRemote, fieldIndex)
    if kind == "CREATURE" and isRemote then return "target", FieldId(true, fieldIndex) end
    return "target", nil   -- the player, or one of your own creatures: not in this tutorial
end)
Guard("NextPhase", function() return "next" end)
Guard("EndTurn", function() return "endTurn" end)
Guard("RequestUndo", function() return "undo" end)
Guard("Mulligan", function() return "mulligan" end)

-- Every board refresh: has the player done the current step?
local refresh = E.RefreshUI
E.RefreshUI = function(self, ...)
    refresh(self, ...)
    if T.active and self.inMatch then T:Check() end
end

-- The game is over: a last word from the coach
local endMatch = E.EndMatch
E.EndMatch = function(self, outcome, ...)
    local wasTutorial = T.active and self.inMatch and self.encounter and self.encounter.isTutorial
    endMatch(self, outcome, ...)
    if wasTutorial then
        T.step = #STEPS
        Paint(outcome == "won" and "won" or "lost")
        T.active = false
        T:ShowAutoPay()
    end
end

-- A Play Tutorial button in the Rules & Guide header
if TTS.RulesFrame then
    local b = CreateFrame("Button", nil, TTS.RulesFrame, "UIPanelButtonTemplate")
    b:SetSize(110, 20)
    b:SetPoint("TOPRIGHT", TTS.RulesFrame, "TOPRIGHT", -34, -15)
    b:SetNormalFontObject("GameFontNormalSmall")
    b:SetHighlightFontObject("GameFontHighlightSmall")
    Loc:Bind(b, "tut.play")
    b:SetScript("OnClick", function() TTS:StartTutorial() end)
end

-- The coach goes with the board (minimised, or closed after the game) and comes back with it
if TTS.BoardFrame then
    TTS.BoardFrame:HookScript("OnHide", function() C:Hide() end)
    TTS.BoardFrame:HookScript("OnShow", function()
        if T.active then T:ShowAutoPay() T:Check() end
    end)
end

-- The Auto-pay checkbox: during the tutorial it sets the tutorial's flag instead of the
-- saved option, and only from the autoPay step on
local box = TTS.BoardFrame and TTS.BoardFrame.autoPayCheck
if box then
    local autoPayStep
    for i, s in ipairs(STEPS) do if s.key == "autoPay" then autoPayStep = i end end
    box:HookScript("OnClick", function(self)
        if not (T.active and E.inMatch) then return end
        local ticked = self:GetChecked() and true or false
        TTS.Options:Set("autoPayMana", T.savedAutoPay)   -- undo what the checkbox saved
        if T.step < autoPayStep then
            self:SetChecked(T.autoPay)
            Refuse()
            return
        end
        T.autoPay = ticked
        E:RefreshUI()
    end)
end
