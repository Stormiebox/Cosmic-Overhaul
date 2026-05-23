package.path = package.path .. ";data/scripts/lib/?.lua"
-- Include the original relations script to access its functions
include("relations") -- Assuming relations.lua is in the same directory
-- AlliedRelationsEnhancer.lua
-- Allied Relations Enhancer (ARE)
-- This mod enhances the faction relations system, specifically for alliances.

-- Creates a backup of the original changeRelations function
local originalChangeRelations = changeRelations

-- Overrides the changeRelations function
function changeRelations(a, b, delta, changeType, notifyA, notifyB, chatterer)
    -- Calls the original function first to retain existing functionality
    originalChangeRelations(a, b, delta, changeType, notifyA, notifyB, chatterer)

    -- Additional logic for handling alliances
    local ally
    local doubledelta = delta * 2  -- Double the relation change for allies

    -- Check if 'a' is a player and 'b' is an AI faction
    if (a.isPlayer) and b.isAIFaction then
        ally = a.alliance  -- Get the player's alliance
        if ally then
            Galaxy():changeFactionRelations(ally, b, doubledelta, notifyA, notifyB)
            -- Update the relation status for the alliance
            local newStatus = Galaxy():getFactionRelationStatus(ally, b)
            setRelationStatus(ally, b, newStatus, notifyA, notifyB)
        end
    end

    -- Check if 'b' is a player and 'a' is an AI faction
    if (b.isPlayer) and a.isAIFaction then
        ally = b.alliance  -- Get the AI faction's alliance
        if ally then
            Galaxy():changeFactionRelations(a, ally, doubledelta, notifyA, notifyB)
            -- Update the relation status for the alliance
            local newStatus = Galaxy():getFactionRelationStatus(a, ally)
            setRelationStatus(a, ally, newStatus, notifyA, notifyB)
        end
    end
end