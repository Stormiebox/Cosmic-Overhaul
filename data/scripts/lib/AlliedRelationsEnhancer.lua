package.path = package.path .. ";data/scripts/lib/?.lua"
include("relations")
--TODO: Look for further polishing and balancing improvements for AlliedRelationsEnhancer.lua. Why? To further synergize with Ascendancy/War.
-- I could add a minor polish. Wrapping the multiplication in math.floor() just to ensure the reputation penalty remains a clean whole number instead of a decimal (e.g., math.floor(allianceDelta * 0.1)), but Avorion's C++ backend handles Lua floats for reputation natively anyways.
-- Cosmic Overhaul: Safely hook the vanilla changeRelations function
local co_are_originalChangeRelations = changeRelations

-- Cosmic Overhaul: Prevent infinite recursion if the hook triggers itself
local isProcessingAlliance = false

function changeRelations(a, b, delta, changeType, notifyA, notifyB, chatterer)
    -- Always process the primary relation change first
    if co_are_originalChangeRelations then
        co_are_originalChangeRelations(a, b, delta, changeType, notifyA, notifyB, chatterer)
    end

    -- Cosmic Overhaul: Allied Relations Enhancer
    -- If a player gains or loses reputation, mirror that change to their Alliance at 2x intensity.
    -- This forces the player's personal actions to have massive diplomatic weight for their group.
    if not isProcessingAlliance and delta ~= 0 then
        isProcessingAlliance = true

        local alliance
        local aiFaction

        -- Identify if the interaction is between a Player and an AI Faction
        if a.isPlayer and b.isAIFaction then
            alliance = a.alliance
            aiFaction = b
        elseif b.isPlayer and a.isAIFaction then
            alliance = b.alliance
            aiFaction = a
        end

        if alliance and aiFaction then
            -- Cosmic Overhaul Balance tweak: Reduced from delta * 2 to 1x parity to prevent cascade wars in Ascendancy/War
            local allianceDelta = delta

            -- Alliance Mirroring Forgiveness Buffer
            -- If a player loses reputation from a minor offense (like a stray shot), mitigate the alliance penalty by 90%
            -- This protects massive multiplayer alliances from immediately tanking over one accident.
            if allianceDelta < 0 and allianceDelta >= -25000 then
                allianceDelta = allianceDelta * 0.1
            end

            -- Pass the Alliance and AI faction back through the vanilla pipeline
            -- so hard caps, traits, and UI notifications trigger correctly!
            if co_are_originalChangeRelations then
                co_are_originalChangeRelations(alliance, aiFaction, allianceDelta, changeType, notifyA, notifyB, chatterer)
            end
        end

        isProcessingAlliance = false
    end
end