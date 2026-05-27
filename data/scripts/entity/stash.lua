-- Cosmic Overhaul: Improved Stashes
-- Enhances hidden stashes to scale better into the late game with improved credit/resource
-- yields, higher drop rarities, and tech-level bumps for turrets.

include("utility")
local SectorTurretGenerator = include("sectorturretgenerator")
local UpgradeGenerator = include("upgradegenerator")

local RewardType = {
    Money = 0,
    Resource = 1
}

local function calculateSectorRewardFactor(distance, s_args)
    -- Sigmoid function for smooth, non-linear scaling
    return s_args.max - (s_args.max - s_args.min) * 1 / ((1 + math.exp(-s_args.bias_start * (distance - s_args.optimal_dist))) ^ s_args.bias_mean)
end

local function getSectorRewardValue(x, y, rewardType)
    local sigmoid_vars = {}
    -- Credits: Starts ~100k, scales to 1.5M at the core.
    sigmoid_vars[RewardType.Money]    = { min = 50000, max = 1500000, optimal_dist = 250, bias_start = 0.016405753, bias_mean = 0.951090399 }
    -- Resources: Starts ~9k, scales to 25k at the core.
    sigmoid_vars[RewardType.Resource] = { min = 5000, max = 25000, optimal_dist = 250, bias_start = 0.010683913, bias_mean = 1.999999997 }

    local distance = length(vec2(x, y))
    return calculateSectorRewardFactor(distance, sigmoid_vars[rewardType])
end

local function getBonusMultiplier()
    local probability = random():getFloat(0, 1)
    if probability < 0.005 then return 10.0
    elseif probability < 0.10 then return 3.0
    elseif probability < 0.25 then return 1.5
    end
    return 1.0
end

local function getDropRarity()
    local probability = random():getFloat(0, 1)
    if probability < 0.005 then return Rarity(RarityType.Legendary)
    elseif probability < 0.05 then return Rarity(RarityType.Exotic)
    elseif probability >= 0.70 then return Rarity(RarityType.Rare)
    end
    return Rarity(RarityType.Exceptional)
end

local function getMaterialType(x, y)
    local probabilities = Balancing_GetMaterialProbability(x, y)
    return Material(getValueFromDistribution(probabilities))
end

local function getTechOffsetDistance(x, y)
    local techOffset = 2 -- Baseline 1-2 tech levels higher
    local probability = random():getFloat(0, 1)
    if probability < 0.005 then
        techOffset = 7 -- 0.5% chance for +7 tech levels
    elseif probability < 0.10 then
        techOffset = 5 -- 10% chance for +5 tech levels
    end

    -- Safety check to prevent offset from pushing the calculation past the core (0,0)
    local offsetLimit = length(vec2(x, y)) / 10
    techOffset = math.min(offsetLimit, techOffset)

    -- Negative distance pushes the item's tech level closer to the core
    return -(techOffset * 10)
end

-- Overwrite Vanilla Stash Functions
function receiveMoney(faction)
    local x, y = Sector():getCoordinates()
    local bonusMultiplier = getBonusMultiplier()
    local translation = Entity().translationf

    -- Drop Credits
    local scaledMoney = getSectorRewardValue(x, y, RewardType.Money)
    local money = math.floor(scaledMoney * bonusMultiplier)
    Sector():dropBundle(translation, faction, nil, money)

    -- Drop Resources
    local scaledResource = getSectorRewardValue(x, y, RewardType.Resource)
    local resources = math.floor(scaledResource * bonusMultiplier)
    local material = getMaterialType(x, y)
    Sector():dropResources(translation, faction, nil, material, resources)
end

function receiveTurret(faction)
    local x, y = Sector():getCoordinates()
    local generator = SectorTurretGenerator()
    generator.minRarity = getDropRarity()

    local techOffset = getTechOffsetDistance(x, y)
    local turret = generator:generate(x, y, techOffset)

    Sector():dropTurret(Entity().translationf, faction, nil, turret)
end

function receiveUpgrade(faction)
    local x, y = Sector():getCoordinates()
    local generator = UpgradeGenerator()
    generator.minRarity = getDropRarity()

    -- Safely pass DLC ownership flags to the generator
    if faction and faction.isPlayer then
        if faction.ownsBlackMarketDLC then
            generator.blackMarketUpgradesEnabled = true
        end
        if faction.ownsIntoTheRiftDLC then
            generator.intoTheRiftUpgradesEnabled = true
        end
    end

    local upgrade = generator:generateSectorSystem(x, y)
    Sector():dropUpgrade(Entity().translationf, faction, nil, upgrade)
end