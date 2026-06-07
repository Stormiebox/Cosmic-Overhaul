package.path = package.path .. ";data/scripts/lib/?.lua"

if onServer() then
    local sector = Sector()
    if sector then
        sector:addScriptOnce("data/scripts/sector/managestationincomes.lua")
    end
end
