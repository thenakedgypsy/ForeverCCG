## 1.0.0

*   denizens can now have a targeted Arrival: choose its target as you cast it, like a spell (if there's nothing to target, it's cast as usual)
*   new: your Hero card - you, but as a card. Its keyword and stats come from your class; every 10 levels choose to upgrade it or take another copy (the Hero button in the deckbuilder). Choices are shared by your alts
*   your opponent's Hero card shows their real character when you can see them (target, mouseover or group). Out of sight, it's a class trainer of their race and gender, wearing their gear
*   new keyword `Shielded`: the next damage the denizen would take is negated, then it loses Shielded. Power Word: Shield, Blessing of Protection, Divine Shield and Evasion now grant it
*   new to Forever: CCG? A Quick Start walkthrough greets you the first time you open the addon, and a short guided tutorial game teaches you the basics turn by turn (Play Tutorial in Rules & Guide, or /tragic tutorial)
*   Rules & Guide rebuilt: a tab per topic (Quick Start, Building a Deck, Collecting Cards, Prayers & Mana, Your Turn, Combat, Keywords, Card Terms, Solo Mode, Playing Others), each opening with an "In short" summary, then bite-sized sections, example cards for every keyword and card term, worked combat examples and buttons straight into the tutorial, Solo Encounters and the Waiting Room
*   new keyword `Support`: the denizen can block an attacker alongside other blockers. Each blocker deals its full combat damage to the attacker; the attacker splits its damage between them, picking the order (each takes enough to kill it before the next takes any)
*   `Support` added to Kurzen Medicine Man, Crimson Initiate, Defias Watchman, Crimson Gallant, Hillsbrad Miner, Scarlet Vanguard, Porcine Entourage, Palemane Tanner and Razorfen Geomancer
*   solo opponents gang-block with Support denizens when that kills the attacker without losing any of them, and pick their damage order to kill your most valuable blockers when they attack
*   Brutish damage against several blockers carries over once each of them has taken enough to kill it
*   new: hearthstones - dual-colour prayers. Clicking one asks which mana to make; auto-pay and the AI pick the colour that's needed
*   some innkeepers around Azeroth may have spare cards for travellers who ask nicely. They can't spare them often, but they'll give you an idea of when to come back. Rumour has it the innkeepers of the great cities keep something special behind the bar too.
*   new: Gear Cards - one for every zone. A Gear Card equips a denizen you control: its stat bonus and keywords last as long as the denizen stays on the battlefield. Up to 8 per deck, on top of the 12 spells, with their own filter and section in the deckbuilder. Weapon merchants out in the world might spare one for travellers who ask, and when they're out, they'll tell you who else to try (innkeepers now name names too). Collect every Gear Card your own faction's merchants give, and they'll start slipping you the other faction's. The deckbuilder tracks your Gear Cards, collected and mastered
*   cards that return a denizen card from a graveyard (Redemption, Ancestral Spirit, Kum'isha the Collector, Azshir the Sleepless) now let you choose which one
*   Mutanus and Prince Tortheldrin's discards are no longer random: the player discarding picks the card (solo-mode opponents drop their least useful one)
*   the Opening Boss dungeon rule (Shadowfang Keep, Razorfen Kraul, Blackrock Depths) is now Free Boss: the boss no longer starts on the battlefield, but costs the opponent nothing, so it's cast as soon as it's drawn
*   solo-mode dungeons can be entered once an hour, win or lose (zones have no wait). Entering one now asks you to confirm first, and a dungeon waiting out its hour is dimmed on the map with the time left in its tooltip
*   winning a solo-mode dungeon now announces it with an emote (and a cheer) when you accept the result
*   once you've declared attackers, End Turn becomes Commit to Attacks & End Turn: the attack goes in and your turn ends as soon as combat is over (the blocks show for a second, then resolve, with no review)
*   while your attack waits for blocks, End Turn becomes End Turn After Combat: click it and combat resolves as soon as the blocks are in, then your turn ends (click again before the blocks arrive to cancel)
*   started combat by accident (e.g. a stray drag at the opponent)? Until you commit to attacks, Undo calls it off: you're back in Main Phase 1 with your attackers ready again
*   Concede and Clear Deck now ask you to confirm first
*   the game log beside the board can be minimised to its title bar with its - button (it stays that way until you open it again)
*   each side of the board now holds up to 16 denizens, shrinking them to fit
*   fix for card models flickering on the board (most noticeable on Hero cards): a model now only reloads when its card is played, drawn or moves
*   tokens now make a sound when they arrive: tadpoles, diggers and skeletons sound like their kin, others rustle like a prayer
*   fix for PvP life totals drifting apart when a player had a damage shield (Power Word: Shield): the attacker's client ignored it, so it could see a win while the other player was still alive
*   fix for "No player named ... is currently playing" spam from the addon checking whether your contacts are online (it still showed in a second chat tab, or when the check went out late)
*   new Lock checkbox at the top of the board: tick it and the board can't be dragged around by accident (remembered between sessions)
*   new graveyard buttons on the board, one for each player: click to list the cards in that graveyard (most recent first) and hover one to see it in the preview
*   options: each kind of tooltip detail panel (keywords, abilities, effects, statuses, symbols, attached cards) can now be switched off
*   decks now shuffle on screen at the start of a game, and yours again when you mulligan (off with "Animate played cards")
*   the opponent's hand no longer lights up as a target while you choose one: target the opponent with their name plate
*   fix for long opponent names spilling out of their name plate
*   fix for PvP games drifting apart when denizens on both sides died at once (e.g. a Martyrdom during combat): each player's client put them into the graveyards in a different order, so High Inquisitor Whitemane could return a different denizen for each player
*   fix for a denizen's model sometimes showing at the wrong zoom after it was played or drawn (mostly in a slot of the board used for the first time that session)
*   fix for being unable to end your turn when Herod arrived after combat (e.g. cast in Main Phase 2): he only has to attack while combat is still to come
*   deckbuilder: new Keyword filter (e.g. show only Support or Airborne cards)
*   collection score: Hearthstones collected and mastered now show at the bottom of the deckbuilder and count towards your score alongside denizens
*   added new art for hearthstones
*   collection scores are coloured by how close they are to the best possible score: grey, white, green, blue, purple, orange, and red once complete (deckbuilder, main window, waiting room, board and minimap tooltips). The deckbuilder's collected/mastered counters use the same colours
*   new: Foil cards - a shiny version of a denizen card, one per card. Once you own a copy, every kill of that denizen has its own small chance to drop its foil (higher for named denizens and dungeon creatures, highest for final bosses), and every copy of that card then plays foil, for your opponent too. Leeroy Jenkins and The Bug Reporter always come in foil. The deckbuilder shows foil names in colour and counts your foils towards your score
*   named denizens (e.g. Gruff Swiftbite) are now rarer drops: 50% for the first copy, then 12%, 6% and 3%
*   every dungeon denizen, bosses included, now drops its card at the named-denizen rates. Final bosses no longer always give a copy, and no longer track your kills through achievements
*   new: Dark Hearthstones - ten more dual-colour prayers, one for every colour pair, that make both colours at once. They arrive Exhausted and return one of your basic prayers to your hand. Sixteen more innkeepers across Azeroth have them to spare, from Sentinel Hill to Feathermoon Stronghold, and the goblin innkeepers of Ratchet, Booty Bay, Gadgetzan and Everlook will serve either faction
*   new: health bars on the life plates - green when full, through yellow to red, with the life just lost draining away. Your life plate now sits in the middle at the bottom of the board, facing your opponent's, with your mana on the left
*   the Mulligan button now sits above To Combat and flashes while you can take a mulligan
*   options: new Tooltip scale slider for card tooltips and the detail panels beside them
*   card tooltips show the cost and the card type on separate lines
*   Azshir the Sleepless: Martyrdom became Arrival, and toughness 5 -> 6
*   fix for an opponent's Hero card sometimes showing your own character instead of theirs
*   fix for card costs sometimes missing from the deckbuilder's tiles when it first opens
*   PvP: attack and block declarations are now sent in one go, so large attacks arrive faster and more reliably
*   balance changes too long to list here.
*   `Drain` now restores life only from combat damage dealt to the opponent (Brutish damage carried over blockers included), not from damage dealt to denizens
*   class spells rebalanced: combat tricks now last instead of wearing off at end of turn (Heroic Strike, Blessing of Might, Rockbiter Weapon, Charge, Overpower, Thorns, Bestial Wrath, Sprint, Evasion, Vanish, Slice and Dice, Stoneskin Totem); heals and utility spells also draw a card (Flash of Light, Holy Light, Flash Heal, Renew, Rejuvenation, Regrowth, Healing Touch, Healing Wave, Prayer of Healing, Mend Pet, Shield Wall, Purge, Concussive Shot, Gouge); damage over time spells now hit up front too (Rend, Garrote, Shadow Word: Pain, Curse of Agony, Corruption, Serpent Sting, Immolation Trap, Flame Shock, Moonfire, Arcane Shot, Fire Blast); plus changes to Execute, Earth Shock, Sinister Strike, Hunter's Mark, Mark of the Wild, Power Word: Shield, Blessing of Protection, Redemption and Ancestral Spirit
*   solo opponents now cast Bloodrage, Innervate, Life Tap, Enslave Demon, Mind Control, Purge and Vanish
*   the regeneration shield from Blessing of Protection and Vanish is now called Soulstone (it works the same way)
*   new names: many keywords adjusted to be less... tragic
*   cards for the new zones added: Riverglades (Twilight's Hammer cultists led by Overlord Kilgar, plus the zone's boars, bats, buzzards, tallstriders and crocolisks) and Zephras Isle (the Al'Aketh, the High Order under Elaadrin Evengale, and the isle's Cirrusflies, Ursera, Galestriders and wind elementals). Kill them out in the world to collect them
*   new solo-mode zone: Riverglades, between Redridge Mountains, Burning Steppes, the Badlands and Swamp of Sorrows. Clear it to earn Demar Brant, Knight Commander of the Brotherhood of the Horse
*   new: card effects - denizens on the battlefield come to life. They swing when they fight, flinch when wounded, fall when they die, and light up when healed, buffed or dispelled; spells hit with an impact in their colour, and Shielded, Soulstone, Frozen, damage and healing over time, and borrowed denizens show a visual for as long as they last. While an effect plays, the denizen steps out in front of its card, which opens up into full art. On by default (Options > Board > Card effects)
*   a denizen's card now shows the keywords it has gained (in green, above its text) and lost (greyed out), on the card itself, the preview card and its tooltip
*   class spells now play their own sound when cast
*   Gear Cards' text is shorter: "Equip: +1/+0 and Support."
*   a cast spell or Gear Card now shows in the middle of the board, moving aside so it doesn't cover any cards
*   your graveyard button now sits to the left of your life plate
*   damage numbers now fly from whatever dealt the damage (the attacking denizen, or the cast spell's card) to the player or denizen it hits, in the card's colour. Damage from several cards at once flies in separately and merges into one big red number that pops up with a flash. Damage to players is shown much larger, and only the filled part of the life bar flashes red
*   in combat, the blocks land first, then any damage that gets through flies on to the player

## 0.15.7

*   added option to disable card preview in creature tooltip

## 0.15.6

*   joining the Forever CCG community is no longer required to join the waiting room; it's still recommended, as it's how the addon finds players on other server shards

## 0.15.5

*   the waiting room now also announces you to your party (or raid) and guild, so players there see you even if the addon's channel doesn't reach them

## 0.15.4

*   fix for players who moved server shard (e.g. by joining a party) being stuck in an old copy of the addon's channel and not seeing anyone: the addon now rejoins it when your party changes and when you open the waiting room

## 0.15.3

*   joining the Forever CCG community is now required to join the waiting room: the Join button stays greyed out until you're a member
*   the Community button shows "Link in chat!" after posting the join link, and greys out as "Joined" once you're a member
*   fix for whispers, challenges, contact pings and party invites not reaching players: they now always use the full first name and surname
*   joining the waiting room can now post in the community every 45 seconds (was 10 minutes)

## 0.15.2

*   the Community button in the waiting room now puts a clickable join link in your chat window: click it to join the Forever CCG community in-game 
*   the waiting room now explains that the community runs in the background (the addon posts for you), so there's no need to chat in it

## 0.15.1

*   waiting room can now find players on other server shards through the Forever CCG community: joining the waiting room posts once in the community (at most every 10 minutes), and members of your faction on the same realm type (PvE, PvP, RP) see you in their waiting room. Use the Community button in the waiting room to get the invite link (this should not spam your in-game chat and can be muted if it does)
*   fix for players on 0.14 and 0.15 not seeing each other in the waiting room at all (they now see each other and are told to update when they challenge)
*   fix for queued players disappearing from others' waiting rooms when they close the waiting room window (e.g. to edit a deck)

## 0.15.0

*   new keyword Bulwark X, Aku'mai now blocks two
*   tokens: murlocs leave tadpoles when they die, kobolds bring diggers when played
*   heal/damage over time on creatures now changes toughness
*   card text fixes
*   dungeon loading screens as solo backgrounds
*   fix for card models not zooming correctly when played
*   balance: Arugal 3/5, VanCleef 4/3, Thalnos 2/2, Gilnid 5/2, Goraluk 6/2, Ghamoo-ra 2/8, Polkelt 1/5 Strikes-First, Viscous Fallout 2/4, Roccor 6/5, Smolderweb 6/7, Panzor 3/11

## 0.14.4

*   add mulligan button

## 0.14.3

*   fix for default filters not showing in deckbuilder

## 0.14.2

*   deck select popup on start a match
*   remove 'active deck'
*   allow editing decks when in queue

## 0.14.1

*   dungeon creature cards can now be collected by looting the corpse, so kills that give no experience still count
*   fix for dungeon creatures whose names appear with an extra word (e.g. Tormented Soul in the Hall of Thanes) not being recognised
*   looting a corpse that already counted from experience no longer rolls for its card again
*   rules guide update to explain how dungeon kills are counted, and that each spell unlock gives 4 copies

## 0.14.0

*   cards for the new dungeons added: Hall of Thanes, Ruins of Lordaeron and Excavation Site (final boss achieves still not in the game so the Final Boss cards for these cant be earned for now)

## 0.13.8

*   localisation support, with additional languages available as a separate download

## 0.13.7

*   fix for error-11, messages now wait and resend when the game blocks addon messages

## 0.13.6

*   cards now link themselves in their unlock notification

## 0.13.5

*   network census in background occasionally

## 0.13.4

*   network census
*   added recent players list
*   fix for dot and damage displays in PvP

## 0.13.3

*   fix for retry error-08

## 0.13.2

*   fix for some network retries

## 0.13.1

*   fix for spells from boss cards

## 0.13.0

*   breaking networking changes
*   fixed an issue where PvP would no longer work after starting the solo campaign

## 0.12.8

*   fix for spells and other effects in PvP

## 0.12.7

*   extra network solution
*   hidden contacts

## 0.12.6

*   added auto-pay (toggle on board)
*   added animations for click to play mode
*   added drag to play mode (toggleable with click to play in options)
*   fixed some highlighting that wasnt triggering correctly
*   added more error logs to the mouse

## 0.12.5

*   updated keyword names to be less…. tragic

## 0.12.4

*   added card linking

## 0.12.3

*   added collection score that was missed in earlier build

## 0.12.2

*   added undo

## 0.12.1

*   spells are now revealed on screen with arrows to their targets, red for damage, green for healing
*   opponents in pvp now see your spell targets too
*   floating damage and heal numbers on creatures and players
*   errors from your own actions show in red at the cursor
*   removed creatures stay in their slot for a second before leaving
*   attack arrows stay up a little longer
*   blocking rework
*   newly acquired cards glow and show NEW at the top of the deckbuilder
*   new power and toughness emblem on cards
*   dual-colour card frames for cards with two colours in their cost
*   colour pips in the deck list

## 0.12.0

*   added solo mode
*   dungeon boss rules
*   57 new cards
*   smarter ai opponents
*   zone and dungeon backgrounds on the board in solo (toggle in options)
*   deck selector on the solo map

## 0.11.4

*   fix to prevent small updates from breaking matchmaking between versions, explained in more detail in rules.
*   added card preview to mob tacker tooltips

## 0.11.3

*   added new card frames
*   added options menu
*   added expanding popups
*   fixed window sizes not saving
*   fixed some text readability

## 0.11.2

*   UI update part 1

## 0.11.1

*   fallbacks for networking

## 0.11.0

*   beta release

## 0.10.6

*   party chat fallback

## 0.10.5

*   alex is strug

## 0.10.4

*   network fix

## 0.10.3

*   networking fix for laggy /w channels

## 0.10.2

*   maximum hand size fix
*   rules update
*   skip resolve step if no blockers

## 0.10.1

*   target dummy fix

## 0.10.0

*   added visual blockers
*   updated sounds
*   added timings to target dummy
*   updated network to handle new additions

## 0.9.3

*   fIxed icons
*   updated rules text