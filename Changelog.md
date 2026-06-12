# Changelog

All notable changes to **Cosmic Overhaul** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

--

## v4.3.0 (CURRENT PROJECT VERSION - NO RELEASE DATE YET!)

- Fully integrated with the Cosmic Vault API framework.
- Swept codebase for legacy callbacks and implemented safe pcall fallbacks.

### LEGACY LOGS BELOW - KEPT FOR HISTORICAL PURPOSES!

# 4.2.3

- **Hotfix:** Fixed a bug with an incorrect script check path causing the sector to fail to detect existing traders, continuously spawning hundreds of AI ships in permanently-simulated sectors until the game hung.
- **Hotfix:** Fixed a fatal client-side crash in the Map QoL UI where a missing reference to the removed `colorPicker` caused the update loop to crash, preventing players from selecting alternate colors for map icons.
- **Hotfix:** Fixed an issue where the Map QoL UI color arrays would revert to pure black upon loading. The UI will now properly fallback to vibrant default colors.
- **Polish:** Added a toggle button allowing players to make all Galaxy Map QoL windows draggable across the screen.
- **Polish:** Added proper UI headers and draggable icon indicators to the Galaxy Map QoL windows.
- **Polish:** Improved the visual clarity of selecting map icons by utilizing the 4-corner targeting reticle instead of a solid white box.

# 4.2.2

- **Hotfix:** Fixed a critical server crash caused by `playerstationutils.lua` missing a `self` reference during asynchronous trader spawning. This issue was heavily exacerbated by "Sector Keep-Alive" mods forcing background traders to spawn endlessly in empty sectors.
- **Hotfix:** Deprecated and terminated the legacy `shipinfo.lua` script to fix massive 24/7 dedicated server console log spam (`player is nil`). Background sectors kept permanently loaded by "Sector Keep-Alive" mods were constantly trying to push illegal UI updates to offline players.

# 4.2.1

- **Hotfix:** Fixed a critical issue where the server would hang and players would lose connection when a ship finished a Background Scouting Mission from the Galaxy Map.
- **Hotfix:** Removed duplicate base-game translation strings from the mod's localization files to prevent tinygettext collision warnings from spamming the client log.

## [4.2.0] - 2026-06-07

### Fixed

- **Galaxy Map QoL Initialization:** Fixed a fatal client-side crash caused by deprecated os.execute folder creation. The mod now correctly uses Avorion's native createDirectory() API for configuration folders.
- **Engine Bootstrap Compliance:** Purged invalid `initialize()` wrappers from `player/init.lua`, `sector/init.lua`, and `entity/init.lua`. Avorion expects these to be global execution scripts. This resolves a fatal bug where UI tabs, sector scripts, and background entity modifiers completely failed to load on fresh saves.
- **Galaxy Map QoL Type Safety:** Prevented stack traces and script failures by explicitly casting config file string loads to boolean values before UI injection.
- **Improved Stashes Override Fix:** Repaired a catastrophic bug where the custom stash.lua file was completely deleting the vanilla game's stash script from memory, resulting in broken stashes that could not be opened. The stash modifications have been safely injected into a cloned vanilla file to ensure UI and interactions work flawlessly while still delivering boosted loot.
- **Compliance Fix:** Wrapped core injection files (init.lua) safely to prevent them from wiping out vanilla initialization scripts.

### Added

- **Galactic News Network Synergy (Requires Cosmic Chronicles):** The underlying economy engine (Faction Wealth tracking) now directly feeds data into the Galactic News Network. Merchant captains can use the News Board to actively hunt for "Trade Crises" and "Market Booms"!
- **Integrated Galaxy Map QoL:** Completely integrated the `Galaxy Map QoL` mod directly into Cosmic Overhaul. It has received the "Cosmic Overhaul Treatment" which includes completely stripping out the dependency on `AzimuthLib` (players no longer need to download it) and converting it to natively use standard Avorion code and UI systems. You can now freely place customizable icons and notes directly on the galaxy map!
- **Full Localization Support:** Processed and injected over 2,400 translated strings across 7 different languages (Chinese, French, Japanese, Portuguese, Spanish, German, and Russian). The mod is now fully translated and completely localized for non-English users.
- **Syndicate Boss Mechanic (Player-Owned Smuggler Markets):** Added massive economic incentives for players to construct their own Smuggler's Market stations:
  - **Syndicate Payouts:** Selling stolen or illegal goods to your *own* station now grants an additional **+25% bonus multiplier** to the final payout.
  - **In-House Laundering:** Unbranding stolen goods at your *own* station now applies a massive **90% discount** on all laundering fees, effectively allowing you to sanitize stolen cargo for pennies.

### Changed

- **Shop Restock Buff:** Increased the maximum number of free restocks from 15 to 25 to provide players with a slightly larger buffer for finding specific modules. The 45-minute cooldown timer remains untouched.

### Fixed

- **Reversed Merchant Pricing (Critical Economy Fix):** Fixed a massive mathematical error where the 15% Merchant Captain trade bonus was actually punishing players! Because of how the vanilla API is structured (`getBuyPrice` means what the *station* pays, not what the *player* pays), having a Merchant Captain on board was accidentally making station purchases 15% *more* expensive, and selling to stations 15% *less* profitable. This is now fully inverted and correctly working in the player's favor!
- **Gate Travel Priority Fallback:** Restored a missing vanilla fallback when `Gate Travel Priority` is disabled. Previously, if a player disabled priority and tried to map a jump across a rift, the mod would throw a "Jump not possible" error instead of checking for a valid gate. It now correctly falls back to using gates to cross rifts when the hyperdrive cannot make the jump.
  - *Note on Engine Behavior:* If `Gate Travel Priority` is disabled, the mod correctly feeds standard `Jump` commands to the ship. However, if the ship *still* goes through a gate, this is because the core Avorion C++ Engine natively intercepts Jump orders if there is an adjacent gate connecting to the exact same destination. The core engine does this to save hyperdrive cooldown, and cannot be bypassed by mods.

- **ARCC Offline Server Hangs & Exploit:** Fixed a critical issue on private multiplayer servers where booting the server would attempt to instantly calculate and simulate hours of "offline" progression for all active captain commands simultaneously. This massive burst of calculations would block the server thread, triggering Avorion's "hang detector" and crashing the server on startup. This also inadvertently rewarded players with "free" resources for time the server was turned off.
  - **MCM Integration:** The ARCC offline simulation is now **disabled by default** to protect private/local servers. Server owners can opt back into offline simulation via the Mod Configuration Menu (MCM) under the new "Offline Simulation (ARCC)" section, where they can also cap the maximum offline simulation time and adjust the offline efficiency ratio.

### Removed

- **Textures Folder:** All textures were removed and migrated into `Cosmic Vault`.

## [4.1.0]

### Added

- **Resource Display Customization:** Added several highly requested quality-of-life toggles directly to the Resource Display player tab. Players can now completely enable/disable the HUD widget, adjust the background opacity for better text contrast against bright nebulas, and enable "Compact Number Formatting" to cleanly shrink massive late-game numbers (e.g., 1.5B credits, 12M Trinium).
- **Dynamic Ship Naming Engine:** Safely hooked into the native game engine to completely rewrite the procedural naming arrays for NPC ships. Military ships now use realistic naval tiers (Corvette to Leviathan), Freighters use logistics terms, Miners use industrial terms, and Traders use commerce terms.
- **Piracy Economy Buff:** Restored the massive Black Market piracy buff! Destroyed civilian ships now drop massive amounts of illegal cargo (scaling up to 250,000 credits based on sector richness), making piracy and smuggling highly lucrative again.

### Fixed

- **Vanilla Function Override Fix:** Safely removed the legacy hard-override of `shiputility.lua` and replaced it with a dynamic surgical injector. This permanently resolves any conflicts with other mods that touch ship generation functions, completely preventing unexpected VM crashes while still deploying the ship naming and piracy buffs.

## Localization

- Further progress in .po files translation. Still a work-in-progress to cover all new strings.

---

## [4.0.0]

### Added

- **Captain Synergy Expansion:** Fully overhauled the `Sell`, `Procure`, `Salvage`, `Refine`, and `Travel` map operations. Relevant Captain classes (like Merchants, Navigators, and Scavengers) now gain massive synergistic bonuses to their operational range, reduce their travel and completion times by up to 25%, and significantly lower their ambush chances!
- **Active Merchant Synergy:** When actively piloting a ship commanded by a Merchant Captain, players now receive a global 15% discount on purchases and a 15% bonus payout on sales at all commercial stations (Trading Posts, Factories, Resource Depots, etc.).
- **Active Smuggler Synergy:** When actively piloting a ship commanded by a Smuggler Captain, players now receive a 15% discount on unbranding fees and a 15% bonus payout on black market sales at the Smuggler's Market.
- **Scavenger Strategy Intel:** If you pilot a ship with a Scavenger captain, the "Wreckages" tab in Strategy Mode will now bypass generic names (like "Husk" or "Derelict") and reveal the exact original identity of the destroyed ships, helping you identify high-value targets in massive graveyards.
- **Resource Display UI:** Added a native, highly configurable Resource Display HUD widget. Tracks personal/alliance credits, resources, cargo space, and inventory slots. Completely rebuilt without legacy `AzimuthLib` dependencies, it automatically saves UI positions and preferences directly to the player's profile.
- **Dynamic Reputation Decay:** Added an inactivity-based reputation decay system. If you ignore factions for too long, relations will slowly drift back towards neutral (Allies forget, Hostiles forgive).
- **Alliance Reputation Synergy:** Player reputation changes now mirror to their Alliance at 2x intensity, forcing individual actions to have massive diplomatic weight for the group.
- **Gate Travel Priority:** When enchaining jump orders on the galaxy map, ships will now actively prioritize using known Gates and Wormholes instead of forcing hyperspace jumps.
- New texture icon for the "Factory Overview" tab in `data/textures/icons/FactoryOverviewTab.png`.
- New texture icon for the "Wreckages" tab in `data/textures/icons/WreckagesTab.png`.
- New texture icon for the "Resource Display" tab in `data/textures/icons/ResourceDisplayTab.png`.

### Fixed

- **Virtual File System Compliance:** Fixed a major architectural flaw where `pcall(require)` was bypassing Avorion's VFS to check for *Cosmic War* in background scripts. All cross-mod bridges now correctly use `pcall(include)`, preventing unpredictable VM crashes on dedicated servers.
- **Phantom API Crash:** Fixed a critical crash in `managestationincomes.lua` where stations attempting to yield resources called a non-existent vanilla function (`Faction:receiveResource`). Resources are now safely routed through the standard `Faction:receive()` C++ binding array.
- **Bulletin Board UI Crash:** Fixed a minor typo in `playerbulletinboard.lua` where a failsafe would call the invalid `printlog` function instead of `print`, crashing the client UI under rare edge cases.
- **Invisible Player Factories:** Added a self-healing loop to player-owned stations. Factories built before Cosmic Overhaul was installed will now automatically detect their missing registration and permanently add themselves to your Factory Overview UI the moment their sector is loaded.
- **Factory Overview Tab Crash:** Fixed a critical crash in `factory_overview_tab.lua` where the script would attempt to call `galaxy:invokeFunction` with an incorrect path, leading to a client-side UI crash. Applied the same fix to `galaxy/init.lua`.
- **Global Translation Pass:** Found and fixed several "Server-Side Translation Traps" hidden inside background simulation utilities (`simulationutility.lua`) and scout note generators (`scoutcommandnotetable.lua`) that forced operation mails to render exclusively in English for international players.
- **Profitable Stations Fix:** Resolved an `attempt to index a boolean value` server crash related to the Cosmic War bridge, and ensured its mail notifications are correctly localized.
- **Simulation & UI Stability:** Fixed an `attempt to index global 'self'` crash during the offline catch-up phase, and resolved a massive scope/double-wrap bug in `sectorshipoverview.lua` that would crash the Strategy UI.
- **Factory Overview Translation:** Corrected an issue in the Factory Overview UI where station titles were not properly translated for non-English players.
- **Ship Info Optimization:** Cleaned up unoptimized nested `else if` statements and added missing localization tags to the Fleet Info UI.
- **Shop Restock Translation Trap:** Fixed an issue where the new "Shop Restock" cooldown messages were broadcasting to clients in English instead of using the local `.po` file translations.
- **Loot Seed Hash Collision:** Fixed a coordinate overlap bug in `upgradegenerator.lua` and `sectorturretgenerator.lua` that accidentally caused hundreds of different sectors to share the exact same generation seed.
- **Command Center Localization:** Corrected a Server-to-Client translation trap where background operations (e.g., "Mining", "Active") were being translated into the Server Host's language instead of the local Client's UI language.
- **Map Command Boundary UI:** Fixed an "off by one cell" boundary calculation in the `Sell`, `Salvage`, `Mine`, `Procure`, and `Refine` map commands that caused a "ship is not inside the target area" error when players dragged the selection box to its absolute edge.
- **Trash Man Alliance/Drone Bug:** Fixed an issue where the "Trash Man" UI icon would disappear when piloting Drones or Alliance ships. The script is now safely attached to physical crafts in `entity/init.lua` using strict ownership checks, ensuring the UI engine always draws the interaction icon.
- **Fleet Status UI Attachment:** Fixed a severe misplaced logic bug in `entity/init.lua` where player UI scripts were mistakenly being attached to ships, restoring the correct Fleet Status initialization.
- **Scout Command Offline Progress:** Fixed a logic bug in `scoutcommand.lua` where the offline simulation catch-up tick was evaluated *after* the incremental sector reveal loop. Scout operations will now correctly and instantly reveal all progress made while the player was offline.
- **Universal Bulletin Board:** Fixed a logic bug in `playerbulletinboard.lua` where the script attempts to format strings using `%` operator without providing fallback empty table for `bulletin.formatArguments`. Which would most likely cause a UI tab crash if any mission that does not use string variables is displayed.
- **Map Command Alliance Crash (Ghost Ship):** Fixed a critical UI thread crash in all map background simulation commands (Mine, Trade, Salvage, etc.) when playing in an Alliance. The map UI occasionally passes a 'Faction 0' placeholder while updating, which our Captain Synergy system tried to index. All map commands now safely verify the ship owner context.
- **Simulation Offline Catch-Up Notification:** Fixed a bug in `simulation.lua` where the offline catch-up notification failed to send to players who were actively commanding Alliance fleets when they logged out.
- **Charity Mission Crash:** Fixed a silent simulation loop crash in `simulation.lua` when yielding relations from Charity Trade missions by adding the missing vanilla `relations.lua` API include.
- **Simulation Translation Trap:** Fixed a major Server-Side Translation Trap in `simulationutility.lua` where applying color tags was breaking the C++ `Format` objects, causing map command assessments to permanently render in English for international clients.
- **Exchange Cargo UI Crash:** Fixed a UI thread crash when opening the Cargo Transfer window with an entirely empty cargo hold by adding safety fallbacks for empty text assignments.
- **Missing Asteroid Mines:** Fixed an issue where claimed Asteroid Mines (e.g., Ice Mines) would fail to register in the Factory Overview UI. The self-healing registration loop now correctly catches claimed neutral stations during the server update cycle instead of initialization.
- **Trading Manager Userdata Bug:** Fixed a bug in `tradingmanager.lua` where station consumption notifications were printing raw `userdata` memory addresses instead of the actual item's name.

### Changed

- **Dynamic API Injection:** Refactored the massive `shiputility.lua` library override into a surgical, memory-safe dynamic injector. This strictly adheres to Avorion's Highlander Virtual File System rules, completely eliminating conflicts with other mods and bulletproofing the mod against future game updates.
- **Player Settings Storage**: Completely refactored the mod to use the new `CosmicVaultPlayerSettings` API for storing persistent UI settings across all map commands (Trade, Salvage, Mine, etc.).
- **War Economy Synergy**: Player-owned stations now have their passive income from the "Profitable Stations" feature dynamically reduced based on the local `War Heat` from the *Cosmic War* mod. High-conflict zones are now less profitable, requiring players to protect their economic hubs.
- **Merchant Inventory Rebalance:** Drastically reduced the sheer volume of items generated by Equipment Docks, Fighter Merchants, and Turret Merchants. Because players can now instantly refresh inventories with the "Shop Restock" button, massive lists of 100+ items were unnecessary UI bloat.
- **Improved Stashes:** Integrated and heavily overhauled the "Improved Stash" framework. Hidden stashes now scale non-linearly into the late-game, dropping significantly better credit and resource rewards with a chance to roll massive multipliers (up to 10x). Stash turrets also have a chance to drop with heavily boosted Tech Levels (+5 to +7), making deep-space exploration deeply rewarding at all stages of the campaign.
- **Loot Micro-Variance:** Injected a micro-variance into the 1x1 sector seed grid for Turrets and System Upgrades. Merchants and Pirates in the same sector will no longer drop exact, identical clones of the same item.
- **Cargo Transfer Overhaul:** Completely modernized the Cargo Transfer UI (`transfercrewgoods.lua`). Added live Search/Filter text boxes, alphabetical sorting, and color-coded cargo bars (Red for illegal/stolen, Yellow for dangerous). Built natively to handle massive late-game cargo holds flawlessly.
- **Advanced Cargo Transfers:** Transferring items will no longer fail completely if the receiving ship lacks space; it will now transfer as much as possible. Added a new "Stacking" feature: hold Right Mouse Button (RMB) when clicking "Transfer All" to only transfer items that the receiving ship already has in its hold.
- **Texture Update:** Updated `data/textures/icons/CommandCenter.png` into `data/textures/icons/CommandCenterTab.png` applied appropiate texture reference change to `command_center_tab.lua`.
- **Texture Update:**: Updated `data/textures/icons/FactoryOverview.png` into `data/textures/icons/FactoryOverviewTab.png` applied appropiate texture reference change to `factory_overview_tab.lua`.
- **Texture Update:** Updated `data/textures/icons/Wreckages.png` into `data/textures/icons/WreckagesTab.png` applied appropiate texture reference change to `sectorshipoverview.lua`.
- **Transporter Range Scaling:** The Transporter Software subsystem range now progressively scales up to a 10x multiplier based on rarity and the ship's transporter block volume.
- **Trade Heatmap Expansion:** The Trading Overview subsystem now progressively scales the economy heatmap range up to a 10x multiplier based on rarity.
- **Simulation Command Optimization:** Performed a massive optimization pass across all background map commands (`sell`, `procure`, `travel`, `trade`, etc.), stripping out heavily bloated unused imports and dead code functions.
- **Scout Command Immersion:** Completely rewrote and heavily expanded the Captain's Log notes generated by the Scout command. Scout reports are now highly thematic and narrative-driven, improving immersion.

### Removed

- **`moddata.lua`**: Completely removed the legacy file-based data storage system (`moddata.lua`). This was a major source of server crashes on fresh installations. All player settings are now handled by the robust, persistent `Cosmic Vault` API.
- **`TransferWindowFix.lua`**: Completely removed the legacy file as it was overhauled and integrated into `transfercrewgoods.lua`.
- **Deprecated Configs:** Removed unused and deprecated captain, map command modifiers and trader toggles from the Mod Configuration Menu (MCM) to align with the new dynamic progression systems.
- **`shipinfo.lua` (Player Tab):** Completely removed a broken, obsolete, and performance-heavy legacy player UI tab script (`data/scripts/player/ui/shipinfo.lua`) that was superseded by the Fleet Status system.
- **`galaxymapqolclient.lua`:** Removed an obsolete, crashing legacy script that attempted to use the deleted `moddata` system to save a single map checkbox state.

## [3.2.1] - 2026/05/25

### Fixed

- **Map Command Data Crash:** Fixed a critical server crash where starting a map operation (Mine, Salvage, etc.) on a fresh dedicated server would fail due to the `moddata` directory not existing on the host machine. The data loader now gracefully handles missing folders and defaults to clean tables.

## [3.2.0]

### Added

- **Galaxy Map Hotkeys**: Players can now quickly switch to their selected ship on the galaxy map using the `[T]` key.
- **Smart Camera Centering**: Using `[Shift + C]` on the galaxy map will now instantly center the camera on your home sector (dynamically choosing your personal or alliance home sector based on the ship you are currently piloting).
- **Localization Support**: Added new translation strings for map commands and hotkeys, updating all supported `.po` language files.

### Fixed

- **AlliedRelationsEnhancer**: Fixed a file naming typo (`.lua.lua`) that prevented the script from loading, restoring the intended alliance reputation enhancement features.

## [3.1.0]

### Added

- **Command Center Tab**: A native Player UI tab to track all active fleet operations (background and physical), including an integrated "Recall Ship" function.
- **Restored 1.0 Orders & Looping**: Re-integrated classic Mine, Refine, Salvage, and Loop map commands, optimized for 2.0+ without requiring external library dependencies.
- **Profitable Stations**: Introduced simulated civilian traffic for player-owned stations (Casinos, Resource Depots, etc.), generating passive income and resource yields.
- **Bulletin Board Enhancements**: Fully functional sorting (Description, Difficulty, Reward, Source) and dynamic filtering by mission type.
- **Enhanced Factory Logistics**: Added "Garbage Output" byproduct delivery to partner stations and improved shuttle volume upgrade scaling.Let's do the same

### Fixed

- **Player Bulletin Board**: Resolved critical UI splitter errors that caused mission lists to disappear.
- **Background AI Scripts**: Fixed pathing misalignments for `harvest.lua`, `refineores.lua`, and station trader logic.
- **Trading Manager API**: Corrected parameter ordering for revenue generation.
- **Localization Sync**: Synchronized translations across all supported languages for new Command Center and Factory features.

### Changed

- **AzimuthLib Dependency**: Removed legacy dependency for map command management, significantly reducing script overhead.
- **Profitable Stations Balance**: Aligned economy generation to better match vanilla progression curves.
- **Command Center Optimization**: Optimized data fetching to handle both simulation-based and physical ship states efficiently.

## [3.0.2]

### Added

- Integrated **Fleet Ship Status UI** into Cosmic Overhaul as an entity-owned feature flow.
- Attached Fleet Status script at entity level via:
  - `data/scripts/entity/init.lua` -> `data/scripts/entity/fleetstatus.lua`
- Added compatibility-safe legacy shim:
  - `data/scripts/player/fleetstatus.lua`
  - Purpose: prevent stale player-context invokes from causing runtime crashes.

### Fixed

- Resolved Fleet Status click/open failures where icon click selected the ship but did not open the Fleet window.
- Resolved repeated player-context UI stack traces caused by ScriptUI creation without entity context.
- Eliminated error path rooted in player-side FleetStatus window construction (`No entity in script's context`).

### Changed

- Fleet Status architecture was normalized back to original proven model:
  - **single entity script owns interaction + ScriptUI window + HUD rendering + config persistence**.
- Removed auto-attach of deprecated player FleetStatus flow from:
  - `data/scripts/player/init.lua`
- Retained `data/scripts/entity/shipinfo.lua` as a separate and intentional feature script (not part of FleetStatus crash path).

### Validation

- In-game verification confirms:
  - FSS icon appears correctly,
  - Fleet window opens,
  - options are clickable,
  - HUD appears and updates as expected,
  - no FleetStatus stack traces during interaction.

### Documentation

- Simplified `README.md` to a concise overview format.
- Moved/standardized full mod details into:
  - `Cosmic_Overhaul_Wiki.md`
- Added/standardized changelog location in-mod as `CHANGELOG.md` for consistency across Cosmic-series repositories.
- README now focuses on:
  - what the mod is,
  - key highlights,
  - installation and compatibility snapshot,
  - and pointer to full wiki details.
- Wiki remains the canonical source for full detailed feature documentation.
