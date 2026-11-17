--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
local L = TTS.L
local Loc = TTS.Locale

-- =========================================================================
-- PACK OPENER
-- Opening the booster packs of Systems\Packs.lua. Down the left the kinds of pack and
-- how many of each the player has, on the right what the chosen kind holds. Opening:
-- the pack shakes and tears open (its _closed art swaps for _ripped), its cards fly out
-- face down and land in a row beneath it, and each click turns one over. When every card
-- is face up, another pack of the same kind can be opened.
-- Opened from the main window's Open Packs button (MainFrame.lua), or /tragic pack.
-- One driver frame runs every animation (Tween): a step(p) per frame for p 0..1, then
-- done(). Closing the window mid-way plays them all to their end at once, silently.
-- =========================================================================
local O = {}
TTS.PackOpener = O
local P = TTS.Packs

local TEXTURE_ROOT = "Interface\\AddOns\\ForeverCCG\\Textures\\"
local CARD_BACK = TEXTURE_ROOT .. "Cards\\card_back.png"
local GLOW_TEX = TEXTURE_ROOT .. "FoilGlow.tga"   -- the card fills its middle 192 of 256 px
local GLOW_PAD = 32 / 192

local W, H = 880, 680
local HEADER_H, LOGO_H = 40, 38
-- The pack art is 380 x 670: the closed pack's body starts 140 px down (the ripped one's
-- torn-off top sits above it there), the ripped pack opens at 182 px down
local ART_W, ART_H = 380, 670
local PACK_SCALE = 0.42
local PACK_W, PACK_H = ART_W * PACK_SCALE, ART_H * PACK_SCALE
local PACK_TOP = -46
local BODY_TOP = 140 * PACK_SCALE
local MOUTH_Y = PACK_TOP - 182 * PACK_SCALE
local SIDE_W = 250                    -- the pack list (left) and the pack's contents (right)
local CARD_GAP = 16
local CARD_Y                          -- the middle of the row of cards (set in Build)

local GOLD = "|cFFFFD200"
local GOLD_RGB = { 1.00, 0.82, 0.00 }

local F, UI
local selected = "dungeon"
local state = "idle"                  -- idle, opening, dealing, revealing, done
local contents                        -- this pack's cards (Packs:Roll)
local slots = {}
local quiet = false                   -- fast-forwarding: no sounds

local function Sound(name)
    if not quiet and TTS.Sound and TTS.Sound.PlayUI then TTS.Sound:PlayUI(name) end
end

-- =========================================================================
-- TWEENS
-- =========================================================================
local tweens = {}
local driver = CreateFrame("Frame")
driver:Hide()

local function Tween(dur, step, done, delay)
    tweens[#tweens + 1] = { start = GetTime() + (delay or 0), dur = dur, step = step, done = done }
    driver:Show()
end

driver:SetScript("OnUpdate", function()
    local now = GetTime()
    for i = #tweens, 1, -1 do
        local t = tweens[i]
        if t and now >= t.start then
            local p = math.min(1, (now - t.start) / t.dur)
            if t.step then t.step(p) end
            if p >= 1 then
                table.remove(tweens, i)
                if t.done then t.done() end
            end
        end
    end
    if #tweens == 0 then driver:Hide() end
end)

-- Plays every tween to its end now (and any they start), without sounds
local function FinishTweens()
    quiet = true
    local guard = 0
    while #tweens > 0 and guard < 500 do
        guard = guard + 1
        local t = table.remove(tweens, 1)
        if t.step then t.step(1) end
        if t.done then t.done() end
    end
    quiet = false
    driver:Hide()
end

local function OutCubic(p) return 1 - (1 - p) ^ 3 end
local function OutBack(p)
    local c = 1.6
    return 1 + (c + 1) * (p - 1) ^ 3 + c * (p - 1) ^ 2
end

-- =========================================================================
-- LAYOUT HELPERS
-- =========================================================================
local function SlotX(i)
    return W / 2 + (i - (P.PACK_SIZE + 1) / 2) * (TTS.PREVIEW_W + CARD_GAP)
end

local function PlacePack(dx, dy)
    F.pack:ClearAllPoints()
    F.pack:SetPoint("TOP", F, "TOP", dx or 0, PACK_TOP + (dy or 0))
end

local function PlaceSlot(s, x, y, scale)
    local cw, ch = TTS.PREVIEW_W * scale, TTS.PREVIEW_H * scale
    s:ClearAllPoints()
    s:SetPoint("CENTER", F, "TOPLEFT", x, y)
    s:SetSize(math.max(1, cw), math.max(1, ch))
    s.glow:ClearAllPoints()
    s.glow:SetPoint("TOPLEFT", s, "TOPLEFT", -cw * GLOW_PAD, ch * GLOW_PAD)
    s.glow:SetPoint("BOTTOMRIGHT", s, "BOTTOMRIGHT", cw * GLOW_PAD, -ch * GLOW_PAD)
end

-- The back's width as it turns (1 = flat on the table, 0 = edge on)
local function SetBackWidth(s, share)
    s.back:ClearAllPoints()
    s.back:SetPoint("CENTER")
    s.back:SetSize(math.max(0.5, s:GetWidth() * share), s:GetHeight())
end

local function PackArt(t, ripped)
    F.packTex:SetTexture(ripped and t.ripped or t.closed)
end

-- =========================================================================
-- SLOTS (one per card in a pack)
-- =========================================================================
-- The card's own colour, as its foil glow on the board has it (Board.lua's FoilColors:
-- the first of a two-colour card's spheres, gold for colourless)
local function SlotColor(entry)
    local colors = TTS.FoilColors and TTS.FoilColors(entry.card)
    return colors and colors[1] or GOLD_RGB
end

local function ShowSlotLabel(s)
    local entry = s.entry
    if not entry then s.label:SetText("") s.sub:SetText("") return end
    local kind = L("packs.kind." .. entry.kind)
    if s.faceUp then
        local c = SlotColor(entry)
        s.label:SetText(entry.foil and (kind .. " - " .. L("packs.foil")) or kind)
        s.label:SetTextColor(c[1], c[2], c[3])
        -- New: none before this pack (its copy went in as it opened, Packs:Open)
        local owned = TTS:GetOwnedCopies(entry.card) or 0
        if (entry.ownedBefore or owned) == 0 then
            s.sub:SetText("|cFF33DD33" .. L("packs.new") .. "|r")
        else
            s.sub:SetText(L("packs.copies", math.min(owned, 4)))
        end
    elseif entry.guaranteed then
        -- (face down: gold, so the label doesn't give the card's colour away)
        s.label:SetText(kind)
        s.label:SetTextColor(GOLD_RGB[1], GOLD_RGB[2], GOLD_RGB[3])
        s.sub:SetText(L("packs.guaranteed"))
    else
        s.label:SetText("")
        s.sub:SetText("")
    end
end

local function UpdateButtons() end   -- (defined below)

local function Flip(s)
    if s.faceUp or s.flipping or state ~= "revealing" then return end
    s.flipping = true
    s.glow:Hide()
    PlaceSlot(s, s.x, s.y, 1)
    Sound("deckCard")
    -- A foil: tell everyone around, then cheer (sent from the click, as chat likes it). The
    -- tag links the foil ("#<id>F", CardLinks.lua): clicking it shows the foil version.
    if s.entry.foil and TTS.Dialog then
        local card = s.entry.card
        local tag = TTS.CardTag and TTS:CardTag(card.id, true) or TTS:CardName(card)
        TTS.Dialog:SendEmote(L("emote.packFoil", tag, P:Name(selected)))
        TTS.Dialog:DoEmote("CHEER", 0.5)
    end
    -- Turns edge on, then the face pops up with a flash in the card's colour
    Tween(0.13, function(p)
        SetBackWidth(s, 1 - p * p)
    end, function()
        s.back:Hide()
        TTS.PaintPreviewCard(s.face, s.entry.card, s.entry.foil)
        s.face:SetAlpha(1)
        s.faceUp = true
        ShowSlotLabel(s)
        local c = SlotColor(s.entry)
        s.flash:SetVertexColor(c[1], c[2], c[3])
        s.flash:SetAlpha(0.6)
        s.flash:Show()
        -- A burst of glow that fades away: only a foil keeps one (its own, Board.lua's)
        s.glow:SetVertexColor(c[1], c[2], c[3])
        s.glow:SetAlpha(1)
        s.glow:Show()
        if not quiet and TTS.Sound and TTS.Sound.QueueCreature then
            TTS.Sound:QueueCreature("aggro", s.entry.card.id)
        end
        Tween(0.22, function(p)
            s.face:SetScale(1.12 - 0.12 * OutCubic(p))
        end)
        Tween(0.6, function(p)
            s.flash:SetAlpha(0.6 * (1 - p))
            s.glow:SetAlpha(1 - p)
        end, function()
            s.flash:Hide()
            s.glow:Hide()
            s.flipping = false
            local allUp = true
            for _, other in ipairs(slots) do
                if other.entry and not other.faceUp then allUp = false end
            end
            if allUp then
                state = "done"
                UpdateButtons()
            end
        end)
    end)
end

local function MakeSlot(i)
    local s = CreateFrame("Button", nil, F)
    s:SetFrameLevel(F:GetFrameLevel() + 20 + i * 4)
    s:RegisterForClicks("LeftButtonUp")
    s.index = i

    s.glow = s:CreateTexture(nil, "BACKGROUND")
    s.glow:SetTexture(GLOW_TEX)
    s.glow:SetBlendMode("ADD")
    s.glow:Hide()

    s.back = s:CreateTexture(nil, "ARTWORK")
    s.back:SetTexture(CARD_BACK)

    s.face = TTS.CreateCardFrame(s, TTS.PREVIEW_W, TTS.PREVIEW_H)
    s.face:ClearAllPoints()
    s.face:SetPoint("CENTER")
    s.face:EnableMouse(false)
    s.face:SetScript("OnEnter", nil)
    s.face:SetScript("OnLeave", nil)
    s.face:Hide()

    local over = CreateFrame("Frame", nil, s)
    over:SetAllPoints()
    over:SetFrameLevel(s:GetFrameLevel() + 3)
    s.flash = over:CreateTexture(nil, "OVERLAY")
    s.flash:SetColorTexture(1, 1, 1, 1)
    s.flash:SetBlendMode("ADD")
    s.flash:SetAllPoints()
    s.flash:Hide()

    s.x, s.y = SlotX(i), CARD_Y
    local labelY = CARD_Y - TTS.PREVIEW_H / 2 - 6
    s.label = F:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    s.label:SetPoint("TOP", F, "TOPLEFT", s.x, labelY)
    s.sub = F:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    s.sub:SetPoint("TOP", s.label, "BOTTOM", 0, -2)

    s:SetScript("OnEnter", function(self)
        if state == "revealing" and not self.faceUp and not self.flipping then
            self.glow:SetVertexColor(1, 0.82, 0)
            self.glow:SetAlpha(0.9)
            self.glow:Show()
            PlaceSlot(self, self.x, self.y + 6, 1)
            SetBackWidth(self, 1)
        end
    end)
    s:SetScript("OnLeave", function(self)
        if not self.faceUp and not self.flipping then
            self.glow:Hide()
            if state == "revealing" then
                PlaceSlot(self, self.x, self.y, 1)
                SetBackWidth(self, 1)
            end
        end
    end)
    s:SetScript("OnClick", Flip)
    s:Hide()
    return s
end

local function ResetSlots()
    for _, s in ipairs(slots) do
        s:Hide()
        s.entry, s.faceUp, s.flipping = nil, false, false
        s.face:Hide()
        s.face:SetScale(1)
        s.back:Show()
        s.back:SetAlpha(1)
        s.glow:Hide()
        s.flash:Hide()
        s.label:SetText("")
        s.sub:SetText("")
    end
end

-- =========================================================================
-- OPENING
-- =========================================================================
local Refresh

-- The cards come out of the pack's torn top one after another, rise over it and land
-- in their places in a row beneath it
local function Deal()
    state = "dealing"
    local x0, y0 = W / 2, MOUTH_Y
    local n = #contents
    for i, entry in ipairs(contents) do
        local s = slots[i]
        s.entry = entry
        local x2, y2 = s.x, s.y
        local x1, y1 = W / 2 + (x2 - W / 2) * 0.45, PACK_TOP + 30   -- over the pack
        Tween(0.6, function(p)
            local e = OutCubic(p)
            local u = 1 - e
            local x = u * u * x0 + 2 * u * e * x1 + e * e * x2
            local y = u * u * y0 + 2 * u * e * y1 + e * e * y2
            PlaceSlot(s, x, y, 0.2 + 0.8 * OutBack(p))
            SetBackWidth(s, 1)
            s:SetAlpha(math.min(1, p * 6))
            if not s:IsShown() then s:Show() end
        end, function()
            PlaceSlot(s, x2, y2, 1)
            SetBackWidth(s, 1)
            ShowSlotLabel(s)
            if i == n then
                state = "revealing"
                UpdateButtons()
            end
        end, 0.18 * (i - 1))
        Tween(0.01, nil, function() Sound("draw") end, 0.18 * (i - 1))
    end
end

-- Shakes the pack, then tears it open
local function StartOpening(key)
    local t = P.BY_KEY[key]
    if not t or state == "opening" or state == "dealing" then return end
    FinishTweens()
    local got = P:Open(key)
    if not got then return end
    selected, contents = key, got
    ResetSlots()
    state = "opening"
    Refresh()
    PackArt(t, false)
    F.burst:SetAlpha(0)
    F.burst:Show()
    Tween(0.5, function(p)
        local amp = 5 * (1 - p * 0.4)
        PlacePack(math.sin(p * 55) * amp, math.cos(p * 41) * amp * 0.4)
        F.burst:SetAlpha(0.6 * p)
    end, function()
        PlacePack(0, 0)
        PackArt(t, true)
        Sound("packPop")
        Sound("packOpen")
        Tween(0.5, function(p)
            F.burst:SetAlpha(0.9 * (1 - p))
        end, function() F.burst:Hide() end)
        Deal()
    end)
end

-- Back to the chosen pack, closed
local function Reset()
    FinishTweens()
    ResetSlots()
    state, contents = "idle", nil
    PackArt(P.BY_KEY[selected], false)
    PlacePack(0, 0)
    F.burst:Hide()
    Refresh()
end

-- =========================================================================
-- WINDOW
-- =========================================================================
UpdateButtons = function()
    local disabled = P:IsDisabled(selected)
    local count = disabled and 0 or P:Count(selected)
    local busy = (state == "opening" or state == "dealing")
    F.openBtn:SetShown(state == "idle")
    F.openBtn:SetEnabled(count > 0)
    F.againBtn:SetShown(state == "done")
    F.againBtn:SetEnabled(count > 0)
    F.doneBtn:SetShown(state == "done")
    if state == "revealing" then
        F.hint:SetText(L("packs.clickToFlip"))
    elseif state == "idle" and disabled then
        F.hint:SetText(L("packs.disabledInfo"))
    elseif state == "idle" and count == 0 then
        F.hint:SetText(L("packs.none"))
    else
        F.hint:SetText("")
    end
    F.pack:SetAlpha((state == "idle" and count == 0) and 0.45 or 1)
    for _, row in ipairs(F.rows) do
        row:SetEnabled(not busy and state ~= "revealing")
    end
end

Refresh = function()
    if not F then return end
    for _, row in ipairs(F.rows) do
        local on = (row.key == selected)
        row.sel:SetShown(on)
        row.bar:SetShown(on)
        row.text:SetFontObject(on and "GameFontHighlight" or "GameFontNormal")
        local n = P:Count(row.key)
        row.count:SetText(n > 0 and (GOLD .. "x" .. n .. "|r") or "|cFF8A8A8Ax0|r")
    end

    local t = P.BY_KEY[selected]
    F.infoName:SetText(P:Name(selected))
    local lines = {}
    if t.disabled then
        lines[#lines + 1] = "|cFFFF6060" .. L("packs.disabledInfo") .. "|r"
        lines[#lines + 1] = ""
    end
    if t.raid then
        local raidName = Loc:Term("zone", t.raid)
        lines[#lines + 1] = L("packs.dropsFrom.raid", raidName)
        lines[#lines + 1] = ""
        lines[#lines + 1] = L("packs.contents.raid", P.RANDOM_SLOTS, P.GUARANTEED_SLOTS, raidName)
    else
        lines[#lines + 1] = L("packs.dropsFrom.dungeon")
        lines[#lines + 1] = ""
        lines[#lines + 1] = L("packs.contents.dungeon", P.RANDOM_SLOTS, P.GUARANTEED_SLOTS)
    end
    lines[#lines + 1] = ""
    lines[#lines + 1] = "|cFFFF80FF" .. L("packs.foilOdds", (P.FOIL_CHANCE[1] or 0) * 100 + 0.5,
        (P.FOIL_CHANCE[2] or 0) * 100 + 0.5) .. "|r"
    if not P.GRANTS_CARDS then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "|cFFFF8040" .. L("packs.preview") .. "|r"
    end
    F.infoText:SetText(table.concat(lines, "\n"))
    F.owned:SetText(L("packs.owned", P:Count(selected)) .. (t.disabled and ("  |cFF8A8A8A" .. L("packs.disabled") .. "|r") or ""))
    F.packTex:SetDesaturated(t.disabled == true)
    UpdateButtons()
end

local ROW_H, ROW_STEP = 58, 62
local LIST_ROWS = 4                   -- rows the pack list shows before it scrolls

local function MakePackRow(parent, t, i, w)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(w, ROW_H)
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -(i - 1) * ROW_STEP)
    b.key = t.key
    b.sel = b:CreateTexture(nil, "BORDER")
    b.sel:SetAllPoints()
    b.sel:SetColorTexture(1, 0.82, 0, 0.16)
    b.bar = b:CreateTexture(nil, "ARTWORK")
    b.bar:SetPoint("TOPLEFT")
    b.bar:SetPoint("BOTTOMLEFT")
    b.bar:SetWidth(3)
    b.bar:SetColorTexture(1, 0.82, 0, 0.9)
    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.08)
    -- The closed pack's body only (38..342 x 138..642 of the art)
    local icon = b:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 53)
    icon:SetPoint("LEFT", 10, 0)
    icon:SetTexture(t.closed)
    icon:SetTexCoord(38 / ART_W, 342 / ART_W, 138 / ART_H, 642 / ART_H)
    b.count = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    b.count:SetPoint("RIGHT", -10, 0)
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    b.text:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    b.text:SetPoint("RIGHT", b.count, "LEFT", -6, 0)
    b.text:SetJustifyH("LEFT")
    b.text:SetText(P:Name(t.key))
    -- A kind that can't be opened yet (Packs.lua P.TYPES disabled): greyed, "Currently disabled"
    -- under its name, its count still shown (they drop and are kept)
    if P:IsDisabled(t.key) then
        icon:SetDesaturated(true)
        icon:SetAlpha(0.6)
        b.text:ClearAllPoints()
        b.text:SetPoint("BOTTOMLEFT", icon, "RIGHT", 10, 1)
        b.text:SetPoint("RIGHT", b.count, "LEFT", -6, 0)
        b.text:SetAlpha(0.6)
        b.off = b:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        b.off:SetPoint("TOPLEFT", icon, "RIGHT", 10, -1)
        b.off:SetText(L("packs.disabled"))
    end
    b:SetScript("OnClick", function(self)
        selected = self.key
        Reset()
    end)
    return b
end

local function Build()
    UI = TTS.DeckBuilderFrame.UI
    CARD_Y = PACK_TOP - PACK_H - 34 - TTS.PREVIEW_H / 2   -- (room for the card's name and cost above it)

    F = CreateFrame("Frame", "TTS_PackOpenerFrame", UIParent)
    O.frame = F
    F:SetSize(W, H)
    F:SetPoint("CENTER")
    F:SetClampedToScreen(true)
    UI.Skin(F, UI.STYLE.windowBg, UI.STYLE.windowBorder, "dialog")
    F:SetFrameStrata("DIALOG")
    F:SetToplevel(true)
    F:EnableMouse(true)
    F:SetMovable(true)
    F:RegisterForDrag("LeftButton")
    F:SetScript("OnDragStart", F.StartMoving)
    F:SetScript("OnDragStop", F.StopMovingOrSizing)
    F:Hide()
    tinsert(UISpecialFrames, "TTS_PackOpenerFrame")   -- Escape closes it

    -- Header, as the Collection Guide's
    local bar = F:CreateTexture(nil, "ARTWORK")
    bar:SetPoint("TOPLEFT", 12, -12)
    bar:SetPoint("TOPRIGHT", -12, -12)
    bar:SetHeight(HEADER_H)
    bar:SetColorTexture(0, 0, 0, 0.35)
    local line = F:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, 0)
    line:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, 0)
    line:SetHeight(1)
    line:SetColorTexture(1, 0.82, 0, 0.55)
    local logo = F:CreateTexture(nil, "OVERLAY")
    logo:SetSize(LOGO_H * 350 / 85, LOGO_H)
    logo:SetPoint("LEFT", bar, "LEFT", 2, 0)
    logo:SetTexture(TEXTURE_ROOT .. "logo.png")
    local title = F:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", logo, "RIGHT", 8, 0)
    Loc:Bind(title, "packs.title")
    local close = CreateFrame("Button", nil, F, "UIPanelCloseButton")
    close:SetScript("OnClick", TTS.CloseParent)
    close:SetPoint("TOPRIGHT", -2, -2)

    local footer = F:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    footer:SetPoint("BOTTOMRIGHT", F, "BOTTOMRIGHT", -26, 13)
    footer:SetText("Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy")

    -- Left: the kinds of pack, LIST_ROWS at a time; more scroll (wheel or scroll bar, shown
    -- only when there are more)
    local list = CreateFrame("Frame", nil, F)
    UI.Skin(list, UI.STYLE.panelBg, UI.STYLE.panelBorder)
    list:SetSize(SIDE_W, 8 + LIST_ROWS * ROW_STEP - (ROW_STEP - ROW_H) + 8)
    list:SetPoint("TOPLEFT", F, "TOPLEFT", 16, -64)
    local scrolls = #P.TYPES > LIST_ROWS
    local scroll = CreateFrame("ScrollFrame", "TTS_PackOpenerListScroll", list, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 8, -8)
    scroll:SetPoint("BOTTOMRIGHT", scrolls and -28 or -8, 8)
    local child = CreateFrame("Frame", nil, scroll)
    local rowW = SIDE_W - 16 - (scrolls and 20 or 0)
    child:SetSize(rowW, #P.TYPES * ROW_STEP - (ROW_STEP - ROW_H))
    scroll:SetScrollChild(child)
    local scrollBar = scroll.ScrollBar or _G["TTS_PackOpenerListScrollScrollBar"]
    if scrollBar then
        scrollBar.scrollStep = ROW_STEP
        scrollBar:SetShown(scrolls)
    end
    F.rows = {}
    for i, t in ipairs(P.TYPES) do F.rows[i] = MakePackRow(child, t, i, rowW) end

    -- Right: what the chosen pack holds
    local info = CreateFrame("Frame", nil, F)
    UI.Skin(info, UI.STYLE.panelBg, UI.STYLE.panelBorder)
    info:SetSize(SIDE_W, list:GetHeight())
    info:SetPoint("TOPRIGHT", F, "TOPRIGHT", -16, -64)
    F.infoName = info:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    F.infoName:SetPoint("TOPLEFT", 12, -12)
    F.infoName:SetPoint("RIGHT", -12, 0)
    F.infoName:SetJustifyH("LEFT")
    F.owned = info:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    F.owned:SetPoint("TOPLEFT", F.infoName, "BOTTOMLEFT", 0, -4)
    F.infoText = info:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    F.infoText:SetPoint("TOPLEFT", F.owned, "BOTTOMLEFT", 0, -10)
    F.infoText:SetPoint("RIGHT", -12, 0)
    F.infoText:SetJustifyH("LEFT")
    F.infoText:SetJustifyV("TOP")
    F.infoText:SetSpacing(2)

    -- Middle: the pack (click it, or the button, to open it)
    F.burst = F:CreateTexture(nil, "BORDER")
    F.burst:SetTexture(GLOW_TEX)
    F.burst:SetBlendMode("ADD")
    F.burst:SetVertexColor(1, 0.85, 0.4)
    F.burst:SetSize(PACK_W * 1.9, (PACK_H - BODY_TOP) * 1.5)
    F.burst:SetPoint("CENTER", F, "TOP", 0, PACK_TOP - BODY_TOP - (PACK_H - BODY_TOP) / 2)
    F.burst:Hide()

    F.pack = CreateFrame("Button", nil, F)
    F.pack:SetSize(PACK_W, PACK_H)
    F.pack:SetFrameLevel(F:GetFrameLevel() + 5)
    F.pack:SetHitRectInsets(0, 0, BODY_TOP, 0)
    F.packTex = F.pack:CreateTexture(nil, "ARTWORK")
    F.packTex:SetAllPoints()
    PlacePack(0, 0)
    F.pack:SetScript("OnClick", function()
        if state == "idle" then StartOpening(selected) end
    end)

    F.hint = F:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    F.hint:SetPoint("BOTTOM", F, "BOTTOM", 0, 44)

    F.openBtn = CreateFrame("Button", nil, F, "UIPanelButtonTemplate")
    F.openBtn:SetSize(160, 26)
    F.openBtn:SetPoint("TOP", F, "TOP", 0, PACK_TOP - PACK_H - 12)
    Loc:Bind(F.openBtn, "packs.open")
    F.openBtn:SetScript("OnClick", function() StartOpening(selected) end)

    F.againBtn = CreateFrame("Button", nil, F, "UIPanelButtonTemplate")
    F.againBtn:SetSize(150, 24)
    F.againBtn:SetPoint("BOTTOMRIGHT", F, "BOTTOM", -6, 14)
    Loc:Bind(F.againBtn, "packs.openAnother")
    F.againBtn:SetScript("OnClick", function() StartOpening(selected) end)

    F.doneBtn = CreateFrame("Button", nil, F, "UIPanelButtonTemplate")
    F.doneBtn:SetSize(150, 24)
    F.doneBtn:SetPoint("BOTTOMLEFT", F, "BOTTOM", 6, 14)
    Loc:Bind(F.doneBtn, "packs.done")
    F.doneBtn:SetScript("OnClick", Reset)

    for i = 1, P.PACK_SIZE do slots[i] = MakeSlot(i) end

    -- Closing mid-way finishes the animations; the cards wait face down for the next visit
    F:SetScript("OnHide", FinishTweens)
    F:SetScript("OnShow", function()
        if state == "idle" then PackArt(P.BY_KEY[selected], false) end
        Refresh()
    end)
    P.onChange = function()
        if F:IsShown() then Refresh() end
    end
    if TTS.Sound and TTS.Sound.HookButtons then TTS.Sound:HookButtons(F) end
end

-- Opens the window on a kind of pack (key, optional)
function O:Open(key)
    if not F then Build() end
    if key and P.BY_KEY[key] and (state == "idle" or state == "done") then
        selected = key
        if state == "done" then Reset() end
    end
    F:Show()
    F:Raise()
    return F
end

function O:Toggle()
    if F and F:IsShown() then F:Hide() else self:Open() end
end
