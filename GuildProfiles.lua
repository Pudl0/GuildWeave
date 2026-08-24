-- GuildProfiles.lua
-- Syncs player profiles (role, professions) via addon messages.
-- Own profile lives in GuildWeaveOwnProfile (SavedVariablesPerCharacter).
-- Received profiles are cached in GuildWeaveProfileCache (SavedVariables, account-wide).

GuildWeave.GuildProfiles = {}

-- Ensure SavedVariables are initialized
GuildWeaveProfileCache = GuildWeaveProfileCache or {}
GuildWeaveOwnProfile        = GuildWeaveOwnProfile        or {}

-- Message prefix for profile payloads
local MSG_PROFILE = "PROFILE2"

-- Serialise own profile into a single addon message string.
-- Format: PROFILE2|role|prof1name|prof1rank|prof2name|prof2rank|discord|deaths
local function Serialize()
    local p      = GuildWeaveOwnProfile
    local handle = DiscordHandle or ""
    local deaths = tostring(CharacterDeaths or 0)
    return table.concat({
        MSG_PROFILE,
        p.role    or "",
        p.prof1   or "",
        p.prof1rank and tostring(p.prof1rank) or "",
        p.prof2   or "",
        p.prof2rank and tostring(p.prof2rank) or "",
        handle,
        deaths,
    }, "|")
end

-- Deserialise a received payload into a profile table (returns nil on bad format).
local function Deserialize(payload)
    local parts = GuildWeave:ParsePipeMessage(payload)
    -- parts[1] = MSG_PROFILE tag, already stripped by caller
    if #parts < 7 then return nil end
    return {
        role      = parts[1] ~= "" and parts[1] or nil,
        prof1     = parts[2] ~= "" and parts[2] or nil,
        prof1rank = parts[3] ~= "" and tonumber(parts[3]) or nil,
        prof2     = parts[4] ~= "" and parts[4] or nil,
        prof2rank = parts[5] ~= "" and tonumber(parts[5]) or nil,
        discord   = parts[6] ~= "" and GuildWeave:SanitizeText(parts[6]) or nil,
        deaths    = parts[7] ~= "" and tonumber(parts[7]) or nil,
        lastSeen  = time(),
    }
end

-- Broadcast own profile to the guild channel.
-- Also writes directly to the local cache because GUILD addon messages
-- do not loop back to the sender in WoW Classic.
function GuildWeave.GuildProfiles:Broadcast()
    if not IsInGuild() then return end
    local payload = Serialize()
    C_ChatInfo.SendAddonMessage(GuildWeave.prefix, payload, "GUILD")
    -- Populate own cache entry so the chat filter can read our discord handle.
    local ownProfile = Deserialize(payload:sub(#MSG_PROFILE + 2))
    if ownProfile then
        GuildWeaveProfileCache[UnitName("player")] = ownProfile
    end
end

-- Save a field on the own profile and re-broadcast.
function GuildWeave.GuildProfiles:SetOwn(key, value)
    GuildWeaveOwnProfile[key] = value
    GuildWeave.GuildProfiles:Broadcast()
end

-- Returns the cached profile for a player name (short, no realm).
function GuildWeave.GuildProfiles:Get(name)
    return GuildWeaveProfileCache[name]
end

-- Detect primary trade professions and return up to two tables {name, rank, maxRank}.
-- Uses GetSkillLineInfo (vanilla-era API, always available in TBC Classic) instead of
-- GetProfessions() which is a Cataclysm backport and can return nil in TBC Classic
-- when profession data hasn't been loaded in the current session frame.
-- isAbandonable=true identifies primary trade professions only — secondary professions
-- (cooking, fishing, first aid) and combat skills are not abandoable.
function GuildWeave.GuildProfiles:DetectProfessions()
    local result = {}
    local n = GetNumSkillLines()
    for i = 1, n do
        local name, isHeader, _, rank, _, _, maxRank, isAbandonable = GetSkillLineInfo(i)
        if not isHeader and isAbandonable and name and name ~= "" then
            table.insert(result, { name = name, rank = rank, maxRank = maxRank })
            if #result >= 2 then break end
        end
    end
    return result
end

-- Handle incoming PROFILE2 addon messages (wired in from Global.lua handler).
function GuildWeave.GuildProfiles:HandleMessage(sender, message)
    -- Respond to profile requests from freshly-logged-in guild members.
    if message == "PROFILE_REQUEST" then
        GuildWeave.GuildProfiles:Broadcast()
        return true
    end

    local tag = message:match("^([^|]+)")
    if tag ~= MSG_PROFILE then return false end

    local payload = message:sub(#MSG_PROFILE + 2) -- strip "PROFILE2|"
    local profile = Deserialize(payload)
    if not profile then return true end

    local shortName = GuildWeave:RemoveRealmFromName(sender)
    GuildWeaveProfileCache[shortName] = profile
    return true
end

function GuildWeave.GuildProfiles:Initialize()
    -- Broadcast own profile on login and request profiles from already-online members.
    GuildWeave.EventManager:RegisterHandler("PLAYER_ENTERING_WORLD",
        function()
            C_Timer.After(6, function()
                GuildWeave.GuildProfiles:Broadcast()
                if IsInGuild() then
                    C_ChatInfo.SendAddonMessage(GuildWeave.prefix, "PROFILE_REQUEST", "GUILD")
                end
            end)
        end, 90, "GuildProfilesBroadcast")

    -- Update profession ranks whenever the player skills up anything.
    -- DetectProfessions() filters to primary tradeskills (isAbandonable=true) only,
    -- so weapon/secondary skill-ups produce no change and trigger no broadcast.
    GuildWeave.EventManager:RegisterHandler("CHAT_MSG_SKILL",
        function()
            local detected = GuildWeave.GuildProfiles:DetectProfessions()
            local changed = false

            for slot = 1, 2 do
                local d = detected[slot]
                local newName = d and d.name or nil
                local newRank = d and d.rank or nil

                if GuildWeaveOwnProfile["prof"..slot] ~= newName then
                    GuildWeaveOwnProfile["prof"..slot] = newName
                    changed = true
                end
                if GuildWeaveOwnProfile["prof"..slot.."rank"] ~= newRank then
                    GuildWeaveOwnProfile["prof"..slot.."rank"] = newRank
                    changed = true
                end
            end

            if changed then
                GuildWeave.GuildProfiles:Broadcast()
            end
        end, 0, "GuildProfilesSkillUp")
end
