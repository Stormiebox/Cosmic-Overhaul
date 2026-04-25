package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include("basesystem")
include("utility")
include("randomext")
include("callable")
include("goods")

local getEconomyRange_vanilla = getEconomyRange
function getEconomyRange(seed, rarity, permanent)
    if not getEconomyRange_vanilla then
        return nil
    end

    local vanillaRange = getEconomyRange_vanilla(seed, rarity, permanent)
    if not vanillaRange then return nil end
    return vanillaRange * 8
end
