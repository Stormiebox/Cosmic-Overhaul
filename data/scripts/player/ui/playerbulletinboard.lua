-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace PlayerBulletinBoard
PlayerBulletinBoard = {}

local self = PlayerBulletinBoard

self.entityMissions = {}

self.allMissions = {}
self.missions = {}
self.page = 0
self.currentSort = "reward"
self.sortReverse = true

if onClient() then

    function PlayerBulletinBoard.initialize()
        Player():registerCallback("onSectorChanged", "onSectorChanged")

        self.tab = PlayerWindow():createTab("Bulletin Board"%_t, "data/textures/icons/warning-system.png","Bulletin Board"%_t)

        self.tab.onSelectedFunction = "onTabSelected"
        local hsplit = UIHorizontalSplitter(Rect(self.tab.size), 10, 10, 0.6)

        local lister = UIVerticalLister(hsplit.top, 7, 10)

        local filterRect = lister:placeCenter(vec2(lister.inner.width, 30))
        local filterSplit = UIVerticalSplitter(filterRect, 10, 0, 0.25)
        self.tab:createLabel(filterSplit.left.lower, "Filter:"%_t, 15)
        self.filterComboBox = self.tab:createValueComboBox(filterSplit.right, "onFilterChanged")

        local vsplit = UIArbitraryVerticalSplitter(lister:placeCenter(vec2(lister.inner.width, 30)), 10, 5, 430, 530, 700) -- 430, 530 originally

        self.btnDesc = self.tab:createButton(vsplit:partition(0), "Description"%_t, "onSortDescription")
        self.btnDesc.textSize = 14
        self.btnDiff = self.tab:createButton(vsplit:partition(1), "Difficulty"%_t, "onSortDifficulty")
        self.btnDiff.textSize = 14
        self.btnReward = self.tab:createButton(vsplit:partition(2), "Reward"%_t, "onSortReward")
        self.btnReward.textSize = 14
        self.btnSource = self.tab:createButton(vsplit:partition(3), "Source"%_t, "onSortSource")
        self.btnSource.textSize = 14

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
            local button = self.tab:createButton(vsplit.right, "Accept"%_t, "onTakeButtonPressed")
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
                local entity = Sector():getEntity(line.entityIndex)
                if valid(entity) then
                    entity:invokeFunction("entity/bulletinboard.lua", "acceptMission", line.bulletinIndex)
                else
                    print("DEBUG: bad entity?")
                end
            end
        end
    end

    function PlayerBulletinBoard.onSourceButtonPressed(button)
        for _, line in pairs(self.lines) do
            if line.source.index == button.index then
                local entity = Entity(line.entityIndex)
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
                line.brief.caption = (bulletin.brief or "")%_t % (bulletin.formatArguments or {})
                line.difficulty.caption = (bulletin.difficulty or "")%_t % (bulletin.formatArguments or {})
                line.reward.caption = (bulletin.reward or "")%_t % (bulletin.formatArguments or {})

                if bulletin.BMDLCOwnersOnly and not Player().ownsBlackMarketDLC then
                    line.button.active = false
                    line.button.tooltip = "This mission is only available for owners of the Black Market DLC."%_t
                else
                    line.button.active = true
                    line.button.tooltip = nil
                end

                if line.selected then
                    self.description.text = (bulletin.description or bulletin.brief or "")%_t % (bulletin.formatArguments or {})
                end

                line:show()
            else
                self.lines[i]:hide()
            end
        end

        if #self.missions == 0 then
            local line = self.lines[1]
            line:show()
            line.brief.caption = "No missions available in this sector!"%_t
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
        if not entityIndex then return end
        bulletins = bulletins or {}

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
        self.allMissions = {}

        for _, missions in pairs(self.entityMissions) do
            if missions.bulletins then
                for __, bulletin in pairs(missions.bulletins) do
                    if bulletin ~= nil then
                        table.insert(self.allMissions, { bulletin = bulletin, entityIndex = missions.entityIndex })
                    end
                end
            end
        end

        self.updateFilterComboBox()
        self.applyFilterAndSort()
    end

    function PlayerBulletinBoard.updateFilterComboBox()
        if not self.filterComboBox then return end

        local currentSelection = self.filterComboBox.selectedValue

        self.filterComboBox:clear()
        self.filterComboBox:addEntry("All"%_t, "All"%_t)

        local uniqueTypes = {}
        for _, mission in pairs(self.allMissions) do
            local b = (mission.bulletin.brief or "")%_t % (mission.bulletin.formatArguments or {})
            if not uniqueTypes[b] then
                uniqueTypes[b] = true
                self.filterComboBox:addEntry(b, b)
            end
        end

        if currentSelection then
            self.filterComboBox:setSelectedValueNoCallback(currentSelection)
        else
            self.filterComboBox:setSelectedIndexNoCallback(0)
        end
    end

    function PlayerBulletinBoard.onFilterChanged()
        self.applyFilterAndSort()
    end

    function PlayerBulletinBoard.setSort(criteria)
        if self.currentSort == criteria then
            self.sortReverse = not self.sortReverse
        else
            self.currentSort = criteria
            self.sortReverse = false
        end
        self.applyFilterAndSort()
    end

    function PlayerBulletinBoard.onSortDescription() self.setSort("description") end
    function PlayerBulletinBoard.onSortDifficulty() self.setSort("difficulty") end
    function PlayerBulletinBoard.onSortReward() self.setSort("reward") end
    function PlayerBulletinBoard.onSortSource() self.setSort("source") end

    function PlayerBulletinBoard.applyFilterAndSort()
        self.missions = {}
        local filterText = nil
        if self.filterComboBox and self.filterComboBox.selectedIndex > 0 then
            filterText = self.filterComboBox.selectedValue
        end

        for _, mission in pairs(self.allMissions) do
            local b = (mission.bulletin.brief or "")%_t % (mission.bulletin.formatArguments or {})
            if not filterText or filterText == "All"%_t or b == filterText then
                table.insert(self.missions, mission)
            end
        end

        local function parseReward(r)
            if not r then return 0 end
            local s = tostring(r):gsub("[^%d]", "")
            return tonumber(s) or 0
        end

        local difficultyOrder = {
            ["Easy"] = 1,
            ["Normal"] = 2,
            ["Hard"] = 3,
            ["Difficult"] = 4,
            ["Extreme"] = 5,
            ["Insane"] = 6
        }

        local function compare(a, b)
            local valA, valB
            if self.currentSort == "description" then
                valA = (a.bulletin.brief or "")%_t % (a.bulletin.formatArguments or {})
                valB = (b.bulletin.brief or "")%_t % (b.bulletin.formatArguments or {})
            elseif self.currentSort == "difficulty" then
                valA = difficultyOrder[a.bulletin.difficulty] or 0
                valB = difficultyOrder[b.bulletin.difficulty] or 0
            elseif self.currentSort == "reward" then
                valA = parseReward((a.bulletin.reward or "")%_t % (a.bulletin.formatArguments or {}))
                valB = parseReward((b.bulletin.reward or "")%_t % (b.bulletin.formatArguments or {}))
            elseif self.currentSort == "source" then
                local eA = Entity(a.entityIndex)
                local eB = Entity(b.entityIndex)
                valA = eA and eA.title or ""
                valB = eB and eB.title or ""
            else
                return false
            end

            if valA == valB then return false end

            if self.sortReverse then
                return valA > valB
            else
                return valA < valB
            end
        end

        table.sort(self.missions, compare)

        self.page = 0
        self.refreshList()
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

    function PlayerBulletinBoard.onSectorChanged()
        self.page = 0
        self.missions = {}
        self.entityMissions = {}

        local entities = { Sector():getEntitiesByScript("entity/bulletinboard.lua") }
        for _, entity in pairs(entities) do
            if valid(entity) then
                local ok, bulletins = entity:invokeFunction("entity/bulletinboard.lua", "getDisplayedBulletins")
                if ok and bulletins then
                    table.insert(self.entityMissions, { bulletins = bulletins, entityIndex = entity.index })
                else
                    table.insert(self.entityMissions, { bulletins = {}, entityIndex = entity.index })
                end
            end
        end

        self.refreshList()
    end

end -- onClient()

function PlayerBulletinBoard.onRemove()
    if Player() then Player():unregisterCallback("onSectorChanged", "onSectorChanged") end
end


function initialize(...)
    if PlayerBulletinBoard.initialize then return PlayerBulletinBoard.initialize(...) end
end
function update(...)
    if PlayerBulletinBoard.update then return PlayerBulletinBoard.update(...) end
end


-- Global Event Callbacks
function onSectorChanged(...)
    if PlayerBulletinBoard.onSectorChanged then return PlayerBulletinBoard.onSectorChanged(...) end
end

return PlayerBulletinBoard
