--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

-- =========================================================================
-- CREATURES FOUND IN MORE THAN ONE ZONE (for UI\CollectionGuide.lua)
-- The zones other than its card.zone where a denizen card's creature (its npcId, or
-- dropsFrom.npcId) also spawns, so the Collection Guide lists it there too. Kills count
-- wherever they happen (BossTracker.lua). Generated from classicdb's NPC spawn lists:
-- zone names as the cards spell them, only zones that have cards, and a zone with fewer
-- than 3 spawns left out (stray border spawns) unless the creature isn't in its card.zone.
-- Regenerate when denizen cards are added. Checked against WoW Forever's Wowhead spawn
-- lists on 2026-11-13: a card's zone must be one where its creature spawns on Forever.
-- =========================================================================
TTS.MOB_ZONES = {
    ["BAD08"] = { "Loch Modan" },   -- Shadowforge Surveyor
    ["BAD09"] = { "Loch Modan" },   -- Shadowforge Digger
    ["DMS02"] = { "Westfall" },   -- Defias Watchman
    ["DUR09"] = { "The Barrens" },   -- Dreadmaw Crocolisk
    ["HIL04"] = { "Alterac Mountains" },   -- Elder Lake Creeper
    ["RED01"] = { "Duskwood" },   -- Gray Forest Wolf
    ["ULD01"] = { "Badlands" },   -- Stonevault Rockchewer
}
