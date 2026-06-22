package.path = package.path .. ";data/scripts/lib/?.lua"
include ("faction")
include ("utility")
include ("callable")
local Dialog = include("dialogutility")
local RepairDock = include("merchantutility") -- Not strictly merchantutility but we'll use include("repairdock") if needed, wait. RepairDock is technically `data/scripts/entity/merchants/repairdock.lua`. But we can just duplicate the getRepairMoneyCost logic, or `invokeFunction` on the script.
-- Stormbox: Important Notes Below!
-- To avoid duplicating the RepairDock's complex tax/cost calculations, we can simply invoke them if they are exposed,
-- but RepairDock doesn't expose them globally in a way we can easily include without loading the entity script.
-- Wait, actually we can call `Entity():invokeFunction("repairdock.lua", "getRepairMoneyCostAndTaxCreditsOnly", ...)`!
-- But since it's a server function, we can just let `repairfleet.lua` handle the UI and invoke the actual server function that we leave inside `repairdock.lua`!
-- That is brilliant! I don't need to move the server logic!

function interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, -30000)
end

function initUI()
    ScriptUI():registerInteraction("Repair Fleet"%_t, "onInteract")
end

function onInteract()
    local dialog = {}
    dialog.text = "We can deploy repair crews to patch up every ship you or your alliance currently has deployed in this sector.\n\nHow would you like to cover the costs?"%_t
    dialog.answers = {
        {answer = "Credits and Materials"%_t, onSelect = "repairCreditsAndMaterials"},
        {answer = "Credits Only (Costs more)"%_t, onSelect = "repairCreditsOnly"},
        {answer = "Nevermind."%_t}
    }
    ScriptUI():showDialog(dialog)
end

function repairCreditsAndMaterials()
    invokeServerFunction("triggerFleetRepair", false)
end

function repairCreditsOnly()
    invokeServerFunction("triggerFleetRepair", true)
end

function triggerFleetRepair(creditsOnly)
    -- Simply proxy the call directly to the RepairDock script on this station
    Entity():invokeFunction("data/scripts/entity/merchants/repairdock.lua", "repairAllSectorShips", creditsOnly)
end
callable(nil, "triggerFleetRepair")
