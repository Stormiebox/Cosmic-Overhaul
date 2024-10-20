function getRealBonuses(seed, rarity, permanent)
	local ok, plan = pcall(Plan)
	if not plan then return 0 end
	local transporterBlocks = plan:getBlocksByType(BlockType.Transporter)
	local transporterVolume = 0
	for k, v in pairs(transporterBlocks) do
		local block = plan:getBlock(v)
		transporterVolume = transporterVolume + length(block.box.size)
	end
	local old_range, fighter = getBonuses(seed, rarity, permanent)
	return old_range + transporterVolume * (rarity.value / 2 + 1) * 3, fighter
end

local transporterRangeFromBlocks_onInstalled = onInstalled
function onInstalled(seed, rarity, permanent)
	if not permanent then return end

	local range, fighter = getRealBonuses(seed, rarity, permanent)
	addAbsoluteBias(StatsBonuses.TransporterRange, range)
	addAbsoluteBias(StatsBonuses.FighterCargoPickup, fighter)
end

local transporterRangeFromBlocks_getTooltipLines = getTooltipLines
function getTooltipLines(seed, rarity, permanent)
	local _, texts = transporterRangeFromBlocks_getTooltipLines(seed, rarity, permanent)
	texts[1].rtext = texts[1].rtext .. " + more from transporter blocks"
	if not permanent then
		return {}, texts
	else
		return texts, texts
	end
end