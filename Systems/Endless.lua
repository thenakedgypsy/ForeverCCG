--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
local L = TTS.L

-- =========================================================================
-- ENDLESS
-- A run is one drafted 20-card deck fighting one opponent after another. The draft happens
-- once (12 picks of 1 from 5, then 8 basic Prayers); every win adds a card and leads to the
-- next, harder fight; the first loss (a deck-out or a concede too) ends the run. Every 8th
-- fight is a dungeon milestone, which pays a Dungeons pack when a charge is banked.
-- Drafted cards are run-only copies: ownership is ignored and nothing enters the collection.
-- One run at a time per account; always available.
--
-- Everything random goes through seeds made from the run's seed, so a /reload re-shows the
-- same offer and replays the same fight (its seed drives both shuffles, the mulligan and the
-- rules: CoreEngine.lua SEEDED RANDOM).
--
-- TTS_Endless = {
--   charges, chargeDay   pack charge bank (0-7, +1 each local midnight) and the local date it
--                        was last topped up
--   best                 most fights won in a run
--   runs                 runs started
--   lastRun              { wins, packs, best } of the run that just ended (the "run over" screen)
--   run = nil | {
--     seed, stage        "draft" | "prayers" | "ready" | "fight" | "reward"
--     picks, offer       draft picks so far, the X.OFFER_SIZE card ids on offer
--     deck               card ids (run-only)
--     fight              the next fight (wins + 1)
--     curses, twists     lasting mutator ids, in the order added
--     recent             the last 5 opponents' encounter ids
--     plan               the next fight, worked out once (PlanFight)
--     reward             the X.OFFER_SIZE card ids on offer after a win
--     packs              packs earned this run
--   } }
-- The window is UI\Endless.lua; a fight's end comes through CoreEngine.lua's EndMatch.
-- =========================================================================
local X = {}
TTS.Endless = X

X.DRAFT_PICKS = 12
X.OFFER_SIZE = 5                    -- cards on offer at each draft pick and after each win
X.PRAYERS = 8
X.MAX_CHARGES = 7
X.MILESTONE_EVERY = 8
X.RECENT = 5
X.MAX_TWISTS = 4
X.PACK = "dungeon"
X.RARE_PICKS = { [4] = true, [8] = true, [12] = true }
X.COMMON_CHANCE = 0.7               -- otherwise Uncommon
X.COLOR_MATCH_FROM = 5              -- from this pick, an offer always holds a card of the deck's colours
X.MULTI_BOSS = { "SMO", "BRS", "DMA", "STR" }   -- fight 24's dungeons

X.COLORS = { "W", "U", "B", "R", "G" }
X.PRAYER_IDS = { W = "W01", U = "U01", B = "B01", R = "R01", G = "G01" }

local function Now() return (GetServerTime and GetServerTime()) or time() end
local function Today() return date("%Y-%m-%d", Now()) end

local function Hash(s) return TTS.StableHash(s) end

-- Days from one "YYYY-MM-DD" to another (0 if either is unreadable)
local function DaysBetween(a, b)
    local function T(s)
        local y, m, d = tostring(s or ""):match("^(%d+)-(%d+)-(%d+)$")
        if not y then return nil end
        return time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 })
    end
    local ta, tb = T(a), T(b)
    if not (ta and tb) then return 0 end
    return math.floor((tb - ta) / 86400 + 0.5)
end

local function Store()
    if type(TTS_Endless) ~= "table" then TTS_Endless = {} end
    local s = TTS_Endless
    if s.charges == nil then s.charges, s.chargeDay = X.MAX_CHARGES, Today() end
    s.best = tonumber(s.best) or 0
    s.runs = tonumber(s.runs) or 0
    return s
end

function X:Run() return Store().run end
function X:Best() return Store().best end
function X:Runs() return Store().runs end
function X:LastRun() return Store().lastRun end

-- =========================================================================
-- PACK CHARGES: +1 at each local midnight, up to 7; a milestone win spends one
-- =========================================================================
function X:Charges()
    local s = Store()
    local today = Today()
    local days = DaysBetween(s.chargeDay, today)
    if days > 0 then s.charges = math.min(self.MAX_CHARGES, (tonumber(s.charges) or 0) + days) end
    s.chargeDay = today
    s.charges = math.max(0, math.min(self.MAX_CHARGES, tonumber(s.charges) or 0))
    return s.charges
end

-- Seconds until the next charge (local midnight), or nil when the bank is full
function X:NextChargeWait()
    if self:Charges() >= self.MAX_CHARGES then return nil end
    local now = Now()
    local t = date("*t", now)
    t.day, t.hour, t.min, t.sec = t.day + 1, 0, 0, 0
    return math.max(0, time(t) - now)
end

-- =========================================================================
-- CARD POOLS
--   Common:   zone denizens (the packs' zone pool) and class spells
--   Uncommon: dungeon denizens (the packs' dungeon pool)
--   Rare:     solo reward cards (not Settlements) and boss cards
-- Never: prizes, the beta card, heroes, Adds, Settlements, profession cards, raid cards,
-- campaign prizes.
-- =========================================================================
local function Excluded(card)
    if not card then return true end
    if card.isPrize or card.isBeta or card.isHero or card.isToken or card.isProfession or card.campaignPrize
        or card.type == "Settlement" or card.type == "Land" or card.unlockOnDeath then
        return true
    end
    return TTS.Packs and TTS.Packs.IsRaidCard and TTS.Packs:IsRaidCard(card) or false
end
X.Excluded = Excluded

local pools
local function Pools()
    if pools then return pools end
    pools = { common = {}, uncommon = {}, rare = {} }
    local seen = {}
    local function Add(list, card)
        if card and not seen[card.id] and not Excluded(card) then
            seen[card.id] = true
            table.insert(list, card.id)
        end
    end
    local P = TTS.Packs
    for _, card in ipairs(P and P:PoolCards("zone") or {}) do Add(pools.common, card) end
    for _, card in ipairs(P and P:PoolCards("dungeon") or {}) do Add(pools.uncommon, card) end
    local ids = {}
    for id in pairs(TTS.Cards or {}) do ids[#ids + 1] = id end
    table.sort(ids)
    for _, id in ipairs(ids) do
        local card = TTS.Cards[id]
        if card.class and card.type == "Sorcery" and card.subType ~= "Gear" and not card.isGift then
            Add(pools.common, card)
        elseif card.isReward or id:match("^BOSS") then
            Add(pools.rare, card)
        end
    end
    for _, list in pairs(pools) do table.sort(list) end
    return pools
end

local function ColorOf(id)
    local c = TTS.Cards[id]
    return c and X.PRAYER_IDS[c.color or ""] and c.color or nil
end

-- The colours of a list of card ids: { W = true, ... }
local function ColorsOf(list)
    local set = {}
    for _, id in ipairs(list or {}) do
        local col = ColorOf(id)
        if col then set[col] = true end
    end
    return set
end
X.ColorsOf = ColorsOf

local function SharesColor(id, colors)
    local col = ColorOf(id)
    return col ~= nil and colors[col] == true
end

-- A card of `pool` not in `taken` and passing ok, picked with rng (nil when none is left)
local function DrawFrom(pool, taken, rng, ok)
    local left = {}
    for _, id in ipairs(pool or {}) do
        if not taken[id] and (not ok or ok(id)) then left[#left + 1] = id end
    end
    if #left == 0 then return nil end
    return left[rng(#left)]
end

-- Makes sure at least one card of `offer` shares a colour with `colors` (when there are any),
-- replacing slot `slot` with a Common of those colours
local function EnsureColor(offer, colors, slot, rng)
    if next(colors) == nil then return end
    for _, id in ipairs(offer) do
        if SharesColor(id, colors) then return end
    end
    local taken = {}
    for i, id in ipairs(offer) do if i ~= slot then taken[id] = true end end
    local id = DrawFrom(Pools().common, taken, rng, function(c) return SharesColor(c, colors) end)
    if id then offer[slot] = id end
end

-- =========================================================================
-- THE RUN
-- =========================================================================
local function Changed()
    if X.onChange then X.onChange() end
end

function X:StartRun()
    local s = Store()
    if s.run then return s.run end
    s.runs = s.runs + 1
    s.lastRun = nil
    s.run = {
        seed = math.random(1, 2147483646), stage = "draft",
        picks = {}, deck = {}, fight = 1, curses = {}, twists = {}, recent = {}, packs = 0,
    }
    self:MakeOffer()
    Changed()
    return s.run
end

-- Ends the run (a loss, a concede, a deck-out, or abandoning it)
function X:EndRun()
    local s = Store()
    local run = s.run
    if not run then return end
    local wins = (run.fight or 1) - 1
    if wins > s.best then s.best = wins end
    s.lastRun = { wins = wins, packs = run.packs or 0, best = s.best }
    s.run = nil
    Changed()
end

-- =========================================================================
-- DRAFT: 12 picks of 1 from 5, then 8 basic Prayers
-- =========================================================================
function X:MakeOffer()
    local run = self:Run()
    if not run then return end
    local k = #run.picks + 1
    local rng = TTS.NewRng(Hash(run.seed .. ":draft:" .. k))
    local pp = Pools()
    local offer, taken = {}, {}
    for slot = 1, X.OFFER_SIZE do
        local pool
        if slot == 1 and self.RARE_PICKS[k] then
            pool = pp.rare
        elseif rng() < self.COMMON_CHANCE then
            pool = pp.common
        else
            pool = pp.uncommon
        end
        local id = DrawFrom(pool, taken, rng) or DrawFrom(pp.common, taken, rng)
        if id then
            offer[#offer + 1] = id
            taken[id] = true
        end
    end
    if k >= self.COLOR_MATCH_FROM then EnsureColor(offer, ColorsOf(run.picks), #offer, rng) end
    run.offer = offer
end

function X:Pick(slot)
    local run = self:Run()
    if not (run and run.stage == "draft" and run.offer and run.offer[slot]) then return end
    local id = run.offer[slot]
    table.insert(run.picks, id)
    table.insert(run.deck, id)
    if #run.picks >= self.DRAFT_PICKS then
        run.offer = nil
        run.stage = "prayers"
    else
        self:MakeOffer()
    end
    Changed()
end

-- counts = { W = n, ... } summing to X.PRAYERS
function X:SetPrayers(counts)
    local run = self:Run()
    if not (run and run.stage == "prayers") then return false end
    local total = 0
    for _, col in ipairs(self.COLORS) do total = total + (tonumber(counts[col]) or 0) end
    if total ~= self.PRAYERS then return false end
    for _, col in ipairs(self.COLORS) do
        for _ = 1, tonumber(counts[col]) or 0 do table.insert(run.deck, self.PRAYER_IDS[col]) end
    end
    run.stage = "ready"
    self:PlanFight()
    Changed()
    return true
end

-- The basic Prayers in the run's deck, by colour: { W = n, ... }, and their total
local PRAYER_COLOR = {}
for col, id in pairs(X.PRAYER_IDS) do PRAYER_COLOR[id] = col end

function X:PrayerCounts()
    local run = self:Run()
    local counts, total = {}, 0
    for _, col in ipairs(self.COLORS) do counts[col] = 0 end
    for _, id in ipairs(run and run.deck or {}) do
        local col = PRAYER_COLOR[id]
        if col then
            counts[col] = counts[col] + 1
            total = total + 1
        end
    end
    return counts, total
end

-- Between fights (after each win, and before the first) the deck's basic Prayers can be
-- moved between colours; their total stays the same (adding one is a win's reward)
function X:CanAdjustPrayers()
    local run = self:Run()
    return run ~= nil and run.stage == "ready"
end

function X:AdjustPrayers(counts)
    if not self:CanAdjustPrayers() then return false end
    local run = self:Run()
    local _, have = self:PrayerCounts()
    local total = 0
    for _, col in ipairs(self.COLORS) do total = total + math.max(0, tonumber(counts[col]) or 0) end
    if total ~= have then return false end
    local deck = {}
    for _, id in ipairs(run.deck) do
        if not PRAYER_COLOR[id] then deck[#deck + 1] = id end
    end
    for _, col in ipairs(self.COLORS) do
        for _ = 1, math.max(0, tonumber(counts[col]) or 0) do deck[#deck + 1] = self.PRAYER_IDS[col] end
    end
    run.deck = deck
    Changed()
    return true
end

-- =========================================================================
-- FIGHTS AND SCALING
--   1-3 basic AI, 4-7 tactical, 9+ expert, opponents on 20 life
--   every 8th fight a dungeon milestone at its own life:
--     8  a tactical dungeon with its boss rules
--     16 an expert dungeon + Tyrannical
--     24 a multi-boss dungeon + Tyrannical + 1 more curse for that fight
--     32, 40, 48... an expert dungeon with 2 boss rules + Tyrannical, and a lasting twist (max 4)
--   from fight 17 (and the milestones from 24) the opponent gets +2 life per 4 fights past 9
--   a lasting curse at fights 12, 16, 20, 24... (no repeats; never Tyrannical)
--   from fight 33 the opponent's denizens get +1/+1, from fight 49 +2/+2
-- =========================================================================
local function LifeBonus(f) return 2 * math.floor((f - 9) / 4) end

function X:IsMilestone(f) return f % self.MILESTONE_EVERY == 0 end

-- The next milestone fight at or after f
function X:NextMilestone(f)
    return math.ceil(f / self.MILESTONE_EVERY) * self.MILESTONE_EVERY
end

local function AIFor(f)
    if f <= 3 then return "basic" end
    if f <= 7 then return "tactical" end
    return "expert"
end

local function Contains(list, v)
    for _, x in ipairs(list or {}) do if x == v then return true end end
    return false
end

local function LastingCurses()
    local out = {}
    for _, id in ipairs(TTS.MUTATOR_CURSES) do
        local rule = TTS.EncounterRules[id]
        if not (rule and rule.milestoneOnly) then out[#out + 1] = id end
    end
    return out
end

local function PickNew(list, have, rng)
    local left = {}
    for _, id in ipairs(list) do if not Contains(have, id) then left[#left + 1] = id end end
    if #left == 0 then return nil end
    return left[rng(#left)]
end

-- The milestone's dungeon for fight f
local function MilestoneDungeons(f)
    local out = {}
    if f == 24 then
        for _, id in ipairs(X.MULTI_BOSS) do
            if TTS.SoloEncounters[id] then out[#out + 1] = TTS.SoloEncounters[id] end
        end
        return out
    end
    for _, enc in ipairs(TTS:GetSoloEncounters("dungeon")) do
        if f == 8 then
            if enc.ai == "tactical" then out[#out + 1] = enc end
        elseif f == 16 then
            if enc.ai == "expert" then out[#out + 1] = enc end
        elseif enc.ai == "expert" and #(enc.rules or {}) >= 2 then
            out[#out + 1] = enc
        end
    end
    return out
end

-- Works out the next fight once (stored on the run, so a /reload keeps it): its opponent, AI,
-- life and rules. Adding a lasting curse or twist happens here.
function X:PlanFight()
    local run = self:Run()
    if not run then return nil end
    if run.plan and run.plan.fight == run.fight then return run.plan end
    local f = run.fight
    local rng = TTS.NewRng(Hash(run.seed .. ":fight:" .. f))
    local milestone = self:IsMilestone(f)
    local plan = { fight = f, milestone = milestone, newCurse = nil, newTwist = nil }

    if f >= 12 and f % 4 == 0 then
        local id = PickNew(LastingCurses(), run.curses, rng)
        if id then
            table.insert(run.curses, id)
            plan.newCurse = id
        end
    end
    if milestone and f >= 32 and #run.twists < self.MAX_TWISTS then
        local id = PickNew(TTS.MUTATOR_TWISTS, run.twists, rng)
        if id then
            table.insert(run.twists, id)
            plan.newTwist = id
        end
    end

    local src, rules = nil, {}
    if milestone then
        local list = MilestoneDungeons(f)
        if #list == 0 then list = TTS:GetSoloEncounters("dungeon") end
        src = list[rng(#list)]
        for _, r in ipairs(src.rules or {}) do rules[#rules + 1] = r end
        plan.ai = (f == 8) and "tactical" or "expert"
        plan.life = (src.life or 20) + (f >= 24 and LifeBonus(f) or 0)
        if f >= 16 then rules[#rules + 1] = "TYRANNICAL" end
        if f == 24 then
            local have = {}
            for _, id in ipairs(run.curses) do have[#have + 1] = id end
            local extra = PickNew(LastingCurses(), have, rng)
            if extra then
                rules[#rules + 1] = extra
                plan.extraCurse = extra
            end
        end
    else
        local zones, fresh = TTS:GetSoloEncounters("zone"), {}
        for _, enc in ipairs(zones) do
            if not Contains(run.recent, enc.id) then fresh[#fresh + 1] = enc end
        end
        if #fresh == 0 then fresh = zones end
        src = fresh[rng(#fresh)]
        plan.ai = AIFor(f)
        plan.life = (f >= 17) and (20 + LifeBonus(f)) or 20
    end

    for _, id in ipairs(run.curses) do if not Contains(rules, id) then rules[#rules + 1] = id end end
    for _, id in ipairs(run.twists) do rules[#rules + 1] = id end
    if f >= 49 then rules[#rules + 1] = "ENDLESS_MIGHT2"
    elseif f >= 33 then rules[#rules + 1] = "ENDLESS_MIGHT1" end

    plan.source = src.id
    plan.rules = rules
    table.insert(run.recent, src.id)
    while #run.recent > self.RECENT do table.remove(run.recent, 1) end
    run.plan = plan
    return plan
end

-- The encounter E:StartMatch plays for the planned fight
function X:BuildEncounter()
    local run = self:Run()
    local plan = run and self:PlanFight()
    if not plan then return nil end
    local src = TTS.SoloEncounters[plan.source]
    if not src then return nil end
    local deck = {}
    for _, id in ipairs(run.deck) do deck[#deck + 1] = id end
    local rules = {}
    for _, id in ipairs(plan.rules) do rules[#rules + 1] = id end
    return {
        id = "ENDLESS", kind = "endless", order = 0,
        name = src.name, zone = src.zone, opponent = src.opponent, bosses = src.bosses,
        life = plan.life, ai = plan.ai, rules = rules, background = src.background,
        deck = TTS.Engine:BuildEncounterDeck(src),
        playerDeck = deck,
        seed = Hash(run.seed .. ":" .. plan.fight),
        source = src.id, fight = plan.fight, milestone = plan.milestone,
    }
end

-- Why a fight can't start now, or nil
function X:StartBlocker()
    local E = TTS.Engine
    if E and E.inMatch then return L("solo.inProgress") end
    if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() then return L("solo.closeDeckbuilder") end
    if TTS.WaitingRoom and TTS.WaitingRoom.isQueued then return L("solo.leaveQueue") end
    local run = self:Run()
    if not (run and run.stage == "ready") then return L("endless.notReady") end
    return nil
end

function X:StartFight()
    local blocker = self:StartBlocker()
    if blocker then return false, blocker end
    local run = self:Run()
    local enc = self:BuildEncounter()
    if not enc then return false, L("endless.notReady") end
    run.stage = "fight"
    TTS.Engine:StartMatch(TTS:EncounterOpponent(enc), true, true, enc)
    if not TTS.Engine.inMatch then
        run.stage = "ready"
        return false
    end
    return true
end

-- =========================================================================
-- AFTER A FIGHT
-- =========================================================================
-- The beaten encounter's own cards: its denizens, and for a dungeon its bosses and reward card
local function EncounterCards(src)
    local list, seen = {}, {}
    local function Add(id)
        local card = TTS.Cards[id]
        if card and not seen[id] and not Excluded(card) then
            seen[id] = true
            list[#list + 1] = id
        end
    end
    local ids = {}
    for id, card in pairs(TTS.Cards) do
        if card.type == "Creature" and card.zone == src.zone and not card.isReward and not id:match("^BOSS") then
            ids[#ids + 1] = id
        end
    end
    table.sort(ids)
    for _, id in ipairs(ids) do Add(id) end
    if src.kind == "dungeon" then
        for _, b in ipairs(src.bosses or {}) do Add(b) end
        if src.reward then Add(src.reward) end
    end
    return list
end

-- X.OFFER_SIZE cards from the beaten encounter, at least one sharing a colour with the run's deck
function X:MakeReward(src, f)
    local run = self:Run()
    local rng = TTS.NewRng(Hash(run.seed .. ":reward:" .. f))
    local pool = EncounterCards(src)
    local offer, taken = {}, {}
    for _ = 1, X.OFFER_SIZE do
        local id = DrawFrom(pool, taken, rng) or DrawFrom(Pools().common, taken, rng)
        if id then
            offer[#offer + 1] = id
            taken[id] = true
        end
    end
    local colors = ColorsOf(run.deck)
    -- One of the encounter's own cards in the deck's colours if it has one, else a Common
    local shares = false
    for _, id in ipairs(offer) do if SharesColor(id, colors) then shares = true end end
    if not shares and next(colors) ~= nil then
        local others = {}
        for i, id in ipairs(offer) do if i ~= #offer then others[id] = true end end
        local id = DrawFrom(pool, others, rng, function(c) return SharesColor(c, colors) end)
        if id then offer[#offer] = id else EnsureColor(offer, colors, #offer, rng) end
    end
    run.reward = offer
end

local function FinishReward(run)
    run.reward = nil
    run.stage = "ready"
    X:PlanFight()
    Changed()
end

function X:TakeReward(slot)
    local run = self:Run()
    if not (run and run.stage == "reward" and run.reward and run.reward[slot]) then return end
    table.insert(run.deck, run.reward[slot])
    FinishReward(run)
end

function X:TakePrayer(col)
    local run = self:Run()
    if not (run and run.stage == "reward" and self.PRAYER_IDS[col]) then return end
    table.insert(run.deck, self.PRAYER_IDS[col])
    FinishReward(run)
end

function X:SkipReward()
    local run = self:Run()
    if not (run and run.stage == "reward") then return end
    FinishReward(run)
end

-- From CoreEngine.lua EndMatch: the result line for the popup (nil for none)
function X:OnMatchEnd(enc, outcome)
    local s = Store()
    local run = s.run
    if not (run and enc and enc.fight == run.fight) then return nil end
    local line
    if outcome == "won" then
        local f = run.fight
        local parts = { L("endless.result.won", f) }
        if self:IsMilestone(f) then
            if self:Charges() > 0 then
                s.charges = s.charges - 1
                run.packs = (run.packs or 0) + 1
                if TTS.Packs then TTS.Packs:Give(self.PACK, L("endless.from")) end
                table.insert(parts, L("endless.result.pack", TTS.Packs and TTS.Packs:Name(self.PACK) or ""))
            else
                local wait = self:NextChargeWait()
                local msg = L("endless.noCharge", wait and TTS:FormatWait(wait) or "?")
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD200[TTSE]|r " .. msg)
                table.insert(parts, msg)
            end
        end
        if f > s.best then s.best = f end
        run.fight = f + 1
        run.plan = nil
        run.stage = "reward"
        local src = TTS.SoloEncounters[enc.source]
        if src then self:MakeReward(src, f) else FinishReward(run) end
        line = table.concat(parts, "\n")
    elseif outcome == "lost" or outcome == "conceded" then
        local wins = run.fight - 1
        self:EndRun()
        line = L("endless.result.over", wins, s.best)
    else
        -- (a game that never really finished: the same fight is played again)
        run.stage = "ready"
    end
    Changed()
    return line
end

-- After the result popup the window comes back (UI\Board.lua CloseAfterMatch)

do
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(self, event, name)
        if name ~= "ForeverCCG" then return end
        self:UnregisterAllEvents()
        local s = Store()
        -- A fight in progress isn't saved: after a /reload, a disconnect or a crash the same
        -- fight starts again from the start (same seed: same opponent, mutators and shuffles)
        if s.run and s.run.stage == "fight" then s.run.stage = "ready" end
        X:Charges()
    end)
end

-- =========================================================================
-- ENDLESS MIGHT (not a mutator: the late fights' stat bonus, SoloEncounters.lua rules)
-- =========================================================================
TTS.EncounterRules.ENDLESS_MIGHT1 = {
    name = "Endless Might",
    text = "The opponent's denizens get +1/+1.",
    statBonus = function(self, enc, perm, isRemote)
        if isRemote then return 1, 1 end
        return 0, 0
    end,
}
TTS.EncounterRules.ENDLESS_MIGHT2 = {
    name = "Endless Might",
    text = "The opponent's denizens get +2/+2.",
    statBonus = function(self, enc, perm, isRemote)
        if isRemote then return 2, 2 end
        return 0, 0
    end,
}
