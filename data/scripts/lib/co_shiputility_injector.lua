package.path = package.path .. ";data/scripts/lib/?.lua"
local ShipUtility = include("shiputility")

local CO_ShipUtilityInjector = {}

function CO_ShipUtilityInjector.inject()
    -- Prevent double-injection if called multiple times in the same Virtual Machine
    if ShipUtility._co_injected then return end
    ShipUtility._co_injected = true

    -- Cosmic Overhaul: Cached tables for massive performance gains during sector generation
    local militaryMaxVolumes = { 128, 320, 800, 2000, 5000, 12500, 19764, 31250, 49411, 78125, 123526, 195312 }
    local civilMaxVolumes = { 163, 183, 232, 356, 664, 1435, 2182, 3363, 5230, 8182, 12850, 20230 }

    ShipUtility.getMilitaryMaxVolumes = function() return militaryMaxVolumes end
    ShipUtility.getCivilMaxVolumes = function() return civilMaxVolumes end

    ShipUtility.getMilitaryShipSizeIndex = function(volume, maxindex)
        for i = 1, #militaryMaxVolumes do
            if volume < militaryMaxVolumes[i] then return math.min(i, maxindex) end
        end
        return math.min(#militaryMaxVolumes + 1, maxindex)
    end

    ShipUtility.getCivilShipSizeIndex = function(volume, maxindex)
        for i = 1, #civilMaxVolumes do
            if volume < civilMaxVolumes[i] then return math.min(i, maxindex) end
        end
        return math.min(#civilMaxVolumes + 1, maxindex)
    end

    ShipUtility.getMinerNameByVolume = function(volume)
        local names = {
            {name = "Light Prospector /* ship title */"%_T, type = ShipUtility.MinerShipTypes.LightMiner},
            {name = "Prospector /* ship title */"%_T, type = ShipUtility.MinerShipTypes.LightMiner},
            {name = "Heavy Prospector /* ship title */"%_T, type = ShipUtility.MinerShipTypes.Miner},
            {name = "Light Miner /* ship title */"%_T, type = ShipUtility.MinerShipTypes.Miner},
            {name = "Medium Miner /* ship title */"%_T, type = ShipUtility.MinerShipTypes.Miner},
            {name = "Heavy Miner /* ship title */"%_T, type = ShipUtility.MinerShipTypes.HeavyMiner},
            {name = "Mining Barge /* ship title */"%_T, type = ShipUtility.MinerShipTypes.HeavyMiner},
            {name = "Heavy Mining Barge /* ship title */"%_T, type = ShipUtility.MinerShipTypes.MiningMoloch},
            {name = "Extraction Vessel /* ship title */"%_T, type = ShipUtility.MinerShipTypes.MiningMoloch},
            {name = "Heavy Extraction Vessel /* ship title */"%_T, type = ShipUtility.MinerShipTypes.MiningMoloch},
            {name = "Asteroid Crusher /* ship title */"%_T, type = ShipUtility.MinerShipTypes.MiningMoloch},
            {name = "Planet Cracker /* ship title */"%_T, type = ShipUtility.MinerShipTypes.MiningMoloch},
            {name = "Mining Moloch /* ship title */"%_T, type = ShipUtility.MinerShipTypes.MiningMoloch},
        }
        local size = ShipUtility.getCivilShipSizeIndex(volume, #names)
        return names[size].name, names[size].type
    end

    ShipUtility.getFreighterNameByVolume = function(volume)
        local names = {
            {name = "Cargo Shuttle /* ship title */"%_T, type = ShipUtility.FreighterShipTypes.Loader},
            {name = "Light Loader /* ship title */"%_T, type = ShipUtility.FreighterShipTypes.Loader},
            {name = "Heavy Loader /* ship title */"%_T, type = ShipUtility.FreighterShipTypes.Transporter},
            {name = "Light Transporter /* ship title */"%_T, type = ShipUtility.FreighterShipTypes.Transporter},
            {name = "Transporter /* ship title */"%_T, type = ShipUtility.FreighterShipTypes.Lifter},
            {name = "Heavy Transporter /* ship title */"%_T, type = ShipUtility.FreighterShipTypes.Lifter},
            {name = "Light Freighter /* ship title */"%_T, type = ShipUtility.FreighterShipTypes.CargoTransport},
            {name = "Freighter /* ship title */"%_T, type = ShipUtility.FreighterShipTypes.Freighter},
            {name = "Heavy Freighter /* ship title */"%_T, type = ShipUtility.FreighterShipTypes.Freighter},
            {name = "Cargo Hauler /* ship title */"%_T, type = ShipUtility.FreighterShipTypes.CargoHauler},
            {name = "Heavy Cargo Hauler /* ship title */"%_T, type = ShipUtility.FreighterShipTypes.CargoHauler},
            {name = "Superfreighter /* ship title */"%_T, type = ShipUtility.FreighterShipTypes.HeavyCargoHauler},
            {name = "Logistics Leviathan /* ship title */"%_T, type = ShipUtility.FreighterShipTypes.HeavyCargoHauler},
        }
        local size = ShipUtility.getCivilShipSizeIndex(volume, #names)
        return names[size].name, names[size].type
    end

    ShipUtility.getTraderNameByVolume = function(volume)
        local names = {
            {name = "Light Courier /* ship title */"%_T, type = ShipUtility.TraderShipTypes.Trader},
            {name = "Courier /* ship title */"%_T, type = ShipUtility.TraderShipTypes.Trader},
            {name = "Heavy Courier /* ship title */"%_T, type = ShipUtility.TraderShipTypes.Trader},
            {name = "Trade Vessel /* ship title */"%_T, type = ShipUtility.TraderShipTypes.Trader},
            {name = "Merchant Vessel /* ship title */"%_T, type = ShipUtility.TraderShipTypes.Merchant},
            {name = "Heavy Merchant Vessel /* ship title */"%_T, type = ShipUtility.TraderShipTypes.Merchant},
            {name = "Commerce Ship /* ship title */"%_T, type = ShipUtility.TraderShipTypes.Merchant},
            {name = "Heavy Commerce Ship /* ship title */"%_T, type = ShipUtility.TraderShipTypes.Merchant},
            {name = "Trade Galleon /* ship title */"%_T, type = ShipUtility.TraderShipTypes.Salesman},
            {name = "Exchange Hub /* ship title */"%_T, type = ShipUtility.TraderShipTypes.Salesman},
            {name = "Grand Exchange /* ship title */"%_T, type = ShipUtility.TraderShipTypes.Salesman},
            {name = "Commercial Colossus /* ship title */"%_T, type = ShipUtility.TraderShipTypes.Salesman},
            {name = "Trade Leviathan /* ship title */"%_T, type = ShipUtility.TraderShipTypes.Salesman},
        }
        local size = ShipUtility.getCivilShipSizeIndex(volume, #names)
        return names[size].name, names[size].type
    end

    ShipUtility.getMilitaryNameByVolume = function(volume)
        local names = {
            {name = "Interceptor /* ship title */"%_T, type = ShipUtility.MilitaryShipTypes.Scout},
            {name = "Scout /* ship title */"%_T, type = ShipUtility.MilitaryShipTypes.Sentinel},
            {name = "Corvette /* ship title */"%_T, type = ShipUtility.MilitaryShipTypes.Corvette},
            {name = "Frigate /* ship title */"%_T, type = ShipUtility.MilitaryShipTypes.Frigate},
            {name = "Destroyer /* ship title */"%_T, type = ShipUtility.MilitaryShipTypes.Destroyer},
            {name = "Cruiser /* ship title */"%_T, type = ShipUtility.MilitaryShipTypes.Cruiser},
            {name = "Heavy Cruiser /* ship title */"%_T, type = ShipUtility.MilitaryShipTypes.Cruiser},
            {name = "Battlecruiser /* ship title */"%_T, type = ShipUtility.MilitaryShipTypes.Battleship},
            {name = "Battleship /* ship title */"%_T, type = ShipUtility.MilitaryShipTypes.Battleship},
            {name = "Dreadnought /* ship title */"%_T, type = ShipUtility.MilitaryShipTypes.Dreadnought},
            {name = "Juggernaut /* ship title */"%_T, type = ShipUtility.MilitaryShipTypes.Dreadnought},
            {name = "Titan /* ship title */"%_T, type = ShipUtility.MilitaryShipTypes.Dreadnought},
            {name = "Leviathan /* ship title */"%_T, type = ShipUtility.MilitaryShipTypes.Dreadnought},
        }
        local size = ShipUtility.getMilitaryShipSizeIndex(volume, #names)
        return names[size].name, names[size].type
    end

    -- Cosmic Overhaul: Piracy Economy Buff
    -- Overrides the default illegal cargo generation to make piracy highly lucrative!
    ShipUtility.addIllegalCargoToCraft = function(entity)
        local g = illegalSpawnableGoods[getInt(1, #illegalSpawnableGoods)]

        local x, y = Sector():getCoordinates()
        -- Cosmic Overhaul: Massive boost to illegal cargo dropped by destroyed civil ships to encourage piracy!
        local maxValue = Balancing_GetSectorRichnessFactor(x, y) * 250000

        local maxAmount = maxValue / g.price
        local amount = 1000 + math.random() * 100
        amount = math.ceil(math.min(maxAmount, amount))

        entity:addCargo(g:good(), amount)
    end
end

return CO_ShipUtilityInjector