package.path = package.path .. ";data/scripts/entity/ai/?.lua"

PlayerStationTrader = {}
if not onServer() then return end

local data = { stationId = Uuid(), stationIndex = nil }
include("interactplayerstation")

local initializeAI = InteractPlayerStation.initialize
local updateServerAI = InteractPlayerStation.updateServer
local restoreAI = InteractPlayerStation.restore
local secureAI = InteractPlayerStation.secure

function PlayerStationTrader.initialize(stationId, stationIndex)
    data.stationId = stationId
    data.stationIndex = stationIndex
    initializeAI(stationId, stationIndex)
end

function PlayerStationTrader.restore(dataIn)
    data = dataIn
    restoreAI(dataIn.ai)
end

function PlayerStationTrader.secure()
    return { ai = secureAI(), stationId = data.stationId, stationIndex = data.stationIndex }
end

function PlayerStationTrader.getUpdateInterval() return 1 end

function PlayerStationTrader.updateServer(timeStep)
    local sector = Sector()
    if sector.numPlayers == 0 then
        sector:sendCallback("onTradeSuccess", data.stationId, Entity().id.string)
        sector:deleteEntityJumped(Entity())
    end
    updateServerAI(timeStep)
end

function initialize(...)
    if PlayerStationTrader.initialize then return PlayerStationTrader.initialize(...) end
end
function restore(...)
    if PlayerStationTrader.restore then return PlayerStationTrader.restore(...) end
end
function secure(...)
    if PlayerStationTrader.secure then return PlayerStationTrader.secure(...) end
end
function getUpdateInterval(...)
    if PlayerStationTrader.getUpdateInterval then return PlayerStationTrader.getUpdateInterval(...) end
end
function updateServer(...)
    if PlayerStationTrader.updateServer then return PlayerStationTrader.updateServer(...) end
end
