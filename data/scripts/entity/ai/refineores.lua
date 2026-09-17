if onServer() then

    -- TPS throttle: a bare global getUpdateInterval() here is a namespace-shadowing bare global
    -- wrapper (see fleetstatus.lua's own note on this exact anti-pattern) -- the engine calls
    -- AIRefine.getUpdateInterval directly, so a same-named global never actually ran and this
    -- refinery AI kept ticking at vanilla's 1s interval instead of the intended 5s throttle.
    local base_getUpdateInterval = AIRefine.getUpdateInterval
    function AIRefine.getUpdateInterval()
        return math.max(base_getUpdateInterval and base_getUpdateInterval() or 0, 5.0)
    end

    -- Wrap updateServer in check to prevent waiting if refinery not found
    AIRefine._updateServer = AIRefine.updateServer
    function AIRefine.updateServer(timeStep)
        if noRefineryFoundTimer > 0 then
            AIRefine.finalize(true)
            return
        end
        AIRefine._updateServer(timeStep)
    end
end
