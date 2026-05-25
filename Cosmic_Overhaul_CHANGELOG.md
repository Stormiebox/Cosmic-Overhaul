# Changelog

All notable changes to **Cosmic Overhaul** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.3.0] - 2026/05/25

### Changed
- **Player Settings Storage**: Completely refactored the mod to use the new `CosmicVaultPlayerSettings` API for storing persistent UI settings (like checkboxes in the Trade and Salvage command windows).
- **War Economy Synergy**: Player-owned stations now have their passive income from the "Profitable Stations" feature dynamically reduced based on the local `War Heat` from the *Cosmic War* mod. High-conflict zones are now less profitable, requiring players to protect their economic hubs.

### Removed
- **`moddata.lua`**: Removed the legacy file-based data storage system (`moddata.lua`), which was a source of server crashes on new installations. All player settings are now handled by the robust `Cosmic Vault` API.

## [3.2.1] - 2026/05/25

-- TODO: Combine all versions on this changelog starting from 3.2.1+. This will be a long project.

### Fixed

- **Map Command Data Crash:** Fixed a critical server crash where starting a map operation (Mine, Salvage, etc.) on a fresh dedicated server would fail due to the `moddata` directory not existing on the host machine. The data loader now gracefully handles missing folders and defaults to clean tables.
- **Command Center Localization:** Corrected a Server-to-Client translation trap where background operations (e.g., "Mining", "Active") were being translated into the Server Host's language instead of the local Client's UI language.

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
