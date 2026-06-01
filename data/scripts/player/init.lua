package.path = package.path .. ";data/scripts/lib/?.lua"

if onServer() then
    local player = Player()

    -- Add scripts to the player
    -- Fleet Status runs as an entity script (data/scripts/entity/fleetstatus.lua)
    player:addScriptOnce("data/scripts/player/ui/factory_overview_tab.lua")
    player:addScriptOnce("data/scripts/player/ui/playerbulletinboard.lua")
    -- Attach the new UI tab script to the player
    player:addScriptOnce("data/scripts/player/ui/command_center_tab.lua")
    -- Resource Display UI
    player:addScriptOnce("data/scripts/player/ui/resourcedisplay.lua")
    -- Cosmic Overhaul: Dynamic Reputation Decay Background Loop
    player:addScriptOnce("data/scripts/lib/DynamicReputationDecay.lua")
end
