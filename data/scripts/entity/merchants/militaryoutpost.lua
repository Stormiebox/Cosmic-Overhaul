local UniversalSR_MilitaryOutpost = MilitaryOutpost.initialize
function MilitaryOutpost.initialize()
    UniversalSR_MilitaryOutpost()

    Entity():setValue("remove_permanent_upgrades", true)
end


function initialize(...)
    if MilitaryOutpost.initialize then return MilitaryOutpost.initialize(...) end
end
