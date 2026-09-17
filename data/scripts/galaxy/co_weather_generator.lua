package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

local cv_weather = include("cosmicvaultweather")
local co_news = include("co_news")

local COWeatherGenerator = {}
COWeatherGenerator.cooldown = 0

function COWeatherGenerator.initialize()
    if not cv_weather then
        include("cosmicvaultdebug").info("Cosmic Overhaul", "[Cosmic Overhaul] CosmicVaultWeather API not found! Weather generation disabled.")
    end
end

function COWeatherGenerator.getUpdateInterval()
    return 60.0 -- Check every minute
end

function COWeatherGenerator.updateServer(timeStep)
    if not cv_weather then return end

    COWeatherGenerator.cooldown = math.max(0, COWeatherGenerator.cooldown - timeStep)
    if COWeatherGenerator.cooldown > 0 then return end

    -- Count only this generator's canonical conditions. Permanent conditions
    -- owned by Ascendancy or War must not consume Overhaul's five-event budget.
    local snapshot = cv_weather.GetWeatherSnapshot()
    local count = 0
    if snapshot and type(snapshot.conditions) == "table" then
        for _, condition in pairs(snapshot.conditions) do
            if type(condition.sourceId) == "string"
                    and string.find(condition.sourceId,
                        "cosmic-overhaul:random-weather:", 1, true) == 1 then
                count = count + 1
            end
        end
    end

    -- Hard cap at 5 concurrent events galaxy-wide -- no guaranteed minimum. With thousands of
    -- sectors and a dedicated server's players spread across many of them, the 1% per-check roll
    -- below is intentionally rare so this never feels like it's spamming the galaxy.
    if count >= 5 then return end

    -- 1% chance to trigger a new weather event
    if random():getFloat() < 0.01 then
        COWeatherGenerator.spawnRandomWeather()
        COWeatherGenerator.cooldown = random():getInt(14400, 28800) -- 4 to 8 hour cooldown before next roll
    end
end

function COWeatherGenerator.spawnRandomWeather()
    local players = {Server():getOnlinePlayers()}
    if #players == 0 then return end

    local player = players[random():getInt(1, #players)]
    local knownSectors = {player:getKnownSectors()}
    if #knownSectors == 0 then return end

    local targetSector = knownSectors[random():getInt(1, #knownSectors)]
    local tx, ty = targetSector:getCoordinates()

    -- Pick weather type
    local types = {"IonStorm", "SolarFlare"}
    local stormType = types[random():getInt(1, #types)]

    -- 4 to 6 hours duration
    local duration = random():getInt(14400, 21600)

    local record, errorCode = cv_weather.StartWeather({
        sourceId = "cosmic-overhaul:random-weather:" .. tostring(tx) .. ":" .. tostring(ty),
        weatherType = stormType,
        x = tx,
        y = ty,
        duration = duration,
        conflictPolicy = "reject"
    })
    if not record then
        include("cosmicvaultdebug").info("Cosmic Overhaul",
            "[Cosmic Overhaul] Weather request rejected at %s:%s: %s",
            tostring(tx), tostring(ty), tostring(errorCode))
        return nil, errorCode
    end

    local newsType = ""
    local content = ""
    local severity = "warning"

    if stormType == "IonStorm" then
        newsType = "Category 5 Ion Storm"
        content = "A massive Ion Storm has erupted at coordinates [" .. tx .. ":" .. ty .. "]. All vessels in the area are warned: Hyperspace and Radar systems will be completely disabled. Travel is highly advised against."
    else
        newsType = "Class-X Solar Flare"
        content = "A dangerous Solar Flare is currently bathing coordinates [" .. tx .. ":" .. ty .. "] in intense radiation. Unshielded vessels will be rapidly destroyed. Evacuate immediately."
        severity = "critical"
    end

    -- The weather record is already durable at this point. News is a projection of that
    -- verified condition and a publication failure must never undo the mechanical event.
    co_news.Upsert({
        kind = "weather",
        eventId = record.conditionId,
        threadId = record.conditionId,
        eventType = "overhaul.weather.active",
        topic = "weather",
        severity = severity,
        breaking = severity == "critical",
        location = {x = tx, y = ty, radius = 0},
        expiresAt = record.expiresAt ~= -1 and record.expiresAt or nil,
        sourceRevision = record.revision or 1,
        sourceState = record.state or "active",
        provenance = {
            recordType = "vault_weather_condition",
            conditionId = tostring(record.conditionId),
            weatherType = tostring(record.weatherType or stormType),
            sourceRevision = record.revision or 1,
            sourceState = tostring(record.state or "active"),
        },
        article = {
            title = "Hazard Warning: " .. newsType,
            content = content,
            category = "Galactic Dread",
        },
    })
    return record, nil
end

function COWeatherGenerator.secure()
    return {
        cooldown = COWeatherGenerator.cooldown
    }
end

function COWeatherGenerator.restore(data)
    if type(data) == "table" then
        COWeatherGenerator.cooldown = data.cooldown or 0
    end
end

function initialize(...)
    if COWeatherGenerator.initialize then return COWeatherGenerator.initialize(...) end
end
function getUpdateInterval(...)
    if COWeatherGenerator.getUpdateInterval then return COWeatherGenerator.getUpdateInterval(...) end
end
function updateServer(...)
    if COWeatherGenerator.updateServer then return COWeatherGenerator.updateServer(...) end
end
function secure(...)
    if COWeatherGenerator.secure then return COWeatherGenerator.secure(...) end
end
function restore(...)
    if COWeatherGenerator.restore then return COWeatherGenerator.restore(...) end
end
