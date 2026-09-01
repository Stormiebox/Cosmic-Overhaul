# 🌌 Cosmic Overhaul

*The ultimate Quality of Life and Galaxy Simulation overhaul for Avorion.*

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
</details>

## ⚙️ Requirements

- Avorion v2.0+
- **Required dependency:** `Cosmic Vault` — the shared foundation library every Cosmic mod builds on.

Cosmic Overhaul runs standalone on top of Cosmic Vault; it doesn't hard-require the rest of the suite. That said, it's designed for cross-mod synergy, and pairs best with the full Core 4 — `Cosmic War`, `Cosmic Chronicles`, and `Cosmic Ascendancy` — which unlock additional synergy mechanics automatically when installed alongside it (see `WIKI.md` → Cross-Mod Synergy for the full list).

## 🚀 Installation

1. Place the folder in:
   - **Windows:** `%AppData%\Avorion\mods\`
   - **Linux:** `~/.avorion/mods/`
2. Enable **Cosmic Overhaul** in **Settings → Mods**.
3. Restart Avorion when prompted.

## 📚 Documentation

For detailed mechanics, guides, and lore, check the in-game **Cosmic Codex**, or the included `WIKI.md` (technical reference) and `PLAYER_GUIDE.md` (gameplay-focused walkthrough) files.
