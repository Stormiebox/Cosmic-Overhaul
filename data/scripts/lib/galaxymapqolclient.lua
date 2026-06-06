package.path = package.path .. ";data/scripts/lib/?.lua"
include("utility")
include("galaxy")
local PassageMap = include("passagemap")
local SectorSpecifics = include("sectorspecifics")



local Azimuth, ConfigTemplate, Log = unpack(include("galaxymapqolinit"))
include("cosmicui_proportionalsplitter")


local function UIRectangle(parent, rect, color, layer)
    local pic = parent:createPicture(rect, "data/textures/icons/galaxymapqol/ui-filled.png")
    if pic then
        pic.color = color
        pic.isIcon = true
        if layer then pic.layer = layer end
    end
    return pic
end

local Integration = include("GalaxyMapQoLIntegration")

GalaxyMapQoL = {}

local editIconBtn, iconsFactionComboBox, showOverlayComboBox, legendRows, editIconWindow, coordinatesLabel, editIconScrollFrame, colorSelector, colorPictures, colorPicker, iconSelector, warZoneCheckBox, factionColorsCheckBox, playerIconsContainer, allianceIconsContainer, lockRadarCheckBox, highlightAllianceNotesCheckBox, allianceNotesContainer, optionsContainer

local Config, customNamespace, sectorsPlayer, sectorsAlliance, isServerUsed, isEditIconShown, iconsFactionBoxHasAlliance, iconPictures, selectedIcon, editedX, editedY, materialDistances, distToCenter, selectedColorIndex, factionColorsIsRunning, factionsColorsCache, techLevels
local factionColorsUpdated = -30
local overlays = {}
local warZoneData = {}
local icons = {"empty", "adopt", "alliance", "anchor", "bag", "bug-report", "cattle", "checkmark", "clockwise-rotation", "cog", "crew", "cross-mark", "diamonds", "domino-mask", "electric", "fighter", "look-at", "flying-flag", "halt", "health-normal", "hourglass", "inventory", "move", "round-star", "select", "shield", "trash-can", "unchecked", "vortex"}
local passageMap = PassageMap(Seed(GameSettings().seed))
local distColor = ColorRGB(1, 1, 1)
local borderColor = ColorRGB(0.5, 0.5, 0.5)
local warZoneColor = ColorRGB(1, 0.1, 0)
local bossDistances = {
  { min = 350, max = 430, name = "Boss Swoks ${num}"%_t % {num = ""}, color = ColorARGB(0.7, 1, 0, 0) },
  { min = 240, max = 340, name = "The AI"%_t, color = ColorARGB(0.7, 0, 1, 0) },
  { min = 150, max = 240, name = "Mobile Energy Lab"%_t, color = ColorARGB(0.7, 0.5, 0.5, 1) },
  { min = 150, max = 180, name = "The 4", color = ColorARGB(0.7, 1, 1, 0) }
}
local playerMapIcons = {}
local allianceMapIcons = {}
local lockedRadarBlips = {}
local specs = SectorSpecifics()
local GT112 = GameVersion() >= Version(1, 1, 2)
local galaxyMapQoL_updateClient
local delIconWindow, deleteIconsMode, delbtn1, delbtn2, delbtn3, delbtn4, delbtn5, delpic1, delpic2, delpic3, delpic4
local helpIconWindow, helpIconsMode, helpbtn1, helpbtn2, helppic1, helppic2
local dragStart, selectedArea, isDragging, dragMoveCount

function GalaxyMapQoL.initialize()
	local defaultColors = {
		ColorInt(0xffffffff):toInt(),
		ColorInt(0xffA0A0A0):toInt(),
		ColorInt(0xffff0000):toInt(),
		ColorInt(0xffFF7F00):toInt(),
		ColorInt(0xffffff00):toInt(),
		ColorInt(0xff00FF00):toInt(),
		ColorInt(0xff00FFFF):toInt(),
		ColorInt(0xff007FFF):toInt(),
		ColorInt(0xff7F00FF):toInt(),
		ColorInt(0xffFF00FF):toInt()
	}
	local configOptions = {
		["_version"] = {"1.1", comment = "Don't touch this file" },
		["playerIcons"] = {{}},
		["colors"] = {defaultColors},
		["markHazards"] = {true},
		["lockRadar"] = {false},
		["highlightAllianceNotes"] = {false},
        ["selectedOverlay"] = {0},
        ["deleteUndo"] = {{}},
	}
	local isModified
	Config, isModified = Azimuth.loadConfig("GalaxyMapQoL", configOptions, true, true)
	if isModified then
		Azimuth.saveConfig("GalaxyMapQoL", Config, configOptions, true, true)
	end
	for i = 1, 10 do
		Config.colors[i] = ColorInt(Config.colors[i])
	end

	for i = 1, #Integration do
		icons[#icons + 1] = Integration[i]
	end

    deleteUndo = Config.deleteUndo or {}

	local maxCoords = Balancing_GetMaxCoordinates()
	local beltSize = Balancing_GetMaterialBeltSize()
	local existanceThreshold = Balancing_GetMaterialExistanceThreshold()
	materialDistances = {}
	for i = 1, NumMaterials() - 1 do
		local beltRadius = Balancing_GetMaterialBeltRadius(i)
		materialDistances[i] = (beltRadius + beltSize * (1 + existanceThreshold)) * maxCoords
	end

	techLevels = {}
	local maxTech = Balancing_GetTechLevel(0, 0)
	if maxTech >= 5 then
		for i = maxTech - 5, 0, -5 do
			techLevels[i] = Balancing_GetSectorByTechLevel(i)
		end
	end

	GalaxyMapQoL.initUI()

	local player = Player()
	player:registerCallback("onShowGalaxyMap", "galaxyMapQoL_onShowGalaxyMap")
	player:registerCallback("onHideGalaxyMap", "galaxyMapQoL_onHideGalaxyMap")
	player:registerCallback("onSelectMapCoordinates", "galaxyMapQoL_onEditIconBtnPressed")
	player:registerCallback("onMapRenderAfterLayers", "galaxyMapQoL_onMapRenderAfterLayers")
    player:registerCallback("onGalaxyMapMouseDown", "galaxyMapQoL_onGalaxyMapMouseDown")
    player:registerCallback("onGalaxyMapMouseButtonEvent", "galaxyMapQoL_onGalaxyMapMouseButtonEvent")
    player:registerCallback("onGalaxyMapMouseMoveEvent", "galaxyMapQoL_onGalaxyMapMouseMove")

	if not customNamespace then
		invokeServerFunction("sync", true)
	end
end

function GalaxyMapQoL.initUI()
	local map = GalaxyMap()

	playerIconsContainer = map:createContainer()
	allianceIconsContainer = map:createContainer()
	allianceIconsContainer.visible = false
	allianceNotesContainer = map:createContainer()

	local container = map:createContainer()
	editIconBtn = container:createButton(Rect(460, 50, 660, 80), "Edit icon"%_t, "galaxyMapQoL_onEditIconBtnPressed")

	iconsFactionComboBox = container:createComboBox(Rect(460, 90, 660, 115), "galaxyMapQoL_onIconsFactionBoxChanged")
	iconsFactionComboBox:addEntry("Hide icons"%_t)
	iconsFactionComboBox:addEntry("Player"%_t)
	iconsFactionComboBox:setSelectedIndexNoCallback(1)

	showOverlayComboBox = container:createComboBox(Rect(460, 125, 660, 150), "galaxyMapQoL_onShowOverlayBoxChanged")
	showOverlayComboBox:addEntry("Show overlay"%_t)
	GalaxyMapQoL.addOverlay("Resources", "Resources"%_t, "onResourcesOverlaySelected", "onResourcesOverlayRendered")
	GalaxyMapQoL.addOverlay("TechLevels", "Tech Level"%_t, "onTechLevelsOverlaySelected", "onTechLevelsOverlayRendered")
	GalaxyMapQoL.addOverlay("Bosses", "Bosses"%_t, "onBossesOverlaySelected", "onBossesOverlayRendered")
    showOverlayComboBox:setSelectedIndexNoCallback(Config.selectedOverlay or 0)

	local lister = UIVerticalLister(Rect(670, 50, 770, 50), 5, 0)
	local partitions, picture
	legendRows = {}
	for i = 1, #materialDistances do
		partitions = CosmicUIVerticalProportionalSplitter(lister:placeCenter(vec2(lister.inner.width, 18)), 5, 0, {18, 0.5})
		picture = container:createPicture(partitions[1], "data/textures/icons/galaxymapqol/ui-filled.png")
		local label = container:createLabel(partitions[2].lower, "", 12)
		picture.visible = false
		label.visible = false
		legendRows[i] = { picture = picture, label = label }
	end
    selectedIcon = 1

	editIconWindow = map:createWindow(Rect(709, 50, 1009, 340))
	editIconWindow.visible = false
	partitions = CosmicUIHorizontalProportionalSplitter(Rect(editIconWindow.size), 10, 10, {15, 20, 24, 0.5, 25})

	coordinatesLabel = editIconWindow:createLabel(partitions[1], "", 14)
	coordinatesLabel.centered = true

	local partition = partitions[2]
	local offset = (partition.width - 275) / 2
	local vPartitions = UIVerticalMultiSplitter(Rect(partition.lower.x + offset, partition.lower.y, partition.upper.x - offset, partition.upper.y), 5, 0, 10)
	colorPictures = {}
	local color
	for i = 0, 10 do
		partition = vPartitions:partition(i)
		UIRectangle(editIconWindow, Rect(partition.lower + vec2(1, 1), partition.upper - vec2(1, 1)), ColorRGB(0, 0, 0))
		picture = editIconWindow:createPicture(Rect(partition.lower + vec2(2, 2), partition.upper - vec2(2, 2)), "data/textures/icons/galaxymapqol/ui-filled.png")
		if i == 0 then
			color = ColorRGB(0, 0.5, 0)
		else
			color = Config.colors[i]
		end
		picture.color = color
		colorPictures[i+1] = { picture = picture, color = color }
	end
	partition = vPartitions:partition(0)
	colorSelector = UIRectangle(editIconWindow, Rect(partition.lower - vec2(1, 1), partition.upper + vec2(1, 1)), ColorRGB(1, 1, 1), 2)
	selectedColorIndex = 1

	-- removed edit button

	partition = partitions[4]
	editIconScrollFrame = editIconWindow:createScrollFrame(partition)
	lister = UIVerticalLister(Rect(vec2(1, 1), vec2(partition.width - 21, partition.height)), 0, 2)
	local rows = math.ceil(#icons / 8)
	local splitter, picture
	iconPictures = {}
	local i = 1
	for y = 1, rows do
		splitter = UIVerticalMultiSplitter(lister:placeCenter(vec2(lister.inner.width, 32)), 2, 0, 7)
		splitter.marginBottom = 2
		for x = 0, 7 do
			partition = splitter:partition(x)
			picture = editIconScrollFrame:createPicture(Rect(partition.lower + vec2(2, 2), partition.upper - vec2(2, 2)), "data/textures/icons/galaxymapqol/"..icons[i]..".png")
			picture.flipped = true
			iconPictures[i] = picture
			i = i + 1
			if i > #icons then break end
		end
		if i > #icons then break end
	end
	iconSelector = UIRectangle(editIconScrollFrame, Rect(), ColorRGB(1, 1, 1), 2)
	iconSelector.rect = Rect(iconPictures[1].lower - vec2(3, 3), iconPictures[1].upper + vec2(3, 3))

	splitter = UIVerticalSplitter(partitions[5], 10, 0, 0.5)
	btn = editIconWindow:createButton(splitter.left, "Apply"%_t, "galaxyMapQoL_onEditIconApplyBtnPressed")
	btn.maxTextSize = 14
	btn = editIconWindow:createButton(splitter.right, "Cancel"%_t, "galaxyMapQoL_onEditIconCancelBtnPressed")
	btn.maxTextSize = 14

	if GameVersion() >= Version("2.0") then
		local btn = container:createButton(Rect(10, 200, 50, 240), "qol", "onShowOptionsBtnPressed")
		btn.tooltip = "Show Galaxy Map QoL options"%_t

		optionsContainer = map:createContainer()
		optionsContainer.visible = false
		local rowY = 50

		warZoneCheckBox = optionsContainer:createCheckBox(Rect(150, rowY, 220, rowY + 30), "", "onWarZoneCheckBoxChecked")
		warZoneCheckBox.captionLeft = false
		warZoneCheckBox.tooltip = "Marks Hazard Zone sectors with a red rectangle in the bottom right corner"%_t
		warZoneCheckBox:setCheckedNoCallback(Config.markHazards == true)
		local picture = optionsContainer:createPicture(Rect(190, rowY, 220, rowY + 30), "data/textures/icons/hazard-sign.png")
		picture.isIcon = true
		rowY = rowY + 40

		lockRadarCheckBox = optionsContainer:createCheckBox(Rect(150, rowY, 220, rowY + 30), "", "onLockRadarCheckBoxChecked")
		lockRadarCheckBox.captionLeft = false
		lockRadarCheckBox.tooltip = "Makes radar blips always visible"%_t
		lockRadarCheckBox:setCheckedNoCallback(Config.lockRadar == true)
		local picture = optionsContainer:createPicture(Rect(190, rowY, 220, rowY + 30), "data/textures/icons/movement-sensor.png")
		picture.isIcon = true
		rowY = rowY + 40

		highlightAllianceNotesCheckBox = optionsContainer:createCheckBox(Rect(150, rowY, 220, rowY + 30), "", "onHighlightAllianceNotesChecked")
		highlightAllianceNotesCheckBox.captionLeft = false
		highlightAllianceNotesCheckBox.tooltip = "Highlight alliance notes with magenta at the bottom right corner"%_t
		highlightAllianceNotesCheckBox:setCheckedNoCallback(Config.highlightAllianceNotes == true)
		local picture = optionsContainer:createPicture(Rect(190, rowY, 220, rowY + 30), "data/textures/icons/galaxymapqol/ui-highlight-alliance-notes.png")
		picture.isIcon = true
	else
		local rowY = 200
		if not customNamespace then
			warZoneCheckBox = container:createCheckBox(Rect(150, rowY, 450, rowY + 20), "Hazard Zones"%_t, "onWarZoneCheckBoxChecked")
			warZoneCheckBox.captionLeft = false
			warZoneCheckBox.tooltip = "Marks Hazard Zone sectors with a red rectangle in the bottom right corner"%_t
			warZoneCheckBox:setCheckedNoCallback(Config.markHazards == true)
			rowY = rowY + 30
		end

		factionColorsCheckBox = container:createCheckBox(Rect(150, rowY, 450, rowY + 20), "Faction Colors"%_t, "galaxyMapQoL_onFactionColorsCheckBoxChecked")
		factionColorsCheckBox.captionLeft = false
		factionColorsCheckBox.tooltip = "EXPERIMENTAL: Highlights faction territories with various colors allowing to distinguish them from other nearby factions.\nFactions won't have unique colors!"%_t
		rowY = rowY + 30

		lockRadarCheckBox = container:createCheckBox(Rect(150, rowY, 450, rowY + 20), "Lock Radar Signatures"%_t, "onLockRadarCheckBoxChecked")
		lockRadarCheckBox.captionLeft = false
		lockRadarCheckBox.tooltip = "Makes radar blips always visible"%_t
		lockRadarCheckBox:setCheckedNoCallback(Config.lockRadar == true)
		rowY = rowY + 30

		highlightAllianceNotesCheckBox = container:createCheckBox(Rect(150, rowY, 450, rowY + 20), "Highlight Alliance Notes"%_t, "onHighlightAllianceNotesChecked")
		highlightAllianceNotesCheckBox.captionLeft = false
		highlightAllianceNotesCheckBox.tooltip = "Highlight alliance notes with magenta at the bottom right corner"%_t
		highlightAllianceNotesCheckBox:setCheckedNoCallback(Config.highlightAllianceNotes == true)
	end

	if not customNamespace then
		-- removed colorPicker
	else
		-- removed colorPicker
	end

	delIconWindow = map:createWindow(Rect(1009, 100, 1048, 290))
	delIconWindow.visible = false

    local h1splitter = UIHorizontalMultiSplitter(Rect(delIconWindow.size), 10, 5, 4)

    delbtn1 = delIconWindow:createButton(h1splitter:partition(0), "", "removeIconsMatchingColor")
	delpic1 = delIconWindow:createPicture(h1splitter:partition(0), "data/textures/icons/galaxymapqol/ui-filled.png")
    delpic1.position = delpic1.position + vec2(1, 1)
    delbtn2 = delIconWindow:createButton(h1splitter:partition(1), "", "removeIconsMatchingIcon")
    delpic2 = delIconWindow:createPicture(h1splitter:partition(1), "data/textures/icons/galaxymapqol/empty.png")
    delpic2.size = vec2(delpic2.size - 2, delpic2.size + 2) delpic2.position = delpic2.position + vec2(1, 1) delpic2.flipped = true
    delbtn3 = delIconWindow:createButton(h1splitter:partition(2), "", "removeIconsMatching")
    delbtn3.textSize = 11
    delpic3 = delIconWindow:createPicture(h1splitter:partition(2), "data/textures/icons/galaxymapqol/empty.png")
    delpic3.size = vec2(delpic3.size - 2, delpic3.size + 2) delpic3.position = delpic3.position + vec2(1, 1) delpic3.flipped = true
    delbtn4 = delIconWindow:createButton(h1splitter:partition(3), "", "removeAllIcons")
    delbtn4.textSize = 11
    delbtn5 = delIconWindow:createButton(h1splitter:partition(4), "Off", "deleteIconsMode")
    delbtn5.textSize = 11 delbtn5.tooltip = "Toggle Delete Mode On/Off\nSelecting A Sector with an icon will\ndelete the icon while this is On."
	delpic4 = delIconWindow:createPicture(h1splitter:partition(4), "data/textures/icons/galaxymapqol/select.png")
    delpic4.position = delpic4.position + vec2(0, 0) delpic4.color = ColorARGB(0.8, 1, 0, 0)
    deleteIconsMode = false

    helpIconWindow = map:createWindow(Rect(670, 173, 709, 290))
	helpIconWindow.visible = false

    local h2splitter = UIHorizontalMultiSplitter(Rect(helpIconWindow.size), 10, 5, 2)

    helpbtn1 = helpIconWindow:createButton(h2splitter:partition(0), "", "restoreDeleteUndo")
    helpbtn1.textSize = 11 helpbtn1.tooltip = "Undo Prev Delete"
    helppic1 = helpIconWindow:createPicture(h2splitter:partition(0), "data/textures/icons/galaxymapqol/clockwise-rotation.png")
    helppic1.size = vec2(helppic1.size - 2, helppic1.size + 2) helppic1.position = helppic1.position + vec2(1, 1) helppic1.flipped = true helppic1.flippedX = true
    helpbtn2 = helpIconWindow:createButton(h2splitter:partition(2), "Off", "helpIconsMode")
    helpbtn2.textSize = 11 helpbtn2.tooltip = "Toggle Instant Mode On/Off\nSelecting A Sector with an icon will\nadd the icon while this is On."
	helppic2 = helpIconWindow:createPicture(h2splitter:partition(2), "data/textures/icons/galaxymapqol/select.png")
    helppic2.position = helppic2.position + vec2(0, 0) helppic2.color = ColorARGB(0.8, 1, 0, 0)
    helpIconsMode = false GalaxyMapQoL.updateAdditionalButtons()
end

function GalaxyMapQoL.galaxyMapQoL_onGalaxyMapMouseDown()
	if not isEditIconShown then return end
	if not Mouse():mousePressed(MouseButton.Left) then return end

	local x, y = GalaxyMap():getHoveredCoordinates()
	if not x then return end

	dragStart = vec2(x, y)
	selectedArea = nil
	isDragging = true
end

function GalaxyMapQoL.updateDrag()
	if not isEditIconShown then return end
	if not dragStart or not isDragging then return end

	local x, y = GalaxyMap():getHoveredCoordinates()
	if not x then return end
	if x == dragStart.x and y == dragStart.y then selectedArea = nil return end
    dragMoveCount = dragMoveCount + 1
    if dragMoveCount > 15 then helpIconsMode = false deleteIconsMode = false GalaxyMapQoL.updateAdditionalButtons() end

    local lower = vec2(math.min(dragStart.x, x) + 1, math.min(dragStart.y, y) + 1)
    local upper = vec2(math.max(dragStart.x, x) - 1, math.max(dragStart.y, y) - 1)

	selectedArea = {lower = lower, upper = upper}
	GalaxyMap():setHighlightedArea(lower, upper, ColorARGB(0.3, 0.2, 0.2, 0.2), "QoL")
end

function GalaxyMapQoL.galaxyMapQoL_onGalaxyMapMouseButtonEvent()
	if Mouse():mouseUp(MouseButton.Left) then
		isDragging = false
		dragStart = nil
        dragMoveCount = 0
	end
    if not selectedArea then GalaxyMapQoL.updateAdditionalButtons() GalaxyMapQoL.clearSelectedArea() end
end

function GalaxyMapQoL.getSelectedArea()
	return selectedArea
end

function GalaxyMapQoL.clearSelectedArea()
	dragStart = nil
	selectedArea = nil
	isDragging = false
	GalaxyMap():removeHighlightedArea("QoL")
end

function GalaxyMapQoL.getUpdateInterval()
	if isEditIconShown  then return 0 end
	return 0.5
end

function GalaxyMapQoL.updateClient(timeStep)
	if isEditIconShown then
        if not helpIconWindow.mouseOver and not editIconWindow.mouseOver and not delIconWindow.mouseOver then
            GalaxyMapQoL.updateDrag()
        end

		-- removed colorPicker update

		local mouse = Mouse()
		if not colorPicker.visible and mouse:mouseDown(MouseButton.Left) then
			local pos = mouse.position

			for i, pair in ipairs(colorPictures) do
				if pair.picture.mouseOver then
					GalaxyMapQoL.selectColor(i)
					break
				end
			end

			if pos.x >= editIconScrollFrame.lower.x and pos.x <= editIconScrollFrame.upper.x and pos.y >= editIconScrollFrame.lower.y and pos.y <= editIconScrollFrame.upper.y then
				for i = 1, #icons do
					local picture = iconPictures[i]
					if pos.x >= picture.lower.x and pos.x <= picture.upper.x and pos.y >= picture.lower.y and pos.y <= picture.upper.y then
						GalaxyMapQoL.selectIcon(i)
						break
					end
				end
			end
		end
	end

	if GT112 and GalaxyMap().visible and allianceNotesContainer and highlightAllianceNotesCheckBox then
		allianceNotesContainer.visible = GalaxyMap().showAllianceInfo and highlightAllianceNotesCheckBox.checked
	end
end

function GalaxyMapQoL.sync(isFullSync, playerData, allianceData)
    if playerData then
        if isFullSync then
            isServerUsed = true
            sectorsPlayer = playerData
            GalaxyMapQoL.updateMapIcons()
            if not sectorsAlliance then
                sectorsAlliance = {}
            end
        else
            if #playerData == 2 then
                sectorsPlayer[playerData[1].."_"..playerData[2]] = nil
                GalaxyMapQoL.updateMapIcons()
            else
                sectorsPlayer[playerData[1].."_"..playerData[2]] = playerData
                GalaxyMapQoL.updateMapIcons(false, playerData)
            end
        end
    else
        if isFullSync then
            sectorsAlliance = allianceData
            GalaxyMapQoL.updateMapIcons(true)
        else
            if #allianceData == 2 then
                sectorsAlliance[allianceData[1].."_"..allianceData[2]] = nil
                GalaxyMapQoL.updateMapIcons(true)
            else
                sectorsAlliance[allianceData[1].."_"..allianceData[2]] = allianceData
                GalaxyMapQoL.updateMapIcons(true, allianceData)
            end
        end
    end
end

function GalaxyMapQoL.syncWarZones(data)
    warZoneData = {}
    for _, s in ipairs(data) do
        warZoneData[s[1]..'_'..s[2]] = s
    end
end

function GalaxyMapQoL.addOverlay(key, name, onSelect, onRender)
    overlays[#overlays+1] = {
      key = key,
      name = name,
      onSelect = onSelect,
      onRender = onRender
    }
    showOverlayComboBox:addEntry(name)
end

function GalaxyMapQoL.removeOverlay(key)
    showOverlayComboBox.selectedIndex = 0
    showOverlayComboBox:clear()
    showOverlayComboBox:addEntry("Show overlay"%_t)
    local newOverlays = {}
    for _, overlay in ipairs(overlays) do
        if overlay.key ~= key then
            newOverlays[#newOverlays+1] = overlay
            showOverlayComboBox:addEntry(overlay.name)
        end
    end
    overlays = newOverlays
end

function GalaxyMapQoL.galaxyMapQoL_onShowGalaxyMap()
    if not isServerUsed and not sectorsPlayer then
        sectorsPlayer = Config.playerIcons
        GalaxyMapQoL.updateMapIcons()
        sectorsAlliance = {}
    end

    local player = Player()
    if isServerUsed and player.alliance and not iconsFactionBoxHasAlliance then
        iconsFactionComboBox:addEntry("Alliance"%_t)
        iconsFactionBoxHasAlliance = true
    elseif not player.alliance and iconsFactionBoxHasAlliance then
        local prevIndex = iconsFactionComboBox.selectedIndex
        iconsFactionComboBox:clear()
        iconsFactionComboBox:addEntry("Hide icons"%_t)
        iconsFactionComboBox:addEntry("Player"%_t)
        iconsFactionComboBox:setSelectedIndexNoCallback(prevIndex == 2 and 1 or prevIndex)
        if prevIndex == 2 then
            allianceIconsContainer.visible = false
            playerIconsContainer.visible = true
        end
        sectorsAlliance = {}
        iconsFactionBoxHasAlliance = false
        GalaxyMapQoL.updateMapIcons(true)
    end

    GalaxyMapQoL.galaxyMapQoL_onIconsFactionBoxChanged()

    if isServerUsed and warZoneCheckBox.checked then
        invokeServerFunction("syncWarZones")
    end

    if factionColorsCheckBox and factionColorsCheckBox.checked then
        if factionsColorsCache then
            local map = GalaxyMap()
            map:clearCustomColors()
            map:setCustomColors(factionsColorsCache)
            map.showFactionLayer = false
            map.showCustomColorLayer = true
        end
        if (appTime() - factionColorsUpdated) >= 30 then
            GalaxyMapQoL.startFactionColorsCalculation()
        end
    end

    GalaxyMapQoL.galaxyMapQoL_onShowOverlayBoxChanged()
    GalaxyMapQoL.onLockRadarCheckBoxChecked()

    if GT112 then
        allianceNotesContainer:clear()
        if player.alliance then
            local path = GameVersion() >= Version("2.0") and "data/textures/icons/galaxymapqol/ui-note-2.0.png" or "data/textures/icons/galaxymapqol/ui-note.png"
            for _, view in ipairs({player.alliance:getKnownSectors()}) do
                if view.note then
                    local hasNote
                    if atype(view.note) == "NamedFormat" then
                        hasNote = view.note.text ~= ""
                    else
                        hasNote = view.note ~= ""
                    end
                    if hasNote then
                        hasNote = false
                        local x, y = view:getCoordinates()
                        local playerView = player:getKnownSector(x, y)
                        if playerView then
                            if atype(playerView.note) == "NamedFormat" then
                                hasNote = playerView.note.text ~= ""
                            else
                                hasNote = playerView.note ~= ""
                            end
                        end
                        if not hasNote then
                            local icon = allianceNotesContainer:createMapIcon(path, ivec2(x, y))
                            icon.color = ColorInt(0xffFF00FF)
                        end
                    end
                end
            end
        end
    end
end

function GalaxyMapQoL.galaxyMapQoL_onHideGalaxyMap()
	isEditIconShown = false deleteIconsMode = false

	Config.colors = {}
	for i = 1, 10 do
		Config.colors[i] = colorPictures[i+1].color:toInt()
	end

	if warZoneCheckBox then Config.markHazards = warZoneCheckBox.checked end
	if lockRadarCheckBox then Config.lockRadar = lockRadarCheckBox.checked end
	if highlightAllianceNotesCheckBox then Config.highlightAllianceNotes = highlightAllianceNotesCheckBox.checked end
    if showOverlayComboBox then Config.selectedOverlay = showOverlayComboBox.selectedIndex end

	Config.deleteUndo = deleteUndo
	Azimuth.saveConfig("GalaxyMapQoL", Config, {_version = {comment = "Don't touch this file"}}, true, true)
end

function GalaxyMapQoL.galaxyMapQoL_onMapRenderAfterLayers()
    local map = GalaxyMap()
    local half, topX, bottomY, bottomX, topY
    local renderer

    if lockRadarCheckBox.checked then
        renderer = UIRenderer()
        half = (map:getCoordinatesScreenPosition(ivec2(1, 0)) - map:getCoordinatesScreenPosition(ivec2(0, 0))) * 0.5
        topX, bottomY = map:getCoordinatesAtScreenPosition(vec2(0, 0))
        bottomX, topY = map:getCoordinatesAtScreenPosition(getResolution())

        local green = ColorInt(0xff42E745)
        local yellow = ColorInt(0xffE7E142)
        for coords, regular in pairs(lockedRadarBlips) do
            if coords.x >= topX and coords.x <= bottomX and coords.y >= topY and coords.y <= bottomY then
                local sx, sy = map:getCoordinatesScreenPosition(coords)
                if regular then
                    renderer:renderIcon(vec2(sx - half, sy - half), vec2(sx + half, sy + half), green, "data/textures/icons/galaxymapqol/ui-blip.png")
                else
                    renderer:renderIcon(vec2(sx - half, sy - half), vec2(sx + half, sy + half), yellow, "data/textures/icons/galaxymapqol/ui-blip-offgrid.png")
                end
            end
        end
    end

    if not GT112 then
        local iconFaction = iconsFactionComboBox.selectedIndex
        if iconFaction ~= 0 then
            renderer = UIRenderer()
            if not half then
                half = (map:getCoordinatesScreenPosition(ivec2(1, 0)) - map:getCoordinatesScreenPosition(ivec2(0, 0))) * 0.5
                topX, bottomY = map:getCoordinatesAtScreenPosition(vec2(0, 0))
                bottomX, topY = map:getCoordinatesAtScreenPosition(getResolution())
            end

            local sectors = iconFaction == 1 and sectorsPlayer or sectorsAlliance
            local sx, sy
            for _, sector in pairs(sectors) do
                if sector[1] >= topX and sector[1] <= bottomX and sector[2] >= topY and sector[2] <= bottomY then
                    sx, sy = map:getCoordinatesScreenPosition(ivec2(sector[1], sector[2]))
                    renderer:renderIcon(vec2(sx - half, sy - half), vec2(sx + half, sy + half), ColorInt(sector[4]), "data/textures/icons/galaxymapqol/"..sector[3]..".png")
                end
            end
        end
    end

    local overlayIndex = showOverlayComboBox.selectedIndex
    if overlayIndex > 0 then
        if not renderer then
            renderer = UIRenderer()
        end
        local overlay = overlays[overlayIndex]
        if overlay and overlay.onRender and GalaxyMapQoL[overlay.onRender] then
            GalaxyMapQoL[overlay.onRender](renderer)
        end
    end

    if renderer then
        renderer:display()
    end

    if warZoneCheckBox and warZoneCheckBox.checked then
        local renderer = UIRenderer()
        if not half then
            half = (map:getCoordinatesScreenPosition(ivec2(1, 0)) - map:getCoordinatesScreenPosition(ivec2(0, 0))) * 0.5
            topX, bottomY = map:getCoordinatesAtScreenPosition(vec2(0, 0))
            bottomX, topY = map:getCoordinatesAtScreenPosition(getResolution())
        end

        local sx, sy
        for _, sector in pairs(warZoneData) do
            if sector[1] >= topX and sector[1] <= bottomX and sector[2] >= topY and sector[2] <= bottomY then
                sx, sy = map:getCoordinatesScreenPosition(ivec2(sector[1], sector[2]))
                renderer:renderRect(vec2(sx + half * 0.25, sy + half * 0.25), vec2(sx + half, sy + half), warZoneColor, 1)
            end
        end

        renderer:display()
    end

    GalaxyMapQoL.drawDistanceToCenter(map)
end

function GalaxyMapQoL.drawDistanceToCenter(map)
    local x, y = map:getHoveredCoordinates()
    if x then
        if not distToCenter or distToCenter.x ~= x or distToCenter.y ~= y then
            local passable = passageMap:passable(x, y)
            distToCenter = { x = x, y = y, passable = passable }
            if passable then
                distToCenter.text = "${x} : ${y} (dist: ${num})"%_t % {x = x, y = y, num = tonumber(string.format("%.4f", math.sqrt(x*x + y*y)))}
                if warZoneData[x..'_'..y] then
                    distToCenter.text = distToCenter.text .. "\n Hazard Zone"%_t
                end
            end
        end
        if distToCenter.passable then
            local mx, my = map:getCoordinatesScreenPosition(ivec2(x, y))
            if GameVersion() >= Version("2.0") then
                drawText(distToCenter.text, mx + 40, my - 15, distColor, 13, 0, 0, 1)
            else
                drawText(distToCenter.text, mx + 24, my - 15, distColor, 13, 0, 0, 1)
            end
        end
    end
end

function GalaxyMapQoL.updateMapIcons(isAlliance, sectorData)
    if not GT112 then return end

    local container = isAlliance and allianceIconsContainer or playerIconsContainer
    local mapIcons = isAlliance and allianceMapIcons or playerMapIcons
    if sectorData then
        local mapIcon = mapIcons[sectorData[1].."_"..sectorData[2]]
        if mapIcon then
            mapIcon.icon = "data/textures/icons/galaxymapqol/map/"..sectorData[3]..".png"
            mapIcon.color = ColorInt(sectorData[4])
        else
            mapIcons[sectorData[1].."_"..sectorData[2]] = container:createMapIcon("data/textures/icons/galaxymapqol/map/"..sectorData[3]..".png", ivec2(sectorData[1], sectorData[2]))
            mapIcons[sectorData[1].."_"..sectorData[2]].color = ColorInt(sectorData[4])
        end
    else
        if isAlliance then
            allianceMapIcons = {}
            mapIcons = allianceMapIcons
        else
            playerMapIcons = {}
            mapIcons = playerMapIcons
        end
        container:clear()
        local sectors = isAlliance and sectorsAlliance or sectorsPlayer
        for key, sector in pairs(sectors) do
            mapIcons[key] = container:createMapIcon("data/textures/icons/galaxymapqol/map/"..sector[3]..".png", ivec2(sector[1], sector[2]))
            mapIcons[key].color = ColorInt(sector[4])
        end
    end
end

function GalaxyMapQoL.galaxyMapQoL_onEditIconBtnPressed(_, isCallback)
	


	if isCallback and not helpIconWindow.mouseOver and not editIconWindow.mouseOver and not delIconWindow.mouseOver and helpIconsMode then
		local x, y = GalaxyMap():getSelectedCoordinates()
		GalaxyMapQoL.addIconAtCoordinates(x, y)
		return
    end

	if isCallback and not helpIconWindow.mouseOver and not editIconWindow.mouseOver and not delIconWindow.mouseOver and deleteIconsMode then
		local x, y = GalaxyMap():getSelectedCoordinates()
		GalaxyMapQoL.removeIconAtCoordinates(x, y)
		return
	end

	if not helpIconsMode and not deleteIconsMode and (isCallback and editIconWindow.visible) or (not isCallback and not editIconWindow.visible) then
		local iconFaction = iconsFactionComboBox.selectedIndex
		local sectors = iconFaction == 1 and sectorsPlayer or sectorsAlliance
		editedX, editedY = GalaxyMap():getSelectedCoordinates()
		coordinatesLabel.caption = editedX .. " : " .. editedY
		local sector = sectors[editedX.."_"..editedY]
		if sector then
			local iconIndex = 1
			for i = 2, #icons do
				if sector[3] == icons[i] then
					iconIndex = i
					break
				end
			end
			local color = ColorInt(sector[4])
			colorPictures[1].picture.color = color
			colorPictures[1].color = color
			GalaxyMapQoL.selectIcon(iconIndex)
			GalaxyMapQoL.selectColor(1)
		else
			--GalaxyMapQoL.selectIcon(1)
		end
	end

	if not isCallback then
        helpIconWindow.visible = not helpIconWindow.visible
		editIconWindow.visible = not editIconWindow.visible
        delIconWindow.visible = not delIconWindow.visible
		isEditIconShown = editIconWindow.visible
	end
end

function GalaxyMapQoL.helpIconsMode()
    deleteIconsMode = false helpIconsMode = not helpIconsMode
    GalaxyMap():setSelectedCoordinates(nil, nil) GalaxyMapQoL.updateAdditionalButtons()
end

function GalaxyMapQoL.addIconAtCoordinates(x, y)
	editedX, editedY = x, y
	coordinatesLabel.caption = editedX .. " : " .. editedY
	GalaxyMapQoL.galaxyMapQoL_onEditIconApplyBtnPressed()
end

function GalaxyMapQoL.getDeleteUndoCount()
	return deleteUndo and #deleteUndo or 0
end

function GalaxyMapQoL.pushDeleteUndo(isAlliance, sectors)
	if not sectors or #sectors == 0 then return end

	table.insert(deleteUndo, 1, {isAlliance = isAlliance, sectors = sectors})

	while #deleteUndo > 3 do
		table.remove(deleteUndo)
	end

	Config.deleteUndo = deleteUndo
end

function GalaxyMapQoL.restoreDeleteUndo()
	if not deleteUndo or #deleteUndo == 0 then return end

	local undo = table.remove(deleteUndo, 1)
	local sectors = undo.isAlliance and sectorsAlliance or sectorsPlayer
	if not sectors then return end

	for _, sector in ipairs(undo.sectors) do
		if isServerUsed then
			invokeServerFunction("setSectorIcon", undo.isAlliance, sector[1], sector[2], sector[3], sector[4])
		else
			sectors[sector[1].."_"..sector[2]] = sector
		end
	end

	Config.deleteUndo = deleteUndo

	if not isServerUsed then
		GalaxyMapQoL.updateMapIcons(undo.isAlliance)
	end

    GalaxyMapQoL.updateAdditionalButtons()
end

function GalaxyMapQoL.deleteIconsMode()
    helpIconsMode = false deleteIconsMode = not deleteIconsMode
    GalaxyMap():setSelectedCoordinates(nil, nil) GalaxyMapQoL.updateAdditionalButtons()
end

function GalaxyMapQoL.removeIconAtCoordinates(x, y, isAlliance)
	if isAlliance == nil then
		isAlliance = iconsFactionComboBox.selectedIndex == 2
	end

	local sectors = isAlliance and sectorsAlliance or sectorsPlayer
	local key = x.."_"..y
	if not sectors or not sectors[key] then return end

	GalaxyMapQoL.pushDeleteUndo(isAlliance, {sectors[key]})

	if isServerUsed then
		invokeServerFunction("setSectorIcon", isAlliance, x, y)
	else
		sectors[key] = nil
		GalaxyMapQoL.updateMapIcons(isAlliance)
	end

    GalaxyMapQoL.updateAdditionalButtons()
end

function GalaxyMapQoL.removeIconsByFilter(iconName, color)
	local isAlliance = iconsFactionComboBox.selectedIndex == 2
	local sectors = isAlliance and sectorsAlliance or sectorsPlayer
	if not sectors then return end

	local remove = {}
	for key, sector in pairs(sectors) do
		if (not iconName or sector[3] == iconName) and (not color or sector[4] == color)
        and (not selectedArea or sector[1] >= selectedArea.lower.x and sector[1] <= selectedArea.upper.x
        and sector[2] >= selectedArea.lower.y and sector[2] <= selectedArea.upper.y) then
			remove[#remove + 1] = sector
		end
	end

	GalaxyMapQoL.pushDeleteUndo(isAlliance, remove)

	for _, sector in ipairs(remove) do
		if isServerUsed then
			invokeServerFunction("setSectorIcon", isAlliance, sector[1], sector[2])
		else
			sectors[sector[1].."_"..sector[2]] = nil
		end
	end

	if not isServerUsed then
		GalaxyMapQoL.updateMapIcons(isAlliance)
	end
end

function GalaxyMapQoL.removeAllIcons()
	GalaxyMapQoL.removeIconsByFilter()
	GalaxyMapQoL.clearSelectedArea()
end

function GalaxyMapQoL.removeIconsMatchingIcon()
	local iconName = icons[selectedIcon]
	if iconName == "empty" then return end

	GalaxyMapQoL.removeIconsByFilter(iconName) GalaxyMapQoL.clearSelectedArea()
end

function GalaxyMapQoL.removeIconsMatchingColor()
	local color = colorPictures[selectedColorIndex].color:toInt()

	GalaxyMapQoL.removeIconsByFilter(nil, color) GalaxyMapQoL.clearSelectedArea()
end

function GalaxyMapQoL.removeIconsMatching()
	local iconName = icons[selectedIcon]
	if iconName == "empty" then return end

	local color = colorPictures[selectedColorIndex].color:toInt()

	GalaxyMapQoL.removeIconsByFilter(iconName, color)
end

function GalaxyMapQoL.galaxyMapQoL_onIconsFactionBoxChanged()
    helpIconWindow.visible = false editIconWindow.visible = false delIconWindow.visible = false
    local iconFaction = iconsFactionComboBox.selectedIndex
    if iconFaction == 0 then
        editIconBtn.active = false
        playerIconsContainer.visible = false
        allianceIconsContainer.visible = false
    elseif iconFaction == 2 then
        local player = Player()
        local alliance = player.alliance
        if not alliance or not alliance:hasPrivilege(player.index, AlliancePrivilege.EditMap) then
            editIconBtn.active = false
        else
            editIconBtn.active = true
        end
        if isServerUsed and alliance then
            playerIconsContainer.visible = false
            allianceIconsContainer.visible = true
            invokeServerFunction("sync")
        end
    else -- 1
        editIconBtn.active = true
        playerIconsContainer.visible = true
        allianceIconsContainer.visible = false
    end
end

function GalaxyMapQoL.galaxyMapQoL_onShowOverlayBoxChanged()
    local overlayIndex = showOverlayComboBox.selectedIndex
    local selectedFunc
    for index, overlay in ipairs(overlays) do
        if index == overlayIndex then
            selectedFunc = overlay.onSelect
        elseif overlay.onSelect and GalaxyMapQoL[overlay.onSelect] then
            GalaxyMapQoL[overlay.onSelect](false)
        end
    end
    if selectedFunc and GalaxyMapQoL[selectedFunc] then
        GalaxyMapQoL[selectedFunc](true)
    end
end

function GalaxyMapQoL.onResourcesOverlaySelected(isSelected)
    local map = GalaxyMap()
    if not isSelected then
        map.showCustomColorLayer = false
        map:clearCustomColors()

        for _, row in ipairs(legendRows) do
            row.picture.visible = false
            row.label.visible = false
        end
    else

        local tbl = {}
        for i, dist in ipairs(materialDistances) do
            local color = Material(i).color
            color.a = 0.7
            GalaxyMapQoL.mapCircle(tbl, dist, color)
        end
        map:setCustomColors(tbl)
        map.showCustomColorLayer = true

        local material, color
        for i, row in ipairs(legendRows) do
            material = Material(i)
            color = material.color
            color.a = 0.7
            row.picture.color = color
            row.label.caption = material.name.." - "..math.floor(materialDistances[i])
            row.picture.visible = true
            row.label.visible = true
        end
    end
end

function GalaxyMapQoL.onResourcesOverlayRendered(renderer)
    local map = GalaxyMap()
    local white = ColorRGB(1, 1, 1)
    for i, dist in ipairs(materialDistances) do
        local sx, sy = map:getCoordinatesScreenPosition(ivec2(0, -dist - 1))
        drawTextRect(Material(i).name, Rect(sx - 200, sy, sx + 200, sy + 20), 0, 0, white, 15, 0, 0, 2)
    end
end

function GalaxyMapQoL.onTechLevelsOverlaySelected(isSelected)
    local map = GalaxyMap()
    if not isSelected then
        map.showCustomColorLayer = false
        map:clearCustomColors()

        for _, row in ipairs(legendRows) do
            row.picture.visible = false
            row.label.visible = false
        end
    else

        local tbl = {}
        for _, dist in pairs(techLevels) do
            local color = ColorRGB(0.7, 0.7, 0.7)
            color.a = 0.7
            GalaxyMapQoL.mapCircle(tbl, dist, color)
        end
        map:setCustomColors(tbl)
        map.showCustomColorLayer = true
    end
end

function GalaxyMapQoL.onTechLevelsOverlayRendered()
    local map = GalaxyMap()
    local white = ColorRGB(1, 1, 1)
    for tech, dist in pairs(techLevels) do
        local sx, sy = map:getCoordinatesScreenPosition(ivec2(0, -dist - 1))
        drawTextRect("Tech"%_t.." "..tech, Rect(sx - 200, sy, sx + 200, sy + 20), 0, 0, white, 15, 0, 0, 2)
    end
end

function GalaxyMapQoL.onBossesOverlaySelected(isSelected)
    local map = GalaxyMap()
    if not isSelected then
        map.showCustomColorLayer = false
        map:clearCustomColors()

        for _, row in ipairs(legendRows) do
            row.picture.visible = false
            row.label.visible = false
        end
    else

        local distances = {}
        for _, boss in ipairs(bossDistances) do
            local dist = distances[boss.min]
            if not dist then
                distances[boss.min] = { boss.color }
            else
                dist[#dist+1] = boss.color
            end
            dist = distances[boss.max]
            if not dist then
                distances[boss.max] = { boss.color }
            else
                dist[#dist+1] = boss.color
            end
        end
        local tbl = {}
        for dist, colors in pairs(distances) do
            GalaxyMapQoL.mapCircle(tbl, dist, colors, 10)
        end
        map:setCustomColors(tbl)
        map.showCustomColorLayer = true

        local row
        for i, boss in ipairs(bossDistances) do
            row = legendRows[i]
            row.picture.color = boss.color
            row.label.caption = boss.name.." - "..boss.min.."-"..boss.max
            row.picture.visible = true
            row.label.visible = true
        end
    end
end

function GalaxyMapQoL.onBossesOverlayRendered(renderer)
    local map = GalaxyMap()
    local white = ColorRGB(1, 1, 1)
    for i, boss in ipairs(bossDistances) do
        local sx, sy = map:getCoordinatesScreenPosition(ivec2(0, -boss.max + 8))
        drawTextRect(boss.name, Rect(sx - 200, sy, sx + 200, sy + 20), 0, 0, white, 15, 0, 0, 2)
    end
end

function GalaxyMapQoL.galaxyMapQoL_onEditSelectedColorBtnPressed()
    -- removed colorPicker show
    local res = getResolution()
    local newPos = editIconWindow.position + vec2(editIconWindow.width + 10, 40)
    if newPos.x + 410 <= res.x then
        colorPicker.position = newPos
    end
end

function GalaxyMapQoL.galaxyMapQoL_onColorPickerApplyBtnPressed(color)
    local colorPicture = colorPictures[selectedColorIndex]
    colorPicture.picture.color = color
    colorPicture.color = color
    GalaxyMapQoL.selectColor(selectedColorIndex)
end

function GalaxyMapQoL.galaxyMapQoL_onEditIconApplyBtnPressed()
    

    deleteIconsMode = false GalaxyMapQoL.updateAdditionalButtons()

    local iconFaction = iconsFactionComboBox.selectedIndex
    if selectedIcon == 1 then
        if isServerUsed then
            invokeServerFunction("setSectorIcon", iconFaction == 2, editedX, editedY)
        else
            sectorsPlayer[editedX.."_"..editedY] = nil
            GalaxyMapQoL.updateMapIcons()
        end
    else
        if isServerUsed then
            invokeServerFunction("setSectorIcon", iconFaction == 2, editedX, editedY, icons[selectedIcon], colorPictures[selectedColorIndex].color:toInt())
        else
            sectorsPlayer[editedX.."_"..editedY] = { editedX, editedY, icons[selectedIcon], colorPictures[selectedColorIndex].color:toInt() }
            GalaxyMapQoL.updateMapIcons(false, sectorsPlayer[editedX.."_"..editedY])
        end
    end
end

function GalaxyMapQoL.galaxyMapQoL_onEditIconCancelBtnPressed()
    -- removed colorPicker hide deleteIconsMode = false
    helpIconWindow.visible = false editIconWindow.visible = false delIconWindow.visible = false
    isEditIconShown = false
end

function GalaxyMapQoL.onShowOptionsBtnPressed()
    optionsContainer.visible = not optionsContainer.visible
end

function GalaxyMapQoL.onWarZoneCheckBoxChecked()
    if isServerUsed and warZoneCheckBox.checked then
        invokeServerFunction("syncWarZones")
    end
end

function GalaxyMapQoL.onLockRadarCheckBoxChecked()
	if not lockRadarCheckBox.checked then
		lockedRadarBlips = {}
		return
	end

	local player = Player()
	local x, y = Sector():getCoordinates()
	local seed = GameSeed()
	local radius = player.craft:getBoostedValue(StatsBonuses.RadarReach, 14)
	local hiddenRadius = player.craft:getBoostedValue(StatsBonuses.HiddenSectorRadarReach, 0)
	lockedRadarBlips = {}

	for i = 0, radius do
		local posEnd = math.floor(math.sqrt(radius * radius - i * i) - 1.00001)
		for j = 1, posEnd + 1 do
			local coords = { {x + i, y + j}, {x + j, y - i}, {x - i, y - j}, {x - j, y + i} }
			for _, pair in ipairs(coords) do
				local n = pair[1]
				local m = pair[2]
				if not player:knowsSector(n, m) then
					local regular, offgrid = specs:determineContent(n, m, seed)
					if regular or (offgrid and distance(vec2(x, y), vec2(n, m)) <= hiddenRadius) then
						lockedRadarBlips[ivec2(n, m)] = regular
					end
				end
			end
		end
	end
end

function GalaxyMapQoL.onHighlightAllianceNotesChecked()
    if allianceNotesContainer and highlightAllianceNotesCheckBox then
        allianceNotesContainer.visible = GalaxyMap().showAllianceInfo and highlightAllianceNotesCheckBox.checked
    end
end

function GalaxyMapQoL.galaxyMapQoL_onFactionColorsCheckBoxChecked()
    local map = GalaxyMap()
    if factionColorsCheckBox.checked then
        if factionsColorsCache then
            map:clearCustomColors()
            map:setCustomColors(factionsColorsCache)
            map.showFactionLayer = false
            map.showCustomColorLayer = true
        end
        if (appTime() - factionColorsUpdated) >= 30 then
            GalaxyMapQoL.startFactionColorsCalculation()
        end
    else
        map:clearCustomColors()
        map.showFactionLayer = true
        map.showCustomColorLayer = false
    end
end

function GalaxyMapQoL.onFactionColorsCalculated(sectors, tookTime, memoryUsage)

    factionsColorsCache = sectors
    if factionColorsCheckBox.checked then
        local map = GalaxyMap()
        map:clearCustomColors()
        map:setCustomColors(sectors)
        map.showFactionLayer = false
        map.showCustomColorLayer = true
    end
    factionColorsUpdated = appTime()
    factionColorsIsRunning = false
end

function GalaxyMapQoL.selectColor(index)
	selectedColorIndex = index
	local colorPicture = colorPictures[index]
	colorSelector.position = colorPicture.picture.position - vec2(3, 3)
	iconPictures[selectedIcon].color = colorPicture.color
	GalaxyMapQoL.updateAdditionalButtons()
end

function GalaxyMapQoL.selectIcon(index)
	if selectedIcon then
		iconPictures[selectedIcon].color = ColorRGB(1, 1, 1)
	end

	selectedIcon = index
	local iconPicture = iconPictures[selectedIcon]
	iconPicture.color = colorPictures[selectedColorIndex].color
	iconSelector.position = iconPicture.lower - vec2(3, 3)
	GalaxyMapQoL.updateAdditionalButtons()
end

function GalaxyMapQoL.updateAdditionalButtons()
	if helpbtn1 then
        local undoCount = GalaxyMapQoL.getDeleteUndoCount()
		if undoCount > 0 then
			helpbtn1.active = true
            helpbtn1.caption = undoCount
		else
			helpbtn1.active = false
            helpbtn1.caption = "0"
		end
	end

	if helppic2 and helpbtn2 then
        helppic2.color = helpIconsMode and ColorARGB(0.8, 0, 1, 0) or ColorARGB(0.8, 1, 0, 0)
		helpbtn2.caption = helpIconsMode and "On"%_t or "Off"%_t
	end

	if delpic1 then
		delpic1.color = colorPictures[selectedColorIndex].color
        if selectedArea then delbtn1.tooltip = "Delete Matching Color\nIn Selected Area" else delbtn1.tooltip = "Delete Matching Color" end
	end

	if delpic2 and delbtn2 then
		if selectedIcon and selectedIcon > 1 then
			delpic2.picture = "data/textures/icons/galaxymapqol/"..icons[selectedIcon]..".png"
            if selectedArea then delbtn2.tooltip = "Delete Matching Icon\nIn Selected Area" else delbtn2.tooltip = "Delete Matching Icon" end
			delbtn2.active = true
		else
			delpic2.picture = "data/textures/icons/galaxymapqol/empty.png"
			delbtn2.active = false
		end
	end

	if delpic3 and delbtn3 then
		if selectedIcon and selectedIcon > 1 then
			delpic3.picture = "data/textures/icons/galaxymapqol/"..icons[selectedIcon]..".png"
            delpic3.color = colorPictures[selectedColorIndex].color
            if selectedArea then
                delbtn3.tooltip = "Delete Matching Color And Icon\nIn Selected Area"
            else
                delbtn3.tooltip = "Delete Matching Color And Icon"
            end
			delbtn3.active = true
		else
			delpic3.picture = "data/textures/icons/galaxymapqol/empty.png"
			delbtn3.active = false
		end
	end

    if delbtn4 then
        if selectedArea then
            delbtn4.caption = "Sel" delbtn4.tooltip = "Delete All Icons\nIn Selected Area"
        else
            delbtn4.caption = "All" delbtn4.tooltip = "Delete All Icons"
        end
    end

	if delpic4 and delbtn5 then
        delpic4.color = deleteIconsMode and ColorARGB(0.8, 0, 1, 0) or ColorARGB(0.8, 1, 0, 0)
		delbtn5.caption = deleteIconsMode and "On"%_t or "Off"%_t
	end
end

function GalaxyMapQoL.mapCircle(tbl, radius, colors, colorSwitchStep)
    if type(colors) ~= "table" then
        colors = {colors}
    end
    local color = colors[1]
    local colorCount = #colors
    local colorIndex = 1
    local colorProgress = 0
    local ex = math.ceil(math.floor(radius) / 2 * math.sqrt(2))
    for x = 0, ex do
        local y = math.floor(math.sqrt(radius * radius - x * x))
        tbl[ivec2(x, y)] = color
        tbl[ivec2(y, x)] = color
        tbl[ivec2(x, -y)] = color
        tbl[ivec2(y, -x)] = color
        tbl[ivec2(-x, y)] = color
        tbl[ivec2(-y, x)] = color
        tbl[ivec2(-x, -y)] = color
        tbl[ivec2(-y, -x)] = color
        if colorSwitchStep then
            if colorProgress == colorSwitchStep then
                colorIndex = colorIndex + 1
                if colorIndex > colorCount then
                    colorIndex = 1
                end
                color = colors[colorIndex]
                colorProgress = 0
            else
                colorProgress = colorProgress + 1
            end
        end
    end
end

function GalaxyMapQoL.drawCircle(renderer, radius, color, layer, color2, colorSwitchStep)
    local map = GalaxyMap()
    local side = map:getCoordinatesScreenPosition(ivec2(0, 0))
    side = map:getCoordinatesScreenPosition(ivec2(1, 0)) - side
    local ex = math.floor(radius)
    local bx, by = -ex, 0
    local sx, sy = map:getCoordinatesScreenPosition(ivec2(bx, by))
    local cx1, cy1, cx2, cy2, tcy1, tcy2
    local y, k
    local x1, y1, ak = -ex, 0, 0
    local x2, y2 = -ex, 0
    local py = 0
    local tempColor
    if not color2 then
        color2 = color
    end
    local switchColor = 0
    for x = -ex, 1 do
        y = math.floor(math.sqrt(radius * radius - x * x))
        k = x ~= 0 and y / x or 0
        if k == ak and x <= 0 then
            x2, y2 = x, y
        elseif py ~= y or x >= 0 then
            if x1 ~= x2 or y1 ~= y2 then
                cx1 = sx + (x1 - bx) * side
                cy1 = sy + (by - y1) * side
                cx2 = sx + (x2 - bx) * side
                cy2 = sy + (by - y2) * side
                tcy1 = cy1
                tcy2 = cy2

                renderer:renderLine(vec2(cx1, cy1), vec2(cx2, cy2), color, layer)

                cy1 = sy + (by + y1) * side
                cy2 = sy + (by + y2) * side
                renderer:renderLine(vec2(cx1, cy1), vec2(cx2, cy2), color2, layer)

                cx1 = sx + (-x1 - bx) * side
                cx2 = sx + (-x2 - bx) * side
                renderer:renderLine(vec2(cx1, cy1), vec2(cx2, cy2), color, layer)

                cy1 = tcy1
                cy2 = tcy2
                renderer:renderLine(vec2(cx1, cy1), vec2(cx2, cy2), color2, layer)

                if colorSwitchStep then
                    if switchColor == colorSwitchStep then
                        tempColor = color
                        color = color2
                        color2 = tempColor
                        switchColor = 0
                    else
                        switchColor = switchColor + 1
                    end
                end
            end
            x1, y1 = x2, y2
            x2, y2 = x, y
            ak = k
        end
        py = y
    end
end

function GalaxyMapQoL.startFactionColorsCalculation()
    if factionColorsIsRunning then return end

    local code = [[
        package.path = package.path .. ";data/scripts/lib/?.lua"

        local PassageMap = include ("passagemap")

        function run(galaxy)
            local memoryUsage = collectgarbage("count") * 1024
            local t = HighResolutionTimer()
            t:start()

            local passageMap = PassageMap(GameSeed())
            local player = Player()
            local sectors
            if player.alliance and GalaxyMap().showAllianceInfo then
                sectors = {}
                for _, view in ipairs({player.alliance:getKnownSectors()}) do
                    if view.factionIndex > 0 and view.influence > 0 then
                        local x, y = view:getCoordinates()
                        sectors[ivec2(x, y)] = view
                    end
                end
                for _, view in ipairs({player:getKnownSectors()}) do
                    if view.factionIndex > 0 and view.influence > 0 then
                        local x, y = view:getCoordinates()
                        if not sectors[ivec2(x, y)] then
                            sectors[ivec2(x, y)] = view
                        end
                    end
                end
            else
                sectors = {player:getKnownSectors()}
            end
            local factions = {}
            local checkedSectors = {}
            for _, view in pairs(sectors) do
                if view.factionIndex > 0 then
                    local factionData = factions[view.factionIndex]
                    if not factionData then
                        factionData = { sectors = {} }
                        factions[view.factionIndex] = factionData
                    end
                    if not factionData.xy and not factionData.count then
                        local faction = Faction(view.factionIndex)
                        if faction.homeSectorUnknown then
                            factionData.x = 0
                            factionData.y = 0
                            factionData.count = 0
                        else
                            local x, y = faction:getHomeSectorCoordinates()
                            factionData.xy = vec2(x, y)
                        end
                    end
                    local x, y = view:getCoordinates()
                    if factionData.count then
                        factionData.x = factionData.x + x
                        factionData.y = factionData.y + y
                        factionData.count = factionData.count + 1
                    end
                    factionData.sectors[#factionData.sectors+1] = ivec2(x, y)
                    -- Find influenced sectors
                    if view.influence > 0 then
                        local radius = math.sqrt(view.influence / math.pi)
                        for i = 0, radius do
                            local posEnd = math.floor(math.sqrt(radius * radius - i * i) - 1.00001)
                            for j = 1, posEnd + 1 do
                                local coords = { {x + i, y + j}, {x + j, y - i}, {x - i, y - j}, {x - j, y + i} }
                                for _, pair in ipairs(coords) do
                                    local n = pair[1]
                                    local m = pair[2]
                                    if n > -499 and n < 500 and m > -499 and m < 500 and not checkedSectors[n.."_"..m] then
                                        checkedSectors[n.."_"..m] = true
                                        if passageMap:passable(n, m) and not player:knowsSector(n, m) then
                                            local factionIndex = galaxy:getControllingFaction(n, m)
                                            if factionIndex then
                                                local factionData = factions[view.factionIndex]
                                                if not factionData then
                                                    factions[view.factionIndex] = { sectors = { ivec2(n, m) } }
                                                else
                                                    factionData.sectors[#factionData.sectors+1] = ivec2(n, m)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            checkedSectors = nil

            local colors = {
              { c = ColorInt(0x4dFF0000), factions = {} }, -- Red
              { c = ColorInt(0x4d00FFFF), factions = {} }, -- Cyan
              { c = ColorInt(0x4d0000FF), factions = {} }, -- Blue
              { c = ColorInt(0x4d00FF00), factions = {} }, -- Green
              { c = ColorInt(0x4dFFFF00), factions = {} }, -- Yellow
              { c = ColorInt(0x4dFF00FF), factions = {} }, -- Magenta
              { c = ColorInt(0x4dA70000), factions = {} }, -- Maroon
              { c = ColorInt(0x4d008000), factions = {} }, -- Dark green
              { c = ColorInt(0x4d00006E), factions = {} }, -- Navy
              { c = ColorInt(0x4dFF8000), factions = {} }, -- Orange
              { c = ColorInt(0x4dFF3277), factions = {} }, -- Rose
              { c = ColorInt(0x4d007FFF), factions = {} }, -- Light blue
              { c = ColorInt(0x4d7FFF7F), factions = {} }, -- Light green
              { c = ColorInt(0x4d808000), factions = {} }, -- Frog
              { c = ColorInt(0x4d6E006E), factions = {} }, -- Dark violet
              { c = ColorInt(0x4d008080), factions = {} }, -- Sea waves
              { c = ColorInt(0x4d864C12), factions = {} }, -- Brown
              { c = ColorInt(0x4d90C8FF), factions = {} }, -- Ice
              { c = ColorInt(0x4dffffff), factions = {} }, -- White
              { c = ColorInt(0x4d8D1CFF), factions = {} }, -- Purple
              { c = ColorInt(0x4d005F3F), factions = {} }, -- Teal
              { c = ColorInt(0x4d808080), factions = {} }, -- Gray
            }
            -- Distribute colors across factions
            sectors = {}
            for index, factionData in pairs(factions) do
                if factionData.count then -- find average coordinates for homeless factions
                    factionData.xy = vec2(factionData.x / factionData.count, factionData.y / factionData.count)
                    factionData.x = nil
                    factionData.y = nil
                    factionData.count = nil
                end
                -- find furthest color
                local color
                local maxDist = 0
                for _, colorData in ipairs(colors) do
                    local minDist = math.huge
                    if #colorData.factions > 0 then -- find closest faction
                        for _, coloredFaction in ipairs(colorData.factions) do
                            local dist = distance(coloredFaction.xy, factionData.xy)
                            if dist < minDist then
                                minDist = dist
                            end
                        end
                        if minDist > maxDist then
                            maxDist = minDist
                            color = colorData
                        end
                    else -- color was never used before, use it immediately
                        color = colorData
                    end
                    if minDist == math.huge then break end
                end
                color.factions[#color.factions+1] = factionData
                for _, sector in ipairs(factionData.sectors) do
                    sectors[sector] = color.c
                end
            end

            galaxy = nil

            t:stop()
            t = t.secondsStr
            memoryUsage = collectgarbage("count") * 1024 - memoryUsage

            return sectors, t, memoryUsage
        end
    ]]

    async("onFactionColorsCalculated", code, Galaxy())

    factionColorsIsRunning = true
end

function GalaxyMapQoL.initOtherNamespace(namespace)
    customNamespace = namespace


    galaxyMapQoL_updateClient = namespace.updateClient
    namespace.updateClient = function(...)
        if galaxyMapQoL_updateClient then galaxyMapQoL_updateClient(...) end
        GalaxyMapQoL.updateClient(...)
    end

    namespace.galaxyMapQoL_onShowGalaxyMap = GalaxyMapQoL.galaxyMapQoL_onShowGalaxyMap
    namespace.galaxyMapQoL_onHideGalaxyMap = GalaxyMapQoL.galaxyMapQoL_onHideGalaxyMap
    namespace.galaxyMapQoL_onMapRenderAfterLayers = GalaxyMapQoL.galaxyMapQoL_onMapRenderAfterLayers
    namespace.galaxyMapQoL_onEditIconBtnPressed = GalaxyMapQoL.galaxyMapQoL_onEditIconBtnPressed
    namespace.galaxyMapQoL_onIconsFactionBoxChanged = GalaxyMapQoL.galaxyMapQoL_onIconsFactionBoxChanged
    namespace.galaxyMapQoL_onShowOverlayBoxChanged = GalaxyMapQoL.galaxyMapQoL_onShowOverlayBoxChanged
    namespace.galaxyMapQoL_onEditSelectedColorBtnPressed = GalaxyMapQoL.galaxyMapQoL_onEditSelectedColorBtnPressed
    namespace.galaxyMapQoL_onColorPickerApplyBtnPressed = GalaxyMapQoL.galaxyMapQoL_onColorPickerApplyBtnPressed
    namespace.galaxyMapQoL_onEditIconApplyBtnPressed = GalaxyMapQoL.galaxyMapQoL_onEditIconApplyBtnPressed
    namespace.galaxyMapQoL_onEditIconCancelBtnPressed = GalaxyMapQoL.galaxyMapQoL_onEditIconCancelBtnPressed
    namespace.galaxyMapQoL_onFactionColorsCheckBoxChecked = GalaxyMapQoL.galaxyMapQoL_onFactionColorsCheckBoxChecked

    GalaxyMapQoL.initialize()
end

return GalaxyMapQoL





