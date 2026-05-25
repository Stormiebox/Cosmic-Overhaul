package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/player/background/simulation/?.lua"

local CommandType = include("commandtype")
local FactoryMap = include("factorymap")
local SimulationUtility = include("simulationutility")
local CaptainUtility = include("captainutility")
local CaptainClass = include("captainclass")
local GatesMap = include("gatesmap")
local SectorSpecifics = include("sectorspecifics")

local original_SellCommand_getAreaSize = SellCommand.getAreaSize
function SellCommand:getAreaSize(ownerIndex, shipName)
    local base = original_SellCommand_getAreaSize and original_SellCommand_getAreaSize(self, ownerIndex, shipName) or { x = 30, y = 30 }

    local ship = ShipDatabaseEntry(ownerIndex, shipName)
    local captain = ship:getCaptain()
    local bonus = 0

    if captain:hasClass(CaptainClass.Merchant) then
        bonus = bonus + 15
    elseif captain:hasClass(CaptainClass.Smuggler) then
        bonus = bonus + 10
    end

    for _, perk in pairs({captain:getPerks()}) do
        if perk == CaptainUtility.PerkType.MarketExpert or perk == CaptainUtility.PerkType.Navigator then
            bonus = bonus + 5
        end
    end

    return { x = base.x + bonus, y = base.y + bonus }
end

local original_SellCommand_calculatePrediction = SellCommand.calculatePrediction
function SellCommand:calculatePrediction(ownerIndex, shipName, area, config)
    local prediction = original_SellCommand_calculatePrediction and original_SellCommand_calculatePrediction(self, ownerIndex, shipName, area, config) or {}
    local ship = ShipDatabaseEntry(ownerIndex, shipName)
    local captain = ship:getCaptain()

    local timeMultiplier = 1.0
    if captain:hasClass(CaptainClass.Merchant) then
        timeMultiplier = 0.70
    elseif captain:hasClass(CaptainClass.Smuggler) then
        timeMultiplier = 0.85
    end

    if prediction and prediction.duration and prediction.duration.value then
        prediction.duration.value = prediction.duration.value * timeMultiplier
    end
    return prediction
end

local original_SellCommand_generateAssessmentFromPrediction = SellCommand.generateAssessmentFromPrediction
function SellCommand:generateAssessmentFromPrediction(prediction, captain, ...)
    local lines = original_SellCommand_generateAssessmentFromPrediction and original_SellCommand_generateAssessmentFromPrediction(self, prediction, captain, ...) or {}
    if type(lines) == "string" and lines == "" then return "" end
    if type(lines) ~= "table" then return lines end

    if not captain:hasClass(CaptainClass.Merchant) then
        local imperfectLine = SimulationUtility.getImperfectTradeClassLine(appTimeMs())
        table.insert(lines, 2, imperfectLine)
    end
    return lines
end
