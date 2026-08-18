package.path = package.path .. ";data/scripts/lib/?.lua"

local ccm = include("ccm")

-- namespace SmartJump
SmartJump = {}

if onClient() then

function SmartJump.initialize()
    Player():registerCallback("onPreRenderHud", "onPreRenderHud")
end

local lastPress = 0

function SmartJump.onPreRenderHud()
    if not ccm then return end
    local cocfg = ccm.bind("Cosmic_Overhaul")
    if not cocfg then return end

    if cocfg.isKeyComboDown("hotkeySmartJump") then
        local now = ClientTime()
        if now - lastPress < 0.5 then return end
        lastPress = now
        
        local player = Player()
        local craft = player.craft
        if not craft then return end
        
        local nav = player:getShipNavigation()
        if not nav then return end
        
        local tx, ty = nav:getJumpDestination()
        if not tx or not ty then return end
        
        local cx, cy = Sector():getCoordinates()
        if tx == cx and ty == cy then return end
        
        invokeServerFunction("alignToJump", tx, ty)
    end
end

end -- onClient

if onServer() then

function SmartJump.alignToJump(tx, ty)
    local player = Player(callingPlayer)
    if not player then return end
    
    local craft = player.craft
    if not craft then return end
    
    local cx, cy = Sector():getCoordinates()
    if tx == cx and ty == cy then return end

    -- The hyperspace direction is provided natively by the engine or math.
    -- In Avorion, the galaxy map Y maps to the sector's negative Z axis (or positive?).
    -- Actually, it is mathematically vec3(tx - cx, 0, -(ty - cy)) or similar.
    -- Wait, looking at vanilla scripts (e.g. gate.lua)
    local dx = tx - cx
    local dy = ty - cy
    
    -- In gate.lua:
    -- local dir = normalize(vec3(dx, 0, -dy))
    local look = normalize(vec3(dx, 0, -dy))
    local up = vec3(0, 1, 0)
    
    local newMatrix = MatrixLookUpPosition(look, up, craft.translationf)
    
    craft.orientation = newMatrix.quaternion
end
callable(SmartJump, "alignToJump")

end -- onServer
