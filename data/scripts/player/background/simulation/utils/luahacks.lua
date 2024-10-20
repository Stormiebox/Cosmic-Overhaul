--[[
    This is intended to be a somewhat generalized (or generalizable) template for using proxy tables
    as a means of tweaking behavior not easily modifiable via conventional means.
]]

local CaptainClass = include 'captainclass'

LuaHackEntry = {}
LuaHackEntry.__index = LuaHackEntry
function LuaHackEntry:enable() self.enabled = true end
function LuaHackEntry:disable() self.enabled = false end
function LuaHackEntry:isEnabled() return self.enabled end
function LuaHackEntry.new()
    return setmetatable({ enabled = false }, LuaHackEntry)
end
setmetatable(LuaHackEntry, { 
    __call = function(self, ...) return LuaHackEntry.new(...) end})

LuaHackCategory = setmetatable({}, {
    __index = LuaHackEntry,
    __call = function(self, ...) return LuaHackCategory.new(...) end
})
function LuaHackCategory:anyEnabled()
    for k, v in pairs(self.hacks) do
        if v.enabled then return true end
    end
    return false
end
function LuaHackCategory.new(includedHacks)
    local m = { hacks = includedHacks }
    return setmetatable({ hacks = includedHacks }, {
        __index = function(self, k)
            for hackKey, hackValue in pairs(self.hacks) do
                if hackKey == k then return hackValue end
            end
            return LuaHackCategory[k]
        end})
end

LuaHacks = {}
LuaHacks.Hacks = {
    ShipDatabaseEntry = LuaHackCategory({
        CaptainAlwaysHasMerchant = LuaHackEntry()
    })
}

-- These styles of hacks often rely on setting up a new table as a "proxy object" to intercept the
-- pieces that should change and forward everything else. That doesn't play nicely with the Avorion
-- inbuilt "valid," though, which faults when trying to call it with a table. Here, we shim valid()
-- to allow it to check the first userdata in a table before failing.
local luaHacks_original_valid_func = valid
valid = function(thing)
    if type(thing) == "table" then
        for _, v in pairs(thing) do
            if type(v) == "userdata" then return luaHacks_original_valid_func(v) end
        end
    end
    return luaHacks_original_valid_func(thing)
end

-- General approach explained:
-- * Identify the behavior you want to modify -- e.g. below, the desire is to make captain:hasClass()
--      always return "true" when checking for Merchant
-- * Walk the sequence of calls used to get the object back up to a top-level global function like
--      Entity, Sector, or (below) ShipDatabaseEntry
-- * Replace the top-level global function with a new one that:
--      - Records the original result using a cached reference to the original function
--      - Checks if the hack should currently be used and returns the original ASAP if it shouldn't
--      - Explicitly replaces the members whose behavior you want to modify
--      - Has its metatable set to a table with an __index like the generic one below
--      - If writes are needed, also include a __newindex
--      - Returns the proxy table
-- * Note that object proxying may need to be repeated across multiple levels to make it work

local luaHacks_genericIndex = function(self, k, ...)
    local indexed = self._proxied[k]
    -- This properly handles strings, numbers, booleans, etc.
    if type(indexed) ~= "function" then return indexed end
    -- This propertly handles "self" funcs of the form thing:function(...)
    return function(...) return indexed(self._proxied, ...) end
end

local luaHacks_original_ShipDatabaseEntry_func = ShipDatabaseEntry
ShipDatabaseEntry = function(...)
    local proxyDatabaseEntry = { _proxied = luaHacks_original_ShipDatabaseEntry_func(...) }
    if not proxyDatabaseEntry._proxied
        or not LuaHacks.Hacks.ShipDatabaseEntry:anyEnabled()
    then
        return proxyDatabaseEntry._proxied
    end

    proxyDatabaseEntry.getCaptain = function(self, ...)
        local proxyGetCaptain = { _proxied = self._proxied:getCaptain(self._proxied, ...) }
        proxyGetCaptain.hasClass = function(self, checkedClass)
            if LuaHacks.Hacks.ShipDatabaseEntry.CaptainAlwaysHasMerchant:isEnabled()
                and checkedClass == CaptainClass.Merchant
            then
                return true
            end
            return self._proxied:hasClass(checkedClass)
        end
        setmetatable(proxyGetCaptain, { __index = luaHacks_genericIndex })
        return proxyGetCaptain
    end
    setmetatable(proxyDatabaseEntry, { __index = luaHacks_genericIndex })
    return proxyDatabaseEntry
end

-- When enabled, all calls to ShipDatabaseEntry will be modified to return modified Captain objects via
-- getCaptain() such that captain:hasClass(CaptainClass.Merchant) will always evaluate to true.
function LuaHacks.SetShipDatabaseEntryCaptainAlwaysHasMerchant(enabled)
    hackToggles.ShipDatabaseEntry.CaptainAlwaysHasMerchant = enabled
end

function LuaHacks.RunWithHacks(hacks, func, ...)
    -- isEnabled present means it's just one hack
    if hacks.isEnabled then hacks = {hacks} end
    for k, hack in pairs(hacks) do
        hack:enable()
    end
    local result = func(...)
    for _, hack in pairs(hacks) do
        hack:disable()
    end
    return result
end

function LuaHacks.HackedFunc(hacks, func, ...)
    return function(...) return LuaHacks.RunWithHacks(hacks, func, ...) end
end

--[[
    Usage notes:

    -- A ShipDatabaseEntry created before the hack is turned on won't point to anything proxied
    -- and will never behave differently
    local prehackDatabaseEntry = ShipDatabaseEntry(ownerIndex, shipName)

    LuaHacks.SetShipDatabaseEntryCaptainAlwaysHasMerchant(true)

    -- A ShipDatabaseEntry created during the hack will point to the updated functions and be
    -- eligible for modified behavior, BUT the functions themselves should also check.
    local hackedDatabaseEntry = ShipDatabaseEntry(ownerIndex, shipName)

    -- All during the hack means it's TRUE
    local hackedCaptain = hackedDatabaseEntry:getCaptain()
    print('This should be TRUE: ' .. tostring(hackedCaptain:hasClass(CaptainClass.Merchant)))

    LuaHacks.SetShipDatabaseEntryCaptainAlwaysHasMerchant(false)

    -- The hacked captain still has the proxied function called, but the function will evaluate FALSE
    print('This should be FALSE: ' .. tostring(hackedCaptain:hasClass(CaptainClass.Merchant)))
]]
return LuaHacks