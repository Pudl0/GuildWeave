# GuildWeave

A configurable guild management addon for WoW Classic TBC (Interface 20505).

## Features

- **Death tracking** — announces deaths to guild chat with zone, cause, and last words; keeps a session death log
- **Level-up announcements** — congratulates members on milestone levels and cap-reaching
- **Guild rules enforcement** — configurable restrictions on mailbox, auction house, trade with non-members, and grouping with non-members
- **PvP warning** — popup when targeting a PvP-flagged player or Alliance NPC
- **Guild panel** — sortable roster with role, profession, deaths, and Discord handle
- **Discord handle system** — account-wide handle stored and shown in tooltips and chat
- **Inactivity tracker** — officers can view and remove members offline for 10+ days

## Requirements

- WoW Classic TBC 2.5.x (Interface version 20505)
- All libraries are bundled in the `libs/` folder — no external dependencies

## Installation

1. Download or clone this repository
2. Copy the `GuildWeave` folder into `World of Warcraft/_classic_/Interface/AddOns/`
3. Restart WoW or type `/reload` in-game

## Configuration

### First-run user setup wizard

Each character that logs in for the first time will see the setup wizard automatically. It walks through:

1. **Discord handle** — stored account-wide and shown in tooltips and guild chat
2. **Pronouns** — used in death messages
3. **Role** — Tank, Heal, or DPS; shown in the guild panel
4. **Professions** — auto-detected or entered manually

To re-open the wizard later, use `/gwsetup`.

### Officer configuration

Right-click the minimap icon to open the **Officer Panel**. Officers can toggle guild rules and set the level cap there; changes are written to guild info text automatically.

### Guild info format (reference)

The addon writes configuration tokens to your guild info text automatically:

```
GuildWeave:1111 GuildWeave-Cap:40
```

- `GuildWeave:XYZW` — four digits (0 or 1) for mail, auction house, trade, and grouping rules
- `GuildWeave-Cap:N` — the current level cap (0 to disable cap enforcement)

## Slash Commands

| Command | Description |
|---------|-------------|
| `/gwsetup` | Re-open the user setup wizard |
| `/gwdebug help` | List debug commands (officers and above only) |
| `/gwd <command>` | Alias for `/gwdebug` |
| `/deathset <number>` | Manually set your death counter |
| `/setHandle <handle>` | Set your Discord handle |
| `/setPronouns <pronouns>` | Set preferred pronouns |
| `/clearPronouns` | Clear preferred pronouns |

## Minimap Icon

| Click | Action |
|-------|--------|
| Left-click | Toggle guild panel |
| Shift+Left-click | Toggle death log |
| Right-click | Toggle Officer Panel |

## Officer Panel

Right-click the minimap icon to open the **Officer Panel**:

- **Rules tab** — toggle restrictions and set the level cap; click "Update Guild Info" to save changes to guild info. All guild members can view this tab (read-only). Officers can edit it.
- **Inactive Members tab** — view members offline for 10+ days with a one-click remove button (officers only)

## Authors

- Pudi

## Support

- [Ko-fi](https://ko-fi.com/einfachpudi)

## License

MIT — see [LICENSE](LICENSE)
