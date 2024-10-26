package.path = package.path .. ";data/scripts/lib/?.lua"
include ("galaxy")
include ("utility")
include ("randomext")
include ("faction")
include ("stringutility")
include ("weapontype")
local Multiplier = 25
local ShopAPI = include ("shop")
local SectorTurretGenerator = include ("sectorturretgenerator")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace TurretMerchant
TurretMerchant = {}
TurretMerchant = ShopAPI.CreateNamespace()
TurretMerchant.interactionThreshold = -30000

TurretMerchant.rarityFactors = {}
TurretMerchant.rarityFactors[-1] = 0.5 -- Reduced probability from 1.0 to 0.5
TurretMerchant.rarityFactors[0] = 0.5  -- Reduced probability from 1.0 to 0.5
TurretMerchant.rarityFactors[1] = 0.5  -- Reduced probability from 1.0 to 0.5
TurretMerchant.rarityFactors[2] = 1.0
TurretMerchant.rarityFactors[3] = 1.0
TurretMerchant.rarityFactors[4] = 1.0
TurretMerchant.rarityFactors[5] = 1.0

TurretMerchant.specialOfferRarityFactors = {}
TurretMerchant.specialOfferRarityFactors[-1] = 0.0
TurretMerchant.specialOfferRarityFactors[0] = 0.0
TurretMerchant.specialOfferRarityFactors[1] = 0.0
TurretMerchant.specialOfferRarityFactors[2] = 1.0
TurretMerchant.specialOfferRarityFactors[3] = 1.0
TurretMerchant.specialOfferRarityFactors[4] = 0.5  -- Increased probability from 0.25 to 0.5
TurretMerchant.specialOfferRarityFactors[5] = 0.25  -- Increased probabilityfrom 0.00 to 0.25

-- if this function returns false, the script will not be listed in the interaction window,
-- even though its UI may be registered
function TurretMerchant.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, TurretMerchant.interactionThreshold)
end

local function comp(a, b)
    local ta = a.turret;
    local tb = b.turret;

    if ta.rarity.value == tb.rarity.value then
        if ta.material.value == tb.material.value then
            return ta.weaponPrefix < tb.weaponPrefix
        else
            return ta.material.value > tb.material.value
        end
    else
        return ta.rarity.value > tb.rarity.value
    end
end

function TurretMerchant.shop:addItems()

    -- simply init with a 'random' seed
    local station = Entity()

    -- create all turrets
    local turrets = {}

    local x, y = Sector():getCoordinates()
    local generator = SectorTurretGenerator()
    generator.rarities = generator:getSectorRarityDistribution(x, y)

    for i, rarity in pairs(generator.rarities) do
        generator.rarities[i] = rarity * TurretMerchant.rarityFactors[i] or 1
    end

    for i = 1, (13*Multiplier) do
        local turret = InventoryTurret(generator:generate(x, y))
        local amount = 1
        if i == 1 then
            turret = InventoryTurret(generator:generate(x, y, nil, nil, WeaponType.MiningLaser))
            amount = 2
        elseif i == 2 then
            turret = InventoryTurret(generator:generate(x, y, nil, nil, WeaponType.PointDefenseChainGun))
            amount = 2
        elseif i == 3 then
            turret = InventoryTurret(generator:generate(x, y, nil, nil, WeaponType.ChainGun))
            amount = 2
        elseif i == 4 then
            turret = InventoryTurret(generator:generate(x, y, nil, nil, WeaponType.RawMiningLaser))
            amount = 2
        elseif i == 5 then
            turret = InventoryTurret(generator:generate(x, y, nil, nil, WeaponType.SalvagingLaser))
            amount = 2
        elseif i == 6 then
            turret = InventoryTurret(generator:generate(x, y, nil, nil, WeaponType.RawSalvagingLaser))
            amount = 2
        elseif i == 7 then
            turret = InventoryTurret(generator:generate(x, y, nil, nil, WeaponType.Bolter))
            amount = 2
        elseif i == 8 then
            turret = InventoryTurret(generator:generate(x, y, nil, nil, WeaponType.ForceGun))
            amount = 2
        elseif i == 9 then
            turret = InventoryTurret(generator:generate(x, y, nil, nil, WeaponType.Laser))
            amount = 2
        elseif i == 10 then
            turret = InventoryTurret(generator:generate(x, y, nil, nil, WeaponType.PointDefenseLaser))
            amount = 2
        elseif i == 11 then
            turret = InventoryTurret(generator:generate(x, y, nil, nil, WeaponType.PlasmaGun))
            amount = 2
        elseif i == 12 then
            turret = InventoryTurret(generator:generate(x, y, nil, nil, WeaponType.PulseCannon))
            amount = 2
        elseif i == 13 then
            turret = InventoryTurret(generator:generate(x, y, nil, nil, WeaponType.AntiFighter))
            amount = 2
        end

        local pair = {}
        pair.turret = turret
        pair.amount = amount

        if turret.rarity.value == -1 then    -- Petty
            pair.amount = math.random(11, 35)
        elseif turret.rarity.value == 0 then -- Common
            pair.amount = math.random(9, 25)
        elseif turret.rarity.value == 1 then -- Uncommon
            pair.amount = math.random(7, 15)
        elseif turret.rarity.value == 2 then -- Rare
            pair.amount = math.random(5, 9)
        elseif turret.rarity.value == 3 then -- Exceptional
            pair.amount = math.random(2, 4)
        elseif turret.rarity.value == 4 then -- Exotic
            pair.amount = math.random(1, 3)
        elseif turret.rarity.value == 5 then -- Legendary
            pair.amount = math.random(1, 2)
        end

        table.insert(turrets, pair)
    end

    table.sort(turrets, comp)

    for _, pair in pairs(turrets) do
        TurretMerchant.shop:add(pair.turret, pair.amount)
    end
end

-- sets the special offer that gets updated every 20 minutes
function TurretMerchant.shop:onSpecialOfferSeedChanged()
    local generator = SectorTurretGenerator(TurretMerchant.shop:generateSeed())

    local x, y = Sector():getCoordinates()
    local rarities = generator:getSectorRarityDistribution(x, y)

    for i, rarity in pairs(rarities) do
        rarities[i] = rarity * TurretMerchant.specialOfferRarityFactors[i] or 1
    end

    generator.rarities = rarities

    local specialOfferTurret = InventoryTurret(generator:generate(x, y))
    TurretMerchant.shop:setSpecialOffer(specialOfferTurret)
end

function TurretMerchant.initialize()

    local station = Entity()
    if station.title == "" then
        station.title = "Turret Merchant"%_t
    end

    TurretMerchant.shop:initialize(station.translatedTitle)

    if onClient() and EntityIcon().icon == "" then
        EntityIcon().icon = "data/textures/icons/pixel/turret.png"
    end
end

function TurretMerchant.initUI()
    local station = Entity()
    TurretMerchant.shop:initUI("Trade Equipment"%_t, station.translatedTitle, "Turrets"%_t, "data/textures/icons/bag_turret.png")
end
