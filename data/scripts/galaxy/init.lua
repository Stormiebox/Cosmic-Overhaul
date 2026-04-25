if onServer() then
	local galaxy = Galaxy()
	if galaxy then
		galaxy:addScriptOnce("factoryregister.lua")
	end
end
