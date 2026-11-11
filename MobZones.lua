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
-- Regenerate when denizen cards are added.
-- =========================================================================
TTS.MOB_ZONES = {
    ["BAD07"] = { "Searing Gorge" },   -- Dark Iron Kidnapper
    ["BAD08"] = { "Loch Modan" },   -- Shadowforge Surveyor
    ["BAD09"] = { "Loch Modan" },   -- Shadowforge Digger
    ["BUR01"] = { "Badlands" },   -- Dustbelcher Mauler
    ["DAR10"] = { "Ashenvale" },   -- Apothecary Falthis
    ["DMS02"] = { "Westfall" },   -- Defias Watchman
    ["DUR09"] = { "The Barrens" },   -- Dreadmaw Crocolisk
    ["FEL10"] = { "Winterspring" },   -- Mezzir the Howler
    ["HIL01"] = { "Silverpine Forest" },   -- Rot Hide Brute
    ["HIL02"] = { "Silverpine Forest" },   -- Rot Hide Plague Weaver
    ["HIL03"] = { "Silverpine Forest" },   -- Raging Rot Hide
    ["HIL04"] = { "Silverpine Forest" },   -- Elder Lake Creeper
    ["HIL09"] = { "Arathi Highlands" },   -- Witherbark Headhunter
    ["RED01"] = { "Elwynn Forest" },   -- Gray Forest Wolf
    ["SWA08"] = { "The Hinterlands" },   -- Witherbark Sadist
    ["SWA09"] = { "The Hinterlands" },   -- Witherbark Broodguard
    ["THO01"] = { "The Barrens" },   -- Savannah Matriarch
    ["ULD01"] = { "Loch Modan" },   -- Stonevault Rockchewer
    ["UNG01"] = { "Feralas" },   -- Ferocious Rage Scar
    ["WET07"] = { "Arathi Highlands" },   -- Syndicate Highwayman
    ["WET08"] = { "Arathi Highlands" },   -- Rumbling Exile
    ["WET09"] = { "Arathi Highlands" },   -- Burning Exile
}
