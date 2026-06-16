-- namespace Gate

Gate = Gate or {}

if onClient() then -- only do icon stuff on the clientside
    package.path = package.path .. ";data/scripts/?.lua"
    local SectorSpecifics = include("sectorspecifics")

    local vanillaGateInitialize = Gate.initialize
    function Gate.initialize(...)
        vanillaGateInitialize(...)

        local dirs = { -- from vanilla gate.lua
            { name = "E /*direction*/"%_t,   key = "E",   angle = math.pi * 2 * 0 / 16 },
            { name = "ENE /*direction*/"%_t, key = "ENE", angle = math.pi * 2 * 1 / 16 },
            { name = "NE /*direction*/"%_t,  key = "NE",  angle = math.pi * 2 * 2 / 16 },
            { name = "NNE /*direction*/"%_t, key = "NNE", angle = math.pi * 2 * 3 / 16 },
            { name = "N /*direction*/"%_t,   key = "N",   angle = math.pi * 2 * 4 / 16 },
            { name = "NNW /*direction*/"%_t, key = "NNW", angle = math.pi * 2 * 5 / 16 },
            { name = "NW /*direction*/"%_t,  key = "NW",  angle = math.pi * 2 * 6 / 16 },
            { name = "WNW /*direction*/"%_t, key = "WNW", angle = math.pi * 2 * 7 / 16 },
            { name = "W /*direction*/"%_t,   key = "W",   angle = math.pi * 2 * 8 / 16 },
            { name = "WSW /*direction*/"%_t, key = "WSW", angle = math.pi * 2 * 9 / 16 },
            { name = "SW /*direction*/"%_t,  key = "SW",  angle = math.pi * 2 * 10 / 16 },
            { name = "SSW /*direction*/"%_t, key = "SSW", angle = math.pi * 2 * 11 / 16 },
            { name = "S /*direction*/"%_t,   key = "S",   angle = math.pi * 2 * 12 / 16 },
            { name = "SSE /*direction*/"%_t, key = "SSE", angle = math.pi * 2 * 13 / 16 },
            { name = "SE /*direction*/"%_t,  key = "SE",  angle = math.pi * 2 * 14 / 16 },
            { name = "ESE /*direction*/"%_t, key = "ESE", angle = math.pi * 2 * 15 / 16 },
            { name = "E /*direction*/"%_t,   key = "E",   angle = math.pi * 2 * 16 / 16 }
        }

        local x, y = Sector():getCoordinates()
        local tx, ty = WormHole():getTargetCoordinates()

        local specs = SectorSpecifics(tx, ty, GameSeed())

        -- find "sky" direction to name the gate
        local ownAngle = math.atan2(ty - y, tx - x) + math.pi * 2
        if ownAngle > math.pi * 2 then ownAngle = ownAngle - math.pi * 2 end
        if ownAngle < 0 then ownAngle = ownAngle + math.pi * 2 end

        local dirString = ""
        local dirKey = ""
        local min = 3.0
        for _, dir in pairs(dirs) do
            local d = math.abs(ownAngle - dir.angle)
            if d < min then
                min = d
                dirString = dir.name
                dirKey = dir.key
            end
        end

        local entity = Entity()
        entity.title = "${dir} Gate to ${sector}"%_t % { dir = dirString, sector = specs.name }

        local iconPath = "data/textures/icons/pixel/cosmic_gatecompass/gate_Unknown.png"
        if dirKey ~= "" then
            iconPath = "data/textures/icons/pixel/cosmic_gatecompass/gate_Direction" .. dirKey .. ".png"
        end

        if onClient() then
            EntityIcon(entity.index).icon = iconPath
        end
    end
end


function initialize(...)
    if Gate.initialize then return Gate.initialize(...) end
end
