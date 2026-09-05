-- Shared generation helpers for Cosmic Overhaul's category-split Equipment Dock / Turret Merchant
-- tabs (co_*turretmerchant.lua, co_*upgrademerchant.lua). Centralizes the "guarantee one of every
-- type in this category, then pad with random extras up to a minimum" pattern so every tab -- with
-- whatever turret types or upgrade systems happen to be registered by whichever mods are installed
-- -- always shows full category coverage instead of a category with few registered types being
-- under-stocked, or a large category never showing its rarer members at all.

package.path = package.path .. ";data/scripts/lib/?.lua"
include("randomext")
local SectorTurretGenerator = include("sectorturretgenerator")
local UpgradeGenerator = include("upgradegenerator")
local CosmicVaultUpgradeCategories = include("cosmicvaultupgradecategories")

local CO_ShopUtils = {}

CO_ShopUtils.MIN_ITEMS_PER_TAB = 13

--- Highest available material for the sector, occasionally one tier lower -- matches the
--- "highest available or one below" sourcing every co_*turretmerchant.lua tab uses.
--- @param x (number) sector x
--- @param y (number) sector y
--- @return (Material)
function CO_ShopUtils.SelectHighQualityMaterial(x, y)
    local material = Balancing_GetHighestAvailableMaterial(x, y)
    if material > 0 and random():test(0.25) then
        material = material - 1
    end
    return Material(material)
end

--- Cosmic Overhaul's existing per-rarity turret stock amounts (unchanged from the original,
--- unsplit turretmerchant.lua). Note Rarity.value uses a DIFFERENT numbering (-1..5) than the
--- RarityType enum (0..6) -- matching the raw literals the original turretmerchant.lua/
--- equipmentdock.lua rarityFactors tables already index by, not RarityType's own numbers.
--- @param rarityValue (int) a Rarity object's .value property (-1 Petty .. 5 Legendary)
--- @return (int) how many of this turret the shop should stock
function CO_ShopUtils.GetTurretAmountForRarity(rarityValue)
    if rarityValue == -1 then -- Petty
        return random():getInt(5, 12)
    elseif rarityValue == 0 then -- Common
        return random():getInt(4, 9)
    elseif rarityValue == 1 then -- Uncommon
        return random():getInt(3, 6)
    elseif rarityValue == 2 then -- Rare
        return random():getInt(2, 4)
    elseif rarityValue == 3 then -- Exceptional
        return random():getInt(1, 2)
    end
    return 1 -- Exotic (4), Legendary (5)
end

local function turretCompare(a, b)
    local ta = a.turret
    local tb = b.turret
    if ta.rarity.value == tb.rarity.value then
        if ta.material.value == tb.material.value then
            return ta.weaponPrefix < tb.weaponPrefix
        end
        return ta.material.value > tb.material.value
    end
    return ta.rarity.value > tb.rarity.value
end

--- Generates a category tab's turret stock: one of every type in validTypes, then random extras
--- (also drawn only from validTypes) padded up to CO_ShopUtils.MIN_ITEMS_PER_TAB.
--- @param x (number) sector x
--- @param y (number) sector y
--- @param validTypes (table) array of WeaponType values eligible for this tab (e.g. WeaponTypes.armedTypes)
--- @param rarityFactors (table) rarity.value -> weight multiplier, applied to the sector's rarity distribution
--- @return (table) array of {turret = InventoryTurret, amount = int}, sorted rarity-then-material-then-name
function CO_ShopUtils.GenerateCategoryTurrets(x, y, validTypes, rarityFactors)
    if not validTypes or #validTypes == 0 then return {} end

    local generator = SectorTurretGenerator()
    generator.rarities = generator:getSectorRarityDistribution(x, y)
    for i, rarity in pairs(generator.rarities) do
        generator.rarities[i] = rarity * (rarityFactors[i] or 1)
    end

    local turrets = {}

    local function addOne(weaponType)
        local turret = InventoryTurret(generator:generate(x, y, nil, nil, weaponType, CO_ShopUtils.SelectHighQualityMaterial(x, y)))
        table.insert(turrets, { turret = turret, amount = CO_ShopUtils.GetTurretAmountForRarity(turret.rarity.value) })
    end

    for _, weaponType in pairs(validTypes) do
        addOne(weaponType)
    end

    while #turrets < CO_ShopUtils.MIN_ITEMS_PER_TAB do
        addOne(getRandomEntry(validTypes))
    end

    table.sort(turrets, turretCompare)
    return turrets
end

local function upgradeCompare(a, b)
    local sa = a.upgrade
    local sb = b.upgrade
    if sa.rarity.value == sb.rarity.value then
        if sa.script == sb.script then
            return sa.price > sb.price
        end
        return sa.script < sb.script
    end
    return sa.rarity.value > sb.rarity.value
end

--- Generates a category tab's upgrade stock: one of every system script in validScripts
--- (unconditionally -- a guarantee is a guarantee, regardless of rolled rarity), then random
--- extras (also drawn only from validScripts, but with petty-rarity rolls kept only 25% of the
--- time, matching the original unsplit equipmentdock.lua's curation) padded up to
--- CO_ShopUtils.MIN_ITEMS_PER_TAB.
--- @param x (number) sector x
--- @param y (number) sector y
--- @param validScripts (table) array of upgrade system script paths eligible for this tab
--- @param rarityFactors (table) rarity.value -> weight multiplier, applied to the sector's rarity distribution
--- @return (table) array of {upgrade = SystemUpgradeTemplate, amount = int}, sorted rarity-then-script-then-price
function CO_ShopUtils.GenerateCategoryUpgrades(x, y, validScripts, rarityFactors)
    if not validScripts or #validScripts == 0 then return {} end

    local generator = UpgradeGenerator()
    local rand = random()

    local rarities = generator:getSectorRarityDistribution(x, y)
    for i, rarity in pairs(rarities) do
        rarities[i] = rarity * (rarityFactors[i] or 1)
    end

    local systems = {}

    local function rollRarity()
        return Rarity(getValueFromDistribution(rarities, rand))
    end

    local function insertOne(script, rarity)
        local seed = generator:getUpgradeSeed(x, y, script, rarity)
        local upgrade = SystemUpgradeTemplate(script, rarity, seed)
        table.insert(systems, { upgrade = upgrade, amount = random():getInt(5, 10) })
    end

    -- Guarantee pass: every registered script appears at least once, at whatever rarity rolls --
    -- never skipped, or "guaranteed" wouldn't mean anything.
    for _, script in pairs(validScripts) do
        insertOne(script, rollRarity())
    end

    -- Padding pass: random extras up to the minimum, with petty rolls kept only 25% of the time
    -- so a small category doesn't end up mostly petty filler.
    while #systems < CO_ShopUtils.MIN_ITEMS_PER_TAB do
        local rarity = rollRarity()
        if rarity.value >= 0 or rand:test(0.25) then
            insertOne(getRandomEntry(validScripts), rarity)
        end
    end

    table.sort(systems, upgradeCompare)
    return systems
end

--- Every upgrade script currently registered with Cosmic Vault's category registry under the
--- given category (Military/Civilian/Misc). A registering mod's own upgradegenerator.lua hook
--- (see Cosmic Starfall's, for the established pattern) always injects the matching script into
--- the generator's own pool in the same place it registers the category, so the two stay in sync
--- without needing a separate cross-check here.
--- @param category (CosmicVaultUpgradeCategories.Category)
--- @return (table) array of script path strings
function CO_ShopUtils.GetScriptsOfCategory(category)
    return CosmicVaultUpgradeCategories.getScriptsOfCategory(category)
end

return CO_ShopUtils
