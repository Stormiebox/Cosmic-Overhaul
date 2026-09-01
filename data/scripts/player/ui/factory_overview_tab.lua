package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/galaxy/?.lua"
include("callable")
include("utility")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace FactoryOverview
FactoryOverview = {}
local self = FactoryOverview
local all_check

if onClient() then
	function FactoryOverview.initialize()
		local playerWindow = PlayerWindow()

		self.tab = playerWindow:createTab("Factory Overview"%_t, "data/textures/icons/FactoryOverviewTab.png",
			"Factory Overview"%_t)
		self.tab.onSelectedFunction = "clientFetchDataFromGalaxy"
		self.tab.onShowFunction = "clientFetchDataFromGalaxy"
		playerWindow:moveTabToTheRight(self.tab)
		FactoryOverview.buildWindow(self.tab)
		FactoryOverview.clientFetchDataFromGalaxy()
	end

	function FactoryOverview.refresh()
		FactoryOverview.clientFetchDataFromGalaxy()
	end
end

function FactoryOverview.clientFetchDataFromGalaxy()
	invokeServerFunction("fetchDataFromGalaxy", (all_check ~= nil and all_check.checked))
end

function FactoryOverview.fetchDataFromGalaxy(alliance_v) -- fetches the current and initial monetary data for each factory registered for the player
	if onClient() then
		invokeServerFunction("fetchDataFromGalaxy", alliance_v)
		return
	end

	local galaxy = Galaxy()
	if not galaxy then
		include("cosmicvaultdebug").info("Cosmic Overhaul", "Galaxy is not accessible from fetchDataFromGalaxy")
	else
		local av = alliance_v and (Player().alliance ~= nil)
		--include("cosmicvaultdebug").info("Cosmic Overhaul", "Alliance: " .. tostring(Player().alliance ~= nil) .. " av: " .. tostring(av))
		local index = Player().index
		if av then
			index = Player().allianceIndex
		end
		--include("cosmicvaultdebug").info("Cosmic Overhaul", "Index: " .. tostring(index) .. " av: " .. tostring(av))
		local errorcode, factories = galaxy:invokeFunction("galaxy/factoryregister.lua", "getFactoriesFor", index, av)

		if errorcode ~= 0 then
			include("cosmicvaultdebug").info("Cosmic Overhaul", "Error while calling getFactoriesFor on Galaxy from Player: " .. tostring(errorcode))
			return
		end

		invokeClientFunction(Player(callingPlayer), "loadData", factories)
	end
end

callable(FactoryOverview, "fetchDataFromGalaxy")

-- Declarations of the different literals and variables
local factory_ui_list     -- the ui element for showing the list
local totalsLabel         -- summary of income/expense/profit across the currently shown factories
local sortingButtons = {} -- all the sorting buttons, this is used later to update the sorting arrows
local sortingLabels = { "Name"%_t, "Type"%_t, "Location"%_t, "Income"%_t, "Expense"%_t, "Profit"%_t, "Profit / h"%_t, "Status"%_t }

local selectedSorting = 6   -- which column do we use for sorting, same as sortingLabels (defaults to Profit)
local sortingType = -1      -- ascending: 1 or descending: -1

-- Parses a working_state percentage ("57.32%") back into a plain number. Values are always
-- pre-formatted strings by factoryregister.lua's addWorkingStrings, never raw numbers.
local function parsePercentage(pctText)
	local num = tonumber(string.match(tostring(pctText or ""), "[%d%.]+"))
	return num or 0
end

-- Finds the working_state reason the factory spent the most time in, so the list can show a
-- single, glanceable health indicator instead of requiring a tooltip hover on every row.
local function getDominantState(workingState)
	-- Plain string default (not %_t-wrapped) so factory['_statusReason'] is always the same
	-- type regardless of path, matching pairs(workingState)'s tostring(reason) entries below --
	-- %_t is applied exactly once, where the value is actually displayed.
	local bestReason, bestPct = "Unknown", -1
	for reason, pctText in pairs(workingState or {}) do
		local pct = parsePercentage(pctText)
		if pct > bestPct then
			bestPct = pct
			bestReason = tostring(reason)
		end
	end
	if bestPct < 0 then bestPct = 0 end
	return bestReason, bestPct
end

local sortingFunctions = {} --
sortingFunctions[1] = function(f1, f2) return f1['name'] < f2['name'] end
sortingFunctions[-1] = function(f1, f2) return f1['name'] > f2['name'] end

sortingFunctions[2] = function(f1, f2) return f1['title'] < f2['title'] end
sortingFunctions[-2] = function(f1, f2) return f1['title'] > f2['title'] end

sortingFunctions[3] = function(f1, f2) return (f1['location'] or "") < (f2['location'] or "") end
sortingFunctions[-3] = function(f1, f2) return (f1['location'] or "") > (f2['location'] or "") end

sortingFunctions[4] = function(f1, f2) return f1['money_gained']+f1['money_tax'] < f2['money_gained']+f2['money_tax'] end
sortingFunctions[-4] = function(f1, f2) return f1['money_gained']+f1['money_tax'] > f2['money_gained']+f2['money_tax'] end

sortingFunctions[5] = function(f1, f2) return f1['money_spent'] < f2['money_spent'] end
sortingFunctions[-5] = function(f1, f2) return f1['money_spent'] > f2['money_spent'] end

sortingFunctions[6] = function(f1, f2) return f1['money_gained']+f1['money_tax']-f1['money_spent'] <
	f2['money_gained']+f2['money_tax']-f2['money_spent'] end
sortingFunctions[-6] = function(f1, f2) return f1['money_gained']+f1['money_tax']-f1['money_spent'] >
	f2['money_gained']+f2['money_tax']-f2['money_spent'] end

sortingFunctions[7] = function(f1, f2) return f1['profitability'] < f2['profitability'] end
sortingFunctions[-7] = function(f1, f2) return f1['profitability'] > f2['profitability'] end

sortingFunctions[8] = function(f1, f2) return f1['_statusPct'] < f2['_statusPct'] end
sortingFunctions[-8] = function(f1, f2) return f1['_statusPct'] > f2['_statusPct'] end

-- sets the sorting values and refreshes the table
function FactoryOverview.updateSorting(newSorting)
	if selectedSorting == newSorting then
		sortingType = sortingType*-1
	else
		selectedSorting = newSorting
		sortingType = 1
	end
	FactoryOverview.updateSortingIcons()
	FactoryOverview.loadData() -- reuses the existing data if no parameter is provided
end

--[[
The window should show a scrollable, sortable, table where each line is a factory, showing
name, type, location, income, expense, profit, profit/time and a glanceable health status.
Tooltip lists the full working-state breakdown.
]] --
function FactoryOverview.buildWindow(container)
	-- Two header rows (title/totals, then controls) so nothing has to share horizontal
	-- space and risk overlapping on a narrower player window.
	local hsplit = UIHorizontalSplitter(Rect(container.size), 5, 5, 0.16)

	local margin = 10
	local topWidth = hsplit.top.width
	local topHeight = hsplit.top.height

	local row1Bottom = topHeight * 0.42
	local row2Top = topHeight * 0.46
	-- The sorting-header row below is drawn in the last 20px of hsplit.top itself (see the
	-- loop further down: Rect(..., hsplit.top.height-20, ..., hsplit.top.height)), so row 2's
	-- controls must stay clear of that band or they visually collide with the header buttons.
	local row2Bottom = topHeight - 24

	-- Row 1: title (left) + aggregate totals for the currently shown factories (right)
	container:createLabel(Rect(margin, 2, margin + 200, row1Bottom), "Factory Overview"%_t, 20)

	totalsLabel = container:createLabel(Rect(topWidth * 0.32, 2, topWidth - margin, row1Bottom), "", 15)
	totalsLabel:setTopLeftAligned()

	-- Row 2: refresh, goto, alliance toggle -- right-aligned in their own corner instead of
	-- sitting over the leftmost sort-header columns, and narrower since these are icon
	-- buttons that don't need the extra width.
	all_check = container:createCheckBox(Rect(topWidth - margin - 150, row2Top, topWidth - margin, row2Bottom),
		"Alliance: "%_t, "switchAllianceFlag")
	all_check.checked = false

	local gotoButton = container:createButton(Rect(topWidth - margin - 250, row2Top, topWidth - margin - 160, row2Bottom), "Goto Selected"%_t,
		"gotoSelectedCoordinates")
	gotoButton.icon = "data/textures/icons/wire.png"
	gotoButton.tooltip = "Jump to selected station"%_t

	local refreshButton = container:createButton(Rect(topWidth - margin - 350, row2Top, topWidth - margin - 260, row2Bottom), "Refresh"%_t, "clientFetchDataFromGalaxy")
	refreshButton.icon = "data/textures/icons/refresh.png"
	refreshButton.tooltip = "Refresh Factory Data"%_t

	-- Account for the scrollbar width (~20px) so the last column doesn't get clipped
	local b_width = (container.size.x-2*margin-20)/#sortingLabels

	-- This is not the most beautiful solution, but I couldn't make clicking on the List Header work for this
	for ndx, sortingLabel in pairs(sortingLabels) do
		local sortingButton = container:createButton(
			Rect(margin+(ndx-1)*b_width+2, hsplit.top.height-20, margin+ndx*b_width-3, hsplit.top.height),
			"",
			"updateSorting" .. tostring(ndx)
		)
		sortingButton.tooltip = "Sort by "%_t .. sortingLabel
		table.insert(sortingButtons, sortingButton)
	end

	FactoryOverview.updateSortingIcons()

	factory_ui_list = container:createListBoxEx(Rect(margin, hsplit.top.height, hsplit.bottom.width-2*margin,
		hsplit.bottom.height))
	factory_ui_list.columns = #sortingLabels
	factory_ui_list.rowHeight = 40


	for ndx = 0, #sortingLabels - 1, 1 do
		factory_ui_list:setColumnWidth(ndx, b_width)
	end

	factory_ui_list.headline = true -- to fix the first line as header
end

function FactoryOverview.switchAllianceFlag()
	FactoryOverview.clientFetchDataFromGalaxy()
end

local current_list -- stores the last data shown

-- populates the lines in the factory_ui_list based on the passed data or the list we used the last
function FactoryOverview.loadData(factory_list)
	if not factory_ui_list then return end

	local list_to_use -- to enable reuse of the last data for sorting
	if not factory_list then
		if not current_list then return end
		list_to_use = current_list
	else
		list_to_use = factory_list
		current_list = factory_list
	end

	local sortedList = {}
	local totalIncome, totalExpense = 0, 0
	for _, val in pairs(list_to_use) do
		-- Pre-compute the dominant working-state reason once per factory so both the
		-- Status column and its sort function can reuse it without re-parsing.
		val['_statusReason'], val['_statusPct'] = getDominantState(val['working_state'])
		table.insert(sortedList, val)

		totalIncome = totalIncome + (val['money_gained'] or 0) + (val['money_tax'] or 0)
		totalExpense = totalExpense + (val['money_spent'] or 0)
	end

	table.sort(sortedList, sortingFunctions[selectedSorting*sortingType]) -- pick sorting function based on column and direction

	FactoryOverview.updateTotals(#sortedList, totalIncome, totalExpense)

	factory_ui_list:clear()
	local white = ColorRGB(1, 1, 1)
	local gray = ColorRGB(0.8, 0.8, 0.8)

	factory_ui_list:addRow() -- headline
	for ndx, sortingLabel in pairs(sortingLabels) do
		factory_ui_list:setEntryNoCallback(ndx-1, 0, sortingLabel, true, false, white)
	end

	for _, factory in pairs(sortedList) do
		local income = factory['money_gained']+factory['money_tax']
		local profit = income-factory['money_spent']

		local statusColor = gray
		local reasonLower = string.lower(factory['_statusReason'] or "")
		if factory['_statusPct'] >= 80 and string.find(reasonLower, "run") then
			statusColor = ColorRGB(0.2, 1.0, 0.2) -- Green: healthy and running most of the time
		elseif string.find(reasonLower, "run") then
			statusColor = ColorRGB(1.0, 0.85, 0.2) -- Amber: running, but noticeable downtime
		else
			statusColor = ColorRGB(1.0, 0.3, 0.3) -- Red: dominant state is something other than running
		end

		factory_ui_list:addRow(factory['location']) -- name, type, location, income, expense, profit, profit / hour, status
		factory_ui_list:setEntryNoCallback(0, factory_ui_list.rows-1, factory['name'], false, false, gray)
		factory_ui_list:setEntryNoCallback(1, factory_ui_list.rows-1, (factory['title'] or "")%_t, false, false, gray)
		factory_ui_list:setEntryNoCallback(2, factory_ui_list.rows-1, factory['location'] or "?", false, false, gray)
		factory_ui_list:setEntryNoCallback(3, factory_ui_list.rows-1,
			"${c}${money}"%_t%{ c = credits(), money = createMonetaryString(income) }, false, false, gray)
		factory_ui_list:setEntryNoCallback(4, factory_ui_list.rows-1,
			"${c}${money}"%_t%{ c = credits(), money = createMonetaryString(factory['money_spent']) }, false, false, gray)
		factory_ui_list:setEntryNoCallback(5, factory_ui_list.rows-1,
			"${c}${money}"%_t%{ c = credits(), money = createMonetaryString(profit) }, false, false, gray)
		factory_ui_list:setEntryNoCallback(6, factory_ui_list.rows-1,
			"${c}${money}"%_t%{ c = credits(), money = createMonetaryString(factory['profitability']) }, false, false,
			gray)
		factory_ui_list:setEntryNoCallback(7, factory_ui_list.rows-1,
			string.format("%d%% %s", math.floor(factory['_statusPct']), factory['_statusReason']%_t), false, false, statusColor)
		factory_ui_list:setTooltip(factory_ui_list.rows-1, getRowTooltip(factory))
	end
end

function FactoryOverview.updateTotals(count, totalIncome, totalExpense)
	if not totalsLabel then return end

	if count == 0 then
		totalsLabel.caption = "No factories to display."%_t
		totalsLabel.color = ColorRGB(0.6, 0.6, 0.6)
		return
	end

	local totalProfit = totalIncome - totalExpense
	local profitColor = totalProfit >= 0 and ColorRGB(0.4, 1.0, 0.6) or ColorRGB(1.0, 0.4, 0.4)

	totalsLabel.caption = string.format("Totals (%d factories): "%_t, count) ..
		"Income "%_t .. credits() .. createMonetaryString(totalIncome) .. "  |  " ..
		"Expense "%_t .. credits() .. createMonetaryString(totalExpense) .. "  |  " ..
		"Profit "%_t .. credits() .. createMonetaryString(totalProfit)
	totalsLabel.color = profitColor
end

-- is this really the only way to do this?! These functions receive the button as input, but that holds no information to help
function FactoryOverview.updateSorting1() FactoryOverview.updateSorting(1) end

function FactoryOverview.updateSorting2() FactoryOverview.updateSorting(2) end

function FactoryOverview.updateSorting3() FactoryOverview.updateSorting(3) end

function FactoryOverview.updateSorting4() FactoryOverview.updateSorting(4) end

function FactoryOverview.updateSorting5() FactoryOverview.updateSorting(5) end

function FactoryOverview.updateSorting6() FactoryOverview.updateSorting(6) end

function FactoryOverview.updateSorting7() FactoryOverview.updateSorting(7) end

function FactoryOverview.updateSorting8() FactoryOverview.updateSorting(8) end

-- sets the selected sorting button to an up or down arrow and the rest to empty
function FactoryOverview.updateSortingIcons()
	for ndx, button in pairs(sortingButtons) do
		if ndx == selectedSorting then
			local icon
			if sortingType < 0 then
				icon = "data/textures/icons/arrow-down2.png"
			else
				icon = "data/textures/icons/arrow-up2.png"
			end
			button.icon = icon
		else
			button.icon = ""
		end
	end
end

-- parses the location from the original string
function FactoryOverview.getCoordinates(coo_string) -- assuming 15,-40 format
	if not coo_string or type(coo_string) ~= "string" then return 0, 0 end
	local comma = coo_string:find(',')
	if not comma then return 0, 0 end
	local x = tonumber(coo_string:sub(1, comma-1))
	local y = tonumber(coo_string:sub(comma+1))
	return x or 0, y or 0
end

-- Opens the Galaxy map and goes to the coordinates of the selected factory
function FactoryOverview.gotoSelectedCoordinates()
	if not factory_ui_list.selectedValue then return end

	local x, y = FactoryOverview.getCoordinates(factory_ui_list.selectedValue)

	GalaxyMap():setSelectedCoordinates(x, y)
	GalaxyMap():show(x, y)
end

-- Lists the percentage of time spent in different states of production, that is, Running vs. some error state
function getRowTooltip(factoryData)
	local tooltip = ""

	if not factoryData['working_state'] then
		include("cosmicvaultdebug").info("Cosmic Overhaul", "Factory data has no key called 'working_state' ")
		printTable(factoryData)
		return ""
	end

	for reason, percentage in pairs(factoryData['working_state']) do
		tooltip = tooltip .. string.format("%7s:  '%s'\n", percentage, reason)
	end

	return tooltip
end

return FactoryOverview
