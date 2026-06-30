package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

local co_famine_level = ""

function initialize(famineLevel)
    co_famine_level = famineLevel or "Struggling"
    
    if onServer() then
        applyDebuffs()
    end
end

function applyDebuffs()
    local entity = Entity()
    entity:removeScriptBonuses()
    
    if co_famine_level == "Severe Famine" then
        entity:addBaseMultiplier(StatsBonuses.ShieldDurability, -0.6) -- 60% weaker shields
        entity:addBaseMultiplier(StatsBonuses.Velocity, -0.4) -- 40% slower
    elseif co_famine_level == "Resource Starved" then
        entity:addBaseMultiplier(StatsBonuses.ShieldDurability, -0.5) -- 50% weaker shields
        entity:addBaseMultiplier(StatsBonuses.Velocity, -0.25) -- 25% slower
    elseif co_famine_level == "Struggling" then
        entity:addBaseMultiplier(StatsBonuses.ShieldDurability, -0.2) -- 20% weaker shields
    end
end

function secure()
    return { level = co_famine_level }
end

function restore(data)
    co_famine_level = data.level
    if onServer() then
        applyDebuffs()
    end
end
