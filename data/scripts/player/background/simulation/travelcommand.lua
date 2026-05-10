-- Used to keep track for attack chance and slider settings
local mcm_lastPrediction
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
function TravelCommand:calculatePrediction(...)
    -- Solely here to intercept so we can snoop on it elsewhere without invasive changes
    mcm_lastPrediction = mcm_TravelCommand_calculatePrediction_original(self, ...)

    local cfg = CosmicOverhaulConfig and CosmicOverhaulConfig.get and CosmicOverhaulConfig.get() or nil
    if cfg and mcm_lastPrediction then
        if mcm_lastPrediction.duration and mcm_lastPrediction.duration.value then
            mcm_lastPrediction.duration.value = mcm_lastPrediction.duration.value *
            (cfg.captainEfficientTravelMultiplier or 1.0)
        end
        if mcm_lastPrediction.attackChance and mcm_lastPrediction.attackChance.value then
            mcm_lastPrediction.attackChance.value = mcm_lastPrediction.attackChance.value *
            (cfg.captainSafeAttackChanceMultiplier or 1.0)
        end
    end

    return mcm_lastPrediction
end
