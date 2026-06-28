# Changelog

All notable changes to **Cosmic Overhaul** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Never remove, overwrite or write above this

## [v5.0.0] UNRELEASED WORKSHOP VERSION (PROJECT UNDER DEVELOPMENT)

### 🌌 Cosmic Vault Synergy (Cross-Mod Engine)
- **Deep Economy Warfare:** Cosmic Overhaul's localized Famine Events now natively tie into the `CosmicVaultEconomy` API, which can physically force starving factions to declare war on wealthy neighbors to survive!
- **Unified News API:** Overhaul's myriad of ambient events and galactic occurrences are now securely routed through the new `CosmicVaultNews.publishArticle` architecture, guaranteeing cross-mod UI stability.
- **Dynamic Trade Pricing:** Hooked offline Merchant Trade commands into `cv_economy`. Trading with a Famine-struck faction now yields up to 2.5x more passive profit.
- **Weather-Affected Map Commands:** Offline Travel and Scout commands now ping `cv_weather`. Navigating hazardous weather (Ion Storms, Nebulas) delays offline map operations by 50% unless piloted by an Explorer or Navigator.
- **Siege Blockade Halts:** Factories dynamically poll `cv_scaling`. If the sector is a War Zone and the defenders are outgunned 2:1, all factory production halts entirely until the siege is lifted.
- **War Profiteering:** `managestationincomes.lua` reversed from a penalty to a massive bonus. Supplying 100% Heat War Zones now yields a 250% income bonus instead of a 20% penalty.
- **Scout Anomalies:** Explorer Captains charting empty sectors will now leave notes hinting at `Cosmic Chronicles` narrative events.
- **Reputation Decay Scaling:** Halved the base Dynamic Reputation Decay rate from 100/hr to 50/hr to synergize with the massive endgame campaigns in `Cosmic Ascendancy`.
- **Alliance Mirroring Parity:** Scaled diplomatic rep gain mirroring for Alliances from 2x down to 1x to prevent massive "cascade wars" in `Cosmic War` / `Cosmic Ascendancy`.
- **Loot Variance Boost:** Pushed the unseeded wild-generation chance for Exotic and Legendary drops from 50% to 75% for enhanced endgame loot variety.

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
  - **Syndicate Heat:** Passive unbranding generates heat. Unbranding 5,000 goods will trigger a massive Sector Lockdown, spawning both a Pirate Raid and a punitive local Faction Military attack aimed directly at your market!
  - **Raid Lockouts:** The Syndicate Heat system is now safely capped and features a 1-Hour real-time cooldown to prevent server-crashing stacked raids when players pipe tens of thousands of stolen goods into their markets via Supply Lines.
- **Cosmic Codex Integration:** The mod now fully supports the Cosmic Codex! Comprehensive lore and mechanical documentation (such as features, UI tools, and dynamic events) are now readable directly in-game from the new Cosmic Codex tab.
- **Dynamic Subspace Weather**: Sector environments are no longer static. Introduced `co_weather_generator.lua` to dynamically generate weather hazards across the galaxy.
- **Ion Storms**: Completely disables radar systems and hyperspace capability.
- **Solar Flares**: Intensely radiated sectors that strip shields and gradually disintegrate unshielded hulls over time.
- **Global Weather Ticker**: A 15% chance per tick to spawn weather in random populated sectors (Maximum 5 active globally). Weather persists across server reboots.

### ✨ Added
- **QoL - Fleet Repair:** You can now instantly repair all damaged ships in a sector! Repair Docks have been upgraded with a new "Repair Fleet" button. It securely handles the math across your private and Alliance fleets, automatically withdrawing from the Alliance vault if you have privileges, or seamlessly falling back to your personal wallet to repair your private ships.
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
- **Fixed:** Fixed multiple API Avorion Indexes across various scripts that could cause C++ attempt to index or attempt to call engine crashes.
  - Corrected stat modifier functions (e.g. modifyBaseMultiplier -> addBaseMultiplier).
  - Corrected entity bias functions (e.g. addMultiplyableFactor -> addMultiplyableBias).
  - Replaced invalid faction relation setters with the correct global Galaxy() alternatives.
  - Removed native calls to non-existent functions (e.g. updateStaticAttributes, tryUnloadSector).
  - Corrected distance checks and serialization methods to match vanilla C++ bindings.
- **Optimized**: Throttled `respawnresourceasteroids.lua` update loop to 10 seconds via `getUpdateInterval()` to save CPU cycles.
- **Optimized**: Throttled `fleetstatus.lua` listbox UI repopulation to run every 0.5s instead of every frame.
- **Fixed**: Eliminated `math.random` usage in `respawnresourceasteroids.lua` and `asteroidfieldgenerator.lua` for full multiplayer determinism.
- **Fixed**: Removed broken `SupplyLine` and Goods order command hooks from `mapcommands.lua` that would sometimes cause the Galaxy Map empty UI crash.
- **Fixed**: Resolved a severe issue where a missing `LuaHacks` dependency in background trade commands would abort the initialization of the Galaxy Map UI, resulting in a blank map and repeated console spam.
- **Fixed:** `playerstationtrader.lua` was missing a `return` statement after `deleteEntityJumped`, leading to continued script execution on a deleted entity.
- **Fixed:** `playerstationutils.lua` generated out-of-bounds random indices in `tableRandom` due to improper bounds scaling.
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
- **Fixed (VM Isolation):** Completely refactored the Dynamic Reputation Decay system. The reputation hard-cap hooks were previously running in an isolated player VM, rendering them as dead code. The hooks and custom Enums have now been properly extracted into a global `relations.lua` override, ensuring all relation changes across the entire galaxy natively respect the Cosmic Overhaul limits. Stray markdown syntax errors in the decay loop were also eradicated.
- Removed `pcall` soft-dependencies. Core 5 mods are now hard requirements.
