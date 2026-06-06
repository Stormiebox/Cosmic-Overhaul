package.path = package.path .. ";data/scripts/lib/?.lua"

local co_old_sector_init = initialize
function initialize(...)
    if co_old_sector_init then co_old_sector_init(...) end

    if onServer() then
        local sector = Sector()
        sector:addScriptOnce("data/scripts/sector/managestationincomes.lua")
    end
end
