-- Category-split Equipment Dock (Civilian/Military/Misc Upgrades). This no longer reassigns
-- EquipmentDock via ShopAPI.CreateNamespace() -- that would discard vanilla's own namespace table
-- entirely and force every function (including ones Overhaul never actually changes, like
-- interactionPossible and initializationFinished) to be redefined from scratch just to carry
-- vanilla's own unmodified behavior forward. Only the two functions that genuinely differ are
-- overridden below; everything else vanilla's own equipmentdock.lua already defined on this same
-- table (interactionPossible, initializationFinished, etc.) is inherited untouched.

-- The single "Subsystems" tab's own item population and UI are replaced by three attached
-- sub-shops, one per Cosmic Vault upgrade category, so every registered upgrade type is
-- guaranteed to show up in its own tab instead of a flat random pool. addItems and
-- onSpecialOfferSeedChanged are neutered (not deleted) so the namespace's own periodic
-- updateServer() restock check -- which still runs regardless, since it's routed automatically by
-- the engine -- doesn't waste cycles regenerating an item pool nobody can see every ~20 minutes.
EquipmentDock.shop.addItems = function() end
EquipmentDock.shop.onSpecialOfferSeedChanged = function() end

local CosmicOverhaul_originalEquipmentDockInitialize = EquipmentDock.initialize
function EquipmentDock.initialize()
    -- Runs vanilla's own title/icon/remove_permanent_upgrades setup and shop:initialize() call
    -- (harmless now that addItems is neutered above) unchanged.
    CosmicOverhaul_originalEquipmentDockInitialize()

    local station = Entity()
    station:addScriptOnce("data/scripts/entity/merchants/co_civilupgrademerchant.lua")
    station:addScriptOnce("data/scripts/entity/merchants/co_militaryupgrademerchant.lua")
    station:addScriptOnce("data/scripts/entity/merchants/co_miscupgrademerchant.lua")
end

function EquipmentDock.initUI()
    -- Replaces vanilla's own initUI (which would create the old "Subsystems" tab): the three
    -- attached category shops above each register their own tab under the same shared
    -- "Trade Equipment" window instead.
end
