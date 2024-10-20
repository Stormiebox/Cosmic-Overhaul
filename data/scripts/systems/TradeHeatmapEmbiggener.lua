package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include("basesystem")
include("utility")
include("randomext")
include("callable")
include("goods")

getEconomyRange_vanilla = getEconomyRange
function getEconomyRange(seed, rarity, permanent)
    local vanillaRange = getEconomyRange_vanilla(seed, rarity, permanent)
    if not vanillaRange then return end
    return vanillaRange * 8
end