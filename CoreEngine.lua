--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
TTS.Engine = TTS.Engine or {
    inMatch = false,
    isMyTurn = false,
    isSolo = false,
    turn = 0,
    phase = "PREGAME",
    opponent = nil,
    landPlayedThisTurn = false,
    preventCombatDamage = false,
    cantBlockThisTurn = false,
    targeting = nil,
    blockingState = nil,
    stolenCreatures = {},

    localState = {
        life = 20,
        mana = { W = 0, U = 0, B = 0, R = 0, G = 0, C = 0 },
        deck = {},
        hand = {},
        field = {},
        graveyard = {},
        damageShield = 0,
        dots = {},
        hots = {}
    },

    remoteState = {
        life = 20,
        handCount = 0,
        hand = {},
        deck = {},
        mana = { W = 0, U = 0, B = 0, R = 0, G = 0, C = 0 },
        field = {},
        graveyard = {},
        damageShield = 0,
        dots = {},
        hots = {}
    }
}

local E = TTS.Engine
local L = TTS.L

function TTS:SafeAfter(seconds, callback)
    if C_Timer and C_Timer.After then
        C_Timer.After(seconds, callback)
    else
        local delayFrame = CreateFrame("Frame")
        local elapsed = 0
        delayFrame:SetScript("OnUpdate", function(self, delta)
            elapsed = elapsed + delta
            if elapsed >= seconds then
                self:SetScript("OnUpdate", nil)
                callback()
            end
        end)
    end
end

function E:Log(msg, category)
    local prefix = "|cFFFFFF00[TTSE]|r "
    if category == "ACTION" then
        prefix = "|cFF00FF00[TTSE]|r "
    elseif category == "COMBAT" then
        prefix = "|cFFFF4444[TTSE]|r "
    elseif category == "MANA" then
        prefix = "|cFF66BBFF[TTSE]|r "
    elseif category == "ERROR" then
        prefix = "|cFFFF2222[TTSE]|r "
    elseif category == "SYSTEM" then
        prefix = "|cFFFFA500[TTSE]|r "
    end

    local formattedMsg = TTS.FormatSymbols and TTS:FormatSymbols(msg, 14) or msg
    local fullText = prefix .. formattedMsg

    if TTS.MatchLog and TTS.MatchLog.AddMessage then
        TTS.MatchLog:AddMessage(fullText)
    else
        DEFAULT_CHAT_FRAME:AddMessage(fullText)
    end
end

function TTS:DeckCardCount(deck)
    local count = 0
    for _, qty in pairs(deck and deck.cards or {}) do count = count + qty end
    return count
end

-- 40-50 cards
function TTS:IsDeckPlayable(deck)
    local count = TTS:DeckCardCount(deck)
    return count >= 40 and count <= 50
end

function TTS:PlayableDeckCount()
    local n = 0
    for i = 1, TTS.MAX_DECK_SLOTS or #(TTS_SavedDecks or {}) do
        if TTS:IsDeckPlayable(TTS_SavedDecks and TTS_SavedDecks[i]) then n = n + 1 end
    end
    return n
end

-- The active deck (solo games, and the deck a PvP game is played with once picked)
function E:ValidateDeck()
    return TTS:IsDeckPlayable(TTS_SavedDecks and TTS_SavedDecks[TTS_ActiveDeckIndex])
end

-- PvP: the deck is picked when the game starts (UI\DeckPicker.lua), so any playable deck will do
function E:HasPlayableDeck()
    return TTS:PlayableDeckCount() > 0
end

-- =========================================================================
-- ATTACK ABILITY CHECK
-- =========================================================================
function E:CanCreatureAttack(perm)
    if not perm then return false end
    local card = TTS.Cards and TTS.Cards[perm.id]
    if not card or card.type ~= "Creature" then return false end

    if perm.tapped then return false end
    if perm.sick and not self:HasKeyword(perm, false, "haste") then return false end
    if card.defender then return false end

    return true
end

-- =========================================================================
-- MATCH COMPLETION & EMOTES
-- =========================================================================
function E:PlayMatchEmote(outcome, opponentName)
    local emoteText = L("emote." .. outcome, opponentName)
    SendChatMessage(emoteText, "EMOTE")

    -- Play the built-in emote a moment later so it does not collide with the emote text above
    local followUp = nil
    if outcome == "won" then
        followUp = "CHEER"
    elseif outcome == "lost" or outcome == "conceded" then
        followUp = "CRY"
    end
    if followUp then
        TTS:SafeAfter(0.5, function() DoEmote(followUp) end)
    end
end

-- Post-game popup: your result, then the opponent's ("Thrall wins!" / "Thrall loses!").
-- The emote is sent from the Accept click: a win often arrives as an
-- addon message, and the chat emote is blocked when no click is behind it.
-- Headline and opponent line per outcome: result.<outcome> / result.opponent.<outcome>
local RESULT_HEADLINES = { won = true, lost = true, conceded = true }

StaticPopupDialogs["TTS_MATCH_RESULT"] = {
    text = "%s\n\n%s",
    button1 = ACCEPT or "Accept",
    OnAccept = function(self, data)
        -- No public emote for games against the AI, except for clearing a solo dungeon
        if data and not data.isSolo then E:PlayMatchEmote(data.outcome, data.opponent) end
        if data and data.dungeon then
            SendChatMessage(L("emote.dungeon", data.dungeon), "EMOTE")
            TTS:SafeAfter(0.5, function() DoEmote("CHEER") end)
        end
        -- Leave the final board (unless a new match has already started on it)
        if not E.inMatch then E:CloseMatchBoard() end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
}

-- Closes the post-match board and returns to the main window
function E:CloseMatchBoard()
    if TTS.BoardFrame and TTS.BoardFrame.CloseAfterMatch then
        TTS.BoardFrame:CloseAfterMatch()
        return
    end
    if TTS.BoardFrame then TTS.BoardFrame:Hide() end
    if TTS.BoardRestoreFrame then TTS.BoardRestoreFrame:Hide() end
    if TTS.MainFrame then
        TTS.MainFrame:Show()
        if TTS.MainFrame.UpdatePlayState then
            TTS.MainFrame:UpdatePlayState()
        end
    end
end

function E:EndMatch(outcome, reason)
    if not self.inMatch then return end
    local opponentName = self.opponent or L("side.opponentCap")

    -- Draw the final board state while still in the match (the board may be minimized),
    -- then freeze it there until the result popup is accepted
    local B = TTS.BoardFrame
    if B then
        if B:IsShown() then self:RefreshUI() else B:Show() end
    end
    self.inMatch = false
    self:ClearChoices()

    -- A solo encounter win records progress and grants the encounter's reward card
    local rewardText, rewardCard
    if outcome == "won" and self.isSolo and self.encounter then
        local rewardId, copies, wasComplete = TTS:RecordEncounterWin(self.encounter)
        rewardCard = rewardId and TTS.Cards[rewardId]
        if rewardCard then
            rewardText = "\n\n" .. L(wasComplete and "result.rewardComplete" or "result.reward", TTS:CardName(rewardCard), copies)
            self:Log(L("log.rewardEarned", TTS:CardName(rewardCard), copies), "SYSTEM")
        end
    end

    local headline = outcome and RESULT_HEADLINES[outcome] and L("result." .. outcome)
    if outcome and opponentName ~= "" then
        if headline then
            -- A won solo dungeon is announced with an emote when the popup is accepted
            local dungeon = outcome == "won" and self.isSolo and self.encounter and self.encounter.kind == "dungeon"
                and TTS:EncounterName(self.encounter) or nil
            StaticPopup_Show("TTS_MATCH_RESULT", headline, L("result.opponent." .. outcome, opponentName) .. (rewardText or ""),
                { outcome = outcome, opponent = opponentName, isSolo = self.isSolo, dungeon = dungeon })
            if rewardCard and B and B.ShowRewardCard then B:ShowRewardCard(rewardCard) end
        else
            if not self.isSolo then self:PlayMatchEmote(outcome, opponentName) end
        end
    end

    self:Log(L("log.matchEnded", L("outcome." .. outcome), reason or ""), "SYSTEM")

    if headline and opponentName ~= "" and B and B.ShowMatchResult then
        B:ShowMatchResult(headline)
    else
        -- No result popup to accept (e.g. a cancelled setup): leave the board straight away
        self:CloseMatchBoard()
    end
end

function E:WinMatch(reason)
    self:EndMatch("won", reason or L("end.victory"))
end

function E:LoseMatch(reason)
    if not self.isSolo and self.opponent then
        TTS.Net:Send(self.opponent, "ACTION:DEFEATED")
    end
    self:EndMatch("lost", reason or L("end.defeat"))
end

function E:ConcedeMatch()
    if not self.isSolo and self.opponent then
        TTS.Net:Send(self.opponent, "ACTION:CONCEDE")
    end
    self:EndMatch("conceded", L("end.conceded"))
end

StaticPopupDialogs["TTS_CONCEDE"] = {
    text = "%s",
    button1 = YES or "Yes",
    button2 = NO or "No",
    OnAccept = function() if E.inMatch then E:ConcedeMatch() end end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- The board's Concede button asks first
function E:ConfirmConcede()
    if not self.inMatch then return end
    StaticPopup_Show("TTS_CONCEDE", L("board.concedeConfirm"))
end

-- =========================================================================
-- DAMAGE & LIFE
-- =========================================================================
function E:DamagePlayer(isRemote, amount, reason)
    if amount <= 0 then return end
    -- Mirroring the PvP opponent's play (CardLogic.lua, E:RunMirrored): their client sends
    -- damage to us itself, and handles their own shield and defeat; we only track their life.
    if self.mirroring then
        if not isRemote then return end
        local shield = self.remoteState.mirror and self.remoteState.mirror.shield or 0
        amount = amount - math.min(amount, shield)
        if amount <= 0 then return end
        self.remoteState.life = self.remoteState.life - amount
        self:Log(L("log.oppTookDamage", self.opponent, amount, TTS:ReasonText(reason) or L("reason.effect"), self.remoteState.life), "COMBAT")
        self:RefreshUI()
        return
    end
    local targetState = isRemote and self.remoteState or self.localState

    if (targetState.damageShield or 0) > 0 then
        local prevented = math.min(amount, targetState.damageShield)
        targetState.damageShield = targetState.damageShield - prevented
        amount = amount - prevented
        self:Log(L("log.shieldPrevented", prevented, isRemote and self.opponent or L("side.you")), "ACTION")
        self:SyncEffects()
        if amount <= 0 then
            self:RefreshUI()
            return
        end
    end

    if isRemote then
        self.remoteState.life = self.remoteState.life - amount
        self:Log(L("log.dealtToOpp", amount, self.opponent, TTS:ReasonText(reason) or L("reason.effect"), self.remoteState.life), "COMBAT")
        if not self.isSolo then
            TTS.Net:Send(self.opponent, string.format("ACTION:DAMAGE:%d:%s", amount, reason or "Damage"))
        end
        if self.remoteState.life <= 0 then
            self:WinMatch(L("end.oppDefeated", self.opponent))
        end
    else
        self.localState.life = self.localState.life - amount
        self:Log(L("log.tookDamage", amount, TTS:ReasonText(reason) or L("reason.damage"), self.localState.life), "COMBAT")
        if self.localState.life <= 0 then
            self:LoseMatch(L("end.zeroLife"))
        end
    end
    self:RefreshUI()
end

-- Damage marked on creatures wears off at the end of every turn (both sides of the board)
function E:ClearCreatureDamage()
    for _, field in ipairs({ self.localState.field, self.remoteState.field }) do
        for _, perm in ipairs(field) do
            perm.damage = 0
        end
    end
end

-- =========================================================================
-- MANA SYSTEM
-- Both functions work for either side's pool (isRemote = the opponent / AI).
-- =========================================================================
local MANA_COLORS = { "W", "U", "B", "R", "G" }

-- What a cost string asks for: { W, U, B, R, G, Generic }
function E:ParseCost(costString)
    local req = { W = 0, U = 0, B = 0, R = 0, G = 0, Generic = 0 }
    for pip in string.gmatch(costString or "", "{(%w+)}") do
        if tonumber(pip) then
            req.Generic = req.Generic + tonumber(pip)
        elseif pip ~= "X" and req[pip] then
            req[pip] = req[pip] + 1
        end
    end
    return req
end

function E:CanPayMana(costString, isRemote)
    if not costString or costString == "" then return true end
    local pool = (isRemote and self.remoteState or self.localState).mana
    local req = self:ParseCost(costString)

    local totalRemaining = 0
    for _, col in ipairs(MANA_COLORS) do
        if (pool[col] or 0) < req[col] then return false end
        totalRemaining = totalRemaining + ((pool[col] or 0) - req[col])
    end
    return totalRemaining >= req.Generic
end

function E:PayMana(costString, isRemote)
    if not self:CanPayMana(costString, isRemote) then return false end
    if not costString or costString == "" then return true end
    local pool = (isRemote and self.remoteState or self.localState).mana
    local req = self:ParseCost(costString)

    for _, col in ipairs(MANA_COLORS) do
        pool[col] = (pool[col] or 0) - req[col]
    end
    local genToPay = req.Generic
    for _, col in ipairs(MANA_COLORS) do
        while (pool[col] or 0) > 0 and genToPay > 0 do
            pool[col] = pool[col] - 1
            genToPay = genToPay - 1
        end
    end
    return true
end

-- =========================================================================
-- PRAYERS AS MANA
-- Untapped prayers count as mana a side could make. The AI always pays this way;
-- the player does when auto-pay is ticked on the board.
-- =========================================================================

-- The colours a prayer can make: { "W" }, or both colours of a dual prayer (colors = { "W", "R" })
function E:ManaColorsOf(card)
    return (card and card.colors) or { card and card.color }
end

-- One side's untapped prayers: basics by colour { W = { perm, ... }, ... }, the prayers
-- that make one of two colours (duals), and those that make both at once when another
-- untapped prayer is tapped with them (doubles, card.makesBoth)
function E:UntappedLands(isRemote)
    local lands = { W = {}, U = {}, B = {}, R = {}, G = {} }
    local duals, doubles = {}, {}
    for _, perm in ipairs((isRemote and self.remoteState or self.localState).field) do
        local card = TTS.Cards[perm.id]
        if card and card.type == "Land" and not perm.tapped then
            if card.makesBoth then
                table.insert(doubles, perm)
            elseif card.colors then
                table.insert(duals, perm)
            elseif lands[card.color] then
                table.insert(lands[card.color], perm)
            end
        end
    end
    return lands, duals, doubles
end

-- The other untapped prayers that could be tapped with a double prayer (perm)
function E:DoublePartners(perm, isRemote)
    local list = {}
    for i, p in ipairs((isRemote and self.remoteState or self.localState).field) do
        local c = TTS.Cards[p.id]
        if p ~= perm and c and c.type == "Land" and not p.tapped then table.insert(list, i) end
    end
    return list
end

local BasePlan

-- Which prayers to tap (and the colour each makes) to pay costString, using mana already
-- in the pool first. Returns the prayers in tap order, the colour of each
-- (colorOf[perm]; "BOTH" for a double prayer), whether that pays the whole cost, and for
-- each double prayer the other prayer tapped with it (partnerOf[perm]); nothing is tapped yet.
-- Double prayers are tried with each possible partner, keeping the plan that pays with
-- the fewest prayers tapped.
function E:PlanLandTaps(costString, isRemote)
    local req = self:ParseCost(costString)
    local lands, duals, doubles = self:UntappedLands(isRemote)
    local mana = (isRemote and self.remoteState or self.localState).mana
    local pool = {}
    for _, col in ipairs(MANA_COLORS) do pool[col] = mana[col] or 0 end

    -- Shallow copies (the prayers themselves stay the same tables)
    local function Copy(t)
        local c = {}
        for k, v in pairs(t) do c[k] = v end
        return c
    end
    local function CopyLands(t)
        local c = {}
        for col, list in pairs(t) do c[col] = { unpack(list) } end
        return c
    end
    local function Remove(list, perm)
        for i, p in ipairs(list) do if p == perm then table.remove(list, i); return true end end
    end

    local best
    local function Consider(plan, colorOf, pays, partnerOf, used)
        local taps = #plan
        for _ in pairs(partnerOf) do taps = taps + 1 end
        if not best or (pays and not best.pays) or (pays == best.pays and (taps < best.taps
            or (taps == best.taps and used < best.used))) then
            best = { plan = plan, colorOf = colorOf, pays = pays, partnerOf = partnerOf, taps = taps, used = used }
        end
    end

    -- doubles[i..]: skip it, or tap it with each prayer still free
    local function Try(i, lands, duals, doubles, pool, front, partnerOf, used)
        if i > #doubles then
            local plan, colorOf, pays = BasePlan(self, req, CopyLands(lands), { unpack(duals) }, Copy(pool))
            local full, colors = {}, {}
            for _, p in ipairs(front) do table.insert(full, p); colors[p] = "BOTH" end
            for _, p in ipairs(plan) do table.insert(full, p); colors[p] = colorOf[p] end
            Consider(full, colors, pays, partnerOf, used)
            return
        end
        local d = doubles[i]
        Try(i + 1, lands, duals, doubles, pool, front, partnerOf, used)   -- not used
        if d.planPartner then return end   -- already the partner of an earlier double
        local c = TTS.Cards[d.id]
        local partners = {}
        for _, col in ipairs(MANA_COLORS) do
            if lands[col][1] then table.insert(partners, lands[col][1]) end   -- one of each colour is enough
        end
        for _, p in ipairs(duals) do table.insert(partners, p) end
        for j = i + 1, #doubles do table.insert(partners, doubles[j]) end
        for _, p in ipairs(partners) do
            local l2, d2, p2 = CopyLands(lands), { unpack(duals) }, Copy(pool)
            local card = TTS.Cards[p.id]
            if not (card.colors and not card.makesBoth and Remove(d2, p)) then
                Remove(l2[card.color] or {}, p)
            end
            p2[c.colors[1]] = p2[c.colors[1]] + 1
            p2[c.colors[2]] = p2[c.colors[2]] + 1
            local f2 = { unpack(front) }
            table.insert(f2, d)
            local po2 = Copy(partnerOf)
            po2[d] = p
            if card.makesBoth then p.planPartner = true end
            Try(i + 1, l2, d2, doubles, p2, f2, po2, used + 1)
            p.planPartner = nil
        end
    end
    Try(1, lands, duals, doubles, pool, {}, {}, 0)
    return best.plan, best.colorOf, best.pays, best.partnerOf
end

-- Taps for costString from basics and duals only (see E:PlanLandTaps); lands, duals and
-- pool are the caller's copies and get used up
BasePlan = function(self, req, lands, duals, pool)
    local plan, colorOf = {}, {}

    local function Tap(perm, col)
        table.insert(plan, perm)
        colorOf[perm] = col
        pool[col] = pool[col] + 1
    end

    -- Coloured pips: basics first, then the dual prayers
    local short = {}
    for _, col in ipairs(MANA_COLORS) do
        while pool[col] < req[col] and #lands[col] > 0 do Tap(table.remove(lands[col]), col) end
        for _ = 1, req[col] - pool[col] do table.insert(short, col) end
    end
    -- Each pip still short goes to a dual prayer that makes its colour (a small search,
    -- so a W/R prayer is kept for the W when another dual can make the R)
    local used = {}
    local function Assign(k)
        if k > #short then return true end
        for _, perm in ipairs(duals) do
            if not used[perm] then
                for _, c in ipairs(self:ManaColorsOf(TTS.Cards[perm.id])) do
                    if c == short[k] then
                        used[perm] = c
                        if Assign(k + 1) then return true end
                        used[perm] = nil
                        break
                    end
                end
            end
        end
        return false
    end
    local paysColours = Assign(1)
    if paysColours then
        for _, perm in ipairs(duals) do
            if used[perm] then Tap(perm, used[perm]) end
        end
    end

    -- Then generic: spare pool mana first, then basics of the colour there are most of,
    -- then dual prayers
    local spare = 0
    for _, col in ipairs(MANA_COLORS) do
        spare = spare + math.max(0, pool[col] - req[col])
    end
    local need = req.Generic - spare
    while need > 0 do
        local best
        for _, col in ipairs(MANA_COLORS) do
            if #lands[col] > 0 and (not best or #lands[col] > #lands[best]) then best = col end
        end
        if best then
            Tap(table.remove(lands[best]), best)
        else
            local perm
            for _, d in ipairs(duals) do
                if not colorOf[d] then perm = d; break end
            end
            if not perm then break end
            Tap(perm, self:ManaColorsOf(TTS.Cards[perm.id])[1])
        end
        need = need - 1
    end
    return plan, colorOf, paysColours and need <= 0
end

-- True if the mana pool plus untapped prayers could pay costString
function E:CanAffordWithLands(costString, isRemote)
    local _, _, pays = self:PlanLandTaps(costString, isRemote)
    return pays
end

function E:AutoPayEnabled()
    return TTS.Options and TTS.Options:Get("autoPayMana") ~= false
end

-- The player's affordability check: the pool alone, or the pool plus untapped prayers with auto-pay
function E:CanPayManaAuto(costString)
    if self:CanPayMana(costString) then return true end
    return self:AutoPayEnabled() and self:CanAffordWithLands(costString, false)
end

-- With auto-pay on, taps the player's prayers the pool is short of for costString,
-- the same way clicking them would (each tap is sent to the opponent).
-- Called before a play's undo snapshot, so both clients save the prayers tapped.
function E:AutoPayMana(costString)
    if not costString or costString == "" or self:CanPayMana(costString) then return end
    if not (self:AutoPayEnabled() and self:CanAffordWithLands(costString, false)) then return end
    local plan, colorOf, _, partnerOf = self:PlanLandTaps(costString, false)
    local function IndexOf(perm)
        for i, p in ipairs(self.localState.field) do
            if p == perm then return i end
        end
    end
    for _, perm in ipairs(plan) do
        local i = IndexOf(perm)
        if i then
            local partner = partnerOf[perm]
            self:TapCard(i, colorOf[perm], partner and IndexOf(partner))
        end
    end
end

-- =========================================================================
-- TURN & PHASE MANAGEMENT
-- =========================================================================

-- "Your turn" alert. Uses the ready-check chime on the Master channel so it is
-- heard even with effects turned down; respects the Sounds checkbox and the
-- "Your-turn alert" option.
local function PlayTurnSound()
    if not (TTS.Sound and TTS.Sound:IsOn("turn")) then return end
    if SOUNDKIT then
        pcall(PlaySound, 31584, "Master")
    else
        pcall(PlaySound, 31584)
    end
end

-- Phase shown while the solo opponent takes its turn
local AI_TURN_PHASE = "WAITING (Opponent's Turn)"
E.AI_TURN_PHASE = AI_TURN_PHASE

function E:CancelTargeting()
    if self.targeting then
        self:Log(L("log.targetingCancelled"), "SYSTEM")
        self.targeting = nil
        self:RefreshUI()
    end
end

function E:NextPhase()
    if self.phase == "COMBAT_BLOCK" and self.blockingState then
        local bs = self.blockingState
        if bs.isRemoteAttacking then
            if self.isSolo then
                -- The AI has no button to click: resolve right away
                self:ResolveCombatDamage()
            elseif not bs.attacksDone then
                -- More ATTACK messages may still be on their way
                self:Log(L("err.stillDeclaring", self.opponent), "ERROR")
            elseif not bs.blocksDeclared and next(bs.blocks) == nil then
                -- No blocks to show the attacker: resolve on both clients straight away
                bs.selectedBlocker = nil
                TTS.Net:Send(self.opponent, "ACTION:RESOLVE_COMBAT")
                self:ResolveCombatDamage()
            elseif not bs.blocksDeclared then
                -- Defending: send our blocks and hand control back to the attacker
                bs.selectedBlocker = nil
                for _, p in ipairs(self:BlockPairs(bs)) do
                    TTS.Net:Send(self.opponent, string.format("ACTION:ASSIGN_BLOCK:%d:%d", p[1], p[2]))
                end
                TTS.Net:Send(self.opponent, "ACTION:BLOCKS_DECLARED")
                bs.blocksDeclared = true
                self:Log(L("log.blocksDeclaredWait"), "SYSTEM")
                self:RefreshUI()
            end
        elseif bs.blocksDeclared then
            -- Attacking: blocks are in and reviewed, resolve combat on both clients
            if not self.isSolo then TTS.Net:Send(self.opponent, "ACTION:RESOLVE_COMBAT") end
            self:ResolveCombatDamage()
        end
        return
    end

    if not self.isMyTurn then return end
    if self:UndoBlocksAction() then return end
    self:CancelTargeting()

    if self.phase == "MAIN1" then
        self:SetPhase("COMBAT_ATTACK")
        self.blockingState = { attackers = {}, blocks = {}, isRemoteAttacking = false }
        self:Log(L("log.combatPhase"), "SYSTEM")

    elseif self.phase == "COMBAT_ATTACK" then
        for i, perm in ipairs(self.localState.field) do
            if not perm.tapped and not perm.sick and perm.id == "BOSS11" then
                self:TapCard(i)
            end
        end

        if self.blockingState and #self.blockingState.attackers > 0 then
            self:SetPhase("COMBAT_BLOCK")
            if self.isSolo then
                self:AIAssignBlocks()
                if next(self.blockingState.blocks) == nil then
                    -- Nothing blocked, so there are no blocks to review: resolve right away
                    self:Log(L("log.oppNoBlockers", self.opponent), "SYSTEM")
                    self:ResolveCombatDamage()
                    return
                end
                self.blockingState.blocksDeclared = true
                self:Log(L("log.oppBlockers", self.opponent), "SYSTEM")
            else
                -- Every ATTACK has gone out: the defender may now block
                TTS.Net:Send(self.opponent, "ACTION:ATTACKS_DONE")
                self:Log(L("log.waitBlockers"), "SYSTEM")
            end
        else
            self.blockingState = nil
            self:SetPhase("MAIN2")
            self:Log(L("log.noAttackers"), "SYSTEM")
        end

    elseif self.phase == "MAIN2" then
        self:EndTurn()
    end
    self:RefreshUI()
end

-- While our attack waits on blocks (or on our Resolve), End Turn instead asks for the turn
-- to end as soon as combat is over; a second click takes that back.
function E:ToggleEndAfterCombat()
    self.endAfterCombat = not self.endAfterCombat or nil
    self:Log(L(self.endAfterCombat and "log.endAfterCombat" or "log.endAfterCombatOff"), "SYSTEM")
    self:RefreshUI()
end

-- Ends the turn asked for during combat, once combat and any choices it brought are done
function E:TryEndAfterCombat()
    if not self.endAfterCombat then return end
    if not (self.inMatch and self.isMyTurn and self.phase == "MAIN2") then return end
    if self.pendingDiscard or self:HasPendingChoice() or self.targeting then return end
    self.endAfterCombat = nil
    self:EndTurn()
end

function E:EndTurn()
    if not self.isMyTurn then return end
    if self:UndoBlocksAction() then return end
    -- Our attack is still being blocked or resolved: end the turn once it's over. With the
    -- blocks already in, that means resolving combat now (TryEndAfterCombat then ends the turn).
    local bs = self.blockingState
    if self.phase == "COMBAT_BLOCK" and bs and not bs.isRemoteAttacking then
        if bs.blocksDeclared then
            self.endAfterCombat = true
            self:NextPhase()
        else
            self:ToggleEndAfterCombat()
        end
        return
    end
    -- Declared attackers have to be resolved first
    if self.phase == "COMBAT_BLOCK" or (self.blockingState and #(self.blockingState.attackers or {}) > 0) then
        self:Log(L("err.finishCombat"), "ERROR")
        return
    end
    self.endAfterCombat = nil

    for _, perm in ipairs(self.localState.field) do
        local mustAttack = (perm.id == "BOSS11")
        if mustAttack and not perm.hasAttackedThisTurn and self:CanCreatureAttack(perm) then
            local card = TTS.Cards[perm.id]
            local cName = card and TTS:CardName(card) or perm.id
            self:Log(L("err.mustAttack", cName), "ERROR")
            return
        end
    end

    self.isMyTurn = false
    self:CloseMulligan()
    self:CancelTargeting()
    self:EndTurnCleanup(false)

    self:Log(L("log.endedTurn"), "SYSTEM")

    if self.isSolo then
        self:SetPhase(AI_TURN_PHASE)
        self:RefreshUI()
        TTS:SafeAfter(1.0, function()
            if not E.inMatch or not E.isSolo then return end
            E:AITakeTurn()
        end)
    else
        self:SetPhase("WAITING")
        TTS.Net:Send(self.opponent, "ACTION:END_TURN")
        -- Their turn starts now: untap their side (frozen creatures stay tapped), tick the
        -- effects we mirrored onto their creatures, and count their draw
        if not self:BeginTurn(true) then return end
        self:RefreshUI()
    end
end

-- Untaps one side's permanents (a frozen permanent stays tapped once) and clears summoning sickness
function E:UntapSide(isRemote)
    for _, perm in ipairs((isRemote and self.remoteState or self.localState).field) do
        perm.sick = false
        perm.isAttacking = nil
        perm.hasAttackedThisTurn = nil
        perm.blockedThisCombat = nil
        if perm.freezeUntap then
            perm.freezeUntap = false
        else
            perm.tapped = false
        end
    end
end

-- Start of a turn for either side: untap, tick that side's over-time effects, draw.
-- Returns false if the match ended along the way.
function E:BeginTurn(isRemote)
    local st = isRemote and self.remoteState or self.localState
    self.blockingState = nil
    self.cantBlockThisTurn = false
    self.preventCombatDamage = false
    if isRemote then
        self.remoteLandPlayed = false
        self.remoteTurns = (self.remoteTurns or 0) + 1
    else
        self.landPlayedThisTurn = false
        self:CloseMulligan()
    end

    self:UntapSide(isRemote)
    st.mana = { W = 0, U = 0, B = 0, R = 0, G = 0, C = 0 }

    -- Creatures that die at the start of their controller's turn (diesAtTurnStart, e.g.
    -- Leeroy Jenkins). Both clients run BeginTurn for both sides, so PvP stays in step.
    local doomed = {}
    for _, perm in ipairs(st.field) do
        local c = TTS.Cards[perm.id]
        if c and c.diesAtTurnStart then table.insert(doomed, perm) end
    end
    for _, perm in ipairs(doomed) do
        self:Log(L("log.diesAtTurnStart", TTS:CardName(perm.id)), "COMBAT")
        self:DestroyCreature(perm)
        if not self.inMatch then return false end
    end

    self:TickOverTime(isRemote)
    if not self.inMatch then return false end
    self:RunEncounterRules(isRemote and "onAITurnStart" or "onPlayerTurnStart")
    if not self.inMatch then return false end
    self:DrawCardFor(isRemote)
    return self.inMatch
end

-- End of a turn for either side: the mana pool empties, "until end of turn" effects wear off,
-- creatures this side took control of go back, and damage on creatures is removed.
function E:EndTurnCleanup(isRemote)
    local st = isRemote and self.remoteState or self.localState
    self.preventCombatDamage = false
    self.cantBlockThisTurn = false
    self.blockingState = nil
    st.mana = { W = 0, U = 0, B = 0, R = 0, G = 0, C = 0 }

    for i = #self.stolenCreatures, 1, -1 do
        local entry = self.stolenCreatures[i]
        if (entry.controllerIsRemote or false) == isRemote then
            table.remove(self.stolenCreatures, i)
            local from = isRemote and self.remoteState.field or self.localState.field
            local to = entry.isRemoteOwner and self.remoteState.field or self.localState.field
            for fIdx, perm in ipairs(from) do
                if perm == entry.perm then
                    table.remove(from, fIdx)
                    perm.sick = true
                    perm.isAttacking = nil
                    table.insert(to, perm)
                    self:Log(L("log.controlExpired"), "ACTION")
                    break
                end
            end
        end
    end

    -- "Until end of turn" effects wear off on both sides of the board
    for _, field in ipairs({ self.localState.field, self.remoteState.field }) do
        for _, perm in ipairs(field) do
            perm.tempPower = 0
            perm.tempToughness = 0
            perm.tempKw = nil
            perm.mustAttack = nil
            perm.isAttacking = nil
            perm.hasAttackedThisTurn = nil
        end
    end
    self:ClearCreatureDamage()
end

-- The opponent (or the AI) ended their turn: our turn begins
function E:OnRemoteEndTurn()
    self:CancelTargeting()
    self:OnLocalTurnStart()
    self:EndTurnCleanup(true)

    self.isMyTurn = true
    self.turn = self.turn + 1
    self:Log(L("log.turnStart", self.turn), "SYSTEM")
    if not self:BeginTurn(false) then return end
    self:SetPhase("MAIN1")
    PlayTurnSound()
    self:RefreshUI()
end

function E:StartMatch(opponentName, isHost, isSolo, encounter)
    if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() then
        self:Log(L("err.deckbuilderOpen"), "ERROR")
        return
    end

    -- Starting a game takes the player out of the waiting room
    local WR = TTS.WaitingRoom
    if WR then
        if WR.isQueued then WR:ToggleQueue() end
        if WR.frame then WR.frame:Hide() end
    end

    if TTS.MatchLog and TTS.MatchLog.Clear then
        TTS.MatchLog:Clear()
    end

    self.inMatch = true
    self.opponent = opponentName or L("side.opponentCap")
    self.opponentScore = nil   -- PvP: set by Network.lua from the INVITE/ACCEPT
    self.isSolo = isSolo or false
    self.isMyTurn = isHost
    -- Hero cards (Hero.lua): the opponent's stands in until their HEROINFO arrives; ours goes
    -- to them before any card can be played
    if TTS.Hero then
        TTS.Hero:BuildCard(TTS.Hero.OPP_ID, { name = self.opponent, class = "WARRIOR", upgrades = 0 })
        if not self.isSolo then TTS.Net:Send(self.opponent, "ACTION:HEROINFO:" .. TTS.Hero:Encode()) end
    end
    self.turn = 1
    self.landPlayedThisTurn = false
    self.preventCombatDamage = false
    self.cantBlockThisTurn = false
    self.targeting = nil
    self.blockingState = nil
    self.pendingDiscard = nil
    self.choiceQueue = nil
    self.endAfterCombat = nil
    self.mulliganOpen = true
    self.stolenCreatures = {}
    self.remoteTurns = 0
    self.remoteLandPlayed = false
    self.checkingSBA = false
    self.encounter = nil
    self.matchReward = nil
    self.bossIndex = nil
    self:ResetUndo()
    self.sentDeckCount = nil
    self.sentEffects = nil
    self.remoteState.deckCount = nil
    -- Deck size goes to the opponent once setup is done, not once per opening draw
    self.startingMatch = true

    self.localState.life = 20
    self.localState.mana = { W = 0, U = 0, B = 0, R = 0, G = 0, C = 0 }
    self.localState.hand = {}
    self.localState.field = {}
    self.localState.graveyard = {}
    self.localState.deck = {}
    self.localState.damageShield = 0
    self.localState.dots = {}
    self.localState.hots = {}
    self.localState.mirror = nil

    -- A scripted solo game (the tutorial) brings the player's deck too: encounter.playerDeck,
    -- top card first; encounter.fixedOrder keeps both decks in the order given
    local scripted = isSolo and encounter
    if scripted and scripted.playerDeck then
        for _, cardId in ipairs(scripted.playerDeck) do
            if TTS.Cards[cardId] then table.insert(self.localState.deck, cardId) end
        end
    else
        local activeDeck = TTS_SavedDecks and TTS_SavedDecks[TTS_ActiveDeckIndex] and TTS_SavedDecks[TTS_ActiveDeckIndex].cards
        if activeDeck then
            for cardId, qty in pairs(activeDeck) do
                -- Decks are shared by all characters: an alt plays only the hero copies it owns
                if TTS.Cards[cardId] and TTS.Cards[cardId].isHero then
                    qty = math.min(qty, TTS:GetOwnedCopies(TTS.Cards[cardId]) or 1)
                end
                if TTS.Cards[cardId] then
                    for _ = 1, qty do table.insert(self.localState.deck, cardId) end
                end
            end
        end
    end

    if not (scripted and scripted.fixedOrder) then
        for i = #self.localState.deck, 2, -1 do
            local j = math.random(i)
            self.localState.deck[i], self.localState.deck[j] = self.localState.deck[j], self.localState.deck[i]
        end
    end

    for _ = 1, 7 do self:DrawCard(true) end

    self.remoteState.life = 20
    self.remoteState.handCount = 0
    self.remoteState.hand = {}
    self.remoteState.deck = {}
    self.remoteState.deckCount = nil
    self.remoteState.mana = { W = 0, U = 0, B = 0, R = 0, G = 0, C = 0 }
    self.remoteState.field = {}
    self.remoteState.graveyard = {}
    self.remoteState.damageShield = 0
    self.remoteState.dots = {}
    self.remoteState.hots = {}
    self.remoteState.mirror = nil

    if self.isSolo then
        -- Every solo game is an encounter; Practice vs Dummy is the PRACTICE entry
        local enc = encounter or (TTS.SoloEncounters and TTS.SoloEncounters.PRACTICE)
        self.encounter = enc
        self.remoteState.life = enc.life or 20
        if TTS.BoardFrame and TTS.BoardFrame.SetBackground then TTS.BoardFrame:SetBackground(enc.background) end
    elseif TTS.BoardFrame and TTS.BoardFrame.ClearBackground then
        TTS.BoardFrame:ClearBackground()
    end

    if self.isSolo then
        local enc = self.encounter

        self.remoteState.deck = self:BuildEncounterDeck(enc)
        if not enc.fixedOrder then
            for i = #self.remoteState.deck, 2, -1 do
                local j = math.random(i)
                self.remoteState.deck[i], self.remoteState.deck[j] = self.remoteState.deck[j], self.remoteState.deck[i]
            end
        end

        for _ = 1, 7 do
            if #self.remoteState.deck > 0 then
                table.insert(self.remoteState.hand, table.remove(self.remoteState.deck, 1))
            end
        end
        self.remoteState.handCount = #self.remoteState.hand
    end

    if TTS.BoardFrame then TTS.BoardFrame:Show() end
    if TTS.MainFrame then TTS.MainFrame:Hide() end

    if self.isSolo then self:RunEncounterRules("onStart") end

    if self.isMyTurn then
        self:SetPhase("MAIN1")
    else
        self:SetPhase("WAITING")
    end
    self.startingMatch = false
    -- Ready check at the start of every game, whoever goes first
    PlayTurnSound()
    self:RefreshUI()
end

-- Calls one hook (onStart, onAITurnStart, onPlayerTurnStart, onCreatureDeath) of every
-- rule the current solo encounter lists. See TTS.EncounterRules in SoloEncounters.lua.
function E:RunEncounterRules(hook, ...)
    local enc = self.encounter
    if not (enc and enc.rules and TTS.EncounterRules) then return end
    for _, ruleId in ipairs(enc.rules) do
        local rule = TTS.EncounterRules[ruleId]
        if rule and rule[hook] then rule[hook](self, enc, ...) end
        if not self.inMatch then return end
    end
end

-- Most cards a hand can hold. Drawing with a full hand asks for a discard first.
local MAX_HAND_SIZE = 10

function E:DrawCard(silent)
    -- Already waiting on a discard: this draw waits its turn behind it
    if self.pendingDiscard then
        self.pendingDiscard = self.pendingDiscard + 1
        return
    end
    if #self.localState.deck == 0 then
        self:LoseMatch(L("end.deckOut"))
        return
    end
    if #self.localState.hand >= MAX_HAND_SIZE then
        self.pendingDiscard = 1
        self:CancelTargeting()
        self:Log(L("log.handFull", MAX_HAND_SIZE), "SYSTEM")
        self:RefreshUI()
        return
    end
    local cardId = table.remove(self.localState.deck, 1)
    table.insert(self.localState.hand, cardId)
    local card = TTS.Cards[cardId]
    if not silent and card then
        self:Log(L("log.drew", TTS:CardName(card)), "ACTION")
    end
    self:RefreshUI()
end

-- Draws a card for either side.
--   Local:          the normal draw (hand limit asks the player to discard).
--   Remote in solo: the AI draws from its real deck; an empty deck loses it the match,
--                   and at the hand limit it discards its least useful card first.
--   Remote in PvP:  the other client draws for itself; we only track the hand size.
function E:DrawCardFor(isRemote)
    if not isRemote then
        self:DrawCard()
        return
    end
    local st = self.remoteState
    if not self.isSolo then
        st.handCount = (st.handCount or 0) + 1
        return
    end

    if #st.deck == 0 then
        self:WinMatch(L("end.oppDeckOut", self.opponent))
        return
    end
    if #st.hand >= MAX_HAND_SIZE then
        local worstIdx, worstVal
        for i, id in ipairs(st.hand) do
            local v = self:AICardValue(id)
            if not worstVal or v < worstVal then worstIdx, worstVal = i, v end
        end
        local discarded = table.remove(st.hand, worstIdx)
        table.insert(st.graveyard, discarded)
        local dc = TTS.Cards[discarded]
        self:Log(L("log.oppDiscardFull", self.opponent, dc and TTS:CardName(dc) or discarded), "ACTION")
    end
    table.insert(st.hand, table.remove(st.deck, 1))
    st.handCount = #st.hand
    self:RefreshUI()
end

-- =========================================================================
-- CHOICES
-- Effects that let the player pick (a card to discard, a creature to return...) queue a
-- choice; the popup (UI\Choice.lua) asks them one at a time and can't be dismissed.
-- spec = { title, options = { { value, cardId?, text? }, ... }, onChoose = fn(value, option) }
-- Without the popup (headless tests) the first option is taken at once.
-- =========================================================================
function E:AskChoice(spec)
    self.choiceQueue = self.choiceQueue or {}
    table.insert(self.choiceQueue, spec)
    if #self.choiceQueue == 1 then self:ShowNextChoice() end
end

function E:ShowNextChoice()
    local spec = self.choiceQueue and self.choiceQueue[1]
    if not spec then return end
    local asked = TTS.Choice and TTS.Choice.frame and true or false
    local function Done(value, option)
        if not (self.choiceQueue and self.choiceQueue[1] == spec) then return end
        table.remove(self.choiceQueue, 1)
        if self.inMatch then
            spec.onChoose(value, option)
            -- Picked later from the popup: the effect has finished, so check for deaths now
            if asked then
                self:SyncEffects()
                self:CheckStateBasedActions()
            end
            self:RefreshUI()
        end
        self:ShowNextChoice()
        -- The last choice made: a turn waiting to end after combat can end now
        if not self:HasPendingChoice() then self:TryEndAfterCombat() end
    end
    if asked then
        TTS.Choice:Show({ title = spec.title, options = spec.options, required = true, onChoose = Done })
    else
        Done(spec.options[1].value, spec.options[1])
    end
end

function E:HasPendingChoice()
    return self.choiceQueue ~= nil and #self.choiceQueue > 0
end

-- Drops every waiting choice (the match is over)
function E:ClearChoices()
    self.choiceQueue = nil
    if TTS.Choice and TTS.Choice.Cancel then TTS.Choice:Cancel(true) end
end

-- One option per different card in ids (a hand or graveyard holds duplicates)
local function CardOptions(ids, keep)
    local options, seen = {}, {}
    for _, id in ipairs(ids) do
        if not seen[id] and (not keep or keep(id)) then
            seen[id] = true
            table.insert(options, { value = id, cardId = id })
        end
    end
    return options
end
E.CardOptions = CardOptions

-- A side discards a card of its choice (forced discards). The player picks it, the AI
-- drops its least useful card. PvP: their client discards and sends ACTION:DISCARD,
-- which updates their hand count.
function E:DiscardChosen(isRemote)
    local st = isRemote and self.remoteState or self.localState
    if isRemote and not self.isSolo then return end
    if #st.hand == 0 then return end

    local function Discard(cardId)
        local idx
        for i, id in ipairs(st.hand) do
            if id == cardId then idx = i; break end
        end
        if not idx then return end
        table.remove(st.hand, idx)
        table.insert(st.graveyard, cardId)
        if isRemote then st.handCount = #st.hand end
        local card = TTS.Cards[cardId]
        local shown = card and TTS:CardName(card) or cardId
        self:Log(isRemote and L("log.oppDiscarded", self.opponent, shown) or L("log.youDiscarded", shown), "ACTION")
        if not isRemote and not self.isSolo then TTS.Net:Send(self.opponent, "ACTION:DISCARD:" .. cardId) end
    end

    if isRemote then
        local worst, worstVal
        for _, id in ipairs(st.hand) do
            local v = self:AICardValue(id)
            if not worstVal or v < worstVal then worst, worstVal = id, v end
        end
        Discard(worst)
    else
        self:AskChoice({ title = L("choice.discard"), options = CardOptions(st.hand),
            onChoose = function(cardId) Discard(cardId) end })
    end
end

-- Discards the hand card the player clicked to make room, then makes the waiting draw(s)
function E:DiscardForDraw(handIndex)
    if not self.pendingDiscard then return end
    local cardId = table.remove(self.localState.hand, handIndex)
    if not cardId then return end

    table.insert(self.localState.graveyard, cardId)
    local card = TTS.Cards[cardId]
    self:Log(L("log.discarded", card and TTS:CardName(card) or cardId), "ACTION")
    if not self.isSolo then TTS.Net:Send(self.opponent, "ACTION:DISCARD:" .. cardId) end

    local waiting = self.pendingDiscard
    self.pendingDiscard = nil
    for _ = 1, waiting do
        if not self.inMatch then break end
        self:DrawCard()
    end
    self:RefreshUI()
end

-- =========================================================================
-- MULLIGAN
-- Once per game, before your first play, phase change or draw, the opening hand
-- can go back into the deck for a fresh one. Hand and deck sizes come out the same,
-- so the opponent's view of us doesn't change: ACTION:MULLIGAN only adds a log line
-- (builds without it ignore the message).
-- =========================================================================
local MULLIGAN_HAND_SIZE = 7

function E:CloseMulligan()
    self.mulliganOpen = nil
end

-- Whether the mulligan button can be used now. Returns ok, reason (reason when not ok).
function E:CanMulligan()
    if not self.inMatch then return false end
    if not self.mulliganOpen then return false, L("mulligan.closed") end
    if self.targeting then return false, L("undo.targeting") end
    if self.pendingDiscard then return false, L("undo.discard") end
    if self.undo and self.undo.pending then return false, L("undo.waiting", self.opponent or L("undo.yourOpponent")) end
    return true
end

function E:Mulligan()
    if not self:CanMulligan() then return end
    self:CloseMulligan()

    local st = self.localState
    for i = #st.hand, 1, -1 do
        table.insert(st.deck, table.remove(st.hand, i))
    end
    for i = #st.deck, 2, -1 do
        local j = math.random(i)
        st.deck[i], st.deck[j] = st.deck[j], st.deck[i]
    end
    for _ = 1, math.min(MULLIGAN_HAND_SIZE, #st.deck) do
        table.insert(st.hand, table.remove(st.deck, 1))
    end

    self:Log(L("log.mulligan", MULLIGAN_HAND_SIZE), "ACTION")
    if not self.isSolo then TTS.Net:Send(self.opponent, "ACTION:MULLIGAN") end
    self:RefreshUI()
end

StaticPopupDialogs["TTS_MULLIGAN"] = {
    text = "%s",
    button1 = YES or "Yes",
    button2 = NO or "No",
    OnAccept = function() E:Mulligan() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function E:ConfirmMulligan()
    if not self:CanMulligan() then return end
    StaticPopup_Show("TTS_MULLIGAN", L("mulligan.confirm", MULLIGAN_HAND_SIZE))
end

-- Phase as shown to the player (phase.<ID>; the ID itself when no translation exists)
function E:PhaseName(phase)
    return TTS.Locale:Data("phase." .. tostring(phase), phase)
end

function E:SetPhase(newPhase)
    self.phase = newPhase
    if self.isMyTurn and newPhase ~= "MAIN1" then self:CloseMulligan() end
    if TTS.BoardFrame and TTS.BoardFrame.phaseText then
        if self.targeting then
            TTS.BoardFrame.phaseText:SetText("|cFFFFD200" .. L("phase.targeting") .. "|r")
        elseif self.phase == "COMBAT_BLOCK" then
            if self.blockingState and self.blockingState.isRemoteAttacking then
                TTS.BoardFrame.phaseText:SetText("|cFFFF4444" .. L("phase.selectBlockers") .. "|r")
            else
                TTS.BoardFrame.phaseText:SetText("|cFFFFD200" .. L("phase.blockersDeclared") .. "|r")
            end
        else
            TTS.BoardFrame.phaseText:SetText(L("phase.label", E:PhaseName(newPhase)))
        end
    end
end

function E:RefreshUI()
    -- PvP: the opponent's board shows how many cards are left in our deck
    self:SyncDeckCount()
    if TTS.BoardFrame and TTS.BoardFrame:IsShown() then
        TTS.BoardFrame:UpdateDisplay()
    end
end