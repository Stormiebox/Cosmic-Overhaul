# ⚙️ Cosmic Overhaul - Detailed Features

Welcome to the **Cosmic Overhaul** official wiki! Below is a complete, user-facing rundown of the features currently included in the mod, complete with practical details on how each mechanic impacts your gameplay.

---

## 📑 Table of Contents

- [System Features](#system-features)
- [Command & Captain Enhancements](#command--captain-enhancements)
- [Black Market / Smuggler’s Market Rework](#black-market--smugglers-market-rework)
- [Cosmic Vault Synergy](#cosmic-vault-synergy)

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

### 🔗 2) Dynamic Reputation Decay & Alliance Synergy

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Introduces inactivity-based relation decay to AI factions over time, while linking individual actions directly to the player's group entity with heightened impact.

**How it works:**

- **Inactivity Drift:** Server-side timed decay checks cause ignored faction relations to slowly drift back towards neutral (Allies forget over time, while Hostiles eventually forgive).
- **Alliance Mirroring:** Individual player reputation changes mirror to their Alliance at **2x intensity**.

**Gameplay Impact:**

- Encourages ongoing diplomacy and active interstellar engagement.
- Prevents permanent "set-and-forget" max reputation states in long-term campaigns.
- Forces individual actions to carry massive diplomatic weight for your entire faction group.

</details>

### ☄️ 3) Persistence Resource Regeneration

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Mined-out asteroid fields slowly regenerate their resources over real-time in the background instead of merely respawning a fraction of asteroids upon sector load.

**How it works:**
- **Background Processing:** The system connects with the Cosmic Overhaul ARCC API to process elapsed offline time mathematically, removing the need to keep sectors loaded.
- **Economic Famine Synergy:** It actively polls the `CosmicVaultEconomy` API. If the faction owning the sector is in **"Severe Famine"**, the sector's natural recovery halts entirely. If **"Resource Starved"**, it recovers at half speed.
- **Emergency Replenishment:** If a sector is entirely barren, an emergency geologic event will spawn new fields. This massive shift has a 5% chance to uncover hidden Precursor Wrecks or Spatial Rifts via the `CosmicVaultAnomalies` API.
- **News Broadcasting:** Emergency replenishments in heavily populated core sectors will automatically publish a breaking news article to the galaxy via the `CosmicVaultNews` API.

**Gameplay Impact:**
- Makes the universe feel geologically active without flooding the sector with too many asteroids.
- Allows players to establish permanent mining operations in safe sectors without worrying about them permanently drying up.
- Creates economic vulnerability: crushing a faction's economy now actively destroys its ability to replenish mining resources.

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

### 4) Dynamic Stock / Goods Flow Improvements

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Adjusts station goods behavior and trade flow assumptions to feel less static and more activity-driven.

**Gameplay Impact:**

- More believable commerce loops.
- Better opportunities to profit from active logistics and supply positioning.

</details>

### ⚖️ 5) Equipment Dock & Merchant Inventory Rebalance

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Drastically cleans up and optimizes the volume of procedurally generated items within Equipment Docks, Fighter Merchants, and Turret Merchants.

**Why it changed:**
Because players can now instantly refresh inventories using the **Shop Restock** utility, massive legacy lists of 100+ items became unnecessary UI bloat.

**Gameplay Impact:**

- Cleaner shop interfaces with significantly reduced frame-draw overhead.
- Better progression feel when rolling for high-value components.

</details>

### 6) Shop Restock Button (Overhaul Variant)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Adds integrated restock functionality with overhaul-specific balancing (grants 25 free uses first, then transitions to cooldown-sensitive behavior).

**Details:**

- Server-to-Client translation fixes prevent cooldown broadcasts from locking to the server host's language, ensuring localized text displays accurately for all players.

**Gameplay Impact:**

- Exceptional quality-of-life improvement during active fitting and ship-building sessions.
- Preserves economy balancing by tracking cooldown metrics via the persistent database.

</details>

### ⚙️ 7) Permanent Subsystem Removal at More Stations

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Enables permanent subsystem removal at additional station types (e.g., `Repair Dock`, `Shipyard`, `Military Outpost`, `Research Station`, and `Scrapyard`).

**Gameplay Impact:**

- More ship building flexibility.
- Easier correction of long-term build mistakes without requiring extreme rerouting.

</details>

### 🛠️ 8) Fleet Repair at Repair Docks

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Upgrades the Repair Dock UI to natively process and repair your entire fleet in the sector simultaneously with a single button click.

**Technical Features:**

- **Alliance Fallback System:** Calculates the repair bill for the entire combined fleet. If the player is in an Alliance with `SpendResources` privileges, it automatically bills the Alliance vault. If the Alliance is broke or the player lacks permissions, the system gracefully falls back to the player's private wallet—mechanically isolating and repairing *only* private player ships to prevent unauthorized Alliance spending.

**Gameplay Impact:**

- Eliminates the tedious necessity of jumping between 15 different ships just to click the "Repair" button on each one individually.

</details>

### ✨ 8) Scrapyard QoL / Time-Limit Removal

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Removes restrictive scrapyard timing friction and improves overall scrapyard flow.

**Gameplay Impact:**

- Smoother salvage gameplay sessions.
- Less downtime and fewer unnecessary interruptions.

</details>

### 9) Transfer Window Enhancements (Cargo UX & Smart Stacking)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Completely modernizes and refactors the legacy Cargo Transfer UI (`transfercrewgoods.lua`) to natively handle massive, late-game ship manifests.

**Details:**

- **Live Filtering & Sorting:** Fully functional text search filtering and alphabetical sorting configurations.
- **Visual Indicators:** Color-coded cargo capacity feedback bars (Red for illegal/stolen, Yellow for dangerous).
- **Fractional Delivery Overfill:** Transfers no longer fail completely if the receiving ship lacks sufficient volumetric storage; instead, the script fills the target hold to maximum capacity and leaves the surplus behind.
- **Inventory Smart Stacking:** Holding **Right Mouse Button (RMB)** when clicking the "Transfer All" macro restricts the action to only transfer commodities that the receiving ship *already possesses* in its inventory hold.

**Gameplay Impact:**

- Unprecedented efficiency during bulk logistics operations, automated cargo distributions, and asset management.

</details>

### 10) Universal Bulletin Board (Player-Centric Access)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Extends sector bulletin board accessibility directly through the player window interface, augmented by hardened string parsing fixes.

**Details:**

- Features advanced grouping filters and dropdown macros to sort by Reward, Difficulty, or Source.
- **Stability Fix:** Patched string formatting routines (`playerbulletinboard.lua`) to provide explicit safety fallbacks for empty argument lists, entirely eliminating client UI crashes when displaying text-lite procedurally generated contracts.

**Gameplay Impact:**

- Instant, centralized access to mission parameters across entire sectors without requiring physical docking maneuvers.

</details>

### 💹 11) Factory Overview Tab (Economic Analytics & Self-Healing)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Adds a robust analytical tracker displaying cash flows, taxes, working states, and performance trajectories over time, backed by automated structural registration routines.

**Technical Features:**

- **V4.0.0 Icon Update:** Fully integrated native custom iconography tracking (`data/textures/icons/FactoryOverviewTab.png`).
- **Self-Healing Loop:** Implemented a real-time tracking cycle that scans sectors on-load. Any claimed neutral station (e.g., Ice Mines) or factory constructed prior to Cosmic Overhaul's installation automatically repairs its missing network registrations and cleanly injects itself into the UI layout.

**Gameplay Impact:**

- Complete strategy-level visibility over multi-sector industrial supply chains, highlighting supply blocks and underperforming installations instantly.

</details>

### 💹 12) Trade Heatmap Expansion

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Progressively scales the underlying tracking range of the Trading Overview subsystem up to a massive **10x multiplier** based directly on component rarity.

**Gameplay Impact:**

- Drastically improves strategic route layout planning and systemic commodity tracking in high-tier sectors.

</details>

### 13) Transporter Range Scaling by Block Investment

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Amplifies the functional range of the Transporter Software subsystem up to a **10x multiplier**, scaling non-linearly based on both component rarity and the total volume of dedicated transporter blocks installed within the active ship plan.

**Gameplay Impact:**

- Seamlessly bridges the gap between mechanical scale and block investment, heavily rewarding specialized freighter and shuttle hulls.

</details>

### 14) Ship/Fleet Info Extensions

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Overhauls ship info presentations to maximize strategic situational awareness while reducing nested calculation loops.

#### 🏗️ Fleet Ship Status UI (Refactored Core Architecture)

Cosmic Overhaul features an fully integrated and highly optimized **Fleet Ship Status** architecture.

**Technical Architecture Adjustments:**

- **Script Ownership Reset:** Completely migrated code hooks from the unstable player context down to the strict entity management layers.
- **Active Path:** `data/scripts/entity/fleetstatus.lua` (Attached cleanly via `data/scripts/entity/init.lua`).
- **Safety No-Op Shim:** The legacy script path at `data/scripts/player/init.lua` has been fully decommissioned. A safety fallback shim remains at the old player path to catch stale legacy save references, completely eliminating engine stack traces and visual layout failures.

**Gameplay Impact:**

- Ensures the FSS HUD icon initializes perfectly, updates without memory leaks, and reliably functions across deep, multi-fleet late-game setups.

</details>

### 15) Seed Randomization & Micro-Variance

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Injects an operational micro-variance into the 1x1 sector seed matrix for System Upgrades and Turrets, while resolving legacy generation collisions.

**Technical Adjustments:**

- **Hash Collision Fix:** Patched a coordinate overlap bug within `upgradegenerator.lua` and `sectorturretgenerator.lua` that previously forced hundreds of distinctly separate coordinate sectors to share identical loot tables.

**Gameplay Impact:**

- Merchants and Pirate drops residing within the exact same grid coordinates will no longer yield repetitive, mirrored clones of identical items, creating a significantly more dynamic loot environment.

</details>

### 🔗 16) UI Settings Persistence (CosmicVault Integration)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Saves selected UI elements, filter drop-downs, widget configurations, and command preferences seamlessly across sessions.

**Backend Refactor:**

- The fragile, crash-prone legacy file-based database system (`moddata.lua`) has been **completely removed**.
- All operational persistence parameters are now funneled through the high-performance, unified `CosmicVaultPlayerSettings` API.

**Gameplay Impact:**

- Complete workflow continuity across map sectors and game restarts, eliminating repetitive reconfiguration hurdles.

</details>

### 17) Wreckage / Salvage Workflow Improvements

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Adds strategy-mode salvage quality-of-life support for quicker targeting and cleanup flow.

**Gameplay Impact:**

- Faster post-combat salvage management.
- Better high-volume debris handling.

</details>

### 18) Trash Manager (Integrated & UI Stabilized)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Adds robust inventory filtering and a bulk trash marking flow with preview support, available for both private and alliance inventory contexts.

**Technical Adjustments:**

- Fixed a rendering bug where the Trash Man icon would fail to compile when switching into an Alliance ship or pilot Drone. The underlying attachment logic now runs safe ownership checks via `entity/init.lua` to guarantee stable rendering at all times.

**Gameplay Impact:**

- Streamlined inventory maintenance that safely segregates high-value marked favorites while enabling rapid "Sell Trash" vendor transactions.

</details>

### 19) Gate Travel Priority & Icon Compasses

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Inverts default map-routing logic, forcing player-issued travel strings to actively prioritize localized Gate networks and Wormholes rather than burning jump-drive charges.

**Details:**

- Enchained route instructions automatically check system structures. If an established gate link exists towards your target direction, the ship steers directly into the transit gate.
- Re-rendered asset icons display precise vector compass markers (`North`, `South`, `North-West`, etc.) on the map plane.

**Gameplay Impact:**

- Massive reduction in micro-management travel orders across populated space, paired with explicit visual layout tracking.

</details>

### 🎖️ 20) Command Center Tab

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Adds a centralized "Command Center" tab to the Player Window that tracks every active ship in your fleet.

**Technical Adjustments:**

- Overhauled texture paths to look modern and sharp (`data/textures/icons/CommandCenterTab.png`), wired to `command_center_tab.lua`.

**Gameplay Impact:**

- Real-time tracking of background simulation commands (Mine, Trade, etc.) and physical sector orders (Looping, Patrolling).
- Displays ETAs for background missions and current status (Active, Recalled, Idle).
- **Remote Recall:** Recall any ship from its operation directly from the list without opening the Galaxy Map.

</details>

### 21) Restored 1.0 Orders & Looping

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Restores the classic map orders from Avorion 1.0, enabling complex automation loops.

**Gameplay Impact:**

- **Restored Orders:** Mine, Refine, Salvage, and Loop.
- **Advanced Looping:** Queue multiple orders (e.g., Jump -> Mine -> Jump -> Refine) and use the Loop command to repeat the entire sequence indefinitely.

**How To Use:** Hold down the "SHIFT" key while clicking orders to queue them to run one after another from the galaxy view map.

</details>

### ⚔️ 22) Simulated Station Profits & War Heat Synergies

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Simulates organic civilian traffic loops and service utility consumption across player-owned installations (Casinos, Depots, Repair Docks), yielding steady credit inflows and item generation.

**Ecosystem Integration:**

- Passive income yields are dynamically modified in real-time by local **War Heat** metrics calculated from the companion *Cosmic War* mod framework.

**Gameplay Impact:**

- High-conflict deployment zones face steep economic drops as commercial vessels avoid hazardous space. Players must actively defend and pacify logistics centers to maintain maximum financial output.

</details>

### ✨ 23) Galaxy Map Enhancements & QoL

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
The Galaxy Map has received massive visual and mechanical upgrades to reduce friction when planning out trade routes or organizing your fleets.

**Details:**

- **Custom Notes & Icons:** You can now freely place customizable icons, draw colorful rectangles, and leave persistent "sticky notes" directly on your galaxy map to mark hazard zones, lucrative trade routes, or alliance borders.
- **[T] Switch to Selected:** Instantly teleport to and take control of the ship you currently have selected on the galaxy map.
- **[Shift + C] Center on Home:** Instantly centers the galaxy map camera on your home sector. Dynamically centers on your Alliance home sector if you are piloting an alliance ship, or your personal home sector if piloting a personal ship.

**Gameplay Impact:**

- Drastically reduces mouse travel and clicking when managing large fleets.
- Faster recovery when panning across massive distances on the map.

</details>

### 24) Resource Display UI (Native Framework)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Deploys a lightweight, native HUD widget configured to monitor credits, raw minerals, cargo capacity metrics, and inventory allocations in real-time.

**Technical Architecture:**

- Fully engineered from scratch to completely isolate and **remove legacy AzimuthLib dependencies**.
- Automatically senses current vessel contexts, seamlessly swapping between personal accounting and Alliance vaults.
- Integrates custom graphical layouts (`data/textures/icons/ResourceDisplayTab.png`).

**Gameplay Impact:**

- Zero-latency oversight over structural empire assets without opening heavy system submenus.

</details>

### 25) Wreckages Strategy Tab

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Adds a new "Wreckages" tab to the Sector Strategy map (F9).

**Details:**

- Displays a sortable list of all wrecked ships and stations in the current sector.
- Sorts by mass/size (from "Tiny Scraps" up to "Colossal Husks") and distance from your ship.
- Uses dedicated texture asset hooks (`data/textures/icons/WreckagesTab.png`).

**Gameplay Impact:**

- Makes cleaning up massive post-battle graveyards much easier.
- Helps identify the largest and most lucrative salvage targets at a glance.

</details>

### 26) NPC Ship Naming Overhaul

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Completely rewrites the procedural naming arrays for NPC ships, safely injecting new terminology into the vanilla generation engine. Replaces generic, repetitive titles with highly immersive, volume-scaled naval and industrial classes.

**Details:**
Ship names now scale dynamically based on their generated block volume across four primary archetypes:

- **Military:** Scales realistically from nimble *Interceptors* and *Corvettes* up through *Cruisers*, *Dreadnoughts*, and colossal *Leviathans*.
- **Freighters:** Progresses from humble *Cargo Shuttles* and *Loaders* up to massive *Superfreighters* and *Logistics Leviathans*.
- **Miners:** Ranges from small *Light Prospectors* up through heavy *Mining Barges* to staggering *Planet Crackers* and *Mining Molochs*.
- **Traders:** Scales from fast *Couriers* to massive *Trade Galleons* and *Commercial Colossuses*.

**Gameplay Impact:**

- Massively improves immersion when scanning sectors or evaluating neutral traffic.
- Provides immediate, intuitive feedback on the actual size and threat level of an NPC vessel simply by reading its title.

</details>

### ✨ 27) War Zone Economy Blockades

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Stations located in active Cosmic War zones will instantly suspend all background AI Trader traffic and explicitly reject any Player docking requests to buy or sell goods.

**Gameplay Impact:**

- Locks down the local economy natively through `factory.lua` injection to prevent exploitation during active sieges.
- Forces players to secure the sector or travel elsewhere for commerce.

</details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Extensively upgrades trade command behavior and outcomes.

**Details:**

- Broader captain usability (removes strict merchant lock-in).
- Adjusted efficiency curves based on captain quality and class context.
- Immediate delivery toggle support.
- Charity mission mode for relationship-focused runs.
- Improved prediction, assessment messaging, and balancing.

**Gameplay Impact:**

- Trade commands are more flexible, less binary, and more strategic.
- Better alignment between captain identity, ship capability, and command output.

</details>

### 🎖️ C) Scout Command Improvements & Offline Catch-up

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Rewrites procedural log creation to inject rich narrative depth into exploratory feedback loops, while correcting execution priorities.

**Technical Adjustments:**

- **Execution Order Fix:** Corrected a logic bug within `scoutcommand.lua` where the offline simulation catch-up check was evaluated *after* the incremental sector loop completed.

**Gameplay Impact:**

- Highly immersive narrative scouting data.
- Scout fleets returning from offline simulation loops will now correctly and instantly reveal all discovered coordinate data the moment the server boots.

</details>

### 🎖️ D) Refine Command Improvements

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Adds refinement-path improvements with better simulation behavior and contextual outcomes.

**Gameplay Impact:**

- Better usability and reduced friction in refinement operations.
- More coherent risk vs. time feel.

</details>

### 🎖️ E) Travel Command Refinements

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Refines travel behavior and practical timing outcomes under safer, no-ambush contexts.

**Gameplay Impact:**

- Better pacing in non-combat logistics travel.
- Reduced dead-time during routine route execution.

</details>

### ✨ F) Salvage / Mine / Procure / Sell Simulation QoL

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Extends and improves several simulation command scripts for consistency and better persistence of selected behavior toggles.

**Technical Adjustments:**

- **Boundary Optimization:** Corrected an "off-by-one cell" boundary truncation calculation across map execution routines that previously forced a spurious "ship is not inside the target area" failure when drag-boxes hit absolute sector grid boundaries.
- **Alliance Ghost Ship Fix:** Patched a critical UI thread crash inside background handlers when tracking Alliance commands. The routine now safely rejects temporary 'Faction 0' placeholder tags passed during standard map updates.

**Gameplay Impact:**

- Perfectly stable automated operations across expansive server frameworks.

</details>

### 🎖️ G) New Captain Operations Modifiers

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Enhances captain operations with new modifiers, improved ranges, and updated loot tables.

**Details:**

- Adds **Exotic** and **Legendary** items into the salvage operation's loot table.
- Adds a modifier to increase the rewards, quality of items, or swiftness for various operations (currently modifies mining, scrap, travel, and scout).
- Adds a modifier to double the range of various operations. *Note: This will make certain operations take longer.*
- Adds a modifier to lower the ambush chance of various operations by 40%.

**Gameplay Impact:**

- Stronger incentives to run salvage operations late-game.
- Increased operational flexibility with improved ranges and rewards.
- Less frustration from random ambushes during map commands.

</details>

### 🎖️ H) Captain Synergy Expansion (Background Map Commands)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Fully overhauls background mechanics (`Sell`, `Procure`, `Salvage`, `Refine`, and `Travel`) to extensively amplify the efficiency of correctly assigned, specialized commanding classes.

**Synergy Metrics:**

- **Range Extension:** Matching the precise class to its native operation unlocks major operational range bonuses.
- **Velocity Tuning:** Reduces background operation completion durations and transit timings by **up to 25%**.
- **Risk Suppression:** Significantly drops localized ambush probability scores during active operations.

**Gameplay Impact:**

- Drives strategic crew assignments, heavily rewarding players who place specialized or multi-class captains into matching commercial, combat, or logistical roles.

</details>

### 🎖️ I) Active Captain Synergies (Piloting Passives)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Deploys sweeping passive modifiers that activate globally exclusively when the player is **actively piloting** a flagship commanded by a specific captain class.

**Active Modifiers:**

- **Active Merchant:** Unlocks a global **15% discount on item purchases** paired with a **15% bonus payout on sales** across all legal commercial stations (Trading Posts, Factories, Resource Depots).
- **Active Smuggler:** Unlocks a **15% reduction in unbranding fees** alongside a **15% bonus credit payout** on black market transactions processed through a Smuggler's Market.
- **Scavenger Strategy Intel:** Directly augments the Sector Strategy interface (F9). While piloting a Scavenger flagship, the system strips out obfuscated wreck names (such as "Husk" or "Derelict") and projects the **exact original vessel identity and class**, pinpointing high-value targets across post-battle debris fields.

**Gameplay Impact:**

- Provides compelling reasons to retain distinct elite captains on your personal flagship, shifting the role from a background numbers-booster into an active playstyle enhancer.

</details>

---

## 🏴‍☠️ Black Market / Smuggler’s Market Rework

### 🏗️ Structural Engineering: Dynamic API Injection

The massive, conflict-heavy legacy file override for `shiputility.lua` has been completely refactored and replaced with a surgical dynamic hook script. This advanced implementation strictly abides by Avorion’s Highlander Virtual File System specifications, guaranteeing total protection against mod conflicts, while completely isolating and restoring the black-market infrastructure.

<details>
<summary><b>Click to expand Black Market details</b></summary>

### What Changed

The Smuggler’s Market logic has been reworked so black-market trading is meaningfully profitable relative to risk and effort:

- **Lucrative Cargo Scales:** The hard-cap ceiling on illegal cargo dropped from annihilated civilian freighters has been elevated from a minor 25,000 credits to a massive **250,000 credits**, scaling relative to local sector richness.
- **Contraband Multipliers:** Illegal and high-risk goods can now be flipped at significantly stronger multipliers, pushing all the way up to full baseline value under optimal conditions.
- **Stolen Goods Handling:** Clean unbranding friction and cost formulas have been rebalanced downwards, making the "hijack -> sanitize -> deploy" loop practical and affordable.
- **The Fence System & Syndicate Heat:** The Smuggler's Market now natively unbrands up to 100 stolen goods per minute from its cargo hold. However, this passive fencing generates *Syndicate Heat*. Upon reaching a threshold of 5,000 unbranded goods, it triggers a massive Sector Lockdown, resulting in an immediate dual-punitive strike from both a Pirate raid and the local Faction Military!

### Why This Exists

In vanilla Avorion, illegal and stolen loops often felt under-rewarded due to high procurement risks, law enforcement scans, sector lockouts, and insufficient financial upside. This overhaul aims to keep the high-stakes fantasy and risk alive while making the reward side economically competitive with standard legal trade lanes.

### Gameplay Impact

- Deep-space piracy, contraband running, and black-market alignment become completely viable standalone career paths capable of sustaining a late-game fleet.

</details>



### 24) Full Localization Support

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Provides native language support for non-English players.

**Details:**

- **7 Supported Languages:** Cosmic Overhaul has been meticulously translated and integrated into Russian, Chinese, German, Spanish, French, Japanese, and Portuguese. Every custom UI, captain interaction, and background logic prompt will seamlessly display in the player's native language.

</details>

---

## 🎖️ Command & Captain Enhancements

### 🎖️ A) Persistent Background Command Progression (ARCC)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
The ARCC system calculates elapsed real-world time while the server was empty/offline and applies that time to your active captain commands upon server restart, treating it as if they kept working while you were away.

**Important Note for Private/Solo Servers:**
Because instantly processing hours of offline progression simultaneously can hang or crash small/private servers on boot (and rewards players for time the server was turned off), **offline simulation is disabled by default.**

**Gameplay Impact:**
- For 24/7 Dedicated Server admins: You can enable and strictly cap offline simulation parameters using the Mod Configuration Menu (MCM) to guarantee strategic continuity for your playerbase.
- For Solo/Private Servers: Booting your server is fast, safe, and free from offline "free resource" exploits.

</details>

### 🎖️ B) Trade Command Overhaul (Major)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Extensively upgrades trade command behavior and outcomes.

**Details:**

- Broader captain usability (removes strict merchant lock-in).
- Adjusted efficiency curves based on captain quality and class context.
- **Immediate Delivery Toggle:** Enables quick delivery. Bypasses travel loops but significantly reduces payout.
- **Charity Toggle:** Trades profit for significant faction relation boosts.

</details>

### ⚙️ C) New Sell Command Feature

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
Significantly expands the reward table and logic behind salvaging operations.

**Details:**

- Exotic and Legendary items can now be recovered.
- Salvaging operations can process raw scrap into refined metals directly if specific captain synergies exist.

</details>

### F) Scouting Expansion

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Scouting commands now reveal greater depth of sector information and generate rich narrative logs.

</details>

### 🎖️ G) New Captain Operations Modifiers

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Enhances captain operations with new modifiers, improved ranges, and updated loot tables.

**Details:**

- Adds **Exotic** and **Legendary** items into the salvage operation's loot table.
- Adds a modifier to increase the rewards, quality of items, or swiftness for various operations.
- Adds a modifier to double the range of various operations. *Note: This will make certain operations take longer.*

</details>

### 🎖️ H) Captain Synergy Expansion (Background Map Commands)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Fully overhauls background mechanics (Sell, Procure, Salvage, Refine, and Travel) to extensively amplify the efficiency of correctly assigned, specialized commanding classes.

**Synergy Metrics:**

- **Range Extension:** Matching the precise class unlocks major operational range bonuses.
- **Velocity Tuning:** Reduces background operation completion durations and transit timings by **up to 25%**.
- **Risk Suppression:** Significantly drops localized ambush probability scores during active operations.

</details>

### 🎖️ I) Active Captain Synergies (Piloting Passives)

<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Deploys sweeping passive modifiers that activate globally exclusively when the player is **actively piloting** a flagship commanded by a specific captain class.

**Active Modifiers:**

- **Active Merchant:** Unlocks a global **15% discount on item purchases** paired with a **15% bonus payout on sales** across all legal commercial stations (Trading Posts, Factories, Resource Depots).
- **Active Smuggler:** Unlocks a **15% reduction in unbranding fees** alongside a **15% bonus credit payout** on black market transactions processed through a Smuggler's Market.

</details>

---

## 🏴‍☠️ Black Market / Smuggler's Market Rework

### 🏗️ Structural Engineering: Dynamic API Injection

The massive, conflict-heavy legacy file override for shiputility.lua has been completely refactored and replaced with a surgical dynamic hook script. This advanced implementation strictly abides by Avorion's Highlander Virtual File System specifications, guaranteeing total protection against mod conflicts, while completely isolating and restoring the black-market infrastructure.

<details>
<summary><b>Click to expand Black Market details</b></summary>

### What Changed

The Smuggler's Market logic has been completely reworked into a massive criminal enterprise:

- **Lucrative Cargo Scales:** The hard-cap ceiling on illegal cargo dropped from annihilated civilian freighters has been elevated from a minor 25,000 credits to a massive **250,000 credits**, scaling relative to local sector richness.
- **Contraband Multipliers:** Illegal and high-risk goods can now be flipped at significantly stronger multipliers, pushing all the way up to full baseline value under optimal conditions.
- **Smuggler Governors:** Assigning a Smuggler captain as the governor of your market grants a 35% bonus profit payout on stolen goods and a 50% extra discount on unbranding fees!
- **The Fence System:** The Smuggler's Market will now automatically unbrand up to 100 stolen goods per minute natively from its cargo hold.
- **Syndicate Heat:** Passive unbranding generates heat. Unbranding 5,000 goods will trigger a massive Sector Lockdown, spawning both a Pirate Raid and a punitive local Faction Military attack aimed directly at your market!
- **Raid Lockouts:** To prevent server-crashing raid queues when piping goods via Supply Lines, the Syndicate Heat system features a 1-Hour real-time cooldown. If heat caps out during the cooldown, the raid simply waits until the hour is up.

**Details:**

- **7 Supported Languages:** Cosmic Overhaul has been meticulously translated and integrated into Russian, Chinese, German, Spanish, French, Japanese, and Portuguese. Every custom UI, captain interaction, and background logic prompt will seamlessly display in the player's native language.

</details>


---

## 🔗 Cosmic Series Integration
<details>
<summary><b>Click to expand</b></summary>

### 📖 Cosmic Codex Integration
All deep lore, stat blocks, and dynamic recipes have been fully integrated into the in-game **Cosmic Codex**. You no longer need to tab out of the game to read these features; they will natively update and unlock inside your Codex UI as you progress!

### 🌌 Cosmic Vault
- **Deep Economy Warfare:** Cosmic Overhaul's localized Famine Events now natively tie into the `CosmicVaultEconomy` API, which can physically force starving factions to declare war on wealthy neighbors to survive!
- **Unified News API:** Overhaul's myriad of ambient events and galactic occurrences are now securely routed through the new `CosmicVaultNews.publishArticle` architecture, guaranteeing cross-mod UI stability.

### 🔒 Network Safety & Anti-Cheat
- **Math.Random Fix:** We systematically replaced all unstable Lua `math.random` calls with Avorion's deterministic `random():getInt()` generation sequence. This guarantees 100% synchronization on Multiplayer Dedicated Servers and prevents cascading desyncs during massive fleet spawns.
- **Callable Validation:** UI and background scripts have been fully hardened. Malicious clients can no longer spoof "free" remote calls; the server actively verifies execution contexts before processing any requests, sealing multiple Arbitrary Code Execution (ACE) vulnerabilities.

### 🛠️ Vanilla Bug Fixes
- **Scout Mission Fix:** We patched a massive, long-standing vanilla bug where Scout Missions would completely skip and ignore Faction Headquarters sectors because the native dialogue trees were missing the template definition.
</details>


---

### Log Streamlining
The Trading Manager logic has been streamlined to gracefully skip dead simulation ticks without flooding server console logs.

## Famine Penalties
When an AI faction reaches 'Severe Famine', all newly spawned ships will inherently have 60% weaker shields and move 40% slower.

---

## Cosmic Vault Synergy

**What it is:**
`Cosmic Overhaul` is built from the ground up to deeply integrate with the rest of the Cosmic modpack suite. When used alongside `Cosmic Vault`, `Cosmic Chronicles`, `Cosmic War`, and `Cosmic Ascendancy`, the following synergistic mechanics are unlocked:

- **Dynamic Trade Pricing:** Your passive Trade Command operations now sync with the galactic live economy. If you send a merchant to trade with a faction suffering from a Famine, they can bring in up to 2.5x more profits!
- **Weather-Affected Commands:** Your map operations (Travel, Scout) respect `Cosmic Vault`'s dynamic weather systems. Traveling through an Ion Storm or Nebula will delay operations by 50% unless piloted by an Explorer or Navigator.
- **Siege Blockade Halts:** When a sector turns into an active War Zone, factories will dynamically calculate the strength of the invaders versus the defenders. If the defenders are outgunned 2:1, factory production completely halts, simulating an economic blockade.
- **War Profiteering:** Delivering goods to a blockaded factory or trading in a high-heat War Zone provides a massive +250% income multiplier. High Risk, High Reward!
- **Scout Anomalies:** Explorer captains actively leave cryptic notes on empty sectors on your galactic map, hinting at where you can find `Cosmic Chronicles` narrative events.
- **Deep Economy Warfare:** Famines and Booms generated in Overhaul sync directly to the `CosmicVaultEconomy` API, which forces starving factions to go to war to survive.
- **Unified News System:** All events broadcast flawlessly through the `CosmicVaultNews` API, guaranteeing your Universal Bulletin Board is always up to date.
- **Famine Relief Charity:** Background Charity Missions sent to starving factions natively grant a +50% Reputation multiplier.
- **Ascendancy Trade Fear:** Merchant trade flights take 20% longer if the target faction is at war with The Eclipse. Smugglers natively bypass this hazard penalty.
- **Entrenched Diplomatic Suicide:** The Alliance reputation mirroring penalty is multiplied by 1.5x if a player commits a hostile act against a faction possessing the `Fortified` trait.
- **Siege Salvage Yield:** Scavenger captains actively flying inside a Contested Siege Zone receive a +20% Salvage Yield buff while cleaning up dreadnought wreckages.
- **Smuggler Deflation:** A Smuggler captain idling in a sector will passively heal the controlling faction's Famine Score, stabilizing the economy through the black market.
