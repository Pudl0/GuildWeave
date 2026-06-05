# GuildWeave

![Interface](https://img.shields.io/badge/Interface-20505-blue)
![Version](https://img.shields.io/badge/Version-1.0.0-green)
![License](https://img.shields.io/badge/License-MIT-lightgrey)
[![CurseForge](https://img.shields.io/curseforge/dt/1502453?logo=curseforge&label=CurseForge&color=F16436)](https://www.curseforge.com/wow/addons/guildweave)
[![Support on Ko-fi](https://img.shields.io/badge/Support-Ko--fi-FF5E5B?logo=ko-fi&logoColor=white)](https://ko-fi.com/einfachpudi)

GuildWeave is a guild management addon built for **Guildfound** — a self-found-style playmode where your guild is your only trading partner. Every item must be looted and distributed within the guild. No trading with outsiders, no grouping outside the guild. GuildWeave enforces those rules automatically and gives officers the tools to manage a roster that actually plays by them.

---

## What is Guildfound?

Guildfound is a community playmode inspired by self-found, but played as a team. The core rules:

- **No trading with players outside the guild** — all items stay inside
- **No grouping with players outside the guild** — progression happens together
- **Everything looted and shared within the guild** — the guild is the economy

GuildWeave was written specifically to enforce these rules in-game, so no one has to police them manually.

---

## Features

**Guildfound rule enforcement**
Officers set the rules once. The addon enforces them for every member automatically:
- Block trading with non-guild members
- Block grouping with non-guild members
- Block mailbox usage
- Block auction house access
- Auto-decline duel requests

**Death tracking**
Announces deaths to guild chat with zone, cause of death, and last words. Keeps a live session death log visible at any time.

**Level-up announcements**
Congratulates members when they hit milestone levels and when they reach the level cap — with a popup reminder if they're approaching it.

**Guild panel**
A sortable, filterable roster showing every member's role, professions, death count, and Discord handle — updated live.

**Discord handle system**
Each player sets their Discord handle once. It appears in tooltips, guild chat, and the death log — no more "who is this person?".

**Inactivity tracker**
Officers see a list of members offline for 10+ days, sortable by duration, with a one-click remove button.

**PvP warning**
Popup alert when you target a PvP-flagged player or an enemy faction NPC.

---

## Support Development

GuildWeave is developed and maintained by a single developer in their spare time. If your guild uses GuildWeave regularly, consider supporting development — it helps cover the time spent maintaining compatibility with new WoW versions, fixing bugs, and building new Guildfound features.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/einfachpudi)

Thank you to everyone who helps keep the project alive.

---

## Setup

### Players
On first login, a short wizard walks through Discord handle, pronouns, role, and professions. Takes about 30 seconds. Re-open anytime with `/gwsetup`.

### Officers
Right-click the minimap icon → **Officer Panel** → **Rules tab**. Toggle rules and set the level cap, then click **Update Guild Info**. Done — the settings are written to guild info text and read by all members automatically.

---

## Slash Commands

| Command | Description |
|---------|-------------|
| `/gwsetup` | Re-open the setup wizard |
| `/setHandle <handle>` | Set your Discord handle |
| `/setPronouns <pronouns>` | Set preferred pronouns |
| `/clearPronouns` | Clear pronouns |
| `/deathset <number>` | Manually correct your death counter |
| `/gwdebug help` | Debug commands (officers only) |

---

## Minimap Icon

| Click | Action |
|-------|--------|
| Left-click | Toggle guild panel |
| Shift + Left-click | Toggle death log |
| Right-click | Toggle Officer Panel (guild members only) |

---

## Enjoying GuildWeave?

If GuildWeave makes your Guildfound experience better, consider supporting future development:

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/einfachpudi)

---

## License

MIT — see [LICENSE](LICENSE)
