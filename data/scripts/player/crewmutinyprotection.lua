package.path = package.path .. ";data/scripts/lib/?.lua"

-- namespace MutinyProtection
MutinyProtection = {}

function MutinyProtection.initialize()
    if onServer() then
        Player():registerCallback("onPreUpdate", "onPreUpdate")
    end
end

local updateTimer = 0
function MutinyProtection.onPreUpdate(timeStep)
    updateTimer = updateTimer + timeStep
    if updateTimer > 60 then
        updateTimer = 0
        MutinyProtection.checkWallets()
    end
end

function MutinyProtection.checkWallets()
    local player = Player()
    if not player.allianceIndex then return end
    
    local alliance = Alliance(player.allianceIndex)
    if not alliance then return end
    
    local totalWages = 0
    local shipNames = player:getShipNames()
    if not shipNames then return end
    
    for _, name in pairs(shipNames) do
        local amount = player:getShipPayment(name)
        if amount and amount > 0 then
            -- Only count ships whose payday is less than 5 minutes away
            local timeLeft = player:getShipPaymentTime(name) or 3600
            if timeLeft < 300 then
                totalWages = totalWages + amount
            end
        end
    end
    
    if totalWages > 0 and player.money < totalWages then
        local deficit = totalWages - player.money
        if alliance.money >= deficit then
            alliance:payWithoutNotify("", deficit)
            player:receive(deficit)
            player:sendChatMessage("Server", 2, "Your personal funds were critically low. " .. createMonetaryString(deficit) .. " Credits have been transferred from your Alliance to prevent crew mutiny.")
        end
    end
end
