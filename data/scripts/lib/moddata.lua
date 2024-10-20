--[[
    This is a simple and horrendously "not secure" generic data loader.
    We rely on the VM to be the security boundary, which seems fair here,
    but it'll load things arbitrarily thanks to the load calls.

    Very convenient, though!

    Usage:

    local saveData = ReadModData(name_of_container.optional.paths.inside)
    -- saveData will read from the name_of_container file and attempt to traverse
    -- the supplied dotted path. If the path doesn't exist, it returns nil.
    -- or:
    local saveData = CreateModData(name_of_container.optional.paths.inside)
    -- saveData reads from the same file but creates all missing intermediate
    -- tables.

    saveData.newKey = newValue
    saveData.newTable = { yep = "tables work, too" }
    saveData:save()
    -- saveData serialized, future load calls will have the values
    -- the whole container is reserialized

    Instances will be cached to minimize file I/O but changes should still be
    flushed immediately to avoid cross-VM synchronization issues
]]

if not ModDataEntry then -- #pragma once

ModDataEntry = {}
ModDataEntry.__index = ModDataEntry

-- Platform/testing support
loadstring = loadstring or load

-- Global tables track top-level instances (nodes attached to actual file paths) and then associative
-- links of descendents back up to those roots -- if you have a table associated with .some.deep.data
-- originating from toplevelfile.moddata, you want the save to update that whole file appropriately.
local instances = {}
local rootLinks = {}

local function stringify(v)
    if type(v) == "number" or type(v) == "boolean" then return tostring(v)
    elseif type(v) == "string" then return '"' .. tostring(v) .. '"'
    else return type(v) end
end

local function recursiveWrite(file, item)
    if not item then return end
    file:write('{')
    for key, value in pairs(item) do
        file:write('[' .. stringify(key) .. ']=')
        if type(value) == "table" then
            recursiveWrite(file, value)
        else
            file:write(stringify(value))
        end
        file:write(',')
    end
    file:write('}')
end

local function readFromFile(filename)
    -- a+ because we're trying to overachieve here
    -- that and because it does read, write, and create all at once
	local file, err = io.open(filename, "a+")
	if err then print(err) return nil end
	local line = file:read()
    if not line then return {} end
    -- Note: this would normally be a security nightmare.
    --          ¯\_(ツ)_/¯
	local getData = loadstring('return ' .. line)
	file:close()
	return getData and getData()
end

local function GenericModData(dottedPath, createIfEmpty)
    local iterator = string.gmatch(dottedPath, "[^%.]+")
    if not iterator then return nil end
    local name = iterator()

    if not instances[name] then
        -- We haven't loaded this file yet; do that and add a new root instance node
        local instance = { path = 'moddata/' .. name .. '.moddata' }
        instance.data = readFromFile(instance.path)
        setmetatable(instance.data, ModDataEntry)
        instances[name] = instance
    end

    -- Traverse through the table hierarchy and either create missing levels or give up, depending
    -- on which mode we were asked to do
    local result = instances[name].data
    for i in iterator do
        if not result[i] then
            if createIfEmpty then result[i] = {}
            else return nil end
        end
        result = result[i]
    end

    -- Link the final child table to its parent for save association and attach metatable (save) to it
    rootLinks[result] = instances[name]
    return setmetatable(result, ModDataEntry)
end

-- Opens or creates the file corresponding to the first period-delimited token in the provided path (e.g.
-- 'test.moddata' for test.subTable.anotherTable) and then traverses or creates any intervening tables before
-- returning a table at the last specified level. Use this when you plan to save some new data to a section
-- of your moddata with known structure.
function CreateModData(dottedPath)
    return GenericModData(dottedPath, true)
end

-- Opens or creates the file corresponding to the first period-delimited token in the provided path (e.g.
-- 'test.moddata' for test.subTable.anotherTable) and then attempts to traverse the specified table hierarchy
-- to reach the final specified level. If any intermediate portion does not exist, this will return nil.
-- Use this when you want to read data and would normally need to do a bunch of intervening nil checks.
function ReadModData(dottedPath)
    return GenericModData(dottedPath, false)
end

-- Serializes the full contents of the file associated with this table to disk. When changing data, best
-- practice is to call save() as promptly as is reasonable, as any use on another VM could result in data
-- loss since instances are not synchronized across VMs.
function ModDataEntry:save()
    local instance = rootLinks[self]
    local file, err = io.open(instance.path, "w+")
    if err then
        print('Unable to write mod data to ' .. instance.path)
    return err end
    recursiveWrite(file, instance.data)
    file:close()
end

end -- if not ModDataEntry