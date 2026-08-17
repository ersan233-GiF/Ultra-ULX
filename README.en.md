# Ultra ULX

[![Latest release](https://img.shields.io/github/v/release/ersan233-GiF/Ultra-ULX?label=Latest&color=blue)](https://github.com/ersan233-GiF/Ultra-ULX/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/ersan233-GiF/Ultra-ULX/total?label=Downloads&color=success)](https://github.com/ersan233-GiF/Ultra-ULX/releases)
[![Stars](https://img.shields.io/github/stars/ersan233-GiF/Ultra-ULX?style=social&label=Stars)](https://github.com/ersan233-GiF/Ultra-ULX)
[![License](https://img.shields.io/badge/license-CC_BY--NC--SA_3.0-green)](LICENSE)
[![ULX](https://img.shields.io/badge/ULX-3.81%20compatible-orange)](https://github.com/TeamUlysses/ulx)
[![ULib](https://img.shields.io/badge/ULib-2.72%20built--in-blueviolet)](https://github.com/TeamUlysses/ulib)
[![Garry's Mod](https://img.shields.io/badge/Garry's%20Mod-Addon-ff69b4)](https://gmod.facepunch.com/)
[![Languages](https://img.shields.io/badge/Languages-4-4FC08D)](#multi-language)
[![Commands](https://img.shields.io/badge/Commands-150%2B-success)](#command-reference)

> 🌐 **English** · [简体中文](README.md) · [Русский](README.ru.md)

> An enhanced fork of [Team Ulysses ULX v3.81](https://github.com/TeamUlysses/ulx) + [ULib v2.72](https://github.com/TeamUlysses/ulib) · Fully localized · 150+ commands · 4 languages · SQLite persistence · Zero-intrusion coexistence

**[⬇️ Download the latest release](https://github.com/ersan233-GiF/Ultra-ULX/releases/latest)** · **[🌐 Official website](https://ersan233-gif.github.io/Ultra-ULX/)** · **[Report an issue](https://github.com/ersan233-GiF/Ultra-ULX/issues)** · **[Changelog](CHANGELOG.md)** · **[Source repository](https://github.com/ersan233-GiF/ultra-ulx-source)**

---

## Table of Contents

- [About](#about)
- [Key Features](#key-features)
- [Installation](#installation)
- [Command Usage](#command-usage)
- [First-Time Server Setup](#first-time-server-setup)
- [Multi-Language Support](#multi-language)
- [Coexistence with Vanilla ULX](#coexistence-with-vanilla-ulx)
- [Uninstallation](#uninstallation)
- [FAQ](#faq)
- [Project Overview](#project-overview)
- [Release Notes](#release-notes)
- [License](#license)
- [Credits](#credits)

---

## About

[Ultra ULX](https://github.com/ersan233-GiF/Ultra-ULX) is an enhanced fork of the Garry's Mod server administration plugin [ULX](https://github.com/TeamUlysses/ulx). On top of all the original features it adds:

- **150+ administration commands** (vanilla has ~45)
- **Fully localized**, with **4 languages** (Simplified Chinese / English / Русский / Classical Chinese), switchable per client
- **SQLite persistence** for the punishment system (automatic backups + recovery)
- **Auto bunnyhop (BHOP)**, coordinate HUD, item spawning and 23 feature modules
- **Zero-intrusion design**: all data is stored in the independent `data/ultra_ulx/` directory — it never modifies vanilla ULX, and deleting it restores vanilla ULX instantly

> **Compatibility:** built on ULX v3.81 + ULib v2.72, ships with a complete ULib — no extra installation needed.

---

## Key Features

| Feature | Description |
|:----|:-----|
| **Permission system** | Multi-level groups + fine-grained permissions + SQLite persistence + 30 automatic backups + corruption recovery |
| **Administration extras** | Timed mute/gag, tiered warning system (3 strikes → auto-gag, 5 strikes → auto-ban), player reports, action logs, persistent IP bans, server maintenance mode |
| **Admin tools** | Ban / kick / mute / teleport / map / cleanup / reset — covers daily server operations |
| **Fun commands** | 50+ interactions, including community extensions (`!slap`, `!ragdoll`, `!freeze`…) |
| **Voting system** | Players vote to change map / kick / ban; supports MapVote / GMVote |
| **XGUI panel** | Full graphical admin interface (`!menu`) — no need to memorize commands |
| **Multi-language** | 4 languages, switchable per client |
| **BHOP** | Reference-server auto bunnyhop: JumpPower 290 + sv_airaccelerate 2000 recipe, energy-conserving slope projection, groundTicks anti-stuck |
| **Item spawning** | 9 categories, 70+ preset items, smart collision detection |
| **Coordinate system** | Screen HUD + above-head coordinates, 4 visibility modes |
| **Crouch-jump boost** | Adjustable jump multiplier + crouch speed + auto-unlock |
| **Safe coexistence** | Independent data directory + InitPostEntity override — remove to restore vanilla ULX |

---

## Installation

> **Priority: [P0] Read before installing**

```
1. Download the release → unzip → put the "Ultra ULX" folder into garrysmod/addons/
2. Restart the server
3. Success is confirmed when the console shows "Ultra ULX v2.98.52 loaded"
```

> **Directory check:** the final path must be `garrysmod/addons/Ultra ULX/lua/...` (do not nest an extra folder).

### Use directly from this repository

```
git clone https://github.com/ersan233-GiF/Ultra-ULX.git
# Copy the whole "Ultra ULX" folder into garrysmod/addons/
```

---

## Command Usage

> **Priority: [P0] Getting started**

| Method | Example | Description |
|:----|:-----|:-----|
| Chat `!command` | `!bring player` | The most common way, type in-game |
| Console `ulx_command` | `ulx bring player` | For admins |
| `!menu` or `!xgui` | Opens the panel | Full-featured XGUI admin panel |

Quick command reference:

```
ulx map <mapname>              ← change map
ulx ban <player> <minutes> <reason>   ← ban a player
ulx kick <player>              ← kick a player
ulx gag <player> <minutes>     ← timed gag (voice)
ulx mute <player> <minutes>    ← timed mute (text)
ulx warn <player> <reason>     ← warn a player (3→auto-gag, 5→auto-ban)
ulx noclip                     ← noclip yourself
ulx god                        ← god mode for yourself
ulx hp 100                     ← restore health
ulx cleanup                    ← clean up all props on the map
ulx bring <player>             ← bring a player to you
ulx goto <player>              ← teleport to a player
ulx freeze <player>            ← freeze a player
ulx ragdoll <player>           ← ragdoll a player
```

---

## First-Time Server Setup

> **Priority: [P0] Must-read for server owners — do these in order**

### Step 1: Get your SteamID

Your SteamID is your unique identifier (e.g. `STEAM_0:1:12345678`) and never changes, even if you rename. Setting admins by SteamID is the most reliable.

```
Method 1: type !who in chat
         → your SteamID appears in the output (e.g. "STEAM_0:1:55554444")

Method 2: open https://steamid.io/ in a browser
         → enter your Steam profile URL to look it up

Method 3: Steam client → Friends → right-click yourself → View profile
         → the number at the end of the URL is your Steam64 ID (needs conversion; method 1 is easier)
```

> Write down your SteamID (format `STEAM_0:1:12345678`) — you'll need it next.

### Step 2: Set yourself as SuperAdmin

When you first join after installing, you have no permissions. Use the **server console** (not the in-game chat):

```
# Server console (rcon/back-end):
ulx adduserid <yourSteamID> superadmin

# For example, if your SteamID is STEAM_0:1:55554444:
ulx adduserid STEAM_0:1:55554444 superadmin
```

> **Tip:** hosting locally (Singleplayer → New Game → Sandbox)? Press `~` to open the console.
> **Tip:** rented server? Use the console/RCON in your host's control panel.
> **Why SteamID?** Player names can change at any time; SteamIDs are permanently bound — permissions survive renames.

Then type `!menu` in chat to open the full admin panel.

### Step 3: Verify permissions

```
Chat commands:
!who               ← see your group (and your SteamID)
!version           ← view Ultra ULX version info
```

If you see `You do not have access to this command`, the previous step didn't take effect — re-run `ulx adduserid`, and double-check the SteamID format.

### Step 4: Common server commands

```
# Server console:
ulx map gm_construct           ← switch to a specific map
ulx ban PlayerName 60 reason   ← ban for 60 minutes
ulx kick PlayerName            ← kick a player
ulx noclip                     ← noclip yourself
ulx god                        ← god mode
ulx hp 100                     ← restore health
ulx cleanup                    ← clean up all props
```

### User group management

> **Recommended: use SteamID** so permissions survive renames.

```
# By SteamID (recommended, permanent):
ulx adduserid STEAM_0:1:55554444 superadmin    ← SuperAdmin (highest)
ulx adduserid STEAM_0:1:55554444 admin         ← Admin
ulx adduserid STEAM_0:1:55554444 operator      ← Operator
ulx removeuserid STEAM_0:1:55554444            ← remove user

# Or by player name (temporary, breaks after rename):
ulx adduser PlayerName superadmin              ← add by name
ulx removeuser PlayerName                      ← remove by name
```

> Tip: `!who` shows all online players' names and SteamIDs.

### XGUI admin panel

```
Type !menu (or !xgui) in chat:
├── Commands     ← browse/run all ulx commands
├── Groups       ← manage users and permission groups visually
├── Bans         ← view/unban
├── Items        ← spawn weapons/items/vehicles
├── Map vote     ← configure map voting
└── Settings     ← server MOTD / language / skin
```

---

## Multi-Language

> **Priority: [P1] Optional**

Client console command:

| Code | Language |
|:----|:-----|
| `ulx_lang zh-cn` | Simplified Chinese |
| `ulx_lang en` | English |
| `ulx_lang ru` | Русский |
| `ulx_lang lzh` | Classical Chinese (文言文) |

Or switch via `!menu` → Settings → Client → Language.

---

## Coexistence with Vanilla ULX

| Scenario | Behavior |
|:----|:-----|
| Vanilla ULX already installed | Ultra ULX automatically overrides same-named commands |
| Only Ultra ULX installed | Ships a complete ULib, no extra install needed |
| Remove Ultra ULX | Vanilla ULX is fully preserved |

---

## Uninstallation

> **Priority: [P0] If you need to uninstall**

```
1. Delete the whole addons/Ultra ULX/ folder
2. (Optional) delete the data/ultra_ulx/ configuration
3. Restart the server — vanilla ULX is restored automatically, zero residue
```

> **Zero-intrusion design:** all data lives in the independent `data/ultra_ulx/` directory; vanilla ULX is never modified.

---

## FAQ

> **Priority: [P1] Check here when you hit problems**

| Problem | Solution |
|:----|:-----|
| `Unknown command: ulx` | Check for an extra folder nesting: `addons/Ultra ULX/lua/` must exist directly |
| `Groups file was not formatted correctly` | Delete `data/ulib/groups.txt` and restart — it rebuilds automatically |
| Commands do nothing | Make sure you have the right permission (SuperAdmin/Admin) |
| Garbled text after switching language | Type `ulx_lang zh-cn` to switch back to Chinese |
| How do I give myself permissions? | Server console: `ulx adduserid <yourSteamID> superadmin` |
| Forgot my SteamID? | Type `!who` in chat to see yourself and online players |
| BHOP not working? | Check whether other physics plugins are active; some gamemodes (e.g. DarkRP) have their own movement limits |
| Items won't spawn? | Check the limits in `data/ultra_ulx/sbox_limits.txt`, or see which categories are checked in `!menu` → Items |

---

## Project Overview

| Metric | Value |
|:---:|:---:|
| Total lines (Lua, with comments) | **~31,400** |
| Release lines (comments stripped) | **~25,650** |
| Lua source size | **~1,120 KB** |
| Lua files | **93** |
| Languages | **4** (zh-cn / en / ru / lzh, ~1,600 keys each) |
| Commands | **~150** (~45 vanilla + 105+ new) |
| Modules | **23** (sh 14 + cl 5 + sv 4) |
| Item categories | **9** |
| ULib version | 2.72 |
| Ultra ULX version | **v2.98.52** |
| ULX compatibility | 3.81 |

---

## Release Notes

This repository is the **Ultra ULX release repository**: the `Ultra ULX/` folder at the root is the complete, ready-to-use addon (development comments stripped, zero dependencies).

- **Source code** (with comments, docs and build tooling): [ultra-ulx-source](https://github.com/ersan233-GiF/ultra-ulx-source)
- **Release process**: develop → bump version → build release package → push here → tag `v*` to auto-create a Release (see `.github/workflows/release.yml`)
- **Current version**: v2.98.52

---

## Development & Contribution

> **Priority: [P2] For developers**

Welcome to submit PRs and Issues! Please read the [Contributing Guide](.github/CONTRIBUTING.md) first.

> This is the **release repository**. Code development and build tooling happen in **[ultra-ulx-source](https://github.com/ersan233-GiF/ultra-ulx-source)** — PRs and Issues are welcome there.

---

## Security

> **Priority: [P1] For server admins**

- All write paths are sanitized and escaped (`sql.SQLStr`) against SQL injection
- The `ulx url` command has a built-in domain whitelist against open redirects
- Client RPC uses a namespace whitelist (`ulx.*` / `ULib.*`) against malicious calls
- To report a security vulnerability, see [SECURITY.md](.github/SECURITY.md) — do not disclose publicly

---

## License

This project is released under [CC BY-NC-SA 3.0](LICENSE) (non-commercial use).

- Original ULX / ULib copyright belongs to [Team Ulysses](https://github.com/TeamUlysses)
- Ultra ULX enhances and localizes while preserving the original copyright notice

---

## Credits

- [Team Ulysses](https://github.com/TeamUlysses) — developers of the original ULX / ULib
- Garry's Mod community — command inspiration and lots of feedback
- Everyone who has submitted Issues / PRs / suggestions for Ultra ULX

---

*Ultra ULX — enhanced from [ULX](https://github.com/TeamUlysses/ulx) by Team Ulysses · [Release repo](https://github.com/ersan233-GiF/Ultra-ULX) · [Source](https://github.com/ersan233-GiF/ultra-ulx-source)*
