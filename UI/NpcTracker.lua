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
-- CARD NPC TRACKER
-- Shows the NPCs of the card game (NpcSpots.lua: card-giving innkeepers and merchants,
-- profession trainers, duel opponents) to the player, each way switched on or off in the
-- options (both on at first):
--   npcMinimap   a card-back pin on the minimap for each one within its range
--   npcWorldMap  a pin on the world map for each one on the map being shown
-- Only NPCs the character's faction can deal with are shown, and duels only once they are
-- live (their Settlement exists) and reachable (SoloEncounters.lua). Every icon is the tracker
-- emblem (Textures\Symbols\tracker.png). Areas are matched to the client's maps by name
-- (C_Map), once, when first needed.
-- =========================================================================
local T = {}
TTS.NpcTracker = T

local ICON_SMALL = "Interface\\AddOns\\ForeverCCG\\Textures\\Symbols\\tracker_small.png"  -- on the maps
local DUEL_TINT = nil   -- (the emblem is in full colour: duel NPCs aren't tinted; their tooltip says what they do)
local MINI_SIZE, WORLD_SIZE = 14, 12
local MINI_TICK = 0.1     -- seconds between minimap updates
-- Minimap view radius in yards by zoom level (outdoors), for clients without GetViewRadius
local OUTDOOR_RADIUS = { [0] = 233.33, 200, 166.67, 133.33, 100, 66.67 }

local function On(key) return TTS.Options and TTS.Options:Get(key) == true end
local function IsSecret(v) return issecretvalue and issecretvalue(v) or false end

-- =========================================================================
-- WHO IS SHOWN
-- =========================================================================
local function MyFaction()
    local f = UnitFactionGroup and UnitFactionGroup("player")
    return (f == "Alliance" and "A") or (f == "Horde" and "H") or nil
end

-- The profession a trainer teaches (TTS.GIFT_POOLS), or nil
local function TrainerProfession(npcId)
    for _, def in pairs(TTS.GIFT_POOLS or {}) do
        if def.profession then
            for _, id in pairs(def.npcs or {}) do
                if id == npcId then return def.profession end
            end
        end
    end
end

-- Whether this character has business with the NPC (s: its NpcSpots.lua row). A trainer
-- while learning their profession still gives a starter card (the account's first 2
-- primaries); once both are picked up, not again until they're done, and then only those
-- that hand out cards: professions the character doesn't know (Professions.lua).
local function Wanted(npcId, s)
    local fac, me = s[5], MyFaction()
    if fac ~= "" and me and fac ~= me then return false end
    if s[4] == "duel" then
        local enc = TTS.DuelForNpc and TTS:DuelForNpc(npcId)
        if not enc or (TTS.CanReachDuel and not TTS:CanReachDuel(enc)) then return false end
    elseif s[4] == "trainer" then
        local prof = TrainerProfession(npcId)
        local P = TTS.Professions
        if not (prof and P and (P:StarterOpen(prof) or P:TrainerCards(prof))) then return false end
    end
    return true
end

local function KindText(kind) return L("tracker.kind." .. kind) end

local function ShowTip(owner, npcId, s)
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    GameTooltip:SetText(s[6] ~= "" and s[6] or ("NPC " .. npcId), 1, 0.82, 0)
    GameTooltip:AddLine(KindText(s[4]), 1, 1, 1, true)
    GameTooltip:Show()
end

-- Whether an NPC has nothing for the player right now (TTS:NpcWaiting, UI\NpcGossip.lua),
-- asked again at most every WAIT_RECHECK seconds (the minimap redraws ten times a second)
local WAIT_RECHECK = 2
local waitCache = {}   -- npcId -> { time, waiting }
local function Waiting(npcId)
    if not (npcId and TTS.NpcWaiting) then return false end
    local now, c = GetTime(), waitCache[npcId]
    if c and now - c[1] < WAIT_RECHECK then return c[2] end
    local ok, waiting = pcall(TTS.NpcWaiting, TTS, npcId)
    waiting = ok and waiting or false
    waitCache[npcId] = { now, waiting }
    return waiting
end

-- Greyed out while the NPC is on a cooldown (or has given everything it has)
local function Paint(tex, kind, icon, npcId)
    tex:SetTexture(icon)
    local grey = Waiting(npcId)
    tex:SetDesaturated(grey)
    if grey then
        tex:SetVertexColor(0.65, 0.65, 0.65)
        return
    end
    local c = kind == "duel" and DUEL_TINT or nil   -- (none at present)
    if c then tex:SetVertexColor(c[1], c[2], c[3]) else tex:SetVertexColor(1, 1, 1) end
end

-- =========================================================================
-- AREAS TO MAPS
-- NpcSpots.lua gives each NPC's area (Wowhead's zone id, the client's AreaTable); pins need
-- the client's map for it (uiMapID): the zone-type map of the same name. byMap[uiMapID] =
-- { { npcId, x, y, row }, ... } (x, y 0-1)
-- =========================================================================
local byMap

local function BuildMaps()
    byMap = {}
    if not (C_Map and C_Map.GetMapInfo and C_Map.GetAreaInfo) then return end
    local names = {}
    for _, s in pairs(TTS.NPC_SPOTS or {}) do
        local area = s[1]
        if area and area > 0 and names[area] == nil then
            local ok, name = pcall(C_Map.GetAreaInfo, area)
            names[area] = (ok and type(name) == "string" and name ~= "") and name or false
        end
    end
    local wanted = {}   -- name -> { areas }
    for area, name in pairs(names) do
        if name then wanted[name] = wanted[name] or {}; table.insert(wanted[name], area) end
    end
    local areaMap = {}   -- area -> uiMapID, the zone-type map preferred
    local zoneType = Enum and Enum.UIMapType and Enum.UIMapType.Zone or 3
    for id = 1, 4000 do
        local info = C_Map.GetMapInfo(id)
        local areas = info and info.name and wanted[info.name]
        if areas then
            for _, area in ipairs(areas) do
                local have = areaMap[area]
                local better = not have or (info.mapType == zoneType and have.type ~= zoneType)
                if better then areaMap[area] = { id = id, type = info.mapType } end
            end
        end
    end
    for npcId, s in pairs(TTS.NPC_SPOTS or {}) do
        local m = areaMap[s[1]]
        if m then
            byMap[m.id] = byMap[m.id] or {}
            table.insert(byMap[m.id], { npcId, s[2] / 100, s[3] / 100, s })
        end
    end
end

local function OnMap(uiMapID)
    if not byMap then BuildMaps() end
    return uiMapID and byMap[uiMapID] or nil
end

-- =========================================================================
-- MINIMAP
-- Each NPC on the player's current map within the minimap's range: offset from the player
-- by their map positions times the map's size in yards, turned with a rotating minimap.
-- =========================================================================
local miniPins = {}

local function MiniPin(i)
    local p = miniPins[i]
    if p then return p end
    p = CreateFrame("Button", nil, Minimap)
    p:SetSize(MINI_SIZE, MINI_SIZE)
    p:SetFrameLevel(Minimap:GetFrameLevel() + 5)
    p.icon = p:CreateTexture(nil, "OVERLAY")
    p.icon:SetAllPoints()
    p:SetScript("OnEnter", function(self) if self.npcId then ShowTip(self, self.npcId, self.row) end end)
    p:SetScript("OnLeave", function() GameTooltip:Hide() end)
    p:Hide()
    miniPins[i] = p
    return p
end

local function HideMini(from)
    for i = from or 1, #miniPins do miniPins[i]:Hide() end
end

local function ViewRadius()
    if C_Minimap and C_Minimap.GetViewRadius then
        local ok, r = pcall(C_Minimap.GetViewRadius)
        if ok and type(r) == "number" and r > 0 then return r end
    end
    if Minimap.GetViewRadius then
        local ok, r = pcall(Minimap.GetViewRadius, Minimap)
        if ok and type(r) == "number" and r > 0 then return r end
    end
    return OUTDOOR_RADIUS[Minimap:GetZoom() or 0] or 200
end

local function UpdateMinimap()
    if not (On("npcMinimap") and Minimap:IsVisible() and C_Map and C_Map.GetBestMapForUnit) then return HideMini() end
    local map = C_Map.GetBestMapForUnit("player")
    local list = OnMap(map)
    if not list then return HideMini() end
    local pos = C_Map.GetPlayerMapPosition(map, "player")
    if not pos or IsSecret(pos) then return HideMini() end
    local px, py = pos:GetXY()
    local w, h
    if C_Map.GetMapWorldSize then w, h = C_Map.GetMapWorldSize(map) end
    if not (px and w and h and w > 0 and h > 0) then return HideMini() end
    local radius = ViewRadius()
    local half = Minimap:GetWidth() / 2
    local facing = (GetCVar("rotateMinimap") == "1") and GetPlayerFacing and GetPlayerFacing() or nil
    local sinF, cosF = facing and math.sin(facing) or 0, facing and math.cos(facing) or 1
    local n = 0
    for _, e in ipairs(list) do
        if Wanted(e[1], e[4]) then
            local east, north = (e[2] - px) * w, -(e[3] - py) * h
            if facing then east, north = east * cosF + north * sinF, -east * sinF + north * cosF end
            if east * east + north * north <= (radius * 0.95) ^ 2 then
                n = n + 1
                local p = MiniPin(n)
                p.npcId, p.row = e[1], e[4]
                Paint(p.icon, e[4][4], ICON_SMALL, e[1])
                p:ClearAllPoints()
                p:SetPoint("CENTER", Minimap, "CENTER", east / radius * half, north / radius * half)
                p:Show()
            end
        end
    end
    HideMini(n + 1)
end

local miniDriver = CreateFrame("Frame")
miniDriver.t = 0
miniDriver:SetScript("OnUpdate", function(self, elapsed)
    self.t = self.t + elapsed
    if self.t < MINI_TICK then return end
    self.t = 0
    local ok, err = pcall(UpdateMinimap)
    if not ok then HideMini(); self:Hide(); if geterrorhandler then geterrorhandler()(err) end end
end)

-- =========================================================================
-- WORLD MAP
-- Pins on the map's canvas, kept the same size on screen as it zooms; redone when the
-- map shown or its zoom changes.
-- =========================================================================
local worldPins = {}
local shownMap, shownScale

local function HideWorld(from)
    for i = from or 1, #worldPins do worldPins[i]:Hide() end
end

local function WorldPin(i, canvas)
    local p = worldPins[i]
    if p then return p end
    p = CreateFrame("Button", nil, canvas)
    p:SetSize(WORLD_SIZE, WORLD_SIZE)
    p.icon = p:CreateTexture(nil, "OVERLAY")
    p.icon:SetAllPoints()
    p:SetScript("OnEnter", function(self) if self.npcId then ShowTip(self, self.npcId, self.row) end end)
    p:SetScript("OnLeave", function() GameTooltip:Hide() end)
    worldPins[i] = p
    return p
end

local function UpdateWorldMap()
    local WM = WorldMapFrame
    if not (On("npcWorldMap") and WM and WM:IsShown() and WM.GetMapID and WM.GetCanvas) then return HideWorld() end
    local canvas = WM:GetCanvas()
    local list = canvas and OnMap(WM:GetMapID())
    if not list then return HideWorld() end
    local cw, ch = canvas:GetSize()
    local scale = (WM.ScrollContainer and WM.ScrollContainer.GetCanvasScale and WM.ScrollContainer:GetCanvasScale()) or 1
    local k = 1 / math.max(0.01, scale)   -- pin scale against the canvas's, so it stays one size
    local n = 0
    for _, e in ipairs(list) do
        if Wanted(e[1], e[4]) then
            n = n + 1
            local p = WorldPin(n, canvas)
            p.npcId, p.row = e[1], e[4]
            Paint(p.icon, e[4][4], ICON_SMALL, e[1])
            p:SetFrameLevel(canvas:GetFrameLevel() + 2000)
            p:SetScale(k)
            p:ClearAllPoints()
            p:SetPoint("CENTER", canvas, "TOPLEFT", e[2] * cw / k, -e[3] * ch / k)
            p:Show()
        end
    end
    HideWorld(n + 1)
end

local worldDriver = CreateFrame("Frame")
worldDriver:SetScript("OnUpdate", function()
    local WM = WorldMapFrame
    if not (WM and WM:IsShown()) then
        if shownMap then shownMap, shownScale = nil, nil; HideWorld() end
        return
    end
    local map = WM.GetMapID and WM:GetMapID()
    local scale = WM.ScrollContainer and WM.ScrollContainer.GetCanvasScale and WM.ScrollContainer:GetCanvasScale()
    if map == shownMap and scale == shownScale then return end
    shownMap, shownScale = map, scale
    local ok, err = pcall(UpdateWorldMap)
    if not ok then HideWorld(); worldDriver:Hide(); if geterrorhandler then geterrorhandler()(err) end end
end)

-- =========================================================================
-- OPTIONS
-- =========================================================================
-- An option changed (UI\Options.lua): redraw at once
function T:Refresh(changedKey)
    miniDriver:Show()
    worldDriver:Show()
    shownMap = nil
    pcall(UpdateMinimap)
end
