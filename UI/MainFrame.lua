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
-- this one back (unless a match has started in the meantime).
-- =========================================================================
local function OnChildHidden(child)
    if not child.ttsOpenedFromMain then return end
    child.ttsOpenedFromMain = nil
    -- Wait a frame: a window closed by a match starting should not bring this back
    TTS:SafeAfter(0, function()
        if child:IsShown() or M:IsShown() then return end
        if TTS.Engine and TTS.Engine.inMatch then return end
        -- Hidden for the deck picker: cancelling it may bring the window back, still ours
        if TTS.DeckPicker and TTS.DeckPicker:IsPending() then
            child.ttsOpenedFromMain = true
            return
        end
        -- Hidden behind a dialog of its own (the solo map's dungeon entry), which brings it back
        if child.ttsIsCovered and child.ttsIsCovered() then
            child.ttsOpenedFromMain = true
            return
        end
        M:Show()
    end)
end

local function OpenFromMain(child)
    if not child:IsShown() then return end   -- it refused to open
    if not child.ttsMainHooked then
        child.ttsMainHooked = true
        child:HookScript("OnHide", OnChildHidden)
    end
    child.ttsOpenedFromMain = true
    M:Hide()
end

-- Opens a window as if from the main window, so closing it comes back here (Board.lua: the
-- solo map after a solo encounter)
function M:OpenChild(child)
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
-- the header; two to a row (GRID_BTN_W). Battle's two columns (PvE, PvP) have a small
-- label each above their buttons.
-- =========================================================================
local SECTION_W, SECTION_GAP = 372, 8
local SIDE, BTN_H, BTN_GAP, FIRST_Y = 10, 24, 4, -32
local GRID_BTN_W = (SECTION_W - 2 * SIDE - 12) / 2     -- two to a row, 12 apart
local COLUMN_LABEL_H = 14                               -- Battle's PvE / PvP labels
local STATUS_Y = FIRST_Y - BTN_H - 8                    -- under Build's buttons
local CAMPFIRE_LINE_H = 16                             -- the campfire bonus line under Collect's button
local COLLECT_H = -FIRST_Y + BTN_H + CAMPFIRE_LINE_H + 10
local BUILD_H = -STATUS_Y + 34                          -- room for two lines of status
local PRIZE_LINE_H = 16                                -- the tournament prize line under PvP's buttons
local BATTLE_H = -FIRST_Y + COLUMN_LABEL_H + 3 * BTN_H + 2 * BTN_GAP + PRIZE_LINE_H + 10   -- three buttons (PvP's)

-- The window fits them: under the title strip, the sections, then room for the footer
M:SetHeight(93 + COLLECT_H + BUILD_H + BATTLE_H + 2 * SECTION_GAP + 34)

-- The y offset of button row `row` (1 = first) in a section, below `top` (default FIRST_Y)
local function RowY(row, top) return (top or FIRST_Y) - (row - 1) * (BTN_H + BTN_GAP) end

-- A small label over one of Battle's columns, its text and colour set by UpdatePlayState
local function ColumnLabel(section, anchor, x)
    local fs = section:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetPoint(anchor, section, anchor, x, FIRST_Y)
    fs:SetWidth(GRID_BTN_W)
    fs:SetJustifyH("CENTER")
    return fs
end

-- =========================================================================
-- COLLECT: the Collection Guide, and the collection score in the header
-- =========================================================================
local collectSection = CreateSection("main.collect", SECTION_W, COLLECT_H)
collectSection:SetPoint("TOPLEFT", M, "TOPLEFT", 14, -93)

-- Which cards each zone and dungeon holds, and how many of each you have (CollectionGuide.lua)
local guideBtn = CreatePanelButton("TTS_CollectionGuideBtn", collectSection, GRID_BTN_W, BTN_H, "main.collectionGuide")
guideBtn:SetPoint("TOP", collectSection, "TOP", 0, RowY(1))

-- Under it: the campfire bonus (more card drops), running or how long until the next
-- (UpdateTimers, below)
local campfireLabel = collectSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
campfireLabel:SetPoint("TOP", guideBtn, "BOTTOM", 0, -4)
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
-- BATTLE: PvE on the left (the campaign and the practice dummy), PvP on the right (the
-- waiting room, the only way to challenge other players; the record; tournaments), and
-- the PvP rating in the header
-- =========================================================================
local battleSection = CreateSection("main.battle", SECTION_W, BATTLE_H)
battleSection:SetPoint("TOPLEFT", buildSection, "BOTTOMLEFT", 0, -SECTION_GAP)
local BATTLE_TOP = FIRST_Y - COLUMN_LABEL_H   -- the first row, under the column labels
-- PvE coloured by the solo rewards won, PvP by the rating's tier (UpdatePlayState)
local pveLabel = ColumnLabel(battleSection, "TOPLEFT", SIDE)
local pvpLabel = ColumnLabel(battleSection, "TOPRIGHT", -SIDE)

local encountersBtn = CreatePanelButton("TTS_SoloEncountersBtn", battleSection, GRID_BTN_W, BTN_H, "main.campaign")
encountersBtn:SetPoint("TOPLEFT", battleSection, "TOPLEFT", SIDE, RowY(1, BATTLE_TOP))
encountersBtn:SetScript("OnClick", function()
    if TTS.SoloSelectFrame then
        TTS.SoloSelectFrame:Show()
        OpenFromMain(TTS.SoloSelectFrame)
    end
end)

local soloBtn = CreatePanelButton("TTS_SoloBtn", battleSection, GRID_BTN_W, BTN_H, "main.practice")
soloBtn:SetPoint("TOPLEFT", battleSection, "TOPLEFT", SIDE, RowY(2, BATTLE_TOP))

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
    -- (cancelling the deck picker brings the main window back; a game starting doesn't)
    OpenFromMain(TTS.DeckPicker)
end)

-- The tutorial game (UI\Tutorial.lua), under Practice: it brings its own decks
local tutorialBtn = CreatePanelButton("TTS_TutorialBtn", battleSection, GRID_BTN_W, BTN_H, "tut.play")
tutorialBtn:SetPoint("TOPLEFT", battleSection, "TOPLEFT", SIDE, RowY(3, BATTLE_TOP))
tutorialBtn:SetScript("OnClick", function()
    if not TTS.StartTutorial then return end
    TTS:StartTutorial()
    if TTS.Engine and TTS.Engine.inMatch then M:Hide() end
end)

local waitingRoomBtn = CreatePanelButton("TTS_WaitingRoomBtn", battleSection, GRID_BTN_W, BTN_H, "main.openWaitingRoom")
waitingRoomBtn:SetPoint("TOPRIGHT", battleSection, "TOPRIGHT", -SIDE, RowY(1, BATTLE_TOP))
waitingRoomBtn:SetScript("OnClick", function()
    if TTS.WaitingRoom and TTS.WaitingRoom.frame then
        TTS.WaitingRoom.frame:Show()
        OpenFromMain(TTS.WaitingRoom.frame)
    end
end)

-- The PvP rating, wins and losses, and the latest games (PvPRecord.lua)
local recordBtn = CreatePanelButton("TTS_PvPRecordBtn", battleSection, GRID_BTN_W, BTN_H, "main.pvpRecord")
recordBtn:SetPoint("TOPRIGHT", battleSection, "TOPRIGHT", -SIDE, RowY(2, BATTLE_TOP))
recordBtn:SetScript("OnClick", function()
    if TTS.PvP then OpenFromMain(TTS.PvP:Open()) end
end)

-- Tournaments (Events\): join one with a code, or host one
local tournamentBtn = CreatePanelButton("TTS_TournamentsBtn", battleSection, GRID_BTN_W, BTN_H, "main.tournaments")
tournamentBtn:SetPoint("TOPRIGHT", battleSection, "TOPRIGHT", -SIDE, RowY(3, BATTLE_TOP))

-- Under it (a minimap tooltip line too): the weekly tournament prize cooldown (UpdateTimers)
local timersLabel = battleSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
timersLabel:SetPoint("TOP", tournamentBtn, "BOTTOM", 0, -4)
timersLabel:SetWidth(GRID_BTN_W)
timersLabel:SetJustifyH("CENTER")
tournamentBtn:SetScript("OnClick", function()
    local win = TTS.OpenTournaments and TTS:OpenTournaments()
    if win then OpenFromMain(win) end
end)

-- PvP rating, right side of the section header (as the collection score is on Collect's)
local ratingLabel = battleSection:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
ratingLabel:SetPoint("TOPRIGHT", battleSection, "TOPRIGHT", -SIDE, -9)
ratingLabel:SetJustifyH("RIGHT")


-- =========================================================================
-- STATE UPDATER & LIFECYCLE (ENFORCING 40-50 CARDS)
-- =========================================================================
function M:UpdatePlayState()
    if TTS.GetCollectionScore then
        scoreLabel:SetText(L("main.score", TTS:ColoredScore((TTS:GetCollectionScore()))))
    end
    if TTS.PvP then
        ratingLabel:SetText(L("pvp.rating", TTS.PvP.ColoredRating((TTS.PvP:Get()))))
    end
    -- PvE in the score's colours by the share of solo reward copies won; PvP in the colour
    -- its rating number has (PvPRecord.lua's tiers)
    local gained, total = 0, 0
    if TTS.PvERewards then gained, total = TTS:PvERewards() end
    pveLabel:SetText(TTS.TierColored and TTS:TierColored(total > 0 and gained / total or 0, L("main.pve")) or L("main.pve"))
    local rated = TTS.PvP and TTS.PvP.ColoredRating((TTS.PvP:Get()))
    local colour = rated and rated:match("^|c(%x%x%x%x%x%x%x%x)")
    pvpLabel:SetText(colour and ("|c" .. colour .. L("main.playOthers") .. "|r") or L("main.playOthers"))

    local inMatch = TTS.Engine and TTS.Engine.inMatch
    local isQueued = TTS.WaitingRoom and TTS.WaitingRoom.isQueued
    local playable = TTS:PlayableDeckCount()

    -- The Deckbuilder cannot be opened while a game is in progress (it can while queued)
    deckBtn:SetEnabled(not inMatch)
    -- Solo encounters open whenever no game is running (the window explains anything else in the way)
    encountersBtn:SetEnabled(not inMatch)
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

-- The campfire and tournament prize lines: ready (green), or the time left (grey); while
-- the bonus runs, its minutes left (orange)
local GREEN, GREY, ORANGE = "|cFF1AFF1A", "|cFF999999", "|cFFFF9933"
local function UpdateTimers()
    local C = TTS.Campfire
    if C then
        local warmth = C:Remaining()
        local wait = C.CooldownLeft and C:CooldownLeft()
        local value = warmth and (ORANGE .. TTS:FormatWait(warmth) .. "|r")
            or wait and (GREY .. TTS:FormatWait(wait) .. "|r") or (GREEN .. L("minimap.ready") .. "|r")
        campfireLabel:SetText(L(warmth and "minimap.campfire" or "minimap.campfireNext") .. " " .. value)

    end
    if TTS.TournamentPrizeCooldown then
        local wait = TTS:TournamentPrizeCooldown()
        timersLabel:SetText(L("minimap.prize") .. " "
            .. (wait > 0 and (GREY .. TTS:FormatWait(wait) .. "|r") or (GREEN .. L("minimap.ready") .. "|r")))
    end
end

-- Counted down while the window is open
local timersTicker
M:SetScript("OnShow", function()
    M:UpdatePlayState()
    UpdateTimers()
    if timersTicker then timersTicker:Cancel() end
    timersTicker = C_Timer.NewTicker(30, UpdateTimers)
end)
M:HookScript("OnHide", function()
    if timersTicker then timersTicker:Cancel(); timersTicker = nil end
end)

-- =========================================================================
-- FOOTER
-- =========================================================================
local footer = content:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
footer:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -20, 14)
footer:SetText("Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy")

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
    elseif cmd == "tutorial" then
        if TTS.StartTutorial then TTS:StartTutorial() end
    elseif cmd == "welcome" or cmd == "intro" or cmd == "quickstart" then
        -- The Quick Start walkthrough new players see first (QuickStart.lua)
        if TTS.ShowQuickStart then TTS:ShowQuickStart(1) end
    elseif cmd == "campaign" or cmd == "solo" or cmd == "encounters" then
        if TTS.SoloSelectFrame then
            if TTS.SoloSelectFrame:IsShown() then
                TTS.SoloSelectFrame:Hide()
            else
                TTS.SoloSelectFrame:Show()
            end
        end
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