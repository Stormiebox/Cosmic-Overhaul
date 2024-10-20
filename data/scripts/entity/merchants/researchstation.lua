local UniversalSR_ResearchStation = ResearchStation.initialize
function ResearchStation.initialize()
    UniversalSR_ResearchStation()

    Entity():setValue("remove_permanent_upgrades", true)
end
