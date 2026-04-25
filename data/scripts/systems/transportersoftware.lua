local transporterRangeFromBlocks_getBonuses = getBonuses

function getRealBonuses(seed, rarity, permanent)
	local ok, plan = pcall(Plan)
	if not ok or not plan then
		local oldRange, fighter = transporterRangeFromBlocks_getBonuses(seed, rarity, permanent)
		return oldRange or 0, fighter or 0
	end

	local transporterBlocks = plan:getBlocksByType(BlockType.Transporter) or {}
	local transporterVolume = 0
	for _, v in pairs(transporterBlocks) do
		local block = plan:getBlock(v)
		if block and block.box and block.box.size then
			transporterVolume = transporterVolume + length(block.box.size)
		end
	end

	local oldRange, fighter = transporterRangeFromBlocks_getBonuses(seed, rarity, permanent)
	oldRange = oldRange or 0
	fighter = fighter or 0
	local rarityValue = (rarity and rarity.value) or 0

	return oldRange + transporterVolume * (rarityValue / 2 + 1) * 3, fighter
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
		texts[1].rtext = texts[1].rtext .. " + more from transporter blocks"
	end

	if not permanent then
		return {}, texts
	end

	return texts, texts
end
