package.path = package.path .. ";data/scripts/lib/?.lua"
include("utility")
include("randomext")
local ShopAPI = include("shop")
local UpgradeGenerator = include("upgradegenerator")
local CO_ShopUtils = include("co_shopgenerationutils")
local CosmicVaultUpgradeCategories = include("cosmicvaultupgradecategories")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace CO_CivilUpgradeMerchant
CO_CivilUpgradeMerchant = {}
CO_CivilUpgradeMerchant = ShopAPI.CreateNamespace()

-- Same tuning as the original, unsplit equipmentdock.lua's EquipmentDock.rarityFactors.
CO_CivilUpgradeMerchant.rarityFactors = {}
CO_CivilUpgradeMerchant.rarityFactors[-1] = 1.0
CO_CivilUpgradeMerchant.rarityFactors[0] = 1.0
CO_CivilUpgradeMerchant.rarityFactors[1] = 1.0
CO_CivilUpgradeMerchant.rarityFactors[2] = 1.0
CO_CivilUpgradeMerchant.rarityFactors[3] = 0.5
CO_CivilUpgradeMerchant.rarityFactors[4] = 0.5
CO_CivilUpgradeMerchant.rarityFactors[5] = 0.25

-- if this function returns false, the script will not be listed in the interaction window,
-- even though its UI may be registered
function CO_CivilUpgradeMerchant.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, -10000)
end

function CO_CivilUpgradeMerchant.shop:addItems()
    local x, y = Sector():getCoordinates()
    local validScripts = CO_ShopUtils.GetScriptsOfCategory(CosmicVaultUpgradeCategories.Category.Civilian)
    local systems = CO_ShopUtils.GenerateCategoryUpgrades(x, y, validScripts, CO_CivilUpgradeMerchant.rarityFactors)
    for _, pair in pairs(systems) do
        CO_CivilUpgradeMerchant.shop:add(pair.upgrade, pair.amount)
    end
end

function CO_CivilUpgradeMerchant.shop:onSpecialOfferSeedChanged()
    local x, y = Sector():getCoordinates()
    local validScripts = CO_ShopUtils.GetScriptsOfCategory(CosmicVaultUpgradeCategories.Category.Civilian)
    if #validScripts == 0 then return end

    local generator = UpgradeGenerator(CO_CivilUpgradeMerchant.shop:generateSeed())
    local script = getRandomEntry(validScripts)
    local rarities = generator:getSectorRarityDistribution(x, y)
    local rarity = Rarity(getValueFromDistribution(rarities, generator.random))
    local seed = generator:getUpgradeSeed(x, y, script, rarity)

    CO_CivilUpgradeMerchant.shop:setSpecialOffer(SystemUpgradeTemplate(script, rarity, seed))
end

function CO_CivilUpgradeMerchant.initialize()
    CO_CivilUpgradeMerchant.shop:initialize(Entity().translatedTitle)
end

function CO_CivilUpgradeMerchant.initUI()
    CO_CivilUpgradeMerchant.shop:initUI("Trade Equipment"%_t, Entity().translatedTitle, "Civilian Upgrades"%_t, "data/textures/icons/circuitry.png")
end
