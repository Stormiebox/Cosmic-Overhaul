package.path = package.path .. ";data/scripts/lib/?.lua"

--namespace shipinfo
shipinfo = {}

local ships = {}

if onClient() then

	local tab, lister, frame, rowList, update, coordinates

	function shipinfo.initialize()

		rowList = {}
		tab = PlayerWindow():createTab("ShipInfo", "data/textures/icons/rss.png", "Ship Info")

		local hSplit = UIHorizontalSplitter(Rect(tab.size), 10, 0, 0.03)
		local vSplit = UIVerticalMultiSplitter(hSplit.top, 0, 0, 2)
		vSplit.marginLeft = 5
		vSplit.marginRight = 20
		local vSplit2 = UIVerticalMultiSplitter(vSplit:partition(2), 0, 0, 1)
		tab:createLabel(vSplit:partition(0), "Ship", 16)
		tab:createLabel(vSplit:partition(1), "Hull/Shield", 16)
		tab:createLabel(vSplit2:partition(0), "Cargo", 16)
		tab:createLabel(vSplit2:partition(1), "Type", 16)

		frame = tab:createScrollFrame(hSplit.bottom)
		frame.scrollSpeed = 40

		lister = UIVerticalLister(Rect(frame.size), 0, 5)
		lister.marginRight = 32

		Player():registerCallback("onPreRenderHud", "handlePreRenderHud")
	end

	local updateTimer = 0
	function shipinfo.update(timeStep)
		if updateTimer <= 0 then
			update = true
			updateTimer = 0.5
		else
			updateTimer = updateTimer - timeStep
		end
	end

	function shipinfo.handlePreRenderHud(state)
    
		if update == true then
			local player = Player()
			
			local shipsCount = tablelength(ships)
			local rowCount = tablelength(rowList)			
			
			local num = 0
			if shipsCount > rowCount then
				for key, ship in pairs (ships) do
					if ship ~= nil then
						if rowList[num] == nil then
							local rect = lister:placeRight(vec2(lister.inner.width, 25))

							rowList[num] = {}

							local vSplit = UIVerticalMultiSplitter(rect, 10, 0, 2)
							local vSplit2 = UIVerticalMultiSplitter(vSplit:partition(2), 0, 0, 1)
							rowList[num]["nameLabel"] = frame:createLabel(vSplit:partition(0), "*Ship*", 16)
							rowList[num]["statusLabel"] = frame:createLabel(vSplit:partition(1), "*Status*", 16)
							rowList[num]["percentLabel"] = frame:createLabel(vSplit2:partition(0), "*Cargo*", 16)
							rowList[num]["typeIcon"] = frame:createPicture(vSplit2:partition(1), "data/textures/icons/player.png")
							rowList[num]["typeIcon"].isIcon = true
							rowList[num]["typeIcon"].height = 20
							rowList[num]["typeIcon"].width = 20
							rowList[num]["typeIcon"].tooltip = "Tooltip"
						else
							rowList[num]["nameLabel"].visible = true
							rowList[num]["statusLabel"].visible = true
							rowList[num]["percentLabel"].visible = true
							rowList[num]["typeIcon"].visible = true
						end
						num = num + 1
					end
				end
			end

			num = shipsCount
			if shipsCount <= rowCount then
				for k, v in pairs (rowList) do
					if k >= num then
						v["nameLabel"].visible = false
						v["statusLabel"].visible = false
						v["percentLabel"].visible = false
						v["typeIcon"].visible = false
					else
						v["nameLabel"].visible = true
						v["statusLabel"].visible = true
						v["percentLabel"].visible = true
						v["typeIcon"].visible = true
					end
				end
			end
	
			-- add sorting by name (eventually)
			-- list alliance ships and playerships separately
			-- player ships first
			num = 0
			for key, ship in pairs (ships) do
				if ship ~= nil then		
					if(ship.allianceOwned) then
					else
					local occupiedCargoSpace = ((ship.occupiedCargoSpace >= 0) and ship.occupiedCargoSpace or 0)
					local maxCargoSpace = ((ship.maxCargoSpace >= 0) and ship.maxCargoSpace or 0)
					local hullPoints = ((ship.maxDurability >= 0) and ship.maxDurability or 0)
					local shieldPoints = ((ship.shieldMaxDurability >= 0) and ship.shieldMaxDurability or 0)
					local hull = ((hullPoints > 0) and round(ship.durability) or 0)
					local shield = ((shieldPoints > 0) and round(ship.shieldDurability) or 0)
			
					if hull > 1000000 then hull = round((hull / 1000000),2) .. "M"
					else if hull > 1000 then hull = round((hull / 1000),2) .. "k" end
					end
					if shield > 1000000 then shield = round((shield / 1000000),2) .. "M"
					else if shield > 1000 then shield = round((shield / 1000),2) .. "k" end
					end
					
					rowList[num]["nameLabel"].caption = ship.name

					rowList[num]["nameLabel"].tooltip = "(" .. ship.xPos .. ":" .. ship.yPos .. ")"
					--rowList[num]["nameLabel"].mouseDownFunction = 
					
					rowList[num]["statusLabel"].caption = ((hullPoints > 0) and round((ship.durability / ship.maxDurability)*100,1) or 0) .. "% / " .. ((shieldPoints > 0) and round((ship.shieldDurability / ship.shieldMaxDurability)*100,1) or 0) .. "%"
					rowList[num]["statusLabel"].tooltip =  hull .. " / " .. shield

					rowList[num]["percentLabel"].caption = ((maxCargoSpace > 0) and round(100 / maxCargoSpace * occupiedCargoSpace,1) or 0) .. "%"
					rowList[num]["percentLabel"].tooltip = ((maxCargoSpace > 0) and round(occupiedCargoSpace) or 0) .. " / " .. ((maxCargoSpace > 0) and round(maxCargoSpace) or 0)

					rowList[num]["typeIcon"].picture = "data/textures/icons/player.png"
					rowList[num]["typeIcon"].tooltip = "Player"
					num = num + 1
					end			
				end
			end
			
			-- alliance ships second
			for key, ship in pairs (ships) do
				if ship ~= nil then		
					if(ship.allianceOwned) then
					local occupiedCargoSpace = ((ship.occupiedCargoSpace >= 0) and ship.occupiedCargoSpace or 0)
					local maxCargoSpace = ((ship.maxCargoSpace >= 0) and ship.maxCargoSpace or 0)
					local hullPoints = ((ship.maxDurability >= 0) and ship.maxDurability or 0)
					local shieldPoints = ((ship.shieldMaxDurability >= 0) and ship.shieldMaxDurability or 0)
					local hull = ((hullPoints > 0) and round(ship.durability) or 0)
					local shield = ((shieldPoints > 0) and round(ship.shieldDurability) or 0)

					if hull > 1000000 then hull = round((hull / 1000000),2) .. "M"
					else if hull > 1000 then hull = round((hull / 1000),2) .. "k" end
					end
					if shield > 1000000 then shield = round((shield / 1000000),2) .. "M"
					else if shield > 1000 then shield = round((shield / 1000),2) .. "k" end
					end
					
					rowList[num]["nameLabel"].caption = ship.name
					rowList[num]["nameLabel"].tooltip = "(" .. ship.xPos .. ":" .. ship.yPos .. ")"
					
					rowList[num]["statusLabel"].caption = ((hullPoints > 0) and round((ship.durability / ship.maxDurability)*100,1) or 0) .. "% / " .. ((shieldPoints > 0) and round((ship.shieldDurability / ship.shieldMaxDurability)*100,1) or 0) .. "%"
					rowList[num]["statusLabel"].tooltip =  hull .. " / " .. shield
					
					rowList[num]["percentLabel"].caption = ((maxCargoSpace > 0) and round(100 / maxCargoSpace * occupiedCargoSpace,1) or 0) .. "%"
					rowList[num]["percentLabel"].tooltip = ((maxCargoSpace > 0) and round(occupiedCargoSpace) or 0) .. " / " .. ((maxCargoSpace > 0) and round(maxCargoSpace) or 0)

					rowList[num]["typeIcon"].picture = "data/textures/icons/alliance.png"
					rowList[num]["typeIcon"].tooltip = "Alliance"
					num = num + 1
					else
					end
				end
			end	
			update = false
		end
	end
	
	function shipinfo.cargoSpaceUpdateShipClient(ship)
		ships[ship.number] = ship
	end

	function shipinfo.cargoSpaceDeleteShipClient(shipNumber)
		if ships[shipNumber] ~= nil then
		ships[shipNumber] = nil
		end
	end

end

if onServer() then

	function shipinfo.cargoSpaceUpdateShip(ship)
		if ships[ship.number] == nil then
			ships[ship.number] = ship
			invokeClientFunction(Player(), "cargoSpaceUpdateShipClient", ship)
		else
			if ships[ship.number].shieldDurability ~= ship.shieldDurability or ships[ship.number].durability ~= ship.durability or ships[ship.number].name ~= ship.name or ships[ship.number].freeCargoSpace ~= ship.freeCargoSpace or ships[ship.number].maxCargoSpace ~= ship.maxCargoSpace or ships[ship.number].occupiedCargoSpace ~= ship.occupiedCargoSpace or ships[ship.number].allianceOwned ~= ship.allianceOwned then
				ships[ship.number] = ship
				invokeClientFunction(Player(), "cargoSpaceUpdateShipClient", ship)
			end
		end
	end

	function shipinfo.cargoSpaceDeleteShip(shipNumber)
		if ships[shipNumber] ~= nil then
			ships[shipNumber] = nil
			invokeClientFunction(Player(), "cargoSpaceDeleteShipClient", shipNumber)
		end
	end

end