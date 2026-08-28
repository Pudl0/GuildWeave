-- Global table for the addon
GuildWeave = GuildWeave or {}

local Localization = GuildWeave.Localization

-- Guild name for the guild found mechanism
GuildWeave.name = _G.GetGuildInfo("player")
GuildWeave.displayName = GuildWeave.name or "GuildWeave"

GuildWeave.prefix    = "GuildWeave"
GuildWeave.colorCode = "|cFFF48CBA"
GuildWeave.version   = C_AddOns.GetAddOnMetadata("GuildWeave", "Version") or "Unknown"

function GuildWeave:PlayAnnouncementSound(standardId)
	PlaySound(standardId, GuildWeaveDB["sound_channel"])
end

GuildWeave.Global = {}

function GuildWeave.Global:Initialize()
	-- Register addon message prefix
	C_ChatInfo.RegisterAddonMessagePrefix(GuildWeave.prefix)

	-- Version checking handler
	local newestVersionSeen = GuildWeave.version
	GuildWeave.EventManager:RegisterHandler("CHAT_MSG_ADDON",
		function(_, prefix, message, _, sender)
			if prefix == GuildWeave.prefix then
				local incomingVersion = message:match("^VERSION:(.+)$")
				if incomingVersion then
					-- Store version of guild member
					if sender then
						GuildWeave.guildMemberVersions[sender] = incomingVersion
					end

					-- Check if incoming version is newer than the currently known newest version
					if GuildWeave:CompareVersions(incomingVersion, newestVersionSeen) > 0 then
						newestVersionSeen = incomingVersion
						GuildWeave:Print(string.format(Localization["VERSION_UPDATE"], newestVersionSeen))
					end
				elseif message == "VERSION_REQUEST" and IsInGuild() then
					-- Respond to version requests from already-online guild members
					C_ChatInfo.SendAddonMessage(GuildWeave.prefix, "VERSION:" .. GuildWeave.version, "GUILD")
				else
					local levelName, levelNum = message:match("^LEVELUP:(.+):(%d+)$")
					if levelName and levelNum and GuildWeave:IsValidGuildSender(sender) then
						GuildWeave.LevelUpAnnouncement:ShowMessage(levelName, tonumber(levelNum))
					end

					local capName, capNum = message:match("^CAP:(.+):(%d+)$")
					if capName and capNum and GuildWeave:IsValidGuildSender(sender) then
						GuildWeave.LevelUpAnnouncement:ShowCap(capName, tonumber(capNum))
					end

					-- Structured death message (guild chat parsing remains as fallback)
					if message:match("^DEATH|") and GuildWeave:IsValidGuildSender(sender) then
						local parts = GuildWeave:ParsePipeMessage(message)
						if #parts >= 5 then
							local senderShort = GuildWeave:RemoveRealmFromName(sender)
							if senderShort ~= UnitName("player") then
								local deathData = {
									name    = parts[2],
									class   = parts[3],
									level   = tonumber(parts[4]),
									zone    = parts[5],
									cause   = (parts[6] and parts[6] ~= "") and parts[6] or nil,
									pronoun = Localization["PRONOUN_2"],
								}
								local profile = GuildWeaveProfileCache and
									GuildWeaveProfileCache[senderShort]
								if profile then
									deathData.discordHandle = profile.discord
									profile.deaths = (profile.deaths or 0) + 1
								end
								GuildWeave.Death.ProcessDeath(deathData)
							end
						end
					end

					-- Remote death-counter set (officer action, sent via whisper)
					local deathSetValue = message:match("^DEATHSET|(.+)$")
					if deathSetValue and GuildWeave:IsValidGuildSender(sender) then
						GuildWeave.Death.HandleRemoteSet(tonumber(deathSetValue))
					end

					-- Profile sync messages
					GuildWeave.GuildProfiles:HandleMessage(sender, message)
				end
			end
		end, 0, "VersionChecker")

	-- Broadcast own version and request versions from already-online guild members
	if IsInGuild() then
		C_ChatInfo.SendAddonMessage(GuildWeave.prefix, "VERSION:" .. GuildWeave.version, "GUILD")
		C_ChatInfo.SendAddonMessage(GuildWeave.prefix, "VERSION_REQUEST", "GUILD")
	end
    C_GuildInfo.GuildRoster() -- Fetch guild roster to build cache.
end

-- Splits a pipe-delimited addon message string into a parts table.
function GuildWeave:ParsePipeMessage(message)
    local parts = {}
    for part in (message .. "|"):gmatch("([^|]*)|") do
        table.insert(parts, part)
    end
    return parts
end

function GuildWeave:SaveFramePosition(frame, dbKey)
    GuildWeaveDB = GuildWeaveDB or {}
    local point, _, relPoint, x, y = frame:GetPoint()
    GuildWeaveDB[dbKey] = { point = point, relPoint = relPoint, x = x, y = y }
end

function GuildWeave:RestoreFramePosition(frame, dbKey, defaultPoint, defaultX, defaultY)
    local saved = GuildWeaveDB and GuildWeaveDB[dbKey]
    if saved then
        frame:ClearAllPoints()
        frame:SetPoint(saved.point, UIParent, saved.relPoint, saved.x, saved.y)
    else
        frame:SetPoint(defaultPoint or "CENTER", UIParent, defaultPoint or "CENTER", defaultX or 0, defaultY or 0)
    end
end

function GuildWeave:Print(message)
    print(GuildWeave.colorCode .. "[" .. GuildWeave.displayName .. "]|r " .. message)
end

function GuildWeave:IsInBattleground()
    local inInstance, instanceType = IsInInstance()
    return inInstance and instanceType == GuildWeave.Constants.INSTANCE_TYPES.PVP
end

function GuildWeave:IsInRaid()
    local inInstance, instanceType = IsInInstance()
    return inInstance and instanceType == GuildWeave.Constants.INSTANCE_TYPES.RAID
end

function GuildWeave:IsInArena()
    local isArena, _ = IsActiveBattlefieldArena()
    return isArena
end

function GuildWeave:ParseVersion(v)
    local major, minor, patch = string.match(v, "(%d+)%.(%d+)%.?(%d*)")
    return tonumber(major or 0), tonumber(minor or 0), tonumber(patch or 0)
end

-- Returns >0 if v1 > v2; <0 if v1 < v2; 0 if equal.
function GuildWeave:CompareVersions(version1, version2)
    local major1, minor1, patch1 = GuildWeave:ParseVersion(version1)
    local major2, minor2, patch2 = GuildWeave:ParseVersion(version2)

    if major1 ~= major2 then return major1 - major2 end -- Compare major version.
    if minor1 ~= minor2 then return minor1 - minor2 end -- Compare minor version.
    return patch1 - patch2                              -- Compare patch version.
end


GuildWeave.guildMemberVersions = {}

local function GuildChatVersionFilter(_, _, msg, sender, ...)
    local modifiedMessage = msg

    -- Prepend guild public note (Gildeninfo) only if the option is explicitly enabled
    if GuildWeaveDB and GuildWeaveDB.show_discord_handle == true then
        local notePrefix = GuildWeave:GetGuildPublicNotePrefix(sender)
        if notePrefix ~= "" then
            modifiedMessage = notePrefix .. modifiedMessage
        end
    end

    -- Prepend stored addon version only if the option is explicitly enabled
    if GuildWeaveDB and GuildWeaveDB.show_version == true then
        local version = GuildWeave.guildMemberVersions[sender]
        if version then
            modifiedMessage = GuildWeave.colorCode .. "[" .. version .. "]|r " .. modifiedMessage
        end
    end

    return false, modifiedMessage, sender, ...
end

if not GuildWeave.guildChatFilterRegistered then
    local events = {
        "CHAT_MSG_GUILD",
        "CHAT_MSG_OFFICER",
        "CHAT_MSG_SAY",
        "CHAT_MSG_YELL",
        "CHAT_MSG_PARTY",
        "CHAT_MSG_PARTY_LEADER",
        "CHAT_MSG_INSTANCE_CHAT",
        "CHAT_MSG_INSTANCE_CHAT_LEADER",
        "CHAT_MSG_RAID",
        "CHAT_MSG_RAID_LEADER",
        "CHAT_MSG_WHISPER",
        "CHAT_MSG_CHANNEL",
    }
    for _, ev in ipairs(events) do
        ChatFrame_AddMessageEventFilter(ev, GuildChatVersionFilter)
    end
    GuildWeave.guildChatFilterRegistered = true
end

function GuildWeave:RemoveRealmFromName(fullName)
    return Ambiguate(fullName, "short")
end

-- Sanitizes text to prevent UI injection via escape codes
-- Removes texture, color, and hyperlink escape sequences
function GuildWeave:SanitizeText(text)
    if not text or type(text) ~= "string" then
        return text
    end
    -- Remove texture escape sequences |Tpath:height:width:...|t
    text = text:gsub("|T[^|]*|t", "")
    -- Remove color escape sequences |cFFFFFFFF...|r
    text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    -- Remove hyperlink escape sequences |Htype:data|h...|h
    text = text:gsub("|H[^|]*|h", "")
    text = text:gsub("|h", "")
    return text
end

function GuildWeave:GetGuildPublicNotePrefix(sender)
    if not sender then return "" end
    local shortName = GuildWeave:RemoveRealmFromName(sender)
    local profile = GuildWeaveProfileCache and GuildWeaveProfileCache[shortName]
    if profile and profile.discord and profile.discord ~= "" then
        return GuildWeave.colorCode .. "[" .. GuildWeave:SanitizeText(profile.discord) .. "]|r "
    end
    return ""
end

-- GuildCache lookup prevents spoofed GUILD-channel addon messages.
function GuildWeave:IsValidGuildSender(sender)
    if not sender then return false end
    local shortName = self:RemoveRealmFromName(sender)
    return GuildWeave.GuildCache:IsGuildMember(shortName)
end

-- Registers a frame so pressing Escape closes it, like a native Blizzard panel.
function GuildWeave:RegisterFrameForEscape(frame)
    if not frame or not frame.GetName or not UISpecialFrames then
        return
    end

    local frameName = frame:GetName()
    if not frameName or frameName == "" then
        return
    end

    for _, registeredName in ipairs(UISpecialFrames) do
        if registeredName == frameName then
            return
        end
    end

    table.insert(UISpecialFrames, frameName)
end

-- Closes a floating dropdown-style list on any click outside it, and whenever
-- ownerFrame (the popup/panel it belongs to) is hidden. listFrame must use a
-- higher strata than "FULLSCREEN_DIALOG" (e.g. "TOOLTIP") so the catcher never
-- swallows item clicks. excludeFrame (optional) lets clicks on that frame pass
-- through without closing the list — e.g. an EditBox the list is suggesting
-- against, so clicking it to keep typing doesn't fight the outside-click catcher.
function GuildWeave:RegisterOutsideClickClose(listFrame, ownerFrame, excludeFrame)
    local catcher = CreateFrame("Button", nil, UIParent)
    catcher:SetAllPoints(UIParent)
    catcher:SetFrameStrata("FULLSCREEN_DIALOG")
    catcher:EnableMouse(true)
    catcher:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    catcher:Hide()
    catcher:SetScript("OnClick", function()
        if excludeFrame and excludeFrame:IsMouseOver() then return end
        listFrame:Hide()
    end)

    listFrame:HookScript("OnShow", function() catcher:Show() end)
    listFrame:HookScript("OnHide", function() catcher:Hide() end)
    if ownerFrame then
        ownerFrame:HookScript("OnHide", function() listFrame:Hide() end)
    end
end

-- Closes a Blizzard UIDropDownMenuTemplate dropdown (context menu or combo box) on any
-- click outside it — needed because clicking another same/higher-strata addon frame
-- (e.g. our own panels) eats the click before Blizzard's own auto-close logic ever
-- sees it. onCloseFn (optional) runs extra cleanup whenever the dropdown closes.
function GuildWeave:RegisterDropdownAutoClose(dropdownFrame, onCloseFn)
    if not DropDownList1 then return end

    local catcher = CreateFrame("Button", nil, UIParent)
    catcher:SetAllPoints(UIParent)
    catcher:SetFrameStrata("DIALOG")
    catcher:EnableMouse(true)
    catcher:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    catcher:Hide()
    catcher:SetScript("OnClick", function() CloseDropDownMenus() end)

    DropDownList1:HookScript("OnShow", function()
        if UIDROPDOWNMENU_OPEN_MENU == dropdownFrame then
            catcher:Show()
        end
    end)
    DropDownList1:HookScript("OnHide", function()
        catcher:Hide()
        if onCloseFn then onCloseFn() end
    end)
end

