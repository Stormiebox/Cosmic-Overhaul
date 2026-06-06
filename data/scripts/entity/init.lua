local co_old_init = initialize

function initialize(...)
    if co_old_init then co_old_init(...) end

    if onServer() then
        local entity = Entity()
        if not entity then return end

        -- Add shipinfo/fleetstatus to player or alliance owned ships/stations only.
        -- This is the Fleet Ship Status UI data + interaction source.
        if not entity.aiOwned and (entity.isShip or entity.isStation) and entity.playerOrAllianceOwned then
            entity:addScriptOnce("data/scripts/entity/shipinfo.lua")
            entity:addScriptOnce("data/scripts/entity/fleetstatus.lua")
        end

        -- Cosmic Overhaul: Add TrashMan.lua to all ships, stations, and drones you pilot (including Alliance)
        if not entity.aiOwned and (entity.isShip or entity.isStation or entity.isDrone) and (entity.playerOwned or entity.allianceOwned) then
            entity:addScriptOnce("data/scripts/entity/TrashMan.lua")
        end
    end
end
