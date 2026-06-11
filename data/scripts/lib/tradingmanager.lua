-- Cosmic Overhaul Dynamic Stock Management starts here
local CaptainClass = include("captainclass")

function randomFloat(lesser, greater)
    return lesser + math.random() * (greater - lesser)
end

-- Custom function to determine station activity level
function TradingManager:getActivityLevel()
    local station = Entity()

    -- Base activity level on station type
    local stationType = station.title or "" -- Station title fetch
    local baseActivityLevel = 5             -- Default activity level

    -- Adjust activity level based on station type
    if stationType == "Trading Post" then
        baseActivityLevel = 8 -- Trading Posts have more activity
    elseif stationType == "Factory" then
        baseActivityLevel = 8 -- Factory has more activity
    elseif stationType == "Resource Depot" then
        baseActivityLevel = 8 -- Resource Depot has more activity
    elseif stationType == "Shipyard" then
        baseActivityLevel = 6 -- Shipyards have moderate activity
    elseif stationType == "Repair Dock" then
        baseActivityLevel = 6 -- Repair Docks have moderate activity
    elseif stationType == "Smuggler's Market" then
        baseActivityLevel = 6 -- Smuggler's Market has moderate activity
    elseif stationType == "Military Outpost" then
        baseActivityLevel = 4 -- Military Outposts have lower activity
    end

    -- Add some randomness based on the number of active ships in the sector
    local shipsInSector = { Sector():getEntitiesByType(EntityType.Ship) }
    local activeShips = math.min(#shipsInSector, 10) -- Cap the impact of ships to avoid excessive values

    return baseActivityLevel + activeShips * randomFloat(0.1, 0.5)
end

function TradingManager:generateRevenue(good, amount)
    local station = Entity()
    if not station then
        print("Error: Station is nil.")
        return
    end

    local price = self:getBuyPrice(good.name)
    local received = math.floor(price * 1.10 * amount)
    self.stats.moneyGainedFromGoods = self.stats.moneyGainedFromGoods + received

    local x, y = Sector():getCoordinates()
    local description = string.format(
        "\\s(%d:%d) %s's population consumed %d units of %s, generating ¢%s in revenue."%_T,
        x, y, station.name, math.floor(amount),
        tostring(good.name),
        createMonetaryString(received))

    local faction = Faction()
    if faction then
        faction:receive(description, received)
    else
        print("Error: Faction is nil.")
    end
end

function TradingManager:useUpBoughtGoods(timeStep)
    if not self.useUpGoodsEnabled then return end

    if #self.boughtGoods == 0 then return end

    -- Dynamic tickTime based on custom activity level logic
    local activityLevel = self:getActivityLevel()
    if activityLevel <= 0 then
        print("Warning: Activity level is zero or negative, skipping goods usage.")
        return
    end

    local tickTime = 120 / activityLevel -- Higher activity reduces time between consumption events

    self.useTimeCounter = self.useTimeCounter + timeStep
    if self.useTimeCounter > tickTime then
        self.useTimeCounter = 0

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
                    consumptionMultiplier = randomFloat(0.3, 0.5)   -- Faster consumption for essentials
                elseif good.name == "Luxury Food" then
                    consumptionMultiplier = randomFloat(0.05, 0.15) -- Slower consumption for luxury goods
                else
                    consumptionMultiplier = randomFloat(0.1, 0.4)   -- Default consumption rate
                end

                local amount = math.random(10, 60) + inStock * consumptionMultiplier
                amount = math.min(inStock, amount)

                if amount > 0 then
                    -- Decrease the goods in stock
                    self:decreaseGoods(good.name, amount)

                    -- Generate revenue for the faction
                    self:generateRevenue(good, amount)

                    -- Cosmic Overhaul <-> Cosmic Vault Synergy: Trigger a Market Boom occasionally for huge consumption
                    if amount >= 50 and math.random() < 0.15 then
                        local cve_success, cve = pcall(include, "cosmicvaulteconomy")
                        if cve_success and cve and cve.TriggerMarketEvent then
                            local x, y = Sector():getCoordinates()
                            cve.TriggerMarketEvent(good.name, x, y, 10, "boom")
                        end
                    end

                    break -- Exit loop after processing a valid good
                end
            end
        end
    end
end

-- Factory Tweaks
local base_restoreTradingGoods = TradingManager.restoreTradingGoods
function TradingManager:restoreTradingGoods(data)
    if base_restoreTradingGoods then base_restoreTradingGoods(self, data) end
    self.garbageStations = data.garbageStations or {}
end

local base_secureTradingGoods = TradingManager.secureTradingGoods
function TradingManager:secureTradingGoods()
    local data = {}
    if base_secureTradingGoods then data = base_secureTradingGoods(self) end
    data.garbageStations = self.garbageStations or {}
    return data
end

-- Merchant Captain Synergy: 15% discount when buying goods (Globally applied)
local original_getBuyPrice = TradingManager.getBuyPrice
function TradingManager:getBuyPrice(goodName, amount, faction, buyer)
    local price, tax
    if original_getBuyPrice then
        price, tax = original_getBuyPrice(self, goodName, amount, faction, buyer)
    end

    local player
    if onClient() then
        player = Player()
    elseif callingPlayer then
        player = Player(callingPlayer)
    end

    if player then
        local ship = player.craft
        if ship then
            local captain = ship:getCaptain()
            if captain and captain:hasClass(CaptainClass.Merchant) then
                price = math.max(1, math.floor((price or 0) * 1.15))
                if tax then tax = math.max(0, math.floor(tax * 1.15)) end
            end
        end
    end
    return price, tax
end

-- Merchant Captain Synergy: 15% bonus payout when selling goods (Globally applied)
local original_getSellPrice = TradingManager.getSellPrice
function TradingManager:getSellPrice(goodName, amount, faction, buyer)
    local price, tax
    if original_getSellPrice then
        price, tax = original_getSellPrice(self, goodName, amount, faction, buyer)
    end

    local player
    if onClient() then
        player = Player()
    elseif callingPlayer then
        player = Player(callingPlayer)
    end

    if player then
        local ship = player.craft
        if ship then
            local captain = ship:getCaptain()
            if captain and captain:hasClass(CaptainClass.Merchant) then
                price = math.max(1, math.floor((price or 0) * 0.85))
                if tax then tax = math.max(0, math.floor(tax * 0.85)) end
            end
        end
    end
    return price, tax
end
-- Cosmic Overhaul Dynamic Stock Management ends here