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

### ✨ Added
- **Sealed Hulks (Boarding Operations):** Deep space hidden mass sectors now have a chance to generate a massive "Sealed Hulk." Docking with these derelicts initiates an interactive "Choose Your Own Adventure" text event where you risk your crew against automated defenses, radiation leaks, and blast doors for massive payouts and Legendary subsystem drops!
- **Tag-Based AI Generation:** Replaced rigid Vanilla Faction tracking with a robust new tag-based AI (`[Aggressive]`, `[Passive]`, `[Trader]`).
- **Dynamic AI Behaviors:** Factions now organically calculate their AI routines (Patrol vs Trade) using the Vault Faction Tag system rather than static hardcoded tables.
- **Cosmic Vault API Framework:** Fully integrated with the Cosmic Vault API framework. Swept codebase for legacy callbacks and implemented safe pcall fallbacks.

### 🐛 Bug Fixes & Optimization
- **UI Memory Leaks Sealed:** Injected `onRemove()` functions into UI scripts like the Bulletin Board and Resource Display. Previously, jumping sectors caused the UI to secretly stack invisible event listeners, leading to massive memory bloat in late-game.
- **Multiplayer Networking & Stability:** Added missing `callable()` declarations to Factory upgrade buttons so they work properly on Dedicated Servers. Also added `onClient()` wrappers to Stash and Galaxy Map scripts to prevent the singleplayer server thread from crashing itself with errant network calls.
- **Performance & TPS Optimization:** Drastically reduced server load during late-game scenarios. Injected a hardcoded `getUpdateInterval` throttle into 5 major AI and UI scripts (`refineores`, `factory`, `transfercrewgoods`, `shipinfo`, `sectorshipoverview`). This prevents highly-industrialized player sectors from dragging down Server TPS by throttling factory logic to run once every 5 seconds instead of 60 times a second.
- **Scout Mission Fix:** Fixed a massive vanilla/mod bug where Scout Missions would completely skip and ignore Faction Headquarters sectors because the `scoutcommandnotetable` lacked dialogue lines for that specific sector template.
- **Multiplayer Desyncs:** Replaced `math.random` with the deterministic engine `random():getInt()` across all custom scripts to prevent massive physics and stats desyncs in multiplayer.
