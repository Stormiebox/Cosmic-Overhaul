package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/player/background/simulation/?.lua"

include("callable")
include("utility")
include("stringutility")

local CommandType = include("commandtype")

-- namespace CommandCenter
CommandCenter = {}
local self = CommandCenter

if onClient() then
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

    local commandList

    function CommandCenter.buildWindow(container)
        local hsplit = UIHorizontalSplitter(Rect(container.size), 5, 5, 0.1)

        local margin = 10
        -- 5 Columns width calculation accounting for the scrollbar (~20px)
        local b_width = (container.size.x-2*margin-20)/5

        local refreshButton = container:createButton(
        Rect(hsplit.top.width-40, 5, hsplit.top.width, hsplit.top.height-25), "Refresh"%_t, "clientFetchData")
        refreshButton.icon = "data/textures/icons/refresh.png"
        refreshButton.tooltip = "Refresh Active Operations"%_t

        local recallButton = container:createButton(
        Rect(hsplit.top.width-200, 5, hsplit.top.width-50, hsplit.top.height-25), "Recall Ship"%_t, "clientRecallShip")
        recallButton.icon = "data/textures/icons/cancel.png"
        recallButton.tooltip = "Recall selected ship from its operation"%_t

        container:createLabel(Rect(margin, 5, margin+200, hsplit.top.height-5), "Active Fleet Operations"%_t, 20)

        commandList = container:createListBoxEx(Rect(margin, hsplit.top.height, hsplit.bottom.width-2*margin,
            hsplit.bottom.height))
        commandList.columns = 5
        commandList.rowHeight = 40

        for ndx = 0, 4 do
            commandList:setColumnWidth(ndx, b_width)
        end

        commandList.headline = true
    end

    function CommandCenter.clientFetchData()
        invokeServerFunction("serverFetchData")
    end

    function CommandCenter.clientRecallShip()
        local selectedShip = commandList.selectedValue
        if not selectedShip or selectedShip == "" then return end
        invokeServerFunction("serverRecallShip", selectedShip)
    end

    function CommandCenter.receiveData(data)
        if not commandList then return end

        commandList:clear()
        local white = ColorRGB(1, 1, 1)
        local gray = ColorRGB(0.8, 0.8, 0.8)

        commandList:addRow() -- headline
        commandList:setEntryNoCallback(0, 0, "Ship"%_t, true, false, white)
        commandList:setEntryNoCallback(1, 0, "Operation"%_t, true, false, white)
        commandList:setEntryNoCallback(2, 0, "Location"%_t, true, false, white)
        commandList:setEntryNoCallback(3, 0, "ETA"%_t, true, false, white)
        commandList:setEntryNoCallback(4, 0, "Status"%_t, true, false, white)

        for _, cmd in pairs(data) do
            commandList:addRow(cmd.shipName)
            local row = commandList.rows-1

            local statusColor = gray
            if cmd.status == "Active"%_T then
                statusColor = ColorRGB(0.2, 1.0, 0.2) -- Green
            elseif cmd.status == "Recalled"%_T then
                statusColor = ColorRGB(1.0, 0.4, 0.4) -- Red
            end

            commandList:setEntryNoCallback(0, row, cmd.shipName, false, false, white)
            commandList:setEntryNoCallback(1, row, cmd.commandName%_t, false, false, gray)
            commandList:setEntryNoCallback(2, row, cmd.location%_t, false, false, gray)
            commandList:setEntryNoCallback(3, row, cmd.eta%_t, false, false, gray)
            commandList:setEntryNoCallback(4, row, cmd.status%_t, false, false, statusColor)
        end
    end
end

function CommandCenter.serverFetchData()
    if not onServer() then return end

    local player = Player(callingPlayer)
    if not player then return end

    -- Intercept the simulation script's memory storage to extract the active commands
    local ok, secureData = player:invokeFunction("simulation.lua", "secure")
    if not ok or type(secureData) ~= "table" or not secureData.commands then
        invokeClientFunction(player, "receiveData", {})
        return
    end

    local formattedData = {}

    -- Map the internal CommandType Enums to UI-friendly text
    local cmdNames = {}
    local function safeAdd(key, name) if key ~= nil then cmdNames[key] = name end end

    safeAdd(CommandType.Mine, "Mining"%_T)
    safeAdd(CommandType.Salvage, "Salvaging"%_T)
    safeAdd(CommandType.Travel, "Traveling"%_T)
    safeAdd(CommandType.Sell, "Selling"%_T)
    safeAdd(CommandType.Procure, "Procuring"%_T)
    safeAdd(CommandType.Trade, "Trading"%_T)
    safeAdd(CommandType.Supply, "Supplying"%_T)
    safeAdd(CommandType.Expedition, "Expedition"%_T)
    safeAdd(CommandType.Scout, "Scouting"%_T)
    safeAdd(CommandType.Restock, "Restocking"%_T)
    safeAdd(CommandType.Refine, "Refining"%_T)

    -- Fallbacks in case the custom commands store their string name directly
    cmdNames["Restock"] = "Restocking"%_T
    cmdNames["Refine"] = "Refining"%_T

    -- OAL (1.0 Orders and Looping) integration support
    cmdNames["co_mine"] = "Mining"%_T
    cmdNames["co_refine"] = "Refining Ores"%_T
    cmdNames["co_salvage"] = "Salvaging"%_T
    cmdNames["co_loop"] = "Looping Orders"%_T

    local backgroundShips = {}

    for shipName, cmd in pairs(secureData.commands) do
        -- Safety check: ensure cmd is a table and actually has a 'type' before parsing
        if type(cmd) == "table" and cmd.type then
            local entry = {}
            entry.shipName = cmd.shipName or (type(shipName) == "string" and shipName) or "Unknown"%_T
            entry.commandName = cmdNames[cmd.type] or "Unknown Operation"%_T

            -- Format the location string
            if cmd.area and cmd.area.lower and cmd.area.upper then
                if cmd.area.lower.x == cmd.area.upper.x and cmd.area.lower.y == cmd.area.upper.y then
                    entry.location = string.format("(%d:%d)", cmd.area.lower.x, cmd.area.lower.y)
                else
                    entry.location = string.format("(%d:%d) to (%d:%d)", cmd.area.lower.x, cmd.area.lower.y,
                        cmd.area.upper.x, cmd.area.upper.y)
                end
            elseif cmd.type == "co_loop" or cmd.type == "Loop" then
                entry.location = "Active Route"%_T
            else
                entry.location = "Unknown"%_T
            end

            -- Format ETA and Status
            if cmd.data then
                if cmd.data.ccm and cmd.data.ccm.recalled then
                    entry.status = "Recalled"%_T
                    entry.eta = "-"
                else
                    if cmd.type == "co_loop" or cmd.type == "Loop" then
                        entry.eta = "Continuous"%_T
                    else
                        local remaining = math.max(0, (cmd.data.duration or 0)-(cmd.data.runTime or 0))
                        entry.eta = createReadableShortTimeString(math.floor(remaining))
                    end
                    entry.status = "Active"%_T
                end
            else
                entry.eta = "?"
                entry.status = "Unknown"%_T
            end

            table.insert(formattedData, entry)
            backgroundShips[entry.shipName] = true
        end
    end

    -- Also fetch standard physical orders for loaded/unloaded ships tracked by the server
    local ok, shipNames = pcall(function() return player:getShipNames() end)
    if ok and shipNames and type(shipNames) == "table" then
        for _, sName in pairs(shipNames) do
            if not backgroundShips[sName] then
                local okStatus, status = pcall(function() return player:getShipStatus(sName) end)
                if okStatus and status and status ~= "" and status ~= "Idle"%_T and status ~= "Destroyed"%_T then
                    local entry = {}
                    entry.shipName = sName
                    entry.commandName = status
                    entry.location = "In-Sector"%_T
                    entry.eta = "Continuous"%_T
                    entry.status = "Active"%_T
                    table.insert(formattedData, entry)
                end
            end
        end
    end

    invokeClientFunction(player, "receiveData", formattedData)
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


function initialize(...)
    if CommandCenter.initialize then return CommandCenter.initialize(...) end
end

return CommandCenter
