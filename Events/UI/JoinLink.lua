--[[
    ForeverCCG Events
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.
]]
local _, ns = ...
local UI, P = ns.UI, ns.Player

-- =========================================================================
-- JOIN LINKS IN CHAT
-- The organizer's Announce (Host.lua) puts "[Forever CCG event: <code> <organizer>]" in chat.
-- The server won't pass custom hyperlinks, so it travels as plain text (anyone without the
-- addon sees it, and the /fccgevents command beside it). With the addon, a chat filter turns
-- it into a gold [Join <organizer>'s tournament] link (|Hgarrmission:ForeverCCG:event:<code>:
-- <organizer>|h, the same borrowed link type as card links, UI\CardLinks.lua): a click joins
-- the event and opens the player's window.
-- =========================================================================
local TAG_PATTERN = "%[Forever CCG event: (%w+) ([^%]%s]+)%]"
local LINK_PREFIX = "garrmission:ForeverCCG:event:"

-- The tag an announcement carries
function UI.JoinTag(code, organizer)
    return "[Forever CCG event: " .. code .. " " .. organizer .. "]"
end

local function Short(name) return (name:match("^([^%-]+)") or name) end

local function ReplaceTag(code, organizer)
    return "|cFFFFD200|H" .. LINK_PREFIX .. code .. ":" .. organizer .. "|h[Join " .. Short(organizer)
        .. "'s tournament]|h|r"
end

local function ChatFilter(_, _, msg, ...)
    if (issecretvalue and issecretvalue(msg)) or type(msg) ~= "string"
        or not msg:find("[Forever CCG event: ", 1, true) then
        return false
    end
    return false, (msg:gsub(TAG_PATTERN, ReplaceTag)), ...
end

local CHAT_EVENTS = {
    "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_EMOTE",
    "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_WHISPER_INFORM",
    "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_CHANNEL", "CHAT_MSG_COMMUNITIES_CHANNEL",
}
if ChatFrame_AddMessageEventFilter then
    for _, event in ipairs(CHAT_EVENTS) do ChatFrame_AddMessageEventFilter(event, ChatFilter) end
end

-- A secure post-hook on SetItemRef, as card links do: Blizzard's handler runs untouched, then
-- we act on our own links
local function OnLinkClicked(link)
    if type(link) ~= "string" or link:sub(1, #LINK_PREFIX) ~= LINK_PREFIX then return end
    local code, organizer = link:sub(#LINK_PREFIX + 1):match("^(%w+):(.+)$")
    if not (code and organizer) then return end
    local j = P:Joined()
    if j then
        -- Already in an event: show it rather than leave it
        UI.OpenPlayer()
        return
    end
    P:Join(code, organizer)
    UI.OpenPlayer()
end
if hooksecurefunc and SetItemRef then
    hooksecurefunc("SetItemRef", OnLinkClicked)
end
