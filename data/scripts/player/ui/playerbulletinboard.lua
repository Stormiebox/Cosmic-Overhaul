-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace PlayerBulletinBoard
PlayerBulletinBoard = {}

local self = PlayerBulletinBoard

self.entityMissions = {}

self.missions = {}
self.page = 0

if onClient() then

    function PlayerBulletinBoard.initialize()
        Player():registerCallback("onSectorChanged", "onSectorChanged")

        self.tab = PlayerWindow():createTab("Bulletin Board" % _t, "data/textures/icons/warning-system.png","Bulletin Board" % _t)

        self.tab.onSelectedFunction = "onTabSelected"
        local hsplit = UIHorizontalSplitter(Rect(self.tab.size), 10, 10, 0.6)

        local lister = UIVerticalLister(hsplit.top, 7, 10)

        local vsplit = UIArbitraryVerticalSplitter(lister:placeCenter(vec2(lister.inner.width, 30)), 10, 5, 430, 530, 700) -- 430, 530 originally

        self.tab:createLabel(vsplit:partition(0).lower, "Description" % _t, 15)
        self.tab:createLabel(vsplit:partition(1).lower, "Difficulty" % _t, 15)
        self.tab:createLabel(vsplit:partition(2).lower, "Reward" % _t, 15)
        self.tab:createLabel(vsplit:partition(3).lower, "Source" % _t, 15)

        self.lines = {}

        for i = 1, 8 do
            local rect = lister:placeCenter(vec2(lister.inner.width, 30))
            local vsplit = UIVerticalSplitter(rect, 10, 0, 0.85)

            local avsplit = UIArbitraryVerticalSplitter(vsplit.left, 10, 7, 430, 530, 700)

            local frame = self.tab:createFrame(vsplit.left)

            local i = 0

            local briefRect = avsplit:partition(i); i = i + 1

            local brief = self.tab:createLabel(briefRect.lower, "", 14);
            brief.width = briefRect.width
            brief.shortenText = true

            local difficulty = self.tab:createLabel(avsplit:partition(i).lower, "", 14); i = i + 1
            local reward = self.tab:createLabel(avsplit:partition(i).lower, "", 14); i = i + 1
            local source = self.tab:createButton(avsplit:partition(i), "Select", "onSourceButtonPressed"); i = i + 1
            source.icon = "data/textures/icons/position-marker.png"
            local button = self.tab:createButton(vsplit.right, "Accept" % _t, "onTakeButtonPressed")
            local hide = function(self)
                self.brief:hide()
                self.difficulty:hide()
                self.reward:hide()
                self.button:hide()
                self.source:hide()
            end

            local show = function(self)
                self.frame:show()
                self.brief:show()
                self.difficulty:show()
                self.reward:show()
                self.button:show()
                self.source:show()
            end

            local line = { frame = frame, brief = brief, difficulty = difficulty, reward = reward, button = button, hide = hide, show = show, selected = false, source = source, entityIndex = nil }

            table.insert(self.lines, line)
        end

        vsplit = UIVerticalMultiSplitter(lister:placeCenter(vec2(lister.inner.width, 30)), 10, 0, 5)

        self.upbutton = self.tab:createButton(vsplit:partition(2), "UP", "onDirectionButtonPressed")
        self.upbutton.icon = "data/textures/icons/arrow-up2.png"
        self.downbutton = self.tab:createButton(vsplit:partition(3), "DOWN", "onDirectionButtonPressed")
        self.downbutton.icon = "data/textures/icons/arrow-down2.png"

        self.tab:createLine(hsplit.bottom.topLeft, hsplit.bottom.topRight)
        self.description = self.tab:createTextField(hsplit.bottom, "")

        self.refreshList()
    end

    function PlayerBulletinBoard.onTabSelected()
        self.buildMissionsTable()
        self.refreshList()
    end

    function PlayerBulletinBoard.onTakeButtonPressed(button)
        for _, line in pairs(self.lines) do
            if line.button.index == button.index then
                entity = Sector():getEntity(line.entityIndex)
                if valid(entity) then
                    entity:invokeFunction("entity/bulletinboard.lua", "acceptMission", line.bulletinIndex)
                else
                    printlog("DEBUG: bad entity?")
                end
            end
        end
    end

    function PlayerBulletinBoard.onSourceButtonPressed(button)
        for _, line in pairs(self.lines) do
            if line.source.index == button.index then
                entity = Entity(line.entityIndex)
                if valid(entity) then
                    Player().selectedObject = entity
                else
                    print("DEBUG: bad entity?")
                end
            end
        end
    end

    function PlayerBulletinBoard.onDirectionButtonPressed(button)
        if button.index == self.upbutton.index then
            if self.page == 0 then return end

            self.page = self.page - 1

        elseif button.index == self.downbutton.index then
            if #self.missions > (self.page * 8 + 8) then
                self.page = self.page + 1
            else
                return
            end
        end

        self.refreshList()
    end

    function PlayerBulletinBoard.refreshList()

        --    local missions = {}
        --    local test = {brief = "stuff", formatArguments = {}, difficulty = "Fubar", reward = "$100,000,000", description = "do stuff"}
        --    local mission = {bulletin = test}

        --    table.insert(missions, mission)

        self.description.text = ""

        for i = 1, 8 do
            local entry = i + self.page * 8
            if self.missions[entry] then
                local bulletin = self.missions[entry].bulletin
                local line = self.lines[i]

                line.entityIndex = self.missions[entry].entityIndex
                line.bulletinIndex = bulletin.bulletinIndex
                line.brief.caption = bulletin.brief % _t % bulletin.formatArguments
                line.difficulty.caption = bulletin.difficulty % _t % bulletin.formatArguments
                line.reward.caption = bulletin.reward % _t % bulletin.formatArguments

                if bulletin.BMDLCOwnersOnly and not Player().ownsBlackMarketDLC then
                    line.button.active = false
                    line.button.tooltip = "This mission is only available for owners of the Black Market DLC." % _t
                else
                    line.button.active = true
                    line.button.tooltip = nil
                end

                if line.selected then
                    self.description.text = (bulletin.description or bulletin.brief or "") % _t % bulletin.formatArguments
                end

                line:show()
            else
                self.lines[i]:hide()
            end
        end

        if #self.missions == 0 then
            local line = self.lines[1]
            line:show()
            line.brief.caption = "No missions available in this sector!" % _t
            line.difficulty.caption = ""
            line.reward.caption = ""
            line.source:hide()
            line.button:hide()
        end
    end

    function PlayerBulletinBoard.showBulletins()
        local window = PlayerWindow()

        window:show()
        window:selectTab(self.tab)
    end

    function PlayerBulletinBoard.updateBulletins(bulletins, entityIndex)

        local found = false
        for _, missions in pairs(self.entityMissions) do
            if missions.entityIndex == entityIndex then
                missions.bulletins = bulletins
                found = true
                break
            end
        end

        if not found then
            table.insert(self.entityMissions, { bulletins = bulletins, entityIndex = entityIndex })
        end

        self.buildMissionsTable()
        self.refreshList()
    end

    function PlayerBulletinBoard.buildMissionsTable()
        self.missions = {}

        for _, missions in pairs(self.entityMissions) do
            for __, bulletin in pairs(missions.bulletins) do
                if bulletin ~= nil then
                    table.insert(self.missions, { bulletin = bulletin, entityIndex = missions.entityIndex })
                end
            end
        end
    end

    function PlayerBulletinBoard.update()
        if not self.lines then return end

        if not self.tab.visible then return end

        for _, line in pairs(self.lines) do
            if line.frame.mouseOver then
                if line.selected then
                    line.frame.backgroundColor = ColorARGB(0.5, 0.35, 0.35, 0.35)
                else
                    line.frame.backgroundColor = ColorARGB(0.5, 0.15, 0.15, 0.15)
                end
            else
                if line.selected then
                    line.frame.backgroundColor = ColorARGB(0.5, 0.25, 0.25, 0.25)
                else
                    line.frame.backgroundColor = ColorARGB(0.5, 0, 0, 0)
                end
            end
        end

        local refresh = false
        if Mouse():mouseDown(1) then

            for i, line in pairs(self.lines) do
                local prevSelected = line.selected
                line.selected = line.frame.mouseOver

                if prevSelected ~= line.selected then
                    refresh = true
                end
            end
        end
        if refresh then
            self.refreshList()
        end
    end

    -- Sorting Missions
    -- Still not fully implemented yet, work in progress!
    function sortMissionsBy(criteria)
        if criteria == "reward" then
            table.sort(self.missions, function(a, b) return a.bulletin.reward > b.bulletin.reward end)
        elseif criteria == "difficulty" then
            table.sort(self.missions, function(a, b) return a.bulletin.difficulty > b.bulletin.difficulty end)
        elseif criteria == "distance" then
            table.sort(self.missions, function(a, b) return a.bulletin.distance < b.bulletin.distance end)
        end
        self.refreshList()
    end

    -- Filtering Missions by Type
    -- Still not fully implemented yet, work in progress!
    function filterMissionsByType(type)
        filteredMissions = {}
        for _, mission in pairs(self.missions) do
            if mission.bulletin.type == type then
                table.insert(filteredMissions, mission)
            end
        end
        self.missions = filteredMissions
        self.refreshList()
    end

    function PlayerBulletinBoard.onSectorChanged()
        self.page = 0
        self.missions = {}
        self.entityMissions = {}

        for _, entity in pairs({ Sector():getEntitiesByScript("entity/bulletinboard.lua") }) do
            local ok, bulletins = entity:invokeFunction("entity/bulletinboard.lua", "getDisplayedBulletins")
            table.insert(self.entityMissions, { bulletins = bulletins, entityIndex = entity.index })
        end

        self.refreshList()
    end

end -- onClient()
