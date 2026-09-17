package.path = package.path .. ";data/scripts/lib/?.lua"

local CosmicOverhaulNews = include("co_news")

local rf = {} -- registered factories, multi level. First level keyed by the faction index, second level by factory id
local initial = {} -- same as above, but only gets updated once, this will be used to calculate profitability over time
local newsRevisions = {} -- durable lifecycle number for re-registration of the same entity

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
	return {rf = rf, initial = initial, newsRevisions = newsRevisions}
end

function restore(data)
	rf = data.rf or {}
	initial = data.initial or {}
	newsRevisions = data.newsRevisions or {}
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
	local isNew = createOrUpdate(fi, entity_data)
	if isNew then
		local entityId = tostring(entity_data.id)
		newsRevisions[entityId] = math.floor(tonumber(newsRevisions[entityId]) or 0) + 1
		entity_data._newsRevision = newsRevisions[entityId]
		publishFactoryRegistration(entity_data)
	end
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
	local removed = rf[fi] and rf[fi][entityIdString] or nil
	if rf[fi] then rf[fi][entityIdString] = nil end
	if initial[fi] then initial[fi][entityIdString] = nil end
	if removed then
		publishFactoryLoss(removed)
	end
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
	return existingContent == nil
end

local function parseLocation(location)
	if type(location) ~= "string" then return nil end
	local x, y = string.match(location, "^%s*(-?%d+)%s*[,x:]%s*(-?%d+)%s*$")
	x, y = tonumber(x), tonumber(y)
	if not x or not y then return nil end
	return {x = x, y = y, radius = 0}
end

function publishFactoryRegistration(factoryData)
	if type(factoryData) ~= "table" or factoryData.id == nil then return end
	local location = parseLocation(factoryData.location)
	local title = tostring(factoryData.title or factoryData.name or "Factory")
	local lifecycle = math.floor(tonumber(factoryData._newsRevision) or 1)
	CosmicOverhaulNews.Publish({
		kind = "factory",
		eventId = "registry:" .. tostring(factoryData.id) .. ":" .. tostring(lifecycle),
		threadId = "factory:" .. tostring(factoryData.id),
		eventType = "overhaul.factory.registered",
		topic = "economy",
		severity = "info",
		location = location,
		provenance = {
			recordType = "overhaul_factory_registry",
			factoryId = tostring(factoryData.id),
			sourceRevision = lifecycle,
			sourceState = "registered",
		},
		article = {
			title = "Factory Joins Production Registry",
			category = "Market Watch",
			content = title .. " has begun reporting verified production data"
				.. (location and string.format(" from sector [%d:%d].", location.x, location.y)
					or "."),
		},
	})
end

function publishFactoryLoss(factoryData)
	if type(factoryData) ~= "table" or factoryData.id == nil then return end
	local location = parseLocation(factoryData.location)
	local title = tostring(factoryData.title or factoryData.name or "A factory")
	local factoryId = tostring(factoryData.id)
	local lifecycle = math.floor(tonumber(factoryData._newsRevision)
		or tonumber(newsRevisions[factoryId]) or 1)
	CosmicOverhaulNews.Resolve("factory",
		"registry:" .. factoryId .. ":" .. tostring(lifecycle),
		"Factory left the production registry.", "resolved")
	CosmicOverhaulNews.Publish({
		kind = "factory",
		eventId = "loss:" .. factoryId .. ":" .. tostring(lifecycle),
		threadId = "factory:" .. factoryId,
		eventType = "overhaul.factory.unregistered",
		topic = "economy",
		severity = "warning",
		location = location,
		provenance = {
			recordType = "overhaul_factory_registry",
			factoryId = factoryId,
			sourceRevision = lifecycle,
			sourceState = "unregistered",
		},
		article = {
			title = "Factory Leaves Production Registry",
			category = "Market Watch",
			content = title .. " is no longer reporting production data"
				.. (location and string.format(" from sector [%d:%d].", location.x, location.y)
					or "."),
		},
	})
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
	-- status_window_runtime is the rolling-window counter factory.lua resets alongside
	-- production_register every 30 minutes, so a problem that started recently isn't averaged
	-- down into invisibility by hours of prior healthy runtime. Falls back to the old lifetime
	-- 'runtime' field so a factory whose data hasn't refreshed since this change (or restored
	-- from an older save) doesn't hit the "no data" branch below instead of just showing lifetime
	-- stats for one cycle.
	local totalTime = data['status_window_runtime'] or data['runtime']
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
        CosmicOverhaulNews.Upsert({
            kind = "factory",
            eventId = "performance:boom:" .. tostring(bestFactory.id),
            threadId = "factory:" .. tostring(bestFactory.id),
            eventType = "overhaul.factory.performance.boom",
            topic = "economy",
            severity = "info",
            location = parseLocation(bestFactory.location),
            sourceRevision = 1,
            sourceState = "profitable",
            article = {
                title = "Economic Boom: " .. (bestFactory.title or "Unknown Factory"),
                category = "Market Watch",
                content = string.format("Financial analysts report massive growth for %s in sector %s. Investors are pouring credits into the surrounding regional economy as profitability skyrockets to record highs.", bestFactory.title or "Unknown Factory", bestFactory.location or "Unknown")
            },
        })
    end

    if worstFactory and lowestProfit < -1000 then
        CosmicOverhaulNews.Upsert({
            kind = "factory",
            eventId = "performance:crash:" .. tostring(worstFactory.id),
            threadId = "factory:" .. tostring(worstFactory.id),
            eventType = "overhaul.factory.performance.crash",
            topic = "economy",
            severity = "warning",
            location = parseLocation(worstFactory.location),
            sourceRevision = 1,
            sourceState = "unprofitable",
            article = {
                title = "Market Crash: " .. (worstFactory.title or "Unknown Factory"),
                category = "Market Watch",
                content = string.format("A severe economic downturn has struck %s in sector %s. Supply chains are failing, and the station is bleeding credits rapidly. Opportunistic traders are advised to avoid the area or exploit the shortages.", worstFactory.title or "Unknown Factory", worstFactory.location or "Unknown")
            },
        })
    end
end
