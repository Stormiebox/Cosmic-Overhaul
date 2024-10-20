if onServer() then
    local entity = Entity()

    -- Add shipinfo.lua to ships
    if not entity.aiOwned and entity.isShip then
        entity:addScriptOnce("data/scripts/entity/shipinfo.lua")
    end

    -- Add TrashMan.lua to drones, ships, and stations
    if (entity.isDrone or entity.isShip or entity.isStation) and not entity.aiOwned then
        entity:addScriptOnce("data/scripts/entity/TrashMan.lua")
    end
end
