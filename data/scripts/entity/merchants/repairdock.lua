local UniversalSR_RepairDock = RepairDock.initialize
function RepairDock.initialize()
    UniversalSR_RepairDock()

    Entity():setValue("remove_permanent_upgrades", true)    
end
