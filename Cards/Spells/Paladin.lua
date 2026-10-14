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
        text = "You or target creature you control regains 5 health.",
        art = "Interface\\Icons\\Spell_Holy_HolyBolt",
        effect = { target = "friendly_any", ops = { { op = "heal", to = "target", n = 5 } } }
    },
    ["PAL02"] = {
        id = "PAL02", name = "Flash of Light", cost = "{W}", cmc = 1, color = "W", type = "Sorcery", class = "Paladin",
        text = "You or target creature you control regains 3 health.",
        art = "Interface\\Icons\\Spell_Holy_FlashHeal",
        effect = { target = "friendly_any", ops = { { op = "heal", to = "target", n = 3 } } }
    },
    ["PAL03"] = {
        id = "PAL03", name = "Blessing of Might", cost = "{W}", cmc = 1, color = "W", type = "Sorcery", class = "Paladin",
        text = "Target creature you control gets +3/+0 until end of turn.",
        art = "Interface\\Icons\\Spell_Holy_FistOfJustice",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", p = 3 } } }
    },
    ["PAL04"] = {
        id = "PAL04", name = "Blessing of Protection", cost = "{W}", cmc = 1, color = "W", type = "Sorcery", class = "Paladin",
        text = "Target creature you control gets +0/+3 until end of turn and gains a regeneration shield.",
        art = "Interface\\Icons\\Spell_Holy_SealOfProtection",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", t = 3 }, { op = "regen", to = "target" } } }
    },
    ["PAL05"] = {
        id = "PAL05", name = "Divine Shield", cost = "{2}{W}", cmc = 3, color = "W", type = "Sorcery", class = "Paladin",
        text = "Prevent the next 8 damage that would be dealt to you.",
        art = "Interface\\Icons\\Spell_Holy_DivineIntervention",
        effect = { ops = { { op = "shield", to = "self_player", n = 8 } } }
    },
    ["PAL06"] = {
        id = "PAL06", name = "Hammer of Justice", cost = "{1}{W}", cmc = 2, color = "W", type = "Sorcery", class = "Paladin",
        text = "Tap target enemy creature. It does not untap during its controller's next untap step.",
        art = "Interface\\Icons\\Spell_Holy_SealOfMight",
        effect = { target = "enemy_creature", ops = { { op = "freeze", to = "target" } } }
    },
    ["PAL07"] = {
        id = "PAL07", name = "Exorcism", cost = "{2}{W}", cmc = 3, color = "W", type = "Sorcery", class = "Paladin",
        text = "Deal 5 damage to target enemy creature.",
        art = "Interface\\Icons\\Spell_Holy_SearingLight",
        effect = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 5 } } }
    },
    ["PAL08"] = {
        id = "PAL08", name = "Consecration", cost = "{3}{W}", cmc = 4, color = "W", type = "Sorcery", class = "Paladin",
        text = "Deal 2 damage to each enemy creature.",
        art = "Interface\\Icons\\Spell_Holy_InnerFire",
        effect = { ops = { { op = "damage", to = "enemy_creatures", n = 2 } } }
    },
    ["PAL09"] = {
        id = "PAL09", name = "Lay on Hands", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Sorcery", class = "Paladin",
        text = "You or target creature you control regains 15 health.",
        art = "Interface\\Icons\\Spell_Holy_LayOnHands",
        effect = { target = "friendly_any", ops = { { op = "heal", to = "target", n = 15 } } }
    },
    ["PAL10"] = {
        id = "PAL10", name = "Redemption", cost = "{3}{W}", cmc = 4, color = "W", type = "Sorcery", class = "Paladin",
        text = "Return a creature card from your graveyard to the battlefield under your control.",
        art = "Interface\\Icons\\Spell_Holy_Resurrection",
        effect = { ops = { { op = "raise", src = "own" } } }
    },
})
