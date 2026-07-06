package.path = package.path .. ";data/scripts/lib/?.lua"

local rf = {} -- registered factories, multi level. First level keyed by the faction index, second level by factory id
local initial = {} -- same as above, but only gets updated once, this will be used to calculate profitability over time

function initialize()
    if onServer() then
        Server():registerCallback("onCCNewsRequestSeed", "onSeedNews")
    end
end

--[[
Inner content structure
	factoryData['id'] = self.id
	factoryData['name'] = self.name
	factoryData['title'] = self.title
	factoryData['money_gained'] = stats.moneyGainedFromGoods
	factoryData['money_tax'] = stats.moneyGainedFromTax
	factoryData['money_spent'] = stats.moneySpentOnGoods
	factoryData['location'] = "0x0"
	... other fields, see in factory.lua, merge function
]]--

function secure()
	return {rf = rf, initial = initial}
end

function restore(data)
	rf = data.rf or {}
	initial = data.initial or {}
end

-- Entry point to call from the factories to register.
function register(factionIndex, allianceFactory, entity_data)
	--include("cosmicvaultdebug").info("Cosmic Overhaul", "Register called " .. tostring(factionIndex) .. " + " .. tostring(entity_data['id']) )
	if not entity_data then
		return
	end

	local fi = factionIndex
	if allianceFactory then
		fi = "a_" .. tostring(factionIndex)
	end
	createOrUpdate(fi, entity_data)
end

-- Called to clean up destroyed/sold factories so they disappear from the UI
function unregister(factionIndex, allianceFactory, entityIdString)
	-- Self-Healing: Safely handle cases where the caller only passed 2 arguments (factionIndex, entityIdString)
	if type(allianceFactory) == "string" and entityIdString == nil then
		entityIdString = allianceFactory
		local faction = Faction(factionIndex)
		allianceFactory = faction and faction.isAlliance or false
	end

	local fi = factionIndex
	if allianceFactory then
		fi = "a_" .. tostring(factionIndex)
	end
	if rf[fi] then rf[fi][entityIdString] = nil end
	if initial[fi] then initial[fi][entityIdString] = nil end
end

-- creates or updates the factory registry with the state passed in
function createOrUpdate(factionIndex, entity_data)
	if not rf[factionIndex] then -- factories are registered for their faction, only player owned factories are stored, but for all players
		rf[factionIndex] = {}
	end
	local entityId = tostring(entity_data['id'])
	if not entityId or entityId == "" or entityId == "nil" then
		include("cosmicvaultdebug").info("Cosmic Overhaul", "Issue with register call in Galaxy, data is not formatted correctly")
		return
	end

	local faction_registry = rf[factionIndex]
	local existingContent = faction_registry[entityId] -- inside the faction, all entities are stored with their id

	if not existingContent then
		--include("cosmicvaultdebug").info("Cosmic Overhaul", "Previously not registered: " .. entityId)
		registerNewFactory(factionIndex, entity_data) -- registering the content for later comparisons
	end
	faction_registry[entityId] = entity_data -- overwriting the previous data
end

function registerNewFactory(factionIndex, entity_data) -- too lazy to generalise both the previous function and this one. You can repeat yourself once, right?
	if not initial[factionIndex] then -- factories are registered for their faction
		initial[factionIndex] = {}
	end
	local entityId = tostring(entity_data['id'])
	if not entityId or entityId == "" or entityId == "nil" then -- ideally we shouldn't be here if this is happening, but things change
		include("cosmicvaultdebug").info("Cosmic Overhaul", "Issue with registerNewFactory call in Galaxy, data is not formatted correctly")
		return
	end

	local existingContent = initial[factionIndex][entityId] -- inside the faction, all entities are stored with their id

	if not existingContent then
		--include("cosmicvaultdebug").info("Cosmic Overhaul", "Initial register for " .. tostring(entity_data['name']))
		entity_data['time'] = Server().unpausedRuntime
		initial[factionIndex][entityId] = entity_data -- registering the content for later comparisons
	else
		-- this is an issue, this function should be called only once for each factory
		include("cosmicvaultdebug").info("Cosmic Overhaul", "!!! Double registering " .. tostring(entity_data['name']))
	end
end

-- used by the player to get a list of all of their factories. Combines current and initial data
function getFactoriesFor(factionId, allianceFactory)
	local fi = factionId
	if allianceFactory then
		fi = "a_" .. tostring(factionId)
	end

	if rf[fi] then
		return merge(fi)
		--return rf[factionId]
	end

	include("cosmicvaultdebug").info("Cosmic Overhaul", "FactionID [" .. tostring(fi) .. "] is not registered.")
	return {}
end

function printRegisteredFactions() -- just for debugging
	local retVal = ""
	for key, _ in pairs(rf) do
		retVal = retVal .. tostring(key) .. ", "
	end
	include("cosmicvaultdebug").info("Cosmic Overhaul", "Registered faction indices: " .. retVal)
end

-- Merges the initial and the current data into a single record for the requesting client, calculates working strings and profitability
function merge(factionId)
	local rf_content = rf[factionId]
	local init_content = initial[factionId]
	if not rf_content or not init_content then
		include("cosmicvaultdebug").info("Cosmic Overhaul", "Missing content in merge for " .. tostring(factionId))
		return {}
	else
		local factories = {}
		for index, data in pairs(rf_content) do
			local init_fdata = init_content[index]
			if not init_fdata then
				init_fdata = data
			end

			local factoryData = {}
			factoryData['id'] = data['id']
			factoryData['index'] = data['index']
			factoryData['name'] = data['name']
			factoryData['title'] = data['title']
			factoryData['money_gained'] = data['money_gained']
			factoryData['money_tax'] = data['money_tax']
			factoryData['money_spent'] = data['money_spent']
			factoryData['location'] = data['location']
			factoryData = calculateProfitability(data, init_fdata, factoryData)
			factoryData = addWorkingStrings(data, init_fdata, factoryData)

			factories[index] = factoryData
		end
		return factories
	end
end


-- Work out the percentage of time spent in different working states, as in working vs. errors
function addWorkingStrings(data, init_fdata, factoryData)
	local totalTime = data['runtime']
	if not totalTime or totalTime == 0 then
		include("cosmicvaultdebug").info("Cosmic Overhaul", "Error elapsed time in registered factory data in Galaxy / 1")
		factoryData['working_state'] = {}
		factoryData['working_state']["Error with data"] = "100%"
		return factoryData
	end

	if not data['production_register']  then
		include("cosmicvaultdebug").info("Cosmic Overhaul", "Error production register is empty in registered factory data in Galaxy")
		factoryData['working_state'] = {}
		factoryData['working_state']["Error with data"] = "100%"
		return factoryData
	end

	local time_check = 0
	local production_percentages = {}


	for reason, time in pairs(data['production_register']) do
		time_check = time_check + time
		production_percentages[reason] = string.format("%.2f%%", (time / totalTime) * 100)
	end

	factoryData['working_state'] = production_percentages

	if time_check == 0 or math.abs( (time_check-totalTime) / totalTime) > 0.01 then
		include("cosmicvaultdebug").info("Cosmic Overhaul", "Error with time calc: " .. tostring(time_check) .. " vs. " .. tostring(totalTime))
	end

	return factoryData
end

-- Calculates the expected profit / hour based on the elapsed time and money changes since the beginning of this play session
function calculateProfitability(data, init_fdata, factoryData)
	local session_runtime = data['runtime'] - (init_fdata['runtime'] or 0) -- elapsed time for THIS tracking period
	if session_runtime < 0 then session_runtime = 0 end

	if session_runtime == 0 then
		factoryData['profitability'] = 0
		return factoryData
	end

	local total_money_gained = data['money_gained'] - (init_fdata['money_gained'] or 0)
	local total_money_tax = data['money_tax'] - (init_fdata['money_tax'] or 0)
	local total_money_spent = data['money_spent'] - (init_fdata['money_spent'] or 0)

	local total_profit = total_money_gained + total_money_tax - total_money_spent -- profit in this play session
	local profitability = 3600 * (total_profit / session_runtime) -- profit / second scaled up to the hour

	factoryData['profitability'] = profitability

	return factoryData
end

function onSeedNews()
    local server = Server()
    if not server then return end

    local bestFactory = nil
    local worstFactory = nil
    local highestProfit = 0
    local lowestProfit = 0

    for factionId, factories in pairs(rf) do
        local mergedData = merge(factionId)
        for _, f in pairs(mergedData) do
            local prof = f.profitability or 0
            if prof > highestProfit then
                highestProfit = prof
                bestFactory = f
            elseif prof < lowestProfit then
                lowestProfit = prof
                worstFactory = f
            end
        end
    end

    if bestFactory and highestProfit > 1000 then
        local article = {
            title = "Economic Boom: " .. (bestFactory.title or "Unknown Factory"),
            category = "Market Watch",
            content = string.format("Financial analysts report massive growth for %s in sector %s. Investors are pouring credits into the surrounding regional economy as profitability skyrockets to record highs.", bestFactory.title or "Unknown Factory", bestFactory.location or "Unknown")
        }
        
        local cvn = include("cosmicvaultnews")
        if cvn and cvn.publishArticle then
            cvn.publishArticle(article)
        else
            local cv_news = include("cosmicvaultnews")
            if cv_news and cv_news.publishArticle then
                cv_news.publishArticle(article)
            else
                server:sendCallback("onCCNewsPublishArticle", article)
            end
        end
    end

    if worstFactory and lowestProfit < -1000 then
        local article = {
            title = "Market Crash: " .. (worstFactory.title or "Unknown Factory"),
            category = "Market Watch",
            content = string.format("A severe economic downturn has struck %s in sector %s. Supply chains are failing, and the station is bleeding credits rapidly. Opportunistic traders are advised to avoid the area or exploit the shortages.", worstFactory.title or "Unknown Factory", worstFactory.location or "Unknown")
        }
        
        local cvn = include("cosmicvaultnews")
        if cvn and cvn.publishArticle then
            cvn.publishArticle(article)
        else
            local cv_news = include("cosmicvaultnews")
            if cv_news and cv_news.publishArticle then
                cv_news.publishArticle(article)
            else
                server:sendCallback("onCCNewsPublishArticle", article)
            end
        end
    end
end