-- namespace FleetStatus
-- Deprecated player-side shim.
-- Fleet Ship Status now runs fully in:
--   data/scripts/entity/fleetstatus.lua
--
-- This file intentionally remains as a compatibility no-op so that
-- stale script references or legacy invokeFunction calls do not crash.

FleetStatus = FleetStatus or {}

function FleetStatus.initialize()
    -- no-op (entity script owns initialization)
end

function FleetStatus.showWindow()
    -- no-op (entity script owns window/context)
end

-- legacy global bridge
function initialize()
    FleetStatus.initialize()
end

function showWindow()
    FleetStatus.showWindow()
end
