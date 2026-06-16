local CosmicOverhaul_old_init = initialize

local cv_economy = include("cosmicvaulteconomy")


function initialize(...)
    if CosmicOverhaul_old_init then CosmicOverhaul_old_init(...) end
    print("[CosmicOverhaul] server.lua initialized! Attaching co_weather_generator.lua")
    Galaxy():addScriptOnce("galaxy/co_weather_generator.lua")
    
    -- Register to catch when new ships are spawned to apply Famine debuffs
    Galaxy():registerCallback("onEntityCreated", "onEntityCreated")
end

function onEntityCreated(id)
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

