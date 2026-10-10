--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

-- =========================================================================
-- TEXTURE PATH CONFIGURATION & MANA ICONS
-- =========================================================================
local TEXTURE_ROOT    = "Interface\\AddOns\\ForeverCCG\\Textures\\"
local CARD_FRAME_DEF  = TEXTURE_ROOT .. "Cards\\card_frame.png"
local CARD_BACK_TEX   = TEXTURE_ROOT .. "Cards\\card_back.png"
local SYMBOL_PATH     = TEXTURE_ROOT .. "Symbols\\"

local CARD_FRAMES = {
    W       = TEXTURE_ROOT .. "Cards\\card_frame_holy.png",
    U       = TEXTURE_ROOT .. "Cards\\card_frame_arcane.png",
    B       = TEXTURE_ROOT .. "Cards\\card_frame_shadow.png",
    R       = TEXTURE_ROOT .. "Cards\\card_frame_fire.png",
    G       = TEXTURE_ROOT .. "Cards\\card_frame_nature.png",
    HOLY    = TEXTURE_ROOT .. "Cards\\card_frame_holy.png",
    ARCANE  = TEXTURE_ROOT .. "Cards\\card_frame_arcane.png",
    SHADOW  = TEXTURE_ROOT .. "Cards\\card_frame_shadow.png",
    FIRE    = TEXTURE_ROOT .. "Cards\\card_frame_fire.png",
    NATURE  = TEXTURE_ROOT .. "Cards\\card_frame_nature.png",
}

-- Native Blizzard spell icons matching each sphere
TTS.MANA_ICONS = {
    W = "Interface\\Icons\\Spell_Holy_Aspiration",     -- White (Holy)
    U = "Interface\\Icons\\Spell_Frost_FrostArmor",     -- Blue  (Arcane)
    B = "Interface\\Icons\\Spell_Shadow_AntiShadow",    -- Black (Shadow)
    R = "Interface\\Icons\\Spell_Fire_Incinerate",      -- Red   (Fire)
    G = "Interface\\Icons\\Spell_Nature_HealingTouch",  -- Green (Nature)
}

local ART_BOX = {
    left    = 0.06,
    right   = 0.06,
    top     = 0.07,
    bottom  = 0.45,
    shiftUp = 0.01,
}

local FALLBACK_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border"
local FALLBACK_BACK   = "Interface\\Buttons\\WHITE8X8"

-- Bulletproof Symbol Formatter
function TTS:FormatSymbols(str, size)
    if not str or str == "" then return "" end
    local s = size or 16

    local formatted = str:gsub("{(%w+)}", function(key)
        local upperKey = string.upper(key)

        -- Tap Symbol
        if upperKey == "T" or upperKey == "TAP" then
            return "|cFFFFD200(T)|r"
        end

        -- Generic / Numeric / X
        if tonumber(key) or upperKey == "X" then
            return string.format("|cFF8E939B(|r|cFFFFFFFF%s|r|cFF8E939B)|r", upperKey)
        end

        -- Colored Mana Spheres
        local icon = TTS.MANA_ICONS and TTS.MANA_ICONS[upperKey]
        if icon then
            return string.format("|T%s:%d:%d:0:0|t", icon, s, s)
        end

        return string.format("(%s)", upperKey)
    end)
    return formatted
end

-- Creature type, faction and zone as one tooltip line, e.g. "Humanoid  •  Defias  •  The Deadmines"
function TTS:GetCardTagLine(card)
    if not card or card.type ~= "Creature" then return nil end
    local parts = {}
    if card.creatureType then table.insert(parts, card.creatureType) end
    if card.faction then table.insert(parts, "|cFFFFD200" .. card.faction .. "|r") end
    if card.zone then table.insert(parts, "|cFF888888" .. card.zone .. "|r") end
    if #parts == 0 then return nil end
    return table.concat(parts, "  •  ")
end

-- Forward declaration for camera refresher
local RefreshAllModelCameras

local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local B = CreateFrame("Frame", "TTS_BoardFrame", UIParent, backdropTemplate)
TTS.BoardFrame = B
B:SetSize(1160, 780)
B:SetPoint("CENTER")
B:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
B:EnableMouse(true)
B:SetMovable(true)
B:RegisterForDrag("LeftButton")
B:SetScript("OnDragStart", B.StartMoving)
B:SetScript("OnDragStop", B.StopMovingOrSizing)
B:SetScript("OnMouseDown", function(self, button)
    if button == "RightButton" then
        if TTS.Engine.targeting then
            TTS.Engine:CancelTargeting()
        elseif TTS.Engine.blockingState and TTS.Engine.blockingState.selectedBlocker then
            TTS.Engine.blockingState.selectedBlocker = nil
            TTS.Engine:RefreshUI()
        end
    end
end)

B:EnableMouseWheel(true)
B:SetScript("OnMouseWheel", function(self, delta)
    if IsControlKeyDown() then
        local cur = self:GetScale() or 1.0
        local newScale = math.max(0.60, math.min(1.60, cur + (delta * 0.05)))
        self:SetScale(newScale)
        if RefreshAllModelCameras then RefreshAllModelCameras() end
    end
end)
B:Hide()

-- =========================================================================
-- DRAGGABLE SCALE HANDLE (Bottom-Right)
-- =========================================================================
local resizer = CreateFrame("Button", nil, B)
resizer:SetSize(16, 16)
resizer:SetPoint("BOTTOMRIGHT", -6, 6)
resizer:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizer:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizer:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

local isRescaling = false
local startCursorX, startCursorY, startScale = 0, 0, 1.0

resizer:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        isRescaling = true
        local cx, cy = GetCursorPosition()
        startCursorX = cx
        startCursorY = cy
        startScale = B:GetScale() or 1.0
    end
end)

resizer:SetScript("OnMouseUp", function() isRescaling = false end)
resizer:SetScript("OnHide", function() isRescaling = false end)
resizer:SetScript("OnUpdate", function(self)
    if isRescaling then
        local cx, cy = GetCursorPosition()
        local uiScale = UIParent:GetEffectiveScale()
        local dx = (cx - startCursorX) / uiScale
        local dy = (startCursorY - cy) / uiScale
        local delta = (dx + dy) * 0.5 * 0.0015
        local newScale = math.max(0.60, math.min(1.60, startScale + delta))
        if math.abs(newScale - B:GetScale()) > 0.001 then
            B:SetScale(newScale)
            if RefreshAllModelCameras then RefreshAllModelCameras() end
        end
    end
end)

-- =========================================================================
-- ATTACHED GAME CHAT / COMBAT LOG (Side Panel)
-- =========================================================================
local sideLog = CreateFrame("Frame", "TTS_SideLogFrame", B, backdropTemplate)
sideLog:SetSize(250, 780)
sideLog:SetPoint("TOPLEFT", B, "TOPRIGHT", 6, 0)
sideLog:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 24,
    insets = { left = 6, right = 6, top = 6, bottom = 6 }
})

local logTitle = sideLog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
logTitle:SetPoint("TOP", 0, -12)
logTitle:SetText("Game Log")

local logMsg = CreateFrame("ScrollingMessageFrame", "TTS_MatchLogFrame", sideLog)
logMsg:SetPoint("TOPLEFT", 14, -36)
logMsg:SetPoint("BOTTOMRIGHT", -14, 38)
logMsg:SetFontObject(GameFontHighlightSmall)
logMsg:SetJustifyH("LEFT")
logMsg:SetFading(false)
logMsg:SetMaxLines(250)
logMsg:EnableMouseWheel(true)
logMsg:SetScript("OnMouseWheel", function(self, delta)
    if delta > 0 then
        if IsControlKeyDown() then self:ScrollToTop() else self:ScrollUp() end
    else
        if IsControlKeyDown() then self:ScrollToBottom() else self:ScrollDown() end
    end
end)
TTS.MatchLog = logMsg

local clearLogBtn = CreateFrame("Button", nil, sideLog, "UIPanelButtonTemplate")
clearLogBtn:SetSize(60, 20)
clearLogBtn:SetPoint("BOTTOMLEFT", 12, 10)
clearLogBtn:SetText("Clear")
clearLogBtn:SetScript("OnClick", function() logMsg:Clear() end)

local bottomLogBtn = CreateFrame("Button", nil, sideLog, "UIPanelButtonTemplate")
bottomLogBtn:SetSize(60, 20)
bottomLogBtn:SetPoint("BOTTOMRIGHT", -12, 10)
bottomLogBtn:SetText("Bottom")
bottomLogBtn:SetScript("OnClick", function() logMsg:ScrollToBottom() end)

-- =========================================================================
-- TOP & BOTTOM ACTION BUTTONS
-- =========================================================================
local concedeBtn = CreateFrame("Button", nil, B, "UIPanelButtonTemplate")
concedeBtn:SetSize(80, 24)
concedeBtn:SetPoint("TOPRIGHT", -20, -14)
concedeBtn:SetText("Concede")
concedeBtn:SetScript("OnClick", function() TTS.Engine:ConcedeMatch() end)

B.endTurnBtn = CreateFrame("Button", nil, B, "UIPanelButtonTemplate")
B.endTurnBtn:SetSize(90, 24)
B.endTurnBtn:SetPoint("BOTTOMRIGHT", -30, 16)
B.endTurnBtn:SetText("End Turn")
B.endTurnBtn:SetScript("OnClick", function() TTS.Engine:EndTurn() end)

B.nextPhaseBtn = CreateFrame("Button", nil, B, "UIPanelButtonTemplate")
B.nextPhaseBtn:SetSize(160, 24)
B.nextPhaseBtn:SetPoint("RIGHT", B.endTurnBtn, "LEFT", -8, 0)
B.nextPhaseBtn:SetText("To Combat")
B.nextPhaseBtn:SetScript("OnClick", function() TTS.Engine:NextPhase() end)

B.phaseText = B:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
B.phaseText:SetPoint("TOP", 0, -16)
B.phaseText:SetText("Phase: SETUP")

-- =========================================================================
-- INTERACTIVE PLAYER LIFE PLATES
-- =========================================================================
B.oppLifeBtn = CreateFrame("Button", nil, B, backdropTemplate)
B.oppLifeBtn:SetSize(270, 30)
B.oppLifeBtn:SetPoint("TOPLEFT", 30, -12)
B.oppLifeBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
B.oppLifeBtn:SetBackdropColor(0, 0, 0, 0.6)
B.oppLifeBtn:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8)
B.oppLifeBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

B.oppLifeText = B.oppLifeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
B.oppLifeText:SetPoint("LEFT", B.oppLifeBtn, "LEFT", 8, 0)
B.oppLifeText:SetJustifyH("LEFT")

B.oppLifeBtn:SetScript("OnClick", function(self, btn)
    if btn == "RightButton" and TTS.Engine.targeting then
        TTS.Engine:CancelTargeting()
        return
    end
    if TTS.Engine.targeting and (TTS.Engine.targeting.targetType == "PLAYER" or TTS.Engine.targeting.targetType == "ANY") then
        TTS.Engine:ResolveTarget("PLAYER", true, 0)
    end
end)
B.oppLifeBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
    GameTooltip:AddLine(TTS.Engine.opponent or "Opponent", 1, 0.82, 0)
    GameTooltip:AddLine(string.format("Life: %d  |  Cards in Hand: %d", TTS.Engine.remoteState.life, TTS.Engine.remoteState.handCount), 1, 1, 1)
    if TTS.Engine.targeting and (TTS.Engine.targeting.targetType == "PLAYER" or TTS.Engine.targeting.targetType == "ANY") then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cFF00FF00[Left-Click to target this player]|r", 0.2, 1.0, 0.2)
    end
    GameTooltip:Show()
end)
B.oppLifeBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

B.myLifeBtn = CreateFrame("Button", nil, B, backdropTemplate)
B.myLifeBtn:SetSize(160, 30)
B.myLifeBtn:SetPoint("BOTTOMLEFT", 30, 14)
B.myLifeBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
B.myLifeBtn:SetBackdropColor(0, 0, 0, 0.6)
B.myLifeBtn:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8)
B.myLifeBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

B.myLifeText = B.myLifeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
B.myLifeText:SetPoint("LEFT", B.myLifeBtn, "LEFT", 8, 0)
B.myLifeText:SetJustifyH("LEFT")

B.myLifeBtn:SetScript("OnClick", function(self, btn)
    if btn == "RightButton" and TTS.Engine.targeting then
        TTS.Engine:CancelTargeting()
        return
    end
    if TTS.Engine.targeting and (TTS.Engine.targeting.targetType == "PLAYER" or TTS.Engine.targeting.targetType == "ANY") then
        TTS.Engine:ResolveTarget("PLAYER", false, 0)
    end
end)
B.myLifeBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:AddLine("You", 1, 0.82, 0)
    GameTooltip:AddLine(string.format("Life: %d", TTS.Engine.localState.life), 1, 1, 1)
    if TTS.Engine.targeting and (TTS.Engine.targeting.targetType == "PLAYER" or TTS.Engine.targeting.targetType == "ANY") then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cFF00FF00[Left-Click to target yourself]|r", 0.2, 1.0, 0.2)
    end
    GameTooltip:Show()
end)
B.myLifeBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

B.manaText = B:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
B.manaText:SetPoint("BOTTOMLEFT", 205, 20)

local myHandFrames     = {}
local oppHandFrames    = {}
local myLandFrames     = {}
local myNonLandFrames  = {}
local oppLandFrames    = {}
local oppNonLandFrames = {}

-- =========================================================================
-- DUAL TOOLTIP SYSTEM
-- =========================================================================
local attachTooltip = CreateFrame("GameTooltip", "TTS_AttachmentTooltip", UIParent, "GameTooltipTemplate")
attachTooltip:Hide()

local function Card_OnEnter(self)
    if not self.cardId then return end
    if self.isHand then
        self:SetScale(1.18)
        self:SetFrameLevel((self.origFrameLevel or 10) + 15)
    end

    local card = TTS.Cards[self.cardId]
    if not card then return end
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:AddLine(card.name, 1, 1, 1)

    local costStr = (card.cost and card.cost ~= "") and TTS:FormatSymbols(card.cost, 20) or "0"
    local displayType = card.type
    if displayType == "Land" then
        displayType = "Prayer"
    end
    GameTooltip:AddLine("Cost: " .. costStr .. "  |  " .. displayType, 0.8, 0.8, 0.8)
    local tagLine = TTS.GetCardTagLine and TTS:GetCardTagLine(card)
    if tagLine then
        GameTooltip:AddLine(tagLine, 1, 1, 1)
    end

    if card.power and card.toughness then
        local effP, effT = card.power, card.toughness
        if self.fieldIndex then
            effP, effT = TTS.Engine:GetCreatureStats((self.isRemote and TTS.Engine.remoteState.field or TTS.Engine.localState.field)[self.fieldIndex], self.isRemote)
        end
        GameTooltip:AddLine(string.format("P/T: %d/%d", effP, effT), 1, 0.8, 0)
    end

    if card.text and card.text ~= "" then
        GameTooltip:AddLine(TTS:FormatSymbols(card.text, 16), 0.9, 0.9, 0.5, true)
    end

    if self.fieldIndex then
        local perm = (self.isRemote and TTS.Engine.remoteState.field or TTS.Engine.localState.field)[self.fieldIndex]
        if perm and perm.attachments and #perm.attachments > 0 then
            attachTooltip:SetOwner(GameTooltip, "ANCHOR_NONE")
            attachTooltip:ClearAllPoints()
            attachTooltip:SetPoint("TOPLEFT", GameTooltip, "TOPRIGHT", 6, 0)
            attachTooltip:ClearLines()

            for idx, att in ipairs(perm.attachments) do
                local attId = type(att) == "table" and att.id or att
                local aCard = TTS.Cards[attId]
                if aCard then
                    if idx > 1 then
                        attachTooltip:AddLine(" ")
                        attachTooltip:AddLine("--------------------------------", 0.4, 0.4, 0.4)
                    end
                    local isEquip = type(att) == "table" and att.isEquipment or (aCard.type == "Equipment" or aCard.isEquipment or aCard.subType == "Equipment")
                    local labelType = isEquip and "Equipment" or "Enchantment"
                    local labelColor = isEquip and "|cFF66BBFF" or "|cFFFFD200"

                    attachTooltip:AddLine(string.format("%s%s|r", labelColor, aCard.name), 1, 1, 1)
                    local aCost = (aCard.cost and aCard.cost ~= "") and TTS:FormatSymbols(aCard.cost, 18) or "0"
                    attachTooltip:AddLine(string.format("Cost: %s  |  %s", aCost, labelType), 0.8, 0.8, 0.8)

                    if aCard.text and aCard.text ~= "" then
                        attachTooltip:AddLine(TTS:FormatSymbols(aCard.text, 16), 0.9, 0.9, 0.6, true)
                    end
                end
            end
            attachTooltip:Show()
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("|cFF00FF00[Attached Cards: see side tooltip]|r", 0.6, 0.9, 0.6)
        end
    end
    GameTooltip:Show()
end

local function Card_OnLeave(self)
    if self.isHand then
        self:SetScale(1.0)
        if self.origFrameLevel then self:SetFrameLevel(self.origFrameLevel) end
    end
    GameTooltip:Hide()
    if attachTooltip then attachTooltip:Hide() end
end

local function GetCardFrameTexture(card)
    if not card then return CARD_FRAME_DEF end
    if card.color and CARD_FRAMES[string.upper(card.color)] then
        return CARD_FRAMES[string.upper(card.color)]
    end
    if card.school and CARD_FRAMES[string.upper(card.school)] then
        return CARD_FRAMES[string.upper(card.school)]
    end
    if card.cost and card.cost ~= "" then
        local firstColor = card.cost:match("{([WUBRGwubrg])}")
        if firstColor then
            return CARD_FRAMES[string.upper(firstColor)] or CARD_FRAME_DEF
        end
    end
    return CARD_FRAME_DEF
end

local function ApplyFrameTexture(t, card)
    local tex = GetCardFrameTexture(card)
    t:SetTexture(tex)
    if not t:GetTexture() then
        t:SetTexture(CARD_FRAME_DEF)
        if not t:GetTexture() then
            t:SetTexture(FALLBACK_BORDER)
        end
    end
end

local function ApplyBackTexture(t)
    t:SetTexture(CARD_BACK_TEX)
    if not t:GetTexture() then
        t:SetTexture(FALLBACK_BACK)
        t:SetVertexColor(0.2, 0.15, 0.1, 1.0)
    end
end

-- =========================================================================
-- CARD FRAME FACTORY
-- =========================================================================
local function CreateCardFrame(parent, sizeX, sizeY)
    local f = CreateFrame("Button", nil, parent)
    f:SetSize(sizeX, sizeY)
    f:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    f.tuckedFrames = {}
    for k = 1, 3 do
        local tf = CreateFrame("Frame", nil, f)
        tf:SetSize(sizeX, sizeY)
        tf:SetPoint("TOPLEFT", f, "TOPLEFT", 6 * k, -9 * k)
        tf:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 6 * k, -9 * k)

        tf.bg = tf:CreateTexture(nil, "BACKGROUND")
        tf.bg:SetAllPoints(tf)
        tf.bg:SetColorTexture(0.08, 0.08, 0.08, 0.95)

        tf.art = tf:CreateTexture(nil, "ARTWORK")
        tf.art:SetPoint("TOPLEFT", tf, "TOPLEFT", 4, -4)
        tf.art:SetPoint("BOTTOMRIGHT", tf, "BOTTOMRIGHT", -4, 4)
        tf.art:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

        tf.border = tf:CreateTexture(nil, "OVERLAY")
        tf.border:SetAllPoints(tf)
        ApplyFrameTexture(tf.border)

        tf:EnableMouse(false)
        tf:Hide()
        f.tuckedFrames[k] = tf
    end

    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetAllPoints(f)
    f.bg:SetColorTexture(0.08, 0.08, 0.08, 0.95)

    local artLeft   = math.floor(sizeX * ART_BOX.left)
    local artRight  = math.floor(sizeX * ART_BOX.right)
    local artShift  = math.floor(sizeY * ART_BOX.shiftUp)
    local artTop    = math.floor(sizeY * ART_BOX.top) - artShift
    local artBottom = math.floor(sizeY * ART_BOX.bottom) + artShift

    local boxW = sizeX - artLeft - artRight
    local boxH = sizeY - artTop - artBottom
    local iconPadX = boxW * 0.025
    local iconPadY = boxH * 0.025

    f.art = f:CreateTexture(nil, "ARTWORK")
    f.art:SetPoint("TOPLEFT", f, "TOPLEFT", artLeft - iconPadX, -(artTop - iconPadY))
    f.art:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -artRight + iconPadX, artBottom - iconPadY)
    f.art:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

    f.model = CreateFrame("PlayerModel", nil, f)
    f.model:SetPoint("TOPLEFT", f, "TOPLEFT", artLeft, -artTop)
    f.model:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -artRight, artBottom)
    f.model:EnableMouse(false)
    f.model:Hide()

    f.overlay = CreateFrame("Frame", nil, f)
    f.overlay:SetAllPoints(f)
    f.overlay:EnableMouse(false)

    local function SyncFrameLevels(baseLevel)
        local base = baseLevel or f:GetFrameLevel() or 10
        if f.tuckedFrames then
            for k, tf in ipairs(f.tuckedFrames) do
                tf:SetFrameLevel(math.max(1, base - k))
            end
        end
        if f.model then f.model:SetFrameLevel(base + 1) end
        if f.overlay then f.overlay:SetFrameLevel(base + 2) end
    end

    f:SetFrameLevel(10)
    SyncFrameLevels(10)

    local origSetFrameLevel = f.SetFrameLevel
    f.SetFrameLevel = function(self, level)
        origSetFrameLevel(self, level)
        SyncFrameLevels(level)
    end

    f.border = f.overlay:CreateTexture(nil, "OVERLAY")
    f.border:SetAllPoints(f.overlay)
    ApplyFrameTexture(f.border)

    f.title = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.title:SetPoint("BOTTOMLEFT", f.overlay, "TOPLEFT", -6, 3)
    f.title:SetPoint("BOTTOMRIGHT", f.overlay, "TOPRIGHT", 6, 3)
    f.title:SetJustifyH("CENTER")

    f.cost = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.cost:SetPoint("BOTTOM", f.title, "TOP", 0, 1)
    f.cost:SetJustifyH("CENTER")
    f.cost:Hide()

    local ptOffsetY = math.floor(sizeY * 0.18)
    f.pt = f.overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    local fontPath = f.pt:GetFont()
    if fontPath then f.pt:SetFont(fontPath, (sizeY > 80 and 15 or 12), "OUTLINE") end
    f.pt:SetPoint("BOTTOM", f.overlay, "BOTTOM", 0, ptOffsetY)
    f.pt:SetJustifyH("CENTER")
    f.pt:SetShadowOffset(1.5, -1.5)
    f.pt:SetShadowColor(0, 0, 0, 1)
    f.pt:Hide()

    f:SetScript("OnEnter", Card_OnEnter)
    f:SetScript("OnLeave", Card_OnLeave)
    f:SetScript("OnHide", function(self)
        if self.cost then self.cost:Hide() end
        if self.isHand then
            self:SetScale(1.0)
            if self.origFrameLevel then self:SetFrameLevel(self.origFrameLevel) end
        end
    end)
    f:Hide()
    return f
end

-- =========================================================================
-- BOARD LAYOUT GRIDS
-- =========================================================================
for i = 1, 10 do
    local slot = CreateFrame("Frame", nil, B)
    slot:SetSize(72, 102)
    slot:SetPoint("BOTTOMLEFT", 35 + ((i - 1) * 96), 52)

    local f = CreateCardFrame(B, 72, 102)
    f.isHand = true
    f.origFrameLevel = f:GetFrameLevel()
    f:SetPoint("CENTER", slot, "CENTER", 0, 0)
    f:SetScript("OnClick", function(self, btn)
        if btn == "RightButton" and TTS.Engine.targeting then
            TTS.Engine:CancelTargeting()
            return
        end
        TTS.Engine:PlayCard(i)
    end)
    myHandFrames[i] = f
end

for i = 1, 10 do
    local f = CreateFrame("Button", nil, B)
    f:SetSize(52, 70)
    f:SetPoint("TOPLEFT", 35 + ((i - 1) * 64), -46)
    f.back = f:CreateTexture(nil, "ARTWORK")
    f.back:SetAllPoints(f)
    ApplyBackTexture(f.back)

    f.targetBorder = f:CreateTexture(nil, "OVERLAY")
    f.targetBorder:SetAllPoints(f)
    f.targetBorder:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    f.targetBorder:Hide()

    f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    f:SetScript("OnClick", function(self, btn)
        if btn == "RightButton" and TTS.Engine.targeting then
            TTS.Engine:CancelTargeting()
            return
        end
        if TTS.Engine.targeting and (TTS.Engine.targeting.targetType == "PLAYER" or TTS.Engine.targeting.targetType == "ANY") then
            TTS.Engine:ResolveTarget("PLAYER", true, 0)
        end
    end)
    f:SetScript("OnEnter", function(self)
        if TTS.Engine.targeting and (TTS.Engine.targeting.targetType == "PLAYER" or TTS.Engine.targeting.targetType == "ANY") then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine(TTS.Engine.opponent or "Opponent", 1, 0.82, 0)
            GameTooltip:AddLine("|cFF00FF00Click to target enemy player|r", 0.2, 1.0, 0.2)
            GameTooltip:Show()
        end
    end)
    f:SetScript("OnLeave", function() GameTooltip:Hide() end)
    f:Hide()
    oppHandFrames[i] = f
end

local BF_CARD_W  = 64
local BF_CARD_H  = 84
local BF_STEP_X  = 86
local BF_START_X = 35

for i = 1, 12 do
    local f = CreateCardFrame(B, BF_CARD_W, BF_CARD_H)
    f.isRemote = false
    f:SetPoint("BOTTOMLEFT", BF_START_X + ((i - 1) * BF_STEP_X), 180)
    f:SetScript("OnClick", function(self, btn)
        if btn == "RightButton" and TTS.Engine.targeting then
            TTS.Engine:CancelTargeting()
            return
        end
        if TTS.Engine.targeting and (TTS.Engine.targeting.targetType == "LAND") then
            if self.fieldIndex then TTS.Engine:ResolveTarget("LAND", false, self.fieldIndex) end
            return
        end
        if self.fieldIndex then TTS.Engine:TapCard(self.fieldIndex) end
    end)
    myLandFrames[i] = f
end

for i = 1, 12 do
    local f = CreateCardFrame(B, BF_CARD_W, BF_CARD_H)
    f.isRemote = false
    f:SetPoint("BOTTOMLEFT", BF_START_X + ((i - 1) * BF_STEP_X), 315)
    f:SetScript("OnClick", function(self, btn)
        if btn == "RightButton" then
            if TTS.Engine.targeting then TTS.Engine:CancelTargeting(); return end
            if TTS.Engine.blockingState and TTS.Engine.blockingState.selectedBlocker then
                TTS.Engine.blockingState.selectedBlocker = nil
                TTS.Engine:RefreshUI()
                return
            end
        end
        if TTS.Engine.targeting then
            local t = TTS.Engine.targeting.targetType
            if t == "CREATURE" or t == "ANY" or t == "ARTIFACT_ENCHANTMENT" then
                if self.fieldIndex then TTS.Engine:ResolveTarget("CREATURE", false, self.fieldIndex) end
                return
            end
        end
        if self.fieldIndex then TTS.Engine:TapCard(self.fieldIndex) end
    end)
    myNonLandFrames[i] = f
end

for i = 1, 12 do
    local f = CreateCardFrame(B, BF_CARD_W, BF_CARD_H)
    f.isRemote = true
    f:SetPoint("TOPLEFT", BF_START_X + ((i - 1) * BF_STEP_X), -140)
    f:SetScript("OnClick", function(self, btn)
        if btn == "RightButton" and TTS.Engine.targeting then
            TTS.Engine:CancelTargeting()
            return
        end
        if TTS.Engine.targeting and (TTS.Engine.targeting.targetType == "LAND") then
            if self.fieldIndex then TTS.Engine:ResolveTarget("LAND", true, self.fieldIndex) end
        end
    end)
    oppLandFrames[i] = f
end

for i = 1, 12 do
    local f = CreateCardFrame(B, BF_CARD_W, BF_CARD_H)
    f.isRemote = true
    f:SetPoint("TOPLEFT", BF_START_X + ((i - 1) * BF_STEP_X), -275)
    f:SetScript("OnClick", function(self, btn)
        if btn == "RightButton" and TTS.Engine.targeting then
            TTS.Engine:CancelTargeting()
            return
        end
        if TTS.Engine.targeting then
            local t = TTS.Engine.targeting.targetType
            if t == "CREATURE" or t == "ANY" or t == "ARTIFACT_ENCHANTMENT" then
                if self.fieldIndex then TTS.Engine:ResolveTarget("CREATURE", true, self.fieldIndex) end
                return
            end
        end
        if self.fieldIndex then TTS.Engine:ClickOpponentCard(self.fieldIndex) end
    end)
    oppNonLandFrames[i] = f
end

local myDeckFrame = CreateFrame("Frame", nil, B)
myDeckFrame:SetSize(62, 88)
myDeckFrame:SetPoint("BOTTOMRIGHT", -30, 52)
myDeckFrame.back = myDeckFrame:CreateTexture(nil, "ARTWORK")
myDeckFrame.back:SetAllPoints(myDeckFrame)
ApplyBackTexture(myDeckFrame.back)
myDeckFrame.count = myDeckFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
myDeckFrame.count:SetPoint("CENTER", 0, 0)

-- =========================================================================
-- 3D MODEL VISUAL HELPER
-- =========================================================================
local function SetupCardVisual(f, card)
    f.currentCard = card
    if card and card.displayId then
        f.art:Hide()
        f.model:Show()
        f.model:ClearModel()
        f.model:SetDisplayInfo(card.displayId)

        local cam = card.modelCam or {}
        if f.model.SetPortraitZoom then f.model:SetPortraitZoom(cam.zoom or 0.75) end
        if f.model.SetCamDistanceScale then f.model:SetCamDistanceScale(cam.camScale or 1.0) end

        local baseZ = cam.z or -0.10
        local currentScale = B:GetScale() or 1.0
        local zComp = (currentScale - 1.0) * 0.18
        local adjZ = baseZ + zComp

        if f.model.SetPosition then f.model:SetPosition(cam.x or 0, cam.y or 0, adjZ) end
        if f.model.SetRotation then f.model:SetRotation(cam.rotation or 0.15) end
    else
        if f.model then f.model:Hide() end
        f.art:Show()
        f.art:SetTexture((card and card.art) or "Interface\\Icons\\INV_Misc_QuestionMark")
    end
end

RefreshAllModelCameras = function()
    local groups = { myHandFrames, myLandFrames, myNonLandFrames, oppLandFrames, oppNonLandFrames }
    for _, group in ipairs(groups) do
        for _, f in ipairs(group) do
            if f:IsShown() and f.currentCard and f.currentCard.displayId and f.model and f.model:IsShown() then
                local cam = f.currentCard.modelCam or {}
                local baseZ = cam.z or -0.10
                local currentScale = B:GetScale() or 1.0
                local zComp = (currentScale - 1.0) * 0.18
                local adjZ = baseZ + zComp
                if f.model.SetPosition then
                    f.model:SetPosition(cam.x or 0, cam.y or 0, adjZ)
                end
            end
        end
    end
end

-- =========================================================================
-- BOARD DISPLAY UPDATE
-- =========================================================================
function B:UpdateDisplay()
    local E = TTS.Engine
    if not E.inMatch then return end

    B.oppLifeText:SetText(string.format("%s: %d Life (%d cards)", E.opponent or "Opponent", E.remoteState.life, E.remoteState.handCount))
    B.myLifeText:SetText(string.format("Life: %d", E.localState.life))

    local m = E.localState.mana
    B.manaText:SetText(string.format("Mana:  %s |cFFFFFFFF%d|r   %s |cFFFFFFFF%d|r   %s |cFFFFFFFF%d|r   %s |cFFFFFFFF%d|r   %s |cFFFFFFFF%d|r",
        TTS:FormatSymbols("{W}", 22), m.W or 0,
        TTS:FormatSymbols("{U}", 22), m.U or 0,
        TTS:FormatSymbols("{B}", 22), m.B or 0,
        TTS:FormatSymbols("{R}", 22), m.R or 0,
        TTS:FormatSymbols("{G}", 22), m.G or 0
    ))

    local isTargetingPlayer = E.targeting and (E.targeting.targetType == "PLAYER" or E.targeting.targetType == "ANY")

    if isTargetingPlayer then
        B.oppLifeBtn:SetBackdropBorderColor(0.2, 1.0, 0.2, 1.0)
        B.oppLifeBtn:SetBackdropColor(0.1, 0.35, 0.1, 0.8)
        B.myLifeBtn:SetBackdropBorderColor(0.2, 1.0, 0.2, 1.0)
        B.myLifeBtn:SetBackdropColor(0.1, 0.35, 0.1, 0.8)
    else
        B.oppLifeBtn:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8)
        B.oppLifeBtn:SetBackdropColor(0, 0, 0, 0.6)
        B.myLifeBtn:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8)
        B.myLifeBtn:SetBackdropColor(0, 0, 0, 0.6)
    end

    -- =====================================================================
    -- PHASE & COMBAT BUTTON STATE
    -- =====================================================================
    if E.phase == "COMBAT_BLOCK" and E.blockingState then
        B.endTurnBtn:Disable()
        if E.blockingState.isRemoteAttacking then
            -- Local player is defending: enabled to confirm blocks and resolve
            B.nextPhaseBtn:Enable()
            local numBlocks = 0
            for _ in pairs(E.blockingState.blocks) do numBlocks = numBlocks + 1 end
            if numBlocks > 0 then
                B.nextPhaseBtn:SetText("Confirm Blocks")
            else
                B.nextPhaseBtn:SetText("No Blocks (Pass)")
            end
        else
            -- Local player is attacking: cannot resolve combat; defender must do it
            B.nextPhaseBtn:SetText("Waiting for Defender...")
            B.nextPhaseBtn:Disable()
        end
    elseif E.pendingDiscard then
        B.nextPhaseBtn:SetText("Discard a Card")
        B.nextPhaseBtn:Disable()
        B.endTurnBtn:Disable()
    elseif E.phase == "COMBAT_ATTACK" then
        B.nextPhaseBtn:Enable()
        B.nextPhaseBtn:SetText("Declare Blocks")
        B.endTurnBtn:Disable()
    elseif not E.isMyTurn or E.phase == "WAITING" or E.phase == "WAITING (Dummy Turn)" or E.phase == "PREGAME" then
        B.nextPhaseBtn:SetText("Opponent Turn")
        B.nextPhaseBtn:Disable()
        B.endTurnBtn:Disable()
    else
        B.nextPhaseBtn:Enable()
        B.endTurnBtn:Enable()
        if E.phase == "MAIN1" then
            B.nextPhaseBtn:SetText("To Combat")
        elseif E.phase == "MAIN2" then
            B.nextPhaseBtn:SetText("End Turn")
        else
            B.nextPhaseBtn:SetText("Next Phase")
        end
    end

    -- =====================================================================
    -- TOP PHASE TEXT
    -- =====================================================================
    if E.pendingDiscard then
        B.phaseText:SetText("|cFFFFCC00DISCARD: Click a card in your hand to discard|r")
    elseif E.targeting then
        B.phaseText:SetText(string.format("|cFFFFD200TARGETING: Select %s for %s (Right-click to cancel)|r", E.targeting.targetType, E.targeting.cardName))
    elseif E.phase == "COMBAT_BLOCK" and E.blockingState then
        if E.blockingState.isRemoteAttacking then
            B.phaseText:SetText("|cFFFF4444COMBAT: Assign Blockers, then click Confirm Blocks|r")
        else
            B.phaseText:SetText("|cFFFFD200COMBAT: Opponent is declaring blockers...|r")
        end
    else
        B.phaseText:SetText("Phase: " .. E.phase)
    end

    myDeckFrame.count:SetText(#E.localState.deck)

    local oppCount = math.min(10, E.remoteState.handCount or 0)
    for i = 1, 10 do
        if i <= oppCount then
            ApplyBackTexture(oppHandFrames[i].back)
            if isTargetingPlayer then
                oppHandFrames[i].targetBorder:SetVertexColor(0.2, 1.0, 0.2, 1.0)
                oppHandFrames[i].targetBorder:Show()
            else
                oppHandFrames[i].targetBorder:Hide()
            end
            oppHandFrames[i]:Show()
        else
            oppHandFrames[i]:Hide()
        end
    end

    for i = 1, 10 do
        local cardId = E.localState.hand[i]
        if cardId then
            local card = TTS.Cards[cardId]
            local f = myHandFrames[i]
            f.cardId = cardId
            SetupCardVisual(f, card)
            ApplyFrameTexture(f.border, card)
            f.title:SetText(card.name)

            if card.cost and card.cost ~= "" then
                f.cost:SetText(TTS:FormatSymbols(card.cost, 12))
                f.cost:Show()
            else
                f.cost:Hide()
            end

            if card.type == "Creature" and card.power and card.toughness then
                f.pt:SetText(string.format("|cFFFFD200%d/%d|r", card.power, card.toughness))
                f.pt:Show()
            else
                f.pt:Hide()
            end

            if E.pendingDiscard then
                f.border:SetVertexColor(1.0, 0.4, 0.4)
            elseif E.targeting and E.targeting.handIndex == i then
                f.border:SetVertexColor(1.0, 0.8, 0.0)
            else
                f.border:SetVertexColor(1.0, 1.0, 1.0)
            end
            f:Show()
        else
            myHandFrames[i]:Hide()
        end
    end

    local myLandIdx, myNonLandIdx = 0, 0
    for i, perm in ipairs(E.localState.field) do
        local card = TTS.Cards[perm.id]
        if card then
            local isLand = (card.type == "Land")
            local f = nil
            if isLand then
                myLandIdx = myLandIdx + 1
                if myLandIdx <= #myLandFrames then f = myLandFrames[myLandIdx] end
            else
                myNonLandIdx = myNonLandIdx + 1
                if myNonLandIdx <= #myNonLandFrames then f = myNonLandFrames[myNonLandIdx] end
            end

            if f then
                f.fieldIndex = i
                f.cardId = perm.id
                SetupCardVisual(f, card)
                ApplyFrameTexture(f.border, card)
                f.title:SetText(card.name)
            
                local atts = perm.attachments or {}
                if f.tuckedFrames then
                    for k = 1, #f.tuckedFrames do
                        local tf = f.tuckedFrames[k]
                        if k <= #atts then
                            local att = atts[k]
                            local attId = type(att) == "table" and att.id or att
                            local aCard = TTS.Cards[attId]
                            if aCard then
                                ApplyFrameTexture(tf.border, aCard)
                                tf.art:SetTexture(aCard.art or "Interface\\Icons\\INV_Misc_QuestionMark")
                                local isEquip = type(att) == "table" and att.isEquipment or (aCard.type == "Equipment" or aCard.isEquipment or aCard.subType == "Equipment")
                                if isEquip then
                                    tf.border:SetVertexColor(0.5, 0.8, 1.0)
                                else
                                    tf.border:SetVertexColor(1.0, 0.85, 0.3)
                                end
                                tf:Show()
                            else
                                tf:Hide()
                            end
                        else
                            tf:Hide()
                        end
                    end
                end

                if card.type == "Creature" then
                    local effP, effT = E:GetCreatureStats(perm, false)
                    local colorCode = (effP > card.power or effT > card.toughness) and "|cFF00FF00" or "|cFFFFD200"
                    f.pt:SetText(string.format("%s%d/%d|r", colorCode, effP, effT))
                    f.pt:Show()
                else
                    f.pt:Hide()
                end

                local shade = perm.tapped and 0.4 or 1.0
                if E.targeting then
                    f.border:SetVertexColor(0.2, 1.0, 0.2)
                elseif E.blockingState and E.blockingState.selectedBlocker == i then
                    f.border:SetVertexColor(0.0, 1.0, 1.0)
                elseif E.blockingState and E.blockingState.blocks and E.blockingState.blocks[i] then
                    f.border:SetVertexColor(0.2, 0.9, 0.2)
                elseif perm.isAttacking then
                    f.border:SetVertexColor(1.0, 0.2, 0.2)
                else
                    f.border:SetVertexColor(shade, shade, shade)
                end
                f.art:SetVertexColor(shade, shade, shade)
                f:Show()
            end
        end
    end

    for i = myLandIdx + 1, #myLandFrames do 
        myLandFrames[i]:Hide()
        myLandFrames[i].fieldIndex = nil
        if myLandFrames[i].tuckedFrames then for k = 1, #myLandFrames[i].tuckedFrames do myLandFrames[i].tuckedFrames[k]:Hide() end end
    end
    for i = myNonLandIdx + 1, #myNonLandFrames do 
        myNonLandFrames[i]:Hide()
        myNonLandFrames[i].fieldIndex = nil
        if myNonLandFrames[i].tuckedFrames then for k = 1, #myNonLandFrames[i].tuckedFrames do myNonLandFrames[i].tuckedFrames[k]:Hide() end end
    end

    local oppLandIdx, oppNonLandIdx = 0, 0
    for i, perm in ipairs(E.remoteState.field) do
        local card = TTS.Cards[perm.id]
        if card then
            local isLand = (card.type == "Land")
            local f = nil
            if isLand then
                oppLandIdx = oppLandIdx + 1
                if oppLandIdx <= #oppLandFrames then f = oppLandFrames[oppLandIdx] end
            else
                oppNonLandIdx = oppNonLandIdx + 1
                if oppNonLandIdx <= #oppNonLandFrames then f = oppNonLandFrames[oppNonLandIdx] end
            end

            if f then
                f.fieldIndex = i
                f.cardId = perm.id
                SetupCardVisual(f, card)
                ApplyFrameTexture(f.border, card)
                f.title:SetText(card.name)
            
                local atts = perm.attachments or {}
                if f.tuckedFrames then
                    for k = 1, #f.tuckedFrames do
                        local tf = f.tuckedFrames[k]
                        if k <= #atts then
                            local att = atts[k]
                            local attId = type(att) == "table" and att.id or att
                            local aCard = TTS.Cards[attId]
                            if aCard then
                                ApplyFrameTexture(tf.border, aCard)
                                tf.art:SetTexture(aCard.art or "Interface\\Icons\\INV_Misc_QuestionMark")
                                local isEquip = type(att) == "table" and att.isEquipment or (aCard.type == "Equipment" or aCard.isEquipment or aCard.subType == "Equipment")
                                if isEquip then
                                    tf.border:SetVertexColor(0.5, 0.8, 1.0)
                                else
                                    tf.border:SetVertexColor(1.0, 0.85, 0.3)
                                end
                                tf:Show()
                            else
                                tf:Hide()
                            end
                        else
                            tf:Hide()
                        end
                    end
                end

                if card.type == "Creature" then
                    local effP, effT = E:GetCreatureStats(perm, true)
                    f.pt:SetText(string.format("|cFFFFD200%d/%d|r", effP, effT))
                    f.pt:Show()
                else
                    f.pt:Hide()
                end

                local shade = perm.tapped and 0.4 or 1.0
                if E.targeting then
                    f.border:SetVertexColor(0.2, 1.0, 0.2)
                elseif perm.isAttacking then
                    f.border:SetVertexColor(1.0, 0.2, 0.2)
                else
                    f.border:SetVertexColor(shade, shade, shade)
                end
                f.art:SetVertexColor(shade, shade, shade)
                f:Show()
            end
        end
    end

    for i = oppLandIdx + 1, #oppLandFrames do 
        oppLandFrames[i]:Hide()
        oppLandFrames[i].fieldIndex = nil
        if oppLandFrames[i].tuckedFrames then for k = 1, #oppLandFrames[i].tuckedFrames do oppLandFrames[i].tuckedFrames[k]:Hide() end end
    end
    for i = oppNonLandIdx + 1, #oppNonLandFrames do 
        oppNonLandFrames[i]:Hide()
        oppNonLandFrames[i].fieldIndex = nil
        if oppNonLandFrames[i].tuckedFrames then for k = 1, #oppNonLandFrames[i].tuckedFrames do oppNonLandFrames[i].tuckedFrames[k]:Hide() end end
    end
end

-- =========================================================================
-- FOOTER
-- =========================================================================
local footer = B:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
footer:SetPoint("BOTTOM", B, "BOTTOM", 0, 10)
footer:SetText("Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy")

-- =========================================================================
-- MODULE EXPORTS
-- =========================================================================
TTS.CreateCardFrame     = CreateCardFrame
TTS.SetupCardVisual     = SetupCardVisual
TTS.ApplyFrameTexture   = ApplyFrameTexture
TTS.GetCardFrameTexture = GetCardFrameTexture
TTS.CARD_FRAME_DEF      = CARD_FRAME_DEF