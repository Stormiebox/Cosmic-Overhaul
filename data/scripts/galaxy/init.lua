if onServer() then
	local galaxy = Galaxy()
	if galaxy then
		galaxy:addScriptOnce("data/scripts/galaxy/factoryregister.lua")
		galaxy:addScriptOnce("data/scripts/galaxy/galaxymapqol.lua")
	end
end
