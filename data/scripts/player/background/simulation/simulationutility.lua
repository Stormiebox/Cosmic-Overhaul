
local function colored(code, line)
    return '\\c(' .. code .. ')' .. line .. '\\c()'
end
local green = function(line) return colored('0d0', line) end
local yellow = function(line) return colored('dd5', line) end
local red = function(line) return colored('d93', line) end

local function randOneOf(seedValue, sourceFunc, ...)
    local rand = Random(Seed('' .. tostring(seedValue)))
    local lines = sourceFunc(...)
    return randomEntry(rand, lines)
end

-- These lines are intended to replace "radio silence" lines when a command can now
-- provide incremental information
function SimulationUtility.getIncrementalReportAssessmentLines()
    local lines = {
        "I'll have regular data for you as the mission progresses."%_t,
        "You'll receive frequent updates as we learn more."%_t,
        "Expect a continual flow of new information."%_t,
    }
    return lines
end
function SimulationUtility.getIncrementalReportAssessmentLine(seedValue)
    return randOneOf(seedValue, SimulationUtility.getIncrementalReportAssessmentLines)
end

-- New lines added for critical and less critical warnings about the impact of deep
-- scan on (e.g. Scout) mission time
function SimulationUtility.getDeepScanAssessmentLines(deepScanRange)
    if not deepScanRange or deepScanRange == 0 then return {
        red("We have no deep scan ability and will have to visit every sector."%_t),
        red("Travel time will be extreme without more deep scan coverage."%_t),
        red("We can't see where hidden mass sectors are without better radar."%_t),
    }
    elseif deepScanRange < 3 then return {
        yellow("With our weak sensors, we'll waste a lot of time jumping blindly."%_t),
        yellow("We'd be a lot faster with more deep scan coverage."%_t),
        yellow("Hidden mass sectors will be hard to find without better radar."%_t),
    }
    else return {}
    end
end
function SimulationUtility.getDeepScanAssessmentLine(seedValue, deepScanRange)
    return randOneOf(seedValue, SimulationUtility.getDeepScanAssessmentLines, deepScanRange)
end

function SimulationUtility.getSameSectorDepotLines()
    return {
        green("There's a refinery right here, so this will be fast and safe."%_t),
        green("Refining will be no problem with a depot right in this sector."%_t),
        green("I can autopilot right to the depot in this sector."%_t),
    }
end
function SimulationUtility.getSameSectorDepotLine(seedValue)
    return randOneOf(seedValue, SimulationUtility.getSameSectorDepotLines)
end


function SimulationUtility.getTradeCharityLines()
    return {
        green("People are sure to appreciate our work here."%_t),
        green("This will help a lot of people."%_t),
        green("Our generosity will help to build trust."%_t),
    }
end
function SimulationUtility.getTradeCharityLine(seedValue)
    return randOneOf(seedValue, SimulationUtility.getTradeCharityLines)
end

function SimulationUtility.getImperfectTradeClassLines()
    return {
        yellow("This isn't my specialty, but I'll see what I can do."%_t),
        yellow("A merchant would do this better, but I can give it a go."%_t),
        yellow("No merchants available, commander?"%_t),
    }
end
function SimulationUtility.getImperfectTradeClassLine(seedValue)
    return randOneOf(seedValue, SimulationUtility.getImperfectTradeClassLines)
end

-- For quick testing purposes only! Disables crew problems.
-- function SimulationUtility.getUsableErrorAssessmentMessage(...) return nil end
-- function SimulationUtility.isShipUsable(...) return nil end