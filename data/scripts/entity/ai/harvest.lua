function AIHarvest:canContinueHarvesting()
    -- prevent terminating script before it even started
    if not self.harvestMaterial then return true end

    -- fully automated harvesting is only possible with captain or pilot
    -- We override this logic so old 1.0 background commands execute even without advanced 2.0 captains!
    return valid(self.harvestLoot) or valid(self.objectToHarvest) or not self.noTargetsLeft
end

function AIHarvest:finalize()
    -- Notify order chain to move to the next queued item
    Entity():invokeFunction("orderchain.lua", "orderCompleted")
    ShipAI():setPassive()
    terminate()
end