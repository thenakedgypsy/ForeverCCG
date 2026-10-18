--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- SPECIAL CARDS
-- Collectible cards that belong to no zone or dungeon.
--   unlockOnDeath = true: copies come from your own deaths instead of kills (BossTracker.lua,
--                         PLAYER_DEAD), with the usual drop chances unless dropChance is set
--   dropChance = { %, %, %, % }: chance per kill/death for copies 1-4 (default 100/25/12/6)
--   diesAtTurnStart = true: dies at the start of its controller's turn (CoreEngine.lua BeginTurn)
--   dressItems = { itemIds }: its display model wears these (UI\Board.lua, Hero.lua DressModel)
-- =========================================================================
TTS:AddCards({
    ["LEEROY"] = {
        id = "LEEROY", name = "Leeroy Jenkins", cost = "{3}{W}", cmc = 4, color = "W", type = "Creature",
        power = 1, toughness = 4, isMob = true, isBoss = true, unlockOnDeath = true, diesAtTurnStart = true,
        dropChance = { 4, 2, 1, 0.5 },   -- % per death for copies 1-4 (BossTracker RecordMobKill)
        -- An NPC display's outfit is baked into its body texture, so items painted onto the body
        -- (chest, tabard, ...) can't go over it; only separate pieces (helm, shoulders, weapon)
        -- can. Hence a Scarlet NPC already in plate and a red tabard.
        displayId = 10341,   -- Highlord Taelan Fordring (classic npc 1842): plate and the red Scarlet tabard
        dressItems = {
            16731,   -- Helm of Valor
            16733,   -- Spaulders of Valor
            12583,   -- Blackhand Doomsaw
        },
        creatureType = "Humanoid",
        enterSound = "Interface\\AddOns\\ForeverCCG\\Audio\\leeroy_jenkins.mp3",   -- only when he arrives (Sound.lua)
        etb = { ops = { { op = "token", id = "TOK04", n = 3 } } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Upon entering the field, create three 0/1 Dragon Egg tokens with Blocker. At the start of your turn, Leeroy Jenkins dies."
    },
})
