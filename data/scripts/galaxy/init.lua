include("data/scripts/galaxy/init.lua")

if onServer() then
    Galaxy():addScriptOnce("data/scripts/galaxy/factoryregister.lua")
    Galaxy():addScriptOnce("data/scripts/galaxy/galaxymapqol.lua")
end
