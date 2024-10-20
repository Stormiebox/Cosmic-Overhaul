package.path = package.path .. ";data/scripts/lib/?.lua"
include("stringutility")
include("callable")

local __CMB_Base_BulletinBoard_receiveData = BulletinBoard.receiveData

function BulletinBoard.receiveData(bulletins_in)
    __CMB_Base_BulletinBoard_receiveData(bulletins_in)

    local bulletins = BulletinBoard.getDisplayedBulletins()
    Player():invokeFunction("player/ui/playerbulletinboard.lua", "updateBulletins", bulletins, Entity().index)
end

if onClient() then
    local window

    function BulletinBoard.initUI()
        local res = getResolution()
        local size = vec2(900, 605)

        local menu = ScriptUI()
        window = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))

        window.caption = "${entity} Bulletin Board" % _t % { entity = (Entity().translatedTitle or "") % _t }
        window.showCloseButton = 1
        window.moveable = 1
        menu:registerWindow(window, "Bulletin Board" % _t, 4);

        BulletinBoard.fetchData()
    end

    function BulletinBoard.refreshUI()
    end

    function BulletinBoard.onShowWindow()
        window:hide()
        Player():invokeFunction("player/ui/playerbulletinboard.lua", "showBulletins")
    end

    function BulletinBoard.acceptMission(index)
        invokeServerFunction("acceptMission", index)
    end

    -- Enhanced error handling for empty mission lists or unexpected states
    function BulletinBoard.checkMissionList()
        local missions = BulletinBoard.getDisplayedBulletins()
        if not missions or #missions == 0 then
            print("No missions available in this sector!")
            return
        end
        Player():invokeFunction("player/ui/playerbulletinboard.lua", "updateBulletins", missions, Entity().index)
    end
end -- onClient()
