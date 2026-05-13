package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/player/background/simulation/?.lua"

include("moddata")

local mcm_MineCommand_buildUI_original = MineCommand.buildUI
function MineCommand:buildUI(...)
    local ui = mcm_MineCommand_buildUI_original(self, ...)
    local originalRefresh = ui.refresh
    ui.refresh = function(self, ...)
        if originalRefresh then
            originalRefresh(self, ...)
        end
        local saveData = ReadModData('NyrinsMapCommandMod.mineCommand')
        if saveData then
            if ui.immediateDeliveryCheckBox then
                ui.immediateDeliveryCheckBox:setCheckedNoCallback(saveData.immediateDelivery)
            end
            if ui.safeModeCheckBox then
                ui.safeModeCheckBox:setCheckedNoCallback(saveData.safeMode)
            end
        end
    end
    return ui
end

local mcm_MineCommand_onStart_original = MineCommand.onStart
function MineCommand:onStart(...)
    mcm_MineCommand_onStart_original(self, ...)
    local saveData = CreateModData('NyrinsMapCommandMod.mineCommand')
    saveData.safeMode = self.config.safeMode
    saveData.immediateDelivery = self.config.immediateDelivery
    saveData:save()
end

local mcm_MineCommand_getAreaSize_original = MineCommand.getAreaSize
function MineCommand:getAreaSize(...)
    local area = mcm_MineCommand_getAreaSize_original and mcm_MineCommand_getAreaSize_original(self, ...) or
        { x = 30, y = 30 }
    local staticBonus = 0
    return { x = area.x + staticBonus, y = area.y + staticBonus }
end
