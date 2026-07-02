local UniversalSR_RepairDock = RepairDock.initialize
function RepairDock.initialize()
    if UniversalSR_RepairDock then UniversalSR_RepairDock() end

    Entity():setValue("remove_permanent_upgrades", true)

    if onServer() then
        Entity():addScriptOnce("data/scripts/entity/merchants/repairfleet.lua")
    end
end

function initialize(...)
    if RepairDock.initialize then return RepairDock.initialize(...) end
end


function RepairDock.repairAllSectorShips(playerIndex, creditsOnly) -- Explicitly receive playerIndex
    playerIndex = playerIndex or callingPlayer -- Fallback for other potential call sites
    if not playerIndex then return end
    if not CheckFactionInteraction(playerIndex, RepairDock.interactionThreshold) then return end

    local player = Player(playerIndex)
    local alliance = player.allianceIndex and Alliance(player.allianceIndex) or nil
    local station = Entity()
    local sector = Sector()

    -- Helper to calculate cost for a set of ships and a specific payer
    local function calculateFleetCost(ships, payer)
        local totalMoney = 0
        local totalTax = 0
        local totalResources = {0, 0, 0, 0, 0, 0, 0}
        local validShips = {}
        local damagedFound = false

        for _, ship in pairs(ships) do
            local owner = Faction(ship.factionIndex)
            if owner then
                local perfectPlan = owner:getShipPlan(ship.name)
                local damagedPlan = ship:getFullPlanCopy()
                if perfectPlan and damagedPlan then
                    local money, tax = 0, 0
                    local resources = {0, 0, 0, 0, 0, 0, 0}

                    if creditsOnly then
                        money, tax = RepairDock.getRepairMoneyCostAndTaxCreditsOnly(player, payer, ship, perfectPlan, damagedPlan, ship.durability / ship.maxDurability)
                    else
                        money, tax = RepairDock.getRepairMoneyCostAndTax(player, payer, ship, perfectPlan, damagedPlan, ship.durability / ship.maxDurability)
                        resources = RepairDock.getRepairResourcesCost(player, payer, ship, perfectPlan, damagedPlan, ship.durability / ship.maxDurability)
                    end

                    if money > 0 or tax > 0 or (resources[1] or 0) > 0 or (resources[2] or 0) > 0 or (resources[3] or 0) > 0 or (resources[4] or 0) > 0 or (resources[5] or 0) > 0 or (resources[6] or 0) > 0 or (resources[7] or 0) > 0 then
                        damagedFound = true
                        totalMoney = totalMoney + money
                        totalTax = totalTax + tax
                        for i = 1, 7 do totalResources[i] = totalResources[i] + (resources[i] or 0) end
                        table.insert(validShips, {ship = ship, perfectPlan = perfectPlan, owner = owner})
                    end
                end
            end
        end
        return totalMoney, totalTax, totalResources, validShips, damagedFound
    end

    -- Helper to execute the mass repair
    local function doRepair(shipsData, payer, totalMoney, totalTax, totalResources)
        receiveTransactionTax(station, totalTax)
        payer:pay(totalMoney, unpack(totalResources))

        for _, data in pairs(shipsData) do
            local ship = data.ship
            local perfectPlan = data.perfectPlan
            local owner = data.owner

            perfectPlan:resetDurability()
            ship:setMalusFactor(1.0, MalusReason.None)
            ship:setMovePlan(perfectPlan)
            ship.durability = ship.maxDurability

            local turretBases = TurretBases(ship)
            if turretBases then
                local turretDesigns = owner:getShipTurretDesigns(ship.name)
                turretBases:setDesigns(turretDesigns)
            end
            owner:restoreTurrets(ship)
        end
    end

    -- Gather Player Ships
    local playerShips = {}
    for _, entity in pairs({sector:getEntitiesByFaction(player.index)}) do
        if entity.isShip or entity.isDrone then
            table.insert(playerShips, entity)
        end
    end

    -- Gather Alliance Ships
    local allianceShips = {}
    if alliance then
        for _, entity in pairs({sector:getEntitiesByFaction(alliance.index)}) do
            if entity.isShip or entity.isDrone then
                table.insert(allianceShips, entity)
            end
        end
    end

    -- Combine for Alliance attempt
    local allShips = {}
    for _, s in pairs(playerShips) do table.insert(allShips, s) end
    for _, s in pairs(allianceShips) do table.insert(allShips, s) end

    if #allShips == 0 then
        player:sendChatMessage(station, 1, "No ships found to repair."%_t)
        return
    end

    local attemptedAlliance = false
    -- 1. Try Alliance First (Pays for EVERYTHING)
    if alliance and alliance:hasPrivilege(player.index, AlliancePrivilege.SpendResources) then
        attemptedAlliance = true
        local totalMoney, totalTax, totalResources, validShips, damagedFound = calculateFleetCost(allShips, alliance)

        if not damagedFound then
            player:sendChatMessage(station, 0, "Fleet is already fully repaired."%_t)
            return
        end

        if #validShips > 0 then
            local canPay, msg, args = alliance:canPay(totalMoney, unpack(totalResources))
            if canPay then
                doRepair(validShips, alliance, totalMoney, totalTax, totalResources)
                player:sendChatMessage(station, 0, "Entire fleet repaired using Alliance funds."%_t)
                return
            end
        end
    end

    -- 2. Fallback to Player (Can ONLY pay for Player ships)
    local totalMoney, totalTax, totalResources, validPlayerShips, damagedFound = calculateFleetCost(playerShips, player)

    if not damagedFound then
        if attemptedAlliance and #allianceShips > 0 then
            -- This means alliance ships were damaged but alliance couldn't pay, and player ships are full HP.
            player:sendChatMessage(station, 1, "Alliance lacks funds for fleet repair, and your private ships are already fully repaired."%_t)
        else
            player:sendChatMessage(station, 0, "Fleet is already fully repaired."%_t)
        end
        return
    end

    local canPay, msg, args = player:canPay(totalMoney, unpack(totalResources))
    if canPay then
        doRepair(validPlayerShips, player, totalMoney, totalTax, totalResources)
        if attemptedAlliance and #allianceShips > 0 then
            -- We must check if any alliance ships were actually damaged to give an accurate message.
            -- Instead of recalculating, we just state private ships were repaired.
            player:sendChatMessage(station, 2, "Repaired private ships. Alliance lacked funds for alliance ships."%_t)
        else
            player:sendChatMessage(station, 0, "Fleet repaired successfully."%_t)
        end
        return
    end

    -- Neither can pay
    player:sendChatMessage(station, 1, "Not enough funds to repair the fleet."%_t)
end
callable(RepairDock, "repairAllSectorShips")
