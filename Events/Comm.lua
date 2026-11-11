--[[
    ForeverCCG Events
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.
]]
local _, ns = ...
local B = ns.Bridge

-- =========================================================================
-- COMM
-- Addon whispers on a prefix of this addon's own. The server sets the sender of a whisper, so
-- nobody can report as someone else. Fields are separated by ":".
--
-- RELIABLE MESSAGES.  R:<id>:<body>  is answered  K:<id>  and sent again until it is. Every
-- handler is safe to run twice, so a repeat does no harm. A persisted message (a game result)
-- is kept in the saved variables and goes on being sent across a /reload or relog, in case the
-- organizer is offline when the game ends.
--
-- Player to organizer:
--   JOIN:<code>:<protocol>:<ccg version>:<rating>:<wins>:<losses>:<score>:<prize wait>
--   CHECKIN:<event>:<deck>:<prize wait>      DROP:<event>         STATUS:<event>:<want standings>
--   GAME:<event>:<round>:<table>:<game>:<deck>:<legal>
--   RESULT:<event>:<round>:<table>:<game>:<outcome>:<quiet>:<turns>:<deck>:<legal>
-- Organizer to player:
--   INFO:<event>:<format>:<best of>:<deck lock>:<round minutes>:<banned count>:<name>:<prizes>
--   (<prize wait>: seconds until the player can win a prize again, -1 = their ForeverCCG can't say)
--   BAN:<event>:<part>:<parts>:<card ids>
--   YOU:<event>:<rev>:<status>:<round>:<rounds>:<my status>:<table>:<opponent>:<match status>
--       :<my wins>:<their wins>:<seconds left>:<result>:<champion>:<note>
--   STAND:<event>:<rev>:<part>:<parts>:<rows>
--   REJECT:<reason>:<detail>          NOTE:<event>:<text>      GONE:<event>
-- =========================================================================
local Comm = {}
ns.Comm = Comm

Comm.PROTOCOL = 1
local PREFIX = "FCCG_EVT"

local SEND_BURST = 8        -- the server allows a prefix about 10 at once, then about 1 a second
local SEND_RATE = 1
local RETRY_TICK = 5        -- seconds between looks at the unanswered messages
local DEFAULT_RETRY = 25
local PERSIST_EXPIRY = 86400
local WHISPER_ERROR_WINDOW = 60

if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
    C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
elseif RegisterAddonMessagePrefix then
    RegisterAddonMessagePrefix(PREFIX)
end

local function IsSecret(v)
    return issecretvalue and issecretvalue(v) or false
end

-- Text safe to put in a field
function Comm.Clean(text)
    return (tostring(text or ""):gsub("[:|%c]", " "))
end

local function Split(text)
    local out, pos = {}, 1
    while true do
        local stop = text:find(":", pos, true)
        if not stop then
            out[#out + 1] = text:sub(pos)
            return out
        end
        out[#out + 1] = text:sub(pos, stop - 1)
        pos = stop + 1
    end
end

-- =========================================================================
-- PACED SENDING
-- =========================================================================
local queue = {}
local tokens = SEND_BURST
local lastRefill = GetTime()
local pumpScheduled = false
local inLoadingScreen = false
local recentWhispers = {}   -- [lower-case name] = until when its "No player named" is hidden

local RESULTS = Enum and Enum.SendAddonMessageResult
local WAIT_CODES = {
    [(RESULTS and RESULTS.AddonMessageThrottle) or 3] = true,
    [(RESULTS and RESULTS.AddOnMessageLockdown) or 11] = true,
}
local GENERAL_ERROR = (RESULTS and RESULTS.GeneralError) or 9   -- comes back around loading screens
local GENERAL_ERROR_TRIES = 3

-- True when the message is finished with; false to try it again shortly
local function RawSend(m)
    local send = (C_ChatInfo and C_ChatInfo.SendAddonMessage) or SendAddonMessage
    local result = send(PREFIX, m.msg, "WHISPER", m.target)
    if WAIT_CODES[result] then return false end
    if result == GENERAL_ERROR then
        m.tries = (m.tries or 0) + 1
        return m.tries >= GENERAL_ERROR_TRIES
    end
    return true
end

local function Pump()
    pumpScheduled = false
    if inLoadingScreen then return end
    local now = GetTime()
    tokens = math.min(SEND_BURST, tokens + (now - lastRefill) * SEND_RATE)
    lastRefill = now
    while tokens >= 1 and queue[1] do
        local m = queue[1]
        recentWhispers[B.Key(m.target)] = time() + WHISPER_ERROR_WINDOW
        if not RawSend(m) then
            tokens = 0
            break
        end
        table.remove(queue, 1)
        tokens = tokens - 1
    end
    if queue[1] then
        pumpScheduled = true
        C_Timer.After(1 / SEND_RATE, Pump)
    end
end

local function HideOfflineError(_, _, msg, ...)
    if IsSecret(msg) or type(msg) ~= "string" or not ERR_CHAT_PLAYER_NOT_FOUND_S then return false, msg, ... end
    local pattern = "^" .. ERR_CHAT_PLAYER_NOT_FOUND_S:lower():gsub("([%(%)%.%+%-%*%?%[%]%^%$])", "%%%1"):gsub("%%s", "(.+)") .. "$"
    local name = msg:lower():match(pattern)
    if name and (recentWhispers[B.Key(name)] or 0) > time() then return true end
    return false, msg, ...
end

do
    local add = ChatFrame_AddMessageEventFilter or (ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter)
    if add then add("CHAT_MSG_SYSTEM", HideOfflineError) end
end

-- =========================================================================
-- MESSAGES
-- =========================================================================
local handlers = {}

function Comm:On(cmd, fn)
    handlers[cmd] = fn
end

local function Run(cmd, parts, from)
    local fn = handlers[cmd]
    if not fn then return end
    local ok, err = pcall(fn, parts, from)
    if not ok then
        local onError = geterrorhandler and geterrorhandler()
        if onError then pcall(onError, err) end
    end
end

local pending = {}   -- [id] = { id, target, body, tries, max, interval, nextAt, key, persist, created }
local counter = 0

local function Forget(id)
    pending[id] = nil
    local box = ns.DB().outbox
    if box then box[id] = nil end
end

-- A message to ourselves (the organizer playing in their own event) never leaves the client
function Comm:Send(target, msg)
    if B.Key(target) == B.Key(B.MyName()) then
        C_Timer.After(0, function() Comm:Receive(msg, B.MyName()) end)
        return
    end
    queue[#queue + 1] = { msg = msg, target = B.NormalizeName(target) }
    if not pumpScheduled then Pump() end
end

function Comm:Receive(msg, from)
    local id, body = msg:match("^R:([^:]+):(.*)$")
    if id then
        self:Send(from, "K:" .. id)
        msg = body
    else
        local acked = msg:match("^K:([^:]+)$")
        if acked then
            local entry = pending[acked]
            if entry and B.SameName(entry.target, from) then
                Forget(acked)
                if entry.onAck then pcall(entry.onAck) end
            end
            return
        end
    end
    local parts = Split(msg)
    Run(parts[1], parts, from)
end

-- opts: key (a newer message with this key and target replaces the waiting one), persist,
-- max (tries before giving up, nil = keep trying), interval, onAck, onFail
function Comm:SendReliable(target, body, opts)
    opts = opts or {}
    if opts.key then
        for id, entry in pairs(pending) do
            if entry.key == opts.key and B.Key(entry.target) == B.Key(target) then Forget(id) end
        end
    end
    counter = counter + 1
    local id = string.format("%x%x", time() % 1048576, counter)
    local entry = { id = id, target = target, body = body, tries = 1, max = opts.max, key = opts.key,
        interval = opts.interval or DEFAULT_RETRY, nextAt = GetTime() + (opts.interval or DEFAULT_RETRY),
        persist = opts.persist, created = time(), onAck = opts.onAck, onFail = opts.onFail }
    pending[id] = entry
    if opts.persist then
        local db = ns.DB()
        db.outbox = db.outbox or {}
        db.outbox[id] = entry
    end
    self:Send(target, "R:" .. id .. ":" .. body)
end

local function RetryTick()
    if #queue > 30 then return end   -- what is already waiting comes first
    local now = GetTime()
    for id, entry in pairs(pending) do
        if entry.persist and time() - (entry.created or 0) > PERSIST_EXPIRY then
            Forget(id)
        elseif now >= entry.nextAt then
            if entry.max and entry.tries >= entry.max then
                Forget(id)
                if entry.onFail then pcall(entry.onFail) end
            else
                entry.tries = entry.tries + 1
                entry.nextAt = now + entry.interval
                Comm:Send(entry.target, "R:" .. id .. ":" .. entry.body)
            end
        end
    end
end

-- At login: pick up what was still unanswered
function Comm:Start()
    for id, entry in pairs(ns.DB().outbox or {}) do
        entry.nextAt = 0     -- a GetTime() from the last session means nothing now
        pending[id] = entry
    end
    C_Timer.NewTicker(RETRY_TICK, RetryTick)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:RegisterEvent("PLAYER_LEAVING_WORLD")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(_, event, prefix, msg, channel, sender)
    if event == "PLAYER_LEAVING_WORLD" then
        inLoadingScreen = true
    elseif event == "PLAYER_ENTERING_WORLD" then
        inLoadingScreen = false
        if queue[1] and not pumpScheduled then
            pumpScheduled = true
            C_Timer.After(1, Pump)
        end
    else
        if IsSecret(prefix) or IsSecret(msg) or IsSecret(channel) or IsSecret(sender) then return end
        if prefix ~= PREFIX or channel ~= "WHISPER" or type(msg) ~= "string" then return end
        Comm:Receive(msg, B.NormalizeName(sender))
    end
end)
