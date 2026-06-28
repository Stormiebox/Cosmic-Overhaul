package.path = package.path .. ";data/scripts/lib/?.lua"
include("relations") -- Include and extend vanilla relations behavior.

-- Cosmic Overhaul: Dynamic Reputation Decay Namespace
DynamicReputationDecay = {}

-- Configuration with explicit units for readability.
local DecayConfig = {
    -- Cosmic Overhaul Balance tweak: Reduced from 100 to 50 to accommodate longer Ascendancy campaigns
    baseDecayPerHour = 50,
    maxDecayPerHour = 3000,
    increaseIntervalSec = 5*60*60,     -- 5 hours
    increaseAmountPerInterval = 100,
    startAfterSec = 60*60,             -- 1 hour inactivity
    updateIntervalSec = 60,            -- Throttle to once a minute for optimal server performance
}


-- =========================================================================
-- Background Decay Loop (Attached to the Player via player/init.lua)
-- =========================================================================

function DynamicReputationDecay.getUpdateInterval()
    return DecayConfig.updateIntervalSec
end

local function processDecayForEntity(entity, factionStr, now, galaxy)
    local cv_task = include("cosmicvaulttask")
    local iters = 0
    for idStr in string.gmatch(factionStr, "([^,]+)") do
        iters = iters + 1
        if cv_task and cv_task.Yield and (iters % 10 == 0) then
            cv_task.Yield()
        end

        local aiFactionIndex = tonumber(idStr)

        -- Fetch the persistent timestamp for this faction
        local lastTime = entity:getValue("co_rep_interact_" .. aiFactionIndex)
        if lastTime then
            local timeSinceLastInteraction = now-lastTime

            -- Has the 1-hour grace period expired?
            if timeSinceLastInteraction >= DecayConfig.startAfterSec then
                local hourlyDecayAmount = math.min(
                    DecayConfig.baseDecayPerHour+
                    (timeSinceLastInteraction/DecayConfig.increaseIntervalSec)*DecayConfig.increaseAmountPerInterval,
                    DecayConfig.maxDecayPerHour
                )

                -- Calculate actual decay for this specific tick interval (e.g. 60 seconds)
                local tickDecay = hourlyDecayAmount*(DecayConfig.updateIntervalSec/3600)
                local currentRel = galaxy:getFactionRelations(entity.index, aiFactionIndex)

                -- Cosmic Overhaul: Decay towards Neutral (0)
                -- Hostile factions slowly forgive, Allied factions slowly forget
                if currentRel > 0 then
                    local actualDecay = math.min(tickDecay, currentRel)
                    galaxy:changeFactionRelations(entity.index, aiFactionIndex, -actualDecay, false, false)
                elseif currentRel < 0 then
                    local actualDecay = math.min(tickDecay, math.abs(currentRel))
                    galaxy:changeFactionRelations(entity.index, aiFactionIndex, actualDecay, false, false)
                end
            end
        end
    end
end

function DynamicReputationDecay.updateServer(timeStep)
    if not onServer() then return end

    local player = Player()
    if not player then return end

    local now = Server().unpausedRuntime
    local galaxy = Galaxy()

    -- Cosmic Synergy: Fetch the active AI factions efficiently from the Cosmic Vault index!
    local factionStr = Server():getValue("factions")
    if type(factionStr) ~= "string" or factionStr == "" then return end

    local cv_task = include("cosmicvaulttask")
    if cv_task and cv_task.RunAsync then
        local taskName = "Decay_" .. player.index
        cv_task.RunAsync(taskName, function()
            -- Process Player
            processDecayForEntity(player, factionStr, now, galaxy)

            -- Process Alliance
            if player.alliance then
                processDecayForEntity(player.alliance, factionStr, now, galaxy)
            end
        end)
    else
        -- Process Player
        processDecayForEntity(player, factionStr, now, galaxy)

        -- Process Alliance
        if player.alliance then
            processDecayForEntity(player.alliance, factionStr, now, galaxy)
        end
    end
end


function getUpdateInterval(...)
    if DynamicReputationDecay.getUpdateInterval then return DynamicReputationDecay.getUpdateInterval(...) end
end
function updateServer(...)
    if DynamicReputationDecay.updateServer then return DynamicReputationDecay.updateServer(...) end
end

return DynamicReputationDecay, RelationChangeMaxCap, RelationChangeMinCap
