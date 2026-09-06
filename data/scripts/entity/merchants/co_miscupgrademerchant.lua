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
    -- Passing the Misc category here (unlike the Civilian/Military tabs) lets the padding pass
    -- also pull from the full generator pool -- see GenerateCategoryUpgrades/
    -- RollMiscUpgradeFromFullPool in co_shopgenerationutils.lua -- so an external mod's own
    -- upgrade system, never registered with CosmicVaultUpgradeCategories, still shows up here
    -- instead of in no tab at all.
    local systems = CO_ShopUtils.GenerateCategoryUpgrades(x, y, validScripts, CO_MiscUpgradeMerchant.rarityFactors, CosmicVaultUpgradeCategories.Category.Misc)
    for _, pair in pairs(systems) do
        CO_MiscUpgradeMerchant.shop:add(pair.upgrade, pair.amount)
    end
end

function CO_MiscUpgradeMerchant.shop:onSpecialOfferSeedChanged()
    local x, y = Sector():getCoordinates()
    local generator = UpgradeGenerator(CO_MiscUpgradeMerchant.shop:generateSeed())
    local rarities = generator:getSectorRarityDistribution(x, y)

    -- Try the full generator pool first (same mechanism as the regular stock above) so an
    -- external mod's unregistered upgrade system has a chance to be the special offer here too,
    -- not just the regular list. Falls back to the explicitly-registered Misc list if 10 rolls in
    -- a row all land Military/Civilian.
    local script, rarity
    for _ = 1, 10 do
        local prototype = CO_ShopUtils.RollMiscUpgradeFromFullPool(generator, x, y, rarities)
        if prototype then
            script, rarity = prototype.script, prototype.rarity
            break
        end
    end

    if not script then
        local validScripts = CO_ShopUtils.GetScriptsOfCategory(CosmicVaultUpgradeCategories.Category.Misc)
        if #validScripts == 0 then return end
        script = getRandomEntry(validScripts)
        rarity = Rarity(getValueFromDistribution(rarities, generator.random))
    end

    local seed = generator:getUpgradeSeed(x, y, script, rarity)
    CO_MiscUpgradeMerchant.shop:setSpecialOffer(SystemUpgradeTemplate(script, rarity, seed))
end

function CO_MiscUpgradeMerchant.initialize()
    CO_MiscUpgradeMerchant.shop:initialize(Entity().translatedTitle)
end

function CO_MiscUpgradeMerchant.initUI()
    CO_MiscUpgradeMerchant.shop:initUI("Trade Equipment"%_t, Entity().translatedTitle, "Misc. Upgrades"%_t, "data/textures/icons/microchip.png")
end
