function Shop:buildGui(window, guiType, config) -- client
    config = config or {}

    local buttonCaption = ""
    local buttonCallback = ""

    local size = window.size
    local pos = window.lower

    local pictureX = 20
    local nameX = 60
    local favX = 455
    local materialX = 480
    local techX = 530
    local stockX = 590
    local priceX = 620
    local buttonX = 720
    local amountBoxX = buttonX

    if guiType == 0 then
        -- buying from the NPC
        buttonCaption = "Buy"%_t
        buttonCallback = "onBuyButtonPressed"
        window:createButton(Rect(0, 50 + 35 * 15, 70, 80 + 35 * 15), "<", "onSoldLeftButtonPressed")
        window:createButton(Rect(size.x - 70, 50 + 35 * 15, 60 + size.x - 60, 80 + 35 * 15), ">", "onSoldRightButtonPressed")
		
		self.pageLabel0 = window:createLabel(vec2(10, 50 + 35 * 15), "", 18)
        self.pageLabel0.lower = vec2(pos.x + 10, pos.y + 50 + 35 * 15)
        self.pageLabel0.upper = vec2(pos.x + size.x - 70, pos.y + 75)
        self.pageLabel0.centered = 1
		self.soldItemsPage = 0

    elseif guiType == 1 then
        -- selling to the NPC
        buttonCaption = "Sell"%_t
        buttonCallback = "onSellButtonPressed"

        window:createButton(Rect(0, 50 + 35 * 15, 70, 80 + 35 * 15), "<", "onLeftButtonPressed")
        window:createButton(Rect(size.x - 70, 50 + 35 * 15, 60 + size.x - 60, 80 + 35 * 15), ">", "onRightButtonPressed")

        self.pageLabel = window:createLabel(vec2(10, 50 + 35 * 15), "", 18)
        self.pageLabel.lower = vec2(pos.x + 10, pos.y + 50 + 35 * 15)
        self.pageLabel.upper = vec2(pos.x + size.x - 70, pos.y + 75)
        self.pageLabel.centered = 1

        self.reverseSellOrderButton = window:createButton(Rect(pictureX, -2, pictureX + 30, 30), "", "onReverseOrderPressed")
        self.reverseSellOrderButton.hasFrame = false
        self.reverseSellOrderButton.icon = "data/textures/icons/up-down.png"
        self.reverseSellOrder = false

        self.showFavoritesButton = window:createButton(Rect(favX, 3, favX + 18, 3+18), "", "onShowFavoritesPressed")
        self.showFavoritesButton.hasFrame = false
        self.showFavoritesButton.icon = "data/textures/icons/round-star.png"
        self.showFavoritesButton.tooltip = "Show Favorited Items"%_t
        self.showFavoritesButton.overlayIcon = "data/textures/icons/cross-mark.png"
        self.showFavoritesButton.overlayIcon = ""
        self.showFavoritesButton.overlayIconColor = ColorRGB(1, 0.3, 0.3)
        self.showFavoritesButton.overlayIconPadding = 0
        self.showFavoritesButton.overlayIconSizeFactor = 1
        self.showFavorites = true

        local x = favX - 30
        self.showTurretsButton = window:createButton(Rect(x, 0, x + 21, 21), "", "onShowTurretsPressed")
        self.showTurretsButton.hasFrame = false
        self.showTurretsButton.icon = "data/textures/icons/turret.png"
        self.showTurretsButton.tooltip = "Show Turrets"%_t
        self.showTurretsButton.overlayIcon = "data/textures/icons/cross-mark.png"
        self.showTurretsButton.overlayIcon = ""
        self.showTurretsButton.overlayIconColor = ColorRGB(1, 0.3, 0.3)
        self.showTurretsButton.overlayIconPadding = 0
        self.showTurretsButton.overlayIconSizeFactor = 1
        self.showTurrets = true

        local x = favX - 60
        self.showBlueprintsButton = window:createButton(Rect(x, 0, x + 21, 21), "", "onShowBlueprintsPressed")
        self.showBlueprintsButton.hasFrame = false
        self.showBlueprintsButton.icon = "data/textures/icons/turret-blueprint.png"
        self.showBlueprintsButton.tooltip = "Show Blueprints"%_t
        self.showBlueprintsButton.iconColor = ColorRGB(0.35, 0.7, 1.0)
        self.showBlueprintsButton.overlayIcon = "data/textures/icons/cross-mark.png"
        self.showBlueprintsButton.overlayIcon = ""
        self.showBlueprintsButton.overlayIconColor = ColorRGB(1, 0.3, 0.3)
        self.showBlueprintsButton.overlayIconPadding = 0
        self.showBlueprintsButton.overlayIconSizeFactor = 1
        self.showBlueprints = true

        local x = favX - 90
        self.showUpgradesButton = window:createButton(Rect(x, 0, x + 21, 21), "", "onShowUpgradesPressed")
        self.showUpgradesButton.hasFrame = false
        self.showUpgradesButton.icon = "data/textures/icons/circuitry.png"
        self.showUpgradesButton.tooltip = "Show Subsystems"%_t
        self.showUpgradesButton.overlayIcon = "data/textures/icons/cross-mark.png"
        self.showUpgradesButton.overlayIcon = ""
        self.showUpgradesButton.overlayIconColor = ColorRGB(1, 0.3, 0.3)
        self.showUpgradesButton.overlayIconPadding = 0
        self.showUpgradesButton.overlayIconSizeFactor = 1
        self.showUpgrades = true

        local x = favX - 120
        self.showDefaultItemsButton = window:createButton(Rect(x, 0, x + 21, 21), "", "onShowDefaultItemsPressed")
        self.showDefaultItemsButton.hasFrame = false
        self.showDefaultItemsButton.icon = "data/textures/icons/satellite.png"
        self.showDefaultItemsButton.tooltip = "Show Items"%_t
        self.showDefaultItemsButton.overlayIcon = "data/textures/icons/cross-mark.png"
        self.showDefaultItemsButton.overlayIcon = ""
        self.showDefaultItemsButton.overlayIconColor = ColorRGB(1, 0.3, 0.3)
        self.showDefaultItemsButton.overlayIconPadding = 0
        self.showDefaultItemsButton.overlayIconSizeFactor = 1
        self.showDefaultItems = true

        if config.hideFilterButtons then
            self.reverseSellOrderButton.active = false
            self.reverseSellOrderButton:hide()

            self.showFavoritesButton.active = false
            self.showFavoritesButton:hide()
            self.showTurretsButton.active = false
            self.showTurretsButton:hide()
            self.showBlueprintsButton.active = false
            self.showBlueprintsButton:hide()
            self.showUpgradesButton.active = false
            self.showUpgradesButton:hide()
            self.showDefaultItemsButton.active = false
            self.showDefaultItemsButton:hide()
        end

    else
        buttonCaption = "Buy"%_t
        buttonCallback = "onBuybackButtonPressed"
    end

    if config.showAmountBoxes then
        materialX = materialX - 70
        techX = techX - 70
        stockX = stockX - 70
        priceX = priceX - 70
        amountBoxX = buttonX - 70
    end

    if config.hideMaterialLabel then
        techX = materialX
    end

    -- header
    local headerY = 0
    if guiType == 0 and config.showSpecialOffer then
        local specialOfferY = 60

        local special = {}
        special.label = window:createLabel(vec2(nameX, 30), "SPECIAL OFFER (30% OFF)"%_t, 18)
        special.label.color = ColorRGB(1.0, 1.0, 0.1)

        special.timeLeftLabel = window:createLabel(vec2(materialX - 60, 30), "??"%_t, 15)
        special.timeLeftLabel.color = ColorRGB(0.5, 0.5, 0.5)
        special.timeLabel = window:createLabel(vec2(priceX, 30), "", 15)
        special.timeLabel.color = ColorRGB(0.5, 0.5, 0.5)

        special.icon = window:createPicture(Rect(pictureX, specialOfferY - 5, pictureX + 30, specialOfferY + 24), "")
        special.nameLabel = window:createLabel(vec2(nameX, specialOfferY), "", 15)
        special.materialLabel = window:createLabel(vec2(materialX, specialOfferY), "", 15)

        special.priceReductionLabel = window:createLabel(vec2(priceX + 40, specialOfferY + 18), "", 10)
        special.priceReductionLabel.color = ColorRGB(1, 1, 0)
        special.priceReductionLabel.caption = "${percentage} OFF!"%_t % {percentage = "30%"}

        special.stockLabel = window:createLabel(Rect(stockX, specialOfferY, priceX - 10, specialOfferY + 30), "", 15)
        special.stockLabel:setTopRightAligned()

        special.techLabel = window:createLabel(Rect(techX, specialOfferY, techX - 10, specialOfferY + 30), "", 15)
        special.techLabel:setTopRightAligned()

        special.priceLabel = window:createLabel(Rect(priceX, specialOfferY, amountBoxX - 20, specialOfferY + 30), "", 15)
        special.priceLabel:setTopRightAligned()

        special.button = window:createButton(Rect(buttonX, specialOfferY, 160 + buttonX, 30 + specialOfferY), "BUY NOW!"%_t, "onBuyButtonPressed")

        special.nameLabel.width = materialX - nameX
        special.nameLabel.shortenText = true
        special.icon.isIcon = 1
        special.button.maxTextSize = 15

        special.frame = window:createFrame(Rect(0, 25, buttonX - 10, 32 + specialOfferY))
        special.topFrame = window:createFrame(Rect(0, 23, buttonX - 10, 25))
        special.bottomFrame = window:createFrame(Rect(0, 32 + specialOfferY, buttonX - 10, 32 + specialOfferY + 2))
        special.leftFrame = window:createFrame(Rect(0, 25, 2, 32 + specialOfferY))
        special.rightFrame = window:createFrame(Rect(buttonX - 12, 25, buttonX - 10, 32 + specialOfferY))
        special.topFrame.backgroundColor = ColorARGB(0.4, 1.0, 1.0, 1.0)
        special.bottomFrame.backgroundColor = ColorARGB(0.4, 1.0, 1.0, 1.0)
        special.leftFrame.backgroundColor = ColorARGB(0.4, 1.0, 1.0, 1.0)
        special.rightFrame.backgroundColor = ColorARGB(0.4, 1.0, 1.0, 1.0)

        special.toSoldOut = function(self)
            special.icon:hide()
            special.nameLabel:hide()
            special.materialLabel:hide()
            special.priceLabel:hide()
            special.priceReductionLabel:hide()
            special.stockLabel:hide()
            special.button:hide()
            special.timeLeftLabel.caption = ""
            special.label.caption = "SOLD OUT!"%_t
        end

        special.show = function(self)
            special.icon:show()
            special.nameLabel:show()
            special.materialLabel:show()
            special.priceLabel:show()
            special.priceReductionLabel:show()
            special.stockLabel:show()
            special.button:show()
        end

        self.specialOfferUI = special

        headerY = 70
    end

    window:createLabel(vec2(nameX, 0), "NAME"%_t, 15)
    local materialLabel = window:createLabel(vec2(materialX, 0), "MAT"%_t, 15)
    if config.hideMaterialLabel then materialLabel:hide() end

    local techLabel = window:createLabel(Rect(techX, 0, stockX - 10, 30), "TECH"%_t, 15)
    techLabel:setTopAligned()
    local amountLabel = window:createLabel(Rect(stockX, 0, priceX - 10, 30), "#"%_t, 15)
    amountLabel:setTopRightAligned()
    local priceLabel = window:createLabel(Rect(priceX, 0, amountBoxX - 20, 30), "¢", 15)
    priceLabel:setTopRightAligned()

    if guiType == 0 then
        self.buyHeadlineAmountLabel = amountLabel
    elseif guiType == 1 then
        self.sellHeadlineAmountLabel = amountLabel
    elseif guiType == 2 then
        self.buybackHeadlineAmountLabel = amountLabel
    end

    local y = 35

    if guiType == 1 then
        self.sellTrashButton = window:createButton(Rect(buttonX, 0 + headerY, 160 + buttonX, 30 + headerY), "Sell Trash"%_t, "onSellTrashButtonPressed")
        self.sellTrashButton.maxTextSize = 15
    end

	local itemsPerPage = self.itemsPerPage
	if guiType == 0 then
		itemsPerPage = 13
	end
    for i = 1, itemsPerPage do

        local yText = y + 6 + headerY

        local line = {}
        line.frame = window:createFrame(Rect(0, y + headerY, amountBoxX - 10, 30 + y + headerY))

        line.nameLabel = window:createLabel(vec2(nameX, yText), "", 14)

        line.priceLabel = window:createLabel(vec2(priceX, yText), "", 14)
        line.priceReductionLabel = window:createLabel(vec2(priceX + 40, yText + 18), "", 10)
        line.priceReductionLabel.color = ColorRGB(1, 1, 0)
        line.priceReductionLabel.caption = "${percentage} OFF!"%_t % {percentage = "30%"}

        line.favoriteIcon = window:createPicture(Rect(favX, yText, favX + 18, yText + 18), "")
        line.materialLabel = window:createLabel(vec2(materialX, yText), "", 14)
        line.techLabel = window:createLabel(Rect(techX, yText, stockX - 10, yText + 30), "", 14)
        line.techLabel:setTopAligned()
        line.stockLabel = window:createLabel(Rect(stockX, yText, priceX - 10, yText + 30), "", 14)
        line.stockLabel:setTopRightAligned()
        line.priceLabel = window:createLabel(Rect(priceX, yText, amountBoxX - 20, yText + 30), "", 14)
        line.priceLabel:setTopRightAligned()

        line.button = window:createButton(Rect(buttonX, y + headerY, 160 + buttonX, 30 + y + headerY), buttonCaption, buttonCallback)
        line.icon = window:createPicture(Rect(pictureX, yText - 5, 29 + pictureX, 29 + yText - 5), "")
        line.background = window:createFrame(Rect(pictureX - 1, yText - 6, 30 + pictureX, 29 + yText - 5))
        line.background.backgroundColor = ColorRGB(0.05, 0.3, 0.5)

        if config.showAmountBoxes then
            line.amountBox = window:createTextBox(Rect(amountBoxX, y + headerY, 60 + amountBoxX, 30 + y + headerY), "onAmountEntered")
            line.amountBox.allowedCharacters = "0123456789"
            line.amountBox.text = "1"
        end

        line.nameLabel.width = favX - nameX
        line.nameLabel.shortenText = true

        line.button.maxTextSize = 15
        line.icon.isIcon = true
        line.favoriteIcon.isIcon = true

        if guiType == 0 then
            table.insert(self.soldItemLines, line)

        elseif guiType == 1 then
            table.insert(self.boughtItemLines, line)

        elseif guiType == 2 then
            table.insert(self.buybackItemLines, line)
        end

        line.hide = function(self)
            self.frame:hide()
            self.nameLabel:hide()
            self.priceLabel:hide()
            self.priceReductionLabel:hide()
            self.materialLabel:hide()
            self.techLabel:hide()
            self.stockLabel:hide()
            self.button:hide()
            self.icon:hide()
            self.background:hide()
            self.favoriteIcon:hide()

            if self.amountBox then self.amountBox:hide() end
        end

        line.show = function(self)
            self.frame:show()
            self.nameLabel:show()
            self.priceLabel:show()
            self.materialLabel:show()
            self.techLabel:show()
            self.stockLabel:show()
            self.button:show()
            self.icon:show()

            if self.amountBox then self.amountBox:show() end
        end

        y = y + 35
    end

end

function Shop:updateSellGui() -- client

    if not self.guiInitialized then return end

    for _, line in pairs(self.soldItemLines) do
        line:hide()
    end

    if self.specialOfferUI then
        self.specialOfferUI:toSoldOut()
    end

    local faction = Faction()
    local buyer = Player()
    local playerCraft = buyer.craft

    if playerCraft and playerCraft.factionIndex == buyer.allianceIndex then
        buyer = buyer.alliance
    end

    if #self.soldItems == 0 then
        local topLine = self.soldItemLines[1]
        topLine.nameLabel:show()
        topLine.nameLabel.color = ColorRGB(1.0, 1.0, 1.0)
        topLine.nameLabel.bold = false
        topLine.nameLabel.caption = "We are completely sold out."%_t
    end

    local numDifferentItems = #self.soldItems
	local itemsPerPage = 13

    while self.soldItemsPage * itemsPerPage >= numDifferentItems do
        self.soldItemsPage = self.soldItemsPage - 1
    end

    if self.soldItemsPage < 0 then
        self.soldItemsPage = 0
    end

    local itemStart = self.soldItemsPage * itemsPerPage + 1
    local itemEnd = math.min(numDifferentItems, itemStart + itemsPerPage -1)
	
	self.pageLabel0.caption = itemStart .. " - " .. itemEnd .. " / " .. numDifferentItems
	local uiIndex = 1

	for index = itemStart, itemEnd do

        local item = self.soldItems[index]
        if item == nil then break end

        local line = self.soldItemLines[uiIndex]
        uiIndex = uiIndex + 1
        line:show()

        line.nameLabel.caption = item:getName()%_t
        line.nameLabel.color = item.rarity.color
        line.nameLabel.bold = false

        if item.material then
            line.materialLabel.caption = item.material.name
            line.materialLabel.color = item.material.color
        else
            line.materialLabel:hide()
        end

        if item.icon then
            line.icon.picture = item.icon
            line.icon.color = item.rarity.color
        end

        local price = self:getSellPriceAndTax(item.price, faction, buyer)
        line.priceLabel.caption = createMonetaryString(price)

        if self.priceRatio < 1 then
            line.priceReductionLabel:show()
            line.priceReductionLabel.caption = "${percentage} OFF!"%_t % {percentage = tostring(round((1 - self.priceRatio) * 100)) .. "%"}
        else
            line.priceReductionLabel:hide()
        end

        line.stockLabel.caption = item.amount
        line.techLabel.caption = item.tech or ""

        line.item = item
		line.itemIndex = index
        
        local msg, args = self:canBeBought(item, playerCraft, buyer)
        if msg then
            line.button.active = false
            line.button.tooltip = string.format(msg%_t, unpack(args or {}))
        else
            line.button.active = true
            line.button.tooltip = nil
        end
    end

    -- update the special offer frame
    local item = self.specialOffer.item
    if item then

        local specialUI = self.specialOfferUI
        specialUI:show()

        local special = self.specialOffer
        specialUI.nameLabel.caption = item.name%_t
        specialUI.nameLabel.color = item.rarity.color
        specialUI.nameLabel.bold = false

        if item.material then
            specialUI.materialLabel.caption = item.material.name
            specialUI.materialLabel.color = item.material.color
        else
            specialUI.materialLabel:hide()
        end

        if item.icon then
            specialUI.icon.picture = item.icon
            specialUI.icon.color = item.rarity.color
        end

        if item.amount then
            specialUI.stockLabel.caption = item.amount
        end

        specialUI.techLabel.caption = item.tech or ""

        specialUI.timeLeftLabel.caption = "LIMITED TIME OFFER!"%_t
        specialUI.label.caption = "SPECIAL OFFER: -30% OFF"%_t

        -- for now, specialPrice is just 70% of the regular price
        -- if this gets changed, it must be changed in <Shop:sellToPlayer> also!
        local price = self:getSellPriceAndTax(item.price, faction, buyer)
        local specialPrice = price * 0.7
        specialUI.priceLabel.caption = createMonetaryString(specialPrice)
        specialUI.priceReductionLabel.caption = "${percentage} OFF!"%_t % {percentage = "30%"}

        local msg, args = self:canBeBought(item, playerCraft, buyer)
        if msg then
            specialUI.button.active = false
            specialUI.button.tooltip = string.format(msg%_t, unpack(args or {}))
        else
            specialUI.button.active = true
            specialUI.button.tooltip = nil
        end
    end
end


function Shop:onSoldLeftButtonPressed()
    self.soldItemsPage = self.soldItemsPage - 1
    self:updateSellGui()
end

function Shop:onSoldRightButtonPressed()
    self.soldItemsPage = self.soldItemsPage + 1
    self:updateSellGui()
end


function Shop:onBuyButtonPressed(button) -- client
    -- check if regular item (shop = 0) or special offer item (shop = 1) was bought
    local itemIndex = 0
    local specialOffer

    for i, line in pairs(self.soldItemLines) do
        if button.index == line.button.index then
            itemIndex = i
        end
    end

    if self.specialOfferUI then
        if button.index == self.specialOfferUI.button.index then
            itemIndex = 1
            specialOffer = true
        end
    end

    local amount = 1
    local line = self.soldItemLines[itemIndex]
    if line and line.amountBox then
        amount = tonumber(line.amountBox.text) or 0
    end

    invokeServerFunction("sellToPlayer", line.itemIndex, specialOffer, amount)
end


function Shop:onMouseEvent(key, pressed, x, y)
    if not pressed then return false end
    if not self.guiInitialized then return false end
    if not self.shared.window.visible then return false end
    if not self.tabbedWindow.visible then return false end


    if self.tabbedWindow:getActiveTab().index == self.buyTab.index then
        if not (Keyboard():keyPressed(KeyboardKey.LControl) or Keyboard():keyPressed(KeyboardKey.RControl)) then return false end

        for i, line in pairs(self.soldItemLines) do
            local frame = line.frame
 
            if line.item ~= nil then
                if frame.visible then

                    local l = frame.lower
                    local u = frame.upper

                    if x >= l.x and x <= u.x then
                    if y >= l.y and y <= u.y then
                        Player():sendChatMessage(line.item)
                        return true
                    end
                    end
                end
            end
        end

        if self.specialOffer.item then
            local l = self.specialOfferUI.frame.lower
            local u = self.specialOfferUI.frame.upper

            if x >= l.x and x <= u.x then
            if y >= l.y and y <= u.y then
                Player():sendChatMessage(self.specialOffer.item.item)
            end
            end
        end

    elseif self.tabbedWindow:getActiveTab().index == self.sellTab.index then

        for i, line in pairs(self.boughtItemLines) do

            if line.item ~= nil then
                if Keyboard():keyPressed(KeyboardKey.LControl) or Keyboard():keyPressed(KeyboardKey.RControl) then
                    local frame = line.frame
                    if frame.visible then

                        local l = frame.lower
                        local u = frame.upper

                        if x >= l.x and x <= u.x then
                        if y >= l.y and y <= u.y then
                            Player():sendChatMessage(line.item.item)
                            return true
                        end
                        end
                    end
                else
                    local icon = line.favoriteIcon

                    local l = icon.lower
                    local u = icon.upper

                    if x >= l.x and x <= u.x then
                    if y >= l.y and y <= u.y then
                        invokeServerFunction("cycleTags", line.item.index)
                        return true
                    end
                    end
                end
            end
        end

    elseif self.tabbedWindow:getActiveTab().index == self.buyBackTab.index then
        if not (Keyboard():keyPressed(KeyboardKey.LControl) or Keyboard():keyPressed(KeyboardKey.RControl)) then return false end

        for i, line in pairs(self.buybackItemLines) do
            local frame = line.frame

            if self.buybackItems[i] ~= nil then
                if frame.visible then

                    local l = frame.lower
                    local u = frame.upper

                    if x >= l.x and x <= u.x then
                    if y >= l.y and y <= u.y then
                        Player():sendChatMessage(self.buybackItems[i].item)
                        return true
                    end
                    end
                end
            end
        end
    end
end


function Shop:onKeyboardEvent(key, pressed)

    if not pressed then return false end
    if key ~= KeyboardKey._E then return false end
    if not self.guiInitialized then return false end
    if not self.shared.window.visible then return false end
    if not self.tabbedWindow.visible then return false end

    local mouse = Mouse().position

    if self.tabbedWindow:getActiveTab().index == self.buyTab.index then
        for i, line in pairs(self.soldItemLines) do
            local frame = line.frame

            if line.item ~= nil then
                if frame.visible then

                    local l = frame.lower
                    local u = frame.upper

                    if mouse.x >= l.x and mouse.x <= u.x then
                    if mouse.y >= l.y and mouse.y <= u.y then
                        Player():addComparisonItem(line.item)
                    end
                    end
                end
            end
        end

        if self.specialOffer.item then
            local l = self.specialOfferUI.frame.lower
            local u = self.specialOfferUI.frame.upper

            if mouse.x >= l.x and mouse.x <= u.x then
            if mouse.y >= l.y and mouse.y <= u.y then
                Player():addComparisonItem(self.specialOffer.item.item)
            end
            end
        end

    elseif self.tabbedWindow:getActiveTab().index == self.sellTab.index then

        for i, line in pairs(self.boughtItemLines) do
            local frame = line.frame

            if line.item ~= nil then
                if frame.visible then

                    local l = frame.lower
                    local u = frame.upper

                    if mouse.x >= l.x and mouse.x <= u.x then
                    if mouse.y >= l.y and mouse.y <= u.y then
                        Player():addComparisonItem(line.item.item)
                    end
                    end
                end
            end
        end

    elseif self.tabbedWindow:getActiveTab().index == self.buyBackTab.index then

        for i, line in pairs(self.buybackItemLines) do
            local frame = line.frame

            if self.buybackItems[i] ~= nil then
                if frame.visible then

                    local l = frame.lower
                    local u = frame.upper

                    if mouse.x >= l.x and mouse.x <= u.x then
                    if mouse.y >= l.y and mouse.y <= u.y then
                        Player():addComparisonItem(self.buybackItems[i].item)
                    end
                    end
                end
            end
        end

    end
end

function Shop:renderUI()
    if not self.tabbedWindow.mouseOver then return end

    local mouse = Mouse().position

    if self.tabbedWindow:getActiveTab().index == self.buyTab.index then
        for i, line in pairs(self.soldItemLines) do
            local frame = line.frame

            if line.item ~= nil then
                if frame.visible then

                    local l = frame.lower
                    local u = frame.upper

                    if mouse.x >= l.x and mouse.x <= u.x then
                    if mouse.y >= l.y and mouse.y <= u.y then
                        local renderer = TooltipRenderer(line.item:getTooltip())
                        renderer:drawMouseTooltip(Mouse().position)
                    end
                    end
                end
            end
        end

        if self.specialOffer.item then
            local l = self.specialOfferUI.frame.lower
            local u = self.specialOfferUI.frame.upper

            if mouse.x >= l.x and mouse.x <= u.x then
            if mouse.y >= l.y and mouse.y <= u.y then
                local renderer = TooltipRenderer(self.specialOffer.item:getTooltip())
                renderer:drawMouseTooltip(Mouse().position)
            end
            end
        end

    elseif self.tabbedWindow:getActiveTab().index == self.sellTab.index then

        for i, line in pairs(self.boughtItemLines) do
            local frame = line.frame

            if line.item ~= nil then
                if frame.visible then

                    local l = frame.lower
                    local u = frame.upper

                    if mouse.x >= l.x and mouse.x <= u.x then
                    if mouse.y >= l.y and mouse.y <= u.y then
                        local renderer = TooltipRenderer(line.item:getTooltip())
                        renderer:drawMouseTooltip(Mouse().position)
                    end
                    end
                end
            end
        end

    elseif self.tabbedWindow:getActiveTab().index == self.buyBackTab.index then

        for i, line in pairs(self.buybackItemLines) do
            local frame = line.frame

            if self.buybackItems[i] ~= nil then
                if frame.visible then

                    local l = frame.lower
                    local u = frame.upper

                    if mouse.x >= l.x and mouse.x <= u.x then
                    if mouse.y >= l.y and mouse.y <= u.y then
                        local renderer = TooltipRenderer(self.buybackItems[i]:getTooltip())
                        renderer:drawMouseTooltip(Mouse().position)
                    end
                    end
                end
            end
        end

    end
end

function PublicNamespace.CreateNamespace()
    local result = {}

    local shop = PublicNamespace.CreateShop()

    shop.shared = PublicNamespace
    result.shop = shop
    result.onShowWindow = function(...) return shop:onShowWindow(...) end
    result.sendItems = function(...) return shop:sendItems(...) end
    result.receiveSoldItems = function(...) return shop:receiveSoldItems(...) end
    result.sellToPlayer = function(...) return shop:sellToPlayer(...) end
    result.buyFromPlayer = function(...) return shop:buyFromPlayer(...) end
    result.buyTrashFromPlayer = function(...) return shop:buyTrashFromPlayer(...) end
    result.sellBackToPlayer = function(...) return shop:sellBackToPlayer(...) end
    result.updateBoughtItem = function(...) return shop:updateBoughtItem(...) end
    result.onLeftButtonPressed = function(...) return shop:onLeftButtonPressed(...) end
    result.onRightButtonPressed = function(...) return shop:onRightButtonPressed(...) end
	
	result.onSoldLeftButtonPressed = function(...) return shop:onSoldLeftButtonPressed(...) end
    result.onSoldRightButtonPressed = function(...) return shop:onSoldRightButtonPressed(...) end
	
    result.onAmountEntered = function(...) return shop:onAmountEntered(...) end
    result.onBuyButtonPressed = function(...) return shop:onBuyButtonPressed(...) end
    result.onSellButtonPressed = function(...) return shop:onSellButtonPressed(...) end
    result.onSellTrashButtonPressed = function(...) return shop:onSellTrashButtonPressed(...) end
    result.onShowFavoritesPressed = function(...) return shop:onShowFavoritesPressed(...) end
    result.onShowTurretsPressed = function(...) return shop:onShowTurretsPressed(...) end
    result.onShowBlueprintsPressed = function(...) return shop:onShowBlueprintsPressed(...) end
    result.onShowUpgradesPressed = function(...) return shop:onShowUpgradesPressed(...) end
    result.onShowDefaultItemsPressed = function(...) return shop:onShowDefaultItemsPressed(...) end
    result.onReverseOrderPressed = function(...) return shop:onReverseOrderPressed(...) end
    result.cycleTags = function(...) return shop:cycleTags(...) end
    result.onBuybackButtonPressed = function(...) return shop:onBuybackButtonPressed(...) end
    result.renderUI = function(...) return shop:renderUI(...) end
    result.onMouseEvent = function(...) return shop:onMouseEvent(...) end
    result.onKeyboardEvent = function(...) return shop:onKeyboardEvent(...) end
    result.add = function(...) return shop:add(...) end
    result.restock = function(...) return shop:restock(...) end

    result.setSpecialOffer = function(...) return shop:setSpecialOffer(...) end
    result.onSpecialOfferSeedChanged = function(...) return shop:onSpecialOfferSeedChanged(...) end
    result.calculateSeed = function (...) return shop:calculateSeed(...) end
    result.generateSeed = function (...) return shop:generateSeed(...) end
    result.setStaticSeed = function(...) return shop:setStaticSeed(...) end
    result.updateClient = function(...) return shop:updateClient(...) end
    result.updateServer = function(...) return shop:updateServer(...) end

    result.getUpdateInterval = function(...) return shop:getUpdateInterval(...) end
    result.updateSellGui = function(...) return shop:updateSellGui(...) end
    result.broadcastItems = function(...) return shop:broadcastItems(...) end
    result.addFront = function(...) return shop:addFront(...) end
    result.getBuyPrice = function(...) return shop:getBuyPrice(...) end
    result.getNumSoldItems = function() return shop:getNumSoldItems() end
    result.getNumBuybackItems = function() return shop:getNumBuybackItems() end
    result.getSoldItemPrice = function(...) return shop:getSoldItemPrice(...) end
    result.getBoughtItemPrice = function(...) return shop:getBoughtItemPrice(...) end
    result.getTax = function() return shop:getTax() end
    result.getSoldItems = function() return shop:getSoldItems() end
    result.getSpecialOffer = function() return shop:getSpecialOffer() end

    -- the following comment is important for a unit test
    -- Dynamic Namespace result
    callable(result, "buyFromPlayer")
    callable(result, "buyTrashFromPlayer")
    callable(result, "sellBackToPlayer")
    callable(result, "sellToPlayer")
    callable(result, "cycleTags")
    callable(result, "sendItems")
    callable(result, "generateSeed")
    callable(result, "updateServer")
    callable(result, "onSpecialOfferSeedChanged")

    return result
end

local edr_buildBuyGui, edr_CreateNamespace -- extended functions
local edr_restockButton                    -- UI
local edr_specialOfferSeed = 0             -- restock the special offer

-- Handle the actual restocking part
if onServer() then
    edr_generateSeed = Shop.generateSeed
    function Shop:generateSeed(...)
        if self.staticSeed then
            return edr_generateSeed(self, ...)
        else
            return edr_generateSeed(self, ...) .. edr_specialOfferSeed
        end
    end

    function Shop:remoteRestock()
        edr_specialOfferSeed = edr_specialOfferSeed + 1
        self:restock()
    end

    edr_CreateNamespace = PublicNamespace.CreateNamespace
    function PublicNamespace.CreateNamespace(...)
        local result = edr_CreateNamespace(...)

        result.remoteRestock = function(...) return result.shop:remoteRestock(...) end

        callable(result, "remoteRestock")

        return result
    end
end

-- Add the button to trigger a restock
if onClient() then
    edr_buildBuyGui = Shop.buildBuyGui
    function Shop:buildBuyGui(tab, config, ...)
        edr_buildBuyGui(self, tab, config, ...)

        -- Defined within the BuildGui function in shop.lua for the Buy buttons
        local x = 720

        edr_restockButton = tab:createButton(Rect(x, 0, x + 160, 30), "", "edr_onRestockButtonPressed")
        edr_restockButton.icon = "data/textures/icons/clockwise-rotation.png"
        edr_restockButton.tooltip = "Restock the shop" % _t
    end

    function Shop:edr_onRestockButtonPressed(button)
        invokeServerFunction("remoteRestock")
    end

    edr_CreateNamespace = PublicNamespace.CreateNamespace
    function PublicNamespace.CreateNamespace(...)
        local result = edr_CreateNamespace(...)

        result.edr_onRestockButtonPressed = function(...) return result.shop:edr_onRestockButtonPressed(...) end

        return result
    end
end
