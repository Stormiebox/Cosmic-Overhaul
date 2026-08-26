local UniversalSR_Shipyard = Shipyard.initialize
function Shipyard.initialize()
    if UniversalSR_Shipyard then UniversalSR_Shipyard() end

    Entity():setValue("remove_permanent_upgrades", true)
end

local UniversalSR_startServerJob = Shipyard.startServerJob
function Shipyard.startServerJob(singleBlock, founder, withCrew, styleName, seed, volume, scale, material, name)
    if UniversalSR_startServerJob then 
        UniversalSR_startServerJob(singleBlock, founder, withCrew, styleName, seed, volume, scale, material, name)
    end
    
    -- Extract the job from the local runningJobs table and transfer it to the global player tracker
    local runningJobs = Shipyard.secure()
    if runningJobs then
        for i, job in pairs(runningJobs) do
            if job.player == callingPlayer and job.shipName == name then
                local extractedJob = runningJobs[i]
                -- Remove from station queue so it doesn't build twice
                runningJobs[i] = nil
                
                local player = Player(callingPlayer)
                local cx, cy = Sector():getCoordinates()
                local stationId = Entity().id.string
                
                -- Add and start the tracker mission
                player:addScriptOnce("player/missions/co_shipyard_tracker.lua")
                player:invokeFunction("co_shipyard_tracker", "trackShip", 
                    extractedJob.singleBlock, extractedJob.founder, extractedJob.withCrew, 
                    extractedJob.styleName, extractedJob.seed, extractedJob.volume, 
                    extractedJob.scale, extractedJob.material, extractedJob.shipName, 
                    extractedJob.duration, cx, cy, stationId, extractedJob.shipOwner, Entity().factionIndex)
                
                break
            end
        end
    end
end

function initialize(...)
    if Shipyard.initialize then return Shipyard.initialize(...) end
end
