--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
-- =========================================================================
-- CLASS SPELLS (10 per playable class)
-- Resolved generically by TTS.Engine:ResolveSpell (see CardLogic.lua).
-- effect.target: enemy_creature | friendly_creature | creature | enemy_any | friendly_any | any | enemy_player | player | nil (no target)
-- =========================================================================
TTS:AddCards({
    -- PALADIN
    ["PAL01"] = {
        id = "PAL01", name = "Holy Light", cost = "{1}{W}", cmc = 2, color = "W", type = "Sorcery", class = "Paladin",
        text = "You regain 5 health, or target denizen you control permanently gets +0/+2. Draw 1.",
        art = "Interface\\Icons\\Spell_Holy_HolyBolt",
        effect = { target = "friendly_any", ops = { { op = "heal", to = "target", n = 5, t = 2 }, { op = "draw", n = 1 } } }
    },
    ["PAL02"] = {
        id = "PAL02", name = "Flash of Light", cost = "{W}", cmc = 1, color = "W", type = "Sorcery", class = "Paladin",
        text = "You regain 3 health, or target denizen you control permanently gets +0/+1. Draw 1.",
        art = "Interface\\Icons\\Spell_Holy_FlashHeal",
        effect = { target = "friendly_any", ops = { { op = "heal", to = "target", n = 3, t = 1 }, { op = "draw", n = 1 } } }
    },
    ["PAL03"] = {
        id = "PAL03", name = "Blessing of Might", cost = "{W}", cmc = 1, color = "W", type = "Sorcery", class = "Paladin",
        text = "Target denizen you control permanently gets +2/+1.",
        art = "Interface\\Icons\\Spell_Holy_FistOfJustice",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", p = 2, t = 1, perm = true } } }
    },
    ["PAL04"] = {
        id = "PAL04", name = "Blessing of Protection", cost = "{W}", cmc = 1, color = "W", type = "Sorcery", class = "Paladin",
        text = "Target denizen you control gains Shielded and Soulstone, and permanently gets +1/+1.",
        art = "Interface\\Icons\\Spell_Holy_SealOfProtection",
        effect = { target = "friendly_creature", ops = { { op = "shielded", to = "target" }, { op = "regen", to = "target" }, { op = "buff", to = "target", p = 1, t = 1, perm = true } } }
    },
    ["PAL05"] = {
        id = "PAL05", name = "Divine Shield", cost = "{2}{W}", cmc = 3, color = "W", type = "Sorcery", class = "Paladin",
        text = "Prevent the next 4 damage to you. Denizens you control gain Shielded.",
        art = "Interface\\Icons\\Spell_Holy_DivineIntervention",
        effect = { ops = { { op = "shield", to = "self_player", n = 4 }, { op = "shielded", to = "friendly_creatures" } } }
    },
    ["PAL06"] = {
        id = "PAL06", name = "Hammer of Justice", cost = "{1}{W}", cmc = 2, color = "W", type = "Sorcery", class = "Paladin",
        text = "Freeze target enemy denizen.",
        art = "Interface\\Icons\\Spell_Holy_SealOfMight",
        effect = { target = "enemy_creature", ops = { { op = "freeze", to = "target" } } }
    },
    ["PAL07"] = {
        id = "PAL07", name = "Exorcism", cost = "{2}{W}", cmc = 3, color = "W", type = "Sorcery", class = "Paladin",
        text = "Deal 5 damage to target enemy denizen.",
        art = "Interface\\Icons\\Spell_Holy_SearingLight",
        effect = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 5 } } }
    },
    ["PAL08"] = {
        id = "PAL08", name = "Consecration", cost = "{3}{W}", cmc = 4, color = "W", type = "Sorcery", class = "Paladin",
        text = "Deal 2 damage to each enemy denizen. You gain 2 life.",
        art = "Interface\\Icons\\Spell_Holy_InnerFire",
        effect = { ops = { { op = "damage", to = "enemy_creatures", n = 2 }, { op = "heal", to = "self_player", n = 2 } } }
    },
    ["PAL09"] = {
        id = "PAL09", name = "Lay on Hands", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Sorcery", class = "Paladin",
        text = "You regain 15 health, or target denizen you control permanently gets +0/+5.",
        art = "Interface\\Icons\\Spell_Holy_LayOnHands",
        effect = { target = "friendly_any", ops = { { op = "heal", to = "target", n = 15, t = 5 } } }
    },
    ["PAL10"] = {
        id = "PAL10", name = "Redemption", cost = "{2}{W}", cmc = 3, color = "W", type = "Sorcery", class = "Paladin",
        text = "Return a denizen card from your graveyard to the battlefield under your control.",
        art = "Interface\\Icons\\Spell_Holy_Resurrection",
        effect = { ops = { { op = "raise", src = "own" } } }
    },
})
