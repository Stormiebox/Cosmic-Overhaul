local UniversalSR_Shipyard = Shipyard.initialize
function Shipyard.initialize()
    UniversalSR_Shipyard()

    Entity():setValue("remove_permanent_upgrades", true)
end


function initialize(...)
    if Shipyard.initialize then return Shipyard.initialize(...) end
end
