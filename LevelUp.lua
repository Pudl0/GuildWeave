-- LevelUp.lua
-- Handles level-up milestone announcements to guild chat

local Localization = GuildWeave.Localization
GuildWeave.LevelUps = {}

local function CheckForMilestone(level)
	-- Cap level takes priority; the cap announcement handles it instead
	if level >= GuildWeave.Rules.CurrentCap then return end

	for _, lvl in pairs(GuildWeave.Constants.LEVEL_MILESTONES) do
		if level == lvl then
			local player = UnitName("player")
			local handle = GuildWeave:GetDiscordHandle()
			local playerDisplay = (handle and handle ~= "") and (player .. " (" .. handle .. ")") or player
			local Message = string.format(Localization["LEVELUP_MSG"], playerDisplay, level)
			SendChatMessage(Message, "GUILD")
			C_ChatInfo.SendAddonMessage(GuildWeave.prefix, "LEVELUP:" .. player .. ":" .. level, "GUILD")
		end
	end
end

function GuildWeave.LevelUps:Initialize()
	GuildWeave.EventManager:RegisterHandler("PLAYER_LEVEL_UP",
		function(_, level)
			CheckForMilestone(level)
			GuildWeave.LevelUps:CheckForCap(level, true)
		end, 0, "LevelUpEvents")
end

function GuildWeave.LevelUps:CheckForCap(level, announce)
	if GuildWeave.Rules.CurrentCap == 0 or level == GuildWeave.Constants.MAX_LEVEL then return end
	if level >= GuildWeave.Rules.CurrentCap then
		local playerExp = UnitXP("player")
		local levelUpXP = UnitXPMax("player")
		local currentXPPercent = (levelUpXP > 0) and (playerExp / levelUpXP * 100) or 0
		GuildWeave.Popup:Show({
			title = Localization["CAP_POPUP_TITLE"],
			message = string.format(Localization["CAP_POPUP_MSG"], currentXPPercent, level + 1, GuildWeave.Rules.CurrentCap),
			displayTime = 8
		})

		if announce then
			local player = UnitName("player")
			local handle = GuildWeave:GetDiscordHandle()
			local playerDisplay = (handle and handle ~= "") and (player .. " (" .. handle .. ")") or player
			local capMessage = string.format(Localization["CAP_MSG"], playerDisplay, level)
			SendChatMessage(capMessage, "GUILD")
			C_ChatInfo.SendAddonMessage(GuildWeave.prefix, "CAP:" .. player .. ":" .. level, "GUILD")
		end
	end
end

