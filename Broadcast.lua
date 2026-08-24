-- Broadcast.lua
-- Officer command to broadcast an onscreen message to the whole guild.

local Localization = GuildWeave.Localization
GuildWeave.Broadcast = {}

function GuildWeave.Broadcast:Initialize()
    GuildWeave.EventManager:RegisterHandler("CHAT_MSG_ADDON",
        function(_, prefix, message, _, _)
            if prefix ~= GuildWeave.prefix then return end
            local valueStr = message:match("^BROADCAST|(.+)$")
            if not valueStr then return end
            valueStr = GuildWeave:SanitizeText(valueStr)
            GuildWeave:Print(valueStr)
            RaidNotice_AddMessage(RaidWarningFrame, valueStr, { r = 0.96, g = 0.55, b = 0.73 }, 10)
        end, 0, "BroadcastReceive")
end

function GuildWeave.Broadcast:Send(message)
    if not CanGuildRemove() then
        GuildWeave:Print(GuildWeave.Constants.COLORS.ERROR .. Localization["BROADCAST_NO_PERM"] .. "|r")
        return
    end

    if not message or message == "" then return end

    C_ChatInfo.SendAddonMessage(GuildWeave.prefix, "BROADCAST|" .. message, "GUILD")
    GuildWeave:Print(GuildWeave.Constants.COLORS.SUCCESS .. Localization["BROADCAST_SENT"] .. "|r")
end

SLASH_GWBROADCAST1 = "/gwbroadcast"
SLASH_GWBROADCAST2 = "/gwb"
SlashCmdList["GWBROADCAST"] = function(msg)
    GuildWeave.Broadcast:Send(msg)
end
