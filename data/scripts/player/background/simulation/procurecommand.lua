package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/player/background/simulation/?.lua"

local CommandType = include("commandtype")
local FactoryMap = include("factorymap")
local SimulationUtility = include("simulationutility")
local CaptainUtility = include("captainutility")
local GatesMap = include("gatesmap")
local SectorSpecifics = include("sectorspecifics")

include("utility")
include("stringutility")
include("goods")
local CosmicOverhaulConfig = include("cosmicoverhaulconfig")

function ProcureCommand:getAreaSize(ownerIndex, shipName)
    local cfg = CosmicOverhaulConfig and CosmicOverhaulConfig.get and CosmicOverhaulConfig.get() or nil
    local bonus = (cfg and cfg.extraLongRangeTradeBonus) or 0
    local size = 30 + bonus
    return { x = size, y = size }
end
