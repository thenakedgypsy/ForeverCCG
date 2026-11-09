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
TTS.WaitingRoom = TTS.WaitingRoom or {
    isQueued = false,
    players = {}, -- [fullName] = lastSeenTimestamp
}

local WR = TTS.WaitingRoom
-- Others drop a waiting player not heard from for this long (UpdateUI). Heartbeats arrive by
-- whisper, a few contacts at a time (BroadcastPresence), so this is longer than the beat.
local WAITING_EXPIRY = 90
WR.scores = WR.scores or {}       -- [lowerName] = collection score (from LFM_QUEUED, LFM_HERE and LFM_CENSUS)
WR.pvp = WR.pvp or {}             -- [lowerName] = { rating, wins, losses } (PvPRecord.lua), from the same messages
WR.pvp = WR.pvp or {}             -- [lowerName] = { rating, wins, losses } (PvPRecord.lua), from the same messages
local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil

-- =========================================================================
-- FULL NATIVE NAME RESOLUTION
-- =========================================================================
local function GetPlayerFullName()
    local fullName = nil

    -- 1. Try GetUnitName with realm flag (often returns full First Last in custom clients)
    if GetUnitName then
        local name = GetUnitName("player", true)
        if name and name ~= "" and name:find(" ") then
            fullName = name
        end
    end

    -- 2. Try UnitFullName
    if not fullName and UnitFullName then
        local first, last = UnitFullName("player")
        if first and last and last ~= "" and not last:find("%.") then
            -- Some versions return (name, realm); verify last isn't a realm
            if not GetRealmName or last ~= GetRealmName() then
                fullName = first .. " " .. last
            end
        elseif first and first:find(" ") then
            fullName = first
        end
    end

    -- 3. Check GameTooltip or UnitPVPName for native title/surname layout
    if not fullName and UnitPVPName then
        local pvpName = UnitPVPName("player")
        if pvpName and pvpName ~= "" and pvpName:find(" ") then
            fullName = pvpName
        end
    end

    -- 4. Native UnitName fallback
    if not fullName then
        fullName = UnitName("player") or "Unknown"
    end

    -- Strip realm suffixes (-RealmName) while strictly preserving internal spaces
    fullName = fullName:match("^([^%-]+)") or fullName
    return fullName:trim()
end
-- Network.lua uses this so match messages are addressed by the same name the waiting room shows
TTS.GetPlayerFullName = GetPlayerFullName

-- =========================================================================
-- WAITING ROOM UI WINDOW
-- =========================================================================
local F = CreateFrame("Frame", "TTS_WaitingRoomFrame", UIParent, backdropTemplate)
WR.frame = F
F:SetSize(520, 690)
F:SetPoint("CENTER", 50, 0)
F:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
F:EnableMouse(true)
F:SetMovable(true)
F:RegisterForDrag("LeftButton")
F:SetScript("OnDragStart", F.StartMoving)
F:SetScript("OnDragStop", F.StopMovingOrSizing)
F:Hide()

local title = F:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", 0, -18)
Loc:Bind(title, "wr.title")

-- The Forever: CCG logo in the top-left corner, beside the centred title
do
    local logo = F:CreateTexture(nil, "OVERLAY")
    logo:SetSize(28 * 350 / 85, 28)   -- the logo is 350 x 85
    logo:SetPoint("TOPLEFT", 16, -10)
    logo:SetTexture("Interface\\AddOns\\ForeverCCG\\Textures\\logo.png")
end

local closeBtn = CreateFrame("Button", nil, F, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -5, -5)

local statusDesc = F:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
statusDesc:SetPoint("TOPLEFT", 20, -42)
statusDesc:SetPoint("TOPRIGHT", -20, -42)
statusDesc:SetJustifyH("CENTER")
Loc:Bind(statusDesc, "wr.lookingForMatch")

local listContainer = CreateFrame("Frame", nil, F, backdropTemplate)
listContainer:SetPoint("TOPLEFT", 20, -72)
listContainer:SetPoint("TOPRIGHT", -20, -72)
listContainer:SetHeight(232)   -- 8 rows
listContainer:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
listContainer:SetBackdropColor(0, 0, 0, 0.5)
listContainer:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

local playerRows = {}
for i = 1, 8 do
    local row = CreateFrame("Frame", nil, listContainer)
    row:SetSize(460, 26)
    row:SetPoint("TOPLEFT", 10, -8 - ((i - 1) * 28))

    row.inviteBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.inviteBtn:SetSize(70, 20)
    row.inviteBtn:SetPoint("RIGHT", -6, 0)
    Loc:Bind(row.inviteBtn, "wr.invite")

    row.partyBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.partyBtn:SetSize(84, 20)
    row.partyBtn:SetPoint("RIGHT", row.inviteBtn, "LEFT", -4, 0)
    Loc:Bind(row.partyBtn, "wr.partyInvite")

    row.scoreText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.scoreText:SetPoint("RIGHT", row.partyBtn, "LEFT", -8, 0)
    row.scoreText:SetWidth(70)
    row.scoreText:SetJustifyH("RIGHT")

    row.ratingText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.ratingText:SetPoint("RIGHT", row.scoreText, "LEFT", -33, 0)   -- under its header (wr.colRating)
    row.ratingText:SetWidth(50)
    row.ratingText:SetJustifyH("RIGHT")

    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.nameText:SetPoint("LEFT", 6, 0)
    row.nameText:SetPoint("RIGHT", row.ratingText, "LEFT", -6, 0)
    row.nameText:SetJustifyH("LEFT")
    row.nameText:SetWordWrap(false)
    row.nameText:SetText("")

    row:Hide()
    playerRows[i] = row
end

-- =========================================================================
-- ONLINE BUT NOT WAITING (greyed out, display only)
-- Contacts who answered a ping recently but aren't queued (Network.lua, GetOnlineIdleContacts)
-- =========================================================================
local ONLINE_ROWS = 6

local onlineDesc = F:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
onlineDesc:SetPoint("TOPLEFT", listContainer, "BOTTOMLEFT", 0, -10)
onlineDesc:SetPoint("TOPRIGHT", listContainer, "BOTTOMRIGHT", 0, -10)
onlineDesc:SetJustifyH("CENTER")

local onlineContainer = CreateFrame("Frame", nil, F, backdropTemplate)
onlineContainer:SetPoint("TOPLEFT", listContainer, "BOTTOMLEFT", 0, -26)
onlineContainer:SetPoint("TOPRIGHT", listContainer, "BOTTOMRIGHT", 0, -26)
onlineContainer:SetHeight(8 + ONLINE_ROWS * 22)
onlineContainer:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
onlineContainer:SetBackdropColor(0, 0, 0, 0.3)
onlineContainer:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

local onlineRows = {}
for i = 1, ONLINE_ROWS do
    local row = CreateFrame("Frame", nil, onlineContainer)
    row:SetSize(460, 20)
    row:SetPoint("TOPLEFT", 10, -6 - ((i - 1) * 22))

    -- Lines up with the score column of the list above (its rows end with 158px of buttons)
    row.scoreText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.scoreText:SetPoint("RIGHT", -172, 0)
    row.scoreText:SetWidth(70)
    row.scoreText:SetJustifyH("RIGHT")

    row.ratingText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.ratingText:SetPoint("RIGHT", row.scoreText, "LEFT", -33, 0)   -- under its header (wr.colRating)
    row.ratingText:SetWidth(50)
    row.ratingText:SetJustifyH("RIGHT")

    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    row.nameText:SetPoint("LEFT", 6, 0)
    row.nameText:SetPoint("RIGHT", row.ratingText, "LEFT", -6, 0)
    row.nameText:SetJustifyH("LEFT")
    row.nameText:SetWordWrap(false)

    row:Hide()
    onlineRows[i] = row
end

local onlineEmpty = onlineContainer:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
onlineEmpty:SetPoint("CENTER")
Loc:Bind(onlineEmpty, "wr.nobodyOnline")
onlineEmpty:SetWidth(380)

local function UpdateOnlineList()
    local list = TTS.Net and TTS.Net.GetOnlineIdleContacts and TTS.Net:GetOnlineIdleContacts() or {}
    onlineDesc:SetText(L("wr.recentOnline", #list))
    onlineEmpty:SetShown(#list == 0)
    for i, row in ipairs(onlineRows) do
        local entry = list[i]
        if i == ONLINE_ROWS and #list > ONLINE_ROWS then
            row.nameText:SetText(L("wr.more", #list - ONLINE_ROWS + 1))
            row.scoreText:SetText("")
            row.ratingText:SetText("")
            row:Show()
        elseif entry then
            row.nameText:SetText(entry.name)
            row.scoreText:SetText(entry.score and TTS:ColoredScore(entry.score) or "-")
            row.ratingText:SetText(TTS.PvP.FormatRating(entry.pvp))
            row:Show()
        else
            row:Hide()
        end
    end
end

-- =========================================================================
-- GAMES IN PROGRESS
-- Players in a PvP game who answered when we opened this window (Spectate.lua)
-- =========================================================================
local GAME_ROWS = 4

local gamesDesc = F:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
gamesDesc:SetPoint("TOPLEFT", onlineContainer, "BOTTOMLEFT", 0, -10)
gamesDesc:SetPoint("TOPRIGHT", onlineContainer, "BOTTOMRIGHT", 0, -10)
gamesDesc:SetJustifyH("CENTER")

local gamesContainer = CreateFrame("Frame", nil, F, backdropTemplate)
gamesContainer:SetPoint("TOPLEFT", onlineContainer, "BOTTOMLEFT", 0, -26)
gamesContainer:SetPoint("TOPRIGHT", onlineContainer, "BOTTOMRIGHT", 0, -26)
gamesContainer:SetHeight(8 + GAME_ROWS * 26)
gamesContainer:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
gamesContainer:SetBackdropColor(0, 0, 0, 0.3)
gamesContainer:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

local gameRows = {}
for i = 1, GAME_ROWS do
    local row = CreateFrame("Frame", nil, gamesContainer)
    row:SetSize(460, 24)
    row:SetPoint("TOPLEFT", 10, -6 - ((i - 1) * 26))

    row.watchBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.watchBtn:SetSize(70, 20)
    row.watchBtn:SetPoint("RIGHT", -6, 0)

    row.turnText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.turnText:SetPoint("RIGHT", row.watchBtn, "LEFT", -8, 0)
    row.turnText:SetWidth(60)
    row.turnText:SetJustifyH("RIGHT")

    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.nameText:SetPoint("LEFT", 6, 0)
    row.nameText:SetPoint("RIGHT", row.turnText, "LEFT", -6, 0)
    row.nameText:SetJustifyH("LEFT")
    row.nameText:SetWordWrap(false)

    row:Hide()
    gameRows[i] = row
end

local gamesEmpty = gamesContainer:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
gamesEmpty:SetPoint("CENTER")
gamesEmpty:SetWidth(380)
Loc:Bind(gamesEmpty, "spec.wrNoGames")

local function UpdateGamesList()
    local Spec = TTS.Spectate
    local list = Spec and Spec:GetGames() or {}
    gamesDesc:SetText(L("spec.wrGames", #list))
    gamesEmpty:SetShown(#list == 0)
    for i, row in ipairs(gameRows) do
        local game = list[i]
        if game then
            row.nameText:SetText(L("spec.wrVs", game.a, game.b))
            row.turnText:SetText(L("spec.wrTurn", game.turn))
            local asked = Spec:IsAsking()
            row.watchBtn:SetText(L(asked == game.host and "spec.requested" or "spec.watch"))
            row.watchBtn:SetEnabled(not asked)
            row.watchBtn:SetScript("OnClick", function() Spec:Watch(game.host) end)
            row:Show()
        else
            row:Hide()
        end
    end
end

-- =========================================================================
-- BOTTOM ACTION BUTTONS
-- =========================================================================
local toggleBtn = CreateFrame("Button", nil, F, "UIPanelButtonTemplate")
toggleBtn:SetSize(180, 26)
toggleBtn:SetPoint("BOTTOM", 0, 42)
Loc:Bind(toggleBtn, "wr.join")

local refreshBtn = CreateFrame("Button", nil, F, "UIPanelButtonTemplate")
refreshBtn:SetSize(100, 22)
refreshBtn:SetPoint("BOTTOM", 0, 14)
Loc:Bind(refreshBtn, "wr.refresh")

-- Leave in red, Join in green
local function UpdateToggleButton()
    if WR.isQueued then
        toggleBtn:SetText("|cFFFF4444" .. L("wr.leave") .. "|r")
    else
        toggleBtn:SetText("|cFF00FF00" .. L("wr.join") .. "|r")
    end
end

-- Addon version (from the .toc), bottom-right corner
local versionText = F:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
versionText:SetPoint("BOTTOMRIGHT", F, "BOTTOMRIGHT", -16, 18)
versionText:SetJustifyH("RIGHT")

local function UpdateVersionText()
    versionText:SetText("v" .. (TTS.VERSION or "?"))
end

-- Column headers, above the list (rows sit 10px in from the list's left and right edges)
local function CreateColumnHeader(textKey, point, relPoint, x)
    local h = F:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    h:SetPoint(point, listContainer, relPoint, x, 2)
    Loc:Bind(h, textKey)
    return h
end
CreateColumnHeader("wr.colPlayer", "BOTTOMLEFT", "TOPLEFT", 16)
CreateColumnHeader("wr.colRating", "BOTTOMRIGHT", "TOPRIGHT", -285)   -- clear of the wider score header
CreateColumnHeader("wr.colScore", "BOTTOMRIGHT", "TOPRIGHT", -182)
CreateColumnHeader("wr.colParty", "BOTTOM", "TOPRIGHT", -132)       -- centred over the Party Invite buttons
CreateColumnHeader("wr.colChallenge", "BOTTOM", "TOPRIGHT", -51)    -- centred over the Invite buttons

-- =========================================================================
-- PARTY INVITES
-- =========================================================================
-- The name to invite: the full "Firstname Surname", like whispers (Network.lua, CharName)
local function PartyName(name)
    return TTS.Net.CharName(name)
end

local function InGroupWith(unitName)
    if UnitInParty and UnitInParty(unitName) then return true end
    if UnitInRaid and UnitInRaid(unitName) then return true end
    return false
end

local function InviteToParty(name)
    local unitName = PartyName(name)
    local invite = (C_PartyInfo and C_PartyInfo.InviteUnit) or InviteUnit
    if not invite then return end
    invite(unitName)
    DEFAULT_CHAT_FRAME:AddMessage(L("wr.partyInviteSent", unitName))
end

-- =========================================================================
-- UI UPDATE & QUEUE TOGGLE
-- =========================================================================
function WR:UpdateUI()
    local myFullName = GetPlayerFullName()
    local myKey = myFullName:lower()

    UpdateToggleButton()

    local now = time()
    local displayList = {}

    -- Display self at top when queued
    if self.isQueued then
        table.insert(displayList, {
            name = myFullName,
            isSelf = true
        })
    end

    for pName, seenTime in pairs(self.players) do
        if (now - seenTime) <= WAITING_EXPIRY then
            if pName:lower() ~= myKey then
                table.insert(displayList, {
                    name = pName,
                    isSelf = false
                })
            end
        else
            self.players[pName] = nil
        end
    end

    for i = 1, #playerRows do
        local row = playerRows[i]
        local entry = displayList[i]
        if entry then
            if entry.isSelf then
                row.nameText:SetText("|cFF00FF00" .. L("wr.you", entry.name) .. "|r")
                row.scoreText:SetText(TTS:ColoredScore(TTS.Net.MyScore()))
                row.ratingText:SetText(TTS.PvP.FormatRating({ rating = (TTS.PvP:Get()) }))
                row.inviteBtn:SetText(L("wr.queued"))
                row.inviteBtn:Disable()
                row.partyBtn:Hide()
            else
                row.nameText:SetText(entry.name)
                local score = WR.scores[entry.name:lower()]
                row.scoreText:SetText(score and TTS:ColoredScore(score) or "|cFF888888-|r")
                row.ratingText:SetText(TTS.PvP.FormatRating(WR.pvp[entry.name:lower()]))
                -- A challenge just went out: no spamming (Network.lua, INVITE_COOLDOWN)
                local Net = TTS.Net
                local wait = Net and Net.InviteCooldownLeft and Net:InviteCooldownLeft() or 0
                if Net and Net.IsInvitePending and Net:IsInvitePending(entry.name) then
                    row.inviteBtn:SetText(L("wr.sent"))
                    row.inviteBtn:Disable()
                elseif wait > 0 then
                    row.inviteBtn:SetText(L("wr.inviteWait", wait))
                    row.inviteBtn:Disable()
                else
                    row.inviteBtn:SetText(L("wr.invite"))
                    row.inviteBtn:Enable()
                end
                row.inviteBtn:SetScript("OnClick", function()
                    if TTS.Net and TTS.Net.InvitePlayer then
                        TTS.Net:InvitePlayer(entry.name)
                    end
                end)
                row.partyBtn:Show()
                if InGroupWith(PartyName(entry.name)) then
                    row.partyBtn:SetText(L("wr.inParty"))
                    row.partyBtn:Disable()
                else
                    row.partyBtn:SetText(L("wr.partyInvite"))
                    row.partyBtn:Enable()
                end
                row.partyBtn:SetScript("OnClick", function()
                    InviteToParty(entry.name)
                end)
            end
            row:Show()
        else
            row:Hide()
        end
    end

    UpdateOnlineList()
    UpdateGamesList()
end

-- The heartbeat whispers HEARTBEAT_WHISPERS online contacts each beat, in turn, so with a
-- lot of them each hears it less often than every beat (hence WAITING_EXPIRY); their own
-- pings fill the gaps
local HEARTBEAT_WHISPERS = 4
local JOIN_WHISPERS = 8

-- Our place in the queue, to party / guild and by whisper to online contacts (the channel
-- can't carry addon messages; Network.lua, CHANNEL LINES)
function WR:BroadcastPresence(whispers)
    if TTS.Net and TTS.Net.BroadcastLFM then
        local msg = "LFM_QUEUED:" .. TTS.Net.MyScore() .. ":" .. TTS.Net.MyPvP() .. ":" .. GetPlayerFullName()
        TTS.Net:BroadcastLFM(msg, true)
        TTS.Net:WhisperOnlineContacts(msg, whispers or HEARTBEAT_WHISPERS, "queued")
    end
end

-- fromClick: called from a click, so the channel line can be typed (Network.lua, SayInChannel);
-- a game starting or the deck check leave without one
function WR:ToggleQueue(fromClick)
    -- The deck is picked when a game starts, so any playable deck will do (and the
    -- Deckbuilder keeps at least one playable while queued)
    if not self.isQueued and TTS.Engine and not TTS.Engine:HasPlayableDeck() then
        DEFAULT_CHAT_FRAME:AddMessage(L("wr.needPlayableDeck"))
        return
    end

    self.isQueued = not self.isQueued
    local myName = GetPlayerFullName()

    if self.isQueued then
        -- Everyone on the channel hears this one, and those waiting whisper back
        if fromClick and TTS.Net and TTS.Net.SayHello then TTS.Net:SayHello() end
        self:BroadcastPresence(JOIN_WHISPERS)
        -- Reaches players on other backend realms, who FCCGTTSE doesn't (Community.lua)
        if TTS.Community then TTS.Community:AnnounceQueued() end
        DEFAULT_CHAT_FRAME:AddMessage(L("wr.joined", myName))
    else
        if fromClick and TTS.Net and TTS.Net.SayLeave then TTS.Net:SayLeave() end
        if TTS.Net and TTS.Net.BroadcastLFM then
            TTS.Net:BroadcastLFM("LFM_LEAVE:" .. myName)
            TTS.Net:WhisperOnlineContacts("LFM_LEAVE:" .. myName, JOIN_WHISPERS, "leave")
        end
        DEFAULT_CHAT_FRAME:AddMessage(L("wr.left"))
    end
    self:UpdateUI()

    -- Main menu's buttons and status line depend on the queue state
    if TTS.MainFrame and TTS.MainFrame.UpdatePlayState then
        TTS.MainFrame:UpdatePlayState()
    end
end

toggleBtn:SetScript("OnClick", function()
    WR:ToggleQueue(true)
end)

refreshBtn:SetScript("OnClick", function()
    if TTS.Net and TTS.Net.BroadcastLFM then
        TTS.Net:SayHello()
        TTS.Net:SendQuery()
    end
    WR:UpdateUI()
end)

F:SetScript("OnShow", function(self)
    -- The waiting room is unavailable during a game
    if TTS.Engine and TTS.Engine.inMatch then
        DEFAULT_CHAT_FRAME:AddMessage(L("minimap.wrInMatch"))
        self:Hide()
        return
    end
    UpdateVersionText()
    UpdateToggleButton()
    if TTS.Net and TTS.Net.BroadcastLFM then
        TTS.Net:SendQuery()
    end
    -- Saved contacts may be on another backend realm, out of reach of the channel (Network.lua)
    if TTS.Net and TTS.Net.PingContacts then TTS.Net:PingContacts() end
    -- Everyone else with the addon on our channel, queued or not
    if TTS.Net and TTS.Net.RunCensus then TTS.Net:RunCensus() end
    WR:UpdateUI()
end)

-- Opening the window says hello in the channel: everyone there whispers back (Network.lua,
-- CHANNEL LINES). On F:Show() rather than OnShow, which also fires when the whole UI comes
-- back (after a cinematic, say) - not a click, so typing into the channel would be blocked.
-- Every F:Show() comes from a click, key press or slash command (main window, minimap
-- button, Rules, /tragic queue).
hooksecurefunc(F, "Show", function()
    if TTS.Net and TTS.Net.SayHello and F:IsShown() then TTS.Net:SayHello() end
end)

-- Presence heartbeat every 10 seconds while queued. On its own frame because a queued
-- player can close the window (e.g. to use the Deckbuilder); others drop anyone not
-- heard from in WAITING_EXPIRY seconds (UpdateUI).
local heartbeat = CreateFrame("Frame")
local heartbeatTicker = 0
heartbeat:SetScript("OnUpdate", function(self, elapsed)
    heartbeatTicker = heartbeatTicker + elapsed
    if heartbeatTicker < 10 then return end
    heartbeatTicker = 0
    if not WR.isQueued then return end
    -- Safety net: cards lost from the collection can leave no deck playable
    if TTS.Engine and not TTS.Engine:HasPlayableDeck() then
        DEFAULT_CHAT_FRAME:AddMessage(L("wr.noPlayableDeckLeft"))
        WR:ToggleQueue()
        return
    end
    WR:BroadcastPresence()
end)

-- Pings, census and list refresh every 10 seconds while the window is open
local ticker = 0
local buttonTicker = 0
F:SetScript("OnUpdate", function(self, elapsed)
    ticker = ticker + elapsed
    -- Once a second while an invite cooldown counts down (or a challenge is retrying)
    buttonTicker = buttonTicker + elapsed
    if buttonTicker >= 1 then
        buttonTicker = 0
        local Net = TTS.Net
        if Net and Net.InviteCooldownLeft and (Net:InviteCooldownLeft() > 0 or next(Net.pendingInvites) or Net.inviteUIStale) then
            -- One extra refresh after it all clears, so the buttons re-enable
            Net.inviteUIStale = (Net:InviteCooldownLeft() > 0 or next(Net.pendingInvites)) and true or nil
            WR:UpdateUI()
        end
    end
    if ticker >= 10 then
        ticker = 0
        if TTS.Net and TTS.Net.PingContacts then TTS.Net:PingContacts() end
        if TTS.Net and TTS.Net.RunCensus then TTS.Net:RunCensus() end
        WR:UpdateUI()
    end
end)