package.path = package.path .. ";data/scripts/lib/?.lua"
include ("utility")
include ("randomext")
include ("sellableinventoryitem")
include ("stringutility")
local SectorFighterGenerator = include("sectorfightergenerator")
local Dialog = include("dialogutility")
local ShopAPI = include ("shop")
local SellableFighter = include ("sellablefighter")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace FighterMerchant
FighterMerchant = {}
FighterMerchant = ShopAPI.CreateNamespace()

FighterMerchant.interactionThreshold = -30000

-- if this function returns false, the script will not be listed in the interaction window on the client,
-- even though its UI may be registered
function FighterMerchant.interactionPossible(playerIndex, option)
    local player = Player(playerIndex)
    local ship = player.craft
    if not ship then return false end
    if not ship:hasComponent(ComponentType.Hangar) then return false end

    return CheckFactionInteraction(playerIndex, FighterMerchant.interactionThreshold)
end

local function isFighterPriceSafe(fighter)
    if not fighter then return false end

    -- Avorion 2.x + external pricing mod compatibility:
    -- avoid shuttle-like entries that can trigger references to removed CargoShuttle enum in third-party price code.
    if fighter.type == FighterType.CrewShuttle then return false end

    if fighter.type == nil then return false end
    if type(fighter.diameter) ~= "number" or fighter.diameter <= 0 then return false end
    if type(fighter.durability) ~= "number" or fighter.durability < 0 then return false end
    if type(fighter.maxVelocity) ~= "number" then return false end
    if type(fighter.turningSpeed) ~= "number" then return false end

    if not fighter.rarity or fighter.rarity.value == nil then return false end
    if not fighter.material or fighter.material.value == nil then return false end
    if fighter.weaponPrefix == nil then return false end

    return true
end

local function comp(a, b)
    local ta = a.fighter
    local tb = b.fighter

    if ta.type == tb.type then
        if ta.rarity.value == tb.rarity.value then
            if ta.material.value == tb.material.value then
                return ta.weaponPrefix < tb.weaponPrefix
            else
                return ta.material.value > tb.material.value
            end
        else
            return ta.rarity.value > tb.rarity.value
        end
    else
        return ta.type < tb.type
    end
end

function FighterMerchant.shop:addItems()
    local station = Entity()

    if station.title == "" then
        station.title = "Fighter Merchant"%_t
    end

     -- create all fighters
    local allFighters = {}
    local generator = SectorFighterGenerator()

    -- Nerfed from 33-66. With on-demand restocking, a smaller, curated selection is better.
    local fighterCount = 8 + math.floor(8 * random():getFloat())
    for i = 1, fighterCount do
        local x, y = Sector():getCoordinates()
        local fighter = generator:generate(x, y)

        if isFighterPriceSafe(fighter) then
            local pair = {}
            pair.fighter = fighter
            pair.amount = getInt(10, 30)
            table.insert(allFighters, pair)
        end
    end

    table.sort(allFighters, comp)

    for _, pair in pairs(allFighters) do
        FighterMerchant.shop:add(pair.fighter, pair.amount)
    end
end

-- sets the special offer that gets updated every 20 minutes
function FighterMerchant.shop:onSpecialOfferSeedChanged()
    local generator = SectorFighterGenerator(FighterMerchant.shop:generateSeed())

    local x, y = Sector():getCoordinates()
    local rarities = generator:getSectorRarityDistribution(x, y)

    rarities[-1] = 0
    rarities[0] = 0
    rarities[1] = 0
    rarities[4] = rarities[4] * 0.25 -- strongly reduced probability for normal high rarity equipment
    rarities[5] = 0 -- no legendaries in equipment dock

    generator.rarities = rarities

    local specialFighter = generator:generate(Sector():getCoordinates())
    if isFighterPriceSafe(specialFighter) then
        local amount = getInt(4, 6)
        FighterMerchant.shop:setSpecialOffer(specialFighter, amount)
    else
        FighterMerchant.shop:setSpecialOffer(nil, 0)
    end
end

function FighterMerchant.onShowWindow()
    if FighterMerchant.getShowTab() then
        FighterMerchant.shop.tabbedWindow:activateTab(FighterMerchant.shop.buyTab)
    else
        FighterMerchant.shop.tabbedWindow:deactivateTab(FighterMerchant.shop.buyTab)
    end
end

function FighterMerchant.getShowTab()
    local hangar = Hangar(Player().craft)
    if hangar and hangar.space > 0 then return true end

    local x, y = Sector():getCoordinates()
    local probability = Balancing_GetSingleMaterialProbability(x, y, MaterialType.Trinium)

    return probability > 0
end

function FighterMerchant.initialize()
    FighterMerchant.shop:initialize("Fighter Merchant"%_t)

    if onClient() and EntityIcon().icon == "" then
        EntityIcon().icon = "data/textures/icons/pixel/fighter.png"
    end
end

function FighterMerchant.initUI()
    FighterMerchant.shop:initUI("Trade Equipment"%_t, "Fighter Merchant"%_t, "Fighters"%_t, "data/textures/icons/bag_fighter.png")
end

FighterMerchant.shop.ItemWrapper = SellableFighter
FighterMerchant.shop.SortFunction = comp


function initialize(...)
    if FighterMerchant.initialize then return FighterMerchant.initialize(...) end
end