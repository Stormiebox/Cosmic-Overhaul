if onServer() then
    local entity = Entity()
    if not entity then
        return
    end

    -- Add shipinfo/fleetstatus to player or alliance owned ships/stations only.
    -- This is the Fleet Ship Status UI data + interaction source.
    if not entity.aiOwned and (entity.isShip or entity.isStation) and entity.playerOrAllianceOwned then
        entity:addScriptOnce("data/scripts/entity/shipinfo.lua")
        entity:addScriptOnce("data/scripts/entity/fleetstatus.lua")
    end

    -- Add TrashMan.lua only to player-owned ships & stations.
    -- Avoid attaching to every non-AI entity in sector creation to reduce script index drift/noise.
    if not entity.aiOwned and (entity.isShip or entity.isStation) and entity.playerOwned then
        entity:addScriptOnce("data/scripts/entity/TrashMan.lua")
    end
end
