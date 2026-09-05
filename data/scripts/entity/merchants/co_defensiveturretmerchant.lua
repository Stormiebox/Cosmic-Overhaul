package.path = package.path .. ";data/scripts/lib/?.lua"
include("utility")
include("randomext")
local ShopAPI = include("shop")
local SectorTurretGenerator = include("sectorturretgenerator")
local CO_ShopUtils = include("co_shopgenerationutils")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace CO_DefensiveTurretMerchant
CO_DefensiveTurretMerchant = {}
CO_DefensiveTurretMerchant = ShopAPI.CreateNamespace()
CO_DefensiveTurretMerchant.interactionThreshold = -30000

-- Same tuning as the original, unsplit turretmerchant.lua's TurretMerchant.rarityFactors.
CO_DefensiveTurretMerchant.rarityFactors = {}
CO_DefensiveTurretMerchant.rarityFactors[-1] = 0.5
CO_DefensiveTurretMerchant.rarityFactors[0] = 0.5
CO_DefensiveTurretMerchant.rarityFactors[1] = 0.5
CO_DefensiveTurretMerchant.rarityFactors[2] = 1.0
CO_DefensiveTurretMerchant.rarityFactors[3] = 1.0
CO_DefensiveTurretMerchant.rarityFactors[4] = 1.0
CO_DefensiveTurretMerchant.rarityFactors[5] = 1.0

function CO_DefensiveTurretMerchant.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, CO_DefensiveTurretMerchant.interactionThreshold)
end

function CO_DefensiveTurretMerchant.shop:addItems()
    local x, y = Sector():getCoordinates()
    local turrets = CO_ShopUtils.GenerateCategoryTurrets(x, y, WeaponTypes.defensiveTypes, CO_DefensiveTurretMerchant.rarityFactors)
    for _, pair in pairs(turrets) do
        CO_DefensiveTurretMerchant.shop:add(pair.turret, pair.amount)
    end
end

function CO_DefensiveTurretMerchant.shop:onSpecialOfferSeedChanged()
    local x, y = Sector():getCoordinates()
    local weaponType = getRandomEntry(WeaponTypes.defensiveTypes)
    local generator = SectorTurretGenerator(CO_DefensiveTurretMerchant.shop:generateSeed())
    local specialOfferTurret = InventoryTurret(generator:generate(x, y, nil, nil, weaponType, CO_ShopUtils.SelectHighQualityMaterial(x, y)))
    CO_DefensiveTurretMerchant.shop:setSpecialOffer(specialOfferTurret)
end

function CO_DefensiveTurretMerchant.initialize()
    CO_DefensiveTurretMerchant.shop:initialize(Entity().translatedTitle)
end

function CO_DefensiveTurretMerchant.initUI()
    CO_DefensiveTurretMerchant.shop:initUI("Trade Equipment"%_t, Entity().translatedTitle, "Defensive Turrets"%_t, "data/textures/icons/point-defense-chaingun.png")
end
