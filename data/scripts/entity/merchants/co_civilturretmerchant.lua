package.path = package.path .. ";data/scripts/lib/?.lua"
include("utility")
include("randomext")
local ShopAPI = include("shop")
local SectorTurretGenerator = include("sectorturretgenerator")
local CO_ShopUtils = include("co_shopgenerationutils")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace CO_CivilTurretMerchant
CO_CivilTurretMerchant = {}
CO_CivilTurretMerchant = ShopAPI.CreateNamespace()
CO_CivilTurretMerchant.interactionThreshold = -30000

-- Same tuning as the original, unsplit turretmerchant.lua's TurretMerchant.rarityFactors.
CO_CivilTurretMerchant.rarityFactors = {}
CO_CivilTurretMerchant.rarityFactors[-1] = 0.5
CO_CivilTurretMerchant.rarityFactors[0] = 0.5
CO_CivilTurretMerchant.rarityFactors[1] = 0.5
CO_CivilTurretMerchant.rarityFactors[2] = 1.0
CO_CivilTurretMerchant.rarityFactors[3] = 1.0
CO_CivilTurretMerchant.rarityFactors[4] = 1.0
CO_CivilTurretMerchant.rarityFactors[5] = 1.0

function CO_CivilTurretMerchant.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, CO_CivilTurretMerchant.interactionThreshold)
end

function CO_CivilTurretMerchant.shop:addItems()
    local x, y = Sector():getCoordinates()
    local turrets = CO_ShopUtils.GenerateCategoryTurrets(x, y, WeaponTypes.unarmedTypes, CO_CivilTurretMerchant.rarityFactors)
    for _, pair in pairs(turrets) do
        CO_CivilTurretMerchant.shop:add(pair.turret, pair.amount)
    end
end

function CO_CivilTurretMerchant.shop:onSpecialOfferSeedChanged()
    local x, y = Sector():getCoordinates()
    local weaponType = getRandomEntry(WeaponTypes.unarmedTypes)
    local generator = SectorTurretGenerator(CO_CivilTurretMerchant.shop:generateSeed())
    local specialOfferTurret = InventoryTurret(generator:generate(x, y, nil, nil, weaponType, CO_ShopUtils.SelectHighQualityMaterial(x, y)))
    CO_CivilTurretMerchant.shop:setSpecialOffer(specialOfferTurret)
end

function CO_CivilTurretMerchant.initialize()
    CO_CivilTurretMerchant.shop:initialize(Entity().translatedTitle)
end

function CO_CivilTurretMerchant.initUI()
    CO_CivilTurretMerchant.shop:initUI("Trade Equipment"%_t, Entity().translatedTitle, "Civilian Turrets"%_t, "data/textures/icons/mining-laser.png")
end
