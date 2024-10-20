local CaptainClass = include("captainclass")
local CaptainUtility = include("captainutility")
local SimulationUtility = include("simulationutility")

-- Used for nicer refreshing of assessment lines
local mcm_uiTimestamp

-- This unfortunately needs to be entirely replaced (not shadowed) because the original
-- threw the prediction away!
function ScoutCommand:initialize()
    -- This is all copy-pasted
    local prediction = self:calculatePrediction(getParentFaction().index, self.shipName, self.area, self.config)
    self.data.duration = prediction.duration.value
    self.data.attackChance = prediction.attackChance.value
    self.data.attackLocation = prediction.attackLocation
    -- This is new
    self.data.mcm = prediction.mcm
end

local original_ScoutCommand_calculatePrediction = ScoutCommand.calculatePrediction
function ScoutCommand:calculatePrediction(ownerIndex, shipName, area, config)
    local prediction = original_ScoutCommand_calculatePrediction(self, ownerIndex, shipName, area, config)

    local ship = ShipDatabaseEntry(ownerIndex, shipName)

    prediction = ScoutCommand.mcm_getExtendedPrediction(prediction, ship, area)

    return prediction
end

function ScoutCommand.mcm_getExtendedPrediction(prediction, ship, area)
    -- Keep mod values in their own part of the prediction
    prediction.mcm = {}

    -- Record the "real" raw values in the prediction
    prediction.mcm.deepScanRange = ScoutCommand.getEstimatedDeepScanRange(ship)
    _, _, prediction.mcm.hyperspaceCooldown = ship:getHyperspaceProperties()

    -- We use a scaled version of the raw inputs to keep things a little smoother and not have
    -- numbers change too wildly, even if it's a little less true to simulation
    local deepScanImpact = ScoutCommand.mcm_getDeepScanImpact(prediction.mcm.deepScanRange)
    local scaledCooldown = ScoutCommand.mcm_getScaledHyperdriveSpeed(prediction.mcm.hyperspaceCooldown)

    -- Keep a copy of all the sectors we might do something interesting with
    prediction.mcm.sectorsLeftToExplore = ScoutCommand.mcm_getScoutableCandidateSectorsInArea(area)
    prediction.mcm.numSectorsToExplore = #prediction.mcm.sectorsLeftToExplore
    shuffle(random(), prediction.mcm.sectorsLeftToExplore)

    -- Count how many sectors are just flybys and how many might have a real look
    local numInterestingSectors = #prediction.mcm.sectorsLeftToExplore
    local numBoringSectors = #area.analysis.reachableCoordinates - numInterestingSectors

    local captain = ship:getCaptain()
    local duration = 0

    -- Now we add up the time for the interesting and non-interesting sectors that will
    -- be visited
    local numBoringJumps = math.ceil(numBoringSectors / deepScanImpact)
    local timePerBoringJump = ScoutCommand.getTimePerBoringSector(captain, scaledCooldown)
    duration = duration + numBoringJumps * timePerBoringJump

    local timePerInterestingJump = ScoutCommand.getTimePerNewSector(captain, scaledCooldown)
    duration = duration + numInterestingSectors * timePerInterestingJump

    duration = duration * ScoutCommand.getCargoDurationMultiplier(ship)

    -- This double applies the perk impact on a little bit of the overall value, but
    -- that's not too significant
    for _, perk in pairs({captain:getPerks()}) do
        duration = duration * (1 + CaptainUtility.getScoutPerkImpact(captain, perk))
    end

    prediction.duration.value = duration
    prediction.mcm.timePerSector = duration / #prediction.mcm.sectorsLeftToExplore

    return prediction
end

local mcm_ScoutCommand_update_original = ScoutCommand.update
function ScoutCommand:update(...)
    self:mcm_update()
    mcm_ScoutCommand_update_original(self, ...)
end

function ScoutCommand:mcm_update()
    if not self.data.mcm then return end

    -- We're going to use update to incrementally reveal sectors instead of all at once.
    -- Even on the default 1-minute timer, it's important to not do too much work here.

    -- Figure out how many sectors we should reveal for how far we are in the command,
    -- storing them in a (small) table
    local ratioComplete = self.data.runTime / self.data.duration
    local totalSectors = self.data.mcm.numSectorsToExplore
    local expectedComplete = math.floor(ratioComplete * totalSectors)
    
    local sectorsThisUpdate = {}

    while (totalSectors - #self.data.mcm.sectorsLeftToExplore) < expectedComplete do
        local nextSector = table.remove(self.data.mcm.sectorsLeftToExplore)
        table.insert(sectorsThisUpdate, nextSector)
    end

    -- To be as noninvasive as possible with the mod, we'll reuse revealSectors.
    -- That requires temporarily swapping the "big" set of reachable coordinates, as
    -- that's what it'll act on.
    if #sectorsThisUpdate > 0 then
        local allSectors = self.area.analysis.reachableCoordinates
        self.area.analysis.reachableCoordinates = sectorsThisUpdate
        self:revealSectors(1)
        self.area.analysis.reachableCoordinates = allSectors
    end
end

function ScoutCommand.mcm_getScoutableCandidateSectorsInArea(area)
    local seed = GameSeed()
    local faction = getParentFaction()
    local specs = SectorSpecifics()

    -- We can't get very precise information about sectors via determineFastContent,
    -- but this filters out the majority of empty sectors and gives us a good narrowed
    -- down list of candidates for revealing things.
    local sectors = {}
    for _, coords in pairs(area.analysis.reachableCoordinates) do
        local view = faction:getKnownSector(coords.x, coords.y)
        if not view or (not view.visited and not view.hasContent) then
            local regular, offgrid = specs.determineFastContent(coords.x, coords.y, seed)
            if regular or offgrid then
                table.insert(sectors, coords)
            end
        end
    end

    return sectors
end

function ScoutCommand.getEstimatedDeepScanRange(ship)
    -- There's no API to get the "real" value, so we're going to approximate based
    -- on what's present.
    local range = 0

    for subsystem, info in pairs(ship:getSystems()) do
        if subsystem.script == "data/scripts/systems/radarbooster.lua" then
            -- Radar boosters give 1 and then 1-1.5 per rarity, doubled if permanent
            local multiplier = (info.permanent and 2.5) or 1.25
            range = range + 1 + math.max(0, subsystem.rarity.value * multiplier)
        elseif subsystem.script == "data/scripts/systems/teleporterkey5.lua" then
            -- The 4's artifact gives a flat 3
            range = range + (info.permanent and 3) or 0
        end
    end

    if ship:getCaptain():hasClass(CaptainClass.Explorer) then
        -- Explorer captains give another 3
        range = range + 3
    end

    return range
end

function ScoutCommand.mcm_getDeepScanImpact(rawRange)
    -- The intent of this math is to make the effect of range progression feel a little
    -- more linear and gradual on both ends
    local maxPowerBase = 9 
    local powerFactor = 1.5
    local multFactor = 2
    local flatFactor = 2

    local powerComponent = math.pow(math.min(rawRange, maxPowerBase), powerFactor)
    local multComponent = rawRange * multFactor
    return powerComponent + multComponent + flatFactor
end

function ScoutCommand.mcm_getScaledHyperdriveSpeed(rawSpeed)
    -- The intention of this is to normalize speeds to keep cooldown as "a benefit"
    -- and not an overpowering factor; that departs from "realism" a bit but so it goes
    local powerOffset = 30
    local power = 2

    return rawSpeed * (1 - math.pow(rawSpeed, power) / math.pow(rawSpeed + powerOffset, power))
end

function ScoutCommand.getTimePerBoringSector(captain, scaledStartTime)
    -- Five seconds to charge the hyperdrive plus the greatest of the ship's sped up
    -- hyperdrive cooldown and the captain reacting to the jump (bad captains slow down fast ships)
    local hyperspaceTime = scaledStartTime / 4

    local captainAwarenessTime = 8
    for _, perk in pairs({captain:getPerks()}) do
        captainAwarenessTime = captainAwarenessTime * (1 + CaptainUtility.getTravelPerkImpact(captain, perk))
    end

    return 5 + math.max(hyperspaceTime, captainAwarenessTime)
end

function ScoutCommand.getTimePerNewSector(captain, scaledStartTime)
    local hyperspaceTime = scaledStartTime / 3

    local captainNoteTime = 20
    for _, perk in pairs({captain:getPerks()}) do
        captainNoteTime = captainNoteTime * (1 + CaptainUtility.getScoutPerkImpact(captain, perk))
    end

    -- Odds are that the hyperspace drive is already cooled down by the time the notes are
    -- written, but for particularly bad cooldowns that'll be the weakest link
    return 5 + math.max(hyperspaceTime, captainNoteTime)
end

function ScoutCommand.getCargoDurationMultiplier(ship)
    local captain = ship:getCaptain()
    local getCargoDurationMultiplierForCaptain = function(captain)
        if captain:hasClass(CaptainClass.Smuggler) then return 1.0 end
        local stolenOrIllegal, dangerousOrSuspicious = SimulationUtility.getSpecialCargoCategories(ship:getCargo())
        return (stolenOrIllegal and 1.15)
            or ((dangerousOrSuspicious and not captain:hasClass(CaptainClass.Merchant)) and 1.15)
            or 1.0
    end
    return getCargoDurationMultiplierForCaptain(captain)
end

local mcm_ScoutCommand_generateAssessmentFromPrediction_original = ScoutCommand.generateAssessmentFromPrediction
function ScoutCommand:generateAssessmentFromPrediction(prediction, ...)
    local lines = mcm_ScoutCommand_generateAssessmentFromPrediction_original(self, prediction, ...)
    if not prediction or not prediction.mcm then return lines end
    local range = (prediction.mcm and prediction.mcm.deepScanRange) or 0

    local scanLine = SimulationUtility.getDeepScanAssessmentLine(mcm_uiTimestamp, range)
    table.insert(lines, 2, scanLine)

    -- This is a fragile replacement of the "underRadar" lines
    local reportLine = SimulationUtility.getIncrementalReportAssessmentLine(mcm_uiTimestamp)
    lines[6] = reportLine

    return lines
end

local mcm_ScoutCommand_onRecall_original = ScoutCommand.onRecall
function ScoutCommand:onRecall()
    --[[
        We don't want recall to do a partial reveal anymore since the command does incremental
        reveal throughout and final reveal isn't synchronized with the partial reveals for
        non-invasiveness; we'll disable the reveal by clearing the area analysis of possible
        candidates.
    ]]
    self.area.analysis.reachableCoordinates = {}
    mcm_ScoutCommand_onRecall_original(self)
end

local mcm_ScoutCommand_buildUI_original = ScoutCommand.buildUI
function ScoutCommand:buildUI(...)
    local ui = mcm_ScoutCommand_buildUI_original(self, ...)
    local refreshOriginal = ui.refresh
    ui.refresh = function(self, ...)
        if not config then
            mcm_uiTimestamp = appTimeMs()
        end
        refreshOriginal(self, ...)
    end
    return ui
end



local OperationExodus = include ("story/operationexodus")
local ScoutCommandNoteTable = include ("scoutcommandnotetable")

-- Optimization
local scf_seed = GameSeed()
local scf_gatesMap = GatesMap(GameSeed())

-- We entirely replace this function as it's not friendly to shadowing
function ScoutCommand:revealSectors(ratio)
    local faction = getParentFaction()
    local ship = ShipDatabaseEntry(faction.index, self.shipName)
    local captain = ship:getCaptain()

    local sectorsToReveal = {}

    for _, coords in pairs(self.area.analysis.reachableCoordinates) do
        local viewToAdd = self:getViewToAdd(coords.x, coords.y, captain, faction)
        if viewToAdd then
            table.insert(sectorsToReveal, viewToAdd)
        end
    end

    shuffle(sectorsToReveal)

    local numSectorsToReveal = math.floor(#sectorsToReveal * ratio)
    for index, view in pairs(sectorsToReveal) do
        if index > numSectorsToReveal then break end

        faction:addKnownSector(view)
    end
end

function ScoutCommand:getViewToAdd(x, y, captain, faction)
    local specifics = SectorSpecifics()
    local isRegular, isOffgrid = specifics.determineFastContent(x, y, scf_seed)

    -- Empty sector check
    if not isRegular and not isOffgrid then return nil end

    -- Replace the fast check with the more expensive check
    specifics:initialize(x, y, scf_seed)
    isRegular = specifics.regular
    isOffgrid = specifics.offgrid

    if specifics.blocked then return nil end

    local note = (isRegular and "") or self:generatePotentialNote(x, y, specifics, captain)

    -- Nil means it's an offgrid sector without a note == can't explore
    if not note then return nil end

    local view = faction:getKnownSector(x, y) or SectorView()
    if view.visited
        or view.hasContent
        or string.match(view.note.text, "${sectorNote}")
    then
        -- Sector is already explored or noted by a captain -- don't add it 
        return nil
    end
    specifics:fillSectorView(view, scf_gatesMap, true)

    return self:getNotedView(view, note, captain)
end

function ScoutCommand:generatePotentialNote(x, y, specifics, captain)
    local templatePath = specifics.generationTemplate.path

     -- If there are no lines for the off-grid sector, it means the captain can't explore it. Nil!
    local lines = ScoutCommandNoteTable:getLines(templatePath, captain)
    if not lines then return nil end

    local line = randomEntry(lines)

    -- Additional check for Operation Exodus beacons
    if OperationExodus.sectorShouldHaveBeacon(x, y, templatePath) then
        local exodusLines = ScoutCommandNoteTable:getLines("story/operationexodusbeacon", captain)
        line = (not exodusLines and line) or line .. "\n" .. randomEntry(exodusLines)
    end

    return line
end

function ScoutCommand:getNotedView(view, note, captain)
    -- Already has a note, don't add a new one
    if not view.note.empty then return view end

    local noteTemplate = (note ~= "" and "${sectorNote}") or ""
    local arguments = { sectorNote = note }

    -- This is really for the captain's "signature," not note as a whole
    if self.config and self.config.addCaptainsNote then
        noteTemplate = (noteTemplate == "" and "") or noteTemplate .. "\n"
        noteTemplate = noteTemplate .. "${captainNote} ${captainName}"%_T
        arguments.captainNote = "Uncovered by captain"%_T
        arguments.captainName = captain.name
    end

    view.note = NamedFormat(noteTemplate, arguments)

    -- make sure that no new icons are created
    if view.tagIconPath == "" then view.tagIconPath = "data/textures/icons/nothing.png" end

    return view
end

-- For quick testing purposes only! Makes the command almost instant and disables attacks.
-- local scf_ScoutCommand_calculatePrediction_original = ScoutCommand.calculatePrediction
-- function ScoutCommand:calculatePrediction(...)
--     local result = scf_ScoutCommand_calculatePrediction_original(self, ...)
--     result.duration.value = 1
--     result.attackChance.value = 0
--     result.attackLocation = nil
--     return result
-- end
