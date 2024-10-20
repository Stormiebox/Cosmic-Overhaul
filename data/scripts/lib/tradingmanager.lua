-- Include necessary Avorion modules and libraries
package.path = package.path .. ";data/scripts/lib/?.lua"
include("galaxy")
include("utility")
include("goods")
include("stringutility")
include("faction")

function randomFloat(lesser, greater)
    return lesser + math.random() * (greater - lesser)
end

-- Custom function to determine station activity level
function TradingManager:getActivityLevel()
    local station = Entity()

    -- Base activity level on station type
    local stationType = station.title or "Generic" -- Station title fetch
    local baseActivityLevel = 5                    -- Default activity level

    -- Adjust activity level based on station type
    if stationType == "Trading Post" then
        baseActivityLevel = 8 -- Trading Posts has more activity
    elseif stationType == "Factory" then
        baseActivityLevel = 8 -- Factory has more activity
    elseif stationType == "Resource Depot" then
        baseActivityLevel = 8 -- Resource Depot has more activity
    elseif stationType == "Shipyard" then
        baseActivityLevel = 6 -- Shipyards has moderate activity
    elseif stationType == "Repair Dock" then
        baseActivityLevel = 6 -- Repair Docks has moderate activity
    elseif stationType == "Smuggler's Market" then
        baseActivityLevel = 6 -- Smuggler's Market has moderate activity
    elseif stationType == "Military Outpost" then
        baseActivityLevel = 4 -- Military Outposts has lower activity
    end

    -- Add some randomness based on the number of docking ships
    local shipsInSector = { Sector():getEntitiesByType(EntityType.Ship) }
    local dockedShips = math.min(#shipsInSector, 10) -- Cap the impact of docked ships to avoid excessive values

    return baseActivityLevel + dockedShips * randomFloat(0.1, 0.5)
end

function TradingManager:generateRevenue(good, amount)
    local price = self:getBuyPrice(good.name)
    local received = price * 1.10 * amount
    self.stats.moneyGainedFromGoods = self.stats.moneyGainedFromGoods + received
    local x, y = Sector():getCoordinates()
    local description = string.format(
        "\\s(%d:%d) %s's population consumed %d units of %s, generating ¢%s in revenue.",
        x, y, station.name, math.floor(amount),
        good:pluralForm(math.floor(amount)),
        createMonetaryString(received))
    local faction = Faction()
    if faction then
        faction:receive(description, received)
    end
end

function TradingManager:useUpBoughtGoods(timeStep)
    if not self.useUpGoodsEnabled then return end

    -- Dynamic tickTime based on custom activity level logic
    local activityLevel = self:getActivityLevel()
    local tickTime = 120 / activityLevel -- Higher activity reduces time between consumption events

    self.useTimeCounter = self.useTimeCounter + timeStep
    if self.useTimeCounter > tickTime then
        self.useTimeCounter = self.useTimeCounter - tickTime

        -- Process up to 2 goods per tick to distribute the load across multiple ticks
        local maxGoodsProcessed = 2
        for i = 1, maxGoodsProcessed do
            -- Select a random good from bought goods
            local good = self.boughtGoods[math.random(1, #self.boughtGoods)]
            if good then
                -- Determine the amount to consume based on stock and good type
                local inStock = self:getNumGoods(good.name)
                local consumptionMultiplier

                if good.name == "Food" or good.name == "Water" then
                    consumptionMultiplier = randomFloat(0.3, 0.5) -- Faster consumption for essentials
                elseif good.name == "Luxury Food" then
                    consumptionMultiplier = randomFloat(0.05, 0.15) -- Slower consumption for luxury goods
                else
                    consumptionMultiplier = randomFloat(0.1, 0.4) -- Default consumption rate
                end

                local amount = math.random(10, 60) + inStock * consumptionMultiplier
                amount = math.min(inStock, amount)

                if amount > 0 then
                    -- Decrease the goods in stock
                    self:decreaseGoods(good.name, amount)

                    -- Generate revenue for the faction
                    self:generateRevenue(good, amount)

                    -- Calculate the revenue and notify the faction
                    local price = self:getBuyPrice(good.name)
                    local received = price * 1.10 * amount
                    local x, y = Sector():getCoordinates()

                    -- Create detailed log messages for the transaction
                    local description = string.format(
                        "\\s(%d:%d) %s's population consumed %d units of %s, generating ¢%s in revenue.",
                        x, y, station.name, math.floor(amount),
                        good:pluralForm(math.floor(amount)),
                        createMonetaryString(received))

                    local faction = Faction()
                    if faction then
                        faction:receive(description, received)
                        self.stats.moneyGainedFromGoods = self.stats.moneyGainedFromGoods + received
                    end

                    break -- Exit loop after processing a valid good
                end
            end
        end
    end
end
