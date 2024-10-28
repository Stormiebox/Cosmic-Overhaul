package.path = package.path .. ";data/scripts/lib/?.lua"
include("relations")       -- Include the original relations script

local lastInteraction = {} -- Table to store the last interaction time for each faction

-- Function to record the last interaction time for a given faction
local function onFactionInteraction(factionIndex)
    lastInteraction[factionIndex] = Server().unpausedRuntime
end

local cCounter = 0 -- Counter for relation change types
local function c()
    cCounter = cCounter + 1
    return cCounter
end

-- All relation change types. When you want to change relations and the type doesn't fit into any category, use 'nil'.
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

-- Populate RelationChangeNames for each change type
RelationChangeNames = {}
for k, v in pairs(RelationChangeType) do
    RelationChangeNames[v] = k
end

-- Maximum relation change caps for different types of interactions
RelationChangeMaxCap = {
    [RelationChangeType.ServiceUsage] = 45000,
    [RelationChangeType.ResourceTrade] = 45000,
    [RelationChangeType.GoodsTrade] = 65000,
    [RelationChangeType.EquipmentTrade] = 75000,
    [RelationChangeType.WeaponsTrade] = 75000,
    [RelationChangeType.Commerce] = 50000,
    [RelationChangeType.Tribute] = 0,
}

-- Minimum relation change caps for illegal activities
RelationChangeMinCap = {
    [RelationChangeType.Smuggling] = -75000,
    [RelationChangeType.GeneralIllegal] = -75000,
}

-- Decay parameters
local baseDecayRate = 100                 -- Base decay per hour
local maxDecayRate = 3000                 -- Maximum decay
local decayIncreaseInterval = 5 * 60 * 60 -- 5 hours in seconds
local decayIncreaseAmount = 100           -- Decay increase per interval

-- Function to change relations between factions
function changeRelations(a, b, delta, changeType, notifyA, notifyB, chatterer)
    if not delta or delta == 0 then return end

    local a, b, ai, player = getInteractingFactions(a, b)
    if not a or not b then return end
    if a.isAIFaction and b.isAIFaction then return end
    if a.index == b.index then return end
    if a.alwaysAtWar or b.alwaysAtWar then return end
    if a.staticRelationsToAll or b.staticRelationsToAll then return end
    if a.staticRelationsToPlayers and (b.isPlayer or b.isAlliance) then return end
    if b.staticRelationsToPlayers and (a.isPlayer or a.isAlliance) then return end

    local galaxy = Galaxy()
    local relations = galaxy:getFactionRelations(a, b)
    local status = galaxy:getFactionRelationStatus(a, b)
    local newStatus

    -- Call onFactionInteraction to reset decay timer for the interacting faction
    if player and ai then
        onFactionInteraction(b.index)

        -- Existing logic for changing relations...
        local uncappedDelta = delta
        if delta > 0 then
            delta = hardCapGain(relations, delta, RelationChangeMaxCap[changeType])
        elseif delta < 0 then
            delta = hardCapLoss(relations, delta, RelationChangeMinCap[changeType])
        end

        -- Apply relation changes and check for status changes...
        galaxy:changeFactionRelations(a, b, delta, notifyA, notifyB)

        -- Handle status changes...
        if newStatus and newStatus ~= status then
            setRelationStatus(a, b, newStatus, notifyA, notifyB)
        end
    end
end

-- Decay management logic
function onUpdate()
    local galaxy = Galaxy()
    local factions = galaxy:getAllFactions()

    for _, faction in pairs(factions) do
        if faction.isAIFaction then
            local relations = galaxy:getFactionRelations(faction.index, faction.index)

            -- Check for player interactions
            if lastInteraction[faction.index] then
                local timeSinceLastInteraction = Server().unpausedRuntime - lastInteraction[faction.index]

                -- If the player has not interacted for a while, start the decay process
                if timeSinceLastInteraction >= 3600 then -- 1 hour in seconds
                    local decayAmount = math.min(
                    baseDecayRate + (timeSinceLastInteraction / decayIncreaseInterval) * decayIncreaseAmount,
                        maxDecayRate)
                    galaxy:changeFactionRelations(faction.index, faction.index, -decayAmount, false, false)
                end
            end
        end
    end
end
