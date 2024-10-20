function TransferCrewGoods.onShowWindow()
	local player = Player()
	local ship = Entity()
	local other = player.craft

	ship:registerCallback("onCrewChanged", "onCrewChanged")
	ship:registerCallback("onCaptainChanged", "onCrewChangedRefreshUI")
	ship:registerCallback("onPassengerAdded", "onCrewChangedRefreshUI")
	ship:registerCallback("onPassengerRemoved", "onCrewChangedRefreshUI")
	ship:registerCallback("onPassengersRemoved", "onCrewChangedRefreshUI")
	other:registerCallback("onCrewChanged", "onCrewChanged")
	other:registerCallback("onCaptainChanged", "onCrewChangedRefreshUI")
	other:registerCallback("onPassengerAdded", "onCrewChangedRefreshUI")
	other:registerCallback("onPassengerRemoved", "onCrewChangedRefreshUI")
	other:registerCallback("onPassengersRemoved", "onCrewChangedRefreshUI")

	-- set all textboxes to default values
	for _, box in pairs(playerCrewTextBoxes) do
		box.text = "1"
	end
	for _, box in pairs(selfCrewTextBoxes) do
		box.text = "1"
	end
	for _, box in pairs(playerCargoTextBoxes) do
		box.text = ""
	end
	for _, box in pairs(selfCargoTextBoxes) do
		box.text = ""
	end

	TransferCrewGoods.refreshUI()
end


function goodColor(good)
    if good.illegal then
        return ColorRGB(0.8, 0, 0)
    end
    if good.dangerous then
        return ColorRGB(0.8, 0.8, 0)
    end
    if good.stolen then
        return ColorRGB(0.6, 0, 0.6)
    end
    if good.suspicious then
        return ColorRGB(0, 0.7, 0.8)
    end
    return ColorRGB(0.8, 0.8, 0.8)
end


function TransferCrewGoods.onPlayerTransferCargoPressed(button)
    -- transfer cargo from player ship to self
	
    -- get amount
    local textboxIndex = textboxIndexByButton[button.index]
    if not textboxIndex then return end
	
    local box = TextBox(textboxIndex)
    if not box then return end
	
    local amount = tonumber(box.text) or 0
    if amount < 1 then return end
	
    invokeServerFunction("transferCargoByName", button.tooltip, Player().craftIndex, false, amount)
end


function TransferCrewGoods.onSelfTransferCargoPressed(button)
    -- transfer cargo from self to player ship

    -- get amount
    local textboxIndex = textboxIndexByButton[button.index]
    if not textboxIndex then return end

    local box = TextBox(textboxIndex)
    if not box then return end

    local amount = tonumber(box.text) or 0
    if amount < 1 then return end

    invokeServerFunction("transferCargoByName", button.tooltip, Player().craftIndex, true, amount)
end


function TransferCrewGoods.transferCargoByName(cargoName, otherIndex, selfToOther, amount)
    local sender
    local receiver

    if selfToOther then
        sender = Entity()
        receiver = Entity(otherIndex)
    else
        sender = Entity(otherIndex)
        receiver = Entity()
    end

    local player = Player(callingPlayer)
    if not player then return end

    if not TransferCrewGoods.checkPermissionsAndDistance(player, sender, receiver) then return end

    -- get the cargo
	local good, availableAmount
    for cargo, amount in pairs(sender:getCargos()) do
		if cargo:displayName(1) == cargoName then
			good = cargo
			availableAmount = amount
		end
	end

    -- make sure sending ship has the cargo
    if not good or not availableAmount then return end
    amount = math.min(amount, availableAmount)

    -- make sure receiving ship has enough space
    if receiver.freeCargoSpace < good.size * amount then
		local fitting = math.floor(receiver.freeCargoSpace / good.size)
		amount = fitting
		-- print(string.format("Free: %s - Size: %s - Amount: %s - Total: %s - Fitting: %s", receiver.freeCargoSpace, good.size, amount, good.size * amount, fitting))
        -- player:sendChatMessage("", 1, "Not enough space on the other craft."%_t)
        -- return
    end

    -- transfer
    sender:removeCargo(good, amount)
    receiver:addCargo(good, amount)

    invokeClientFunction(player, "refreshUI")
end
callable(TransferCrewGoods, "transferCargoByName")


function TransferCrewGoods.onPlayerTransferCargoTextEntered(textBox)
    local enteredNumber = tonumber(textBox.text)
    if enteredNumber == nil then
        enteredNumber = 0
    end

    local newNumber = enteredNumber

    -- get available amount
    local cargoName = cargosByTextBox[textBox.index]
    if not cargoName then return end

    newNumber = math.min(newNumber, TransferCrewGoods.playerAmountByIndex[cargoName])

    if newNumber ~= enteredNumber then
        textBox.text = newNumber
    end
end


function TransferCrewGoods.onSelfTransferCargoTextEntered(textBox)
    local enteredNumber = tonumber(textBox.text)
    if enteredNumber == nil then
        enteredNumber = 0
    end

    local newNumber = enteredNumber

    -- get available amount
    local cargoName = cargosByTextBox[textBox.index]
    if not cargoName then return end

    newNumber = math.min(newNumber, TransferCrewGoods.selfAmountByIndex[cargoName])

    if newNumber ~= enteredNumber then
        textBox.text = newNumber
    end
end

TransferCrewGoods.ftw_onPlayerTransferAllCargoPressed = TransferCrewGoods.onPlayerTransferAllCargoPressed
function TransferCrewGoods.onPlayerTransferAllCargoPressed(button)
	if Mouse():mousePressed(3) then
		invokeServerFunction("stackAllCargo", Player().craftIndex, false)
	else
    	TransferCrewGoods.ftw_onPlayerTransferAllCargoPressed()
	end
end

TransferCrewGoods.ftw_onSelfTransferAllCargoPressed = TransferCrewGoods.onSelfTransferAllCargoPressed
function TransferCrewGoods.onSelfTransferAllCargoPressed(button)
	if Mouse():mousePressed(3) then
		invokeServerFunction("stackAllCargo", Player().craftIndex, true)
	else
    	TransferCrewGoods.ftw_onSelfTransferAllCargoPressed()
	end
end

function TransferCrewGoods.stackAllCargo(otherIndex, selfToOther)
    local sender
    local receiver

    if selfToOther then
        sender = Entity()
        receiver = Entity(otherIndex)
    else
        sender = Entity(otherIndex)
        receiver = Entity()
    end

    local player = Player(callingPlayer)
    if not player then return end

    if not TransferCrewGoods.checkPermissionsAndDistance(player, sender, receiver) then return end

    -- get the cargo
    local selfCargos = {}
	local otherCargos = {}
	local stackCargos = {}
	
	-- remapping the data because UserData can NOT be used as a table key because it does NOT evaluate to TRUE when compared to an identical copy of itself
	for good, amount in pairs(sender:getCargos()) do
		selfCargos[good:displayName(1)] = { good = good, amount = amount }
	end
	for good, amount in pairs(receiver:getCargos()) do
		otherCargos[good:displayName(1)] = { good = good, amount = amount }
	end
	
	local cargos = {}
    local cargoTransferred = false
	
	for goodName, data in pairs(selfCargos) do
		if otherCargos[goodName] then
			cargos[data.good] = data.amount
		end
	end

	-- printTable(cargos)

    for good, amount in pairs(cargos) do
		-- make sure receiving ship has enough space
		if receiver.freeCargoSpace < good.size * amount then
			-- transfer as much as possible
			amount = math.floor(receiver.freeCargoSpace / good.size)

			if amount == 0 then
				player:sendChatMessage("", 1, "Not enough space on the other craft."%_t)
				break;
			end
		end

		-- transfer
		sender:removeCargo(good, amount)
		receiver:addCargo(good, amount)
		cargoTransferred = true
    end

    if cargoTransferred then
        invokeClientFunction(player, "refreshUI")
    end
end
callable(TransferCrewGoods, "stackAllCargo")


TransferCrewGoods.playerAmountByIndex = {}
TransferCrewGoods.selfAmountByIndex = {}
function TransferCrewGoods.refreshCargoUI(playerShip, ship)
	-- update cargo info
	playerTotalCargoBar:clear()
	selfTotalCargoBar:clear()

	playerTotalCargoBar:setRange(0, playerShip.maxCargoSpace)
	selfTotalCargoBar:setRange(0, ship.maxCargoSpace)

	-- restore textbox values
	TransferCrewGoods.playerAmountByIndex = {}
	TransferCrewGoods.selfAmountByIndex = {}
	--[[ 
	for cargoName, index in pairs(playerCargoTextBoxByIndex) do
		TransferCrewGoods.playerAmountByIndex[cargoName] = playerCargoTextBoxes[index].text
	end
	for cargoName, index in pairs(selfCargoTextBoxByIndex) do
		TransferCrewGoods.selfAmountByIndex[cargoName] = selfCargoTextBoxes[index].text
	end
	]]

	local playerCargo = {}
	local selfCargo = {}
	playerCargoTextBoxByIndex = {}
	selfCargoTextBoxByIndex = {}

	local index = 1
	for good, amount in pairs(playerShip:getCargos()) do
		local goodName = good:displayName(1)
		table.insert(playerCargo, { name = goodName, good = good, amount = amount, index = index })
		TransferCrewGoods.playerAmountByIndex[goodName] = amount
		index = index + 1
	end
	-- for i,g in ipairs(playerCargo) do
	-- print(string.format("Player: %s x %s", g.amount, g:displayName(1)))
	-- end
	table.sort(playerCargo, function(a,b) return a.name < b.name end)
	
	local index = 1
	for good, amount in pairs(ship:getCargos()) do
		local goodName = good:displayName(1)
		table.insert(selfCargo, { name = goodName, good = good, amount = amount, index = index })
		TransferCrewGoods.selfAmountByIndex[goodName] = amount
		index = index + 1
	end
	-- for i,g in ipairs(selfCargo) do
		-- print(string.format("Traded: %s x %s", g.amount, g:displayName(1)))
	-- end
	table.sort(selfCargo, function(a,b) return a.name < b.name end)

	for i, _ in pairs(playerCargoBars) do
		local icon = playerCargoIcons[i]
		local bar = playerCargoBars[i]
		local button = playerCargoButtons[i]
		local box = playerCargoTextBoxes[i]

		if i > playerShip.numCargos then
			icon:hide()
			bar:hide()
			button:hide()
			box:hide()
		else
			icon:show()
			bar:show()
			button:show()
			
			local cargo = playerCargo[i] 
			local good = cargo.good
			local goodName = good:displayName(1)
			local amount = cargo.amount
			local maxSpace = playerShip.maxCargoSpace
			local color = goodColor(good)
			playerCargoName[i] = goodName
			icon.picture = good.icon
			icon.color = color
			bar:setRange(0, maxSpace)
			bar.value = amount * good.size
			bar.color = color

			button.tooltip = goodName

			-- restore textbox value
			if not box.isTypingActive then
				local boxAmount = TransferCrewGoods.clampNumberString(TransferCrewGoods.playerAmountByIndex[goodName] or amount, amount)
				playerCargoTextBoxByIndex[goodName] = box.index
				cargosByTextBox[box.index] = goodName
				box:show()
				if boxAmount == "" then
					box.text = amount
				else
					box.text = boxAmount
				end
			end

			local name = "${amount} ${good}"%_t % {amount = createMonetaryString(amount), good = good:displayName(amount)}
			bar.name = name
			playerTotalCargoBar:addEntry(amount * good.size, name, color)
		end


		local icon = selfCargoIcons[i]
		local bar = selfCargoBars[i]
		local button = selfCargoButtons[i]
		local box = selfCargoTextBoxes[i]

		if i > ship.numCargos then
			icon:hide()
			bar:hide()
			button:hide()
			box:hide()
		else
			icon:show()
			bar:show()
			button:show()
			
			local cargo = selfCargo[i] 
			local good = cargo.good
			local goodName = good:displayName(1)
			local amount = cargo.amount
			local maxSpace = ship.maxCargoSpace
			local color = goodColor(good)
			selfCargoName[i] = goodName
			icon.picture = good.icon
			icon.color = color
			bar:setRange(0, maxSpace)
			bar.value = amount * good.size
			bar.color = color
			
			button.tooltip = goodName

			-- restore textbox value
			if not box.isTypingActive then
				local boxAmount = TransferCrewGoods.clampNumberString(TransferCrewGoods.selfAmountByIndex[goodName] or amount, amount)
				selfCargoTextBoxByIndex[goodName] = box.index
				cargosByTextBox[box.index] = goodName
				box:show()
				if boxAmount == "" then
					box.text = amount
				else
					box.text = boxAmount
				end
			end

			local name = "${amount} ${good}"%_t % {amount = createMonetaryString(amount), good = good:displayName(amount)}
			bar.name = name
			selfTotalCargoBar:addEntry(amount * good.size, name, color)
		end
	end
end
