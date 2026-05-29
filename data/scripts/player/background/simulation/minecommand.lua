package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/player/background/simulation/?.lua"

local PlayerSettings = include("cosmicvaultplayersettings")
local CaptainClass = include("captainclass")
local CaptainUtility = include("captainutility")

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
function MineCommand:getAreaSize(ownerIndex, shipName)
    local a1, a2, a3
    if mcm_MineCommand_getAreaSize_original then
        a1, a2, a3 = mcm_MineCommand_getAreaSize_original(self, ownerIndex, shipName)
    end
    if not a1 then a1 = { x = 15, y = 15 } end

    local ship = (ownerIndex and ownerIndex > 0 and shipName) and ShipDatabaseEntry(ownerIndex, shipName)
    local bonus = 0

    if ship then
        local captain = ship:getCaptain()
        if captain then
            if captain:hasClass(CaptainClass.Miner) then
                bonus = bonus + 15
            elseif captain:hasClass(CaptainClass.Scavenger) then
                bonus = bonus + 10
            end

            for _, perk in pairs({captain:getPerks()}) do
                if perk == CaptainUtility.PerkType.Navigator then
                    bonus = bonus + 5
                end
            end
        end
    end

    local squareBase = math.floor(a1.x + bonus)
    local longerEdge = math.floor((29 / 17) * squareBase)
    local shorterEdge = math.floor((11 / 17) * squareBase)

    return { x = squareBase, y = squareBase },
           { x = longerEdge, y = shorterEdge },
           { x = shorterEdge, y = longerEdge }
end
