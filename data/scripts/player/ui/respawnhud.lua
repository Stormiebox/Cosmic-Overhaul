package.path = package.path .. ";data/scripts/lib/?.lua"

include("utility")

local CosmicOverhaulConfig = include("cosmicoverhaulconfig")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace RespawnHud
RespawnHud = {}

-- Sector value keys (must match respawnresourceasteroids.lua)
local KEY_RESOURCE_BASELINE = "outlands_rr_res_baseline"
local KEY_TARGET_PCT = "outlands_rr_target_pct"
local KEY_LAST_RESPAWN = "outlands_rr_last_respawn"

-- Material types in order (Iron=0 through Avorion=6)
local NUM_MATERIALS = 7

-- Layout constants
local layout = {
    barW = 300,
    barH = 4,
    rowGap = 2,
    resH = 12,
    colGap = 8,
    timerW = 80,
    pctW = 80,
    topOffset = 5,
    smallFont = 11,
    tallFont = 18,
}

-- UI elements (populated in initialize)
local ui = {
    container = nil,
    barFrame = nil,
    segments = {},
    depletionZone = nil,
    timerLabel = nil,
    resourceLabel = nil,
    surplusLabel = nil,
    pctLabel = nil,
    emptyLabel = nil,
    visible = false,
    flashTimer = 0,
}

-- Lerp and data state
local state = {
    display = {},       -- smoothed amounts per material
    target = {},        -- actual amounts per material (updated periodically)
    displayTotal = 0,
    targetTotal = 0,
    baseline = 0,
    targetPct = 0.8,
    dataTimer = 0,
    dataReady = false,
    lerpSpeed = 4.0,
    dataInterval = 1.0,
}

-- Format resource numbers with thousand separators (e.g. 2,400,000)
local function formatResources(amount)
    local s = string.format("%d", amount)
    local pos = #s % 3
    if pos == 0 then pos = 3 end
    local parts = {s:sub(1, pos)}
    for i = pos + 1, #s, 3 do
        table.insert(parts, s:sub(i, i + 2))
    end
    return table.concat(parts, ",")
end

local function resetState()
    for i = 0, NUM_MATERIALS - 1 do
        state.display[i] = 0
        state.target[i] = 0
    end
    state.displayTotal = 0
    state.targetTotal = 0
    state.baseline = 0
    state.dataReady = false
    state.dataTimer = 0
end

function RespawnHud.onSectorChanged()
    resetState()
end

function RespawnHud.initialize()


    if not onClient() then return end

    local res = getResolution()
    local L = layout

    ui.container = Hud():createContainer(Rect(vec2(0, 0), res))

    -- Total width: timer + gap + bar + gap + pct
    local totalW = L.timerW + L.colGap + L.barW + L.colGap + L.pctW
    local startX = math.floor((res.x - totalW) / 2)

    -- Column positions
    local timerX = startX
    local barX = timerX + L.timerW + L.colGap
    local pctX = barX + L.barW + L.colGap

    -- Row positions
    local barY = L.topOffset
    local resY = barY + L.barH + L.rowGap
    local totalH = L.barH + L.rowGap + L.resH

    -- Background frame for the bar area (Col 2, Row 1)
    ui.barFrame = ui.container:createFrame(Rect(barX - 1, barY - 1, barX + L.barW + 1, barY + L.barH + 1))
    ui.barFrame.backgroundColor = ColorARGB(0.4, 0.0, 0.0, 0.0)

    -- Depletion zone: red segment from target to end of bar (created before segments so it renders behind)
    local targetX = barX + math.floor(L.barW * 0.8)
    ui.depletionZone = ui.container:createFrame(Rect(targetX, barY, barX + L.barW, barY + L.barH))
    ui.depletionZone.backgroundColor = ColorARGB(0.8, 0.6, 0.1, 0.1)

    -- Create one segment frame per material type (on top of depletion zone)
    for i = 0, NUM_MATERIALS - 1 do
        local mat = Material(i)
        local seg = ui.container:createFrame(Rect(barX, barY, barX, barY + L.barH))
        seg.backgroundColor = mat.color
        seg.visible = false
        ui.segments[i] = seg
    end

    -- Vertically center tall labels, shifted up slightly
    local tallY = barY + math.floor((totalH - L.tallFont) / 2) - 3

    -- Col 1, Rows 1-2: Timer (tall bold font, right-aligned, +1px to match pct baseline)
    ui.timerLabel = ui.container:createLabel(vec2(timerX, tallY + 1), "", L.tallFont)
    ui.timerLabel.size = vec2(L.timerW, L.tallFont + 2)
    ui.timerLabel.color = ColorRGB(0.7, 0.7, 0.7)
    ui.timerLabel.bold = true
    ui.timerLabel:setRightAligned()

    -- Col 2, Row 2: Resource amount (left half)
    local halfW = math.floor(L.barW / 2)
    ui.resourceLabel = ui.container:createLabel(vec2(barX, resY), "", L.smallFont)
    ui.resourceLabel.size = vec2(halfW, L.resH)
    ui.resourceLabel.color = ColorRGB(0.7, 0.7, 0.7)

    -- Col 2, Row 2: Surplus over target (right half, green, right-aligned)
    ui.surplusLabel = ui.container:createLabel(vec2(barX + halfW, resY), "", L.smallFont)
    ui.surplusLabel.size = vec2(halfW, L.resH)
    ui.surplusLabel.color = ColorRGB(0.3, 0.8, 0.3)
    ui.surplusLabel:setRightAligned()

    -- Col 3, Rows 1-2: Percentage (tall bold font)
    ui.pctLabel = ui.container:createLabel(vec2(pctX, tallY), "", L.tallFont)
    ui.pctLabel.size = vec2(L.pctW, L.tallFont + 2)
    ui.pctLabel.color = ColorRGB(0.7, 0.7, 0.7)
    ui.pctLabel.bold = true

    -- "No resources found" label (centered below bar, hidden by default)
    ui.emptyLabel = ui.container:createLabel(vec2(barX, resY), "No resources found"%_t, L.smallFont)
    ui.emptyLabel.size = vec2(L.barW, L.resH)
    ui.emptyLabel.color = ColorRGB(0.6, 0.3, 0.3)
    ui.emptyLabel:setCenterAligned()
    ui.emptyLabel.visible = false

    ui.container.visible = false
end

function RespawnHud.getUpdateInterval()
    return 0
end

function RespawnHud.updateClient(timeStep)
    if not ui.container then return end

    -- Check MCM visibility toggle
    if CosmicOverhaulConfig.get().showHud == false then
        if ui.visible then
            ui.container.visible = false
            ui.visible = false
        end
        return
    end

    -- Only show when the player's ship has a mining system installed
    local player = Player()
    local craft = player and player.craft
    if not craft
        or not (craft:hasScript("data/scripts/systems/miningsystem.lua")
             or craft:hasScript("internal/dlc/rift/systems/miningcarrierhybrid.lua")) then
        if ui.visible then
            ui.container.visible = false
            ui.visible = false
        end
        return
    end

    -- Periodic data refresh (query sector every dataInterval seconds)
    state.dataTimer = state.dataTimer + timeStep
    if state.dataTimer >= state.dataInterval or not state.dataReady then
        state.dataTimer = 0

        local sector = Sector()
        local resBaseline = sector:getValue(KEY_RESOURCE_BASELINE)

        -- Determine mode: full (respawn script active) or simplified (resources only)
        state.baseline = resBaseline or 0
        state.targetPct = sector:getValue(KEY_TARGET_PCT) or 0.8
        local hasRespawn = state.baseline > 0

        -- Sum actual resource amounts by material type
        for i = 0, NUM_MATERIALS - 1 do state.target[i] = 0 end
        state.targetTotal = 0

        for _, entity in pairs({sector:getEntitiesByComponent(ComponentType.MineableMaterial)}) do
            if entity.type == EntityType.Asteroid then
                local resList = {entity:getMineableResources()}
                local entityTotal = 0
                for _, amount in pairs(resList) do
                    entityTotal = entityTotal + amount
                end

                if entityTotal > 0 then
                    state.targetTotal = state.targetTotal + entityTotal
                    local mat = entity:getMineableMaterial()
                    if mat then
                        local v = mat.value
                        if v >= 0 and v < NUM_MATERIALS then
                            state.target[v] = state.target[v] + entityTotal
                        end
                    end
                end
            end
        end

        -- Mark data as ready even with zero resources — HUD stays visible

        -- Col 1: Timer (only in full mode)
        if hasRespawn and CosmicOverhaulConfig.get().showTimer then
            local lastRespawn = sector:getValue(KEY_LAST_RESPAWN)
            local interval = (CosmicOverhaulConfig.get().respawnInterval or 2) * 60
            if lastRespawn and interval > 0 then
                local elapsed = Server().unpausedRuntime - lastRespawn
                local remaining = interval - (elapsed % interval)
                local mins = math.floor(remaining / 60)
                local secs = remaining % 60
                ui.timerLabel.caption = string.format("%d:%02d", mins, secs)
            else
                ui.timerLabel.caption = ""
            end
        else
            ui.timerLabel.caption = ""
        end

        -- On first data load, snap display values to targets (no lerp)
        if not state.dataReady then
            for i = 0, NUM_MATERIALS - 1 do
                state.display[i] = state.target[i]
            end
            state.displayTotal = state.targetTotal
            state.dataReady = true
        end
    end

    if not state.dataReady then return end

    local L = layout
    local hasRespawn = state.baseline > 0

    -- Lerp display values toward targets
    local alpha = math.min(1.0, state.lerpSpeed * timeStep)
    for i = 0, NUM_MATERIALS - 1 do
        state.display[i] = state.display[i] + (state.target[i] - state.display[i]) * alpha
    end
    state.displayTotal = state.displayTotal + (state.targetTotal - state.displayTotal) * alpha

    -- Calculate layout positions
    local res = getResolution()
    local totalW = L.timerW + L.colGap + L.barW + L.colGap + L.pctW
    local startX = math.floor((res.x - totalW) / 2)
    local barX = startX + L.timerW + L.colGap
    local barY = L.topOffset
    local cursor = barX

    -- Count visible segments for gap calculation
    local visibleCount = 0
    for i = 0, NUM_MATERIALS - 1 do
        if state.display[i] > 0.5 then visibleCount = visibleCount + 1 end
    end
    local totalGaps = math.max(0, visibleCount - 1)
    local usableW = L.barW - totalGaps

    -- Update segment widths using smoothed values
    -- Full mode: bar represents progress toward restoration target, clamped
    -- Simplified mode: bar fills proportionally to show material distribution
    local targetAmount = hasRespawn and (state.baseline * state.targetPct) or 0
    local barScale
    if hasRespawn then
        barScale = targetAmount > 0 and math.min(state.displayTotal, targetAmount) / targetAmount or 0
    else
        barScale = 1.0
    end
    local scaledW = math.floor(barScale * usableW)
    local visibleIdx = 0
    local lastVisibleSeg = nil
    for i = 0, NUM_MATERIALS - 1 do
        local seg = ui.segments[i]
        if state.display[i] > 0.5 then
            visibleIdx = visibleIdx + 1
            local ratio = state.displayTotal > 0 and (state.display[i] / state.displayTotal) or 0
            local w = math.max(1, math.floor(ratio * scaledW))
            seg.rect = Rect(cursor, barY, cursor + w, barY + L.barH)
            seg.visible = true
            lastVisibleSeg = seg
            cursor = cursor + w
            if visibleIdx < visibleCount then cursor = cursor + 1 end
        else
            seg.visible = false
        end
    end

    -- Absorb rounding remainder into the last visible segment
    local targetEnd = barX + scaledW + totalGaps
    if lastVisibleSeg and cursor < targetEnd then
        local r = lastVisibleSeg.rect
        lastVisibleSeg.rect = Rect(r.lower.x, barY, r.upper.x + (targetEnd - cursor), barY + L.barH)
    end

    -- Depletion zone and surplus: only in full mode
    if hasRespawn then
        local targetMarkX = barX + math.floor(L.barW * math.min(1.0, state.targetPct))
        local gapCursor = cursor + (visibleCount > 0 and 1 or 0)
        local depletionX = math.max(targetMarkX, gapCursor)
        if state.targetPct < 1.0 and depletionX < barX + L.barW then
            ui.depletionZone.rect = Rect(depletionX, barY, barX + L.barW, barY + L.barH)
            ui.depletionZone.visible = true
        else
            ui.depletionZone.visible = false
        end

        local surplus = state.displayTotal - targetAmount
        if surplus > 0 then
            ui.surplusLabel.caption = "+" .. formatResources(math.floor(surplus))
        else
            ui.surplusLabel.caption = ""
        end
    else
        ui.depletionZone.visible = false
        ui.surplusLabel.caption = ""
    end

    -- Col 2, Row 2: Resource amount or "No resources found"
    local displayInt = math.floor(state.displayTotal + 0.5)
    if displayInt > 0 then
        ui.resourceLabel.caption = formatResources(displayInt)
        ui.resourceLabel.visible = true
        ui.emptyLabel.visible = false
    else
        ui.resourceLabel.visible = false
        ui.surplusLabel.caption = ""
        -- Flash the empty label via sine wave on alpha
        ui.flashTimer = ui.flashTimer + timeStep
        local flash = 0.5 + 0.5 * math.sin(ui.flashTimer * 3.0)
        ui.emptyLabel.color = ColorARGB(flash, 0.9, 0.4, 0.4)
        ui.emptyLabel.visible = true
    end

    -- Col 3: Percentage (only in full mode)
    if hasRespawn then
        local targetRatio = targetAmount > 0 and (state.displayTotal / targetAmount) or 0
        local pct = math.floor(targetRatio * 100 + 0.5)
        ui.pctLabel.caption = string.format("%d%%", pct)
        if targetRatio >= 1.0 then
            ui.pctLabel.color = ColorRGB(0.3, 0.8, 0.3)
        elseif targetRatio <= 0.0 then
            ui.pctLabel.color = ColorRGB(1.0, 0.2, 0.2)
        elseif targetRatio < 0.25 then
            local t = targetRatio / 0.25
            ui.pctLabel.color = ColorRGB(1.0, 0.2 + 0.65 * t, 0.2)
        elseif targetRatio < 0.5 then
            local t = (targetRatio - 0.25) / 0.25
            ui.pctLabel.color = ColorRGB(
                1.0 + (0.7 - 1.0) * t,
                0.85 + (0.7 - 0.85) * t,
                0.2 + (0.7 - 0.2) * t)
        else
            ui.pctLabel.color = ColorRGB(0.7, 0.7, 0.7)
        end
    else
        ui.pctLabel.caption = ""
    end

    if not ui.visible then
        ui.container.visible = true
        ui.visible = true
    end
end



function initialize(...)
    if RespawnHud.initialize then return RespawnHud.initialize(...) end
end
function getUpdateInterval(...)
    if RespawnHud.getUpdateInterval then return RespawnHud.getUpdateInterval(...) end
end
function updateClient(...)
    if RespawnHud.updateClient then return RespawnHud.updateClient(...) end
end

return RespawnHud
