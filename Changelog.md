# Changelog

All notable changes to **Cosmic Overhaul** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Never remove, overwrite or write above this

## [v5.1.4]
### Fixed
- [Bugfix] **Sealed Hulk State Exploit:** Fixed an exploit in `sealedhulkboarding.lua` where the script failed to utilize the engine's `secure()` and `restore()` pipeline to save the event state to disk. Players could previously abuse this by pushing deeper into the hulk, logging out, and reloading the sector to reset the event back to the first stage and farm resources indefinitely. The event state is now strictly serialized to the save file.
- [Bugfix] **Sealed Hulk Boarding Crash:** Fixed a silent engine crash inside `sealedhulkboarding.lua` where choosing the aggressive options ("Blow the blast doors" or "Push through the crossfire") would attempt to execute a `ship:removeCrew` call without the strictly required `Crewman` argument. The boarding logic will now correctly iterate over the ship's crew manifest to simulate realistic casualties without throwing silent C++ exceptions!
- [Localization] Fixed missing server-to-client UI localization tags (`%_T`) on the Sealed Hulk extraction messages.

### Removed
- [Feature] **Smart Jump Autopilot:** Completely scrapped the Smart Jump hotkey feature. Attempting to natively hijack the Avorion engine's hyperspace calculation routines and force ship alignments without a captain resulted in engine limitations that proved too drastic for the scope of the Cosmic series.

### Balanced
- [Balanced] **Merchant Captain Synergy:** The flat 15% discount/bonus payout applied globally when trading with a Merchant Captain has been rebalanced to dynamically scale based on both the captain's level and tier. The new formula adds +2% per level and +2% per tier, creating perfect synergy with the vanilla Captain progression system. A fresh Common Level 1 Merchant now provides a minimal +2% edge, while a Max Level 5 Legendary Merchant pushes the economy to a massive +16% bonus payout and discount!

## [v5.1.3]
### Fixed
- [Bugfix] **Respawn Resource Asteroids Crash:** Fixed an issue in `respawnresourceasteroids.lua` where the background simulation would attempt to read `sector.factionIndex` instead of correctly resolving the sector's controlling faction via `Galaxy():getControllingFaction(x, y)`. This previously caused the Famine Synergy check to silently crash the sector's asteroid regeneration loop.

## [v5.1.2]
### Fixed
- Fixed a massive oversight in Captain Elite Traits (specifically Commodore and Scavenger) where continuously terminating and re-applying status effects caused the underlying engine to recalculate max shield capacity, completely freezing natural shield regeneration for the entire duration of the trait effect. Buffs now successfully use a seamless refresh loop.

## [v5.1.1]

### 🐛 Bug Fixes
- [Bugfix] **AI Trader Jump Crash (`interactplayerstation.lua`):** Fixed an issue where AI station traders were unable to leave the sector and endlessly spammed `attempt to call global 'random' (a nil value)` to the server console. The script was missing an `include("randomext")` declaration to expose the engine's global `random()` helper.
- [Bugfix] **Elite Captain Traits Oscillation & Stacking (`captainelitetraits.lua`):** Addressed multiple severe issues with Commodore and Scavenger Elite Traits:
  - **Buff Overlaps:** Applied an idempotent refresh using strict `buffId` termination. The script previously used blindly overlapping `addScript` invocations, causing duplicate modifiers to stack continuously.
  - **Math Correction:** Modified `addBaseMultiplier` calls to correctly pass `0.10` instead of `1.10`. The engine evaluates base multipliers as additive percentages, meaning `1.10` was mistakenly applying a +110% buff instead of +10%.
  - **Damage Stat Mapping:** Changed the Commodore's "Damage" buff to map to `"FireRate"`. It was previously mapped to `"Damage"` which modified `StatsBonuses.ArmedTurrets`, artificially inflating turret slot counts and causing severe UI stat oscillation without providing a real damage boost.

## [v5.1.0]

### ✨ Quality of Life (QoL) Updates
- [QoL] **Consolidate Inventory to Vault:** Added a new button in the Trash Man UI allowing you to instantly transfer all unequipped and non-favorite turrets and subsystems from your private inventory directly into the Alliance Vault.
- [QoL] **Smart Jump Orientation Hotkey:** Added a new hotkey (configurable via Cosmic Configuration Menu) that instantly aligns your ship to your plotted hyperspace jump destination, saving you the hassle of manually turning your ship.
- [QoL] **Crew Mutiny Fallback Wallet:** Implemented an automated background protection script. If your personal funds run critically low before payday, the system will automatically transfer the missing credits from the Alliance Vault and notify you via chat, preventing a silent crew strike.

### 🐛 Bug Fixes
- [Bugfix] **Mining Operation Background Crash:** Patched a server crash occurring during background mining operations (`minecommand.lua:attempt to call field MineableBy`). This crash was caused by conflicting mods destroying the vanilla `galaxy.lua` export table. Cosmic Overhaul now injects a universal safeguard that forces the function back into memory, protecting your mining fleets from crashing out.
- [Bugfix] **Dynamic Reputation Rapid Decay:** Fixed a critical bug where the reputation decay script was missing a namespace declaration and using global wrappers. This caused the Avorion engine to silently fail its 45-minute throttle and fallback to a 15-second loop, applying 45 minutes worth of decay every 15 seconds! Relations will now correctly decay precisely once every 45 minutes as intended.
- [Bugfix] **Allied Relations Enhancer Crash & Silent Failure:** Patched a fatal engine crash occurring during diplomacy and reputation events. The script was incorrectly attempting to index raw integer IDs directly instead of normalizing them into Faction objects first, which would crash the server. Additionally, fixed a silent failure where the script looked for a non-existent `.alliance` property, completely preventing it from mirroring your reputation changes to your Alliance. It now properly executes the vanilla normalization pipeline and perfectly mirrors your diplomatic actions!

## [v5.0.12]

### ⚖️ Balanced
- [Balanced] **Dynamic Reputation Pacing:** The dynamic reputation decay interval has been further increased from 15 minutes to 45 minutes. Because the background script mathematically scales the penalty to match the interval, your overall hourly reputation loss remains exactly the same! This drastically reduces UI notification spam by processing 45 minutes worth of decay all at once (e.g. "-5828 Reputation with Cookie Empire").

## [v5.0.11]

### ⚖️ Balanced
- [Balanced] **Dynamic Reputation Pacing:** The dynamic reputation decay interval has been increased from 60 seconds to 15 minutes. Because the background script mathematically scales the penalty to match the interval, your overall hourly reputation loss remains exactly the same! However, instead of spamming your screen with a tiny "-1 Relation" notification every 60 seconds, it will now cleanly process 15 minutes worth of decay all at once (e.g. "-15 Relations"). This drastically reduces UI notification spam while maintaining the exact same math and balance.

## [v5.0.10]

### ⚖️ Balanced
- [Balanced] **Subspace Weather Rarity:** Significantly reduced the spawn rate of natural Subspace Weather events (Ion Storms, Solar Flares) to 1% (down from 15%) and massively increased the global cooldown between storms to 4-8 hours (up from 30-60 minutes). Weather events are now a very rare, high-impact phenomenon rather than a constant nuisance.
- [Balanced] **War Profiteering:** Increased the maximum passive income multiplier for Player Stations located in a max-heat Cosmic War zone from 250% to 300%. Setting up supply chains in warzones is now incredibly lucrative.
- [Balanced] **Eclipse Contraband Premium (Cosmic Chronicles Synergy):** Reduced the Smuggler's Market payout multiplier for fencing Ascendant Matter and Eclipse Datacores from 200% (2.0x) to 150% (1.5x) to curb late-game inflation while still offering a solid premium.
- [Balanced] **Ascendancy Trade Fear (Cosmic Ascendancy Synergy):** Increased the flight time penalty for non-smuggler merchants trading near factions at war with the Ascendancy (The Eclipse) from 35% delay (1.35x) to 50% delay (1.5x).
- [Balanced] **Famine Relief Charity:** Increased the reputation multiplier for Charity Missions sent to starving factions from +75% to +100%.
- [Balanced] **War Profiteering Distance Scaling:** Player Station passive income now scales dynamically based on distance to the galactic core. Stations near the edge of the galaxy receive a standard 1.0x multiplier, while stations deep in the core receive up to a 3.0x multiplier to their base payout, heavily incentivizing core expansions.

### ⚙️ Adjustments
- [Adjustment] **Subspace Weather Generator Engine Compliance:** Hardened the structural foundation of the weather generator. It now features full state persistence (storm cooldowns will properly save/restore across server restarts instead of resetting to 0) and strict adherence to the Avorion SectorView API for coordinate parsing.
- [Adjustment] **Cosmic Overhaul Codex:** Updated Codex with new information while adding in left out information from the official Cosmic Overhaul Wiki.

### 🐛 Bug Fixes
- [Bugfix] **Dynamic Reputation Decay Alliance Double-Penalty:** Fixed a severe logic flaw where passive reputation decay was being calculated independently for both the Player and their Alliance, but applied using an API function (`cvf.changeRelations`) that automatically mirrored the Player's decay to the Alliance. This caused the Alliance to suffer the decay penalty twice. The script now safely bypasses mirroring and applies decay directly via the vanilla `galaxy:setFactionRelations()` API.
- [Bugfix] **Dynamic Reputation Decay Type Safety:** Added strict `tonumber()` type coercion when fetching interaction timestamps to prevent potential silent Lua exceptions if the engine cache returned a timestamp as a string.
- [Bugfix] **Dynamic Reputation Decay Entity Script Structure:** Cleaned up the script structure by removing a leaked `return` statement at the bottom of the script that attempted to export undefined globals (a copy-paste error from vanilla's `relations.lua`).
- [Bugfix] **Famine Event Persistence:** Fixed a critical API bug where the background Famine Listener queue lacked state persistence. Famine debuff evaluations will no longer permanently skip ships if a sector unloads or the server restarts while ships are still waiting in the queue.


## [v5.0.9]

### ⚙️ Changed & Balanced
- [Changed] **Keybind Adjustments:** Unbound the default keys for the Cosmic Overhaul UI tabs (Bulletin Board, Resource Display). They now default to unbound to allow players to set their own custom shortcuts without overlapping with other mods.

## [v5.0.8]

### 🐛 Bug Fixes

- [Bugfix] **Dynamic Reputation Decay AI Halt:** Fixed a critical bug in `DynamicReputationDecay.lua` where evaluating non-existent relations caused an `attempt to compare number with nil` exception. This background error would flood the server update loop, severely disrupting faction AI logic and causing ships to ignore combat.
- [Missions] **Delivery Missions:** Delivery missions will no longer select a destination sector owned by a faction that the questgiver is currently at war with. - Patch

## [v5.0.7] - Hotfix

### 🐛 Bug Fixes

- [Bugfix] **Dynamic Reputation Decay Error:** Fixed a severe server log spam issue originating from `DynamicReputationDecay.lua`. The script was incorrectly passing integer indices directly into the `getFactionRelations` native API, causing recurring `invalid type 'number'` errors. Indices are now properly wrapped in `Faction()` objects.
- [Bugfix] **Weather Generator Loading:** Fixed a silent script attachment failure in `server.lua`. `co_weather_generator.lua` was missing the mandatory `data/scripts/` root path prefix, preventing the engine from properly loading the global weather script on server start.

## [v5.0.6]

### 🐛 Bug Fixes

- [Bugfixed] **Offline Simulation (ARCC):** Resolved an issue where checking the `Enable Offline Catch-up` option in the CCM window and relaunching the game would result in the option visually or functionally reverting to disabled. The background simulation script now evaluates the configuration dynamically at runtime when parsing the first update tick, rather than caching the default values prematurely during initial script load before the Cosmic Configuration Menu completes parsing `ccm.lua`.
- [Bugfixed] **Traders (AI Bloat & Desync):** Fixed a severe optimization bug originating from the `ft_gateTradeMult` trader influx logic within `factory.lua`. If a player sat in an accelerated sector (e.g., heavily populated with Gates/Wormholes) for an extremely extended period (8+ hours), the factory spawned traders faster than the vanilla Avorion docking AI could process them. Overwhelmed docking queues caused AI tradeship scripts to timeout or detach, leaving hundreds of permanent, unscripted ghost ships drifting thousands of kilometers away and tricking the factory into continuously spawning more. A strict sector-wide safety cap on active AI traders has been introduced to prevent runaway inflation while preserving trade volume.

## [v5.0.5]

### 🐛 Bug Fixes & ⚖️ Balance Tweaks

- [Bugfixed] **Offline Simulation (ARCC):** Fixed a critical logic error in `simulation.lua` where the script fetched `Server().unpausedRuntime` instead of the system's real-world clock (`os.time()`). Because `unpausedRuntime` freezes while the server is offline or the game is closed, returning players were incorrectly awarded exactly 0 seconds of background catch-up time regardless of how long they were away. This has been fully corrected.
- [Balanced] **Scavenger Yield Buff (Cosmic War):** Increased the Salvage Yield multiplier from `1.20` (+20%) to `1.50` (+50%) when a Scavenger captain is operating inside an active Contested Siege Zone. Risking a captain inside a War Zone is now much more lucrative.
- [Balanced] **Ascendancy Trade Fear (Cosmic Ascendancy):** Increased the flight time penalty for non-smuggler merchants trading near factions actively at war with The Eclipse from `20%` delay to `35%` delay.
- [Balanced] **Charity Reputation Bonus (Cosmic Vault):** Buffed the diplomatic multiplier for Charity Missions sent to starving factions from `+50%` to `+75%`. Sending aid during an economic crisis is now incredibly rewarding.
- [Balanced] **Eclipse Contraband Premium (Cosmic Chronicles):** Buffed the Smuggler's Market fence multiplier for `Ascendant Matter` and `Eclipse Datacore` from `+50%` to `+100%` payout.

## [v5.0.4]

### 🐛 Bug Fixes & ⚖️ Balance Tweaks

- [Bugfixed] **Transfer Crew & Goods:** Addressed a lingering edge case in the `v5.0.3` Hangar fix. The server was attempting to resolve the `Hangar` component directly from network-transmitted UUIDs, which could silently fail during transfers between complex entity states (e.g., Alliance ships) and falsely report a "Missing hangar." The engine now securely resolves the component strictly via the verified Entity object instance.
- [Balanced] **Famine Economic Multipliers:** Softened the blunt +250% trade bonus applied to all starving factions. It now appropriately scales up based on severity (Struggling: +125%, Resource Starved: +175%, Severe Famine: +250%). Smuggler blockade bypasses natively halve these bonuses.
- [Balanced] **Famine Entity Debuffs:** Toned down the extreme stat penalties applied to factions experiencing Severe Famines (Shields: -50%, Velocity: -30%) and Resource Starved (Shields: -30%, Velocity: -20%) to keep AI fleets somewhat competitive when reacting to Cosmic War siege events.
- [Balanced] **Rift Tech Fencing:** Lowered the profit ceiling for fencing stolen Rift Technology at the Smuggler's Market to a random scale of `1.5x - 2.5x` to prevent hyper-inflation of the late-game economy when combined with Smuggler trait bonuses.

## [v5.0.3]

## 🐛 Bug Fix Patch Update

- [Bugfixed] **Transfer Crew & Goods:** Fixed a critical bug in `transfercrewgoods.lua` where the `Entity().hangar` property was incorrectly referenced instead of the proper `Hangar(entity)` component API. This resolved an issue that completely blocked all fighter transfers between ships and stations by falsely claiming a hangar was missing.

## [v5.0.1 & v5.0.2]

### 🐛 Bug Fixes & 🛠️ Optimization

- [Bugfixed] **Instance Crash:** Fixed a critical bug causing single-player instances and dedicated servers to crash via `EXCEPTION_ACCESS_VIOLATION`. The `CosmicVaultTask.RunAsync` API was improperly used inside `DynamicReputationDecay.lua` without a pumping mechanism. Because the coroutines were never pumped via `Update()`, they were left dangling as memory leaks holding C++ userdata (such as the Galaxy object). When the Engine's Garbage Collector eventually collected the player VM, the dangling threads triggered a fatal memory boundary violation. The script has been rewritten to execute synchronously.

## [v5.0.0]

### ✨ New Features & 📦 Content Additions

- [Content] **Ascendant Neural Implants:** You can now equip the legendary Ascendant Neural Implant subsystem, which physically transforms your ship into a biomechanical dreadnought (scaling massive stats like jump reach, fighters, and turrets while injecting extreme velocity).
- [Feature] **CCM Keybind API:** The Bulletin Board and Resource Display panels have been fully hooked into the CCM Keybind API. Players can now assign custom hotkeys to instantly toggle these UI panels without clicking through station menus!
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
- [Bugfixed] **VM Isolation Reputation Bug:** Completely refactored the Dynamic Reputation Decay system. The reputation hard-cap hooks were previously running in an isolated player VM (dead code) and have now been properly extracted into a global `relations.lua` override.
- [Bugfixed] **Map UI & Trading Manager Spam:** Eliminated the `Activity level is zero or negative` console spam which flooded server logs. Removed broken `SupplyLine` and Goods order command hooks from `mapcommands.lua` that caused empty Galaxy Map UI crashes, and resolved a severe issue where missing `LuaHacks` dependencies aborted map initialization.
- [Bugfixed] **Memory Leaks & UI Crashes:** Sealed memory leaks by injecting `onRemove()` functions into UI scripts like Bulletin Board and Resource Display. Reinstated `self.currencyLabel` in `shop.lua` to prevent merchant crashes.
- [Bugfixed] **Script Execution Faults:** Fixed `playerstationtrader.lua` missing a `return` statement after `deleteEntityJumped` and `playerstationutils.lua` generating out-of-bounds indices in `tableRandom` due to improper bounds scaling.
- [Bugfixed] **Multiplayer Networking & Stability:** Added missing `callable()` declarations to Factory upgrade buttons so they work properly on Dedicated Servers. Added `onClient()` wrappers to Stash and Galaxy Map scripts to prevent the singleplayer server thread from crashing itself with errant network calls.
- [Bugfixed] **Scout Mission Fix:** Fixed a massive vanilla/mod bug where Scout Missions would completely skip and ignore Faction Headquarters sectors because the `scoutcommandnotetable` lacked dialogue lines for that specific sector template.

- [Bugfixed] **VFS Compliance:** Stripped redundant global wrapper functions from namespaced scripts to prevent silent double-execution logic loops and engine crashes.
