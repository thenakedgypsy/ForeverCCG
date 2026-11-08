--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

-- =========================================================================
-- MODELS AND LOADING SCREENS
-- A 3D model still loaded while the client tears the old world down (entering an instance,
-- a portal, a hearth) is a suspected cause of crashes on zoning. At PLAYER_LEAVING_WORLD
-- every card model, its spell-effect carriers (CardFX.lua) and the mob card's model
-- (MobTooltip.lua) are unloaded and hidden. Once the new world is in (PLAYER_ENTERING_WORLD,
-- plus RESTORE_DELAY), the card frames still on screen load theirs again. A card put on a
-- frame in between (SetupCardVisual) waits for that too: G:Hold.
-- =========================================================================
TTS.ModelGuard = {}
local G = TTS.ModelGuard

local RESTORE_DELAY = 1   -- seconds after the loading screen before models load again

G.loading = false
local tracked = setmetatable({}, { __mode = "k" })   -- every card frame that has shown a card
local held = {}                                        -- frames to load again afterwards
local generation = 0                                   -- a newer loading screen cancels a pending restore

-- SetupCardVisual (Board.lua), every call. While the world is loading, keeps the frame's card
-- for afterwards and returns true: the caller loads no model now.
function G:Hold(f, card)
    tracked[f] = true
    if not (self.loading and f.model) then return false end
    f.currentCard, f.visualCard = card, nil
    held[f] = true
    return true
end

local function UnloadCardModel(f)
    local m = f.model
    if not m then return end
    -- Effects first: they live on carriers of their own, and on the model itself
    if TTS.CardFX and TTS.CardFX.Release and (f.fxPerm or f.fxLayer or f.fxRaised) then
        pcall(TTS.CardFX.Release, TTS.CardFX, f)
    end
    m.heroDressToken = nil   -- (a hero's dressing still pending is dropped: Hero.lua)
    if m:IsShown() then held[f] = true end
    pcall(m.ClearModel, m)
    m:Hide()
    f.visualCard = nil       -- (the same card shown again loads its model again)
end

local function UnloadAll()
    for f in pairs(tracked) do UnloadCardModel(f) end
    if TTS.MobTooltip and TTS.MobTooltip.UnloadModels then
        pcall(TTS.MobTooltip.UnloadModels, TTS.MobTooltip)
    end
end

local function RestoreAll()
    local list = held
    held = {}
    for f in pairs(list) do
        if f:IsShown() and f.currentCard and TTS.SetupCardVisual then
            f.visualCard = nil
            TTS.SetupCardVisual(f, f.currentCard, f.isFoil)
        end
    end
    -- The board puts its effects back on with its next redraw (CardFX's SyncFrame)
    local B = TTS.BoardFrame
    if B and B:IsShown() and B.UpdateDisplay then B:UpdateDisplay() end
end

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_LEAVING_WORLD")
watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
watcher:SetScript("OnEvent", function(_, event)
    generation = generation + 1
    if event == "PLAYER_LEAVING_WORLD" then
        G.loading = true
        UnloadAll()
        return
    end
    if not G.loading then return end   -- (login: nothing was unloaded)
    local this = generation
    TTS:SafeAfter(RESTORE_DELAY, function()
        if this ~= generation then return end
        G.loading = false
        RestoreAll()
    end)
end)
