package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

local co_famine_level = ""

function initialize(famineLevel)
    co_famine_level = famineLevel or "Struggling"
    
    if onServer() then
        local entity = Entity()
        local _k = entity:addMultiplyableBias(StatsBonuses.ShieldDurability, 0)
        entity:removeBonus(_k)
    end
end

function onBaseMultiplierCalculated(entity, statModifier)
    if co_famine_level == "Severe Famine" then
        statModifier:addBaseMultiplier(StatsBonuses.ShieldDurability, 0.4) -- 60% weaker shields
        statModifier:addBaseMultiplier(StatsBonuses.Velocity, 0.6) -- 40% slower
    elseif co_famine_level == "Resource Starved" then
        statModifier:addBaseMultiplier(StatsBonuses.ShieldDurability, 0.5) -- 50% weaker shields
        statModifier:addBaseMultiplier(StatsBonuses.Velocity, 0.75) -- 25% slower
    elseif co_famine_level == "Struggling" then
        statModifier:addBaseMultiplier(StatsBonuses.ShieldDurability, 0.8) -- 20% weaker shields
    end
end

function secure()
    return { level = co_famine_level }
end

function restore(data)
    co_famine_level = data.level
    local entity = Entity()
    local _k = entity:addMultiplyableBias(StatsBonuses.ShieldDurability, 0)
    entity:removeBonus(_k)
end
