package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/player/background/simulation/?.lua"

local PlayerSettings = include("cosmicvaultplayersettings")
local CosmicOverhaulConfig = include("cosmicoverhaulconfig")
local CaptainClass = include("captainclass")
local CaptainUtility = include("captainutility")
include("randomext")

local mcm_SalvageCommand_buildUI_original = SalvageCommand.buildUI
function SalvageCommand:buildUI(...)
    local ui = mcm_SalvageCommand_buildUI_original(self, ...)
    local originalRefresh = ui.refresh
    ui.refresh = function(self, ...)
        if originalRefresh then
            originalRefresh(self, ...)
        end
        if PlayerSettings then
            local player = Player()
            if ui.immediateDeliveryCheckBox then
                ui.immediateDeliveryCheckBox:setCheckedNoCallback(PlayerSettings.get(player, "CosmicOverhaul", "salvage_immediateDelivery", false))
            end
            if ui.safeModeCheckBox then
                ui.safeModeCheckBox:setCheckedNoCallback(PlayerSettings.get(player, "CosmicOverhaul", "salvage_safeMode", false))
            end
        end
    end
    return ui
end

local mcm_SalvageCommand_onStart_original = SalvageCommand.onStart
function SalvageCommand:onStart(...)
    mcm_SalvageCommand_onStart_original(self, ...)
    if PlayerSettings then
        local player = Player()
        PlayerSettings.set(player, "CosmicOverhaul", "salvage_safeMode", self.config.safeMode)
        PlayerSettings.set(player, "CosmicOverhaul", "salvage_immediateDelivery", self.config.immediateDelivery)
    end
end

local mcm_SalvageCommand_getAreaSize_original = SalvageCommand.getAreaSize
function SalvageCommand:getAreaSize(ownerIndex, shipName)
    local a1, a2, a3
    if mcm_SalvageCommand_getAreaSize_original then
        a1, a2, a3 = mcm_SalvageCommand_getAreaSize_original(self, ownerIndex, shipName)
    end
    if not a1 then a1 = { x = 15, y = 15 } end

    local ship = (ownerIndex and ownerIndex > 0 and shipName) and ShipDatabaseEntry(ownerIndex, shipName)
    local bonus = 0

    if ship then
        local captain = ship:getCaptain()
        if captain then
            if captain:hasClass(CaptainClass.Scavenger) then
                bonus = bonus + 15
            elseif captain:hasClass(CaptainClass.Miner) then
                bonus = bonus + 10
            end

            for _, perk in pairs({captain:getPerks()}) do
                if perk == CaptainUtility.PerkType.Navigator then
                    bonus = bonus + 5
                end
            end
        end
    end

    -- Cosmic Overhaul: Ensure all 3 rectangular shapes are properly returned and cleanly floored
    -- This prevents the "off by one cell" boundary UI validation error when players select the maximum edge.
    local squareBase = math.floor(a1.x + bonus)
    local longerEdge = math.floor((29 / 17) * squareBase)
    local shorterEdge = math.floor((11 / 17) * squareBase)

    return { x = squareBase, y = squareBase },
        { x = longerEdge, y = shorterEdge },
        { x = shorterEdge, y = longerEdge }
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

    -- Keep deterministic behavior consistent with vanilla prediction flow:
    -- use one stable RNG seed per command context instead of random() per item.
    local rollSeed = string.format("co_salvage_rarity_%s_%s_%s_%s",
        tostring(self.shipName or "ship"),
        tostring((self.area and self.area.lower and self.area.lower.x) or 0),
        tostring((self.area and self.area.lower and self.area.lower.y) or 0),
        tostring(amount or 0))
    local rarityRandom = Random(Seed(rollSeed))

    local function upgradeListRarities(list)
        for _, item in pairs(list or {}) do
            if item then
                item.rarity = Rarity(rollRarity(rarityRandom))
            end
        end
    end

    upgradeListRarities(items.turrets)
    upgradeListRarities(items.subsystems)

    return items
end
