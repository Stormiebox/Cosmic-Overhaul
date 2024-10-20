include ("moddata")

local mcm_SalvageCommand_buildUI_original = SalvageCommand.buildUI
function SalvageCommand:buildUI(...)
    local ui = mcm_SalvageCommand_buildUI_original(self, ...)
    local originalRefresh = ui.refresh
    ui.refresh = function(self, ...)
        if originalRefresh then
            originalRefresh(self, ...)
        end
        local saveData = ReadModData('NyrinsMapCommandMod.salvageCommand')
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

local mcm_SalvageCommand_onStart_original = SalvageCommand.onStart
function SalvageCommand:onStart(...)
    mcm_SalvageCommand_onStart_original(self, ...)
    local saveData = CreateModData('NyrinsMapCommandMod.salvageCommand')
    saveData.safeMode = self.config.safeMode
    saveData.immediateDelivery = self.config.immediateDelivery
    saveData:save()
end