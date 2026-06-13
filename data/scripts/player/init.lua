if onServer() then
    local player = Player()

    -- Add scripts to the player
    player:addScriptOnce("data/scripts/player/ui/factory_overview_tab.lua")
    player:addScriptOnce("data/scripts/player/ui/playerbulletinboard.lua")
    player:addScriptOnce("data/scripts/player/ui/command_center_tab.lua")
    player:addScriptOnce("data/scripts/player/ui/resourcedisplay.lua")
    player:addScriptOnce("data/scripts/lib/DynamicReputationDecay.lua")
    player:addScriptOnce("data/scripts/player/map/galaxymapqol.lua")
    player:addScriptOnce("data/scripts/player/cosmicoverhaulcodex.lua")
end
