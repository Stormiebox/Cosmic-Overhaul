return {
    image = "data/textures/MCM_Cosmic_Overhaul.png",
    pages = {
        {
            title = "Systems",
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
                {
                    key = "profitableStationsSpawnTraderWhenLoaded",
                    type = "bool",
                    title = "Spawn Trader In Loaded Sectors",
                    description = "Allows trader presence logic while the sector is loaded. (Default: true)",
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
            title = "Map Commands & Captains",
            options = {
                {
                    key = "captainEfficientTravelMultiplier",
                    type = "slider",
                    title = "Travel Time Multiplier",
                    description =
                    "Scales travel time for Navigators. Lower is faster. (Default: 85% | Min: 25% | Max: 200%)",
                    default = 85,
                    min = 25,
                    max = 200,
                    step = 1,
                    unit = "%",
                },
                {
                    key = "captainSafeAttackChanceMultiplier",
                    type = "slider",
                    title = "Ambush Chance Multiplier",
                    description =
                    "Scales ambush chance for Navigators. Lower is safer. (Default: 60% | Min: 5% | Max: 200%)",
                    default = 60,
                    min = 5,
                    max = 200,
                    step = 1,
                    unit = "%",
                },
                {
                    key = "enableGateTravelPriority",
                    type = "bool",
                    title = "Enable Gate Travel Priority",
                    description = "Ships prioritize gates/wormholes when executing map travel orders. (Default: true)",
                    default = true,
                },
            },
        },
    },
}
