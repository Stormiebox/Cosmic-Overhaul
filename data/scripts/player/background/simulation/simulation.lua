if onServer() then

--[[
Balancing:
    - Replay ratio controls how much command time a given amount of real-world time can receive,
        e.g. a ratio of 0.667 advances commands about 2 hours after being gone 3 hours.
    - Max replay time caps the amount of time that commands are allowed to advance.
]]
local ARCC_offlineTimeReplayRatio = 0.667
local ARCC_maxOfflineReplayTime = 8 * 60 * 60

-- Do the first update faster to not wait a full minute before seeing something happen
local ARCC_Simulation_getUpdateInterval_original = Simulation.getUpdateInterval
function Simulation.getUpdateInterval()
    if not ARCC_hasRunFirstUpdate then return 30 end
    return ARCC_Simulation_getUpdateInterval_original()
end

-- Combined Simulation.update logic
local ARCC_Simulation_update_original = Simulation.update
function Simulation.update(timestep)
    ARCC_Simulation_update_original(timestep)

    if not ARCC_hasRunFirstUpdate then
        ARCC_hasRunFirstUpdate = true
        local timeToApply = ARCC_getTimeToApply(timestep)
        ARCC_applyCatchUpTime(timeToApply)
    end
end

-- Combined Simulation.secure logic
local ARCC_Simulation_secure_original = Simulation.secure
function Simulation.secure()
    if self.commands and #self.commands > 0 then
        local secureTime = os.time() - 1
        print("[ARCC] Securing commands with a timestamp of: ${timestamp}" % {
            timestamp = os.date("!%c (UTC)", secureTime),
        })
        for _, command in pairs(self.commands or {}) do
            command.data.lastSecuredClockTime = secureTime
        end
    end
    return ARCC_Simulation_secure_original()
end

-- ARCC and MCM logic for makeCommand
local mcm_Simulation_makeCommand_original = Simulation.makeCommand
function Simulation.makeCommand(...)
    local command = mcm_Simulation_makeCommand_original(...)

    -- Hook new, generalized logic for immediate delivery into addYield
    -- Also include new generalized reputation gain logic
    local originalAddYield = command.addYield
    command.addYield = function(self, message, money, resources, items)
        Simulation.tryChangeRelationsForMoney(self, money)

        local immediate = self.config.immediateDelivery
            or (self.config.mcm and self.config.mcm.immediateDelivery)
        local recalled = self.data and self.data.mcm and self.data.mcm.recalled

        if immediate and not recalled then
            local parent = getParentFaction()
            money = math.max(0, money or 0)
            resources = resources or {}
            parent:receive(message, money, unpack(resources))
            if items then
                originalAddYield(self, "", 0, {}, items)
                self.simulation.takeYield(self.shipName)
            end
        else
            originalAddYield(self, message, money, resources, items)
        end
    end

    return command
end

-- Handles changing relations based on money yield
function Simulation.tryChangeRelationsForMoney(command, money)
    if not command
        or not command.data
        or not command.data.prediction
        or not command.data.prediction.mcm
        or not command.data.prediction.mcm.moneyToRelationEntries
    then
        return
    end

    for _, changeEntry in pairs(command.data.prediction.mcm.moneyToRelationEntries) do
        local moneyAmount = money or 0
        if changeEntry.moneyAmount then
            if changeEntry.moneyAmount.min and changeEntry.moneyAmount.max then
                moneyAmount = random():getInt(changeEntry.moneyAmount.min, changeEntry.moneyAmount.max)
            else
                moneyAmount = changeEntry.moneyAmount
            end
        end

        local ratio = changeEntry.ratio or 1
        local relationChange = ratio * GetRelationChangeFromMoney(moneyAmount)

        changeRelations(
            getParentFaction(),
            changeEntry.faction,
            relationChange,
            changeEntry.relationType
        )
    end
end

-- Retrieves the smallest timestep among all current commands
function ARCC_getSmallestTimestep()
    local timestep = 60 * 60
    for _, command in pairs(self.commands or {}) do
        if command.data.yieldTime then
            timestep = math.min(timestep, command.data.yieldTime)
        elseif command.data.regularYieldsTime then
            timestep = math.min(timestep, command.data.regularYieldsTime)
        elseif command.data.prediction and command.data.prediction.flightTime then
            timestep = math.min(timestep, command.data.prediction.flightTime.value)
        elseif command.data.currentFlight and command.data.currentFlight.time
            and command.data.currentFlight.index
            and command.data.flights and command.data.flights[command.data.currentFlight.index]
            and command.data.flights[command.data.currentFlight.index].minutes
        then
            local currentSupplyFlight = command.data.currentFlight
            local supplyFlightInfo = command.data.flights[currentSupplyFlight.index]
            local timeLeftInFlight = supplyFlightInfo.minutes * 60 - currentSupplyFlight.time
            timestep = math.min(timestep, timeLeftInFlight)
        end
    end
    return timestep
end

function ARCC_getTimeToApply(rawTimeToDeduct)
    local restoreTime = os.time()

    -- Assumption: all commands were secured at about the same time
    local secureTime = restoreTime
    for _, command in pairs(self.commands or {}) do
        if command.data and command.data.lastSecuredClockTime then
            secureTime = math.min(secureTime, command.data.lastSecuredClockTime)
            command.data.lastSecuredClockTime = nil
        end
    end

    print("[ARCC] Restoring commands from a timestamp of: ${timestamp}" % {
        timestamp = os.date("!%c (UTC)", secureTime),
    })

    local timeToApply = math.max(0, restoreTime - secureTime - (rawTimeToDeduct or 0))

    -- Apply balancing factors
    timeToApply = timeToApply * ARCC_offlineTimeReplayRatio
    timeToApply = math.min(timeToApply, ARCC_maxOfflineReplayTime)

    return timeToApply
end

function ARCC_applyCatchUpTime(timeToApply)
    if timeToApply <= 0 or not self.commands or #self.commands == 0 then return end

    while (#self.commands > 0 and timeToApply > 0) do
        local nextStep = ARCC_getSmallestTimestep()
        nextStep = math.min(nextStep, timeToApply)
        print("[ARCC] Simulating catch-up of ${time} for ${num} active commands" % {
            time = createReadableShortTimeString(nextStep),
            num = #self.commands,
        })
        Simulation.update(nextStep)
        timeToApply = timeToApply - nextStep
    end

    local player = Player(callingPlayer)
    if player then
        player:sendChatMessage("", 3, "Your captains continued working while you were away."%_t)
    end
end

end -- if onServer()
