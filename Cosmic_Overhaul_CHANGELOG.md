# Changelog

All notable changes to **Cosmic Overhaul** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Code Clean Up & Overhaul
- Cleaned up code in command scripts.
- Overhauled command scripts to be more compatible with other mods in Avorion.

## [Unreleased]
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
