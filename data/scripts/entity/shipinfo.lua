package.path = package.path .. ";data/scripts/lib/?.lua"

-- namespace shipinfo
shipinfo = {}

if onServer() then

	local ship = {}
	local hasBlock = false
	
	function shipinfo.initialize()
		ship.number = Entity().id.number
		ship.id = Entity().id
		ship.name = Entity().name
		local x, y = Sector():getCoordinates(Entity().id)
		ship.xPos = x
		ship.yPos = y

		ship.durability = Entity().durability
		ship.maxDurability = Entity().maxDurability
		ship.shieldDurability = Entity().shieldDurability
		ship.shieldMaxDurability = Entity().shieldMaxDurability
		ship.factionIndex = Entity().factionIndex
		ship.freeCargoSpace = Entity().freeCargoSpace
		ship.maxCargoSpace = Entity().maxCargoSpace
		ship.occupiedCargoSpace = Entity().occupiedCargoSpace
		ship.allianceOwned = Entity().allianceOwned
		ship.playerOwned = Entity().playerOwned
		
		--local blocks = ReadOnlyPlan(Entity()):getBlocksByType(16)
		--for key, data in pairs (blocks) do
		--print data
		--end

		
		Entity():registerCallback("onCargoChanged", "handleCargoChanged")
		Entity():registerCallback("onBlocksAdded", "handleBlockChanged")
		Entity():registerCallback("onBlocksRemoved", "handleBlockChanged")
		Entity():registerCallback("onBlockChanged", "handleBlockChanged")
		Entity():registerCallback("onDamaged", "handleDamaged")
		Entity():registerCallback("onShieldDamaged", "handleShieldDamaged")
		
	end

	local update = 0
	function shipinfo.update(timeStep)
		if update <= 0 then
		hasBlock = true
			if Entity() ~= nil and hasBlock == true then			
				ship.number = Entity().id.number
				ship.id = Entity().id
				ship.name = Entity().name
				local x, y = Sector():getCoordinates(Entity().id)
				ship.xPos = x
				ship.yPos = y
				
				ship.durability = Entity().durability
				ship.maxDurability = Entity().maxDurability
				ship.shieldDurability = Entity().shieldDurability
				ship.shieldMaxDurability = Entity().shieldMaxDurability
				ship.factionIndex = Entity().factionIndex
				ship.freeCargoSpace = Entity().freeCargoSpace
				ship.maxCargoSpace = Entity().maxCargoSpace
				ship.occupiedCargoSpace = Entity().occupiedCargoSpace
				ship.allianceOwned = Entity().allianceOwned
				ship.playerOwned = Entity().playerOwned

				if ship.playerOwned and Server():isOnline(ship.factionIndex) then
					invokeFactionFunction(ship.factionIndex, true, "shipinfo", "cargoSpaceUpdateShip", ship)
				end

				if ship.allianceOwned then
					local members = {Alliance(ship.factionIndex):getMembers()}
					for i = 1,#members,1 do 
						if members[i] ~= nil and Server():isOnline(members[i]) then
							invokeFactionFunction(members[i], true, "shipinfo", "cargoSpaceUpdateShip", ship)
						end
					end
				end
			else
				shipinfo:removeShip()
			end
			update = 20
		else
			update = update - timeStep
		end
	end

	function shipinfo.onDelete()
		hasModule = false
		shipinfo:removeShip()
	end

	function shipinfo.removeShip()
		if ship.playerOwned and Server():isOnline(ship.factionIndex) then
			invokeFactionFunction(ship.factionIndex, true, "shipinfo", "cargoSpaceDeleteShip", ship.number)
		end
		if ship.allianceOwned then
			local members = {Alliance(ship.factionIndex):getMembers()}
			for i = 1,#members,1 do 
				if members[i] ~= nil and Server():isOnline(members[i]) then
					invokeFactionFunction(members[i], true, "shipinfo", "cargoSpaceDeleteShip", ship.number)
				end
			end
		end
	end

	-- Callbacks --
	function shipinfo.handleCargoChanged(index, delta, good)
		update = 0
	end

	function shipinfo.handleBlockChanged(objectIndex, blockIndex, changeFlags)
		--if ReadOnlyPlan(Entity().id):getBlocksByType(16) then
		--if ReadOnlyPlan(Entity()):exists(16) then
		--hasBlock = true
		--print "yay"
		--else
		--print "nay"
		--hasBlock = false
		--end
		update = 0
	end

	function shipinfo.handleDamaged(objectIndex, blockIndex, changeFlags)
		update = 0
	end
	
	function shipinfo.handleShieldDamaged(entityId, amount, damageType, inflictorId)
		update = 0
	end	

end