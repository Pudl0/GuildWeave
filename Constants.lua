-- Constants.lua
-- Central constants for the GuildWeave addon

GuildWeave.Constants = {}

-- ============================================================
-- == GUILD CONFIGURATION =====================================
-- Officers configure rules via the in-game Officer Panel.
-- ============================================================

-- Key used in guild info to encode the current level cap.
-- Officers put this in the guild description: e.g. "GuildWeave-Cap:40"
-- Note: this is a Lua pattern, the hyphen is escaped.
GuildWeave.Constants.RULES_CAP_KEY = "GuildWeave%-Cap"

-- Separator line written before the GuildWeave block in guild info.
-- Makes it easy to spot in the guild description and separates it from
-- any existing guild text (e.g. "### WICHTIG FÜRS ADDON ###").
GuildWeave.Constants.GUILD_INFO_SEPARATOR = "--- GuildWeave ---"

-- Key used in the guild info text to encode rules.
-- Officers put this in the guild description: e.g. "GuildWeave:1111"
-- Each digit (0/1) controls: mail, auction house, trade, grouping rules.
GuildWeave.Constants.RULES_KEY = "GuildWeave"

-- ============================================================
-- == ADDON CONSTANTS =========================================
-- ============================================================

local mediaBase = "Interface\\AddOns\\GuildWeave\\media\\"

GuildWeave.Constants.MEDIA = {
    GUILD_LOGO   = mediaBase .. "graphics\\GuildLogo.tga",
    MINIMAP_ICON = mediaBase .. "graphics\\MinimapIcon.tga",
}

-- Maximum level (TBC Classic = 70)
GuildWeave.Constants.MAX_LEVEL = 70

-- Level milestones for announcements
GuildWeave.Constants.LEVEL_MILESTONES = {10, 20, 30, 40, 50, 60, 70}

-- Instance types
GuildWeave.Constants.INSTANCE_TYPES = {
    PVP     = "pvp",
    RAID    = "raid",
    DUNGEON = "party"
}

-- Sound IDs
GuildWeave.Constants.SOUNDS = {
    PVP_ALERT            = 8174,
    DEATH_ANNOUNCEMENT   = 8192,
    LEVELUP_ANNOUNCEMENT = 888,
    CAP_ANNOUNCEMENT     = 8574,  -- Achievement sound
}

-- Colors for messages
GuildWeave.Constants.COLORS = {
    ADDON_PREFIX = "|cFFF48CBA",
    ERROR        = "|cffff0000",
    SUCCESS      = "|cff00ff00",
    WARNING      = "|cffffaa00",
    INFO         = "|cff88ccff"
}

-- Cooldowns (in seconds)
GuildWeave.Constants.COOLDOWNS = {
    PVP_ALERT          = 10,
    GUILD_ROSTER_CACHE = 60,   -- 1 minute
    DEATH_ANNOUNCEMENT = 10
}

-- Panel backdrop: solid color background + thin tooltip border (used by panel-style frames).
-- Background color and border color set via SetBackdropColor / SetBackdropBorderColor.
GuildWeave.Constants.PANEL_BACKDROP = {
    bgFile   = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

-- UI Backdrop Settings
GuildWeave.Constants.BACKDROP = {
    bgFile   = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile     = true,
    tileSize = 32,
    edgeSize = 32,
    insets   = { left = 11, right = 12, top = 12, bottom = 11 }
}

-- Popup Backdrop Settings
GuildWeave.Constants.POPUPBACKDROP = {
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true, tileSize = 16, edgeSize = 16,
    insets   = { left = 4, right = 4, top = 4, bottom = 4 }
}

-- Dark dialog backdrop (PvP warning frame)
GuildWeave.Constants.DARK_BACKDROP = {
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
}

-- Inactivity threshold (days)
GuildWeave.Constants.INACTIVE_DAYS_THRESHOLD = 10

-- Guild member roles
GuildWeave.Constants.ROLES = { "Tank", "Heal", "DPS" }

