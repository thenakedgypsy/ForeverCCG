TTS = TTS or {}
TTS.Cards = {
    -- =========================================================================
    -- PRAYERS (LANDS)
    -- =========================================================================
    ["W01"] = {
        id = "W01", name = "Prayer of Light", cost = "", cmc = 0, color = "W", type = "Land",
        text = "{T}: Add {W}.",
        art = "Interface\\Icons\\Spell_Holy_Aspiration"
    },
    ["U01"] = {
        id = "U01", name = "Prayer of Arcane", cost = "", cmc = 0, color = "U", type = "Land",
        text = "{T}: Add {U}.",
        art = "Interface\\Icons\\Spell_Frost_FrostArmor"
    },
    ["B01"] = {
        id = "B01", name = "Prayer of Shadow", cost = "", cmc = 0, color = "B", type = "Land",
        text = "{T}: Add {B}.",
        art = "Interface\\Icons\\Spell_Shadow_AntiShadow"
    },
    ["R01"] = {
        id = "R01", name = "Prayer of Fire", cost = "", cmc = 0, color = "R", type = "Land",
        text = "{T}: Add {R}.",
        art = "Interface\\Icons\\Spell_Fire_Incinerate"
    },
    ["G01"] = {
        id = "G01", name = "Prayer of Nature", cost = "", cmc = 0, color = "G", type = "Land",
        text = "{T}: Add {G}.",
        art = "Interface\\Icons\\Spell_Nature_HealingTouch"
    },

    -- =========================================================================
    -- CLASS SPELLS (10 per playable class)
    -- Resolved generically by TTS.Engine:ResolveSpell (see CardLogic.lua).
    -- effect.target: enemy_creature | friendly_creature | creature | enemy_any | friendly_any | any | enemy_player | player | nil (no target)
    -- =========================================================================

    -- WARRIOR
    ["WAR01"] = {
        id = "WAR01", name = "Heroic Strike", cost = "{R}", cmc = 1, color = "R", type = "Sorcery", class = "Warrior",
        text = "Target creature you control gets +2/+0 until end of turn.",
        art = "Interface\\Icons\\Ability_Rogue_Ambush",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", p = 2 } } }
    },
    ["WAR02"] = {
        id = "WAR02", name = "Charge", cost = "{R}", cmc = 1, color = "R", type = "Sorcery", class = "Warrior",
        text = "Target creature you control gets +1/+0 and gains Haste until end of turn.",
        art = "Interface\\Icons\\Ability_Warrior_Charge",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", p = 1, kw = { "haste" } } } }
    },
    ["WAR03"] = {
        id = "WAR03", name = "Rend", cost = "{1}{R}", cmc = 2, color = "R", type = "Sorcery", class = "Warrior",
        text = "Target enemy creature takes 1 damage at the start of each of your turns for 4 turns.",
        art = "Interface\\Icons\\Ability_Gouge",
        effect = { target = "enemy_creature", ops = { { op = "dot", to = "target", n = 1, turns = 4 } } }
    },
    ["WAR04"] = {
        id = "WAR04", name = "Bloodrage", cost = "{R}", cmc = 1, color = "R", type = "Sorcery", class = "Warrior",
        text = "You take 2 damage. Add {R}{R} to your mana pool.",
        art = "Interface\\Icons\\Ability_Racial_BloodRage",
        effect = { ops = { { op = "damage", to = "self_player", n = 2 }, { op = "mana", n = 2, color = "R" } } }
    },
    ["WAR05"] = {
        id = "WAR05", name = "Thunder Clap", cost = "{1}{R}", cmc = 2, color = "R", type = "Sorcery", class = "Warrior",
        text = "Deal 1 damage to each enemy creature and tap them.",
        art = "Interface\\Icons\\Spell_Nature_ThunderClap",
        effect = { ops = { { op = "damage", to = "enemy_creatures", n = 1 }, { op = "tap", to = "enemy_creatures" } } }
    },
    ["WAR06"] = {
        id = "WAR06", name = "Overpower", cost = "{1}{R}", cmc = 2, color = "R", type = "Sorcery", class = "Warrior",
        text = "Target creature you control gets +3/+0 and gains First Strike until end of turn.",
        art = "Interface\\Icons\\Ability_MeleeDamage",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", p = 3, kw = { "firstStrike" } } } }
    },
    ["WAR07"] = {
        id = "WAR07", name = "Execute", cost = "{R}", cmc = 1, color = "R", type = "Sorcery", class = "Warrior",
        text = "Destroy target enemy creature that has been dealt damage.",
        art = "Interface\\Icons\\INV_Sword_48",
        effect = { target = "enemy_creature", ops = { { op = "destroy", to = "target", damaged = true } } }
    },
    ["WAR08"] = {
        id = "WAR08", name = "Shield Wall", cost = "{1}{W}", cmc = 2, color = "W", type = "Sorcery", class = "Warrior",
        text = "Prevent the next 6 damage that would be dealt to you.",
        art = "Interface\\Icons\\Ability_Warrior_ShieldWall",
        effect = { ops = { { op = "shield", to = "self_player", n = 6 } } }
    },
    ["WAR09"] = {
        id = "WAR09", name = "Mortal Strike", cost = "{2}{R}", cmc = 3, color = "R", type = "Sorcery", class = "Warrior",
        text = "Deal 4 damage to target enemy creature.",
        art = "Interface\\Icons\\Ability_Warrior_SavageBlow",
        effect = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 4 } } }
    },
    ["WAR10"] = {
        id = "WAR10", name = "Whirlwind", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Sorcery", class = "Warrior",
        text = "Deal 3 damage to each enemy creature.",
        art = "Interface\\Icons\\Ability_Whirlwind",
        effect = { ops = { { op = "damage", to = "enemy_creatures", n = 3 } } }
    },

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

    -- HUNTER
    ["HUN01"] = {
        id = "HUN01", name = "Arcane Shot", cost = "{U}", cmc = 1, color = "U", type = "Sorcery", class = "Hunter",
        text = "Deal 2 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Ability_ImpalingBolt",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 2 } } }
    },
    ["HUN02"] = {
        id = "HUN02", name = "Serpent Sting", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Hunter",
        text = "Target enemy creature or the opponent takes 1 damage at the start of each of your turns for 4 turns.",
        art = "Interface\\Icons\\Ability_Hunter_Quickshot",
        effect = { target = "enemy_any", ops = { { op = "dot", to = "target", n = 1, turns = 4 } } }
    },
    ["HUN03"] = {
        id = "HUN03", name = "Aimed Shot", cost = "{2}{G}", cmc = 3, color = "G", type = "Sorcery", class = "Hunter",
        text = "Deal 4 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\INV_Spear_07",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 4 } } }
    },
    ["HUN04"] = {
        id = "HUN04", name = "Multi-Shot", cost = "{2}{G}", cmc = 3, color = "G", type = "Sorcery", class = "Hunter",
        text = "Deal 2 damage to each enemy creature.",
        art = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
        effect = { ops = { { op = "damage", to = "enemy_creatures", n = 2 } } }
    },
    ["HUN05"] = {
        id = "HUN05", name = "Concussive Shot", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Hunter",
        text = "Tap target enemy creature.",
        art = "Interface\\Icons\\Spell_Frost_Stun",
        effect = { target = "enemy_creature", ops = { { op = "tap", to = "target" } } }
    },
    ["HUN06"] = {
        id = "HUN06", name = "Freezing Trap", cost = "{1}{U}", cmc = 2, color = "U", type = "Sorcery", class = "Hunter",
        text = "Tap target enemy creature. It does not untap during its controller's next untap step.",
        art = "Interface\\Icons\\Spell_Frost_ChainsOfIce",
        effect = { target = "enemy_creature", ops = { { op = "freeze", to = "target" } } }
    },
    ["HUN07"] = {
        id = "HUN07", name = "Immolation Trap", cost = "{2}{R}", cmc = 3, color = "R", type = "Sorcery", class = "Hunter",
        text = "Target enemy creature or the opponent takes 2 damage at the start of each of your turns for 3 turns.",
        art = "Interface\\Icons\\Spell_Fire_FlameShock",
        effect = { target = "enemy_any", ops = { { op = "dot", to = "target", n = 2, turns = 3 } } }
    },
    ["HUN08"] = {
        id = "HUN08", name = "Mend Pet", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Hunter",
        text = "Target creature you control regains 3 health, then regains 1 health at the start of each of your turns for 3 turns.",
        art = "Interface\\Icons\\Ability_Hunter_MendPet",
        effect = { target = "friendly_creature", ops = { { op = "heal", to = "target", n = 3 }, { op = "hot", to = "target", n = 1, turns = 3 } } }
    },
    ["HUN09"] = {
        id = "HUN09", name = "Hunter's Mark", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Hunter",
        text = "Target enemy creature permanently gets -2/-1.",
        art = "Interface\\Icons\\Ability_Hunter_SniperShot",
        effect = { target = "enemy_creature", ops = { { op = "buff", to = "target", p = -2, t = -1, perm = true } } }
    },
    ["HUN10"] = {
        id = "HUN10", name = "Bestial Wrath", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Sorcery", class = "Hunter",
        text = "Target creature you control gets +3/+3 and gains Trample until end of turn.",
        art = "Interface\\Icons\\Ability_Druid_FerociousBite",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", p = 3, t = 3, kw = { "trample" } } } }
    },

    -- ROGUE
    ["ROG01"] = {
        id = "ROG01", name = "Sinister Strike", cost = "{B}", cmc = 1, color = "B", type = "Sorcery", class = "Rogue",
        text = "Deal 2 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 2 } } }
    },
    ["ROG02"] = {
        id = "ROG02", name = "Backstab", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Rogue",
        text = "Deal 3 damage to target enemy creature, or 6 damage if it is tapped.",
        art = "Interface\\Icons\\Ability_BackStab",
        effect = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 3, bonusIfTapped = 3 } } }
    },
    ["ROG03"] = {
        id = "ROG03", name = "Eviscerate", cost = "{2}{B}", cmc = 3, color = "B", type = "Sorcery", class = "Rogue",
        text = "Deal 5 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Ability_Rogue_Eviscerate",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 5 } } }
    },
    ["ROG04"] = {
        id = "ROG04", name = "Gouge", cost = "{B}", cmc = 1, color = "B", type = "Sorcery", class = "Rogue",
        text = "Deal 1 damage to target enemy creature and tap it.",
        art = "Interface\\Icons\\Ability_Gouge",
        effect = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 1 }, { op = "tap", to = "target" } } }
    },
    ["ROG05"] = {
        id = "ROG05", name = "Cheap Shot", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Rogue",
        text = "Tap target enemy creature. It does not untap during its controller's next untap step.",
        art = "Interface\\Icons\\Ability_CheapShot",
        effect = { target = "enemy_creature", ops = { { op = "freeze", to = "target" } } }
    },
    ["ROG06"] = {
        id = "ROG06", name = "Sprint", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Rogue",
        text = "Target creature you control gains Haste and Unblockable until end of turn.",
        art = "Interface\\Icons\\Ability_Rogue_Sprint",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", kw = { "haste", "unblockable" } } } }
    },
    ["ROG07"] = {
        id = "ROG07", name = "Vanish", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Rogue",
        text = "Target creature you control gains Hexproof until end of turn and a regeneration shield.",
        art = "Interface\\Icons\\Ability_Vanish",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", kw = { "hexproof" } }, { op = "regen", to = "target" } } }
    },
    ["ROG08"] = {
        id = "ROG08", name = "Evasion", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Rogue",
        text = "Target creature you control gets +0/+2 and gains First Strike until end of turn.",
        art = "Interface\\Icons\\Spell_Shadow_ShadowWard",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", t = 2, kw = { "firstStrike" } } } }
    },
    ["ROG09"] = {
        id = "ROG09", name = "Slice and Dice", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Rogue",
        text = "Creatures you control get +1/+0 and gain Haste until end of turn.",
        art = "Interface\\Icons\\Ability_Rogue_SliceDice",
        effect = { ops = { { op = "buff", to = "friendly_creatures", p = 1, kw = { "haste" } } } }
    },
    ["ROG10"] = {
        id = "ROG10", name = "Garrote", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Rogue",
        text = "Target enemy creature takes 2 damage at the start of each of your turns for 3 turns.",
        art = "Interface\\Icons\\Ability_Rogue_Garrote",
        effect = { target = "enemy_creature", ops = { { op = "dot", to = "target", n = 2, turns = 3 } } }
    },

    -- PRIEST
    ["PRI01"] = {
        id = "PRI01", name = "Power Word: Shield", cost = "{W}", cmc = 1, color = "W", type = "Sorcery", class = "Priest",
        text = "Prevent the next 4 damage that would be dealt to you, or give target creature you control +0/+4 until end of turn.",
        art = "Interface\\Icons\\Spell_Holy_PowerWordShield",
        effect = { target = "friendly_any", ops = { { op = "shield", to = "target", n = 4 } } }
    },
    ["PRI02"] = {
        id = "PRI02", name = "Renew", cost = "{W}", cmc = 1, color = "W", type = "Sorcery", class = "Priest",
        text = "You or target creature you control regains 2 health at the start of each of your turns for 3 turns.",
        art = "Interface\\Icons\\Spell_Holy_Renew",
        effect = { target = "friendly_any", ops = { { op = "hot", to = "target", n = 2, turns = 3 } } }
    },
    ["PRI03"] = {
        id = "PRI03", name = "Flash Heal", cost = "{1}{W}", cmc = 2, color = "W", type = "Sorcery", class = "Priest",
        text = "You or target creature you control regains 5 health.",
        art = "Interface\\Icons\\Spell_Holy_FlashHeal",
        effect = { target = "friendly_any", ops = { { op = "heal", to = "target", n = 5 } } }
    },
    ["PRI04"] = {
        id = "PRI04", name = "Prayer of Healing", cost = "{3}{W}", cmc = 4, color = "W", type = "Sorcery", class = "Priest",
        text = "You and each creature you control regain 4 health.",
        art = "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
        effect = { ops = { { op = "heal", to = "self_player", n = 4 }, { op = "heal", to = "friendly_creatures", n = 4 } } }
    },
    ["PRI05"] = {
        id = "PRI05", name = "Smite", cost = "{1}{W}", cmc = 2, color = "W", type = "Sorcery", class = "Priest",
        text = "Deal 3 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Spell_Holy_HolySmite",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 } } }
    },
    ["PRI06"] = {
        id = "PRI06", name = "Holy Fire", cost = "{2}{W}", cmc = 3, color = "W", type = "Sorcery", class = "Priest",
        text = "Deal 3 damage to target enemy creature or the opponent. It takes 1 more damage at the start of each of your turns for 2 turns.",
        art = "Interface\\Icons\\Spell_Holy_SearingLight",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 }, { op = "dot", to = "target", n = 1, turns = 2 } } }
    },
    ["PRI07"] = {
        id = "PRI07", name = "Shadow Word: Pain", cost = "{B}", cmc = 1, color = "B", type = "Sorcery", class = "Priest",
        text = "Target enemy creature or the opponent takes 2 damage at the start of each of your turns for 3 turns.",
        art = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
        effect = { target = "enemy_any", ops = { { op = "dot", to = "target", n = 2, turns = 3 } } }
    },
    ["PRI08"] = {
        id = "PRI08", name = "Mind Blast", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Priest",
        text = "Deal 3 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 } } }
    },
    ["PRI09"] = {
        id = "PRI09", name = "Mind Control", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Sorcery", class = "Priest",
        text = "Gain control of target enemy creature until end of turn. Untap it. It gains Haste.",
        art = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
        effect = { target = "enemy_creature", ops = { { op = "steal", to = "target", untilEnd = true } } }
    },
    ["PRI10"] = {
        id = "PRI10", name = "Psychic Scream", cost = "{2}{B}", cmc = 3, color = "B", type = "Sorcery", class = "Priest",
        text = "Tap each enemy creature. They do not untap during their controller's next untap step.",
        art = "Interface\\Icons\\Spell_Shadow_PsychicScream",
        effect = { ops = { { op = "freeze", to = "enemy_creatures" } } }
    },

    -- SHAMAN
    ["SHA01"] = {
        id = "SHA01", name = "Lightning Bolt", cost = "{1}{G}", cmc = 2, color = "G", type = "Sorcery", class = "Shaman",
        text = "Deal 3 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Spell_Nature_Lightning",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 } } }
    },
    ["SHA02"] = {
        id = "SHA02", name = "Earth Shock", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Shaman",
        text = "Deal 2 damage to target enemy creature.",
        art = "Interface\\Icons\\Spell_Nature_EarthShock",
        effect = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 2 } } }
    },
    ["SHA03"] = {
        id = "SHA03", name = "Flame Shock", cost = "{1}{R}", cmc = 2, color = "R", type = "Sorcery", class = "Shaman",
        text = "Deal 1 damage to target enemy creature or the opponent. It takes 1 more damage at the start of each of your turns for 3 turns.",
        art = "Interface\\Icons\\Spell_Fire_FlameShock",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 1 }, { op = "dot", to = "target", n = 1, turns = 3 } } }
    },
    ["SHA04"] = {
        id = "SHA04", name = "Frost Shock", cost = "{1}{U}", cmc = 2, color = "U", type = "Sorcery", class = "Shaman",
        text = "Deal 1 damage to target enemy creature and tap it. It does not untap during its controller's next untap step.",
        art = "Interface\\Icons\\Spell_Frost_FrostShock",
        effect = { target = "enemy_creature", ops = { { op = "damage", to = "target", n = 1 }, { op = "freeze", to = "target" } } }
    },
    ["SHA05"] = {
        id = "SHA05", name = "Chain Lightning", cost = "{3}{G}", cmc = 4, color = "G", type = "Sorcery", class = "Shaman",
        text = "Deal 2 damage to each enemy creature and to the opponent.",
        art = "Interface\\Icons\\Spell_Nature_ChainLightning",
        effect = { ops = { { op = "damage", to = "enemy_creatures", n = 2 }, { op = "damage", to = "enemy_player", n = 2 } } }
    },
    ["SHA06"] = {
        id = "SHA06", name = "Healing Wave", cost = "{2}{W}", cmc = 3, color = "W", type = "Sorcery", class = "Shaman",
        text = "You or target creature you control regains 7 health.",
        art = "Interface\\Icons\\Spell_Nature_MagicImmunity",
        effect = { target = "friendly_any", ops = { { op = "heal", to = "target", n = 7 } } }
    },
    ["SHA07"] = {
        id = "SHA07", name = "Rockbiter Weapon", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Shaman",
        text = "Target creature you control gets +2/+0 until end of turn.",
        art = "Interface\\Icons\\Spell_Nature_RockBiter",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", p = 2 } } }
    },
    ["SHA08"] = {
        id = "SHA08", name = "Stoneskin Totem", cost = "{1}{G}", cmc = 2, color = "G", type = "Sorcery", class = "Shaman",
        text = "Creatures you control get +0/+2 until end of turn.",
        art = "Interface\\Icons\\Spell_Nature_StoneSkinTotem",
        effect = { ops = { { op = "buff", to = "friendly_creatures", t = 2 } } }
    },
    ["SHA09"] = {
        id = "SHA09", name = "Purge", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Shaman",
        text = "Remove beneficial effects from target enemy creature, or harmful effects from target creature you control.",
        art = "Interface\\Icons\\Spell_Holy_Dizzy",
        effect = { target = "creature", ops = { { op = "dispel", to = "target" } } }
    },
    ["SHA10"] = {
        id = "SHA10", name = "Ancestral Spirit", cost = "{4}{W}", cmc = 5, color = "W", type = "Sorcery", class = "Shaman",
        text = "Return a creature card from any graveyard to the battlefield under your control.",
        art = "Interface\\Icons\\Spell_Nature_Regenerate",
        effect = { ops = { { op = "raise", src = "any" } } }
    },

    -- MAGE
    ["MAG01"] = {
        id = "MAG01", name = "Fireball", cost = "{2}{R}", cmc = 3, color = "R", type = "Sorcery", class = "Mage",
        text = "Deal 3 damage to target enemy creature or the opponent. It takes 1 more damage at the start of each of your turns for 2 turns.",
        art = "Interface\\Icons\\Spell_Fire_FlameBolt",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 }, { op = "dot", to = "target", n = 1, turns = 2 } } }
    },
    ["MAG02"] = {
        id = "MAG02", name = "Fire Blast", cost = "{R}", cmc = 1, color = "R", type = "Sorcery", class = "Mage",
        text = "Deal 2 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Spell_Fire_Fireball",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 2 } } }
    },
    ["MAG03"] = {
        id = "MAG03", name = "Flamestrike", cost = "{3}{R}", cmc = 4, color = "R", type = "Sorcery", class = "Mage",
        text = "Deal 3 damage to each enemy creature.",
        art = "Interface\\Icons\\Spell_Fire_SelfDestruct",
        effect = { ops = { { op = "damage", to = "enemy_creatures", n = 3 } } }
    },
    ["MAG04"] = {
        id = "MAG04", name = "Pyroblast", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Sorcery", class = "Mage",
        text = "Deal 6 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Spell_Fire_Fireball02",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 6 } } }
    },
    ["MAG05"] = {
        id = "MAG05", name = "Frostbolt", cost = "{2}{U}", cmc = 3, color = "U", type = "Sorcery", class = "Mage",
        text = "Deal 3 damage to target enemy creature or the opponent. If it is a creature, tap it; it does not untap during its controller's next untap step.",
        art = "Interface\\Icons\\Spell_Frost_FrostBolt02",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 }, { op = "freeze", to = "target" } } }
    },
    ["MAG06"] = {
        id = "MAG06", name = "Frost Nova", cost = "{2}{U}", cmc = 3, color = "U", type = "Sorcery", class = "Mage",
        text = "Tap each enemy creature. They do not untap during their controller's next untap step.",
        art = "Interface\\Icons\\Spell_Frost_FrostNova",
        effect = { ops = { { op = "freeze", to = "enemy_creatures" } } }
    },
    ["MAG07"] = {
        id = "MAG07", name = "Blizzard", cost = "{3}{U}", cmc = 4, color = "U", type = "Sorcery", class = "Mage",
        text = "Deal 2 damage to each enemy creature and tap them.",
        art = "Interface\\Icons\\Spell_Frost_IceStorm",
        effect = { ops = { { op = "damage", to = "enemy_creatures", n = 2 }, { op = "tap", to = "enemy_creatures" } } }
    },
    ["MAG08"] = {
        id = "MAG08", name = "Polymorph", cost = "{1}{U}", cmc = 2, color = "U", type = "Sorcery", class = "Mage",
        text = "Put target enemy creature on top of its owner's library.",
        art = "Interface\\Icons\\Spell_Nature_Polymorph",
        effect = { target = "enemy_creature", ops = { { op = "tuck", to = "target" } } }
    },
    ["MAG09"] = {
        id = "MAG09", name = "Arcane Missiles", cost = "{1}{U}", cmc = 2, color = "U", type = "Sorcery", class = "Mage",
        text = "Deal 3 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Spell_Nature_StarFall",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 } } }
    },
    ["MAG10"] = {
        id = "MAG10", name = "Arcane Intellect", cost = "{2}{U}", cmc = 3, color = "U", type = "Sorcery", class = "Mage",
        text = "Draw 2 cards.",
        art = "Interface\\Icons\\Spell_Holy_MagicalSentry",
        effect = { ops = { { op = "draw", n = 2 } } }
    },

    -- WARLOCK
    ["WLK01"] = {
        id = "WLK01", name = "Shadow Bolt", cost = "{2}{B}", cmc = 3, color = "B", type = "Sorcery", class = "Warlock",
        text = "Deal 4 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 4 } } }
    },
    ["WLK02"] = {
        id = "WLK02", name = "Corruption", cost = "{1}{B}", cmc = 2, color = "B", type = "Sorcery", class = "Warlock",
        text = "Target enemy creature or the opponent takes 2 damage at the start of each of your turns for 3 turns.",
        art = "Interface\\Icons\\Spell_Shadow_AbominationExplosion",
        effect = { target = "enemy_any", ops = { { op = "dot", to = "target", n = 2, turns = 3 } } }
    },
    ["WLK03"] = {
        id = "WLK03", name = "Curse of Agony", cost = "{B}", cmc = 1, color = "B", type = "Sorcery", class = "Warlock",
        text = "Target enemy creature or the opponent takes 1 damage at the start of each of your turns for 4 turns.",
        art = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras",
        effect = { target = "enemy_any", ops = { { op = "dot", to = "target", n = 1, turns = 4 } } }
    },
    ["WLK04"] = {
        id = "WLK04", name = "Drain Life", cost = "{2}{B}", cmc = 3, color = "B", type = "Sorcery", class = "Warlock",
        text = "Deal 3 damage to target enemy creature or the opponent. You regain 3 health.",
        art = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 }, { op = "heal", to = "self_player", n = 3 } } }
    },
    ["WLK05"] = {
        id = "WLK05", name = "Howl of Terror", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Sorcery", class = "Warlock",
        text = "Tap each enemy creature. They do not untap during their controller's next untap step.",
        art = "Interface\\Icons\\Spell_Shadow_DeathScream",
        effect = { ops = { { op = "freeze", to = "enemy_creatures" } } }
    },
    ["WLK06"] = {
        id = "WLK06", name = "Death Coil", cost = "{2}{B}", cmc = 3, color = "B", type = "Sorcery", class = "Warlock",
        text = "Destroy target non-black enemy creature.",
        art = "Interface\\Icons\\Spell_Shadow_DeathCoil",
        effect = { target = "enemy_creature", ops = { { op = "destroy", to = "target", nonColor = "B" } } }
    },
    ["WLK07"] = {
        id = "WLK07", name = "Immolate", cost = "{1}{R}", cmc = 2, color = "R", type = "Sorcery", class = "Warlock",
        text = "Deal 2 damage to target enemy creature or the opponent. It takes 1 more damage at the start of each of your turns for 2 turns.",
        art = "Interface\\Icons\\Spell_Fire_Immolation",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 2 }, { op = "dot", to = "target", n = 1, turns = 2 } } }
    },
    ["WLK08"] = {
        id = "WLK08", name = "Soul Fire", cost = "{3}{R}", cmc = 4, color = "R", type = "Sorcery", class = "Warlock",
        text = "Deal 5 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Spell_Fire_SoulBurn",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 5 } } }
    },
    ["WLK09"] = {
        id = "WLK09", name = "Life Tap", cost = "{B}", cmc = 1, color = "B", type = "Sorcery", class = "Warlock",
        text = "You take 3 damage. Add {B}{B}{B} to your mana pool.",
        art = "Interface\\Icons\\Spell_Shadow_BurningSpirit",
        effect = { ops = { { op = "damage", to = "self_player", n = 3 }, { op = "mana", n = 3, color = "B" } } }
    },
    ["WLK10"] = {
        id = "WLK10", name = "Enslave Demon", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Sorcery", class = "Warlock",
        text = "Gain control of target enemy creature with power 3 or less.",
        art = "Interface\\Icons\\Spell_Shadow_EnslaveDemon",
        effect = { target = "enemy_creature", ops = { { op = "steal", to = "target", maxPower = 3, permanent = true } } }
    },

    -- DRUID
    ["DRU01"] = {
        id = "DRU01", name = "Wrath", cost = "{1}{G}", cmc = 2, color = "G", type = "Sorcery", class = "Druid",
        text = "Deal 3 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Spell_Nature_AbolishMagic",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 3 } } }
    },
    ["DRU02"] = {
        id = "DRU02", name = "Moonfire", cost = "{U}", cmc = 1, color = "U", type = "Sorcery", class = "Druid",
        text = "Deal 1 damage to target enemy creature or the opponent. It takes 1 more damage at the start of each of your turns for 2 turns.",
        art = "Interface\\Icons\\Spell_Nature_StarFall",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 1 }, { op = "dot", to = "target", n = 1, turns = 2 } } }
    },
    ["DRU03"] = {
        id = "DRU03", name = "Healing Touch", cost = "{2}{G}", cmc = 3, color = "G", type = "Sorcery", class = "Druid",
        text = "You or target creature you control regains 8 health.",
        art = "Interface\\Icons\\Spell_Nature_HealingTouch",
        effect = { target = "friendly_any", ops = { { op = "heal", to = "target", n = 8 } } }
    },
    ["DRU04"] = {
        id = "DRU04", name = "Rejuvenation", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Druid",
        text = "You or target creature you control regains 2 health at the start of each of your turns for 3 turns.",
        art = "Interface\\Icons\\Spell_Nature_Rejuvenation",
        effect = { target = "friendly_any", ops = { { op = "hot", to = "target", n = 2, turns = 3 } } }
    },
    ["DRU05"] = {
        id = "DRU05", name = "Regrowth", cost = "{1}{G}", cmc = 2, color = "G", type = "Sorcery", class = "Druid",
        text = "You or target creature you control regains 3 health, then regains 1 health at the start of each of your turns for 3 turns.",
        art = "Interface\\Icons\\Spell_Nature_ResistNature",
        effect = { target = "friendly_any", ops = { { op = "heal", to = "target", n = 3 }, { op = "hot", to = "target", n = 1, turns = 3 } } }
    },
    ["DRU06"] = {
        id = "DRU06", name = "Mark of the Wild", cost = "{1}{G}", cmc = 2, color = "G", type = "Sorcery", class = "Druid",
        text = "Target creature you control permanently gets +1/+1.",
        art = "Interface\\Icons\\Spell_Nature_Regeneration",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", p = 1, t = 1, perm = true } } }
    },
    ["DRU07"] = {
        id = "DRU07", name = "Entangling Roots", cost = "{1}{G}", cmc = 2, color = "G", type = "Sorcery", class = "Druid",
        text = "Tap target enemy creature. It does not untap during its controller's next untap step.",
        art = "Interface\\Icons\\Spell_Nature_StrangleVines",
        effect = { target = "enemy_creature", ops = { { op = "freeze", to = "target" } } }
    },
    ["DRU08"] = {
        id = "DRU08", name = "Thorns", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Druid",
        text = "Target creature you control gets +1/+1 and gains Deathtouch until end of turn.",
        art = "Interface\\Icons\\Spell_Nature_Thorns",
        effect = { target = "friendly_creature", ops = { { op = "buff", to = "target", p = 1, t = 1, kw = { "deathtouch" } } } }
    },
    ["DRU09"] = {
        id = "DRU09", name = "Innervate", cost = "{G}", cmc = 1, color = "G", type = "Sorcery", class = "Druid",
        text = "Add {G}{G}{G} to your mana pool.",
        art = "Interface\\Icons\\Spell_Nature_Lightning",
        effect = { ops = { { op = "mana", n = 3, color = "G" } } }
    },
    ["DRU10"] = {
        id = "DRU10", name = "Starfire", cost = "{3}{U}", cmc = 4, color = "U", type = "Sorcery", class = "Druid",
        text = "Deal 5 damage to target enemy creature or the opponent.",
        art = "Interface\\Icons\\Spell_Nature_StarFall",
        effect = { target = "enemy_any", ops = { { op = "damage", to = "target", n = 5 } } }
    },

    -- =========================================================================
    -- ZONE CREATURES (10 per zone) - UNLOCKED BY KILLING THEM (isBoss = true reuses BossTracker as-is)
    -- Names / displayIds / creatureId come from the classicdb creature_template table.
    -- =========================================================================

    -- ELWYNN FOREST
    ["ELW01"] = {
        id = "ELW01", name = "Kobold Vermin", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 10913,
        zone = "Elwynn Forest", creatureType = "Humanoid", faction = "Kobold", npcId = 6,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ELW02"] = {
        id = "ELW02", name = "Kobold Worker", cost = "{W}", cmc = 1, color = "W", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 10912,
        zone = "Elwynn Forest", creatureType = "Humanoid", faction = "Kobold", npcId = 257,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ELW03"] = {
        id = "ELW03", name = "Defias Thug", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 5035,
        zone = "Elwynn Forest", creatureType = "Humanoid", faction = "Defias", npcId = 38,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ELW04"] = {
        id = "ELW04", name = "Stonetusk Boar", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 503,
        zone = "Elwynn Forest", creatureType = "Beast", npcId = 113,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ELW05"] = {
        id = "ELW05", name = "Kobold Tunneler", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 2, toughness = 3, isMob = true, isBoss = true, displayId = 139,
        zone = "Elwynn Forest", creatureType = "Humanoid", faction = "Kobold", npcId = 475,
        anthem = { tag = "faction", value = "Kobold", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Kobolds you control get +1/+0."
    },
    ["ELW06"] = {
        id = "ELW06", name = "Porcine Entourage", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 377,
        zone = "Elwynn Forest", creatureType = "Beast", npcId = 390,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ELW07"] = {
        id = "ELW07", name = "Defias Rogue Wizard", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 3, toughness = 4, firstStrike = true, isMob = true, isBoss = true, displayId = 2359,
        zone = "Elwynn Forest", creatureType = "Humanoid", faction = "Defias", npcId = 474,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["ELW08"] = {
        id = "ELW08", name = "Murloc Forager", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 441,
        zone = "Elwynn Forest", creatureType = "Humanoid", faction = "Murloc", npcId = 46,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ELW09"] = {
        id = "ELW09", name = "Murloc Lurker", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 983,
        zone = "Elwynn Forest", creatureType = "Humanoid", faction = "Murloc", npcId = 732,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ELW10"] = {
        id = "ELW10", name = "Gruff Swiftbite", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 8, toughness = 8, isMob = true, isBoss = true, displayId = 175,
        zone = "Elwynn Forest", creatureType = "Humanoid", npcId = 100,
        anthem = { tag = "zone", value = "Elwynn Forest", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Elwynn Forest creatures you control get +1/+1."
    },

    -- DUN MOROGH
    ["DUN01"] = {
        id = "DUN01", name = "Ragged Young Wolf", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 855,
        zone = "Dun Morogh", creatureType = "Beast", npcId = 705,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["DUN02"] = {
        id = "DUN02", name = "Burly Rockjaw Trogg", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 611,
        zone = "Dun Morogh", creatureType = "Humanoid", npcId = 724,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DUN03"] = {
        id = "DUN03", name = "Ragged Timber Wolf", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 11416,
        zone = "Dun Morogh", creatureType = "Beast", npcId = 704,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["DUN04"] = {
        id = "DUN04", name = "Frostmane Troll Whelp", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 5606,
        zone = "Dun Morogh", creatureType = "Humanoid", faction = "Troll", npcId = 706,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DUN05"] = {
        id = "DUN05", name = "Crag Boar", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 607,
        zone = "Dun Morogh", creatureType = "Beast", npcId = 1125,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DUN06"] = {
        id = "DUN06", name = "Wendigo", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 950,
        zone = "Dun Morogh", creatureType = "Humanoid", npcId = 1135,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DUN07"] = {
        id = "DUN07", name = "Snow Leopard", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 3, haste = true, isMob = true, isBoss = true, displayId = 954,
        zone = "Dun Morogh", creatureType = "Beast", npcId = 1201,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["DUN08"] = {
        id = "DUN08", name = "Winter Wolf", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 6, toughness = 4, isMob = true, isBoss = true, displayId = 785,
        zone = "Dun Morogh", creatureType = "Beast", npcId = 1131,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DUN09"] = {
        id = "DUN09", name = "Ice Claw Bear", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 4, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 8840,
        zone = "Dun Morogh", creatureType = "Beast", npcId = 1196,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["DUN10"] = {
        id = "DUN10", name = "Hammerspine", cost = "{5}{G}{G}", cmc = 7, color = "G", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 830,
        zone = "Dun Morogh", creatureType = "Humanoid", npcId = 1119,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },

    -- TIRISFAL GLADES
    ["TIR01"] = {
        id = "TIR01", name = "Mindless Zombie", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 10973,
        zone = "Tirisfal Glades", creatureType = "Undead", npcId = 1501,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TIR02"] = {
        id = "TIR02", name = "Wretched Zombie", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 10979,
        zone = "Tirisfal Glades", creatureType = "Undead", npcId = 1502,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TIR03"] = {
        id = "TIR03", name = "Young Night Web Spider", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 513,
        zone = "Tirisfal Glades", creatureType = "Beast", npcId = 1504,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["TIR04"] = {
        id = "TIR04", name = "Decrepit Darkhound", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 9021,
        zone = "Tirisfal Glades", creatureType = "Demon", npcId = 1547,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TIR05"] = {
        id = "TIR05", name = "Rotting Dead", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 1200,
        zone = "Tirisfal Glades", creatureType = "Undead", npcId = 1525,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TIR06"] = {
        id = "TIR06", name = "Greater Duskbat", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 2, flying = true, lifelink = true, isMob = true, isBoss = true, displayId = 4734,
        zone = "Tirisfal Glades", creatureType = "Beast", npcId = 1553,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying, Lifelink."
    },
    ["TIR07"] = {
        id = "TIR07", name = "Vile Fin Minor Oracle", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 3, toughness = 5, isMob = true, isBoss = true, displayId = 1005,
        zone = "Tirisfal Glades", creatureType = "Humanoid", faction = "Murloc", npcId = 1544,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TIR08"] = {
        id = "TIR08", name = "Vile Fin Muckdweller", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 346,
        zone = "Tirisfal Glades", creatureType = "Humanoid", faction = "Murloc", npcId = 1545,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TIR09"] = {
        id = "TIR09", name = "Scarlet Vanguard", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 5, toughness = 6, vigilance = true, isMob = true, isBoss = true, displayId = 2481,
        zone = "Tirisfal Glades", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 1540,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["TIR10"] = {
        id = "TIR10", name = "Fellicent's Shade", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 7, toughness = 9, isMob = true, isBoss = true, displayId = 5430,
        zone = "Tirisfal Glades", creatureType = "Undead", npcId = 10358,
        anthem = { tag = "type", value = "Undead", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Undead you control get +1/+0."
    },

    -- WESTFALL
    ["WES01"] = {
        id = "WES01", name = "Coyote", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 643,
        zone = "Westfall", creatureType = "Beast", npcId = 834,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["WES02"] = {
        id = "WES02", name = "Defias Smuggler", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 1, firstStrike = true, isMob = true, isBoss = true, displayId = 4418,
        zone = "Westfall", creatureType = "Humanoid", faction = "Defias", npcId = 95,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["WES03"] = {
        id = "WES03", name = "Harvest Golem", cost = "{1}{W}", cmc = 2, color = "W", type = "Creature",
        power = 1, toughness = 5, defender = true, isMob = true, isBoss = true, displayId = 367,
        zone = "Westfall", creatureType = "Mechanical", npcId = 36,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Defender."
    },
    ["WES04"] = {
        id = "WES04", name = "Fleshripper", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, flying = true, isMob = true, isBoss = true, displayId = 2305,
        zone = "Westfall", creatureType = "Beast", npcId = 1109,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["WES05"] = {
        id = "WES05", name = "Goretusk", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 3027,
        zone = "Westfall", creatureType = "Beast", npcId = 157,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["WES06"] = {
        id = "WES06", name = "Harvest Watcher", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 1, toughness = 7, defender = true, isMob = true, isBoss = true, displayId = 378,
        zone = "Westfall", creatureType = "Mechanical", npcId = 114,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Defender."
    },
    ["WES07"] = {
        id = "WES07", name = "Defias Digger", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 2441,
        zone = "Westfall", creatureType = "Humanoid", faction = "Defias", npcId = 824,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WES08"] = {
        id = "WES08", name = "Riverpaw Bandit", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 4, toughness = 5, firstStrike = true, isMob = true, isBoss = true, displayId = 383,
        zone = "Westfall", creatureType = "Humanoid", faction = "Gnoll", npcId = 452,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["WES09"] = {
        id = "WES09", name = "Shore Crawler", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 4, toughness = 8, isMob = true, isBoss = true, displayId = 9570,
        zone = "Westfall", creatureType = "Beast", npcId = 1216,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WES10"] = {
        id = "WES10", name = "Vultros", cost = "{5}{G}{G}", cmc = 7, color = "G", type = "Creature",
        power = 7, toughness = 7, flying = true, isMob = true, isBoss = true, displayId = 507,
        zone = "Westfall", creatureType = "Beast", npcId = 462,
        anthem = { tag = "zone", value = "Westfall", p = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Flying. Other Westfall creatures you control get +1/+0."
    },

    -- LOCH MODAN
    ["LOC01"] = {
        id = "LOC01", name = "Tunnel Rat Vermin", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 10913,
        zone = "Loch Modan", creatureType = "Humanoid", faction = "Kobold", npcId = 1172,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["LOC02"] = {
        id = "LOC02", name = "Forest Lurker", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, reach = true, isMob = true, isBoss = true, displayId = 827,
        zone = "Loch Modan", creatureType = "Beast", npcId = 1195,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["LOC03"] = {
        id = "LOC03", name = "Loch Frenzy", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 1004,
        zone = "Loch Modan", creatureType = "Beast", npcId = 1193,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["LOC04"] = {
        id = "LOC04", name = "Grizzled Black Bear", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 762,
        zone = "Loch Modan", creatureType = "Beast", npcId = 1188,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["LOC05"] = {
        id = "LOC05", name = "Mangy Mountain Boar", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 3027,
        zone = "Loch Modan", creatureType = "Beast", npcId = 1191,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["LOC06"] = {
        id = "LOC06", name = "Mountain Buzzard", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 2, flying = true, isMob = true, isBoss = true, displayId = 410,
        zone = "Loch Modan", creatureType = "Beast", npcId = 1194,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["LOC07"] = {
        id = "LOC07", name = "Elder Mountain Boar", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 3, toughness = 4, trample = true, isMob = true, isBoss = true, displayId = 1208,
        zone = "Loch Modan", creatureType = "Beast", npcId = 1192,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["LOC08"] = {
        id = "LOC08", name = "Black Bear Patriarch", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 4, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 762,
        zone = "Loch Modan", creatureType = "Beast", npcId = 1189,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["LOC09"] = {
        id = "LOC09", name = "Young Threshadon", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 867,
        zone = "Loch Modan", creatureType = "Beast", npcId = 1224,
        modelCam = { zoom = 0.54, camScale = 1.22, z = -0.14, rotation = 0.15 },
        text = ""
    },
    ["LOC10"] = {
        id = "LOC10", name = "Large Loch Crocolisk", cost = "{5}{G}{G}", cmc = 7, color = "G", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 831,
        zone = "Loch Modan", creatureType = "Beast", npcId = 2476,
        modelCam = { zoom = 0.81, camScale = 1.03, z = -0.11, rotation = 0.15 },
        text = ""
    },

    -- SILVERPINE FOREST
    ["SIL01"] = {
        id = "SIL01", name = "Moonrage Whitescalp", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 11180,
        zone = "Silverpine Forest", creatureType = "Humanoid", faction = "Worgen", npcId = 1769,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SIL02"] = {
        id = "SIL02", name = "Mottled Worg", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 246,
        zone = "Silverpine Forest", creatureType = "Beast", npcId = 1766,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["SIL03"] = {
        id = "SIL03", name = "Ferocious Grizzled Bear", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 1006,
        zone = "Silverpine Forest", creatureType = "Beast", npcId = 1778,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SIL04"] = {
        id = "SIL04", name = "Moonrage Glutton", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 1947,
        zone = "Silverpine Forest", creatureType = "Humanoid", faction = "Worgen", npcId = 1779,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SIL05"] = {
        id = "SIL05", name = "Vile Fin Shredder", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 441,
        zone = "Silverpine Forest", creatureType = "Humanoid", faction = "Murloc", npcId = 1767,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SIL06"] = {
        id = "SIL06", name = "Giant Grizzled Bear", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 4, isMob = true, isBoss = true, displayId = 820,
        zone = "Silverpine Forest", creatureType = "Beast", npcId = 1797,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SIL07"] = {
        id = "SIL07", name = "Mist Creeper", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 3, toughness = 3, deathtouch = true, isMob = true, isBoss = true, displayId = 760,
        zone = "Silverpine Forest", creatureType = "Beast", npcId = 1781,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["SIL08"] = {
        id = "SIL08", name = "Bloodsnout Worg", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 6, toughness = 4, isMob = true, isBoss = true, displayId = 741,
        zone = "Silverpine Forest", creatureType = "Beast", npcId = 1923,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SIL09"] = {
        id = "SIL09", name = "Ravenclaw Guardian", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 5, toughness = 6, vigilance = true, isMob = true, isBoss = true, displayId = 370,
        zone = "Silverpine Forest", creatureType = "Undead", npcId = 1973,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["SIL10"] = {
        id = "SIL10", name = "Ravenclaw Regent", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 8, toughness = 9, vigilance = true, isMob = true, isBoss = true, displayId = 1019,
        zone = "Silverpine Forest", creatureType = "Undead", npcId = 2283,
        modelCam = { zoom = 0.63, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Vigilance."
    },

    -- REDRIDGE MOUNTAINS
    ["RED01"] = {
        id = "RED01", name = "Gray Forest Wolf", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 380,
        zone = "Redridge Mountains", creatureType = "Beast", npcId = 1922,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["RED02"] = {
        id = "RED02", name = "Tarantula", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, reach = true, isMob = true, isBoss = true, displayId = 366,
        zone = "Redridge Mountains", creatureType = "Beast", npcId = 442,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["RED03"] = {
        id = "RED03", name = "Redridge Poacher", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 551,
        zone = "Redridge Mountains", creatureType = "Humanoid", faction = "Gnoll", npcId = 424,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["RED04"] = {
        id = "RED04", name = "Redridge Mystic", cost = "{1}{W}", cmc = 2, color = "W", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 10789,
        zone = "Redridge Mountains", creatureType = "Humanoid", faction = "Gnoll", npcId = 430,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["RED05"] = {
        id = "RED05", name = "Murloc Flesheater", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 506,
        zone = "Redridge Mountains", creatureType = "Humanoid", faction = "Murloc", npcId = 422,
        modelCam = { zoom = 0.73, camScale = 1.08, z = -0.12, rotation = 0.15 },
        text = ""
    },
    ["RED06"] = {
        id = "RED06", name = "Redridge Basher", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 2, toughness = 3, isMob = true, isBoss = true, displayId = 609,
        zone = "Redridge Mountains", creatureType = "Humanoid", faction = "Gnoll", npcId = 446,
        anthem = { tag = "faction", value = "Gnoll", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Gnolls you control get +1/+0."
    },
    ["RED07"] = {
        id = "RED07", name = "Murloc Scout", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 3, toughness = 4, haste = true, isMob = true, isBoss = true, displayId = 391,
        zone = "Redridge Mountains", creatureType = "Humanoid", faction = "Murloc", npcId = 578,
        modelCam = { zoom = 0.68, camScale = 1.12, z = -0.12, rotation = 0.15 },
        text = "Haste."
    },
    ["RED08"] = {
        id = "RED08", name = "Blackrock Champion", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 5, toughness = 4, vigilance = true, isMob = true, isBoss = true, displayId = 6044,
        zone = "Redridge Mountains", creatureType = "Humanoid", faction = "Blackrock", npcId = 435,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["RED09"] = {
        id = "RED09", name = "Squiddic", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 5243,
        zone = "Redridge Mountains", creatureType = "Humanoid", faction = "Murloc", npcId = 14270,
        anthem = { tag = "faction", value = "Murloc", p = 1, t = 1 },
        modelCam = { zoom = 0.68, camScale = 1.12, z = -0.12, rotation = 0.15 },
        text = "Other Murlocs you control get +1/+1."
    },
    ["RED10"] = {
        id = "RED10", name = "Kazon", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 6041,
        zone = "Redridge Mountains", creatureType = "Humanoid", faction = "Blackrock", npcId = 584,
        modelCam = { zoom = 0.58, camScale = 1.20, z = -0.14, rotation = 0.15 },
        text = ""
    },

    -- DUSKWOOD
    ["DSK01"] = {
        id = "DSK01", name = "Skeletal Warrior", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 200,
        zone = "Duskwood", creatureType = "Undead", npcId = 48,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DSK02"] = {
        id = "DSK02", name = "Young Black Ravager", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 246,
        zone = "Duskwood", creatureType = "Beast", npcId = 923,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["DSK03"] = {
        id = "DSK03", name = "Skeletal Horror", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 9786,
        zone = "Duskwood", creatureType = "Undead", npcId = 202,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DSK04"] = {
        id = "DSK04", name = "Black Widow Hatchling", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 368,
        zone = "Duskwood", creatureType = "Beast", npcId = 930,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["DSK05"] = {
        id = "DSK05", name = "Defias Night Runner", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 2, haste = true, firstStrike = true, isMob = true, isBoss = true, displayId = 4276,
        zone = "Duskwood", creatureType = "Humanoid", faction = "Defias", npcId = 215,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike, Haste."
    },
    ["DSK06"] = {
        id = "DSK06", name = "Carrion Recluse", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 2, deathtouch = true, isMob = true, isBoss = true, displayId = 545,
        zone = "Duskwood", creatureType = "Beast", npcId = 949,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["DSK07"] = {
        id = "DSK07", name = "Nightbane Worgen", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 657,
        zone = "Duskwood", creatureType = "Humanoid", faction = "Worgen", npcId = 898,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DSK08"] = {
        id = "DSK08", name = "Plague Spreader", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 4, toughness = 6, isMob = true, isBoss = true, displayId = 519,
        zone = "Duskwood", creatureType = "Undead", npcId = 604,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DSK09"] = {
        id = "DSK09", name = "Nightbane Dark Runner", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 5, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 736,
        zone = "Duskwood", creatureType = "Humanoid", faction = "Worgen", npcId = 205,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["DSK10"] = {
        id = "DSK10", name = "Nefaru", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 11181,
        zone = "Duskwood", creatureType = "Humanoid", npcId = 534,
        modelCam = { zoom = 0.77, camScale = 1.06, z = -0.11, rotation = 0.15 },
        text = ""
    },

    -- HILLSBRAD FOOTHILLS
    ["HIL01"] = {
        id = "HIL01", name = "Rot Hide Brute", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 10851,
        zone = "Hillsbrad Foothills", creatureType = "Undead", faction = "Gnoll", npcId = 1939,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIL02"] = {
        id = "HIL02", name = "Rot Hide Plague Weaver", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 10855,
        zone = "Hillsbrad Foothills", creatureType = "Undead", faction = "Gnoll", npcId = 1940,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIL03"] = {
        id = "HIL03", name = "Raging Rot Hide", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 10856,
        zone = "Hillsbrad Foothills", creatureType = "Undead", faction = "Gnoll", npcId = 1943,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIL04"] = {
        id = "HIL04", name = "Elder Lake Creeper", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 631,
        zone = "Hillsbrad Foothills", creatureType = "Elemental", npcId = 1956,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIL05"] = {
        id = "HIL05", name = "Syndicate Watchman", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 3, vigilance = true, isMob = true, isBoss = true, displayId = 3623,
        zone = "Hillsbrad Foothills", creatureType = "Humanoid", faction = "Syndicate", npcId = 2261,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["HIL06"] = {
        id = "HIL06", name = "Vicious Gray Bear", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 4, isMob = true, isBoss = true, displayId = 1007,
        zone = "Hillsbrad Foothills", creatureType = "Beast", npcId = 2354,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIL07"] = {
        id = "HIL07", name = "Starving Mountain Lion", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 4, toughness = 3, haste = true, isMob = true, isBoss = true, displayId = 1059,
        zone = "Hillsbrad Foothills", creatureType = "Beast", npcId = 2384,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["HIL08"] = {
        id = "HIL08", name = "Hillsbrad Miner", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 3629,
        zone = "Hillsbrad Foothills", creatureType = "Humanoid", npcId = 2269,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIL09"] = {
        id = "HIL09", name = "Witherbark Headhunter", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 3997,
        zone = "Hillsbrad Foothills", creatureType = "Humanoid", faction = "Troll", npcId = 2556,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIL10"] = {
        id = "HIL10", name = "Zalas Witherbark", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 4003,
        zone = "Hillsbrad Foothills", creatureType = "Humanoid", npcId = 2605,
        modelCam = { zoom = 0.58, camScale = 1.19, z = -0.14, rotation = 0.15 },
        text = ""
    },

    -- WETLANDS
    ["WET01"] = {
        id = "WET01", name = "Young Wetlands Crocolisk", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 2, toughness = 1, isMob = true, isBoss = true, displayId = 1035,
        zone = "Wetlands", creatureType = "Beast", npcId = 1417,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WET02"] = {
        id = "WET02", name = "Mosshide Fenrunner", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 714,
        zone = "Wetlands", creatureType = "Humanoid", faction = "Gnoll", npcId = 1010,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["WET03"] = {
        id = "WET03", name = "Mottled Raptor", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 960,
        zone = "Wetlands", creatureType = "Beast", npcId = 1020,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["WET04"] = {
        id = "WET04", name = "Crimson Whelp", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 505,
        zone = "Wetlands", creatureType = "Dragonkin", faction = "Scarlet Crusade", npcId = 1069,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WET05"] = {
        id = "WET05", name = "Dragonmaw Raider", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 4916,
        zone = "Wetlands", creatureType = "Humanoid", npcId = 1034,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WET06"] = {
        id = "WET06", name = "Highland Razormaw", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 180,
        zone = "Wetlands", creatureType = "Beast", npcId = 1018,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["WET07"] = {
        id = "WET07", name = "Syndicate Highwayman", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 4, firstStrike = true, isMob = true, isBoss = true, displayId = 3984,
        zone = "Wetlands", creatureType = "Humanoid", faction = "Syndicate", npcId = 2586,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["WET08"] = {
        id = "WET08", name = "Rumbling Exile", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 4, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 9587,
        zone = "Wetlands", creatureType = "Elemental", npcId = 2592,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["WET09"] = {
        id = "WET09", name = "Burning Exile", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 5, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 2172,
        zone = "Wetlands", creatureType = "Elemental", npcId = 2760,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["WET10"] = {
        id = "WET10", name = "Molok the Crusher", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 9, toughness = 8, trample = true, isMob = true, isBoss = true, displayId = 536,
        zone = "Wetlands", creatureType = "Humanoid", faction = "Ogre", npcId = 2604,
        modelCam = { zoom = 0.73, camScale = 1.08, z = -0.12, rotation = 0.15 },
        text = "Trample."
    },

    -- ALTERAC MOUNTAINS
    ["ALT01"] = {
        id = "ALT01", name = "Mountain Yeti", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 1050,
        zone = "Alterac Mountains", creatureType = "Humanoid", npcId = 2250,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ALT02"] = {
        id = "ALT02", name = "Syndicate Thief", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 1, firstStrike = true, isMob = true, isBoss = true, displayId = 3709,
        zone = "Alterac Mountains", creatureType = "Humanoid", faction = "Syndicate", npcId = 2241,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["ALT03"] = {
        id = "ALT03", name = "Giant Yeti", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 6767,
        zone = "Alterac Mountains", creatureType = "Humanoid", npcId = 2251,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ALT04"] = {
        id = "ALT04", name = "Hulking Mountain Lion", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 2300,
        zone = "Alterac Mountains", creatureType = "Beast", npcId = 2407,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["ALT05"] = {
        id = "ALT05", name = "Syndicate Wizard", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 2, toughness = 4, isMob = true, isBoss = true, displayId = 3712,
        zone = "Alterac Mountains", creatureType = "Humanoid", faction = "Syndicate", npcId = 2319,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ALT06"] = {
        id = "ALT06", name = "Crushridge Ogre", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 2, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 11567,
        zone = "Alterac Mountains", creatureType = "Humanoid", faction = "Ogre", npcId = 2252,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["ALT07"] = {
        id = "ALT07", name = "Crushridge Brute", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 4, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 610,
        zone = "Alterac Mountains", creatureType = "Humanoid", faction = "Ogre", npcId = 2253,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["ALT08"] = {
        id = "ALT08", name = "Syndicate Assassin", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 4, toughness = 5, firstStrike = true, isMob = true, isBoss = true, displayId = 3727,
        zone = "Alterac Mountains", creatureType = "Humanoid", faction = "Syndicate", npcId = 2246,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["ALT09"] = {
        id = "ALT09", name = "Crushridge Mage", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 6, toughness = 8, isMob = true, isBoss = true, displayId = 6705,
        zone = "Alterac Mountains", creatureType = "Humanoid", faction = "Ogre", npcId = 2255,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ALT10"] = {
        id = "ALT10", name = "Crushridge Warmonger", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 536,
        zone = "Alterac Mountains", creatureType = "Humanoid", faction = "Ogre", npcId = 2287,
        modelCam = { zoom = 0.73, camScale = 1.08, z = -0.12, rotation = 0.15 },
        text = ""
    },

    -- ARATHI HIGHLANDS
    ["ARA01"] = {
        id = "ARA01", name = "Drywhisker Kobold", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 2153,
        zone = "Arathi Highlands", creatureType = "Humanoid", faction = "Kobold", npcId = 2572,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ARA02"] = {
        id = "ARA02", name = "Elder Mesa Buzzard", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 1, flying = true, isMob = true, isBoss = true, displayId = 388,
        zone = "Arathi Highlands", creatureType = "Beast", npcId = 2580,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["ARA03"] = {
        id = "ARA03", name = "Cresting Exile", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 5561,
        zone = "Arathi Highlands", creatureType = "Elemental", npcId = 2761,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["ARA04"] = {
        id = "ARA04", name = "Thundering Exile", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 5490,
        zone = "Arathi Highlands", creatureType = "Elemental", npcId = 2762,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ARA05"] = {
        id = "ARA05", name = "Daggerspine Raider", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 11254,
        zone = "Arathi Highlands", creatureType = "Humanoid", npcId = 2595,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ARA06"] = {
        id = "ARA06", name = "Syndicate Prowler", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 4, haste = true, isMob = true, isBoss = true, displayId = 4016,
        zone = "Arathi Highlands", creatureType = "Humanoid", faction = "Syndicate", npcId = 2588,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["ARA07"] = {
        id = "ARA07", name = "Stromgarde Troll Hunter", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 4, toughness = 4, trample = true, vigilance = true, isMob = true, isBoss = true, displayId = 4139,
        zone = "Arathi Highlands", creatureType = "Humanoid", npcId = 2583,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample, Vigilance."
    },
    ["ARA08"] = {
        id = "ARA08", name = "Boulderfist Shaman", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 5, toughness = 7, isMob = true, isBoss = true, displayId = 416,
        zone = "Arathi Highlands", creatureType = "Humanoid", faction = "Ogre", npcId = 2570,
        modelCam = { zoom = 0.77, camScale = 1.06, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["ARA09"] = {
        id = "ARA09", name = "Darbel Montrose", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 6, toughness = 7, isMob = true, isBoss = true, displayId = 4027,
        zone = "Arathi Highlands", creatureType = "Humanoid", faction = "Syndicate", npcId = 2598,
        anthem = { tag = "faction", value = "Syndicate", p = 1, t = 1 },
        modelCam = { zoom = 0.68, camScale = 1.12, z = -0.12, rotation = 0.15 },
        text = "Other Syndicate you control get +1/+1."
    },
    ["ARA10"] = {
        id = "ARA10", name = "Foulbelly", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 10, toughness = 10, isMob = true, isBoss = true, displayId = 11551,
        zone = "Arathi Highlands", creatureType = "Humanoid", faction = "Ogre", npcId = 2601,
        modelCam = { zoom = 0.68, camScale = 1.12, z = -0.12, rotation = 0.15 },
        text = ""
    },

    -- STRANGLETHORN VALE
    ["STV01"] = {
        id = "STV01", name = "Young Panther", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 2437,
        zone = "Stranglethorn Vale", creatureType = "Beast", npcId = 683,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["STV02"] = {
        id = "STV02", name = "Kurzen Medicine Man", cost = "{W}", cmc = 1, color = "W", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 4436,
        zone = "Stranglethorn Vale", creatureType = "Humanoid", npcId = 940,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STV03"] = {
        id = "STV03", name = "Stranglethorn Tiger", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 320,
        zone = "Stranglethorn Vale", creatureType = "Beast", npcId = 682,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["STV04"] = {
        id = "STV04", name = "Venture Co. Geologist", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 7197,
        zone = "Stranglethorn Vale", creatureType = "Humanoid", faction = "Venture Co.", npcId = 1096,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STV05"] = {
        id = "STV05", name = "Stranglethorn Tigress", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 614,
        zone = "Stranglethorn Vale", creatureType = "Beast", npcId = 772,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["STV06"] = {
        id = "STV06", name = "Jungle Thunderer", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 845,
        zone = "Stranglethorn Vale", creatureType = "Beast", npcId = 1114,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STV07"] = {
        id = "STV07", name = "Elder Mistvale Gorilla", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 4, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 838,
        zone = "Stranglethorn Vale", creatureType = "Beast", npcId = 1557,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["STV08"] = {
        id = "STV08", name = "Venture Co. Strip Miner", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 7202,
        zone = "Stranglethorn Vale", creatureType = "Humanoid", faction = "Venture Co.", npcId = 674,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STV09"] = {
        id = "STV09", name = "Southern Sand Crawler", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 4, toughness = 8, isMob = true, isBoss = true, displayId = 9573,
        zone = "Stranglethorn Vale", creatureType = "Beast", npcId = 2544,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STV10"] = {
        id = "STV10", name = "Lord Sakrasis", cost = "{5}{U}{U}", cmc = 7, color = "U", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 4910,
        zone = "Stranglethorn Vale", creatureType = "Humanoid", npcId = 2541,
        modelCam = { zoom = 0.58, camScale = 1.20, z = -0.14, rotation = 0.15 },
        text = ""
    },

    -- BADLANDS
    ["BAD01"] = {
        id = "BAD01", name = "Shadowforge Tunneler", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 4932,
        zone = "Badlands", creatureType = "Humanoid", faction = "Dark Iron", npcId = 2739,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BAD02"] = {
        id = "BAD02", name = "Shadowforge Darkweaver", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 4933,
        zone = "Badlands", creatureType = "Humanoid", faction = "Dark Iron", npcId = 2740,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BAD03"] = {
        id = "BAD03", name = "Starving Buzzard", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 1, flying = true, isMob = true, isBoss = true, displayId = 10824,
        zone = "Badlands", creatureType = "Beast", npcId = 2829,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["BAD04"] = {
        id = "BAD04", name = "Ridge Huntress", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, firstStrike = true, isMob = true, isBoss = true, displayId = 1055,
        zone = "Badlands", creatureType = "Beast", npcId = 2732,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["BAD05"] = {
        id = "BAD05", name = "Rock Elemental", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 1, toughness = 7, defender = true, isMob = true, isBoss = true, displayId = 171,
        zone = "Badlands", creatureType = "Elemental", npcId = 92,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Defender."
    },
    ["BAD06"] = {
        id = "BAD06", name = "Scalding Whelp", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 2, toughness = 2, flying = true, isMob = true, isBoss = true, displayId = 715,
        zone = "Badlands", creatureType = "Dragonkin", npcId = 2725,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["BAD07"] = {
        id = "BAD07", name = "Dark Iron Kidnapper", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 7789,
        zone = "Badlands", creatureType = "Humanoid", faction = "Dark Iron", npcId = 15692,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BAD08"] = {
        id = "BAD08", name = "Shadowforge Surveyor", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 6051,
        zone = "Badlands", creatureType = "Humanoid", faction = "Dark Iron", npcId = 4844,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BAD09"] = {
        id = "BAD09", name = "Shadowforge Digger", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 7, toughness = 7, isMob = true, isBoss = true, displayId = 6052,
        zone = "Badlands", creatureType = "Humanoid", faction = "Dark Iron", npcId = 4846,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BAD10"] = {
        id = "BAD10", name = "Anathemus", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 10, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 10040,
        zone = "Badlands", creatureType = "Giant", npcId = 2754,
        modelCam = { zoom = 0.64, camScale = 1.15, z = -0.13, rotation = 0.15 },
        text = "Trample."
    },

    -- SWAMP OF SORROWS
    ["SWA01"] = {
        id = "SWA01", name = "Young Sawtooth Crocolisk", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 2, toughness = 1, isMob = true, isBoss = true, displayId = 814,
        zone = "Swamp of Sorrows", creatureType = "Beast", npcId = 1084,
        modelCam = { zoom = 0.80, camScale = 1.03, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["SWA02"] = {
        id = "SWA02", name = "Sorrow Spinner", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, reach = true, isMob = true, isBoss = true, displayId = 2543,
        zone = "Swamp of Sorrows", creatureType = "Beast", npcId = 858,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["SWA03"] = {
        id = "SWA03", name = "Lost One Hunter", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 152,
        zone = "Swamp of Sorrows", creatureType = "Humanoid", npcId = 759,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SWA04"] = {
        id = "SWA04", name = "Shadow Panther", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 633,
        zone = "Swamp of Sorrows", creatureType = "Beast", npcId = 768,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["SWA05"] = {
        id = "SWA05", name = "Tangled Horror", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 697,
        zone = "Swamp of Sorrows", creatureType = "Elemental", npcId = 766,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["SWA06"] = {
        id = "SWA06", name = "Silt Crawler", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 2, toughness = 4, isMob = true, isBoss = true, displayId = 9571,
        zone = "Swamp of Sorrows", creatureType = "Beast", npcId = 922,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SWA07"] = {
        id = "SWA07", name = "Sawtooth Snapper", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 815,
        zone = "Swamp of Sorrows", creatureType = "Beast", npcId = 1087,
        modelCam = { zoom = 0.70, camScale = 1.11, z = -0.12, rotation = 0.15 },
        text = ""
    },
    ["SWA08"] = {
        id = "SWA08", name = "Witherbark Sadist", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 6489,
        zone = "Swamp of Sorrows", creatureType = "Humanoid", faction = "Troll", npcId = 2653,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SWA09"] = {
        id = "SWA09", name = "Witherbark Broodguard", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 4, toughness = 6, deathtouch = true, isMob = true, isBoss = true, displayId = 1157,
        zone = "Swamp of Sorrows", creatureType = "Beast", faction = "Troll", npcId = 2686,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["SWA10"] = {
        id = "SWA10", name = "Zekkis", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 9, toughness = 11, isMob = true, isBoss = true, displayId = 6693,
        zone = "Swamp of Sorrows", creatureType = "Undead", npcId = 5400,
        modelCam = { zoom = 0.63, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },

    -- THE HINTERLANDS
    ["HIN01"] = {
        id = "HIN01", name = "Mangy Silvermane", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 11413,
        zone = "The Hinterlands", creatureType = "Beast", npcId = 2923,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["HIN02"] = {
        id = "HIN02", name = "Trained Razorbeak", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 1149,
        zone = "The Hinterlands", creatureType = "Beast", npcId = 2657,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIN03"] = {
        id = "HIN03", name = "Witherbark Hideskinner", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 6483,
        zone = "The Hinterlands", creatureType = "Humanoid", faction = "Troll", npcId = 2651,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIN04"] = {
        id = "HIN04", name = "Primitive Owlbeast", cost = "{1}{W}", cmc = 2, color = "W", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 12238,
        zone = "The Hinterlands", creatureType = "Humanoid", npcId = 2928,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIN05"] = {
        id = "HIN05", name = "Highvale Scout", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 2, haste = true, vigilance = true, isMob = true, isBoss = true, displayId = 6549,
        zone = "The Hinterlands", creatureType = "Humanoid", npcId = 2692,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste, Vigilance."
    },
    ["HIN06"] = {
        id = "HIN06", name = "Saltwater Snapjaw", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 4, isMob = true, isBoss = true, displayId = 5027,
        zone = "The Hinterlands", creatureType = "Beast", npcId = 2505,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIN07"] = {
        id = "HIN07", name = "Revantusk Watcher", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 3, toughness = 4, vigilance = true, isMob = true, isBoss = true, displayId = 14760,
        zone = "The Hinterlands", creatureType = "Humanoid", faction = "Troll", npcId = 14730,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["HIN08"] = {
        id = "HIN08", name = "Vilebranch Shadow Hunter", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 6538,
        zone = "The Hinterlands", creatureType = "Humanoid", faction = "Troll", npcId = 2645,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["HIN09"] = {
        id = "HIN09", name = "Vilebranch Blood Drinker", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 6, toughness = 6, lifelink = true, isMob = true, isBoss = true, displayId = 6495,
        zone = "The Hinterlands", creatureType = "Humanoid", faction = "Troll", npcId = 2646,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["HIN10"] = {
        id = "HIN10", name = "Mith'rethis the Enchanter", cost = "{5}{U}{U}", cmc = 7, color = "U", type = "Creature",
        power = 10, toughness = 10, isMob = true, isBoss = true, displayId = 6512,
        zone = "The Hinterlands", creatureType = "Humanoid", npcId = 8217,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },

    -- SEARING GORGE
    ["SEA01"] = {
        id = "SEA01", name = "Dark Iron Slaver", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 7789,
        zone = "Searing Gorge", creatureType = "Humanoid", faction = "Dark Iron", npcId = 5844,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SEA02"] = {
        id = "SEA02", name = "Enslaved Archaeologist", cost = "{W}", cmc = 1, color = "W", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 7751,
        zone = "Searing Gorge", creatureType = "Humanoid", npcId = 8402,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SEA03"] = {
        id = "SEA03", name = "Searing Lava Spider", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 4457,
        zone = "Searing Gorge", creatureType = "Beast", npcId = 5857,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["SEA04"] = {
        id = "SEA04", name = "Blazing Elemental", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 1070,
        zone = "Searing Gorge", creatureType = "Elemental", npcId = 5850,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SEA05"] = {
        id = "SEA05", name = "Dark Iron Taskmaster", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 3, isMob = true, isBoss = true, displayId = 7798,
        zone = "Searing Gorge", creatureType = "Humanoid", faction = "Dark Iron", npcId = 5846,
        anthem = { tag = "faction", value = "Dark Iron", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Dark Iron you control get +1/+0."
    },
    ["SEA06"] = {
        id = "SEA06", name = "Magma Elemental", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 1, toughness = 7, defender = true, isMob = true, isBoss = true, displayId = 2075,
        zone = "Searing Gorge", creatureType = "Elemental", npcId = 5855,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Defender."
    },
    ["SEA07"] = {
        id = "SEA07", name = "Greater Lava Spider", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 3, deathtouch = true, isMob = true, isBoss = true, displayId = 7510,
        zone = "Searing Gorge", creatureType = "Beast", npcId = 5858,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["SEA08"] = {
        id = "SEA08", name = "Heavy War Golem", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 1, toughness = 11, defender = true, isMob = true, isBoss = true, displayId = 10801,
        zone = "Searing Gorge", creatureType = "Mechanical", npcId = 5854,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = "Defender."
    },
    ["SEA09"] = {
        id = "SEA09", name = "Incendosaur", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 8509,
        zone = "Searing Gorge", creatureType = "Beast", npcId = 9318,
        modelCam = { zoom = 0.75, camScale = 1.07, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["SEA10"] = {
        id = "SEA10", name = "Smoldar", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 8, toughness = 10, isMob = true, isBoss = true, displayId = 5781,
        zone = "Searing Gorge", creatureType = "Elemental", npcId = 8278,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },

    -- BLASTED LANDS
    ["BLA01"] = {
        id = "BLA01", name = "Starving Snickerfang", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 8050,
        zone = "Blasted Lands", creatureType = "Beast", npcId = 5984,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["BLA02"] = {
        id = "BLA02", name = "Snickerfang Hyena", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 2714,
        zone = "Blasted Lands", creatureType = "Beast", npcId = 5985,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["BLA03"] = {
        id = "BLA03", name = "Scorpok Stinger", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 6068,
        zone = "Blasted Lands", creatureType = "Beast", npcId = 5988,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["BLA04"] = {
        id = "BLA04", name = "Felbeast", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 7949,
        zone = "Blasted Lands", creatureType = "Demon", npcId = 8675,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BLA05"] = {
        id = "BLA05", name = "Redstone Crystalhide", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 798,
        zone = "Blasted Lands", creatureType = "Beast", npcId = 5991,
        modelCam = { zoom = 0.74, camScale = 1.08, z = -0.12, rotation = 0.15 },
        text = ""
    },
    ["BLA06"] = {
        id = "BLA06", name = "Helboar", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 11410,
        zone = "Blasted Lands", creatureType = "Demon", npcId = 5993,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BLA07"] = {
        id = "BLA07", name = "Shadowsworn Warlock", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 5, isMob = true, isBoss = true, displayId = 6789,
        zone = "Blasted Lands", creatureType = "Humanoid", npcId = 6008,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BLA08"] = {
        id = "BLA08", name = "Shadowsworn Enforcer", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 4, isMob = true, isBoss = true, displayId = 7841,
        zone = "Blasted Lands", creatureType = "Humanoid", npcId = 6007,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BLA09"] = {
        id = "BLA09", name = "Dreadmaul Mauler", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 6, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 14401,
        zone = "Blasted Lands", creatureType = "Humanoid", faction = "Ogre", npcId = 5977,
        modelCam = { zoom = 0.58, camScale = 1.20, z = -0.14, rotation = 0.15 },
        text = "Trample."
    },
    ["BLA10"] = {
        id = "BLA10", name = "Dreadscorn", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 7844,
        zone = "Blasted Lands", creatureType = "Humanoid", npcId = 8304,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },

    -- BURNING STEPPES
    ["BUR01"] = {
        id = "BUR01", name = "Dustbelcher Mauler", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 2, toughness = 1, isMob = true, isBoss = true, displayId = 1120,
        zone = "Burning Steppes", creatureType = "Humanoid", faction = "Ogre", npcId = 2717,
        modelCam = { zoom = 0.70, camScale = 1.10, z = -0.12, rotation = 0.15 },
        text = ""
    },
    ["BUR02"] = {
        id = "BUR02", name = "Firegut Ogre", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 11549,
        zone = "Burning Steppes", creatureType = "Humanoid", faction = "Ogre", npcId = 7033,
        modelCam = { zoom = 0.64, camScale = 1.15, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["BUR03"] = {
        id = "BUR03", name = "Flamekin Sprite", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 10816,
        zone = "Burning Steppes", creatureType = "Demon", npcId = 9777,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BUR04"] = {
        id = "BUR04", name = "Black Broodling", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 397,
        zone = "Burning Steppes", creatureType = "Dragonkin", npcId = 7047,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BUR05"] = {
        id = "BUR05", name = "Ember Worg", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 9371,
        zone = "Burning Steppes", creatureType = "Beast", npcId = 9690,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["BUR06"] = {
        id = "BUR06", name = "Flamekin Spitter", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 10815,
        zone = "Burning Steppes", creatureType = "Demon", npcId = 9776,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BUR07"] = {
        id = "BUR07", name = "Venomtip Scorpid", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 3, deathtouch = true, isMob = true, isBoss = true, displayId = 8970,
        zone = "Burning Steppes", creatureType = "Beast", npcId = 9691,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["BUR08"] = {
        id = "BUR08", name = "Firegut Brute", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 5, toughness = 4, trample = true, isMob = true, isBoss = true, displayId = 10707,
        zone = "Burning Steppes", creatureType = "Humanoid", faction = "Ogre", npcId = 7035,
        modelCam = { zoom = 0.61, camScale = 1.17, z = -0.13, rotation = 0.15 },
        text = "Trample."
    },
    ["BUR09"] = {
        id = "BUR09", name = "War Reaver", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 5, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 10806,
        zone = "Burning Steppes", creatureType = "Elemental", npcId = 7039,
        modelCam = { zoom = 0.73, camScale = 1.08, z = -0.12, rotation = 0.15 },
        text = "First Strike."
    },
    ["BUR10"] = {
        id = "BUR10", name = "Volchan", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 10, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 12232,
        zone = "Burning Steppes", creatureType = "Giant", npcId = 10119,
        modelCam = { zoom = 0.54, camScale = 1.22, z = -0.14, rotation = 0.15 },
        text = "Trample."
    },

    -- WESTERN PLAGUELANDS
    ["WPL01"] = {
        id = "WPL01", name = "Venom Mist Lurker", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 1, reach = true, isMob = true, isBoss = true, displayId = 1087,
        zone = "Western Plaguelands", creatureType = "Beast", npcId = 1822,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["WPL02"] = {
        id = "WPL02", name = "Skeletal Sorcerer", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 11403,
        zone = "Western Plaguelands", creatureType = "Undead", npcId = 1784,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WPL03"] = {
        id = "WPL03", name = "Diseased Black Bear", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 1082,
        zone = "Western Plaguelands", creatureType = "Beast", npcId = 1815,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["WPL04"] = {
        id = "WPL04", name = "Carrion Lurker", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 1091,
        zone = "Western Plaguelands", creatureType = "Beast", npcId = 1821,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["WPL05"] = {
        id = "WPL05", name = "Diseased Wolf", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 4124,
        zone = "Western Plaguelands", creatureType = "Beast", npcId = 1817,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["WPL06"] = {
        id = "WPL06", name = "Rotting Cadaver", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 4631,
        zone = "Western Plaguelands", creatureType = "Undead", npcId = 4474,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WPL07"] = {
        id = "WPL07", name = "Diseased Grizzly", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 4, trample = true, isMob = true, isBoss = true, displayId = 1083,
        zone = "Western Plaguelands", creatureType = "Beast", npcId = 1816,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = "Trample."
    },
    ["WPL08"] = {
        id = "WPL08", name = "Scarlet Worker", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 4, toughness = 5, vigilance = true, isMob = true, isBoss = true, displayId = 10303,
        zone = "Western Plaguelands", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 1883,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["WPL09"] = {
        id = "WPL09", name = "Haunting Vision", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 5, toughness = 7, isMob = true, isBoss = true, displayId = 146,
        zone = "Western Plaguelands", creatureType = "Undead", npcId = 4472,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WPL10"] = {
        id = "WPL10", name = "Scarlet High Clerist", cost = "{5}{W}{W}", cmc = 7, color = "W", type = "Creature",
        power = 9, toughness = 10, vigilance = true, isMob = true, isBoss = true, displayId = 10342,
        zone = "Western Plaguelands", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 1839,
        modelCam = { zoom = 0.63, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Vigilance."
    },

    -- EASTERN PLAGUELANDS
    ["EPL01"] = {
        id = "EPL01", name = "Plaguehound Runt", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 2, toughness = 1, isMob = true, isBoss = true, displayId = 7890,
        zone = "Eastern Plaguelands", creatureType = "Demon", npcId = 8596,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["EPL02"] = {
        id = "EPL02", name = "Carrion Grub", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 7898,
        zone = "Eastern Plaguelands", creatureType = "Beast", npcId = 8603,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["EPL03"] = {
        id = "EPL03", name = "Cannibal Ghoul", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 10626,
        zone = "Eastern Plaguelands", creatureType = "Undead", npcId = 8530,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["EPL04"] = {
        id = "EPL04", name = "Noxious Plaguebat", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 1, flying = true, isMob = true, isBoss = true, displayId = 7896,
        zone = "Eastern Plaguelands", creatureType = "Beast", npcId = 8601,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["EPL05"] = {
        id = "EPL05", name = "Putrid Gargoyle", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 2, flying = true, isMob = true, isBoss = true, displayId = 7854,
        zone = "Eastern Plaguelands", creatureType = "Undead", npcId = 8534,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["EPL06"] = {
        id = "EPL06", name = "Carrion Devourer", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 7900,
        zone = "Eastern Plaguelands", creatureType = "Beast", npcId = 8605,
        modelCam = { zoom = 0.66, camScale = 1.13, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["EPL07"] = {
        id = "EPL07", name = "Monstrous Plaguebat", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 2, toughness = 3, flying = true, lifelink = true, isMob = true, isBoss = true, displayId = 7897,
        zone = "Eastern Plaguelands", creatureType = "Beast", npcId = 8602,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying, Lifelink."
    },
    ["EPL08"] = {
        id = "EPL08", name = "Frenzied Plaguehound", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 9022,
        zone = "Eastern Plaguelands", creatureType = "Demon", npcId = 8598,
        modelCam = { zoom = 0.74, camScale = 1.08, z = -0.12, rotation = 0.15 },
        text = ""
    },
    ["EPL09"] = {
        id = "EPL09", name = "Stitched Horror", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 5, toughness = 7, isMob = true, isBoss = true, displayId = 1693,
        zone = "Eastern Plaguelands", creatureType = "Undead", npcId = 8543,
        modelCam = { zoom = 0.80, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["EPL10"] = {
        id = "EPL10", name = "Nerubian Overseer", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 9, toughness = 10, vigilance = true, isMob = true, isBoss = true, displayId = 14698,
        zone = "Eastern Plaguelands", creatureType = "Undead", npcId = 16184,
        modelCam = { zoom = 0.75, camScale = 1.07, z = -0.11, rotation = 0.15 },
        text = "Vigilance."
    },

    -- DUROTAR
    ["DUR01"] = {
        id = "DUR01", name = "Vile Familiar", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 1185,
        zone = "Durotar", creatureType = "Humanoid", npcId = 3101,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DUR02"] = {
        id = "DUR02", name = "Clattering Scorpid", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 1, reach = true, isMob = true, isBoss = true, displayId = 2486,
        zone = "Durotar", creatureType = "Beast", npcId = 3125,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["DUR03"] = {
        id = "DUR03", name = "Dire Mottled Boar", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 381,
        zone = "Durotar", creatureType = "Beast", npcId = 3099,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DUR04"] = {
        id = "DUR04", name = "Armored Scorpid", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 2487,
        zone = "Durotar", creatureType = "Beast", npcId = 3126,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["DUR05"] = {
        id = "DUR05", name = "Bloodtalon Taillasher", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 1960,
        zone = "Durotar", creatureType = "Beast", npcId = 3122,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["DUR06"] = {
        id = "DUR06", name = "Elder Mottled Boar", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 193,
        zone = "Durotar", creatureType = "Beast", npcId = 3100,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DUR07"] = {
        id = "DUR07", name = "Venomtail Scorpid", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 3, deathtouch = true, isMob = true, isBoss = true, displayId = 2732,
        zone = "Durotar", creatureType = "Beast", npcId = 3127,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["DUR08"] = {
        id = "DUR08", name = "Bloodtalon Scythemaw", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 6, toughness = 4, isMob = true, isBoss = true, displayId = 1959,
        zone = "Durotar", creatureType = "Beast", npcId = 3123,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DUR09"] = {
        id = "DUR09", name = "Dreadmaw Crocolisk", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 1250,
        zone = "Durotar", creatureType = "Beast", npcId = 3110,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DUR10"] = {
        id = "DUR10", name = "Death Flayer", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 6, toughness = 8, deathtouch = true, isMob = true, isBoss = true, displayId = 2491,
        zone = "Durotar", creatureType = "Beast", npcId = 5823,
        anthem = { tag = "zone", value = "Durotar", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch. Other Durotar creatures you control get +1/+1."
    },

    -- MULGORE
    ["MUL01"] = {
        id = "MUL01", name = "Plainstrider", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 1219,
        zone = "Mulgore", creatureType = "Beast", npcId = 2955,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["MUL02"] = {
        id = "MUL02", name = "Mountain Cougar", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 11451,
        zone = "Mulgore", creatureType = "Beast", npcId = 2961,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["MUL03"] = {
        id = "MUL03", name = "Battleboar", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 8869,
        zone = "Mulgore", creatureType = "Beast", npcId = 2966,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["MUL04"] = {
        id = "MUL04", name = "Bristleback Quilboar", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 1967,
        zone = "Mulgore", creatureType = "Humanoid", faction = "Quilboar", npcId = 2952,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["MUL05"] = {
        id = "MUL05", name = "Palemane Tanner", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 550,
        zone = "Mulgore", creatureType = "Humanoid", npcId = 2949,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["MUL06"] = {
        id = "MUL06", name = "Prairie Wolf", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 1100,
        zone = "Mulgore", creatureType = "Beast", npcId = 2958,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["MUL07"] = {
        id = "MUL07", name = "Wiry Swoop", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 2, toughness = 3, flying = true, haste = true, isMob = true, isBoss = true, displayId = 1228,
        zone = "Mulgore", creatureType = "Beast", npcId = 2969,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying, Haste."
    },
    ["MUL08"] = {
        id = "MUL08", name = "Venture Co. Worker", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 7247,
        zone = "Mulgore", creatureType = "Humanoid", faction = "Venture Co.", npcId = 2978,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["MUL09"] = {
        id = "MUL09", name = "Venture Co. Supervisor", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 7245,
        zone = "Mulgore", creatureType = "Humanoid", faction = "Venture Co.", npcId = 2979,
        anthem = { tag = "faction", value = "Venture Co.", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Venture Co. you control get +1/+1."
    },
    ["MUL10"] = {
        id = "MUL10", name = "Snagglespear", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 275,
        zone = "Mulgore", creatureType = "Humanoid", faction = "Quilboar", npcId = 5786,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },

    -- DARKSHORE
    ["DAR01"] = {
        id = "DAR01", name = "Pygmy Tide Crawler", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 1000,
        zone = "Darkshore", creatureType = "Beast", npcId = 2231,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DAR02"] = {
        id = "DAR02", name = "Young Reef Crawler", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 999,
        zone = "Darkshore", creatureType = "Beast", npcId = 2234,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DAR03"] = {
        id = "DAR03", name = "Foreststrider Fledgling", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 1, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 1042,
        zone = "Darkshore", creatureType = "Beast", npcId = 2321,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["DAR04"] = {
        id = "DAR04", name = "Darkshore Thresher", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 992,
        zone = "Darkshore", creatureType = "Beast", npcId = 2185,
        modelCam = { zoom = 0.54, camScale = 1.22, z = -0.14, rotation = 0.15 },
        text = ""
    },
    ["DAR05"] = {
        id = "DAR05", name = "Rabid Thistle Bear", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 8840,
        zone = "Darkshore", creatureType = "Beast", npcId = 2164,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DAR06"] = {
        id = "DAR06", name = "Coastal Frenzy", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 245,
        zone = "Darkshore", creatureType = "Beast", npcId = 2174,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DAR07"] = {
        id = "DAR07", name = "Giant Foreststrider", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 3, toughness = 4, haste = true, isMob = true, isBoss = true, displayId = 1283,
        zone = "Darkshore", creatureType = "Beast", npcId = 2323,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["DAR08"] = {
        id = "DAR08", name = "Stormscale Myrmidon", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 4036,
        zone = "Darkshore", creatureType = "Humanoid", faction = "Naga", npcId = 2181,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DAR09"] = {
        id = "DAR09", name = "Raging Reef Crawler", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 4, toughness = 8, isMob = true, isBoss = true, displayId = 1001,
        zone = "Darkshore", creatureType = "Beast", npcId = 2236,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DAR10"] = {
        id = "DAR10", name = "Apothecary Falthis", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 4156,
        zone = "Darkshore", creatureType = "Humanoid", npcId = 3735,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },

    -- TELDRASSIL
    ["TEL01"] = {
        id = "TEL01", name = "Young Nightsaber", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 11454,
        zone = "Teldrassil", creatureType = "Beast", npcId = 2031,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["TEL02"] = {
        id = "TEL02", name = "Young Thistle Boar", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 8869,
        zone = "Teldrassil", creatureType = "Beast", npcId = 1984,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TEL03"] = {
        id = "TEL03", name = "Mangy Nightsaber", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 11448,
        zone = "Teldrassil", creatureType = "Beast", npcId = 2032,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["TEL04"] = {
        id = "TEL04", name = "Webwood Spider", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 709,
        zone = "Teldrassil", creatureType = "Beast", npcId = 1986,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["TEL05"] = {
        id = "TEL05", name = "Webwood Lurker", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 2, deathtouch = true, unblockable = true, isMob = true, isBoss = true, displayId = 760,
        zone = "Teldrassil", creatureType = "Beast", npcId = 1998,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch, Cannot be blocked."
    },
    ["TEL06"] = {
        id = "TEL06", name = "Strigid Owl", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 2, flying = true, isMob = true, isBoss = true, displayId = 10832,
        zone = "Teldrassil", creatureType = "Beast", npcId = 1995,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["TEL07"] = {
        id = "TEL07", name = "Gnarlpine Shaman", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 3, toughness = 5, isMob = true, isBoss = true, displayId = 897,
        zone = "Teldrassil", creatureType = "Humanoid", faction = "Furbolg", npcId = 2009,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TEL08"] = {
        id = "TEL08", name = "Gnarlpine Defender", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 4, toughness = 5, vigilance = true, isMob = true, isBoss = true, displayId = 6801,
        zone = "Teldrassil", creatureType = "Humanoid", faction = "Furbolg", npcId = 2010,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["TEL09"] = {
        id = "TEL09", name = "Strigid Screecher", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 5, toughness = 5, flying = true, isMob = true, isBoss = true, displayId = 4877,
        zone = "Teldrassil", creatureType = "Beast", npcId = 1996,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["TEL10"] = {
        id = "TEL10", name = "Blackmoss the Fetid", cost = "{5}{G}{G}", cmc = 7, color = "G", type = "Creature",
        power = 8, toughness = 10, isMob = true, isBoss = true, displayId = 1549,
        zone = "Teldrassil", creatureType = "Elemental", npcId = 3535,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },

    -- THE BARRENS
    ["BRN01"] = {
        id = "BRN01", name = "Kolkar Wrangler", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 9442,
        zone = "The Barrens", creatureType = "Humanoid", npcId = 3272,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BRN02"] = {
        id = "BRN02", name = "Sunscale Screecher", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 1747,
        zone = "The Barrens", creatureType = "Beast", npcId = 3255,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["BRN03"] = {
        id = "BRN03", name = "Savannah Prowler", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 1973,
        zone = "The Barrens", creatureType = "Beast", npcId = 3425,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["BRN04"] = {
        id = "BRN04", name = "Hecklefang Hyena", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 2710,
        zone = "The Barrens", creatureType = "Beast", npcId = 4127,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["BRN05"] = {
        id = "BRN05", name = "Theramore Marine", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 2, toughness = 2, firstStrike = true, vigilance = true, isMob = true, isBoss = true, displayId = 1858,
        zone = "The Barrens", creatureType = "Humanoid", npcId = 3385,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike, Vigilance."
    },
    ["BRN06"] = {
        id = "BRN06", name = "Stormsnout", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 1537,
        zone = "The Barrens", creatureType = "Beast", npcId = 3240,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BRN07"] = {
        id = "BRN07", name = "Bael'dun Excavator", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 1968,
        zone = "The Barrens", creatureType = "Humanoid", npcId = 3374,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BRN08"] = {
        id = "BRN08", name = "Silithid Swarmer", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 4, toughness = 4, deathtouch = true, isMob = true, isBoss = true, displayId = 2731,
        zone = "The Barrens", creatureType = "Beast", npcId = 3252,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["BRN09"] = {
        id = "BRN09", name = "Stormhide", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 1539,
        zone = "The Barrens", creatureType = "Beast", npcId = 3238,
        modelCam = { zoom = 0.82, camScale = 1.02, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BRN10"] = {
        id = "BRN10", name = "Azzere the Skyblade", cost = "{5}{U}{U}", cmc = 7, color = "U", type = "Creature",
        power = 8, toughness = 8, flying = true, isMob = true, isBoss = true, displayId = 2702,
        zone = "The Barrens", creatureType = "Beast", npcId = 5834,
        modelCam = { zoom = 0.58, camScale = 1.20, z = -0.14, rotation = 0.15 },
        text = "Flying."
    },

    -- STONETALON MOUNTAINS
    ["STO01"] = {
        id = "STO01", name = "Gogger Geomancer", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 26,
        zone = "Stonetalon Mountains", creatureType = "Humanoid", npcId = 11917,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STO02"] = {
        id = "STO02", name = "Gogger Rock Keeper", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 26,
        zone = "Stonetalon Mountains", creatureType = "Humanoid", npcId = 11915,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STO03"] = {
        id = "STO03", name = "Gogger Stonepounder", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 26,
        zone = "Stonetalon Mountains", creatureType = "Humanoid", npcId = 11918,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STO04"] = {
        id = "STO04", name = "Windshear Digger", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 2153,
        zone = "Stonetalon Mountains", creatureType = "Humanoid", faction = "Kobold", npcId = 3999,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STO05"] = {
        id = "STO05", name = "Pridewing Wyvern", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 2, toughness = 2, flying = true, isMob = true, isBoss = true, displayId = 295,
        zone = "Stonetalon Mountains", creatureType = "Beast", npcId = 4012,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["STO06"] = {
        id = "STO06", name = "Pridewing Consort", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 2297,
        zone = "Stonetalon Mountains", creatureType = "Beast", npcId = 4014,
        modelCam = { zoom = 0.78, camScale = 1.05, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["STO07"] = {
        id = "STO07", name = "Rogue Flame Spirit", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 3, toughness = 4, firstStrike = true, isMob = true, isBoss = true, displayId = 4607,
        zone = "Stonetalon Mountains", creatureType = "Elemental", npcId = 4036,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["STO08"] = {
        id = "STO08", name = "Blackened Basilisk", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 2173,
        zone = "Stonetalon Mountains", creatureType = "Beast", npcId = 4044,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STO09"] = {
        id = "STO09", name = "Bloodfury Windcaller", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 5, toughness = 5, flying = true, isMob = true, isBoss = true, displayId = 10282,
        zone = "Stonetalon Mountains", creatureType = "Humanoid", npcId = 4026,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["STO10"] = {
        id = "STO10", name = "Sorrow Wing", cost = "{5}{U}{U}", cmc = 7, color = "U", type = "Creature",
        power = 10, toughness = 10, isMob = true, isBoss = true, displayId = 11012,
        zone = "Stonetalon Mountains", creatureType = "Beast", npcId = 5928,
        modelCam = { zoom = 0.68, camScale = 1.12, z = -0.12, rotation = 0.15 },
        text = ""
    },

    -- ASHENVALE
    ["ASH01"] = {
        id = "ASH01", name = "Clattering Crawler", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 9566,
        zone = "Ashenvale", creatureType = "Beast", npcId = 3812,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ASH02"] = {
        id = "ASH02", name = "Spined Crawler", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 1001,
        zone = "Ashenvale", creatureType = "Beast", npcId = 3814,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ASH03"] = {
        id = "ASH03", name = "Ashenvale Bear", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 820,
        zone = "Ashenvale", creatureType = "Beast", npcId = 3809,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ASH04"] = {
        id = "ASH04", name = "Shadowhorn Stag", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 1991,
        zone = "Ashenvale", creatureType = "Beast", npcId = 3817,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ASH05"] = {
        id = "ASH05", name = "Ghostpaw Howler", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 1207,
        zone = "Ashenvale", creatureType = "Beast", npcId = 3824,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["ASH06"] = {
        id = "ASH06", name = "Befouled Water Elemental", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 525,
        zone = "Ashenvale", creatureType = "Elemental", npcId = 3917,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ASH07"] = {
        id = "ASH07", name = "Shadethicket Bark Ripper", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 3, toughness = 5, isMob = true, isBoss = true, displayId = 2024,
        zone = "Ashenvale", creatureType = "Elemental", npcId = 3784,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ASH08"] = {
        id = "ASH08", name = "Warsong Peon", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 11857,
        zone = "Ashenvale", creatureType = "Humanoid", npcId = 11656,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ASH09"] = {
        id = "ASH09", name = "Ghostpaw Alpha", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 6, toughness = 5, isMob = true, isBoss = true, displayId = 776,
        zone = "Ashenvale", creatureType = "Beast", npcId = 3825,
        anthem = { tag = "type", value = "Beast", p = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Beasts you control get +1/+0."
    },
    ["ASH10"] = {
        id = "ASH10", name = "Terrowulf Packlord", cost = "{5}{G}{G}", cmc = 7, color = "G", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 522,
        zone = "Ashenvale", creatureType = "Humanoid", npcId = 3792,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },

    -- THOUSAND NEEDLES
    ["THO01"] = {
        id = "THO01", name = "Savannah Matriarch", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 1058,
        zone = "Thousand Needles", creatureType = "Beast", npcId = 3416,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["THO02"] = {
        id = "THO02", name = "Galak Windchaser", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 9412,
        zone = "Thousand Needles", creatureType = "Humanoid", npcId = 4096,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["THO03"] = {
        id = "THO03", name = "Galak Wrangler", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 9414,
        zone = "Thousand Needles", creatureType = "Humanoid", npcId = 4093,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["THO04"] = {
        id = "THO04", name = "Pesterhide Hyena", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 2713,
        zone = "Thousand Needles", creatureType = "Beast", npcId = 4248,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["THO05"] = {
        id = "THO05", name = "Needles Cougar", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 1056,
        zone = "Thousand Needles", creatureType = "Beast", npcId = 4124,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["THO06"] = {
        id = "THO06", name = "Pesterhide Snarler", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 10903,
        zone = "Thousand Needles", creatureType = "Beast", npcId = 4249,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["THO07"] = {
        id = "THO07", name = "Screeching Roguefeather", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 3, toughness = 4, firstStrike = true, isMob = true, isBoss = true, displayId = 1350,
        zone = "Thousand Needles", creatureType = "Humanoid", npcId = 4101,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["THO08"] = {
        id = "THO08", name = "Sparkleshell Borer", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 3, toughness = 7, isMob = true, isBoss = true, displayId = 2307,
        zone = "Thousand Needles", creatureType = "Beast", npcId = 4144,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["THO09"] = {
        id = "THO09", name = "Scorpid Terror", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 4, toughness = 6, deathtouch = true, isMob = true, isBoss = true, displayId = 2491,
        zone = "Thousand Needles", creatureType = "Beast", npcId = 4139,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["THO10"] = {
        id = "THO10", name = "Vile Sting", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 8, toughness = 10, deathtouch = true, isMob = true, isBoss = true, displayId = 10988,
        zone = "Thousand Needles", creatureType = "Beast", npcId = 5937,
        modelCam = { zoom = 0.63, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Deathtouch."
    },

    -- DESOLACE
    ["DES01"] = {
        id = "DES01", name = "Burning Blade Augur", cost = "{W}", cmc = 1, color = "W", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 4699,
        zone = "Desolace", creatureType = "Humanoid", faction = "Burning Blade", npcId = 4663,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DES02"] = {
        id = "DES02", name = "Scorpashi Snapper", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 1, reach = true, isMob = true, isBoss = true, displayId = 2729,
        zone = "Desolace", creatureType = "Beast", npcId = 4696,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["DES03"] = {
        id = "DES03", name = "Burning Blade Reaver", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 1, firstStrike = true, isMob = true, isBoss = true, displayId = 4703,
        zone = "Desolace", creatureType = "Humanoid", faction = "Burning Blade", npcId = 4664,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["DES04"] = {
        id = "DES04", name = "Gritjaw Basilisk", cost = "{1}{W}", cmc = 2, color = "W", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 1074,
        zone = "Desolace", creatureType = "Beast", npcId = 4728,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DES05"] = {
        id = "DES05", name = "Dread Swoop", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 2, flying = true, haste = true, isMob = true, isBoss = true, displayId = 1192,
        zone = "Desolace", creatureType = "Beast", npcId = 4692,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying, Haste."
    },
    ["DES06"] = {
        id = "DES06", name = "Raging Thunder Lizard", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 2, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 2742,
        zone = "Desolace", creatureType = "Beast", npcId = 4726,
        modelCam = { zoom = 0.82, camScale = 1.02, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["DES07"] = {
        id = "DES07", name = "Dread Flyer", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 3, flying = true, isMob = true, isBoss = true, displayId = 10273,
        zone = "Desolace", creatureType = "Beast", npcId = 4693,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["DES08"] = {
        id = "DES08", name = "Undead Ravager", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 4, toughness = 6, isMob = true, isBoss = true, displayId = 11369,
        zone = "Desolace", creatureType = "Undead", npcId = 11561,
        modelCam = { zoom = 0.68, camScale = 1.12, z = -0.12, rotation = 0.15 },
        text = ""
    },
    ["DES09"] = {
        id = "DES09", name = "Elder Thunder Lizard", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 5, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 2764,
        zone = "Desolace", creatureType = "Beast", npcId = 4727,
        modelCam = { zoom = 0.78, camScale = 1.05, z = -0.11, rotation = 0.15 },
        text = "Trample."
    },
    ["DES10"] = {
        id = "DES10", name = "Kaskk", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 14255,
        zone = "Desolace", creatureType = "Demon", npcId = 14226,
        modelCam = { zoom = 0.78, camScale = 1.05, z = -0.11, rotation = 0.15 },
        text = ""
    },

    -- DUSTWALLOW MARSH
    ["DUS01"] = {
        id = "DUS01", name = "Noxious Flayer", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 1, flying = true, isMob = true, isBoss = true, displayId = 2700,
        zone = "Dustwallow Marsh", creatureType = "Beast", npcId = 4346,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["DUS02"] = {
        id = "DUS02", name = "Withervine Creeper", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 4, defender = true, isMob = true, isBoss = true, displayId = 2024,
        zone = "Dustwallow Marsh", creatureType = "Elemental", npcId = 4382,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Defender."
    },
    ["DUS03"] = {
        id = "DUS03", name = "Mirefin Murloc", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 652,
        zone = "Dustwallow Marsh", creatureType = "Humanoid", faction = "Murloc", npcId = 4359,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["DUS04"] = {
        id = "DUS04", name = "Drywallow Snapper", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 814,
        zone = "Dustwallow Marsh", creatureType = "Beast", npcId = 4343,
        modelCam = { zoom = 0.80, camScale = 1.03, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["DUS05"] = {
        id = "DUS05", name = "Mottled Drywallow Crocolisk", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 2548,
        zone = "Dustwallow Marsh", creatureType = "Beast", npcId = 4344,
        modelCam = { zoom = 0.80, camScale = 1.03, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["DUS06"] = {
        id = "DUS06", name = "Darkfang Creeper", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 2, deathtouch = true, isMob = true, isBoss = true, displayId = 2546,
        zone = "Dustwallow Marsh", creatureType = "Beast", npcId = 4412,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["DUS07"] = {
        id = "DUS07", name = "Young Murk Thresher", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 2425,
        zone = "Dustwallow Marsh", creatureType = "Beast", npcId = 4388,
        modelCam = { zoom = 0.46, camScale = 1.28, z = -0.16, rotation = 0.15 },
        text = ""
    },
    ["DUS08"] = {
        id = "DUS08", name = "Muckshell Pincer", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 2599,
        zone = "Dustwallow Marsh", creatureType = "Humanoid", npcId = 4403,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DUS09"] = {
        id = "DUS09", name = "Muckshell Scrabbler", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 2600,
        zone = "Dustwallow Marsh", creatureType = "Humanoid", npcId = 4404,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DUS10"] = {
        id = "DUS10", name = "Lord Angler", cost = "{5}{U}{U}", cmc = 7, color = "U", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 14257,
        zone = "Dustwallow Marsh", creatureType = "Humanoid", npcId = 14236,
        modelCam = { zoom = 0.58, camScale = 1.19, z = -0.14, rotation = 0.15 },
        text = ""
    },

    -- FERALAS
    ["FER01"] = {
        id = "FER01", name = "Woodpaw Mystic", cost = "{W}", cmc = 1, color = "W", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 10794,
        zone = "Feralas", creatureType = "Humanoid", faction = "Gnoll", npcId = 5254,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["FER02"] = {
        id = "FER02", name = "Woodpaw Reaver", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 1, firstStrike = true, isMob = true, isBoss = true, displayId = 10795,
        zone = "Feralas", creatureType = "Humanoid", faction = "Gnoll", npcId = 5255,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = "First Strike."
    },
    ["FER03"] = {
        id = "FER03", name = "Groddoc Ape", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 3186,
        zone = "Feralas", creatureType = "Beast", npcId = 5260,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["FER04"] = {
        id = "FER04", name = "Hatecrest Sorceress", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 11260,
        zone = "Feralas", creatureType = "Humanoid", faction = "Naga", npcId = 5336,
        modelCam = { zoom = 0.80, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["FER05"] = {
        id = "FER05", name = "Longtooth Howler", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 3202,
        zone = "Feralas", creatureType = "Beast", npcId = 5287,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["FER06"] = {
        id = "FER06", name = "Grizzled Ironfur Bear", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 4, isMob = true, isBoss = true, displayId = 8838,
        zone = "Feralas", creatureType = "Beast", npcId = 5272,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["FER07"] = {
        id = "FER07", name = "Frayfeather Patriarch", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 6756,
        zone = "Feralas", creatureType = "Beast", npcId = 5306,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["FER08"] = {
        id = "FER08", name = "Sea Spray", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 4, toughness = 6, isMob = true, isBoss = true, displayId = 5562,
        zone = "Feralas", creatureType = "Elemental", npcId = 5462,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["FER09"] = {
        id = "FER09", name = "Sea Elemental", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 5, toughness = 7, isMob = true, isBoss = true, displayId = 5450,
        zone = "Feralas", creatureType = "Elemental", npcId = 5461,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["FER10"] = {
        id = "FER10", name = "Antilus the Soarer", cost = "{5}{U}{U}", cmc = 7, color = "U", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 10889,
        zone = "Feralas", creatureType = "Beast", npcId = 5347,
        modelCam = { zoom = 0.58, camScale = 1.20, z = -0.14, rotation = 0.15 },
        text = ""
    },

    -- TANARIS
    ["TAN01"] = {
        id = "TAN01", name = "Scorpid Hunter", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 1, reach = true, isMob = true, isBoss = true, displayId = 2414,
        zone = "Tanaris", creatureType = "Beast", npcId = 5422,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["TAN02"] = {
        id = "TAN02", name = "Glasshide Basilisk", cost = "{W}", cmc = 1, color = "W", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 141,
        zone = "Tanaris", creatureType = "Beast", npcId = 5419,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TAN03"] = {
        id = "TAN03", name = "Steeljaw Snapper", cost = "{1}{W}", cmc = 2, color = "W", type = "Creature",
        power = 1, toughness = 3, isMob = true, isBoss = true, displayId = 7114,
        zone = "Tanaris", creatureType = "Beast", npcId = 14123,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TAN04"] = {
        id = "TAN04", name = "Scorpid Tail Lasher", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 10987,
        zone = "Tanaris", creatureType = "Beast", npcId = 5423,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["TAN05"] = {
        id = "TAN05", name = "Blisterpaw Hyena", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 1536,
        zone = "Tanaris", creatureType = "Beast", npcId = 5426,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["TAN06"] = {
        id = "TAN06", name = "Glasshide Gazer", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 7344,
        zone = "Tanaris", creatureType = "Beast", npcId = 5420,
        modelCam = { zoom = 0.78, camScale = 1.05, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["TAN07"] = {
        id = "TAN07", name = "Rabid Blisterpaw", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 4, toughness = 3, haste = true, isMob = true, isBoss = true, displayId = 2609,
        zone = "Tanaris", creatureType = "Beast", npcId = 5427,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["TAN08"] = {
        id = "TAN08", name = "Dunemaul Brute", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 5, toughness = 4, trample = true, isMob = true, isBoss = true, displayId = 11545,
        zone = "Tanaris", creatureType = "Humanoid", faction = "Ogre", npcId = 5474,
        modelCam = { zoom = 0.67, camScale = 1.13, z = -0.13, rotation = 0.15 },
        text = "Trample."
    },
    ["TAN09"] = {
        id = "TAN09", name = "Surf Glider", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 4, toughness = 8, isMob = true, isBoss = true, displayId = 7114,
        zone = "Tanaris", creatureType = "Beast", npcId = 5431,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["TAN10"] = {
        id = "TAN10", name = "Cyclok the Mad", cost = "{5}{U}{U}", cmc = 7, color = "U", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 11532,
        zone = "Tanaris", creatureType = "Humanoid", faction = "Ogre", npcId = 8202,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },

    -- AZSHARA
    ["AZS01"] = {
        id = "AZS01", name = "Highborne Apparition", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 1, unblockable = true, isMob = true, isBoss = true, displayId = 10702,
        zone = "Azshara", creatureType = "Undead", npcId = 6116,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Cannot be blocked."
    },
    ["AZS02"] = {
        id = "AZS02", name = "Mosshoof Runner", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 8013,
        zone = "Azshara", creatureType = "Beast", npcId = 8759,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["AZS03"] = {
        id = "AZS03", name = "Spitelash Warrior", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 6747,
        zone = "Azshara", creatureType = "Humanoid", faction = "Naga", npcId = 6190,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["AZS04"] = {
        id = "AZS04", name = "Timbermaw Shaman", cost = "{1}{W}", cmc = 2, color = "W", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 2000,
        zone = "Azshara", creatureType = "Humanoid", faction = "Furbolg", npcId = 6188,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["AZS05"] = {
        id = "AZS05", name = "Thunderhead Skystormer", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 2, toughness = 2, flying = true, isMob = true, isBoss = true, displayId = 10893,
        zone = "Azshara", creatureType = "Beast", npcId = 6378,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["AZS06"] = {
        id = "AZS06", name = "Spitelash Myrmidon", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 11265,
        zone = "Azshara", creatureType = "Humanoid", faction = "Naga", npcId = 6196,
        modelCam = { zoom = 0.73, camScale = 1.08, z = -0.12, rotation = 0.15 },
        text = ""
    },
    ["AZS07"] = {
        id = "AZS07", name = "Mosshoof Courser", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 3, toughness = 4, haste = true, isMob = true, isBoss = true, displayId = 10957,
        zone = "Azshara", creatureType = "Beast", npcId = 8761,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["AZS08"] = {
        id = "AZS08", name = "Legashi Rogue", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 5, toughness = 4, firstStrike = true, isMob = true, isBoss = true, displayId = 6743,
        zone = "Azshara", creatureType = "Demon", faction = "Satyr", npcId = 6201,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["AZS09"] = {
        id = "AZS09", name = "Coralshell Lurker", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 4, toughness = 8, isMob = true, isBoss = true, displayId = 10947,
        zone = "Azshara", creatureType = "Beast", npcId = 6352,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["AZS10"] = {
        id = "AZS10", name = "Monnos the Elder", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 10, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 10042,
        zone = "Azshara", creatureType = "Giant", npcId = 6646,
        modelCam = { zoom = 0.64, camScale = 1.15, z = -0.13, rotation = 0.15 },
        text = "Trample."
    },

    -- FELWOOD
    ["FEL01"] = {
        id = "FEL01", name = "Felpaw Wolf", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 4124,
        zone = "Felwood", creatureType = "Beast", npcId = 8959,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["FEL02"] = {
        id = "FEL02", name = "Angerclaw Bear", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 9276,
        zone = "Felwood", creatureType = "Beast", npcId = 8956,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["FEL03"] = {
        id = "FEL03", name = "Deadwood Warrior", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 2000,
        zone = "Felwood", creatureType = "Humanoid", faction = "Furbolg", npcId = 7153,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["FEL04"] = {
        id = "FEL04", name = "Felpaw Scavenger", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 1, haste = true, isMob = true, isBoss = true, displayId = 9278,
        zone = "Felwood", creatureType = "Beast", npcId = 8960,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["FEL05"] = {
        id = "FEL05", name = "Jadefire Satyr", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 2019,
        zone = "Felwood", creatureType = "Demon", faction = "Satyr", npcId = 7105,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["FEL06"] = {
        id = "FEL06", name = "Angerclaw Mauler", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 2, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 1083,
        zone = "Felwood", creatureType = "Beast", npcId = 8958,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = "Trample."
    },
    ["FEL07"] = {
        id = "FEL07", name = "Irontree Stomper", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 1, toughness = 9, defender = true, isMob = true, isBoss = true, displayId = 6351,
        zone = "Felwood", creatureType = "Elemental", npcId = 7139,
        modelCam = { zoom = 0.61, camScale = 1.17, z = -0.13, rotation = 0.15 },
        text = "Defender."
    },
    ["FEL08"] = {
        id = "FEL08", name = "Warpwood Moss Flayer", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 4, toughness = 6, isMob = true, isBoss = true, displayId = 8389,
        zone = "Felwood", creatureType = "Elemental", npcId = 7100,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["FEL09"] = {
        id = "FEL09", name = "Jaedenar Darkweaver", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 5, toughness = 7, isMob = true, isBoss = true, displayId = 6393,
        zone = "Felwood", creatureType = "Humanoid", npcId = 7118,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["FEL10"] = {
        id = "FEL10", name = "Mezzir the Howler", cost = "{5}{W}{W}", cmc = 7, color = "W", type = "Creature",
        power = 9, toughness = 9, isMob = true, isBoss = true, displayId = 3208,
        zone = "Felwood", creatureType = "Humanoid", npcId = 10197,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },

    -- UN'GORO CRATER
    ["UNG01"] = {
        id = "UNG01", name = "Ferocious Rage Scar", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 3208,
        zone = "Un'Goro Crater", creatureType = "Humanoid", npcId = 5299,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["UNG02"] = {
        id = "UNG02", name = "Ravasaur", cost = "{G}", cmc = 1, color = "G", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 5242,
        zone = "Un'Goro Crater", creatureType = "Beast", npcId = 6505,
        modelCam = { zoom = 0.68, camScale = 1.12, z = -0.12, rotation = 0.15 },
        text = ""
    },
    ["UNG03"] = {
        id = "UNG03", name = "Bloodpetal Lasher", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 11634,
        zone = "Un'Goro Crater", creatureType = "Elemental", npcId = 6509,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["UNG04"] = {
        id = "UNG04", name = "Un'Goro Gorilla", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 844,
        zone = "Un'Goro Crater", creatureType = "Beast", npcId = 6514,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["UNG05"] = {
        id = "UNG05", name = "Bloodpetal Flayer", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 11635,
        zone = "Un'Goro Crater", creatureType = "Elemental", npcId = 6510,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["UNG06"] = {
        id = "UNG06", name = "Diemetradon", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 8511,
        zone = "Un'Goro Crater", creatureType = "Beast", npcId = 9163,
        modelCam = { zoom = 0.66, camScale = 1.13, z = -0.13, rotation = 0.15 },
        text = "Trample."
    },
    ["UNG07"] = {
        id = "UNG07", name = "Un'Goro Thunderer", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 4, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 5244,
        zone = "Un'Goro Crater", creatureType = "Beast", npcId = 6516,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["UNG08"] = {
        id = "UNG08", name = "Frenzied Pterrordax", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 4, toughness = 4, flying = true, isMob = true, isBoss = true, displayId = 8412,
        zone = "Un'Goro Crater", creatureType = "Beast", npcId = 9167,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["UNG09"] = {
        id = "UNG09", name = "Living Blaze", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 5, toughness = 7, isMob = true, isBoss = true, displayId = 5488,
        zone = "Un'Goro Crater", creatureType = "Elemental", npcId = 6521,
        modelCam = { zoom = 0.75, camScale = 1.07, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["UNG10"] = {
        id = "UNG10", name = "Uhk'loc", cost = "{5}{G}{G}", cmc = 7, color = "G", type = "Creature",
        power = 9, toughness = 8, trample = true, isMob = true, isBoss = true, displayId = 8129,
        zone = "Un'Goro Crater", creatureType = "Beast", npcId = 6585,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },

    -- SILITHUS
    ["SLI01"] = {
        id = "SLI01", name = "Tortured Druid", cost = "{B}", cmc = 1, color = "B", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 12269,
        zone = "Silithus", creatureType = "Undead", npcId = 12178,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SLI02"] = {
        id = "SLI02", name = "Dredge Striker", cost = "{R}", cmc = 1, color = "R", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 15386,
        zone = "Silithus", creatureType = "Beast", npcId = 11740,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SLI03"] = {
        id = "SLI03", name = "Stonelash Pincer", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 15384,
        zone = "Silithus", creatureType = "Beast", npcId = 11736,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["SLI04"] = {
        id = "SLI04", name = "Sand Skitterer", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 1, toughness = 2, reach = true, isMob = true, isBoss = true, displayId = 8014,
        zone = "Silithus", creatureType = "Beast", npcId = 11738,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["SLI05"] = {
        id = "SLI05", name = "Dust Stormer", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 8715,
        zone = "Silithus", creatureType = "Elemental", npcId = 11744,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SLI06"] = {
        id = "SLI06", name = "Stonelash Flayer", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 2, deathtouch = true, isMob = true, isBoss = true, displayId = 15385,
        zone = "Silithus", creatureType = "Beast", npcId = 11737,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["SLI07"] = {
        id = "SLI07", name = "Desert Rumbler", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 3, toughness = 4, trample = true, isMob = true, isBoss = true, displayId = 8550,
        zone = "Silithus", creatureType = "Elemental", npcId = 11746,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["SLI08"] = {
        id = "SLI08", name = "Twilight Avenger", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 11811,
        zone = "Silithus", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 11880,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SLI09"] = {
        id = "SLI09", name = "Twilight Geolord", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 11819,
        zone = "Silithus", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 11881,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SLI10"] = {
        id = "SLI10", name = "Mistress Natalia Mar'alith", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 10, toughness = 10, isMob = true, isBoss = true, displayId = 15330,
        zone = "Silithus", creatureType = "Humanoid", npcId = 15215,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },

    -- WINTERSPRING
    ["WIN01"] = {
        id = "WIN01", name = "Winterspring Owl", cost = "{W}", cmc = 1, color = "W", type = "Creature",
        power = 1, toughness = 1, flying = true, isMob = true, isBoss = true, displayId = 6212,
        zone = "Winterspring", creatureType = "Beast", npcId = 7455,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["WIN02"] = {
        id = "WIN02", name = "Ice Thistle Yeti", cost = "{U}", cmc = 1, color = "U", type = "Creature",
        power = 1, toughness = 2, isMob = true, isBoss = true, displayId = 10579,
        zone = "Winterspring", creatureType = "Humanoid", npcId = 7458,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WIN03"] = {
        id = "WIN03", name = "Shardtooth Mauler", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 2, toughness = 2, isMob = true, isBoss = true, displayId = 8842,
        zone = "Winterspring", creatureType = "Beast", npcId = 7443,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = ""
    },
    ["WIN04"] = {
        id = "WIN04", name = "Chillwind Chimaera", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 1, toughness = 2, flying = true, isMob = true, isBoss = true, displayId = 10810,
        zone = "Winterspring", creatureType = "Beast", npcId = 7448,
        modelCam = { zoom = 0.77, camScale = 1.06, z = -0.11, rotation = 0.15 },
        text = "Flying."
    },
    ["WIN05"] = {
        id = "WIN05", name = "Moontouched Owlbeast", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 12237,
        zone = "Winterspring", creatureType = "Humanoid", npcId = 7453,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WIN06"] = {
        id = "WIN06", name = "Elder Shardtooth", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 4, isMob = true, isBoss = true, displayId = 8837,
        zone = "Winterspring", creatureType = "Beast", npcId = 7445,
        modelCam = { zoom = 0.73, camScale = 1.08, z = -0.12, rotation = 0.15 },
        text = ""
    },
    ["WIN07"] = {
        id = "WIN07", name = "Chillwind Ravager", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 10809,
        zone = "Winterspring", creatureType = "Beast", npcId = 7449,
        modelCam = { zoom = 0.73, camScale = 1.08, z = -0.12, rotation = 0.15 },
        text = ""
    },
    ["WIN08"] = {
        id = "WIN08", name = "Winterspring Screecher", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 4, toughness = 4, flying = true, isMob = true, isBoss = true, displayId = 10833,
        zone = "Winterspring", creatureType = "Beast", npcId = 7456,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = "Flying."
    },
    ["WIN09"] = {
        id = "WIN09", name = "Frostsaber Huntress", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 6, toughness = 5, firstStrike = true, isMob = true, isBoss = true, displayId = 11444,
        zone = "Winterspring", creatureType = "Beast", npcId = 7433,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["WIN10"] = {
        id = "WIN10", name = "Lady Hederine", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 10, toughness = 10, isMob = true, isBoss = true, displayId = 10925,
        zone = "Winterspring", creatureType = "Demon", npcId = 10201,
        modelCam = { zoom = 0.79, camScale = 1.04, z = -0.11, rotation = 0.15 },
        text = ""
    },

    -- =========================================================================
    -- DUNGEON CREATURES & BOSSES - UNLOCKED BY KILLING THEM (same isMob/isBoss tracking as zone creatures)
    -- Names / displayIds / npcId come from the classicdb creature_template table; all are dungeon elites.
    -- Final dungeon bosses keep their dedicated BOSSxx cards below.
    -- =========================================================================

    -- RAGEFIRE CHASM
    ["RFC01"] = {
        id = "RFC01", name = "Ragefire Trogg", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 11609,
        zone = "Ragefire Chasm", creatureType = "Humanoid", npcId = 11318,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["RFC02"] = {
        id = "RFC02", name = "Earthborer", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 3, toughness = 2, trample = true, isMob = true, isBoss = true, displayId = 11010,
        zone = "Ragefire Chasm", creatureType = "Beast", npcId = 11320,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["RFC03"] = {
        id = "RFC03", name = "Searing Blade Warlock", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 11438,
        zone = "Ragefire Chasm", creatureType = "Humanoid", faction = "Burning Blade", npcId = 11324,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["RFC04"] = {
        id = "RFC04", name = "Molten Elemental", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 2075,
        zone = "Ragefire Chasm", creatureType = "Elemental", npcId = 11321,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["RFC05"] = {
        id = "RFC05", name = "Oggleflint", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 4, firstStrike = true, isMob = true, isBoss = true, displayId = 11611,
        zone = "Ragefire Chasm", creatureType = "Humanoid", npcId = 11517,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["RFC06"] = {
        id = "RFC06", name = "Jergosh the Invoker", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 3, toughness = 5, deathtouch = true, isMob = true, isBoss = true, displayId = 11429,
        zone = "Ragefire Chasm", creatureType = "Humanoid", faction = "Burning Blade", npcId = 11518,
        anthem = { tag = "faction", value = "Burning Blade", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch. Other Burning Blade you control get +1/+1."
    },
    ["RFC07"] = {
        id = "RFC07", name = "Taragaman the Hungerer", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 6, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 7970,
        zone = "Ragefire Chasm", creatureType = "Humanoid", faction = "Burning Blade", npcId = 11520,
        anthem = { tag = "zone", value = "Ragefire Chasm", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample. Other Ragefire Chasm creatures you control get +1/+1."
    },

    -- THE DEADMINES
    ["DMS01"] = {
        id = "DMS01", name = "Defias Pirate", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 2347,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 657,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["DMS02"] = {
        id = "DMS02", name = "Defias Watchman", cost = "{1}{W}", cmc = 2, color = "W", type = "Creature",
        power = 2, toughness = 4, vigilance = true, isMob = true, isBoss = true, displayId = 184,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 1725,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["DMS03"] = {
        id = "DMS03", name = "Goblin Engineer", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 7109,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 622,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DMS04"] = {
        id = "DMS04", name = "Defias Blackguard", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 3, unblockable = true, isMob = true, isBoss = true, displayId = 2314,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 636,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Cannot be blocked."
    },
    ["DMS05"] = {
        id = "DMS05", name = "Defias Evoker", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 2318,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 1729,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DMS06"] = {
        id = "DMS06", name = "Gilnid", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 5, firstStrike = true, isMob = true, isBoss = true, displayId = 7124,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 1763,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["DMS07"] = {
        id = "DMS07", name = "Rhahk'Zor", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 14403,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 644,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["DMS08"] = {
        id = "DMS08", name = "Sneed's Shredder", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 5, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 1269,
        zone = "The Deadmines", creatureType = "Mechanical", faction = "Defias", npcId = 642,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample."
    },
    ["DMS09"] = {
        id = "DMS09", name = "Cookie", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 5, toughness = 6, lifelink = true, isMob = true, isBoss = true, displayId = 1305,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 645,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["DMS10"] = {
        id = "DMS10", name = "Captain Greenskin", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 5, toughness = 6, vigilance = true, isMob = true, isBoss = true, displayId = 7113,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 647,
        anthem = { tag = "faction", value = "Defias", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance. Other Defias you control get +1/+1."
    },
    ["DMS11"] = {
        id = "DMS11", name = "Mr. Smite", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 2026,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias", npcId = 646,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },

    -- WAILING CAVERNS
    ["WCV01"] = {
        id = "WCV01", name = "Deviate Adder", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 2, toughness = 2, deathtouch = true, isMob = true, isBoss = true, displayId = 4317,
        zone = "Wailing Caverns", creatureType = "Beast", npcId = 5048,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["WCV02"] = {
        id = "WCV02", name = "Deviate Ravager", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 4, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 1747,
        zone = "Wailing Caverns", creatureType = "Beast", npcId = 3636,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["WCV03"] = {
        id = "WCV03", name = "Deviate Guardian", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 2, toughness = 7, defender = true, isMob = true, isBoss = true, displayId = 755,
        zone = "Wailing Caverns", creatureType = "Beast", npcId = 3637,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Defender."
    },
    ["WCV04"] = {
        id = "WCV04", name = "Druid of the Fang", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 4233,
        zone = "Wailing Caverns", creatureType = "Humanoid", faction = "Druids of the Fang", npcId = 3840,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["WCV05"] = {
        id = "WCV05", name = "Deviate Faerie Dragon", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, flying = true, isMob = true, isBoss = true, displayId = 1267,
        zone = "Wailing Caverns", creatureType = "Dragonkin", npcId = 5912,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["WCV06"] = {
        id = "WCV06", name = "Skum", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 4, toughness = 5, isMob = true, isBoss = true, displayId = 4203,
        zone = "Wailing Caverns", creatureType = "Beast", npcId = 3674,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["WCV07"] = {
        id = "WCV07", name = "Kresh", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 8, vigilance = true, isMob = true, isBoss = true, displayId = 5126,
        zone = "Wailing Caverns", creatureType = "Beast", npcId = 3653,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["WCV08"] = {
        id = "WCV08", name = "Lady Anacondra", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 5, toughness = 6, lifelink = true, isMob = true, isBoss = true, displayId = 4313,
        zone = "Wailing Caverns", creatureType = "Humanoid", faction = "Druids of the Fang", npcId = 3671,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["WCV09"] = {
        id = "WCV09", name = "Lord Cobrahn", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 5, toughness = 6, deathtouch = true, isMob = true, isBoss = true, displayId = 4213,
        zone = "Wailing Caverns", creatureType = "Humanoid", faction = "Druids of the Fang", npcId = 3669,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["WCV10"] = {
        id = "WCV10", name = "Lord Pythas", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 6, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 4214,
        zone = "Wailing Caverns", creatureType = "Humanoid", faction = "Druids of the Fang", npcId = 3670,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["WCV11"] = {
        id = "WCV11", name = "Lord Serpentis", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 6, toughness = 6, deathtouch = true, isMob = true, isBoss = true, displayId = 4215,
        zone = "Wailing Caverns", creatureType = "Humanoid", faction = "Druids of the Fang", npcId = 3673,
        anthem = { tag = "faction", value = "Druids of the Fang", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch. Other Druids of the Fang you control get +1/+1."
    },
    ["WCV12"] = {
        id = "WCV12", name = "Verdan the Everliving", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 7, toughness = 8, trample = true, isMob = true, isBoss = true, displayId = 4256,
        zone = "Wailing Caverns", creatureType = "Elemental", npcId = 5775,
        anthem = { tag = "zone", value = "Wailing Caverns", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample. Other Wailing Caverns creatures you control get +1/+1."
    },

    -- SHADOWFANG KEEP
    ["SFK01"] = {
        id = "SFK01", name = "Shadowfang Whitescalp", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 729,
        zone = "Shadowfang Keep", creatureType = "Humanoid", faction = "Worgen", npcId = 3851,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SFK02"] = {
        id = "SFK02", name = "Slavering Worg", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 11421,
        zone = "Shadowfang Keep", creatureType = "Beast", npcId = 3862,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["SFK03"] = {
        id = "SFK03", name = "Haunted Servitor", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 3229,
        zone = "Shadowfang Keep", creatureType = "Undead", npcId = 3875,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SFK04"] = {
        id = "SFK04", name = "Vile Bat", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 3, flying = true, lifelink = true, isMob = true, isBoss = true, displayId = 8808,
        zone = "Shadowfang Keep", creatureType = "Beast", npcId = 3866,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying, Lifelink."
    },
    ["SFK05"] = {
        id = "SFK05", name = "Lupine Horror", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 2446,
        zone = "Shadowfang Keep", creatureType = "Undead", faction = "Worgen", npcId = 3863,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SFK06"] = {
        id = "SFK06", name = "Rethilgore", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 5, toughness = 6, isMob = true, isBoss = true, displayId = 524,
        zone = "Shadowfang Keep", creatureType = "Humanoid", npcId = 3914,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SFK07"] = {
        id = "SFK07", name = "Razorclaw the Butcher", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 524,
        zone = "Shadowfang Keep", creatureType = "Humanoid", faction = "Worgen", npcId = 3886,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["SFK08"] = {
        id = "SFK08", name = "Odo the Blindwatcher", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 6, toughness = 5, haste = true, isMob = true, isBoss = true, displayId = 522,
        zone = "Shadowfang Keep", creatureType = "Humanoid", faction = "Worgen", npcId = 4279,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["SFK09"] = {
        id = "SFK09", name = "Baron Silverlaine", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 7, lifelink = true, isMob = true, isBoss = true, displayId = 3222,
        zone = "Shadowfang Keep", creatureType = "Undead", npcId = 3887,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["SFK10"] = {
        id = "SFK10", name = "Commander Springvale", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 5, toughness = 6, vigilance = true, isMob = true, isBoss = true, displayId = 3223,
        zone = "Shadowfang Keep", creatureType = "Undead", npcId = 4278,
        anthem = { tag = "zone", value = "Shadowfang Keep", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance. Other Shadowfang Keep creatures you control get +1/+1."
    },
    ["SFK11"] = {
        id = "SFK11", name = "Wolf Master Nandos", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 6, toughness = 5, haste = true, isMob = true, isBoss = true, displayId = 11179,
        zone = "Shadowfang Keep", creatureType = "Humanoid", faction = "Worgen", npcId = 3927,
        anthem = { tag = "faction", value = "Worgen", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste. Other Worgen you control get +1/+1."
    },
    ["SFK12"] = {
        id = "SFK12", name = "Fenrus the Devourer", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 7, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 2352,
        zone = "Shadowfang Keep", creatureType = "Beast", npcId = 4274,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },

    -- BLACKFATHOM DEEPS
    ["BFD01"] = {
        id = "BFD01", name = "Blindlight Murloc", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 4920,
        zone = "Blackfathom Deeps", creatureType = "Humanoid", faction = "Murloc", npcId = 4818,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BFD02"] = {
        id = "BFD02", name = "Aku'mai Fisher", cost = "{1}{U}", cmc = 2, color = "U", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 1244,
        zone = "Blackfathom Deeps", creatureType = "Beast", npcId = 4824,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["BFD03"] = {
        id = "BFD03", name = "Fallenroot Shadowstalker", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 2, unblockable = true, isMob = true, isBoss = true, displayId = 2014,
        zone = "Blackfathom Deeps", creatureType = "Demon", faction = "Satyr", npcId = 4798,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Cannot be blocked."
    },
    ["BFD04"] = {
        id = "BFD04", name = "Twilight Reaver", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 2901,
        zone = "Blackfathom Deeps", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 4810,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BFD05"] = {
        id = "BFD05", name = "Blackfathom Sea Witch", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 5, isMob = true, isBoss = true, displayId = 4982,
        zone = "Blackfathom Deeps", creatureType = "Humanoid", faction = "Naga", npcId = 4805,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BFD06"] = {
        id = "BFD06", name = "Lady Sarevess", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 5, firstStrike = true, isMob = true, isBoss = true, displayId = 4979,
        zone = "Blackfathom Deeps", creatureType = "Humanoid", faction = "Naga", npcId = 4831,
        anthem = { tag = "faction", value = "Naga", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike. Other Naga you control get +1/+1."
    },
    ["BFD07"] = {
        id = "BFD07", name = "Ghamoo-ra", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 9, vigilance = true, isMob = true, isBoss = true, displayId = 5027,
        zone = "Blackfathom Deeps", creatureType = "Beast", npcId = 4887,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Vigilance."
    },
    ["BFD08"] = {
        id = "BFD08", name = "Lorgus Jett", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 5, haste = true, isMob = true, isBoss = true, displayId = 12822,
        zone = "Blackfathom Deeps", creatureType = "Humanoid", npcId = 12902,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["BFD09"] = {
        id = "BFD09", name = "Gelihast", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 5, toughness = 5, isMob = true, isBoss = true, displayId = 1773,
        zone = "Blackfathom Deeps", creatureType = "Humanoid", faction = "Murloc", npcId = 6243,
        rally = { tag = "faction", value = "Murloc", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Gets +1/+1 for each other Murloc you control."
    },
    ["BFD10"] = {
        id = "BFD10", name = "Old Serra'kis", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 7, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 1816,
        zone = "Blackfathom Deeps", creatureType = "Beast", npcId = 4830,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample."
    },
    ["BFD11"] = {
        id = "BFD11", name = "Twilight Lord Kelris", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 5, toughness = 7, lifelink = true, isMob = true, isBoss = true, displayId = 4939,
        zone = "Blackfathom Deeps", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 4832,
        anthem = { tag = "faction", value = "Twilight's Hammer", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink. Other Twilight's Hammer you control get +1/+1."
    },

    -- THE STOCKADE
    ["STK01"] = {
        id = "STK01", name = "Defias Prisoner", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 2148,
        zone = "The Stockade", creatureType = "Humanoid", faction = "Defias", npcId = 1706,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STK02"] = {
        id = "STK02", name = "Defias Insurgent", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 3, haste = true, isMob = true, isBoss = true, displayId = 2147,
        zone = "The Stockade", creatureType = "Humanoid", faction = "Defias", npcId = 1715,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["STK03"] = {
        id = "STK03", name = "Targorr the Dread", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 517,
        zone = "The Stockade", creatureType = "Humanoid", faction = "Defias", npcId = 1696,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["STK04"] = {
        id = "STK04", name = "Dextren Ward", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 5, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 2149,
        zone = "The Stockade", creatureType = "Humanoid", faction = "Defias", npcId = 1663,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["STK05"] = {
        id = "STK05", name = "Kam Deepfury", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 4, toughness = 7, vigilance = true, isMob = true, isBoss = true, displayId = 825,
        zone = "The Stockade", creatureType = "Humanoid", faction = "Defias", npcId = 1666,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["STK06"] = {
        id = "STK06", name = "Hamhock", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 8, isMob = true, isBoss = true, displayId = 3250,
        zone = "The Stockade", creatureType = "Humanoid", faction = "Defias", npcId = 1717,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["STK07"] = {
        id = "STK07", name = "Bruegal Ironknuckle", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 6, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 2142,
        zone = "The Stockade", creatureType = "Humanoid", faction = "Defias", npcId = 1720,
        anthem = { tag = "zone", value = "The Stockade", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike. Other Stockade creatures you control get +1/+1."
    },

    -- GNOMEREGAN
    ["GNO01"] = {
        id = "GNO01", name = "Caverndeep Burrower", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 830,
        zone = "Gnomeregan", creatureType = "Humanoid", npcId = 6206,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["GNO02"] = {
        id = "GNO02", name = "Leprous Defender", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 5, vigilance = true, isMob = true, isBoss = true, displayId = 6982,
        zone = "Gnomeregan", creatureType = "Humanoid", npcId = 6223,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["GNO03"] = {
        id = "GNO03", name = "Mechano-Flamewalker", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 6890,
        zone = "Gnomeregan", creatureType = "Mechanical", npcId = 6226,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["GNO04"] = {
        id = "GNO04", name = "Mechano-Frostwalker", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 5, isMob = true, isBoss = true, displayId = 6891,
        zone = "Gnomeregan", creatureType = "Mechanical", npcId = 6227,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["GNO05"] = {
        id = "GNO05", name = "Viscous Fallout", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 5, deathtouch = true, isMob = true, isBoss = true, displayId = 5497,
        zone = "Gnomeregan", creatureType = "Elemental", npcId = 7079,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["GNO06"] = {
        id = "GNO06", name = "Dark Iron Ambassador", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 6669,
        zone = "Gnomeregan", creatureType = "Humanoid", faction = "Dark Iron", npcId = 6228,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["GNO07"] = {
        id = "GNO07", name = "Electrocutioner 6000", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 6, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 6915,
        zone = "Gnomeregan", creatureType = "Mechanical", npcId = 6235,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["GNO08"] = {
        id = "GNO08", name = "Crowd Pummeler 9-60", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 6, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 6774,
        zone = "Gnomeregan", creatureType = "Mechanical", npcId = 6229,
        anthem = { tag = "type", value = "Mechanical", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample. Other Mechanicals you control get +1/+1."
    },

    -- RAZORFEN KRAUL
    ["RFK01"] = {
        id = "RFK01", name = "Razorfen Warrior", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 6109,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar", npcId = 4435,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["RFK02"] = {
        id = "RFK02", name = "Razorfen Quilguard", cost = "{1}{W}", cmc = 2, color = "W", type = "Creature",
        power = 2, toughness = 4, vigilance = true, isMob = true, isBoss = true, displayId = 6108,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar", npcId = 4436,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["RFK03"] = {
        id = "RFK03", name = "Razorfen Geomancer", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 4647,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar", npcId = 4520,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["RFK04"] = {
        id = "RFK04", name = "Kraul Bat", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 3, flying = true, isMob = true, isBoss = true, displayId = 1955,
        zone = "Razorfen Kraul", creatureType = "Beast", npcId = 4538,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["RFK05"] = {
        id = "RFK05", name = "Death's Head Priest", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 6096,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar", npcId = 4517,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["RFK06"] = {
        id = "RFK06", name = "Blind Hunter", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 5, toughness = 5, flying = true, isMob = true, isBoss = true, displayId = 4735,
        zone = "Razorfen Kraul", creatureType = "Beast", npcId = 4425,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["RFK07"] = {
        id = "RFK07", name = "Roogug", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 6, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 6110,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar", npcId = 6168,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["RFK08"] = {
        id = "RFK08", name = "Aggem Thorncurse", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 5, toughness = 7, lifelink = true, isMob = true, isBoss = true, displayId = 6097,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar", npcId = 4424,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["RFK09"] = {
        id = "RFK09", name = "Death Speaker Jargba", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 7, deathtouch = true, isMob = true, isBoss = true, displayId = 4644,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar", npcId = 4428,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["RFK10"] = {
        id = "RFK10", name = "Earthcaller Halmgar", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 7, toughness = 8, vigilance = true, isMob = true, isBoss = true, displayId = 6102,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar", npcId = 4842,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["RFK11"] = {
        id = "RFK11", name = "Overlord Ramtusk", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 6, trample = true, isMob = true, isBoss = true, displayId = 4652,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar", npcId = 4420,
        anthem = { tag = "faction", value = "Quilboar", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample. Other Quilboar you control get +1/+1."
    },
    ["RFK12"] = {
        id = "RFK12", name = "Agathelos the Raging", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 7, toughness = 7, haste = true, trample = true, isMob = true, isBoss = true, displayId = 2450,
        zone = "Razorfen Kraul", creatureType = "Beast", npcId = 4422,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Haste, Trample."
    },

    -- SCARLET MONASTERY
    ["SMO01"] = {
        id = "SMO01", name = "Scarlet Torturer", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 2607,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 4306,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SMO02"] = {
        id = "SMO02", name = "Scarlet Tracking Hound", cost = "{1}{G}", cmc = 2, color = "G", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 2709,
        zone = "Scarlet Monastery", creatureType = "Beast", faction = "Scarlet Crusade", npcId = 4304,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["SMO03"] = {
        id = "SMO03", name = "Scarlet Monk", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 4, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 2604,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 4540,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["SMO04"] = {
        id = "SMO04", name = "Scarlet Adept", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 5725,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 4296,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["SMO05"] = {
        id = "SMO05", name = "Haunting Phantasm", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 3, unblockable = true, isMob = true, isBoss = true, displayId = 4629,
        zone = "Scarlet Monastery", creatureType = "Undead", npcId = 6427,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Cannot be blocked."
    },
    ["SMO06"] = {
        id = "SMO06", name = "Scarlet Myrmidon", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 4, trample = true, isMob = true, isBoss = true, displayId = 2515,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 4295,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["SMO07"] = {
        id = "SMO07", name = "Scarlet Champion", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 3, toughness = 3, vigilance = true, isMob = true, isBoss = true, displayId = 2460,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 4302,
        rally = { tag = "faction", value = "Scarlet Crusade", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance. Gets +1/+1 for each other Scarlet Crusade you control."
    },
    ["SMO08"] = {
        id = "SMO08", name = "Interrogator Vishas", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 5, toughness = 6, deathtouch = true, isMob = true, isBoss = true, displayId = 2044,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 3983,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["SMO09"] = {
        id = "SMO09", name = "Houndmaster Loksey", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 5, toughness = 5, haste = true, isMob = true, isBoss = true, displayId = 2040,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 3974,
        anthem = { tag = "type", value = "Beast", kw = { "haste" } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste. Other Beasts you control have Haste."
    },
    ["SMO10"] = {
        id = "SMO10", name = "Fallen Champion", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 7, lifelink = true, isMob = true, isBoss = true, displayId = 5230,
        zone = "Scarlet Monastery", creatureType = "Undead", npcId = 6488,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["SMO11"] = {
        id = "SMO11", name = "Ironspine", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 8, trample = true, isMob = true, isBoss = true, displayId = 5231,
        zone = "Scarlet Monastery", creatureType = "Undead", npcId = 6489,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["SMO12"] = {
        id = "SMO12", name = "High Inquisitor Fairbanks", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 6, toughness = 8, lifelink = true, isMob = true, isBoss = true, displayId = 2605,
        zone = "Scarlet Monastery", creatureType = "Undead", faction = "Scarlet Crusade", npcId = 4542,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["SMO13"] = {
        id = "SMO13", name = "Scarlet Commander Mograine", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 7, toughness = 8, firstStrike = true, vigilance = true, isMob = true, isBoss = true, displayId = 2042,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 3976,
        anthem = { tag = "faction", value = "Scarlet Crusade", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike, Vigilance. Other Scarlet Crusade you control get +1/+1."
    },

    -- RAZORFEN DOWNS
    ["RFD01"] = {
        id = "RFD01", name = "Withered Warrior", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 11386,
        zone = "Razorfen Downs", creatureType = "Undead", npcId = 7327,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["RFD02"] = {
        id = "RFD02", name = "Skeletal Frostweaver", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 5, isMob = true, isBoss = true, displayId = 9783,
        zone = "Razorfen Downs", creatureType = "Undead", npcId = 7341,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["RFD03"] = {
        id = "RFD03", name = "Boneflayer Ghoul", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 4, toughness = 3, haste = true, isMob = true, isBoss = true, displayId = 1065,
        zone = "Razorfen Downs", creatureType = "Undead", npcId = 7347,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["RFD04"] = {
        id = "RFD04", name = "Death's Head Necromancer", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 11381,
        zone = "Razorfen Downs", creatureType = "Humanoid", faction = "Quilboar", npcId = 7337,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["RFD05"] = {
        id = "RFD05", name = "Mordresh Fire Eye", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 8055,
        zone = "Razorfen Downs", creatureType = "Undead", faction = "Quilboar", npcId = 7357,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["RFD06"] = {
        id = "RFD06", name = "Glutton", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 9, lifelink = true, isMob = true, isBoss = true, displayId = 7864,
        zone = "Razorfen Downs", creatureType = "Undead", faction = "Quilboar", npcId = 8567,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Lifelink."
    },
    ["RFD07"] = {
        id = "RFD07", name = "Ragglesnout", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 8, trample = true, isMob = true, isBoss = true, displayId = 11382,
        zone = "Razorfen Downs", creatureType = "Humanoid", faction = "Quilboar", npcId = 7354,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },

    -- ULDAMAN
    ["ULD01"] = {
        id = "ULD01", name = "Stonevault Rockchewer", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 721,
        zone = "Uldaman", creatureType = "Humanoid", npcId = 4851,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ULD02"] = {
        id = "ULD02", name = "Shadowforge Relic Hunter", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 4, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 6054,
        zone = "Uldaman", creatureType = "Humanoid", faction = "Dark Iron", npcId = 4847,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["ULD03"] = {
        id = "ULD03", name = "Jadespine Basilisk", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 5, isMob = true, isBoss = true, displayId = 4486,
        zone = "Uldaman", creatureType = "Beast", npcId = 4863,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ULD04"] = {
        id = "ULD04", name = "Venomlash Scorpid", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 4, deathtouch = true, isMob = true, isBoss = true, displayId = 2488,
        zone = "Uldaman", creatureType = "Beast", npcId = 7022,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["ULD05"] = {
        id = "ULD05", name = "Eric \"The Swift\"", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 4, haste = true, isMob = true, isBoss = true, displayId = 5708,
        zone = "Uldaman", creatureType = "Humanoid", npcId = 6907,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["ULD06"] = {
        id = "ULD06", name = "Baelog", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 5, toughness = 6, vigilance = true, isMob = true, isBoss = true, displayId = 5710,
        zone = "Uldaman", creatureType = "Humanoid", npcId = 6906,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["ULD07"] = {
        id = "ULD07", name = "Olaf", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 4, toughness = 8, vigilance = true, isMob = true, isBoss = true, displayId = 5709,
        zone = "Uldaman", creatureType = "Humanoid", npcId = 6908,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["ULD08"] = {
        id = "ULD08", name = "Revelosh", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 5945,
        zone = "Uldaman", creatureType = "Humanoid", npcId = 6910,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ULD09"] = {
        id = "ULD09", name = "Obsidian Sentinel", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 4, toughness = 9, defender = true, isMob = true, isBoss = true, displayId = 5285,
        zone = "Uldaman", creatureType = "Mechanical", npcId = 7023,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Defender."
    },
    ["ULD10"] = {
        id = "ULD10", name = "Galgann Firehammer", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 7, firstStrike = true, isMob = true, isBoss = true, displayId = 6059,
        zone = "Uldaman", creatureType = "Humanoid", faction = "Dark Iron", npcId = 7291,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["ULD11"] = {
        id = "ULD11", name = "Grimlok", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 8, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 11165,
        zone = "Uldaman", creatureType = "Humanoid", npcId = 4854,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["ULD12"] = {
        id = "ULD12", name = "Ancient Stone Keeper", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 7, toughness = 9, vigilance = true, isMob = true, isBoss = true, displayId = 10798,
        zone = "Uldaman", creatureType = "Elemental", npcId = 7206,
        anthem = { tag = "zone", value = "Uldaman", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Vigilance. Other Uldaman creatures you control get +1/+1."
    },

    -- ZUL'FARRAK
    ["ZFK01"] = {
        id = "ZFK01", name = "Sandfury Blood Drinker", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 3, lifelink = true, isMob = true, isBoss = true, displayId = 6423,
        zone = "Zul'Farrak", creatureType = "Humanoid", faction = "Troll", npcId = 5649,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["ZFK02"] = {
        id = "ZFK02", name = "Sandfury Shadowhunter", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 6425,
        zone = "Zul'Farrak", creatureType = "Humanoid", faction = "Troll", npcId = 7246,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ZFK03"] = {
        id = "ZFK03", name = "Sandfury Executioner", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 6440,
        zone = "Zul'Farrak", creatureType = "Humanoid", faction = "Troll", npcId = 7274,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["ZFK04"] = {
        id = "ZFK04", name = "Sul'lithuz Sandcrawler", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 5, isMob = true, isBoss = true, displayId = 7345,
        zone = "Zul'Farrak", creatureType = "Beast", npcId = 8095,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ZFK05"] = {
        id = "ZFK05", name = "Theka the Martyr", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 5, toughness = 7, lifelink = true, isMob = true, isBoss = true, displayId = 6696,
        zone = "Zul'Farrak", creatureType = "Undead", faction = "Troll", npcId = 7272,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["ZFK06"] = {
        id = "ZFK06", name = "Hydromancer Velratha", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 5, toughness = 7, isMob = true, isBoss = true, displayId = 6685,
        zone = "Zul'Farrak", creatureType = "Humanoid", faction = "Troll", npcId = 7795,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["ZFK07"] = {
        id = "ZFK07", name = "Witch Doctor Zum'rah", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 5, toughness = 6, deathtouch = true, isMob = true, isBoss = true, displayId = 6434,
        zone = "Zul'Farrak", creatureType = "Humanoid", faction = "Troll", npcId = 7271,
        anthem = { tag = "faction", value = "Troll", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch. Other Trolls you control get +1/+1."
    },
    ["ZFK08"] = {
        id = "ZFK08", name = "Ruuzlu", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 6687,
        zone = "Zul'Farrak", creatureType = "Humanoid", faction = "Troll", npcId = 7797,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["ZFK09"] = {
        id = "ZFK09", name = "Dustwraith", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 6, unblockable = true, isMob = true, isBoss = true, displayId = 9292,
        zone = "Zul'Farrak", creatureType = "Humanoid", npcId = 10081,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Cannot be blocked."
    },
    ["ZFK10"] = {
        id = "ZFK10", name = "Sandarr Dunereaver", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 8, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 9291,
        zone = "Zul'Farrak", creatureType = "Humanoid", faction = "Troll", npcId = 10080,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["ZFK11"] = {
        id = "ZFK11", name = "Antu'sul", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 7, toughness = 8, deathtouch = true, isMob = true, isBoss = true, displayId = 7353,
        zone = "Zul'Farrak", creatureType = "Humanoid", npcId = 8127,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },

    -- MARAUDON
    ["MAR01"] = {
        id = "MAR01", name = "Putridus Shadowstalker", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, unblockable = true, isMob = true, isBoss = true, displayId = 2021,
        zone = "Maraudon", creatureType = "Demon", faction = "Satyr", npcId = 11792,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Cannot be blocked."
    },
    ["MAR02"] = {
        id = "MAR02", name = "Barbed Lasher", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 5, reach = true, isMob = true, isBoss = true, displayId = 12347,
        zone = "Maraudon", creatureType = "Elemental", npcId = 12219,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["MAR03"] = {
        id = "MAR03", name = "Deeprot Stomper", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 2079,
        zone = "Maraudon", creatureType = "Elemental", npcId = 13141,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["MAR04"] = {
        id = "MAR04", name = "Celebrian Dryad", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 11714,
        zone = "Maraudon", creatureType = "Humanoid", npcId = 11793,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["MAR05"] = {
        id = "MAR05", name = "Theradrim Guardian", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 5, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 11712,
        zone = "Maraudon", creatureType = "Elemental", npcId = 11784,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample."
    },
    ["MAR06"] = {
        id = "MAR06", name = "Razorlash", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 6, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 12389,
        zone = "Maraudon", creatureType = "Elemental", npcId = 12258,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["MAR07"] = {
        id = "MAR07", name = "Noxxion", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 6, toughness = 8, deathtouch = true, isMob = true, isBoss = true, displayId = 11172,
        zone = "Maraudon", creatureType = "Elemental", npcId = 13282,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["MAR08"] = {
        id = "MAR08", name = "Lord Vyletongue", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 7, firstStrike = true, isMob = true, isBoss = true, displayId = 12334,
        zone = "Maraudon", creatureType = "Demon", npcId = 12236,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["MAR09"] = {
        id = "MAR09", name = "Tinkerer Gizlock", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 7, firstStrike = true, isMob = true, isBoss = true, displayId = 7125,
        zone = "Maraudon", creatureType = "Humanoid", npcId = 13601,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["MAR10"] = {
        id = "MAR10", name = "Celebras the Cursed", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 7, toughness = 8, lifelink = true, isMob = true, isBoss = true, displayId = 12350,
        zone = "Maraudon", creatureType = "Humanoid", npcId = 12225,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["MAR11"] = {
        id = "MAR11", name = "Rotgrip", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 9, toughness = 8, trample = true, isMob = true, isBoss = true, displayId = 13589,
        zone = "Maraudon", creatureType = "Beast", npcId = 13596,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample."
    },
    ["MAR12"] = {
        id = "MAR12", name = "Landslide", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 7, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 12293,
        zone = "Maraudon", creatureType = "Giant", npcId = 12203,
        anthem = { tag = "zone", value = "Maraudon", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample. Other Maraudon creatures you control get +1/+1."
    },

    -- SUNKEN TEMPLE
    ["SUN01"] = {
        id = "SUN01", name = "Atal'ai Warrior", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 7709,
        zone = "Sunken Temple", creatureType = "Humanoid", faction = "Troll", npcId = 5256,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SUN02"] = {
        id = "SUN02", name = "Murk Worm", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 4, deathtouch = true, isMob = true, isBoss = true, displayId = 7549,
        zone = "Sunken Temple", creatureType = "Beast", npcId = 5226,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["SUN03"] = {
        id = "SUN03", name = "Atal'ai Witch Doctor", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 6670,
        zone = "Sunken Temple", creatureType = "Humanoid", faction = "Troll", npcId = 5259,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["SUN04"] = {
        id = "SUN04", name = "Hakkari Frostwing", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 3, toughness = 3, flying = true, isMob = true, isBoss = true, displayId = 7569,
        zone = "Sunken Temple", creatureType = "Beast", npcId = 5291,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["SUN05"] = {
        id = "SUN05", name = "Nightmare Scalebane", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 5, toughness = 5, vigilance = true, isMob = true, isBoss = true, displayId = 7903,
        zone = "Sunken Temple", creatureType = "Dragonkin", npcId = 5277,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Vigilance."
    },
    ["SUN06"] = {
        id = "SUN06", name = "Gasher", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 5, haste = true, isMob = true, isBoss = true, displayId = 6698,
        zone = "Sunken Temple", creatureType = "Undead", faction = "Troll", npcId = 5713,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["SUN07"] = {
        id = "SUN07", name = "Hukku", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 5, toughness = 6, deathtouch = true, isMob = true, isBoss = true, displayId = 6702,
        zone = "Sunken Temple", creatureType = "Undead", faction = "Troll", npcId = 5715,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["SUN08"] = {
        id = "SUN08", name = "Spawn of Hakkar", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 6, flying = true, isMob = true, isBoss = true, displayId = 4065,
        zone = "Sunken Temple", creatureType = "Beast", npcId = 5708,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Flying."
    },
    ["SUN09"] = {
        id = "SUN09", name = "Ogom the Wretched", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 7, deathtouch = true, isMob = true, isBoss = true, displayId = 6709,
        zone = "Sunken Temple", creatureType = "Undead", faction = "Troll", npcId = 5711,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["SUN10"] = {
        id = "SUN10", name = "Jammal'an the Prophet", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 5, toughness = 6, lifelink = true, isMob = true, isBoss = true, displayId = 6708,
        zone = "Sunken Temple", creatureType = "Humanoid", faction = "Troll", npcId = 5710,
        rally = { tag = "faction", value = "Troll", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink. Gets +1/+1 for each other Troll you control."
    },
    ["SUN11"] = {
        id = "SUN11", name = "Morphaz", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 7, toughness = 7, flying = true, isMob = true, isBoss = true, displayId = 7975,
        zone = "Sunken Temple", creatureType = "Dragonkin", npcId = 5719,
        anthem = { tag = "type", value = "Dragonkin", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Flying. Other Dragonkin you control get +1/+1."
    },
    ["SUN12"] = {
        id = "SUN12", name = "Hazzas", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 7, toughness = 9, flying = true, vigilance = true, isMob = true, isBoss = true, displayId = 9584,
        zone = "Sunken Temple", creatureType = "Dragonkin", npcId = 5722,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Flying, Vigilance."
    },

    -- BLACKROCK DEPTHS
    ["BRD01"] = {
        id = "BRD01", name = "Anvilrage Guardsman", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 8750,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 8891,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BRD02"] = {
        id = "BRD02", name = "Fireguard", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 2172,
        zone = "Blackrock Depths", creatureType = "Elemental", npcId = 8909,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BRD03"] = {
        id = "BRD03", name = "Twilight's Hammer Torturer", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 4, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 8790,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Twilight's Hammer", npcId = 8912,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["BRD04"] = {
        id = "BRD04", name = "Anvilrage Medic", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 8752,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 8894,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["BRD05"] = {
        id = "BRD05", name = "Doomforge Dragoon", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 4, trample = true, isMob = true, isBoss = true, displayId = 8820,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 8899,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["BRD06"] = {
        id = "BRD06", name = "Lord Roccor", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 5781,
        zone = "Blackrock Depths", creatureType = "Elemental", npcId = 9025,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["BRD07"] = {
        id = "BRD07", name = "High Interrogator Gerstahn", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 5, toughness = 6, deathtouch = true, isMob = true, isBoss = true, displayId = 8761,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 9018,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["BRD08"] = {
        id = "BRD08", name = "Verek", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 6, toughness = 6, haste = true, isMob = true, isBoss = true, displayId = 9019,
        zone = "Blackrock Depths", creatureType = "Demon", npcId = 9042,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["BRD09"] = {
        id = "BRD09", name = "Molten War Golem", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 8179,
        zone = "Blackrock Depths", creatureType = "Elemental", npcId = 8908,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample."
    },
    ["BRD10"] = {
        id = "BRD10", name = "Houndmaster Grebmar", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 6, toughness = 6, haste = true, isMob = true, isBoss = true, displayId = 9212,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 9319,
        anthem = { tag = "type", value = "Beast", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste. Other Beasts you control get +1/+1."
    },
    ["BRD11"] = {
        id = "BRD11", name = "Fineous Darkvire", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 7, toughness = 7, lifelink = true, isMob = true, isBoss = true, displayId = 8704,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 9056,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["BRD12"] = {
        id = "BRD12", name = "Pyromancer Loregrain", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 8762,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 9024,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["BRD13"] = {
        id = "BRD13", name = "Warder Stilgiss", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 6, toughness = 9, isMob = true, isBoss = true, displayId = 9089,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 9041,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BRD14"] = {
        id = "BRD14", name = "Phalanx", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 7, toughness = 11, vigilance = true, isMob = true, isBoss = true, displayId = 8177,
        zone = "Blackrock Depths", creatureType = "Elemental", npcId = 9502,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Vigilance."
    },
    ["BRD15"] = {
        id = "BRD15", name = "Doom'rel", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 8, toughness = 9, lifelink = true, isMob = true, isBoss = true, displayId = 8687,
        zone = "Blackrock Depths", creatureType = "Undead", faction = "Dark Iron", npcId = 9039,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["BRD16"] = {
        id = "BRD16", name = "Golem Lord Argelmach", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 8, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 8759,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 8983,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["BRD17"] = {
        id = "BRD17", name = "Ambassador Flamelash", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 9, toughness = 8, firstStrike = true, isMob = true, isBoss = true, displayId = 8329,
        zone = "Blackrock Depths", creatureType = "Humanoid", npcId = 9156,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["BRD18"] = {
        id = "BRD18", name = "Bael'Gar", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 9, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 12162,
        zone = "Blackrock Depths", creatureType = "Giant", npcId = 9016,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample."
    },
    ["BRD19"] = {
        id = "BRD19", name = "Lord Incendius", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 8, toughness = 9, firstStrike = true, isMob = true, isBoss = true, displayId = 1204,
        zone = "Blackrock Depths", creatureType = "Elemental", npcId = 9017,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "First Strike."
    },
    ["BRD20"] = {
        id = "BRD20", name = "Panzor the Invincible", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 7, toughness = 11, hexproof = true, isMob = true, isBoss = true, displayId = 8270,
        zone = "Blackrock Depths", creatureType = "Elemental", npcId = 8923,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Hexproof."
    },
    ["BRD21"] = {
        id = "BRD21", name = "General Angerforge", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 9, toughness = 9, firstStrike = true, isMob = true, isBoss = true, displayId = 8756,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron", npcId = 9033,
        anthem = { tag = "faction", value = "Dark Iron", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike. Other Dark Iron you control get +1/+1."
    },
    ["BRD22"] = {
        id = "BRD22", name = "Magmus", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 9, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 12162,
        zone = "Blackrock Depths", creatureType = "Giant", npcId = 9938,
        anthem = { tag = "zone", value = "Blackrock Depths", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample. Other Blackrock Depths creatures you control get +1/+1."
    },

    -- BLACKROCK SPIRE
    ["BRS01"] = {
        id = "BRS01", name = "Scarshield Legionnaire", cost = "{1}{R}", cmc = 2, color = "R", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 9629,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Blackrock", npcId = 9097,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["BRS02"] = {
        id = "BRS02", name = "Spirestone Enforcer", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 11577,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Ogre", npcId = 9199,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["BRS03"] = {
        id = "BRS03", name = "Smolderthorn Headhunter", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 4, toughness = 3, haste = true, isMob = true, isBoss = true, displayId = 9682,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Troll", npcId = 9241,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["BRS04"] = {
        id = "BRS04", name = "Smolderthorn Shadow Priest", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 9728,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Troll", npcId = 9240,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["BRS05"] = {
        id = "BRS05", name = "Firebrand Pyromancer", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 4, toughness = 3, firstStrike = true, isMob = true, isBoss = true, displayId = 9656,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Blackrock", npcId = 9264,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["BRS06"] = {
        id = "BRS06", name = "Spire Spider", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 4, reach = true, isMob = true, isBoss = true, displayId = 9755,
        zone = "Blackrock Spire", creatureType = "Beast", npcId = 10374,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["BRS07"] = {
        id = "BRS07", name = "Blackhand Iron Guard", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 5, toughness = 6, vigilance = true, isMob = true, isBoss = true, displayId = 9696,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Blackrock", npcId = 10319,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["BRS08"] = {
        id = "BRS08", name = "Rage Talon Dragonspawn", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 6, isMob = true, isBoss = true, displayId = 2554,
        zone = "Blackrock Spire", creatureType = "Dragonkin", npcId = 9096,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["BRS09"] = {
        id = "BRS09", name = "Quartermaster Zigris", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 6, firstStrike = true, isMob = true, isBoss = true, displayId = 9738,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Blackrock", npcId = 9736,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["BRS10"] = {
        id = "BRS10", name = "Halycon", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 7, toughness = 6, haste = true, isMob = true, isBoss = true, displayId = 9567,
        zone = "Blackrock Spire", creatureType = "Beast", npcId = 10220,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["BRS11"] = {
        id = "BRS11", name = "Shadow Hunter Vosh'gajin", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 7, deathtouch = true, isMob = true, isBoss = true, displayId = 9732,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Troll", npcId = 9236,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["BRS12"] = {
        id = "BRS12", name = "War Master Voone", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 8, toughness = 7, firstStrike = true, isMob = true, isBoss = true, displayId = 9733,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Troll", npcId = 9237,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["BRS13"] = {
        id = "BRS13", name = "Mother Smolderweb", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 9, deathtouch = true, reach = true, isMob = true, isBoss = true, displayId = 9929,
        zone = "Blackrock Spire", creatureType = "Beast", npcId = 10596,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch, Reach."
    },
    ["BRS14"] = {
        id = "BRS14", name = "Jed Runewatcher", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 6, toughness = 7, vigilance = true, isMob = true, isBoss = true, displayId = 9686,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Blackrock", npcId = 10509,
        anthem = { tag = "faction", value = "Blackrock", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance. Other Blackrock you control get +1/+1."
    },
    ["BRS15"] = {
        id = "BRS15", name = "Spirestone Butcher", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 8, toughness = 8, isMob = true, isBoss = true, displayId = 11574,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Ogre", npcId = 9219,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["BRS16"] = {
        id = "BRS16", name = "Highlord Omokk", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 7, toughness = 8, trample = true, isMob = true, isBoss = true, displayId = 11565,
        zone = "Blackrock Spire", creatureType = "Humanoid", faction = "Ogre", npcId = 9196,
        rally = { tag = "faction", value = "Ogre", p = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample. Gets +1/+0 for each other Ogre you control."
    },
    ["BRS17"] = {
        id = "BRS17", name = "Goraluk Anvilcrack", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 9, toughness = 9, firstStrike = true, isMob = true, isBoss = true, displayId = 10222,
        zone = "Blackrock Spire", creatureType = "Humanoid", npcId = 10899,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["BRS18"] = {
        id = "BRS18", name = "Pyroguard Emberseer", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 9, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 2172,
        zone = "Blackrock Spire", creatureType = "Elemental", npcId = 9816,
        anthem = { tag = "type", value = "Elemental", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample. Other Elementals you control get +1/+1."
    },
    ["BRS19"] = {
        id = "BRS19", name = "The Beast", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 10, toughness = 10, haste = true, trample = true, isMob = true, isBoss = true, displayId = 10193,
        zone = "Blackrock Spire", creatureType = "Beast", npcId = 10430,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Haste, Trample."
    },

    -- DIRE MAUL
    ["DMA01"] = {
        id = "DMA01", name = "Wildspawn Rogue", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 2, toughness = 2, unblockable = true, isMob = true, isBoss = true, displayId = 2021,
        zone = "Dire Maul", creatureType = "Demon", faction = "Satyr", npcId = 11452,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Cannot be blocked."
    },
    ["DMA02"] = {
        id = "DMA02", name = "Warpwood Tangler", cost = "{2}{G}", cmc = 3, color = "G", type = "Creature",
        power = 3, toughness = 5, reach = true, isMob = true, isBoss = true, displayId = 9592,
        zone = "Dire Maul", creatureType = "Elemental", npcId = 11464,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Reach."
    },
    ["DMA03"] = {
        id = "DMA03", name = "Gordok Brute", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 5, toughness = 3, trample = true, isMob = true, isBoss = true, displayId = 12473,
        zone = "Dire Maul", creatureType = "Humanoid", faction = "Ogre", npcId = 11441,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample."
    },
    ["DMA04"] = {
        id = "DMA04", name = "Eldreth Sorcerer", cost = "{2}{U}", cmc = 3, color = "U", type = "Creature",
        power = 4, toughness = 4, isMob = true, isBoss = true, displayId = 11205,
        zone = "Dire Maul", creatureType = "Undead", npcId = 11470,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DMA05"] = {
        id = "DMA05", name = "Pusillin", cost = "{2}{R}", cmc = 3, color = "R", type = "Creature",
        power = 3, toughness = 2, haste = true, unblockable = true, isMob = true, isBoss = true, displayId = 7552,
        zone = "Dire Maul", creatureType = "Demon", npcId = 14354,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste, Cannot be blocked."
    },
    ["DMA06"] = {
        id = "DMA06", name = "Warpwood Crusher", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 6, toughness = 5, trample = true, isMob = true, isBoss = true, displayId = 12929,
        zone = "Dire Maul", creatureType = "Elemental", npcId = 13021,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample."
    },
    ["DMA07"] = {
        id = "DMA07", name = "Gordok Mage-Lord", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 11537,
        zone = "Dire Maul", creatureType = "Humanoid", faction = "Ogre", npcId = 11444,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["DMA08"] = {
        id = "DMA08", name = "Zevrim Thornhoof", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 6, lifelink = true, isMob = true, isBoss = true, displayId = 11335,
        zone = "Dire Maul", creatureType = "Demon", faction = "Satyr", npcId = 11490,
        anthem = { tag = "faction", value = "Satyr", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink. Other Satyrs you control get +1/+1."
    },
    ["DMA09"] = {
        id = "DMA09", name = "Lethtendris", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 8, deathtouch = true, isMob = true, isBoss = true, displayId = 14378,
        zone = "Dire Maul", creatureType = "Humanoid", npcId = 14327,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["DMA10"] = {
        id = "DMA10", name = "Hydrospawn", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 7, toughness = 8, isMob = true, isBoss = true, displayId = 5489,
        zone = "Dire Maul", creatureType = "Elemental", npcId = 13280,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["DMA11"] = {
        id = "DMA11", name = "Illyanna Ravenoak", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 7, toughness = 7, firstStrike = true, isMob = true, isBoss = true, displayId = 11270,
        zone = "Dire Maul", creatureType = "Undead", npcId = 11488,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["DMA12"] = {
        id = "DMA12", name = "Magister Kalendris", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 8, lifelink = true, isMob = true, isBoss = true, displayId = 14384,
        zone = "Dire Maul", creatureType = "Undead", npcId = 11487,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["DMA13"] = {
        id = "DMA13", name = "Cho'Rush the Observer", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 7, toughness = 8, isMob = true, isBoss = true, displayId = 11537,
        zone = "Dire Maul", creatureType = "Humanoid", faction = "Ogre", npcId = 14324,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["DMA14"] = {
        id = "DMA14", name = "Guard Mol'dar", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 8, vigilance = true, isMob = true, isBoss = true, displayId = 11561,
        zone = "Dire Maul", creatureType = "Humanoid", faction = "Ogre", npcId = 14326,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Vigilance."
    },
    ["DMA15"] = {
        id = "DMA15", name = "Stomper Kreeg", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 8, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 11545,
        zone = "Dire Maul", creatureType = "Humanoid", faction = "Ogre", npcId = 14322,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample."
    },
    ["DMA16"] = {
        id = "DMA16", name = "Tendris Warpwood", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 7, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 14383,
        zone = "Dire Maul", creatureType = "Elemental", npcId = 11489,
        anthem = { tag = "zone", value = "Dire Maul", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample. Other Dire Maul creatures you control get +1/+1."
    },
    ["DMA17"] = {
        id = "DMA17", name = "Captain Kromcrush", cost = "{4}{R}{R}", cmc = 6, color = "R", type = "Creature",
        power = 8, toughness = 8, vigilance = true, isMob = true, isBoss = true, displayId = 11564,
        zone = "Dire Maul", creatureType = "Humanoid", faction = "Ogre", npcId = 14325,
        anthem = { tag = "faction", value = "Ogre", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Vigilance. Other Ogres you control get +1/+1."
    },
    ["DMA18"] = {
        id = "DMA18", name = "Immol'thar", cost = "{5}{B}{B}", cmc = 7, color = "B", type = "Creature",
        power = 9, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 14173,
        zone = "Dire Maul", creatureType = "Demon", npcId = 11496,
        anthem = { tag = "type", value = "Demon", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample. Other Demons you control get +1/+1."
    },

    -- SCHOLOMANCE
    ["SCH01"] = {
        id = "SCH01", name = "Scholomance Acolyte", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 11157,
        zone = "Scholomance", creatureType = "Humanoid", npcId = 10471,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["SCH02"] = {
        id = "SCH02", name = "Risen Guard", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 5, vigilance = true, isMob = true, isBoss = true, displayId = 7848,
        zone = "Scholomance", creatureType = "Undead", npcId = 10489,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["SCH03"] = {
        id = "SCH03", name = "Scholomance Necromancer", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 4, lifelink = true, isMob = true, isBoss = true, displayId = 11163,
        zone = "Scholomance", creatureType = "Humanoid", npcId = 10477,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["SCH04"] = {
        id = "SCH04", name = "Diseased Ghoul", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 4, toughness = 3, haste = true, isMob = true, isBoss = true, displayId = 519,
        zone = "Scholomance", creatureType = "Undead", npcId = 10495,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["SCH05"] = {
        id = "SCH05", name = "Necrofiend", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 4, toughness = 5, deathtouch = true, reach = true, isMob = true, isBoss = true, displayId = 11178,
        zone = "Scholomance", creatureType = "Undead", npcId = 11551,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch, Reach."
    },
    ["SCH06"] = {
        id = "SCH06", name = "Risen Construct", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 12074,
        zone = "Scholomance", creatureType = "Undead", npcId = 10488,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample."
    },
    ["SCH07"] = {
        id = "SCH07", name = "Marduk Blackpool", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 7, firstStrike = true, isMob = true, isBoss = true, displayId = 10248,
        zone = "Scholomance", creatureType = "Undead", npcId = 10433,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["SCH08"] = {
        id = "SCH08", name = "Vectus", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 7, trample = true, isMob = true, isBoss = true, displayId = 2606,
        zone = "Scholomance", creatureType = "Undead", npcId = 10432,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["SCH09"] = {
        id = "SCH09", name = "Jandice Barov", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 6, toughness = 7, hexproof = true, isMob = true, isBoss = true, displayId = 11073,
        zone = "Scholomance", creatureType = "Undead", npcId = 10503,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Hexproof."
    },
    ["SCH10"] = {
        id = "SCH10", name = "Instructor Malicia", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 8, lifelink = true, isMob = true, isBoss = true, displayId = 11069,
        zone = "Scholomance", creatureType = "Humanoid", npcId = 10505,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["SCH11"] = {
        id = "SCH11", name = "Lorekeeper Polkelt", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 9, deathtouch = true, isMob = true, isBoss = true, displayId = 11492,
        zone = "Scholomance", creatureType = "Undead", npcId = 10901,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["SCH12"] = {
        id = "SCH12", name = "Doctor Theolen Krastinov", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 8, toughness = 7, firstStrike = true, isMob = true, isBoss = true, displayId = 10901,
        zone = "Scholomance", creatureType = "Humanoid", npcId = 11261,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["SCH13"] = {
        id = "SCH13", name = "Lord Alexei Barov", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 8, lifelink = true, isMob = true, isBoss = true, displayId = 11072,
        zone = "Scholomance", creatureType = "Undead", npcId = 10504,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["SCH14"] = {
        id = "SCH14", name = "Lady Illucia Barov", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 6, toughness = 8, hexproof = true, isMob = true, isBoss = true, displayId = 11835,
        zone = "Scholomance", creatureType = "Undead", npcId = 10502,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Hexproof."
    },
    ["SCH15"] = {
        id = "SCH15", name = "Rattlegore", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 8, toughness = 8, trample = true, isMob = true, isBoss = true, displayId = 12073,
        zone = "Scholomance", creatureType = "Undead", npcId = 11622,
        anthem = { tag = "zone", value = "Scholomance", p = 1, t = 1 },
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample. Other Scholomance creatures you control get +1/+1."
    },
    ["SCH16"] = {
        id = "SCH16", name = "The Ravenian", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 9, toughness = 9, trample = true, isMob = true, isBoss = true, displayId = 10433,
        zone = "Scholomance", creatureType = "Undead", npcId = 10507,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = "Trample."
    },
    ["SCH17"] = {
        id = "SCH17", name = "Ras Frostwhisper", cost = "{5}{U}{U}", cmc = 7, color = "U", type = "Creature",
        power = 8, toughness = 10, vigilance = true, isMob = true, isBoss = true, displayId = 7919,
        zone = "Scholomance", creatureType = "Undead", npcId = 10508,
        anthem = { tag = "type", value = "Undead", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance. Other Undead you control get +1/+1."
    },

    -- STRATHOLME
    ["STR01"] = {
        id = "STR01", name = "Crimson Initiate", cost = "{1}{W}", cmc = 2, color = "W", type = "Creature",
        power = 3, toughness = 3, isMob = true, isBoss = true, displayId = 10496,
        zone = "Stratholme", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 10420,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STR02"] = {
        id = "STR02", name = "Plague Ghoul", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 3, toughness = 2, haste = true, isMob = true, isBoss = true, displayId = 559,
        zone = "Stratholme", creatureType = "Undead", npcId = 10405,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["STR03"] = {
        id = "STR03", name = "Crimson Gallant", cost = "{2}{W}", cmc = 3, color = "W", type = "Creature",
        power = 3, toughness = 4, vigilance = true, isMob = true, isBoss = true, displayId = 10512,
        zone = "Stratholme", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 10424,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["STR04"] = {
        id = "STR04", name = "Rockwing Gargoyle", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 3, flying = true, isMob = true, isBoss = true, displayId = 7533,
        zone = "Stratholme", creatureType = "Undead", npcId = 10408,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Flying."
    },
    ["STR05"] = {
        id = "STR05", name = "Shrieking Banshee", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 2, toughness = 3, unblockable = true, isMob = true, isBoss = true, displayId = 10728,
        zone = "Stratholme", creatureType = "Undead", npcId = 10463,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Cannot be blocked."
    },
    ["STR06"] = {
        id = "STR06", name = "Crypt Crawler", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 3, toughness = 4, deathtouch = true, isMob = true, isBoss = true, displayId = 6841,
        zone = "Stratholme", creatureType = "Undead", npcId = 10412,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["STR07"] = {
        id = "STR07", name = "Patchwork Horror", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 6, toughness = 6, isMob = true, isBoss = true, displayId = 1693,
        zone = "Stratholme", creatureType = "Undead", npcId = 10414,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["STR08"] = {
        id = "STR08", name = "Venom Belcher", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 8, isMob = true, isBoss = true, displayId = 12819,
        zone = "Stratholme", creatureType = "Undead", npcId = 10417,
        modelCam = { zoom = 0.62, camScale = 1.16, z = -0.13, rotation = 0.15 },
        text = ""
    },
    ["STR09"] = {
        id = "STR09", name = "Magistrate Barthilas", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 6, toughness = 5, haste = true, isMob = true, isBoss = true, displayId = 10433,
        zone = "Stratholme", creatureType = "Undead", npcId = 10435,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Haste."
    },
    ["STR10"] = {
        id = "STR10", name = "Hearthsinger Forresten", cost = "{2}{B}{B}", cmc = 4, color = "B", type = "Creature",
        power = 5, toughness = 6, lifelink = true, isMob = true, isBoss = true, displayId = 10482,
        zone = "Stratholme", creatureType = "Undead", npcId = 10558,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["STR11"] = {
        id = "STR11", name = "The Unforgiven", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 6, toughness = 8, isMob = true, isBoss = true, displayId = 10771,
        zone = "Stratholme", creatureType = "Undead", npcId = 10516,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STR12"] = {
        id = "STR12", name = "Skul", cost = "{3}{U}{U}", cmc = 5, color = "U", type = "Creature",
        power = 7, toughness = 7, firstStrike = true, isMob = true, isBoss = true, displayId = 2606,
        zone = "Stratholme", creatureType = "Undead", npcId = 10393,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["STR13"] = {
        id = "STR13", name = "Cannon Master Willey", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 8, toughness = 7, isMob = true, isBoss = true, displayId = 10674,
        zone = "Stratholme", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 10997,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = ""
    },
    ["STR14"] = {
        id = "STR14", name = "Archivist Galford", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 8, firstStrike = true, isMob = true, isBoss = true, displayId = 10544,
        zone = "Stratholme", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 10811,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "First Strike."
    },
    ["STR15"] = {
        id = "STR15", name = "Malor the Zealous", cost = "{3}{W}{W}", cmc = 5, color = "W", type = "Creature",
        power = 7, toughness = 8, vigilance = true, isMob = true, isBoss = true, displayId = 10458,
        zone = "Stratholme", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 11032,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Vigilance."
    },
    ["STR16"] = {
        id = "STR16", name = "Baroness Anastari", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 8, lifelink = true, isMob = true, isBoss = true, displayId = 10698,
        zone = "Stratholme", creatureType = "Undead", npcId = 10436,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink."
    },
    ["STR17"] = {
        id = "STR17", name = "Nerub'enkan", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 7, toughness = 8, deathtouch = true, isMob = true, isBoss = true, displayId = 9793,
        zone = "Stratholme", creatureType = "Undead", npcId = 10437,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Deathtouch."
    },
    ["STR18"] = {
        id = "STR18", name = "Stonespine", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 8, toughness = 8, trample = true, isMob = true, isBoss = true, displayId = 7856,
        zone = "Stratholme", creatureType = "Undead", npcId = 10809,
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Trample."
    },
    ["STR19"] = {
        id = "STR19", name = "Maleki the Pallid", cost = "{4}{U}{U}", cmc = 6, color = "U", type = "Creature",
        power = 8, toughness = 8, isMob = true, isBoss = true, displayId = 10546,
        zone = "Stratholme", creatureType = "Humanoid", npcId = 10438,
        anthem = { tag = "zone", value = "Stratholme", p = 1, t = 1 },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Other Stratholme creatures you control get +1/+1."
    },
    ["STR20"] = {
        id = "STR20", name = "Grand Crusader Dathrohan", cost = "{5}{W}{W}", cmc = 7, color = "W", type = "Creature",
        power = 10, toughness = 10, lifelink = true, vigilance = true, isMob = true, isBoss = true, displayId = 10545,
        zone = "Stratholme", creatureType = "Humanoid", faction = "Scarlet Crusade", npcId = 10812,
        anthem = { tag = "faction", value = "Scarlet Crusade", kw = { "lifelink" } },
        modelCam = { zoom = 0.80, camScale = 1.00, z = -0.10, rotation = 0.15 },
        text = "Lifelink, Vigilance. Other Scarlet Crusade you control have Lifelink."
    },

    -- =========================================================================
    -- BOSS CARDS (WITH RESTORED ART PATHS & 3D MODEL DATA)
    -- =========================================================================
    -- RFC: Bazzalan
    ["BOSS01"] = {
        id = "BOSS01", name = "Bazzalan", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 4, toughness = 4, isBoss = true, displayId = 2007, achievementId = 629,
        zone = "Ragefire Chasm", creatureType = "Demon", faction = "Burning Blade",
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.10, rotation = 0.15 },
        text = "{T}: Target opponent loses 2 life and you gain 2 life."
    },

    -- Deadmines: Edwin VanCleef
    ["BOSS02"] = {
        id = "BOSS02", name = "Edwin VanCleef", cost = "{1}{R}{B}", cmc = 3, color = "B", type = "Creature",
        power = 5, toughness = 4, haste = true, firstStrike = true, isBoss = true, displayId = 2029, achievementId = 628,
        zone = "The Deadmines", creatureType = "Humanoid", faction = "Defias",
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.12, rotation = 0.20 },
        text = "Haste, First Strike."
    },

    -- Wailing Caverns: Mutanus the Devourer
    ["BOSS03"] = {
        id = "BOSS03", name = "Mutanus the Devourer", cost = "{3}{U}{B}", cmc = 5, color = "U", type = "Creature",
        power = 7, toughness = 8, isBoss = true, displayId = 4088, achievementId = 630,
        zone = "Wailing Caverns", creatureType = "Humanoid", faction = "Murloc",
        modelCam = { zoom = 0.55, camScale = 1.25, z = -0.18, rotation = 0.15 },
        text = "Whenever Mutanus attacks, target opponent discards a card and loses 1 life."
    },

    -- Shadowfang Keep: Archmage Arugal
    ["BOSS04"] = {
        id = "BOSS04", name = "Archmage Arugal", cost = "{2}{U}{U}", cmc = 4, color = "U", type = "Creature",
        power = 4, toughness = 6, isBoss = true, displayId = 2353, achievementId = 631,
        zone = "Shadowfang Keep", creatureType = "Humanoid",
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.10, rotation = 0.15 },
        text = "{T}: Put target tapped creature on top of its owner's library."
    },

    -- Blackfathom Deeps: Aku'mai
    ["BOSS05"] = {
        id = "BOSS05", name = "Aku'mai", cost = "{4}{G}{U}", cmc = 6, color = "G", type = "Creature",
        power = 8, toughness = 9, trample = true, isBoss = true, displayId = 2837, achievementId = 632,
        zone = "Blackfathom Deeps", creatureType = "Beast",
        modelCam = { zoom = 0.20, camScale = 1.80, z = 0.00, rotation = -0.30 },
        text = "Trample. Aku'mai can block up to two creatures each combat."
    },

    -- Stockade: Bazil Thredd
    ["BOSS06"] = {
        id = "BOSS06", name = "Bazil Thredd", cost = "{2}{B}", cmc = 3, color = "B", type = "Creature",
        power = 4, toughness = 4, isBoss = true, displayId = 1621, achievementId = 634,
        zone = "The Stockade", creatureType = "Humanoid", faction = "Defias",
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.12, rotation = 0.15 },
        text = "Other creatures you control get +1/+1."
    },

    -- Gnomeregan: Mekgineer Thermaplugg
    ["BOSS07"] = {
        id = "BOSS07", name = "Mekgineer Thermaplugg", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 7, isBoss = true, displayId = 6980, achievementId = 635,
        zone = "Gnomeregan", creatureType = "Humanoid",
        modelCam = { zoom = 0.70, camScale = 0.90, z = 0.05, rotation = 0.15 },
        text = "{T}: Deal 2 damage to each opposing creature."
    },

    -- Razorfen Kraul: Charlga Razorflank
    ["BOSS08"] = {
        id = "BOSS08", name = "Charlga Razorflank", cost = "{2}{G}{G}", cmc = 4, color = "G", type = "Creature",
        power = 5, toughness = 6, reach = true, isBoss = true, displayId = 4642, achievementId = 636,
        zone = "Razorfen Kraul", creatureType = "Humanoid", faction = "Quilboar",
        modelCam = { zoom = 0.70, camScale = 1.10, z = -0.12, rotation = 0.15 },
        text = "Reach. {T}: Tap target creature. It does not untap during its controller's next untap step."
    },

    -- SM Graveyard: Bloodmage Thalnos
    ["BOSS09"] = {
        id = "BOSS09", name = "Bloodmage Thalnos", cost = "{1}{B}", cmc = 2, color = "B", type = "Creature",
        power = 3, toughness = 3, deathtouch = true, isBoss = true, displayId = 11396, achievementId = 638,
        zone = "Scarlet Monastery", creatureType = "Undead", faction = "Scarlet Crusade",
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.10, rotation = 0.15 },
        text = "Deathtouch. When Bloodmage Thalnos dies, draw a card."
    },

    -- SM Library: Arcanist Doan
    ["BOSS10"] = {
        id = "BOSS10", name = "Arcanist Doan", cost = "{2}{U}{R}", cmc = 4, color = "R", type = "Creature",
        power = 5, toughness = 5, isBoss = true, displayId = 5266, achievementId = 638,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade",
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.12, rotation = 0.15 },
        text = "{T}: Deal 2 damage to all opposing creatures."
    },

    -- SM Armory: Herod
    ["BOSS11"] = {
        id = "BOSS11", name = "Herod", cost = "{2}{R}{R}", cmc = 4, color = "R", type = "Creature",
        power = 6, toughness = 5, haste = true, isBoss = true, displayId = 2041, achievementId = 638,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade",
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.15, rotation = 0.20 },
        text = "Haste. Herod attacks each combat if able."
    },

    -- SM Cathedral: High Inquisitor Whitemane
    ["BOSS12"] = {
        id = "BOSS12", name = "High Inquisitor Whitemane", cost = "{2}{W}{W}", cmc = 4, color = "W", type = "Creature",
        power = 4, toughness = 6, lifelink = true, isBoss = true, displayId = 2043, achievementId = 638,
        zone = "Scarlet Monastery", creatureType = "Humanoid", faction = "Scarlet Crusade",
        modelCam = { zoom = 0.85, camScale = 1.0, z = -0.15, rotation = 0.20 },
        text = "Lifelink. When Whitemane dies, return another target creature from your graveyard to the battlefield."
    },

    -- Razorfen Downs: Amnennar the Coldbringer
    ["BOSS13"] = {
        id = "BOSS13", name = "Amnennar the Coldbringer", cost = "{3}{U}{B}", cmc = 5, color = "U", type = "Creature",
        power = 6, toughness = 8, isBoss = true, displayId = 7971, achievementId = 637,
        zone = "Razorfen Downs", creatureType = "Undead",
        modelCam = { zoom = 0.65, camScale = 1.20, z = -0.15, rotation = 0.15 },
        text = "Whenever Amnennar attacks, tap target creature. That creature does not untap during its controller's next untap step."
    },

    -- Uldaman: Archaedas
    ["BOSS14"] = {
        id = "BOSS14", name = "Archaedas", cost = "{4}{W}{W}", cmc = 6, color = "W", type = "Creature",
        power = 8, toughness = 10, vigilance = true, hexproof = true, isBoss = true, displayId = 5988, achievementId = 639,
        zone = "Uldaman", creatureType = "Giant",
        modelCam = { zoom = 0.40, camScale = 1.40, z = -0.22, rotation = 0.15 },
        text = "Vigilance, Hexproof (Archaedas cannot be the target of spells or abilities your opponents control)."
    },

    -- Zul'Farrak: Chief Ukorz Sandscalp
    ["BOSS15"] = {
        id = "BOSS15", name = "Chief Ukorz Sandscalp", cost = "{3}{R}{R}", cmc = 5, color = "R", type = "Creature",
        power = 8, toughness = 7, trample = true, isBoss = true, displayId = 6439, achievementId = 640,
        zone = "Zul'Farrak", creatureType = "Humanoid", faction = "Troll",
        modelCam = { zoom = 0.70, camScale = 1.15, z = -0.15, rotation = 0.15 },
        text = "Trample. Ukorz gets +3/+0 as long as your life total is 10 or less."
    },

    -- Maraudon: Princess Theradras
    ["BOSS16"] = {
        id = "BOSS16", name = "Princess Theradras", cost = "{4}{G}{G}", cmc = 6, color = "G", type = "Creature",
        power = 9, toughness = 9, trample = true, isBoss = true, displayId = 12292, achievementId = 641,
        zone = "Maraudon", creatureType = "Elemental",
        modelCam = { zoom = 0.35, camScale = 1.60, z = -0.25, rotation = 0.10 },
        text = "Trample. Whenever Theradras deals combat damage to a player, destroy target non-basic land that player controls."
    },

    -- Sunken Temple: Shade of Eranikus
    ["BOSS17"] = {
        id = "BOSS17", name = "Shade of Eranikus", cost = "{3}{U}{G}", cmc = 5, color = "G", type = "Creature",
        power = 8, toughness = 8, flying = true, isBoss = true, displayId = 7806, achievementId = 642,
        zone = "Sunken Temple", creatureType = "Dragonkin",
        modelCam = { zoom = 0.25, camScale = 1.80, z = -0.05, rotation = -0.20 },
        text = "Flying. Whenever Eranikus deals combat damage to a creature, tap that creature and it does not untap during its controller's next untap step."
    },

    -- BRD: Emperor Dagran Thaurissan
    ["BOSS18"] = {
        id = "BOSS18", name = "Emperor Dagran Thaurissan", cost = "{3}{R}{W}", cmc = 5, color = "R", type = "Creature",
        power = 7, toughness = 7, isBoss = true, displayId = 8807, achievementId = 643,
        zone = "Blackrock Depths", creatureType = "Humanoid", faction = "Dark Iron",
        modelCam = { zoom = 0.75, camScale = 0.95, z = 0.00, rotation = 0.15 },
        text = "Other creatures you control gain +1/+1 and Vigilance."
    },

    -- LBRS: Overlord Wyrmthalak
    ["BOSS19"] = {
        id = "BOSS19", name = "Overlord Wyrmthalak", cost = "{4}{R}{B}", cmc = 6, color = "R", type = "Creature",
        power = 9, toughness = 8, trample = true, isBoss = true, displayId = 8711, achievementId = 644,
        zone = "Blackrock Spire", creatureType = "Dragonkin", faction = "Blackrock",
        modelCam = { zoom = 0.50, camScale = 1.35, z = -0.20, rotation = 0.15 },
        text = "Trample. When Wyrmthalak enters the battlefield, deal 3 damage to all opposing creatures."
    },

    -- UBRS: General Drakkisath
    ["BOSS20"] = {
        id = "BOSS20", name = "General Drakkisath", cost = "{5}{R}{R}", cmc = 7, color = "R", type = "Creature",
        power = 10, toughness = 9, trample = true, isBoss = true, displayId = 10115, achievementId = 1307,
        zone = "Blackrock Spire", creatureType = "Dragonkin", faction = "Blackrock",
        modelCam = { zoom = 0.40, camScale = 1.50, z = -0.25, rotation = 0.15 },
        text = "Trample. All other creatures lose and cannot gain Haste."
    },

    -- Dire Maul East: Alzzin the Wildshaper
    ["BOSS21"] = {
        id = "BOSS21", name = "Alzzin the Wildshaper", cost = "{3}{G}{G}", cmc = 5, color = "G", type = "Creature",
        power = 7, toughness = 8, deathtouch = true, isBoss = true, displayId = 14416, achievementId = 645,
        zone = "Dire Maul", creatureType = "Demon", faction = "Satyr",
        modelCam = { zoom = 0.70, camScale = 1.10, z = -0.15, rotation = 0.15 },
        text = "Deathtouch. {T}: You gain 4 life."
    },

    -- Dire Maul West: Prince Tortheldrin
    ["BOSS22"] = {
        id = "BOSS22", name = "Prince Tortheldrin", cost = "{2}{U}{B}", cmc = 4, color = "U", type = "Creature",
        power = 5, toughness = 5, isBoss = true, displayId = 11256, achievementId = 645,
        zone = "Dire Maul", creatureType = "Humanoid",
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.12, rotation = 0.15 },
        text = "{2}{U}: Draw a card, then discard a card. Tortheldrin gains +1/+1 until end of turn."
    },

    -- Dire Maul North: King Gordok
    ["BOSS23"] = {
        id = "BOSS23", name = "King Gordok", cost = "{4}{G}{R}", cmc = 6, color = "R", type = "Creature",
        power = 10, toughness = 8, trample = true, isBoss = true, displayId = 11583, achievementId = 645,
        zone = "Dire Maul", creatureType = "Humanoid", faction = "Ogre",
        modelCam = { zoom = 0.45, camScale = 1.45, z = -0.22, rotation = 0.15 },
        text = "Trample. Whenever King Gordok attacks, he gets +2/+0 until end of turn."
    },

    -- Scholomance: Darkmaster Gandling
    ["BOSS24"] = {
        id = "BOSS24", name = "Darkmaster Gandling", cost = "{3}{B}{B}", cmc = 5, color = "B", type = "Creature",
        power = 6, toughness = 7, isBoss = true, displayId = 11070, achievementId = 646,
        zone = "Scholomance", creatureType = "Humanoid",
        modelCam = { zoom = 0.80, camScale = 1.0, z = -0.12, rotation = 0.15 },
        text = "Whenever another creature dies, you draw a card."
    },

    -- Stratholme: Baron Rivendare
    ["BOSS25"] = {
        id = "BOSS25", name = "Baron Rivendare", cost = "{4}{B}{B}", cmc = 6, color = "B", type = "Creature",
        power = 8, toughness = 8, lifelink = true, isBoss = true, displayId = 10729, achievementId = 633,
        zone = "Stratholme", creatureType = "Undead",
        modelCam = { zoom = 0.70, camScale = 1.15, z = -0.18, rotation = 0.15 },
        text = "Lifelink. Whenever an opposing creature dies, its controller loses 2 life."
    },

    -- Stratholme: Balnazzar
    ["BOSS26"] = {
        id = "BOSS26", name = "Balnazzar", cost = "{4}{B}{U}", cmc = 6, color = "B", type = "Creature",
        power = 8, toughness = 9, flying = true, isBoss = true, displayId = 10691, achievementId = 633,
        zone = "Stratholme", creatureType = "Demon",
        modelCam = { zoom = 0.55, camScale = 1.30, z = -0.20, rotation = 0.15 },
        text = "Flying. When Balnazzar enters the battlefield, gain control of target opposing creature with power 4 or less."
    },
}


-- =========================================================================
-- SAVED DECK CLEANUP
-- Cards from earlier versions of the database no longer exist; drop them from saved decks once saved variables are loaded.
-- =========================================================================
function TTS:PruneRemovedCards()
    if not TTS_SavedDecks then return end
    local removed = 0
    for _, deck in pairs(TTS_SavedDecks) do
        if deck.cards then
            for id, qty in pairs(deck.cards) do
                if not TTS.Cards[id] then
                    deck.cards[id] = nil
                    removed = removed + qty
                end
            end
        end
    end
    if removed > 0 and DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFFFFA500[TTS]|r Removed %d card(s) that no longer exist from your saved decks.", removed))
    end
end

local pruneFrame = CreateFrame("Frame")
pruneFrame:RegisterEvent("PLAYER_LOGIN")
pruneFrame:SetScript("OnEvent", function(self)
    TTS:PruneRemovedCards()
    self:UnregisterAllEvents()
end)