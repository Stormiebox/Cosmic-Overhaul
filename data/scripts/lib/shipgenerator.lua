-- Cosmic Overhaul: ShipGenerator Append
-- Injects CosmicVaultData tags into all vanilla generated ships

include("cosmicvaultdata")

local over_oldCreateMilitaryShip = ShipGenerator.createMilitaryShip
ShipGenerator.createMilitaryShip = function(faction, position, volume)
    local ship = over_oldCreateMilitaryShip(faction, position, volume)
    if valid(ship) and CosmicVaultData then
        CosmicVaultData.AddTag(ship, "Military")
    end
    return ship
end

local over_oldCreateDefender = ShipGenerator.createDefender
ShipGenerator.createDefender = function(faction, position)
    local ship = over_oldCreateDefender(faction, position)
    if valid(ship) and CosmicVaultData then
        CosmicVaultData.AddTag(ship, "Military")
    end
    return ship
end

local over_oldCreateCarrier = ShipGenerator.createCarrier
ShipGenerator.createCarrier = function(faction, position, fighters)
    local ship = over_oldCreateCarrier(faction, position, fighters)
    if valid(ship) and CosmicVaultData then
        CosmicVaultData.AddTag(ship, "Military")
    end
    return ship
end

local over_oldCreateTradingShip = ShipGenerator.createTradingShip
ShipGenerator.createTradingShip = function(faction, position, volume)
    local ship = over_oldCreateTradingShip(faction, position, volume)
    if valid(ship) and CosmicVaultData then
        CosmicVaultData.AddTag(ship, "Trader")
    end
    return ship
end

local over_oldCreateFreighterShip = ShipGenerator.createFreighterShip
ShipGenerator.createFreighterShip = function(faction, position, volume)
    local ship = over_oldCreateFreighterShip(faction, position, volume)
    if valid(ship) and CosmicVaultData then
        CosmicVaultData.AddTag(ship, "Trader")
    end
    return ship
end

local over_oldCreateMiningShip = ShipGenerator.createMiningShip
ShipGenerator.createMiningShip = function(faction, position, volume)
    local ship = over_oldCreateMiningShip(faction, position, volume)
    if valid(ship) and CosmicVaultData then
        CosmicVaultData.AddTag(ship, "Scavenger")
    end
    return ship
end

-- [Cosmic Overhaul] Append ends here. Vanilla already returns ShipGenerator above.
