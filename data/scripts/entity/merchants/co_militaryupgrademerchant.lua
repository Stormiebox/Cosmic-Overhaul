package.path = package.path .. ";data/scripts/lib/?.lua"
include("utility")
include("randomext")
local ShopAPI = include("shop")
local UpgradeGenerator = include("upgradegenerator")
local CO_ShopUtils = include("co_shopgenerationutils")
local CosmicVaultUpgradeCategories = include("cosmicvaultupgradecategories")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace CO_MilitaryUpgradeMerchant
CO_MilitaryUpgradeMerchant = {}
CO_MilitaryUpgradeMerchant = ShopAPI.CreateNamespace()

-- Same tuning as the original, unsplit equipmentdock.lua's EquipmentDock.rarityFactors.
CO_MilitaryUpgradeMerchant.rarityFactors = {}
CO_MilitaryUpgradeMerchant.rarityFactors[-1] = 1.0
CO_MilitaryUpgradeMerchant.rarityFactors[0] = 1.0
CO_MilitaryUpgradeMerchant.rarityFactors[1] = 1.0
CO_MilitaryUpgradeMerchant.rarityFactors[2] = 1.0
CO_MilitaryUpgradeMerchant.rarityFactors[3] = 0.5
CO_MilitaryUpgradeMerchant.rarityFactors[4] = 0.5
CO_MilitaryUpgradeMerchant.rarityFactors[5] = 0.25

-- if this function returns false, the script will not be listed in the interaction window,
-- even though its UI may be registered
function CO_MilitaryUpgradeMerchant.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, -10000)
end

function CO_MilitaryUpgradeMerchant.shop:addItems()
    local x, y = Sector():getCoordinates()
    local validScripts = CO_ShopUtils.GetScriptsOfCategory(CosmicVaultUpgradeCategories.Category.Military)
    local systems = CO_ShopUtils.GenerateCategoryUpgrades(x, y, validScripts, CO_MilitaryUpgradeMerchant.rarityFactors)
    for _, pair in pairs(systems) do
        CO_MilitaryUpgradeMerchant.shop:add(pair.upgrade, pair.amount)
    end
end

function CO_MilitaryUpgradeMerchant.shop:onSpecialOfferSeedChanged()
    local x, y = Sector():getCoordinates()
    local validScripts = CO_ShopUtils.GetScriptsOfCategory(CosmicVaultUpgradeCategories.Category.Military)
    if #validScripts == 0 then return end

    local generator = UpgradeGenerator(CO_MilitaryUpgradeMerchant.shop:generateSeed())
    local script = getRandomEntry(validScripts)
    local rarities = generator:getSectorRarityDistribution(x, y)
    local rarity = Rarity(getValueFromDistribution(rarities, generator.random))
    local seed = generator:getUpgradeSeed(x, y, script, rarity)

    CO_MilitaryUpgradeMerchant.shop:setSpecialOffer(SystemUpgradeTemplate(script, rarity, seed))
end

function CO_MilitaryUpgradeMerchant.initialize()
    CO_MilitaryUpgradeMerchant.shop:initialize(Entity().translatedTitle)
end

function CO_MilitaryUpgradeMerchant.initUI()
    CO_MilitaryUpgradeMerchant.shop:initUI("Trade Equipment"%_t, Entity().translatedTitle, "Military Upgrades"%_t, "data/textures/icons/gears.png")
end
