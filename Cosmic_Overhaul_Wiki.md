# Cosmic Overhaul - Detailed Features

Welcome to the **Cosmic Overhaul** official wiki! Below is a complete, user-facing rundown of the features currently included in the mod, complete with practical details on how each mechanic impacts your gameplay.

---

## Table of Contents
- [System Features](#system-features)
- [Command & Captain Enhancements](#command--captain-enhancements)
- [Black Market / Smuggler’s Market Rework](#black-market--smugglers-market-rework)

---

## System Features

### 1) Allied Relations Enhancer
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Improves alliance and faction relation progression by increasing the impact of your positive interaction loops, making diplomacy feel more responsive and meaningful.

**Gameplay Impact:**
- Faster reinforcement of good-standing faction ties.
- Better payoff for trade, protection, and helpful actions during sustained faction play.
</details>

### 2) Dynamic Reputation Decay
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Introduces inactivity-based relation decay to AI factions over time. If you ignore relations for too long, they will naturally cool down.

**How it works:**
- Server-side timed decay checks.
- Scales with inactivity windows (penalties are gradual, not instant).
- Applies to both player and alliance relation pathways.

**Gameplay Impact:**
- Encourages ongoing diplomacy and engagement.
- Prevents “set-and-forget” permanent max reputation states in long campaigns.
</details>

### 3) Dynamic Station Shuttle Scaling
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

### 5) Equipment Dock / Merchant Inventory Improvements
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Rebalances availability and variety in relevant merchant inventories (e.g., subsystems, turrets, fighters).

**Gameplay Impact:**
- Reduced frustration from low-value refresh cycles.
- Better progression feel when searching for useful components.
</details>

### 6) Shop Restock Button (Overhaul Variant)
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Adds integrated restock functionality with overhaul-specific balancing (grants free uses first, then transitions to cooldown-sensitive behavior).

**Gameplay Impact:**
- Better merchant usability during active fitting sessions.
- Preserves balance by preventing unlimited spam restocking.

*Note: This is intentionally different from the standalone **Shop Restock Revamped** mod.*
</details>

### 7) Permanent Subsystem Removal at More Stations
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Enables permanent subsystem removal at additional station types (e.g., `Repair Dock`, `Shipyard`, `Military Outpost`, `Research Station`, and `Scrapyard`).

**Gameplay Impact:**
- More ship building flexibility.
- Easier correction of long-term build mistakes without requiring extreme rerouting.
</details>

### 8) Scrapyard QoL / Time-Limit Removal
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Removes restrictive scrapyard timing friction and improves overall scrapyard flow.

**Gameplay Impact:**
- Smoother salvage gameplay sessions.
- Less downtime and fewer unnecessary interruptions.
</details>

### 9) Transfer Window Enhancements (Cargo UX)
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Improves transfer UI behavior, readability, and handling, including better visual feedback for risky cargo states.

**Gameplay Impact:**
- Faster cargo management.
- Better clarity while handling mixed legal, illegal, or stolen inventories.
</details>

### 10) Universal Bulletin Board (Player-Centric Access)
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Extends bulletin board accessibility from the player-side UI workflow for quicker mission access and reduced station-by-station friction.

**Gameplay Impact:**
- Faster mission acquisition.
- Better flow when juggling fleets and objectives.
</details>

### 11) Factory Overview Tab (Economic Analytics)
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Adds player-side factory analytics with tracking for money gained, money spent, tax contributions, profitability tendencies, and working-state status over time.

**Gameplay Impact:**
- Better strategic visibility into production chains.
- Easier identification of underperforming factories and bottlenecks.
</details>

### 12) Trade Heatmap Expansion
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Extends trade heatmap behavior and range utility based on subsystem quality progression.

**Gameplay Impact:**
- Better route planning quality.
- Stronger value from higher-end trading configurations.
</details>

### 13) Transporter Range Scaling by Block Investment
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Transporter subsystem range receives extra scaling based on the transporter block investment on the ship plan.

**Gameplay Impact:**
- More consistent “build investment to functional payoff” ratio.
- Better support for logistics-focused ship designs.
</details>

### 14) Ship/Fleet Info Extensions
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Extends player ship information flows to provide better operational awareness, including strategy and fleet utility visibility. Includes the integrated **Fleet Ship Status UI**.

#### Fleet Ship Status UI (Integrated + Refactored)
Cosmic Overhaul includes integrated **Fleet Ship Status** functionality utilizing the original proven **entity-owned** architecture.

**Technical Details:**
- **Active script owner:** `data/scripts/entity/fleetstatus.lua`
- **Entity attach path:** `data/scripts/entity/init.lua`
- **Deprecated player path removed:** `data/scripts/player/init.lua` no longer attaches `data/scripts/player/fleetstatus.lua`.
- A compatibility no-op shim remains at `data/scripts/player/fleetstatus.lua` to prevent stale legacy invoke paths from crashing saves.

*Note: This architecture prevents `ScriptUI` from initializing in the player context, which would otherwise fail because the window and HUD creation depends on the entity context.*

**Gameplay Impact:**
- Better command and logistics oversight.
- More informed decisions during multitask or fleet-heavy play.
- FSS icon appears correctly, opens the window reliably, and prevents repeated stack traces.
</details>

### 15) ReSeed / Randomization Improvements
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Expands randomization quality in relevant generation paths to improve diversity and reduce repetitive outcomes.

**Gameplay Impact:**
- More varied progression and loot drops.
- Less repetition in long campaigns.
</details>

### 16) UI Settings Persistence for Command/Workflow States
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Persists selected UI and configuration states across sessions for improved continuity in map-command workflows.

**Gameplay Impact:**
- Less repetitive reconfiguration after a relog or restart.
- Better convenience during long play sessions.
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

### 18) Trash Manager (Integrated)
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Adds robust inventory filtering and a bulk trash marking flow with preview support, available for both private and alliance inventory contexts.

**Details:**
- Marks items as trash (does **not** force-delete or sell them immediately).
- Favorites are protected and skipped.
- Tech-range filtering support.
- Supports merchant-driven “Sell Trash” loops.

**Gameplay Impact:**
- Dramatically faster inventory cleanup.
- Safer mass-processing of loot without the risk of accidentally losing important items.
</details>

### 19) Gate Travel Priority & Icon Compasses
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Inverts Avorion's priority for player-issued travel commands via the map, placing emphasis on gates and wormholes instead of hyperspace jumps.

**Details:**
- When enchaining jump orders on the map, ships will prioritize gate and wormhole connections. If the ship is in a system with known gate connections, enchaining jump commands to those targets will order the ship to fly through the gates instead. This even works for wormholes with distant connections.
- Changes gate icons to display a compass arrow (`North`, `South`, `West`, `East`, `NW`, `SW`, etc.), indicating which way they lead.

**Gameplay Impact:**
- Smoother map navigation and travel routing logic.
- Better visual clarity on the galaxy map for where gates connect.
</details>

---

## Command & Captain Enhancements

Cosmic Overhaul includes substantial enhancements to Avorion's background command simulation.

### A) Persistent Background Command Progression
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Background captain commands are treated more consistently during offline or return scenarios, featuring improved progression behavior and risk continuity.

**Gameplay Impact:**
- Better strategic continuity.
- Less of a “frozen world” feeling when returning to active saves.
</details>

### B) Trade Command Overhaul (Major)
<details>
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

### C) Scout Command Improvements
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Enhances scouting reliability and quality with better simulation behavior and exploration utility scaling.

**Gameplay Impact:**
- Better scouting value in real campaign conditions.
- Improved map progression quality for exploration-focused playstyles.
</details>

### D) Refine Command Improvements
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Adds refinement-path improvements with better simulation behavior and contextual outcomes.

**Gameplay Impact:**
- Better usability and reduced friction in refinement operations.
- More coherent risk vs. time feel.
</details>

### E) Travel Command Refinements
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Refines travel behavior and practical timing outcomes under safer, no-ambush contexts.

**Gameplay Impact:**
- Better pacing in non-combat logistics travel.
- Reduced dead-time during routine route execution.
</details>

### F) Salvage / Mine / Procure / Sell Simulation QoL
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Extends and improves several simulation command scripts for consistency and better persistence of selected behavior toggles.

**Gameplay Impact:**
- More predictable autonomous fleet operation.
- Less micromanagement overhead.
</details>

### G) New Captain Operations and Other Operations!
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

---

## Black Market / Smuggler’s Market Rework

A major user-requested feature in **Cosmic Overhaul** is the black market economy pass, ensuring illegal cargo is no longer disproportionately low-value versus its acquisition risk.

<details>
<summary><b>Click to expand Black Market details</b></summary>

### What Changed
The Smuggler’s Market logic has been reworked so black-market trading is meaningfully profitable relative to risk and effort:
- **Illegal Cargo:** Can now be sold at a much stronger multiplier (up to full base value in current tuning).
- **Dangerous Goods:** Accepted with a moderate multiplier.
- **Stolen Goods:** Retain discounted handling but at improved rates compared to strict vanilla expectations.
- **Unbranding Costs:** Rebalanced to make the “steal -> clean -> sell/use” loop less punishing and more practical.

### Why This Exists
In vanilla Avorion, illegal and stolen loops often felt under-rewarded due to:
- High procurement risk.
- Smuggling and detection risk.
- Reputation and route risk.
- Insufficient final economic upside.

This overhaul aims to keep the fantasy and risk alive while making the reward side economically worthwhile.

### Gameplay Impact
- Smuggling-focused runs become legitimately viable.
- Black market station interactions matter more.
- Illegal-cargo logistics can support real progression instead of novelty-only gameplay.
</details>