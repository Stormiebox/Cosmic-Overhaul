package.path = package.path .. ";data/scripts/lib/?.lua"
include("utility")
include("randomext")
local ShopAPI = include("shop")
local SectorTurretGenerator = include("sectorturretgenerator")
local CO_ShopUtils = include("co_shopgenerationutils")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace CO_MilitaryTurretMerchant
CO_MilitaryTurretMerchant = {}
CO_MilitaryTurretMerchant = ShopAPI.CreateNamespace()
CO_MilitaryTurretMerchant.interactionThreshold = -30000

-- Same tuning as the original, unsplit turretmerchant.lua's TurretMerchant.rarityFactors.
CO_MilitaryTurretMerchant.rarityFactors = {}
CO_MilitaryTurretMerchant.rarityFactors[-1] = 0.5
CO_MilitaryTurretMerchant.rarityFactors[0] = 0.5
CO_MilitaryTurretMerchant.rarityFactors[1] = 0.5
CO_MilitaryTurretMerchant.rarityFactors[2] = 1.0
CO_MilitaryTurretMerchant.rarityFactors[3] = 1.0
CO_MilitaryTurretMerchant.rarityFactors[4] = 1.0
CO_MilitaryTurretMerchant.rarityFactors[5] = 1.0

function CO_MilitaryTurretMerchant.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, CO_MilitaryTurretMerchant.interactionThreshold)
end

function CO_MilitaryTurretMerchant.shop:addItems()
    local x, y = Sector():getCoordinates()
    local turrets = CO_ShopUtils.GenerateCategoryTurrets(x, y, WeaponTypes.armedTypes, CO_MilitaryTurretMerchant.rarityFactors)
    for _, pair in pairs(turrets) do
        CO_MilitaryTurretMerchant.shop:add(pair.turret, pair.amount)
    end
end

function CO_MilitaryTurretMerchant.shop:onSpecialOfferSeedChanged()
    local x, y = Sector():getCoordinates()
    local weaponType = getRandomEntry(WeaponTypes.armedTypes)
    local generator = SectorTurretGenerator(CO_MilitaryTurretMerchant.shop:generateSeed())
    local specialOfferTurret = InventoryTurret(generator:generate(x, y, nil, nil, weaponType, CO_ShopUtils.SelectHighQualityMaterial(x, y)))
    CO_MilitaryTurretMerchant.shop:setSpecialOffer(specialOfferTurret)
end

function CO_MilitaryTurretMerchant.initialize()
    CO_MilitaryTurretMerchant.shop:initialize(Entity().translatedTitle)
end

function CO_MilitaryTurretMerchant.initUI()
    CO_MilitaryTurretMerchant.shop:initUI("Trade Equipment"%_t, Entity().translatedTitle, "Military Turrets"%_t, "data/textures/icons/bolter.png")
end
