package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

local cv_weather = include("cosmicvaultweather")
local cv_news = include("cosmicvaultnews")

local COWeatherGenerator = {}
COWeatherGenerator.timer = 0
COWeatherGenerator.cooldown = 0
COWeatherGenerator.activeCount = 0

function COWeatherGenerator.initialize()
    if not cv_weather then
        print("[Cosmic Overhaul] CosmicVaultWeather API not found! Weather generation disabled.")
    end
end

function COWeatherGenerator.getUpdateInterval()
    return 60.0 -- Check every minute
end

function COWeatherGenerator.updateServer(timeStep)
    if not cv_weather then return end

    COWeatherGenerator.cooldown = math.max(0, COWeatherGenerator.cooldown - timeStep)
    if COWeatherGenerator.cooldown > 0 then return end

    -- Sync active count
    local server = Server()
    local ok, activeWeathers = server:invokeFunction("server/cosmicvaultweather_server.lua", "secure")

    local count = 0
    if ok == 0 and activeWeathers and activeWeathers.activeWeathers then
        for k, v in pairs(activeWeathers.activeWeathers) do
            -- Only count random overhauls, ignore Eclipse specific ones if we wanted to
            count = count + 1
        end
    end
    COWeatherGenerator.activeCount = count

    -- Ensure min of 1, max of 5
    if count >= 5 then return end

    -- 15% chance to trigger a new weather event
    if random():getFloat() < 0.15 or count == 0 then
        COWeatherGenerator.spawnRandomWeather()
        COWeatherGenerator.cooldown = random():getInt(1800, 3600) -- 30 to 60 minute cooldown before next roll
    end
end

function COWeatherGenerator.spawnRandomWeather()
    local players = {Server():getPlayers()}
    if #players == 0 then return end

    local player = players[random():getInt(1, #players)]
    local knownSectors = {player:getKnownSectors()}
    if #knownSectors == 0 then return end

    local targetSector = knownSectors[random():getInt(1, #knownSectors)]
    local tx, ty = targetSector.x, targetSector.y

    -- Pick weather type
    local types = {"IonStorm", "SolarFlare"}
    local stormType = types[random():getInt(1, #types)]

    -- 4 to 6 hours duration
    local duration = random():getInt(14400, 21600)

    cv_weather.triggerStorm(tx, ty, stormType, duration)

    if cv_news.publishArticle then
        local newsType = ""
        local content = ""

        if stormType == "IonStorm" then
            newsType = "Category 5 Ion Storm"
            content = "A massive Ion Storm has erupted at coordinates [" .. tx .. ":" .. ty .. "]. All vessels in the area are warned: Hyperspace and Radar systems will be completely disabled. Travel is highly advised against."
        else
            newsType = "Class-X Solar Flare"
            content = "A dangerous Solar Flare is currently bathing coordinates [" .. tx .. ":" .. ty .. "] in intense radiation. Unshielded vessels will be rapidly destroyed. Evacuate immediately."
        end

        cv_news.publishArticle({
            title = "Hazard Warning: " .. newsType,
            content = content,
            category = "Galactic Dread"
        })
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
