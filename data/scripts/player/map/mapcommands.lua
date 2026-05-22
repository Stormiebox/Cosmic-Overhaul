OALMapCommands = include("ordersandlooping-mapcommands")
OALMapCommands.initialize()

if onClient() then

    -- Wrap initUI to update orders and orderButtons
    function MapCommands.initUI()
        -- Run copy of base initUI
        OALMapCommands._initUI()

        -- Extract base orders/missions
        local baseOrders = {}
        for i = #orders, 1, -1 do
            table.insert(baseOrders, table.remove(orders, i))
        end

        -- Insert managed orders
        OALMapCommands.applyCommands(OrderButtonType, orders)

        -- Re-insert base orders/missions, excluding those which are now managed
        for i = #baseOrders, 1, -1 do
            if type(baseOrders[i].type) == "string" or baseOrders[i].type > 5 then
                table.insert(orders, table.remove(baseOrders, i))
            end
        end

        -- Re-create order buttons for ship list, filtering disabled missions
        shipList.orderButtons = {}
        for _, order in pairs(orders) do
            if OALMapCommands.commandEnabled(order.type) then
                local button = shipList.ordersContainer:createRoundButton(Rect(), order.icon, order.callback)
                button.tooltip = order.tooltip
                table.insert(shipList.orderButtons, button)
            end
        end
    end

    -- Wrap so enchainCoordinates can be set accurately to fix the Loop bug
    function MapCommands.updateOrderButtons()
        local cx, cy = GalaxyMap():getSelectedCoordinates()
        local enqueueing = MapCommands.isEnqueueing()

        if #shipList.selectedPortraits > 0 and enqueueing then
            local x, y = MapCommands.getLastLocationFromInfo(shipList.selectedPortraits[1].info)
            if x and y then
                MapCommands.enchainCoordinates = {x=x, y=y}
            else
                MapCommands.enchainCoordinates = {x=cx, y=cy}
            end
        else
            MapCommands.enchainCoordinates = nil
        end

        OALMapCommands._updateOrderButtons()
    end
end

-- Base commands with fixed integer IDs from vanilla
OALMapCommands.addCommand("Undo",   "Undo"%_t,           "data/textures/icons/undo.png",           "onUndoPressed", nil, 1)
OALMapCommands.addCommand("Patrol", "Patrol Sector"%_t,  "data/textures/icons/back-forth.png",     "onPatrolPressed", nil, 2)
OALMapCommands.addCommand("Attack", "Attack Enemies"%_t, "data/textures/icons/crossed-rifles.png", "onAggressivePressed", true, 3)
OALMapCommands.addCommand("Repair", "Repair"%_t,         "data/textures/icons/health-normal.png",  "onRepairPressed", nil, 4)

-- Insert 1.3.8 commands along with their callbacks using clean string IDs
OALMapCommands.addCommand("Mine", "Mine"%_t, "data/textures/icons/mining.png", "onMinePressed", nil, "co_mine")
function MapCommands.onMinePressed()
    MapCommands.clearOrdersIfNecessary()
    MapCommands.enqueueOrder("addMineOrder")
    if not MapCommands.isEnqueueing() then MapCommands.runOrders() end
end

OALMapCommands.addCommand("RefineOres", "Refine Ores"%_t, "data/textures/icons/metal-bar.png", "onRefineOresPressed", nil, "co_refine")
function MapCommands.onRefineOresPressed()
    MapCommands.clearOrdersIfNecessary()
    MapCommands.enqueueOrder("addRefineOresOrder")
    if not MapCommands.isEnqueueing() then MapCommands.runOrders() end
end

OALMapCommands.addCommand("Salvage", "Salvage"%_t, "data/textures/icons/scrap-metal.png", "onSalvagePressed", nil, "co_salvage")
function MapCommands.onSalvagePressed()
    MapCommands.clearOrdersIfNecessary()
    MapCommands.enqueueOrder("addSalvageOrder")
    if not MapCommands.isEnqueueing() then MapCommands.runOrders() end
end

OALMapCommands.addCommand("Loop", "Loop"%_t, "data/textures/icons/loop.png", "onLoopPressed", nil, "co_loop")
function MapCommands.onLoopPressed()
    if not MapCommands.enchainCoordinates then return end
    MapCommands.enqueueOrder("addLoop", MapCommands.enchainCoordinates.x, MapCommands.enchainCoordinates.y)
end