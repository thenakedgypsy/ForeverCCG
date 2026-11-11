--[[
    ForeverCCG Events
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.
]]
local _, ns = ...

-- =========================================================================
-- UI PARTS
-- Windows, buttons and scrolling lists shared by the organizer's and the player's windows.
-- =========================================================================
local UI = {}
ns.UI = UI

local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local refreshers = {}

function UI.AddRefresher(fn)
    refreshers[#refreshers + 1] = fn
end

function UI.Refresh()
    for _, fn in ipairs(refreshers) do fn() end
end

function UI.Window(globalName, width, height, title)
    local F = CreateFrame("Frame", globalName, UIParent, backdropTemplate)
    F:SetSize(width, height)
    F:SetPoint("CENTER")
    F:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    F:SetFrameStrata("DIALOG")
    F:EnableMouse(true)
    F:SetMovable(true)
    F:RegisterForDrag("LeftButton")
    F:SetScript("OnDragStart", F.StartMoving)
    F:SetScript("OnDragStop", F.StopMovingOrSizing)
    F:Hide()
    tinsert(UISpecialFrames, globalName)

    local bar = F:CreateTexture(nil, "ARTWORK")
    bar:SetPoint("TOPLEFT", 12, -12)
    bar:SetPoint("TOPRIGHT", -12, -12)
    bar:SetHeight(25)
    bar:SetColorTexture(0, 0, 0, 0.35)
    local line = F:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, 0)
    line:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, 0)
    line:SetHeight(1)
    line:SetColorTexture(1, 0.82, 0, 0.55)

    F.title = F:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    F.title:SetPoint("TOPLEFT", 18, -15)
    F.title:SetText(title)
    local close = CreateFrame("Button", nil, F, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)
    return F
end

function UI.Button(parent, text, width, height, onClick)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(width, height or 22)
    b:SetText(text)
    b:SetNormalFontObject("GameFontNormalSmall")
    b:SetHighlightFontObject("GameFontHighlightSmall")
    b:SetDisabledFontObject("GameFontDisableSmall")
    if onClick then b:SetScript("OnClick", onClick) end
    return b
end

function UI.Label(parent, font, x, y, width)
    local s = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlightSmall")
    if x then s:SetPoint("TOPLEFT", x, y) end
    if width then
        s:SetWidth(width)
        s:SetJustifyH("LEFT")
        s:SetWordWrap(false)
    end
    return s
end

function UI.Edit(parent, width, onEnter)
    local e = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    e:SetSize(width, 20)
    e:SetAutoFocus(false)
    e:SetScript("OnEscapePressed", e.ClearFocus)
    e:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        if onEnter then onEnter() end
    end)
    return e
end

-- =========================================================================
-- DROPDOWNS
-- One list, shared by every dropdown, opens under the one clicked. A click anywhere else
-- closes it, and so does hiding the dropdown (closing the window, changing tab). Made here
-- rather than with Blizzard's menu templates, which differ from one client to the next.
-- =========================================================================
local MENU_ROW = 18
local menu, catcher, menuOwner

local function CloseMenu()
    if menu then menu:Hide() end
end

local function MenuRow(i)
    local row = CreateFrame("Button", nil, menu)
    row:SetHeight(MENU_ROW)
    row:SetPoint("TOPLEFT", 5, -5 - (i - 1) * MENU_ROW)
    row:SetPoint("TOPRIGHT", -5, -5 - (i - 1) * MENU_ROW)
    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 0.82, 0, 0.18)
    row.check = row:CreateTexture(nil, "ARTWORK")
    row.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    row.check:SetSize(14, 14)
    row.check:SetPoint("LEFT", 2, 0)
    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.text:SetPoint("LEFT", 18, 0)
    row.text:SetPoint("RIGHT", -2, 0)
    row.text:SetJustifyH("LEFT")
    row.text:SetWordWrap(false)
    row:SetScript("OnClick", function(self)
        local owner = menuOwner
        CloseMenu()
        if owner then owner:Choose(self.index) end
    end)
    menu.rows[i] = row
    return row
end

local function MenuFrame()
    if menu then return menu end
    catcher = CreateFrame("Button", nil, UIParent)
    catcher:SetAllPoints(UIParent)
    catcher:SetFrameStrata("FULLSCREEN")
    catcher:RegisterForClicks("AnyUp")
    catcher:SetScript("OnClick", CloseMenu)
    catcher:Hide()

    menu = CreateFrame("Frame", nil, UIParent, backdropTemplate)
    menu:SetFrameStrata("FULLSCREEN_DIALOG")
    menu:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    menu:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    menu:EnableMouse(true)
    menu:SetClampedToScreen(true)
    menu.rows = {}
    menu:SetScript("OnHide", function()
        catcher:Hide()
        menuOwner = nil
    end)
    menu:Hide()
    return menu
end

local function OpenMenu(owner)
    local m = MenuFrame()
    if menuOwner == owner and m:IsShown() then
        CloseMenu()
        return
    end
    m:Hide()
    menuOwner = owner
    local options = owner.options
    for i, option in ipairs(options) do
        local row = m.rows[i] or MenuRow(i)
        row.index = i
        row.text:SetText(option[2])
        row.check:SetShown(i == owner.index)
        row:Show()
    end
    for i = #options + 1, #m.rows do m.rows[i]:Hide() end
    m:SetSize(math.max(owner:GetWidth(), 90), #options * MENU_ROW + 10)
    m:ClearAllPoints()
    m:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", 0, 2)
    catcher:Show()
    m:Show()
end

-- A dropdown: options are { { value, label }, ... }. onChange(value) runs when the player picks
-- a different option (not on SetValue).
function UI.Dropdown(parent, width, options, onChange)
    local b = UI.Button(parent, "", width, 22)
    b.options, b.index = options, 1

    local label = b:GetFontString()
    label:ClearAllPoints()
    label:SetPoint("LEFT", 8, 0)
    label:SetPoint("RIGHT", -20, 0)
    label:SetJustifyH("LEFT")
    label:SetWordWrap(false)
    local arrow = b:CreateTexture(nil, "OVERLAY")
    arrow:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
    arrow:SetSize(12, 12)
    arrow:SetPoint("RIGHT", -7, -2)

    local function Show()
        b:SetText(options[b.index][2])
    end
    function b:GetValue()
        return options[self.index][1]
    end
    function b:SetValue(value)
        for i, option in ipairs(options) do
            if option[1] == value then self.index = i end
        end
        Show()
    end
    function b:Choose(i)
        if not options[i] or i == self.index then return end
        self.index = i
        Show()
        if onChange then onChange(options[i][1]) end
    end
    local baseSetEnabled = b.SetEnabled
    function b:SetEnabled(on)
        baseSetEnabled(self, on)
        arrow:SetDesaturated(not on)
        if not on and menuOwner == self then CloseMenu() end
    end
    b:SetScript("OnClick", function(self) OpenMenu(self) end)
    b:HookScript("OnHide", function(self)
        if menuOwner == self then CloseMenu() end
    end)
    Show()
    return b
end

-- Rows on a mouse wheel. makeRow(row) builds a row once; fillRow(row, item) shows an item on it.
function UI.List(parent, x, y, width, rowHeight, count, makeRow, fillRow)
    local list = { data = {}, offset = 0, rows = {} }
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetPoint("TOPLEFT", x, y)
    holder:SetSize(width, rowHeight * count)
    holder:EnableMouseWheel(true)

    function list:Refresh()
        self.offset = math.max(0, math.min(self.offset, #self.data - count))
        for i, row in ipairs(self.rows) do
            local item = self.data[i + self.offset]
            row.item = item
            if item then
                fillRow(row, item)
                row:Show()
            else
                row:Hide()
            end
        end
    end

    function list:SetData(data)
        self.data = data
        self:Refresh()
    end

    holder:SetScript("OnMouseWheel", function(_, delta)
        list.offset = list.offset - delta * 3
        list:Refresh()
    end)

    for i = 1, count do
        local row = CreateFrame("Button", nil, holder)
        row:SetSize(width, rowHeight)
        row:SetPoint("TOPLEFT", 0, -(i - 1) * rowHeight)
        local highlight = row:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints()
        highlight:SetColorTexture(1, 0.82, 0, 0.12)
        makeRow(row)
        row:Hide()
        list.rows[i] = row
    end
    return list
end

StaticPopupDialogs["FCCGE_CONFIRM"] = {
    text = "%s",
    button1 = YES or "Yes",
    button2 = NO or "No",
    OnAccept = function(_, data)
        if data then data() end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function UI.Confirm(text, fn)
    StaticPopup_Show("FCCGE_CONFIRM", text, nil, fn)
end

-- A player's prize eligibility for the organizer's list: from the wait their client reported
-- (p.prizeWait seconds, at p.prizeHeard), counted down since
function UI.PrizeText(p)
    if p.manual then return UI.GREY .. "No addon|r" end
    if not p.prizeWait then return UI.GREY .. "Unknown|r" end
    local left = p.prizeWait - (ns.Now() - (p.prizeHeard or ns.Now()))
    if left <= 0 then return UI.GREEN .. "Prize eligible|r" end
    local days = math.ceil(left / 86400)
    return UI.ORANGE .. "Cooldown " .. days .. (days == 1 and " day" or " days") .. "|r"
end

-- "1:05" from seconds
function UI.Clock(seconds)
    seconds = math.max(0, math.floor(seconds))
    return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

UI.GREY, UI.RED, UI.ORANGE, UI.GREEN, UI.GOLD = "|cFF888888", "|cFFFF4444", "|cFFFF9933", "|cFF33DD33", "|cFFFFD200"

UI.STATUS_TEXT = {
    open = "Open for entries", checkin = "Check-in open", running = "Running", finished = "Finished",
}
UI.PLAYER_TEXT = {
    registered = "Joined", checkedin = "Checked in", active = "Playing", dropped = "Dropped", noshow = "No-show",
}
