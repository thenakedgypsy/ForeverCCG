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
-- CARD TOASTS
-- A card found out in the world (a copy from a kill, Systems\BossTracker.lua; a foil; an
-- NPC's gift, UI\NpcGossip.lua) slides in face down, turns over with a flash in its colour
-- and the creature's voice, and shows what it is: "Card Found!", "Rare Card!", "Boss Card!"
-- or "Foil Card!", its name, cost and how many copies are now owned. Toasts wait while the
-- player is in combat and come one after another.
-- Hovering one holds it (up to HOVER_MAX seconds, so it always times out) and shows the
-- card's tooltip; clicking it opens the card's preview (shift-click links it); right-click or
-- its X dismisses it; dragging it moves it, and it stays where it's put (toastPos).
-- Settings (UI\Options.lua, Card Pop-ups): cardToasts (on/off), toastTier (which cards: "all",
-- "rare" kinds and up, or "big": foils and boss cards), toastSound, toastHoverHold,
-- toastDuration (seconds, foils and boss cards BIG_EXTRA more), toastScale, toastPos.
--
-- GUILD SHOUT-OUTS
-- A foil, or the first copy of a boss card, is told to the guild (CARD_SHOUT:<id>:<F|C>,
-- Core\Network.lua's BroadcastGuild): guildmates with the add-on see a chat line with the
-- card's link. Sending and showing both follow the guildShouts option.
-- =========================================================================
local T = {}
TTS.CardToast = T

local TEXTURE_ROOT = "Interface\\AddOns\\ForeverCCG\\Textures\\"
local CARD_BACK = TEXTURE_ROOT .. "Cards\\card_back.png"
local GLOW_TEX = TEXTURE_ROOT .. "FoilGlow.tga"   -- the card fills its middle 192 of 256 px
local GLOW_PAD = 32 / 192

local W, H = 320, 168
local CARD_SCALE = 0.62
local DEFAULT_X, DEFAULT_Y = -40, 140   -- its right edge from the screen's, and its middle above the screen's
local SLIDE_FROM = 160                  -- how far right it starts, sliding in (and fading in)
local SLIDE_IN = 0.35
local FLIP_AT = 0.45                    -- when the card starts to turn over
local FLIP_TIME = 0.13                  -- its back narrowing to edge-on
local TURNED = FLIP_AT + FLIP_TIME
local POP_TIME = 0.22
local BURST_TIME = 0.6
local DEFAULT_DURATION = 6              -- seconds it stays once turned (toastDuration)
local BIG_EXTRA = 2                     -- foils and boss cards stay this much longer
local HOVER_MAX = 10                    -- the most a hover holds it, in all
local FADE_OUT = 0.5
local SHOUT_DEDUPE = 60                 -- seconds a guildmate's same shout is shown once

local TIER_HEADER = {
    normal = { key = "toast.normal", rgb = { 1.00, 0.82, 0.00 } },
    rare   = { key = "toast.rare",   rgb = { 0.64, 0.21, 0.93 } },
    boss   = { key = "toast.boss",   rgb = { 1.00, 0.50, 0.00 } },
}

local queue = {}
local current
local F
local shoutsSeen = {}

local function Opt(key)
    return not TTS.Options or TTS.Options:Get(key) ~= false
end

local function Num(key, default)
    return TTS.Options and tonumber(TTS.Options:Get(key)) or default
end

local function OutCubic(p) return 1 - (1 - p) ^ 3 end

local function InCombat()
    return (InCombatLockdown and InCombatLockdown()) or (UnitAffectingCombat and UnitAffectingCombat("player")) or false
end

-- Which cards pop up (toastTier): "all", "rare" or "big"
function T:TierSetting()
    local v = TTS.Options and TTS.Options:Get("toastTier")
    return (v == "rare" or v == "big") and v or "all"
end

-- Whether a card of this tier (foil or not) pops up, by the settings
local function Wanted(tier, foil)
    if not Opt("cardToasts") then return false end
    local setting = T:TierSetting()
    if setting == "big" then return foil or tier == "boss" end
    if setting == "rare" then return foil or tier ~= "normal" end
    return true
end

local function IsBig(c) return c.foil or c.tier == "boss" end

-- Seconds from its start until it begins to fade (without a hover's hold)
local function FadeAt(c)
    return TURNED + math.max(1, Num("toastDuration", DEFAULT_DURATION)) + (IsBig(c) and BIG_EXTRA or 0)
end

-- =========================================================================
-- PLACE AND SIZE
-- =========================================================================
-- Puts the toast where it belongs, `slide` pixels (screen units) right of it
local function Place(slide)
    local scale = math.max(0.3, Num("toastScale", 1))
    F:SetScale(scale)
    local pos = TTS.Options and TTS.Options:Get("toastPos")
    local x, y = DEFAULT_X, DEFAULT_Y
    if type(pos) == "table" and tonumber(pos.x) and tonumber(pos.y) then x, y = pos.x, pos.y end
    F:ClearAllPoints()
    -- (offsets are in the toast's own scale; the saved ones are in the screen's)
    F:SetPoint("RIGHT", UIParent, "RIGHT", (x + (slide or 0)) / scale, y / scale)
end

-- The size or place changed in Settings: a toast showing follows
function T:ApplyPlacement()
    if F and F:IsShown() and not F.dragging then Place(0) end
end

-- Back to the screen's right edge
function T:ResetPosition()
    if TTS.Options then TTS.Options:Set("toastPos", nil) end
    self:ApplyPlacement()
end

-- Where it was dragged to, kept as its right edge and middle from the screen's (screen units)
local function SavePosition()
    local right, top, bottom = F:GetRight(), F:GetTop(), F:GetBottom()
    if not (right and top and bottom) then return end
    local k = F:GetEffectiveScale() / UIParent:GetEffectiveScale()
    local x = right * k - UIParent:GetWidth()
    local y = (top + bottom) / 2 * k - UIParent:GetHeight() / 2
    if TTS.Options then TTS.Options:Set("toastPos", { x = math.floor(x + 0.5), y = math.floor(y + 0.5) }) end
end

-- =========================================================================
-- THE TOAST FRAME (made the first time one shows: the card factory is in UI\Board.lua)
-- =========================================================================
local function Build()
    if F then return F end
    F = CreateFrame("Button", "TTS_CardToast", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    F:SetSize(W, H)
    F:SetFrameStrata("HIGH")
    F:SetClampedToScreen(true)
    F:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    F:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    F:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    F:SetMovable(true)
    F:RegisterForDrag("LeftButton")
    F.ttsSilent = true
    F:Hide()

    local cw, ch = TTS.PREVIEW_W * CARD_SCALE, TTS.PREVIEW_H * CARD_SCALE
    local holder = CreateFrame("Frame", nil, F)
    holder:SetSize(cw, ch)
    holder:SetPoint("LEFT", F, "LEFT", 16, 0)
    F.holder = holder

    -- A burst of glow behind the card as it turns over
    F.glow = holder:CreateTexture(nil, "BACKGROUND")
    F.glow:SetTexture(GLOW_TEX)
    F.glow:SetBlendMode("ADD")
    F.glow:SetPoint("TOPLEFT", holder, "TOPLEFT", -cw * GLOW_PAD, ch * GLOW_PAD)
    F.glow:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", cw * GLOW_PAD, -ch * GLOW_PAD)
    F.glow:Hide()

    F.back = holder:CreateTexture(nil, "ARTWORK")
    F.back:SetTexture(CARD_BACK)
    F.back:SetPoint("CENTER")
    F.back:SetSize(cw, ch)

    F.card = TTS.CreateCardFrame(holder, TTS.PREVIEW_W, TTS.PREVIEW_H)
    F.card:SetScale(CARD_SCALE)
    F.card:ClearAllPoints()
    F.card:SetPoint("CENTER", holder, "CENTER")
    F.card:EnableMouse(false)
    F.card:SetScript("OnEnter", nil)
    F.card:SetScript("OnLeave", nil)
    F.card:Hide()

    local over = CreateFrame("Frame", nil, holder)
    over:SetAllPoints()
    over:SetFrameLevel(F.card:GetFrameLevel() + 10)
    F.flash = over:CreateTexture(nil, "OVERLAY")
    F.flash:SetColorTexture(1, 1, 1, 1)
    F.flash:SetBlendMode("ADD")
    F.flash:SetAllPoints()
    F.flash:Hide()

    local textLeft = 16 + cw + 14
    F.header = F:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    F.header:SetPoint("TOPLEFT", F, "TOPLEFT", textLeft, -22)
    F.header:SetPoint("RIGHT", F, "RIGHT", -24, 0)
    F.header:SetJustifyH("LEFT")

    F.name = F:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    F.name:SetPoint("TOPLEFT", F.header, "BOTTOMLEFT", 0, -8)
    F.name:SetPoint("RIGHT", F, "RIGHT", -14, 0)
    F.name:SetJustifyH("LEFT")
    F.name:SetWordWrap(true)

    F.cost = F:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    F.cost:SetPoint("TOPLEFT", F.name, "BOTTOMLEFT", 0, -6)
    F.cost:SetJustifyH("LEFT")

    F.sub = F:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    F.sub:SetPoint("TOPLEFT", F.cost, "BOTTOMLEFT", 0, -8)
    F.sub:SetPoint("RIGHT", F, "RIGHT", -14, 0)
    F.sub:SetJustifyH("LEFT")

    local close = CreateFrame("Button", nil, F, "UIPanelCloseButton")
    close:SetSize(24, 24)
    close:SetPoint("TOPRIGHT", F, "TOPRIGHT", -2, -2)
    close:SetScript("OnClick", function() T:Dismiss() end)

    F:SetScript("OnClick", function(self, btn)
        local c = current
        if not c then return end
        if btn == "RightButton" then T:Dismiss(); return end
        if TTS:TryLinkCard(c.card.id, c.foil) then return end
        if TTS.ShowCardPreview then TTS:ShowCardPreview(c.card.id, c.foil) end
    end)
    -- Dragged: it moves (its slide-in is cut short) and stays where it's dropped
    F:SetScript("OnDragStart", function(self)
        self.dragging = true
        if current then current.slid = true end
        Place(0)
        self:StartMoving()
    end)
    F:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.dragging = nil
        SavePosition()
        Place(0)
    end)
    F:SetScript("OnEnter", function(self)
        local c = current
        if c and c.revealed and c.card and TTS.Tooltip then
            TTS.Tooltip:ShowCard(self, "ANCHOR_LEFT", c.card.id, { foil = c.foil })
        end
    end)
    F:SetScript("OnLeave", function(self) if TTS.Tooltip then TTS.Tooltip:Hide(self) end end)
    -- A broken toast (an error painting it) closes rather than staying up
    F:SetScript("OnUpdate", function(self, dt)
        local ok, err = pcall(T.Tick, T, dt)
        if not ok then
            current = nil
            self:StopMovingOrSizing()
            self.dragging = nil
            self:Hide()
            if geterrorhandler then geterrorhandler()(err) end
            T:Next()
        end
    end)
    if TTS.Sound and TTS.Sound.HookButtons then TTS.Sound:HookButtons(F) end
    return F
end

-- The card's colour (as its foil glow has it), for the flash and a foil's header
local function CardRGB(card)
    local colors = TTS.FoilColors and TTS.FoilColors(card)
    return colors and colors[1] or { 1, 0.82, 0 }
end

-- Fills the toast for entry c, face down
local function Paint(c)
    local card = c.card
    F.back:SetWidth(F.holder:GetWidth())
    F.back:Show()
    F.card:Hide()
    F.card:SetScale(CARD_SCALE)
    F.glow:Hide()
    F.flash:Hide()
    if c.foil then
        local rgb = CardRGB(card)
        F.header:SetText(L("toast.foil"))
        F.header:SetTextColor(rgb[1], rgb[2], rgb[3])
    else
        local h = TIER_HEADER[c.tier] or TIER_HEADER.normal
        F.header:SetText(L(h.key))
        F.header:SetTextColor(h.rgb[1], h.rgb[2], h.rgb[3])
    end
    F.name:SetText(TTS:CardName(card) or card.id)
    F.cost:SetText((card.cost and card.cost ~= "") and TTS:FormatCost(card.cost, 16) or "")
    if c.foil then
        F.sub:SetText(L("toast.foilSub"))
        F.sub:SetTextColor(1, 0.82, 0)
    elseif (c.copies or 0) <= 1 then
        F.sub:SetText(L("toast.new"))
        F.sub:SetTextColor(0.2, 0.87, 0.2)
    else
        F.sub:SetText(L("toast.copies", math.min(4, c.copies)))
        F.sub:SetTextColor(0.8, 0.8, 0.8)
    end
end

-- The card turns face up: flash, glow burst, sounds
local function Reveal(c)
    c.revealed = true
    F.back:Hide()
    TTS.PaintPreviewCard(F.card, c.card, c.foil)
    -- (its name and cost are in the toast's text)
    F.card.title:Hide()
    F.card.cost:Hide()
    local rgb = CardRGB(c.card)
    F.flash:SetVertexColor(rgb[1], rgb[2], rgb[3])
    F.glow:SetVertexColor(rgb[1], rgb[2], rgb[3])
    F.flash:Show()
    F.glow:Show()
    if TTS.Sound and Opt("toastSound") then
        if IsBig(c) then
            TTS.Sound:PlayUI("foilCard")
        elseif c.tier == "rare" then
            TTS.Sound:PlayUI("rareCard")
        else
            TTS.Sound:PlayUI("deckCard")
        end
        if TTS.Sound.QueueCreature then TTS.Sound:QueueCreature("aggro", c.card.id) end
    end
    if F:IsMouseOver() and TTS.Tooltip then
        TTS.Tooltip:ShowCard(F, "ANCHOR_LEFT", c.card.id, { foil = c.foil })
    end
end

function T:Tick(dt)
    local c = current
    if not c then F:Hide(); return end
    local fadeAt = FadeAt(c)
    -- Held while the mouse is over it once it has turned (toastHoverHold), but never for
    -- more than HOVER_MAX seconds in all, and not while it's fading or dismissed
    local holding = Opt("toastHoverHold") and not c.dismissed and c.t >= TURNED and c.t < fadeAt
        and (c.held or 0) < HOVER_MAX and (F:IsMouseOver() or F.dragging)
    if holding then
        c.held = (c.held or 0) + dt
    else
        c.t = c.t + dt
    end
    if c.dismissed and c.t < fadeAt then c.t = fadeAt end
    local t = c.t

    -- Slides and fades in from the right (unless it has been dragged)
    if not c.slid and not F.dragging then
        local p = math.min(1, t / SLIDE_IN)
        Place(SLIDE_FROM * (1 - OutCubic(p)))
        if p >= 1 then c.slid = true end
    end

    -- Turns over: the back narrows to edge-on, then the face pops up
    if t >= FLIP_AT and not c.revealed then
        local p = math.min(1, (t - FLIP_AT) / FLIP_TIME)
        F.back:SetWidth(math.max(1, F.holder:GetWidth() * (1 - p * p)))
        if p >= 1 then Reveal(c) end
    end
    if c.revealed and F.card:IsShown() then
        local since = math.max(0, t - TURNED)
        local pop = math.min(1, since / POP_TIME)
        F.card:SetScale(CARD_SCALE * (1.12 - 0.12 * OutCubic(pop)))
        local burst = math.min(1, since / BURST_TIME)
        F.flash:SetAlpha(0.6 * (1 - burst))
        F.glow:SetAlpha(1 - burst)
        if burst >= 1 then F.flash:Hide(); F.glow:Hide() end
    end

    -- Fades in, stays, fades away, then the next one
    if t >= fadeAt then
        local p = math.min(1, (t - fadeAt) / FADE_OUT)
        F:SetAlpha(1 - p)
        if p >= 1 then
            current = nil
            if F.dragging then F:StopMovingOrSizing(); F.dragging = nil; SavePosition() end
            F:Hide()
            F:SetAlpha(1)
            if TTS.Tooltip then TTS.Tooltip:Hide(F) end
            self:Next()
        end
    else
        F:SetAlpha(math.min(1, t / SLIDE_IN))
    end
end

-- Starts the next toast waiting, unless one is showing or the player is fighting
function T:Next()
    if current or #queue == 0 or InCombat() then return end
    if not (TTS.CreateCardFrame and TTS.PaintPreviewCard) then return end
    Build()
    current = table.remove(queue, 1)
    current.t = 0
    Paint(current)
    Place(SLIDE_FROM)
    F:SetAlpha(0)
    F:Show()
end

-- The showing toast fades away now (right-click, or its close button)
function T:Dismiss()
    local c = current
    if not c then return end
    c.dismissed = true
    if not c.revealed then c.revealed = true end   -- (gone before it turned: no reveal sounds)
end

-- Queues a toast: tier "normal", "rare" or "boss", foil, copies (owned now). force: shown
-- whatever the settings say which cards pop up (the test commands)
function T:Show(card, tier, foil, copies, force)
    if not card then return end
    if not force and not Wanted(tier, foil) then return end
    table.insert(queue, { card = card, tier = tier or "normal", foil = foil and true or false, copies = copies })
    self:Next()
end

local function Tier(card)
    return TTS.BossTracker and TTS.BossTracker.CardTier and TTS.BossTracker:CardTier(card) or "normal"
end

-- =========================================================================
-- FROM BossTracker.lua AND NpcGossip.lua
-- =========================================================================
-- A copy of a card was found (copies: how many are owned now). A boss card's first copy is
-- told to the guild.
function T:OnCopy(card, copies)
    local tier = Tier(card)
    self:Show(card, tier, false, copies)
    if tier == "boss" and copies == 1 then self:Shout(card, false) end
end

-- A foil was found: its toast and the guild's shout-out. Returns true when a toast shows it
-- (BossTracker's center-screen line is left out then).
function T:OnFoil(card)
    self:Shout(card, true)
    if not Wanted(Tier(card), true) then return false end
    self:Show(card, Tier(card), true)
    return true
end

-- =========================================================================
-- GUILD SHOUT-OUTS
-- =========================================================================
function T:Shout(card, foil)
    if not (card and Opt("guildShouts") and TTS.Net and TTS.Net.BroadcastGuild) then return end
    TTS.Net:BroadcastGuild("CARD_SHOUT:" .. card.id .. ":" .. (foil and "F" or "C"))
end

-- CARD_SHOUT:<id>:<F|C> from a guildmate (Core\Network.lua)
function T:OnShout(message, sender)
    if not Opt("guildShouts") then return end
    local id, kind = message:match("^CARD_SHOUT:([%w_]+):([FC])$")
    local card = id and TTS.Cards and TTS.Cards[id]
    if not (card and sender and sender ~= "") then return end
    local key = sender .. ":" .. id .. ":" .. kind
    local now = GetTime()
    if shoutsSeen[key] and now - shoutsSeen[key] < SHOUT_DEDUPE then return end
    shoutsSeen[key] = now
    local who = "|cFF40FF40" .. (Ambiguate and Ambiguate(sender, "none") or sender) .. "|r"
    local link = TTS.CardLink and TTS:CardLink(id, kind == "F") or TTS:CardName(card)
    DEFAULT_CHAT_FRAME:AddMessage(L(kind == "F" and "toast.shoutFoil" or "toast.shoutBoss", who, link))
end

-- =========================================================================
-- TEST COMMANDS (/tragic toast ..., UI\MainFrame.lua; Settings' Test button). Nothing is
-- added to the collection, and they show whatever the "which cards" setting says.
--   /tragic toast              a random card of any kind
--   /tragic toast normal|rare|boss|foil
--   /tragic toast all          one of each, queued one after another
--   /tragic toast <cardId>     that card (<cardId>F: as its foil), e.g. /tragic toast BOSS02F
--   /tragic toast combat       a card, held until you leave combat (start a fight first)
--   /tragic toast reset        puts the pop-up back at the screen's right edge
--   /tragic toast shout        the guild shout-out lines, shown to you only
--   /tragic toast shoutsend    a real foil shout-out to your guild (guildmates see it)
-- =========================================================================
local function SampleCard(tier)
    local list = {}
    for _, card in pairs(TTS.Cards or {}) do
        if type(card) == "table" and card.type == "Creature" and not card.isToken
            and (tier == nil or Tier(card) == tier) then
            list[#list + 1] = card
        end
    end
    if #list == 0 then return nil end
    return list[math.random(#list)]
end

local function Say(text) DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD200[TTSE]|r " .. text) end

function T:SlashCommand(arg)
    arg = (arg or ""):trim()
    local low = arg:lower()
    local function Toast(tier, foil, copies)
        local card = SampleCard(tier) or SampleCard(nil)
        if not card then Say("No card to show."); return end
        self:Show(card, Tier(card), foil, copies or math.random(1, 4), true)
    end
    if not Opt("cardToasts") and low ~= "reset" and not low:match("^shout") then
        Say("Card pop-ups are off in Settings.")
        return
    end
    if low == "" then
        Toast(nil)
    elseif low == "normal" or low == "rare" then
        Toast(low)
    elseif low == "boss" then
        Toast("boss", false, 1)
    elseif low == "foil" then
        Toast("rare", true)
    elseif low == "all" then
        Toast("normal"); Toast("rare"); Toast("boss", false, 1); Toast("rare", true)
    elseif low == "combat" then
        Toast(nil)
        if InCombat() then Say("Queued: it shows when you leave combat.") end
    elseif low == "reset" then
        self:ResetPosition()
        Say("The card pop-up is back at the right edge of the screen.")
    elseif low == "shout" then
        local me = UnitName("player") or "You"
        local foilCard, bossCard = SampleCard("rare"), SampleCard("boss")
        shoutsSeen = {}
        if foilCard then self:OnShout("CARD_SHOUT:" .. foilCard.id .. ":F", me) end
        if bossCard then self:OnShout("CARD_SHOUT:" .. bossCard.id .. ":C", me) end
        if not Opt("guildShouts") then Say("Guild shout-outs are off in Settings.") end
    elseif low == "shoutsend" then
        local card = SampleCard("rare")
        if not (IsInGuild and IsInGuild()) then Say("You're not in a guild."); return end
        if not Opt("guildShouts") then Say("Guild shout-outs are off in Settings."); return end
        if card then
            self:Shout(card, true)
            Say("Sent a test foil shout-out for " .. (TTS:CardLink(card.id, true) or card.id) .. " to your guild.")
        end
    else
        local up = arg:upper()
        local id, foil = up:match("^([%w_]-)(F?)$")
        local card = id and TTS.Cards[id]
        if not card and foil == "F" then card = TTS.Cards[up]; foil = "" end   -- an id that ends in F
        if not card then Say("No card with the id " .. arg .. "."); return end
        self:Show(card, Tier(card), foil == "F", math.random(1, 4), true)
    end
end

-- Toasts held back during a fight show once it's over
local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_REGEN_ENABLED")
watcher:SetScript("OnEvent", function() T:Next() end)
