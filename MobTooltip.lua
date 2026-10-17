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
    if actor.SetAlpha then actor:SetAlpha(GameTooltip:GetEffectiveAlpha()) end

    scene.card = card
    actor:SetModelByCreatureDisplayID(card.displayId)
    -- Framing needs the model's size, which is only known once it has loaded:
    -- done now if it's cached, otherwise by the card's OnUpdate once it loads
    scene.needsFraming = not FrameModelScene(scene, card)
    scene:Show()
end

-- =========================================================================
-- CARD BESIDE THE TOOLTIP
-- Built on first use with Board.lua's card frame (loaded by then).
-- =========================================================================
local mobCard

local function EnsureMobCard()
    if mobCard then return mobCard end
    if not TTS.CreateCardFrame then return nil end
    -- Parented to the tooltip so it fades out (and hides) along with it
    local f = TTS.CreateCardFrame(GameTooltip, PREVIEW_W, PREVIEW_H)
    f:SetFrameStrata("TOOLTIP")
    f:SetClampedToScreen(true)
    f:EnableMouse(false)
    f:SetScript("OnEnter", nil)
    f:SetScript("OnLeave", nil)

    f.scene = CreateModelScene(f)

    -- Model actors ignore their parent's alpha, so copy the tooltip's fade onto the actor each frame
    f:SetScript("OnUpdate", function(self)
        local scene = self.scene
        if not (scene and scene:IsShown() and scene.actor) then return end
        if scene.needsFraming and scene.card then
            scene.needsFraming = not FrameModelScene(scene, scene.card)
        end
        if scene.actor.SetAlpha then
            scene.actor:SetAlpha(GameTooltip:GetEffectiveAlpha())
        end
    end)

    mobCard = f
    return f
end

local function HideMobCard()
    if mobCard then mobCard:Hide() end
end

-- Scales the card so its height matches the tooltip's, top edges level
local function FitMobCardToTooltip(tooltip)
    local f = mobCard
    if not f then return end
    local h = tooltip:GetHeight()
    if not h or h <= 0 then return end
    -- The card is a child of the tooltip, so both heights are in the tooltip's own units
    local scale = h / PREVIEW_H
    f:SetScale(scale)
    f:ClearAllPoints()
    f:SetPoint("TOPRIGHT", tooltip, "TOPLEFT", -8 / scale, 0)
end

local function ShowMobCard(tooltip, card)
    local f = EnsureMobCard()
    if not f then return end

    FitMobCardToTooltip(tooltip)

    if TTS.SetupCardVisual then TTS.SetupCardVisual(f, card) end
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
        f.cost:SetText(TTS:FormatSymbols(card.cost, 18))
        f.cost:Show()
    else
        f.cost:Hide()
    end

    TTS.ShowPrintedStats(f, card)

    f:Show()
    if TTS.UpdateCardRules then TTS.UpdateCardRules(f, PREVIEW_RULES) end
end

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
    tooltip:Show()

    ShowMobCard(tooltip, card)
end

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Unit then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, AddCardLine)
else
    GameTooltip:HookScript("OnTooltipSetUnit", AddCardLine)
end

-- The card goes away with the tooltip, or when the tooltip switches to something else
GameTooltip:HookScript("OnHide", HideMobCard)
GameTooltip:HookScript("OnTooltipCleared", HideMobCard)

-- Lines added after ours change the tooltip's height, so keep the card matched to it
GameTooltip:HookScript("OnSizeChanged", function(self)
    if mobCard and mobCard:IsShown() then
        FitMobCardToTooltip(self)
        if TTS.UpdateCardRules then TTS.UpdateCardRules(mobCard, PREVIEW_RULES) end
    end
end)