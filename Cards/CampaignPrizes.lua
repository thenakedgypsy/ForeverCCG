--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- CAMPAIGN PRIZES
-- Earned by winning the whole campaign, worked out live from the campaign wins
-- (TTS_SoloProgress.cleared), so they need no stored grant and reach existing players too.
--   campaignPrize = "zones": every zone encounter won once is 1 copy, every one won twice is
--                            2 copies, and so on up to 4 (SoloEncounters.lua GetOwnedCopies)
--   campaignPrize = "all":   the same over every zone and dungeon encounter
-- Not isPrize: the admin random prize and the tournament prize never pick them, and they count
-- towards the collection score like any other card. Never in packs or Endless drafts.
-- =========================================================================
TTS:AddCards({
    ["CMP01"] = {
        id = "CMP01", name = "Brann Bronzebeard", cost = "{4}", cmc = 4, color = "C", type = "Creature",
        power = 3, toughness = 4, vigilance = true, unique = true, campaignPrize = "zones", alwaysFoil = true,
        creatureType = "Humanoid",
        -- TODO: Brann's npcId and displayId (not in the Forever creature lists yet); the icon
        -- stands in until then
        art = "Interface\\Icons\\INV_Misc_Head_Dwarf_01",
        etb = { ops = { { op = "draw", n = 2 } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Unique. Vigilant. Arrival: Draw 2."
    },
    ["CMP02"] = {
        id = "CMP02", name = "The Ashbringer", cost = "{5}", cmc = 5, color = "C", type = "Sorcery", subType = "Gear",
        campaignPrize = "all", alwaysFoil = true,
        -- TODO verify in game: the item id worn by a humanoid denizen (13262 = Ashbringer) and the icon
        art = "Interface\\Icons\\INV_Sword_48",
        wear = 13262, wearSlot = "weapon",
        effect = { target = "friendly_creature", ops = {
            { op = "buff", to = "target", p = 3, t = 3, kw = { "lifelink", "firstStrike" }, perm = true },
        } },
        text = "Equip: +3/+3, Drain and Strikes-First."
    },
})
