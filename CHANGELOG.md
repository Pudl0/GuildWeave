# Changelog

## [1.1.2] (2026-08-28)

Fixed:
- Minimap icon position now saves properly and is restored between sessions

## [1.1.1] (2026-08-28)

Fixed:
- Removing all Battleground and Arena deaths from DeathBroadcasting. They only count towards the timer. Also removing raid deaths from broadcasting to prevent spam

## [1.1.0] (2026-08-24)

New:
- Officer panel now has a Members tab and a Discord tab for a quick overview of the guild
- Inactive members are now shown right inside the officer panel instead of a separate window
- Officers can send a message to the whole guild with /gwbroadcast
- New keybindings to open the guild panel and the officer panel
- Popup windows (death, level up, PvP warning) can be moved to a new spot with /gwedit

Fixed:
- Discord handles sometimes showed broken or garbled text
- Windows could not be dragged around
- The setup wizard sometimes showed its text outside the window
- Your death counter now always goes up correctly, even during a raid wipe where the chat message gets skipped to avoid spam
- An old guild note was not always cleared properly after finishing your profile setup

## [1.0.0] — 2026-06-21

Initial public release.

- Multi-role support: players can select multiple roles (e.g. Tank/Heal) in the setup wizard; displayed as abbreviations (T/H) in the guild panel
- Skip profession wizard step: bank alts and players without professions can skip it permanently; `/gwsetup` always shows it regardless
