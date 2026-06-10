-- namespace shipinfo
shipinfo = shipinfo or {}

function shipinfo.initialize()
	terminate()
end

-- Stub out remaining callbacks to prevent log warnings during the tick before termination
function shipinfo.updateServer(timeStep) end
function shipinfo.onDelete() end
function shipinfo.handleCargoChanged() end
function shipinfo.handleBlockChanged() end
function shipinfo.handleDamaged() end
function shipinfo.handleShieldDamaged() end
