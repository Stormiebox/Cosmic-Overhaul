-- [Outlands: Resource Respawn] Extension for asteroidfieldgenerator.lua
-- Injected before the vanilla return statement via include() system.
-- AsteroidFieldGenerator is a local in scope from the vanilla file.

local CosmicOverhaulConfig = include("cosmicoverhaulconfig")

-- Store vanilla functions
local vanillaCreateAsteroidFieldEx = AsteroidFieldGenerator.createAsteroidFieldEx
local vanillaCreateForestAsteroidFieldEx = AsteroidFieldGenerator.createForestAsteroidFieldEx

-- Override createAsteroidFieldEx with configurable treasure chance and size modifier
function AsteroidFieldGenerator:createAsteroidFieldEx(numAsteroids, fieldSize, minAsteroidSize, maxAsteroidSize, hasResources, probability)

    fieldSize = fieldSize or 2000
    minAsteroidSize = minAsteroidSize or 5.0
    maxAsteroidSize = maxAsteroidSize or 25.0
    if hasResources == false then probability = 0 end

    -- [Outlands: Resource Respawn] Apply configurable size modifier
    local sizeModifier = CosmicOverhaulConfig.get().sizeModifier / 100
    minAsteroidSize = minAsteroidSize * sizeModifier
    maxAsteroidSize = maxAsteroidSize * sizeModifier

    -- [Outlands: Resource Respawn] Read configurable hidden treasure chance
    local hiddenTreasureChance = CosmicOverhaulConfig.get().hiddenTreasureChance / 100

    local asteroidsWithResources = numAsteroids * (probability or 0.05)

    asteroidsWithResources = asteroidsWithResources * GameSettings().resourceAsteroidFactor

    local asteroidFieldPosition = self:getFieldPosition()
    local asteroids = {}

    -- if no specific asteroid positions were set, create an organic cloud of asteroids
    if not self.asteroidPositions then
        local points = self:generateOrganicCloud(numAsteroids)

        self.asteroidPositions = {}
        for _, point in pairs(points) do
            table.insert(self.asteroidPositions, asteroidFieldPosition:transformCoord(point))
        end
    end

    for i = 1, numAsteroids do
        local resources = false
        if asteroidsWithResources > 0 then
            resources = true
            asteroidsWithResources = asteroidsWithResources - 1
        end

        -- create asteroid size from those min/max values and the actual value
        local size
        local hiddenTreasure = false

        if math.random() < 0.15 then
            -- create a bigger asteroid, but without resources
            size = lerp(math.random(), 0, 1.0, minAsteroidSize, maxAsteroidSize);
            if resources then
                resources = false
                asteroidsWithResources = asteroidsWithResources + 1
            end
        else
            -- normal asteroid
            size = lerp(math.random(), 0, 2.5, minAsteroidSize, maxAsteroidSize);
        end

        -- [Outlands: Resource Respawn] Configurable hidden treasure chance (vanilla: 1/50)
        if math.random() < hiddenTreasureChance then
            hiddenTreasure = true
        end

        local asteroidPosition = self:getNextAsteroidPosition(asteroidFieldPosition, fieldSize)
        local material = self:getAsteroidType()

        local asteroid = nil
        if hiddenTreasure then
            asteroid = self:createHiddenTreasureAsteroid(asteroidPosition, size, material)
        else
            asteroid = self:createSmallAsteroid(asteroidPosition, size, resources, material)
        end
        table.insert(asteroids, asteroid)
    end

    -- clear the asteroid positions once they're empty
    if self.asteroidPositions and #self.asteroidPositions == 0 then
        self.asteroidPositions = nil
    end

    return asteroidFieldPosition, asteroids
end

-- Override createForestAsteroidFieldEx with same configurable parameters
function AsteroidFieldGenerator:createForestAsteroidFieldEx(numAsteroids, fieldSize, minAsteroidSize, maxAsteroidSize, hasResources, probability, position)

    numAsteroids = 250 -- the number of asteroids

    probability = probability or 0.05

    local asteroidsWithResources = numAsteroids * probability
    if not hasResources then asteroidsWithResources = 0 end

    -- [Outlands: Resource Respawn] Apply configurable size modifier
    local sizeModifier = CosmicOverhaulConfig.get().sizeModifier / 100
    minAsteroidSize = (minAsteroidSize or 5.0) * sizeModifier
    maxAsteroidSize = (maxAsteroidSize or 25.0) * sizeModifier

    -- [Outlands: Resource Respawn] Read configurable hidden treasure chance
    local hiddenTreasureChance = CosmicOverhaulConfig.get().hiddenTreasureChance / 100

    local mat = self:getFieldPosition()
    if position ~= nil then
        mat.position = position
    end

    local xcoord = mat.pos.x
    local ycoord = mat.pos.y
    local zcoord = mat.pos.z

    local asteroids = {}

    local counter = 0
    local angle = getFloat(0, math.pi * 2.0)
    local height = getFloat(-fieldSize / 5, fieldSize / 5)
    local distFromCenter = getFloat(0, fieldSize * 0.75)

    for i = 1, numAsteroids do
        local resources = false
            if asteroidsWithResources > 0 then
                resources = true
                asteroidsWithResources = asteroidsWithResources - 1
            end
            -- create asteroid size from those min/max values and the actual value
            local size
            local hiddenTreasure = false

            if math.random() < 0.15 then
                size = lerp(math.random(), 0, 1.0, minAsteroidSize, maxAsteroidSize);
                if resources then
                    resources = false
                    asteroidsWithResources = asteroidsWithResources + 1
                end
            else
                size = lerp(math.random(), 0, 2.5, minAsteroidSize, maxAsteroidSize);
            end

            -- [Outlands: Resource Respawn] Configurable hidden treasure chance (vanilla: 1/50)
            if math.random() < hiddenTreasureChance then
                hiddenTreasure = true
            end

            zcoord = zcoord + 40
            counter = counter + 1
            local randomHeight = math.random(4,9)

            if counter == randomHeight or counter >= 10 then

                zcoord = mat.pos.z
                counter = 0
                angle = getFloat(0, math.pi * 2.0)
                height = getFloat(-fieldSize / 5, fieldSize / 5)
                distFromCenter = getFloat(0, fieldSize * 0.75)

            end

            local asteroidPosition = vec3(math.sin(angle) * distFromCenter, height, zcoord)

            asteroidPosition = mat:transformCoord(asteroidPosition)
            local material = self:getAsteroidType()

            local asteroid = nil
            if hiddenTreasure then
                asteroid = self:createHiddenTreasureAsteroid(asteroidPosition, size, material)
            else
                asteroid = self:createSmallAsteroid(asteroidPosition, size, resources, material)
            end
            table.insert(asteroids, asteroid)
        end
    return mat, asteroids
end
