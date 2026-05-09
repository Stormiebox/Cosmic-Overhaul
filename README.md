# Cosmic Overhaul

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Overview

**Cosmic Overhaul** is a large-scale Avorion quality-of-life and systems-rebalance mod in the *Cosmic* series.  
It combines many battle-tested gameplay improvements into one package, with a strong focus on usability, economy flow, command simulation quality, and reducing friction in long campaigns.

This mod changes multiple core gameplay loops (trade, logistics, station management, faction relations, UI workflows, and captain command simulation), so starting a **new galaxy** is strongly recommended.

---

## 📖 Full Feature Breakdown

Due to the extensive nature of this overhaul, the full detailed feature list has been moved to our GitHub Wiki!

👉 **[Click here to read the full feature breakdown on the Official Wiki](https://github.com/Stormiebox/Cosmic-Overhaul/wiki/Features-&-Enhancements)**

### Quick Overview

* **System Features:** Dynamic Reputation Decay, Smuggler's Market Rework, Universal Bulletin Board, Trash Manager, Allied Relations Enhancer, and over a dozen more QoL improvements.
* **Command & Captain Enhancements:** Persistent Offline Commands, Real-time Scout updates, expanded Trade and Refine missions, and travel optimizations.

---

## Installation

1. Place the mod folder into:
   * **Windows:** `%AppData%\Avorion\mods\`
   * **Linux:** `~/.avorion/mods/`
2. Start Avorion.
3. Enable **Cosmic Overhaul** in **Settings -> Mods**.
4. Restart the game when prompted.

---

## Requirements / Compatibility

* **New game strongly recommended:** Yes.
* **saveGameAltering:** true
* **serverSideOnly:** false (intentional due to mixed client/server script paths in Avorion architecture)
* **Major incompatibilities:** See Workshop discussion and `modinfo.lua` incompatibility list.

---

## Design Principles

* Uses Avorion-compatible `include()` extension patterns.
* Preserves vanilla behavior where possible via wrappers/overrides.
* Focuses on practical QoL with systemic payoff.
* Prefers gameplay depth without excessive busywork.

---

## Support / Notes

* For incompatibilities and troubleshooting, refer to:
  * Workshop discussion thread
  * your logs (`clientlog` / server logs)
* If you maintain heavily modded stacks, test load order and script overlap carefully when combining multiple large overhauls.

---

## Credits

Cosmic Overhaul builds on community ideas, prior workshop innovations, and long-term iteration.  
Special thanks and credit to original authors and contributors whose work inspired components and approaches:

`TheDeadlyShoe, Nyrin, I has a bucket, Geterwin, Chefkoch, Rinart73, BloodyRain2k, Towelie, LateTide, Snuggly Wuggums!, Bubbet!, KnifeHeart, Madranis, The_Rusty_Geek`
