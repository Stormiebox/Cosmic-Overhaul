# Cosmic Overhaul - Workshop Change Notes (2026-05-09)

## New Feature, Stability & Compatibility Update

This update focuses on runtime stability and compatibility with newer Avorion behavior and mixed mod stacks.

### Fixed
- Resolved Fighter Merchant script stability issues introduced during previous compatibility work.
- Rebuilt and validated `data/scripts/entity/merchants/fightermerchant.lua` structure to prevent script-load/runtime failures.
- Added safer fighter handling paths to reduce invalid fighter entries reaching pricing logic.

### Compatibility Notes
- A known crash source in some setups came from external Workshop mods that override:
  - `data/scripts/lib/inventoryitemprice.lua`
- Those external overrides referenced removed Avorion 2.x enum paths (`FighterType.CargoShuttle`) and could trigger:
  - `Enum value doesn't exist: FighterType.CargoShuttle`
- Cosmic Overhaul has been hardened to reduce exposure in Fighter Merchant generation paths.
- If you still see this exact enum error, review/unsubscribe conflicting pricing override mods that ship old `inventoryitemprice.lua` logic.

### Gameplay / Balance Intent Preserved
- Equipment Dock / Fighter Merchant stock expansion intent remains intact:
  - higher fighter amount/variety
  - rarity shaping still active in special offer logic

### Verification Summary

- Latest provided logs indicate:
  - Cosmic Overhaul issue appears resolved in current test runs,
  - no reoccurring Fighter Merchant crash chain from the previous failing path.

## Black Market / Smuggler’s Market Rework (New Feature Detail)

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

## Recommended player note (short form)
If you encounter `FighterType.CargoShuttle` errors, another mod is likely overriding `inventoryitemprice.lua` with pre-2.x logic. Disable that override mod or use an updated version.
