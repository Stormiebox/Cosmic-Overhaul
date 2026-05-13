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
                    description = "Enables periodic station income simulation enhancements.",
                    default = true,
                },
                {
                    key = "profitableStationsInterval",
                    type = "number",
                    title = "Profitable Stations Interval (s)",
                    description = "Update interval for profitable stations simulation.",
                    default = 600,
                    min = 30,
                    max = 7200,
                },
                {
                    key = "profitableStationsPayoutMultiplier",
                    type = "number",
                    title = "Profitable Stations Payout Multiplier",
                    description = "Scales profitable stations payout values.",
                    default = 1.00,
                    min = 0.10,
                    max = 10.00,
                },
                {
                    key = "profitableStationsSpawnTraderWhenLoaded",
                    type = "bool",
                    title = "Spawn Trader In Loaded Sectors",
                    description = "Allows trader presence logic while sector is loaded.",
                    default = true,
                },
                {
                    key = "enableExoticLegendarySalvage",
                    type = "bool",
                    title = "Enable Exotic/Legendary Salvage",
                    description = "Applies weighted rarity upgrades to salvage-generated items.",
                    default = true,
                },
            },
        },
    },
}
