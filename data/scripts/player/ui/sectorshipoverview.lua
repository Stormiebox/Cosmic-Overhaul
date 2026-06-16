-- Concept: add a new "Wreckages" tab to the strategy mode tabs.

function getUpdateInterval()
    return 1.0
end

-- Display a list of all wreckages in the sector, sorted by how big they are.
-- TODO: Adding benefits for Scavenger captains and particular subsystem upgrades
-- TODO: Possible (scanners?) to see more information, e.g. resource richness.

if onClient() then

local CaptainClass = include("captainclass")

local swt_initialize_original = SectorShipOverview.initialize
function SectorShipOverview.initialize()
    swt_initialize_original()
    SectorShipOverview.buildWreckagesUI()
    SectorShipOverview.refreshWreckagesList()
end

local swt_show_original = SectorShipOverview.show
function SectorShipOverview.show()
    swt_show_original()
    SectorShipOverview.refreshWreckagesList()
end

-- The wreckages refresh is somewhat expensive so we won't do it each and every
-- second like some of the updates.
local swt_update_counter = 0
local swt_update_frequency = 3

local swt_updateClient_original = SectorShipOverview.updateClient
function SectorShipOverview.updateClient(timestep)
    swt_updateClient_original(timestep)

    if not SectorShipOverview.wreckagesTab then return end

        -- Cosmic Overhaul: Use .visible to avoid UIElement property read errors
        if SectorShipOverview.wreckagesTab.visible then
        if swt_update_counter % swt_update_frequency == 0 then
            SectorShipOverview.refreshWreckagesList()
        end
        swt_update_counter = swt_update_counter + 1
    end
end

function SectorShipOverview.buildWreckagesUI()
        SectorShipOverview.wreckagesTab = SectorShipOverview.tabbedWindow:createTab("Wreckages"%_t,
        "data/textures/icons/WreckagesTab.png", "Wreckages"%_t)
    local hsplit = UIHorizontalSplitter(Rect(SectorShipOverview.wreckagesTab.size), 0, 0, 0.0)
    SectorShipOverview.wreckagesList = SectorShipOverview.wreckagesTab:createListBoxEx(hsplit.bottom)
    SectorShipOverview.wreckagesList.columns = 3
    SectorShipOverview.wreckagesList.rowHeight = SectorShipOverview.rowHeight
    SectorShipOverview.wreckagesList:setColumnWidth(0, SectorShipOverview.iconColumnWidth)
    local notColumnWidth = SectorShipOverview.wreckagesList.width - SectorShipOverview.iconColumnWidth
    SectorShipOverview.wreckagesList:setColumnWidth(1, notColumnWidth * 2 / 3)
    SectorShipOverview.wreckagesList:setColumnWidth(2, notColumnWidth / 3)
    SectorShipOverview.wreckagesList.onSelectFunction = "onEntrySelected"
end

local wreckageNames = {
    huge = {
        "Husk"%_t,
        "Derelict"%_t,
        "Ruin"%_t,
        "Hulk"%_t,
    },
    large = {
        "Skeleton"%_t,
        "Wreckage"%_t,
        "Remnant"%_t
    },
    medium = {
        "Flotsam"%_t,
        "Wreck"%_t
    },
    small = {
        "Salvage"%_t,
        "Dross"%_t
    },
    tiny = {
        "Fragments"%_t,
        "Debris"%_t,
        "Scraps"%_t,
        "Detritus"%_t
    }
}

function SectorShipOverview.refreshWreckagesList()
    if not SectorShipOverview.wreckagesList then return end

    local startingScrollPosition = SectorShipOverview.wreckagesList.scrollPosition

    local sector = Sector()
    local player = Player()
    local ship = player.craft

    local hasScavenger = false
    if ship then
        local shipEntry = ShipDatabaseEntry(player.index, ship.name)
        if shipEntry then
            local captain = shipEntry:getCaptain()
            if captain and captain:hasClass(CaptainClass.Scavenger) then
                hasScavenger = true
            end
        end
    end

    local wreckages = {sector:getEntitiesByType(EntityType.Wreckage)}
    table.sort(wreckages, function (w1, w2) return w1.mass > w2.mass end)
    SectorShipOverview.wreckagesList:clear()

    local white = ColorRGB(1, 1, 1)
    local gray = ColorRGB(0.6, 0.6, 0.6)

    local getMassString = function(entity)
        if not entity then return "" end
        local seed = Seed(entity.id.string)
        local name = function(list) return randomEntry(Random(seed), list) end
        local flavorName = ""

        if entity.mass >= 100 * 1000 * 1000 then
            flavorName = round(entity.mass / 1000 / 1000, 0) .. " Mt -- "
                .. name(wreckageNames.huge)
        elseif entity.mass >= 1000 * 1000 then
            flavorName = round(entity.mass / 1000 / 1000, 1) .. " Mt -- "
                .. name(wreckageNames.huge)
        elseif entity.mass >= 100 * 1000 then
            flavorName = round(entity.mass / 1000, 0) .. " Kt -- "
                .. name(wreckageNames.large)
        elseif entity.mass >= 1000 then
            flavorName = round(entity.mass / 1000, 1) .. " Kt -- "
                .. name(wreckageNames.medium)
        elseif entity.mass >= 100 then
            flavorName = round(entity.mass, 0) .. " t -- "
                .. name(wreckageNames.small)
        else
            flavorName = round(entity.mass, 1) .. " t -- "
                .. name(wreckageNames.tiny)
        end

        -- Scavenger Captain Synergy: Reveal the true identity of the wreckage!
        if hasScavenger and entity.translatedTitle and entity.translatedTitle ~= "" then
            return flavorName .. " (" .. entity.translatedTitle .. ")"
        end

        return flavorName
    end

    local getDistString = function(entity)
        if not ship or not entity then return "" end
        local dist = ship:getNearestDistance(entity)
        if dist >= 100 then return round(dist / 100, 1) .. "km" end
        return round(dist / 100, 2) .. "km"
    end

    local scrapIcon = "data/textures/icons/scrap-metal.png"

    for _, wreckage in pairs(wreckages) do
        SectorShipOverview.wreckagesList:addRow(wreckage.id.string)
        SectorShipOverview.wreckagesList:setEntry(0, SectorShipOverview.wreckagesList.rows - 1, scrapIcon, false, false, gray)
        SectorShipOverview.wreckagesList:setEntry(1, SectorShipOverview.wreckagesList.rows - 1, getMassString(wreckage), false, false, white)
        SectorShipOverview.wreckagesList:setEntry(2, SectorShipOverview.wreckagesList.rows - 1, getDistString(wreckage), false, false, gray)
        SectorShipOverview.wreckagesList:setEntryType(0, SectorShipOverview.wreckagesList.rows - 1, ListBoxEntryType.Icon)
    end

    if player.selectedObject then
        SectorShipOverview.wreckagesList:selectValueNoCallback(player.selectedObject.string)
    end

    SectorShipOverview.wreckagesList.scrollPosition = startingScrollPosition
end

end -- if onClient()

function initialize(...)
    if SectorShipOverview.initialize then return SectorShipOverview.initialize(...) end
end
function updateClient(...)
    if SectorShipOverview.updateClient then return SectorShipOverview.updateClient(...) end
end
