
package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include ("randomext")
include ("stringutility")
include ("callable")
local UpgradeGenerator = include ("upgradegenerator")
local SectorTurretGenerator = include ("sectorturretgenerator")
local BuildingKnowledgeUT = include("buildingknowledgeutility")

local data = {}
data.empty = false

-- if this function returns false, the script will not be listed in the interaction window,
-- even though its UI may be registered
function interactionPossible(playerIndex, option)

    local player = Player(playerIndex)
    local self = Entity()

    local craft = player.craft
    if craft == nil then return false end

    local dist = craft:getNearestDistance(self)

    if dist < 20.0 then
        return true
    end

    return false, "You're not close enough to open the object."%_t
end

function initialize(empty)
    local entity = Entity()

    if entity.title == "" then entity.title = "Smuggler's Cache"%_t end

    entity:setValue("valuable_object", RarityType.Exceptional)
    data.empty = empty or false
end

-- create all required UI elements for the client side
function initUI()

    local res = getResolution()
    local size = vec2(800, 600)

    local menu = ScriptUI()
    window = menu:createWindow(Rect(vec2(0, 0), vec2(0, 0)))

    menu:registerWindow(window, "[Open]"%_t, 5);
end

function onShowWindow()
    invokeServerFunction("claim")
    ScriptUI():stopInteraction()
end

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
    if faction and (faction.isPlayer or faction.isAlliance) then
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



function receiveBuildingKnowledge(faction)
    local x, y = Sector():getCoordinates()
    local material = BuildingKnowledgeUT.getLocalKnowledgeMaterial(x, y)
    local item = BuildingKnowledgeUT.makeKnowledge(faction.index, material)

    local loot = Sector():dropUsableItem(Entity().translationf, faction, nil, item)
    loot.reservationTime = 60 * 60
end

function checkForLaserBossHint()
    -- if stash is inside barrier and player defeated guardian (aka has laser boss spawn script),
    -- it can contain a hint for the location of the laser boss
    local x, y = Sector():getCoordinates()
    local distToCenter = math.sqrt(x * x + y * y)
    if distToCenter < 150 then
        local player = Player(callingPlayer)
        if player:hasScript("spawnlaserboss.lua") then
            player:invokeFunction("spawnlaserboss.lua", "getHint")
        end
    end
end

function claim()

    local receiver, ship, player = getInteractingFaction(callingPlayer, AlliancePrivilege.AddItems, AlliancePrivilege.AddResources)
    if not receiver then return end

    local entity = Entity()
    local dist = ship:getNearestDistance(entity)
    if dist > 20.0 then
        player:sendChatMessage("", ChatMessageType.Error, "You're not close enough to open the object."%_t)
        return
    end

    local sector = Sector()

    if not data.empty then
        receiveMoney(receiver)

        if random():getFloat() < 0.5 then
            receiveTurret(receiver)
        else
            receiveUpgrade(receiver)
        end

        if random():getFloat() < 0.5 then
            if random():getFloat() < 0.5 then
                receiveTurret(receiver)
            else
                receiveUpgrade(receiver)
            end
        end

        if random():getFloat() < 0.05 then
            local item = UsableInventoryItem("unbrandedreconstructionkit.lua", Rarity(RarityType.Legendary))
            sector:dropUsableItem(entity.translationf, receiver, nil, item)
        elseif random():getFloat() < 0.05 then
            local item = UsableInventoryItem("jumperbosscaller.lua", Rarity(RarityType.Legendary))
            sector:dropUsableItem(entity.translationf, receiver, nil, item)
        end

        -- small chance to drop building knowledge
        if random():getFloat() < 1 / 20 then
            receiveBuildingKnowledge(player)
        end

        checkForLaserBossHint()
    end

    -- send callback that stash is opened
    local player = Player(callingPlayer)
    sector:sendCallback("onStashOpened", entity.id, player.index)
    player:sendCallback("onStashOpened", entity.id, player.index)
    entity:sendCallback("onStashOpened", entity.id, player.index)

    -- terminate script and remove entity from object detection
    terminate()
    entity:setValue("valuable_object", nil)
end
callable(nil, "claim")

function setEmpty(value)
    data.empty = value
end

function secure()
    return data
end

function restore(data_in)
    data = data_in
end





