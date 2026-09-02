-- Options.lua
-- Manages addon settings via AceConfig-3.0

GuildWeaveDB = GuildWeaveDB or {}

local AceConfig       = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local Localization    = GuildWeave.Localization

-- Generic getter/setter: arg key must match the GuildWeaveDB key
local function get(info) return GuildWeaveDB[info[#info]] end
local function set(info, val) GuildWeaveDB[info[#info]] = val end

local options = {
    name = "GuildWeave",
    type = "group",
    childGroups = "tab",
    args = {
        general = {
            name  = Localization["OPTIONS_TAB_GENERAL"],
            type  = "group",
            order = 1,
            args  = {
                show_version = {
                    type  = "toggle",
                    name  = Localization["OPTIONS_SHOW_VER_NAME"],
                    desc  = Localization["OPTIONS_SHOW_VER_DESC"],
                    order = 1,
                    width = "full",
                    get   = get,
                    set   = set,
                },
                auto_decline_duels = {
                    type  = "toggle",
                    name  = Localization["OPTIONS_DUEL_NAME"],
                    desc  = Localization["OPTIONS_DUEL_DESC"],
                    order = 2,
                    width = "full",
                    get   = get,
                    set   = set,
                },
                show_discord_handle = {
                    type  = "toggle",
                    name  = Localization["OPTIONS_DISCORD_NAME"],
                    desc  = Localization["OPTIONS_DISCORD_DESC"],
                    order = 3,
                    width = "full",
                    get   = get,
                    set   = set,
                },
            },
        },
        notifications = {
            name  = Localization["OPTIONS_TAB_NOTIF"],
            type  = "group",
            order = 2,
            args  = {
                pvp = {
                    type   = "group",
                    name   = Localization["OPTIONS_PVP_GROUP"],
                    inline = true,
                    order  = 1,
                    args   = {
                        pvp_alert = {
                            type  = "toggle",
                            name  = Localization["OPTIONS_ENABLED"],
                            desc  = Localization["OPTIONS_PVP_EN_DESC"],
                            order = 1,
                            get   = get,
                            set   = set,
                        },
                        pvp_alert_sound = {
                            type  = "toggle",
                            name  = Localization["OPTIONS_SOUND"],
                            desc  = Localization["OPTIONS_PVP_SND_DESC"],
                            order = 2,
                            get   = get,
                            set   = set,
                        },
                    },
                },
                death = {
                    type   = "group",
                    name   = Localization["OPTIONS_DEATH_GROUP"],
                    inline = true,
                    order  = 2,
                    args   = {
                        deathmessages = {
                            type  = "toggle",
                            name  = Localization["OPTIONS_ENABLED"],
                            desc  = Localization["OPTIONS_DEATH_EN_DESC"],
                            order = 1,
                            get   = get,
                            set   = set,
                        },
                        deathmessages_sound = {
                            type  = "toggle",
                            name  = Localization["OPTIONS_SOUND"],
                            desc  = Localization["OPTIONS_DEATH_SND_DESC"],
                            order = 2,
                            get   = get,
                            set   = set,
                        },
                        deathframe_always_small = {
                            type  = "toggle",
                            name  = Localization["OPTIONS_DEATH_SMALL_NAME"],
                            desc  = Localization["OPTIONS_DEATH_SMALL_DESC"],
                            order = 3,
                            width = "full",
                            get   = get,
                            set   = set,
                        },
                    },
                },
                levelup = {
                    type   = "group",
                    name   = Localization["OPTIONS_LEVELUP_GROUP"],
                    inline = true,
                    order  = 3,
                    args   = {
                        levelmessages = {
                            type  = "toggle",
                            name  = Localization["OPTIONS_ENABLED"],
                            desc  = Localization["OPTIONS_LEVELUP_EN_DESC"],
                            order = 1,
                            get   = get,
                            set   = set,
                        },
                        levelmessages_sound = {
                            type  = "toggle",
                            name  = Localization["OPTIONS_SOUND"],
                            desc  = Localization["OPTIONS_LEVELUP_SND_DESC"],
                            order = 2,
                            get   = get,
                            set   = set,
                        },
                    },
                },
                cap = {
                    type   = "group",
                    name   = Localization["OPTIONS_CAP_GROUP"],
                    inline = true,
                    order  = 4,
                    args   = {
                        capmessages = {
                            type  = "toggle",
                            name  = Localization["OPTIONS_ENABLED"],
                            desc  = Localization["OPTIONS_CAP_EN_DESC"],
                            order = 1,
                            get   = get,
                            set   = set,
                        },
                        capmessages_sound = {
                            type  = "toggle",
                            name  = Localization["OPTIONS_SOUND"],
                            desc  = Localization["OPTIONS_CAP_SND_DESC"],
                            order = 2,
                            get   = get,
                            set   = set,
                        },
                    },
                },
            },
        },
        sound = {
            name  = Localization["OPTIONS_TAB_SOUND"],
            type  = "group",
            order = 3,
            args  = {
                sound_channel = {
                    type   = "select",
                    name   = Localization["OPTIONS_SND_CH_NAME"],
                    desc   = string.format(Localization["OPTIONS_SND_CH_DESC"], GuildWeave.displayName),
                    order  = 1,
                    values = {
                        Master   = Localization["OPTIONS_SND_MASTER"],
                        SFX      = Localization["OPTIONS_SND_SFX"],
                        Ambience = Localization["OPTIONS_SND_AMBIENCE"],
                        Music    = Localization["OPTIONS_SND_MUSIC"],
                    },
                    get    = get,
                    set    = set,
                },
            },
        },
    },
}

AceConfig:RegisterOptionsTable("GuildWeave", options)
AceConfigDialog:AddToBlizOptions("GuildWeave", "GuildWeave")

function GuildWeave:InitializeOptionsDB()
    local defaults = {
        show_version            = false,
        auto_decline_duels      = false,
        show_discord_handle     = false,
        pvp_alert               = true,
        pvp_alert_sound         = true,
        deathmessages           = true,
        deathmessages_sound     = true,
        deathframe_always_small = false,
        levelmessages           = true,
        levelmessages_sound     = true,
        capmessages             = true,
        capmessages_sound       = true,
        sound_channel           = "Master",
    }
    for key, value in pairs(defaults) do
        if GuildWeaveDB[key] == nil then
            GuildWeaveDB[key] = value
        end
    end
end
