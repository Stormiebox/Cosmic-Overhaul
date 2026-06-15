package.path = package.path .. ";data/scripts/lib/?.lua"
include("relations") -- Include and extend vanilla relations behavior.

-- Cosmic Overhaul: Dynamic Reputation Decay Namespace
DynamicReputationDecay = {}

-- Configuration with explicit units for readability.
local DecayConfig = {
    baseDecayPerHour = 100,
    maxDecayPerHour = 3000,
    increaseIntervalSec = 5*60*60,     -- 5 hours
    increaseAmountPerInterval = 100,
    startAfterSec = 60*60,             -- 1 hour inactivity
    updateIntervalSec = 60,            -- Throttle to once a minute for optimal server performance
}

-- Cosmic Overhaul: Safely inject custom enums without destroying the vanilla table!
local function injectRelationEnum(name)
    if not RelationChangeType[name] then
        local max = 0
        for _, v in pairs(RelationChangeType) do
            if type(v) == "number" and v > max then max = v end
        end
        RelationChangeType[name] = max+1
        RelationChangeNames[max+1] = name
    end
end

injectRelationEnum("Smuggling")
injectRelationEnum("Raiding")
injectRelationEnum("GeneralIllegal")
injectRelationEnum("ServiceUsage")
injectRelationEnum("ResourceTrade")
injectRelationEnum("GoodsTrade")
injectRelationEnum("EquipmentTrade")
injectRelationEnum("WeaponsTrade")
injectRelationEnum("Commerce")
injectRelationEnum("Tribute")

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

-- Cosmic Overhaul: Non-Destructive Hook!
-- We save the vanilla function so we don't break trait processing, alliance syncing, or notifications.
-- Since the previous version of this, did exactly just that. Yikes!
local co_vanilla_changeRelations = changeRelations
function changeRelations(a, b, delta, changeType, notifyA, notifyB, chatterer)
    if not delta or delta == 0 then return end

    local factionA, factionB, aiFaction, playerFaction = getInteractingFactions(a, b)

    if playerFaction and aiFaction then
        -- 1. Persistent State Tracking (Fixes Lua VM Isolation bug)
        -- Save the timestamp to the Player/Alliance database so it survives server restarts and sector jumps
        if playerFaction.isPlayer or playerFaction.isAlliance then
            Player(playerFaction.index):setValue("co_rep_interact_" .. aiFaction.index, Server().unpausedRuntime)
        elseif playerFaction.isAlliance then
            Alliance(playerFaction.index):setValue("co_rep_interact_" .. aiFaction.index, Server().unpausedRuntime)
        end

        -- 2. Apply Custom Hard Caps before passing to Vanilla
        local galaxy = Galaxy()
        local relations = galaxy:getFactionRelations(factionA, factionB)

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
    end

    -- 3. Pass the capped delta back to the Vanilla function
    if co_vanilla_changeRelations then
        co_vanilla_changeRelations(a, b, delta, changeType, notifyA, notifyB, chatterer)
    end
end

-- =========================================================================
-- Background Decay Loop (Attached to the Player via player/init.lua)
-- =========================================================================

function DynamicReputationDecay.getUpdateInterval()
    return DecayConfig.updateIntervalSec
end

local function processDecayForEntity(entity, factionStr, now, galaxy)
    local cv_task_success, cv_task = true, include("cosmicvaulttask")
    local iters = 0
    for idStr in string.gmatch(factionStr, "([^,]+)") do
        iters = iters + 1
        if cv_task_success and cv_task and cv_task.Yield and (iters % 10 == 0) then
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

    local cv_task_success, cv_task = true, include("cosmicvaulttask")
    if cv_task_success and cv_task and cv_task.RunAsync then
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
