--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
TTS.Sound = TTS.Sound or {}
local S = TTS.Sound

-- Master switch for every addon sound (toggled by the Sounds checkbox on the board)
S.enabled = true

function S:SetEnabled(on)
    self.enabled = on and true or false
end

-- =========================================================================
-- CREATURE SOUND DATA
-- [cardId] = { aggro = <sound>, death = <sound> }
--   <sound> = SoundKit ID (number)               -> PlaySound
--           = game sound file path (string)      -> PlaySoundFile
-- A creature card in the Cards files may also carry its own aggroSound / deathSound
-- field, which takes priority over this table.
--
-- Generated from the client tables (build 1.60.1.70338):
--   card displayId -> CreatureDisplayInfo.SoundID (or CreatureModelData.SoundID when 0)
--   -> CreatureSoundData.SoundAggroID / SoundDeathID
-- Bosses and elites with a voiced aggro / death line (ClassicDB world database)
-- use that line instead. Creatures whose sound data has no aggro sound play
-- only their death sound.
-- =========================================================================
TTS.CreatureSounds = {
    ["ALT01"] = { aggro = 1243, death = 1242 }, -- Mountain Yeti
    ["ALT02"] = { aggro = 1263, death = 2944 }, -- Syndicate Thief
    ["ALT03"] = { aggro = 1243, death = 1242 }, -- Giant Yeti
    ["ALT04"] = { aggro = 647, death = 646 }, -- Hulking Mountain Lion
    ["ALT05"] = { aggro = 1263, death = 2944 }, -- Syndicate Wizard
    ["ALT06"] = { aggro = 396, death = 400 }, -- Crushridge Ogre
    ["ALT07"] = { aggro = 396, death = 400 }, -- Crushridge Brute
    ["ALT08"] = { aggro = 1263, death = 2944 }, -- Syndicate Assassin
    ["ALT09"] = { aggro = 402, death = 406 }, -- Crushridge Mage
    ["ALT10"] = { aggro = 396, death = 400 }, -- Crushridge Warmonger
    ["ALT11"] = { aggro = 1263, death = 2944 }, -- Archmage Ansirem Runeweaver
    ["ARA01"] = { aggro = 694, death = 314 }, -- Drywhisker Kobold
    ["ARA02"] = { aggro = 447, death = 444 }, -- Elder Mesa Buzzard
    ["ARA03"] = { aggro = 1408, death = 1406 }, -- Cresting Exile
    ["ARA04"] = { aggro = 3789, death = 3787 }, -- Thundering Exile
    ["ARA05"] = { aggro = 3438, death = 3436 }, -- Daggerspine Raider
    ["ARA06"] = { aggro = 1263, death = 2944 }, -- Syndicate Prowler
    ["ARA07"] = { aggro = 1263, death = 2944 }, -- Stromgarde Troll Hunter
    ["ARA08"] = { aggro = 396, death = 400 }, -- Boulderfist Shaman
    ["ARA09"] = { aggro = 283054, death = 2940 }, -- Darbel Montrose
    ["ARA10"] = { aggro = 396, death = 400 }, -- Foulbelly
    ["ARA11"] = { death = 2940 }, -- Captain Nials
    ["ASH01"] = { aggro = 1230, death = 1228 }, -- Clattering Crawler
    ["ASH02"] = { aggro = 1230, death = 1228 }, -- Spined Crawler
    ["ASH03"] = { aggro = 478, death = 475 }, -- Ashenvale Bear
    ["ASH04"] = { aggro = 2656, death = 2654 }, -- Shadowhorn Stag
    ["ASH05"] = { aggro = 390, death = 394 }, -- Ghostpaw Howler
    ["ASH06"] = { aggro = 1408, death = 1406 }, -- Befouled Water Elemental
    ["ASH07"] = { aggro = 462, death = 458 }, -- Shadethicket Bark Ripper
    ["ASH08"] = { death = 213 }, -- Warsong Peon
    ["ASH09"] = { aggro = 390, death = 394 }, -- Ghostpaw Alpha
    ["ASH10"] = { aggro = 437, death = 441 }, -- Terrowulf Packlord
    ["ASH11"] = { death = 2936 }, -- Raene Wolfrunner
    ["AZS01"] = { aggro = 1173, death = 1171 }, -- Highborne Apparition
    ["AZS02"] = { aggro = 2656, death = 2654 }, -- Mosshoof Runner
    ["AZS03"] = { aggro = 3438, death = 3436 }, -- Spitelash Warrior
    ["AZS04"] = { aggro = 356, death = 357 }, -- Timbermaw Shaman
    ["AZS05"] = { aggro = 713, death = 712 }, -- Thunderhead Skystormer
    ["AZS06"] = { aggro = 3438, death = 3436 }, -- Spitelash Myrmidon
    ["AZS07"] = { aggro = 2656, death = 2654 }, -- Mosshoof Courser
    ["AZS08"] = { aggro = 1010, death = 1009 }, -- Legashi Rogue
    ["AZS09"] = { aggro = 1464, death = 1462 }, -- Coralshell Lurker
    ["AZS10"] = { aggro = 3685, death = 3683 }, -- Monnos the Elder
    ["AZS11"] = { aggro = 1415, death = 1413 }, -- Kim'jael
    ["BAD01"] = { death = 2932 }, -- Shadowforge Tunneler
    ["BAD02"] = { death = 2932 }, -- Shadowforge Darkweaver
    ["BAD03"] = { aggro = 447, death = 444 }, -- Starving Buzzard
    ["BAD04"] = { aggro = 647, death = 646 }, -- Ridge Huntress
    ["BAD05"] = { aggro = 739, death = 738 }, -- Rock Elemental
    ["BAD06"] = { aggro = 428, death = 432 }, -- Scalding Whelp
    ["BAD07"] = { death = 2932 }, -- Dark Iron Kidnapper
    ["BAD08"] = { death = 2932 }, -- Shadowforge Surveyor
    ["BAD09"] = { death = 2932 }, -- Shadowforge Digger
    ["BAD10"] = { aggro = 3685, death = 3683 }, -- Anathemus
    ["BAD11"] = { death = 3278 }, -- Lotwil Veriatus
    ["BFD01"] = { aggro = 416, death = 420 }, -- Blindlight Murloc
    ["BFD02"] = { aggro = 1464, death = 1462 }, -- Aku'mai Fisher
    ["BFD03"] = { aggro = 1010, death = 1009 }, -- Fallenroot Shadowstalker
    ["BFD04"] = { death = 229 }, -- Twilight Reaver
    ["BFD05"] = { aggro = 4025, death = 4023 }, -- Blackfathom Sea Witch
    ["BFD06"] = { aggro = 5799, death = 5801 }, -- Lady Sarevess
    ["BFD07"] = { aggro = 1464, death = 1462 }, -- Ghamoo-ra
    ["BFD08"] = { aggro = 1263, death = 2944 }, -- Lorgus Jett
    ["BFD09"] = { aggro = 416, death = 420 }, -- Gelihast
    ["BFD10"] = { aggro = 1236, death = 1234 }, -- Old Serra'kis
    ["BFD11"] = { aggro = 5802, death = 5803 }, -- Twilight Lord Kelris
    ["BFD12"] = { aggro = 1408, death = 1406 }, -- Baron Aquanis
    ["BLA01"] = { aggro = 2511, death = 2509 }, -- Starving Snickerfang
    ["BLA02"] = { aggro = 2511, death = 2509 }, -- Snickerfang Hyena
    ["BLA03"] = { aggro = 719, death = 718 }, -- Scorpok Stinger
    ["BLA04"] = { aggro = 1249, death = 1250 }, -- Felbeast
    ["BLA05"] = { aggro = 570, death = 569 }, -- Redstone Crystalhide
    ["BLA06"] = { aggro = 379, death = 383 }, -- Helboar
    ["BLA07"] = { death = 1318 }, -- Shadowsworn Warlock
    ["BLA08"] = { aggro = 283608, death = 18493 }, -- Shadowsworn Enforcer
    ["BLA09"] = { aggro = 396, death = 400 }, -- Dreadmaul Mauler
    ["BLA10"] = { death = 1322 }, -- Dreadscorn
    ["BLA11"] = { aggro = 596, death = 595 }, -- Kum'isha the Collector
    ["BOSS01"] = { aggro = 1010, death = 1009 }, -- Bazzalan
    ["BOSS02"] = { aggro = 5780, death = 2944 }, -- Edwin VanCleef
    ["BOSS03"] = { aggro = 416, death = 420 }, -- Mutanus the Devourer
    ["BOSS04"] = { aggro = 5793, death = 2944 }, -- Archmage Arugal
    ["BOSS05"] = { aggro = 5375, death = 449 }, -- Aku'mai
    ["BOSS06"] = { aggro = 1263, death = 2944 }, -- Bazil Thredd
    ["BOSS07"] = { aggro = 5807, death = 1980 }, -- Mekgineer Thermaplugg
    ["BOSS08"] = { aggro = 1181, death = 1179 }, -- Charlga Razorflank
    ["BOSS09"] = { aggro = 2517, death = 2515 }, -- Bloodmage Thalnos
    ["BOSS10"] = { aggro = 5842, death = 2944 }, -- Arcanist Doan
    ["BOSS11"] = { aggro = 5830, death = 2944 }, -- Herod
    ["BOSS12"] = { aggro = 283054, death = 2940 }, -- High Inquisitor Whitemane
    ["BOSS13"] = { aggro = 5800, death = 5796 }, -- Amnennar the Coldbringer
    ["BOSS14"] = { aggro = 5855 }, -- Archaedas
    ["BOSS15"] = { aggro = 344001, death = 3310 }, -- Chief Ukorz Sandscalp
    ["BOSS16"] = { aggro = 210, death = 213 }, -- Princess Theradras
    ["BOSS17"] = { aggro = 3525, death = 3523 }, -- Shade of Eranikus
    ["BOSS18"] = { death = 2932 }, -- Emperor Dagran Thaurissan
    ["BOSS19"] = { aggro = 367, death = 369 }, -- Overlord Wyrmthalak
    ["BOSS20"] = { aggro = 368, death = 369 }, -- General Drakkisath
    ["BOSS21"] = { aggro = 1010, death = 1009 }, -- Alzzin the Wildshaper
    ["BOSS22"] = { aggro = 341954, death = 2959 }, -- Prince Tortheldrin
    ["BOSS23"] = { aggro = 396, death = 400 }, -- King Gordok
    ["BOSS24"] = { aggro = 1263, death = 2944 }, -- Darkmaster Gandling
    ["BOSS25"] = { aggro = 3611, death = 3609 }, -- Baron Rivendare
    ["BOSS26"] = { aggro = 1095, death = 1094 }, -- Balnazzar
    -- WoW Forever bosses (new models: sounds borrowed from a creature of the same kind)
    ["BOSS27"] = { death = 2932 }, -- Durgen Dirgehammer (dark iron dwarf)
    ["BOSS28"] = { aggro = 1357, death = 2936 }, -- Rath'mael (undead caster)
    ["BOSS29"] = { aggro = 472, death = 468 }, -- Relic Guardian (golem)
    ["BOSS30"] = { aggro = 3424, death = 3422 }, -- Shade of the Archmage (phantasm)
    ["BRD01"] = { death = 2932 }, -- Anvilrage Guardsman
    ["BRD02"] = { aggro = 1288, death = 1286 }, -- Fireguard
    ["BRD03"] = { aggro = 1263, death = 2944 }, -- Twilight's Hammer Torturer
    ["BRD04"] = { death = 2932 }, -- Anvilrage Medic
    ["BRD05"] = { death = 2932 }, -- Doomforge Dragoon
    ["BRD06"] = { aggro = 739, death = 738 }, -- Lord Roccor
    ["BRD07"] = { aggro = 283054, death = 2940 }, -- High Interrogator Gerstahn
    ["BRD08"] = { aggro = 579, death = 578 }, -- Verek
    ["BRD09"] = { aggro = 472, death = 468 }, -- Molten War Golem
    ["BRD10"] = { death = 2932 }, -- Houndmaster Grebmar
    ["BRD11"] = { death = 2932 }, -- Fineous Darkvire
    ["BRD12"] = { death = 1356 }, -- Pyromancer Loregrain
    ["BRD13"] = { death = 2932 }, -- Warder Stilgiss
    ["BRD14"] = { aggro = 472, death = 468 }, -- Phalanx
    ["BRD15"] = { death = 2932 }, -- Doom'rel
    ["BRD16"] = { death = 2932 }, -- Golem Lord Argelmach
    ["BRD17"] = { aggro = 3438, death = 3436 }, -- Ambassador Flamelash
    ["BRD18"] = { aggro = 3685, death = 3683 }, -- Bael'Gar
    ["BRD19"] = { aggro = 1288, death = 1286 }, -- Lord Incendius
    ["BRD20"] = { aggro = 472, death = 468 }, -- Panzor the Invincible
    ["BRD21"] = { death = 2932 }, -- General Angerforge
    ["BRD22"] = { aggro = 3685, death = 3683 }, -- Magmus
    ["BRD23"] = { death = 2928 }, -- Princess Moira Bronzebeard
    ["BRN01"] = { aggro = 1044, death = 1043 }, -- Kolkar Wrangler
    ["BRN02"] = { aggro = 708, death = 707 }, -- Sunscale Screecher
    ["BRN03"] = { aggro = 643, death = 647 }, -- Savannah Prowler
    ["BRN04"] = { aggro = 2511, death = 2509 }, -- Hecklefang Hyena
    ["BRN05"] = { aggro = 1263, death = 2944 }, -- Theramore Marine
    ["BRN06"] = { aggro = 1236, death = 1972 }, -- Stormsnout
    ["BRN07"] = { death = 2932 }, -- Bael'dun Excavator
    ["BRN08"] = { aggro = 719, death = 718 }, -- Silithid Swarmer
    ["BRN09"] = { aggro = 1236, death = 1972 }, -- Stormhide
    ["BRN10"] = { aggro = 590, death = 589 }, -- Azzere the Skyblade
    ["BRN11"] = { death = 1322 }, -- Mankrik
    ["BRN12"] = { aggro = 2656, death = 2654 }, -- Barrens Giraffe
    ["BRS01"] = { death = 1322 }, -- Scarshield Legionnaire
    ["BRS02"] = { aggro = 396, death = 400 }, -- Spirestone Enforcer
    ["BRS03"] = { aggro = 344001, death = 3310 }, -- Smolderthorn Headhunter
    ["BRS04"] = { aggro = 344001, death = 3310 }, -- Smolderthorn Shadow Priest
    ["BRS05"] = { death = 1322 }, -- Firebrand Pyromancer
    ["BRS06"] = { aggro = 422, death = 426 }, -- Spire Spider
    ["BRS07"] = { death = 1322 }, -- Blackhand Iron Guard
    ["BRS08"] = { aggro = 367, death = 369 }, -- Rage Talon Dragonspawn
    ["BRS09"] = { death = 1322 }, -- Quartermaster Zigris
    ["BRS10"] = { aggro = 390, death = 394 }, -- Halycon
    ["BRS11"] = { aggro = 344002, death = 3304 }, -- Shadow Hunter Vosh'gajin
    ["BRS12"] = { aggro = 343252, death = 3310 }, -- War Master Voone
    ["BRS13"] = { aggro = 422, death = 426 }, -- Mother Smolderweb
    ["BRS14"] = { death = 1322 }, -- Jed Runewatcher
    ["BRS15"] = { aggro = 396, death = 400 }, -- Spirestone Butcher
    ["BRS16"] = { aggro = 396, death = 400 }, -- Highlord Omokk
    ["BRS17"] = { death = 1322 }, -- Goraluk Anvilcrack
    ["BRS18"] = { aggro = 1288, death = 1286 }, -- Pyroguard Emberseer
    ["BRS19"] = { aggro = 6819, death = 6817 }, -- The Beast
    ["BRS20"] = { death = 1322 }, -- Warchief Rend Blackhand
    ["BUR01"] = { aggro = 396, death = 400 }, -- Dustbelcher Mauler
    ["BUR02"] = { aggro = 396, death = 400 }, -- Firegut Ogre
    ["BUR03"] = { aggro = 770, death = 769 }, -- Flamekin Sprite
    ["BUR04"] = { aggro = 428, death = 432 }, -- Black Broodling
    ["BUR05"] = { aggro = 390, death = 394 }, -- Ember Worg
    ["BUR06"] = { aggro = 770, death = 769 }, -- Flamekin Spitter
    ["BUR07"] = { aggro = 719, death = 718 }, -- Venomtip Scorpid
    ["BUR08"] = { aggro = 396, death = 400 }, -- Firegut Brute
    ["BUR09"] = { aggro = 472, death = 468 }, -- War Reaver
    ["BUR10"] = { aggro = 3685, death = 3683 }, -- Volchan
    ["BUR11"] = { aggro = 1263, death = 2944 }, -- Marshal Maxwell
    ["DAR01"] = { aggro = 1230, death = 1228 }, -- Pygmy Tide Crawler
    ["DAR02"] = { aggro = 1230, death = 1228 }, -- Young Reef Crawler
    ["DAR03"] = { aggro = 1481, death = 1479 }, -- Foreststrider Fledgling
    ["DAR04"] = { aggro = 1236, death = 1234 }, -- Darkshore Thresher
    ["DAR05"] = { aggro = 478, death = 475 }, -- Rabid Thistle Bear
    ["DAR06"] = { aggro = 642, death = 641 }, -- Coastal Frenzy
    ["DAR07"] = { aggro = 1481, death = 1479 }, -- Giant Foreststrider
    ["DAR08"] = { aggro = 3438, death = 3436 }, -- Stormscale Myrmidon
    ["DAR09"] = { aggro = 1230, death = 1228 }, -- Raging Reef Crawler
    ["DAR10"] = { death = 1318 }, -- Apothecary Falthis
    ["DAR11"] = { death = 2959 }, -- Thundris Windweaver
    ["DES01"] = { death = 1322 }, -- Burning Blade Augur
    ["DES02"] = { aggro = 719, death = 718 }, -- Scorpashi Snapper
    ["DES03"] = { death = 1322 }, -- Burning Blade Reaver
    ["DES04"] = { aggro = 570, death = 569 }, -- Gritjaw Basilisk
    ["DES05"] = { aggro = 447, death = 444 }, -- Dread Swoop
    ["DES06"] = { aggro = 1236, death = 1972 }, -- Raging Thunder Lizard
    ["DES07"] = { aggro = 447, death = 444 }, -- Dread Flyer
    ["DES08"] = { aggro = 2517, death = 2515 }, -- Undead Ravager
    ["DES09"] = { aggro = 1236, death = 1972 }, -- Elder Thunder Lizard
    ["DES10"] = { aggro = 1102, death = 1101 }, -- Kaskk
    ["DES11"] = { aggro = 3565, death = 3563 }, -- Uthek the Wise
    ["DMA01"] = { aggro = 1010, death = 1009 }, -- Wildspawn Rogue
    ["DMA02"] = { aggro = 1498, death = 3375 }, -- Warpwood Tangler
    ["DMA03"] = { aggro = 396, death = 400 }, -- Gordok Brute
    ["DMA04"] = { aggro = 341954, death = 2959 }, -- Eldreth Sorcerer
    ["DMA05"] = { aggro = 770, death = 769 }, -- Pusillin
    ["DMA06"] = { aggro = 298, death = 300 }, -- Warpwood Crusher
    ["DMA07"] = { aggro = 402, death = 406 }, -- Gordok Mage-Lord
    ["DMA08"] = { aggro = 1010, death = 1009 }, -- Zevrim Thornhoof
    ["DMA09"] = { aggro = 341950, death = 341949 }, -- Lethtendris
    ["DMA10"] = { aggro = 1408, death = 1406 }, -- Hydrospawn
    ["DMA11"] = { aggro = 341952, death = 2936 }, -- Illyanna Ravenoak
    ["DMA12"] = { aggro = 341954, death = 2959 }, -- Magister Kalendris
    ["DMA13"] = { aggro = 402, death = 406 }, -- Cho'Rush the Observer
    ["DMA14"] = { aggro = 396, death = 400 }, -- Guard Mol'dar
    ["DMA15"] = { aggro = 396, death = 400 }, -- Stomper Kreeg
    ["DMA16"] = { aggro = 1525, death = 1523 }, -- Tendris Warpwood
    ["DMA17"] = { aggro = 396, death = 400 }, -- Captain Kromcrush
    ["DMA18"] = { aggro = 6819, death = 6817 }, -- Immol'thar
    ["DMA19"] = { aggro = 1095, death = 1094 }, -- Lord Hel'nurath
    ["DMS01"] = { aggro = 1263, death = 2944 }, -- Defias Pirate
    ["DMS02"] = { aggro = 1110, death = 324 }, -- Defias Watchman
    ["DMS03"] = { aggro = 283608, death = 18493 }, -- Goblin Engineer
    ["DMS04"] = { aggro = 1263, death = 2944 }, -- Defias Blackguard
    ["DMS05"] = { aggro = 1263, death = 2944 }, -- Defias Evoker
    ["DMS06"] = { aggro = 283608, death = 18493 }, -- Gilnid
    ["DMS07"] = { aggro = 5774, death = 400 }, -- Rhahk'Zor
    ["DMS08"] = { aggro = 1982, death = 1980 }, -- Sneed's Shredder
    ["DMS09"] = { aggro = 416, death = 420 }, -- Cookie
    ["DMS10"] = { aggro = 283608, death = 18493 }, -- Captain Greenskin
    ["DMS11"] = { aggro = 5777, death = 1356 }, -- Mr. Smite
    ["DMS12"] = { aggro = 1415, death = 1413 }, -- Sneed
    ["DSK01"] = { aggro = 1016, death = 337 }, -- Skeletal Warrior
    ["DSK02"] = { aggro = 390, death = 394 }, -- Young Black Ravager
    ["DSK03"] = { aggro = 2517, death = 2515 }, -- Skeletal Horror
    ["DSK04"] = { aggro = 422, death = 426 }, -- Black Widow Hatchling
    ["DSK05"] = { aggro = 1263, death = 2944 }, -- Defias Night Runner
    ["DSK06"] = { aggro = 422, death = 426 }, -- Carrion Recluse
    ["DSK07"] = { aggro = 437, death = 441 }, -- Nightbane Worgen
    ["DSK08"] = { aggro = 409, death = 413 }, -- Plague Spreader
    ["DSK09"] = { aggro = 437, death = 441 }, -- Nightbane Dark Runner
    ["DSK10"] = { aggro = 437, death = 441 }, -- Nefaru
    ["DSK11"] = { aggro = 1263, death = 2944 }, -- Lord Ello Ebonlocke
    ["DUN01"] = { aggro = 390, death = 394 }, -- Ragged Young Wolf
    ["DUN02"] = { aggro = 659, death = 658 }, -- Burly Rockjaw Trogg
    ["DUN03"] = { aggro = 390, death = 394 }, -- Ragged Timber Wolf
    ["DUN04"] = { aggro = 344001, death = 3310 }, -- Frostmane Troll Whelp
    ["DUN05"] = { aggro = 379, death = 383 }, -- Crag Boar
    ["DUN06"] = { aggro = 1243, death = 1242 }, -- Wendigo
    ["DUN07"] = { aggro = 647, death = 646 }, -- Snow Leopard
    ["DUN08"] = { aggro = 390, death = 394 }, -- Winter Wolf
    ["DUN09"] = { aggro = 478, death = 475 }, -- Ice Claw Bear
    ["DUN10"] = { aggro = 659, death = 658 }, -- Hammerspine
    ["DUN11"] = { death = 2932 }, -- Senir Whitebeard
    ["DUR01"] = { aggro = 770, death = 769 }, -- Vile Familiar
    ["DUR02"] = { aggro = 719, death = 718 }, -- Clattering Scorpid
    ["DUR03"] = { aggro = 379, death = 383 }, -- Dire Mottled Boar
    ["DUR04"] = { aggro = 719, death = 718 }, -- Armored Scorpid
    ["DUR05"] = { aggro = 708, death = 707 }, -- Bloodtalon Taillasher
    ["DUR06"] = { aggro = 379, death = 383 }, -- Elder Mottled Boar
    ["DUR07"] = { aggro = 719, death = 718 }, -- Venomtail Scorpid
    ["DUR08"] = { aggro = 708, death = 707 }, -- Bloodtalon Scythemaw
    ["DUR09"] = { aggro = 570, death = 569 }, -- Dreadmaw Crocolisk
    ["DUR10"] = { aggro = 719, death = 718 }, -- Death Flayer
    ["DUR11"] = { death = 3310 }, -- Vol'jin
    ["DUS01"] = { aggro = 590, death = 589 }, -- Noxious Flayer
    ["DUS02"] = { aggro = 462, death = 458 }, -- Withervine Creeper
    ["DUS03"] = { aggro = 416, death = 420 }, -- Mirefin Murloc
    ["DUS04"] = { aggro = 570, death = 569 }, -- Drywallow Snapper
    ["DUS05"] = { aggro = 570, death = 569 }, -- Mottled Drywallow Crocolisk
    ["DUS06"] = { aggro = 422, death = 426 }, -- Darkfang Creeper
    ["DUS07"] = { aggro = 1236, death = 1234 }, -- Young Murk Thresher
    ["DUS08"] = { aggro = 1452, death = 1450 }, -- Muckshell Pincer
    ["DUS09"] = { aggro = 1452, death = 1450 }, -- Muckshell Scrabbler
    ["DUS10"] = { aggro = 1452, death = 1450 }, -- Lord Angler
    ["DUS11"] = { death = 2940 }, -- Lady Jaina Proudmoore
    ["ELW01"] = { aggro = 694, death = 314 }, -- Kobold Vermin
    ["ELW02"] = { aggro = 694, death = 314 }, -- Kobold Worker
    ["ELW03"] = { aggro = 1263, death = 2944 }, -- Defias Thug
    ["ELW04"] = { aggro = 379, death = 383 }, -- Stonetusk Boar
    ["ELW05"] = { aggro = 694, death = 314 }, -- Kobold Tunneler
    ["ELW06"] = { aggro = 379, death = 383 }, -- Porcine Entourage
    ["ELW07"] = { aggro = 283054, death = 2940 }, -- Defias Rogue Wizard
    ["ELW08"] = { aggro = 416, death = 420 }, -- Murloc Forager
    ["ELW09"] = { aggro = 416, death = 420 }, -- Murloc Lurker
    ["ELW10"] = { aggro = 1015, death = 413 }, -- Gruff Swiftbite
    ["ELW11"] = { aggro = 1263, death = 2944 }, -- Marshal Dughan
    ["EPL01"] = { aggro = 579, death = 578 }, -- Plaguehound Runt
    ["EPL02"] = { aggro = 5043, death = 5041 }, -- Carrion Grub
    ["EPL03"] = { aggro = 409, death = 413 }, -- Cannibal Ghoul
    ["EPL04"] = { aggro = 3369, death = 3367 }, -- Noxious Plaguebat
    ["EPL05"] = { aggro = 3369, death = 3367 }, -- Putrid Gargoyle
    ["EPL06"] = { aggro = 5043, death = 5041 }, -- Carrion Devourer
    ["EPL07"] = { aggro = 3369, death = 3367 }, -- Monstrous Plaguebat
    ["EPL08"] = { aggro = 579, death = 578 }, -- Frenzied Plaguehound
    ["EPL09"] = { aggro = 1446, death = 1444 }, -- Stitched Horror
    ["EPL10"] = { aggro = 3346, death = 3344 }, -- Nerubian Overseer
    ["EPL11"] = { aggro = 1263, death = 2944 }, -- Duke Nicholas Zverenhoff
    ["FEL01"] = { aggro = 390, death = 394 }, -- Felpaw Wolf
    ["FEL02"] = { aggro = 478, death = 475 }, -- Angerclaw Bear
    ["FEL03"] = { aggro = 356, death = 357 }, -- Deadwood Warrior
    ["FEL04"] = { aggro = 390, death = 394 }, -- Felpaw Scavenger
    ["FEL05"] = { aggro = 1010, death = 1009 }, -- Jadefire Satyr
    ["FEL06"] = { aggro = 478, death = 475 }, -- Angerclaw Mauler
    ["FEL07"] = { aggro = 1498, death = 3375 }, -- Irontree Stomper
    ["FEL08"] = { aggro = 462, death = 458 }, -- Warpwood Moss Flayer
    ["FEL09"] = { death = 1322 }, -- Jaedenar Darkweaver
    ["FEL10"] = { aggro = 1243, death = 1242 }, -- Mezzir the Howler
    ["FEL11"] = { death = 2936 }, -- Arathandris Silversky
    ["FER01"] = { aggro = 1015, death = 308 }, -- Woodpaw Mystic
    ["FER02"] = { aggro = 1015, death = 308 }, -- Woodpaw Reaver
    ["FER03"] = { aggro = 1391, death = 1389 }, -- Groddoc Ape
    ["FER04"] = { aggro = 4025, death = 4023 }, -- Hatecrest Sorceress
    ["FER05"] = { aggro = 390, death = 394 }, -- Longtooth Howler
    ["FER06"] = { aggro = 478, death = 475 }, -- Grizzled Ironfur Bear
    ["FER07"] = { aggro = 713, death = 712 }, -- Frayfeather Patriarch
    ["FER08"] = { aggro = 1408, death = 1406 }, -- Sea Spray
    ["FER09"] = { aggro = 1408, death = 1406 }, -- Sea Elemental
    ["FER10"] = { aggro = 713, death = 712 }, -- Antilus the Soarer
    ["FER11"] = { death = 2936 }, -- Kindal Moonweaver
    ["GNO01"] = { aggro = 659, death = 658 }, -- Caverndeep Burrower
    ["GNO02"] = { death = 3272 }, -- Leprous Defender
    ["GNO03"] = { aggro = 4319, death = 4317 }, -- Mechano-Flamewalker
    ["GNO04"] = { aggro = 4319, death = 4317 }, -- Mechano-Frostwalker
    ["GNO05"] = { aggro = 1408, death = 1406 }, -- Viscous Fallout
    ["GNO06"] = { death = 2932 }, -- Dark Iron Ambassador
    ["GNO07"] = { aggro = 5811, death = 4317 }, -- Electrocutioner 6000
    ["GNO08"] = { aggro = 2092, death = 2518 }, -- Crowd Pummeler 9-60
    ["GNO09"] = { aggro = 659, death = 658 }, -- Grubbis
    ["HIL01"] = { aggro = 1015, death = 413 }, -- Rot Hide Brute
    ["HIL02"] = { aggro = 1015, death = 308 }, -- Rot Hide Plague Weaver
    ["HIL03"] = { aggro = 1015, death = 413 }, -- Raging Rot Hide
    ["HIL04"] = { aggro = 462, death = 458 }, -- Elder Lake Creeper
    ["HIL05"] = { aggro = 1263, death = 2944 }, -- Syndicate Watchman
    ["HIL06"] = { aggro = 478, death = 475 }, -- Vicious Gray Bear
    ["HIL07"] = { aggro = 647, death = 646 }, -- Starving Mountain Lion
    ["HIL08"] = { aggro = 1263, death = 2944 }, -- Hillsbrad Miner
    ["HIL09"] = { aggro = 344001, death = 3310 }, -- Witherbark Headhunter
    ["HIL10"] = { aggro = 344001, death = 3310 }, -- Zalas Witherbark
    ["HIL11"] = { aggro = 1263, death = 2944 }, -- Magistrate Henry Maleb
    ["HIN01"] = { aggro = 390, death = 394 }, -- Mangy Silvermane
    ["HIN02"] = { aggro = 1378, death = 1376 }, -- Trained Razorbeak
    ["HIN03"] = { aggro = 344001, death = 3310 }, -- Witherbark Hideskinner
    ["HIN04"] = { aggro = 5361, death = 5359 }, -- Primitive Owlbeast
    ["HIN05"] = { aggro = 341951, death = 341946 }, -- Highvale Scout
    ["HIN06"] = { aggro = 1464, death = 1462 }, -- Saltwater Snapjaw
    ["HIN07"] = { aggro = 344001, death = 3310 }, -- Revantusk Watcher
    ["HIN08"] = { aggro = 344001, death = 3310 }, -- Vilebranch Shadow Hunter
    ["HIN09"] = { aggro = 344001, death = 3310 }, -- Vilebranch Blood Drinker
    ["HIN10"] = { aggro = 344001, death = 3310 }, -- Mith'rethis the Enchanter
    ["HIN11"] = { death = 2932 }, -- Falstad Wildhammer
    ["LOC01"] = { aggro = 694, death = 314 }, -- Tunnel Rat Vermin
    ["LOC02"] = { aggro = 422, death = 426 }, -- Forest Lurker
    ["LOC03"] = { aggro = 642, death = 641 }, -- Loch Frenzy
    ["LOC04"] = { aggro = 478, death = 475 }, -- Grizzled Black Bear
    ["LOC05"] = { aggro = 379, death = 383 }, -- Mangy Mountain Boar
    ["LOC06"] = { aggro = 447, death = 444 }, -- Mountain Buzzard
    ["LOC07"] = { aggro = 379, death = 383 }, -- Elder Mountain Boar
    ["LOC08"] = { aggro = 478, death = 475 }, -- Black Bear Patriarch
    ["LOC09"] = { aggro = 1236, death = 1234 }, -- Young Threshadon
    ["LOC10"] = { aggro = 570, death = 569 }, -- Large Loch Crocolisk
    ["LOC11"] = { death = 2932 }, -- Mountaineer Stormpike
    ["MAR01"] = { aggro = 1010, death = 1009 }, -- Putridus Shadowstalker
    ["MAR02"] = { aggro = 5050, death = 5048 }, -- Barbed Lasher
    ["MAR03"] = { aggro = 1498, death = 3375 }, -- Deeprot Stomper
    ["MAR04"] = { aggro = 1134, death = 1133 }, -- Celebrian Dryad
    ["MAR05"] = { aggro = 739, death = 738 }, -- Theradrim Guardian
    ["MAR06"] = { aggro = 5050, death = 5048 }, -- Razorlash
    ["MAR07"] = { aggro = 1408, death = 1406 }, -- Noxxion
    ["MAR08"] = { aggro = 1010, death = 1009 }, -- Lord Vyletongue
    ["MAR09"] = { aggro = 283608, death = 18493 }, -- Tinkerer Gizlock
    ["MAR10"] = { aggro = 1127, death = 1126 }, -- Celebras the Cursed
    ["MAR11"] = { aggro = 570, death = 569 }, -- Rotgrip
    ["MAR12"] = { aggro = 3685, death = 3683 }, -- Landslide
    ["MAR13"] = { aggro = 462, death = 458 }, -- Meshlok the Harvester
    ["MUL01"] = { aggro = 1481, death = 1479 }, -- Plainstrider
    ["MUL02"] = { aggro = 647, death = 646 }, -- Mountain Cougar
    ["MUL03"] = { aggro = 379, death = 383 }, -- Battleboar
    ["MUL04"] = { aggro = 1181, death = 1179 }, -- Bristleback Quilboar
    ["MUL05"] = { aggro = 1015, death = 308 }, -- Palemane Tanner
    ["MUL06"] = { aggro = 390, death = 394 }, -- Prairie Wolf
    ["MUL07"] = { aggro = 447, death = 444 }, -- Wiry Swoop
    ["MUL08"] = { aggro = 283608, death = 18493 }, -- Venture Co. Worker
    ["MUL09"] = { aggro = 283608, death = 18493 }, -- Venture Co. Supervisor
    ["MUL10"] = { aggro = 1015, death = 308 }, -- Snagglespear
    ["MUL11"] = { death = 1356 }, -- Baine Bloodhoof
    ["RED01"] = { aggro = 390, death = 394 }, -- Gray Forest Wolf
    ["RED02"] = { aggro = 422, death = 426 }, -- Tarantula
    ["RED03"] = { aggro = 1015, death = 308 }, -- Redridge Poacher
    ["RED04"] = { aggro = 1015, death = 308 }, -- Redridge Mystic
    ["RED05"] = { aggro = 416, death = 420 }, -- Murloc Flesheater
    ["RED06"] = { aggro = 1015, death = 413 }, -- Redridge Basher
    ["RED07"] = { aggro = 416, death = 420 }, -- Murloc Scout
    ["RED08"] = { death = 1322 }, -- Blackrock Champion
    ["RED09"] = { aggro = 416, death = 420 }, -- Squiddic
    ["RED10"] = { death = 1322 }, -- Kazon
    ["RED11"] = { aggro = 1263, death = 2944 }, -- Magistrate Solomon
    ["RFC01"] = { aggro = 659, death = 658 }, -- Ragefire Trogg
    ["RFC02"] = { aggro = 5043, death = 5041 }, -- Earthborer
    ["RFC03"] = { death = 1322 }, -- Searing Blade Warlock
    ["RFC04"] = { aggro = 739, death = 738 }, -- Molten Elemental
    ["RFC05"] = { aggro = 659, death = 658 }, -- Oggleflint
    ["RFC06"] = { death = 1322 }, -- Jergosh the Invoker
    ["RFC07"] = { aggro = 1102, death = 1101 }, -- Taragaman the Hungerer
    ["RFC08"] = { death = 213 }, -- Searing Blade Enforcer
    ["RFD01"] = { aggro = 1181, death = 1179 }, -- Withered Warrior
    ["RFD02"] = { aggro = 2517, death = 2515 }, -- Skeletal Frostweaver
    ["RFD03"] = { aggro = 409, death = 413 }, -- Boneflayer Ghoul
    ["RFD04"] = { aggro = 1181, death = 1179 }, -- Death's Head Necromancer
    ["RFD05"] = { aggro = 5822, death = 2515 }, -- Mordresh Fire Eye
    ["RFD06"] = { aggro = 1446, death = 1444 }, -- Glutton
    ["RFD07"] = { aggro = 1181, death = 1179 }, -- Ragglesnout
    ["RFD08"] = { aggro = 3346, death = 3344 }, -- Tuten'kash
    ["RFK01"] = { aggro = 1181, death = 1179 }, -- Razorfen Warrior
    ["RFK02"] = { aggro = 1181, death = 1179 }, -- Razorfen Quilguard
    ["RFK03"] = { aggro = 1181, death = 1179 }, -- Razorfen Geomancer
    ["RFK04"] = { aggro = 3369, death = 3367 }, -- Kraul Bat
    ["RFK05"] = { aggro = 1181, death = 1179 }, -- Death's Head Priest
    ["RFK06"] = { aggro = 3369, death = 3367 }, -- Blind Hunter
    ["RFK07"] = { aggro = 1181, death = 1179 }, -- Roogug
    ["RFK08"] = { aggro = 1181, death = 1179 }, -- Aggem Thorncurse
    ["RFK09"] = { aggro = 1181, death = 1179 }, -- Death Speaker Jargba
    ["RFK10"] = { aggro = 1181, death = 1179 }, -- Earthcaller Halmgar
    ["RFK11"] = { aggro = 5812, death = 1179 }, -- Overlord Ramtusk
    ["RFK12"] = { aggro = 379, death = 383 }, -- Agathelos the Raging
    ["RFK13"] = { aggro = 1181, death = 1179 }, -- Razorfen Totemic
    ["SCH01"] = { aggro = 1357, death = 2936 }, -- Scholomance Acolyte
    ["SCH02"] = { aggro = 1016, death = 337 }, -- Risen Guard
    ["SCH03"] = { aggro = 1357, death = 2936 }, -- Scholomance Necromancer
    ["SCH04"] = { aggro = 409, death = 413 }, -- Diseased Ghoul
    ["SCH05"] = { aggro = 3346, death = 3344 }, -- Necrofiend
    ["SCH06"] = { aggro = 2517, death = 2515 }, -- Risen Construct
    ["SCH07"] = { death = 1318 }, -- Marduk Blackpool
    ["SCH08"] = { aggro = 2517, death = 2515 }, -- Vectus
    ["SCH09"] = { aggro = 283054, death = 2940 }, -- Jandice Barov
    ["SCH10"] = { aggro = 341950, death = 341949 }, -- Instructor Malicia
    ["SCH11"] = { aggro = 1473, death = 1471 }, -- Lorekeeper Polkelt
    ["SCH12"] = { aggro = 1263, death = 2944 }, -- Doctor Theolen Krastinov
    ["SCH13"] = { aggro = 1263, death = 2944 }, -- Lord Alexei Barov
    ["SCH14"] = { aggro = 283054, death = 2940 }, -- Lady Illucia Barov
    ["SCH15"] = { aggro = 2517, death = 2515 }, -- Rattlegore
    ["SCH16"] = { aggro = 7139, death = 7137 }, -- The Ravenian
    ["SCH17"] = { aggro = 5800, death = 5796 }, -- Ras Frostwhisper
    ["SCH18"] = { aggro = 3369, death = 3367 }, -- Kirtonos the Herald
    ["SEA01"] = { death = 2932 }, -- Dark Iron Slaver
    ["SEA02"] = { death = 2932 }, -- Enslaved Archaeologist
    ["SEA03"] = { aggro = 422, death = 426 }, -- Searing Lava Spider
    ["SEA04"] = { aggro = 1288, death = 1286 }, -- Blazing Elemental
    ["SEA05"] = { death = 2932 }, -- Dark Iron Taskmaster
    ["SEA06"] = { aggro = 739, death = 738 }, -- Magma Elemental
    ["SEA07"] = { aggro = 422, death = 426 }, -- Greater Lava Spider
    ["SEA08"] = { aggro = 472, death = 468 }, -- Heavy War Golem
    ["SEA09"] = { aggro = 570, death = 569 }, -- Incendosaur
    ["SEA10"] = { aggro = 739, death = 738 }, -- Smoldar
    ["SEA11"] = { aggro = 1263, death = 2944 }, -- Kalaran Windblade
    ["SFK01"] = { aggro = 437, death = 441 }, -- Shadowfang Whitescalp
    ["SFK02"] = { aggro = 390, death = 394 }, -- Slavering Worg
    ["SFK03"] = { aggro = 1263, death = 2944 }, -- Haunted Servitor
    ["SFK04"] = { aggro = 3369, death = 3367 }, -- Vile Bat
    ["SFK05"] = { aggro = 6699, death = 6697 }, -- Lupine Horror
    ["SFK06"] = { aggro = 437, death = 441 }, -- Rethilgore
    ["SFK07"] = { aggro = 437, death = 441 }, -- Razorclaw the Butcher
    ["SFK08"] = { aggro = 437, death = 441 }, -- Odo the Blindwatcher
    ["SFK09"] = { aggro = 1263, death = 2944 }, -- Baron Silverlaine
    ["SFK10"] = { aggro = 1263, death = 2944 }, -- Commander Springvale
    ["SFK11"] = { aggro = 437, death = 441 }, -- Wolf Master Nandos
    ["SFK12"] = { aggro = 6017, death = 394 }, -- Fenrus the Devourer
    ["SFK13"] = { aggro = 1263, death = 2944 }, -- Deathsworn Captain
    ["SIL01"] = { aggro = 437, death = 441 }, -- Moonrage Whitescalp
    ["SIL02"] = { aggro = 390, death = 394 }, -- Mottled Worg
    ["SIL03"] = { aggro = 478, death = 475 }, -- Ferocious Grizzled Bear
    ["SIL04"] = { aggro = 437, death = 441 }, -- Moonrage Glutton
    ["SIL05"] = { aggro = 416, death = 420 }, -- Vile Fin Shredder
    ["SIL06"] = { aggro = 478, death = 475 }, -- Giant Grizzled Bear
    ["SIL07"] = { aggro = 422, death = 426 }, -- Mist Creeper
    ["SIL08"] = { aggro = 390, death = 394 }, -- Bloodsnout Worg
    ["SIL09"] = { aggro = 1016, death = 337 }, -- Ravenclaw Guardian
    ["SIL10"] = { aggro = 1016, death = 337 }, -- Ravenclaw Regent
    ["SIL11"] = { death = 1318 }, -- High Executor Hadrec
    ["SLI01"] = { aggro = 341954, death = 2959 }, -- Tortured Druid
    ["SLI02"] = { aggro = 5043, death = 5041 }, -- Dredge Striker
    ["SLI03"] = { aggro = 719, death = 718 }, -- Stonelash Pincer
    ["SLI04"] = { aggro = 422, death = 426 }, -- Sand Skitterer
    ["SLI05"] = { aggro = 3789, death = 3787 }, -- Dust Stormer
    ["SLI06"] = { aggro = 719, death = 718 }, -- Stonelash Flayer
    ["SLI07"] = { aggro = 739, death = 738 }, -- Desert Rumbler
    ["SLI08"] = { aggro = 1263, death = 2944 }, -- Twilight Avenger
    ["SLI09"] = { death = 2928 }, -- Twilight Geolord
    ["SLI10"] = { aggro = 341952, death = 2936 }, -- Mistress Natalia Mar'alith
    ["SLI11"] = { aggro = 1263, death = 2944 }, -- Highlord Demitrian
    ["SMO01"] = { aggro = 1263, death = 2944 }, -- Scarlet Torturer
    ["SMO02"] = { aggro = 2511, death = 2509 }, -- Scarlet Tracking Hound
    ["SMO03"] = { aggro = 1263, death = 2944 }, -- Scarlet Monk
    ["SMO04"] = { aggro = 283054, death = 2940 }, -- Scarlet Adept
    ["SMO05"] = { aggro = 3424, death = 3422 }, -- Haunting Phantasm
    ["SMO06"] = { aggro = 283054, death = 2940 }, -- Scarlet Myrmidon
    ["SMO07"] = { aggro = 283054, death = 2940 }, -- Scarlet Champion
    ["SMO08"] = { aggro = 5847, death = 2944 }, -- Interrogator Vishas
    ["SMO09"] = { aggro = 5841, death = 2944 }, -- Houndmaster Loksey
    ["SMO10"] = { death = 1318 }, -- Fallen Champion
    ["SMO11"] = { aggro = 1016, death = 337 }, -- Ironspine
    ["SMO12"] = { death = 1318 }, -- High Inquisitor Fairbanks
    ["SMO13"] = { aggro = 5835, death = 2944 }, -- Scarlet Commander Mograine
    ["SMO14"] = { aggro = 1263, death = 2944 }, -- Azshir the Sleepless
    ["STK01"] = { aggro = 1263, death = 2944 }, -- Defias Prisoner
    ["STK02"] = { aggro = 1263, death = 2944 }, -- Defias Insurgent
    ["STK03"] = { aggro = 1346, death = 1344 }, -- Targorr the Dread
    ["STK04"] = { aggro = 1263, death = 2944 }, -- Dextren Ward
    ["STK05"] = { death = 2932 }, -- Kam Deepfury
    ["STK06"] = { aggro = 402, death = 406 }, -- Hamhock
    ["STK07"] = { death = 2932 }, -- Bruegal Ironknuckle
    ["STK08"] = { aggro = 1263, death = 2944 }, -- Defias Convict
    ["STO01"] = { aggro = 694, death = 314 }, -- Gogger Geomancer
    ["STO02"] = { aggro = 694, death = 314 }, -- Gogger Rock Keeper
    ["STO03"] = { aggro = 694, death = 314 }, -- Gogger Stonepounder
    ["STO04"] = { aggro = 694, death = 314 }, -- Windshear Digger
    ["STO05"] = { aggro = 761, death = 760 }, -- Pridewing Wyvern
    ["STO06"] = { aggro = 761, death = 760 }, -- Pridewing Consort
    ["STO07"] = { aggro = 1288, death = 1286 }, -- Rogue Flame Spirit
    ["STO08"] = { aggro = 570, death = 569 }, -- Blackened Basilisk
    ["STO09"] = { aggro = 584, death = 583 }, -- Bloodfury Windcaller
    ["STO10"] = { aggro = 761, death = 760 }, -- Sorrow Wing
    ["STO11"] = { aggro = 1127, death = 1126 }, -- Keeper Albagorm
    ["STR01"] = { aggro = 1263, death = 2944 }, -- Crimson Initiate
    ["STR02"] = { aggro = 409, death = 413 }, -- Plague Ghoul
    ["STR03"] = { aggro = 1263, death = 2944 }, -- Crimson Gallant
    ["STR04"] = { aggro = 3369, death = 3367 }, -- Rockwing Gargoyle
    ["STR05"] = { aggro = 1173, death = 1171 }, -- Shrieking Banshee
    ["STR06"] = { aggro = 3346, death = 3344 }, -- Crypt Crawler
    ["STR07"] = { aggro = 1446, death = 1444 }, -- Patchwork Horror
    ["STR08"] = { aggro = 1446, death = 1444 }, -- Venom Belcher
    ["STR09"] = { aggro = 7139, death = 7137 }, -- Magistrate Barthilas
    ["STR10"] = { aggro = 1263, death = 2944 }, -- Hearthsinger Forresten
    ["STR11"] = { aggro = 3417, death = 3416 }, -- The Unforgiven
    ["STR12"] = { aggro = 2517, death = 2515 }, -- Skul
    ["STR13"] = { aggro = 1263, death = 2944 }, -- Cannon Master Willey
    ["STR14"] = { aggro = 1263, death = 2944 }, -- Archivist Galford
    ["STR15"] = { aggro = 1263, death = 2944 }, -- Malor the Zealous
    ["STR16"] = { aggro = 1173, death = 1171 }, -- Baroness Anastari
    ["STR17"] = { aggro = 3346, death = 3344 }, -- Nerub'enkan
    ["STR18"] = { aggro = 3369, death = 3367 }, -- Stonespine
    ["STR19"] = { aggro = 1263, death = 2944 }, -- Maleki the Pallid
    ["STR20"] = { aggro = 1263, death = 2944 }, -- Grand Crusader Dathrohan
    ["STR21"] = { aggro = 1446, death = 1444 }, -- Ramstein the Gorger
    -- WoW Forever dungeons: same sound as an existing card with the same model, else one of the same kind
    ["HOT01"] = { aggro = 2511, death = 2509 }, -- Bloodhound Runt (hound)
    ["HOT02"] = { aggro = 1288, death = 1286 }, -- Fiery Assistant
    ["HOT03"] = { death = 2932 }, -- Dark Iron Looter
    ["HOT04"] = { aggro = 1173, death = 1171 }, -- Enraged Apparition (spirit)
    ["HOT05"] = { aggro = 1173, death = 1171 }, -- Tormented Soul (spirit)
    ["HOT06"] = { death = 2932 }, -- Dark Iron Engineer
    ["HOT07"] = { death = 2932 }, -- Dark Iron Summoner
    ["HOT08"] = { aggro = 472, death = 468 }, -- Lesser Stone Golem
    ["HOT09"] = { aggro = 1173, death = 1171 }, -- Faldrim Anvilmar (spirit)
    ["HOT10"] = { aggro = 739, death = 738 }, -- Plunder (elemental)
    ["HOT11"] = { aggro = 1288, death = 1286 }, -- Magmatus
    ["HOT12"] = { aggro = 1173, death = 1171 }, -- Ghostly Attendant (spirit)
    ["ROL01"] = { aggro = 422, death = 426 }, -- Broodling (spider)
    ["ROL02"] = { aggro = 409, death = 413 }, -- Ragged Ghoul
    ["ROL03"] = { aggro = 1016, death = 337 }, -- Skeletal Soldier
    ["ROL04"] = { aggro = 422, death = 426 }, -- Broodwidow
    ["ROL05"] = { aggro = 2517, death = 2515 }, -- Skeletal Mage
    ["ROL06"] = { aggro = 1173, death = 1171 }, -- Wailing Banshee
    ["ROL07"] = { aggro = 7139, death = 7137 }, -- Mangled Cadaver
    ["ROL08"] = { aggro = 2517, death = 2515 }, -- Fallen Berserker
    ["ROL09"] = { aggro = 2517, death = 2515 }, -- Fallen Necromancer
    ["ROL10"] = { aggro = 422, death = 426 }, -- Witherfang (spider)
    ["ROL11"] = { aggro = 1016, death = 337 }, -- Bjork
    ["ROL12"] = { aggro = 1446, death = 1444 }, -- Flesh Golem
    ["ROL13"] = { aggro = 1016, death = 337 }, -- The Baron
    ["ROL14"] = { aggro = 7139, death = 7137 }, -- Viktor the Vile
    ["ROL15"] = { aggro = 1357, death = 2936 }, -- The Abandoned
    ["ROL16"] = { aggro = 1263, death = 2944 }, -- Captain Truman
    ["EXC01"] = { aggro = 708, death = 707 }, -- Young Riptooth (raptor)
    ["EXC02"] = { aggro = 422, death = 426 }, -- Highland Spider
    ["EXC03"] = { death = 1322 }, -- Dragonmaw Saboteur
    ["EXC04"] = { aggro = 570, death = 569 }, -- Marsh Crocolisk
    ["EXC05"] = { aggro = 422, death = 426 }, -- Highland Lurker
    ["EXC06"] = { death = 1322 }, -- Dragonmaw Warder
    ["EXC07"] = { aggro = 708, death = 707 }, -- Thicket Stalker (raptor)
    ["EXC08"] = { aggro = 1464, death = 1462 }, -- Highland Snapper
    ["EXC09"] = { aggro = 708, death = 707 }, -- Thicket Hunter (raptor)
    ["EXC10"] = { aggro = 570, death = 569 }, -- Elder Crocolisk
    ["EXC11"] = { aggro = 739, death = 738 }, -- Highland Horror (elemental)
    ["EXC12"] = { death = 1322 }, -- Dragonmaw Thaumaturgist
    ["EXC13"] = { aggro = 1288, death = 1286 }, -- Captive Fire Elemental
    ["EXC14"] = { aggro = 708, death = 707 }, -- Thicket Matriarch (raptor)
    ["EXC15"] = { aggro = 570, death = 569 }, -- Saltspine
    ["EXC16"] = { aggro = 708, death = 707 }, -- Shadetooth (raptor)
    ["EXC17"] = { aggro = 1263, death = 2944 }, -- Deathstalker Agent
    ["DAL01"] = { aggro = 1408, death = 1406 }, -- Arcane Manaling (elemental)
    ["DAL02"] = { aggro = 1249, death = 1250 }, -- Mana Fiend (felbeast)
    ["DAL03"] = { aggro = 3424, death = 3422 }, -- Mana Phantom (phantasm)
    ["DAL04"] = { aggro = 1408, death = 1406 }, -- Seeking Remnant (elemental)
    ["DAL05"] = { aggro = 1408, death = 1406 }, -- Saturated Remnant (elemental)
    ["DAL06"] = { aggro = 3424, death = 3422 }, -- Phantasm
    ["DAL07"] = { aggro = 472, death = 468 }, -- Fragmented Sentry (golem)
    ["DAL08"] = { aggro = 1357, death = 2936 }, -- Kirin Tor Necromancer
    ["DAL09"] = { aggro = 3424, death = 3422 }, -- Arcane Echo (phantasm)
    ["DAL10"] = { aggro = 1408, death = 1406 }, -- Mana Stalker (elemental)
    ["DAL11"] = { aggro = 1408, death = 1406 }, -- Arcane Elemental
    ["DAL12"] = { aggro = 3424, death = 3422 }, -- Mana Echo (phantasm)
    ["DAL13"] = { aggro = 462, death = 458 }, -- Suffused Treant
    ["DAL14"] = { aggro = 3424, death = 3422 }, -- Mana Wraith (phantasm)
    ["DAL15"] = { aggro = 1408, death = 1406 }, -- Arcane Anomaly (elemental)
    ["DAL16"] = { aggro = 1408, death = 1406 }, -- Arcanic Enigma (elemental)
    ["DAL17"] = { aggro = 472, death = 468 }, -- Unstable Sentinel (golem)
    ["DAL18"] = { aggro = 1249, death = 1250 }, -- Mana Devourer (felbeast)
    ["DAL19"] = { aggro = 1263, death = 2944 }, -- Lyn the Ignored
    ["DAL20"] = { aggro = 462, death = 458 }, -- Fel Ancient (treant)
    ["DAL21"] = { aggro = 3611, death = 3609 }, -- Atrexis the Grave Knight (death knight)
    ["DAL22"] = { aggro = 1263, death = 2944 }, -- Archmage Modera
    ["STV01"] = { aggro = 647, death = 646 }, -- Young Panther
    ["STV02"] = { aggro = 1263, death = 2944 }, -- Kurzen Medicine Man
    ["STV03"] = { aggro = 647, death = 646 }, -- Stranglethorn Tiger
    ["STV04"] = { aggro = 283608, death = 18493 }, -- Venture Co. Geologist
    ["STV05"] = { aggro = 647, death = 646 }, -- Stranglethorn Tigress
    ["STV06"] = { aggro = 1391, death = 1389 }, -- Jungle Thunderer
    ["STV07"] = { aggro = 1391, death = 1389 }, -- Elder Mistvale Gorilla
    ["STV08"] = { aggro = 283608, death = 18493 }, -- Venture Co. Strip Miner
    ["STV09"] = { aggro = 1230, death = 1228 }, -- Southern Sand Crawler
    ["STV10"] = { aggro = 3438, death = 3436 }, -- Lord Sakrasis
    ["STV11"] = { death = 2932 }, -- Hemet Nesingwary
    ["SUN01"] = { aggro = 5893, death = 5891 }, -- Atal'ai Warrior
    ["SUN02"] = { aggro = 5043, death = 5041 }, -- Murk Worm
    ["SUN03"] = { aggro = 344001, death = 3310 }, -- Atal'ai Witch Doctor
    ["SUN04"] = { aggro = 590, death = 589 }, -- Hakkari Frostwing
    ["SUN05"] = { aggro = 367, death = 369 }, -- Nightmare Scalebane
    ["SUN06"] = { aggro = 344001, death = 3310 }, -- Gasher
    ["SUN07"] = { aggro = 344001, death = 3310 }, -- Hukku
    ["SUN08"] = { aggro = 590, death = 589 }, -- Spawn of Hakkar
    ["SUN09"] = { aggro = 344001, death = 3310 }, -- Ogom the Wretched
    ["SUN10"] = { aggro = 344001, death = 3310 }, -- Jammal'an the Prophet
    ["SUN11"] = { aggro = 4065, death = 4063 }, -- Morphaz
    ["SUN12"] = { aggro = 4065, death = 4063 }, -- Hazzas
    ["SUN13"] = { aggro = 7055, death = 7059 }, -- Avatar of Hakkar
    ["SWA01"] = { aggro = 570, death = 569 }, -- Young Sawtooth Crocolisk
    ["SWA02"] = { aggro = 422, death = 426 }, -- Sorrow Spinner
    ["SWA03"] = { aggro = 596, death = 595 }, -- Lost One Hunter
    ["SWA04"] = { aggro = 647, death = 646 }, -- Shadow Panther
    ["SWA05"] = { aggro = 462, death = 458 }, -- Tangled Horror
    ["SWA06"] = { aggro = 1230, death = 1228 }, -- Silt Crawler
    ["SWA07"] = { aggro = 570, death = 569 }, -- Sawtooth Snapper
    ["SWA08"] = { aggro = 344001, death = 3310 }, -- Witherbark Sadist
    ["SWA09"] = { aggro = 422, death = 426 }, -- Witherbark Broodguard
    ["SWA10"] = { aggro = 344001, death = 3310 }, -- Zekkis
    ["SWA11"] = { death = 1322 }, -- Fallen Hero of the Horde
    ["TAN01"] = { aggro = 719, death = 718 }, -- Scorpid Hunter
    ["TAN02"] = { aggro = 570, death = 569 }, -- Glasshide Basilisk
    ["TAN03"] = { aggro = 1464, death = 1462 }, -- Steeljaw Snapper
    ["TAN04"] = { aggro = 719, death = 718 }, -- Scorpid Tail Lasher
    ["TAN05"] = { aggro = 2511, death = 2509 }, -- Blisterpaw Hyena
    ["TAN06"] = { aggro = 570, death = 569 }, -- Glasshide Gazer
    ["TAN07"] = { aggro = 2511, death = 2509 }, -- Rabid Blisterpaw
    ["TAN08"] = { aggro = 396, death = 400 }, -- Dunemaul Brute
    ["TAN09"] = { aggro = 1464, death = 1462 }, -- Surf Glider
    ["TAN10"] = { aggro = 402, death = 406 }, -- Cyclok the Mad
    ["TAN11"] = { aggro = 1415, death = 1413 }, -- Marin Noggenfogger
    ["TEL01"] = { aggro = 647, death = 646 }, -- Young Nightsaber
    ["TEL02"] = { aggro = 379, death = 383 }, -- Young Thistle Boar
    ["TEL03"] = { aggro = 647, death = 646 }, -- Mangy Nightsaber
    ["TEL04"] = { aggro = 422, death = 426 }, -- Webwood Spider
    ["TEL05"] = { aggro = 422, death = 426 }, -- Webwood Lurker
    ["TEL06"] = { aggro = 3605, death = 3603 }, -- Strigid Owl
    ["TEL07"] = { aggro = 356, death = 357 }, -- Gnarlpine Shaman
    ["TEL08"] = { aggro = 356, death = 357 }, -- Gnarlpine Defender
    ["TEL09"] = { aggro = 3605, death = 3603 }, -- Strigid Screecher
    ["TEL10"] = { aggro = 462, death = 458 }, -- Blackmoss the Fetid
    ["TEL11"] = { death = 2959 }, -- Conservator Ilthalaine
    ["THO01"] = { aggro = 647, death = 646 }, -- Savannah Matriarch
    ["THO02"] = { aggro = 3565, death = 3563 }, -- Galak Windchaser
    ["THO03"] = { aggro = 1044, death = 1043 }, -- Galak Wrangler
    ["THO04"] = { aggro = 2511, death = 2509 }, -- Pesterhide Hyena
    ["THO05"] = { aggro = 647, death = 646 }, -- Needles Cougar
    ["THO06"] = { aggro = 2511, death = 2509 }, -- Pesterhide Snarler
    ["THO07"] = { aggro = 584, death = 583 }, -- Screeching Roguefeather
    ["THO08"] = { aggro = 1464, death = 1462 }, -- Sparkleshell Borer
    ["THO09"] = { aggro = 719, death = 718 }, -- Scorpid Terror
    ["THO10"] = { aggro = 719, death = 718 }, -- Vile Sting
    ["THO11"] = { aggro = 1415, death = 1413 }, -- Pozzik
    ["TIR01"] = { aggro = 1473, death = 1471 }, -- Mindless Zombie
    ["TIR02"] = { aggro = 1473, death = 1471 }, -- Wretched Zombie
    ["TIR03"] = { aggro = 422, death = 426 }, -- Young Night Web Spider
    ["TIR04"] = { aggro = 579, death = 578 }, -- Decrepit Darkhound
    ["TIR05"] = { aggro = 1473, death = 1471 }, -- Rotting Dead
    ["TIR06"] = { aggro = 3369, death = 3367 }, -- Greater Duskbat
    ["TIR07"] = { aggro = 416, death = 420 }, -- Vile Fin Minor Oracle
    ["TIR08"] = { aggro = 416, death = 420 }, -- Vile Fin Muckdweller
    ["TIR09"] = { aggro = 283054, death = 2940 }, -- Scarlet Vanguard
    ["TIR10"] = { aggro = 3417, death = 3416 }, -- Fellicent's Shade
    ["TIR11"] = { death = 1318 }, -- Executor Zygand
    ["ULD01"] = { aggro = 659, death = 658 }, -- Stonevault Rockchewer
    ["ULD02"] = { death = 2932 }, -- Shadowforge Relic Hunter
    ["ULD03"] = { aggro = 570, death = 569 }, -- Jadespine Basilisk
    ["ULD04"] = { aggro = 719, death = 718 }, -- Venomlash Scorpid
    ["ULD05"] = { death = 2932 }, -- Eric "The Swift"
    ["ULD06"] = { death = 2932 }, -- Baelog
    ["ULD07"] = { death = 2932 }, -- Olaf
    ["ULD08"] = { aggro = 659, death = 658 }, -- Revelosh
    ["ULD09"] = { aggro = 472, death = 468 }, -- Obsidian Sentinel
    ["ULD10"] = { aggro = 5852, death = 2932 }, -- Galgann Firehammer
    ["ULD11"] = { aggro = 5853, death = 658 }, -- Grimlok
    ["ULD12"] = { aggro = 472, death = 468 }, -- Ancient Stone Keeper
    ["ULD13"] = { aggro = 3032, death = 3035 }, -- Ironaya
    ["UNG01"] = { aggro = 1243, death = 1242 }, -- Ferocious Rage Scar
    ["UNG02"] = { aggro = 708, death = 707 }, -- Ravasaur
    ["UNG03"] = { aggro = 5050, death = 5048 }, -- Bloodpetal Lasher
    ["UNG04"] = { aggro = 1391, death = 1389 }, -- Un'Goro Gorilla
    ["UNG05"] = { aggro = 5050, death = 5048 }, -- Bloodpetal Flayer
    ["UNG06"] = { aggro = 570, death = 569 }, -- Diemetradon
    ["UNG07"] = { aggro = 1391, death = 1389 }, -- Un'Goro Thunderer
    ["UNG08"] = { aggro = 6431, death = 6430 }, -- Frenzied Pterrordax
    ["UNG09"] = { aggro = 1288, death = 1286 }, -- Living Blaze
    ["UNG10"] = { aggro = 1391, death = 1389 }, -- Uhk'loc
    ["UNG11"] = { death = 1356 }, -- Torwa Pathfinder
    ["WCV01"] = { aggro = 4499, death = 4497 }, -- Deviate Adder
    ["WCV02"] = { aggro = 708, death = 707 }, -- Deviate Ravager
    ["WCV03"] = { aggro = 708, death = 707 }, -- Deviate Guardian
    ["WCV04"] = { aggro = 341952, death = 2936 }, -- Druid of the Fang
    ["WCV05"] = { aggro = 1649, death = 1647 }, -- Deviate Faerie Dragon
    ["WCV06"] = { aggro = 1236, death = 1972 }, -- Skum
    ["WCV07"] = { aggro = 1464, death = 1462 }, -- Kresh
    ["WCV08"] = { aggro = 341952, death = 2936 }, -- Lady Anacondra
    ["WCV09"] = { aggro = 5785, death = 2959 }, -- Lord Cobrahn
    ["WCV10"] = { aggro = 5787, death = 2959 }, -- Lord Pythas
    ["WCV11"] = { aggro = 5788, death = 2959 }, -- Lord Serpentis
    ["WCV12"] = { aggro = 462, death = 458 }, -- Verdan the Everliving
    ["WCV13"] = { death = 2959 }, -- Boahn
    ["WES01"] = { aggro = 390, death = 394 }, -- Coyote
    ["WES02"] = { aggro = 1263, death = 2944 }, -- Defias Smuggler
    ["WES03"] = { aggro = 2092, death = 2518 }, -- Harvest Golem
    ["WES04"] = { aggro = 447, death = 444 }, -- Fleshripper
    ["WES05"] = { aggro = 379, death = 383 }, -- Goretusk
    ["WES06"] = { aggro = 2092, death = 2518 }, -- Harvest Watcher
    ["WES07"] = { aggro = 1294, death = 1292 }, -- Defias Digger
    ["WES08"] = { aggro = 1015, death = 308 }, -- Riverpaw Bandit
    ["WES09"] = { aggro = 1230, death = 1228 }, -- Shore Crawler
    ["WES10"] = { aggro = 447, death = 444 }, -- Vultros
    ["WES11"] = { aggro = 1263, death = 2944 }, -- Gryan Stoutmantle
    ["WET01"] = { aggro = 570, death = 569 }, -- Young Wetlands Crocolisk
    ["WET02"] = { aggro = 1015, death = 308 }, -- Mosshide Fenrunner
    ["WET03"] = { aggro = 708, death = 707 }, -- Mottled Raptor
    ["WET04"] = { aggro = 428, death = 432 }, -- Crimson Whelp
    ["WET05"] = { death = 1322 }, -- Dragonmaw Raider
    ["WET06"] = { aggro = 708, death = 707 }, -- Highland Razormaw
    ["WET07"] = { aggro = 1263, death = 2944 }, -- Syndicate Highwayman
    ["WET08"] = { aggro = 739, death = 738 }, -- Rumbling Exile
    ["WET09"] = { aggro = 1288, death = 1286 }, -- Burning Exile
    ["WET10"] = { aggro = 396, death = 400 }, -- Molok the Crusher
    ["WET11"] = { death = 2932 }, -- Captain Stoutfist
    ["WIN01"] = { aggro = 3605, death = 3603 }, -- Winterspring Owl
    ["WIN02"] = { aggro = 1243, death = 1242 }, -- Ice Thistle Yeti
    ["WIN03"] = { aggro = 478, death = 475 }, -- Shardtooth Mauler
    ["WIN04"] = { aggro = 455, death = 449 }, -- Chillwind Chimaera
    ["WIN05"] = { aggro = 5361, death = 5359 }, -- Moontouched Owlbeast
    ["WIN06"] = { aggro = 478, death = 475 }, -- Elder Shardtooth
    ["WIN07"] = { aggro = 455, death = 449 }, -- Chillwind Ravager
    ["WIN08"] = { aggro = 3605, death = 3603 }, -- Winterspring Screecher
    ["WIN09"] = { aggro = 647, death = 646 }, -- Frostsaber Huntress
    ["WIN10"] = { aggro = 1122, death = 1120 }, -- Lady Hederine
    ["WIN11"] = { death = 2928 }, -- Donova Snowden
    ["WPL01"] = { aggro = 422, death = 426 }, -- Venom Mist Lurker
    ["WPL02"] = { aggro = 2517, death = 2515 }, -- Skeletal Sorcerer
    ["WPL03"] = { aggro = 478, death = 475 }, -- Diseased Black Bear
    ["WPL04"] = { aggro = 422, death = 426 }, -- Carrion Lurker
    ["WPL05"] = { aggro = 390, death = 394 }, -- Diseased Wolf
    ["WPL06"] = { aggro = 1473, death = 1471 }, -- Rotting Cadaver
    ["WPL07"] = { aggro = 478, death = 475 }, -- Diseased Grizzly
    ["WPL08"] = { aggro = 1263, death = 2944 }, -- Scarlet Worker
    ["WPL09"] = { aggro = 3417, death = 3416 }, -- Haunting Vision
    ["WPL10"] = { aggro = 1263, death = 2944 }, -- Scarlet High Clerist
    ["WPL11"] = { aggro = 1263, death = 2944 }, -- Tirion Fordring
    ["ZFK01"] = { aggro = 344001, death = 3310 }, -- Sandfury Blood Drinker
    ["ZFK02"] = { aggro = 344001, death = 3310 }, -- Sandfury Shadowhunter
    ["ZFK03"] = { aggro = 5874, death = 3310 }, -- Sandfury Executioner
    ["ZFK04"] = { aggro = 570, death = 569 }, -- Sul'lithuz Sandcrawler
    ["ZFK05"] = { aggro = 344001, death = 3310 }, -- Theka the Martyr
    ["ZFK06"] = { aggro = 344002, death = 3304 }, -- Hydromancer Velratha
    ["ZFK07"] = { aggro = 5872, death = 3310 }, -- Witch Doctor Zum'rah
    ["ZFK08"] = { aggro = 344001, death = 3310 }, -- Ruuzlu
    ["ZFK09"] = { aggro = 344001, death = 3310 }, -- Dustwraith
    ["ZFK10"] = { aggro = 344001, death = 3310 }, -- Sandarr Dunereaver
    ["ZFK11"] = { aggro = 344001, death = 3310 }, -- Antu'sul
    ["ZFK12"] = { aggro = 455, death = 449 }, -- Gahz'rilla
    -- Tokens (Cards\Tokens.lua) borrow a similar mob's sounds; one without (the Dragon Egg)
    -- arrives with the paper sound prayers make (PlayTokenSound)
    ["TOK01"] = { aggro = 416, death = 420 }, -- Murloc Tadpole (as Murloc Forager)
    ["TOK02"] = { aggro = 694, death = 314 }, -- Kobold Digger (as Kobold Worker)
    ["TOK03"] = { aggro = 1016, death = 337 }, -- Skeleton (as Skeletal Warrior)
    ["TOK05"] = { aggro = 428, death = 432 }, -- Rookery Whelp (as Scalding Whelp)
}

-- =========================================================================
-- SPELL SOUND DATA
-- [cardId] = SoundKit ID played when the spell card is cast (E:PlaySpellCastSound).
-- A spell card may also carry its own castSound field, which takes priority. A spell in
-- neither (and Gear, which is hammered out) keeps the generic cast sound.
--
-- Generated from the client tables (build 1.60.1.70532): the card's name -> SpellName
-- (lowest spell id with a sound) -> SpellXSpellVisual -> SpellVisualEvent ->
-- SpellVisualKitEffect (type 5, a SoundKit). The cast event's sound is used, else the
-- impact's, else the aura's.
-- =========================================================================
TTS.SpellSounds = {
    ["DRU01"] = 2561, -- Wrath
    ["DRU02"] = 1641, -- Moonfire
    ["DRU03"] = 2561, -- Healing Touch
    ["DRU04"] = 2561, -- Rejuvenation
    ["DRU05"] = 2561, -- Regrowth
    ["DRU06"] = 2561, -- Mark of the Wild
    ["DRU07"] = 2561, -- Entangling Roots
    ["DRU08"] = 2561, -- Thorns
    ["DRU09"] = 2561, -- Innervate
    ["DRU10"] = 1641, -- Starfire
    ["HUN01"] = 3333, -- Arcane Shot
    ["HUN02"] = 1501, -- Serpent Sting
    ["HUN03"] = 3333, -- Aimed Shot
    ["HUN04"] = 3071, -- Multi-Shot
    ["HUN05"] = 3333, -- Concussive Shot
    ["HUN06"] = 29, -- Freezing Trap
    ["HUN07"] = 38, -- Immolation Trap
    ["HUN08"] = 1432, -- Mend Pet
    ["HUN09"] = 2561, -- Hunter's Mark
    ["HUN10"] = 1641, -- Bestial Wrath
    ["MAG01"] = 1484, -- Fireball
    ["MAG02"] = 1484, -- Fire Blast
    ["MAG03"] = 1484, -- Flamestrike
    ["MAG04"] = 1484, -- Pyroblast
    ["MAG05"] = 2559, -- Frostbolt
    ["MAG06"] = 3076, -- Frost Nova
    ["MAG07"] = 2559, -- Blizzard
    ["MAG08"] = 1641, -- Polymorph
    ["MAG09"] = 1641, -- Arcane Missiles
    ["MAG10"] = 1641, -- Arcane Intellect
    ["PAL01"] = 2562, -- Holy Light
    ["PAL02"] = 2562, -- Flash of Light
    ["PAL03"] = 2562, -- Blessing of Might
    ["PAL04"] = 2562, -- Blessing of Protection
    ["PAL05"] = 2562, -- Divine Shield
    ["PAL06"] = 2562, -- Hammer of Justice
    ["PAL07"] = 2562, -- Exorcism
    ["PAL08"] = 2562, -- Consecration
    ["PAL09"] = 2562, -- Lay on Hands
    ["PAL10"] = 1455, -- Redemption
    ["PRI01"] = 2562, -- Power Word: Shield
    ["PRI02"] = 2562, -- Renew
    ["PRI03"] = 2562, -- Flash Heal
    ["PRI04"] = 2562, -- Prayer of Healing
    ["PRI05"] = 2562, -- Smite
    ["PRI06"] = 1484, -- Holy Fire
    ["PRI07"] = 2560, -- Shadow Word: Pain
    ["PRI08"] = 2560, -- Mind Blast
    ["PRI09"] = 2560, -- Mind Control
    ["PRI10"] = 3113, -- Psychic Scream
    ["ROG01"] = 3091, -- Sinister Strike
    ["ROG02"] = 3091, -- Backstab
    ["ROG03"] = 3091, -- Eviscerate
    ["ROG04"] = 3091, -- Gouge
    ["ROG05"] = 3091, -- Cheap Shot
    ["ROG06"] = 3339, -- Sprint
    ["ROG07"] = 3324, -- Vanish
    ["ROG08"] = 2560, -- Evasion
    ["ROG09"] = 349040, -- Slice and Dice
    ["ROG10"] = 3134, -- Garrote
    ["SHA01"] = 348052, -- Lightning Bolt
    ["SHA02"] = 2561, -- Earth Shock
    ["SHA03"] = 1484, -- Flame Shock
    ["SHA04"] = 2559, -- Frost Shock
    ["SHA05"] = 305443, -- Chain Lightning
    ["SHA06"] = 2561, -- Healing Wave
    ["SHA07"] = 2561, -- Rockbiter Weapon
    ["SHA08"] = 2552, -- Stoneskin Totem
    ["SHA09"] = 2561, -- Purge
    ["SHA10"] = 2561, -- Ancestral Spirit
    ["WLK01"] = 2560, -- Shadow Bolt
    ["WLK02"] = 2560, -- Corruption
    ["WLK03"] = 2560, -- Curse of Agony
    ["WLK04"] = 2560, -- Drain Life
    ["WLK05"] = 3113, -- Howl of Terror
    ["WLK06"] = 2560, -- Death Coil
    ["WLK07"] = 1484, -- Immolate
    ["WLK08"] = 1484, -- Soul Fire
    ["WLK09"] = 2560, -- Life Tap
    ["WLK10"] = 2560, -- Enslave Demon (as Subjugate Demon)
    ["WAR01"] = 3091, -- Heroic Strike
    ["WAR02"] = 3330, -- Charge
    ["WAR03"] = 3091, -- Rend
    ["WAR04"] = 4120, -- Bloodrage
    ["WAR05"] = 3090, -- Thunder Clap
    ["WAR06"] = 3091, -- Overpower
    ["WAR07"] = 3091, -- Execute
    ["WAR08"] = 3660, -- Shield Wall
    ["WAR09"] = 3091, -- Mortal Strike
    ["WAR10"] = 5674, -- Whirlwind
}

-- =========================================================================
-- UI FEEDBACK SOUNDS
-- kit = SOUNDKIT key (modern clients), id = numeric fallback, legacy = pre-SOUNDKIT name
-- =========================================================================
local UI_SOUNDS = {
    button = { kit = "IG_MAINMENU_OPTION",             id = 852,  legacy = "igMainMenuOption" },
    card   = { kit = "IG_MAINMENU_OPTION_CHECKBOX_ON", id = 856,  legacy = "igMainMenuOptionCheckBoxOn" },
    tap    = { kit = "U_CHAT_SCROLL_BUTTON",           id = 1115, legacy = "uChatScrollButton" },
    -- A card going into or coming out of a deck in the Deckbuilder: paper, like turning a page
    deckCard = { kit = "IG_SPELLBOOK_OPEN", id = 829, legacy = "igSpellBookOpen" },
    -- A card drawn, as it leaves the deck (Board.lua's draw animations): a short click, like tapping
    draw     = { kit = "U_CHAT_SCROLL_BUTTON", id = 1115, legacy = "uChatScrollButton" },
    -- A page turned in the Quick Start walkthrough
    page     = { kit = "IG_ABILITY_PAGE_TURN", id = 836, legacy = "igAbiliityPageTurn" },
    -- A match's result as its popup shows: the level-up fanfare for a win, quest failed for a loss
    victory  = { kit = "LEVELUP",         id = 888, legacy = "LevelUp" },
    defeat   = { kit = "IG_QUEST_FAILED", id = 847, legacy = "igQuestFailed" },
}

local function PlayRaw(sound)
    if type(sound) == "number" then
        pcall(PlaySound, sound, "SFX")
    elseif type(sound) == "string" then
        pcall(PlaySoundFile, sound, "SFX")
    end
end

function S:PlayUI(name)
    if not self.enabled then return end
    local def = UI_SOUNDS[name]
    if not def then return end
    if SOUNDKIT then
        PlayRaw(SOUNDKIT[def.kit] or def.id)
    else
        pcall(PlaySound, def.legacy)
    end
end

-- =========================================================================
-- CREATURE SOUNDS (aggro / death)
-- Events queued in the same moment are batched: only one sound per kind plays,
-- taken from the highest-cost creature in the batch that has sound data.
-- =========================================================================
-- kind "enter" (arriving on the battlefield) is the card's enterSound if it has one, and
-- otherwise its aggro sound, like attacking
function S:GetCreatureSound(cardId, kind)
    local card = TTS.Cards and TTS.Cards[cardId]
    if not card or card.type ~= "Creature" then return nil end
    local own = card[kind .. "Sound"]
    if own then return own end
    if kind == "enter" then return self:GetCreatureSound(cardId, "aggro") end
    local data = TTS.CreatureSounds[cardId]
    return data and data[kind]
end

local BATCH_WINDOW = 0.05
local pending = { aggro = {}, death = {}, enter = {} }
local flushScheduled = false

local function Flush()
    flushScheduled = false
    for _, kind in ipairs({ "enter", "aggro", "death" }) do
        local bestSound, bestCmc = nil, -1
        for _, cardId in ipairs(pending[kind]) do
            local snd = S:GetCreatureSound(cardId, kind)
            if snd then
                local cmc = TTS.Cards[cardId].cmc or 0
                if cmc > bestCmc then
                    bestSound, bestCmc = snd, cmc
                end
            end
        end
        pending[kind] = {}
        if bestSound then PlayRaw(bestSound) end
    end
end

-- A token's card appearing (UI\Board.lua token spawns): its mob sound, or without one a
-- paper sound (spellbook open; a prayer being played has the close one, E:PlayNonCreatureCardSound)
local PAPER_SOUND = 829
function S:PlayTokenSound(cardId)
    if not self.enabled then return end
    PlayRaw(self:GetCreatureSound(cardId, "enter") or PAPER_SOUND)
end

-- kind = "enter" (creature arrives; tokens use PlayTokenSound instead), "aggro" (attacking)
-- or "death"
function S:QueueCreature(kind, cardId)
    if not self.enabled or not pending[kind] or not cardId then return end
    table.insert(pending[kind], cardId)
    if not flushScheduled then
        flushScheduled = true
        TTS:SafeAfter(BATCH_WINDOW, Flush)
    end
end

-- =========================================================================
-- BUTTON CLICK HOOKS
-- Every button in the addon's windows clicks when pressed. Buttons flagged
-- ttsSilent (the board's cards) play their own card / tap sounds instead.
-- PostClick is used so later SetScript("OnClick") calls don't remove the sound.
-- =========================================================================
local function PlayButtonClick()
    S:PlayUI("button")
end

function S:HookButtons(frame)
    if not frame or not frame.GetChildren then return end
    if frame.IsObjectType and frame:IsObjectType("Button") and frame.HookScript
        and not frame.ttsSilent and not frame.ttsClickHooked then
        frame.ttsClickHooked = true
        frame:HookScript("PostClick", PlayButtonClick)
    end
    for _, child in ipairs({ frame:GetChildren() }) do
        self:HookButtons(child)
    end
end

local hookFrame = CreateFrame("Frame")
hookFrame:RegisterEvent("PLAYER_LOGIN")
hookFrame:SetScript("OnEvent", function(self)
    self:UnregisterAllEvents()
    S:HookButtons(TTS.MainFrame)
    S:HookButtons(TTS.WaitingRoom and TTS.WaitingRoom.frame)
    S:HookButtons(TTS.DeckBuilderFrame)
    S:HookButtons(TTS.RulesFrame)
    S:HookButtons(TTS.BoardFrame)
    S:HookButtons(TTS.BoardRestoreFrame)
    S:HookButtons(_G["TTS_MinimapButton"])
end)