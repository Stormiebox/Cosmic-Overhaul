local co_old_init = initialize

function initialize(...)
    if co_old_init then co_old_init(...) end

    if onServer() then
        local player = Player()

        -- Add scripts to the player
        -- Cosmic Overhaul: Updated Fleet Status runs as an entity script (data/scripts/entity/fleetstatus.lua)
        player:addScriptOnce("data/scripts/player/ui/factory_overview_tab.lua")
        player:addScriptOnce("data/scripts/player/ui/playerbulletinboard.lua")
        -- Attach the new UI tab script to the player
        player:addScriptOnce("data/scripts/player/ui/command_center_tab.lua")
        -- Cosmic Overhaul: Updated Resource Display UI
        player:addScriptOnce("data/scripts/player/ui/resourcedisplay.lua")
        -- Cosmic Overhaul: Dynamic Reputation Decay Background Loop
        player:addScriptOnce("data/scripts/lib/DynamicReputationDecay.lua")
        -- Cosmic Overhaul: Updated Galaxy Map QoL
        player:addScriptOnce("data/scripts/player/map/galaxymapqol.lua")
    end
end
