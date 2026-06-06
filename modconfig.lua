return {
    image = "data/textures/MCM_Cosmic_Overhaul.png",
    pages = {
        {
            title = "Profit Configurations",
            options = {
                {
                    key = "enableProfitableStations",
                    type = "bool",
                    title = "Enable Profitable Stations",
                    description = "Enables periodic station income simulation enhancements. (Default: true)",
                    default = true,
                },
                {
                    key = "profitableStationsInterval",
                    type = "number",
                    title = "Profitable Stations Interval (s)",
                    description =
                    "Update interval for profitable stations simulation. (Default: 600s / 10m | Min: 30s | Max: 7200s / 2h)",
                    default = 600,
                    min = 30,
                    max = 7200,
                },
                {
                    key = "profitableStationsPayoutMultiplier",
                    type = "number",
                    title = "Profitable Stations Payout Multiplier",
                    description = "Scales profitable stations payout values. (Default: 1.0 | Min: 0.1 | Max: 10.0)",
                    default = 1.00,
                    min = 0.10,
                    max = 10.00,
                },
            },
        },
        {
            title = "Other Configurations",
            options = {
                {
                    key = "enableGateTravelPriority",
                    type = "bool",
                    title = "Enable Gate Travel Priority",
                    description = "Ships prioritize gates/wormholes when executing map travel orders. (Default: true)",
                    default = true,
                },
                {
                    key = "enableExoticLegendarySalvage",
                    type = "bool",
                    title = "Enable Exotic/Legendary Salvage",
                    description = "Applies weighted rarity upgrades to salvage-generated items. (Default: true)",
                    default = true,
                },
            },
        },
        {
            title = "Offline Simulation (ARCC)",
            options = {
                {
                    key = "enableOfflineCatchup",
                    type = "bool",
                    title = "Enable Offline Catch-up",
                    description = "Should captain commands continue simulating while the server is offline/empty? (Default: false)",
                    default = false,
                },
                {
                    key = "offlineCatchupMaxDuration",
                    type = "number",
                    title = "Max Catch-up Duration (s)",
                    description = "Maximum offline time (in seconds) that will be simulated. (Max: 86400s / 24H) (Default: 28800s / 8h)",
                    default = 28800,
                    min = 0,
                    max = 86400,
                },
                {
                    key = "offlineCatchupRatio",
                    type = "number",
                    title = "Catch-up Efficiency Ratio",
                    description = "What percentage of offline time is actually counted (Min 0.0, Max 1.0). (Default: 0.667)",
                    default = 0.667,
                    min = 0.0,
                    max = 1.0,
                },
            },
        },
    },
}
