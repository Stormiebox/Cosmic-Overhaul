package.path = package.path .. ";data/scripts/lib/?.lua"
include ("faction")
include ("utility")
include("data/scripts/lib/callable")
-- The actual repair-cost/tax math lives entirely in repairdock.lua, attached to the same station
-- entity by RepairDock.initialize(). This script only builds the dialog/UI and proxies the server
-- call via invokeFunction, so that calculation never has to be duplicated here.

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
    Entity():invokeFunction("data/scripts/entity/merchants/repairdock.lua", "repairAllSectorShips", callingPlayer, creditsOnly)
end
callable(nil, "triggerFleetRepair")
