--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
]]
TTS = TTS or {}
TTS.CollectionCode = TTS.CollectionCode or {}
local CC = TTS.CollectionCode
local L = TTS.L
local Loc = TTS.Locale

-- =========================================================================
-- COLLECTION CODE
-- The Deckbuilder's Export / Import buttons: the whole collection (TTS.COLLECTION_VARS,
-- DataStamp.lua, plus the beta flag) as one line of text to keep somewhere safe, and put
-- back later. Importing merges the code's collection into the current one (CC:Apply).
-- A code is bound to the character that made it ("name-realm"): the data is scrambled with
-- a keystream seeded from that name, a salt and a random nonce, and signed with a checksum
-- of the same, so on another character (or after any edit) it fails to read.
--   code = Encode( nonce(4) .. scrambled payload .. checksum(4) )
--   payload = { t = export time, beta = true|nil, vars = { [saved variable] = value } }
-- =========================================================================
local VERSION = 1
local SALT = "\70\67\67\71\175\23\201\94\12\120\140\61\233\8\118\27\164"
-- Not carried: which cards glow as new is only for the current session's eyes
local SKIP = { TTS_NewCards = true }

local TWO32 = 4294967296
local PM_MOD = 2147483647   -- Park-Miller keystream

-- Polynomial hash mod 2^32 (h * mult stays under 2^53, so doubles keep it exact)
local function Hash(s, h, mult)
    for i = 1, #s do
        h = (h * mult + s:byte(i) + i) % TWO32
    end
    return h
end

local function CharacterKey()
    local name = UnitName("player") or "?"
    local realm = (GetRealmName and GetRealmName() or ""):gsub("%s", "")
    return (name .. "-" .. realm):lower()
end

-- =========================================================================
-- SERIALIZE
--   {k v k v ...}   table      sN:bytes   string      iN;   integer
--   nX;   other number         t / f      booleans
-- Functions and other types are left out.
-- =========================================================================
local Ser

local function Writable(v)
    local t = type(v)
    return t == "table" or t == "string" or t == "number" or t == "boolean"
end

Ser = function(v, out)
    local t = type(v)
    if t == "table" then
        out[#out + 1] = "{"
        for k, x in pairs(v) do
            if Writable(k) and type(k) ~= "table" and Writable(x) then
                Ser(k, out)
                Ser(x, out)
            end
        end
        out[#out + 1] = "}"
    elseif t == "string" then
        out[#out + 1] = "s" .. #v .. ":" .. v
    elseif t == "number" then
        if v == math.floor(v) and math.abs(v) < 2 ^ 53 then
            out[#out + 1] = string.format("i%d;", v)
        else
            out[#out + 1] = string.format("n%.17g;", v)
        end
    elseif t == "boolean" then
        out[#out + 1] = v and "t" or "f"
    end
end

-- Returns the value and the position after it; errors on anything malformed
local function Parse(s, pos, depth)
    if depth > 20 then error("deep") end
    local c = s:sub(pos, pos)
    if c == "{" then
        local t = {}
        pos = pos + 1
        while s:sub(pos, pos) ~= "}" do
            if pos > #s then error("open") end
            local k, v
            k, pos = Parse(s, pos, depth + 1)
            v, pos = Parse(s, pos, depth + 1)
            if type(k) == "table" then error("key") end
            t[k] = v
        end
        return t, pos + 1
    elseif c == "s" then
        local colon = s:find(":", pos + 1, true)
        local len = colon and tonumber(s:sub(pos + 1, colon - 1))
        if not len or colon + len > #s then error("string") end
        return s:sub(colon + 1, colon + len), colon + len + 1
    elseif c == "i" or c == "n" then
        local semi = s:find(";", pos + 1, true)
        local n = semi and tonumber(s:sub(pos + 1, semi - 1))
        if not n or n ~= n then error("number") end
        return n, semi + 1
    elseif c == "t" then
        return true, pos + 1
    elseif c == "f" then
        return false, pos + 1
    end
    error("token")
end

-- =========================================================================
-- SCRAMBLE (each byte also depends on the one before it, so one change spoils the rest)
-- =========================================================================
local function Keystream(seed)
    local state = seed % (PM_MOD - 1) + 1
    return function()
        state = state * 16807 % PM_MOD
        return math.floor(state / 128) % 256
    end
end

local function Scramble(s, seed, undo)
    local nextKey, prev, out = Keystream(seed), 0, {}
    for i = 1, #s do
        local b = s:byte(i)
        local k = nextKey()
        local r
        if undo then
            r = (b - k - prev) % 256
            prev = b
        else
            r = (b + k + prev) % 256
            prev = r
        end
        out[i] = string.char(r)
    end
    return table.concat(out)
end

local function Uint32(n)
    return string.char(math.floor(n / 16777216) % 256, math.floor(n / 65536) % 256,
        math.floor(n / 256) % 256, n % 256)
end

local function ReadUint32(s, pos)
    local a, b, c, d = s:byte(pos, pos + 3)
    return ((a * 256 + b) * 256 + c) * 256 + d
end

local function Seed(nonce, who)
    return Hash(SALT .. who .. nonce .. VERSION, 5381, 33)
end

local function Checksum(plain, who)
    return Hash(who .. plain .. SALT, 761203, 1000003)
end

-- =========================================================================
-- TEXT (base64 over a shuffled alphabet)
-- =========================================================================
local ALPHABET = "Qw3eRt5yUi7oPa9sDf2gHj4kLz6xCv8bNmMnBV1cXZlKJhGFdSApOIuYTrEWq0+/"
local VALUE = {}
for i = 1, 64 do VALUE[ALPHABET:byte(i)] = i - 1 end

local function ToText(s)
    local out = {}
    for i = 1, #s, 3 do
        local a, b, c = s:byte(i, i + 2)
        local n = a * 65536 + (b or 0) * 256 + (c or 0)
        local chars = {}
        for j = 4, 1, -1 do
            chars[j] = ALPHABET:sub(n % 64 + 1, n % 64 + 1)
            n = math.floor(n / 64)
        end
        if not b then chars[3], chars[4] = "", ""
        elseif not c then chars[4] = "" end
        out[#out + 1] = table.concat(chars)
    end
    return table.concat(out)
end

local function FromText(text)
    local out = {}
    for i = 1, #text, 4 do
        local group = text:sub(i, i + 3)
        local n, count = 0, #group
        if count < 2 then return nil end
        for j = 1, 4 do
            local v = 0
            if j <= count then
                v = VALUE[group:byte(j)]
                if not v then return nil end
            end
            n = n * 64 + v
        end
        local a, b, c = math.floor(n / 65536), math.floor(n / 256) % 256, n % 256
        out[#out + 1] = string.char(a)
        if count >= 3 then out[#out + 1] = string.char(b) end
        if count >= 4 then out[#out + 1] = string.char(c) end
    end
    return table.concat(out)
end

-- =========================================================================
-- ENCODE / DECODE (a payload as a code bound to "who")
-- =========================================================================
local function Encode(payload, who)
    local out = {}
    Ser(payload, out)
    local plain = table.concat(out)
    local nonce = Uint32(math.random(0, 65535) * 65536 + math.random(0, 65535))
    return ToText(nonce .. Scramble(plain, Seed(nonce, who)) .. Uint32(Checksum(plain, who)))
end

local function DecodeAs(text, who)
    text = tostring(text or ""):gsub("%s", "")
    local raw = FromText(text)
    if not raw or #raw < 9 then return nil end
    local nonce = raw:sub(1, 4)
    local plain = Scramble(raw:sub(5, -5), Seed(nonce, who), true)
    if Checksum(plain, who) ~= ReadUint32(raw, #raw - 3) then return nil end
    local ok, payload, pos = pcall(Parse, plain, 1, 0)
    if not (ok and type(payload) == "table" and pos == #plain + 1 and type(payload.vars) == "table") then
        return nil
    end
    return payload
end

-- =========================================================================
-- EXPORT / IMPORT
-- =========================================================================
function CC:Export()
    local vars = {}
    for _, name in ipairs(TTS.COLLECTION_VARS or {}) do
        if not SKIP[name] and _G[name] ~= nil then vars[name] = _G[name] end
    end
    return Encode({
        t = time(),
        beta = (TTS_DataStamp and TTS_DataStamp.beta) and true or nil,
        vars = vars,
    }, CharacterKey())
end

-- The code's payload, or nil if it can't be read on this character
function CC:Decode(text)
    return DecodeAs(text, CharacterKey())
end

-- =========================================================================
-- SAVED DATA SIGNATURE AND RESET REPORT (DataStamp.lua)
-- The signature is a checksum of the saved data in a fixed form: keys sorted and fractions
-- rounded, so the same data always gives the same text however the client stored it.
-- A report code holds the data a reset cleared. It's bound to REPORT_KEY rather than a
-- character (character keys are "name-realm"), so no character can import it; it's read
-- outside the game (ForeverCCG_Tests\decode_report.lua).
-- =========================================================================
local SIGN_KEY = "#signature"
local REPORT_KEY = "#report"
local KEY_ORDER = { boolean = 1, number = 2, string = 3 }

local function KeyLess(a, b)
    local ta, tb = type(a), type(b)
    if ta ~= tb then return KEY_ORDER[ta] < KEY_ORDER[tb] end
    if ta == "boolean" then return b and not a end
    return a < b
end

local function Canon(v, out)
    local t = type(v)
    if t == "table" then
        local keys = {}
        for k, x in pairs(v) do
            if KEY_ORDER[type(k)] and Writable(x) then keys[#keys + 1] = k end
        end
        table.sort(keys, KeyLess)
        out[#out + 1] = "{"
        for _, k in ipairs(keys) do
            Canon(k, out)
            Canon(v[k], out)
        end
        out[#out + 1] = "}"
    elseif t == "number" then
        -- Every number alike, so 3 and a 3.0000000001 the client saved as 3 still match
        -- (and -0, which it may save as 0)
        out[#out + 1] = string.format("n%.4f;", v == 0 and 0 or v)
    elseif Writable(v) then
        Ser(v, out)
    else
        out[#out + 1] = "-"
    end
end

-- Checksum of the named saved variables, in order, plus "extra". Ones never set are left out,
-- so adding a name in an update doesn't change the signature of data saved before it.
function CC:Signature(names, extra)
    local out = {}
    for _, name in ipairs(names) do
        if _G[name] ~= nil then
            out[#out + 1] = "s" .. #name .. ":" .. name
            Canon(_G[name], out)
        end
    end
    Canon(extra, out)
    return Checksum(table.concat(out), SIGN_KEY)
end

-- payload = { t, who, reason, beta, vars = { [saved variable] = value } }
function CC:ReportCode(payload)
    payload.who = payload.who or CharacterKey()
    return Encode(payload, REPORT_KEY)
end

function CC:DecodeReport(text)
    return DecodeAs(text, REPORT_KEY)
end

-- Best of both, key by key: the higher number (copies, wins, and the later of two times, so
-- a gift or dungeon wait is never shortened), either true, tables merged the same way.
-- Anything else keeps the current value.
local function Merge(cur, inc)
    if type(cur) == "table" and type(inc) == "table" then
        for k, v in pairs(inc) do cur[k] = Merge(cur[k], v) end
        return cur
    end
    if cur == nil then return inc end
    if type(cur) == "number" and type(inc) == "number" then return math.max(cur, inc) end
    if type(cur) == "boolean" and type(inc) == "boolean" then return cur or inc end
    return cur
end

local function DeckIsEmpty(deck)
    return not (type(deck) == "table" and type(deck.cards) == "table" and next(deck.cards))
end

-- Lists that don't merge key by key
local MERGE = {
    -- Hero choices are in milestone order: the longer list has made more of them
    TTS_HeroChoices = function(cur, inc)
        if type(inc) == "table" and (type(cur) ~= "table" or #inc > #cur) then return inc end
        return cur
    end,
    -- Current decks stay; the code's fill only the slots that are empty
    TTS_SavedDecks = function(cur, inc)
        if type(cur) ~= "table" then return inc end
        for i, deck in pairs(type(inc) == "table" and inc or {}) do
            if DeckIsEmpty(cur[i]) and not DeckIsEmpty(deck) then cur[i] = deck end
        end
        return cur
    end,
    TTS_ActiveDeckIndex = function(cur, inc) return cur or inc end,
}

-- Merges a decoded payload into the collection (nothing owned is ever lost)
function CC:Apply(payload)
    for _, name in ipairs(TTS.COLLECTION_VARS or {}) do
        local inc = payload.vars[name]
        if not SKIP[name] and inc ~= nil then
            _G[name] = (MERGE[name] or Merge)(_G[name], inc)
        end
    end
    TTS_DataStamp = TTS_DataStamp or { launch = true }
    TTS_DataStamp.beta = (TTS_DataStamp.beta or payload.beta) and true or nil
    if TTS.EnsureDeckSlots then TTS:EnsureDeckSlots() end
    local DB = TTS.DeckBuilderFrame
    if DB and DB:IsShown() and DB.RefreshAll then DB:RefreshAll() end
    DEFAULT_CHAT_FRAME:AddMessage(L("cc.imported"))
end

-- =========================================================================
-- WINDOW (one window, three modes: "export" and "report" show a code, "import" takes one)
-- =========================================================================
local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local W

local function SelectAll()
    W.edit:SetFocus()
    W.edit:HighlightText()
end

local function SetHint(key, ...)
    Loc:Bind(W.hint, key, ...)
end

StaticPopupDialogs["TTS_IMPORT_COLLECTION"] = {
    text = "%s",
    button1 = ACCEPT or "Accept",
    button2 = CANCEL or "Cancel",
    OnAccept = function(_, payload)
        if not payload then return end
        CC:Apply(payload)
        if W then W:Hide() end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    showAlert = true,
    preferredIndex = 3,
}

local function TryImport()
    local payload = CC:Decode(W.edit:GetText())
    if not payload then
        SetHint("cc.invalid")
        return
    end
    local when = tonumber(payload.t) and date("%Y-%m-%d %H:%M", payload.t) or "?"
    local popup = StaticPopup_Show("TTS_IMPORT_COLLECTION", L("cc.confirm", when))
    if popup then popup.data = payload end
end

local function BuildWindow()
    W = CreateFrame("Frame", "TTS_CollectionCodeFrame", UIParent, backdropTemplate)
    W:SetSize(520, 300)
    W:SetPoint("CENTER")
    W:SetFrameStrata("FULLSCREEN_DIALOG")
    W:SetToplevel(true)
    W:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    W:EnableMouse(true)
    W:SetMovable(true)
    W:RegisterForDrag("LeftButton")
    W:SetScript("OnDragStart", W.StartMoving)
    W:SetScript("OnDragStop", W.StopMovingOrSizing)
    table.insert(UISpecialFrames, "TTS_CollectionCodeFrame")

    W.title = W:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    W.title:SetPoint("TOPLEFT", 18, -16)

    local close = CreateFrame("Button", nil, W, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    W.button = CreateFrame("Button", nil, W, "UIPanelButtonTemplate")
    W.button:SetSize(110, 22)
    W.button:SetPoint("BOTTOMRIGHT", -18, 16)
    W.button:SetScript("OnClick", function()
        if W.mode == "import" then TryImport() else SelectAll() end
    end)

    W.hint = W:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    W.hint:SetPoint("BOTTOMLEFT", 20, 21)
    W.hint:SetPoint("RIGHT", W.button, "LEFT", -10, 0)
    W.hint:SetJustifyH("LEFT")

    -- A dark, bordered box for the code: a click anywhere in it puts the cursor in the text
    local box = CreateFrame("Button", nil, W, backdropTemplate)
    box:SetPoint("TOPLEFT", 16, -40)
    box:SetPoint("BOTTOMRIGHT", -16, 44)
    box:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    box:SetBackdropColor(0, 0, 0, 0.8)
    box:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    box:SetScript("OnClick", function() W.edit:SetFocus() end)

    -- Shown while the import box is empty
    W.placeholder = box:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    W.placeholder:SetPoint("CENTER")
    W.placeholder:SetWidth(380)
    Loc:Bind(W.placeholder, "cc.pasteHere")

    local scroll = CreateFrame("ScrollFrame", "TTS_CollectionCodeScroll", box, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 8, -8)
    scroll:SetPoint("BOTTOMRIGHT", -28, 8)
    scroll:EnableMouse(true)
    scroll:SetScript("OnMouseDown", function() W.edit:SetFocus() end)

    local edit = CreateFrame("EditBox", nil, scroll)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(0)
    edit:SetFontObject(ChatFontSmall or GameFontHighlightSmall)
    edit:SetWidth(scroll:GetWidth() > 0 and scroll:GetWidth() or 460)
    edit:SetScript("OnEscapePressed", function() W:Hide() end)
    edit:SetScript("OnTextChanged", function(self, userInput)
        if not userInput then return end
        if W.mode ~= "import" then
            -- Read-only: typing puts the code back
            self:SetText(W.text)
            self:HighlightText()
        else
            SetHint("cc.importHint", UnitName("player") or "?")
        end
    end)
    edit:HookScript("OnTextChanged", function(self)
        W.placeholder:SetShown(W.mode == "import" and self:GetText() == "")
    end)
    scroll:SetScrollChild(edit)
    scroll:SetScript("OnSizeChanged", function(_, w) edit:SetWidth(w) end)
    W.edit = edit
    W.scroll = scroll
end

local function Open(mode, code)
    if not W then BuildWindow() end
    W.mode = mode
    local name = UnitName("player") or "?"
    if mode == "export" then
        W.text = CC:Export()
        Loc:Bind(W.title, "cc.exportTitle")
        Loc:Bind(W.button, "matchLog.selectAll")
        SetHint("cc.exportHint", name)
    elseif mode == "report" then
        W.text = code or ""
        Loc:Bind(W.title, "cc.reportTitle")
        Loc:Bind(W.button, "matchLog.selectAll")
        SetHint("cc.reportHint")
    else
        W.text = ""
        Loc:Bind(W.title, "cc.importTitle")
        Loc:Bind(W.button, "cc.import")
        SetHint("cc.importHint", name)
    end
    W.edit:SetText(W.text)
    W.placeholder:SetShown(mode == "import")
    W:Show()
    W.edit:SetCursorPosition(0)
    W.scroll:SetVerticalScroll(0)
    if mode == "import" then W.edit:SetFocus() else SelectAll() end
end

function CC:ShowExport() Open("export") end
function CC:ShowImport() Open("import") end
function CC:ShowReport(code) Open("report", code) end
