package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/player/background/simulation/?.lua"

include("utility")
include("stringutility")
include("randomext")
include("moddata")

local isInHotkeyCommandMode

local GMHK_MapCommands_onGalaxyMapKeyboardEvent_shadow = MapCommands.onGalaxyMapKeyboardEvent
function MapCommands.onGalaxyMapKeyboardEvent(key, pressed)
    if not Keyboard().altPressed then
        GMHK_MapCommands_onGalaxyMapKeyboardEvent_shadow(key, pressed)
    end

    local keyToCommandMap = {}
    keyToCommandMap[KeyboardKey._Q] = CommandType.Salvage
    keyToCommandMap[KeyboardKey._W] = CommandType.Mine
    keyToCommandMap[KeyboardKey._E] = CommandType.Refine
    keyToCommandMap[KeyboardKey._R] = CommandType.Travel
    keyToCommandMap[KeyboardKey._A] = CommandType.Procure
    keyToCommandMap[KeyboardKey._S] = CommandType.Sell
    keyToCommandMap[KeyboardKey._D] = CommandType.Trade
    keyToCommandMap[KeyboardKey._F] = CommandType.Restock
    keyToCommandMap[KeyboardKey._Z] = CommandType.Recall
    keyToCommandMap[KeyboardKey._X] = CommandType.Expedition
    keyToCommandMap[KeyboardKey._C] = CommandType.Scout

    if key == KeyboardKey.LAlt then
        isInHotkeyCommandMode = pressed
    elseif key >= KeyboardKey._1 and key <= KeyboardKey._9 and pressed then
        local tappedIndex = key - KeyboardKey._1 + 1
        GMHK_onSelectionGroupTapped(tappedIndex)
    elseif key == KeyboardKey._T and pressed then
        local firstPortrait = MapCommands.getFirstSelectedPortrait()
        if firstPortrait then
            Player():sendChatMessage(
            string.format("/teleporttoship %i %i %i \"%s\"", firstPortrait.coordinates.x, firstPortrait.coordinates.y,
                firstPortrait.owner, firstPortrait.name), 1)
        end
    elseif keyToCommandMap[key] and pressed then
        GMHK_tryDoHotkeyCaptainCommand(keyToCommandMap[key])
    elseif pressed and key == KeyboardKey._G then
        -- Really want this to be equivalent to right click > enter coordinates, but that seems
        -- impossible in .lua at the moment.
        -- local x, y = GalaxyMap():getHoveredCoordinates()
        -- local cx, cy = Sector():getCoordinates()
        -- printlog("DEBUG: setting jump from "
        -- .. cx .. ", " .. cy .. " to " .. x .. ", " .. y .. " for " .. Player().craft.name)
        -- invokeEntityFunction(cx, cy, nil, {faction = Player().index, name = Player().craft.name}, "data/scripts/entity/orderchain.lua", "addJumpOrder", x, y)
        -- -- invokeServerFunction("GMHK_jumpTo", x, y)
    end
end

function MapCommands.GMHK_jumpTo(x, y)
    printlog("DEBUG: jumping to " .. x .. ", " .. y)
    local player = Player()
    local ship = player.craft
    ControlUnit(ship).autoPilotEnabled = true
    ShipAI(ship):setJump(x, y)
    -- ControlUnit(ship).autoPilotEnabled = false
end

callable(MapCommands, "GMHK_jumpTo")

local GMHK_MapCommands_updateInputHints_shadow = MapCommands.updateInputHints
function MapCommands.updateInputHints()
    GMHK_MapCommands_updateInputHints_shadow()

    if #shipList.selectedPortraits > 0 then
        if isInHotkeyCommandMode then
            inputHints.label.caption = "[Holding ALT: Commands]\n"
                .. "[ALT+Q] Salvage   [Alt+W] Mine   [ALT+E] Refine   [ALT+R] Travel\n"
                .. "[ALT+A] Procure   [ALT+S] Sell   [ALT+D] Trade   [ALT+F] Restock\n"
                .. "[ALT+Z] Recall   [ALT+X] Expedition   [Alt+C] Scout"
        else
            inputHints.label.caption = inputHints.label.caption
                .. "\n[T] Switch to selected"
        end
    end
end

function GMHK_tryDoHotkeyCaptainCommand(commandType)
    if not isInHotkeyCommandMode then return false end
    local portrait = MapCommands.getFirstSelectedPortrait()
    if not portrait then return false end
    if not portrait.captain then return false end
    if not portrait.portrait.available
        and portrait.commandType ~= commandType
        and commandType ~= CommandType.Recall
    then
        return false
    end
    if commandType == CommandType.Recall then
        if portrait.portrait.available then return false end
        MapCommands.onRecallPressed()
    else
        MapCommands[commandType .. "_CommandButtonPressed"]()
    end
    return true
end

function GMHK_onSelectionGroupTapped(tappedIndex)
    local nowMs = appTimeMs()
    if GMHK_lastSelectionGroupTapIndex == tappedIndex
        and GMHK_lastSelectionGroupTapTimeMs + 500 >= nowMs
    then
        local ship, coordinates = GMHK_getFirstShipFromSelectionGroup(tappedIndex)
        if ship then
            local galaxyMap = GalaxyMap()
            galaxyMap:setSelectedCoordinates(coordinates.x, coordinates.y)
            galaxyMap:lookAtSmooth(coordinates.x, coordinates.y)
        end
    end
    GMHK_lastSelectionGroupTapIndex = tappedIndex
    GMHK_lastSelectionGroupTapTimeMs = nowMs
end

function GMHK_getFirstShipFromSelectionGroup(index)
    for ship, groupIndex in pairs(Player():getSelectionGroup(index)) do
        if groupIndex == index then
            for _, portraitWrapper in pairs(shipList.selectedPortraits) do
                if portraitWrapper.owner == ship.factionIndex and ship.name == portraitWrapper.name then
                    return ship, { x = portraitWrapper.coordinates.x, y = portraitWrapper.coordinates.y }
                end
            end
        end
    end
end

-- This is just to save the effective state of things like "show offscreen ships"

if onClient() then
    local mcm_MapCommands_initialize_original = MapCommands.initialize
    function MapCommands.initialize(...)
        if mcm_MapCommands_initialize_original then
            mcm_MapCommands_initialize_original(...)
        end
        local saveData = ReadModData('NyrinsMapCommandMod.mapCommands')
        if saveData then
            shipList.stationsVisible = saveData.stationsVisible or shipList.stationsVisible
            shipList.offscreenShipsVisible = saveData.offscreenShipsVisible or shipList.offscreenShipsVisible
            shipList.backgroundShipsVisible = saveData.backgroundShipsVisible or shipList.backgroundShipsVisible
        end
    end

    function doThenSave(originalFunc, ...)
        return function(...)
            if originalFunc then originalFunc(...) end
            local saveData = CreateModData('NyrinsMapCommandMod.mapCommands')
            saveData.stationsVisible = shipList.stationsVisible
            saveData.offscreenShipsVisible = shipList.offscreenShipsVisible
            saveData.backgroundShipsVisible = shipList.backgroundShipsVisible
            saveData:save()
        end
    end

    MapCommands.onToggleOffscreenButtonPressed = doThenSave(MapCommands.onToggleOffscreenButtonPressed)
    MapCommands.onToggleStationsButtonPressed = doThenSave(MapCommands.onToggleStationsButtonPressed)
    MapCommands.onToggleBGSButtonPressed = doThenSave(MapCommands.onToggleBGSButtonPressed)
end
