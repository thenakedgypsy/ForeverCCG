--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
]]
-- Spell ids for the class spell cards (the WoW spell each card is named after), found by
-- exact name and class on Wowhead. Used only by the tools that fetch translated names;
-- the addon never loads this.
return {
    DRU01 = 5176, -- Wrath
    DRU02 = 8921, -- Moonfire
    DRU03 = 5185, -- Healing Touch
    DRU04 = 774, -- Rejuvenation
    DRU05 = 8936, -- Regrowth
    DRU06 = 1126, -- Mark of the Wild
    DRU07 = 339, -- Entangling Roots
    DRU08 = 467, -- Thorns
    DRU09 = 29166, -- Innervate
    DRU10 = 2912, -- Starfire
    HUN01 = 3044, -- Arcane Shot
    HUN02 = 1978, -- Serpent Sting
    HUN03 = 19434, -- Aimed Shot
    HUN04 = 2643, -- Multi-Shot
    HUN05 = 5116, -- Concussive Shot
    HUN06 = 1499, -- Freezing Trap
    HUN07 = 13795, -- Immolation Trap
    HUN08 = 136, -- Mend Pet
    HUN09 = 1130, -- Hunter's Mark
    HUN10 = 19574, -- Bestial Wrath
    MAG01 = 133, -- Fireball
    MAG02 = 2136, -- Fire Blast
    MAG03 = 2120, -- Flamestrike
    MAG04 = 11366, -- Pyroblast
    MAG05 = 116, -- Frostbolt
    MAG06 = 122, -- Frost Nova
    MAG07 = 10, -- Blizzard
    MAG08 = 118, -- Polymorph
    MAG09 = 5143, -- Arcane Missiles
    MAG10 = 1459, -- Arcane Intellect
    PAL01 = 635, -- Holy Light
    PAL02 = 19750, -- Flash of Light
    PAL03 = 19740, -- Blessing of Might
    PAL04 = 1022, -- Blessing of Protection
    PAL05 = 642, -- Divine Shield
    PAL06 = 853, -- Hammer of Justice
    PAL07 = 879, -- Exorcism
    PAL08 = 26573, -- Consecration
    PAL09 = 633, -- Lay on Hands
    PRI01 = 17, -- Power Word: Shield
    PRI02 = 139, -- Renew
    PRI03 = 2061, -- Flash Heal
    PRI04 = 596, -- Prayer of Healing
    PRI05 = 585, -- Smite
    PRI06 = 14914, -- Holy Fire
    PRI07 = 589, -- Shadow Word: Pain
    PRI08 = 8092, -- Mind Blast
    PRI09 = 605, -- Mind Control
    PRI10 = 8122, -- Psychic Scream
    ROG01 = 1752, -- Sinister Strike
    ROG02 = 53, -- Backstab
    ROG03 = 2098, -- Eviscerate
    ROG04 = 1776, -- Gouge
    ROG05 = 1833, -- Cheap Shot
    ROG06 = 2983, -- Sprint
    ROG07 = 1856, -- Vanish
    ROG08 = 5277, -- Evasion
    ROG09 = 5171, -- Slice and Dice
    ROG10 = 703, -- Garrote
    SHA01 = 403, -- Lightning Bolt
    SHA02 = 8042, -- Earth Shock
    SHA03 = 8050, -- Flame Shock
    SHA04 = 8056, -- Frost Shock
    SHA05 = 421, -- Chain Lightning
    SHA06 = 331, -- Healing Wave
    SHA07 = 8017, -- Rockbiter Weapon
    SHA08 = 8071, -- Stoneskin Totem
    SHA09 = 370, -- Purge
    SHA10 = 2008, -- Ancestral Spirit
    WAR01 = 78, -- Heroic Strike
    WAR02 = 100, -- Charge
    WAR03 = 772, -- Rend
    WAR04 = 2687, -- Bloodrage
    WAR05 = 6343, -- Thunder Clap
    WAR06 = 7384, -- Overpower
    WAR07 = 5308, -- Execute
    WAR08 = 871, -- Shield Wall
    WAR09 = 12294, -- Mortal Strike
    WAR10 = 1680, -- Whirlwind
    WLK01 = 686, -- Shadow Bolt
    WLK03 = 980, -- Curse of Agony
    WLK04 = 689, -- Drain Life
    WLK05 = 5484, -- Howl of Terror
    WLK06 = 6789, -- Death Coil
    WLK07 = 348, -- Immolate
    WLK08 = 6353, -- Soul Fire
    WLK09 = 1454, -- Life Tap
    -- Not found by the search parser; checked by hand on Wowhead
    PAL10 = 7328, -- Redemption
    WLK02 = 172, -- Corruption
    WLK10 = 1098, -- Enslave Demon (Wowhead now calls it Subjugate Demon)

    -- Italian names come from retail Wowhead, which no longer has these Classic ranks:
    -- the same spell's current retail id. (Immolation Trap, Blessing of Might, Bloodrage,
    -- Healing Touch, Heroic Strike and Rockbiter Weapon are gone from retail.)
    RETAIL = {
        [10] = 190356, -- Blizzard
        [1499] = 187650, -- Freezing Trap
        [1978] = 271788, -- Serpent Sting
        [2136] = 108853, -- Fire Blast
        [2912] = 194153, -- Starfire
        [3044] = 185358, -- Arcane Shot
        [331] = 77472, -- Healing Wave
        [403] = 188196, -- Lightning Bolt
        [421] = 188443, -- Chain Lightning
        [635] = 82326, -- Holy Light
        [689] = 234153, -- Drain Life
        [8050] = 188389, -- Flame Shock
        [8056] = 196840, -- Frost Shock
        [8071] = 383017, -- Stoneskin Totem
        [879] = 383185, -- Exorcism
    },
}
