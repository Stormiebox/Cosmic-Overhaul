if onServer() then
    local entity = Entity()
    if not entity then
        return
    end

    -- Add shipinfo.lua to ships
    if not entity.aiOwned and entity.isShip then
        entity:addScriptOnce("data/scripts/entity/shipinfo.lua")
    end

    -- Add TrashMan.lua only to player-owned ships & stations.
    -- Avoid attaching to every non-AI entity in sector creation to reduce script index drift/noise.
    if not entity.aiOwned and (entity.isShip or entity.isStation) and entity.playerOwned then
        entity:addScriptOnce("data/scripts/entity/TrashMan.lua")
    end
end
