-- Utility function injected for Factory Tweaks

function getUpdateInterval()
    return 5.0
end

local function timer(current, period, deltaTime)
    local hasFired = false
    current = current + deltaTime
    if current >= period then
        current = current - period
        hasFired = true
    end
    return {hasFired=hasFired, newTime = current}
end

local next = next
local ternary = function(condition, trueValue, falseValue)
    if condition then return trueValue else return falseValue end
end

-- Overrides
local base_secure = Factory.secure
local base_restore = Factory.restore
local base_initialize = Factory.initialize
local base_sync = Factory.sync
local base_updateServer = Factory.updateServer
local base_updateProduction = Factory.updateProduction
local base_onRemove = Factory.onRemove

local base_getShuttleUpgradeCost = Factory.getShuttleUpgradeCost
local base_onUpgradeShuttlesButtonPressed = Factory.onUpgradeShuttlesButtonPressed

local base_onShowWindow = Factory.onShowWindow
local base_buildConfigUI = Factory.buildConfigUI
local base_refreshConfigUI = Factory.refreshConfigUI
local base_refreshConfigCombos = Factory.refreshConfigCombos
local base_sendDeliveryErrors = Factory.sendDeliveryErrors
local base_renderUIIndicator = Factory.renderUIIndicator

local base_setProduction = Factory.setProduction
local base_requestTraders = Factory.requestTraders
local base_updateDeliveryToOtherStations = Factory.updateDeliveryToOtherStations
local base_updateFetchingFromOtherStations = Factory.updateFetchingFromOtherStations

-- Local values for this mod go here
local ft_minVolume = 10
local ft_maxGates = 4
local ft_gateTradeMult = 0.25
Factory.MinShuttleVolume = ft_minVolume
Factory.shuttleVolume = ft_minVolume

-- Factory Overview Telemetry Variables
local fo_refreshFrequency = 10
local fo_runtime = 0
local fo_refreshTime = fo_refreshFrequency
local fo_productionStateRegister = {}

local garbageStations = {}
local garbageStationCombo = nil
local garbageStationErrorLabel = nil
local garbageDeliveryError = ""
local garbageDeliveryErrorOld = ""
local garbageDeliveryErrorCode = 0
local numGarbageGoods = 0
local garbageVolumeByGood = nil
Factory.trader.garbageStations = {}
Factory.garbageDeliveryTimer = 0
Factory.garbageDeliveryInterval = 30.0

function Factory.getProductionVolume()
    local function volumeFromProductionParts(parts)
        local totalVolume = 0
        for _, productionPart in pairs(parts) do
            for _, productionGood in pairs(productionPart) do
                local size = 1
                if goods[productionGood.name] then size = goods[productionGood.name].size end
                local space = size * productionGood.amount
                totalVolume = totalVolume + space
            end
        end
        return totalVolume
    end

    local spaceForInput = volumeFromProductionParts({production.ingredients})
    local spaceForOutput = volumeFromProductionParts({production.results, production.garbages})
    return math.max(spaceForInput, spaceForOutput)
end

function Factory.updateGarbageVolumes()
    numGarbageGoods = 0
    garbageVolumeByGood = {}
    for _, garbage in pairs(production.garbages) do
        local size = 1
        if goods[garbage.name] then size = goods[garbage.name].size end
        numGarbageGoods = numGarbageGoods + garbage.amount
        garbageVolumeByGood[garbage.name] = { size = size, count = garbage.amount }
    end
end

function Factory.isDockedTo(station)
    local self = Entity()
    local isDocked = station.dockingParent == self.id or self.dockingParent == station.id
    local sharesParent = station.dockingParent and self.dockingParent and station.dockingParent == self.dockingParent
    return isDocked or sharesParent
end

function Factory.applyShuttleVolume(data)
    if not data then
        data = {}
        data.shuttleVolume = Factory.shuttleVolume
        data.MinShuttleVolume = Factory.MinShuttleVolume
        data.maxNumProductions = Factory.maxNumProductions
    end

    local totalProductionVolume = data.MinShuttleVolume or ft_minVolume
    if production then totalProductionVolume = Factory.getProductionVolume() end

    local exportsPerMinute = 60 / Factory.SectorTradeInterval
    local productionsPerMinute = (60 / Factory.MinimumTimeToProduce)
    local upgradeInterval = math.ceil((productionsPerMinute * totalProductionVolume) / exportsPerMinute)

    upgradeInterval = math.max(upgradeInterval, ft_minVolume)

    Factory.MinShuttleVolume = upgradeInterval
    Factory.MaxShuttleVolume = upgradeInterval * data.maxNumProductions
    if Entity():getValue("governor_engineer_active") then
        Factory.MaxShuttleVolume = Factory.MaxShuttleVolume * 1.5 -- Engineer Governor boosts logistics capacity!
    end
    Factory.shuttleVolume = math.min(math.max(data.shuttleVolume, totalProductionVolume), Factory.MaxShuttleVolume)
end

function Factory.setProduction(production_in, size)
    base_setProduction(production_in, size)
    Factory.updateGarbageVolumes()
    Factory.applyShuttleVolume()
end

function Factory.restore(data)
    base_restore(data)
    Factory.applyShuttleVolume(data)
end

function Factory.secure()
    local data = base_secure()
    data.MinShuttleVolume = Factory.MinShuttleVolume
    return data
end

function Factory.initialize(producedGood, productionIndex, size)
    base_initialize(producedGood, productionIndex, size)
    if onServer() then
        Factory.applyShuttleVolume()
    end
end

function Factory.sync(data)
    if onServer() then
        Factory.applyShuttleVolume()
        Factory.FactoryTweaks_sync()
    end
    if base_sync then base_sync(data) end
end

function Factory.FactoryTweaks_sync(data)
    if onClient() then
        if not data then
            invokeServerFunction("FactoryTweaks_sync")
        else
            Factory.MinShuttleVolume = data.MinShuttleVolume
            Factory.MaxShuttleVolume = data.MinShuttleVolume * data.maxNumProductions
            Factory.onShowWindow()
        end
    else
        local data = {}
        data.MinShuttleVolume = Factory.MinShuttleVolume
        data.maxNumProductions = Factory.maxNumProductions
        invokeClientFunction(Player(callingPlayer), "FactoryTweaks_sync", data)
    end
end
callable(Factory, "FactoryTweaks_sync")

function Factory.refreshConfigUI()
    base_refreshConfigUI()
    if Factory.shuttleVolume < Factory.MaxShuttleVolume then
        upgradeShuttlesButton.active = true
        upgradeShuttlesButton.tooltip = "Upgrade to allow up to ${volume} transported volume per shuttle every ${seconds} seconds."%_t % {
                volume = Factory.shuttleVolume + Factory.MinShuttleVolume,
                seconds = Factory.SectorTradeInterval
            }
    end
    transportCapacityLabel.caption = transportCapacityLabel.caption .. " "%_t
end

function Factory.renderUIIndicator(px, py, size)
    x = px - size / 2
    y = py + size / 2
    local index = 0
    for i, p in pairs(currentProductions) do
        index = index + 1
        dx = x
        dy = y + index * 5
        sx = size + 2
        sy = 4
        drawRect(Rect(dx, dy, sx + dx, sy + dy), ColorRGB(0, 0, 0))
        dx = dx + 1
        dy = dy + 1
        sx = sx - 2
        sy = sy - 2
        sx = sx * p.progress
        local color = ColorRGB(0.66, 0.66, 1.0)
        if Factory.timeToProduce > Factory.MinimumTimeToProduce then color = ColorRGB(1, 0.36, 0) end
        drawRect(Rect(dx, dy, sx + dx, sy + dy), color)
    end
end

callable(Factory, "onUpgradeShuttlesButtonPressed")
function Factory.onUpgradeShuttlesButtonPressed()
    if onClient() then
        invokeServerFunction("onUpgradeShuttlesButtonPressed")
        return
    end
    local buyer, _, player = getInteractingFaction(callingPlayer, AlliancePrivilege.SpendResources, AlliancePrivilege.ManageStations)
    if not buyer then return end

    if Factory.shuttleVolume >= Factory.MaxShuttleVolume then
        player:sendChatMessage("", ChatMessageType.Error, "Transport capacity is already at maximum (${c}/${m})."%_t % {
                c = Factory.shuttleVolume, m = Factory.MaxShuttleVolume
            })
        return
    end

    local price = Factory.getShuttleUpgradeCost(production, factorySize + 1)
    local canPay, msg, args = buyer:canPay(price)
    if not canPay then
        player:sendChatMessage(Entity(), 1, msg, unpack(args))
        return
    end

    buyer:pay(price)
    Factory.shuttleVolume = math.min(Factory.MaxShuttleVolume, Factory.shuttleVolume + Factory.MinShuttleVolume)
    Factory.sync()
    invokeClientFunction(player, "refreshConfigUI")
end

function Factory.getShuttleUpgradeCost()
    local stage = math.ceil(Factory.shuttleVolume / Factory.MinShuttleVolume)
    local price = getFactoryUpgradeCost(production, stage) / 5
    return price
end

function Factory.onShowWindow()
    base_onShowWindow()
    if configTab then
        local player = Player()
        local faction = Faction()
        if player.index == faction.index or player.allianceIndex == faction.index then
            invokeServerFunction("FactoryTweaks_sendConfig")
        end
    end
end

function Factory.buildConfigUI(tab)
    base_buildConfigUI(tab)
    local thsplit = UIHorizontalSplitter(Rect(tab.size), 10, 0, 0.35)
    local vsplit = UIVerticalMultiSplitter(thsplit.bottom, 10, 0, 2)
    local lister = UIVerticalLister(vsplit:partition(1), 8, 0)
    local label = tab:createLabel(Rect(), ""%_t, 12)
    lister:placeElementTop(label)
    label.centered = true
    lister:nextRect(5 + (deliveredStationsCombos[1].rect.size.y + 8) * 3)
    local combo = tab:createValueComboBox(Rect(), "FactoryTweaks_sendConfig")
    lister:placeElementTop(combo)
    garbageStationCombo = combo

    local errorLister = UIVerticalLister(vsplit:partition(2), 15, 0)
    local errorLabelTop = tab:createLabel(Rect(), "", 6)
    errorLister:placeElementTop(errorLabelTop)
    errorLabelTop.centered = true
    errorLister:nextRect((deliveredStationsCombos[1].rect.size.y + 8) * 3)
    local errorLabel = tab:createLabel(Rect(), "", 14)
    errorLister:placeElementTop(errorLabel)
    errorLabel.color = ColorRGB(1, 1, 0)
    garbageStationErrorLabel = errorLabel
end

function Factory.FactoryTweaks_sendConfig()
    local config = {}
    if onClient() then
        config.garbageStations = {}
        local id = garbageStationCombo.selectedValue
        if id then
            local trades = garbageStations[id] or {}
            config.garbageStations[id] = trades
        end
        invokeServerFunction("FactoryTweaks_setConfig", config)
    else
        config.garbageStations = Factory.trader.garbageStations
        invokeClientFunction(Player(callingPlayer), "FactoryTweaks_setConfig", config)
    end
end
callable(Factory, "FactoryTweaks_sendConfig")

function Factory.FactoryTweaks_setConfig(config)
    if onClient() then
        local isTradeSet = false
        local id, trades = next(config.garbageStations)
        if trades then
            garbageStationCombo:setSelectedValueNoCallback(id)
            isTradeSet = true
        end
        if not isTradeSet then garbageStationCombo:setSelectedIndexNoCallback(0) end
        if TradingAPI.window.visible then Factory.refreshConfigUI() end
    else
        if not config then return end
        local owner, station, player = checkEntityInteractionPermissions(Entity(), AlliancePrivilege.ManageStations)
        if not owner then return end
        Factory.trader.garbageStations = config.garbageStations or {}
        Factory.FactoryTweaks_sendConfig()
    end
end
callable(Factory, "FactoryTweaks_setConfig")

function Factory.refreshConfigCombos()
    if not production or not production.ingredients or not production.results or not production.garbages then return end

    local sectorStations = {Sector():getEntitiesByType(EntityType.Station)}
    deliveredStations = {}
    deliveringStations = {}
    garbageStations = {}

    local function addTrades(station, goods, isSelling, tradeTables)
        for _, ingredient in pairs(goods) do
            local good = ingredient.name
            local script = ternary(isSelling, TradingUtility.getEntitySellsGood(station, good), TradingUtility.getEntityBuysGood(station, good))
            if script then
                for _, trade in pairs(tradeTables) do
                    local trades = trade[station.id.string] or {}
                    table.insert(trades, { good = good, script = script })
                    trade[station.id.string] = trades
                end
            end
        end
    end

    for _, station in pairs(sectorStations) do
        addTrades(station, production.ingredients, true, {deliveringStations})
        addTrades(station, production.results, false, {deliveredStations})
        addTrades(station, production.garbages, false, {deliveredStations, garbageStations})
    end

    local function setCombos(comboSet, validStations, emptySelectionString)
        for _, combo in pairs(comboSet) do
            combo:clear()
            combo:addEntry(nil, emptySelectionString%_t)
            for id, _ in pairs(validStations) do
                local station = Sector():getEntity(id)
                local name = station.translatedTitle .. " " .. station.name
                local faction = Faction(station.factionIndex)
                if faction then name = name .. " - (" .. faction.translatedName .. ")" end
                if Factory.isDockedTo(station) then name = "[D] " .. name end
                combo:addEntry(id, name)
            end
        end
    end

    setCombos(deliveredStationsCombos, deliveredStations, "- None -")
    setCombos(deliveringStationsCombos, deliveringStations, "- None -")

    if not next(production.garbages) then
        garbageStationCombo.active = false
        garbageStationCombo.visible = false
        garbageStationErrorLabel.visible = false
        return
    end

    setCombos({garbageStationCombo}, garbageStations, "- Garbage Output -")
end

function Factory.updateServer(timeStep)
    base_updateServer(timeStep)
    Factory.updateGarbageDeliveryToOtherStations(timeStep)

    -- Cosmic Overhaul Self-Healing: Asteroid Mines (like Ice Mines) are claimed from neutral entities,
    -- so their initialize() fires before the player owns them! We catch them here in the update loop instead.
    if not Factory._co_registered then
        local faction = Faction()
        if faction and (faction.isPlayer or faction.isAlliance) then
            Galaxy():invokeFunction("galaxy/factoryregister.lua", "register", Entity().id)
        end
        Factory._co_registered = true
    end
end

function Factory.updateProduction(timeStep)
    if base_updateProduction then base_updateProduction(timeStep) end

    local owner = Owner()
    if owner and (owner.isPlayer or owner.isAlliance) then
        local alliance = owner.isAlliance
        fo_refreshTime = fo_refreshTime + timeStep
        fo_runtime = fo_runtime + timeStep

        -- Capture vanilla production error state, default to "Running" if no error
        local currentError = Factory.productionError
        if not currentError or currentError == "" then
            currentError = "Running"%_T
        end

        fo_productionStateRegister[currentError] = (fo_productionStateRegister[currentError] or 0) + timeStep

        if fo_refreshTime > fo_refreshFrequency then
            fo_refreshTime = 0
            Factory.FactoryOverview_updateGalaxy(alliance)
        end
    end
end

function Factory.FactoryOverview_updateGalaxy(allianceFactory)
    local galaxy = Galaxy()
    if not galaxy then return end

    local self = Entity()
    local x, y = Sector():getCoordinates()
    local stats = Factory.trader.stats

    local factoryData = {
        id = self.id.string,
        index = self.index,
        name = self.name,
        title = (self.title or "") % (self:getTitleArguments() or {}),
        money_gained = stats.moneyGainedFromGoods or 0,
        money_tax = stats.moneyGainedFromTax or 0,
        money_spent = stats.moneySpentOnGoods or 0,
        location = tostring(x) .. "," .. tostring(y),
        runtime = fo_runtime,
        production_register = fo_productionStateRegister
    }

    galaxy:invokeFunction("galaxy/factoryregister.lua", "register", self.factionIndex, allianceFactory, factoryData)
end

function Factory.onRemove()
    if base_onRemove then base_onRemove() end
    local faction = Faction()
    if faction and (faction.isPlayer or faction.isAlliance) then
        Galaxy():invokeFunction("galaxy/factoryregister.lua", "unregister", faction.index, Entity().id.string)
    end
end

function Factory.updateDelivery(stations, dockedOnly, isSelling, debugSource)
    local self = Entity()
    local sector = Sector()
    local ids = {}
    local errorCodes = {}
    local deliveryError = 0
    local unusedShuttleVolume = Factory.shuttleVolume

    for id, trades in pairs(stations) do
        if #trades > 0 then table.insert(ids, id) end
    end

    shuffle(random(), ids)
    for index, id in pairs(ids) do
        if unusedShuttleVolume <= 0 then break end
        local station = sector:getEntity(id)

        if not station then
            errorCodes[index] = "Error with partner station!"%_T
            deliveryError = 2
            goto stationContinue
        end

        if dockedOnly and not Factory.isDockedTo(station) then goto stationContinue end

        local trades = stations[id]
        shuffle(random(), trades)
        for _, trade in pairs(trades) do
            if unusedShuttleVolume <= 0 then break end

            local ownStock, ownMaxStock = Factory.getStock(trade.good)
            local errorCode, otherStock, otherMaxStock = station:invokeFunction(trade.script, "getStock", trade.good)
            local good = ternary(isSelling, Factory.getSoldGoodByName(trade.good), Factory.getBoughtGoodByName(trade.good))

            -- Cosmic Overhaul Quality Check: Fallback for garbage goods not in soldGoods list
            if not good and isSelling and production and production.garbages then
                for _, g in pairs(production.garbages) do
                    if g.name == trade.good then
                        good = goods[g.name]
                        break
                    end
                end
            end

            if errorCode ~= 0 or not good then
                errorCodes[index] = "Error with partner station!"%_T
                deliveryError = 2
                goto tradeContinue
            end

            if isSelling then
                if ownStock == 0 then
                    errorCodes[index] = "No more goods!"%_T
                    deliveryError = 0
                    goto tradeContinue
                elseif otherStock >= otherMaxStock then
                    errorCodes[index] = "No more space."%_T
                    deliveryError = 1
                    goto tradeContinue
                end
            else
                if otherStock == 0 then
                    errorCodes[index] = "No more goods on partner station!"%_T
                    deliveryError = 1
                    goto tradeContinue
                elseif ownStock >= ownMaxStock or self.freeCargoSpace < good.size then
                    errorCodes[index] = "Station at full capacity!"%_T
                    deliveryError = 1
                    goto tradeContinue
                end
            end

            local maxShuttleItems = math.max(1, math.floor(unusedShuttleVolume / good.size))
            local maxSendable = maxShuttleItems
            local amount = maxShuttleItems
            local transaction = nil
            local getTransactionError = nil
            local errorCode1, errorCode2, price = nil, nil, nil;

            if isSelling then
                maxSendable = math.max(otherMaxStock - otherStock, 0)
                amount = math.min(ownStock, maxShuttleItems, maxSendable)
                transaction = "buyGoods"
                getTransactionError = Factory.getBuyGoodsErrorMessage
            else
                maxSendable = math.max(ownMaxStock - ownStock, 0)
                amount = math.min(otherStock, maxShuttleItems, maxSendable)
                transaction = "sellGoods"
                getTransactionError = Factory.getSellGoodsErrorMessage
            end

            errorCode1, errorCode2, price = station:invokeFunction(trade.script, transaction, good, amount, self.factionIndex, isSelling)

            if errorCode1 ~= 0 then
                errorCodes[index] = "Error with partner station!"%_T
                deliveryError = 2
                goto tradeContinue
            elseif errorCode2 ~= 0 then
                errorCodes[index] = getTransactionError(errorCode2)
                deliveryError = 1
                goto tradeContinue
            end

            if isSelling then
                station:addCargo(good, amount)
                Factory.decreaseGoods(trade.good, amount)
                Factory.trader.stats.moneyGainedFromGoods = Factory.trader.stats.moneyGainedFromGoods + price
            else
                self:addCargo(good, amount)
                Factory.trader.stats.moneySpentOnGoods = Factory.trader.stats.moneySpentOnGoods + price
            end

            unusedShuttleVolume = unusedShuttleVolume - good.size * amount
            ::tradeContinue::
        end
        ::stationContinue::
    end
    return errorCodes, deliveryError
end

function Factory.updateDeliveryToOtherStations(timeStep, dockedOnly)
    newDeliveredStationsErrors = Factory.updateDelivery(Factory.trader.deliveredStations, dockedOnly, true, "Delivery")
end

function Factory.updateFetchingFromOtherStations(timeStep, dockedOnly)
    newDeliveringStationsErrors = Factory.updateDelivery(Factory.trader.deliveringStations, dockedOnly, false, "Fetching")
end

function Factory.updateGarbageDeliveryToOtherStations(timeStep)
    local garbageInterval = Factory.garbageDeliveryInterval
    if Sector():getValue("war_zone") then garbageInterval = 60 end

    local dockedOnly = true
    local garbageTimer = timer(Factory.garbageDeliveryTimer, garbageInterval, timeStep)
    Factory.garbageDeliveryTimer = garbageTimer.newTime

    if garbageTimer.hasFired then dockedOnly = false end

    local errorCodes, deliveryCode = Factory.updateDelivery(Factory.trader.garbageStations, dockedOnly, true, "Garbage")
    garbageDeliveryErrorOld = garbageDeliveryError
    garbageDeliveryError = errorCodes[1] or ""
    garbageDeliveryErrorCode = deliveryCode
end

function Factory.requestTraders(timestep)
    local count = 0
    local sector = Sector()
    local gates = {sector:getEntitiesByComponent(ComponentType.WormHole)}
    for _, gate in pairs(gates) do count = count + 1 end

    local bonus = 1 + ft_gateTradeMult * math.min(ft_maxGates, count)
    local maxTimer = 90 / bonus
    if Factory.traderRequestCooldown > maxTimer then
        Factory.traderRequestCooldown = maxTimer + (Factory.traderRequestCooldown - 90)
    end
    base_requestTraders(timestep)
end

function Factory.sendDeliveryErrors()
    if base_sendDeliveryErrors then base_sendDeliveryErrors() end
    if not Owner().isPlayer then return end
    if garbageDeliveryError ~= garbageDeliveryErrorOld then
        local player = Player()
        local x, y = Sector():getCoordinates()
        local px, py = Player():getSectorCoordinates()
        if x == px and y == py then
            invokeClientFunction(player, "FactoryTweaks_receiveGarbageError", garbageDeliveryError, garbageDeliveryErrorCode)
        end
    end
end

function Factory.FactoryTweaks_receiveGarbageError(error, code)
    garbageDeliveryError = error
    garbageDeliveryErrorCode = code
    if garbageStationErrorLabel then Factory.FactoryTweaks_refreshConfigErrors() end
    if not garbageDeliveryError then garbageDeliveryError = "" end
end
callable(Factory, "FactoryTweaks_receiveGarbageError")

function Factory.FactoryTweaks_refreshConfigErrors()
    local color = nil
    if garbageDeliveryErrorCode == 0 then color = ColorRGB(0, 1, 0)
    elseif garbageDeliveryErrorCode == 1 then color = ColorRGB(1, 1, 0)
    else color = ColorRGB(1, 0, 0) end
    garbageStationErrorLabel.color = color
    garbageStationErrorLabel.caption = garbageDeliveryError or ""
end