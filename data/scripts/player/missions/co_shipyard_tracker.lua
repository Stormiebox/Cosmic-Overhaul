package.path = package.path .. ";data/scripts/lib/?.lua"

include("utility")
include("structuredmission")
local ShipFounding = include("shipfounding")
local PlanGenerator = include("plangenerator")
local json = include("json")

mission.data.title = {text = "Shipyard Production: ${ship}"%_T}
mission.data.brief = {text = "Your ship is currently under construction."%_T}
mission.data.autoTrackMission = true
mission.data.custom.location = {}
mission.data.description = {}

mission.globalPhase.noBossEncountersTargetSector = true
mission.globalPhase.noPlayerEventsTargetSector = true
mission.globalPhase.noLocalPlayerEventsTargetSector = true

mission.globalPhase.onRestore = function()
    local player = Player()
    local queueStr = player:getValue("co_pending_shipyard_spawns")
    if queueStr then
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

    mission.data.title.arguments = {ship = shipName}
    mission.data.brief.arguments = {ship = shipName}
    mission.data.location = {x = cx, y = cy}

    mission.data.custom.job = {
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
        stationFactionIndex = stationFactionIndex
    }

    mission.data.description[1] = {text = "Wait for construction to finish."%_T}
    mission.data.description[2] = {text = "Shipyard Sector: (${x}:${y})"%_T, arguments = {x = cx, y = cy}, bulletPoint = true}
    
    sync()
end

mission.phases[1] = {}
mission.phases[1].getUpdateInterval = function()
    return 1.0
end

mission.phases[1].updateServer = function(timeStep)
    local job = mission.data.custom.job
    if not job then return end

    job.executed = (job.executed or 0) + timeStep

    if job.executed >= job.duration then
        -- Timer is complete!
        local player = Player()
        local sx, sy
        if Sector() then
            sx, sy = Sector():getCoordinates()
        end

        -- Inform the player
        player:sendChatMessage("", ChatMessageType.Information, "Your ship '%1%' is finished building at Sector (%2%:%3%)!"%_T, job.shipName, job.cx, job.cy)

        if sx == job.cx and sy == job.cy then
            -- Player is IN the sector! Spawn it immediately.
            spawnShip(job)
        else
            -- Player is NOT in the sector. Queue it for progressive materialization.
            queueShipForMaterialization(job)
        end
        
        -- Complete the mission
        finish()
    end
end

function spawnShip(job)
    local buyer = Galaxy():findFaction(job.ownerIndex)
    if not buyer then return end

    local station = Entity(Uuid(job.stationId))
    if not station then 
        -- If station is dead, spawn at center
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
            -- Fallback
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

function queueShipForMaterialization(job)
    local player = Player()
    
    -- Load the existing queue
    local queueStr = player:getValue("co_pending_shipyard_spawns")
    local queue = {}
    if queueStr then
        local success, decoded = pcall(json.decode, queueStr)
        if success and decoded then
            queue = decoded
        end
    end
    
    table.insert(queue, job)
    
    -- Save the queue
    player:setValue("co_pending_shipyard_spawns", json.encode(queue))
    
    -- Register the listener so when the player enters the sector, it spawns
    player:registerCallback("onSectorEntered", "onSectorEntered")
end

function onSectorEntered(playerIndex, x, y, sectorChangeType)
    local player = Player(playerIndex)
    local queueStr = player:getValue("co_pending_shipyard_spawns")
    if not queueStr then return end
    
    local success, queue = pcall(json.decode, queueStr)
    if not success or not queue then return end
    
    local remainingQueue = {}
    local spawnedAny = false
    
    for _, job in pairs(queue) do
        if job.cx == x and job.cy == y then
            -- The player has entered the sector where the ship was built!
            spawnShip(job)
            spawnedAny = true
        else
            table.insert(remainingQueue, job)
        end
    end
    
    if spawnedAny then
        if #remainingQueue > 0 then
            player:setValue("co_pending_shipyard_spawns", json.encode(remainingQueue))
        else
            player:setValue("co_pending_shipyard_spawns", nil)
            player:unregisterCallback("onSectorEntered", "onSectorEntered")
        end
    end
end
