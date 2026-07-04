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
                    { key = "profitableStationsInterval", type = "number", title = "Profitable Stations Interval (s)", description = "Update interval for profitable stations simulation. (Min: 30s | Max: 7200s)", default = 1200, min = 30, max = 7200 },
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
            {
                title = "Resource Regeneration",
                options = {
                    { key = "enableResourceRegen", type = "bool", title = "Enable Resource Regeneration", description = "Globally enables or disables the persistent background asteroid regeneration.", default = true },
                    { key = "restorationPct", type = "number", title = "Restoration Target (%)", description = "Resource level to restore toward. 25% means mining has lasting impact.", default = 25, min = 0, max = 100 },
                    { key = "respawnRate", type = "number", title = "Respawn Rate (%)", description = "Percentage of the baseline asteroid count to respawn per tick.", default = 1, min = 1, max = 100 },
                    { key = "respawnInterval", type = "number", title = "Respawn Interval (min)", description = "Minutes between respawn ticks.", default = 20, min = 1, max = 60 },
                    { key = "respawnedFields", type = "number", title = "Emergency Field Count", description = "Fields spawned when asteroids drop below 200.", default = 3, min = 1, max = 6 },
                    { key = "bigAsteroidChance", type = "number", title = "Big Asteroid Chance (%)", description = "Chance respawned asteroid is a big resource asteroid.", default = 1, min = 0, max = 5 },
                    { key = "hiddenTreasureChance", type = "number", title = "Hidden Treasure Chance (%)", description = "Chance asteroid is a hidden treasure.", default = 2, min = 0, max = 10 },
                    { key = "sizeModifier", type = "number", title = "Size Modifier (%)", description = "Multiplier applied to asteroid min/max sizes.", default = 100, min = 50, max = 200 },
                    { key = "abandonmentEnabled", type = "bool", title = "Abandonment Mechanic", description = "When enabled, AI-owned claimable asteroids have a chance to become abandoned instead of mines.", default = true },
                    { key = "abandonmentChance", type = "number", title = "Abandonment Chance (%)", description = "Chance per hour that an AI-owned claimable asteroid becomes abandoned.", default = 10, min = 5, max = 50 },
                    { key = "showResHud", type = "bool", title = "Show Resource HUD", description = "Show the resource HUD (mining system required).", default = false, isClient = true },
                    { key = "showResTimer", type = "bool", title = "Show Respawn Timer", description = "Show the countdown until the next respawn tick.", default = false, isClient = true },
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

    profitableStationsInterval = 1200,
    profitableStationsPayoutMultiplier = 1.00,

    enableResourceRegen = true,
    restorationPct = 25,
    respawnRate = 1,
    respawnInterval = 20,
    respawnedFields = 3,
    bigAsteroidChance = 1,
    hiddenTreasureChance = 2,
    sizeModifier = 100,
    abandonmentEnabled = true,
    abandonmentChance = 10,
    showResHud = false,
    showResTimer = false,
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
    if value == nil then return fallback end
    if type(value) == "boolean" then return value end
    if type(value) == "string" then
        local lower = string.lower(value)
        if lower == "true" or lower == "1" then return true end
        if lower == "false" or lower == "0" then return false end
    end
    if type(value) == "number" then
        if value == 1 then return true end
        if value == 0 then return false end
    end
    return fallback
end

local function build()
    local out = {}

    out.enableGateTravelPriority = readBool("enableGateTravelPriority", defaults.enableGateTravelPriority)
    out.enableProfitableStations = readBool("enableProfitableStations", defaults.enableProfitableStations)
    out.enableExoticLegendarySalvage = readBool("enableExoticLegendarySalvage", defaults.enableExoticLegendarySalvage)
    
    out.enableOfflineCatchup = readBool("enableOfflineCatchup", defaults.enableOfflineCatchup)
    out.offlineCatchupRatio = readNumber("offlineCatchupRatio", 0.0, 1.0, defaults.offlineCatchupRatio)
    out.offlineCatchupMaxDuration = readNumber("offlineCatchupMaxDuration", 0, 86400, defaults.offlineCatchupMaxDuration)

    out.profitableStationsInterval = math.floor(readNumber("profitableStationsInterval", 30, 7200,
        defaults.profitableStationsInterval))
    out.profitableStationsPayoutMultiplier = readNumber("profitableStationsPayoutMultiplier", 0.10, 10.0,
        defaults.profitableStationsPayoutMultiplier)

    out.enableResourceRegen = readBool("enableResourceRegen", defaults.enableResourceRegen)
    out.restorationPct = readNumber("restorationPct", 0, 100, defaults.restorationPct)
    out.respawnRate = readNumber("respawnRate", 1, 100, defaults.respawnRate)
    out.respawnInterval = readNumber("respawnInterval", 1, 60, defaults.respawnInterval)
    out.respawnedFields = readNumber("respawnedFields", 1, 6, defaults.respawnedFields)
    out.bigAsteroidChance = readNumber("bigAsteroidChance", 0, 5, defaults.bigAsteroidChance)
    out.hiddenTreasureChance = readNumber("hiddenTreasureChance", 0, 10, defaults.hiddenTreasureChance)
    out.sizeModifier = readNumber("sizeModifier", 50, 200, defaults.sizeModifier)
    out.abandonmentEnabled = readBool("abandonmentEnabled", defaults.abandonmentEnabled)
    out.abandonmentChance = readNumber("abandonmentChance", 5, 50, defaults.abandonmentChance)
    out.showResHud = readBool("showResHud", defaults.showResHud)
    out.showResTimer = readBool("showResTimer", defaults.showResTimer)

    local vaultCfg = (CosmicVaultConfig and CosmicVaultConfig.get and CosmicVaultConfig.get()) or nil
    out.debugLogs = (vaultCfg and type(vaultCfg.debugEnabled) == "boolean") and vaultCfg.debugEnabled or false

    return out
end

function CosmicOverhaulConfig.get()
    return build()
end

return CosmicOverhaulConfig
