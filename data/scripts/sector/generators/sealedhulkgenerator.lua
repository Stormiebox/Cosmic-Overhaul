package.path = package.path .. ";data/scripts/lib/?.lua"
local PlanGenerator = include("plangenerator")
local SectorGenerator = include("SectorGenerator")

local SealedHulkGenerator = {}

function SealedHulkGenerator.generate(x, y)
    local generator = SectorGenerator(x, y)
    
    local faction = Galaxy():getPirateFaction(0)
    local plan = PlanGenerator.makeFreighterPlan(faction)
    plan:scale(vec3(5.0, 5.0, 5.0)) -- Massive scaling!
    
    local position = generator:getPositionInSector(15000)
    local hulk = Sector():createWreckage(plan, position)
    
    hulk.title = "Sealed Hulk"%_t
    hulk:addScript("data/scripts/entity/sealedhulkboarding.lua")
    
    -- Give it a unique icon on the map if the player finds it
    hulk:setValue("is_sealed_hulk", true)
    
    return hulk
end
