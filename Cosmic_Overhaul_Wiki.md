# Cosmic Overhaul - Detailed Features

Below is a complete, user-facing rundown of what Cosmic Overhaul currently includes, with practical details on what each feature does.

---

## System Features

### 1) Allied Relations Enhancer
**What it does:** Improves alliance/faction relation progression feel by increasing the impact of your positive interaction loops, making allied diplomacy feel more responsive and meaningful.

**Gameplay impact:** - Faster reinforcement of good-standing faction ties.
- Better payoff for trade/protection/helpful actions in sustained faction play.

### 2) Dynamic Reputation Decay
**What it does:** Introduces inactivity-based relation decay to AI factions over time. If you ignore relations for too long, they naturally cool down.

**How it works (high level):**
- Server-side timed decay checks.
- Scales with inactivity windows (not instant penalties).
- Applies to player/alliance relation pathways.

**Gameplay impact:** - Encourages ongoing diplomacy and engagement.
- Prevents “set-and-forget” permanent max reputation states in long saves.

### 3) Dynamic Station Shuttle Scaling
**What it does:** Expands and rebalances shuttle behavior/capacity progression for station logistics.

**Gameplay impact:** - Better station throughput scaling.
- Improved late-game station utility and production responsiveness.

### 4) Dynamic Stock / Goods Flow Improvements
**What it does:** Adjusts station goods behavior and trade flow assumptions to feel less static and more activity-driven.

**Gameplay impact:** - More believable commerce loops.
- Better opportunities to profit from active logistics and supply positioning.

### 5) Equipment Dock / Merchant Inventory Improvements
**What it does:** Rebalances availability and variety in relevant merchant inventories (subsystems, turrets, fighters, etc.).

**Gameplay impact:** - Reduced frustration from low-value refresh cycles.
- Better progression feel when searching for useful components.

### 6) Shop Restock Button (Overhaul Variant)
**What it does:** Adds integrated restock functionality with overhaul-specific balancing (free uses first, then cooldown-sensitive behavior).

**Gameplay impact:** - Better merchant usability during active fitting sessions.
- Preserves balance versus unlimited spam restocking.

*Note: This is intentionally not the same behavior as the standalone Shop Restock Revamped mod.*

### 7) Permanent Subsystem Removal at More Stations
**What it does:** Enables permanent subsystem removal at additional station types (e.g. Repair Dock, Shipyard, Military Outpost, Research, Scrapyard, etc.).

**Gameplay impact:** - More ship build flexibility.
- Easier correction of long-term build mistakes without extreme rerouting.

### 8) Scrapyard QoL / Time-Limit Removal
**What it does:** Removes restrictive scrapyard timing friction and improves scrapyard flow.

**Gameplay impact:** - Smoother salvage gameplay sessions.
- Less downtime and fewer unnecessary interruptions.

### 9) Transfer Window Enhancements (Cargo UX)
**What it does:** Improves transfer UI behavior, readability, and handling (including better visual handling for risky cargo states).

**Gameplay impact:** - Faster cargo management.
- Better clarity while handling mixed legal/illegal/stolen inventories.

### 10) Universal Bulletin Board (Player-Centric Access)
**What it does:** Adds/extends bulletin board accessibility from the player-side UI workflow for quicker mission access and less station-by-station friction.

**Gameplay impact:** - Faster mission acquisition.
- Better flow when juggling fleets and objectives.

### 11) Factory Overview Tab (Economic Analytics)
**What it does:** Adds player-side factory analytics with tracking for:
- money gained,
- money spent,
- tax contribution,
- profitability tendencies,
- working-state status over runtime.

**Gameplay impact:** - Better strategic visibility into production chains.
- Easier identification of underperforming factories and bottlenecks.

### 12) Trade Heatmap Expansion
**What it does:** Extends trade heatmap behavior and range utility based on subsystem quality progression.

**Gameplay impact:** - Better route planning quality.
- Stronger value from higher-end trading configurations.

### 13) Transporter Range Scaling by Block Investment
**What it does:** Transporter subsystem range receives extra scaling from transporter block investment on the ship plan.

**Gameplay impact:** - More consistent “build investment -> functional payoff”.
- Better support for logistics-focused ship design.

### 14) Ship/Fleet Info Extensions
**What it does:** Extends player ship information flows (including strategy/fleet utility visibility) for better operational awareness.

**Gameplay impact:** - Better command and logistics oversight.
- More informed decisions during multitask/fleet-heavy play.

#### Fleet Ship Status UI (Integrated + Refactored)
Cosmic Overhaul now includes integrated Fleet Ship Status functionality with the original proven **entity-owned** architecture.

**Implementation model:**
- Active script owner: `data/scripts/entity/fleetstatus.lua`
- Entity attach path: `data/scripts/entity/init.lua`
- Deprecated player path removed from auto-init:
  - `data/scripts/player/init.lua` no longer attaches `data/scripts/player/fleetstatus.lua`
- A compatibility no-op shim remains at:
  - `data/scripts/player/fleetstatus.lua`
  - This prevents stale legacy invoke paths from crashing saves.

**Why this architecture was used:**
A previous split player/entity flow caused ScriptUI to initialize in player context, which can fail because Fleet Status window/hud creation is entity-context dependent.

**Resolved behavior after fix:**
- FSS icon appears correctly.
- Clicking FSS opens the Fleet Ship Status window.
- Fleet/HUD options function correctly.
- No repeated FleetStatus stack traces during option interaction.

### 15) ReSeed / Randomization Improvements
**What it does:** Expands randomization quality in relevant generation paths to improve diversity and reduce repetitive outcomes.

**Gameplay impact:** - More varied progression and loot/session feel.
- Less repetition in long campaigns.

### 16) UI Settings Persistence for Command/Workflow States
**What it does:** Persists selected UI/config states across sessions for improved continuity in map-command workflows.

**Gameplay impact:** - Less repetitive reconfiguration after relog/restart.
- Better long-session convenience.

### 17) Wreckage / Salvage Workflow Improvements
**What it does:** Adds strategy-mode salvage quality-of-life support for quicker targeting and cleanup flow.

**Gameplay impact:** - Faster post-combat salvage management.
- Better high-volume debris handling.

### 18) Trash Manager (Integrated)
**What it does:** Adds robust inventory filtering + bulk trash marking flow with preview support, for private and alliance inventory contexts.

**Details:**
- Marks as trash (does **not** force-delete/sell immediately).
- Favorites are protected/skipped.
- Tech-range filtering support.
- Supports merchant-driven “Sell Trash” loops.

**Gameplay impact:** - Dramatically faster inventory cleanup.
- Safer mass-processing of loot without accidental important-item loss.

---

## Command & Captain Enhancements

Cosmic Overhaul includes substantial enhancements to Avorion background command simulation.

### A) Persistent Background Command Progression
**What it does:** Background captain commands are treated more consistently during offline/return scenarios, with improved progression behavior and risk continuity.

**Gameplay impact:** - Better strategic continuity.
- Less “frozen world” feeling when returning to active saves.

### B) Trade Command Overhaul (Major)
**What it does:** Extensively upgrades trade command behavior and outcomes, including:
- broader captain usability (not only strict merchant lock-in),
- adjusted efficiency curves by captain quality/class context,
- immediate delivery toggle support,
- charity mission mode for relationship-focused runs,
- improved prediction/assessment messaging and balancing.

**Gameplay impact:** - Trade command is more flexible, less binary, and more strategic.
- Better alignment between captain identity, ship capability, and command output.

### C) Scout Command Improvements
**What it does:** Enhances scouting reliability/quality with better simulation behavior and exploration utility scaling.

**Gameplay impact:** - Better scouting value in real campaign conditions.
- Improved map progression quality for exploration-focused playstyles.

### D) Refine Command Improvements
**What it does:** Adds refinement-path improvements with better simulation behavior and contextual outcomes.

**Gameplay impact:** - Better usability and reduced friction in refinement operations.
- More coherent risk/time feel.

### E) Travel Command Refinements
**What it does:** Refines travel behavior and practical timing outcomes under safer/no-ambush contexts.

**Gameplay impact:** - Better pacing in non-combat logistics travel.
- Reduced dead-time in routine route execution.

### F) Salvage / Mine / Procure / Sell Simulation QoL
**What it does:** Extends and improves several simulation command scripts for consistency and better persistence of selected behavior toggles.

**Gameplay impact:** - More predictable autonomous fleet operation.
- Less micromanagement overhead.

---

## Black Market / Smuggler’s Market Rework

A major user-requested feature in Cosmic Overhaul is the black market economy pass so illegal cargo is no longer disproportionately low-value versus its acquisition risk.

### What changed
The Smuggler’s Market logic has been reworked so black-market trading is meaningfully profitable relative to risk and effort:
- **Illegal cargo** can now be sold at a much stronger multiplier (up to full base value in current tuning).
- **Dangerous goods** are accepted with a moderate multiplier.
- **Stolen goods** retain discounted handling but at improved rates compared to strict vanilla expectations.
- **Unbranding costs** are rebalanced to make the “steal -> clean -> sell/use” loop less punishing and more practical.

### Why this exists
In vanilla, illegal/stolen loops often felt under-rewarded:
- high procurement risk,
- smuggling/detection risk,
- reputation/route risk,
- but insufficient final economic upside.

This overhaul aims to keep the fantasy and risk while making the reward side economically worthwhile.

### Gameplay impact
- Smuggling-focused runs become legitimately viable.
- Black market station interactions matter more.
- Illegal-cargo logistics can support real progression instead of novelty-only gameplay.