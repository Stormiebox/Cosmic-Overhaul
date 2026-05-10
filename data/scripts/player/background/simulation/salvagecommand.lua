include("moddata")
local CosmicOverhaulConfig = include("cosmicoverhaulconfig")
include("randomext")

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

local mcm_SalvageCommand_getAreaSize_original = SalvageCommand.getAreaSize
function SalvageCommand:getAreaSize(...)
    local area = mcm_SalvageCommand_getAreaSize_original and mcm_SalvageCommand_getAreaSize_original(self, ...) or
        { x = 30, y = 30 }
    local cfg = CosmicOverhaulConfig and CosmicOverhaulConfig.get and CosmicOverhaulConfig.get() or nil
    local bonus = (cfg and cfg.extraLongRangeSalvageBonus) or 0
    return { x = area.x + bonus, y = area.y + bonus }
end

local mcm_SalvageCommand_generateItems_original = SalvageCommand.generateItems
function SalvageCommand:generateItems(amount)
    local cfg = CosmicOverhaulConfig and CosmicOverhaulConfig.get and CosmicOverhaulConfig.get() or nil
    if not (cfg and cfg.enableExoticLegendarySalvage) then
        return mcm_SalvageCommand_generateItems_original(self, amount)
    end

    if not mcm_SalvageCommand_generateItems_original then
        return {}
    end

    local items = mcm_SalvageCommand_generateItems_original(self, amount) or {}
    items.turrets = items.turrets or {}
    items.subsystems = items.subsystems or {}

    local rarityRoll = {
        { value = RarityType.Legendary,   weight = 5 },
        { value = RarityType.Exotic,      weight = 7 },
        { value = RarityType.Exceptional, weight = 14 },
        { value = RarityType.Rare,        weight = 19 },
        { value = RarityType.Uncommon,    weight = 26 },
        { value = RarityType.Common,      weight = 29 },
    }

    local function rollRarity(r)
        local total = 0
        for _, entry in pairs(rarityRoll) do total = total + entry.weight end
        local pick = r:getInt(1, total)
        local acc = 0
        for _, entry in pairs(rarityRoll) do
            acc = acc + entry.weight
            if pick <= acc then
                return entry.value
            end
        end
        return RarityType.Common
    end

    local function upgradeListRarities(list)
        for _, item in pairs(list or {}) do
            if item then
                item.rarity = rollRarity(random())
            end
        end
    end

    upgradeListRarities(items.turrets)
    upgradeListRarities(items.subsystems)

    return items
end
