package.path = package.path .. ";data/scripts/lib/?.lua"
include("utility")
include("randomext")
local ShopAPI = include("shop")
local UpgradeGenerator = include("upgradegenerator")
local CO_ShopUtils = include("co_shopgenerationutils")
local CosmicVaultUpgradeCategories = include("cosmicvaultupgradecategories")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace CO_MiscUpgradeMerchant
CO_MiscUpgradeMerchant = {}
CO_MiscUpgradeMerchant = ShopAPI.CreateNamespace()

-- Same tuning as the original, unsplit equipmentdock.lua's EquipmentDock.rarityFactors.
CO_MiscUpgradeMerchant.rarityFactors = {}
CO_MiscUpgradeMerchant.rarityFactors[-1] = 1.0
CO_MiscUpgradeMerchant.rarityFactors[0] = 1.0
CO_MiscUpgradeMerchant.rarityFactors[1] = 1.0
CO_MiscUpgradeMerchant.rarityFactors[2] = 1.0
CO_MiscUpgradeMerchant.rarityFactors[3] = 0.5
CO_MiscUpgradeMerchant.rarityFactors[4] = 0.5
CO_MiscUpgradeMerchant.rarityFactors[5] = 0.25

-- if this function returns false, the script will not be listed in the interaction window,
-- even though its UI may be registered
function CO_MiscUpgradeMerchant.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, -10000)
end

function CO_MiscUpgradeMerchant.shop:addItems()
    local x, y = Sector():getCoordinates()
    local validScripts = CO_ShopUtils.GetScriptsOfCategory(CosmicVaultUpgradeCategories.Category.Misc)
    local systems = CO_ShopUtils.GenerateCategoryUpgrades(x, y, validScripts, CO_MiscUpgradeMerchant.rarityFactors)
    for _, pair in pairs(systems) do
        CO_MiscUpgradeMerchant.shop:add(pair.upgrade, pair.amount)
    end
end

function CO_MiscUpgradeMerchant.shop:onSpecialOfferSeedChanged()
    local x, y = Sector():getCoordinates()
    local validScripts = CO_ShopUtils.GetScriptsOfCategory(CosmicVaultUpgradeCategories.Category.Misc)
    if #validScripts == 0 then return end

    local generator = UpgradeGenerator(CO_MiscUpgradeMerchant.shop:generateSeed())
    local script = getRandomEntry(validScripts)
    local rarities = generator:getSectorRarityDistribution(x, y)
    local rarity = Rarity(getValueFromDistribution(rarities, generator.random))
    local seed = generator:getUpgradeSeed(x, y, script, rarity)

    CO_MiscUpgradeMerchant.shop:setSpecialOffer(SystemUpgradeTemplate(script, rarity, seed))
end

function CO_MiscUpgradeMerchant.initialize()
    CO_MiscUpgradeMerchant.shop:initialize(Entity().translatedTitle)
end

function CO_MiscUpgradeMerchant.initUI()
    CO_MiscUpgradeMerchant.shop:initUI("Trade Equipment"%_t, Entity().translatedTitle, "Misc. Upgrades"%_t, "data/textures/icons/microchip.png")
end
