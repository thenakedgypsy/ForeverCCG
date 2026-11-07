--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

-- =========================================================================
-- UNIT TOOLTIP CARD COUNTER
-- Hovering a creature that has a Forever: CCG card adds a line with the card-back
-- icon and how many copies you have unlocked, e.g. "Forever: CCG card: 2/4",
-- and shows the card itself docked to the left of the tooltip.
-- =========================================================================
local CARD_BACK_ICON = "Interface\\AddOns\\ForeverCCG\\Textures\\Cards\\card_back.png"
local MAX_COPIES = 4

-- Card shown beside the tooltip: same proportions and rules text as the Board / Deckbuilder preview
local PREVIEW_W, PREVIEW_H = 150, 212
local PREVIEW_RULES = {
    fontMax = 11,
    fontMin = 8,
    offsetX = 3,   -- pixels right
    offsetY = 3,   -- pixels down
}

-- 3D model in the tooltip card's art box (a ModelScene, so it can fade with the tooltip)
local SCENE_FOV = math.rad(30)
-- How much of the model shows, measured down from the top of its head (0.75 = top 75%)
local SCENE_VIEW_FRACTION = 0.75

local cardsByNpcId, cardsByName

-- Secret-value safety (same approach as BossTracker.lua)
local function IsSecret(v)
    return issecretvalue and issecretvalue(v) or false
end

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b = pcall(fn, ...)
    if ok then return a, b end
    return nil
end

local function ExtractNpcID(guid)
    if not guid or IsSecret(guid) or type(guid) ~= "string" then return nil end
    local idStr = guid:match("Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
        or guid:match("Vehicle%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
    if idStr then return tonumber(idStr) end
    if guid:find("^0x") then
        return tonumber(guid:sub(6, 10), 16)
    end
    return nil
end

-- Built on first use so every card file has loaded
local function BuildLookup()
    cardsByNpcId, cardsByName = {}, {}
    for _, card in pairs(TTS.Cards or {}) do
        if card.isBoss or card.isMob then
            if card.npcId then
                cardsByNpcId[card.npcId] = card
            end
            -- A card that drops from another NPC (Sneed's Shredder from Sneed) shows on that one too
            local src = card.dropsFrom
            local named = src and TTS.Cards[src.card]
            if src and src.npcId then cardsByNpcId[src.npcId] = card end
            if named and named.name then
                cardsByName[named.name:lower()] = card
                local shown = TTS:CardName(named)
                if shown then cardsByName[shown:lower()] = card end
            end
            if card.name then
                cardsByName[card.name:lower()] = card
                -- The client reports names in its own language; match the translated name too
                local shown = TTS:CardName(card)
                if shown then cardsByName[shown:lower()] = card end
            end
        end
    end
end

local function FindCardForUnit(unit)
    if not cardsByNpcId then BuildLookup() end

    local guid = SafeCall(UnitGUID, unit)
    local npcId = ExtractNpcID(guid)
    if npcId and cardsByNpcId[npcId] then
        return cardsByNpcId[npcId]
    end

    local name = SafeCall(UnitName, unit)
    if name and not IsSecret(name) and type(name) == "string" then
        return cardsByName[name:lower()]
    end
    return nil
end

local function GetUnlockedCopies(card)
    local raw = TTS_KilledBosses and TTS_KilledBosses[card.id]
    local kills = 0
    if raw == true then
        kills = MAX_COPIES
    elseif type(raw) == "number" then
        kills = raw
    end
    return math.min(MAX_COPIES, kills)
end

-- =========================================================================
-- MODEL SCENE (tooltip card only)
-- Uses the card's modelCam: zoom (0 = whole body, 1 = head), camScale
-- (camera distance multiplier), rotation (facing), x / y / z (model offset).
-- =========================================================================
local function CreateModelScene(f)
    if not (f.model and CreateFrame) then return nil end
    local ok, scene = pcall(CreateFrame, "ModelScene", nil, f)
    if not ok or not scene then return nil end

    scene:SetAllPoints(f.model)              -- same art box as the PlayerModel it replaces
    scene:SetFrameLevel(f:GetFrameLevel() + 1)
    scene:EnableMouse(false)

    if scene.SetCameraFieldOfView then scene:SetCameraFieldOfView(SCENE_FOV) end
    if scene.SetCameraNearClip then scene:SetCameraNearClip(0.01) end
    if scene.SetCameraFarClip then scene:SetCameraFarClip(200) end
    if scene.SetLightVisible then scene:SetLightVisible(true) end
    if scene.SetLightDirection then scene:SetLightDirection(-0.7, 0.3, -0.65) end
    if scene.SetLightAmbientColor then scene:SetLightAmbientColor(0.7, 0.7, 0.7) end
    if scene.SetLightDiffuseColor then scene:SetLightDiffuseColor(0.8, 0.8, 0.8) end

    scene.actor = scene:CreateActor()
    scene:Hide()
    return scene
end

-- Points the camera at the loaded model, using the card's modelCam.
-- Returns true once framed, false if the model hasn't loaded yet.
local function FrameModelScene(scene, card)
    local actor = scene.actor
    if not (actor and actor.GetActiveBoundingBox) then return true end   -- can't frame; don't keep trying
    if actor.IsLoaded and not actor:IsLoaded() then return false end
    -- Newer clients return two vectors (min, max); older ones six numbers
    local minX, minY, minZ, maxX, maxY, maxZ = actor:GetActiveBoundingBox()
    if type(minX) == "table" then
        local lo, hi = minX, minY
        minX, minY, minZ = lo.x, lo.y, lo.z
        maxX, maxY, maxZ = hi and hi.x, hi and hi.y, hi and hi.z
    end
    if not (minZ and maxZ) or maxZ <= minZ then return false end

    local cam = card.modelCam or {}
    local height = maxZ - minZ

    -- Fill the art box with the top SCENE_VIEW_FRACTION of the model; camScale still
    -- pulls the camera back (above 1) or in (below 1), as on the board
    local viewH = height * SCENE_VIEW_FRACTION
    local targetZ = maxZ - viewH / 2

    local dist = (viewH / 2) / math.tan(SCENE_FOV / 2) * (cam.camScale or 1.0)

    -- Measure that distance from the front of the model, not its centre: long creatures
    -- (crocolisks, wolves) face the camera, so their snout sticks out well past the centre.
    -- Furthest horizontal reach of the box, so it holds whichever way the model is turned.
    local front = math.max(math.abs(minX or 0), math.abs(maxX or 0), math.abs(minY or 0), math.abs(maxY or 0))

    if scene.SetCameraPosition then scene:SetCameraPosition(front + dist, 0, targetZ) end
    if scene.SetCameraOrientationByYawPitchRoll then scene:SetCameraOrientationByYawPitchRoll(math.pi, 0, 0) end
    return true
end

local function ShowModelScene(scene, card)
    local actor = scene.actor
    if not actor then return end
    local cam = card.modelCam or {}

    if actor.SetYaw then actor:SetYaw(cam.rotation or 0.15) end
    if actor.SetPosition then actor:SetPosition(cam.x or 0, cam.y or 0, cam.z or 0) end
    if actor.SetAlpha then actor:SetAlpha(scene:GetParent():GetEffectiveAlpha()) end

    scene.card = card
    actor:SetModelByCreatureDisplayID(card.displayId)
    -- Framing needs the model's size, which is only known once it has loaded:
    -- done now if it's cached, otherwise by the card's OnUpdate once it loads
    scene.needsFraming = not FrameModelScene(scene, card)
    scene:Show()
end

-- =========================================================================
-- CARD FRAMES
-- Built on first use with Board.lua's card frame (loaded by then). Three use
-- them: the card beside the tooltip, the detached card window, and the size
-- preview beside the Options window.
-- =========================================================================
TTS.MobTooltip = TTS.MobTooltip or {}
local M = TTS.MobTooltip

local function Opt(key)
    return TTS.Options and TTS.Options.Get and TTS.Options:Get(key)
end

local function Detached()
    return Opt("mobCardDetached") == true
end

local mobCard      -- beside the tooltip
local lastCard     -- the last creature card hovered (the size preview shows it)

local function NewCardFrame(parent)
    if not TTS.CreateCardFrame then return nil end
    local f = TTS.CreateCardFrame(parent, PREVIEW_W, PREVIEW_H)
    f:EnableMouse(false)
    f:SetScript("OnEnter", nil)
    f:SetScript("OnLeave", nil)

    f.scene = CreateModelScene(f)

    -- Model actors ignore their parent's alpha, so copy the card's (e.g. the tooltip's fade)
    -- onto the actor each frame
    f:SetScript("OnUpdate", function(self)
        local scene = self.scene
        if not (scene and scene:IsShown() and scene.actor) then return end
        if scene.needsFraming and scene.card then
            scene.needsFraming = not FrameModelScene(scene, scene.card)
        end
        if scene.actor.SetAlpha then
            scene.actor:SetAlpha(self:GetEffectiveAlpha())
        end
    end)
    f:Hide()
    return f
end

-- Paints the card onto f (shown by the caller, which then lays out its rules text)
local function FillCard(f, card)
    f.card = card
    if TTS.SetupCardVisual then TTS.SetupCardVisual(f, card, TTS:HasFoil(card.id)) end
    if TTS.ApplyFrameTexture then TTS.ApplyFrameTexture(f.border, card) end
    f.border:SetVertexColor(1, 1, 1)
    if TTS.TintArt then TTS.TintArt(f.art, card) else f.art:SetVertexColor(1, 1, 1) end
    f.title:SetText(TTS:CardName(card) or "")

    -- 3D model goes in the ModelScene instead of the card's PlayerModel
    if card.displayId and f.scene then
        f.model:ClearModel()
        f.model:Hide()
        f.art:Hide()
        ShowModelScene(f.scene, card)
    elseif f.scene then
        f.scene:Hide()
    end

    if card.cost and card.cost ~= "" then
        f.cost:SetText(TTS:FormatCost(card.cost, 18))
        f.cost:Show()
    else
        f.cost:Hide()
    end

    TTS.ShowPrintedStats(f, card)
end

local function UpdateRules(f)
    if TTS.UpdateCardRules then TTS.UpdateCardRules(f, PREVIEW_RULES) end
end

-- =========================================================================
-- CARD BESIDE THE TOOLTIP
-- Sized to the tooltip's height, or to the Options' card size when manual
-- scaling is on (mobCardManualScale / mobCardScale).
-- =========================================================================
local function EnsureMobCard()
    if mobCard then return mobCard end
    -- Parented to the tooltip so it fades out (and hides) along with it
    local f = NewCardFrame(GameTooltip)
    if not f then return nil end
    f:SetFrameStrata("TOOLTIP")
    f:SetClampedToScreen(true)
    mobCard = f
    return f
end

local function HideMobCard()
    if mobCard then mobCard:Hide() end
end

-- The card size picked in Options (1 = 150 x 212 at the UI's scale)
local function ManualScale()
    return tonumber(Opt("mobCardScale")) or 1
end

-- Scales the card so its height matches the tooltip's, top edges level (or to the
-- manual size, top edges still level)
local function FitMobCardToTooltip(tooltip)
    local f = mobCard
    if not f then return end
    local scale
    if Opt("mobCardManualScale") then
        -- The card is a child of the tooltip, so undo the tooltip's own scale
        local tipScale = tooltip:GetEffectiveScale()
        if not tipScale or tipScale <= 0 then return end
        scale = ManualScale() * UIParent:GetEffectiveScale() / tipScale
    else
        local h = tooltip:GetHeight()
        if not h or h <= 0 then return end
        -- Both heights are in the tooltip's own units
        scale = h / PREVIEW_H
    end
    f:SetScale(scale)
    f:ClearAllPoints()
    f:SetPoint("TOPRIGHT", tooltip, "TOPLEFT", -8 / scale, 0)
end

local function ShowMobCard(tooltip, card)
    local f = EnsureMobCard()
    if not f then return end
    FitMobCardToTooltip(tooltip)
    FillCard(f, card)
    f:Show()
    UpdateRules(f)
end

-- =========================================================================
-- DETACHED CARD WINDOW (mobCardDetached)
-- The hovered creature's card in a window of its own: it shows the last card
-- hovered, and can be moved (drag it), scaled (the grip, bottom
-- right) and minimised to its title bar. Place, scale and minimised state are
-- saved in mobCardWindow. Like the tooltip's card it goes once the tooltip
-- does, but WIN_HOLD seconds later (longer while the cursor is on it), fading
-- out over WIN_FADE.
-- =========================================================================
local WIN_PAD, WIN_TITLE_H = 8, 24
-- The card's name and cost sit above its frame (Board.lua's card), so leave them room
-- between the title bar and the card
local WIN_HEADROOM = 38
local WIN_W = PREVIEW_W + WIN_PAD * 2
local WIN_H = WIN_TITLE_H + WIN_HEADROOM + PREVIEW_H + WIN_PAD
local WIN_HOLD, WIN_FADE = 3, 0.5
local WIN_MIN_SCALE, WIN_MAX_SCALE = 0.4, 2.5
local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil

local win

local function WinDB()
    local db = TTS.Options and TTS.Options.GetDB and TTS.Options:GetDB()
    if not db then return {} end
    if type(db.mobCardWindow) ~= "table" then db.mobCardWindow = {} end
    return db.mobCardWindow
end

-- Top-left corner at x, y (UIParent units), or the default spot
local function PlaceWindow(x, y)
    local s = win:GetScale()
    win:ClearAllPoints()
    if x and y then
        win:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / s, y / s)
    else
        win:SetPoint("RIGHT", UIParent, "RIGHT", -260 / s, 0)
    end
end

local function SaveWindow()
    local db = WinDB()
    local s = win:GetScale()
    local left, top = win:GetLeft(), win:GetTop()
    if left and top then db.x, db.y = left * s, top * s end
    db.scale = s
end

-- Rescales the window about its top-left corner
local function SetWindowScale(s)
    s = math.max(WIN_MIN_SCALE, math.min(WIN_MAX_SCALE, s))
    local old = win:GetScale()
    local left, top = win:GetLeft(), win:GetTop()
    win:SetScale(s)
    if left and top then PlaceWindow(left * old, top * old) end
end

local function SetMinimised(minimised)
    WinDB().minimised = minimised and true or false
    win:SetHeight(minimised and WIN_TITLE_H + 4 or WIN_H)
    win.card:SetShown(not minimised and win.card.card ~= nil)
    win.grip:SetShown(not minimised)
    win.minBtn:SetText(minimised and "+" or "-")
    if not minimised and win.card.card then UpdateRules(win.card) end
end

local function EnsureWindow()
    if win then return win end
    if not TTS.CreateCardFrame then return nil end
    local L = TTS.L

    win = CreateFrame("Frame", "TTS_MobCardWindow", UIParent, backdropTemplate)
    win:SetSize(WIN_W, WIN_H)
    win:SetFrameStrata("MEDIUM")
    win:SetToplevel(true)
    win:SetClampedToScreen(true)
    win:SetMovable(true)
    win:EnableMouse(true)
    win:RegisterForDrag("LeftButton")
    win:SetScript("OnDragStart", function(self)
        self.moving = true
        self:StartMoving()
    end)
    win:SetScript("OnDragStop", function(self)
        self.moving = false
        self:StopMovingOrSizing()
        SaveWindow()
    end)

    -- Fade-out once the tooltip has gone (fadeAt: when it starts); the cursor on the
    -- window, or moving or scaling it, holds it up
    win:SetScript("OnUpdate", function(self)
        if not self.fadeAt then return end
        local now = GetTime()
        if self.moving or self.sizing or self:IsMouseOver() then
            self.fadeAt = now + WIN_HOLD
        end
        local t = now - self.fadeAt
        if t <= 0 then
            self:SetAlpha(1)
        elseif t >= WIN_FADE then
            self.fadeAt = nil
            self:Hide()
            self:SetAlpha(1)
        else
            self:SetAlpha(1 - t / WIN_FADE)
        end
    end)
    if win.SetBackdrop then
        win:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        win:SetBackdropColor(0.04, 0.04, 0.04, 0.85)
        win:SetBackdropBorderColor(0.60, 0.56, 0.48, 1)
    end
    win:Hide()

    win.title = win:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    win.title:SetPoint("TOPLEFT", 9, -7)
    win.title:SetPoint("RIGHT", win, "RIGHT", -28, 0)
    win.title:SetJustifyH("LEFT")
    win.title:SetWordWrap(false)
    win.title:SetText("Forever: CCG")

    local minBtn = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
    minBtn:SetSize(20, 18)
    minBtn:SetPoint("TOPRIGHT", -4, -3)
    minBtn:SetScript("OnClick", function() SetMinimised(not WinDB().minimised) end)
    minBtn:SetScript("OnEnter", function(self)
        if TTS.Tooltip then
            TTS.Tooltip:ShowText(self, "ANCHOR_TOP", L(WinDB().minimised and "board.restore" or "board.minimize"))
        end
    end)
    minBtn:SetScript("OnLeave", function(self) if TTS.Tooltip then TTS.Tooltip:Hide(self) end end)
    win.minBtn = minBtn

    win.card = NewCardFrame(win)
    win.card:SetPoint("TOPLEFT", win, "TOPLEFT", WIN_PAD, -(WIN_TITLE_H + WIN_HEADROOM))

    -- Scale grip: the window's bottom-right corner follows the cursor
    local grip = CreateFrame("Button", nil, win)
    grip:SetSize(14, 14)
    grip:SetPoint("BOTTOMRIGHT", -2, 2)
    grip:SetFrameLevel(win.card:GetFrameLevel() + 10)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    grip.ttsSilent = true
    grip:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then win.sizing = true end
    end)
    local function StopSizing()
        if not win.sizing then return end
        win.sizing = false
        SaveWindow()
        UpdateRules(win.card)
    end
    grip:SetScript("OnMouseUp", StopSizing)
    grip:SetScript("OnHide", StopSizing)
    grip:SetScript("OnUpdate", function()
        if not win.sizing then return end
        local s = win:GetScale()
        local left, top = win:GetLeft(), win:GetTop()
        if not (left and top) then return end
        local ui = UIParent:GetEffectiveScale()
        local cx, cy = GetCursorPosition()
        cx, cy = cx / ui, cy / ui
        -- Window corner in UIParent units = left*s + WIN_W*new; take the larger stretch
        local sx = (cx - left * s) / WIN_W
        local sy = (top * s - cy) / WIN_H
        local want = math.max(sx, sy)
        if math.abs(want - s) > 0.005 then SetWindowScale(want) end
    end)
    win.grip = grip

    local db = WinDB()
    win:SetScale(math.max(WIN_MIN_SCALE, math.min(WIN_MAX_SCALE, tonumber(db.scale) or 1)))
    PlaceWindow(db.x, db.y)
    SetMinimised(db.minimised)
    return win
end

local function ShowInWindow(card)
    local w = EnsureWindow()
    if not w then return end
    w.title:SetText(TTS:CardName(card) or "Forever: CCG")
    local minimised = WinDB().minimised
    if w.card.card ~= card then
        FillCard(w.card, card)
        w.card:SetShown(not minimised)
        if not minimised then UpdateRules(w.card) end
    end
    w.fadeAt = nil
    w:SetAlpha(1)
    w:Show()
end

local function HideWindow()
    if win then
        win.fadeAt = nil
        win:SetAlpha(1)
        win:Hide()
    end
end

-- The tooltip's gone (or moved on to something without a card): the window follows later
local function FadeWindowLater()
    if win and win:IsShown() and not win.fadeAt then
        win.fadeAt = GetTime() + WIN_HOLD
    end
end

-- =========================================================================
-- SIZE PREVIEW (Options)
-- The manual card size shown beside the Options window while it's adjusted;
-- it goes 2 seconds after the last call to ShowScalePreview.
-- =========================================================================
local PREVIEW_LINGER = 2
local preview, previewDriver
local SAMPLE_CARD = "ELW12"   -- Hogger, until a creature card has been hovered

local function EnsurePreview()
    if preview then return preview end
    preview = NewCardFrame(UIParent)
    if not preview then return nil end
    preview:SetFrameStrata("FULLSCREEN_DIALOG")
    preview:SetClampedToScreen(true)
    previewDriver = CreateFrame("Frame", nil, preview)
    previewDriver:SetScript("OnUpdate", function()
        if preview.hideAt and GetTime() >= preview.hideAt then preview:Hide() end
    end)
    return preview
end

local function SampleCard()
    if lastCard then return lastCard end
    local cards = TTS.Cards or {}
    if cards[SAMPLE_CARD] then return cards[SAMPLE_CARD] end
    for _, card in pairs(cards) do
        if card.isMob and card.displayId then return card end
    end
end

function M:ShowScalePreview(anchor)
    local p = EnsurePreview()
    local card = SampleCard()
    if not (p and card) then return end
    if p.card ~= card then FillCard(p, card) end
    local s = ManualScale()
    local resized = math.abs(p:GetScale() - s) > 0.001
    p:SetScale(s)
    p:ClearAllPoints()
    if anchor then
        p:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 8 / s, 0)
    else
        p:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
    p.hideAt = GetTime() + PREVIEW_LINGER
    if not p:IsShown() or resized then
        p:Show()
        UpdateRules(p)
    end
end

function M:HideScalePreview()
    if preview then preview:Hide() end
end

-- Options changed: the card follows its new mode at once
function M:OptionsChanged()
    if Opt("mobCardPreview") == false or not Detached() then HideWindow() end
    if Detached() or Opt("mobCardPreview") == false then
        HideMobCard()
    elseif mobCard and mobCard:IsShown() then
        FitMobCardToTooltip(GameTooltip)
        UpdateRules(mobCard)
    end
end

-- =========================================================================
-- TOOLTIP HOOKS
-- =========================================================================
local function AddCardLine(tooltip)
    if tooltip ~= GameTooltip then return end

    local _, unit = SafeCall(tooltip.GetUnit, tooltip)
    if not unit or IsSecret(unit) then return end

    local isPlayer = SafeCall(UnitIsPlayer, unit)
    if isPlayer == nil or IsSecret(isPlayer) or isPlayer then return end

    local card = FindCardForUnit(unit)
    if not card then return end

    local copies = GetUnlockedCopies(card)
    local color = (copies >= MAX_COPIES) and "|cFF00FF00" or (copies == 0 and "|cFF888888" or "|cFFFFFFFF")

    tooltip:AddLine(string.format("|T%s:20:10|t |cFFFFD200%s|r %s%d/%d|r",
        CARD_BACK_ICON, TTS.L("mobtip.card"), color, copies, MAX_COPIES))
    -- Your foil of it, in the card's colour (as on the card)
    if TTS:HasFoil(card.id) then
        local rgb = TTS.FoilColors and TTS.FoilColors(card)[1] or { 1, 0.82, 0 }
        tooltip:AddLine(TTS.L("link.ownFoil"), rgb[1], rgb[2], rgb[3])
    end
    tooltip:Show()

    lastCard = card
    if Opt("mobCardPreview") == false then return end
    if Detached() then
        ShowInWindow(card)
    else
        ShowMobCard(tooltip, card)
    end
end

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Unit then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, AddCardLine)
else
    GameTooltip:HookScript("OnTooltipSetUnit", AddCardLine)
end

-- The card goes away with the tooltip, or when the tooltip switches to something else
-- (the detached window a few seconds later; a creature card hovered again keeps it up)
local function TooltipCardGone()
    HideMobCard()
    FadeWindowLater()
end
GameTooltip:HookScript("OnHide", TooltipCardGone)
GameTooltip:HookScript("OnTooltipCleared", TooltipCardGone)

-- Lines added after ours change the tooltip's height, so keep the card matched to it
GameTooltip:HookScript("OnSizeChanged", function(self)
    if mobCard and mobCard:IsShown() then
        FitMobCardToTooltip(self)
        UpdateRules(mobCard)
    end
end)
