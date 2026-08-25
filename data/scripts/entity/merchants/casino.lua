package.path = package.path .. ";data/scripts/entity/merchants/?.lua;"
package.path = package.path .. ";data/scripts/lib/?.lua;"
include ("stringutility")
local ConsumerGoods = include ("consumergoods")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace Casino
Casino = include ("consumer")

Casino.consumerName = "Casino"%_t
Casino.consumerIcon = "data/textures/icons/pixel/casino.png"
Casino.consumedGoods = ConsumerGoods.Casino()

function Casino.initializationFinished()
    -- use the initilizationFinished() function on the client since in initialize() we may not be able to access Sector scripts on the client
    if onClient() then
        local ok, r = Sector():invokeFunction("radiochatter", "addSpecificLines", Entity().id.string,
        {
            "Oh no! I've lost my ship! I guess I'll have to walk home now."%_t,
            "What? Drunk? Me? Never."%_t,
            "Recreational gambling - the best in the sector!"%_t,
            "We offer over ${N3}0 different games!"%_t,
            "The first round is free!"%_t,
            "Come to our casino, we have the most modern games and you might even win!"%_t,
        })
    end
end

local oldInitUI = Casino.initUI
function Casino.initUI()
    if oldInitUI then oldInitUI() end
    ScriptUI():registerInteraction("Trade Rumor (10,000 Cr)"%_t, "onTradeRumor", 90)
end

function Casino.onTradeRumor()
    local dialog = {}
    dialog.text = "You want a rumor? I hear things. But information isn't free. 10,000 credits, upfront."%_t
    dialog.answers = {
        {answer = "Here's 10,000 Credits."%_t, onSelect = "onPayTradeRumor"},
        {answer = "Nevermind."%_t}
    }
    ScriptUI():showDialog(dialog)
end

function Casino.onPayTradeRumor()
    invokeServerFunction("payTradeRumor")
end

function Casino.payTradeRumor()
    local player = Player(callingPlayer)
    if not player then return end

    local canPay, msg, args = player:canPay(10000)
    if not canPay then
        player:sendChatMessage(Entity(), 1, msg, unpack(args))
        return
    end

    player:pay("Paid %1% Credits for a trade rumor."%_T, 10000)

    local x, y = Sector():getCoordinates()
    local dist = 30
    local rand = random()
    local targetX = x + rand:getInt(-dist, dist)
    local targetY = y + rand:getInt(-dist, dist)
    player:addKnownSector(SectorView(targetX, targetY))
    player:sendChatMessage(Entity(), 0, "I've uploaded the coordinates to your map. Look around %1%:%2%. Lots of profit to be made there."%_t, targetX, targetY)
end
callable(Casino, "payTradeRumor")
