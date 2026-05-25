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
        "We saw a very large, very old gate in this sector."%_T,
        "There is a big gate here."%_T,
        "A large, unusual, inactive gate is in this sector."%_T
    })
    :forNewSector("sectors/asteroidshieldboss")
    :addLines({
        "Some strange, glowing asteroids in this sector. We stayed away."%_T,
        "A very unusual ring of asteroids here. Are they charging something?"%_T,
        "An unnatural arrangement of asteroids with a weird signal in this sector."%_T
    })
    :forNewSector("sectors/cultists")
    :addLines({
        "Some very odd people are gathered around a big asteroid here."%_T,
        "People around an asteroid. Lots of chanting."%_T,
        "I think there are people worshipping a rock in this sector. Really."%_T
    })
    :forNewSector("sectors/lonewormhole")
    :addLines({
        "It looked empty at first, but there's a wormhole here."%_T,
        "We almost stumbled straight into a wormhole in this sector."%_T,
        "Not sure where it goes, but there's a wormhole."%_T
    })
    :forNewSector("sectors/researchsatellite")
    :addLines({
        "An unusual satellite looping some research notes here."%_T,
        "A satellite in this sector talking about energy and stone."%_T,
        "There's a satellite registered to 'M.A.D. Science' in this sector."%_T
    })
    :forNewSector("sectors/resistancecell")
    :addLines({
        "I couldn't believe it, but there are still people surviving in this sector."%_T,
        "Against all odds, there's a small outpost hiding from the Xsotan here."%_T,
        "Some people claiming to be part of a resistance are stationed here."%_T
    })
    :forNewSector("sectors/teleporter")
    :addLines({
        "A very strange ring of asteroids here. Xsotan energy signatures."%_T,
        "There's a circular formation of strange, numbered asteroids here."%_T,
        "A ring of asteroids with inactive stations. Waiting for something."%_T
    })
    -- Functional Wreckage: special notes (Explorer/Scavenger)
    :forNewSector("sectors/functionalwreckage")
    :forNewClasses({
        CaptainUtility.ClassType.Explorer,
        CaptainUtility.ClassType.Scavenger,
    })
    :addLines({
        "An abandoned ship is here that looks largely intact. It may be repairable."%_T,
        "A good repair crew might be able to get a ship we found flying again."%_T,
        "A wreck in this sector is only lightly damaged. I bet we can repair it."%_T,
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
        "There are wrecks in this sector."%_T,
        "We found wrecks in this sector."%_T,
        "This sector contains wrecks."%_T,
    })
    -- Container field notes (Explorer)
    :forNewSectors({
        "sectors/containerfield",
        "sectors/massivecontainerfield",
    })
    :forNewClass(CaptainUtility.ClassType.Explorer)
    :addLines({
        "Containers are stored in this sector."%_T,
        "We found a container field in this sector."%_T,
        "There is a container field in this sector."%_T,
    })
    -- Smuggler's Market (Smuggler Hideout): Explorer and Smuggler
    :forNewSector("sectors/smugglerhideout")
    :forNewClasses({
        CaptainUtility.ClassType.Explorer,
        CaptainUtility.ClassType.Smuggler,
    })
    :addLines({
        "Smugglers hide here."%_T,
        "There are smugglers hanging around here."%_T,
        "Smugglers use this sector as their hideout."%_T,
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
        "There are asteroids here."%_T,
        "We found an asteroid field in this sector."%_T,
        "We found asteroids here."%_T,
        "There are asteroids in this sector."%_T,
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
        "There are pirates hiding here."%_T,
        "We saw pirates in this sector."%_T,
        "This sector is infested with pirates."%_T,
    })
    -- Xsotan: still Explorer and Daredevil
    :forNewSectors({
        "sectors/xsotanasteroids",
        "sectors/xsotantransformed",
        "sectors/xsotanbreeders",
    })
    :addLines({
        "There are Xsotan here."%_T,
        "We saw Xsotan in this sector."%_T,
        "Don't go here if you don't like Xsotan."%_T,
    })
    -- Extra for Operation Exodus; overloading use of sector
    :forNewSector("story/operationexodusbeacon")
    :forNewClass(CaptainUtility.ClassType.Explorer)
    :addLines({
        "Also, some sort of communication beacon was active here."%_T,
        "We also detected a signal from some sort of beacon."%_T,
        "Oh, and there was a beacon broadcasting something about 'Exodus'."%_T,
    })