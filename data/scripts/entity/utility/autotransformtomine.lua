-- Outlands: Resource Respawn — Claimable Asteroid Abandonment
-- Same-path extension: appended after vanilla autotransformtomine.lua
-- When abandonment is enabled, AI-owned claimable asteroids have a configurable
-- chance per hour to become abandoned and reclaimable instead of transforming into mines.

local CosmicOverhaulConfig = include("cosmicoverhaulconfig")

local KEY_SOLD_TIME = "outlands_rr_sold_time"

if onServer() then

-- Store vanilla function references before overriding
local vanilla_initialize = initialize
local vanilla_onPlayerLeft = onPlayerLeft
local vanilla_createMine = createMine

function initialize()
    if not CosmicOverhaulConfig.get().abandonmentEnabled then
        vanilla_initialize()
        return
    end

    -- Record when this asteroid was sold to an AI faction
    local entity = Entity()
    if not entity:getValue(KEY_SOLD_TIME) then
        entity:setValue(KEY_SOLD_TIME, os.time())
    end
end

function getUpdateInterval()
    if not CosmicOverhaulConfig.get().abandonmentEnabled then
        return 0
    end
    return 60
end

function updateServer()
    if not CosmicOverhaulConfig.get().abandonmentEnabled then return end

    local entity = Entity()
    local soldTime = entity:getValue(KEY_SOLD_TIME)
    if not soldTime then return end

    local elapsed = os.time() - soldTime
    local elapsedHours = elapsed / 3600

    if elapsedHours < 0.01 then return end

    local chancePerHour = (CosmicOverhaulConfig.get().abandonmentChance or 10) / 100
    -- Cumulative probability: 1 - (1 - chance)^hours
    local cumulativeChance = 1 - ((1 - chancePerHour) ^ elapsedHours)

    local rng = Random(Seed(entity.id.number + os.time()))
    if rng:test(cumulativeChance) then
        abandonAsteroid(entity)
    end
end

function onPlayerLeft()
    if CosmicOverhaulConfig.get().abandonmentEnabled then
        -- No-op: disable vanilla mine transformation
        return
    end
    vanilla_onPlayerLeft()
end

function createMine()
    if CosmicOverhaulConfig.get().abandonmentEnabled then
        -- No-op: disable vanilla mine transformation
        return
    end
    vanilla_createMine()
end

function abandonAsteroid(entity)
    print("Abandoning asteroid %s in sector %s", tostring(entity.id), tostring(Sector():getCoordinates()))

    -- Unclaim: set faction to neutral (0 = no faction)
    entity.factionIndex = 0

    -- Remove scripts added when claimed/sold
    entity:removeScript("sellobject.lua")
    entity:removeScript("minefounder.lua")
    entity:removeScript("aiundockable.lua")

    -- Re-add claim script so players can reclaim it
    entity:addScriptOnce("claim.lua")

    -- Clean up sold timestamp
    entity:setValue(KEY_SOLD_TIME, nil)

    -- Remove map marker if present
    entity:setValue("map_marker", nil)

    -- Self-terminate (removes autotransformtomine from entity)
    terminate()
end

end -- onServer
