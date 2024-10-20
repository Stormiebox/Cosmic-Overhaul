package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/player/background/simulation/?.lua"

local CommandType = include("commandtype")
local FactoryMap = include("factorymap")
local SimulationUtility = include("simulationutility")
local CaptainUtility = include("captainutility")
local GatesMap = include("gatesmap")
local SectorSpecifics = include("sectorspecifics")

function SellCommand:getAreaSize(shipName)
    return {x = 30, y = 30}
end