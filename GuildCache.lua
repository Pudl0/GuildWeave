-- GuildCache.lua
-- Caches the guild roster with a 60-second TTL to reduce repeated API calls.

GuildWeave.GuildCache = {
	members = {},           -- Cached guild member list (name -> true)
	fullRoster = {},        -- Full roster data with details
	lastUpdate = 0,         -- Timestamp of last cache update
	isUpdating = false      -- Flag to prevent concurrent updates
}

function GuildWeave.GuildCache:IsValid()
	local now = GetTime()
	local age = now - self.lastUpdate
	return age < GuildWeave.Constants.COOLDOWNS.GUILD_ROSTER_CACHE
end

function GuildWeave.GuildCache:RequestUpdate()
	if self.isUpdating then
		return false
	end

	self.isUpdating = true
	C_GuildInfo.GuildRoster()
	return true
end

function GuildWeave.GuildCache:ProcessRosterData()
	-- Clear old data
	wipe(self.members)
	wipe(self.fullRoster)

	local numTotalMembers = GetNumGuildMembers()

	for i = 1, numTotalMembers do
		local name, rankName, rankIndex, level, classDisplayName, zone,
			  publicNote, officerNote, isOnline, status, class = GetGuildRosterInfo(i)

		if name then
			-- Remove realm name for easier comparison
			local shortName = GuildWeave:RemoveRealmFromName(name)

			-- Store in fast lookup table
			self.members[shortName] = true

			-- Calculate last online data
			local yearsOffline, monthsOffline, daysOffline, hoursOffline = GetGuildRosterLastOnline(i)
			yearsOffline = yearsOffline or 0
			monthsOffline = monthsOffline or 0
			daysOffline = daysOffline or 0
			hoursOffline = hoursOffline or 0

			local totalDaysOffline = (yearsOffline * 365) + (monthsOffline * 30) + daysOffline + (hoursOffline / 24)

			-- Store complete data
			table.insert(self.fullRoster, {
				name = shortName,
				fullName = name,
				rank = rankName,
				rankIndex = rankIndex,
				level = level,
				class = class,
				classDisplayName = classDisplayName,
				zone = zone,
				publicNote = publicNote,
				officerNote = officerNote,
				isOnline = isOnline,
				status = status,
				yearsOffline = yearsOffline,
				monthsOffline = monthsOffline,
				daysOffline = daysOffline,
				hoursOffline = hoursOffline,
				totalDaysOffline = totalDaysOffline
			})
		end
	end

	self.lastUpdate = GetTime()
	self.isUpdating = false
end

function GuildWeave.GuildCache:GetFullRoster()
	return self.fullRoster
end

function GuildWeave.GuildCache:IsGuildMember(playerName)
	if not playerName then return false end

	-- Remove realm name if present
	local shortName = GuildWeave:RemoveRealmFromName(playerName)

	-- Check directly in cache
	return self.members[shortName] == true
end

function GuildWeave.GuildCache:GetMemberInfo(playerName)
	if not playerName then return nil end

	local shortName = GuildWeave:RemoveRealmFromName(playerName)
	local roster = self:GetFullRoster()

	for _, member in ipairs(roster) do
		if member.name == shortName then
			return member
		end
	end

	return nil
end

function GuildWeave.GuildCache:GetMembersByRank(rankName)
	local roster = self:GetFullRoster()
	local result = {}

	for _, member in ipairs(roster) do
		if member.rank == rankName then
			table.insert(result, member)
		end
	end

	return result
end

function GuildWeave.GuildCache:GetOnlineMembers()
	local roster = self:GetFullRoster()
	local result = {}

	for _, member in ipairs(roster) do
		if member.isOnline then
			table.insert(result, member)
		end
	end

	return result
end

function GuildWeave.GuildCache:ForceRefresh()
	return self:RequestUpdate()
end

function GuildWeave.GuildCache:GetStats()
	local now = GetTime()
	local age = now - self.lastUpdate
	local isValid = self:IsValid()

	return {
		memberCount = #self.fullRoster,
		lastUpdate = self.lastUpdate,
		age = age,
		isValid = isValid,
		expiresIn = math.max(0, GuildWeave.Constants.COOLDOWNS.GUILD_ROSTER_CACHE - age)
	}
end

function GuildWeave.GuildCache:Initialize()
	-- Update on guild roster updates (fires automatically on login)
	-- Processes roster data whenever the event fires - keeps cache always up to date
	GuildWeave.EventManager:RegisterHandler("GUILD_ROSTER_UPDATE",
		function()
			GuildWeave.GuildCache:ProcessRosterData()
		end, 100, "GuildCacheAutoUpdate")

	-- Initial update on login
	GuildWeave.EventManager:RegisterHandler("PLAYER_ENTERING_WORLD",
		function()
			-- Wait briefly after login, then request roster
			C_Timer.After(2, function()
				GuildWeave.GuildCache:RequestUpdate()
			end)
		end, 90, "GuildCacheInit")
end
