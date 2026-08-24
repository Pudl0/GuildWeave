-- Locales/deDE.lua
-- German (deDE) localization. Only loaded on German clients; overrides enUS keys.

if GetLocale() ~= "deDE" then return end
local Localization = GuildWeave.Localization

-- ── Pronouns ─────────────────────────────────────────────────────────────────
Localization["PRONOUN_2"] = "der"   -- männlich
Localization["PRONOUN_3"] = "die"   -- weiblich
Localization["PRONOUN_1"] = "der"   -- unbekannt

-- ── Rules popups ─────────────────────────────────────────────────────────────
Localization["MAILBOX_BLOCKED_TITLE"] = "Briefkasten gesperrt!"
Localization["MAILBOX_BLOCKED_MSG"]   = "Die Nutzung des Briefkastens ist nicht erlaubt."

Localization["AH_BLOCKED_TITLE"] = "Auktionshaus gesperrt!"
Localization["AH_BLOCKED_MSG"]   = "Die Nutzung des Auktionshauses ist nicht erlaubt."

Localization["TRADE_BLOCKED_TITLE"] = "Handel blockiert!"
Localization["TRADE_BLOCKED_MSG"]   = "Du kannst nur mit Gildenmitgliedern handeln."

Localization["GROUP_LEFT_TITLE"] = "Gruppe verlassen!"
Localization["GROUP_LEFT_MSG"]   = "Du kannst nur mit Gildenmitgliedern in einer Gruppe sein."

-- ── PvP warning ──────────────────────────────────────────────────────────────
Localization["PVP_WARNING_TITLE"] = "Obacht!"
Localization["PVP_FLAGGED"]       = "%s ist PvP-aktiv!"

-- ── Version update ───────────────────────────────────────────────────────────
Localization["VERSION_UPDATE"] = "Eine neue Version des Addons wurde gefunden: %s. Bitte aktualisiere das Addon!"

-- ── Death messages ───────────────────────────────────────────────────────────
Localization["DEATH_MSG"]         = "%s %s %s ist mit Level %s in %s gestorben. Schande!"
Localization["DEATH_MSG_DISCORD"] = "%s (%s) %s %s ist mit Level %s in %s gestorben. Schande!"
Localization["DEATH_CAUSE"]       = " Gestorben an %s"
Localization["DEATH_LAST_WORDS"]  = ". Die letzten Worte: \"%s\""
Localization["DEATH_UNKNOWN"]     = "Unbekannt"

-- Umgebungsbedingte Todesursachen (CLEU's environmentalType hat keine Quelleinheit)
Localization["DEATH_CAUSE_FALLING"]  = "Sturzschaden"
Localization["DEATH_CAUSE_DROWNING"] = "Ertrinken"
Localization["DEATH_CAUSE_FATIGUE"]  = "Erschöpfung"
Localization["DEATH_CAUSE_FIRE"]     = "Feuer"
Localization["DEATH_CAUSE_LAVA"]     = "Lava"
Localization["DEATH_CAUSE_SLIME"]    = "Schleim"

Localization["DEATH_ANNOUNCEMENT_HEADER"] = "Schande!"

-- ── Level-up messages ────────────────────────────────────────────────────────
Localization["LEVELUP_MSG"] = "%s hat Level %s erreicht! Herzlichen Glückwunsch!"
Localization["CAP_MSG"]     = "%s hat das Level Cap von %s erreicht! Herzlichen Glückwunsch!"

Localization["CAP_POPUP_TITLE"] = "Level Cap erreicht"
Localization["CAP_POPUP_MSG"]   = "Du bist bei %d%% von Level %d.\nDas aktuelle Cap ist %d.\nAchte auf die Level Schande!"

Localization["LEVELUP_ANNOUNCEMENT_HEADER"] = "Herzlichen Glückwunsch!"
Localization["CAP_ANNOUNCEMENT_HEADER"]     = "Level Cap erreicht!"
Localization["LEVELUP_ANNOUNCEMENT_BODY"]   = "%s hat Level %s erreicht!"


-- ── Discord handle & pronouns ────────────────────────────────────────────────
Localization["DISCORD_MIGRATED"]  = "Profildaten aus Gildennotiz migriert."
Localization["DISCORD_SET"]       = "Discord Handle gesetzt: %s"
Localization["DISCORD_CURRENT"]   = "Aktueller Discord Handle: %s"
Localization["DISCORD_USAGE"]     = "Verwendung: /setHandle <dein Discord Handle>"
Localization["PRONOUNS_SET"]      = "Pronomen gesetzt: %s"
Localization["PRONOUNS_USAGE"]    = "Verwendung: /setPronouns <deine Pronomen>"
Localization["PRONOUNS_CLEARED"]  = "Pronomen gelöscht."

-- ── Setup wizard ─────────────────────────────────────────────────────────────
Localization["WIZARD_STEP_LABEL"]       = "Schritt %d von %d"
Localization["WIZARD_BTN_NEXT"]         = "Weiter >"
Localization["WIZARD_BTN_DONE"]         = "Fertig"
Localization["WIZARD_BTN_BACK"]         = "< Zurück"
Localization["WIZARD_DISCORD_PROMPT"]   = "Gib deinen Discord Handle ein.\nEr wird mit deinem Profil gespeichert."
Localization["WIZARD_DISCORD_REQUIRED"] = "Bitte einen Discord Handle eingeben."
Localization["WIZARD_PRONOUNS_PROMPT"]  = "Möchtest du bevorzugte Pronomen angeben?\nz.B. er/ihm, sie/ihr, they/them"
Localization["WIZARD_ROLE_PROMPT"]      = "Welche Rolle(n) spielst du? (alle zutreffenden auswählen)"
Localization["WIZARD_ROLE_REQUIRED"]    = "Bitte mindestens eine Rolle auswählen."
Localization["WIZARD_PROF_PROMPT"]      = "Deine Berufe (erkannt oder manuell eingeben):"
Localization["WIZARD_PROF_LABEL"]       = "Beruf %d:"
Localization["WIZARD_PROF_SKIP"]        = "Überspringen (keine Berufe)"

-- ── Options panel ────────────────────────────────────────────────────────────
Localization["OPTIONS_TAB_GENERAL"]      = "Allgemein"
Localization["OPTIONS_SHOW_VER_NAME"]    = "Version anzeigen"
Localization["OPTIONS_SHOW_VER_DESC"]    = "Zeigt die Versionen der Spieler:innen im Gildenchat an"
Localization["OPTIONS_DUEL_NAME"]        = "Duelle Ablehnen"
Localization["OPTIONS_DUEL_DESC"]        = "Lehnt automatisch alle Duell-Anfragen ab"
Localization["OPTIONS_DISCORD_NAME"]     = "Discord Handle im Gildenchat anzeigen"
Localization["OPTIONS_DISCORD_DESC"]     = "Zeigt deinen Discord Handle im Gildenchat an"

Localization["OPTIONS_TAB_NOTIF"]        = "Benachrichtigungen"
Localization["OPTIONS_PVP_GROUP"]        = "PVP Warnung"
Localization["OPTIONS_ENABLED"]          = "Aktiviert"
Localization["OPTIONS_PVP_EN_DESC"]      = "Aktiviert die PVP Warnung"
Localization["OPTIONS_SOUND"]            = "Ton"
Localization["OPTIONS_PVP_SND_DESC"]     = "Aktiviert den Ton für die PVP Warnung"
Localization["OPTIONS_DEATH_GROUP"]      = "Todesmeldungen"
Localization["OPTIONS_DEATH_EN_DESC"]    = "Aktiviert die Todesmeldungen"
Localization["OPTIONS_DEATH_SND_DESC"]   = "Aktiviert den Ton für die Todesmeldungen"
Localization["OPTIONS_LEVELUP_GROUP"]    = "Level-Up Meldungen"
Localization["OPTIONS_LEVELUP_EN_DESC"]  = "Aktiviert die Level-Up Meldungen"
Localization["OPTIONS_LEVELUP_SND_DESC"] = "Aktiviert den Ton für die Level-Up Meldungen"
Localization["OPTIONS_CAP_GROUP"]        = "Cap-Meldungen"
Localization["OPTIONS_CAP_EN_DESC"]      = "Aktiviert die Level-Cap Meldungen"
Localization["OPTIONS_CAP_SND_DESC"]     = "Aktiviert den Ton für die Level-Cap Meldungen"

Localization["OPTIONS_TAB_SOUND"]        = "Sound"
Localization["OPTIONS_SND_CH_NAME"]      = "Soundkanal"
Localization["OPTIONS_SND_CH_DESC"]      = "Wähle über welchen ingame Regler du die %s Sounds regulieren möchtest"
Localization["OPTIONS_SND_MASTER"]       = "Master Regler"
Localization["OPTIONS_SND_SFX"]          = "Effekte Regler"
Localization["OPTIONS_SND_AMBIENCE"]     = "Umgebungs Regler"
Localization["OPTIONS_SND_MUSIC"]        = "Musik Regler"

-- ── Inactivity window ────────────────────────────────────────────────────────
Localization["INACTIVE_HEADER"]      = "Inaktive Mitglieder (> %d Tage)"
Localization["INACTIVE_COL_RANK"]    = "Rang"
Localization["INACTIVE_COL_OFFLINE"] = "Offline Seit"
Localization["INACTIVE_DUR_Y"]       = "%d J"
Localization["INACTIVE_DUR_M"]       = "%d M"
Localization["INACTIVE_DUR_D"]       = "%d T"
Localization["INACTIVE_UNKNOWN"]     = "Unbekannt"
Localization["INACTIVE_REMOVE_BTN"]  = "Entfernen"
Localization["INACTIVE_NO_PERM"]     = "Du hast keine Berechtigung mehr, Spieler zu entfernen."
Localization["INACTIVE_NONE_FOUND"]  = "Keine inaktiven Mitglieder gefunden."


-- ── Mail handler ─────────────────────────────────────────────────────────────
Localization["MAIL_NON_GUILD_WARNING"] = "|cffff0000HINWEIS:|r Post von Nicht-Gildenmitglied!\n\nDiese Post muss gelöscht werden."
Localization["MAIL_DELETE_BTN"]        = "Löschen"
Localization["MAIL_CANCEL_BTN"]        = "Abbrechen"
Localization["MAIL_BUTTON_LOCKED"]     = "|cffff0000Dieser Button ist gesperrt!"
Localization["MAIL_DELETED_ERROR"]     = "Diese Mail kann nicht gelöscht werden, da sie bereits geöffnet war und der Charakter mittlerweile gelöscht wurde! Ein Bezug zur Gilde ist nicht mehr nachvollziehbar"

-- ── Death log window ─────────────────────────────────────────────────────────
Localization["DEATHLOG_TITLE"]         = "Letzte Tode"
Localization["DEATHLOG_COL_CLASS"]     = "Klasse"
Localization["DEATHLOG_TIP_CLASS"]     = "Klasse:"
Localization["DEATHLOG_TIP_CAUSE"]     = "Todesursache:"
Localization["DEATHLOG_TIP_LASTWORDS"] = "Letzte Worte:"

-- ── Guild panel ───────────────────────────────────────────────────────────────
Localization["PANEL_COL_RANK"]    = "Rang"
Localization["PANEL_COL_ROLE"]    = "Rolle"
Localization["PANEL_COL_DEATHS"]  = "Tode"
Localization["PANEL_TIP_CLASS"]   = "Klasse:"
Localization["PANEL_TIP_RANK"]    = "Rang:"
Localization["PANEL_TIP_NOTE"]    = "Notiz:"
Localization["PANEL_TIP_ROLE"]    = "Rolle:"
Localization["PANEL_TIP_PROF1"]   = "Beruf 1:"
Localization["PANEL_TIP_PROF2"]   = "Beruf 2:"
Localization["PANEL_TIP_DEATHS"]  = "Tode:"

-- ── Filter panel ─────────────────────────────────────────────────────────────
Localization["FILTER_ROLE"]       = "Rolle:"
Localization["FILTER_PROFESSION"] = "Beruf:"
Localization["FILTER_ALL_PROFS"]  = "Alle Berufe"
Localization["FILTER_RESET"]      = "Zurücksetzen"

-- ── Tooltip ──────────────────────────────────────────────────────────────────
Localization["TOOLTIP_RANK_IN_GUILD"] = "%s der Gilde %s"
Localization["TOOLTIP_ROLE"]          = "Rolle:"
Localization["TOOLTIP_DEATHS"]        = "Tode:"

-- ── Broadcast ────────────────────────────────────────────────────────────────
Localization["BROADCAST_NO_PERM"] = "Du hast keine Berechtigung für diesen Befehl."
Localization["BROADCAST_SENT"]    = "Broadcast-Nachricht an die Gilde gesendet."

-- ── Deathcounter aus der Ferne setzen ───────────────────────────────────────
Localization["DEATHSET_NO_PERM"]  = "Du hast keine Berechtigung für diesen Befehl."
Localization["DEATHSET_INVALID"]  = "Wert muss zwischen 0 und 999999 liegen."
Localization["DEATHSET_SENT"]     = "Deathcounter-Update an %s gesendet."
Localization["DEATHSET_RECEIVED"] = "Deathcounter von einem Offizier auf %d gesetzt."

-- ── Popup-Bearbeitungsmodus ──────────────────────────────────────────────────
Localization["POPUPEDIT_TITLE"]    = "GuildWeave Popup-Bearbeitungsmodus"
Localization["POPUPEDIT_HINT"]     = "Verschiebe die Platzhalter und klicke oben auf \"Speichern & Beenden\"."
Localization["POPUPEDIT_SAVE_BTN"] = "Speichern & Beenden"
Localization["POPUPEDIT_ENABLED"]  = "Popup-Bearbeitungsmodus aktiv: Ziehe die Platzhalter, um Positionen zu speichern."
Localization["POPUPEDIT_DISABLED"] = "Popup-Bearbeitungsmodus beendet."

-- ── Offizier-Panel: Mitglieder-/Discord-Tabs ────────────────────────────────
Localization["OFFICER_MEMBERS_NONE_FOUND"] = "Keine Mitglieder gefunden."
Localization["OFFICER_DISCORD_NONE_FOUND"] = "Keine Discord Handles in den Profilen gefunden."
Localization["CONTEXTMENU_SET_DEATHSET"]   = "Deathcounter setzen"
Localization["DEATHSET_DIALOG_TEXT"]       = "Deathcounter für %s setzen:"

-- ── Debug test data ──────────────────────────────────────────────────────────
Localization["DEBUG_TEST_CLASSES"] = {"Krieger", "Magier", "Schamane", "Jäger"}
Localization["DEBUG_TEST_ZONES"]   = {"Durotar", "Brachland", "Mulgore", "Tirisfal"}
Localization["DEBUG_DEATH_MSG"]    = "%s %s %s ist mit Level %s in %s gestorben."
Localization["DEBUG_DEATH_CAUSE"]  = "Test-Eber"
