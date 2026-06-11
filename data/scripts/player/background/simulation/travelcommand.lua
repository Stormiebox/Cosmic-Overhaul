-- Used to keep track for attack chance and slider settings
local ccm_lastPrediction

local CaptainClass = include("captainclass")

local ccm_TravelCommand_initialize_original = TravelCommand.initialize
function TravelCommand:initialize(...)
    ccm_TravelCommand_initialize_original(self, ...)
    -- This is really TravelCommand's "start," so save anything interesting here
end

local ccm_TravelCommand_buildUI_original = TravelCommand.buildUI
function TravelCommand:buildUI(...)
    local ui = ccm_TravelCommand_buildUI_original(self, ...)

    local refreshPredictionsOriginal = ui.refreshPredictions
    ui.refreshPredictions = function(self, ownerIndex, shipName, area, config)
        refreshPredictionsOriginal(self, ownerIndex, shipName, area, config)
        if ccm_lastPrediction.attackChance.value == 0 and self.swiftnessSlider then
            -- If there's no attack chance, just crank that baby all the way to the right
            local values = TravelCommand:getConfigurableValues()
            self.swiftnessSlider:setValueNoCallback(values.swiftness.to)
            self:displayPrediction(ccm_lastPrediction, config, ownerIndex)
        end
    end

    return ui
end

local ccm_TravelCommand_calculatePrediction_original = TravelCommand.calculatePrediction
function TravelCommand:calculatePrediction(ownerIndex, shipName, area, config)
    -- Solely here to intercept so we can snoop on it elsewhere without invasive changes
    ccm_lastPrediction = ccm_TravelCommand_calculatePrediction_original(self, ownerIndex, shipName, area, config)

    if not ccm_lastPrediction then return ccm_lastPrediction end

    local ship = (ownerIndex and ownerIndex > 0 and shipName) and ShipDatabaseEntry(ownerIndex, shipName)
    if ship then
        local captain = ship:getCaptain()
        if captain then
            -- Navigators and Explorers have supreme mastery over long-distance routes
            if captain:hasClass(CaptainClass.Navigator) then
                if ccm_lastPrediction.duration and ccm_lastPrediction.duration.value then
                    ccm_lastPrediction.duration.value = ccm_lastPrediction.duration.value*0.75
                end
                if ccm_lastPrediction.attackChance and ccm_lastPrediction.attackChance.value then
                    ccm_lastPrediction.attackChance.value = ccm_lastPrediction.attackChance.value*0.50
                end
            elseif captain:hasClass(CaptainClass.Explorer) then
                if ccm_lastPrediction.duration and ccm_lastPrediction.duration.value then
                    ccm_lastPrediction.duration.value = ccm_lastPrediction.duration.value*0.85
                end
                if ccm_lastPrediction.attackChance and ccm_lastPrediction.attackChance.value then
                    ccm_lastPrediction.attackChance.value = ccm_lastPrediction.attackChance.value*0.75
                end
            end
        end
    end

    return ccm_lastPrediction
end

local ccm_TravelCommand_generateAssessmentFromPrediction_original = TravelCommand.generateAssessmentFromPrediction
function TravelCommand:generateAssessmentFromPrediction(prediction, captain, ...)
    local lines = ccm_TravelCommand_generateAssessmentFromPrediction_original and
        ccm_TravelCommand_generateAssessmentFromPrediction_original(self, prediction, captain, ...) or {}
    if type(lines) == "string" and lines == "" then return "" end
    if type(lines) ~= "table" then return lines end

    if captain:hasClass(CaptainClass.Navigator) then
        table.insert(lines, 2,
            "\\c(0d0)I know these spatial routes like the back of my hand. We'll make incredible time.\\c()"%_t)
    end
    return lines
end
