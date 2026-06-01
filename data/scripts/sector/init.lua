package.path = package.path .. ";data/scripts/lib/?.lua"

if onServer() then
    local sector = Sector()
    sector:addScriptOnce("data/scripts/sector/managestationincomes.lua")
end
