# Changelog

All notable changes to **Cosmic Overhaul** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.1.0]
### Added
- **New Command Center Tab**: A native Player UI tab to track all active fleet operations (background and physical), including an integrated "Recall Ship" function.
- **Restored 1.0 Orders & Looping**: Re-integrated classic Mine, Refine, Salvage, and Loop map commands, optimized for 2.0+ without requiring external library dependencies.
- **Profitable Stations**: Introduced simulated civilian traffic for player-owned stations (Casinos, Resource Depots, etc.), generating passive income and resource yields.
- **Bulletin Board Enhancements**: Fully functional sorting (Description, Difficulty, Reward, Source) and dynamic filtering by mission type.
- **Enhanced Factory Logistics**: Added "Garbage Output" byproduct delivery to partner stations and improved shuttle volume upgrade scaling.

### Fixed
- Resolved critical UI splitter errors in the Player Bulletin Board that caused mission lists to disappear.
- Fixed pathing misalignments for background AI scripts (`harvest.lua`, `refineores.lua`) and station trader logic.
- Corrected API parameter ordering for revenue generation in the Trading Manager.
- Synchronized localization across all supported languages for new Command Center and Factory features.

### Changed
- Removed legacy dependency on `AzimuthLib` for map command management, significantly reducing script overhead.
- Balanced Profitable Stations economy to align with vanilla progression curves.
- Optimized Command Center data fetching to handle both simulation-based and physical ship states.

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
