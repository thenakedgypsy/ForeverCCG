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

local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
TTS.MainFrame = CreateFrame("Frame", "TTS_MainDialog", UIParent, backdropTemplate)
local M = TTS.MainFrame

-- =========================================================================
-- STYLE (matches the Deckbuilder: dialog window, dark title strip with a gold
-- line, tooltip-bordered panels with gold section headers, small-font buttons)
-- =========================================================================
local PANEL_BG     = { 0.04, 0.04, 0.04, 0.70 }
local PANEL_BORDER = { 0.60, 0.56, 0.48, 1 }

M:SetSize(400, 391)
M:SetPoint("CENTER")
M:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
M:EnableMouse(true)
M:SetMovable(true)
M:RegisterForDrag("LeftButton")
M:SetScript("OnDragStart", M.StartMoving)
M:SetScript("OnDragStop", M.StopMovingOrSizing)
M:Hide()
tinsert(UISpecialFrames, "TTS_MainDialog")   -- Escape closes it

-- =========================================================================
-- TITLE & CLOSE
-- =========================================================================
local titleBar = M:CreateTexture(nil, "ARTWORK")
titleBar:SetPoint("TOPLEFT", 12, -12)
titleBar:SetPoint("TOPRIGHT", -12, -12)
titleBar:SetHeight(72)   -- room for the logo
titleBar:SetColorTexture(0, 0, 0, 0.35)

local titleLine = M:CreateTexture(nil, "ARTWORK")
titleLine:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 0)
titleLine:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
titleLine:SetHeight(1)
titleLine:SetColorTexture(1, 0.82, 0, 0.55)

-- The Forever: CCG logo (350 x 85) in the title strip, in its proportions
local LOGO_H = 64
local logo = M:CreateTexture(nil, "OVERLAY")
logo:SetSize(LOGO_H * 350 / 85, LOGO_H)
logo:SetPoint("LEFT", titleBar, "LEFT", 4, 0)
logo:SetTexture("Interface\\AddOns\\ForeverCCG\\Textures\\logo.png")

local closeBtn = CreateFrame("Button", nil, M, "UIPanelCloseButton")
closeBtn:SetScript("OnClick", TTS.CloseParent)   -- (not HideUIPanel: blocked in combat)
closeBtn:SetPoint("RIGHT", titleBar, "RIGHT", 6, 27)

local content = CreateFrame("Frame", nil, M)
content:SetAllPoints(M)

-- Tooltip-bordered panel with a gold section header (locale key) and divider
local function CreateSection(labelKey, w, h)
    local p = CreateFrame("Frame", nil, content, backdropTemplate)
    p:SetSize(w, h)
    p:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    p:SetBackdropColor(PANEL_BG[1], PANEL_BG[2], PANEL_BG[3], PANEL_BG[4])
    p:SetBackdropBorderColor(PANEL_BORDER[1], PANEL_BORDER[2], PANEL_BORDER[3], PANEL_BORDER[4])

    local header = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header:SetPoint("TOPLEFT", 10, -9)
    Loc:Bind(header, labelKey)

    local line = p:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", 8, -24)
    line:SetPoint("TOPRIGHT", -8, -24)
    line:SetHeight(1)
    line:SetColorTexture(1, 0.82, 0, 0.30)
    p.headerText, p.divider = header, line   -- (folding moves the one and hides the other)
    return p
end

-- Red panel button with the Deckbuilder's small fonts, labelled with locale key textKey
local function CreatePanelButton(name, parent, w, h, textKey)
    local b = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    b:SetSize(w, h)
    b:SetNormalFontObject("GameFontNormalSmall")
    b:SetHighlightFontObject("GameFontHighlightSmall")
    b:SetDisabledFontObject("GameFontDisableSmall")
    Loc:Bind(b, textKey)
    return b
end

-- =========================================================================
-- OPENING WINDOWS FROM HERE
-- Picking an option closes this window; closing the window it opened brings
-- this one back (unless a match has started in the meantime). The PvE and PvP windows
-- (below) open their own windows the same way, and close back to this one.
-- child.ttsReturnTo: the window that comes back when it closes
-- child.ttsHome: the PvE or PvP window it belongs to (M:OpenChild goes through it)
-- =========================================================================
local function OnChildHidden(child)
    local back = child.ttsReturnTo
    if not back then return end
    child.ttsReturnTo = nil
    -- Wait a frame: a window closed by a match starting should not bring this back
    TTS:SafeAfter(0, function()
        if child:IsShown() or back:IsShown() then return end
        if TTS.Engine and TTS.Engine.inMatch then return end
        -- Hidden for the deck picker: cancelling it may bring the window back, still ours
        if TTS.DeckPicker and TTS.DeckPicker:IsPending() then
            child.ttsReturnTo = back
            return
        end
        -- Hidden behind a window of its own (the solo map's dungeon entry, the PvE window's
        -- solo map), which brings it back
        if child.ttsIsCovered and child.ttsIsCovered() then
            child.ttsReturnTo = back
            return
        end
        back:Show()
    end)
end

local function OpenFrom(parent, child)
    if not (child and child:IsShown()) then return end   -- it refused to open
    if not child.ttsMainHooked then
        child.ttsMainHooked = true
        child:HookScript("OnHide", OnChildHidden)
    end
    child.ttsReturnTo = parent
    parent.ttsOpenChild = child
    parent:Hide()
end

local function OpenFromMain(child) OpenFrom(M, child) end

-- A shown window takes over as parent's child (closing it brings parent back): the
-- tournament windows that replace one another (Events\UI\Choose.lua)
function M:OpenChildFrom(parent, child) OpenFrom(parent, child) end

-- Opens a window as if from the main window, so closing it comes back here (Board.lua: the
-- solo map after a solo encounter). A window of the PvE or PvP window's opens over that one.
-- (A PvE / PvP section docked in the main window: the child opens from the main window. One
-- popped out into its own window: from that window, the main window staying as it is.)
function M:OpenChild(child)
    local home = child.ttsHome
    if home and home ~= child and not home.docked then
        home:Show()
        child:Show()
        OpenFrom(home, child)
        return
    end
    if not M:IsShown() then M:Show() end
    child:Show()
    OpenFromMain(child)
end

-- =========================================================================
-- OPTIONS (title bar, left of the close button)
-- =========================================================================
local optionsBtn = CreatePanelButton("TTS_OptionsBtn", M, 64, 20, "options.title")
optionsBtn:SetPoint("RIGHT", closeBtn, "LEFT", 2, 0)   -- level with the close button
optionsBtn:SetScript("OnClick", function()
    if TTS.OptionsFrame then
        TTS.OptionsFrame:Show()
        OpenFromMain(TTS.OptionsFrame)
    end
end)

-- =========================================================================
-- LAYOUT: three sections, one under another, full width: Collect, Build and Battle.
-- Every button sits SIDE in from its section's edges, BTN_GAP apart, the first row under
-- the header; two to a row (GRID_BTN_W). Battle holds two buttons, PvE and PvP, each
-- opening a window of its own.
-- =========================================================================
local SECTION_W, SECTION_GAP = 372, 8
local SIDE, BTN_H, BTN_GAP, FIRST_Y = 10, 24, 4, -32
local GRID_BTN_W = (SECTION_W - 2 * SIDE - 12) / 2     -- two to a row, 12 apart
local STATUS_Y = FIRST_Y - BTN_H - 8                    -- under Build's buttons
local CAMPFIRE_LINE_H = 16                             -- the campfire bonus line under Collect's button
local COLLECT_H = -FIRST_Y + BTN_H + CAMPFIRE_LINE_H + 10
local BUILD_H = -STATUS_Y + 34                          -- room for two lines of status
-- The PvE and PvP sections, one under the other (THE PvE AND PvP SECTIONS, below, which sizes
-- the Battle section and the window to them as they open and fold)
local DOCK_TOP = -28
local BATTLE_H = 300

-- The window fits them: under the title strip, the sections, then room for the footer
M:SetHeight(93 + COLLECT_H + BUILD_H + BATTLE_H + 2 * SECTION_GAP + 34)

-- The y offset of button row `row` (1 = first) in a section, below `top` (default FIRST_Y)
local function RowY(row, top) return (top or FIRST_Y) - (row - 1) * (BTN_H + BTN_GAP) end

-- =========================================================================
-- COLLECT: the Collection Guide, and the collection score in the header
-- =========================================================================
local collectSection = CreateSection("main.collect", SECTION_W, COLLECT_H)
collectSection:SetPoint("TOPLEFT", M, "TOPLEFT", 14, -93)

-- Which cards each zone and dungeon holds, and how many of each you have (CollectionGuide.lua)
local guideBtn = CreatePanelButton("TTS_CollectionGuideBtn", collectSection, GRID_BTN_W, BTN_H, "main.collectionGuide")
guideBtn:SetPoint("TOPLEFT", collectSection, "TOPLEFT", SIDE, RowY(1))

-- Beside it: the booster pack opener (PackOpener.lua), with how many packs are waiting
local packsBtn = CreatePanelButton("TTS_OpenPacksBtn", collectSection, GRID_BTN_W, BTN_H, "packs.button")
packsBtn:SetPoint("TOPRIGHT", collectSection, "TOPRIGHT", -SIDE, RowY(1))
packsBtn:SetScript("OnClick", function()
    if TTS.PackOpener then OpenFromMain(TTS.PackOpener:Open()) end
end)
function M:RefreshPacksButton()
    local n = TTS.Packs and TTS.Packs:Total() or 0
    if n > 0 then Loc:Bind(packsBtn, "packs.buttonCount", n) else Loc:Bind(packsBtn, "packs.button") end
end

-- Under them: the daily bonuses, the campfire bonus (more card drops; running or how long
-- until the next) and the daily dungeon pack, one timer once both are had (UpdateTimers, below)
local campfireLabel = collectSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
campfireLabel:SetPoint("TOP", collectSection, "TOP", 0, RowY(1) - BTN_H - 4)
campfireLabel:SetWidth(SECTION_W - 2 * SIDE)
campfireLabel:SetJustifyH("CENTER")
guideBtn:SetScript("OnClick", function()
    if TTS.CollectionGuide then OpenFromMain(TTS.CollectionGuide:Open()) end
end)

-- Collection score, right side of the section header
local scoreLabel = collectSection:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
scoreLabel:SetPoint("TOPRIGHT", collectSection, "TOPRIGHT", -SIDE, -9)
scoreLabel:SetJustifyH("RIGHT")

-- =========================================================================
-- BUILD: the Deckbuilder, the rules, and whether a deck is ready to play
-- =========================================================================
local buildSection = CreateSection("main.build", SECTION_W, BUILD_H)
buildSection:SetPoint("TOPLEFT", collectSection, "BOTTOMLEFT", 0, -SECTION_GAP)

local deckBtn = CreatePanelButton("TTS_DeckBuilderBtn", buildSection, GRID_BTN_W, BTN_H, "main.openDeckbuilder")
deckBtn:SetPoint("TOPLEFT", buildSection, "TOPLEFT", SIDE, RowY(1))
deckBtn:SetScript("OnClick", function()
    if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame.TryOpen then
        TTS.DeckBuilderFrame:TryOpen()
        OpenFromMain(TTS.DeckBuilderFrame)
    end
end)

local rulesBtn = CreatePanelButton("TTS_RulesBtn", buildSection, GRID_BTN_W, BTN_H, "main.rules")
rulesBtn:SetPoint("TOPRIGHT", buildSection, "TOPRIGHT", -SIDE, RowY(1))
rulesBtn:SetScript("OnClick", function()
    if TTS.RulesFrame then
        TTS.RulesFrame:Show()
        OpenFromMain(TTS.RulesFrame)
    end
end)

local statusLabel = buildSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
statusLabel:SetPoint("TOP", buildSection, "TOP", 0, STATUS_Y)
statusLabel:SetWidth(SECTION_W - 4 * SIDE)
statusLabel:SetJustifyH("CENTER")
statusLabel:SetWordWrap(true)

-- =========================================================================
-- BATTLE: the PvE and PvP sections (each folds down to its header, below), and the PvP
-- rating in the header
-- =========================================================================
local battleSection = CreateSection("main.battle", SECTION_W, BATTLE_H)
battleSection:SetPoint("TOPLEFT", buildSection, "BOTTOMLEFT", 0, -SECTION_GAP)

-- PvP rating, right side of the section header (as the collection score is on Collect's)
local ratingLabel = battleSection:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
ratingLabel:SetPoint("TOPRIGHT", battleSection, "TOPRIGHT", -SIDE, -9)
ratingLabel:SetJustifyH("RIGHT")

-- =========================================================================
-- THE PvE AND PvP WINDOWS
-- Small windows in the main window's look: a title strip, then one section of full-width
-- buttons. Each takes the main window's place; the windows they open take theirs, and
-- closing those comes back to them (OPENING WINDOWS FROM HERE, above).
-- =========================================================================
local SUB_W = 280
local SUB_BTN_W = SUB_W - 28 - 2 * SIDE
local SUB_TOP = -44

local function CreateSubWindow(name, titleKey, rows, extraH)
    local w = CreateFrame("Frame", name, UIParent, backdropTemplate)
    local sectionH = -FIRST_Y + rows * BTN_H + (rows - 1) * BTN_GAP + (extraH or 0) + 10
    w:SetSize(SUB_W, -SUB_TOP + sectionH + 40)
    w:SetPoint("CENTER")
    w:SetFrameStrata("DIALOG")
    w:SetToplevel(true)
    w:SetClampedToScreen(true)
    w:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    w:EnableMouse(true)
    w:SetMovable(true)
    w:RegisterForDrag("LeftButton")
    w:SetScript("OnDragStart", w.StartMoving)
    w:SetScript("OnDragStop", w.StopMovingOrSizing)
    w:Hide()
    tinsert(UISpecialFrames, name)

    local bar = w:CreateTexture(nil, "ARTWORK")
    bar:SetPoint("TOPLEFT", 12, -12)
    bar:SetPoint("TOPRIGHT", -12, -12)
    bar:SetHeight(25)
    bar:SetColorTexture(0, 0, 0, 0.35)
    local line = w:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, 0)
    line:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, 0)
    line:SetHeight(1)
    line:SetColorTexture(1, 0.82, 0, 0.55)
    w.title = w:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    w.title:SetPoint("TOPLEFT", 16, -16)
    Loc:Bind(w.title, titleKey)
    local close = CreateFrame("Button", nil, w, "UIPanelCloseButton")
    close:SetScript("OnClick", TTS.CloseParent)
    close:SetPoint("TOPRIGHT", -2, -2)

    local p = CreateFrame("Frame", nil, w, backdropTemplate)
    p:SetPoint("TOPLEFT", w, "TOPLEFT", 14, SUB_TOP)
    p:SetPoint("TOPRIGHT", w, "TOPRIGHT", -14, SUB_TOP)
    p:SetHeight(sectionH)
    p:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    p:SetBackdropColor(PANEL_BG[1], PANEL_BG[2], PANEL_BG[3], PANEL_BG[4])
    p:SetBackdropBorderColor(PANEL_BORDER[1], PANEL_BORDER[2], PANEL_BORDER[3], PANEL_BORDER[4])
    -- The section header: a line of status (UpdatePlayState) and the divider
    w.header = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    w.header:SetPoint("TOPLEFT", 10, -9)
    w.header:SetPoint("TOPRIGHT", -10, -9)
    w.header:SetJustifyH("LEFT")
    local divider = p:CreateTexture(nil, "ARTWORK")
    divider:SetPoint("TOPLEFT", 8, -24)
    divider:SetPoint("TOPRIGHT", -8, -24)
    divider:SetHeight(1)
    divider:SetColorTexture(1, 0.82, 0, 0.30)
    w.section, w.divider = p, divider

    -- Hidden behind a window it opened, it isn't closed (OnChildHidden)
    w.ttsIsCovered = function()
        local c = w.ttsOpenChild
        return c ~= nil and (c:IsShown() or c.ttsReturnTo == w)
    end
    w:SetScript("OnShow", function(self)
        if TTS.Engine and TTS.Engine.inMatch then
            self:Hide()
            return
        end
        M:UpdatePlayState()
    end)
    local footerText = w:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    footerText:SetPoint("BOTTOM", w, "BOTTOM", 0, 16)
    footerText:SetText("Tragic: The Saddening Engine")
    local loader = CreateFrame("Frame")
    loader:RegisterEvent("PLAYER_LOGIN")
    loader:SetScript("OnEvent", function(self)
        if TTS.Sound and TTS.Sound.HookButtons then TTS.Sound:HookButtons(w) end
        self:UnregisterAllEvents()
    end)
    return w
end

-- A full-width button on row `row` of a window's section (its width follows the section's,
-- docked or popped out: w.buttons)
local function SubButton(w, name, row, key)
    local b = CreatePanelButton(name, w.section, SUB_BTN_W, BTN_H, key)
    b:SetPoint("TOP", w.section, "TOP", 0, RowY(row))
    w.buttons = w.buttons or {}
    table.insert(w.buttons, b)
    return b
end

-- What a PvE / PvP button's window opens over and comes back to: the main window, where both
-- sections are (THE PvE AND PvP SECTIONS)
local function Home(w) return w.docked and M or w end

-- -------------------------------------------------------------------------
-- PvE: the campaign, the Daily challenge, Endless, practice and the tutorial
-- -------------------------------------------------------------------------
local pveWin = CreateSubWindow("TTS_PvEFrame", "main.pveTitle", 5)
TTS.PvEFrame = pveWin

local encountersBtn = SubButton(pveWin, "TTS_SoloEncountersBtn", 1, "main.campaign")
encountersBtn:SetScript("OnClick", function()
    if TTS.SoloSelectFrame then
        TTS.SoloSelectFrame:Show()
        OpenFrom(Home(pveWin), TTS.SoloSelectFrame)
    end
end)

-- The Daily challenge (UI\DailyPanel.lua) and Endless (UI\Endless.lua)
local dailyBtn = SubButton(pveWin, "TTS_DailyBtn", 2, "main.daily")
dailyBtn:SetScript("OnClick", function()
    if TTS.DailyPanel then OpenFrom(Home(pveWin), TTS.DailyPanel:Open()) end
end)
local endlessBtn = SubButton(pveWin, "TTS_EndlessBtn", 3, "main.endless")
endlessBtn:SetScript("OnClick", function()
    if TTS.EndlessFrame then OpenFrom(Home(pveWin), TTS.EndlessFrame:Open()) end
end)

local soloBtn = SubButton(pveWin, "TTS_SoloBtn", 4, "main.practice")
soloBtn:SetScript("OnClick", function()
    if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() then
        DEFAULT_CHAT_FRAME:AddMessage(L("main.closeDeckbuilderFirst"))
        return
    end
    local dummy = L("solo.dummy")
    -- How the dummy plays, chosen as the deck is (E.practice, AI.lua), and remembered
    local O = TTS.Options
    TTS.DeckPicker:Open({
        opponent = dummy,
        checks = {
            { key = "attacks", label = "picker.dummyAttacks", value = not O or O:Get("practiceAttacks") ~= false },
            { key = "blocks",  label = "picker.dummyBlocks",  value = not O or O:Get("practiceBlocks") ~= false },
        },
        onPick = function(_, checked)
            if TTS.Engine.inMatch then return end
            if O then
                O:Set("practiceAttacks", checked.attacks)
                O:Set("practiceBlocks", checked.blocks)
            end
            TTS.Engine.practice = { attacks = checked.attacks, blocks = checked.blocks }
            TTS.Engine:StartMatch(dummy, true, true)
        end,
    })
    -- (cancelling the deck picker brings this window back; a game starting doesn't)
    OpenFrom(Home(pveWin), TTS.DeckPicker)
end)

-- The tutorial game (UI\Tutorial.lua): it brings its own decks
local tutorialBtn = SubButton(pveWin, "TTS_TutorialBtn", 5, "tut.play")
tutorialBtn:SetScript("OnClick", function()
    if not TTS.StartTutorial then return end
    TTS:StartTutorial()
    if TTS.Engine and TTS.Engine.inMatch then pveWin:Hide() end
end)

-- -------------------------------------------------------------------------
-- PvP: the waiting room (the only way to challenge other players), the record,
-- tournaments, and the weekly tournament prize under them
-- -------------------------------------------------------------------------
local pvpWin = CreateSubWindow("TTS_PvPFrame", "main.pvpTitle", 3, CAMPFIRE_LINE_H + 4)
TTS.PvPFrame = pvpWin

local waitingRoomBtn = SubButton(pvpWin, "TTS_WaitingRoomBtn", 1, "main.openWaitingRoom")
waitingRoomBtn:SetScript("OnClick", function()
    if TTS.WaitingRoom and TTS.WaitingRoom.frame then
        TTS.WaitingRoom.frame:Show()
        OpenFrom(Home(pvpWin), TTS.WaitingRoom.frame)
    end
end)

-- The PvP rating, wins and losses, and the latest games (PvPRecord.lua)
local recordBtn = SubButton(pvpWin, "TTS_PvPRecordBtn", 2, "main.pvpRecord")
recordBtn:SetScript("OnClick", function()
    if TTS.PvP then OpenFrom(Home(pvpWin), TTS.PvP:Open()) end
end)

-- Tournaments (Events\): join one with a code, or host one
local tournamentBtn = SubButton(pvpWin, "TTS_TournamentsBtn", 3, "main.tournaments")
tournamentBtn:SetScript("OnClick", function()
    local win = TTS.OpenTournaments and TTS:OpenTournaments()
    if win then OpenFrom(Home(pvpWin), win) end
end)

-- Under it (a minimap tooltip line too): the weekly tournament prize cooldown (UpdateTimers)
local timersLabel = pvpWin.section:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
timersLabel:SetPoint("TOP", tournamentBtn, "BOTTOM", 0, -6)
timersLabel:SetWidth(SUB_BTN_W)
timersLabel:SetJustifyH("CENTER")

-- The solo map, the Daily and Endless open over the PvE window however they're opened
-- (M:OpenChild); they load after this file
do
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", function(self)
        self:UnregisterAllEvents()
        for _, w in ipairs({ TTS.SoloSelectFrame, TTS.DailyPanel, TTS.EndlessFrame }) do w.ttsHome = pveWin end
    end)
end

-- =========================================================================
-- FOLDING SECTIONS
-- Every section folds: the main window's Collect, Build and Battle, and inside Battle the PvE
-- and PvP sections (both windows' sections live there now, one under the other, full width,
-- their buttons two to a row; the windows themselves no longer open, so what their buttons
-- open comes back to the main window). A +/- at the left of each header, or a click anywhere
-- on the header, folds the section down to that line or opens it again, sliding; the main
-- window grows and shrinks to fit. Remembered (the mainExpand option: { build = false } =
-- folded). What a folded section hides it shows again as it was when it opens.
-- (In a function of its own: the file's main chunk is near Lua's 200 locals.)
-- =========================================================================
;(function()
    local HEAD_H = 26                 -- a folded section: its header line
    local INNER_W = SECTION_W - 2 * SIDE
    local HALF_W = (INNER_W - 2 * SIDE - 8) / 2
    local SLIDE = 0.15                -- seconds to fold or open
    local inner = { pveWin, pvpWin }
    local folds, tops = {}, {}
    local battleOpen = HEAD_H

    local function Expanded(key)
        local o = TTS.Options and TTS.Options:Get("mainExpand")
        return not (type(o) == "table" and o[key] == false)
    end
    local function SaveExpanded(key, on)
        if not TTS.Options then return end
        local o = TTS.Options:Get("mainExpand")
        if type(o) ~= "table" then o = {} end
        o[key] = on and true or false
        TTS.Options:Set("mainExpand", o)
    end

    -- An open PvE / PvP section: its buttons two to a row, and PvP's timer line under them
    local function InnerOpenHeight(w)
        local rows = math.ceil(#(w.buttons or {}) / 2)
        return -FIRST_Y + rows * BTN_H + (rows - 1) * BTN_GAP + (w.timers and (CAMPFIRE_LINE_H + 6) or 0) + 10
    end

    -- Every section's height as it is now: PvE and PvP stacked in Battle, Battle's open
    -- height from them, the main window round the three
    local function Relayout()
        local y = DOCK_TOP
        for _, w in ipairs(inner) do
            local p = w.section
            p:ClearAllPoints()
            p:SetPoint("TOPLEFT", battleSection, "TOPLEFT", SIDE, y)
            p:SetWidth(INNER_W)
            p:SetHeight(w.fold.height)
            y = y - w.fold.height - 6
        end
        battleOpen = -y + 2
        local battle = battleSection.fold
        if battle.expanded and not battle.sliding then battle.height = battleOpen end
        local total = 0
        for _, f in ipairs(tops) do
            f.p:SetHeight(f.height)
            total = total + f.height
        end
        M:SetHeight(93 + total + 2 * SECTION_GAP + 34)
    end

    -- Hides what's in a section but its header (remembering what was showing), or shows it again
    local function ShowInside(f, on)
        local p = f.p
        if not on then
            if f.hidden then return end
            f.hidden = {}
            local function Hide(x)
                if not f.keep[x] and x:IsShown() then x:Hide(); f.hidden[#f.hidden + 1] = x end
            end
            for _, c in ipairs({ p:GetChildren() }) do Hide(c) end
            for _, r in ipairs({ p:GetRegions() }) do Hide(r) end
        elseif f.hidden then
            for _, x in ipairs(f.hidden) do x:Show() end
            f.hidden = nil
        end
        f.toggle:SetNormalTexture(on and "Interface\\Buttons\\UI-MinusButton-Up" or "Interface\\Buttons\\UI-PlusButton-Up")
        f.toggle:SetPushedTexture(on and "Interface\\Buttons\\UI-MinusButton-Down" or "Interface\\Buttons\\UI-PlusButton-Down")
    end

    -- Folds or opens it, sliding (straight there with animations off, UI\Motion.lua's option)
    local function SetExpanded(f, on, instant)
        f.expanded = on
        local target = on and f.open() or HEAD_H
        if on then ShowInside(f, true) end
        local motion = not TTS.Options or TTS.Options:Get("uiMotion") ~= false
        if instant or not motion or not M:IsVisible() then
            f.height, f.sliding = target, nil
            if not on then ShowInside(f, false) end
            Relayout()
            return
        end
        local from, t = f.height or target, 0
        f.sliding = true
        f.slider:SetScript("OnUpdate", function(self, dt)
            t = t + dt
            local p = math.min(1, t / SLIDE)
            local e = 1 - (1 - p) ^ 3
            f.height = from + (target - from) * e
            Relayout()
            if p >= 1 then
                self:SetScript("OnUpdate", nil)
                f.sliding = nil
                if not on then ShowInside(f, false) end
                Relayout()
            end
        end)
    end

    -- Makes section p fold: key (saved), open() its open height, header its header text, keep
    -- the regions that stay up when folded (besides the header and the toggle)
    local function Foldable(p, key, open, header, keep)
        local f = { p = p, key = key, open = open, expanded = true, keep = {} }
        p.fold = f
        if p.SetClipsChildren then p:SetClipsChildren(true) end   -- (nothing spills out while it slides)
        f.slider = CreateFrame("Frame", nil, p)
        f.toggle = CreateFrame("Button", nil, p)
        f.toggle:SetSize(16, 16)
        f.toggle:SetPoint("TOPLEFT", p, "TOPLEFT", 6, -5)
        f.toggle:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")
        header:ClearAllPoints()
        header:SetPoint("TOPLEFT", p, "TOPLEFT", 26, -9)
        if keep.stretch then header:SetPoint("TOPRIGHT", p, "TOPRIGHT", -10, -9) end
        local band = CreateFrame("Button", nil, p)
        band:SetPoint("TOPLEFT", p, "TOPLEFT", 4, -3)
        band:SetPoint("TOPRIGHT", p, "TOPRIGHT", -4, -3)
        band:SetHeight(HEAD_H - 6)
        band:SetFrameLevel(math.max(1, f.toggle:GetFrameLevel() - 1))
        for _, x in ipairs({ f.slider, f.toggle, band, header }) do f.keep[x] = true end
        for _, x in ipairs(keep) do f.keep[x] = true end
        local function Toggle()
            SetExpanded(f, not f.expanded)
            SaveExpanded(key, f.expanded)
            if TTS.Sound then TTS.Sound:PlayUI("button") end
        end
        f.toggle:SetScript("OnClick", Toggle)
        band:SetScript("OnClick", Toggle)
        for _, x in ipairs({ f.toggle, band }) do
            x:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:SetText(L(f.expanded and "main.collapse" or "main.expand"), 1, 0.82, 0)
                GameTooltip:Show()
            end)
            x:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end
        ShowInside(f, true)
        folds[#folds + 1] = f
        return f
    end

    -- The PvE and PvP sections, moved in from their windows
    for _, w in ipairs(inner) do
        local p = w.section
        p:SetParent(battleSection)
        w.docked = true
        w.timers = (w == pvpWin) and timersLabel or nil
        for i, b in ipairs(w.buttons or {}) do
            b:ClearAllPoints()
            b:SetWidth(HALF_W)
            local row, col = math.ceil(i / 2), (i - 1) % 2
            b:SetPoint("TOPLEFT", p, "TOPLEFT", SIDE + col * (HALF_W + 8), RowY(row))
        end
        if w.timers then
            local rows = math.ceil(#w.buttons / 2)
            w.timers:ClearAllPoints()
            w.timers:SetPoint("TOP", p, "TOP", 0, RowY(rows) - BTN_H - 6)
            w.timers:SetWidth(INNER_W - 2 * SIDE)
        end
        local f = Foldable(p, (w == pveWin) and "pve" or "pvp", function() return InnerOpenHeight(w) end, w.header, { stretch = true })
        f.height = f.open()
        w.fold = f
    end

    -- The three main sections (their right-hand header lines stay up when folded)
    local function Top(p, key, h, keep)
        local f = Foldable(p, key, type(h) == "function" and h or function() return h end, p.headerText, keep)
        f.height = f.open()
        tops[#tops + 1] = f
    end
    Top(collectSection, "collect", COLLECT_H, { scoreLabel })
    Top(buildSection, "build", BUILD_H, {})
    Top(battleSection, "battle", function() return battleOpen end, { ratingLabel })
    Relayout()
    battleSection.fold.height = battleOpen
    Relayout()

    -- The saved choice, once the options have loaded
    local loader = CreateFrame("Frame")
    loader:RegisterEvent("PLAYER_LOGIN")
    loader:SetScript("OnEvent", function(self)
        self:UnregisterAllEvents()
        for _, f in ipairs(folds) do
            if not Expanded(f.key) then SetExpanded(f, false, true) end
        end
    end)
end)()

-- =========================================================================
-- STATE UPDATER & LIFECYCLE (ENFORCING 40-50 CARDS)
-- =========================================================================
function M:UpdatePlayState()
    if TTS.GetCollectionScore then
        scoreLabel:SetText(L("main.score", TTS:ColoredScore((TTS:GetCollectionScore()))))
    end
    local rated = TTS.PvP and TTS.PvP.ColoredRating((TTS.PvP:Get()))
    if rated then ratingLabel:SetText(L("pvp.rating", rated)) end
    -- Each section's header: PvE in the score's colours by the share of solo reward copies
    -- won, with that count; PvP in the colour its rating number has (PvPRecord.lua's tiers),
    -- with the rating
    local gained, total = 0, 0
    if TTS.PvERewards then gained, total = TTS:PvERewards() end
    local pveName = TTS.TierColored and TTS:TierColored(total > 0 and gained / total or 0, L("main.pve")) or L("main.pve")
    pveWin.header:SetText(pveName .. "  |cFFBBBBBB" .. L("main.pveRewards",
        TTS.ColoredCount and TTS:ColoredCount(gained, total) or (gained .. "/" .. total)) .. "|r")
    local colour = rated and rated:match("^|c(%x%x%x%x%x%x%x%x)")
    local pvpName = colour and ("|c" .. colour .. L("main.playOthers") .. "|r") or L("main.playOthers")
    pvpWin.header:SetText(pvpName .. (rated and ("  |cFFBBBBBB" .. L("pvp.rating", rated) .. "|r") or ""))

    local inMatch = TTS.Engine and TTS.Engine.inMatch
    local isQueued = TTS.WaitingRoom and TTS.WaitingRoom.isQueued
    local playable = TTS:PlayableDeckCount()

    -- The Deckbuilder cannot be opened while a game is in progress (it can while queued)
    deckBtn:SetEnabled(not inMatch)
    -- Solo encounters open whenever no game is running (the window explains anything else in the way)
    encountersBtn:SetEnabled(not inMatch)
    dailyBtn:SetEnabled(not inMatch)
    endlessBtn:SetEnabled(not inMatch)
    tutorialBtn:SetEnabled(not inMatch and not isQueued)
    -- Decks are picked as a game starts, so one playable deck is enough. Once queued the
    -- waiting room always reopens, so the player can leave.
    waitingRoomBtn:SetEnabled(not inMatch and (isQueued or playable > 0))
    -- Practice vs Dummy is unavailable during a game or while queued in the waiting room
    soloBtn:SetEnabled(not inMatch and not isQueued and playable > 0
        and not (TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown()))

    if isQueued then
        statusLabel:SetText(L("main.inWaitingRoom"))
    elseif TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() then
        statusLabel:SetText(L("main.deckbuilderOpen"))
    elseif playable > 0 then
        statusLabel:SetText(L("main.decksReady", playable))
    else
        statusLabel:SetText(L("main.noDeckReady"))
    end
end

-- Hovering either line explains how to get it: a frame over just the text (the lines are
-- centred in a wider box), resized whenever the text changes
local function AddHoverTip(label, titleKey, bodyKey)
    local hover = CreateFrame("Frame", nil, label:GetParent())
    hover:SetPoint("CENTER", label, "CENTER")
    hover:SetHeight(CAMPFIRE_LINE_H)
    hover:SetWidth(1)
    hover:EnableMouse(true)
    function hover:FitText()
        self:SetWidth(math.max(1, label:GetStringWidth() + 8))
    end
    hover:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L(titleKey), 1, 0.82, 0)
        GameTooltip:AddLine(L(bodyKey), 1, 1, 1, true)
        GameTooltip:Show()
    end)
    hover:SetScript("OnLeave", function() GameTooltip:Hide() end)
    label.hover = hover
end
AddHoverTip(campfireLabel, "main.campfireTipTitle", "main.campfireTip")
AddHoverTip(timersLabel, "main.prizeTipTitle", "main.prizeTip")

-- The timers: ready (green), or the time left (grey); while the campfire bonus runs, its
-- time left (orange)
local GREEN, GREY, ORANGE = "|cFF1AFF1A", "|cFF999999", "|cFFFF9933"

-- The daily bonuses as they stand: each one's label and coloured value, and the seconds
-- until each can be had again (nil while it can be, or while the campfire's runs)
local function DailyBonuses()
    local C, P = TTS.Campfire, TTS.Packs
    local warmth = C and C:Remaining()
    local fireWait = C and C.CooldownLeft and C:CooldownLeft()
    local packWait = P and P.DailyCooldownLeft and P:DailyCooldownLeft()
    local fire = {
        label = L(warmth and "minimap.campfire" or "minimap.campfireNext"),
        value = warmth and (ORANGE .. TTS:FormatWait(warmth) .. "|r")
            or fireWait and (GREY .. TTS:FormatWait(fireWait) .. "|r") or (GREEN .. L("minimap.ready") .. "|r"),
        wait = fireWait,
    }
    local pack = {
        label = L("minimap.dailyPack"),
        value = packWait and (GREY .. TTS:FormatWait(packWait) .. "|r") or (GREEN .. L("minimap.ready") .. "|r"),
        wait = packWait,
    }
    -- The Daily challenge's reward (Daily.lua): ready, or until local midnight once won
    local D = TTS.Daily
    local dailyWait = D and D:RewardWait()
    local daily = {
        label = L("minimap.daily"),
        value = dailyWait and (GREY .. TTS:FormatWait(dailyWait) .. "|r") or (GREEN .. L("minimap.ready") .. "|r"),
        wait = dailyWait,
    }
    return fire, pack, daily
end

-- The line's short labels (three timers share one line)
local SHORT_LABEL = { fire = "main.short.campfire", warmth = "main.short.warmth", pack = "main.short.dailyPack", daily = "main.short.daily" }

-- The bonuses line's tooltip: each bonus with its timer and how to get it
campfireLabel.hover:SetScript("OnEnter", function(self)
    local fire, pack, daily = DailyBonuses()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L("main.bonusesTipTitle"), 1, 0.82, 0)
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(fire.label, fire.value, 1, 0.6, 0.2)
    GameTooltip:AddLine(L("main.campfireTip"), 0.9, 0.9, 0.9, true)
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(pack.label, pack.value, 1, 0.82, 0)
    GameTooltip:AddLine(L("main.dailyPackTip"), 0.9, 0.9, 0.9, true)
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(daily.label, daily.value, 1, 0.82, 0)
    GameTooltip:AddLine(L("main.dailyTip"), 0.9, 0.9, 0.9, true)
    GameTooltip:Show()
end)

local function UpdateTimers()
    if TTS.Campfire or TTS.Packs then
        local fire, pack, daily = DailyBonuses()
        if fire.wait and pack.wait and daily.wait then
            -- All had today: one timer, until the first is ready again (all at midnight)
            campfireLabel:SetText(L("main.bonusesNext") .. " "
                .. GREY .. TTS:FormatWait(math.min(fire.wait, pack.wait, daily.wait)) .. "|r")
        else
            local warm = TTS.Campfire and TTS.Campfire:Remaining()
            local sep = "  |cFF666666·|r  "
            campfireLabel:SetText(L(warm and SHORT_LABEL.warmth or SHORT_LABEL.fire) .. " " .. fire.value .. sep
                .. L(SHORT_LABEL.pack) .. " " .. pack.value .. sep .. L(SHORT_LABEL.daily) .. " " .. daily.value)
        end
        campfireLabel.hover:FitText()
        -- An open tooltip follows the timers
        if GameTooltip:IsOwned(campfireLabel.hover) then campfireLabel.hover:GetScript("OnEnter")(campfireLabel.hover) end
    end
    if TTS.TournamentPrizeCooldown then
        local wait = TTS:TournamentPrizeCooldown()
        timersLabel:SetText(L("minimap.prize") .. " "
            .. (wait > 0 and (GREY .. TTS:FormatWait(wait) .. "|r") or (GREEN .. L("minimap.ready") .. "|r")))
        timersLabel.hover:FitText()
    end
end

-- Counted down while the window is open
local timersTicker
M:SetScript("OnShow", function()
    M:RefreshPacksButton()
    M:UpdatePlayState()
    UpdateTimers()
    if timersTicker then timersTicker:Cancel() end
    timersTicker = C_Timer.NewTicker(30, UpdateTimers)
end)
M:HookScript("OnHide", function()
    if timersTicker then timersTicker:Cancel(); timersTicker = nil end
end)
-- The PvP window shows the tournament prize timer
pvpWin:HookScript("OnShow", UpdateTimers)

-- =========================================================================
-- FOOTER
-- =========================================================================
local footer = content:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
footer:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -20, 14)
footer:SetText("Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy")

-- Join the Discord (bottom-left): a popup with the invite link selected, ready to copy
local DISCORD_LINK = "https://discord.gg/NprE8CErwP"

local function FillDiscordLink(eb)
    if not eb then return end
    eb:SetText(DISCORD_LINK)
    eb:SetFocus()
    eb:HighlightText()
end

local function DiscordEditBox(dialog)
    return dialog and (dialog.editBox or dialog.EditBox or (dialog.GetEditBox and dialog:GetEditBox()))
end

-- (The addon's own dialog: UI\Dialog.lua)
TTS.Dialog:Register("TTS_DISCORD_LINK", {
    text = "",
    button1 = OKAY or "Okay",
    hasEditBox = true,
    editBoxWidth = 260,
    OnShow = function(self)
        local eb = DiscordEditBox(self)
        FillDiscordLink(eb)
        -- Some clients clear the box after OnShow: fill it again next frame
        TTS:SafeAfter(0, function() FillDiscordLink(eb) end)
    end,
    -- Read-only: typing puts the link back
    EditBoxOnTextChanged = function(self, userInput)
        if userInput and self:GetText() ~= DISCORD_LINK then FillDiscordLink(self) end
    end,
    EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
})

local discordBtn = CreatePanelButton(nil, content, 72, 16, "main.discord")
discordBtn:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 18, 12)
discordBtn:SetScript("OnClick", function()
    StaticPopupDialogs["TTS_DISCORD_LINK"].text = L("main.discordPopup")
    TTS.Dialog:Popup("TTS_DISCORD_LINK")
end)

-- Shrinks the footer text until it fits between the Discord button and the right edge
local FOOTER_FONT, FOOTER_SIZE, FOOTER_FLAGS = footer:GetFont()
local function FitFooter()
    if not FOOTER_FONT then return end
    local room = (M:GetWidth() - 20) - (18 + discordBtn:GetWidth() + 8)
    local size = FOOTER_SIZE
    footer:SetFont(FOOTER_FONT, size, FOOTER_FLAGS)
    while footer:GetStringWidth() > room and size > 7 do
        size = size - 0.5
        footer:SetFont(FOOTER_FONT, size, FOOTER_FLAGS)
    end
end
FitFooter()
M:HookScript("OnShow", FitFooter)

-- Resizing: drag the bottom-right grip to scale the whole window (saved)
M:SetClampedToScreen(true)
TTS:AddScaleGrip(M, "mainScale")

-- =========================================================================
-- SLASH COMMAND
-- =========================================================================
SLASH_TRAGIC1 = "/tragic"

SlashCmdList["TRAGIC"] = function(msg)
    local cmd = (msg or ""):trim():lower()

    if cmd == "build" or cmd == "builder" or cmd == "deck" then
        if TTS.DeckBuilderFrame and TTS.DeckBuilderFrame.TryOpen then
            if TTS.DeckBuilderFrame:TryOpen() and TTS.MainFrame and TTS.MainFrame:IsShown() then
                TTS.MainFrame:Hide()
            end
        else
            DEFAULT_CHAT_FRAME:AddMessage(L("main.noDeckbuilder"))
        end
    elseif cmd == "board" or cmd == "game" then
        if TTS.BoardFrame then
            if TTS.BoardFrame:IsShown() then
                TTS.BoardFrame:Hide()
            else
                TTS.BoardFrame:Show()
            end
        end
    elseif cmd == "rules" or cmd == "rule" or cmd == "guide" then
        if TTS.RulesFrame then
            if TTS.RulesFrame:IsShown() then
                TTS.RulesFrame:Hide()
            else
                TTS.RulesFrame:Show()
            end
        else
            DEFAULT_CHAT_FRAME:AddMessage(L("main.noRules"))
        end
    elseif cmd:match("^lang") then
        -- /tragic lang [auto|enUS|deDE|...|pseudo]: choose a language (pseudo marks untranslated text)
        local choice = msg:trim():match("^%S+%s+(%S+)")
        if choice then
            if choice:lower() == "auto" or choice:lower() == "pseudo" then choice = choice:lower() end
            Loc:SetChoice(choice)
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD200[TTSE]|r " .. choice .. " - " .. L("locale.reload"))
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD200[TTSE]|r " .. L("options.language") .. ": " .. Loc:GetChoice() .. " (" .. Loc.code .. ")")
        end
    elseif cmd == "collection" or cmd == "cards" then
        -- The Collection Guide (CollectionGuide.lua)
        if TTS.CollectionGuide then
            local f = TTS.CollectionGuide.frame
            if f and f:IsShown() then f:Hide() else TTS.CollectionGuide:Open() end
        end
    elseif cmd == "pack" or cmd == "packs" or cmd:match("^packs? ") then
        -- Booster packs (Packs.lua, PackOpener.lua): /tragic pack opens the window, the rest test
        if TTS.Packs then TTS.Packs:SlashCommand(cmd:match("^packs?%s*(.*)$")) end
    elseif cmd == "critters" then
        -- How many critters this account has killed (Systems\Critters.lua), for testing
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD200[TTSE]|r Critters killed: " .. (TTS.Critters and TTS.Critters:Kills() or 0))
    elseif cmd == "resume" then
        -- A game saved by a /reload (Core\Resume.lua): offered again if the popup was closed
        if not (TTS.Resume and TTS.Resume:Offer()) then DEFAULT_CHAT_FRAME:AddMessage(L("resume.none")) end
    elseif cmd == "toast" or cmd:match("^toast ") then
        -- Tries out the card toasts (CardToast.lua); nothing is added to the collection
        if TTS.CardToast then TTS.CardToast:SlashCommand(msg:trim():match("^%S+%s*(.*)$")) end
    elseif cmd == "tutorial" then
        if TTS.StartTutorial then TTS:StartTutorial() end
    elseif cmd == "welcome" or cmd == "intro" or cmd == "quickstart" then
        -- The Quick Start walkthrough new players see first (QuickStart.lua)
        if TTS.ShowQuickStart then TTS:ShowQuickStart(1) end
    elseif cmd == "whatsnew" or cmd == "new" or cmd == "news" then
        -- What's new in this version (QuickStart.lua)
        if TTS.ShowWhatsNew then TTS:ShowWhatsNew(1) end
    elseif cmd == "campaign" or cmd == "solo" or cmd == "encounters" then
        if TTS.SoloSelectFrame then
            if TTS.SoloSelectFrame:IsShown() then
                TTS.SoloSelectFrame:Hide()
            else
                TTS.SoloSelectFrame:Show()
            end
        end
    elseif cmd == "daily" or cmd == "endless" or cmd == "eternity" or cmd == "draft" then
        -- The Daily challenge (DailyPanel.lua) and the Eternity Draft (Endless.lua; "endless" kept
        -- from before the rename)
        local win = (cmd == "daily") and TTS.DailyPanel or TTS.EndlessFrame
        if win then win:SetShown(not win:IsShown()) end
    elseif cmd == "queue" or cmd == "lfm" or cmd == "waiting" then
        if TTS.WaitingRoom and TTS.WaitingRoom.frame then
            if TTS.WaitingRoom.frame:IsShown() then
                TTS.WaitingRoom.frame:Hide()
            else
                TTS.WaitingRoom.frame:Show()
            end
        end
    else
        if TTS.MainFrame then
            if TTS.MainFrame:IsShown() then
                TTS.MainFrame:Hide()
            else
                TTS.MainFrame:Show()
            end
        end
    end
end