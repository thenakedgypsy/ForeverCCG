--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
TTS.WaitingRoom = TTS.WaitingRoom or {
    isQueued = false,
    players = {}, -- [fullName] = lastSeenTimestamp
}

local WR = TTS.WaitingRoom
WR.scores = WR.scores or {}       -- [lowerName] = collection score (from LFM_SCORE; older builds don't send one)
WR.unitNames = WR.unitNames or {} -- [lowerName] = character name the announce came from, for party invites
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
F:SetSize(460, 430)
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
title:SetText("Forever: CCG - Waiting Room")

local closeBtn = CreateFrame("Button", nil, F, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -5, -5)

local statusDesc = F:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
statusDesc:SetPoint("TOPLEFT", 20, -42)
statusDesc:SetPoint("TOPRIGHT", -20, -42)
statusDesc:SetJustifyH("CENTER")
statusDesc:SetText("Players currently looking for a match:")

local listContainer = CreateFrame("Frame", nil, F, backdropTemplate)
listContainer:SetPoint("TOPLEFT", 20, -72)
listContainer:SetPoint("BOTTOMRIGHT", -20, 80)
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
    row:SetSize(400, 26)
    row:SetPoint("TOPLEFT", 10, -8 - ((i - 1) * 28))

    row.inviteBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.inviteBtn:SetSize(70, 20)
    row.inviteBtn:SetPoint("RIGHT", -6, 0)
    row.inviteBtn:SetText("Invite")

    row.partyBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.partyBtn:SetSize(84, 20)
    row.partyBtn:SetPoint("RIGHT", row.inviteBtn, "LEFT", -4, 0)
    row.partyBtn:SetText("Party Invite")

    row.scoreText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.scoreText:SetPoint("RIGHT", row.partyBtn, "LEFT", -8, 0)
    row.scoreText:SetWidth(70)
    row.scoreText:SetJustifyH("RIGHT")

    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.nameText:SetPoint("LEFT", 6, 0)
    row.nameText:SetPoint("RIGHT", row.scoreText, "LEFT", -6, 0)
    row.nameText:SetJustifyH("LEFT")
    row.nameText:SetWordWrap(false)
    row.nameText:SetText("")

    row:Hide()
    playerRows[i] = row
end

-- =========================================================================
-- BOTTOM ACTION BUTTONS
-- =========================================================================
local toggleBtn = CreateFrame("Button", nil, F, "UIPanelButtonTemplate")
toggleBtn:SetSize(180, 26)
toggleBtn:SetPoint("BOTTOM", 0, 42)
toggleBtn:SetText("Join Waiting Room")

local refreshBtn = CreateFrame("Button", nil, F, "UIPanelButtonTemplate")
refreshBtn:SetSize(100, 22)
refreshBtn:SetPoint("BOTTOM", 0, 14)
refreshBtn:SetText("Refresh")

-- Addon version (from the .toc), bottom-right corner
local versionText = F:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
versionText:SetPoint("BOTTOMRIGHT", F, "BOTTOMRIGHT", -16, 18)
versionText:SetJustifyH("RIGHT")

local function UpdateVersionText()
    versionText:SetText("v" .. (TTS.VERSION or "unknown"))
end

-- Column headers, above the list (rows sit 10px in from the list's left and right edges)
local function CreateColumnHeader(text, point, relPoint, x)
    local h = F:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    h:SetPoint(point, listContainer, relPoint, x, 2)
    h:SetText(text)
    return h
end
CreateColumnHeader("Player", "BOTTOMLEFT", "TOPLEFT", 16)
CreateColumnHeader("Collection Score", "BOTTOMRIGHT", "TOPRIGHT", -182)
CreateColumnHeader("Party", "BOTTOM", "TOPRIGHT", -132)       -- centred over the Party Invite buttons
CreateColumnHeader("Challenge", "BOTTOM", "TOPRIGHT", -51)    -- centred over the Invite buttons

-- =========================================================================
-- PARTY INVITES
-- =========================================================================
-- The character name to invite: the one their announce came from, else the first word
-- of their waiting-room name ("Firstname Surname" -> "Firstname")
local function PartyName(name)
    return WR.unitNames[name:lower()] or name:match("^(%S+)") or name
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
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[TTS]|r Party invite sent to " .. unitName .. ".")
end

-- =========================================================================
-- UI UPDATE & QUEUE TOGGLE
-- =========================================================================
function WR:UpdateUI()
    local myFullName = GetPlayerFullName()
    local myKey = myFullName:lower()

    if self.isQueued then
        toggleBtn:SetText("|cFFFF4444Leave Waiting Room|r")
    else
        toggleBtn:SetText("|cFF00FF00Join Waiting Room|r")
    end

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
        if (now - seenTime) <= 25 then
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
                row.nameText:SetText(string.format("|cFF00FF00%s (You)|r", entry.name))
                row.scoreText:SetText("|cFFFFFFFF" .. TTS:FormatScore(TTS.Net.MyScore()) .. "|r")
                row.inviteBtn:SetText("Queued")
                row.inviteBtn:Disable()
                row.partyBtn:Hide()
            else
                row.nameText:SetText(entry.name)
                local score = WR.scores[entry.name:lower()]
                row.scoreText:SetText(score and ("|cFFFFFFFF" .. TTS:FormatScore(score) .. "|r") or "|cFF888888-|r")
                -- A challenge just went out: no spamming (Network.lua, INVITE_COOLDOWN)
                local Net = TTS.Net
                local wait = Net and Net.InviteCooldownLeft and Net:InviteCooldownLeft() or 0
                if Net and Net.IsInvitePending and Net:IsInvitePending(entry.name) then
                    row.inviteBtn:SetText("Sent...")
                    row.inviteBtn:Disable()
                elseif wait > 0 then
                    row.inviteBtn:SetText(string.format("Invite (%d)", wait))
                    row.inviteBtn:Disable()
                else
                    row.inviteBtn:SetText("Invite")
                    row.inviteBtn:Enable()
                end
                row.inviteBtn:SetScript("OnClick", function()
                    if TTS.Net and TTS.Net.InvitePlayer then
                        TTS.Net:InvitePlayer(entry.name)
                    end
                end)
                row.partyBtn:Show()
                if InGroupWith(PartyName(entry.name)) then
                    row.partyBtn:SetText("In Party")
                    row.partyBtn:Disable()
                else
                    row.partyBtn:SetText("Party Invite")
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
end

function WR:BroadcastPresence()
    if TTS.Net and TTS.Net.BroadcastLFM then
        local myName = GetPlayerFullName()
        TTS.Net:BroadcastLFM("LFM_ANNOUNCE:" .. myName)
        -- Separate message so older builds, which read everything after LFM_ANNOUNCE: as the name, are unaffected
        TTS.Net:BroadcastLFM("LFM_SCORE:" .. TTS.Net.MyScore() .. ":" .. myName)
    end
end

function WR:ToggleQueue()
    -- The Deckbuilder is disabled while queued, so it must be closed before joining
    if not self.isQueued and TTS.DeckBuilderFrame and TTS.DeckBuilderFrame:IsShown() then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222[TTS]|r Close the Deckbuilder before joining the waiting room.")
        return
    end

    self.isQueued = not self.isQueued
    local myName = GetPlayerFullName()

    if self.isQueued then
        self:BroadcastPresence()
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[TTS]|r You joined the waiting room as " .. myName .. ".")
    else
        if TTS.Net and TTS.Net.BroadcastLFM then
            TTS.Net:BroadcastLFM("LFM_LEAVE:" .. myName)
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF4444[TTS]|r You left the waiting room.")
    end
    self:UpdateUI()

    -- Main menu's Deckbuilder button depends on the queue state
    if TTS.MainFrame and TTS.MainFrame.UpdatePlayState then
        TTS.MainFrame:UpdatePlayState()
    end
end

toggleBtn:SetScript("OnClick", function()
    WR:ToggleQueue()
end)

refreshBtn:SetScript("OnClick", function()
    if TTS.Net and TTS.Net.BroadcastLFM then
        TTS.Net:BroadcastLFM("LFM_QUERY")
    end
    WR:UpdateUI()
end)

F:SetScript("OnShow", function(self)
    -- The waiting room is unavailable during a game
    if TTS.Engine and TTS.Engine.inMatch then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222[TTS]|r The waiting room can't be opened during a game.")
        self:Hide()
        return
    end
    UpdateVersionText()
    if TTS.Net and TTS.Net.BroadcastLFM then
        TTS.Net:BroadcastLFM("LFM_QUERY")
    end
    -- Saved contacts may be on another backend realm, out of reach of the channel (Network.lua)
    if TTS.Net and TTS.Net.PingContacts then TTS.Net:PingContacts() end
    WR:UpdateUI()
end)

-- Heartbeat broadcast every 10 seconds
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
        if WR.isQueued then
            WR:BroadcastPresence()
        end
        if TTS.Net and TTS.Net.PingContacts then TTS.Net:PingContacts() end
        WR:UpdateUI()
    end
end)