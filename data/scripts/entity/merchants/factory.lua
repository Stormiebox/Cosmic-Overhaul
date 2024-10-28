package.path = package.path .. ";data/scripts/galaxy/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include("utility")
include("faction")
include("callable")

-- Cosmic Overhaul shuttle delivery modifications start here

-- Constants for shuttle volume
Factory.BaseShuttleVolume = 50
Factory.MaxShuttleVolume = 500
Factory.ShuttleVolumeIncrement = 50

-- Initialize shuttle volume to the base value
Factory.shuttleVolume = Factory.BaseShuttleVolume

-- Modify the upgrade function for shuttles
function Factory.onUpgradeShuttlesButtonPressed()
	if onClient() then
		invokeServerFunction("onUpgradeShuttlesButtonPressed")
		return
	end

	local buyer, _, player = getInteractingFaction(callingPlayer, AlliancePrivilege.SpendResources, AlliancePrivilege.ManageStations)
	if not buyer then return end

	if Factory.shuttleVolume >= Factory.MaxShuttleVolume then
		player:sendChatMessage("", ChatMessageType.Error, "Transport capacity is already at maximum."%_t)
		return
	end

	local price = Factory.getShuttleUpgradeCost(production, factorySize + 1)

	local canPay, msg, args = buyer:canPay(price)
	if not canPay then -- if there was an error, print it
		player:sendChatMessage(Entity(), 1, msg, unpack(args))
		return
	end

	buyer:pay(price)

	-- Increase shuttle volume by the defined increment
	Factory.shuttleVolume = math.min(Factory.shuttleVolume + Factory.ShuttleVolumeIncrement, Factory.MaxShuttleVolume)

	Factory.sync()
	invokeClientFunction(player, "refreshConfigUI")
end

callable(Factory, "onUpgradeShuttlesButtonPressed")

-- Update the cost calculation for shuttle upgrades
function Factory.getShuttleUpgradeCost()
	local stage = (Factory.shuttleVolume - Factory.BaseShuttleVolume) / Factory.ShuttleVolumeIncrement
	local price = getFactoryUpgradeCost(production, stage + 1) / 10 -- Adjust as needed
	return price
end

-- Override the original refreshConfigUI function
local DynamicShuttleRefreshUI = Factory.refreshConfigUI
function Factory.refreshConfigUI()
	DynamicShuttleRefreshUI()

	if Factory.shuttleVolume < Factory.MaxShuttleVolume then
		local price = createMonetaryString(Factory.getShuttleUpgradeCost())
		upgradeShuttlesPriceLabel.caption = "${price} Cr"%_t % {price = price}

		upgradeShuttlesButton.visible = true
		upgradeShuttlesPriceLabel.visible = true

		upgradeShuttlesButton.tooltip = "Upgrade to allow up to ${volume} transported volume per shuttle every ${seconds} seconds."%_t % {volume = Factory.shuttleVolume + 50, seconds = Factory.SectorTradeInterval}
	else
		upgradeShuttlesPriceLabel.visible = false
		upgradeShuttlesButton.visible = true
		upgradeShuttlesButton.active = false
		upgradeShuttlesButton.tooltip = nil
	end
end

-- Cosmic Overhaul shuttle delivery modifications end here

function print_info(message) -- for adding the factory name to the messages, helps debugging when the player has more than one
	local name = Entity().name
	print(name .. ": " .. message)
end

local DATA_REFRESH_FREQUECY = 10 -- controls how often factories call in with new data, in seconds. Could be a bigger number.

local runtime = 0 -- to measure actual elapsed time, without the time spent in paused state
local productionStateRegister = {} -- stores the time spent in different states, working vs. different errors

-- Registers the relevant stats of the factory in the galaxy, grouped under faction ID 
function updateGalaxy(allianceFactory) 
	local galaxy = Galaxy()
	if not galaxy then
		print("Can't find galaxy in updateGalaxy in Factory")
		return
	end
	local factoryData = {}
	local self = Entity()
	local coox, cooy = Sector():getCoordinates()
	local stats = Factory.trader.stats
	
	factoryData['id'] = self.id
	factoryData['index'] = self.index
	factoryData['name'] = self.name
	factoryData['title'] = (self.title or "") % (self:getTitleArguments() or {})
	factoryData['money_gained'] = stats.moneyGainedFromGoods
	factoryData['money_tax'] = stats.moneyGainedFromTax
	factoryData['money_spent'] = stats.moneySpentOnGoods
	factoryData['location'] = tostring(coox) .. "," .. tostring(cooy)
	factoryData['runtime'] = runtime
	factoryData['production_register'] = productionStateRegister
	
	--print_info(tostring(stats.moneyGainedFromGoods))
	
	local callError = galaxy:invokeFunction("factoryregister", "register", self.factionIndex, allianceFactory, factoryData)
	if callError ~= 0 then -- returns 4 when I mess up the code and it doesn't compile :)
		print("Error calling galaxy from Factory: " .. tostring(callError))
	end

end

local refreshTime = DATA_REFRESH_FREQUECY -- setting it to this so the first update is instantaneous

local old_upd = Factory.updateProduction
function Factory.updateProduction(timeStep)
	old_upd(timeStep)
	if Owner().isPlayer or Owner().isAlliance then 
		local alliance = Owner().isAlliance
		refreshTime = refreshTime + timeStep 
		runtime = runtime + timeStep -- total runtime, will not be increased when in pause

		updateProductionStateRegister(timeStep, newProductionError) -- is it working, or is there an error?

		if refreshTime > DATA_REFRESH_FREQUECY then
			--print_info("Refresh at " .. tostring(refreshTime))
			refreshTime = 0
			updateGalaxy(alliance)
			--print_info("Factory Player Index: " .. tostring(Entity().factionIndex) .. " A: " .. tostring(alliance))			
		end
		--print_info("Factory.updateProduction was called " .. tostring(timeStep))
	end
end

newProductionError = "" -- Will this fix that issue in the function call below? 

-- We are storing a snapshot of the state every time when there is an update. Later this is used to show the ratio of working vs.
-- not working for various errors. 
-- 
-- Not happy with this solution, but the alternative is to re-write the whole updateProduction function and use codes instead of 
-- strings. That is a much more flexible overall solution, however any changes in the base code would require me to update the mod
function updateProductionStateRegister(timeStep, newProductionError)
	local reason = "Running"%_T
	if newProductionError == nil then
		reason = "Running?"%_T -- how the heck can this happen?!
	elseif newProductionError ~= "" then
		reason = newProductionError
	end

	productionStateRegister[reason] = (productionStateRegister[reason] or 0) + timeStep
end
