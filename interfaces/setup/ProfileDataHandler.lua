-- ProfileDataHandler.lua
-- Data layer for player profile: Discord handle, pronouns, and guild note migration.
-- UI is handled by SetupWizard.lua.
local Localization = GuildWeave.Localization

-- Get the account-wide Discord handle
function GuildWeave:GetDiscordHandle()
    return DiscordHandle
end

-- Set the account-wide Discord handle and clear the guild note
function GuildWeave:SetDiscordHandle(handle)
    DiscordHandle = handle
    GuildWeave:ClearGuildNote()
    GuildWeave.GuildProfiles:Broadcast()
end

-- Set preferred pronouns
function GuildWeave:SetPreferredPronouns(pronouns)
    Pronouns = pronouns
    GuildWeave:ClearGuildNote()
end

-- Returns handle with pronouns appended if present: "myhandle (he/him)" or "myhandle"
-- Returns nil if no handle is set
function GuildWeave:GetFormattedHandle()
    local handle = DiscordHandle or ""
    if handle == "" then return nil end
    local pronouns = Pronouns or ""
    if pronouns ~= "" then
        return string.format("%s (%s)", handle, pronouns)
    end
    return handle
end

-- Wipes the guild note (called once to migrate away from note-based storage).
function GuildWeave:ClearGuildNote()
    local playerName = UnitName("player")
    if not playerName or not IsInGuild() then return end

    C_Timer.After(2, function()
        local numMembers = GetNumGuildMembers()
        for i = 1, numMembers do
            local name = GetGuildRosterInfo(i)
            if name then
                local shortName = GuildWeave:RemoveRealmFromName(name)
                if shortName == playerName then
                    GuildRosterSetPublicNote(i, "")
                    return
                end
            end
        end
    end)
end

-- Parses an old-format guild note and returns handle, pronouns, deaths (or nil).
-- Used only for one-time migration on first login after update.
function GuildWeave:ParseGuildNote(note)
    if not note or note == "" then return nil end

    local handle, pronouns, deaths = note:match("^(.-)%s+%((.-)%)%s+Tode:%s*(%d+)%s*$")
    if handle and handle ~= "" then
        return handle, pronouns, tonumber(deaths)
    end

    handle, deaths = note:match("^(.-)%s+%(Tode:%s*(%d+)%)%s*$")
    if handle and handle ~= "" then
        return handle, nil, tonumber(deaths)
    end

    return nil
end

-- On login: attempt to restore data from old-format note, then clear it.
function GuildWeave:MigrateFromGuildNoteIfNeeded()
    if not IsInGuild() then return end
    if DiscordHandle and DiscordHandle ~= "" then
        -- Already have a handle — just ensure note is cleared
        GuildWeave:ClearGuildNote()
        return
    end

    local playerName = UnitName("player")
    local member = GuildWeave.GuildCache:GetMemberInfo(playerName)
    if member and member.publicNote and member.publicNote ~= "" then
        local handle, pronouns, deaths = GuildWeave:ParseGuildNote(member.publicNote)
        if handle then
            DiscordHandle = handle
            if pronouns and pronouns ~= "" then Pronouns = pronouns end
            if deaths then CharacterDeaths = deaths end
            GuildWeave:Print(GuildWeave.Constants.COLORS.SUCCESS ..
                Localization["DISCORD_MIGRATED"] .. "|r")
        end
        GuildWeave:ClearGuildNote()
    end
end

-- Slash commands
function GuildWeave:InitializeProfileData()
    SLASH_SETHANDLE1 = '/setHandle'
    SLASH_SETHANDLE2 = '/sethandle'
    SlashCmdList["SETHANDLE"] = function(msg)
        local handle = msg:match("^%s*(.-)%s*$")
        if handle and handle ~= "" then
            GuildWeave:SetDiscordHandle(handle)
            GuildWeave:Print(GuildWeave.Constants.COLORS.SUCCESS ..
                string.format(Localization["DISCORD_SET"], handle) .. "|r")
        else
            local current = GuildWeave:GetDiscordHandle()
            if current and current ~= "" then
                GuildWeave:Print(string.format(Localization["DISCORD_CURRENT"], current))
            else
                GuildWeave:Print(GuildWeave.Constants.COLORS.WARNING ..
                    Localization["DISCORD_USAGE"] .. "|r")
            end
        end
    end

    SLASH_SETPRONOUNS1 = '/setPronouns'
    SLASH_SETPRONOUNS2 = '/setpronouns'
    SlashCmdList["SETPRONOUNS"] = function(msg)
        local pronouns = msg:match("^%s*(.-)%s*$")
        if pronouns and pronouns ~= "" then
            GuildWeave:SetPreferredPronouns(pronouns)
            GuildWeave:Print(GuildWeave.Constants.COLORS.SUCCESS ..
                string.format(Localization["PRONOUNS_SET"], pronouns) .. "|r")
        else
            GuildWeave:Print(GuildWeave.Constants.COLORS.WARNING ..
                Localization["PRONOUNS_USAGE"] .. "|r")
        end
    end

    SLASH_CLEARPRONOUNS1 = '/clearPronouns'
    SLASH_CLEARPRONOUNS2 = '/clearpronouns'
    SlashCmdList["CLEARPRONOUNS"] = function()
        GuildWeave:SetPreferredPronouns(nil)
        GuildWeave:Print(GuildWeave.Constants.COLORS.SUCCESS .. Localization["PRONOUNS_CLEARED"] .. "|r")
    end
end
