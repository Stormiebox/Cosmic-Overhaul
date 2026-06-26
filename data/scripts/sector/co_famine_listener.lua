package.path = package.path .. ";data/scripts/lib/?.lua"

local cv_economy = include("cosmicvaulteconomy")

local COFamineListener = {}
COFamineListener.pendingEntities = {}

function COFamineListener.initialize()
    if onServer() then
        Sector():registerCallback("onEntityCreated", "onEntityCreated")
    end
end

function COFamineListener.getUpdateInterval()
    return 1.0 -- run every second
end

function COFamineListener.onEntityCreated(id)
    -- Queue the entity ID to be processed outside of the synchronous generation phase
    table.insert(COFamineListener.pendingEntities, id.string)
end

function COFamineListener.updateServer(timeStep)
    if #COFamineListener.pendingEntities > 0 then
        local count = 0
        while #COFamineListener.pendingEntities > 0 and count < 50 do
            local idString = table.remove(COFamineListener.pendingEntities, 1)
            COFamineListener.processEntity(Uuid(idString))
            count = count + 1
        end
    end
end

function COFamineListener.processEntity(id)
    local entity = Entity(id)
    if not entity then return end
    
    -- Only affect AI Faction Ships (Not players, not Eclipse boss ships)
    if entity.type == EntityType.Ship and entity.factionIndex and entity.factionIndex > 0 then
        local faction = Faction(entity.factionIndex)
        if faction and not faction.isPlayer and not faction.isAlliance and faction.name ~= "The Eclipse" then
            local famineLevel = cv_economy.getFamineLevel(faction.index)
            if famineLevel ~= "Stable" then
                entity:addScriptOnce("data/scripts/entity/co_famine_debuff.lua", famineLevel)
            end
        end
    end
end

function initialize(...)
    if COFamineListener.initialize then return COFamineListener.initialize(...) end
end
function onEntityCreated(...)
    if COFamineListener.onEntityCreated then return COFamineListener.onEntityCreated(...) end
end
function getUpdateInterval(...)
    if COFamineListener.getUpdateInterval then return COFamineListener.getUpdateInterval(...) end
end
function updateServer(...)
    if COFamineListener.updateServer then return COFamineListener.updateServer(...) end
end

return COFamineListener
