local CosmicOverhaulConfig = include("cosmicoverhaulconfig")

function OrderChain.addJumpOrder(x, y)
    -- this command should only ever run server-side for consistency
    if onClient() then
        invokeServerFunction("addJumpOrder", x, y)
        return
    end

    -- this command needs a captain or a player as it changes sector
    local entity = Entity()
    local pilot = entity:getPilotIndices()
    if not pilot and not checkCaptain() then return end

    if callingPlayer then
        local owner, _, player = checkEntityInteractionPermissions(entity, AlliancePrivilege.ManageShips)
        if not owner then
            local player = Player(callingPlayer)
            player:sendChatMessage("", ChatMessageType.Error, "You don't have permission to do that."%_T)
            return
        end

        if not OrderChain.canReceivePlayerOrder() then return end
    end

    -- Cosmic Overhaul: Gate Travel Priority Config Check
    local cfg = CosmicOverhaulConfig and CosmicOverhaulConfig.get and CosmicOverhaulConfig.get() or {}
    local useGatePriority = cfg.enableGateTravelPriority ~= false

    local shipX, shipY = Sector():getCoordinates()

    for _, action in pairs(OrderChain.chain) do
        if action.action == OrderType.Jump or action.action == OrderType.FlyThroughWormhole then
            shipX = action.x
            shipY = action.y
        end
    end

    -- prefer gates and wormholes if the player initiates it
    local jumpValid, error = entity:isJumpRouteValid(shipX, shipY, x, y)
    if callingPlayer and useGatePriority then
        -- Cosmic Overhaul: Gate Travel Priority
        -- Prioritize jumping through known Gates and Wormholes over standard hyperspace routes.
        -- Gather valid gate and wormhole destinations from the player/alliance map knowledge.
        local sectorViewsToCheck = {}

        local player = Player(callingPlayer)
        local view = player:getKnownSector(shipX, shipY)
        if view then
            table.insert(sectorViewsToCheck, view)
        end

        local alliance = Alliance()
        if alliance then
            local view = alliance:getKnownSector(shipX, shipY)
            if view then
                table.insert(sectorViewsToCheck, view)
            end
        end

        -- queue valid gate/wormhole targets if any
        for _, sectorView in pairs(sectorViewsToCheck) do
            local wormholeDestinations = { sectorView:getWormHoleDestinations() }
            for _, dest in pairs(wormholeDestinations) do
                if dest.x == x and dest.y == y then
                    local order = { action = OrderType.FlyThroughWormhole, x = x, y = y, gate = false }
                    if OrderChain.canEnchain(order) then
                        OrderChain.enchain(order)
                    end
                    return
                end
            end

            local gateDestinations = { sectorView:getGateDestinations() }
            for _, dest in pairs(gateDestinations) do
                if dest.x == x and dest.y == y then
                    local order = { action = OrderType.FlyThroughWormhole, x = x, y = y, gate = true }
                    if OrderChain.canEnchain(order) then
                        OrderChain.enchain(order)
                    end
                    return
                end
            end
        end
    end

    -- Cosmic Overhaul: Fallback to standard Hyperspace Jump
    if jumpValid then
        local order = { action = OrderType.Jump, x = x, y = y }
        if OrderChain.canEnchain(order) then
            OrderChain.enchain(order)
        end
        return
    end

    -- Jump not possible
    if not callingPlayer then return end
    local player = Player(callingPlayer)
    player:sendChatMessage("", ChatMessageType.Error, error)
end
callable(OrderChain, "addJumpOrder")

-- Cosmic Overhaul: Expose OAL (Orders And Looping) Map Commands to the Client
callable(OrderChain, "addMineOrder")
callable(OrderChain, "addRefineOresOrder")
callable(OrderChain, "addSalvageOrder")

-- Cosmic Overhaul: Restored 1.0 Looping Support
-- Adds the ability for players to command their ships to loop their queued orders endlessly.
function OrderChain.addLoop(a, b)
    if onClient() then
        invokeServerFunction("addLoop", a, b)
        return
    end

    if callingPlayer then
        local owner, _, player = checkEntityInteractionPermissions(Entity(), AlliancePrivilege.ManageShips)
        if not owner then return end
    end

    local loopIndex
    if a and not b then
        -- interpret as action index
        loopIndex = a
    elseif a and b then
        -- interpret as coordinates
        local x, y = a, b
        local cx, cy = Sector():getCoordinates()
        local i = OrderChain.activeOrder
        local chain = OrderChain.chain

        if i == 0 then i = 1 end

        while i > 0 and i <= #chain do
            local current = chain[i]

            if cx == x and cy == y then
                loopIndex = i
                break
            end

            if current.action == OrderType.Jump then
                cx, cy = current.x, current.y
            end

            i = i + 1
        end

        if not loopIndex then
            OrderChain.sendError("Could not find any orders at %1%:%2%!"%_T, x, y)
        end
    end

    if not loopIndex or loopIndex == 0 or loopIndex > #OrderChain.chain then return end

    local order = {action = OrderType.Loop, loopIndex = loopIndex}

    if OrderChain.canEnchain(order) then
        OrderChain.enchain(order)
    end
end
callable(OrderChain, "addLoop")

function OrderChain.activateLoop(loopIndex)
    if OrderChain.activeOrder == loopIndex then
        -- prevent infinite loops
        return
    end

    OrderChain.activeOrder = loopIndex
    OrderChain.activateOrder()
end

-- Cosmic Overhaul: OAL Looping Guard
-- Wraps orderCompleted to ensure the script does not wipe active orders while a loop is active
if onServer() then
    OrderChain._orderCompleted = OrderChain.orderCompleted
    function OrderChain.orderCompleted()
        if not OrderChain.hasMoreOrders() then
            OrderChain._orderCompleted()
        end
    end
end

-- Cosmic Overhaul: OAL Validation Fix
-- Fixes broken base game order validation that crashes when using custom integer IDs
function OrderChain.checkOrdersValid()
    for _, order in pairs(OrderChain.chain) do
        local exists = false

        for _, v in pairs(OrderType) do
            if order.action == v then
                exists = true
                break
            end
        end

        if not exists then return false end
    end

    return true
end