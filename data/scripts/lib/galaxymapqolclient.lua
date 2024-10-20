-- Just extra QoL for the QoL mod, namely saving some settings and restoring them.

if GalaxyMapQoL and onClient() then

include('moddata')

local mcm_GalaxyMapQoL_onLockRadarCheckBoxChecked_original = GalaxyMapQoL.onLockRadarCheckBoxChecked

local mcm_GalaxyMapQoL_initUI_original = GalaxyMapQoL.initUI
function GalaxyMapQoL.initUI(...)
    if mcm_GalaxyMapQoL_initUI_original then
        mcm_GalaxyMapQoL_initUI_original(...)
    end

    local saveData = ReadModData('NyrinsMapCommandMod.galaxyMapQoL')
    if saveData
        and lockRadarCheckBox and mcm_GalaxyMapQoL_onLockRadarCheckBoxChecked_original
        and lockRadarCheckBox.checked ~= saveData.lockRadarCheckBoxChecked
    then
        lockRadarCheckBox:setCheckedNoCallback(saveData.lockRadarCheckBoxChecked)
        if Player() and Player().craft then
            mcm_GalaxyMapQoL_onLockRadarCheckBoxChecked_original()
        end
    end
end

function GalaxyMapQoL.onLockRadarCheckBoxChecked(...)
    if not mcm_GalaxyMapQoL_onLockRadarCheckBoxChecked_original or not lockRadarCheckBox then
        return
    end
    mcm_GalaxyMapQoL_onLockRadarCheckBoxChecked_original(...)
    local saveData = CreateModData('NyrinsMapCommandMod.galaxyMapQol')
    if saveData.lockRadarCheckBoxChecked ~= lockRadarCheckBox.checked then
        saveData.lockRadarCheckBoxChecked = lockRadarCheckBox.checked
        saveData:save()
    end
end

end