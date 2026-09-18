-- Cosmic Overhaul: VFS override of vanilla tradingoverview.lua, wrapping only getEconomyRange.
-- See Changelog.md for why this can't be done as a standalone additive item (economyinfo.lua
-- hardcodes the two script paths it will call getEconomyRange on).
local tradingOverview_getEconomyRange = getEconomyRange

function getEconomyRange(seed, rarity, permanent)
	local vanillaRange = tradingOverview_getEconomyRange(seed, rarity, permanent)
	if not vanillaRange or vanillaRange == 0 then return vanillaRange end

	local rarityValue = (rarity and rarity.value) or 0

	-- Cosmic Overhaul: Progressive Rarity Scaling
	-- Standardized the scaling curve across all Cosmic Overhaul subsystems
	local multiplier = 2 -- Baseline 2x for Common/Petty
	if rarityValue >= RarityType.Legendary then multiplier = 10
	elseif rarityValue >= RarityType.Exotic then multiplier = 8
	elseif rarityValue >= RarityType.Exceptional then multiplier = 6
	elseif rarityValue >= RarityType.Rare then multiplier = 4
	elseif rarityValue >= RarityType.Uncommon then multiplier = 3
	end

	return vanillaRange * multiplier
end
