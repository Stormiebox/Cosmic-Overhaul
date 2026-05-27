package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include("basesystem")
include("utility")
include("randomext")
include("callable")
include("goods")

-- Cosmic Overhaul: Safely hook into the vanilla getEconomyRange function
local getEconomyRange_vanilla = getEconomyRange
function getEconomyRange(seed, rarity, permanent)
    if not getEconomyRange_vanilla then
        return nil
    end

    local vanillaRange = getEconomyRange_vanilla(seed, rarity, permanent)
    if not vanillaRange then return nil end

    -- Cosmic Overhaul: Trade Heatmap Expansion
    -- Instead of a flat multiplier, we dynamically scale the economy map
    -- range based on the subsystem's rarity to make progression much more rewarding!
    local rarityValue = (rarity and rarity.value) or 0
    local multiplier = 2 -- Baseline 2x for Common/Petty

    if rarityValue >= RarityType.Legendary then multiplier = 10
    elseif rarityValue >= RarityType.Exotic then multiplier = 8
    elseif rarityValue >= RarityType.Exceptional then multiplier = 6
    elseif rarityValue >= RarityType.Rare then multiplier = 4
    elseif rarityValue >= RarityType.Uncommon then multiplier = 3
    end

    return vanillaRange * multiplier
end
