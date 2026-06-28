package.path = package.path .. ";data/scripts/lib/?.lua"

local ReSeed_UpgradeGenerator_getUpgradeSeed = UpgradeGenerator.getUpgradeSeed
function UpgradeGenerator:getUpgradeSeed(x, y, script, rarity)
    -- Cosmic Overhaul Balance tweak: Boosted wild chance to 75% for Exotic/Legendary to prevent dupe farming in Ascendancy late game
    if rarity.type >= RarityType.Exotic and self.random:test(0.75) then
        return self.random:createSeed(), x, y
    end

    -- Introduce a micro-variance (1 to 3) so the exact same sector/rarity/script combination
    -- can still yield slightly different drops, preventing merchants and loot from dropping exact duplicates.
    local microVariance = self.random:getInt(1, 3)

    -- Use delimiters (_) to prevent hash collisions (e.g., x=1,y=23 vs x=12,y=3)
    local seedString = string.format("%s_%s_%s_%s_%s_%s",
        tostring(GameSeed().int32),
        tostring(x), tostring(y),
        tostring(script), tostring(rarity.type), tostring(microVariance))

    return Seed(seedString), x, y
end

-- [Cosmic Overhaul] Append ends here. Vanilla already returns UpgradeGenerator above.
