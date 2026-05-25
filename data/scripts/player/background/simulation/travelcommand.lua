-- Used to keep track for attack chance and slider settings
local mcm_lastPrediction

local CaptainClass = include("captainclass")
local SimulationUtility = include("simulationutility")
local CosmicOverhaulConfig = include("cosmicoverhaulconfig")

local mcm_TravelCommand_initialize_original = TravelCommand.initialize
function TravelCommand:initialize(...)
    mcm_TravelCommand_initialize_original(self, ...)
    -- This is really TravelCommand's "start," so save anything interesting here
end

local mcm_TravelCommand_buildUI_original = TravelCommand.buildUI
function TravelCommand:buildUI(...)
    local ui = mcm_TravelCommand_buildUI_original(self, ...)

    local refreshPredictionsOriginal = ui.refreshPredictions
    ui.refreshPredictions = function(self, ownerIndex, shipName, area, config)
        refreshPredictionsOriginal(self, ownerIndex, shipName, area, config)
        if mcm_lastPrediction.attackChance.value == 0 and self.swiftnessSlider then
            -- If there's no attack chance, just crank that baby all the way to the right
            local values = TravelCommand:getConfigurableValues()
            self.swiftnessSlider:setValueNoCallback(values.swiftness.to)
            self:displayPrediction(mcm_lastPrediction, config, ownerIndex)
        end
    end

    return ui
end

local mcm_TravelCommand_calculatePrediction_original = TravelCommand.calculatePrediction
function TravelCommand:calculatePrediction(ownerIndex, shipName, area, config)
    -- Solely here to intercept so we can snoop on it elsewhere without invasive changes
    mcm_lastPrediction = mcm_TravelCommand_calculatePrediction_original(self, ownerIndex, shipName, area, config)

    if not mcm_lastPrediction then return mcm_lastPrediction end

    local ship = ShipDatabaseEntry(ownerIndex, shipName)
    local captain = ship:getCaptain()

    -- Navigators and Explorers have supreme mastery over long-distance routes
    if captain:hasClass(CaptainClass.Navigator) then
        if mcm_lastPrediction.duration and mcm_lastPrediction.duration.value then
            mcm_lastPrediction.duration.value = mcm_lastPrediction.duration.value*0.75
        end
        if mcm_lastPrediction.attackChance and mcm_lastPrediction.attackChance.value then
            mcm_lastPrediction.attackChance.value = mcm_lastPrediction.attackChance.value*0.50
        end
    elseif captain:hasClass(CaptainClass.Explorer) then
        if mcm_lastPrediction.duration and mcm_lastPrediction.duration.value then
            mcm_lastPrediction.duration.value = mcm_lastPrediction.duration.value*0.85
        end
        if mcm_lastPrediction.attackChance and mcm_lastPrediction.attackChance.value then
            mcm_lastPrediction.attackChance.value = mcm_lastPrediction.attackChance.value*0.75
        end
    end

    return mcm_lastPrediction
end

local mcm_TravelCommand_generateAssessmentFromPrediction_original = TravelCommand.generateAssessmentFromPrediction
function TravelCommand:generateAssessmentFromPrediction(prediction, captain, ...)
    local lines = mcm_TravelCommand_generateAssessmentFromPrediction_original and
    mcm_TravelCommand_generateAssessmentFromPrediction_original(self, prediction, captain, ...) or {}
    if type(lines) == "string" and lines == "" then return "" end
    if type(lines) ~= "table" then return lines end

    if captain:hasClass(CaptainClass.Navigator) then
        table.insert(lines, 2,
            "\\c(0d0)I know these spatial routes like the back of my hand. We'll make incredible time.\\c()"%_t)
    end
    return lines
end
