
local SimulationUtility = include 'simulationutility'

local mcm_uiTimestamp

-- After everything else with analysis, do an extra check for whether or not a resource depot is in
-- the same sector
local mcm_RefineCommand_onAreaAnalysisFinished_original = RefineCommand.onAreaAnalysisFinished
function RefineCommand:onAreaAnalysisFinished(results, meta)
    mcm_RefineCommand_onAreaAnalysisFinished_original(self, results, meta)

    local playerShip = ShipDatabaseEntry(meta.faction.index, meta.shipName)
    if not playerShip then return end
    local shipX, shipY = playerShip:getCoordinates()
    local shipSectorView = meta.faction:getKnownSector(shipX, shipY)
    if not shipSectorView then return end

    if meta.faction:getRelationStatus(shipSectorView.factionIndex) == RelationStatus.War then
        -- No refining at hostile depots, sorry!
        return
    end

    for _, name in pairs({shipSectorView:getStationTitles()}) do
        if string.match(name.text, "Resource Depot"%_t) then
            results.sameSectorDepot = true
        end
    end
end

-- When calculating prediction, improve things if area analysis flagged a friendly refinery in the
-- same sector as the ship
local mcm_RefineCommand_calculatePrediction_original = RefineCommand.calculatePrediction
function RefineCommand:calculatePrediction(ownerIndex, shipName, area, config)
    local prediction = mcm_RefineCommand_calculatePrediction_original(self, ownerIndex, shipName, area, config)
    if area.analysis.sameSectorDepot then
        -- If it's the same sector, reduce duration by the greater of one third or 3 minutes, but
        -- never below 3 minutes
        local reduction = math.max(0.33 * prediction.duration, 3 * 60)
        prediction.duration = math.max(prediction.duration - reduction, 3 * 60)
        -- And, come on, it's in the same friendly sector, there's no ambushing going on
        prediction.attackChance = 0
    end
    prediction.timestamp = appTimeMs()
    return prediction
end

-- Update the assessment generator with nice flavor text for the refine bonuses
local mcm_RefineCommand_generateAssessmentFromPrediction_original 
    = RefineCommand.generateAssessmentFromPrediction
function RefineCommand:generateAssessmentFromPrediction(prediction, captain, ownerIndex, shipName, area, config)
    local originalResult = mcm_RefineCommand_generateAssessmentFromPrediction_original(
        self, prediction, captain, ownerIndex, shipName, area, config)
    if originalResult == '' then return '' end

    if area.analysis.sameSectorDepot then
        -- Somewhat fragile assumptions; we're going to replace the "refine lines" and "friendly lines"
        local inSectorLine = SimulationUtility.getSameSectorDepotLine(mcm_uiTimestamp)
        originalResult[1] = ''
        originalResult[2] = inSectorLine
    end

    return originalResult
end

local mcm_RefineCommand_buildUI_original = RefineCommand.buildUI
function RefineCommand:buildUI(...)
    local ui = mcm_RefineCommand_buildUI_original(self, ...)
    local originalRefresh = ui.refresh
    ui.refresh = function(self, ownerIndex, shipName, area, config)
        if not config then
            mcm_uiTimestamp = appTimeMs()
        end
        originalRefresh(self, ownerIndex, shipName, area, config)
    end
    return ui
end