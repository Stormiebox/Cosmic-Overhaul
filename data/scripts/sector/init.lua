package.path = package.path .. ";data/scripts/lib/?.lua"
local CO_ShipUtilityInjector = include("co_shiputility_injector")
if CO_ShipUtilityInjector then CO_ShipUtilityInjector.inject() end

if onServer() then
    local sector = Sector()
    sector:addScriptOnce("sector/managestationincomes.lua")
end
