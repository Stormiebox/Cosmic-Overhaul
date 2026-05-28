local SimulationUtility = include 'simulationutility'
local CaptainClass = include("captainclass")
local CaptainUtility = include("captainutility")

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

    for _, title in pairs({ shipSectorView:getStationTitles() }) do
        local titleString = type(title) == "table" and title.text or tostring(title)
        if string.match(titleString, "Resource Depot"%_t) then
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
        -- Keep attackChance shape compatible with vanilla/UI expectations.
        if type(prediction.attackChance) == "table" then
            prediction.attackChance.value = 0
        else
            prediction.attackChance = 0
        end
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

local mcm_RefineCommand_getAreaSize_original = RefineCommand.getAreaSize
function RefineCommand:getAreaSize(ownerIndex, shipName)
    local a1, a2, a3
    if mcm_RefineCommand_getAreaSize_original then
        a1, a2, a3 = mcm_RefineCommand_getAreaSize_original(self, ownerIndex, shipName)
    end
    if not a1 then a1 = { x = 15, y = 15 } end

    local ship = ShipDatabaseEntry(ownerIndex, shipName)
    local captain = ship:getCaptain()
    local bonus = 0

    if captain:hasClass(CaptainClass.Merchant) then
        bonus = bonus + 15
    elseif captain:hasClass(CaptainClass.Miner) then
        bonus = bonus + 10
    end

    for _, perk in pairs({captain:getPerks()}) do
        if perk == CaptainUtility.PerkType.MarketExpert or perk == CaptainUtility.PerkType.Navigator then
            bonus = bonus + 5
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
