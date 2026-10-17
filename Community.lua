--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}
local L = TTS.L

-- =========================================================================
-- FOREVER CCG COMMUNITY
-- FCCGTTSE only reaches players on our own backend realm; community chat reaches
-- every member. Joining the waiting room posts one readable line there, ending in
-- a tag the addon reads:
--   <sentence> [FCCG:Q:<score>:<A/H faction>:<ruleset>:<character name>:<waiting-room name>]
-- The character name (what whispers need) travels in the tag because a Battle.net
-- community shows authors by BattleTag. A Battle.net community spans every realm and both
-- factions, but whispers cross neither, so only clients of the same faction and realm
-- ruleset (PVE, PVP, RP, RPPVP) take the post: they add the poster as a contact and list
-- them as waiting. The ruleset is compared rather than the realm name, as the shards of
-- one realm may report different names. From then on the usual whisper pings keep them listed (Network.lua,
-- CONTACTS); challenges and matches never go through the community.
-- Only waiting-room joins post (a click, so allowed even if the server wants one),
-- at most once per POST_COOLDOWN, so the community chat stays readable.
-- =========================================================================
local C = {}
TTS.Community = C

-- The Battle.net community (clubType 0, so both factions); by id, so a rename doesn't matter.
-- Compared with tostring, so it matches whether the client gives ids as numbers or strings.
local COMMUNITY_ID = "23144891"
-- The invite's ticket, posted as a clickable chat link; the browser link is the fallback
local INVITE_TICKET = "MMoX03SMMn"
local INVITE_LINK = "https://blizzard.com/invite/" .. INVITE_TICKET
local POST_COOLDOWN = 600

local TAG_PATTERN = "%[FCCG:Q:(%d+):(%a?):(%a*):([^:%]]+):([^%]]+)%]%s*$"
local lastPost = -POST_COOLDOWN

-- "A", "H" or "" (unknown)
local function MyFaction()
    local faction = UnitFactionGroup and UnitFactionGroup("player")
    return faction == "Alliance" and "A" or faction == "Horde" and "H" or ""
end

-- "PVE", "PVP", "RP", "RPPVP" or "" (unknown), from the words of the realm name
-- ("Classic Beta PvP 2" -> "PVP", "Some Realm RP-PvP" -> "RPPVP")
local function MyRuleset()
    local words = {}
    for w in ((GetRealmName and GetRealmName()) or ""):gmatch("%w+") do words[w:upper()] = true end
    if words.RPPVP or (words.RP and words.PVP) then return "RPPVP" end
    if words.RP then return "RP" end
    if words.PVP then return "PVP" end
    if words.PVE then return "PVE" end
    return ""
end

-- Our character name, as whispers to us need it (no realm tag)
local function MyCharName()
    local name = UnitName("player") or ""
    return name:match("^([^%-]+)") or name
end

-- clubId, streamId of the community's first channel, or nil when we're not a member
function C:Stream()
    if not (C_Club and C_Club.GetSubscribedClubs and C_Club.GetStreams) then return nil end
    for _, club in ipairs(C_Club.GetSubscribedClubs() or {}) do
        if tostring(club.clubId) == COMMUNITY_ID then
            local streams = C_Club.GetStreams(club.clubId) or {}
            local first
            for _, s in ipairs(streams) do
                if not first or (tonumber(s.streamId) or 0) < (tonumber(first) or 0) then first = s.streamId end
            end
            -- Returned as the API gave them, for passing back to it
            if first then return club.clubId, first end
        end
    end
    return nil
end

function C:IsMember()
    return self:Stream() ~= nil
end

function C:InviteLink()
    return INVITE_LINK
end

-- Called when the player joins the waiting room
function C:AnnounceQueued()
    local clubId, streamId = self:Stream()
    if not clubId or not C_Club.SendMessage then return end
    if GetTime() - lastPost < POST_COOLDOWN then return end
    lastPost = GetTime()
    local name, score = TTS.GetPlayerFullName(), TTS.Net.MyScore()
    local text = L("community.lookingForMatch", name, TTS:FormatScore(score))
        .. " [FCCG:Q:" .. score .. ":" .. MyFaction() .. ":" .. MyRuleset() .. ":" .. MyCharName() .. ":" .. name .. "]"
    -- pcall: a client that refuses addon posts shouldn't break joining the queue
    pcall(C_Club.SendMessage, clubId, streamId, text)
end

-- Someone else's community post (also callable with a made-up post, to test alone)
function C:OnPost(content)
    local score, faction, ruleset, charName, name = content:match(TAG_PATTERN)
    if not name then return end
    -- Other factions and realms can't be whispered, so couldn't be reached or challenged
    -- (either side unknown: let it through)
    local myFaction, myRuleset = MyFaction(), MyRuleset()
    if faction ~= "" and myFaction ~= "" and faction ~= myFaction then return end
    if ruleset ~= "" and myRuleset ~= "" and ruleset ~= myRuleset then return end
    TTS.Net.NotePresence(name, charName, true, tonumber(score))
end

-- A message arrived in one of our communities
local function OnMessageAdded(clubId, streamId, messageId)
    local ourClub, ourStream = C:Stream()
    if not ourClub or tostring(clubId) ~= tostring(ourClub) or tostring(streamId) ~= tostring(ourStream) then return end
    local info = C_Club.GetMessageInfo and C_Club.GetMessageInfo(clubId, streamId, messageId)
    local author = info and info.author
    if not author or author.isSelf or type(info.content) ~= "string" then return end
    C:OnPost(info.content)
end

local f = CreateFrame("Frame")
f:RegisterEvent("CLUB_MESSAGE_ADDED")
f:RegisterEvent("CLUB_ADDED")
f:SetScript("OnEvent", function(_, event, ...)
    if event == "CLUB_MESSAGE_ADDED" then OnMessageAdded(...)
    elseif event == "CLUB_ADDED" then
        local clubId = ...
        if tostring(clubId) == COMMUNITY_ID then
            DEFAULT_CHAT_FRAME:AddMessage(L("community.joined"))
            if C.onMembershipChanged then C.onMembershipChanged() end
        end
    end
end)

-- The popup's edit box, under whichever name this client's popups use
local function PopupEditBox(dialog)
    return dialog and (dialog.editBox or dialog.EditBox or (dialog.GetEditBox and dialog:GetEditBox()))
end

-- Puts the link in the box, selected for copying
local function FillLink(eb)
    if not eb then return end
    eb:SetText(C:InviteLink())
    eb:SetFocus()
    eb:HighlightText()
end

-- Shows the invite link, selected for copying
StaticPopupDialogs["TTS_COMMUNITY_LINK"] = {
    text = "",
    button1 = OKAY or "Okay",
    hasEditBox = true,
    editBoxWidth = 350,
    OnShow = function(self)
        local eb = PopupEditBox(self)
        FillLink(eb)
        -- Some clients clear the box after OnShow: fill it again next frame
        TTS:SafeAfter(0, function() FillLink(eb) end)
    end,
    -- Read-only: typing puts the link back
    EditBoxOnTextChanged = function(self, userInput)
        if userInput and self:GetText() ~= C:InviteLink() then FillLink(self) end
    end,
    EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function C:ShowLink()
    -- The message is set here, so OnShow doesn't depend on the popup's text field name
    StaticPopupDialogs["TTS_COMMUNITY_LINK"].text = L("community.linkPopup")
    StaticPopup_Show("TTS_COMMUNITY_LINK")
end

-- The in-game invite as a chat hyperlink. Redeeming a ticket is protected, so the addon
-- can't join for the player; clicking this link runs Blizzard's own join dialog instead.
local function TicketChatLink()
    if GetClubTicketLink then
        local ok, link = pcall(GetClubTicketLink, INVITE_TICKET, "Forever CCG", 0)
        if ok and type(link) == "string" and link ~= "" then return link end
    end
    return "|cff82c5ff|HclubTicket:" .. INVITE_TICKET .. "|h[" .. L("community.linkText") .. "]|h|r"
end

-- The Community button: a clickable join link in chat, else the browser link
function C:ShowInvite()
    if not C_Club then
        self:ShowLink()
        return
    end
    DEFAULT_CHAT_FRAME:AddMessage(L("community.clickToJoin", TicketChatLink()))
end
