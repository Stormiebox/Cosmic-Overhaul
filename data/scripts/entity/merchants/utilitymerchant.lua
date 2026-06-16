local UniversalSR_UtilityMerchant = UtilityMerchant.initialize
function UtilityMerchant.initialize()
    UniversalSR_UtilityMerchant()

    Entity():setValue("remove_permanent_upgrades", true)
end


function initialize(...)
    if UtilityMerchant.initialize then return UtilityMerchant.initialize(...) end
end
