package.path = package.path .. ";data/scripts/entity/?.lua"
package.path = package.path .. ";data/scripts/?.lua"
package.path = package.path .. ";data/scripts/sector/?.lua"

InteractPlayerStation = {}
local DockAI = include("ai/dock")
local data = { stationId = Uuid(), stationIndex = nil }
local stage, waitCount, tractorWaitCount, timeAlive, hasTraded = nil, nil, nil, 0, false

if not onServer() then return end

function InteractPlayerStation.initialize(targetId, targetIndex)
    data.stationId = targetId
    data.stationIndex = targetIndex
end

function InteractPlayerStation.leaveSector(ship, reason)
    if not hasTraded then
        Sector():sendCallback("onTradeSuccess", data.stationId, ship.id.string)
        hasTraded = true
    end
    if ship.aiOwned then
        ship:addScript("ai/passsector.lua", random():getDirection() * 2000)
    end
    terminate()
end

function InteractPlayerStation.updateServer(timeStep)
    local ship = Entity()
    timeAlive = timeAlive + timeStep
    local station = Sector():getEntity(data.stationIndex)

    if timeAlive > 300 then return InteractPlayerStation.leaveSector(ship, "took too long") end
    if not station then return InteractPlayerStation.leaveSector(ship, "station is invalid") end

    local docks = DockingPositions(station)
    if not valid(docks) or docks.numDockingPositions == 0 or not docks.docksEnabled then
        return InteractPlayerStation.leaveSector(ship, "no docks available")
    end
    if station:getValue("minimum_population_fulfilled") == false then
        return InteractPlayerStation.leaveSector(ship, "minimum population not fulfilled")
    end

    stage = stage or "docking"

    if stage == "docking" then
        local atDock, tractorActive = DockAI.flyToDock(ship, station)
        if atDock then stage = "waiting" return end
        if tractorActive then
            tractorWaitCount = (tractorWaitCount or 0) + timeStep
            if tractorWaitCount > 120 then
                docks:stopPulling(ship)
                return InteractPlayerStation.leaveSector(ship, "tractor stuck")
            end
        end
    elseif stage == "waiting" then
        waitCount = (waitCount or 0) + timeStep
        ShipAI(ship.index):setPassive()
        if waitCount > 25 then
            docks:stopPulling(ship)
            hasTraded = true
            Sector():sendCallback("onTradeSuccess", station.id, ship.id)
            stage = "leaving"
            return
        end
    elseif stage == "leaving" then
        if DockAI.flyAwayFromDock(ship, station) then
            docks:stopPulling(ship)
            InteractPlayerStation.leaveSector(ship, "leaving stage")
        end
    end
end

function InteractPlayerStation.restore(data_in)
    data.stationId = data_in.stationId
    data.stationIndex = data_in.stationIndex
    hasTraded = data_in.hasTraded
    stage = data_in.stage
    DockAI.restore(data_in)
end

function InteractPlayerStation.secure()
    local data_out = {}
    data_out.stationId = data.stationId
    data_out.stationIndex = data.stationIndex
    data_out.stage = stage
    data_out.hasTraded = hasTraded
    DockAI.secure(data_out)
    return data_out
end

function InteractPlayerStation.getUpdateInterval() return 2 end

function initialize(...)
    if InteractPlayerStation.initialize then return InteractPlayerStation.initialize(...) end
end
function updateServer(...)
    if InteractPlayerStation.updateServer then return InteractPlayerStation.updateServer(...) end
end
function restore(...)
    if InteractPlayerStation.restore then return InteractPlayerStation.restore(...) end
end
function secure(...)
    if InteractPlayerStation.secure then return InteractPlayerStation.secure(...) end
end
function getUpdateInterval(...)
    if InteractPlayerStation.getUpdateInterval then return InteractPlayerStation.getUpdateInterval(...) end
end
