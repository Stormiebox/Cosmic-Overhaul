package.path = package.path .. ";data/scripts/lib/?.lua"
include("stringutility")
include("callable")

-- Script for interacting with a Sealed Hulk
-- State 0 = Initial approach
-- State 1 = Pushing deeper
-- State 2 = Final vault

local state = 0

function interactionPossible(playerIndex)
    local player = Player(playerIndex)
    local craft = player.craft
    if not craft then return false end

    -- Must be close to the hulk
    local dist = craft:getDistanceTo(Entity())
    if dist > 500 then return false end

    return true
end

function getInteractionText(playerIndex)
    return "Board Sealed Hulk"%_t
end

function initialize()
    if onServer() then
        Sector():registerCallback("onRestoredFromDisk", "onRestoredFromDisk")
    end
end

function onRestoredFromDisk()
    -- Maintain state
end

function initUI()
    ScriptUI():registerInteraction("Board Sealed Hulk"%_t, "onInteract")
end

function onInteract()
    ScriptUI():showDialog(makeDialog())
end

function makeDialog()
    local dialog = {}

    if state == 0 then
        dialog.text = "You attach boarding umbilicals to the massive, silent derelict. The airlock cycles with a heavy groan. Your boarding party reports the first deck is clear, but power is completely dead. They found a small cache of resources near the airlock, but the blast doors leading deeper into the ship are heavily sealed.\n\nRisk sending them deeper? You might lose crew."%_t
        dialog.answers = {
            {answer = "Take the surface scrap and extract."%_t, onSelect = "extractEarly"},
            {answer = "Blow the blast doors. Push deeper."%_t, onSelect = "pushDeeper"}
        }
    elseif state == 1 then
        dialog.text = "The blast doors give way. Suddenly, emergency lights flicker on! Automated defense turrets spin up and begin firing on your crew! Several crew members are pinned down in the crossfire.\n\nYour commander spots the entrance to the main cargo vault at the end of the hall. It's heavily fortified."%_t
        dialog.answers = {
            {answer = "Fall back immediately! Abandon the operation!"%_t, onSelect = "extractMid"},
            {answer = "Push through the crossfire! Breach the vault!"%_t, onSelect = "pushFinal"}
        }
    elseif state == 2 then
        dialog.text = "The vault is breached! Inside, your surviving crew discovers untouched, pristine shipping containers filled with immense wealth and lost technology.\n\nYour boarding party extracts safely with the haul."%_t
        dialog.answers = {
            {answer = "Excellent work."%_t, onSelect = "extractFinal"}
        }
    end

    return dialog
end

function extractEarly()
    if onClient() then invokeServerFunction("extractEarly") return end
    
    local player = Player(callingPlayer)
    player:receive("Extracted minor scrap", 50000)
    terminate()
end

function pushDeeper()
    if onClient() then invokeServerFunction("pushDeeper") return end
    
    local player = Player(callingPlayer)
    local ship = player.craft
    -- Risk losing 5 crew
    ship:removeCrew(5)
    player:sendChatMessage("", 1, "Your boarding party took casualties breaching the doors.")
    
    state = 1
    invokeClientFunction(player, "refreshDialog")
end

function extractMid()
    if onClient() then invokeServerFunction("extractMid") return end
    
    local player = Player(callingPlayer)
    player:receive("Extracted mid-tier salvage", 150000)
    terminate()
end

function pushFinal()
    if onClient() then invokeServerFunction("pushFinal") return end
    
    local player = Player(callingPlayer)
    local ship = player.craft
    -- Risk losing 15 crew
    ship:removeCrew(15)
    player:sendChatMessage("", 1, "Heavy casualties sustained breaching the final vault!")
    
    state = 2
    invokeClientFunction(player, "refreshDialog")
end

function extractFinal()
    if onClient() then invokeServerFunction("extractFinal") return end
    
    local player = Player(callingPlayer)
    player:receive("Extracted the Grand Vault!", 1000000)
    -- Also drop a legendary upgrade in the sector
    local upgrade = SystemUpgradeTemplate("data/scripts/systems/batterybooster.lua", Rarity(RarityType.Legendary), Seed(123))
    Sector():dropUpgrade(Entity().translationf, nil, nil, upgrade)
    
    terminate()
end

function refreshDialog()
    ScriptUI():showDialog(makeDialog())
end

-- Callable functions
callable(nil, "extractEarly")
callable(nil, "pushDeeper")
callable(nil, "extractMid")
callable(nil, "pushFinal")
callable(nil, "extractFinal")
