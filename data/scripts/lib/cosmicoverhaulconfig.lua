package.path = package.path .. ";data/scripts/lib/?.lua"

local ccm = include("ccm")
local config = ccm and ccm.bind("Cosmic_Overhaul") or nil

include("cosmicvaultconfig")

CosmicOverhaulConfig = CosmicOverhaulConfig or {}

if ccm then
    ccm.register("Cosmic_Overhaul", {
        pages = {
            {
                title = "Profit Configurations",
                options = {
                    { key = "enableProfitableStations", type = "bool", title = "Enable Profitable Stations", description = "Enables periodic station income simulation enhancements.", default = true },
                    { key = "profitableStationsInterval", type = "number", title = "Profitable Stations Interval (s)", description = "Update interval for profitable stations simulation. (Min: 30s | Max: 7200s)", default = 600, min = 30, max = 7200 },
                    { key = "profitableStationsPayoutMultiplier", type = "number", title = "Profitable Stations Payout Multiplier", description = "Scales profitable stations payout values. (Min: 0.1 | Max: 10.0)", default = 1.00, min = 0.10, max = 10.00 },
                },
            },
            {
                title = "Other Configurations",
                options = {
                    { key = "enableGateTravelPriority", type = "bool", title = "Enable Gate Travel Priority", description = "Ships prioritize gates/wormholes when executing map travel orders.", default = true },
                    { key = "enableExoticLegendarySalvage", type = "bool", title = "Enable Exotic/Legendary Salvage", description = "Applies weighted rarity upgrades to salvage-generated items.", default = true },
                },
            },
            {
                title = "Offline Simulation (ARCC)",
                options = {
                    { key = "enableOfflineCatchup", type = "bool", title = "Enable Offline Catch-up", description = "Should captain commands continue simulating while the server is offline/empty?", default = false },
                    { key = "offlineCatchupMaxDuration", type = "number", title = "Max Catch-up Duration (s)", description = "Maximum offline time (in seconds) that will be simulated. (Max: 86400s / 24H)", default = 28800, min = 0, max = 86400 },
                    { key = "offlineCatchupRatio", type = "number", title = "Catch-up Efficiency Ratio", description = "What percentage of offline time is actually counted (Min 0.0, Max 1.0).", default = 0.667, min = 0.0, max = 1.0 },
                },
            },
        },
    })
end

local defaults =
{
    enableGateTravelPriority = true,
    enableProfitableStations = true,
    enableExoticLegendarySalvage = true,

    enableOfflineCatchup = false,
    offlineCatchupRatio = 0.667,
    offlineCatchupMaxDuration = 28800,

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
    
    out.enableOfflineCatchup = readBool("enableOfflineCatchup", defaults.enableOfflineCatchup)
    out.offlineCatchupRatio = readNumber("offlineCatchupRatio", 0.0, 1.0, defaults.offlineCatchupRatio)
    out.offlineCatchupMaxDuration = readNumber("offlineCatchupMaxDuration", 0, 86400, defaults.offlineCatchupMaxDuration)

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
