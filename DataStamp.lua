--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
]]
TTS = TTS or {}

-- =========================================================================
-- LAUNCH STAMP
-- Saved data from the beta doesn't carry over into launch. The launch build stamps the
-- saved data (TTS_DataStamp.launch = true); data without the stamp (the beta's, or a beta
-- file copied back in) is cleared once and stamped, so the collection starts afresh.
-- Every saved variable is in the one ForeverCCG.lua file, so copying an old file over a
-- new one brings back its missing stamp too.
--
-- This file loads before the others that use the data, so its ADDON_LOADED runs before
-- any of them reads it.
-- =========================================================================

-- Cleared when the stamp is missing
local CLEARED = {
    "TTS_KilledBosses", "TTS_SoloProgress", "TTS_NpcGifts", "TTS_HeroChoices",
    "TTS_SavedDecks", "TTS_ActiveDeckIndex", "TTS_NewCards",
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
    if addon ~= "ForeverCCG" then return end
    self:UnregisterEvent("ADDON_LOADED")
    if type(TTS_DataStamp) == "table" and TTS_DataStamp.launch == true then return end

    -- A new player has nothing to lose; anyone else is told why their collection is empty
    local had = false
    for _, name in ipairs(CLEARED) do
        local v = _G[name]
        if type(v) == "table" and next(v) ~= nil then had = true end
        _G[name] = nil
    end
    TTS_DataStamp = { launch = true }
    if had and DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage((TTS.L or tostring)("stamp.fresh"))
    end
end)
