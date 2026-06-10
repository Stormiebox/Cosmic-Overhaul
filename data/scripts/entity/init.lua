if onServer() then
    local entity = Entity()
    if not entity then return end

    if not entity.aiOwned and (entity.isShip or entity.isStation) and entity.playerOrAllianceOwned then
        entity:addScriptOnce("data/scripts/entity/fleetstatus.lua")
    end

    if not entity.aiOwned and (entity.isShip or entity.isStation or entity.isDrone) and (entity.playerOwned or entity.allianceOwned) then
        entity:addScriptOnce("data/scripts/entity/TrashMan.lua")
    end
end
