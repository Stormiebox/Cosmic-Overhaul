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
        "Sensors picked up a massive, dormant gate structure adrift in this sector."%_T,
        "We found a colossal ring gate here. It looks ancient and entirely dead."%_T,
        "There is an enormous, deactivated hyperspace gate floating silently in this sector."%_T,
        "We mapped a monolithic ancient gate construct. Its original builders are long gone."%_T
    })
    :forNewSector("sectors/asteroidshieldboss")
    :addLines({
        "Asteroids in a perfect ring formation are emitting bizarre energy readings here. We kept our distance."%_T,
        "We detected a massive energy shield tethered to a cluster of glowing asteroids."%_T,
        "There is a highly suspicious, shielded rock formation in this sector. Proceed with caution."%_T,
        "An unnatural arrangement of asteroids is broadcasting a hostile energy signature in this area."%_T
    })
    :forNewSector("sectors/cultists")
    :addLines({
        "Sensors picked up a group of zealots obsessing over a massive asteroid."%_T,
        "A strange cult seems to have set up camp around a giant rock in this sector."%_T,
        "We intercepted some unhinged radio chatter. Cultists are congregating around an asteroid here."%_T,
        "There are fanatics out here worshipping an asteroid. Space madness is a terrible thing."%_T
    })
    :forNewSector("sectors/lonewormhole")
    :addLines({
        "A localized spatial tear is present here. Looks like a stable wormhole."%_T,
        "Scanners picked up a lone wormhole hidden in the void of this sector."%_T,
        "There is a wormhole phenomenon active here. Destination unknown."%_T,
        "We almost stumbled straight into a spatial anomaly. A wormhole is open in this sector."%_T
    })
    :forNewSector("sectors/researchsatellite")
    :addLines({
        "We intercepted a repeating broadcast from a lone research satellite."%_T,
        "An automated science probe is transmitting strange data about asteroids here."%_T,
        "A solitary satellite is pinging complex research telemetry in this sector."%_T,
        "There is an abandoned satellite registered to 'M.A.D. Science' looping its logs here."%_T
    })
    :forNewSector("sectors/resistancecell")
    :addLines({
        "We stumbled upon a hidden resistance cell operating completely off the grid."%_T,
        "Against all odds, there's a scrappy survivor outpost tucked away in this sector."%_T,
        "A heavily concealed resistance faction is holding out against the Xsotan here."%_T,
        "We found a pocket of survivors out here claiming to be part of a rebellion."%_T
    })
    :forNewSector("sectors/teleporter")
    :addLines({
        "An artificial ring of numbered asteroids and strange stations is adrift here."%_T,
        "We found a complex arrangement of asteroids with strange numerical markings."%_T,
        "A dormant, circular array of asteroids and Xsotan tech is floating in this sector."%_T,
        "There is a bizarre, ritualistic ring of marked asteroids generating faint energy spikes."%_T
    })
    :forNewSector("sectors/factionheadquarters")
    :forNewClass(CaptainUtility.ClassType.Explorer)
    :addLines({
        "Sensors are going crazy. We've discovered a massive Faction Headquarters here."%_T,
        "We've located a heavily fortified central command station. It's a Faction HQ."%_T,
        "This sector is bustling with military traffic protecting a Faction Headquarters."%_T,
        "I've mapped the location of a major Faction Headquarters in this sector."%_T
    })
    -- Functional Wreckage: special notes (Explorer/Scavenger)
    :forNewSector("sectors/functionalwreckage")
    :forNewClasses({
        CaptainUtility.ClassType.Explorer,
        CaptainUtility.ClassType.Scavenger,
    })
    :addLines({
        "Sensors show a derelict ship with an intact core. We could restore it to working order."%_T,
        "There's a heavily damaged but structurally sound ship abandoned in this sector."%_T,
        "We located an intact derelict vessel here. With a solid repair crew, she'll fly again."%_T,
        "I spotted a salvageable ship out here. It is practically begging to be claimed and repaired."%_T,
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
        "Massive debris fields and wrecked hulls detected in this sector."%_T,
        "We mapped a graveyard of destroyed ships here. Prime salvaging territory."%_T,
        "This sector is littered with the husks of dead ships."%_T,
        "Sensors show heavy wreckage concentrations in this area. Bring your salvage lasers."%_T,
    })
    -- Container field notes (Explorer)
    :forNewSectors({
        "sectors/containerfield",
        "sectors/massivecontainerfield",
    })
    :forNewClass(CaptainUtility.ClassType.Explorer)
    :addLines({
        "A massive stash of lost cargo containers is floating freely here."%_T,
        "We detected a dense cluster of abandoned shipping containers in this sector."%_T,
        "There is a veritable goldmine of unbranded cargo crates adrift out here."%_T,
        "Sensors picked up a large, unsecured container cache drifting in the void."%_T,
    })
    -- Smuggler's Market (Smuggler Hideout): Explorer and Smuggler
    :forNewSector("sectors/smugglerhideout")
    :forNewClasses({
        CaptainUtility.ClassType.Explorer,
        CaptainUtility.ClassType.Smuggler,
    })
    :addLines({
        "We picked up encrypted comms. Looks like a black market hub is nearby."%_T,
        "A shady syndicate operates a hidden Smuggler's Market in this sector."%_T,
        "Sensors detected a heavily cloaked Smuggler's Hideout operating off the books."%_T,
        "There is a hive of scum and villainy tucked away in this area."%_T,
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
        "Dense asteroid clusters detected. Good prospects for a mining operation."%_T,
        "We mapped a massive, resource-rich asteroid field in this sector."%_T,
        "Heavy asteroid presence here. Prime territory for our mining lasers."%_T,
        "Scanners show a dense field of unmined rocks in this sector."%_T,
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
        "Hostile pirate signatures detected. They are heavily entrenched in this sector."%_T,
        "A major pirate syndicate controls this area. Approach with weapons hot."%_T,
        "Sensors are lighting up with raider transponders. It's a pirate stronghold."%_T,
        "We spotted a large contingent of pirate scum operating in this sector."%_T,
    })
    -- Xsotan: still Explorer and Daredevil
    :forNewSectors({
        "sectors/xsotanasteroids",
        "sectors/xsotantransformed",
        "sectors/xsotanbreeders",
    })
    :addLines({
        "Massive alien energy spikes detected. The Xsotan are swarming here."%_T,
        "We barely avoided a massive Xsotan breeding cluster in this sector."%_T,
        "This sector is heavily infested by the Xsotan menace."%_T,
        "Alien bio-signatures confirmed. The Xsotan have claimed this space."%_T,
    })
    -- Extra for Operation Exodus; overloading use of sector
    :forNewSector("story/operationexodusbeacon")
    :forNewClass(CaptainUtility.ClassType.Explorer)
    :addLines({
        "We also picked up a repeating automated beacon on a forgotten frequency."%_T,
        "There's a strange navigational beacon here transmitting encrypted coordinates."%_T,
        "Also, a lone beacon is pulsing an 'Exodus' distress signal."%_T,
        "Oh, and I noted an ancient beacon broadcasting fragments of a mysterious message."%_T,
    })
