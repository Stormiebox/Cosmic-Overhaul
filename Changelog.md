# Changelog

All notable changes to **Cosmic Overhaul** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Never remove, overwrite or write above this

## [v5.0.0] UNRELEASED WORKSHOP VERSION (PROJECT UNDER DEVELOPMENT)

### ✨ New Features & 📦 Content Additions

- [Feature] **Deep Economy Warfare:** Cosmic Overhaul's localized Famine Events now natively tie into the `CosmicVaultEconomy` API, which can physically force starving factions to declare war on wealthy neighbors to survive!
- [Feature] **Weather-Affected Map Commands:** Offline Travel and Scout commands now ping `cv_weather`. Navigating hazardous weather (Ion Storms, Nebulas) delays offline map operations by 50% unless piloted by an Explorer or Navigator.
- [Feature] **Siege Blockade Halts:** Factories dynamically poll `cv_scaling`. If the sector is a War Zone and the defenders are outgunned 2:1, all factory production halts entirely until the siege is lifted.
- [Feature] **War Zone Blockades:** Stations located in active Cosmic War zones will instantly suspend all background AI Trader traffic and explicitly reject any Player docking requests to buy or sell goods, locking down the local economy natively through `factory.lua` injection.
- [Feature] **Ascendancy Trade Fear:** Merchant trade flights take 20% longer to resolve if the target faction is at war with the Ascendancy (The Eclipse). Smugglers natively bypass this hazard penalty.
- [Feature] **Captain Elite Traits:** Level 3 Captains now possess massive sector-wide or unique bonuses: Commodores provide +10% Shield/Damage to player/alliance ships; Miners gain +25 area command bonus; Smugglers grant absolute immunity to all cargo/contraband inspections.
- [Feature] **Station Governors:** Players can now assign idle captains to their stations as "Governors" for massive bonuses. Merchant Governors boost passive income by 25% and AI traffic by 50%. Engineer Governors boost factory shuttle capacity by 50%. Smuggler Governors bypass Cosmic War siege blockades, while Merchant Governors offer Privateer Subsidies (50% crew cost reduction).
- [Feature] **Cosmic Codex Integration:** The mod now fully supports the Cosmic Codex! Comprehensive lore and mechanical documentation (features, UI tools, dynamic events) are now readable directly in-game.
- [Feature] **Deep Wiki Integration:** Injected 43+ detailed mechanical and lore articles straight from the official Wiki into the Cosmic Codex. Features like Empire Management, Captain Synergies, and the Black Market rework are fully documented in-game.
- [Feature] **Dynamic Subspace Weather:** Sector environments are no longer static. Introduced `co_weather_generator.lua` to dynamically generate weather hazards across the galaxy (15% chance per tick in populated sectors, max 5 globally). Includes Ion Storms (disables radar/hyperspace) and Solar Flares (strips shields/disintegrates hulls).
- [Feature] **QoL - Fleet Repair:** Instantly repair all damaged ships in a sector! Repair Docks feature a "Repair Fleet" button that securely handles math across private and Alliance fleets, automatically withdrawing from the correct vault.
- [Feature] **Persistence Resource Regeneration:** Asteroid fields now naturally regenerate over real-time (background processed). Tied to the Vault economy API: factions in 'Severe Famine' halt regeneration, while 'Resource Starved' factions regenerate at half-speed.
- [Feature] **Famine Debuff System:** Implemented `co_famine_debuff.lua` hooked into the Vault Economy API. A Severe Famine debuff heavily penalizes factions, reducing their shields by 60% and velocity by 40%.
- [Feature] **Tag-Based AI Generation & Dynamic Behaviors:** Replaced rigid Vanilla Faction tracking with a robust new tag-based AI (`[Aggressive]`, `[Passive]`, `[Trader]`). Factions now organically calculate AI routines (Patrol vs Trade) using this Vault Faction Tag system rather than static hardcoded tables.
- [Feature] **Cosmic Vault API Framework:** Fully integrated with the Cosmic Vault API framework. Swept codebase for legacy callbacks and implemented safe pcall fallbacks.
- [Content] **Scout Anomalies:** Explorer Captains charting empty sectors will now leave notes hinting at `Cosmic Chronicles` narrative events.
- [Content] **The Syndicate Hub Expansion:** The Smuggler's Market is now a massive criminal enterprise! Features an automatic "Fence" system to unbrand stolen goods, yielding an Eclipse Contraband Premium (1.5x payout). Assigning a Smuggler Governor grants a 35% bonus profit and 50% discount on unbranding. Passive unbranding generates Syndicate Heat; reaching limits triggers local lockdowns and raids, safely capped by a 1-Hour real-time cooldown to prevent stacked raids.
- [Content] **Emergency Replenishment Anomalies:** When a completely barren sector triggers an emergency resource replenishment, there is a 5% chance to unearth a Precursor Wreck or Spatial Rift. In populated sectors, this triggers an instant galaxy-wide breaking news alert.
- [Content] **Sealed Hulks (Boarding Operations):** Deep space hidden mass sectors now have a chance to generate a massive "Sealed Hulk." Docking initiates an interactive "Choose Your Own Adventure" text event risking crew against defenses and radiation for Legendary subsystem drops!
- [Content] **Fencing Rift Tech:** The Smuggler's Market now eagerly accepts classified `Rift Research Data` and `Subclass Subsystems` for a 200%-300% markup. However, fencing this sensitive technology causes temporary reputation loss with the local faction.

### ⚙️ Changed & ⚖️ Balanced

- [Changed] **Unified News API:** Overhaul's myriad of ambient events and galactic occurrences are now securely routed through the new `CosmicVaultNews.publishArticle` architecture, guaranteeing cross-mod UI stability.
- [Changed] **Core Dependencies:** Removed `pcall` soft-dependencies. Core 5 mods are now hard requirements.
- [Balanced] **Dynamic Trade Pricing:** Hooked offline Merchant Trade commands into `cv_economy`. Trading with a Famine-struck faction now yields up to 2.5x more passive profit.
- [Balanced] **War Profiteering:** `managestationincomes.lua` reversed from a penalty to a massive bonus. Supplying 100% Heat War Zones now yields a 250% income bonus instead of a 20% penalty.
- [Balanced] **Reputation Decay Scaling:** Halved the base Dynamic Reputation Decay rate from 100/hr to 50/hr to synergize with the massive endgame campaigns in `Cosmic Ascendancy`.
- [Balanced] **Alliance Mirroring Parity:** Scaled diplomatic rep gain mirroring for Alliances from 2x down to 1x to prevent massive "cascade wars". This mirroring penalty is multiplied by 1.5x if a player commits a hostile act against a faction possessing the `Fortified` trait.
- [Balanced] **Loot Variance Boost:** Pushed the unseeded wild-generation chance for Exotic and Legendary drops from 50% to 75% for enhanced endgame loot variety.
- [Balanced] **Famine Relief Charity:** Background Charity Missions sent to factions suffering from Famine natively grant a +50% Reputation multiplier.
- [Balanced] **Siege Salvage Yield:** Scavenger captains actively flying inside a Contested Siege Zone natively receive a +20% Salvage Yield buff while cleaning up dreadnought wreckages.
- [Balanced] **Smuggler Deflation:** A Smuggler captain idling in a sector will passively heal the controlling faction's Famine Score by `-0.1` every 5 seconds.
- [Balanced] **Galactic Turn Synchronization:** `respawnInterval` changed from 10m to 20m. `profitableStationsInterval` synced to 1200s (20m) to align with the global server turn, massively reducing asynchronous background processing and eliminating server micro-stutter.
- [Balanced] **Economic Stabilization:** To compensate for the Profitable Stations interval doubling from 10m to 20m, the base payouts have been strictly doubled (Credit base: 8k -> 16k, Resource base: 3.5k -> 7k). The economy remains perfectly balanced without punishing players for the new performance optimizations.

### 🐛 Bug Fixes & 🛠️ Optimization

- [Optimized] **Performance & TPS Optimization:** Drastically reduced server load during late-game scenarios. Injected a hardcoded `getUpdateInterval` throttle into 5 major AI and UI scripts (`refineores`, `factory`, `transfercrewgoods`, `shipinfo`, `sectorshipoverview`) and `respawnresourceasteroids.lua`. Additionally throttled `fleetstatus.lua` listbox repopulation (0.5s). Prevents highly-industrialized sectors from dragging down TPS by running 60 times a second.
- [Bugfixed] **Engine Crash Fixes:** Fixed multiple API Avorion Indexes across various scripts that could cause C++ attempt to index or call engine crashes (e.g. corrected stat modifiers, entity bias functions, invalid faction setters, removed native calls to non-existent functions, and corrected C++ matching distance checks).
- [Bugfixed] **Multiplayer Desyncs:** Replaced `math.random` with the deterministic engine `random():getInt()` across all custom scripts (including `respawnresourceasteroids.lua` and `asteroidfieldgenerator.lua`) to prevent massive physics and stats desyncs in multiplayer.
- [Bugfixed] **RNG Calculation Math Bug:** Swept the codebase and replaced critical logic faults in Station Governors and AI Traders where probability checks were evaluating against `getInt()` instead of `getFloat()`, restoring exact percentage math for random economic events.
- [Bugfixed] **VM Isolation Reputation Bug:** Completely refactored the Dynamic Reputation Decay system. The reputation hard-cap hooks were previously running in an isolated player VM (dead code) and have now been properly extracted into a global `relations.lua` override. Stray markdown syntax errors in the decay loop were also eradicated.
- [Bugfixed] **Map UI & Trading Manager Spam:** Eliminated the `Activity level is zero or negative` console spam which flooded server logs. Removed broken `SupplyLine` and Goods order command hooks from `mapcommands.lua` that caused empty Galaxy Map UI crashes, and resolved a severe issue where missing `LuaHacks` dependencies aborted map initialization.
- [Bugfixed] **Memory Leaks & UI Crashes:** Sealed memory leaks by injecting `onRemove()` functions into UI scripts like Bulletin Board and Resource Display. Reinstated `self.currencyLabel` in `shop.lua` to prevent merchant crashes.
- [Bugfixed] **Script Execution Faults:** Fixed `playerstationtrader.lua` missing a `return` statement after `deleteEntityJumped` and `playerstationutils.lua` generating out-of-bounds indices in `tableRandom` due to improper bounds scaling.
- [Bugfixed] **Multiplayer Networking & Stability:** Added missing `callable()` declarations to Factory upgrade buttons so they work properly on Dedicated Servers. Added `onClient()` wrappers to Stash and Galaxy Map scripts to prevent the singleplayer server thread from crashing itself with errant network calls.
- [Bugfixed] **Scout Mission Fix:** Fixed a massive vanilla/mod bug where Scout Missions would completely skip and ignore Faction Headquarters sectors because the `scoutcommandnotetable` lacked dialogue lines for that specific sector template.
