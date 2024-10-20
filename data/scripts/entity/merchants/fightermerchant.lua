package.path = package.path .. ";data/scripts/lib/?.lua"
include("galaxy")
include("utility")
include("randomext")
include("faction")
include("sellableinventoryitem")
include("stringutility")

-- Function to generate random amounts for fighters
local function getRandomFighterAmount(rarityValue)
    if rarityValue == RarityType.Exceptional then
        return getInt(25, 80)
    elseif rarityValue == RarityType.Rare then
        return getInt(25, 80)
    elseif rarityValue == RarityType.Uncommon then
        return getInt(25, 80)
    else -- Common fighters
        return getInt(25, 80)
    end
end

function FighterMerchant.shop:addItems()

    -- Simply init with a 'random' seed
    local station = Entity()

    -- Create all fighters
    local fighters = {}
    local generator = SectorFighterGenerator()

    local fNum = 33 + math.floor(33 * math.random())
    for i = 1, fNum do
        local x, y = Sector():getCoordinates()
        local fighter = generator:generate(x, y)

        local pair = {}
        pair.fighter = fighter
        pair.amount = getRandomFighterAmount(fighter.rarity.value)

        table.insert(fighters, pair)
    end

    table.sort(fighters, comp)

    for _, pair in pairs(fighters) do
        FighterMerchant.shop:add(pair.fighter, pair.amount)
    end
end

