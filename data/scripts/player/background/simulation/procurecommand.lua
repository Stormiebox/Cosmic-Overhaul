package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/player/background/simulation/?.lua"

local SimulationUtility = include("simulationutility")
local CaptainUtility = include("captainutility")
local CaptainClass = include("captainclass")

include("utility")
include("stringutility")
include("goods")

local original_ProcureCommand_getAreaSize = ProcureCommand.getAreaSize
function ProcureCommand:getAreaSize(ownerIndex, shipName)
    local a1, a2, a3
    if original_ProcureCommand_getAreaSize then
        a1, a2, a3 = original_ProcureCommand_getAreaSize(self, ownerIndex, shipName)
    end
    if not a1 then a1 = { x = 15, y = 15 } end

    local ship = (ownerIndex and ownerIndex > 0 and shipName) and ShipDatabaseEntry(ownerIndex, shipName)
    local bonus = 0

    if ship then
        local captain = ship:getCaptain()
        if captain then
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
        end
    end

    -- Cosmic Overhaul: Ensure all 3 rectangular shapes are properly returned and cleanly floored
    -- This prevents the "off by one cell" boundary UI validation error when players select the maximum edge.
    local squareBase = math.floor(a1.x + bonus)
    local longerEdge = math.floor((29 / 17) * squareBase)
    local shorterEdge = math.floor((11 / 17) * squareBase)

    return { x = squareBase, y = squareBase },
           { x = longerEdge, y = shorterEdge },
           { x = shorterEdge, y = longerEdge }
end

local original_ProcureCommand_calculatePrediction = ProcureCommand.calculatePrediction
function ProcureCommand:calculatePrediction(ownerIndex, shipName, area, config)
    local prediction = original_ProcureCommand_calculatePrediction and original_ProcureCommand_calculatePrediction(self, ownerIndex, shipName, area, config) or {}

    local ship = (ownerIndex and ownerIndex > 0 and shipName) and ShipDatabaseEntry(ownerIndex, shipName)

    local timeMultiplier = 1.0
    if ship then
        local captain = ship:getCaptain()
        if captain then
            -- Merchants and Smugglers are much faster at procuring goods
            if captain:hasClass(CaptainClass.Merchant) then
                timeMultiplier = 0.70
            elseif captain:hasClass(CaptainClass.Smuggler) then
                timeMultiplier = 0.85
            end
        end
    end

    if prediction and prediction.duration and prediction.duration.value then
        prediction.duration.value = prediction.duration.value * timeMultiplier
    end

    return prediction
end

local original_ProcureCommand_generateAssessmentFromPrediction = ProcureCommand.generateAssessmentFromPrediction
function ProcureCommand:generateAssessmentFromPrediction(prediction, captain, ...)
    local lines = original_ProcureCommand_generateAssessmentFromPrediction and original_ProcureCommand_generateAssessmentFromPrediction(self, prediction, captain, ...) or {}
    if type(lines) == "string" and lines == "" then return "" end
    if type(lines) ~= "table" then return lines end

    -- Include the "I'm not the best at this" line for non-merchant trading
    if not captain:hasClass(CaptainClass.Merchant) then
        local imperfectLine = SimulationUtility.getImperfectTradeClassLine(appTimeMs())
        table.insert(lines, 2, imperfectLine)
    end

    return lines
end
