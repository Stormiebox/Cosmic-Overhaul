# ⚙️ Cosmic Overhaul — Wiki

Complete technical reference for **Cosmic Overhaul**, covering every system currently in the mod as of **v5.3.0**. This document favors precision over brevity — file names, exact multipliers, and mechanic thresholds are included wherever they matter. If you just want a friendly tour of what the mod does, read `PLAYER_GUIDE.md` instead; if you want the version-by-version history, read `Changelog.md`.

---

## 📑 Table of Contents

- [System Features](#system-features)
- [Command & Captain Enhancements](#command--captain-enhancements)
- [Captain Elite Traits](#captain-elite-traits)
- [Black Market / Smuggler's Market Rework](#black-market--smugglers-market-rework)
- [Localization](#localization)
- [Cross-Mod Synergy](#cross-mod-synergy)

---

## ⚙️ System Features

### 1) Allied Relations Enhancer

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Improves alliance and faction relation progression by increasing the impact of your positive interaction loops, making diplomacy feel more responsive and meaningful.

**Gameplay Impact:**

- Faster reinforcement of good-standing faction ties.
- Better payoff for trade, protection, and helpful actions during sustained faction play.

</details>

### 🔗 2) Dynamic Reputation Decay & Alliance Mirroring

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Introduces inactivity-based relation decay to AI factions over time, and mirrors your personal reputation changes onto your Alliance so individual actions carry real diplomatic weight for the whole group.

**How it works:**

- **Inactivity Drift:** After an hour of no interaction with a faction, relations begin drifting back toward neutral — Allies slowly forget your good deeds, Hostiles slowly forgive your past sins. Decay starts at 50 relation/hour and escalates the longer a faction is ignored (up to a 3,000/hour cap), applied in a single batch every 45 minutes rather than trickling out constantly.
- **Alliance Mirroring:** Personal reputation changes mirror onto your Alliance at **1:1 parity** (reduced from an earlier 2x multiplier to prevent cascading multi-faction wars once Cosmic War/Ascendancy content is in play).
- **Forgiveness Buffer:** Small reputation losses (down to -25,000) are dampened by 90% before they reach the Alliance ledger, so one player's stray shot doesn't tank the whole group's standing.
- **Entrenched Diplomatic Suicide:** If the mirrored loss targets a faction with the Cosmic War `Fortified` trait, the penalty is multiplied by an additional 1.5x.

**Gameplay Impact:**

- Encourages ongoing diplomacy instead of "set it and forget it" max-reputation states.
- Individual actions matter to the whole Alliance, but minor accidents won't sink it.

</details>

### ☄️ 3) Persistence Resource Regeneration

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Mined-out asteroid fields slowly regenerate their resources over real-time in the background instead of merely respawning a fraction of asteroids upon sector load.

**How it works:**

- **Background Processing:** Ties into the ARCC offline-catch-up API to process elapsed time mathematically, so sectors don't need to stay loaded to recover.
- **Economic Famine Synergy:** Polls the `CosmicVaultEconomy` API. If the controlling faction is in **Severe Famine**, natural recovery halts entirely. If **Resource Starved**, it recovers at half speed.
- **Emergency Replenishment:** A fully barren sector has a chance to trigger an emergency geologic event that spawns new fields, with a 5% chance to also uncover a hidden Precursor Wreck or Spatial Rift via the `CosmicVaultAnomalies` API.
- **News Broadcasting:** Emergency replenishments in populated core sectors publish a breaking news article galaxy-wide via `CosmicVaultNews`.

**Gameplay Impact:**

- Permanent mining operations in safe sectors don't permanently dry up.
- Crushing a faction's economy now measurably damages its ability to replenish resources.

</details>

### 4) Dynamic Station Shuttle Scaling

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Expands and rebalances shuttle behavior and capacity progression for station logistics.

**Gameplay Impact:**

- Better station throughput scaling.
- Improved late-game station utility and production responsiveness.

</details>

### 5) Dynamic Stock / Goods Flow Improvements

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Adjusts station goods behavior and trade flow assumptions to feel less static and more activity-driven.

**Gameplay Impact:**

- More believable commerce loops.
- Better opportunities to profit from active logistics and supply positioning.

</details>

### ⚖️ 6) Equipment Dock & Merchant Inventory Rebalance

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Drastically cleans up and optimizes the volume of procedurally generated items within Equipment Docks, Fighter Merchants, and Turret Merchants.

**Why it changed:**
Because players can now instantly refresh inventories using the Shop Restock button (below), massive legacy lists of 100+ items became unnecessary UI bloat.

**Gameplay Impact:**

- Cleaner shop interfaces with significantly reduced frame-draw overhead.
- Better progression feel when rolling for high-value components.

</details>

### 7) Shop Restock Button (Overhaul Variant)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Adds integrated restock functionality with overhaul-specific balancing (grants 25 free uses first, then transitions to cooldown-sensitive behavior).

**Details:**

- Server-to-client translation fixes prevent cooldown broadcasts from locking to the server host's language, ensuring localized text displays accurately for all players.

**Gameplay Impact:**

- Preserves economy balancing by tracking cooldown metrics via the persistent database.

</details>

### ⚙️ 8) Permanent Subsystem Removal at More Stations

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Enables permanent subsystem removal at additional station types (Repair Dock, Shipyard, Military Outpost, Research Station, and Scrapyard).

**Gameplay Impact:**

- More ship building flexibility.
- Easier correction of long-term build mistakes without requiring extreme rerouting.

</details>

### 🛠️ 9) Fleet Repair at Repair Docks

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Upgrades the Repair Dock UI to natively process and repair your entire fleet in the sector simultaneously with a single button click.

**Technical Features:**

- **Alliance Fallback System:** Calculates the repair bill for the entire combined fleet. If the player is in an Alliance with `SpendResources` privileges, it automatically bills the Alliance vault. If the Alliance is broke or the player lacks permissions, the system falls back to the player's private wallet, repairing only private ships to prevent unauthorized Alliance spending.

**Gameplay Impact:**

- Eliminates jumping between a dozen ships just to click "Repair" on each one individually.

</details>

### ✨ 10) Scrapyard QoL / Time-Limit Removal

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Removes restrictive scrapyard timing friction and improves overall scrapyard flow.

**Gameplay Impact:**

- Smoother salvage gameplay sessions.
- Less downtime and fewer unnecessary interruptions.

</details>

### 11) Transfer Window Enhancements (Cargo UX & Smart Stacking)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Modernizes and refactors the legacy Cargo Transfer UI (`transfercrewgoods.lua`) to natively handle massive, late-game ship manifests.

**Details:**

- **Live Filtering & Sorting:** Text search filtering and alphabetical sorting.
- **Visual Indicators:** Color-coded cargo capacity bars (red for illegal/stolen, yellow for dangerous).
- **Fractional Delivery Overfill:** Transfers no longer fail outright if the receiving ship lacks sufficient volume — the script fills the target hold to capacity and leaves the surplus behind.
- **Inventory Smart Stacking:** Holding **Right Mouse Button (RMB)** while clicking "Transfer All" restricts the action to commodities the receiving ship already has in its hold.

**Gameplay Impact:**

- Major efficiency gains during bulk logistics operations and asset management.

</details>

### 12) Universal Bulletin Board (Player-Centric Access)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Extends sector bulletin board accessibility directly through the player window interface.

**Details:**

- Grouping filters and dropdown macros to sort by Reward, Difficulty, or Source.
- **Stability Fix:** Patched string formatting routines (`playerbulletinboard.lua`) with explicit safety fallbacks for empty argument lists, eliminating client UI crashes on text-lite procedurally generated contracts.

**Gameplay Impact:**

- Instant, centralized access to mission parameters across an entire sector without physical docking.

</details>

### 💹 13) Factory Overview Tab (Economic Analytics & Self-Healing)

<details>
<summary><b>Click to expand details — updated in v5.3.0</b></summary>

**What it does:**
Adds an analytical tracker displaying cash flows, taxes, working states, and performance trends across every factory you own.

**Technical Features:**

- **Self-Healing Loop:** A real-time tracking cycle scans sectors on-load. Any claimed neutral station (e.g. Ice Mines) or factory built before Cosmic Overhaul was installed automatically repairs its missing network registrations and injects itself into the UI.
- **🆕 Location Column (v5.3.0):** Every factory's sector coordinates are now a visible, sortable column instead of something you can only reach blind via "Goto Selected."
- **🆕 Status Column (v5.3.0):** Shows the dominant working-state reason and the percentage of time spent in it (e.g. "94% Running" in green, "62% Missing Ingredients" in red), computed from the same working-state breakdown the tooltip has always shown — so a stalled factory is visible without hovering every row.
- **🆕 Totals Summary (v5.3.0):** A header readout aggregates Income, Expense, and Profit across every factory currently shown, respecting the Alliance toggle.
- All seven columns (the original five plus Location and Status) are fully sortable. The header is split across two rows so the title/totals no longer crowd the Refresh/Goto/Alliance controls.

**Gameplay Impact:**

- Complete strategy-level visibility over multi-sector industrial supply chains — a stalled or underperforming factory is now visible at a glance, not just on hover.

</details>

### 💹 14) Trade Heatmap Expansion

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Progressively scales the tracking range of the Trading Overview subsystem up to a **10x multiplier** based on component rarity.

**Gameplay Impact:**

- Drastically improves route planning and commodity tracking in high-tier sectors.

</details>

### 15) Transporter Range Scaling by Block Investment

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Amplifies the range of the Transporter Software subsystem up to a **10x multiplier**, scaling non-linearly based on both component rarity and the number of dedicated transporter blocks installed on the ship.

**Gameplay Impact:**

- Rewards specialized freighter and shuttle hulls that invest in transporter blocks.

</details>

### 🏗️ 16) Fleet Ship Status UI (Fleet Status Screen)

<details>
<summary><b>Click to expand details — overhauled in v5.3.0</b></summary>

**What it does:**
A standalone Player UI window (opened from a ship, not a Player Window tab — deliberately kept that way) that tracks shield/hull status for any ships you pin to the HUD.

**v5.3.0 changes:**

- **🆕 Live Durability Column:** Both ship-selection lists (Show in HUD / Available Ships) now show a live, color-coded **hull durability percentage** next to every ship name instead of a bare name with no health context. Each list header also shows a running count (e.g. "Show in HUD (3)").
- **🆕 Critical Damage Pulse:** A ship at or below **25% hull durability** now pulses its durability bar on the HUD overlay instead of sitting at a flat, easy-to-miss red — a ship taking damage while you're elsewhere now actually draws your eye.
- **Script Ownership Reset:** Fully migrated from the unstable player context to the entity management layer. Active path: `data/scripts/entity/fleetstatus.lua`. The legacy path at `data/scripts/player/init.lua` is fully decommissioned; a no-op safety shim remains there only to catch stale legacy save references.
- **Namespace Routing Fixed:** Removed bare global wrapper functions (`initialize`, `update`, `getUpdateInterval`, `renderShipStatus`, `loadToShip`) that shadowed the script's own namespaced functions instead of letting the engine call them directly.
- **Row Indexing Fixed:** Both ship lists were reading a UI widget's pixel size (`.size`) instead of its row count (`.rows`) when addressing a just-added row, which could scramble the name/status columns — corrected to the real row-count property.
- **Stale Reference Guard:** `ShipDatabaseEntry(...)` is a constructor, not a lookup, so it never returned `nil` even for a ship that no longer existed — the old `if entry then` guard never caught it. Replaced with a real `entry:exists()` check, plus a guard against clicking a stale row for a ship renamed, sold, or destroyed between UI repaints.

**Gameplay Impact:**

- Damaged ships are now visible both in the settings window (durability column) and on the HUD overlay (pulse), instead of only if you happen to glance at the right bar at the right time.

</details>

### 17) Seed Randomization & Micro-Variance

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Injects operational micro-variance into the 1x1 sector seed matrix for System Upgrades and Turrets, while resolving legacy generation collisions.

**Technical Adjustments:**

- **Hash Collision Fix:** Patched a coordinate overlap bug in `upgradegenerator.lua` and `sectorturretgenerator.lua` that previously forced hundreds of distinct coordinate sectors to share identical loot tables.

**Gameplay Impact:**

- Merchants and pirate drops at the same grid coordinates no longer yield repetitive, mirrored clones of identical items.

</details>

### 🔗 18) UI Settings Persistence (Cosmic Vault Integration)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Saves selected UI elements, filter drop-downs, widget configurations, and command preferences across sessions.

**Backend Refactor:**

- The fragile, crash-prone legacy file-based database (`moddata.lua`) has been completely removed.
- All persistence now runs through the unified `CosmicVaultPlayerSettings` API.

**Gameplay Impact:**

- Workflow continuity across map sectors and game restarts, with no repetitive reconfiguration.

</details>

### 19) Wreckage / Salvage Workflow Improvements

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Adds strategy-mode salvage quality-of-life support for quicker targeting and cleanup flow.

**Gameplay Impact:**

- Faster post-combat salvage management and high-volume debris handling.

</details>

### 20) Trash Manager (Integrated & UI Stabilized)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Adds reliable inventory filtering and a bulk trash-marking flow with preview support, for both private and Alliance inventory contexts. As of v5.3.0, this runs the newly overhauled standalone **Trash Manager Revamped** mod, integrated directly into Cosmic Overhaul.

**Technical Adjustments:**

- Fixed a rendering bug where the Trash Man icon would fail to compile when switching into an Alliance ship or pilot drone — attachment logic now runs safe ownership checks via `entity/init.lua`.

**Gameplay Impact:**

- Streamlined inventory maintenance that segregates favorited gear from bulk "Sell Trash" transactions.

</details>

### 21) Gate Travel Priority & Icon Compasses

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Inverts default map-routing logic so player-issued travel orders actively prioritize localized Gate networks and Wormholes rather than burning jump-drive charges.

**Details:**

- Enchained route instructions check system structures; if an established gate link exists toward your target, the ship steers into the transit gate instead.
- Re-rendered map icons display precise compass markers (North, South, North-West, etc.).

**Gameplay Impact:**

- Major reduction in micro-management for travel orders across populated space.

</details>

### 🎖️ 22) Command Center Tab (Fleet Operations & Earnings Dashboard)

<details>
<summary><b>Click to expand details — reworked in v5.3.0</b></summary>

**What it does:**
The Command Center tab in your Player Window was previously just a list of active background/physical orders with no sorting, filtering, or financial context — largely redundant with vanilla's own Fleet window. It's now a dedicated dashboard for what your background fleet is actually doing and earning, deliberately complementing rather than duplicating vanilla's Fleet window. *(See [Command & Captain Enhancements](#command--captain-enhancements) below for the underlying background-command mechanics this dashboard surfaces — that section covers Trade/Scout/Salvage/etc. behavior itself, this one covers the UI that tracks it.)*

**v5.3.0 rework:**

- **🆕 Fleet Income Tracker:** A cumulative counter of credits earned through background commands (Trade, Mine, Salvage, etc.), aggregated across your own faction and your Alliance, with a manual reset button. Backed by two hooks in `simulation.lua` (`ARCC_trackFleetIncome`) wired into both payout paths a background command can take — immediate delivery and the deferred `Simulation.takeYield` path — so nothing slips through uncounted.
- **🆕 Idle Ship Surfacing:** Ships with no active order at all are now shown as their own rows instead of being silently skipped, so the tab can answer "which of my ships are doing nothing."
- **🆕 Attention Needed Strip:** Live, clickable counts of Idle Ships, Operations Completing Soon (ETA under 60 seconds), and Recalled ships — click any count to jump straight to that filter.
- **🆕 Full Column Sorting:** The operations table sorts by Ship, Operation, Location, ETA, or Status, defaulting to soonest-ETA-first.
- Header layout was split across separate rows so controls no longer share horizontal space and risk overlapping on a narrower player window.

**Three bugs fixed while rebuilding this tab:**

- `invokeFunction`'s first return value is a call-status code (`0` means success), not a boolean — the original `if not ok then` guard could never detect a failed call, because in Lua every number (including `0`) is truthy.
- Several server-authored strings were wrapped in the network-deferred `%_T` marker and then re-translated client-side with `%_t` — instead of being sent as plain text and translated once on receipt. Non-English clients could have seen incorrectly or doubly-resolved text in the operation list.
- `Player:getShipNames()` was captured into a single local (`local shipNames = player:getShipNames()`) and gated on `type(shipNames) == "table"`. The engine's own docs and every real vanilla call site confirm it returns a vararg of strings, not a table — the unwrapped capture silently truncated to just the first ship name, so the check always failed and the physical-ship/idle-ship listing never ran. Fixed by wrapping the call as `{ player:getShipNames() }`, matching vanilla convention.

**Gameplay Impact:**

- Real-time tracking of background simulation commands and physical sector orders, ETAs, and status (Active, Recalled, Idle).
- **Remote Recall:** Recall any ship from its operation directly from the list without opening the Galaxy Map.
- **Financial Awareness:** See exactly how much your background fleet has earned you without cross-referencing chat logs.

</details>

### 23) Restored 1.0 Orders & Looping

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Restores the classic map orders from Avorion 1.0, enabling complex automation loops.

**Gameplay Impact:**

- **Restored Orders:** Mine, Refine, Salvage, and Loop.
- **Advanced Looping:** Queue multiple orders (e.g. Jump → Mine → Jump → Refine) and use the Loop command to repeat the sequence indefinitely.

**How To Use:** Hold `SHIFT` while clicking orders on the Galaxy Map to queue them one after another.

</details>

### ⚔️ 24) Simulated Station Profits & War Heat Synergies

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Simulates organic civilian traffic and service utility consumption across player-owned installations (Casinos, Depots, Repair Docks), yielding steady credit inflows and item generation.

**Ecosystem Integration:**

- Passive income is dynamically modified in real time by local **War Heat**, calculated by the companion *Cosmic War* mod when it's installed. At maximum war heat, this civilian-traffic income drops to 20% of normal — commercial vessels avoid hazardous space. (This is the opposite direction from — and a separate mechanic than — the War Profiteering bonus described under [Cross-Mod Synergy](#cross-mod-synergy), which rewards *supplying into* a warzone rather than passively operating near one.)

**Gameplay Impact:**

- High-conflict deployment zones face steep economic drops; players must actively defend and pacify logistics centers to maintain maximum financial output.

</details>

### ✨ 25) Galaxy Map Enhancements & QoL

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Visual and mechanical upgrades to the Galaxy Map to reduce friction when planning trade routes or organizing fleets.

**Details:**

- **Custom Notes & Icons:** Place customizable icons, draw colored rectangles, and leave persistent sticky notes directly on the map to mark hazard zones, trade routes, or alliance borders.
- **`[T]` Switch to Selected:** Instantly teleport into the ship you currently have selected on the map.
- **`[Shift + C]` Center on Home:** Instantly centers the camera on your home sector (or your Alliance's home sector if piloting an alliance ship).

**Gameplay Impact:**

- Drastically reduces mouse travel and clicking when managing large fleets.

</details>

### 26) Resource Display UI (Native Framework)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
A lightweight, native HUD widget that monitors credits, raw minerals, cargo capacity, and inventory allocations in real time.

**Technical Architecture:**

- Rebuilt from scratch to remove legacy AzimuthLib dependencies.
- Automatically detects the current vessel context, swapping between personal and Alliance vaults as needed.

**Gameplay Impact:**

- Zero-latency oversight over empire assets without opening heavy system submenus.

</details>

### 27) Wreckages Strategy Tab

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Adds a "Wreckages" tab to the Sector Strategy map (`F9`).

**Details:**

- Sortable list of every wrecked ship and station in the current sector.
- Sorts by mass/size (from "Tiny Scraps" up to "Colossal Husks") and distance from your ship.

**Gameplay Impact:**

- Makes cleaning up post-battle graveyards much easier and helps identify the most lucrative salvage targets at a glance.

</details>

### 28) NPC Ship Naming Overhaul

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Rewrites the procedural naming arrays for NPC ships, replacing generic, repetitive titles with immersive, volume-scaled naval and industrial classes.

**Details:**
Ship names scale dynamically based on generated block volume across four archetypes:

- **Military:** *Interceptors* and *Corvettes* up through *Cruisers*, *Dreadnoughts*, and colossal *Leviathans*.
- **Freighters:** *Cargo Shuttles* and *Loaders* up to massive *Superfreighters* and *Logistics Leviathans*.
- **Miners:** *Light Prospectors* up through *Mining Barges* to *Planet Crackers* and *Mining Molochs*.
- **Traders:** *Couriers* up to *Trade Galleons* and *Commercial Colossuses*.

**Gameplay Impact:**

- Immediate, intuitive feedback on an NPC vessel's size and threat level simply by reading its title.

</details>

### ✨ 29) War Zone Economy Blockades

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Stations located in active Cosmic War zones instantly suspend all background AI trader traffic and reject any player docking requests to buy or sell goods.

**Gameplay Impact:**

- Locks down the local economy natively through `factory.lua` injection to prevent exploitation during active sieges.
- Forces players to secure the sector or travel elsewhere for commerce.

</details>

---

## 🎖️ Command & Captain Enhancements

This section covers the *background command mechanics* themselves — how Trade, Scout, Salvage, Procure, and Travel orders behave, and how captain class affects them. For the v5.3.0 **Command Center dashboard** that displays and tracks these commands (Fleet Income, Idle Ships, Attention Needed strip), see [System Features → item 22](#system-features) — the two are complementary, not overlapping: one is the mechanic, the other is the UI that surfaces it.

### 🎖️ A) Persistent Background Command Progression (ARCC)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Calculates elapsed real-world time while the server was empty/offline and applies it to your active captain commands on server restart, as if they kept working while you were away.

**Important Note for Private/Solo Servers:**
Instantly processing hours of offline progress at once can hang or crash small/private servers on boot, and rewards players for time the server was simply turned off — so **offline simulation is disabled by default.**

**Gameplay Impact:**

- 24/7 dedicated server admins can enable and cap offline simulation via the Cosmic Configuration Menu (CCM).
- Solo/private servers boot fast, safe, and free of offline "free resource" exploits.

</details>

### 🎖️ B) Trade Command Overhaul (Major)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Extensively upgrades trade command behavior and outcomes.

**Details:**

- Broader captain usability (removes strict merchant lock-in).
- Efficiency curves adjusted by captain quality and class context.
- **Immediate Delivery Toggle:** Bypasses travel loops for a quick delivery, at a significantly reduced payout.
- **Charity Toggle:** Trades profit for a significant faction relation boost instead of credits.

**Gameplay Impact:**

- Trade commands are more flexible, less binary, and more strategic.

</details>

### ⚙️ C) New Sell Command

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Adds functionality to automatically sell cargo using local supply/demand metrics.

**Gameplay Impact:**

- Removes the tedium of manually finding buyers for high-value cargo holds.
- Can be chained into loops for automated factory logistics.

</details>

### 🎖️ D) Enhanced Procure Command

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Improves procurement options, expanding available goods and calculating better purchase prices.

</details>

### 🎖️ E) Expanded Salvage Command

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Significantly expands the reward table and logic behind salvage operations.

**Details:**

- Exotic and Legendary items can now be recovered.
- Salvage operations can process raw scrap into refined metals directly if the right captain synergy is present.

</details>

### 🎖️ F) Scout Command Improvements & Offline Catch-up

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Rewrites procedural log creation to inject narrative depth into exploratory feedback loops, and corrects execution priorities.

**Technical Adjustments:**

- **Execution Order Fix:** Corrected a logic bug in `scoutcommand.lua` where the offline simulation catch-up check ran *after* the incremental sector loop completed.

**Gameplay Impact:**

- Scout fleets returning from an offline simulation loop now correctly and instantly reveal all discovered coordinates the moment the server boots.

</details>

### 🎖️ G) New Captain Operations Modifiers

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Enhances captain operations with new modifiers, improved ranges, and updated loot tables.

**Details:**

- Adds **Exotic** and **Legendary** items to the salvage loot table.
- A modifier that increases rewards, item quality, or swiftness for various operations (currently mining, scrap, travel, and scout).
- A modifier that doubles the range of various operations. *Note: this also makes those operations take longer.*
- A modifier that lowers ambush chance on various operations by **40%**.

**Gameplay Impact:**

- Stronger incentive to run salvage operations late-game.
- Increased operational flexibility and less frustration from random ambushes during map commands.

</details>

### 🎖️ H) Captain Synergy Expansion (Background Map Commands)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Amplifies the efficiency of correctly assigned, specialized captains across Sell, Procure, Salvage, Refine, and Travel commands.

**Synergy Metrics:**

- **Range Extension:** Matching the precise class to its native operation unlocks major operational range bonuses.
- **Velocity Tuning:** Reduces background operation completion time and transit duration by **up to 25%**.
- **Risk Suppression:** Significantly drops ambush probability during active operations.

**Gameplay Impact:**

- Rewards placing specialized or multi-class captains into matching commercial, combat, or logistical roles.

</details>

### 🎖️ I) Active Captain Synergies (Piloting Passives)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Deploys passive modifiers that activate globally, only while you are **actively piloting** a flagship commanded by a specific captain class.

**Active Modifiers:**

- **Active Merchant:** A global **15% discount on purchases** paired with a **15% bonus payout on sales**, across all legal commercial stations (Trading Posts, Factories, Resource Depots).
- **Active Smuggler:** A **15% reduction in unbranding fees** alongside a **15% bonus payout** on Smuggler's Market black-market sales.
- **Scavenger Strategy Intel:** While piloting a Scavenger flagship, the Sector Strategy interface (`F9`) strips out obfuscated wreck names ("Husk", "Derelict") and shows the exact original vessel identity and class, pinpointing high-value targets across post-battle debris fields.

**Gameplay Impact:**

- Gives distinct elite captains a reason to stay on your personal flagship, turning captain class from a background numbers-booster into an active playstyle choice.

</details>

---

## 🎖️ Captain Elite Traits

Reaching **Level 3** with a captain unlocks a sector-wide passive Elite Trait tied to their class, active whenever that captain is piloting the ship you're currently in. These stack with the piloting passives above and are separate from them.

- **Commodore:** Every friendly ship and station in the sector gets a **+10% Shield** and **+10% Fire Rate** buff, refreshed continuously while the Commodore remains in the sector.
- **Smuggler:** The ship becomes immune to cargo/contraband inspections (uses the vanilla `ignore_inspections` flag, so AI ignores it completely). Also passively drains the local controlling faction's Famine Score by `-0.1` every 5 seconds ("Smuggler Deflation").
- **Miner:** A **+15% bonus to rich asteroid yields** while actively mining.
- **Scavenger:** A **+50% Salvage Yield** buff while inside an active Cosmic War Contested Siege Zone.

---

## 🏴‍☠️ Black Market / Smuggler's Market Rework

### 🏗️ Structural Engineering: Dynamic API Injection

The old, conflict-heavy legacy override of `shiputility.lua` has been replaced with a surgical dynamic hook script that abides strictly by Avorion's Virtual File System rules — total protection against mod conflicts, while fully restoring the black-market infrastructure.

<details>
<summary><b>Click to expand Black Market details</b></summary>

### Why This Exists

In vanilla Avorion, illegal and stolen-goods loops often felt under-rewarded relative to the risk of procurement, scans, and lockouts. This rework keeps the high-stakes fantasy alive while making the payoff economically competitive with standard legal trade.

### Buy Multipliers (What the Smuggler's Market Pays You)

The base rate the Smuggler's Market pays for goods you sell it depends on the good's classification:

- **Stolen goods:** 75% of item value (vanilla default is 25%).
- **Illegal, non-stolen goods:** 100% of item value.
- **Dangerous goods:** 60% of item value.

Stacking bonuses on top of the base rate, all multiplicative:

- **Smuggler captain aboard:** +10% at Tier 0, up to +25% at Tier 3 (+5% per tier).
- **You own the station** (Syndicate Boss): +25% profit.
- **Smuggler Governor assigned:** +35% profit.
- **Eclipse Contraband Premium** (Ascendant Matter, Eclipse Datacore — Cosmic Chronicles synergy): a further **1.5x (150%)** flat multiplier.
- **Rift Tech fencing** (Rift Research Data, Subclass Subsystem — Rift DLC synergy): a further random **1.5x–2.5x (150%–250%)** multiplier. Fencing this sensitive technology also costs 2,500 reputation with the local AI faction.

### Unbranding Stolen Goods

Cleaning ("unbranding") stolen cargo so it can be sold at a normal station uses a price factor of **40%** of item value (vanilla is 50%), reduced further by:

- **Smuggler captain aboard:** -10% at Tier 0, up to -25% at Tier 3.
- **Smuggler Governor assigned:** an additional -50% (half price).
- **You own the station:** -90% (unbranding your own stolen goods at your own market is almost free).

### The Fence System & Syndicate Heat

The Smuggler's Market automatically unbrands up to **100 stolen goods per minute** straight from its own cargo hold — a passive fencing operation that doesn't need you present. Each unbranded good adds to a running **Syndicate Heat** counter. At **5,000 heat**, the market triggers a Sector Lockdown: a simultaneous Pirate raid and local Faction Military strike. Heat is capped and the raid gated behind a **1-hour real-time cooldown**, so heat can't queue up multiple overlapping raids.

### Other Changes

- **Lucrative Cargo Scales:** The illegal-cargo drop cap from destroyed civilian freighters rose from a vanilla 25,000 credits to **up to 250,000 credits**, scaling with local sector richness.
- **Boarding Loot:** Successfully boarding a ship or station drops 1-2 high-rarity loot crates (turrets or upgrades).
- **Smuggler Market Generation:** Markets scale their illegal goods inventory to local faction wealth and traits, and spawn more often in off-the-grid hidden-mass sectors.

### Gameplay Impact

- Deep-space piracy, contraband running, and black-market alignment are viable standalone career paths capable of sustaining a late-game fleet.

</details>

---

## 🌐 Localization

<details>
<summary><b>Click to expand details</b></summary>

**7 Supported Languages:** Cosmic Overhaul is fully translated into Russian, Chinese, German, Spanish, French, Japanese, and Portuguese, alongside English. Every custom UI, captain interaction, and background logic prompt displays in the player's own language.

</details>

---

## 🔗 Cross-Mod Synergy

**What it is:**
Cosmic Overhaul is built to deeply integrate with the rest of the Cosmic Series. It only *requires* `Cosmic Vault` to run (see `README.md` for the exact dependency), but the mechanics below light up automatically when `Cosmic War`, `Cosmic Chronicles`, and/or `Cosmic Ascendancy` are also installed — no configuration needed.

### 🌌 With Cosmic Vault (always active)

- **Deep Economy Warfare:** Overhaul's localized Famine Events tie into the `CosmicVaultEconomy` API, which can force starving factions to declare war on wealthy neighbors to survive.
- **Unified News API:** Ambient events and galactic occurrences route through `CosmicVaultNews.publishArticle`, keeping the Universal Bulletin Board and news feed in sync across the whole suite.
- **Weather-Affected Commands:** Offline Travel and Scout operations respect Cosmic Vault's dynamic weather. Navigating an Ion Storm or Nebula delays the operation by 50%, unless piloted by an Explorer or Navigator.
- **Dynamic Trade Pricing:** Trading with a Famine-struck faction via the Trade Command can yield up to **2.5x** more profit — this maxes out alongside the Severe Famine trade-bonus tier.
- **CCM Keybind Interoperability:** The Bulletin Board and Resource Display panels support user-defined hotkey toggling via Cosmic Vault's CCM.

### 📉 Famine Stat Debuffs (Cosmic Vault Economy)

Ships belonging to a faction suffering economic collapse take real combat penalties, scaled to severity:

| Famine Tier | Shield Penalty | Velocity Penalty |
|---|---|---|
| Struggling | -15% | — |
| Resource Starved | -30% | -20% |
| Severe Famine | -50% | -30% |

Destroying enemy resource sectors to push a faction into Famine is a legitimate way to soften them up before an invasion.

### ⚔️ With Cosmic War

- **Siege Blockade Halts:** In a War Zone, if the defenders are outgunned 2:1, factory production halts entirely until the siege lifts.
- **War Zone Blockades:** Stations in active war zones suspend all AI trader traffic and reject player docking for trade (see [System Features → item 29](#system-features)).
- **War Profiteering:** Delivering goods to a blockaded factory, or trading in a max-heat War Zone, grants up to a **+300% (3.0x)** income multiplier from war heat alone. This stacks with a separate **distance-to-core scaling** multiplier — stations near the galactic edge get a standard 1.0x, while stations deep in the core get up to an additional 3.0x. High risk, high reward.
- **Siege Salvage Yield:** A Scavenger captain actively flying inside a Contested Siege Zone gets a **+50% Salvage Yield** buff (Elite Trait; see above).
- **Blockade Runner Governors:** Smuggler Governors bypass factory blockades entirely during active sieges, enabling wartime profiteering.
- **Entrenched Diplomatic Suicide:** Alliance reputation mirroring penalties are multiplied by 1.5x against a faction with the `Fortified` trait.

### 🌌 With Cosmic Chronicles

- **Scout Anomalies:** Explorer captains charting empty sectors leave notes hinting at Cosmic Chronicles narrative events.
- **Eclipse Contraband Premium:** See [Black Market rework](#black-market--smugglers-market-rework) above — a 1.5x fencing premium on Ascendant Matter and Eclipse Datacores.
- **Famine Relief Charity:** Background Charity Missions to starving factions grant a **+100%** reputation multiplier.
- **Ascendancy Trade Fear:** Non-smuggler merchant trade flights take **50% longer** to resolve if the target faction is at war with The Eclipse. Smugglers bypass this penalty entirely.

### 🧬 With Cosmic Ascendancy

- **Ascendant Neural Implants:** Equip the legendary Ascendant Neural Implant subsystem, physically transforming your ship into a biomechanical dreadnought (massive jump reach, fighters, turrets, and velocity scaling).

### 👔 Station Governors

- **Merchant Governors:** +25% passive station income, +50% AI traffic, and Privateer Subsidies (50% crew/captain hiring cost reduction while enlisted as a Mercenary for the station's faction).
- **Engineer Governors:** +50% factory shuttle capacity.
- **Smuggler Governors:** Bypass Cosmic War siege blockades and grant the Black Market bonuses listed above.

### 🔒 Network Safety & Stability

- All Lua `math.random` calls were replaced with Avorion's deterministic `random():getInt()` generator, eliminating desyncs during multiplayer fleet spawns.
- Remote-callable UI and background functions are hardened against spoofed client calls — the server verifies execution context before processing requests.
- The Trading Manager gracefully skips dead simulation ticks instead of flooding server console logs.

### 🛠️ Notable Vanilla Bug Fixes

- **Scout Mission Fix:** Scout Missions previously skipped Faction Headquarters sectors entirely because the vanilla dialogue tree lacked a template for that sector type — now fixed.

### 📖 In-Game Documentation

All of the above is also available in-game through the **Cosmic Codex** — no need to tab out to read mechanics or lore while you play.
