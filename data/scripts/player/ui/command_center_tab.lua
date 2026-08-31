package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/player/background/simulation/?.lua"

include("callable")
include("utility")
include("stringutility")

local CommandType = include("commandtype")

-- namespace CommandCenter
CommandCenter = {}
local self = CommandCenter

local COMPLETING_SOON_THRESHOLD = 60 -- seconds

if onClient() then
    local commandList
    local filterComboBox
    local incomeLabel
    local idleChip, soonChip, recalledChip
    local sortingButtons = {}
    local sortingLabels = { "Ship"%_t, "Operation"%_t, "Location"%_t, "ETA"%_t, "Status"%_t }
    local selectedSorting = 4 -- ETA by default, so the most urgent operations float up
    local sortingType = 1
    local lastOperations = {}

    function CommandCenter.initialize()
        local playerWindow = PlayerWindow()

        -- Using custom CommandCenter icon for the tab
        self.tab = playerWindow:createTab("Command Center"%_t, "data/textures/icons/CommandCenterTab.png",
            "Command Center"%_t)
        self.tab.onSelectedFunction = "clientFetchData"
        self.tab.onShowFunction = "clientFetchData"
        playerWindow:moveTabToTheRight(self.tab)
        CommandCenter.buildWindow(self.tab)
        CommandCenter.clientFetchData()
    end

    function CommandCenter.buildWindow(container)
        -- Three header rows (title/income, filter controls, attention chips) stacked above
        -- the operations list, each on its own strip so nothing has to share horizontal
        -- space and risk overlapping on a narrower player window.
        local hsplit = UIHorizontalSplitter(Rect(container.size), 5, 5, 0.20)
        local margin = 10
        local topWidth = hsplit.top.width
        local topHeight = hsplit.top.height

        local row1Bottom = topHeight * 0.30
        local row2Top = topHeight * 0.34
        local row2Bottom = topHeight * 0.64
        local row3Top = topHeight * 0.68
        local row3Bottom = topHeight - 4

        -- Row 1: title (left) + fleet income summary (right)
        container:createLabel(Rect(margin, 2, margin + 260, row1Bottom), "Command Center"%_t, 20)

        incomeLabel = container:createLabel(Rect(topWidth * 0.40, 2, topWidth - margin, row1Bottom), "", 15)
        incomeLabel:setTopLeftAligned()

        -- Row 2: filter, refresh, recall, reset -- left-to-right with fixed spacing
        filterComboBox = container:createValueComboBox(Rect(margin, row2Top, margin + 220, row2Bottom), "onFilterChanged")
        filterComboBox:addEntry("All", "All Operations"%_t)
        filterComboBox:addEntry("Idle", "Idle Ships"%_t)
        filterComboBox:addEntry("Active", "Active Operations"%_t)
        filterComboBox:addEntry("Soon", "Completing Soon"%_t)
        filterComboBox:addEntry("Recalled", "Recalled"%_t)
        filterComboBox.tooltip = "Filter the fleet list"%_t

        local refreshButton = container:createButton(Rect(margin + 235, row2Top, margin + 355, row2Bottom), "Refresh"%_t, "clientFetchData")
        refreshButton.icon = "data/textures/icons/refresh.png"
        refreshButton.tooltip = "Refresh Active Operations"%_t

        local recallButton = container:createButton(Rect(margin + 370, row2Top, margin + 520, row2Bottom), "Recall Ship"%_t, "clientRecallShip")
        recallButton.icon = "data/textures/icons/cancel.png"
        recallButton.tooltip = "Recall selected ship from its operation"%_t

        local resetIncomeButton = container:createButton(Rect(margin + 535, row2Top, margin + 700, row2Bottom), "Reset Income Tracker"%_t, "clientResetIncome")
        resetIncomeButton.tooltip = "Reset the cumulative Fleet Income counter back to zero"%_t

        -- Row 3: clickable "attention needed" chips -- clicking one jumps the filter straight to it
        idleChip = container:createButton(Rect(margin, row3Top, margin + 220, row3Bottom), "", "onIdleChipPressed")
        idleChip.tooltip = "Show idle ships not currently running any operation"%_t

        soonChip = container:createButton(Rect(margin + 235, row3Top, margin + 455, row3Bottom), "", "onSoonChipPressed")
        soonChip.tooltip = "Show operations completing within a minute"%_t

        recalledChip = container:createButton(Rect(margin + 470, row3Top, margin + 690, row3Bottom), "", "onRecalledChipPressed")
        recalledChip.tooltip = "Show ships that were recalled and are returning"%_t

        -- Operations list
        local listRect = Rect(margin, hsplit.bottom.lower.y, container.size.x - margin, container.size.y - 5)
        local width = listRect.width - 20

        local currentX = margin
        local colWidths = { width * 0.24, width * 0.20, width * 0.22, width * 0.14, width * 0.20 }
        for i = 1, 5 do
            local btnRect = Rect(currentX, listRect.lower.y - 22, currentX + colWidths[i] - 2, listRect.lower.y)
            local btn = container:createButton(btnRect, sortingLabels[i], "onSort" .. i)
            btn.hasFrame = false
            btn.textSize = 14
            btn.tooltip = "Sort by "%_t .. sortingLabels[i]
            table.insert(sortingButtons, btn)
            currentX = currentX + colWidths[i]
        end

        commandList = container:createListBoxEx(listRect)
        commandList.columns = 5
        commandList.rowHeight = 32
        for ndx = 0, 4 do
            commandList:setColumnWidth(ndx, colWidths[ndx + 1])
        end

        CommandCenter.updateSortingIcons()
    end

    function CommandCenter.clientFetchData()
        invokeServerFunction("serverFetchData")
    end

    function CommandCenter.clientRecallShip()
        local selectedShip = commandList.selectedValue
        if not selectedShip or selectedShip == "" then return end
        invokeServerFunction("serverRecallShip", selectedShip)
    end

    function CommandCenter.clientResetIncome()
        invokeServerFunction("serverResetIncome")
    end

    function CommandCenter.onFilterChanged()
        CommandCenter.populateUI()
    end

    -- ValueComboBox only exposes "NoCallback" setters for programmatic selection, so the
    -- filter has to be re-applied explicitly here rather than relying on onFilterChanged.
    local function jumpFilterTo(value)
        filterComboBox:setSelectedValueNoCallback(value)
        CommandCenter.populateUI()
    end

    function CommandCenter.onIdleChipPressed() jumpFilterTo("Idle") end
    function CommandCenter.onSoonChipPressed() jumpFilterTo("Soon") end
    function CommandCenter.onRecalledChipPressed() jumpFilterTo("Recalled") end

    function CommandCenter.onSort1() CommandCenter.updateSorting(1) end
    function CommandCenter.onSort2() CommandCenter.updateSorting(2) end
    function CommandCenter.onSort3() CommandCenter.updateSorting(3) end
    function CommandCenter.onSort4() CommandCenter.updateSorting(4) end
    function CommandCenter.onSort5() CommandCenter.updateSorting(5) end

    function CommandCenter.updateSorting(newSorting)
        if selectedSorting == newSorting then
            sortingType = sortingType * -1
        else
            selectedSorting = newSorting
            sortingType = 1
        end
        CommandCenter.updateSortingIcons()
        CommandCenter.populateUI()
    end

    function CommandCenter.updateSortingIcons()
        for ndx, button in ipairs(sortingButtons) do
            local label = sortingLabels[ndx]
            if ndx == selectedSorting then
                button.caption = label .. (sortingType < 0 and " ▼" or " ▲")
            else
                button.caption = label
            end
        end
    end

    -- Compares by the field relevant to the selected column; ETA sorts by raw seconds
    -- (soonest first by default) rather than the formatted display string.
    local function sortValue(entry, column)
        if column == 1 then return entry.shipName
        elseif column == 2 then return entry.commandName
        elseif column == 3 then return entry.location
        elseif column == 4 then return entry.etaSeconds or math.huge
        elseif column == 5 then return entry.status
        end
        return ""
    end

    function CommandCenter.receiveData(data)
        if not commandList then return end
        if type(data) ~= "table" then return end

        lastOperations = data.operations or {}
        CommandCenter.updateIncomeLabel(data.income)
        CommandCenter.updateChips()
        CommandCenter.populateUI()
    end

    function CommandCenter.updateIncomeLabel(income)
        if not incomeLabel then return end
        if not income or (income.total or 0) <= 0 then
            incomeLabel.caption = "Fleet Income: "%_t .. "¢0 (no background payouts tracked yet)"%_t
            incomeLabel.color = ColorRGB(0.6, 0.6, 0.6)
            return
        end

        local sinceText = ""
        if income.since and income.since > 0 then
            local elapsed = math.max(0, (income.now or income.since) - income.since)
            sinceText = " "%_t .. "over the last"%_t .. " " .. createReadableShortTimeString(math.floor(elapsed))
        end

        incomeLabel.caption = "Fleet Income: "%_t .. "¢" .. createMonetaryString(income.total) .. sinceText
        incomeLabel.color = ColorRGB(0.4, 1.0, 0.6)
    end

    function CommandCenter.updateChips()
        local idleCount, soonCount, recalledCount = 0, 0, 0
        for _, entry in pairs(lastOperations) do
            if entry.category == "idle" then idleCount = idleCount + 1
            elseif entry.category == "soon" then soonCount = soonCount + 1
            elseif entry.category == "recalled" then recalledCount = recalledCount + 1
            end
        end

        idleChip.caption = "Idle Ships: "%_t .. tostring(idleCount)
        idleChip.icon = idleCount > 0 and "data/textures/icons/warning-system.png" or ""

        soonChip.caption = "Completing Soon: "%_t .. tostring(soonCount)
        soonChip.icon = soonCount > 0 and "data/textures/icons/warning-system.png" or ""

        recalledChip.caption = "Recalled: "%_t .. tostring(recalledCount)
        recalledChip.icon = ""
    end

    function CommandCenter.populateUI()
        if not commandList or not filterComboBox then return end

        local filter = filterComboBox.selectedValue
        local filtered = {}
        for _, entry in pairs(lastOperations) do
            local match = true
            if filter == "Idle" and entry.category ~= "idle" then match = false end
            if filter == "Active" and entry.category ~= "active" and entry.category ~= "soon" then match = false end
            if filter == "Soon" and entry.category ~= "soon" then match = false end
            if filter == "Recalled" and entry.category ~= "recalled" then match = false end
            if match then table.insert(filtered, entry) end
        end

        table.sort(filtered, function(a, b)
            local valA, valB = sortValue(a, selectedSorting), sortValue(b, selectedSorting)
            if valA == valB then return false end
            if sortingType == 1 then return valA < valB else return valA > valB end
        end)

        commandList:clear()
        local white = ColorRGB(1, 1, 1)
        local gray = ColorRGB(0.8, 0.8, 0.8)

        for _, entry in pairs(filtered) do
            commandList:addRow(entry.shipName)
            local row = commandList.rows - 1

            local statusColor = gray
            if entry.category == "soon" then statusColor = ColorRGB(1.0, 0.85, 0.2) -- Amber
            elseif entry.category == "active" then statusColor = ColorRGB(0.2, 1.0, 0.2) -- Green
            elseif entry.category == "recalled" then statusColor = ColorRGB(1.0, 0.4, 0.4) -- Red
            elseif entry.category == "idle" then statusColor = ColorRGB(0.7, 0.7, 0.7) -- Gray
            end

            -- shipName is a proper noun and is never translated; the rest were sent as
            -- plain strings server-side, so %_t is applied once, locally, here.
            commandList:setEntryNoCallback(0, row, entry.shipName, false, false, white)
            commandList:setEntryNoCallback(1, row, entry.commandName%_t, false, false, gray)
            commandList:setEntryNoCallback(2, row, entry.location%_t, false, false, gray)
            commandList:setEntryNoCallback(3, row, entry.eta%_t, false, false, gray)
            commandList:setEntryNoCallback(4, row, entry.status%_t, false, false, statusColor)
        end
    end
end

-- Categorizes a formatted operation entry for filtering/coloring on the client. Kept
-- server-side so client and server never disagree on what counts as "soon".
local function categorize(entry)
    if entry.isRecalled then return "recalled" end
    if entry.isIdle then return "idle" end
    if entry.etaSeconds and entry.etaSeconds <= COMPLETING_SOON_THRESHOLD then return "soon" end
    return "active"
end

-- Reads the cumulative Fleet Income counters tracked by simulation.lua's
-- ARCC_trackFleetIncome, summed across the player's own faction and (if applicable)
-- their alliance, since a background command can be attached to either.
local function collectIncome(player)
    local total, since = 0, nil

    local holders = { player }
    if player.allianceIndex and player.allianceIndex > 0 then
        local alliance = Alliance(player.allianceIndex)
        if alliance then table.insert(holders, alliance) end
    end

    for _, holder in pairs(holders) do
        local holderTotal = holder:getValue("co_fleet_income_total") or 0
        if holderTotal > 0 then
            total = total + holderTotal
            local holderSince = holder:getValue("co_fleet_income_since")
            if holderSince and (not since or holderSince < since) then
                since = holderSince
            end
        end
    end

    return total, since
end

function CommandCenter.serverFetchData()
    if not onServer() then return end

    local player = Player(callingPlayer)
    if not player then return end

    -- Intercept the simulation script's memory storage to extract the active commands.
    -- invokeFunction's first return is a call-status code (0 = success), not a boolean --
    -- every Lua number including 0 is truthy, so a bare "not ok" check never actually
    -- catches a failed call here; compare against 0 explicitly.
    local ok, secureData = player:invokeFunction("simulation.lua", "secure")
    if ok ~= 0 or type(secureData) ~= "table" or not secureData.commands then
        secureData = { commands = {} }
    end

    local formattedData = {}

    -- Map the internal CommandType Enums to UI-friendly text. Kept as plain, untranslated
    -- strings and sent as-is -- the client applies %_t locally once on receipt (see
    -- populateUI), matching the "send pure strings across the network boundary" convention
    -- already established elsewhere in this mod suite (e.g. galacticpolitics_tab.lua).
    local cmdNames = {}
    local function safeAdd(key, name) if key ~= nil then cmdNames[key] = name end end

    safeAdd(CommandType.Mine, "Mining")
    safeAdd(CommandType.Salvage, "Salvaging")
    safeAdd(CommandType.Travel, "Traveling")
    safeAdd(CommandType.Sell, "Selling")
    safeAdd(CommandType.Procure, "Procuring")
    safeAdd(CommandType.Trade, "Trading")
    safeAdd(CommandType.Supply, "Supplying")
    safeAdd(CommandType.Expedition, "Expedition")
    safeAdd(CommandType.Scout, "Scouting")
    safeAdd(CommandType.Restock, "Restocking")
    safeAdd(CommandType.Refine, "Refining")

    -- Fallbacks in case the custom commands store their string name directly
    cmdNames["Restock"] = "Restocking"
    cmdNames["Refine"] = "Refining"

    -- OAL (1.0 Orders and Looping) integration support
    cmdNames["co_mine"] = "Mining"
    cmdNames["co_refine"] = "Refining Ores"
    cmdNames["co_salvage"] = "Salvaging"
    cmdNames["co_loop"] = "Looping Orders"

    local backgroundShips = {}

    for shipName, cmd in pairs(secureData.commands) do
        -- Safety check: ensure cmd is a table and actually has a 'type' before parsing
        if type(cmd) == "table" and cmd.type then
            local entry = {}
            entry.shipName = cmd.shipName or (type(shipName) == "string" and shipName) or "Unknown"
            entry.commandName = cmdNames[cmd.type] or "Unknown Operation"

            -- Format the location string
            if cmd.area and cmd.area.lower and cmd.area.upper then
                if cmd.area.lower.x == cmd.area.upper.x and cmd.area.lower.y == cmd.area.upper.y then
                    entry.location = string.format("(%d:%d)", cmd.area.lower.x, cmd.area.lower.y)
                else
                    entry.location = string.format("(%d:%d) to (%d:%d)", cmd.area.lower.x, cmd.area.lower.y,
                        cmd.area.upper.x, cmd.area.upper.y)
                end
            elseif cmd.type == "co_loop" or cmd.type == "Loop" then
                entry.location = "Active Route"
            else
                entry.location = "Unknown"
            end

            -- Format ETA and Status
            if cmd.data then
                if cmd.data.ccm and cmd.data.ccm.recalled then
                    entry.isRecalled = true
                    entry.status = "Recalled"
                    entry.eta = "-"
                else
                    if cmd.type == "co_loop" or cmd.type == "Loop" then
                        entry.eta = "Continuous"
                    else
                        local remaining = math.max(0, (cmd.data.duration or 0)-(cmd.data.runTime or 0))
                        entry.etaSeconds = remaining
                        entry.eta = createReadableShortTimeString(math.floor(remaining))
                    end
                    entry.status = "Active"
                end
            else
                entry.eta = "?"
                entry.status = "Unknown"
            end

            entry.category = categorize(entry)
            table.insert(formattedData, entry)
            backgroundShips[entry.shipName] = true
        end
    end

    -- Also fetch standard physical orders and idle ships tracked by the server.
    -- getShipNames() returns a vararg of strings (confirmed against the engine's own
    -- generated docs: "function string... getShipNames()", and every vanilla call site,
    -- e.g. simulation.lua/mapcommands.lua/repairdock.lua, all use the {obj:getShipNames()}
    -- wrapping below) -- NOT a single table, despite the Avorion Stubs' own return-type
    -- annotation claiming table<number,string>. Capturing it unwrapped into one local would
    -- silently truncate to just the first ship name.
    local shipNames = { player:getShipNames() }
    if #shipNames > 0 then
        for _, sName in pairs(shipNames) do
            if not backgroundShips[sName] then
                local status = player:getShipStatus(sName)
                if status and status ~= "" and status ~= "Destroyed"%_T then
                    local entry = {}
                    entry.shipName = sName
                    entry.eta = "-"

                    if status == "Idle"%_T then
                        entry.isIdle = true
                        entry.commandName = "Idle"
                        entry.location = "No Active Orders"
                        entry.status = "Idle"
                    else
                        entry.commandName = status
                        entry.location = "In-Sector"
                        entry.eta = "Continuous"
                        entry.status = "Active"
                    end

                    entry.category = categorize(entry)
                    table.insert(formattedData, entry)
                end
            end
        end
    end

    local total, since = collectIncome(player)

    invokeClientFunction(player, "receiveData", {
        operations = formattedData,
        income = { total = total, since = since, now = os.time() },
    })
end

callable(CommandCenter, "serverFetchData")

function CommandCenter.serverRecallShip(shipName)
    if not onServer() then return end
    local player = Player(callingPlayer)
    if not player then return end

    -- Safely tap into the background simulation script to order the recall
    player:invokeFunction("simulation.lua", "recall", shipName)

    CommandCenter.serverFetchData() -- Instantly refresh UI to show "Recalled"
end

callable(CommandCenter, "serverRecallShip")

function CommandCenter.serverResetIncome(shipName)
    if not onServer() then return end
    local player = Player(callingPlayer)
    if not player then return end

    player:setValue("co_fleet_income_total", 0)
    player:setValue("co_fleet_income_since", nil)

    if player.allianceIndex and player.allianceIndex > 0 then
        local alliance = Alliance(player.allianceIndex)
        if alliance then
            alliance:setValue("co_fleet_income_total", 0)
            alliance:setValue("co_fleet_income_since", nil)
        end
    end

    CommandCenter.serverFetchData()
end

callable(CommandCenter, "serverResetIncome")

return CommandCenter
