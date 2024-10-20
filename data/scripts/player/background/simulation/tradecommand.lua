include 'moddata'
local SimulationUtility = include 'simulationutility'
local CaptainClass = include 'captainclass'
local CaptainUtility = include 'captainutility'
local LuaHacks = include 'utils/luahacks'
local PerkType = CaptainUtility.PerkType or {}

local mcm_uiTimestamp

local mcm_TradeCommand_buildUI_original = TradeCommand.buildUI
function TradeCommand:buildUI(startPressedCallback, changeAreaPressedCallback, recallPressedCallback, configChangedCallback)
    local ui = mcm_TradeCommand_buildUI_original(self, startPressedCallback, changeAreaPressedCallback, recallPressedCallback, configChangedCallback)

    -- Change: make the deposit slider default to the maximum that the player can afford, as it's
    -- the common case to want to maximize investment and return on investment
    local onRouteChecked_original = self.mapCommands.TradeCommand_onRouteChecked
    self.mapCommands.TradeCommand_onRouteChecked = function(checkBox)
        onRouteChecked_original(checkBox)
        local routeLine = nil
        for _, line in pairs(ui.routeLines) do
            if line.check.index == checkBox.index then
                routeLine = line
                break
            end
        end

        local lowestDeposit = routeLine.minPrice * ui.depositSlider.min
        local highestDeposit = routeLine.minPrice * ui.depositSlider.max

        local highestValue = math.floor(lerp(
                getParentFaction().money,
                lowestDeposit, highestDeposit,
                ui.depositSlider.min, ui.depositSlider.max))

        ui.depositSlider:setValueNoCallback(highestValue)
        self.mapCommands[configChangedCallback]()
    end

    -- Change: store the values of the new checkboxes into the config
    local buildConfig_original = ui.buildConfig
    ui.buildConfig = function(self)
        local config = buildConfig_original(self)
        config.mcm = config.mcm or {}
        config.mcm.immediateDelivery = ui.mcm and ui.mcm.immediateDeliveryCheckBox and ui.mcm.immediateDeliveryCheckBox.checked
        config.mcm.charityMission = ui.mcm and ui.mcm.charityMissionCheckBox and ui.mcm.charityMissionCheckBox.checked
        return config
    end

    local setActive_original = ui.setActive
    ui.setActive = function(self, active, ...)
        setActive_original(self, active, ...)
        self.mcm.immediateDeliveryCheckBox.active = active
        self.mcm.charityMissionCheckBox.active = active
    end

    -- Change: keep a per-config timestamp for smarter line selection
    local refresh_original = ui.refresh
    ui.refresh = function(self, ownerIndex, shipName, area, config)
        if not config then
            mcm_uiTimestamp = appTimeMs()
        end
        refresh_original(self, ownerIndex, shipName, area, config)
    end

    -- This is going to be outrageously fragile to any changes in the vanilla UI, as
    -- everything is built up in local variables we're trying to keep shadowed; we're just going
    -- to walk through the rectangle creations to get to the placements we care about
    local vlist = UIVerticalLister(ui.commonUI.configRect, 5, 5)
    local rect = vlist:nextRect(15)
    rect.lower = rect.lower - vec2(0, 10)
    for i = 1, 4 do
        local rect = vlist:nextRect(30)
    end
    local rect = vlist:nextRect(50)
    -- This is where the slider is


    local vlist = UIVerticalLister(ui.commonUI.predictionRect, 5, 0)

    -- attack chance
    vlist:nextRect(20)
    for i = 1, 4 do
        -- amount, profit, flight time, flights
        vlist:nextRect(15)
    end

    -- A little padding
    vlist:nextRect(5)

    ui.mcm = ui.mcm or {}

    -- At last! New row for immediate delivery option:
    local rect = vlist:nextRect(22)
    local frame = ui.window:createFrame(rect)
    frame.tooltip = "Directly deposit returns as soon as they're available"%_t
    local vsplit2 = UIVerticalSplitter(rect, 0, 0, 0.6)
    local label = ui.window:createLabel(vsplit2.left, "Immediate delivery"%_t, 14)
    ui.mcm.immediateDeliveryCheckBox = ui.window:createCheckBox(vsplit2.right, "", configChangedCallback)

    -- And another for charity missions:
    local rect = vlist:nextRect(22)
    local frame = ui.window:createFrame(rect)
    frame.tooltip = "Trade most of this contract's profit for increased reputation gain"%_t
    local vsplit2 = UIVerticalSplitter(rect, 0, 0, 0.6)
    local label = ui.window:createLabel(vsplit2.left, "Charity mission", 14)
    ui.mcm.charityMissionCheckBox = ui.window:createCheckBox(vsplit2.right, "", configChangedCallback)

    local saveData = ReadModData('NyrinsMapCommandMod.tradeCommand')
    ui.mcm.immediateDeliveryCheckBox:setCheckedNoCallback(saveData and saveData.immediateDelivery)
    ui.mcm.charityMissionCheckBox:setCheckedNoCallback(saveData and saveData.charityMission)
    ui:buildConfig()

    return ui
end

local mcm_TradeCommand_onStart_original = TradeCommand.onStart
function TradeCommand:onStart()
    if self.area.analysis.biggestFactionInArea then
        self:computeRelationImpacts()
    end
    mcm_TradeCommand_onStart_original(self)
    local saveData = CreateModData('NyrinsMapCommandMod.tradeCommand')
    saveData.immediateDelivery = self.config.mcm and self.config.mcm.immediateDelivery
    saveData.charityMission = self.config.mcm and self.config.mcm.charityMission
    saveData:save()
end

local mcm_TradeCommand_onRecall_original = TradeCommand.onRecall
function TradeCommand:onRecall()
    -- Track recall state to suppress immediate delivery for things like ambushes
    -- This would ideally be done in simulation but it's buried deep in there
    self.data.mcm = self.data.mcm or {}
    self.data.mcm.recalled = true

    -- Disable reputation change and charity mission reductions for abnormal termination
    if self.data and self.data.prediction and self.data.prediction.mcm then
        self.data.prediction.mcm.moneyToRelationEntries = nil
    end

    mcm_TradeCommand_onRecall_original(self)
end

-- Factor in the new "charity mission" option that converts per-flight profit to reputation

function TradeCommand.getRelationChangeRatioForTrade() return 0.15 end
function TradeCommand.getRelationChangeRatioForCharity() return 0.25 end

function TradeCommand:computeRelationImpacts()
    -- We move this variable into the hooked-in one to change/augment how reputation gain
    -- works without needing to rewrite the entirety of update()
    local factionForRelations = self.area.analysis.biggestFactionInArea
    if not factionForRelations then return end
    self.area.analysis.biggestFactionInArea = nil

    -- Add a reputation entry for standard goods trade
    self.data.prediction.mcm = self.data.prediction.mcm or {}
    self.data.prediction.mcm.moneyToRelationEntries =
        self.data.prediction.mcm.moneyToRelationEntries or {}

    table.insert(self.data.prediction.mcm.moneyToRelationEntries, {
        faction = factionForRelations,
        ratio = TradeCommand.getRelationChangeRatioForTrade(),
        relationType = RelationChangeType.GoodsTrade
    })

    if self.config and self.config.mcm and self.config.mcm.charityMission
        and self.data.prediction.mcm.charityPerFlight
    then
        -- Add a reputation entry for charity gains, per-flight profit converted into
        -- reputation at a slightly higher rate and higher-cap category
        table.insert(self.data.prediction.mcm.moneyToRelationEntries, {
            faction = factionForRelations,
            moneyAmount = {
                min = self.data.prediction.mcm.charityPerFlight.from,
                max = self.data.prediction.mcm.charityPerFlight.to,
            },
            ratio = TradeCommand.getRelationChangeRatioForCharity(),
            relationType = RelationChangeType.EquipmentTrade
        })
    end
end

local mcm_TradeCommand_secure_original = TradeCommand.secure
function TradeCommand:secure(...)
    local data = {}
    if mcm_TradeCommand_secure_original then
        data = mcm_TradeCommand_secure_original(self, ...)
    end
    data.mcm = {
        immediateDelivery = self.config and self.config.mcm and self.config.mcm.immediateDelivery,
        charityMission = self.config and self.config.mcm and self.config.mcm.charityMission,
    }
    return data
end

local mcm_TradeCommand_restore_original = TradeCommand.restore
function TradeCommand:restore(data, ...)
    if data and data.mcm then
        self.config.mcm = self.config.mcm or {}
        self.config.mcm.immediateDelivery = data.mcm.immediateDelivery
        self.config.mcm.charityMission = data.mcm.charityMission
    end
    if mcm_TradeCommand_restore_original then
        mcm_TradeCommand_restore_original(self, data, ...)
    end
end

local mcm_TradeCommand_generateAssessmentFromPrediction_original =
    TradeCommand.generateAssessmentFromPrediction
function TradeCommand:generateAssessmentFromPrediction(prediction, captain, ...)
    local lines = mcm_TradeCommand_generateAssessmentFromPrediction_original(self, prediction, captain, ...)
    if lines == '' then return '' end

    if prediction and prediction.mcm and prediction.mcm.charityPerFlight then
        -- Replace the "this will be profitable" with something more appropriate
        local charityLine = SimulationUtility.getTradeCharityLine(mcm_uiTimestamp)
        lines[1] = charityLine
    end

    -- Include the "I'm not the best at this" line for non-merchant trading
    if not captain:hasClass(CaptainClass.Merchant) then
        table.insert(lines, 2, SimulationUtility.getImperfectTradeClassLine(mcm_uiTimestamp))
    end

    return lines
end

function TradeCommand:getAreaSize(ownerIndex, shipName)
    local ship = ShipDatabaseEntry(ownerIndex, shipName)

    local bonus = TradeCommand:mcm_getAreaSizeBonus(ship)

    --[[
        Three size choices:
            1. a square (vanilla 17x17)
            2. a wide rectangle (vanilla 29x11)
            3. a tall rectangle (vanilla 11x29)
    ]]
    local squareBase = 10 + bonus
    local longerEdge = math.floor((29/17) * squareBase)
    local shorterEdge = math.floor((11/17) * squareBase)
    return { x = squareBase, y = squareBase },
        { x = longerEdge, y = shorterEdge },
        { x = shorterEdge, y = longerEdge }
end

function TradeCommand:mcm_getAreaSizeBonus(ship)

    local bonus = 0

    bonus = bonus + self:mcm_getAreaSizeBonusForShip(ship)
    bonus = bonus + self:mcm_getAreaSizeBonusForSubsystems(ship)
    bonus = bonus + self:mcm_getAreaSizeBonusForCaptain(ship:getCaptain())

    return bonus
end

function TradeCommand:mcm_getAreaSizeBonusForShip(ship)
    local range = ship:getHyperspaceProperties()
    if range > 12 then return 2 end
    if range > 6 then return 1 end
    return 0
end

local function genericGetAreaSizeBonusForCaptainLevel(table, key, level)
    local levelMap = table[key] or table[false]
    local bonus = 0
    for i = 0, level do
        bonus = math.max(bonus, (levelMap[level] or 0))
    end
    return bonus
end

-- Given a level table, returns a function that when evaluated on a captain will give the highest value
-- defined for an index <= the captain's level
local function mcm_captainLevelScaleFunc(table)
    return function(captain)
        local bonus = 0
        for i = 0, captain.level do 
            bonus = math.max((table[i] or 0), bonus)
        end
        return bonus
    end
end


local mcm_captainClassAreaBonusFuncs = {
    [CaptainClass.Merchant] = mcm_captainLevelScaleFunc({ [0] = 4, [2] = 5, [4] = 6, [6] = 7 }),
    [CaptainClass.Smuggler] = mcm_captainLevelScaleFunc({ [0] = 2, [3] = 3, [6] = 4 }),
    [false] = mcm_captainLevelScaleFunc({ [0] = 0, [4] = 1 }),
}
local function mcm_getCaptainClassAreaBonusFunc(class) 
    return mcm_captainClassAreaBonusFuncs[class] or mcm_captainClassAreaBonusFuncs[false]
end
local mcm_captainPerkAreaBonusFuncs = {
    [PerkType.MarketExpert] = mcm_captainLevelScaleFunc({ [0] = 1 }),
    [PerkType.Navigator] = mcm_captainLevelScaleFunc({ [0] = 1 }),
    [false] = mcm_captainLevelScaleFunc({}),
}

function TradeCommand:mcm_getAreaSizeBonusForCaptain(captain)
    local classBonus = math.max(
        mcm_getCaptainClassAreaBonusFunc(captain.primaryClass)(captain),
        mcm_getCaptainClassAreaBonusFunc(captain.secondaryClass)(captain))

    local perkBonus = 0
    for _, perk in pairs({captain:getPerks()}) do
        local perkFunc = mcm_captainPerkAreaBonusFuncs[perk] or mcm_captainPerkAreaBonusFuncs[false]
        perkBonus = perkBonus + perkFunc(captain)
    end

    return classBonus + perkBonus
end

local function mcm_rarityScaleFunc(table)
    return function(rarity)
        local value = 0
        for i = RarityType.Petty, rarity.value do
            value = math.max(value, (table[i] or 0))
        end
        return value
    end
end

local function TableWithFallback(values, fallback)
    return setmetatable(values, { __index = function(self, k, ...) return fallback end })
end

local mcm_subsystemRarityBonuses = TableWithFallback({
    ['data/scripts/systems/tradingoverview.lua'] = TableWithFallback({
        [RarityType.Uncommon] = 1,
        [RarityType.Exceptional] = 2,
        [RarityType.Legendary] = 4,
    }, 0)
}, TableWithFallback({}, 0))

local mcm_subsystemAreaBonusFuncs = {
    ['data/scripts/systems/tradingoverview.lua'] = mcm_rarityScaleFunc({
        [RarityType.Uncommon] = 1,
        [RarityType.Exceptional] = 2,
        [RarityType.Legendary] = 4,
    }),
    [false] = mcm_rarityScaleFunc({}),
}
local function mcm_getSubsystemAreaBonusFunc(subsystem)
    return mcm_subsystemAreaBonusFuncs[subsystem.script] or mcm_subsystemAreaBonusFuncs[false]
end

-- sumtf = "sum table (with) function" -- add up a computed value of each item in the table
-- according to the provided evaluation function
local function sumtf(table, evalFunc)
    local sum = 0
    for k, v in pairs(table) do
        sum = sum + evalFunc(k, v) end
    return sum
end


function TradeCommand:mcm_getAreaSizeBonusForSubsystems(ship)
    return sumtf(ship:getSystems(), function(system)
        return mcm_subsystemRarityBonuses[system.script][system.rarity.value]
    end)
end

local mcm_tradeCaptainClassFlightTimeMultipliers = {
    [CaptainClass.Merchant] = 1.0,
    [CaptainClass.Smuggler] = 1.4,
    [false] = 2.2,    
}

local mcm_TradeCommand_calculatePrediction_original = TradeCommand.calculatePrediction
function TradeCommand:calculatePrediction(ownerIndex, shipName, area, config)
    local prediction = LuaHacks.RunWithHacks(
        LuaHacks.Hacks.ShipDatabaseEntry.CaptainAlwaysHasMerchant,
        mcm_TradeCommand_calculatePrediction_original,
        self, ownerIndex, shipName, area, config)

    prediction.mcm = prediction.mcm or {}

    if config.mcm and config.mcm.charityMission then
        -- When doing a "charity mission," switch from 90%-100% base profit per flight
        -- to 0-20% profit per flight, converting the 70-100% into reputation later
        local baseProfit = prediction.profitPerFlight.to
        prediction.profitPerFlight.from = 0
        prediction.profitPerFlight.to = 0.20 * baseProfit
        prediction.mcm.charityPerFlight = {
            from = 0.70 * baseProfit,
            to = baseProfit,
        }
    end

    local ship = ShipDatabaseEntry(ownerIndex, shipName)
    local captain = ship:getCaptain()
    local timeFunc = function(c) 
        return mcm_tradeCaptainClassFlightTimeMultipliers[c] or mcm_tradeCaptainClassFlightTimeMultipliers[false]
    end
    local timeFactor = math.min(timeFunc(captain.primaryClass), timeFunc(captain.secondaryClass))
    
    prediction.flightTime.value = prediction.flightTime.value * timeFactor

    return prediction
end

-- These two functions are just tweaked to pretend the captain's always a merchant
TradeCommand.onAreaAnalysisFinished = LuaHacks.HackedFunc(
    LuaHacks.Hacks.ShipDatabaseEntry.CaptainAlwaysHasMerchant,
    TradeCommand.onAreaAnalysisFinished, self, ...)

TradeCommand.getErrors = LuaHacks.HackedFunc(
    LuaHacks.Hacks.ShipDatabaseEntry.CaptainAlwaysHasMerchant,
    TradeCommand.getErrors, self, ...)
