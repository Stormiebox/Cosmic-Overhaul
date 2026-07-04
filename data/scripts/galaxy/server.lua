
local CosmicOverhaul_old_init = initialize

function initialize(...)
    if CosmicOverhaul_old_init then CosmicOverhaul_old_init(...) end
    include("cosmicvaultdebug").info("Cosmic Overhaul", "[CosmicOverhaul] server.lua initialized! Attaching co_weather_generator.lua")
    Galaxy():addScriptOnce("galaxy/co_weather_generator.lua")
end
