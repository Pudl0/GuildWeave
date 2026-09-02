-- Initialize the Death module in the GuildWeave namespace
local Localization = GuildWeave.Localization
GuildWeave.Death = {
	lastChatMessage = "",
	lastAttackSource = "",
	MAX_LOG_ENTRIES = 50  -- Maximum number of stored deaths
}

-- Initialize CharacterDeaths to avoid nil reference
CharacterDeaths = CharacterDeaths or 0

-- Cooldown for sending own death to guild (seconds)
local lastOwnDeathSendTime = 0

-- Session-based death log (NOT persisted, only during session)
-- This prevents out-of-sync issues when players are offline
GuildWeave.DeathLogData = {}

-- Track deaths we've already processed to prevent duplicates
local seenDeaths = {}

-- CLEU's environmentalType field is one of this fixed Blizzard-defined set; it has no
-- combat log source unit, so it needs its own display text instead of a sourceName.
local ENVIRONMENTAL_CAUSE_KEYS = {
	Falling  = "DEATH_CAUSE_FALLING",
	Drowning = "DEATH_CAUSE_DROWNING",
	Fatigue  = "DEATH_CAUSE_FATIGUE",
	Fire     = "DEATH_CAUSE_FIRE",
	Lava     = "DEATH_CAUSE_LAVA",
	Slime    = "DEATH_CAUSE_SLIME",
}

-- Function to add an entry to the death log with rotation
function GuildWeave.Death:AddLogEntry(entry)
	table.insert(GuildWeave.DeathLogData, 1, entry)

	-- Rotation: Keep only the last MAX_LOG_ENTRIES entries
	while #GuildWeave.DeathLogData > GuildWeave.Death.MAX_LOG_ENTRIES do
		table.remove(GuildWeave.DeathLogData)
	end
end


-- Process a death (from guild chat parsing or addon messages)
local function processDeath(data, isOwnDeath)
	-- Create unique ID to prevent duplicates (bucket to 5s to handle dual-path latency)
	local deathID = data.name .. "-" .. data.level .. "-" .. data.zone .. "-" .. math.floor(time() / 5)
	if seenDeaths[deathID] then
		return
	end
	seenDeaths[deathID] = true

	-- Add to death log
	local deathEntry = {
		name = data.name,
		class = data.class,
		level = data.level,
		zone = data.zone,
		cause = data.cause or Localization["DEATH_UNKNOWN"],
		lastWords = data.lastWords,
		discordHandle = data.discordHandle,
		timestamp = time()
	}
	GuildWeave.Death:AddLogEntry(deathEntry)

	-- Update UI
	GuildWeave:UpdateDeathlog()

	-- Show a death announcement for other players only — your own death is
	-- recorded in the log above but never pops an announcement at you.
	-- Use the compact top-right notice when the viewer is inside any instance
	-- (dungeon/raid/BG) or has opted into it, so a full-screen popup never lands mid-pull.
	if not isOwnDeath then
		if GuildWeaveDB["deathframe_always_small"] or IsInInstance() then
			GuildWeave.DeathAnnouncement:ShowSmallDeathMessage(data.name)
		else
			local pronoun = data.pronoun or "der"
			local messageString
			if data.discordHandle and data.discordHandle ~= "" then
				messageString = string.format(Localization["DEATH_MSG_DISCORD"],
					data.name, data.discordHandle, pronoun, data.class, data.level, data.zone)
			else
				messageString = string.format(Localization["DEATH_MSG"],
					data.name, pronoun, data.class, data.level, data.zone)
			end
			GuildWeave.DeathAnnouncement:ShowDeathMessage(messageString)
		end
	end
end

-- Public wrapper for use from other modules (e.g. Global.lua addon message handler)
GuildWeave.Death.ProcessDeath = function(data)
	processDeath(data, false)
end

-- Initializes the Death module and registers events
function GuildWeave.Death:Initialize()
	local playerName = UnitName("player")

	-- PLAYER_DEAD event handler
	GuildWeave.EventManager:RegisterHandler("PLAYER_DEAD",
		function()
			local name = UnitName("player")
			if not name then return end

			local _, rank = GetGuildInfo("player")
			local class = UnitClass("player")
			local level = UnitLevel("player")
			local sex = UnitSex("player")

			local inPvP = GuildWeave:IsInBattleground() or GuildWeave:IsInRaid() or GuildWeave:IsInArena()

			-- Safe zone query with error handling
			local zone, mapID
			if IsInInstance() then
				zone = GetInstanceInfo()
			else
				mapID = C_Map.GetBestMapForUnit("player")
				if mapID then
					local mapInfo = C_Map.GetMapInfo(mapID)
					zone = mapInfo and mapInfo.name or "Unknown"
				else
					zone = "Unknown"
				end
			end

			local pronoun = Localization["PRONOUN_" .. sex] or Localization["PRONOUN_1"]

			-- Get Discord handle for death message
			local discordHandle = GuildWeave:GetDiscordHandle()

			-- Build death message with optional Discord handle
			local messageString
			if discordHandle and discordHandle ~= "" then
				messageString = string.format(Localization["DEATH_MSG_DISCORD"],
					name, discordHandle, pronoun, class, level, zone)
			else
				messageString = string.format(Localization["DEATH_MSG"],
					name, pronoun, class, level, zone)
			end

			-- Store cause and last words before adding to message (for own death log entry)
			local deathCause = nil
			local deathLastWords = nil

			if GuildWeave.Death.lastAttackSource and GuildWeave.Death.lastAttackSource ~= "" then
				deathCause = GuildWeave.Death.lastAttackSource
				messageString = messageString .. string.format(Localization["DEATH_CAUSE"], GuildWeave.Death.lastAttackSource)
				GuildWeave.Death.lastAttackSource = ""
			end

			if GuildWeave.Death.lastChatMessage and GuildWeave.Death.lastChatMessage ~= "" then
				deathLastWords = GuildWeave.Death.lastChatMessage
				messageString = messageString .. string.format(Localization["DEATH_LAST_WORDS"], GuildWeave.Death.lastChatMessage)
				GuildWeave.Death.lastChatMessage = ""
			end

			-- Own death counter always increments, even for PvP / instanced deaths
			-- whose broadcast and death-log entry are suppressed below.
			CharacterDeaths = CharacterDeaths + 1

			-- PvP and raid-instance deaths count toward the total but are never
			-- broadcast to guild chat or added to the death log (avoids BG/wipe spam).
			-- Still sync the updated counter to the guild.
			if inPvP then
				C_Timer.After(2, function()
					GuildWeave.GuildProfiles:Broadcast()
				end)
				return
			end

			-- Enforce cooldown: only send own death every OWN_DEATH_COOLDOWN seconds.
			local now = time()
			if (now - lastOwnDeathSendTime) >= GuildWeave.Constants.COOLDOWNS.DEATH_ANNOUNCEMENT then
				SendChatMessage(messageString, "GUILD")
				lastOwnDeathSendTime = now

				-- Structured addon message for other addon users (chat parsing stays as fallback)
				-- Format: DEATH|name|class|level|zone|cause
				local addonDeathMsg = table.concat({
					"DEATH",
					name,
					class,
					tostring(level),
					zone,
					deathCause or "",
				}, "|")
				C_ChatInfo.SendAddonMessage(GuildWeave.prefix, addonDeathMsg, "GUILD")
			end

			-- Process own death immediately (add to log with cause, last words, and handle)
			local deathData = {
				name = name,
				class = class,
				level = level,
				zone = zone,
				cause = deathCause,
				lastWords = deathLastWords,
				discordHandle = discordHandle,
				pronoun = pronoun,
			}
			processDeath(deathData, true)

			C_Timer.After(2, function()
				GuildWeave.GuildProfiles:Broadcast()
			end)
		end, 0, "DeathTracker")

	-- Chat message tracker for last words
	GuildWeave.EventManager:RegisterHandler("CHAT_MSG_SAY", function(_, msg, sender)
		if sender == playerName or sender:match("^" .. playerName .. "%-") then
			GuildWeave.Death.lastChatMessage = msg
		end
	end, 0, "LastWordsSay")

	GuildWeave.EventManager:RegisterHandler("CHAT_MSG_GUILD", function(_, msg, sender)
		local senderBase = sender:match("^([^-]+)") or sender

		-- Track last words for own messages
		if senderBase == playerName then
			GuildWeave.Death.lastChatMessage = msg
		end
	end, 0, "LastWordsGuild")

	GuildWeave.EventManager:RegisterHandler("CHAT_MSG_PARTY", function(_, msg, sender)
		if sender == playerName or sender:match("^" .. playerName .. "%-") then
			GuildWeave.Death.lastChatMessage = msg
		end
	end, 0, "LastWordsParty")

	GuildWeave.EventManager:RegisterHandler("CHAT_MSG_RAID", function(_, msg, sender)
		if sender == playerName or sender:match("^" .. playerName .. "%-") then
			GuildWeave.Death.lastChatMessage = msg
		end
	end, 0, "LastWordsRaid")

	-- Combat log for last attack source
	GuildWeave.EventManager:RegisterHandler("COMBAT_LOG_EVENT_UNFILTERED",
		function()
			local _, subevent, _, _, sourceName, _, _, destGUID, _, _, _, environmentalType = CombatLogGetCurrentEventInfo()

			if destGUID ~= UnitGUID("player") then return end

			-- Track damage events
			if subevent == "SWING_DAMAGE" or subevent == "RANGE_DAMAGE" or
			   subevent == "SPELL_DAMAGE" or subevent == "SPELL_PERIODIC_DAMAGE" then
				GuildWeave.Death.lastAttackSource = sourceName or Localization["DEATH_UNKNOWN"]
			elseif subevent == "ENVIRONMENTAL_DAMAGE" then
				local causeKey = ENVIRONMENTAL_CAUSE_KEYS[environmentalType]
				GuildWeave.Death.lastAttackSource = causeKey and Localization[causeKey] or Localization["DEATH_UNKNOWN"]
			end
		end, 0, "LastAttackTracker")

	-- A hit taken mid-fight (but survived) must not stick around to be misattributed to
	-- a later, unrelated death (e.g. fall damage after the fight is long over) — clear
	-- once combat ends so only damage from the encounter that actually kills us counts.
	GuildWeave.EventManager:RegisterHandler("PLAYER_REGEN_ENABLED",
		function() GuildWeave.Death.lastAttackSource = "" end, 0, "LastAttackTrackerCombatEnd")

	-- Dedup bucket only needs to survive within a session; clear it on login so it
	-- doesn't grow unbounded or carry stale entries across relogs.
	GuildWeave.EventManager:RegisterHandler("PLAYER_ENTERING_WORLD",
		function() wipe(seenDeaths) end, 0, "DeathSeenClear")
end

-- Handle a remote death-counter set request (received via whisper addon message).
function GuildWeave.Death.HandleRemoteSet(value)
	if value and value >= 0 and value <= 999999 then
		CharacterDeaths = value
		GuildWeave:Print(GuildWeave.Constants.COLORS.SUCCESS ..
			string.format(Localization["DEATHSET_RECEIVED"], CharacterDeaths) .. "|r")
	end
end

-- Officer action: set another guild member's death counter remotely via whisper.
function GuildWeave.Death:SetRemote(targetName, valueStr)
	if not CanGuildRemove() then
		GuildWeave:Print(GuildWeave.Constants.COLORS.ERROR .. Localization["DEATHSET_NO_PERM"] .. "|r")
		return
	end

	if not targetName or targetName == "" then return end

	local value = tonumber(valueStr)
	if not value or value < 0 or value > 999999 then
		GuildWeave:Print(GuildWeave.Constants.COLORS.ERROR .. Localization["DEATHSET_INVALID"] .. "|r")
		return
	end

	C_ChatInfo.SendAddonMessage(GuildWeave.prefix, "DEATHSET|" .. tostring(value), "WHISPER", targetName)
	GuildWeave:Print(GuildWeave.Constants.COLORS.SUCCESS ..
		string.format(Localization["DEATHSET_SENT"], targetName) .. "|r")
end

-- Define slash command
SLASH_DEATHSET1 = '/deathset'
SlashCmdList["DEATHSET"] = function(msg)
	local inputValue = tonumber(msg)

	-- If user didn't provide a number, show error message with instructions
	if not inputValue then
		GuildWeave:Print(GuildWeave.Constants.COLORS.ERROR .. "Invalid input. Use: /deathset <number>|r")
		return
	end

	-- Validation: Number must be in a reasonable range
	if inputValue < 0 or inputValue > 999999 then
		GuildWeave:Print(GuildWeave.Constants.COLORS.ERROR .. "Value must be between 0 and 999999|r")
		return
	end

	CharacterDeaths = inputValue
	GuildWeave:Print(GuildWeave.Constants.COLORS.SUCCESS .. "Death counter set to " .. CharacterDeaths .. "|r")
end
