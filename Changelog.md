# Changelog

All notable changes to **Cosmic Overhaul** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Never remove, overwrite or write above this

## v5.0.0 (CURRENT PROJECT VERSION - NO RELEASE DATE YET!)


### 🚀 Major Overhaul Features
- **Captain Elite Traits:** Level 3 Captains now possess massive sector-wide or unique bonuses:
  - **Commodores:** Provide a global +10% Shield and +10% Damage buff to all player/alliance ships in the sector.
  - **Miners:** Gain an immense +25 area command bonus to the Mining map operation.
  - **Smugglers:** Provide the ship with absolute immunity to all cargo and contraband inspections.
- **Station Governors:** Players can now assign idle captains to their stations as "Governors" for massive economic and defensive bonuses:
  - **Merchant Governors:** Boost passive station income by 25% and increase AI trader traffic by 50%.
  - **Engineer Governors:** Boost the factory's maximum shuttle volume capacity by 50%.
- **The Syndicate Hub Expansion:** The Smuggler's Market is now a massive criminal enterprise:
  - **Smuggler Governors:** Assigning a Smuggler as governor to your market grants a 35% bonus profit payout on stolen goods and a 50% extra discount on unbranding fees!
  - **The Fence System:** The Smuggler's Market will now automatically unbrand up to 100 stolen goods per minute natively from its cargo hold.
- **True Supply Lines:** Added a new background map command `Supply Line`. Establish continuous, automated ferry routes to infinitely transfer a configurable good between your current location and a designated target sector without needing cumbersome manual loops.
- **Cosmic Codex Integration:** The mod now fully supports the Cosmic Codex! Comprehensive lore and mechanical documentation (such as features, UI tools, and dynamic events) are now readable directly in-game from the new Cosmic Codex tab.
- **Dynamic Subspace Weather**: Sector environments are no longer static. Introduced `co_weather_generator.lua` to dynamically generate weather hazards across the galaxy.
- **Ion Storms**: Completely disables radar systems and hyperspace capability.
- **Solar Flares**: Intensely radiated sectors that strip shields and gradually disintegrate unshielded hulls over time.
- **Global Weather Ticker**: A 15% chance per tick to spawn weather in random populated sectors (Maximum 5 active globally). Weather persists across server reboots.

### ✨ Added
- **Persistence Resource Regeneration:** Asteroid fields now naturally regenerate over real-time (background processed). Regeneration is heavily tied to the Cosmic Vault economy API; factions suffering from 'Severe Famine' will see all natural resource regeneration pause in their sectors, while 'Resource Starved' factions will regenerate at half-speed.
- **Emergency Replenishment Anomalies & News:** When a completely barren sector triggers an emergency resource replenishment, there is a 5% chance to unearth a Precursor Wreck or Spatial Rift. In populated sectors, this triggers an instant galaxy-wide breaking news alert via Cosmic Chronicles.
- Implemented the Famine Debuff system (`co_famine_debuff.lua`) hooked into the Vault Economy API.
- **War Zone Blockades:** Stations located in active Cosmic War zones will instantly suspend all background AI Trader traffic and explicitly reject any Player docking requests to buy or sell goods, locking down the local economy natively through `factory.lua` injection.
- **Deep Wiki Integration:** Injected 43+ detailed mechanical and lore articles straight from the official Wiki into the Cosmic Codex. Features like Empire Management, Captain Synergies, and the Black Market rework are fully documented in-game.
- **Sealed Hulks (Boarding Operations):** Deep space hidden mass sectors now have a chance to generate a massive "Sealed Hulk." Docking with these derelicts initiates an interactive "Choose Your Own Adventure" text event where you risk your crew against automated defenses, radiation leaks, and blast doors for massive payouts and Legendary subsystem drops!
- **Tag-Based AI Generation:** Replaced rigid Vanilla Faction tracking with a robust new tag-based AI (`[Aggressive]`, `[Passive]`, `[Trader]`).
- **Dynamic AI Behaviors:** Factions now organically calculate their AI routines (Patrol vs Trade) using the Vault Faction Tag system rather than static hardcoded tables.
- **Cosmic Vault API Framework:** Fully integrated with the Cosmic Vault API framework. Swept codebase for legacy callbacks and implemented safe pcall fallbacks.

### ⚖️ Balance
- **Galactic Turn Synchronization:** `respawnInterval` changed from 10m to 20m. `profitableStationsInterval` synced to 1200s (20m) to align with the global server turn, massively reducing asynchronous background processing and eliminating server micro-stutter.
- **Economic Stabilization:** To compensate for the Profitable Stations interval doubling from 10m to 20m, the base payouts have been strictly doubled (Credit base: 8k -> 16k, Resource base: 3.5k -> 7k). The economy remains perfectly balanced without punishing players for the new performance optimizations.

### 🐛 Bug Fixes & Optimization
- **Trading Manager Spam:** Completely eradicated the `Activity level is zero or negative` console spam which flooded server logs.
- **RNG Calculation Math Bug:** Swept the codebase and replaced critical logic faults in Station Governors and AI Traders where probability checks were evaluating against `getInt()` instead of `getFloat()`, restoring exact percentage math for random economic events.
- **Trading Manager Spam:** Fixed an issue where the "Activity level is zero or negative..." warning in `tradingmanager.lua` would spam the server logs every second. It now only prints once per session.
- **Shop UI Crash:** Reinstated `self.currencyLabel` in `shop.lua` to prevent crashes when interacting with merchants.
- **UI Memory Leaks Sealed:** Injected `onRemove()` functions into UI scripts like the Bulletin Board and Resource Display. Previously, jumping sectors caused the UI to secretly stack invisible event listeners, leading to massive memory bloat in late-game.
- **Multiplayer Networking & Stability:** Added missing `callable()` declarations to Factory upgrade buttons so they work properly on Dedicated Servers. Also added `onClient()` wrappers to Stash and Galaxy Map scripts to prevent the singleplayer server thread from crashing itself with errant network calls.
- **Performance & TPS Optimization:** Drastically reduced server load during late-game scenarios. Injected a hardcoded `getUpdateInterval` throttle into 5 major AI and UI scripts (`refineores`, `factory`, `transfercrewgoods`, `shipinfo`, `sectorshipoverview`). This prevents highly-industrialized player sectors from dragging down Server TPS by throttling factory logic to run once every 5 seconds instead of 60 times a second.
- **Scout Mission Fix:** Fixed a massive vanilla/mod bug where Scout Missions would completely skip and ignore Faction Headquarters sectors because the `scoutcommandnotetable` lacked dialogue lines for that specific sector template.
- **Multiplayer Desyncs:** Replaced `math.random` with the deterministic engine `random():getInt()` across all custom scripts to prevent massive physics and stats desyncs in multiplayer.
- Severe Famine debuff reduces shields by 60% and velocity by 40%.
- Removed `pcall` soft-dependencies. Core 5 mods are now hard requirements.
