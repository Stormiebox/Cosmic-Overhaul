package.path = package.path .. ";data/scripts/lib/?.lua"

include("stringutility")
include("randomext")
include("callable")
include("playerstationutils")
local CosmicOverhaulConfig = include("cosmicoverhaulconfig")
-- Cosmic Overhaul: Use pcall(include) to respect Avorion's VFS and Highlander rules
local cw_success = pcall(include, "cosmicwarbridge")
local UpgradeGenerator = include("upgradegenerator")()
local TurretGenerator = include("sectorturretgenerator")()

-- namespace ManageStationIncomes
ManageStationIncomes = {}
if not onServer() then return end
local stationMappings

function ManageStationIncomes.initialize()
    local sector = Sector()
    sector:registerCallback("onTradeSuccess", "onTradeSuccess")
end

function ManageStationIncomes.getWarHeatMultiplier()
    local heat = 0
    if cw_success and type(CosmicWarBridge) == "table" and CosmicWarBridge.getFactionWarHeat then
        local sector = Sector()
        local factions = { sector:getPresentFactions() }
        for _, f_idx in pairs(factions) do
            local f = Faction(f_idx)
            if f and f.isAIFaction then
                heat = math.max(heat, CosmicWarBridge.getFactionWarHeat(f.index) or 0)
            end
        end
    end
    -- Income is reduced as heat increases. At max heat (1.0), income is only 20%.
    -- TODO: Keep testing to ensure it integrates properly or if values need to be increased/decreased accordingly.
    return 1.0-(heat*0.8)
end

function ManageStationIncomes.onTradeSuccess(stationId, buyerId)
    local station = Entity(stationId)
    local buyer = Entity(buyerId)
    local mapping = ManageStationIncomes.getMapping(station)
    if not (station and buyer and mapping) then return end
    mapping.giveFunction(station, buyer)
end

function ManageStationIncomes.getUpdateInterval()
    local cfg = CosmicOverhaulConfig and CosmicOverhaulConfig.get and CosmicOverhaulConfig.get() or {}
    return cfg.profitableStationsInterval or 120
end

function ManageStationIncomes.isStationReserved(station)
    local ents = { Sector():getEntitiesByScript("merchants/playerstationtrader.lua") }
    if not ents or #ents == 0 then return false end
    for _, ent in pairs(ents) do
        if ent:getValue("plystation_partner") == station.id.string then return true end
    end
    return false
end

function ManageStationIncomes.getMapping(station)
    return stationMappings[station.title%_t]
end

function ManageStationIncomes.giveStationResources(station, _seller)
    local faction = Faction(station.factionIndex)
    local amounts = ManageStationIncomes.getResourceIncome()
    local mapping = ManageStationIncomes.getMapping(station)
    local cfg = CosmicOverhaulConfig and CosmicOverhaulConfig.get and CosmicOverhaulConfig.get() or {}
    local payoutMult = cfg.profitableStationsPayoutMultiplier or 1.0

    if not faction then return end

    for i = 1, NumMaterials() do
        local amount = math.floor(amounts[i] or 0)
        local mat = Material(i-1)
        amount = math.floor(amount*mapping.quantity)
        amount = math.floor(amount*payoutMult)
        if amount > 0 then
            local amountStr = createMonetaryString(amount) .. " " .. mat.name
            local msg = mapping.giveMsg%{ amount = amountStr, station = station.name }
            -- Cosmic Overhaul: Safely route resources through the standard receive() API
            local args = { 0, 0, 0, 0, 0, 0, 0 }
            args[i] = amount
            faction:receive(msg, 0, unpack(args))
        end
    end
end

function ManageStationIncomes.giveStationSystem(station, _seller)
    local sector = Sector()
    local x, y = sector:getCoordinates()
    local system = UpgradeGenerator:generateSectorSystem(x, y)
    local mapping = ManageStationIncomes.getMapping(station)

    local faction = Faction(station.factionIndex)
    local inv = faction:getInventory()
    local msg = mapping.giveMsg%{ amount = "a system"%_T, station = station.name }

    inv:addOrDrop(system)
    faction:sendChatMessage(station, ChatMessageType.Economy, msg)
end

function ManageStationIncomes.giveStationTurret(station, _seller, weapontype)
    local sector = Sector()
    local x, y = sector:getCoordinates()
    local mapping = ManageStationIncomes.getMapping(station)

    local turret = InventoryTurret(TurretGenerator:generate(x, y))
    local faction = Faction(station.factionIndex)
    local inv = faction:getInventory()
    local msg = mapping.giveMsg%{ amount = "a turret"%_T, station = station.name }

    inv:addOrDrop(turret)
    faction:sendChatMessage(station, ChatMessageType.Economy, msg)
end

function ManageStationIncomes.giveStationMoney(station, _seller)
    local faction = Faction(station.factionIndex)
    local mapping = ManageStationIncomes.getMapping(station)
    local cfg = CosmicOverhaulConfig and CosmicOverhaulConfig.get and CosmicOverhaulConfig.get() or {}
    local payoutMult = cfg.profitableStationsPayoutMultiplier or 1.0
    if not faction then return end

    -- Cosmic Overhaul Balance tweak: Reduced base payout from 16k to 8k
    local money = math.floor((0.3+(2*math.random()/3))*8000)
    if math.random() < 0.2 then money = money*2 end
    money = math.floor(money*mapping.quantity)
    money = money*ManageStationIncomes.getWarHeatMultiplier()
    money = math.floor(money*payoutMult)

    local amountStr = "${c}${money}"%_T%{ c = credits(), money = createMonetaryString(money) }
    local msg = mapping.giveMsg%{ amount = amountStr, station = station.name }
    faction:receive(msg, money)
end

function ManageStationIncomes.giveStationDistribution(moneyChance, resourceChance, systemChance, turretChance)
    local totalChance = moneyChance+resourceChance+systemChance+turretChance
    local resultFunc = function(station, _seller)
        local choice = random():getFloat(0, totalChance)
        if choice < moneyChance then
            ManageStationIncomes.giveStationMoney(station, _seller)
        elseif choice < moneyChance+resourceChance then
            ManageStationIncomes.giveStationResources(station, _seller)
        elseif choice < moneyChance+resourceChance+systemChance then
            ManageStationIncomes.giveStationSystem(station, _seller)
        elseif choice < moneyChance+resourceChance+systemChance+turretChance then
            ManageStationIncomes.giveStationTurret(station, _seller)
        end
    end
    return resultFunc
end

function ManageStationIncomes.getResourceIncome()
    local x, y = Sector():getCoordinates()
    local probabilities = Balancing_GetMaterialProbability(x, y)
    local richness = Balancing_GetSectorRichnessFactor(x, y, 1)
    local cfg = CosmicOverhaulConfig and CosmicOverhaulConfig.get and CosmicOverhaulConfig.get() or {}
    local payoutMult = cfg.profitableStationsPayoutMultiplier or 1.0

    local amounts = {}

    for i = 1, NumMaterials() do
        local probFactor = math.max(0, probabilities[i-1])
        local mats = 0
        if probFactor > 0.05 then
            local matRichness = math.max(probFactor*(richness), 0.2)
            -- Cosmic Overhaul Balance tweak: Reduced from 8000 base to 3500 base
            mats = (0.5+math.random()/2)*3500
            mats = mats*matRichness
            mats = mats*ManageStationIncomes.getWarHeatMultiplier()
            mats = mats*payoutMult
            if random():test(0.2) then
                mats = mats*2
                if random():test(0.1) then mats = mats*2 end
            end
        end
        amounts[i] = mats
    end
    return amounts
end

function ManageStationIncomes.manageStation(station)
    local mapping = ManageStationIncomes.getMapping(station)
    if not mapping then return end
    if random():test(mapping.chance) then return end

    local isInstant = ManageStationIncomes.isInstantTrade()
    if isInstant then
        mapping.giveFunction(station)
        return
    end

    local isReserved = ManageStationIncomes.isStationReserved(station)
    if not isReserved then
        PlayerStationUtils.spawnTraderFor(ManageStationIncomes, station, mapping.traderTypes)
    end
end

function ManageStationIncomes.isSectorTradeable()
    local sector = Sector()
    -- Cosmic War & Hazard Synergy: Trading stops entirely in warzones and blocked areas.
    if sector:getValue("war_zone") or sector:getValue("hazard_zone") or sector:getValue("no_trade_zone") then return false end
    return true
end

function ManageStationIncomes.isInstantTrade()
    return Sector().numPlayers == 0
end

function ManageStationIncomes.updateServer(timeStep)
    local cfg = CosmicOverhaulConfig and CosmicOverhaulConfig.get and CosmicOverhaulConfig.get() or {}
    if cfg.enableProfitableStations == false then return end

    if not ManageStationIncomes.isSectorTradeable() then return end
    local stations = { Sector():getEntitiesByType(EntityType.Station) }
    for _, station in pairs(stations) do
        local faction = Faction(station.factionIndex)
        if faction and (faction.isPlayer or faction.isAlliance) then
            ManageStationIncomes.manageStation(station)
        end
    end
end

stationMappings = {
    ["Resource Depot"%_t] = {
        giveFunction = ManageStationIncomes.giveStationResources,
        giveMsg = "Earned ${amount} in taxes from Resource Depot ${station}."%_T,
        chance = 0.5,
        quantity = 1.0,
        traderTypes = { "freighter" },
    },
    ["Smuggler's Market"%_t] = {
        giveFunction = ManageStationIncomes.giveStationMoney,
        giveMsg = "Received ${amount} in unbranding fees from Smuggler's Market ${station}."%_T,
        chance = 0.6,
        quantity = 1.25,
        traderTypes = { "freighter", "trader", "military" }
    },
    ["Casino"%_t] = {
        giveFunction = ManageStationIncomes.giveStationMoney,
        giveMsg = "Received ${amount} in gambling income from Casino ${station}."%_T,
        chance = 0.7,
        quantity = 1.5,
        traderTypes = { "freighter", "trader", "military" }
    },
    ["Repair Dock"%_t] = {
        giveFunction = ManageStationIncomes.giveStationMoney,
        giveMsg = "Received ${amount} in repair fees from Repair Dock ${station}."%_T,
        chance = 0.2,
        quantity = 3.0,
        traderTypes = { "freighter", "trader", "military" }
    },
    ["Shipyard"%_t] = {
        giveFunction = ManageStationIncomes.giveStationMoney,
        giveMsg = "Received ${amount} in repair fees from Shipyard ${station}."%_T,
        chance = 0.3,
        quantity = 2.3,
        traderTypes = { "freighter", "trader", "military" }
    },
    ["Travel Hub"%_t] = {
        giveFunction = ManageStationIncomes.giveStationMoney,
        giveMsg = "Gained ${amount} in travel fees from Travel Hub ${station}."%_T,
        chance = 0.3,
        quantity = 2.3,
        traderTypes = { "freighter", "trader", "military", "torpedo" }
    },
    ["Equipment Dock"%_t] = {
        giveFunction = ManageStationIncomes.giveStationDistribution(0.1, 0.0, 0.7, 0.2),
        giveMsg = "Received ${amount} in taxes from Equipment Dock ${station}."%_T,
        chance = 0.4,
        quantity = 1.0,
        traderTypes = { "military", "torpedo", "freighter", "trader" }
    },
    ["Research Station"%_t] = {
        giveFunction = ManageStationIncomes.giveStationDistribution(0.0, 0.0, 0.8, 0.2),
        giveMsg = "Received ${amount} in taxes from Research Station ${station}."%_T,
        chance = 0.4,
        quantity = 1.0,
        traderTypes = { "freighter", "trader", "military", "torpedo" }
    },
    ["Military Outpost"%_t] = {
        giveFunction = ManageStationIncomes.giveStationDistribution(0.0, 0.0, 0.3, 0.7),
        giveMsg = "Received ${amount} in taxes from Military Outpost ${station}."%_T,
        chance = 0.35,
        quantity = 1.0,
        traderTypes = { "military", "torpedo" }
    },
    ["Turret Factory"%_t] = {
        giveFunction = ManageStationIncomes.giveStationTurret,
        giveMsg = "Gained ${amount} in taxes from Turret Factory ${station}."%_T,
        chance = 0.4,
        quantity = 1.0,
        traderTypes = { "military", "torpedo" }
    },
    ["Fighter Factory"%_t] = {
        giveFunction = ManageStationIncomes.giveStationMoney,
        giveMsg = "Earned ${amount} in fighter costs from Fighter Factory ${station}."%_T,
        chance = 0.4,
        quantity = 1.0,
        traderTypes = { "military", "torpedo" }
    },
}
