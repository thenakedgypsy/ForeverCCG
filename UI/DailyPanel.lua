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
-- DAILY CHALLENGE PANEL (Systems\Daily.lua)
-- Today's opponent and its background, AI and life, the curse and twist, whether today's
-- reward is still to be won, and when the next challenge (UTC) and reward (local) come.
-- Play opens the deck picker, then starts the match. Same look as the solo map's windows.
-- =========================================================================
local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local GOLD, GREY, RED, GREEN = "|cFFFFD200", "|cFF8A8A8A", "|cFFFF4444", "|cFF33DD33"
local CURSE_COLOR, TWIST_COLOR, RULE_COLOR = "|cFFFF6060", "|cFF66BBFF", "|cFFFF8040"

local WIN_W, WIN_H = 560, 430
local ART_W, ART_H = 240, 160
local TEXT_W = WIN_W - ART_W - 64

local F = CreateFrame("Frame", "TTS_DailyPanel", UIParent, backdropTemplate)
TTS.DailyPanel = F
F:SetSize(WIN_W, WIN_H)
F:SetPoint("CENTER")
F:SetClampedToScreen(true)
F:SetFrameStrata("DIALOG")
F:SetToplevel(true)
F:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
F:EnableMouse(true)
F:SetMovable(true)
F:RegisterForDrag("LeftButton")
F:SetScript("OnDragStart", F.StartMoving)
F:SetScript("OnDragStop", F.StopMovingOrSizing)
F:Hide()
tinsert(UISpecialFrames, "TTS_DailyPanel")

do
    local bar = F:CreateTexture(nil, "ARTWORK")
    bar:SetPoint("TOPLEFT", 12, -12)
    bar:SetPoint("TOPRIGHT", -12, -12)
    bar:SetHeight(25)
    bar:SetColorTexture(0, 0, 0, 0.35)
    local line = F:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, 0)
    line:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, 0)
    line:SetHeight(1)
    line:SetColorTexture(1, 0.82, 0, 0.55)
end

local title = F:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
Loc:Bind(title, "daily.title")
local dayText = F:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
dayText:SetPoint("LEFT", title, "RIGHT", 10, -1)

local closeBtn = CreateFrame("Button", nil, F, "UIPanelCloseButton")
closeBtn:SetScript("OnClick", TTS.CloseParent)
closeBtn:SetPoint("TOPRIGHT", -2, -2)

local footer = F:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
footer:SetPoint("BOTTOMRIGHT", F, "BOTTOMRIGHT", -20, 14)
footer:SetText("Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy")

-- =========================================================================
-- BACKGROUND PREVIEW: an encounter's board background, small (shared with UI\Endless.lua)
--   local art = TTS.CreateEncounterArt(parent, w, h)   -- a bordered frame w + 8 by h + 8
--   art:SetBackground(encounter.background)
-- =========================================================================
local MAP_W, MAP_H, MAP_TILE = 1002, 668, 256

function TTS.CreateEncounterArt(parent, artW, artH)
    local art = CreateFrame("Frame", nil, parent, backdropTemplate)
    art:SetSize(artW + 8, artH + 8)
    art:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    art:SetBackdropColor(0, 0, 0, 1)
    art:SetBackdropBorderColor(0.60, 0.56, 0.48, 1)

    local canvas = CreateFrame("Frame", nil, art)
    canvas:SetPoint("TOPLEFT", 4, -4)
    canvas:SetSize(artW, artH)
    if canvas.SetClipsChildren then canvas:SetClipsChildren(true) end
    art.canvas = canvas

    local loadArt = canvas:CreateTexture(nil, "BACKGROUND")
    loadArt:SetAllPoints(canvas)
    local tiles = {}
    for i = 1, 12 do tiles[i] = canvas:CreateTexture(nil, "BACKGROUND") end

    function art:SetBackground(bg)
        loadArt:Hide()
        for _, t in ipairs(tiles) do t:Hide() end
        if not bg then return end
        if bg.loadscreen then
            local ok = loadArt:SetTexture(type(bg.loadscreen) == "number" and bg.loadscreen
                or ("Interface\\Glues\\LoadingScreens\\" .. bg.loadscreen))
            if ok ~= false and loadArt:GetTexture() then
                -- Cropped to the preview's shape from 4:3 (or 16:9)
                local aspect, want = bg.wide and 16 / 9 or 4 / 3, artW / artH
                if aspect > want then
                    local keep = want / aspect
                    loadArt:SetTexCoord((1 - keep) / 2, 1 - (1 - keep) / 2, 0, 1)
                else
                    local keep = aspect / want
                    loadArt:SetTexCoord(0, 1, (1 - keep) / 2, 1 - (1 - keep) / 2)
                end
                loadArt:Show()
                return
            end
        end
        if bg.map then
            -- The world map (1002 x 668), scaled to the preview's width, the middle kept
            local s = artW / MAP_W
            local top = (MAP_H * s - artH) / 2
            for row = 0, 2 do
                for col = 0, 3 do
                    local t = tiles[row * 4 + col + 1]
                    t:SetTexture(string.format("Interface\\WorldMap\\%s\\%s%d", bg.map, bg.map, row * 4 + col + 1))
                    local w = math.min(MAP_TILE, MAP_W - col * MAP_TILE)
                    local h = math.min(MAP_TILE, MAP_H - row * MAP_TILE)
                    t:ClearAllPoints()
                    t:SetPoint("TOPLEFT", canvas, "TOPLEFT", col * MAP_TILE * s, -(row * MAP_TILE * s - top))
                    t:SetSize(w * s, h * s)
                    t:SetTexCoord(0, w / MAP_TILE, 0, h / MAP_TILE)
                    t:Show()
                end
            end
        end
    end
    return art
end

local art = TTS.CreateEncounterArt(F, ART_W, ART_H)
art:SetPoint("TOPLEFT", F, "TOPLEFT", 20, -50)
local function ShowBackground(bg) art:SetBackground(bg) end

-- The encounter's name and kind on a dark strip along the bottom of the art
local nameStrip = CreateFrame("Frame", nil, art)
nameStrip:SetPoint("BOTTOMLEFT", art.canvas, "BOTTOMLEFT", 0, 0)
nameStrip:SetPoint("BOTTOMRIGHT", art.canvas, "BOTTOMRIGHT", 0, 0)
nameStrip:SetHeight(36)
nameStrip:SetFrameLevel(art:GetFrameLevel() + 5)
do
    local shade = nameStrip:CreateTexture(nil, "BACKGROUND")
    shade:SetAllPoints()
    shade:SetColorTexture(0, 0, 0, 0.65)
end
local oppName = nameStrip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
oppName:SetPoint("TOPLEFT", 8, -4)
oppName:SetPoint("TOPRIGHT", -8, -4)
oppName:SetJustifyH("LEFT")
local kindText = nameStrip:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
kindText:SetPoint("TOPLEFT", oppName, "BOTTOMLEFT", 0, -2)

-- Under the art: today's reward (a pack, ready or won) and when the next challenge and
-- reward come
local REWARD_H = 104
local rewardPanel = CreateFrame("Frame", nil, F, backdropTemplate)
rewardPanel:SetSize(ART_W + 8, REWARD_H)
rewardPanel:SetPoint("TOPLEFT", art, "BOTTOMLEFT", 0, -8)
rewardPanel:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
rewardPanel:SetBackdropColor(0.04, 0.04, 0.04, 0.70)
rewardPanel:SetBackdropBorderColor(0.60, 0.56, 0.48, 1)

local packIcon = rewardPanel:CreateTexture(nil, "ARTWORK")
packIcon:SetSize(34, 48)
packIcon:SetPoint("TOPLEFT", 12, -10)
packIcon:SetTexture("Interface\\AddOns\\ForeverCCG\\Textures\\Packs\\pack_dungeon_closed.png")

local rewardTitle = rewardPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
rewardTitle:SetPoint("TOPLEFT", packIcon, "TOPRIGHT", 10, -2)
Loc:Bind(rewardTitle, "daily.rewardTitle")
local rewardText = rewardPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
rewardText:SetPoint("TOPLEFT", rewardTitle, "BOTTOMLEFT", 0, -4)
rewardText:SetWidth(ART_W - 60)
rewardText:SetJustifyH("LEFT")

do
    local line = rewardPanel:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", 8, -66)
    line:SetPoint("TOPRIGHT", -8, -66)
    line:SetHeight(1)
    line:SetColorTexture(1, 0.82, 0, 0.30)
end
local timersText = rewardPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
timersText:SetPoint("TOPLEFT", 12, -72)
timersText:SetWidth(ART_W - 16)
timersText:SetJustifyH("LEFT")

-- =========================================================================
-- DETAILS (right side)
-- =========================================================================
local body = F:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
body:SetPoint("TOPLEFT", art, "TOPRIGHT", 16, -2)
body:SetWidth(TEXT_W)
body:SetJustifyH("LEFT")
body:SetJustifyV("TOP")
if body.SetWordWrap then body:SetWordWrap(true) end

local hint = F:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
hint:SetPoint("BOTTOM", F, "BOTTOM", 0, 64)
hint:SetWidth(WIN_W - 48)

local playBtn = CreateFrame("Button", nil, F, "UIPanelButtonTemplate")
playBtn:SetSize(140, 26)
playBtn:SetPoint("BOTTOM", F, "BOTTOM", 0, 32)
Loc:Bind(playBtn, "daily.play")

local AI_LABEL = setmetatable({}, { __index = function(_, ai) return Loc:Data("solo.ai." .. tostring(ai), ai) end })

local function DetailText(enc)
    local lines = {}
    local function Add(s) lines[#lines + 1] = s end
    Add(L("solo.opponent", GOLD .. TTS:EncounterOpponent(enc) .. "|r"))
    if #(enc.bosses or {}) > 1 then
        local names = {}
        for _, b in ipairs(enc.bosses) do table.insert(names, TTS.Cards[b] and TTS:CardName(b) or b) end
        Add(L("solo.bosses", GOLD .. table.concat(names, ", ") .. "|r"))
    end
    Add(L("solo.lifeAi", GOLD .. (enc.life or 20) .. "|r", GOLD .. AI_LABEL[enc.ai] .. "|r"))
    -- The encounter's own boss rules, then the day's curse and twist
    local own = {}
    for _, id in ipairs(enc.rules or {}) do
        if id ~= enc.curse and id ~= enc.twist then own[#own + 1] = id end
    end
    for _, rule in ipairs(TTS:GetEncounterRuleLines({ rules = own })) do
        Add(" ")
        Add(RULE_COLOR .. rule.name .. "|r")
        Add(rule.text)
    end
    for _, m in ipairs(TTS.Daily:MutatorLines(enc)) do
        Add(" ")
        local color = m.kind == "twist" and TWIST_COLOR or CURSE_COLOR
        Add(color .. L(m.kind == "twist" and "daily.twist" or "daily.curse", m.name) .. "|r")
        Add(m.text)
    end
    return table.concat(lines, "\n")
end

local function UpdateTimers()
    local D = TTS.Daily
    local claimed = D:RewardClaimed()
    if claimed then
        rewardText:SetText(GREY .. L("daily.rewardClaimed") .. "|r")
    else
        rewardText:SetText(GREEN .. L("daily.rewardReady", TTS.Packs and TTS.Packs:Name(D.PACK) or "") .. "|r")
    end
    if packIcon.SetDesaturated then packIcon:SetDesaturated(claimed) end
    packIcon:SetAlpha(claimed and 0.5 or 1)
    local lines = { L("daily.nextChallenge", TTS:FormatWait(D:NextChallengeWait())) }
    local wait = D:RewardWait()
    if wait then lines[#lines + 1] = L("daily.nextReward", TTS:FormatWait(wait)) end
    timersText:SetText(GREY .. table.concat(lines, "\n") .. "|r")
end

function F:Refresh()
    if not self:IsShown() then return end
    local D = TTS.Daily
    local enc = D:GetEncounter()
    dayText:SetText(enc.day or "")
    ShowBackground(enc.background)
    oppName:SetText(TTS:EncounterName(enc))
    local src = TTS.SoloEncounters[enc.source]
    kindText:SetText(src and src.kind == "dungeon" and L("solo.dungeon") or L("solo.zoneGauntlet"))
    body:SetText(DetailText(enc))
    UpdateTimers()
    -- As tall as the taller column (the art and reward, or the details), then the hint and Play
    local leftH = 50 + ART_H + 8 + 8 + REWARD_H
    local rightH = 52 + (body:GetStringHeight() or 0)
    self:SetHeight(math.max(leftH, rightH) + 100)
    local blocker = D:StartBlocker()
    hint:SetText(blocker and (RED .. blocker .. "|r") or (GREY .. L("daily.hint") .. "|r"))
    playBtn:SetEnabled(blocker == nil)
end

playBtn:SetScript("OnClick", function()
    local D = TTS.Daily
    F.picking = true
    F:Hide()
    local ok, why = D:Start(function()
        -- The picker was cancelled: back to the panel (which brings the main window back on close)
        F:Show()
    end)
    F.picking = nil
    if not ok then
        F:Show()
        if why then hint:SetText(RED .. why .. "|r") end
    end
end)

-- Covered by the deck picker, the panel isn't closed (MainFrame.lua's child windows)
F.ttsIsCovered = function() return F.picking or (TTS.DeckPicker and TTS.DeckPicker:IsPending()) end

local ticker
F:SetScript("OnShow", function(self)
    if TTS.Engine and TTS.Engine.inMatch then
        self:Hide()
        return
    end
    self:Refresh()
    if ticker then ticker:Cancel() end
    ticker = C_Timer.NewTicker(30, function() if F:IsShown() then UpdateTimers() end end)
end)
F:SetScript("OnHide", function()
    if ticker then ticker:Cancel(); ticker = nil end
end)

-- Opened any way while the main window is up, it takes its place (as the solo map does)
F:HookScript("OnShow", function(self)
    local M = TTS.MainFrame
    if self:IsShown() and M and M:IsShown() and M.OpenChild then M:OpenChild(self) end
end)

function F:Open()
    self:Show()
    return self
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    if TTS.Sound and TTS.Sound.HookButtons then TTS.Sound:HookButtons(F) end
    self:UnregisterAllEvents()
end)
