package.path = package.path .. ";data/scripts/lib/?.lua"

local mcm = include("mcm")
local config = mcm and mcm.bind("Cosmic_Overhaul") or nil

CosmicOverhaulConfig = CosmicOverhaulConfig or {}

local defaults =
{
    captainEfficientTravelMultiplier = 0.85,  -- lower is faster
    captainSafeAttackChanceMultiplier = 0.60, -- lower is safer

    extraLongRangeTradeBonus = 0,
    extraLongRangeSellBonus = 0,
    extraLongRangeMineBonus = 0,
    extraLongRangeRefineBonus = 0,
    extraLongRangeSalvageBonus = 0,
    extraLongRangeScoutBonus = 0,

    enableGateTravelPriority = true,
    enableProfitableStations = true,
    enableExoticLegendarySalvage = true,

    profitableStationsInterval = 120,
    profitableStationsPayoutMultiplier = 1.00,
    profitableStationsSpawnTraderWhenLoaded = true,

    debugLogs = false,
}

local function clampNumber(v, minV, maxV, fallback)
    if type(v) ~= "number" then return fallback end
    if v < minV then return minV end
    if v > maxV then return maxV end
    return v
end

local function readNumber(key, minV, maxV, fallback)
    if not config then return fallback end
    local value = config.get(key)
    return clampNumber(value, minV, maxV, fallback)
end

local function readBool(key, fallback)
    if not config then return fallback end
    local value = config.get(key)
    if type(value) ~= "boolean" then return fallback end
    return value
end

local function build()
    local out = {}

    out.captainEfficientTravelMultiplier = readNumber("captainEfficientTravelMultiplier", 0.25, 2.0,
        defaults.captainEfficientTravelMultiplier)
    out.captainSafeAttackChanceMultiplier = readNumber("captainSafeAttackChanceMultiplier", 0.05, 2.0,
        defaults.captainSafeAttackChanceMultiplier)

    out.extraLongRangeTradeBonus = math.floor(readNumber("extraLongRangeTradeBonus", 0, 40,
        defaults.extraLongRangeTradeBonus))
    out.extraLongRangeSellBonus = math.floor(readNumber("extraLongRangeSellBonus", 0, 40,
        defaults.extraLongRangeSellBonus))
    out.extraLongRangeMineBonus = math.floor(readNumber("extraLongRangeMineBonus", 0, 40,
        defaults.extraLongRangeMineBonus))
    out.extraLongRangeRefineBonus = math.floor(readNumber("extraLongRangeRefineBonus", 0, 40,
        defaults.extraLongRangeRefineBonus))
    out.extraLongRangeSalvageBonus = math.floor(readNumber("extraLongRangeSalvageBonus", 0, 40,
        defaults.extraLongRangeSalvageBonus))
    out.extraLongRangeScoutBonus = math.floor(readNumber("extraLongRangeScoutBonus", 0, 40,
        defaults.extraLongRangeScoutBonus))

    out.enableGateTravelPriority = readBool("enableGateTravelPriority", defaults.enableGateTravelPriority)
    out.enableProfitableStations = readBool("enableProfitableStations", defaults.enableProfitableStations)
    out.enableExoticLegendarySalvage = readBool("enableExoticLegendarySalvage", defaults.enableExoticLegendarySalvage)

    out.profitableStationsInterval = math.floor(readNumber("profitableStationsInterval", 30, 1800,
        defaults.profitableStationsInterval))
    out.profitableStationsPayoutMultiplier = readNumber("profitableStationsPayoutMultiplier", 0.10, 10.0,
        defaults.profitableStationsPayoutMultiplier)
    out.profitableStationsSpawnTraderWhenLoaded = readBool("profitableStationsSpawnTraderWhenLoaded",
        defaults.profitableStationsSpawnTraderWhenLoaded)

    out.debugLogs = readBool("debugLogs", defaults.debugLogs)

    return out
end

function CosmicOverhaulConfig.get()
    return build()
end
