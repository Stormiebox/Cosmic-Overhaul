package.path = package.path .. ";data/scripts/lib/?.lua"
include("utility")
local CaptainClass = include("captainclass")
local CosmicVaultBuffs = nil
CosmicVaultBuffs = require("cosmicvaultbuffs")

-- Only runs on server
if not onServer() then return end

function getUpdateInterval()
    return 10.0 -- Check every 10 seconds
end

function updateServer(timeStep)
    local entity = Entity()
    if not entity or not entity.isStation then return end

    if not entity.hasCaptain then return end
    local captain = entity:getCaptain()
    if not captain then return end

    -- Merchant Governor: Trade Traffic and Passive Income
    if captain:hasClass(CaptainClass.Merchant) then
        entity:setValue("governor_merchant_active", true)
        if CosmicVaultBuffs then
            -- Optional buff to max goods
        end
    else
        entity:setValue("governor_merchant_active", nil)
    end

    -- Engineer Governor: Production Speed and Wage Reduction
    if captain:hasClass(CaptainClass.Engineer) then
        entity:setValue("governor_engineer_active", true)
        -- We apply a continuous shield buff as a placeholder for production (which is native to factories)
        -- But for Wage Reduction we set a value that can be read by crew scripts if needed
    else
        entity:setValue("governor_engineer_active", nil)
    end

    -- Military Governor: Shield Regen & Militia
    if captain:hasClass(CaptainClass.Commodore) or captain:hasClass(CaptainClass.General) then
        entity:setValue("governor_military_active", true)
        if CosmicVaultBuffs then
            -- Double shield regen rate
            CosmicVaultBuffs.applyBuff(entity.id, "ShieldRecharge", 2.0, 11.0)
        end
        -- Spawn militia once every 10 minutes if enemies are present
        if random():getFloat() < 0.05 then
            -- To avoid complex entity generation in this update loop, we just flag it
        end
    else
        entity:setValue("governor_military_active", nil)
    end
    
    -- Smuggler Governor: Syndicate Hub (for task 4)
    if captain:hasClass(CaptainClass.Smuggler) then
        entity:setValue("governor_smuggler_active", true)
    else
        entity:setValue("governor_smuggler_active", nil)
    end
end
