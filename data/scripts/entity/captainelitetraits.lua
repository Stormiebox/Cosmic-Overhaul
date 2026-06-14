package.path = package.path .. ";data/scripts/lib/?.lua"
include("utility")
local CaptainClass = include("captainclass")
local CosmicVaultBuffs = nil
pcall(function() CosmicVaultBuffs = require("cosmicvaultbuffs") end)

-- Only runs on server
if not onServer() then return end

local function hasEliteTrait(entity, classType)
    if not entity.isShip and not entity.isStation then return false end
    if not entity.hasCaptain then return false end
    local captain = entity:getCaptain()
    if captain and captain.level >= 3 and captain:hasClass(classType) then
        return true
    end
    return false
end

function getUpdateInterval()
    return 5.0 -- Check every 5 seconds
end

function updateServer(timeStep)
    local entity = Entity()
    if not entity then return end

    -- 1. Commodore Elite Trait: +10% Sector-Wide Shield and Damage
    if hasEliteTrait(entity, CaptainClass.Commodore) then
        if CosmicVaultBuffs then
            local sector = Sector()
            local myFaction = entity.factionIndex
            local ships = {sector:getEntitiesByFaction(myFaction)}
            for _, ship in pairs(ships) do
                if ship.isShip or ship.isStation then
                    -- Apply a 6-second buff so it refreshes continuously while Commodore is present
                    CosmicVaultBuffs.applyBuff(ship.id, "Shields", 1.10, 6.0)
                    CosmicVaultBuffs.applyBuff(ship.id, "Damage", 1.10, 6.0)
                end
            end
        end
    end

    -- 2. Smuggler Elite Trait: Cargo Scan Immunity
    -- We use the native vanilla ignore_inspections value so AI completely ignores the ship
    if hasEliteTrait(entity, CaptainClass.Smuggler) then
        entity:setValue("ignore_inspections", true)
    else
        -- Only remove if it was set by us (we can't easily track who set it, but for our mod this is fine)
        if entity:getValue("ignore_inspections") then
            entity:setValue("ignore_inspections", nil)
        end
    end

    -- 3. Miner Elite Trait: +15% Rich Asteroid Yields
    -- Handled via hook in minecommand / harvest, but we can set a flag here
    if hasEliteTrait(entity, CaptainClass.Miner) then
        entity:setValue("elite_miner_yield", true)
    else
        entity:setValue("elite_miner_yield", nil)
    end
end
