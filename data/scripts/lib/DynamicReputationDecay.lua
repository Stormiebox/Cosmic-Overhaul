package.path = package.path .. ";data/scripts/lib/?.lua"
include("relations") -- Include and extend vanilla relations behavior.

-- Track last interaction timestamp by AI faction index.
local lastInteraction = {}

-- Configuration with explicit units for readability.
local DecayConfig = {
    baseDecayPerHour = 100,
    maxDecayPerHour = 3000,
    increaseIntervalSec = 5 * 60 * 60, -- 5 hours
    increaseAmountPerInterval = 100,
    startAfterSec = 60 * 60, -- 1 hour inactivity
    updateIntervalSec = 10, -- throttle expensive processing
}

local updateAccumulator = 0

local function onFactionInteraction(aiFactionIndex)
    if not aiFactionIndex then return end
    lastInteraction[aiFactionIndex] = Server().unpausedRuntime
end

local cCounter = 0
local function c()
    cCounter = cCounter + 1
    return cCounter
end

-- Intentionally global to stay compatible with scripts expecting these symbols.
RelationChangeType = {
    Default = c(),
    CraftDestroyed = c(),
    ShieldsDamaged = c(),
    HullDamaged = c(),
    Boarding = c(),
    CombatSupport = c(),
    Smuggling = c(),
    Raiding = c(),
    GeneralIllegal = c(),
    ServiceUsage = c(),
    ResourceTrade = c(),
    GoodsTrade = c(),
    EquipmentTrade = c(),
    WeaponsTrade = c(),
    Commerce = c(),
    Tribute = c(),
}

RelationChangeNames = {}
for k, v in pairs(RelationChangeType) do
    RelationChangeNames[v] = k
end

RelationChangeMaxCap = {
    [RelationChangeType.ServiceUsage] = 45000,
    [RelationChangeType.ResourceTrade] = 45000,
    [RelationChangeType.GoodsTrade] = 65000,
    [RelationChangeType.EquipmentTrade] = 75000,
    [RelationChangeType.WeaponsTrade] = 75000,
    [RelationChangeType.Commerce] = 50000,
    [RelationChangeType.Tribute] = 0,
}

RelationChangeMinCap = {
    [RelationChangeType.Smuggling] = -75000,
    [RelationChangeType.GeneralIllegal] = -75000,
}

-- Keep signature compatible with vanilla relations script.
function changeRelations(a, b, delta, changeType, notifyA, notifyB, chatterer)
    if not delta or delta == 0 then return end

    local factionA, factionB, aiFaction, playerFaction = getInteractingFactions(a, b)
    if not factionA or not factionB then return end
    if factionA.isAIFaction and factionB.isAIFaction then return end
    if factionA.index == factionB.index then return end
    if factionA.alwaysAtWar or factionB.alwaysAtWar then return end
    if factionA.staticRelationsToAll or factionB.staticRelationsToAll then return end
    if factionA.staticRelationsToPlayers and (factionB.isPlayer or factionB.isAlliance) then return end
    if factionB.staticRelationsToPlayers and (factionA.isPlayer or factionA.isAlliance) then return end

    local galaxy = Galaxy()
    local relations = galaxy:getFactionRelations(factionA, factionB)

    if playerFaction and aiFaction then
        onFactionInteraction(aiFaction.index)

        if delta > 0 then
            local maxCap = RelationChangeMaxCap[changeType]
            if maxCap ~= nil then
                delta = hardCapGain(relations, delta, maxCap)
            end
        elseif delta < 0 then
            local minCap = RelationChangeMinCap[changeType]
            if minCap ~= nil then
                delta = hardCapLoss(relations, delta, minCap)
            end
        end

        galaxy:changeFactionRelations(factionA, factionB, delta, notifyA, notifyB)
    end
end

-- Runs server-side to apply inactivity-based decay to player/alliance -> AI relations.
function onUpdate(timeStep)
    if not onServer() then return end

    updateAccumulator = updateAccumulator + (timeStep or 0)
    if updateAccumulator < DecayConfig.updateIntervalSec then return end
    updateAccumulator = 0

    local now = Server().unpausedRuntime
    local galaxy = Galaxy()

    -- Iterate only factions with known interactions, not every faction in the galaxy.
    for aiFactionIndex, lastTime in pairs(lastInteraction) do
        local timeSinceLastInteraction = now - lastTime
        if timeSinceLastInteraction >= DecayConfig.startAfterSec then
            local decayAmount = math.min(
                DecayConfig.baseDecayPerHour + (timeSinceLastInteraction / DecayConfig.increaseIntervalSec) * DecayConfig.increaseAmountPerInterval,
                DecayConfig.maxDecayPerHour
            )

            local players = galaxy:getPlayers() or {}
            for _, player in pairs(players) do
                if player then
                    galaxy:changeFactionRelations(player.index, aiFactionIndex, -decayAmount, false, false)

                    local allianceIndex = player.allianceIndex
                    if allianceIndex then
                        galaxy:changeFactionRelations(allianceIndex, aiFactionIndex, -decayAmount, false, false)
                    end
                end
            end
        end
    end
end
