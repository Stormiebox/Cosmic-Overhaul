package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/player/background/?.lua"

local CommandType = include ("simulation/commandtype")

local OALMapCommands = {}

function OALMapCommands.initialize()
    OALMapCommands.commands = {}
    OALMapCommands.commandsOrder = {}

    -- Keep copies of overridden base functions
    OALMapCommands._initUI = MapCommands.initUI
    OALMapCommands._updateOrderButtons = MapCommands.updateOrderButtons
end

function OALMapCommands.commandEnabled(commandType)
    return true -- Natively enabled in Cosmic Overhaul
end

function OALMapCommands.addCommand(typeName, tooltip, icon, callback, stationAllowed, buttonId)
    -- Only insert new commands, override duplicates
    if not OALMapCommands.commands[typeName] then
        OALMapCommands.commandsOrder[#OALMapCommands.commandsOrder+1] = typeName
    end
    OALMapCommands.commands[typeName] = {
        type = buttonId or typeName, -- Use provided hardcoded ID or fallback to string name
        tooltip = tooltip,
        icon = icon,
        callback = callback,
        stationAllowed = stationAllowed
    }
end

function OALMapCommands.applyCommands(orderButtonType, orders)
    for _, typeName in pairs(OALMapCommands.commandsOrder) do
        local command = OALMapCommands.commands[typeName]
        orderButtonType[typeName] = command.type
        table.insert(orders, command)
    end
end

function initialize(...)
    if OALMapCommands.initialize then return OALMapCommands.initialize(...) end
end


return OALMapCommands