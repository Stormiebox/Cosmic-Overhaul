package.path = package.path .. ";data/scripts/lib/?.lua"
include("callable")
include("utility")

-- namespace ResourceDisplay
ResourceDisplay = {}

local red_config = {
    EnableHUD = true,
    PositionX = 5,
    PositionY = 28,
    ShowCargoCapacity = true,
    ShowInventoryCapacity = true,
    InventoryCapacityShowBothAlways = false,
    ShowAllianceResources = true,
    BackgroundOpacity = 0.0,
    CompactNumbers = false
}

local red_rect
local red_moveUI = false
local red_dragged = nil

if onClient() then
    function ResourceDisplay.initialize()
        -- Load settings natively stored on the player database
        local p = Player()
        local enabled = p:getValue("CO_RD_Enabled")
        if enabled ~= nil then red_config.EnableHUD = enabled end
        red_config.PositionX = p:getValue("CO_RD_PosX") or 5
        red_config.PositionY = p:getValue("CO_RD_PosY") or 28

        local cargo = p:getValue("CO_RD_Cargo")
        if cargo ~= nil then red_config.ShowCargoCapacity = cargo end
        local inv = p:getValue("CO_RD_Inv")
        if inv ~= nil then red_config.ShowInventoryCapacity = inv end
        local invBoth = p:getValue("CO_RD_InvBoth")
        if invBoth ~= nil then red_config.InventoryCapacityShowBothAlways = invBoth end
        local alli = p:getValue("CO_RD_Alli")
        if alli ~= nil then red_config.ShowAllianceResources = alli end

        local bgOp = p:getValue("CO_RD_BgOp")
        if bgOp ~= nil then red_config.BackgroundOpacity = bgOp end
        local cmpNum = p:getValue("CO_RD_CmpNum")
        if cmpNum ~= nil then red_config.CompactNumbers = cmpNum end

        red_rect = Rect(
            red_config.PositionX, red_config.PositionY,
            red_config.PositionX + 290, red_config.PositionY + 180
        )

        -- Native Avorion UI window generation
        local tab = PlayerWindow():createTab("Resources Display"%_t, "data/textures/icons/ResourceDisplayTab.png",
        "Resources Display"%_t)
        local lister = UIVerticalLister(Rect(tab.size), 10, 0)

        local checkBoxEnable = tab:createCheckBox(lister:placeRight(vec2(lister.inner.width, 25)), "Enable Resource Display HUD"%_t, "onToggleEnableHUD")
        checkBoxEnable.captionLeft = false
        checkBoxEnable:setCheckedNoCallback(red_config.EnableHUD)

        local row1 = lister:placeRight(vec2(lister.inner.width, 25))
        local split = UIVerticalSplitter(row1, 10, 0, 0.5)

        local checkBoxMovement = tab:createCheckBox(split.left, "Enable UI movement"%_t, "onToggleMovement")
        checkBoxMovement.captionLeft = false
        local btn = tab:createButton(split.right, "Reset UI position"%_t, "onResetPosition")

        local checkBoxCargo = tab:createCheckBox(lister:placeRight(vec2(lister.inner.width, 25)), "Show current ship cargo capacity"%_t, "onToggleCargo")
        checkBoxCargo.captionLeft = false
        checkBoxCargo:setCheckedNoCallback(red_config.ShowCargoCapacity)

        local checkBoxInv = tab:createCheckBox(lister:placeRight(vec2(lister.inner.width, 25)), "Show currently used and total inventory slots"%_t, "onToggleInventory")
        checkBoxInv.captionLeft = false
        checkBoxInv:setCheckedNoCallback(red_config.ShowInventoryCapacity)

        local checkBoxInvBoth = tab:createCheckBox(lister:placeRight(vec2(lister.inner.width, 25)), "Show inventory capacity for alliance/ship at the same time"%_t, "onToggleInventoryBoth")
        checkBoxInvBoth.captionLeft = false
        checkBoxInvBoth:setCheckedNoCallback(red_config.InventoryCapacityShowBothAlways)

        local checkBoxAlli = tab:createCheckBox(lister:placeRight(vec2(lister.inner.width, 25)), "Show alliance resources when piloting an alliance ship"%_t, "onToggleAlliance")
        checkBoxAlli.captionLeft = false
        checkBoxAlli:setCheckedNoCallback(red_config.ShowAllianceResources)

        local checkBoxCompact = tab:createCheckBox(lister:placeRight(vec2(lister.inner.width, 25)), "Compact number formatting (e.g. 1.5M)"%_t, "onToggleCompactNumbers")
        checkBoxCompact.captionLeft = false
        checkBoxCompact:setCheckedNoCallback(red_config.CompactNumbers)

        local sliderRect = lister:placeRight(vec2(lister.inner.width, 25))
        local sliderSplit = UIVerticalSplitter(sliderRect, 10, 0, 0.5)
        tab:createLabel(sliderSplit.left, "Background Opacity (Min: 0.0, Max: 1.0)"%_t, 14)
        local sliderOpacity = tab:createSlider(sliderSplit.right, 0.0, 1.0, 20, "", "onSliderOpacity")
        sliderOpacity:setValueNoCallback(red_config.BackgroundOpacity)

        -- Hook into the native HUD rendering flow
        Player():registerCallback("onPreRenderHud", "onPreRenderHud")
    end

    function ResourceDisplay.getUpdateInterval()
        return red_moveUI and 0 or 1
    end

    function ResourceDisplay.updateClient(timeStep)
        local mouse, isMouseDown, saveNewPosition
        if red_moveUI then
            if Player().state == PlayerStateType.Fly then
                mouse = Mouse()
                isMouseDown = mouse:mouseDown(MouseButton.Left)
            elseif red_dragged then
                saveNewPosition = true
            end
        else
            saveNewPosition = true
        end

        if isMouseDown and not red_dragged then
            if mouse.position.x >= red_rect.lower.x and mouse.position.x <= red_rect.upper.x
                and mouse.position.y >= red_rect.lower.y and mouse.position.y <= red_rect.upper.y then
                red_dragged = {
                    offsetX = mouse.position.x - red_rect.lower.x,
                    offsetY = mouse.position.y - red_rect.lower.y
                }
            end
        end

        if red_dragged then
            local x = mouse.position.x - red_dragged.offsetX
            local y = mouse.position.y - red_dragged.offsetY
            red_rect = Rect(x, y, x + red_rect.width, y + red_rect.height)
            if mouse:mouseUp(MouseButton.Left) then
                saveNewPosition = true
            end
            if saveNewPosition then
                saveNewPosition = false
                red_config.PositionX = x
                red_config.PositionY = y
                red_dragged = nil
                invokeServerFunction("savePosition", x, y)
            end
        end
    end

    function ResourceDisplay.onToggleMovement(checkbox, value) red_moveUI = value end
    function ResourceDisplay.onToggleEnableHUD(_, state) red_config.EnableHUD = state; invokeServerFunction("saveSetting", "CO_RD_Enabled", state) end
    function ResourceDisplay.onToggleCargo(_, state) red_config.ShowCargoCapacity = state; invokeServerFunction("saveSetting", "CO_RD_Cargo", state) end
    function ResourceDisplay.onToggleInventory(_, state) red_config.ShowInventoryCapacity = state; invokeServerFunction("saveSetting", "CO_RD_Inv", state) end
    function ResourceDisplay.onToggleInventoryBoth(_, state) red_config.InventoryCapacityShowBothAlways = state; invokeServerFunction("saveSetting", "CO_RD_InvBoth", state) end
    function ResourceDisplay.onToggleAlliance(_, state) red_config.ShowAllianceResources = state; invokeServerFunction("saveSetting", "CO_RD_Alli", state) end
    function ResourceDisplay.onToggleCompactNumbers(_, state) red_config.CompactNumbers = state; invokeServerFunction("saveSetting", "CO_RD_CmpNum", state) end
    function ResourceDisplay.onSliderOpacity(slider) red_config.BackgroundOpacity = slider.value; invokeServerFunction("saveSetting", "CO_RD_BgOp", slider.value) end

    function ResourceDisplay.onResetPosition()
        local x, y = 5, 28
        red_rect = Rect(x, y, x + 290, y + 180)
        red_config.PositionX = x; red_config.PositionY = y
        invokeServerFunction("savePosition", x, y)
    end

    function ResourceDisplay.onPreRenderHud(state)
        if not red_config.EnableHUD then return end
        if state ~= PlayerStateType.Fly then return end

        local player = Player()
        local faction = player
        local prefix = ""
        if player.craft and player.craft.allianceOwned then
            faction = Alliance()
            prefix = "[A]  /* Alliance resource prefix */"%_t
        end

        local x, x2, y = red_rect.lower.x, red_rect.upper.x, red_rect.lower.y

        local function formatValue(num)
            if not red_config.CompactNumbers then return createMonetaryString(num) end
            if num >= 1000000000000 then return string.format("%.1fT", num / 1000000000000)
            elseif num >= 1000000000 then return string.format("%.1fB", num / 1000000000)
            elseif num >= 1000000 then return string.format("%.1fM", num / 1000000)
            elseif num >= 1000 then return string.format("%.1fK", num / 1000)
            else return createMonetaryString(num) end
        end

        -- Calculate how much height the background box needs
        local numLines = 0
        if not faction.infiniteResources then
            numLines = numLines + NumMaterials() + 1
        end
        if red_config.ShowInventoryCapacity then
            numLines = numLines + 1
            if red_config.InventoryCapacityShowBothAlways and player.alliance then numLines = numLines + 1 end
        end
        if red_config.ShowCargoCapacity then
            numLines = numLines + 1
        end
        if red_config.BackgroundOpacity > 0 and numLines > 0 then
            drawRect(Rect(x - 5, y - 2, x2 + 5, y + (numLines * 18)), ColorARGB(red_config.BackgroundOpacity, 0, 0, 0))
        end

        if not faction.infiniteResources then
            local matFaction = (not red_config.ShowAllianceResources and player) or faction
            local matPrefix = (not red_config.ShowAllianceResources and "") or prefix
            for i, amount in ipairs({matFaction:getResources()}) do
                local material = Material(i-1)
                drawTextRect(matPrefix..material.name, Rect(x, y, x2, y + 16), -1, -1, material.color, 15, 0, 0, 2)
                drawTextRect(formatValue(amount), Rect(x, y, x2, y + 16), 1, -1, material.color, 15, 0, 0, 2)
                y = y + 18
            end
            drawTextRect(matPrefix.."Credits"%_t, Rect(x, y, x2, y + 16), -1, -1, ColorRGB(1, 1, 1), 15, 0, 0, 2)
            drawTextRect("¢"..formatValue(matFaction.money), Rect(x, y, x2, y + 16), 1, -1, ColorRGB(1, 1, 1), 15, 0, 0, 2)
            y = y + 18
        end

        if red_config.ShowInventoryCapacity then
            local invFaction = (red_config.InventoryCapacityShowBothAlways and player) or faction
            local invPrefix = (red_config.InventoryCapacityShowBothAlways and "") or prefix
            local inv = invFaction:getInventory()
            local color = ColorRGB(0.8, 0.8, 0.8)
            drawTextRect(invPrefix.."Inventory Slots"%_t, Rect(x, y, x2, y + 16), -1, -1, color, 15, 0, 0, 2)
            drawTextRect(inv.occupiedSlots.."/"..inv.maxSlots, Rect(x, y, x2, y + 16), 1, -1, color, 15, 0, 0, 2)
            y = y + 18
            if red_config.InventoryCapacityShowBothAlways and player.alliance then
                inv = player.alliance:getInventory()
                drawTextRect("[A]  /* Alliance resource prefix */"%_t.."Inventory Slots"%_t, Rect(x, y, x2, y + 16), -1, -1, color, 15, 0, 0, 2)
                drawTextRect(inv.occupiedSlots.."/"..inv.maxSlots, Rect(x, y, x2, y + 16), 1, -1, color, 15, 0, 0, 2)
                y = y + 18
            end
        end

        if red_config.ShowCargoCapacity then
            local ship = getPlayerCraft()
            local color = ColorRGB(0.8, 0.8, 0.8)
            drawTextRect("Cargo Hold"%_t, Rect(x, y, x2, y + 16), -1, -1, color, 15, 0, 0, 2)
            if ship and ship.maxCargoSpace then
                drawTextRect(math.ceil(ship.occupiedCargoSpace).."/"..math.floor(ship.maxCargoSpace), Rect(x, y, x2, y + 16), 1, -1, color, 15, 0, 0, 2)
            else
                drawTextRect("-", Rect(x, y, x2, y + 16), 1, -1, color, 15, 0, 0, 2)
            end
        end

        if red_moveUI then drawRect(red_rect, ColorARGB(0.6, 0.4, 0.4, 0.4)) end
    end
end

-- Server-side functions to safely save UI configuration data permanently to the player's database file
function ResourceDisplay.savePosition(x, y)
    if not onServer() then return end
    local p = Player(callingPlayer)
    p:setValue("CO_RD_PosX", x)
    p:setValue("CO_RD_PosY", y)
end
callable(ResourceDisplay, "savePosition")

function ResourceDisplay.saveSetting(key, value)
    if not onServer() then return end
    local p = Player(callingPlayer)
    p:setValue(key, value)
end
callable(ResourceDisplay, "saveSetting")