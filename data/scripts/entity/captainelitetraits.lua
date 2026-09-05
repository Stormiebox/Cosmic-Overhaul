package.path = package.path .. ";data/scripts/lib/?.lua"
include("utility")
local CaptainClass = include("captainclass")
local CosmicVaultBuffs = nil
CosmicVaultBuffs = include("cosmicvaultbuffs")

-- Only runs on server
if not onServer() then return end

local function hasEliteTrait(entity, classType)
    if not entity.isShip and not entity.isStation then return false end
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
                    -- Try to refresh existing buffs, otherwise apply new ones
                    -- CosmicVaultBuffs.applyBuff's multiplier is a SCALE factor (cosmicbuff.lua
                    -- converts it to an addBaseMultiplier delta via multiplier - 1.0, matching the
                    -- engine's own "a factor of 0.3 becomes 1.3" semantics for addBaseMultiplier) --
                    -- 1.10 for +10%, not 0.10. Passing 0.10 previously computed a delta of -0.9,
                    -- silently applying a -90% Shield/FireRate penalty instead of the advertised
                    -- +10% Commodore bonus.
                    local shieldRefreshed = CosmicVaultBuffs.refreshBuff(ship.id, "CommodoreShield")
                    if not shieldRefreshed then
                        CosmicVaultBuffs.applyBuff(ship.id, "Shield", 1.10, 6.0, "CommodoreShield")
                    end

                    local fireRateRefreshed = CosmicVaultBuffs.refreshBuff(ship.id, "CommodoreFireRate")
                    if not fireRateRefreshed then
                        CosmicVaultBuffs.applyBuff(ship.id, "FireRate", 1.10, 6.0, "CommodoreFireRate")
                    end
                end
            end
        end
    end

    -- 2. Smuggler Elite Trait: Cargo Scan Immunity
    -- We use the native vanilla ignore_inspections value so AI completely ignores the ship
    if hasEliteTrait(entity, CaptainClass.Smuggler) then
        entity:setValue("ignore_inspections", true)

        -- Smuggler Deflation
        local cv_eco = include("cosmicvaulteconomy")
        if cv_eco then
            local cx, cy = Sector():getCoordinates()
            local faction = Galaxy():getControllingFaction(cx, cy)
            if faction then
                cv_eco.addFamineScore(faction.index, -0.1)
            end
        end
    else
        -- Only remove if it was set by us (we can't easily track who set it, but for our mod this is fine)
        if entity:getValue("ignore_inspections") then
            entity:setValue("ignore_inspections", nil)
        end
    end

    -- 3. Miner Elite Trait: this flag was set here but never read anywhere in the workspace --
    -- confirmed dead (grepped for "elite_miner_yield" workspace-wide, only writer, no reader).
    -- The real Elite Miner bonus already exists, correctly working, in minecommand.lua's own
    -- MineCommand:getAreaSize (+25 mining area at captain level 3+) and MineCommand:calculatePrediction
    -- (Mining Captain Hazard Pay: 25% chance of a +10% yield event). Removed the orphaned flag
    -- rather than wire it to a second, redundant bonus mechanism.

    -- 4. Scavenger Elite Trait: +50% Salvage Yield in Contested/Siege Zones. This used to route
    -- through CosmicVaultBuffs.applyBuff("SalvageYield", ...) -- "SalvageYield" was never one of
    -- cosmicbuff.lua's handled stat names (no native StatsBonuses enum for salvage yield exists
    -- either), so the buff silently did nothing, every time, since this was written. Moved to a
    -- real fix in salvagecommand.lua's own SalvageCommand:calculatePrediction override, which
    -- multiplies the predicted resource yield directly -- the same hookable mechanism
    -- minecommand.lua's own Mining Captain Hazard Pay bonus already uses successfully.
end
