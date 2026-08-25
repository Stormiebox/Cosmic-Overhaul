package.path = package.path .. ";data/scripts/lib/?.lua"
include("utility")
include("randomext")

local SectorTurretGenerator = include("sectorturretgenerator")
local UpgradeGenerator = include("upgradegenerator")

-- namespace COBoardingLoot
COBoardingLoot = {}

function COBoardingLoot.initialize()
    if onServer() then
        Player():registerCallback("onSectorEntered", "onSectorEntered")
        local sector = Sector()
        if sector then
            sector:registerCallback("onBoardingSuccessful", "onBoardingSuccessful")
        end
    end
end

function COBoardingLoot.onSectorEntered()
    if onServer() then
        local sector = Sector()
        if sector then
            sector:registerCallback("onBoardingSuccessful", "onBoardingSuccessful")
        end
    end
end

function COBoardingLoot.onBoardingSuccessful(id, oldFactionIndex, newFactionIndex)
    if not onServer() then return end
    
    local player = Player()
    if newFactionIndex ~= player.index then return end
    
    local entity = Entity(id)
    if not entity then return end
    
    -- Dynamic Boarding Loot: 25% chance to generate high-value random subsystem or weapon
    if random():test(0.25) then
        local sector = Sector()
        local x, y = sector:getCoordinates()
        
        -- High value rarity (Exceptional or Exotic)
        local rarityType = RarityType.Exceptional
        if random():test(0.2) then rarityType = RarityType.Exotic end
        local rarity = Rarity(rarityType)
        
        if random():test(0.5) then
            -- Weapon
            local generator = SectorTurretGenerator()
            local turret = generator:generate(x, y, 0, rarity)
            player:getInventory():add(turret)
            player:sendChatMessage("Boarding Party", 0, "We secured a high-grade weapon cache from the armory!")
        else
            -- Subsystem
            local generator = UpgradeGenerator()
            local upgrade = generator:generateSectorSystem(x, y, rarity)
            player:getInventory():add(upgrade)
            player:sendChatMessage("Boarding Party", 0, "We successfully extracted a pristine subsystem from their databanks!")
        end
    end
end
