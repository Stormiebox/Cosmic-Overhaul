package.path = package.path .. ";data/scripts/lib/?.lua"

local mcm = include("mcm")
local config = mcm and mcm.bind("Cosmic_Overhaul") or nil

include("cosmicvaultconfig")

CosmicOverhaulConfig = CosmicOverhaulConfig or {}

local defaults =
{
    enableGateTravelPriority = true,
    enableProfitableStations = true,
    enableExoticLegendarySalvage = true,

    profitableStationsInterval = 120,
    profitableStationsPayoutMultiplier = 1.00,
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

    out.enableGateTravelPriority = readBool("enableGateTravelPriority", defaults.enableGateTravelPriority)
    out.enableProfitableStations = readBool("enableProfitableStations", defaults.enableProfitableStations)
    out.enableExoticLegendarySalvage = readBool("enableExoticLegendarySalvage", defaults.enableExoticLegendarySalvage)

    out.profitableStationsInterval = math.floor(readNumber("profitableStationsInterval", 30, 1800,
        defaults.profitableStationsInterval))
    out.profitableStationsPayoutMultiplier = readNumber("profitableStationsPayoutMultiplier", 0.10, 10.0,
        defaults.profitableStationsPayoutMultiplier)

    local vaultCfg = (CosmicVaultConfig and CosmicVaultConfig.get and CosmicVaultConfig.get()) or nil
    out.debugLogs = (vaultCfg and type(vaultCfg.debugEnabled) == "boolean") and vaultCfg.debugEnabled or false

    return out
end

function CosmicOverhaulConfig.get()
    return build()
end
