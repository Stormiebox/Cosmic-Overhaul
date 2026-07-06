local transporterRangeFromBlocks_getBonuses = getBonuses

function getRealBonuses(seed, rarity, permanent)
	local plan = Plan()
	if not plan then
		local oldRange, fighter = transporterRangeFromBlocks_getBonuses(seed, rarity, permanent)
		return oldRange or 0, fighter or 0
	end

	local transporterBlocks = plan:getBlocksByType(BlockType.Transporter) or {}
	local transporterScale = 0
	for _, v in pairs(transporterBlocks) do
		local block = plan:getBlock(v)
		if block and block.box and block.box.size then
			-- Cosmic Overhaul: Using length (diagonal dimension) prevents exponential range scaling from massive blocks
			transporterScale = transporterScale+length(block.box.size)
		end
	end

	local oldRange, fighter = transporterRangeFromBlocks_getBonuses(seed, rarity, permanent)
	oldRange = oldRange or 0
	fighter = fighter or 0
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

	return oldRange+(transporterScale*multiplier), fighter
end

local transporterRangeFromBlocks_onInstalled = onInstalled
function onInstalled(seed, rarity, permanent)
	if transporterRangeFromBlocks_onInstalled then
		transporterRangeFromBlocks_onInstalled(seed, rarity, permanent)
	end

	if not permanent then return end

	local range, fighter = getRealBonuses(seed, rarity, permanent)
	addAbsoluteBias(StatsBonuses.TransporterRange, range or 0)
	addAbsoluteBias(StatsBonuses.FighterCargoPickup, fighter or 0)
end

local transporterRangeFromBlocks_getTooltipLines = getTooltipLines
function getTooltipLines(seed, rarity, permanent)
	local left, right = transporterRangeFromBlocks_getTooltipLines(seed, rarity, permanent)

	local texts = right or left or {}
	if texts[1] and texts[1].rtext then
		-- Cosmic Overhaul: Updated tooltip to explicitly mention the progressive scaling
		texts[1].rtext = texts[1].rtext .. " (+ scaled by Transporter Blocks)"%_t
	end

	if not permanent then
		return {}, texts
	end

	return texts, texts
end
