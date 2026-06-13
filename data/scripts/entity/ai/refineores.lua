if onServer() then

function getUpdateInterval()
    return 5.0
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