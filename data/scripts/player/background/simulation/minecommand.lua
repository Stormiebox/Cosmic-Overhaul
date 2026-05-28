package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/player/background/simulation/?.lua"

local PlayerSettings = include("cosmicvaultplayersettings")

local mcm_MineCommand_buildUI_original = MineCommand.buildUI
function MineCommand:buildUI(...)
    local ui = mcm_MineCommand_buildUI_original(self, ...)
    local originalRefresh = ui.refresh
    ui.refresh = function(self, ...)
        if originalRefresh then
            originalRefresh(self, ...)
        end
        if PlayerSettings then
            local player = Player()
            if ui.immediateDeliveryCheckBox then
                ui.immediateDeliveryCheckBox:setCheckedNoCallback(PlayerSettings.get(player, "CosmicOverhaul", "mine_immediateDelivery", false))
            end
            if ui.safeModeCheckBox then
                ui.safeModeCheckBox:setCheckedNoCallback(PlayerSettings.get(player, "CosmicOverhaul", "mine_safeMode", false))
            end
        end
    end
    return ui
end

local mcm_MineCommand_onStart_original = MineCommand.onStart
function MineCommand:onStart(...)
    mcm_MineCommand_onStart_original(self, ...)
    if PlayerSettings then
        local player = Player()
        PlayerSettings.set(player, "CosmicOverhaul", "mine_safeMode", self.config.safeMode)
        PlayerSettings.set(player, "CosmicOverhaul", "mine_immediateDelivery", self.config.immediateDelivery)
    end
end

local mcm_MineCommand_getAreaSize_original = MineCommand.getAreaSize
function MineCommand:getAreaSize(...)
    local a1, a2, a3
    if mcm_MineCommand_getAreaSize_original then
        a1, a2, a3 = mcm_MineCommand_getAreaSize_original(self, ...)
    end
    if not a1 then a1 = { x = 15, y = 15 } end

    local staticBonus = 0
    local squareBase = math.floor(a1.x + staticBonus)
    local longerEdge = math.floor((29 / 17) * squareBase)
    local shorterEdge = math.floor((11 / 17) * squareBase)

    return { x = squareBase, y = squareBase },
           { x = longerEdge, y = shorterEdge },
           { x = shorterEdge, y = longerEdge }
end
