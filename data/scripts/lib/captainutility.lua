
local CaptainClass = include 'captainclass'

local function mcm_scaledFuncForNonMerchant(func, modFunc, ...)
    return function(captain, ...)
        local result = func(captain, ...)
        if not captain:hasClass(CaptainClass.Merchant) then
            result = modFunc(result)
        end
        return result
    end
end

-- Positive perks benefit non-merchants less and negative perks impact them more

CaptainUtility.getTradeSellPricePerkImpact = mcm_scaledFuncForNonMerchant(
    CaptainUtility.getTradeSellPricePerkImpact,
    function(original) if original > 0 then return original / 2 end return original * 2 end,
    ...)

CaptainUtility.getTradeTimePerkImpact = mcm_scaledFuncForNonMerchant(
    CaptainUtility.getTradeTimePerkImpact,
    function(original) if original < 0 then return original / 2 end return original * 2 end,
    ...)

CaptainUtility.getTradeBuyPricePerkImpact = mcm_scaledFuncForNonMerchant(
    CaptainUtility.getTradeBuyPricePerkImpact,
    function(original) if original < 0 then return original / 2 end return original * 2 end,
    ...)