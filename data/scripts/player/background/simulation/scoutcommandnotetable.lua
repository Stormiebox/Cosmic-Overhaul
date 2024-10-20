local SectorClassNoteLineTable = include("sectorclassnotelinetable")
local CaptainUtility = include("captainutility")

-- Here's where the lines are actually built:
--  :forNewClass / :forNewClasses *reset* the current classes the next :addLines will apply to
--  :forAnotherClass *adds to* the current classes that the next :addLines will apply to
--  :forNewSector / :forNewSectors / :forAnotherSector work the same way
--  :addLines inserts the input lines to whatever's currently set
--  :setLines applies the input lines and replaces what was already there
--
-- Mods can easily add to/change this by just continuing the table build:
--   scf_scoutCommandLineTableBuilder = scf_scoutCommandLineTableBuilder
--       :forNewClass(...)
--       :forNewSector(...)
--       :addLines(...)
--
return SectorClassNoteLineTable.new()
    -- Explorer-only hidden mass sectors start here
    :forNewClass(CaptainUtility.ClassType.Explorer)
    :forNewSector("sectors/ancientgates")
    :addLines({
        "We saw a very large, very old gate in this sector."%_t,
        "There is a big gate here."%_t,
        "A large, unusual, inactive gate is in this sector."%_t
    })
    :forNewSector("sectors/asteroidshieldboss")
    :addLines({
        "Some strange, glowing asteroids in this sector. We stayed away."%_t,
        "A very unusual ring of asteroids here. Are they charging something?"%_t,
        "An unnatural arrangement of asteroids with a weird signal in this sector."%_t
    })
    :forNewSector("sectors/cultists")
    :addLines({
        "Some very odd people are gathered around a big asteroid here."%_t,
        "People around an asteroid. Lots of chanting."%_t,
        "I think there are people worshipping a rock in this sector. Really."%_t
    })
    :forNewSector("sectors/lonewormhole")
    :addLines({
        "It looked empty at first, but there's a wormhole here."%_t,
        "We almost stumbled straight into a wormhole in this sector."%_t,
        "Not sure where it goes, but there's a wormhole."%_t
    })
    :forNewSector("sectors/researchsatellite")
    :addLines({
        "An unusual satellite looping some research notes here."%_t,
        "A satellite in this sector talking about energy and stone."%_t,
        "There's a satellite registered to 'M.A.D. Science' in this sector."%_t
    })
    :forNewSector("sectors/resistancecell")
    :addLines({
        "I couldn't believe it, but there are still people surviving in this sector."%_t,
        "Against all odds, there's a small outpost hiding from the Xsotan here."%_t,
        "Some people claiming to be part of a resistance are stationed here."%_t
    })
    :forNewSector("sectors/teleporter")
    :addLines({
        "A very strange ring of asteroids here. Xsotan energy signatures."%_t,
        "There's a circular formation of strange, numbered asteroids here."%_t,
        "A ring of asteroids with inactive stations. Waiting for something."%_t
    })
    -- Functional Wreckage: special notes (Explorer/Scavenger)
    :forNewSector("sectors/functionalwreckage")
    :forNewClasses({
        CaptainUtility.ClassType.Explorer,
        CaptainUtility.ClassType.Scavenger,
    })
    :addLines({
        "An abandoned ship is here that looks largely intact. It may be repairable."%_t,
        "A good repair crew might be able to get a ship we found flying again."%_t,
        "A wreck in this sector is only lightly damaged. I bet we can repair it."%_t,
    })
    -- Other Wreckages: Explorer and Scavenger
    :forNewSectors({
        "sectors/stationwreckage",
        "sectors/wreckageasteroidfield",
        "sectors/wreckagefield",
    })
    :forNewClasses({
        CaptainUtility.ClassType.Explorer,
        CaptainUtility.ClassType.Scavenger,
    })
    :addLines({
        "There are wrecks in this sector."%_t,
        "We found wrecks in this sector."%_t,
        "This sector contains wrecks."%_t,
    })
    -- Container field notes (Explorer)
    :forNewSectors({
        "sectors/containerfield",
        "sectors/massivecontainerfield",
    })
    :forNewClass(CaptainUtility.ClassType.Explorer)
    :addLines({
        "Containers are stored in this sector."%_t,
        "We found a container field in this sector."%_t,
        "There is a container field in this sector."%_t,
    })
    -- Smuggler's Market (Smuggler Hideout): Explorer and Smuggler
    :forNewSector("sectors/smugglerhideout")
    :forNewClasses({
        CaptainUtility.ClassType.Explorer,
        CaptainUtility.ClassType.Smuggler,
    })
    :addLines({
        "Smugglers hide here."%_t,
        "There are smugglers hanging around here."%_t,
        "Smugglers use this sector as their hideout."%_t,
    })
    -- Asteroids: Explorer and Miner
    :forNewSectors({
        "sectors/asteroidfield",
        "sectors/pirateasteroidfield",
        "sectors/defenderasteroidfield",
        "sectors/asteroidfieldminer",
        "sectors/smallasteroidfield",
        "sectors/wreckageasteroidfield",
    })
    :forNewClasses({
        CaptainUtility.ClassType.Explorer,
        CaptainUtility.ClassType.Miner,
    })
    :addLines({
        "There are asteroids here."%_t,
        "We found an asteroid field in this sector."%_t,
        "We found asteroids here."%_t,
        "There are asteroids in this sector."%_t,
    })
    -- Pirates: Explorer and Daredevil
    :forNewSectors({
        "sectors/pirateasteroidfield",
        "sectors/piratefight",
        "sectors/piratestation",
    })
    :forNewClasses({
        CaptainUtility.ClassType.Explorer,
        CaptainUtility.ClassType.Daredevil,
    })
    :addLines({
        "There are pirates hiding here."%_t,
        "We saw pirates in this sector."%_t,
        "This sector is infested with pirates."%_t,  
    })
    -- Xsotan: still Explorer and Daredevil
    :forNewSectors({
        "sectors/xsotanasteroids",
        "sectors/xsotantransformed",
        "sectors/xsotanbreeders",
    })
    :addLines({
        "There are Xsotan here."%_t,
        "We saw Xsotan in this sector."%_t,
        "Don't go here if you don't like Xsotan."%_t,
    })
    -- Extra for Operation Exodus; overloading use of sector
    :forNewSector("story/operationexodusbeacon")
    :forNewClass(CaptainUtility.ClassType.Explorer)
    :addLines({
        "Also, some sort of communication beacon was active here."%_t,
        "We also detected a signal from some sort of beacon."%_t,
        "Oh, and there was a beacon broadcasting something about 'Exodus'."%_t,
    })