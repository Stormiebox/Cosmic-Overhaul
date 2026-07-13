package.path = package.path .. ";data/scripts/lib/?.lua"

include ("stringutility")
include ("goods")
include ("utility")
include ("randomext")
include ("merchantutility")
include ("stringutility")
include ("callable")
include ("relations")
local CaptainClass = include ("captainclass")
local TradingAPI = include ("tradingmanager")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace SmugglersMarket
SmugglersMarket = {}
include("cosmicui_proportionalsplitter")
SmugglersMarket = TradingAPI:CreateNamespace()
SmugglersMarket.trader.tax = 0.2
SmugglersMarket.trader.factionPaymentFactor = 0.0
SmugglersMarket.interactionThreshold = -80000
SmugglersMarket.syndicateHeat = 0

-- Cosmic Overhaul Black Market tuning knobs
SmugglersMarket.coConfig = {
    stolenBuyMultiplier = 0.75,      -- vanilla is 0.25
    illegalBuyMultiplier = 1.00,     -- allow non-stolen illegal goods at full base value
    dangerousBuyMultiplier = 0.60,   -- allow dangerous goods with a moderate multiplier
    unbrandPriceFactor = 0.40,       -- vanilla is 0.50 (cheaper unbranding = smoother gameplay loop)
}

local itemStart = 0
local numStolenItems = 0
local pageLabel
local brandLines = {}
local playerCargos = {}

function SmugglersMarket.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, SmugglersMarket.interactionThreshold)
end

function SmugglersMarket.generateInteractionText()
    local a = {
        "This is a free station, where everybody can mind their own business."%_t,
        "Best wares in the galaxy."%_t,
        "Welcome to the true, free market."%_t,
        "You'll find members for nearly everything on this station, if the coin is right."%_t,
    }
    local b = {
        "What do you want?"%_t,
        "If you get in trouble, it's your own fault."%_t,
        "Don't make any trouble."%_t,
        "I'm sure you'll find what you're looking for."%_t,
        "What's up?"%_t,
    }

    return randomEntry(random(), a) .. " " .. randomEntry(random(), b)
end

function SmugglersMarket.initialize()
    if onServer() then
        Sector():addScriptOnce("sector/traders.lua")

        local station = Entity()
        station:addScriptOnce("internal/dlc/blackmarket/entity/merchants/crackcontainers.lua")
        station:addScriptOnce("data/scripts/entity/merchants/smugglerbuildingknowledgemerchant.lua")

        if station.title == "" then
            station.title = "Smuggler's Market"%_t
        end
    end

    if onClient() then
        EntityIcon().icon = "data/textures/icons/pixel/crate.png"
        InteractionText().text = SmugglersMarket.generateInteractionText()
    end
end

function SmugglersMarket.getUpdateInterval()
    return 60.0 -- Update every 60 seconds
end

function SmugglersMarket.updateServer(timeStep)
    local station = Entity()
    if not station or not station:getValue("governor_smuggler_active") then return end

    local totalUnbranded = 0
    -- The Fence System: Automatically unbrand up to 100 stolen goods per minute natively
    local cargos = station:getCargos()
    for good, amount in pairs(cargos) do
        if good.stolen and totalUnbranded < 100 then
            local unbrandAmount = math.min(amount, 100 - totalUnbranded)
            local cleanGood = copy(good)
            cleanGood.stolen = false

            station:removeCargo(good, unbrandAmount)
            station:addCargo(cleanGood, unbrandAmount)

            totalUnbranded = totalUnbranded + unbrandAmount
        end
    end

    if totalUnbranded > 0 then
        SmugglersMarket.syndicateHeat = (SmugglersMarket.syndicateHeat or 0) + totalUnbranded
        if SmugglersMarket.syndicateHeat >= 5000 then
            local now = Server().unpausedRuntime
            if not SmugglersMarket.lastRaidTime or now - SmugglersMarket.lastRaidTime > 3600 then
                SmugglersMarket.syndicateHeat = 0
                SmugglersMarket.lastRaidTime = now
                Sector():broadcastChatMessage(station.title, 2, "Syndicate Heat Critical. Fencing operation detected. Sector Lockdown Imminent.")
                Sector():addScriptOnce("data/scripts/events/pirateattack.lua")
                Sector():addScriptOnce("data/scripts/events/factionattackssmugglers.lua")
            else
                SmugglersMarket.syndicateHeat = 5000 -- Cap heat while on cooldown
            end
        end
    end
end

function SmugglersMarket.secure()
    return { syndicateHeat = SmugglersMarket.syndicateHeat, lastRaidTime = SmugglersMarket.lastRaidTime }
end

function SmugglersMarket.restore(data)
    SmugglersMarket.syndicateHeat = data.syndicateHeat or 0
    SmugglersMarket.lastRaidTime = data.lastRaidTime or 0
end

function SmugglersMarket.initializationFinished()
    -- use the initilizationFinished() function on the client since in initialize() we may not be able to access Sector scripts on the client
    if onClient() then
        local ok, r = Sector():invokeFunction("radiochatter", "addSpecificLines", Entity().id.string,
        {
            "Pssst! You wanna take a look?"%_t,
            "Everything's legal here, of course. As long as you don't look too closely..."%_t,
            "Oh. That must have gotten lost."%_t,
            "You bring 'em, we crack 'em. Secured Containers only."%_t,
            "We do Secured Containers only, we don't want no bug infestations."%_t,
        })
    end
end

function SmugglersMarket.initUI()

    local res = getResolution()
    local size = vec2(950, 600)

    local menu = ScriptUI()
    local window = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))

    window.caption = "Smuggler's Market"%_t
    window.showCloseButton = 1
    window.moveable = 1
    menu:registerWindow(window, "Unbrand Stolen Goods"%_t, 10);

    -- create a tabbed window inside the main window
    local tabbedWindow = window:createTabbedWindow(Rect(vec2(10, 10), size - 10))

    -- create unbrand tab
    local brandTab = tabbedWindow:createTab("Unbrand"%_t, "data/textures/icons/domino-mask.png", "Unbrand Stolen Goods"%_t)

    local lister = UIVerticalLister(Rect(tabbedWindow.size), 5, 0)
    local rect = lister:placeCenter(vec2(lister.inner.width, 21))

    local vasplit1 = CosmicUIVerticalProportionalSplitter(rect, 10, 0, {0.8, 0.1, 0.1})
    local vasplit2 = CosmicUIVerticalProportionalSplitter(vasplit1.partitions[1], 10, 0, {0.55, 0.06, 0.22, 0.17})

    brandTab:createLabel(vasplit2.partitions[1].lower + vec2(10, 0), "NAME"%_t, 15)
    brandTab:createLabel(vasplit2.partitions[3].lower + vec2(10, 0), "PRICE/U"%_t, 15)
    brandTab:createLabel(vasplit2.partitions[4].lower + vec2(10, 0), "YOU"%_t, 15)

    -- buttons and labels for page turning
    brandTab:createButton(Rect(0, size.y - 100, 70, size.y - 70), "<", "onPageLeftButtonPressed")
    brandTab:createButton(Rect(size.x - 90, size.y - 100, size.x - 20, size.y - 70), ">", "onPageRightButtonPressed")

    pageLabel = brandTab:createLabel(vec2(), "", 20)
    pageLabel.lower = brandTab.lower + vec2(0, size.y - 100)
    pageLabel.upper = brandTab.lower + vec2(size.x, size.y - 70)
    pageLabel.centered = 1

    brandLines = {}
    for i = 1, 13 do
        local line = {}
        local rect = lister:placeCenter(vec2(lister.inner.width, 30))

        local vasplit1 = CosmicUIVerticalProportionalSplitter(rect, 10, 0, {0.8, 0.1, 0.1})
        line.frame = brandTab:createFrame(vasplit1.partitions[1])

        line.numbers = brandTab:createTextBox(vasplit1.partitions[2], "onUnbrandTextEntered")
        line.button = brandTab:createButton(vasplit1.partitions[3], "Unbrand"%_t, "onUnbrandClicked")
        line.button.maxTextSize = 16

        local vasplit2 = CosmicUIVerticalProportionalSplitter(vasplit1.partitions[1], 10, 0, {0.55, 0.06, 0.22, 0.17})

        line.name = brandTab:createLabel(vasplit2.partitions[1].lower + vec2(10, 6), "Name"%_t, 15)
        line.icon = brandTab:createPicture(vasplit2.partitions[2], "")
        line.price = brandTab:createLabel(vasplit2.partitions[3].lower + vec2(10, 6), "560.501", 15)
        line.you = brandTab:createLabel(vasplit2.partitions[4].lower + vec2(10, 6), "750", 15)

        line.icon.isIcon = 1
        line.numbers.clearOnClick = 1
        line.numbers.allowedCharacters = "0123456789"

        line.hide = function(self)
            self.frame:hide()
            self.numbers:hide()
            self.button:hide()
            self.name:hide()
            self.icon:hide()
            self.price:hide()
            self.you:hide()
        end

        line.show = function(show)
            show.frame:show()
            show.numbers:show()
            show.button:show()
            show.name:show()
            show.icon:show()
            show.price:show()
            show.you:show()
        end

        table.insert(brandLines, line)
    end

    -- create sell tab
    local sellTab = tabbedWindow:createTab("Sell"%_t, "data/textures/icons/sell.png", "Sell Stolen Goods"%_t)
    SmugglersMarket.buildSellGui(sellTab)
    SmugglersMarket.trader.guiInitialized = true

    SmugglersMarket.setCrewInteractionThresholds()
end

function SmugglersMarket.setCrewInteractionThresholds()
    if onClient() then
        invokeServerFunction("setCrewInteractionThresholds")
    end

    Entity():invokeFunction("data/scripts/entity/crewboard.lua", "overrideRelationThreshold", -200000)
end
callable(SmugglersMarket, "setCrewInteractionThresholds")

function SmugglersMarket.onShowWindow()
    local buyer = Player()
    local ship = buyer.craft
    if ship.factionIndex == buyer.allianceIndex then
        buyer = buyer.alliance
    end

    -- read cargos and sort
    local cargos = {}
    for good, amount in pairs(ship:getCargos()) do
        table.insert(cargos, {good = good, amount = amount})
    end

    function comp(a, b) return a.good.name < b.good.name end
    table.sort (cargos, comp)

    for _, line in pairs(SmugglersMarket.trader.boughtLines) do
        line:hide();
        line.number.text = "0"
    end
    for _, line in pairs(brandLines) do
        line:hide();
        line.numbers.text = "0"
    end

    SmugglersMarket.trader.boughtGoods = {}
    local faction = Faction()
    local boughtGoods = SmugglersMarket.trader.boughtGoods
    local i = 1
    local itemOffset = 0
    local stolenGoods = {}

    for _, p in pairs(cargos) do
        local good, amount = p.good, p.amount

        if good.stolen or good.name == "Rift Research Data" or good.name == "Subclass Subsystem" then
            table.insert(stolenGoods, p)
            if i - 1 < itemStart then
                i = i + 1
            else

                if i - itemStart <= #brandLines then
                    -- do sell lines
                    local line = SmugglersMarket.trader.boughtLines[i - itemStart]
                    line:show()
                    line.icon.picture = good.icon
                    line.name.caption = good:displayName(2)
                    line.price.caption = createMonetaryString(round(SmugglersMarket.getStolenBuyPrice(good.name, ship)))
                    line.size.caption = round(good.size, 2)
                    line.you.caption = amount
                    line.stock.caption = "   -"

                    boughtGoods[i - itemStart] = good

                    -- do unbranding lines
                    local line = brandLines[i - itemStart]

                    line:show()
                    line.icon.picture = good.icon
                    line.name.caption = good:displayName(2)

                    local unbrandPrice = SmugglersMarket.getUnbrandPriceAndTax(good.price, 1, faction, buyer, ship)
                    line.price.caption = createMonetaryString(round(unbrandPrice))
                    line.numbers.text = amount

                    line.you.caption = amount
                end

                i = i + 1
            end
        end
    end

    -- if the player has no stolen goods
    if #stolenGoods == 0 then
        -- the sell stolen goods tab
        local line = SmugglersMarket.trader.boughtLines[1]
        line:show()
        line.name.caption = "You have no stolen goods on you."%_t
        line.price.caption = ""
        line.you.caption = ""
        line.stock.caption = ""
        line.size.caption = ""
        line.icon:hide()
        line.button:hide()
        line.number:hide()
        -- the unbrand stolen goods tab
        local lineBrand = brandLines[1]
        lineBrand:show()
        lineBrand.name.caption = "You have no stolen goods on you."%_t
        lineBrand.price.caption = ""
        lineBrand.you.caption = ""
        lineBrand.icon:hide()
        lineBrand.button:hide()
        lineBrand.numbers:hide()
    end

    -- update page label caption
    numStolenItems = i - 1

    local itemEnd = math.min(numStolenItems, itemStart + #brandLines)
    local itemStartText = math.min(itemStart + 1, itemEnd)
    pageLabel.caption = itemStartText .. " - " .. itemEnd .. " / " .. numStolenItems
end

function SmugglersMarket.onPageLeftButtonPressed()
    itemStart = itemStart - #brandLines
    itemStart = math.max(itemStart, 0)
    SmugglersMarket.onShowWindow()
end

function SmugglersMarket.onPageRightButtonPressed()
    local itemsPerPage = #brandLines

    local page = itemStart / itemsPerPage
    page = math.min(page + 1, math.ceil(numStolenItems / itemsPerPage) - 1)
    page = math.max(page, 0)
    itemStart = page * itemsPerPage

    include("cosmicvaultdebug").info("Cosmic Overhaul", "page: " .. page .. ", " .. itemStart .. ", num: " .. (numStolenItems / itemsPerPage))

    SmugglersMarket.onShowWindow()
end

function SmugglersMarket.onUnbrandTextEntered(textBox)
    local self = SmugglersMarket.trader

    local enteredNumber = tonumber(textBox.text)
    if enteredNumber == nil then
        enteredNumber = 0
    end

    local newNumber = enteredNumber

    local ship = Player().craft
    local msg

    local goodIndex = nil
    for i, line in pairs(brandLines) do
        if line.numbers.index == textBox.index then
            goodIndex = i
            break
        end
    end
    if goodIndex == nil then return end

    local good = self.boughtGoods[goodIndex]
    if not good then
        include("cosmicvaultdebug").info("Cosmic Overhaul", "good with index " .. goodIndex .. " can't be unbranded")
        printEntityDebugInfo();
        return
    end

    -- make sure the player does not sell more than he has in his cargo bay
    local amountOnPlayerShip = ship:getCargoAmount(good)
    if amountOnPlayerShip == nil then return end --> no cargo bay

    if amountOnPlayerShip < newNumber then
        newNumber = amountOnPlayerShip
        if newNumber == 0 then
            msg = "You don't have any of this!"%_t
        end
    end

    if msg then
        self:sendError(nil, msg)
    end

    -- maximum number of unbrandable things is the amount the player has on his ship
    if newNumber ~= enteredNumber then
        textBox.text = newNumber
    end
end

function SmugglersMarket.onSellTextEntered(textBox)
    local self = SmugglersMarket.trader

    local enteredNumber = tonumber(textBox.text)
    if enteredNumber == nil then
        enteredNumber = 0
    end

    local newNumber = enteredNumber

    local goodIndex = nil
    for i, line in pairs(self.boughtLines) do
        if line.number.index == textBox.index then
            goodIndex = i
            break
        end
    end
    if goodIndex == nil then return end

    local good = self.boughtGoods[goodIndex]
    if not good then
        include("cosmicvaultdebug").info("Cosmic Overhaul", "good with index " .. goodIndex .. " isn't bought")
        printEntityDebugInfo();
        return
    end

    local ship = Player().craft
    local msg

    -- make sure the player does not sell more than he has in his cargo bay
    local amountOnPlayerShip = ship:getCargoAmount(good)
    if amountOnPlayerShip == nil then return end --> no cargo bay

    if amountOnPlayerShip < newNumber then
        newNumber = amountOnPlayerShip
        if newNumber == 0 then
            msg = "You don't have any of this!"%_t
        end
    end

    if msg then
        self:sendError(nil, msg)
    end

    -- maximum number of sellable things is the amount the player has on his ship
    if newNumber ~= enteredNumber then
        textBox.text = newNumber
    end
end

function SmugglersMarket.onSellButtonPressed(button)
    local self = SmugglersMarket.trader

    local shipIndex = Player().craftIndex
    local goodIndex = nil

    for i, line in ipairs(self.boughtLines) do
        if line.button.index == button.index then
            goodIndex = i
        end
    end

    if goodIndex == nil then
        return
    end

    local amount = self.boughtLines[goodIndex].number.text
    if amount == "" then
        amount = 0
    else
        amount = tonumber(amount)
    end

    local good = self.boughtGoods[goodIndex]
    if not good then
        include("cosmicvaultdebug").info("Cosmic Overhaul", "internal error, good with index " .. goodIndex .. " of sell button not found.")
        printEntityDebugInfo()
        return
    end

    invokeServerFunction("buyIllegalGood", good.name, amount)
end

function SmugglersMarket.buyIllegalGood(goodName, amount)

    if not CheckFactionInteraction(callingPlayer, SmugglersMarket.interactionThreshold) then return end

    if anynils(goodName, amount) then return end

    local seller, ship, player = getInteractingFaction(callingPlayer, AlliancePrivilege.AddResources, AlliancePrivilege.SpendItems)
    if not seller then return end

    local self = SmugglersMarket.trader

    -- check if the specific good from the player can be bought
    local cargos = ship:findCargos(goodName)
    local good = nil
    local msg

    for g, amount in pairs(cargos) do
        local ok
        ok, msg = self:isBoughtBySelf(g)

        -- Cosmic Overhaul: accept stolen OR illegal OR dangerous cargo for the black market loop
        if ok and (g.stolen or g.illegal or g.dangerous or g.name == "Rift Research Data" or g.name == "Subclass Subsystem") then
            good = g
            break
        end
    end

    msg = msg or "You don't have any %s to sell!"%_t
    if not good then
        self:sendError(seller, msg, goodName)
        return
    end

    local station = Entity()
    local stationFaction = Faction()

    -- make sure the player does not sell more than he has in his cargo bay
    local amountOnShip = ship:getCargoAmount(good)

    if amountOnShip < amount then
        amount = amountOnShip

        if amountOnShip == 0 then
            self:sendError(seller, "You don't have any %s on your ship."%_t, good:displayName(0))
        end
    end

    if amount == 0 then
        return
    end

    -- begin transaction
    -- calculate price
    local price = SmugglersMarket.getStolenBuyPrice(good.name, ship) * amount

    if not noDockCheck then
        -- test the docking last so the player can know what he can buy from afar already
        local errors = {}
        errors[EntityType.Station] = "You must be docked to the station to trade."%_T
        errors[EntityType.Ship] = "You must be closer to the ship to trade."%_T
        if not CheckShipDocked(seller, ship, station, errors) then
            return
        end
    end

    local x, y = Sector():getCoordinates()

    local toDescription = Format("\\s(%1%:%2%) %3% sold %4% %5% to some shady figure for %6% Credits."%_T,
            x, y, ship.name, amount, good:pluralForm(amount), createMonetaryString(price))

    -- give money to ship faction
    seller:receive(toDescription, price)

    -- give tax to station owner
    receiveTransactionTax(station, price * self.tax)

    -- log tax
    local tax = round(price * self.tax)
    if tax > 0 then
        self.stats.moneyGainedFromTax = self.stats.moneyGainedFromTax + tax
    end

    -- remove goods from ship
    ship:removeCargo(good, amount)
    -- the goods just disappear, since they are being sold to "a shady figure"

    -- trading (non-military) ships get higher relation gain
    local relationsChange = GetRelationChangeFromMoney(price)
    if ship:getNumArmedTurrets() <= 1 then
        relationsChange = relationsChange * 1.5
    end

    -- Cosmic Chronicles - Black Market Rift Trade rep consequence
    if good.name == "Rift Research Data" or good.name == "Subclass Subsystem" then
        -- Fencing highly sensitive rift technology damages your reputation with the local faction slightly
        local localFaction = Galaxy():getControllingFaction(x, y)
        if localFaction and localFaction > 0 and localFaction ~= stationFaction.index then
            local f = Faction(localFaction)
            if f and f.isAIFaction then
                changeRelations(seller, f, -2500, RelationChangeType.Smuggling, nil, nil, station)
                seller:sendChatMessage(f.name, 1, "We are aware you are fencing classified Rift Technology to the black market. Cease this immediately."%_t)
            end
        end
    end

    changeRelations(seller, stationFaction, relationsChange, RelationChangeType.Commerce, nil, nil, station)

    invokeClientFunction(Player(callingPlayer), "onShowWindow")
end
callable(SmugglersMarket, "buyIllegalGood")

function SmugglersMarket.onUnbrandClicked(button)
    local boughtGoods = SmugglersMarket.trader.boughtGoods

    for i, line in pairs(brandLines) do
        if line.button.index == button.index then
            invokeServerFunction("unbrand", boughtGoods[i].name, tonumber(line.numbers.text))
        end
    end
end

function SmugglersMarket.unbrand(goodName, amount)

    if not CheckFactionInteraction(callingPlayer, SmugglersMarket.interactionThreshold) then return end

    if anynils(goodName, amount) then return end

    local buyer, ship, player = getInteractingFaction(callingPlayer, AlliancePrivilege.SpendResources)
    if not buyer then return end

    amount = math.max(amount or 0, 0)

    local station = Entity()

    local cargos = ship:findCargos(goodName)
    local good = nil
    for g, cargoAmount in pairs(cargos) do
        if g.stolen then
            good = g
            amount = math.min(cargoAmount, amount)
            break
        end
    end

    if not good then
        SmugglersMarket.sendError(player, "You don't have any stolen %s!"%_t, goodName)
        return
    end

    local price, tax = SmugglersMarket.getUnbrandPriceAndTax(good.price, amount, Faction(), buyer, ship)

    local canPay, msg, args = buyer:canPay(price)
    if not canPay then
        SmugglersMarket.sendError(player, msg, unpack(args))
        return
    end

    if not station:isInDockingArea(ship) then
        SmugglersMarket.sendError(player, "You have to be docked to the station to unbrand goods!"%_t)
        return
    end

    -- pay and exchange
    receiveTransactionTax(station, tax)

    buyer:pay("Paid %1% Credits to unbrand stolen goods."%_T, price)

    local purified = copy(good)
    purified.stolen = false

    ship:removeCargo(good, amount)
    ship:addCargo(purified, amount)

    invokeClientFunction(player, "onShowWindow")
end
callable(SmugglersMarket, "unbrand")

function SmugglersMarket.getUnbrandPriceAndTax(goodPrice, num, stationFaction, buyerFaction, ship)
    local factor = SmugglersMarket.coConfig.unbrandPriceFactor

    local station = Entity()
    if station and station:getValue("governor_smuggler_active") then
        factor = factor * 0.5 -- 50% extra discount if Smuggler is Governor!
    end

    if stationFaction.index == buyerFaction.index then
        factor = factor * 0.1 -- Syndicate Boss: 90% discount on unbranding fees at your own station!
    elseif ship then
        local captain = ship:getCaptain()
        if captain and captain:hasClass(CaptainClass.Smuggler) then
            factor = math.max(0.10, factor - 0.15) -- Smuggler Synergy: 15% discount on unbranding fees
        end
    end

    local price = num * round(goodPrice * factor)
    local tax = round(price * SmugglersMarket.trader.tax)

    if stationFaction.index == buyerFaction.index then
        price = price - tax
        -- don't pay out for the second time
        tax = 0
    end

    return price, tax
end

function SmugglersMarket.getUnbrandPriceAndTaxTest(goodPrice, num)
    return SmugglersMarket.getUnbrandPriceAndTax(goodPrice, num, Faction(), Faction(Player(callingPlayer).craft.factionIndex), Player(callingPlayer).craft)
end

function SmugglersMarket.receiveGoods()
    SmugglersMarket.onShowWindow()
end

function SmugglersMarket.trader:isBoughtBySelf(good)
    local original = goods[good.name]
    if not original then
        return false, "You can't sell ${displayPlural} here."%_t % {displayPlural = good:displayName(2)}
    end

    return true
end

SmugglersMarket.oldBuyFromShip = SmugglersMarket.buyFromShip
function SmugglersMarket.buyFromShip(...)
    SmugglersMarket.oldBuyFromShip(...)
    invokeClientFunction(Player(callingPlayer), "onShowWindow")
end

-- price for which goods are bought from players
function SmugglersMarket.getStolenBuyPrice(goodName, ship)
    local good = goods[goodName]
    if not good then return 0 end

    -- Cosmic Overhaul Black Market multipliers
    local multiplier = SmugglersMarket.coConfig.stolenBuyMultiplier
    if good.illegal then
        multiplier = SmugglersMarket.coConfig.illegalBuyMultiplier
    elseif good.dangerous then
        multiplier = SmugglersMarket.coConfig.dangerousBuyMultiplier
    end

    if ship then
        local captain = ship:getCaptain()
        if captain and captain:hasClass(CaptainClass.Smuggler) then
            multiplier = multiplier + 0.15 -- Smuggler Synergy: 15% bonus payout on stolen/illegal goods
        end
        local station = Entity()
        if station and station.factionIndex == ship.factionIndex then
            multiplier = multiplier + 0.25 -- Syndicate Boss: 25% extra profit for owning the market!
        end
        if station and station:getValue("governor_smuggler_active") then
            multiplier = multiplier + 0.35 -- Smuggler Governor: 35% extra profit!
        end
    end

    -- Cosmic Overhaul/Ascendancy: Eclipse Contraband Premium
    if goodName == "Ascendant Matter" or goodName == "Eclipse Datacore" then
        multiplier = multiplier * 1.5
    end

    -- Cosmic Chronicles - Black Market Rift Trade
    if goodName == "Rift Research Data" or goodName == "Subclass Subsystem" then
        multiplier = multiplier * random():getFloat(2.0, 3.0)
    end

    return round(good.price * multiplier)
end



