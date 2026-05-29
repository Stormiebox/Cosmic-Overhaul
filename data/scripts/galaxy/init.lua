if onServer() then
	local galaxy = Galaxy()
	if galaxy then
		galaxy:addScriptOnce("data/scripts/galaxy/factoryregister.lua")
	end
end
