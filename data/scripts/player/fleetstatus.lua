-- namespace FleetStatus
-- Deprecated player-side shim.
-- Fleet Ship Status now runs fully in:
--   data/scripts/entity/fleetstatus.lua
--
-- This file intentionally remains as a compatibility no-op so that
-- stale script references or legacy invokeFunction calls do not crash.

FleetStatus = FleetStatus or {}

local _deprecatedWarned = false
local function warnDeprecatedOnce(endpoint)
    if _deprecatedWarned then return end
    _deprecatedWarned = true
    print(string.format(
    "[Cosmic Overhaul][FleetStatus][DeprecatedPlayerShim] Called '%s' on player shim. Ignoring and using entity-owned FleetStatus flow.",
        tostring(endpoint)))
end

function FleetStatus.initialize()
    -- no-op (entity script owns initialization)
end

function FleetStatus.showWindow()
    -- no-op (entity script owns window/context)
end

-- Legacy compatibility receivers (no-op by design).
-- These absorb stale invokes from old saves/callers and prevent nil-call stack traces.
function FleetStatus.receiveShipSnapshot(...)
    warnDeprecatedOnce("receiveShipSnapshot")
end

function FleetStatus.receiveFleetSnapshot(...)
    warnDeprecatedOnce("receiveFleetSnapshot")
end

function FleetStatus.updateStatus(...)
    warnDeprecatedOnce("updateStatus")
end

function FleetStatus.updateHud(...)
    warnDeprecatedOnce("updateHud")
end

function FleetStatus.syncConfig(...)
    warnDeprecatedOnce("syncConfig")
end

-- legacy global bridge
function initialize()
    FleetStatus.initialize()
end

function showWindow()
    FleetStatus.showWindow()
end

function receiveShipSnapshot(...)
    FleetStatus.receiveShipSnapshot(...)
end

function receiveFleetSnapshot(...)
    FleetStatus.receiveFleetSnapshot(...)
end

function updateStatus(...)
    FleetStatus.updateStatus(...)
end

function updateHud(...)
    FleetStatus.updateHud(...)
end

function syncConfig(...)
    FleetStatus.syncConfig(...)
end

return FleetStatus
