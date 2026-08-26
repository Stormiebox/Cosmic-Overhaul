package.path = package.path .. ";data/scripts/lib/?.lua"

include("utility")
include("structuredmission")
local ShipFounding = include("shipfounding")
local PlanGenerator = include("plangenerator")

mission.data.title = {text = "Shipyard Production Tracker"%_T}
mission.data.brief = {text = "Tracking your queued ships."%_T}
mission.data.autoTrackMission = true
mission.data.custom.jobs = {} -- Array of ships

mission.globalPhase.noBossEncountersTargetSector = true
mission.globalPhase.noPlayerEventsTargetSector = true
mission.globalPhase.noLocalPlayerEventsTargetSector = true

mission.globalPhase.onRestore = function()
    local player = Player()
    
    -- Re-register sector listener just in case there are finished ships waiting
    local hasFinishedJob = false
    local jobs = mission.data.custom.jobs or {}
    for _, job in pairs(jobs) do
        if job.finished then
            hasFinishedJob = true
            break
        end
    end
    
    if hasFinishedJob then
        player:registerCallback("onSectorEntered", "onSectorEntered")
        
        -- Also check if they spawned into the exact sector on load
        local sx, sy
        if Sector() then
            sx, sy = Sector():getCoordinates()
        end
        if sx and sy then
            onSectorEntered(player.index, sx, sy, 0)
        end
    end
end

function trackShip(singleBlock, founder, withCrew, styleName, seed, volume, scale, material, shipName, duration, cx, cy, stationId, ownerIndex, stationFactionIndex)
    if not onServer() then return end

    local newJob = {
        singleBlock = singleBlock,
        founder = founder,
        withCrew = withCrew,
        styleName = styleName,
        seed = seed,
        volume = volume,
        scale = scale,
        material = material,
        shipName = shipName,
        duration = duration,
        executed = 0,
        cx = cx,
        cy = cy,
        stationId = stationId,
        ownerIndex = ownerIndex,
        stationFactionIndex = stationFactionIndex,
        finished = false
    }

    mission.data.custom.jobs = mission.data.custom.jobs or {}
    table.insert(mission.data.custom.jobs, newJob)
    
    updateMissionUI()
end

function updateMissionUI()
    local jobs = mission.data.custom.jobs or {}
    local desc = {}
    
    if #jobs == 0 then
        -- Clean up mission if no jobs exist
        finish()
        return
    end

    local bulletCount = 1
    for _, job in pairs(jobs) do
        if job.finished then
            desc[bulletCount] = {text = "Construction of '%1%' complete! Travel to (%2%:%3%) to retrieve it."%_T, arguments = {job.shipName, job.cx, job.cy}, bulletPoint = true}
        else
            desc[bulletCount] = {text = "Building '%1%' at (%2%:%3%)"%_T, arguments = {job.shipName, job.cx, job.cy}, bulletPoint = true}
        end
        bulletCount = bulletCount + 1
    end

    mission.data.description = desc
    sync()
end

mission.phases[1] = {}
mission.phases[1].getUpdateInterval = function()
    return 1.0
end

mission.phases[1].updateServer = function(timeStep)
    local jobs = mission.data.custom.jobs or {}
    if #jobs == 0 then return end

    local player = Player()
    local sx, sy
    if Sector() then
        sx, sy = Sector():getCoordinates()
    end

    local needsSync = false

    for i, job in pairs(jobs) do
        if not job.finished then
            job.executed = (job.executed or 0) + timeStep

            if job.executed >= job.duration then
                job.finished = true
                needsSync = true
                
                player:sendChatMessage("", ChatMessageType.Information, "Your ship '%1%' is finished building at Sector (%2%:%3%)!"%_T, job.shipName, job.cx, job.cy)

                if sx == job.cx and sy == job.cy then
                    -- Spawn immediately if player is in sector
                    spawnShip(job)
                    jobs[i] = nil
                else
                    -- Wait for player to arrive
                    player:registerCallback("onSectorEntered", "onSectorEntered")
                end
            end
        end
    end

    -- Clean up nils from array to maintain contiguous indices for Serialization
    local activeJobs = {}
    for _, job in pairs(jobs) do
        table.insert(activeJobs, job)
    end
    mission.data.custom.jobs = activeJobs

    if needsSync or #mission.data.custom.jobs == 0 then
        updateMissionUI()
    end
end

function onSectorEntered(playerIndex, x, y, sectorChangeType)
    local jobs = mission.data.custom.jobs or {}
    local needsSync = false
    local player = Player(playerIndex)

    for i, job in pairs(jobs) do
        if job.finished and x == job.cx and y == job.cy then
            spawnShip(job)
            jobs[i] = nil
            needsSync = true
        end
    end

    -- Clean up nils
    local activeJobs = {}
    local hasFinishedJob = false
    for _, job in pairs(jobs) do
        table.insert(activeJobs, job)
        if job.finished then
            hasFinishedJob = true
        end
    end
    mission.data.custom.jobs = activeJobs
    
    if not hasFinishedJob then
        player:unregisterCallback("onSectorEntered", "onSectorEntered")
    end

    if needsSync or #mission.data.custom.jobs == 0 then
        updateMissionUI()
    end
end

function spawnShip(job)
    local buyer = Galaxy():findFaction(job.ownerIndex)
    if not buyer then return end

    local station = Entity(Uuid(job.stationId))
    if not station then 
        station = { orientation = Matrix() }
        station.orientation.translation = vec3(0, 0, 0)
        station.getBoundingSphere = function() return Sphere(vec3(0,0,0), 100) end
    end

    local plan
    if job.singleBlock then
        plan = BlockPlan()
        plan:addBlock(vec3(0, 0, 0), vec3(2, 2, 2), -1, -1, ColorRGB(1, 1, 1), Material(job.material), Matrix(), BlockType.Hull, ColorNone())
    else
        local stationFaction = Faction(job.stationFactionIndex) or Faction()
        local style = stationFaction:getPlanStyle(job.styleName)
        if style then
            plan = GeneratePlanFromStyle(style, Seed(job.seed), job.volume, 2000, 1, Material(job.material))
        else
            plan = BlockPlan()
            plan:addBlock(vec3(0, 0, 0), vec3(2, 2, 2), -1, -1, ColorRGB(1, 1, 1), Material(job.material), Matrix(), BlockType.Hull, ColorNone())
        end
    end

    if not plan then return end
    plan:scale(vec3(job.scale, job.scale, job.scale))

    local position = station.orientation
    local sphere = station:getBoundingSphere()
    position.translation = sphere.center + random():getDirection() * (sphere.radius + plan.radius + 50)

    local ship = Sector():createShip(buyer, job.shipName, plan, position)
    if not ship then return end
    
    AddDefaultShipScripts(ship)
    SetBoardingDefenseLevel(ship)

    if job.founder then
        local sf = Faction(job.stationFactionIndex) or Faction()
        ship:addScript("data/scripts/entity/stationfounder.lua", sf)
    end

    if job.withCrew then
        local crew = ship.idealCrew
        ship.crew = crew
    end

    local senderInfo = makeCallbackSenderInfo(Entity())
    buyer:sendCallback("onShipCreationFinished", senderInfo, ship.id, job.founder)

    if GameSettings().difficulty <= Difficulty.Veteran and GameSettings().reconstructionAllowed then
        local kit = createReconstructionKit(ship)
        buyer:getInventory():addOrDrop(kit, true)
    end
end
