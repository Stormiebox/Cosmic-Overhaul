-- Cosmic Overhaul: Highlander Shim for crewboard.lua
local base_getPriceAndTax = CrewBoard.getPriceAndTax
if base_getPriceAndTax then
    function CrewBoard.getPriceAndTax(profession, num, stationFaction, buyerFaction)
        local price, tax = base_getPriceAndTax(profession, num, stationFaction, buyerFaction)

        -- Cosmic Overhaul/War: Privateer Subsidies
        local entity = Entity()
        if entity and entity.isStation and entity:getValue("governor_merchant_active") then
            local faction = Faction(buyerFaction)
            if faction then
                local mercFaction = faction:getValue("cw_mercenary_faction")
                if mercFaction and mercFaction == stationFaction then
                    price = price * 0.5
                    tax = tax * 0.5
                end
            end
        end

        return price, tax
    end
end
