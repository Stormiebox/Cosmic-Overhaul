package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include("utility")
include("randomext")
include("galaxy")

local AsyncShipGenerator = include("asyncshipgenerator")

PlayerStationUtils = {}
if not onServer() then return end

function PlayerStationUtils.GetAsyncGenFor(type)
    local hash = { miner = "createMiningShip", trader = "createTradingShip", military = "createMilitaryShip", freighter = "createFreighterShip", torpedo = "createTorpedoShip" }
    return hash[type]
end

local function tableRandom(haystack)
    return haystack[math.floor(math.random() * (#haystack - 1)) + 1]
end

function PlayerStationUtils.spawnTraderFor(namespace, station, shipTypes)
    shipTypes = shipTypes or { "freighter" }
    local sector = Sector()
    local x, y = sector:getCoordinates()
    local chosenType = tableRandom(shipTypes)

    if sector:getValue("war_zone") or sector:getValue("hazard_zone") then return end
    local faction = Galaxy():getNearestFaction(x, y)
    if faction:getRelations(station.factionIndex) < -40000 then return end

    local pos = random():getDirection() * 1500
    local matrix = MatrixLookUpPosition(normalize(-pos), vec3(0, 1, 0), pos)

    local generatedFunc = function(ship)
        if not valid(station) then return end
        ship:addScript("ai/playerstationtrader.lua", station.id.string, station.index)
        ship:setValue("plystation_partner", station.id.string)
    end
    AsyncShipGenerator(namespace, generatedFunc)[PlayerStationUtils.GetAsyncGenFor(chosenType)](nil, faction, matrix)
end