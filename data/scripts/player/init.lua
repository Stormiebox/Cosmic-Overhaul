if onServer() then
    local player = Player()

    -- Add scripts to the player
    player:addScriptOnce("data/scripts/player/ui/shipinfo.lua")
    player:addScriptOnce("data/scripts/player/ui/factory_overview_tab.lua")
    player:addScriptOnce("ui/playerbulletinboard.lua")
end
