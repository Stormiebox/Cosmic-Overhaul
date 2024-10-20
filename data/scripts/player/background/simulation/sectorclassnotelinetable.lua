
-- This is a utility class to build note tables.

local SectorClassNoteLineTable = {}
SectorClassNoteLineTable.__index = SectorClassNoteLineTable

-- implementation detail

local function new(...)
    return setmetatable({
        sectors = {},
        classes = {},
        data = {},
    }, SectorClassNoteLineTable)
end

function SectorClassNoteLineTable:forNewSector(sector)
    self.sectors = { sector }
    return self
end

function SectorClassNoteLineTable:forAnotherSector(sector)
    table.insert(self.sectors, sector)
    return self
end

function SectorClassNoteLineTable:forNewSectors(sectors)
    self.sectors = sectors
    return self
end

function SectorClassNoteLineTable:forNewClass(classType)
    self.classes = { classType }
    return self
end

function SectorClassNoteLineTable:forAnotherClass(classType)
    table.insert(self.classes, classType)
    return self
end

function SectorClassNoteLineTable:forNewClasses(classTypes)
    self.classes = classTypes
    return self
end

function SectorClassNoteLineTable:addLines(lines)
    for _, sector in pairs(self.sectors) do
        for _, class in pairs(self.classes) do
            self.data[sector] = self.data[sector] or {}
            self.data[sector][class] = self.data[sector][class] or {}
            for _, line in pairs(lines) do
                table.insert(self.data[sector][class], line)
            end
        end
    end
    return self
end

function SectorClassNoteLineTable:setLines(lines)
    for _, sector in pairs(self.sectors) do
        for _, class in pairs(self.classes) do
            self.data[sector] = self.data[sector] or {}
            self.data[sector][class] = lines
        end
    end
    return self
end

function SectorClassNoteLineTable:getLines(sectorPath, captain)
    if not self.data[sectorPath] then return end
    if self.data[sectorPath][captain.primaryClass] then return self.data[sectorPath][captain.primaryClass] end
    if self.data[sectorPath][captain.secondaryClass] then return self.data[sectorPath][captain.secondaryClass] end
    return nil
end

-- For diagnostic purposes
function SectorClassNoteLineTable:dump()
    for sector, classes in pairs(self.data) do
        print(sector)
        for class, lines in pairs(classes) do
            print ("   " .. class)
            for _, line in pairs(lines) do
              print("      " .. line)
            end
        end
    end
    return self
end

return setmetatable({new = new}, {__call = function(_, ...) return new(...) end})
