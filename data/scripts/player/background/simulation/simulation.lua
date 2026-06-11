if onServer() then
    -- Cosmic Overhaul: Ensure relations API is available for Trade/Charity mission yields
    include("relations")
    include("cosmicoverhaulconfig")

    --[[
Balancing:
    - Replay ratio controls how much command time a given amount of real-world time can receive,
        e.g. a ratio of 0.667 advances commands about 2 hours after being gone 3 hours.
    - Max replay time caps the amount of time that commands are allowed to advance.
]]
    local config = CosmicOverhaulConfig and CosmicOverhaulConfig.get and CosmicOverhaulConfig.get() or nil
    local ARCC_offlineTimeReplayRatio = config and config.offlineCatchupRatio or 0.667
    local ARCC_maxOfflineReplayTime = config and config.offlineCatchupMaxDuration or (8*60*60)
    local enableOfflineCatchup = config and config.enableOfflineCatchup or false

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
        if Simulation.commands and #Simulation.commands > 0 then
            local secureTime = os.time()-1
            print("[ARCC] Securing commands with a timestamp of: ${timestamp}"%{
                timestamp = os.date("!%c (UTC)", secureTime),
            })
            for _, command in pairs(Simulation.commands or {}) do
                command.data.lastSecuredClockTime = secureTime
            end
        end
        return ARCC_Simulation_secure_original()
    end

    -- ARCC and ccm logic for makeCommand
    local ccm_Simulation_makeCommand_original = Simulation.makeCommand
    function Simulation.makeCommand(...)
        local command = ccm_Simulation_makeCommand_original(...)

        -- Hook new, generalized logic for immediate delivery into addYield
        -- Also include new generalized reputation gain logic
        local originalAddYield = command.addYield
        command.addYield = function(self, message, money, resources, items)
            Simulation.tryChangeRelationsForMoney(self, money)

            local immediate = self.config.immediateDelivery
                or (self.config.ccm and self.config.ccm.immediateDelivery)
            local recalled = self.data and self.data.ccm and self.data.ccm.recalled

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
            or not command.data.prediction.ccm
            or not command.data.prediction.ccm.moneyToRelationEntries
        then
            return
        end

        for _, changeEntry in pairs(command.data.prediction.ccm.moneyToRelationEntries) do
            local moneyAmount = money or 0
            if changeEntry.moneyAmount then
                if changeEntry.moneyAmount.min and changeEntry.moneyAmount.max then
                    moneyAmount = random():getInt(changeEntry.moneyAmount.min, changeEntry.moneyAmount.max)
                else
                    moneyAmount = changeEntry.moneyAmount
                end
            end

            local ratio = changeEntry.ratio or 1
            local relationChange = ratio*GetRelationChangeFromMoney(moneyAmount)

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
        local timestep = 60*60
        for _, command in pairs(Simulation.commands or {}) do
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
                local timeLeftInFlight = supplyFlightInfo.minutes*60-currentSupplyFlight.time
                timestep = math.min(timestep, timeLeftInFlight)
            end
        end
        return timestep
    end

    function ARCC_getTimeToApply(rawTimeToDeduct)
        local restoreTime = os.time()

        -- Assumption: all commands were secured at about the same time
        local secureTime = restoreTime
        for _, command in pairs(Simulation.commands or {}) do
            if command.data and command.data.lastSecuredClockTime then
                secureTime = math.min(secureTime, command.data.lastSecuredClockTime)
                command.data.lastSecuredClockTime = nil
            end
        end

        print("[ARCC] Restoring commands from a timestamp of: ${timestamp}"%{
            timestamp = os.date("!%c (UTC)", secureTime),
        })

        local timeToApply = 0
        if enableOfflineCatchup then
            timeToApply = math.max(0, restoreTime-secureTime-(rawTimeToDeduct or 0))

            -- Apply balancing factors
            timeToApply = timeToApply*ARCC_offlineTimeReplayRatio
            timeToApply = math.min(timeToApply, ARCC_maxOfflineReplayTime)
        else
            print("[ARCC] Offline catch-up is disabled via ccm. Skipping catch-up.")
        end

        return timeToApply
    end

    function ARCC_applyCatchUpTime(timeToApply)
        if timeToApply <= 0 or not Simulation.commands or #Simulation.commands == 0 then return end

        while (#Simulation.commands > 0 and timeToApply > 0) do
            local nextStep = ARCC_getSmallestTimestep()
            nextStep = math.min(nextStep, timeToApply)
            print("[ARCC] Simulating catch-up of ${time} for ${num} active commands"%{
                time = createReadableShortTimeString(nextStep),
                num = #Simulation.commands,
            })
            Simulation.update(nextStep)
            timeToApply = timeToApply-nextStep
        end

        -- Cosmic Overhaul: Safely handle both Player and Alliance contexts (callingPlayer is nil in update loops)
        local faction = getParentFaction()
        if faction then
            faction:sendChatMessage("", 3, "Your captains continued working while you were away."%_t)
        end
    end
end -- if onServer()
