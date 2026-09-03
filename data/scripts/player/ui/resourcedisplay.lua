package.path = package.path .. ";data/scripts/lib/?.lua"
include("callable")
include("utility")

-- namespace ResourceDisplay
ResourceDisplay = {}

local CosmicVaultSettingsSchema = include("cosmicvaultsettingsschema")

-- One schema entry per HUD setting: {field} is this file's own red_config key,
-- {key} is the persisted storage key (kept identical to the pre-schema raw
-- Player():setValue() key of the same name so existing installs' saved values are
-- still found -- see readSettingWithLegacyFallback below for how the transition
-- from the old unprefixed storage to the schema's prefixed one is handled without
-- resetting anyone's preferences).
local RD_MOD_ID = "CosmicOverhaul_ResourceDisplay"
local RD_SETTINGS_DEF = {
    { field = "EnableHUD",                       key = "CO_RD_Enabled", default = true,  type = "bool" },
    { field = "PositionX",                       key = "CO_RD_PosX",    default = 5,     type = "number" },
    { field = "PositionY",                       key = "CO_RD_PosY",    default = 28,    type = "number" },
    { field = "ShowCargoCapacity",                key = "CO_RD_Cargo",   default = true,  type = "bool" },
    { field = "ShowInventoryCapacity",            key = "CO_RD_Inv",     default = true,  type = "bool" },
    { field = "InventoryCapacityShowBothAlways",  key = "CO_RD_InvBoth", default = false, type = "bool" },
    { field = "ShowAllianceResources",            key = "CO_RD_Alli",    default = true,  type = "bool" },
    { field = "BackgroundOpacity",                key = "CO_RD_BgOp",    default = 0.0,   type = "number" },
    { field = "CompactNumbers",                   key = "CO_RD_CmpNum",  default = false, type = "bool" },
}
local RD_SETTINGS = CosmicVaultSettingsSchema.define(RD_MOD_ID, RD_SETTINGS_DEF)

local RD_KEY_BY_FIELD = {}
for _, entry in ipairs(RD_SETTINGS_DEF) do
    RD_KEY_BY_FIELD[entry.field] = entry.key
end

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
    -- Reads one setting client-side, checking the schema's own storage location
    -- first (where every write lands from now on), falling back to the pre-schema
    -- raw key of the same name so a returning player's saved HUD preferences don't
    -- silently reset to defaults the moment they load a version of this file that
    -- switched to CosmicVaultSettingsSchema. Both reads are the same bare,
    -- no-argument Player():getValue() call this file has always made client-side --
    -- see cosmicvaultsettingsschema.lua's own header comment for why that's trusted
    -- here despite cosmicvaultplayersettings.lua's unrelated, documented client-crash
    -- restriction (that restriction is about a different call shape; see the note).
    local function readSettingWithLegacyFallback(key, default)
        local p = Player()
        if not p then return default end
        local v = p:getValue("cv_ps_" .. RD_MOD_ID .. "_" .. key)
        if v == nil then v = p:getValue(key) end
        if v == nil then return default end
        return v
    end

    -- Updates the local HUD state instantly and persists it server-side through the
    -- schema (real key/type validation instead of the old bare string-prefix check).
    local function setLocalAndSave(field, value)
        red_config[field] = value
        local key = RD_KEY_BY_FIELD[field]
        if key then invokeServerFunction("saveSetting", key, value) end
    end

    function ResourceDisplay.initialize()
        for _, entry in ipairs(RD_SETTINGS_DEF) do
            red_config[entry.field] = readSettingWithLegacyFallback(entry.key, entry.default)
        end

        red_rect = Rect(
            red_config.PositionX, red_config.PositionY,
            red_config.PositionX + 290, red_config.PositionY + 180
        )

        -- Native Avorion UI window generation
        ResourceDisplay.tab = PlayerWindow():createTab("Resources Display"%_t, "data/textures/icons/ResourceDisplayTab.png",
        "Resources Display"%_t)
        local tab = ResourceDisplay.tab
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
    function ResourceDisplay.onToggleEnableHUD(_, state) setLocalAndSave("EnableHUD", state) end
    function ResourceDisplay.onToggleCargo(_, state) setLocalAndSave("ShowCargoCapacity", state) end
    function ResourceDisplay.onToggleInventory(_, state) setLocalAndSave("ShowInventoryCapacity", state) end
    function ResourceDisplay.onToggleInventoryBoth(_, state) setLocalAndSave("InventoryCapacityShowBothAlways", state) end
    function ResourceDisplay.onToggleAlliance(_, state) setLocalAndSave("ShowAllianceResources", state) end
    function ResourceDisplay.onToggleCompactNumbers(_, state) setLocalAndSave("CompactNumbers", state) end
    function ResourceDisplay.onSliderOpacity(slider) setLocalAndSave("BackgroundOpacity", slider.value) end

    function ResourceDisplay.onResetPosition()
        local x, y = 5, 28
        red_rect = Rect(x, y, x + 290, y + 180)
        red_config.PositionX = x; red_config.PositionY = y
        invokeServerFunction("savePosition", x, y)
    end

    -- Picks which faction's data a HUD section should read: the alliance (when this
    -- craft is alliance-owned) or the player's own personal data, according to
    -- `showAlliance`. Used by the resources block directly; the inventory block
    -- inverts its own toggle's meaning ("show both" implies "show personal here,
    -- alliance separately below") so it does NOT reuse this helper -- forcing both
    -- call sites through one signature would hide that the two toggles mean
    -- different things, not simplify anything real.
    local function pickDisplayFaction(player, allianceFaction, allianceOwned, showAlliance, prefix)
        if allianceOwned and showAlliance then
            return allianceFaction, prefix
        end
        return player, ""
    end

    function ResourceDisplay.onPreRenderHud(state)
        local ccm = include("ccm")
        if ccm then
            local cocfg = ccm.bind("Cosmic_Overhaul")
            if cocfg.isKeyComboDown("hotkeyResourceDisplay") then
                local pw = PlayerWindow()
                if pw and ResourceDisplay.tab then
                    pw:show()
                    if pw.selectTab then
                        pw:selectTab(ResourceDisplay.tab)
                    elseif pw.activateTab then
                        pw:activateTab(ResourceDisplay.tab)
                    end
                end
            end
        end

        if not red_config.EnableHUD then return end
        if state ~= PlayerStateType.Fly then return end

        local player = Player()
        local allianceOwned = player.craft and player.craft.allianceOwned
        local alliance = allianceOwned and Alliance() or nil
        local alliancePrefix = "[A]  /* Alliance resource prefix */"%_t

        local x, x2, y = red_rect.lower.x, red_rect.upper.x, red_rect.lower.y

        local function formatValue(num)
            if not red_config.CompactNumbers then return createMonetaryString(num) end
            if num >= 1000000000000 then return string.format("%.1fT", num / 1000000000000)
            elseif num >= 1000000000 then return string.format("%.1fB", num / 1000000000)
            elseif num >= 1000000 then return string.format("%.1fM", num / 1000000)
            elseif num >= 1000 then return string.format("%.1fK", num / 1000)
            else return createMonetaryString(num) end
        end

        -- craftFaction (alliance-if-owned, regardless of the display toggle below) is
        -- what the original code gated infiniteResources on -- kept separate from
        -- matFaction/matPrefix (which IS toggle-adjusted) so that gating behavior is
        -- unchanged: whether the resources block shows at all still depends on the
        -- owning craft's faction, not on which faction's numbers the toggle picks to
        -- actually display.
        local craftFaction = allianceOwned and alliance or player
        local matFaction, matPrefix = pickDisplayFaction(player, alliance, allianceOwned, red_config.ShowAllianceResources, alliancePrefix)

        -- Calculate how much height the background box needs
        local numLines = 0
        if not craftFaction.infiniteResources then
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

        if not craftFaction.infiniteResources then
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
            local invFaction = (red_config.InventoryCapacityShowBothAlways and player) or (allianceOwned and alliance) or player
            local invPrefix = (red_config.InventoryCapacityShowBothAlways and "") or (allianceOwned and alliancePrefix) or ""
            local inv = invFaction:getInventory()
            local color = ColorRGB(0.8, 0.8, 0.8)
            drawTextRect(invPrefix.."Inventory Slots"%_t, Rect(x, y, x2, y + 16), -1, -1, color, 15, 0, 0, 2)
            drawTextRect(inv.occupiedSlots.."/"..inv.maxSlots, Rect(x, y, x2, y + 16), 1, -1, color, 15, 0, 0, 2)
            y = y + 18
            if red_config.InventoryCapacityShowBothAlways and player.alliance then
                inv = player.alliance:getInventory()
                drawTextRect(alliancePrefix.."Inventory Slots"%_t, Rect(x, y, x2, y + 16), -1, -1, color, 15, 0, 0, 2)
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
    RD_SETTINGS:set(p, "CO_RD_PosX", x)
    RD_SETTINGS:set(p, "CO_RD_PosY", y)
end
callable(ResourceDisplay, "savePosition")

function ResourceDisplay.saveSetting(key, value)
    if not onServer() then return end
    local p = Player(callingPlayer)
    RD_SETTINGS:set(p, key, value) -- validates key/type against RD_SETTINGS_DEF; unknown keys are rejected and logged
end
callable(ResourceDisplay, "saveSetting")
function ResourceDisplay.onRemove()
    if Player() then Player():unregisterCallback("onPreRenderHud", "onPreRenderHud") end
end


return ResourceDisplay
