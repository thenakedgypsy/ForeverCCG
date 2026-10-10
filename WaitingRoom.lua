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

-- =========================================================================
-- WAITING ROOM UI WINDOW
-- =========================================================================
local F = CreateFrame("Frame", "TTS_WaitingRoomFrame", UIParent, backdropTemplate)
WR.frame = F
F:SetSize(380, 430)
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
statusDesc:SetPoint("TOPLEFT", 20, -48)
statusDesc:SetPoint("TOPRIGHT", -20, -48)
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
    row:SetSize(320, 26)
    row:SetPoint("TOPLEFT", 10, -8 - ((i - 1) * 28))

    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.nameText:SetPoint("LEFT", 6, 0)
    row.nameText:SetWidth(230)
    row.nameText:SetJustifyH("LEFT")
    row.nameText:SetWordWrap(false)
    row.nameText:SetText("")

    row.inviteBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.inviteBtn:SetSize(75, 20)
    row.inviteBtn:SetPoint("RIGHT", -6, 0)
    row.inviteBtn:SetText("Invite")

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
                row.inviteBtn:SetText("Queued")
                row.inviteBtn:Disable()
            else
                row.nameText:SetText(entry.name)
                row.inviteBtn:SetText("Invite")
                row.inviteBtn:Enable()
                row.inviteBtn:SetScript("OnClick", function()
                    if TTS.Net and TTS.Net.InvitePlayer then
                        TTS.Net:InvitePlayer(entry.name)
                    end
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
    end
end

function WR:ToggleQueue()
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

F:SetScript("OnShow", function()
    if TTS.Net and TTS.Net.BroadcastLFM then
        TTS.Net:BroadcastLFM("LFM_QUERY")
    end
    WR:UpdateUI()
end)

-- Heartbeat broadcast every 10 seconds
local ticker = 0
F:SetScript("OnUpdate", function(self, elapsed)
    ticker = ticker + elapsed
    if ticker >= 10 then
        ticker = 0
        if WR.isQueued then
            WR:BroadcastPresence()
        end
        WR:UpdateUI()
    end
end)
