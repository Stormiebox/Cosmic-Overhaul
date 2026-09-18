-- Cosmic Overhaul: Resource Respawn — Claimable Asteroid Abandonment
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
    -- Always run vanilla's initialize (registers onPlayerLeft), regardless of the current config
    -- state: onPlayerLeft() below re-checks abandonmentEnabled live on every call, so registering
    -- unconditionally here (instead of only on the disabled branch) keeps a mid-game CCM toggle
    -- working for asteroids that were attached while abandonment was enabled -- otherwise those
    -- asteroids never call Sector():registerCallback at all and permanently lose the vanilla
    -- mine-transformation path even after the admin disables abandonment again.
    vanilla_initialize()

    if not CosmicOverhaulConfig.get().abandonmentEnabled then
        return
    end

    -- Record when this asteroid was sold to an AI faction
    local entity = Entity()
    if not entity:getValue(KEY_SOLD_TIME) then
        entity:setValue(KEY_SOLD_TIME, Server().unpausedRuntime)
    end
end

function getUpdateInterval()
    -- Tick at 60s either way -- when disabled, updateServer() below immediately no-ops, so a
    -- fast interval only adds pointless per-tick config lookups across every claimed asteroid
    -- in the galaxy. (The previous version returned 0 -- "as fast as possible" -- specifically
    -- when disabled, which is the opposite of the intended throttle.)
    return 60
end

function updateServer()
    if not CosmicOverhaulConfig.get().abandonmentEnabled then return end

    local entity = Entity()
    local soldTime = entity:getValue(KEY_SOLD_TIME)
    if not soldTime then return end

    local elapsed = Server().unpausedRuntime - soldTime
    local elapsedHours = elapsed / 3600

    if elapsedHours < 0.01 then return end

    local chancePerHour = (CosmicOverhaulConfig.get().abandonmentChance or 10) / 100
    -- Cumulative probability: 1 - (1 - chance)^hours
    local cumulativeChance = 1 - ((1 - chancePerHour) ^ elapsedHours)

    local rng = Random(Seed(entity.id.number + Server().unpausedRuntime))
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
    include("cosmicvaultdebug").info("Cosmic Overhaul", "Abandoning asteroid %s in sector %s", tostring(entity.id), tostring(Sector():getCoordinates()))

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
