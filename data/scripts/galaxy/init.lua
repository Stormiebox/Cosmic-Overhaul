local co_old_galaxy_init = initialize
function initialize(...)
    if co_old_galaxy_init then co_old_galaxy_init(...) end

    if onServer() then
        local galaxy = Galaxy()
        if galaxy then
            galaxy:addScriptOnce("data/scripts/galaxy/factoryregister.lua")
            galaxy:addScriptOnce("data/scripts/galaxy/galaxymapqol.lua")
        end
    end
end
