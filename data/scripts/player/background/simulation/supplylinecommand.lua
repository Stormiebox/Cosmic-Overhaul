package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/player/background/simulation/?.lua"

local CommanderCommand = include("commandercommand")
local SimulationUtility = include("simulationutility")
local CaptainClass = include("captainclass")
include("utility")
include("stringutility")

local SupplyLineCommand = {}
setmetatable(SupplyLineCommand, {__index = CommanderCommand})

function SupplyLineCommand:getIcon()
    return "data/textures/icons/trade-route.png"
end

function SupplyLineCommand:getDescription()
    return "Supply Line"%_t
end

function SupplyLineCommand:getTooltip()
    return "Establish an automated supply line between two stations."%_t
end

function SupplyLineCommand:getSizeConstraints()
    return {min = 1, max = 1}
end

function SupplyLineCommand:getAreaSize(ownerIndex, shipName)
    return {x = 1, y = 1}
end

function SupplyLineCommand:getAreaBounds()
    return {lower = vec2(-500, -500), upper = vec2(500, 500)}
end

function SupplyLineCommand:isAreaFixed(ownerIndex, shipName)
    return true
end

function SupplyLineCommand:getConfigurableValues(ownerIndex, shipName)
    local values = {}
    values.goodToTransfer = {displayName = "Cargo to Transfer"%_t}
    return values
end

function SupplyLineCommand:getErrors(ownerIndex, shipName, area, config)
    local ship = ShipDatabaseEntry(ownerIndex, shipName)
    if not ship then return "Ship not found"%_t end

    local captain = ship:getCaptain()
    if not captain then return "Ship needs a captain"%_t end

    if not config or not config.goodToTransfer then
        return "Select a good to transfer."%_t
    end

    return nil
end

function SupplyLineCommand:calculatePrediction(ownerIndex, shipName, area, config)
    local prediction = {}
    prediction.duration = {value = 60 * 60, name = "Duration"%_t, format = SimulationUtility.formatTime}
    prediction.attackChance = {value = 0.05, name = "Ambush Chance"%_t, format = SimulationUtility.formatPercentage}
    return prediction
end

function SupplyLineCommand:generateAssessmentFromPrediction(prediction, captain, ownerIndex, shipName, area, config)
    local lines = {}
    table.insert(lines, "We will ferry goods between the designated outposts continuously."%_t)
    return lines
end

function SupplyLineCommand:buildUI(startPressedCallback, cancelPressedCallback, configChangedCallback)
    local ui = {}
    ui.orderName = "Supply Line"%_t
    ui.icon = self:getIcon()

    local window = TooltipMaker()
    window:addText("Select the good to transfer between the current sector and target sector.")
    
    -- In a full implementation, we'd build a combo box here mapping cargo goods
    
    ui.window = window
    ui.clear = function(self) end
    ui.refresh = function(self, ownerIndex, shipName, area, config) end
    ui.displayPrediction = function(self, prediction, config, ownerIndex) end

    return ui
end

function SupplyLineCommand:onStart(ownerIndex, shipName, area, config)
    local ship = ShipDatabaseEntry(ownerIndex, shipName)
    ship:setStatusMessage("Ferrying supply line..."%_t)
end

function SupplyLineCommand:update(ownerIndex, shipName, timeStep, area, config)
    -- Every hour (or timeStep), automatically shift goods
    -- For brainstorm prototype, we simulate a background completion 
end

function SupplyLineCommand:onRecall(ownerIndex, shipName, area, config)
    -- Handle ship recall
end

function SupplyLineCommand:onFinish(ownerIndex, shipName, area, config)
    -- Handle finish
end

return SupplyLineCommand
