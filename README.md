# 🌌 Cosmic Overhaul

*The ultimate Quality of Life and Galaxy Simulation overhaul for Avorion.*

![Version](https://img.shields.io/badge/version-5.6.0-6f42c1?style=flat-square)
![Avorion](https://img.shields.io/badge/Avorion-2.5.13-2f81f7?style=flat-square)
![License](https://img.shields.io/badge/license-Apache--2.0-informational?style=flat-square)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-lightgrey?style=flat-square)
![Requires](https://img.shields.io/badge/requires-Core%204-success?style=flat-square)

> [!TIP]
> New here? [`PLAYER_GUIDE.md`](https://github.com/Stormiebox/Cosmic-Overhaul/wiki/Player-Guide) is a friendly gameplay tour. [`WIKI.md`](https://github.com/Stormiebox/Cosmic-Overhaul/wiki/Features-and-Enhancements) has the full technical reference with exact numbers.

## 📖 Overview

Cosmic Overhaul adds a rebuilt Fleet Operations dashboard, a smarter black market economy, dynamic subspace weather, persistent background commands, and deep faction diplomacy to Avorion, all backed by the shared **Cosmic Vault** framework. **v5.3.0** brought a major dashboard-focused rework to the UI layer; see `Changelog.md` for the full version history.

## ✨ Highlights

<details>
<summary><b>Click to expand highlights</b></summary>

- **Fleet Operations & Earnings Dashboard:** A reworked Command Center tab tracks Fleet Income, surfaces idle ships, and flags what needs your attention — no more digging through the map to find out what your background fleet is doing.
- **Smarter Factories:** Factory Overview now shows each factory's location, a live working-state Status column, and a Totals summary across your whole industrial empire.
- **Fleet Health at a Glance:** The Fleet Status Screen shows live hull durability on every tracked ship, with a HUD pulse when one drops critically low.
- **A Real Black Market:** The Smuggler's Market pays real money for stolen and illegal goods, dynamically scales its inventory to local faction wealth, and runs its own Fence/Syndicate Heat risk-reward loop.
- **Living Economy:** Dynamic faction wars, Famine events, subspace weather, and persistent resource regeneration make the galaxy react to what you do in it.
</details>

## 🌌 Cosmic Vault Synergy

<details>
<summary><b>Click to expand</b></summary>

Cosmic Overhaul deeply integrates into the central **Cosmic Vault** APIs:

- **Dynamic Trade Pricing:** Passive trade commands scale profits up to 2.5x during local faction Famines.
- **Weather-Affected Commands:** Offline operations face up to 50% time delays when navigating hazardous storms, unless piloted by an Explorer.
- **Siege Blockade Halts:** Factory production halts when a sector is invaded by an overwhelming force (requires Cosmic War).
- **War Profiteering:** Delivering goods to highly contested War Zones grants up to a +300% payout multiplier (requires Cosmic War).
- **Persistent Market Events:** Boom and crash mechanics always affect prices for their configured lifetime. Disabling economy-event messages suppresses the broadcast only; it does not disable the event.
</details>

## ⚙️ Requirements

- Avorion v2.0+
- **Required:** `Cosmic Vault`, `Cosmic War`, `Cosmic Chronicles`, and `Cosmic Ascendancy` — Cosmic Overhaul is one of the Core 4, and the Core 4 require each other plus Vault.

`modinfo.lua` itself only declares `Cosmic Vault` — Avorion throws a circular-dependency error if the Core 4 try to cross-declare each other there, so the real requirement is enforced through each mod's Steam Workshop "Require Items" listing instead, same as the rest of the Core 4. See `WIKI.md` → Cross-Mod Synergy for the full list of mechanics that light up with each one installed.

## 🚀 Installation

1. Place the folder in:
   - **Windows:** `%AppData%\Avorion\mods\`
   - **Linux:** `~/.avorion/mods/`
2. Enable **Cosmic Overhaul** in **Settings → Mods**.
3. Restart Avorion when prompted.

## 📚 Documentation

| Document | For | Covers |
|---|---|---|
| [`PLAYER_GUIDE.md`](https://github.com/Stormiebox/Cosmic-Overhaul/wiki/Player-Guide) | Players | A friendly, gameplay-focused walkthrough of every feature. |
| [`WIKI.md`](https://github.com/Stormiebox/Cosmic-Overhaul/wiki/Features-and-Enhancements) | Anyone who wants the exact numbers | Complete technical reference — file names, multipliers, and mechanic thresholds. |
| **Cosmic Codex** *(in-game)* | Players | All of the above, readable without leaving the game. |

---

<div align="center">

**🌌 Cosmic Overhaul** — part of the [Cosmic Series](https://github.com/Stormiebox) · built by **Stormbox**

</div>
