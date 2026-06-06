package.path = package.path .. ";data/scripts/lib/?.lua"

local Config = {
    ConsoleLogLevel = 2,
    FileLogLevel = 2,
    IconsPerPlayer = 75,
    IconsPerAlliance = 200,
    HazardZoneRequestInterval = 60
}

local Log = {
    Error = function(msg) print("[GalaxyMapQoL] [ERROR] " .. tostring(msg)) end,
    Warning = function(msg) if Config.ConsoleLogLevel >= 2 then print("[GalaxyMapQoL] [WARN] " .. tostring(msg)) end end,
    Info = function(msg) if Config.ConsoleLogLevel >= 3 then print("[GalaxyMapQoL] [INFO] " .. tostring(msg)) end end,
    Debug = function(msg) if Config.ConsoleLogLevel >= 4 then print("[GalaxyMapQoL] [DEBUG] " .. tostring(msg)) end end
}

local function getModDataFolder()
    if onServer() then return Server().folder .. "/moddata/GalaxyMapQoL/" end
    -- Fallback for client side, usually Avorion/client/moddata
    return "moddata/GalaxyMapQoL/"
end

local function saveConfig(name, data)
    local path = getModDataFolder() .. name .. ".json"
    createDirectory(getModDataFolder())
    local f = io.open(path, "w")
    if f then
        -- We write a simple serialization for our specific data
        local function serialize(v)
            if type(v) == "string" then return string.format("%q", v) end
            if type(v) == "number" or type(v) == "boolean" then return tostring(v) end
            if type(v) == "table" then
                local res = "{"
                local first = true
                for k, val in pairs(v) do
                    if not first then res = res .. "," end
                    if type(k) == "string" then res = res .. string.format("[%q]=", k) else res = res .. "[" .. tostring(k) .. "]=" end
                    res = res .. serialize(val)
                    first = false
                end
                return res .. "}"
            end
            return "nil"
        end
        f:write("return " .. serialize(data))
        f:close()
    end
end

local function loadConfig(name, defaultData)
    local path = getModDataFolder() .. name .. ".json"
    local f = io.open(path, "r")
    if f then
        local content = f:read("*a")
        f:close()
        local func = loadstring(content)
        if func then
            local success, data = pcall(func)
            if success and type(data) == "table" then
                for k, v in pairs(defaultData or {}) do
                    if data[k] == nil then data[k] = v end
                end
                return data, false
            end
        end
    end
    return defaultData, true
end

local Azimuth = {
    loadConfig = function(name, defaultData) return loadConfig(name, defaultData) end,
    saveConfig = function(name, data) saveConfig(name, data) end
}

return {Azimuth, Config, Log}
