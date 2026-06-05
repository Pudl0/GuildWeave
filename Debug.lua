-- Debug.lua
-- Central debug module for developers
-- All debug commands are only available for players with the configured DEBUG_RANK.

GuildWeave.Debug = {}
local Localization = GuildWeave.Localization

-- Checks if the player has debug permission (officers and above)
function GuildWeave.Debug:HasPermission()
	return CanGuildRemove()
end

-- Shows a permission error message
local function ShowPermissionError()
	GuildWeave:Print(GuildWeave.Constants.COLORS.ERROR ..
		"Debug commands are available to officers and above.|r")
end

-- Initializes the debug module
function GuildWeave.Debug:Initialize()
	-- Debug mode toggle
	GuildWeave.Debug.enabled = false

	-- Main command: /gwdebug
	SLASH_GWDEBUG1 = '/gwdebug'
	SlashCmdList["GWDEBUG"] = function(msg)
		local args = {}
		for word in msg:gmatch("%S+") do
			table.insert(args, word)
		end

		local command = args[1] or "help"

		if command == "help" then
			GuildWeave.Debug:ShowHelp()
		elseif command == "rules" then
			GuildWeave.Debug:ShowRules()
		elseif command == "toggle" then
			GuildWeave.Debug:ToggleDebugMode()
		elseif command == "eventdebug" then
			GuildWeave.EventManager:DebugInfo()
		elseif command == "deathframe" then
			GuildWeave.Debug:TestDeathFrame()
		elseif command == "levelup" then
			GuildWeave.Debug:TestLevelUpFrame()
		elseif command == "cap" then
			GuildWeave.Debug:TestCapFrame()
		elseif command == "deathset" then
			local value = tonumber(args[2])
			if value then
				GuildWeave.Debug:SetDeathCount(value)
			else
				GuildWeave:Print(GuildWeave.Constants.COLORS.ERROR ..
					"Invalid number. Use: /gwdebug deathset <number>|r")
			end
		elseif command == "cachestats" then
			GuildWeave.Debug:ShowCacheStats()
		elseif command == "cacherefresh" then
			GuildWeave.GuildCache:ForceRefresh()
			GuildWeave:Print(GuildWeave.Constants.COLORS.SUCCESS .. "Guild cache refresh forced|r")
		else
			GuildWeave:Print(GuildWeave.Constants.COLORS.WARNING ..
				"Unknown command. Use /gwdebug help for help.|r")
		end
	end

	-- Alias: /gwd
	SLASH_GWD1 = '/gwd'
	SlashCmdList["GWD"] = SlashCmdList["GWDEBUG"]
end

-- Shows debug help
function GuildWeave.Debug:ShowHelp()
	print(GuildWeave.Constants.COLORS.INFO .. "=== GuildWeave Debug Commands ===" .. "|r")
	print(GuildWeave.colorCode .. "/gwdebug help" .. "|r - Shows this help")
	print(GuildWeave.colorCode .. "/gwdebug toggle" .. "|r - Enables/Disables debug mode")
	print(GuildWeave.colorCode .. "/gwdebug eventdebug" .. "|r - Shows EventManager debug info")
	print(GuildWeave.colorCode .. "/gwdebug deathframe" .. "|r - Test death announcement frame")
	print(GuildWeave.colorCode .. "/gwdebug levelup" .. "|r - Test level-up announcement frame")
	print(GuildWeave.colorCode .. "/gwdebug cap" .. "|r - Test cap announcement frame")
	print(GuildWeave.colorCode .. "/gwdebug deathset <number>" .. "|r - Sets the death counter")
	print(GuildWeave.colorCode .. "/gwdebug cachestats" .. "|r - Shows guild cache statistics")
	print(GuildWeave.colorCode .. "/gwdebug cacherefresh" .. "|r - Forces guild cache refresh")
	print(GuildWeave.Constants.COLORS.WARNING .. "Alias: /gwd <command>" .. "|r")
end

-- Shows active rules
function GuildWeave.Debug:ShowRules()
	print(GuildWeave.Constants.COLORS.INFO .. "=== GuildWeave Rules ===" .. "|r")
	print(GuildWeave.colorCode .. "Mailbox Rule: " .. GuildWeave.InfoRules.mailRule .. "|r")
	print(GuildWeave.colorCode .. "Auction House Rule: " .. GuildWeave.InfoRules.auctionHouseRule .. "|r")
	print(GuildWeave.colorCode .. "Trade Rule: " .. GuildWeave.InfoRules.tradeRule .. "|r")
	print(GuildWeave.colorCode .. "Grouping Rule: " .. GuildWeave.InfoRules.groupingRule .. "|r")
end

-- Enables/Disables debug mode
function GuildWeave.Debug:ToggleDebugMode()
	GuildWeave.Debug.enabled = not GuildWeave.Debug.enabled
	local status = GuildWeave.Debug.enabled and "enabled" or "disabled"
	GuildWeave:Print(GuildWeave.Constants.COLORS.SUCCESS ..
		"Debug mode " .. status .. "|r")
end

-- Tests the death announcement frame
function GuildWeave.Debug:TestDeathFrame()
	local testNames   = {"Aldric", "Seraphel", "Morthen", "Zuvira"}
	local testClasses = Localization["DEBUG_TEST_CLASSES"]
	local testZones   = Localization["DEBUG_TEST_ZONES"]

	local name = testNames[math.random(#testNames)]
	local class = testClasses[math.random(#testClasses)]
	local level = math.random(1, GuildWeave.Constants.MAX_LEVEL)
	local zone = testZones[math.random(#testZones)]

	local pronoun = Localization["PRONOUN_2"]
	GuildWeave.DeathAnnouncement:ShowDeathMessage(
		string.format(Localization["DEBUG_DEATH_MSG"], name, pronoun, class, level, zone))

	-- Add to death log (insert at position 1 so newest is first)
	GuildWeave.DeathLogData = GuildWeave.DeathLogData or {}
	table.insert(GuildWeave.DeathLogData, 1, {
		name = name,
		class = class,
		level = level,
		zone = zone,
		cause = Localization["DEBUG_DEATH_CAUSE"]
	})
	GuildWeave:UpdateDeathlog()

	GuildWeave:Print(GuildWeave.Constants.COLORS.SUCCESS ..
		"Test death frame shown for " .. name .. "|r")
end

-- Tests the level-up announcement frame
function GuildWeave.Debug:TestLevelUpFrame()
	local testNames = {"Aldric", "Seraphel", "Morthen", "Zuvira"}
	local name = testNames[math.random(#testNames)]
	local level = GuildWeave.Constants.LEVEL_MILESTONES[math.random(#GuildWeave.Constants.LEVEL_MILESTONES - 1)]

	GuildWeave.LevelUpAnnouncement:ShowMessage(name, level)

	GuildWeave:Print(GuildWeave.Constants.COLORS.SUCCESS ..
		"Test level-up frame shown for " .. name .. " (Level " .. level .. ")|r")
end

-- Tests the cap announcement frame
function GuildWeave.Debug:TestCapFrame()
	local testNames = {"Aldric", "Seraphel", "Morthen", "Zuvira"}
	local name = testNames[math.random(#testNames)]

	GuildWeave.LevelUpAnnouncement:ShowCap(name, GuildWeave.Constants.MAX_LEVEL)

	GuildWeave:Print(GuildWeave.Constants.COLORS.SUCCESS ..
		"Test cap frame shown for " .. name .. "|r")
end

-- Sets the death counter
function GuildWeave.Debug:SetDeathCount(value)
	if value < 0 or value > 999999 then
		GuildWeave:Print(GuildWeave.Constants.COLORS.ERROR ..
			"Value must be between 0 and 999999|r")
		return
	end

	CharacterDeaths = value
	GuildWeave:Print(GuildWeave.Constants.COLORS.SUCCESS ..
		"Death counter set to " .. CharacterDeaths .. "|r")
end

-- Shows guild cache statistics
function GuildWeave.Debug:ShowCacheStats()
	local stats = GuildWeave.GuildCache:GetStats()

	print(GuildWeave.Constants.COLORS.INFO .. "=== Guild Cache Statistics ===" .. "|r")
	print(string.format("Members in cache: %d", stats.memberCount))
	print(string.format("Last update: %.1f seconds ago", stats.age))
	print(string.format("Cache valid: %s", stats.isValid and "Yes" or "No"))

	if stats.isValid then
		print(string.format("Cache expires in: %.1f seconds", stats.expiresIn))
	else
		print(GuildWeave.Constants.COLORS.WARNING .. "Cache expired and will be updated on next access" .. "|r")
	end

	-- Show some online members as example
	local onlineMembers = GuildWeave.GuildCache:GetOnlineMembers()
	print(string.format("Online members: %d", #onlineMembers))

	print("=======================================")
end

-- Debug print function (only when debug mode is enabled)
function GuildWeave.Debug:Print(message)
	if GuildWeave.Debug.enabled then
		print(GuildWeave.Constants.COLORS.WARNING .. "[DEBUG]|r " .. message)
	end
end
