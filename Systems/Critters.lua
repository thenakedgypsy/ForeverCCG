--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

-- =========================================================================
-- CRITTER KILLS (the secret card)
-- Every critter you (or your party) kill counts, account-wide (TTS_CritterKills). At a card's
-- critterUnlock count (Mr. Bigglesworth, Cards\Critters.lua: 100) it unlocks, all four copies
-- at once, with its pop-up (UI\CardToast.lua) and a line in chat. Nothing says it's coming:
-- the card has no zone, so the Collection Guide doesn't list it until it's yours.
-- A kill only says which creature died (its GUID), not what it was, so critters are noted as
-- the game shows them to us: the target, the mouseover and nameplates whose creature type is
-- Critter (in the client's language). A kill BossTracker credits to us (Systems\BossTracker.lua
-- RecordMobKillByGUIDOrName: ours or our party's) of a GUID noted that way counts once.
-- =========================================================================
local C = {}
TTS.Critters = C

local CRITTER_TYPE_ID = 8    -- CreatureType.db2: Critter
local SEEN_KEEP = 600        -- seconds a critter we saw stays noted
local MAX_SEEN = 400

local function IsSecret(v) return issecretvalue and issecretvalue(v) or false end

-- "Critter" in the client's language
local critterName
local function CritterTypeName()
    if critterName then return critterName end
    local ok, info = pcall(function()
        return C_CreatureInfo and C_CreatureInfo.GetCreatureTypeInfo and C_CreatureInfo.GetCreatureTypeInfo(CRITTER_TYPE_ID)
    end)
    critterName = (ok and type(info) == "table" and type(info.name) == "string" and info.name) or "Critter"
    return critterName
end

local seen, seenCount = {}, 0       -- GUID -> GetTime() we saw it
local counted = {}                  -- GUIDs already counted

local function Note(unit)
    if not (UnitExists and UnitGUID and UnitCreatureType) then return end
    local ok, exists = pcall(UnitExists, unit)
    if not ok or not exists then return end
    local okG, guid = pcall(UnitGUID, unit)
    local okT, kind = pcall(UnitCreatureType, unit)
    if not (okG and okT) or IsSecret(guid) or IsSecret(kind) then return end
    if type(guid) ~= "string" or type(kind) ~= "string" then return end
    if kind ~= CritterTypeName() and kind ~= "Critter" then return end
    if not seen[guid] then seenCount = seenCount + 1 end
    seen[guid] = GetTime()
    if seenCount > MAX_SEEN then
        local now = GetTime()
        seenCount = 0
        for g, t in pairs(seen) do
            if now - t > SEEN_KEEP then seen[g] = nil else seenCount = seenCount + 1 end
        end
    end
end

function C:Kills()
    return tonumber(TTS_CritterKills) or 0
end

-- The cards critter kills unlock (critterUnlock), checked against the count now
local function CheckUnlocks(kills)
    TTS_KilledBosses = TTS_KilledBosses or {}
    for _, card in pairs(TTS.Cards or {}) do
        local need = type(card) == "table" and tonumber(card.critterUnlock)
        if need and kills >= need and (tonumber(TTS_KilledBosses[card.id]) or 0) < 4 then
            TTS_KilledBosses[card.id] = 4
            if TTS.MarkCardNew then TTS:MarkCardNew(card.id) end
            local link = TTS.CardLink and TTS:CardLink(card.id, card.alwaysFoil) or TTS:CardName(card)
            DEFAULT_CHAT_FRAME:AddMessage(TTS.L("critters.unlocked", link, need))
            if TTS.CardToast then TTS.CardToast:OnCopy(card, 4) end
            if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() and TTS.DeckBuilderFrame.RefreshAll then
                TTS.DeckBuilderFrame:RefreshAll()
            end
        end
    end
end

-- A kill credited to us: counted if it was a critter we saw
function C:OnKill(guid)
    if type(guid) ~= "string" or IsSecret(guid) or counted[guid] then return end
    -- (the target or mouseover may be the critter that just died, never noted before)
    for _, unit in ipairs({ "target", "mouseover" }) do
        local ok, g = pcall(UnitGUID, unit)
        if ok and g == guid then Note(unit) end
    end
    if not seen[guid] then return end
    counted[guid] = true
    seen[guid] = nil
    TTS_CritterKills = self:Kills() + 1
    CheckUnlocks(TTS_CritterKills)
end

-- Every kill BossTracker credits to us comes through here too
local function HookTracker()
    local BT = TTS.BossTracker
    if not (BT and BT.RecordMobKillByGUIDOrName) or BT.critterHooked then return end
    BT.critterHooked = true
    local orig = BT.RecordMobKillByGUIDOrName
    BT.RecordMobKillByGUIDOrName = function(self, guid, ...)
        pcall(C.OnKill, C, guid)
        return orig(self, guid, ...)
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
for _, ev in ipairs({ "PLAYER_TARGET_CHANGED", "UPDATE_MOUSEOVER_UNIT", "NAME_PLATE_UNIT_ADDED" }) do
    pcall(f.RegisterEvent, f, ev)
end
f:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_LOGIN" then
        HookTracker()
        CheckUnlocks(C:Kills())   -- (a count reached before the card existed)
    elseif event == "PLAYER_TARGET_CHANGED" then
        Note("target")
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        Note("mouseover")
    elseif event == "NAME_PLATE_UNIT_ADDED" and type(unit) == "string" then
        Note(unit)
    end
end)
HookTracker()
