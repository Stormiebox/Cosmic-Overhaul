
-- This makes the question of "will this sector spawn a beacon" reproducible and abstracts a few
-- properties for the Exodus beacons (chance, distance) into more mod-friendly variables.

local scf_operationExodusBeaconChance = 0.33
local scf_operationExodusBeaconMinDistance = 200
local scf_operationExodusBeaconMaxDistance = nil

-- The sectors that can spawn a beacon need to be repeated here because we need a way of
-- looking up that it'll spawn a beacon; it's otherwise just at the end via the tryCreate call.
local scf_operationExodusBeaconTemplates = {}
scf_operationExodusBeaconTemplates["sectors/asteroidfield"] = true
scf_operationExodusBeaconTemplates["sectors/defenderasteroidfield"] = true
scf_operationExodusBeaconTemplates["sectors/functionalwreckage"] = true
scf_operationExodusBeaconTemplates["sectors/pirateasteroidfield"] = true
scf_operationExodusBeaconTemplates["sectors/smallasteroidfield"] = true
scf_operationExodusBeaconTemplates["sectors/wreckageasteroidfield"] = true
scf_operationExodusBeaconTemplates["sectors/wreckagefield"] = true

function OperationExodus.sectorShouldHaveBeacon(x, y, template)
    local distance = length(vec2(x, y))
    if (scf_operationExodusBeaconMinDistance and distance < scf_operationExodusBeaconMinDistance)
        or (scf_operationExodusBeaconMaxDistance and distance > scf_operationExodusBeaconMaxDistance)
    then
        -- Not in the right range, can't create a beacon here
        return false
    end

    if template and not scf_operationExodusBeaconTemplates[template] then
        -- Inquiring about a specific template and it's not listed, no can do
        return false
    end

    local seed = SectorSeed(x, y)
    local sectorRandom = Random(seed)

    if not sectorRandom:test(scf_operationExodusBeaconChance) then
        -- Failed the random check, no beacon
        return false
    end

    -- Everything passed! This sector will have a beacon.
    return true
end

function OperationExodus.tryGenerateBeacon(generator)
    if OperationExodus.sectorShouldHaveBeacon(generator.coordX, generator.coordY) then
        OperationExodus.generateBeacon(generator)
    end
end
