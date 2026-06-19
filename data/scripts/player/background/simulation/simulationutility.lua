
local function randOneOf(seedValue, sourceFunc, ...)
    local rand = Random(Seed('' .. tostring(seedValue)))
    local lines = sourceFunc(...)
    return randomEntry(rand, lines)
end

-- These lines are intended to replace "radio silence" lines when a command can now
-- provide incremental information
function SimulationUtility.getIncrementalReportAssessmentLines()
    local lines = {
        "I'll have regular data for you as the mission progresses."%_T,
        "You'll receive frequent updates as we learn more."%_T,
        "Expect a continual flow of new information."%_T,
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
        "\\c(d93)We have no deep scan ability and will have to visit every sector.\\c()"%_T,
        "\\c(d93)Travel time will be extreme without more deep scan coverage.\\c()"%_T,
        "\\c(d93)We can't see where hidden mass sectors are without better radar.\\c()"%_T,
    }
    elseif deepScanRange < 3 then return {
        "\\c(dd5)With our weak sensors, we'll waste a lot of time jumping blindly.\\c()"%_T,
        "\\c(dd5)We'd be a lot faster with more deep scan coverage.\\c()"%_T,
        "\\c(dd5)Hidden mass sectors will be hard to find without better radar.\\c()"%_T,
    }
    else return {}
    end
end
function SimulationUtility.getDeepScanAssessmentLine(seedValue, deepScanRange)
    return randOneOf(seedValue, SimulationUtility.getDeepScanAssessmentLines, deepScanRange)
end

function SimulationUtility.getSameSectorDepotLines()
    return {
        "\\c(0d0)There's a refinery right here, so this will be fast and safe.\\c()"%_T,
        "\\c(0d0)Refining will be no problem with a depot right in this sector.\\c()"%_T,
        "\\c(0d0)I can autopilot right to the depot in this sector.\\c()"%_T,
    }
end
function SimulationUtility.getSameSectorDepotLine(seedValue)
    return randOneOf(seedValue, SimulationUtility.getSameSectorDepotLines)
end


function SimulationUtility.getTradeCharityLines()
    return {
        "\\c(0d0)People are sure to appreciate our work here.\\c()"%_T,
        "\\c(0d0)This will help a lot of people.\\c()"%_T,
        "\\c(0d0)Our generosity will help to build trust.\\c()"%_T,
    }
end
function SimulationUtility.getTradeCharityLine(seedValue)
    return randOneOf(seedValue, SimulationUtility.getTradeCharityLines)
end

function SimulationUtility.getImperfectTradeClassLines()
    return {
        "\\c(dd5)This isn't my specialty, but I'll see what I can do.\\c()"%_T,
        "\\c(dd5)A merchant would do this better, but I can give it a go.\\c()"%_T,
        "\\c(dd5)No merchants available, commander?\\c()"%_T,
    }
end
function SimulationUtility.getImperfectTradeClassLine(seedValue)
    return randOneOf(seedValue, SimulationUtility.getImperfectTradeClassLines)
end

-- For quick testing purposes only! Disables crew problems.
-- function SimulationUtility.getUsableErrorAssessmentMessage(...) return nil end
-- function SimulationUtility.isShipUsable(...) return nil end
