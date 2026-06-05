-- Locales/enUS.lua
-- English (default) localization. Always loaded; provides fallback for all keys.

GuildWeave.Localization = {}
local Localization = GuildWeave.Localization

-- ── Pronouns (used in death messages before class name) ──────────────────────
Localization["PRONOUN_2"] = "the"   -- male
Localization["PRONOUN_3"] = "the"   -- female
Localization["PRONOUN_1"] = "the"   -- unknown/neutral

-- ── Rules popups ─────────────────────────────────────────────────────────────
Localization["MAILBOX_BLOCKED_TITLE"] = "Mailbox blocked!"
Localization["MAILBOX_BLOCKED_MSG"]   = "Mailbox usage is not permitted."

Localization["AH_BLOCKED_TITLE"] = "Auction House blocked!"
Localization["AH_BLOCKED_MSG"]   = "Auction House usage is not permitted."

Localization["TRADE_BLOCKED_TITLE"] = "Trade blocked!"
Localization["TRADE_BLOCKED_MSG"]   = "You may only trade with guild members."

Localization["GROUP_LEFT_TITLE"] = "Left group!"
Localization["GROUP_LEFT_MSG"]   = "You may only group with guild members."

-- ── PvP warning ──────────────────────────────────────────────────────────────
Localization["PVP_WARNING_TITLE"]  = "PvP Alert!"
Localization["PVP_FLAGGED"]        = "%s is PvP-flagged!"

-- ── Version update ───────────────────────────────────────────────────────────
Localization["VERSION_UPDATE"] = "A new addon version was found: %s. Please update the addon!"

-- ── Death messages ───────────────────────────────────────────────────────────
-- Format: name, pronoun, class, level, zone
Localization["DEATH_MSG"]         = "%s %s %s died at level %s in %s. Shame!"
-- Format: name, discord, pronoun, class, level, zone
Localization["DEATH_MSG_DISCORD"] = "%s (%s) %s %s died at level %s in %s. Shame!"
Localization["DEATH_CAUSE"]       = " killed by %s"
Localization["DEATH_LAST_WORDS"]  = ". Last words: \"%s\""
Localization["DEATH_UNKNOWN"]     = "Unknown"

Localization["DEATH_ANNOUNCEMENT_HEADER"] = "Shame!"

-- ── Level-up messages ────────────────────────────────────────────────────────
-- Format: playerDisplay, level
Localization["LEVELUP_MSG"] = "%s reached level %s! Congratulations!"
-- Format: playerDisplay, level
Localization["CAP_MSG"]     = "%s reached the level cap of %s! Congratulations!"

Localization["CAP_POPUP_TITLE"] = "Level Cap Reached"
-- Format: xp%, level+1, cap
Localization["CAP_POPUP_MSG"]   = "You are at %d%% of level %d.\nThe current cap is %d.\nWatch the level shame!"

Localization["LEVELUP_ANNOUNCEMENT_HEADER"] = "Congratulations!"
Localization["CAP_ANNOUNCEMENT_HEADER"]     = "Level Cap Reached!"
-- Format: name, level
Localization["LEVELUP_ANNOUNCEMENT_BODY"]   = "%s reached level %s!"


-- ── Discord handle & pronouns ────────────────────────────────────────────────
Localization["DISCORD_MIGRATED"]  = "Profile data migrated from guild note."
-- Format: handle
Localization["DISCORD_SET"]       = "Discord handle set: %s"
-- Format: handle
Localization["DISCORD_CURRENT"]   = "Current Discord handle: %s"
Localization["DISCORD_USAGE"]     = "Usage: /setHandle <your Discord handle>"
-- Format: pronouns
Localization["PRONOUNS_SET"]      = "Pronouns set: %s"
Localization["PRONOUNS_USAGE"]    = "Usage: /setPronouns <your pronouns>"
Localization["PRONOUNS_CLEARED"]  = "Pronouns cleared."

-- ── Setup wizard ─────────────────────────────────────────────────────────────
-- Format: current, total
Localization["WIZARD_STEP_LABEL"]       = "Step %d of %d"
Localization["WIZARD_BTN_NEXT"]         = "Next >"
Localization["WIZARD_BTN_DONE"]         = "Done"
Localization["WIZARD_BTN_BACK"]         = "< Back"
Localization["WIZARD_DISCORD_PROMPT"]   = "Enter your Discord handle.\nIt will be saved to your profile."
Localization["WIZARD_DISCORD_REQUIRED"] = "Please enter a Discord handle."
Localization["WIZARD_PRONOUNS_PROMPT"]  = "Would you like to set preferred pronouns?\ne.g. he/him, she/her, they/them"
Localization["WIZARD_ROLE_PROMPT"]      = "What is your primary role?"
Localization["WIZARD_ROLE_REQUIRED"]    = "Please select a role."
Localization["WIZARD_PROF_PROMPT"]      = "Your professions (auto-detected or enter manually):"
-- Format: slot number
Localization["WIZARD_PROF_LABEL"]       = "Profession %d:"

-- ── Options panel ────────────────────────────────────────────────────────────
Localization["OPTIONS_TAB_GENERAL"]      = "General"
Localization["OPTIONS_SHOW_VER_NAME"]    = "Show version"
Localization["OPTIONS_SHOW_VER_DESC"]    = "Shows the versions of players in guild chat"
Localization["OPTIONS_DUEL_NAME"]        = "Auto-decline duels"
Localization["OPTIONS_DUEL_DESC"]        = "Automatically declines all duel requests"
Localization["OPTIONS_DISCORD_NAME"]     = "Show Discord handle in guild chat"
Localization["OPTIONS_DISCORD_DESC"]     = "Shows your Discord handle in guild chat"

Localization["OPTIONS_TAB_NOTIF"]        = "Notifications"
Localization["OPTIONS_PVP_GROUP"]        = "PvP Warning"
Localization["OPTIONS_ENABLED"]          = "Enabled"
Localization["OPTIONS_PVP_EN_DESC"]      = "Enables the PvP warning"
Localization["OPTIONS_SOUND"]            = "Sound"
Localization["OPTIONS_PVP_SND_DESC"]     = "Enables the sound for the PvP warning"
Localization["OPTIONS_DEATH_GROUP"]      = "Death Messages"
Localization["OPTIONS_DEATH_EN_DESC"]    = "Enables death messages"
Localization["OPTIONS_DEATH_SND_DESC"]   = "Enables the sound for death messages"
Localization["OPTIONS_LEVELUP_GROUP"]    = "Level-Up Messages"
Localization["OPTIONS_LEVELUP_EN_DESC"]  = "Enables level-up messages"
Localization["OPTIONS_LEVELUP_SND_DESC"] = "Enables the sound for level-up messages"
Localization["OPTIONS_CAP_GROUP"]        = "Cap Messages"
Localization["OPTIONS_CAP_EN_DESC"]      = "Enables level cap messages"
Localization["OPTIONS_CAP_SND_DESC"]     = "Enables the sound for level cap messages"

Localization["OPTIONS_TAB_SOUND"]        = "Sound"
-- Format: addon name
Localization["OPTIONS_SND_CH_NAME"]      = "Sound Channel"
Localization["OPTIONS_SND_CH_DESC"]      = "Choose which in-game volume slider controls %s sounds"
Localization["OPTIONS_SND_MASTER"]       = "Master"
Localization["OPTIONS_SND_SFX"]          = "Effects"
Localization["OPTIONS_SND_AMBIENCE"]     = "Ambience"
Localization["OPTIONS_SND_MUSIC"]        = "Music"

-- ── Inactivity window ────────────────────────────────────────────────────────
-- Format: threshold days
Localization["INACTIVE_HEADER"]      = "Inactive Members (> %d days)"
Localization["INACTIVE_COL_RANK"]    = "Rank"
Localization["INACTIVE_COL_OFFLINE"] = "Offline Since"
-- Format: years / months / days
Localization["INACTIVE_DUR_Y"]       = "%dY"
Localization["INACTIVE_DUR_M"]       = "%dM"
Localization["INACTIVE_DUR_D"]       = "%dd"
Localization["INACTIVE_UNKNOWN"]     = "Unknown"
Localization["INACTIVE_REMOVE_BTN"]  = "Remove"
Localization["INACTIVE_NO_PERM"]     = "You no longer have permission to remove players."
Localization["INACTIVE_NONE_FOUND"]  = "No inactive members found."


-- ── Mail handler ─────────────────────────────────────────────────────────────
Localization["MAIL_NON_GUILD_WARNING"] = "|cffff0000WARNING:|r Mail from non-guild member!\n\nThis mail must be deleted."
Localization["MAIL_DELETE_BTN"]        = "Delete"
Localization["MAIL_CANCEL_BTN"]        = "Cancel"
Localization["MAIL_BUTTON_LOCKED"]     = "|cffff0000This button is locked!"
Localization["MAIL_DELETED_ERROR"]     = "This mail cannot be deleted because it was already opened and the character has since been deleted. Guild affiliation can no longer be verified."

-- ── Death log window ─────────────────────────────────────────────────────────
Localization["DEATHLOG_TITLE"]         = "Recent Deaths"
Localization["DEATHLOG_COL_CLASS"]     = "Class"
Localization["DEATHLOG_TIP_CLASS"]     = "Class:"
Localization["DEATHLOG_TIP_CAUSE"]     = "Cause of death:"
Localization["DEATHLOG_TIP_LASTWORDS"] = "Last words:"

-- ── Guild panel ───────────────────────────────────────────────────────────────
Localization["PANEL_COL_RANK"]    = "Rank"
Localization["PANEL_COL_ROLE"]    = "Role"
Localization["PANEL_COL_DEATHS"]  = "Deaths"
Localization["PANEL_TIP_CLASS"]   = "Class:"
Localization["PANEL_TIP_RANK"]    = "Rank:"
Localization["PANEL_TIP_NOTE"]    = "Note:"
Localization["PANEL_TIP_ROLE"]    = "Role:"
Localization["PANEL_TIP_PROF1"]   = "Profession 1:"
Localization["PANEL_TIP_PROF2"]   = "Profession 2:"
Localization["PANEL_TIP_DEATHS"]  = "Deaths:"

-- ── Filter panel ─────────────────────────────────────────────────────────────
Localization["FILTER_ROLE"]          = "Role:"
Localization["FILTER_PROFESSION"]    = "Profession:"
Localization["FILTER_ALL_PROFS"]     = "All Professions"
Localization["FILTER_RESET"]         = "Reset"

-- ── Tooltip ──────────────────────────────────────────────────────────────────
-- Format: rank, guild name
Localization["TOOLTIP_RANK_IN_GUILD"] = "%s of %s"
Localization["TOOLTIP_ROLE"]          = "Role:"
Localization["TOOLTIP_DEATHS"]        = "Deaths:"

-- ── Debug test data ──────────────────────────────────────────────────────────
Localization["DEBUG_TEST_CLASSES"] = {"Warrior", "Mage", "Shaman", "Hunter"}
Localization["DEBUG_TEST_ZONES"]   = {"Durotar", "The Barrens", "Mulgore", "Tirisfal"}
-- Format: name, pronoun, class, level, zone
Localization["DEBUG_DEATH_MSG"]    = "%s %s %s died at level %s in %s."
Localization["DEBUG_DEATH_CAUSE"]  = "Test Boar"
