-- namespace shipinfo
shipinfo = shipinfo or {}

local updateTimer = 0
local UPDATE_INTERVAL = 5

local function _buildSnapshot(entity)
	if not entity then return nil end

	local x, y = Sector():getCoordinates(entity.id)

	return {
		idNumber = entity.id.number,
		id = entity.id,
		name = entity.name,
		xPos = x,
		yPos = y,
		durability = entity.durability,
		maxDurability = entity.maxDurability,
		shieldDurability = entity.shieldDurability,
		shieldMaxDurability = entity.shieldMaxDurability,
		factionIndex = entity.factionIndex,
		freeCargoSpace = entity.freeCargoSpace,
		maxCargoSpace = entity.maxCargoSpace,
		occupiedCargoSpace = entity.occupiedCargoSpace,
		allianceOwned = entity.allianceOwned,
		playerOwned = entity.playerOwned
	}
end

local function _shipKey(snapshot)
	if not snapshot then return nil end
	return tostring(snapshot.factionIndex or -1) .. "::" .. tostring(snapshot.name or "unknown")
end

local function _ensureFleetStatusScript(playerIndex)
	if not playerIndex then return false end
	local p = Player(playerIndex)
	if not p then return false end

	if not p:hasScript("data/scripts/player/fleetstatus.lua") then
		p:addScriptOnce("data/scripts/player/fleetstatus.lua")
	end

	return true
end

local function _publishToPlayer(playerIndex, snapshot)
	if not playerIndex or not snapshot then return end
	if not Server():isOnline(playerIndex) then return end
	if not _ensureFleetStatusScript(playerIndex) then return end
	invokeFactionFunction(playerIndex, true, "fleetstatus", "receiveShipSnapshot", snapshot)
end

local function _publishSnapshot(snapshot)
	if not snapshot then return end

	if snapshot.playerOwned then
		_publishToPlayer(snapshot.factionIndex, snapshot)
	end

	if snapshot.allianceOwned then
		local alliance = Alliance(snapshot.factionIndex)
		if alliance then
			local members = { alliance:getMembers() }
			for _, memberIndex in pairs(members) do
				_publishToPlayer(memberIndex, snapshot)
			end
		end
	end
end

local function _publishDelete(snapshot)
	if not snapshot then return end
	local key = _shipKey(snapshot)
	if not key then return end

	if snapshot.playerOwned and Server():isOnline(snapshot.factionIndex) then
		if _ensureFleetStatusScript(snapshot.factionIndex) then
			invokeFactionFunction(snapshot.factionIndex, true, "fleetstatus", "deleteShipSnapshot", key)
		end
	end

	if snapshot.allianceOwned then
		local alliance = Alliance(snapshot.factionIndex)
		if alliance then
			local members = { alliance:getMembers() }
			for _, memberIndex in pairs(members) do
				if memberIndex and Server():isOnline(memberIndex) then
					if _ensureFleetStatusScript(memberIndex) then
						invokeFactionFunction(memberIndex, true, "fleetstatus", "deleteShipSnapshot", key)
					end
				end
			end
		end
	end
end

function shipinfo.initialize()
	if not onServer() then return end
	local entity = Entity()
	if not entity then return end

	entity:registerCallback("onCargoChanged", "handleCargoChanged")
	entity:registerCallback("onBlocksAdded", "handleBlockChanged")
	entity:registerCallback("onBlocksRemoved", "handleBlockChanged")
	entity:registerCallback("onBlockChanged", "handleBlockChanged")
	entity:registerCallback("onDamaged", "handleDamaged")
	entity:registerCallback("onShieldDamaged", "handleShieldDamaged")

	updateTimer = 0
end

function shipinfo.updateServer(timeStep)
	updateTimer = math.max(0, updateTimer - timeStep)
	if updateTimer > 0 then return end

	local entity = Entity()
	if not entity then return end

	local snapshot = _buildSnapshot(entity)
	_publishSnapshot(snapshot)
	updateTimer = UPDATE_INTERVAL
end

function shipinfo.onDelete()
	if not onServer() then return end
	local entity = Entity()
	if not entity then return end

	local snapshot = _buildSnapshot(entity)
	_publishDelete(snapshot)
end

function shipinfo.handleCargoChanged(index, delta, good)
	updateTimer = 0
end

function shipinfo.handleBlockChanged(objectIndex, blockIndex, changeFlags)
	updateTimer = 0
end

function shipinfo.handleDamaged(objectIndex, blockIndex, changeFlags)
	updateTimer = 0
end

function shipinfo.handleShieldDamaged(entityId, amount, damageType, inflictorId)
	updateTimer = 0
end
