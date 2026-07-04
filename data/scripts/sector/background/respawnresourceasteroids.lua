package.path = package.path .. ";data/scripts/lib/?.lua"

include("randomext")
local SectorGenerator = include("SectorGenerator")
local AsteroidFieldGenerator = include("asteroidfieldgenerator")
local Placer = include("placer")
local CosmicOverhaulConfig = include("cosmicoverhaulconfig")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace RespawnResourceAsteroids
RespawnResourceAsteroids = {}
local self = RespawnResourceAsteroids

-- Sector():setValue() keys for persistent state
local KEY_BASELINE = "outlands_rr_baseline"
local KEY_RESOURCE_BASELINE = "outlands_rr_res_baseline"
local KEY_LAST_RESPAWN = "outlands_rr_last_respawn"
local KEY_TARGET_PCT = "outlands_rr_target_pct"

-- Config defaults (as fractions â€” loadConfig() converts from MCM integer percentages)
self.restorationPct = 0.50   -- MCM: 50%
self.respawnRate = 0.01      -- MCM: 1%
self.respawnInterval = 5     -- MCM: 5 min
self.bigAsteroidChance = 0.01    -- MCM: 1%
self.hiddenTreasureChance = 0.02  -- MCM: 2%
self.sizeModifier = 1.0     -- MCM: 100%
self.respawnedFields = 3

-- Live respawn timer (not persisted â€” resets on sector load)
self.timer = 0

if onServer() then

-- Count asteroids that actually have minable resources remaining.
-- getNumEntitiesByComponent(ComponentType.MineableMaterial) counts entities
-- that have the component, but in edge cases the component may persist
-- after resources are depleted (e.g. stone shells from hidden treasure
-- asteroids where fighters mined the ore but left the stone blocks).
-- This function verifies actual resources.

local isSectorDirty = true
local cachedVerified = 0
local cachedGhosts = 0
local cachedComponentCount = 0
local cachedTotalRes = 0

local isSectorDirty = true
local cachedVerified = 0
local cachedGhosts = 0
local cachedComponentCount = 0
local cachedTotalRes = 0

-- Raw counting function (internal)
local function _countVerifiedMineable(sector)
    local entities = {sector:getEntitiesByComponent(ComponentType.MineableMaterial)}
    local verified = 0
    local ghosts = 0
    local totalRes = 0

    for _, entity in pairs(entities) do
        if entity.type == EntityType.Asteroid then
            local resources = entity:getMineableResources()
            if resources and resources > 0 then
                verified = verified + 1
                totalRes = totalRes + resources
            else
                ghosts = ghosts + 1
            end
        end
    end

    return verified, ghosts, #entities, totalRes
end

-- Cached wrapper
local function getVerifiedMineable(sector)
    if isSectorDirty then
        cachedVerified, cachedGhosts, cachedComponentCount, cachedTotalRes = _countVerifiedMineable(sector)
        isSectorDirty = false
    end
    return cachedVerified, cachedGhosts, cachedComponentCount
end

-- Cached wrapper
local function getTotalResources(sector)
    if isSectorDirty then
        cachedVerified, cachedGhosts, cachedComponentCount, cachedTotalRes = _countVerifiedMineable(sector)
        isSectorDirty = false
    end
    return cachedTotalRes
end

function RespawnResourceAsteroids.onEntityDestroyed(id, lastDamageInflictor)
    local entity = Sector():getEntity(id)
    if entity and entity.type == EntityType.Asteroid then
        isSectorDirty = true
    end
end

-- Remove depleted asteroid shells: entities with MineableMaterial component
-- but no actual resources remaining. These are typically stone shells left
-- behind after fighters mine the ore out of hidden treasure asteroids.
local function cleanupGhostAsteroids(sector)
    local entities = {sector:getEntitiesByComponent(ComponentType.MineableMaterial)}
    local removed = 0

    for _, entity in pairs(entities) do
        if entity.type == EntityType.Asteroid then
            local resources = entity:getMineableResources()
            if not resources or resources == 0 then
                sector:deleteEntity(entity)
                removed = removed + 1
            end
        end
    end

    if removed > 0 then
        print("Cleanup: removed %d depleted asteroid shells", removed)
    end

    return removed
end

function RespawnResourceAsteroids.loadConfig()
    self.enableResourceRegen = CosmicOverhaulConfig.get().enableResourceRegen
    if self.enableResourceRegen == nil then self.enableResourceRegen = true end
    self.restorationPct = (CosmicOverhaulConfig.get().restorationPct or 25) / 100
    self.respawnRate = (CosmicOverhaulConfig.get().respawnRate or 1) / 100
    self.respawnInterval = CosmicOverhaulConfig.get().respawnInterval or 2
    self.bigAsteroidChance = (CosmicOverhaulConfig.get().bigAsteroidChance or 1) / 100
    self.hiddenTreasureChance = (CosmicOverhaulConfig.get().hiddenTreasureChance or 2) / 100
    self.sizeModifier = (CosmicOverhaulConfig.get().sizeModifier or 100) / 100
    self.respawnedFields = CosmicOverhaulConfig.get().respawnedFields or 3
end

function RespawnResourceAsteroids.initialize()
    self.loadConfig()
    if not self.enableResourceRegen then return end

    self.timer = 0

    -- Register for push notifications when admin changes config via MCM


    local sector = Sector()
    sector:registerCallback("onDestroyed", "onEntityDestroyed")

    sector:setValue(KEY_TARGET_PCT, self.restorationPct)

    -- Snapshot system â€” take baseline BEFORE any emergency respawn
    -- so it reflects the sector's natural resource count, not inflated by emergency fields
    local baseline = sector:getValue(KEY_BASELINE)
    local lastRespawn = sector:getValue(KEY_LAST_RESPAWN)
    local now = Server().unpausedRuntime

    if not baseline then
        -- First load: take snapshot of current state BEFORE any modifications
        local verified, ghosts, componentCount = getVerifiedMineable(sector)
        baseline = verified
        sector:setValue(KEY_BASELINE, baseline)
        sector:setValue(KEY_RESOURCE_BASELINE, getTotalResources(sector))
        sector:setValue(KEY_LAST_RESPAWN, now)

        print("Snapshot taken: %d verified resource asteroids (component count: %d, ghosts: %d)", baseline, componentCount, ghosts)
    else
        -- Backfill resource baseline for sectors that predate this key
        if not sector:getValue(KEY_RESOURCE_BASELINE) then
            sector:setValue(KEY_RESOURCE_BASELINE, getTotalResources(sector))
        end

        -- Correct resource baseline if current resources exceed it
        -- (can happen after emergency respawn fields inflated the sector)
        local resBaseline = sector:getValue(KEY_RESOURCE_BASELINE)
        local totalRes = getTotalResources(sector)
        if resBaseline and totalRes > resBaseline then
            sector:setValue(KEY_RESOURCE_BASELINE, totalRes)
            print("Corrected resource baseline %d -> %d (exceeded by current resources)", resBaseline, totalRes)
        end
    end

    -- Clean up depleted asteroid shells (stone remnants from mined hidden treasures)
    cleanupGhostAsteroids(sector)

    -- Emergency replenishment: if sector is nearly empty, spawn full fields
    -- This runs AFTER baseline snapshot so emergency asteroids don't inflate the baseline
    local numAsteroids = sector:getNumEntitiesByType(EntityType.Asteroid)
    if numAsteroids < 200 then
        self.respawnFields()
    end


    -- Catch-up: simulate elapsed time since last respawn (unattended â€” can exceed target)
    local elapsed = now - (lastRespawn or now)

    -- Apply Cosmic Overhaul ARCC Limits
    if CosmicOverhaulConfig.get().enableOfflineCatchup then
        local maxDur = CosmicOverhaulConfig.get().offlineCatchupMaxDuration or 28800
        local ratio = CosmicOverhaulConfig.get().offlineCatchupRatio or 0.667
        elapsed = math.min(elapsed, maxDur) * ratio
    else
        elapsed = 0
    end

    local intervalSec = self.respawnInterval * 60


    if intervalSec > 0 and elapsed > 0 then
        local ticksPassed = math.floor(elapsed / intervalSec)
        if ticksPassed > 0 then
            local count = self.spawnBatch(baseline, ticksPassed, true)

            if count > 0 then
                print("Catch-up: %d ticks elapsed, spawned %d resource asteroids (unattended)", ticksPassed, count)
            end
        end
    end

    -- Always reset timer so the HUD countdown cycles correctly
    sector:setValue(KEY_LAST_RESPAWN, now)

    self.dumpDiagnostics(sector, baseline)
end

function RespawnResourceAsteroids.getUpdateInterval()
    return 10.0
end

function RespawnResourceAsteroids.updateServer(timeStep)
    if not self.enableResourceRegen then return end

    self.timer = self.timer + timeStep
    if self.timer < self.respawnInterval * 60 then return end
    self.timer = self.timer - self.respawnInterval * 60

    local sector = Sector()
    local baseline = sector:getValue(KEY_BASELINE)
    if not baseline then return end

    -- Backfill resource baseline if missing (e.g. sector predates this key)
    if not sector:getValue(KEY_RESOURCE_BASELINE) then
        sector:setValue(KEY_RESOURCE_BASELINE, getTotalResources(sector))
    end

    -- Clean up depleted asteroid shells before spawning new ones
    cleanupGhostAsteroids(sector)

    -- Unattended if no players are in the sector (e.g. kept alive by Sector Keep-Alive)
    local unattended = #{sector:getPlayers()} == 0

    local count = self.spawnBatch(baseline, 1, unattended)
    sector:setValue(KEY_LAST_RESPAWN, Server().unpausedRuntime)

    if count > 0 then
        print("Live tick: spawned %d resource asteroids%s", count, unattended and " (unattended)" or "")
    end
    self.dumpDiagnostics(sector, baseline)
end

-- @param baseline number Asteroid count baseline
-- @param ticks number Number of respawn intervals to simulate
-- @param unattended bool If true, allow spawning above restoration target (up to 100% baseline)
function RespawnResourceAsteroids.spawnBatch(baseline, ticks, unattended)
    local sector = Sector()

    -- Resource and asteroid caps depend on whether the sector was unattended
    -- Unattended (catch-up): cap at 100% of baseline (full natural recovery)
    -- Attended (live tick): cap at restoration target (e.g. 80%)
    local capPct = unattended and 1.0 or self.restorationPct
    -- Famine Synergy check
    local faction = Faction(sector.factionIndex)
    if faction and faction.isAIFaction then
        local economy = include("cosmicvaulteconomy")
        if economy then
            local famineScore = economy.getFamineLevel(faction.index)
            if famineScore == "Severe Famine" then
                print("Respawn paused: Faction is in Severe Famine.")
                return 0
            elseif famineScore == "Resource Starved" then
                print("Respawn throttled: Faction is Resource Starved.")
                ticks = math.max(1, math.floor(ticks * 0.5))
            end
        end
    end

    -- Resource-based gating

    local resBaseline = sector:getValue(KEY_RESOURCE_BASELINE)
    local totalRes = resBaseline and resBaseline > 0 and getTotalResources(sector)
    local resCap = resBaseline and resBaseline > 0 and resBaseline * capPct

    if totalRes and resCap and totalRes >= resCap then
        print("SpawnBatch skipped: resources %d >= cap %d%s", totalRes, math.floor(resCap), unattended and " (unattended)" or " (attended)")
        return 0
    end

    -- Asteroid count deficit
    local current, ghosts = getVerifiedMineable(sector)
    local target = math.ceil(baseline * capPct)
    if current >= target then return 0 end

    if ghosts > 0 then
        print("Ghost entities detected: %d asteroids have MineableMaterial component but no resources", ghosts)
    end

    local batchSize = math.max(1, math.ceil(baseline * self.respawnRate))
    local totalToSpawn = math.min(batchSize * ticks, target - current)

    -- Cap by resource deficit to avoid overshooting the cap
    if totalRes and resCap and resBaseline > 0 and baseline > 0 then
        local avgResPerAsteroid = resBaseline / baseline
        local resDeficit = resCap - totalRes
        if avgResPerAsteroid > 0 then
            local maxByRes = math.max(1, math.ceil(resDeficit / avgResPerAsteroid))
            totalToSpawn = math.min(totalToSpawn, maxByRes)
        end
    end

    if totalToSpawn <= 0 then return 0 end

    -- Collect anchor asteroids: prefer empties, fall back to any asteroid
    local allAsteroids = {sector:getEntitiesByType(EntityType.Asteroid)}
    if #allAsteroids == 0 then return 0 end

    local anchors = {}
    for _, asteroid in pairs(allAsteroids) do
        if not asteroid:hasComponent(ComponentType.MineableMaterial) then
            table.insert(anchors, asteroid)
        end
    end

    -- Fall back to all asteroids if no empties found
    if #anchors == 0 then
        anchors = allAsteroids
    end

    -- Shuffle anchors for spatial distribution
    for i = #anchors, 2, -1 do
        local random = random()
        local j = random:getInt(1, i)
        anchors[i], anchors[j] = anchors[j], anchors[i]
    end

    local x, y = sector:getCoordinates()
    local fieldGenerator = AsteroidFieldGenerator(x, y)
    local sectorGenerator = SectorGenerator(x, y)
    local spawned = {}

    for i = 1, totalToSpawn do
        -- Cycle through shuffled anchors
        local anchor = anchors[((i - 1) % #anchors) + 1]
        local dir = random():getDirection()
        local offset = random():getFloat(20, 80)
        local translation = anchor.translationf + dir * offset

        local position = MatrixLookUp(vec3(random():getFloat(), random():getFloat(), random():getFloat()), vec3(random():getFloat(), random():getFloat(), random():getFloat()))
        position.pos = translation

        local asteroid
        if random():test(self.bigAsteroidChance) then
            local size = random():getFloat(40.0, 60.0) * self.sizeModifier
            asteroid = sectorGenerator:createBigAsteroidEx(position, size, true)
        elseif random():test(self.hiddenTreasureChance) then
            local size = random():getFloat(5.0, 25.0) * self.sizeModifier
            asteroid = fieldGenerator:createHiddenTreasureAsteroid(translation, size, fieldGenerator:getAsteroidType())
        else
            local size = random():getFloat(5.0, 25.0) * self.sizeModifier
            asteroid = fieldGenerator:createSmallAsteroid(translation, size, true, fieldGenerator:getAsteroidType())
        end

        table.insert(spawned, asteroid)
    end

    if #spawned > 0 then
        Placer.resolveIntersections(spawned)
    end

    return #spawned
end

function RespawnResourceAsteroids.respawnFields()
    local sector = Sector()
    local x, y = sector:getCoordinates()
    local generator = SectorGenerator(x, y)

    for i = 1, self.respawnedFields do
        generator:createAsteroidField()
    end

    Placer.resolveIntersections()

    -- Anomaly Synergy
    if random():test(0.05) then
        local anomalies = include("cosmicvaultanomalies")
        if anomalies then
            local anomalyType = random():test(0.5) and "PrecursorWreck" or "SpatialRift"
            local position = MatrixLookUp(vec3(random():getFloat(), random():getFloat(), random():getFloat()), vec3(random():getFloat(), random():getFloat(), random():getFloat()))
            position.pos = vec3(random():getInt(-2000, 2000), random():getInt(-2000, 2000), random():getInt(-2000, 2000))
            anomalies.spawnAnomaly(x, y, anomalyType, position)
            print("Anomaly Spawned: " .. anomalyType)
        end
    end

    -- News Integration
    local faction = Faction(sector.factionIndex)
    if faction and faction.isAIFaction and sector:getEntitiesByType(EntityType.Station) then
        local numStations = #{sector:getEntitiesByType(EntityType.Station)}
        if numStations >= 2 then
            local news = include("cosmicvaultnews_server")
            if news and news.publishArticle then
                news.publishArticle({
                    title = "Seismic Shifts in " .. faction.name .. " Space",
                    content = "New Resource Veins Discovered in Sector [" .. x .. ":" .. y .. "] as shifting gravity wells unearth hidden riches.",
                    category = "Economy",
                    author = "Cosmic Chronicles"
                })
            end
        end
    end


    -- Update baselines if emergency fields pushed counts above the original snapshot
    -- This prevents the HUD from showing >100% and keeps caps consistent
    local verified = getVerifiedMineable(sector)
    local baseline = sector:getValue(KEY_BASELINE) or 0
    if verified > baseline then
        sector:setValue(KEY_BASELINE, verified)
        print("Emergency: updated asteroid baseline %d -> %d", baseline, verified)
    end

    local totalRes = getTotalResources(sector)
    local resBaseline = sector:getValue(KEY_RESOURCE_BASELINE) or 0
    if totalRes > resBaseline then
        sector:setValue(KEY_RESOURCE_BASELINE, totalRes)
        print("Emergency: updated resource baseline %d -> %d", resBaseline, totalRes)
    end

    sector:setValue(KEY_LAST_RESPAWN, Server().unpausedRuntime)

    print("Emergency: spawned %d asteroid fields (total < 200)", self.respawnedFields)
end

function RespawnResourceAsteroids.dumpDiagnostics(sector, baseline)
    local verified, ghosts, componentCount = getVerifiedMineable(sector)
    local totalAsteroids = sector:getNumEntitiesByType(EntityType.Asteroid)
    local asteroidTarget = math.ceil(baseline * self.restorationPct)
    local resBaseline = sector:getValue(KEY_RESOURCE_BASELINE) or 0
    local totalRes = getTotalResources(sector)
    local resTarget = math.floor(resBaseline * self.restorationPct)

    print("=== DIAGNOSTICS ===")
    print("Asteroids: %d total, %d with resources (ghosts: %d, component: %d)", totalAsteroids, verified, ghosts, componentCount)
    print("Asteroid baseline: %d, target: %d, deficit: %d", baseline, asteroidTarget, math.max(0, asteroidTarget - verified))
    print("Resources: %d / %d (target: %d, %d%%)", totalRes, resBaseline, resTarget, math.floor(self.restorationPct * 100))
    print("===================")
end

end -- if onServer()


function initialize(...)
    if RespawnResourceAsteroids.initialize then return RespawnResourceAsteroids.initialize(...) end
end
function getUpdateInterval(...)
    if RespawnResourceAsteroids.getUpdateInterval then return RespawnResourceAsteroids.getUpdateInterval(...) end
end
function updateServer(...)
    if RespawnResourceAsteroids.updateServer then return RespawnResourceAsteroids.updateServer(...) end
end


-- Global Event Callbacks
function onEntityDestroyed(...)
    if RespawnResourceAsteroids.onEntityDestroyed then return RespawnResourceAsteroids.onEntityDestroyed(...) end
end