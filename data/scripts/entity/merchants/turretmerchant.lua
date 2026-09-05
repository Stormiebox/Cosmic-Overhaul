-- Category-split Turret Merchant (Civilian/Military/Defensive Turrets). This no longer reassigns
-- TurretMerchant via ShopAPI.CreateNamespace() -- that would discard vanilla's own namespace table
-- entirely and force every function (including ones Overhaul never actually changes, like
-- interactionPossible/interactionThreshold) to be redefined from scratch just to carry vanilla's
-- own unmodified behavior forward. Only the functions that genuinely differ are overridden below;
-- everything else vanilla's own turretmerchant.lua already defined on this same table
-- (interactionPossible, interactionThreshold) is inherited untouched.

-- The single "Turrets" tab's own item population and UI are replaced by three attached
-- sub-shops, one per vanilla WeaponTypes category (armedTypes/unarmedTypes/defensiveTypes --
-- automatically includes any turret type any installed mod registers via WeaponTypes.addType, so
-- this stays correct without any per-mod list to maintain). addItems and onSpecialOfferSeedChanged
-- are neutered (not deleted) so the namespace's own periodic updateServer() restock check -- which
-- still runs regardless, since it's routed automatically by the engine -- doesn't waste cycles
-- regenerating a turret pool nobody can see every ~20 minutes.
TurretMerchant.shop.addItems = function() end
TurretMerchant.shop.onSpecialOfferSeedChanged = function() end

local CosmicOverhaul_originalTurretMerchantInitialize = TurretMerchant.initialize
function TurretMerchant.initialize()
    -- Runs vanilla's own title/icon setup and shop:initialize() call (harmless now that addItems
    -- is neutered above) unchanged.
    CosmicOverhaul_originalTurretMerchantInitialize()

    -- Vanilla's own TurretMerchant never sets this -- only EquipmentDock does. Extending it here
    -- so players can remove permanently-installed subsystems at a Turret Merchant too.
    Entity():setValue("remove_permanent_upgrades", true)

    local station = Entity()
    station:addScriptOnce("data/scripts/entity/merchants/co_civilturretmerchant.lua")
    station:addScriptOnce("data/scripts/entity/merchants/co_militaryturretmerchant.lua")
    station:addScriptOnce("data/scripts/entity/merchants/co_defensiveturretmerchant.lua")
end

function TurretMerchant.initUI()
    -- Replaces vanilla's own initUI (which would create the old "Turrets" tab): the three
    -- attached category shops above each register their own tab under the same shared
    -- "Trade Equipment" window instead.
end
