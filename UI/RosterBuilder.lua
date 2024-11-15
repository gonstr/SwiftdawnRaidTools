local SwiftdawnRaidTools = SwiftdawnRaidTools
local SharedMedia = LibStub("LibSharedMedia-3.0")

local WINDOW_WIDTH = 600

local State = {
    LOAD_OR_CREATE_ROSTER = 1,
    ADD_OR_REMOVE_PLAYERS = 2,
    CREATE_ASSIGNMENTS = 3
}

--- Roster Builder window class object
---@class RosterBuilder:SRTWindow
RosterBuilder = setmetatable({
    state = State.LOAD_OR_CREATE_ROSTER,
    lastState = State.LOAD_OR_CREATE_ROSTER,
    availableRosters = {},

    ---@class Roster?
    selectedRoster = nil,

    roster = {},
    availablePlayers = {
        guild = {
            players = {}
        }
    }
}, SRTWindow)
RosterBuilder.__index = RosterBuilder

local availablePlayerFilterDefaults = {
    ["Class"] = {
        ["Death Knight"] = true,
        ["Druid"] = true,
        ["Hunter"] = true,
        ["Mage"] = true,
        ["Paladin"] = true,
        ["Priest"] = true,
        ["Rogue"] = true,
        ["Shaman"] = true,
        ["Warlock"] = true,
        ["Warrior"] = true
    },
    ["Guild Rank"] = {
        _function = function (key)
            return GetGuildRankNameByIndex(key + 1)
        end,
    },
    ["Online only"] = false,
}
for i = 0, GuildControlGetNumRanks() - 2, 1 do
    availablePlayerFilterDefaults["Guild Rank"][i] = true
end

---@return RosterBuilder
function RosterBuilder:New(height)
    local obj = SRTWindow.New(self, "RosterBuilder", height, WINDOW_WIDTH, nil, nil, WINDOW_WIDTH, WINDOW_WIDTH)
    ---@cast obj RosterBuilder
    self.__index = self
    return obj
end

function RosterBuilder:SetToLeftSide(child, parent)
    child:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    child:SetPoint("TOPRIGHT", parent, "TOP", -5, 0)
    child:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
    child:SetPoint("BOTTOMRIGHT", parent, "BOTTOM", -5, 0)
end

function RosterBuilder:SetToRightSide(child, parent)
    child:SetPoint("TOPLEFT", parent, "TOP", 5, 0)
    child:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    child:SetPoint("BOTTOMLEFT", parent, "BOTTOM", 5, 0)
    child:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
end

function RosterBuilder:SelectRoster()

end

function RosterBuilder:Initialize()
    SRTWindow.Initialize(self)
    -- Unset clipping to show filter menu out the side
    self.container:SetClipsChildren(false)

    -- Set header text
    self.headerText:SetText("Roster Builder")
    
    -- Set menu button script
    self.menuButton:SetScript("OnClick", function()
        if not SRT_IsTesting() and InCombatLockdown() then
            return
        end
        self:UpdatePopupMenu()
        self.popupMenu:Show()
    end)

    -- Create content pane
    self.content = CreateFrame("Frame", "SRTRoster_Content", self.main)
    self.content:SetClipsChildren(false)
    self.content:SetPoint("TOPLEFT", self.main, "TOPLEFT", 10, -5)
    self.content:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", -10, -5)
    self.content:SetPoint("BOTTOMLEFT", self.main, "BOTTOMLEFT", 10, 5)
    self.content:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", -10, 5)

    -- Create possible left/right panes
    self:InitializeLoadOrCreateRoster()
    self:InitializeAddOrRemovePlayers()
    self:InitializeCreateAssignments()

    -- Update appearance
    self:UpdateAppearance()
end

function RosterBuilder:InitializeLoadOrCreateRoster()
    self.loadCreate = {}
    self.loadCreate.load = {}
    self.loadCreate.load.pane = CreateFrame("Frame", "SRTRoster_Load", self.content)
    self.loadCreate.load.pane:SetClipsChildren(false)
    self:SetToLeftSide(self.loadCreate.load.pane, self.content)
    self.loadCreate.load.title = self.loadCreate.load.pane:CreateFontString(self.loadCreate.load.pane:GetName().."_Title", "OVERLAY", "GameFontNormal")
    self.loadCreate.load.title:SetPoint("TOPLEFT", self.loadCreate.load.pane, "TOPLEFT", 5 , -5)
    self.loadCreate.load.title:SetText("Roster")
    self.loadCreate.load.title:SetFont(self:GetHeaderFont(), 16)
    self.loadCreate.load.title:SetTextColor(1, 1, 1, 0.8)
    self.loadCreate.load.scroll = FrameBuilder.CreateScrollArea(self.loadCreate.load.pane, "SavedItems")
    self.loadCreate.load.scroll:SetPoint("TOPLEFT", self.loadCreate.load.pane, "TOPLEFT", 0, -28)
    self.loadCreate.load.scroll:SetPoint("TOPRIGHT", self.loadCreate.load.pane, "TOPRIGHT", 0, -28)
    self.loadCreate.load.scroll:SetPoint("BOTTOMLEFT", self.loadCreate.load.pane, "BOTTOMLEFT", 0, 35)
    self.loadCreate.load.scroll:SetPoint("BOTTOMRIGHT", self.loadCreate.load.pane, "BOTTOMRIGHT", 0, 35)
    self.loadCreate.load.scroll:SetScript("OnMouseDown", function ()
        self.selectedRoster = nil
        self.loadCreate.loadButton:SetScript("OnMouseDown", nil)
        self.loadCreate.loadButton.color = SRTColor.Gray
        self.loadCreate.loadButton.colorHightlight = SRTColor.GrayHighlight
        FrameBuilder.UpdateButton(self.loadCreate.loadButton)
        self:UpdateAppearance()
    end)
    self.loadCreate.info = {}
    self.loadCreate.info.pane = CreateFrame("Frame", "SRTRoster_SelectedInfo", self.content)
    self.loadCreate.info.pane:SetClipsChildren(false)
    self:SetToRightSide(self.loadCreate.info.pane, self.content)
    self.loadCreate.info.title = self.loadCreate.info.pane:CreateFontString(self.loadCreate.info.pane:GetName().."_Title", "OVERLAY", "GameFontNormal")
    self.loadCreate.info.title:SetPoint("TOPLEFT", self.loadCreate.info.pane, "TOPLEFT", 5 , -5)
    self.loadCreate.info.title:SetText("Selected Player Info")
    self.loadCreate.info.title:SetFont(self:GetHeaderFont(), 16)
    self.loadCreate.info.title:SetTextColor(1, 1, 1, 0.8)
    self.loadCreate.info.scroll = FrameBuilder.CreateScrollArea(self.loadCreate.info.pane, "RosterInfo")
    self.loadCreate.info.scroll:SetPoint("TOPLEFT", self.loadCreate.info.pane, "TOPLEFT", 0, -28)
    self.loadCreate.info.scroll:SetPoint("TOPRIGHT", self.loadCreate.info.pane, "TOPRIGHT", 0, -28)
    self.loadCreate.info.scroll:SetPoint("BOTTOMLEFT", self.loadCreate.info.pane, "BOTTOMLEFT", 0, 35)
    self.loadCreate.info.scroll:SetPoint("BOTTOMRIGHT", self.loadCreate.info.pane, "BOTTOMRIGHT", 0, 35)

    -- Create buttons
    self.loadCreate.loadButton = FrameBuilder.CreateButton(self.loadCreate.load.pane, 95, 25, "Load", SRTColor.Gray, SRTColor.Gray)
    self.loadCreate.loadButton:SetPoint("BOTTOMRIGHT", self.loadCreate.load.pane, "BOTTOMRIGHT", -5, 5)
    self.loadCreate.deleteButton = FrameBuilder.CreateButton(self.loadCreate.load.pane, 95, 25, "Delete", SRTColor.Gray, SRTColor.Gray)
    self.loadCreate.deleteButton:SetPoint("RIGHT", self.loadCreate.loadButton, "LEFT", -10, 0)
    self.loadCreate.createButton = FrameBuilder.CreateButton(self.loadCreate.info.pane, 95, 25, "Create New", SRTColor.Green, SRTColor.GreenHighlight)
    self.loadCreate.createButton:SetPoint("BOTTOMRIGHT", self.loadCreate.info.pane, "BOTTOMRIGHT", -5, 5)
    self.loadCreate.createButton:SetScript("OnMouseDown", function ()
        self.selectedRoster = SRTData.CreateNewRoster()
        self.state = State.ADD_OR_REMOVE_PLAYERS
        self:UpdateAppearance()
    end)
end

function RosterBuilder:InitializeAddOrRemovePlayers()
    self.addRemove = {}
    self.addRemove.roster = {}
    self.addRemove.roster.pane = CreateFrame("Frame", "SRTRoster_RosterPane", self.content)
    self.addRemove.roster.pane:SetClipsChildren(false)
    self:SetToLeftSide(self.addRemove.roster.pane, self.content)
    self.addRemove.roster.title = self.addRemove.roster.pane:CreateFontString(self.addRemove.roster.pane:GetName().."_Title", "OVERLAY", "GameFontNormal")
    self.addRemove.roster.title:SetPoint("TOPLEFT", self.addRemove.roster.pane, "TOPLEFT", 5 , -5)
    self.addRemove.roster.title:SetText("Roster")
    self.addRemove.roster.title:SetFont(self:GetHeaderFont(), 16)
    self.addRemove.roster.title:SetTextColor(1, 1, 1, 0.8)
    self.addRemove.roster.scroll = FrameBuilder.CreateScrollArea(self.addRemove.roster.pane, "Roster")
    self.addRemove.roster.scroll:SetPoint("TOPLEFT", self.addRemove.roster.pane, "TOPLEFT", 0, -28)
    self.addRemove.roster.scroll:SetPoint("TOPRIGHT", self.addRemove.roster.pane, "TOPRIGHT", 0, -28)
    self.addRemove.roster.scroll:SetPoint("BOTTOMLEFT", self.addRemove.roster.pane, "BOTTOMLEFT", 0, 35)
    self.addRemove.roster.scroll:SetPoint("BOTTOMRIGHT", self.addRemove.roster.pane, "BOTTOMRIGHT", 0, 35)
    self.addRemove.available = {}
    self.addRemove.available.pane = CreateFrame("Frame", "SRTRoster_AvailablePlayers", self.content)
    self.addRemove.available.pane:SetClipsChildren(false)
    self:SetToRightSide(self.addRemove.available.pane, self.content)
    self.addRemove.available.title = self.addRemove.available.pane:CreateFontString(self.addRemove.available.pane:GetName().."_Title", "OVERLAY", "GameFontNormal")
    self.addRemove.available.title:SetPoint("TOPLEFT", self.addRemove.available.pane, "TOPLEFT", 5 , -5)
    self.addRemove.available.title:SetText("Available Players")
    self.addRemove.available.title:SetFont(self:GetHeaderFont(), 16)
    self.addRemove.available.title:SetTextColor(1, 1, 1, 0.8)
    self.addRemove.available.filterButton = CreateFrame("Button", self.addRemove.available.pane:GetName().."_Filter", self.addRemove.available.pane, "BackdropTemplate")
    self.addRemove.available.filterButton.texture = self.addRemove.available.filterButton:CreateTexture(nil, "BACKGROUND")
    self.addRemove.available.filterButton.texture:SetTexture("Interface\\Addons\\SwiftdawnRaidTools\\Media\\filter_white_64x64.tga")
    self.addRemove.available.filterButton.texture:SetAllPoints()
    self.addRemove.available.filterButton.texture:SetAlpha(0.8)
    self.addRemove.available.filterButton:SetSize(16, 16)
    self.addRemove.available.filterButton:SetPoint("TOPRIGHT", self.content, "TOPRIGHT", -5, -5)
    self.addRemove.available.filterPopup = FrameBuilder.CreateFilterMenu(self.addRemove.available.filterButton, availablePlayerFilterDefaults, self:GetPlayerFont(), function() self:UpdateAddOrRemovePlayers() end)
    self.addRemove.available.filterPopup:SetPoint("TOPLEFT", self.addRemove.available.filterButton, "BOTTOMLEFT", 0, -3)
    self.addRemove.available.filterPopup:Hide()
    self.addRemove.available.filterButton:SetScript("OnClick", function ()
        if self.addRemove.available.filterPopup:IsShown() then self.addRemove.available.filterPopup:Hide() else self.addRemove.available.filterPopup:Show() end
    end)
    self.addRemove.available.scroll = FrameBuilder.CreateScrollArea(self.addRemove.available.pane, "Available")
    self.addRemove.available.scroll:SetPoint("TOPLEFT", self.addRemove.available.pane, "TOPLEFT", 0, -28)
    self.addRemove.available.scroll:SetPoint("TOPRIGHT", self.addRemove.available.pane, "TOPRIGHT", 0, -28)
    self.addRemove.available.scroll:SetPoint("BOTTOMLEFT", self.addRemove.available.pane, "BOTTOMLEFT", 0, 35)
    self.addRemove.available.scroll:SetPoint("BOTTOMRIGHT", self.addRemove.available.pane, "BOTTOMRIGHT", 0, 35)

    -- Create buttons
    self.addRemove.backButton = FrameBuilder.CreateButton(self.addRemove.roster.pane, 95, 25, "Back", SRTColor.Red, SRTColor.RedHighlight)
    self.addRemove.backButton:SetPoint("BOTTOMLEFT", self.content, "BOTTOMLEFT", 5, 5)
    self.addRemove.backButton:SetScript("OnMouseDown", function (button)
        self.state = State.LOAD_OR_CREATE_ROSTER
        self.selectedRoster = nil
        self.loadCreate.loadButton:SetScript("OnMouseDown", nil)
        self.loadCreate.loadButton.color = SRTColor.Gray
        self.loadCreate.loadButton.colorHightlight = SRTColor.GrayHighlight
        FrameBuilder.UpdateButton(self.loadCreate.loadButton)
        self:UpdateAppearance()
    end)
    self.addRemove.assignmentsButton = FrameBuilder.CreateButton(self.addRemove.available.pane, 95, 25, "Assignments", SRTColor.Green, SRTColor.GreenHighlight)
    self.addRemove.assignmentsButton:SetPoint("BOTTOMRIGHT", self.content, "BOTTOMRIGHT", -5, 5)
    self.addRemove.assignmentsButton:SetScript("OnMouseDown", function (button)
        self.state = State.CREATE_ASSIGNMENTS
        self:UpdateAppearance()
    end)
end

function RosterBuilder:InitializeCreateAssignments()
    self.assignments = {}
    self.assignments.players = {}
    self.assignments.players.pane = CreateFrame("Frame", "SRTRoster_AssignablePlayersPane", self.content)
    self.assignments.players.pane:SetClipsChildren(false)
    self:SetToLeftSide(self.assignments.players.pane, self.content)
    self.assignments.bossSelector = FrameBuilder.CreateSelector(self.assignments.players.pane, {}, 280, self:GetHeaderFontType(), 16, "Select encounter...")
    self.assignments.bossSelector:SetPoint("TOPLEFT", 0, -5)
    self.assignments.players.title = self.assignments.players.pane:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.assignments.players.title:SetFont(self:GetHeaderFontType(), 14)
    self.assignments.players.title:SetTextColor(0.8, 0.8, 0.8, 1)
    self.assignments.players.title:SetText("Roster")
    self.assignments.players.title:SetPoint("TOPLEFT", self.assignments.bossSelector, "BOTTOMLEFT", 10, -8)
    self.assignments.players.scroll = FrameBuilder.CreateScrollArea(self.assignments.players.pane, "Players")
    self.assignments.players.scroll:SetPoint("TOPLEFT", 0, -51)
    self.assignments.players.scroll:SetPoint("TOPRIGHT", 0, -51)
    self.assignments.players.scroll:SetPoint("BOTTOMLEFT", 0, 38)
    self.assignments.players.scroll:SetPoint("BOTTOMRIGHT", 0, 38)
    self.assignments.encounter = {}
    self.assignments.encounter.pane = CreateFrame("Frame", "SRTRoster_BossAssignmentsPane", self.content)
    self.assignments.encounter.pane:SetClipsChildren(false)
    self:SetToRightSide(self.assignments.encounter.pane, self.content)
    self.assignments.encounter.title = self.assignments.encounter.pane:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.assignments.encounter.title:SetFont(self:GetHeaderFontType(), 14)
    self.assignments.encounter.title:SetTextColor(0.8, 0.8, 0.8, 1)
    self.assignments.encounter.title:SetText("")
    self.assignments.encounter.title:SetPoint("TOPLEFT", self.assignments.encounter.pane, "TOPLEFT", 10, -8)
    self.assignments.encounter.scroll = FrameBuilder.CreateScrollArea(self.assignments.encounter.pane, "Encounter")
    self.assignments.encounter.scroll:SetPoint("TOPLEFT", 0, -5)
    self.assignments.encounter.scroll:SetPoint("TOPRIGHT", 0, -5)
    self.assignments.encounter.scroll:SetPoint("BOTTOMLEFT", 0, 35)
    self.assignments.encounter.scroll:SetPoint("BOTTOMRIGHT", 0, 35)

    -- Create buttons
    self.assignments.backButton = FrameBuilder.CreateButton(self.assignments.players.pane, 95, 25, "Back", SRTColor.Red, SRTColor.RedHighlight)
    self.assignments.backButton:SetPoint("BOTTOMLEFT", self.content, "BOTTOMLEFT", 5, 5)
    self.assignments.backButton:SetScript("OnMouseDown", function (button)
        self.state = State.ADD_OR_REMOVE_PLAYERS
        self:UpdateAppearance()
    end)
    self.assignments.finishButton = FrameBuilder.CreateButton(self.assignments.encounter.pane, 95, 25, "Finish", SRTColor.Gray, SRTColor.Gray)
    self.assignments.finishButton:SetPoint("BOTTOMRIGHT", self.content, "BOTTOMRIGHT", -5, 5)
    self.assignments.finishButton:SetScript("OnMouseDown", nil)
end

function RosterBuilder:UpdateAppearance()
    SRTWindow.UpdateAppearance(self)

    self:UpdateLoadOrCreateRoster()
    self:UpdateAddOrRemovePlayers()
    self:UpdateCreateAssignments()
end

local rosterInfo = {}

--- Update left side of Load or Create state
function RosterBuilder:UpdateLoadOrCreateRoster()
    if self.state == State.LOAD_OR_CREATE_ROSTER then
        self.loadCreate.load.pane:Show()
        self.loadCreate.info.pane:Show()
    else
        self.loadCreate.load.pane:Hide()
        self.loadCreate.info.pane:Hide()
        for id, rosterFrame in pairs(self.availableRosters) do
            rosterFrame:Hide()
        end
        return
    end

    self.loadCreate.load.title:SetText("Saved Rosters")

    local previousFrame = nil
    local visibleRosters = 0
    for id, roster in pairs(SRTData.GetRosters()) do
        local rosterFrame = self.availableRosters[id] or FrameBuilder.CreateRosterFrame(self.loadCreate.load.scroll.content, roster, 260, 20, self:GetPlayerFont(), self:GetAppearance().playerFontSize)
        if previousFrame then
            rosterFrame:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -3)
        else
            rosterFrame:SetPoint("TOPLEFT", self.loadCreate.load.scroll.content, "TOPLEFT", 10, 0)
        end

        rosterFrame:SetScript("OnMouseDown", function ()
            self.selectedRoster = roster

            -- FIXME: REMOVE ME! FOR TESTING ONLY!
            self.selectedRoster.encounters = {}
            -- FIXME: REMOVE ME! FOR TESTING ONLY!

            self:UpdateAppearance()
        end)

        rosterFrame:Show()
        self.availableRosters[id] = rosterFrame
        previousFrame = rosterFrame
        visibleRosters = visibleRosters + 1
    end

    self.loadCreate.load.scroll.content:SetHeight(23*visibleRosters)

    if self.selectedRoster then
        self.loadCreate.deleteButton.color = SRTColor.Red
        self.loadCreate.deleteButton.colorHighlight = SRTColor.RedHighlight
        FrameBuilder.UpdateButton(self.loadCreate.deleteButton)
        self.loadCreate.deleteButton:SetScript("OnMouseDown", function (button)
            SRTData.RemoveRoster(self.selectedRoster.id)
            self.availableRosters[self.selectedRoster.id]:Hide()
            self.availableRosters[self.selectedRoster.id] = nil
            self.selectedRoster = nil
            self:UpdateAppearance()
        end)
        self.loadCreate.loadButton.color = SRTColor.Green
        self.loadCreate.loadButton.colorHightlight = SRTColor.GreenHighlight
        FrameBuilder.UpdateButton(self.loadCreate.loadButton)
        self.loadCreate.loadButton:SetScript("OnMouseDown", function (button)
            self.state = State.ADD_OR_REMOVE_PLAYERS
            self:UpdateAppearance()
        end)
        self.loadCreate.info.title:SetText(Roster.GetName(self.selectedRoster))

        rosterInfo.timestamp = rosterInfo.timestamp or self.loadCreate.info.scroll.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        rosterInfo.timestamp:SetFont(self:GetPlayerFont(), self:GetAppearance().playerFontSize)
        rosterInfo.timestamp:SetText("Created on "..self.selectedRoster.timestamp)
        rosterInfo.timestamp:SetTextColor(0.8, 0.8, 0.8, 1)
        rosterInfo.timestamp:SetPoint("TOPLEFT", 10, -5)
        rosterInfo.timestamp:Show()

        rosterInfo.players = rosterInfo.players or self.loadCreate.info.scroll.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        rosterInfo.players:SetFont(self:GetPlayerFont(), self:GetAppearance().playerFontSize)
        local playerNames = nil
        for _, player in pairs(self.selectedRoster.players) do
            if playerNames then
                playerNames = string.format("%s, %s", playerNames, strsplit("-", player.name))
            else
                playerNames = string.format("\nPlayers: \n\n%s", strsplit("-", player.name))
            end
        end
        rosterInfo.players:SetText(playerNames)
        rosterInfo.players:SetTextColor(0.8, 0.8, 0.8, 1)
        rosterInfo.players:SetWidth(260)
        rosterInfo.players:SetJustifyH("LEFT")
        rosterInfo.players:SetWordWrap(true)
        rosterInfo.players:SetPoint("TOPLEFT", rosterInfo.timestamp, "BOTTOMLEFT", 0, -3)
        rosterInfo.players:Show()

        rosterInfo.encounters = rosterInfo.encounters or self.loadCreate.info.scroll.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        rosterInfo.encounters:SetFont(self:GetPlayerFont(), self:GetAppearance().playerFontSize)
        local playerNames = nil
        -- self.selectedRoster.encounters[self.selectedEncounterID][assignmentFrame.abilityIndex].assignments[groupFrame.index]
        local encounterIDsWithFilledAssignments = function ()
            local ids = {}
            for encounterID, encounter in pairs(self.selectedRoster.encounters) do
                for _, abilityFrame in pairs(encounter) do
                    if #abilityFrame.assignments > 0 then
                        table.insert(ids, encounterID)
                        break
                    end
                end
            end
            return ids
        end
        local encounters = nil
        for _, encounterID in pairs(encounterIDsWithFilledAssignments()) do
            if encounters then
                encounters = string.format("%s, %d", encounters, encounterID)
            else
                encounters = string.format("\nEncounters: \n\n%d", encounterID)
            end
        end
        rosterInfo.encounters:SetText(encounters)
        rosterInfo.encounters:SetTextColor(0.8, 0.8, 0.8, 1)
        rosterInfo.encounters:SetWidth(260)
        rosterInfo.encounters:SetJustifyH("LEFT")
        rosterInfo.encounters:SetWordWrap(true)
        rosterInfo.encounters:SetPoint("TOPLEFT", rosterInfo.players, "BOTTOMLEFT", 0, -3)
        rosterInfo.encounters:Show()
    else
        self.loadCreate.deleteButton.color = SRTColor.Gray
        self.loadCreate.deleteButton.colorHighlight = SRTColor.GrayHighlight
        FrameBuilder.UpdateButton(self.loadCreate.deleteButton)
        self.loadCreate.deleteButton:SetScript("OnMouseDown", nil)
        self.loadCreate.loadButton.color = SRTColor.Gray
        self.loadCreate.loadButton.colorHightlight = SRTColor.GrayHighlight
        FrameBuilder.UpdateButton(self.loadCreate.loadButton)
        self.loadCreate.loadButton:SetScript("OnMouseDown", nil)
        if rosterInfo.timestamp then
            rosterInfo.timestamp:Hide()
        end
        if rosterInfo.players then
            rosterInfo.players:Hide()
        end
        if rosterInfo.encounters then
            rosterInfo.encounters:Hide()
        end
        self.loadCreate.info.title:SetText("No roster selected")
    end
end

--- Update roster; used in Create Roster and Select Role states
function RosterBuilder:UpdateAddOrRemovePlayers()
    if self.state == State.ADD_OR_REMOVE_PLAYERS then
        self.addRemove.roster.pane:Show()
        self.addRemove.available.pane:Show()
    else
        self.addRemove.roster.pane:Hide()
        self.addRemove.available.pane:Hide()
        for _, playerFrame in pairs(self.addRemove.roster.scroll.items) do
            playerFrame:Hide()
        end
        for _, playerFrame in pairs(self.addRemove.available.scroll.items) do
            playerFrame:Hide()
        end
        return
    end

    local lastPlayerFrame
    local visiblePlayers = 0
    for _, rosteredPlayer in pairs(self.selectedRoster.players) do
        local playerFrame = self.addRemove.roster.scroll.items[rosteredPlayer.name] or FrameBuilder.CreatePlayerFrame(self.addRemove.roster.scroll.content, rosteredPlayer.name, rosteredPlayer.class.fileName, 260, 20, self:GetPlayerFont(), self:GetAppearance().playerFontSize, 14)
        playerFrame.info = rosteredPlayer.info
        if lastPlayerFrame then
            playerFrame:SetPoint("TOPLEFT", lastPlayerFrame, "BOTTOMLEFT", 0, -3)
        else
            playerFrame:SetPoint("TOPLEFT", self.addRemove.roster.scroll.content, "TOPLEFT", 10, 0)
        end
        playerFrame:Show()
        playerFrame:SetMovable(true)
        playerFrame:EnableMouse(true)
        playerFrame:RegisterForDrag("LeftButton")
        playerFrame:SetScript("OnDragStart", function(_)
            self.addRemove.roster.scroll.DisconnectItem(rosteredPlayer.name, playerFrame, self.content)
            playerFrame:StartMoving()
        end)
        playerFrame:SetScript("OnDragStop", function(_)
            -- Change parent back to scrollpane
            playerFrame:SetParent(self.addRemove.roster.scroll.content)
            -- Stop moving
            playerFrame:StopMovingOrSizing()
            -- Check if over other pane
            if self.addRemove.available.scroll.IsMouseOverArea() then
                -- Remove from roster
                self.selectedRoster.players[rosteredPlayer.name] = nil
                self.addRemove.roster.scroll.items[rosteredPlayer.name] = nil
                self:UpdateAddOrRemovePlayers()
                playerFrame:Hide()
            else
                self.addRemove.roster.scroll.ConnectItem(rosteredPlayer.name, playerFrame)
            end
        end)

        self.addRemove.roster.scroll.items[rosteredPlayer.name] = playerFrame
        visiblePlayers = visiblePlayers + 1
        lastPlayerFrame = playerFrame
    end

    self.addRemove.roster.title:SetText(string.format("Roster (%d)", visiblePlayers))
    self.addRemove.roster.scroll.content:SetHeight(23 * visiblePlayers)

    local shouldShowPlayer = function(guildMember)
        if self.addRemove.roster.scroll.items[guildMember.name] then
            return false
        end
        if not self.addRemove.available.filterPopup.items.Class.popup.items[guildMember.class].value then
            return false
        end
        if not self.addRemove.available.filterPopup.items["Guild Rank"].popup.items[guildMember.rankIndex].value then
            return false
        end
        if self.addRemove.available.filterPopup.items["Online only"].value then
            return guildMember.online
        end
        return true
    end

    visiblePlayers = 0
    lastPlayerFrame = nil
    for name, frame in pairs(self.addRemove.available.scroll.items) do
        frame:Hide()
    end
    for name, playerInfo in pairs(self:GetGuildMembers()) do
        if shouldShowPlayer(playerInfo) then
            local playerFrame = self.addRemove.available.scroll.items[playerInfo.name] or FrameBuilder.CreatePlayerFrame(self.addRemove.available.scroll.content, playerInfo.name, playerInfo.classFileName, 260, 20, self:GetPlayerFont(), self:GetAppearance().playerFontSize, 14)
            playerFrame.info = playerInfo
            if lastPlayerFrame then
                playerFrame:SetPoint("TOPLEFT", lastPlayerFrame, "BOTTOMLEFT", 0, -3)
            else
                playerFrame:SetPoint("TOPLEFT", self.addRemove.available.scroll.content, "TOPLEFT", 10, 0)
            end
            playerFrame:SetMovable(true)
            playerFrame:EnableMouse(true)
            playerFrame:RegisterForDrag("LeftButton")
            playerFrame:SetScript("OnDragStart", function(_)
                self.addRemove.available.scroll.DisconnectItem(name, playerFrame, self.content)
                playerFrame:StartMoving()
            end)
            playerFrame:SetScript("OnDragStop", function(_)
                -- Change parent back to scrollpane
                playerFrame:SetParent(self.addRemove.available.scroll.content)
                playerFrame:StopMovingOrSizing()
                if self.addRemove.roster.scroll.IsMouseOverArea() then
                    self.selectedRoster.players[playerInfo.name] = self.selectedRoster.players[playerInfo.name] or Player:New(playerInfo.name, SRTData.GetClass(playerInfo.classFileName))
                    self.selectedRoster.players[playerInfo.name].info = playerInfo
                    playerFrame:Hide()
                    self:UpdateAddOrRemovePlayers()
                else
                    self.addRemove.available.scroll.ConnectItem(name, playerFrame)
                end

            end)
            playerFrame:Show()
            visiblePlayers = visiblePlayers + 1
            self.addRemove.available.scroll.items[playerInfo.name] = playerFrame
            lastPlayerFrame = playerFrame
        end
    end
    self.addRemove.available.title:SetText(string.format("Available Players (%d)", visiblePlayers))
    self.addRemove.available.scroll.content:SetHeight(23 * visiblePlayers)
end

function RosterBuilder:UpdateCreateAssignments()
    if self.state == State.CREATE_ASSIGNMENTS then
        self.assignments.players.pane:Show()
        self.assignments.encounter.pane:Show()
    else
        self.assignments.players.pane:Hide()
        self.assignments.encounter.pane:Hide()
        return
    end

    local shouldShowPlayer = function(rosterPlayer)
        return true
    end

    local visiblePlayers = 0
    local lastPlayerFrame = nil
    for name, player in pairs(self.selectedRoster.players) do
        if shouldShowPlayer(player) then
            local playerFrame = self.assignments.players.scroll.items[name] or FrameBuilder.CreatePlayerFrame(self.assignments.players.scroll.content, name, player.class.fileName, 260, 20, self:GetPlayerFont(), self:GetAppearance().playerFontSize, 14, true)
            playerFrame.info = player.info
            if lastPlayerFrame then
                playerFrame:SetPoint("TOPLEFT", lastPlayerFrame, "BOTTOMLEFT", 0, -3)
            else
                playerFrame:SetPoint("TOPLEFT", self.assignments.players.scroll.content, "TOPLEFT", 10, 0)
            end
            playerFrame:SetMovable(true)
            playerFrame:EnableMouse(true)
            playerFrame:RegisterForDrag("LeftButton")
            playerFrame:SetScript("OnDragStart", function(_)
                self.assignments.players.scroll.DisconnectItem(name, playerFrame, self.content)
                playerFrame:SetScript("OnUpdate", function ()
                    local mouseOverFound = false
                    for _, assignmentFrame in pairs(self.assignments.encounter.scroll.items) do
                        assignmentFrame:SetBackdropColor(0, 0, 0, 0)
                        if assignmentFrame.IsMouseOverFrame() then
                            for _, groupFrame in pairs(assignmentFrame.groups) do
                                if groupFrame.IsMouseOverFrame() then
                                    groupFrame:SetBackdropColor(1, 1, 1, 0.4)
                                    mouseOverFound = true
                                else
                                    groupFrame:SetBackdropColor(0, 0, 0, 0)
                                end
                            end
                            if mouseOverFound == false then
                                assignmentFrame:SetBackdropColor(1, 1, 1, 0.4)
                            end
                        end
                    end
                end)
                playerFrame:StartMoving()
            end)
            playerFrame:SetScript("OnDragStop", function(_)
                playerFrame:StopMovingOrSizing()
                self.assignments.players.scroll.ConnectItem(name, playerFrame)
                playerFrame:SetScript("OnUpdate", nil)
                for _, assignmentFrame in pairs(self.assignments.encounter.scroll.items) do
                    if assignmentFrame.IsMouseOverFrame() then
                        assignmentFrame:SetBackdropColor(0, 0, 0, 0)
                        for _, groupFrame in pairs(assignmentFrame.groups) do
                            if groupFrame.IsMouseOverFrame() then
                                groupFrame:SetBackdropColor(0, 0, 0, 0)

                                -- TODO Add to assignment group
                                self.selectedRoster.encounters = self.selectedRoster.encounters or {}
                                self.selectedRoster.encounters[self.selectedEncounterID] = self.selectedRoster.encounters[self.selectedEncounterID] or SRTData.GetAssignmentDefaults()[self.selectedEncounterID]
                                self.selectedRoster.encounters[self.selectedEncounterID][assignmentFrame.abilityIndex] = self.selectedRoster.encounters[self.selectedEncounterID][assignmentFrame.abilityIndex] or {}
                                self.selectedRoster.encounters[self.selectedEncounterID][assignmentFrame.abilityIndex].assignments = self.selectedRoster.encounters[self.selectedEncounterID][assignmentFrame.abilityIndex].assignments or {}
                                self.selectedRoster.encounters[self.selectedEncounterID][assignmentFrame.abilityIndex].assignments[groupFrame.index] = self.selectedRoster.encounters[self.selectedEncounterID][assignmentFrame.abilityIndex].assignments[groupFrame.index] or {}

                                local assignmentsInGroup = #self.selectedRoster.encounters[self.selectedEncounterID][assignmentFrame.abilityIndex].assignments[groupFrame.index]
                                if assignmentsInGroup == 2 then
                                    -- Group is already full; add new group
                                    break
                                end
                                -- TODO: Add spell select pane (similar to assignment explorer)
                                local classSpells = SRTData.GetClass(playerFrame.info.classFileName).spells
                                local spell = #classSpells > 0 and classSpells[math.random(#classSpells)] or nil
                                table.insert(self.selectedRoster.encounters[self.selectedEncounterID][assignmentFrame.abilityIndex].assignments[groupFrame.index], {
                                    ["spell_id"] = spell and spell.id or nil,
                                    ["type"] = "SPELL",
                                    ["player"] = name,
                                })
                                self:UpdateCreateAssignments()
                                return
                            end
                        end
                        self.selectedRoster.encounters = self.selectedRoster.encounters or {}
                        self.selectedRoster.encounters[self.selectedEncounterID] = self.selectedRoster.encounters[self.selectedEncounterID] or SRTData.GetAssignmentDefaults()[self.selectedEncounterID]
                        self.selectedRoster.encounters[self.selectedEncounterID][assignmentFrame.abilityIndex] = self.selectedRoster.encounters[self.selectedEncounterID][assignmentFrame.abilityIndex] or {}
                        self.selectedRoster.encounters[self.selectedEncounterID][assignmentFrame.abilityIndex].assignments = self.selectedRoster.encounters[self.selectedEncounterID][assignmentFrame.abilityIndex].assignments or {}
                        -- TODO: Add spell select pane (similar to assignment explorer)
                        local classSpells = SRTData.GetClass(playerFrame.info.classFileName).spells
                        local spell = #classSpells > 0 and classSpells[math.random(#classSpells)] or nil
                        table.insert(self.selectedRoster.encounters[self.selectedEncounterID][assignmentFrame.abilityIndex].assignments, {
                            [1] = {
                                ["spell_id"] = spell and spell.id or nil,
                                ["type"] = "SPELL",
                                ["player"] = name,
                            }
                        })
                        self:UpdateCreateAssignments()
                        return
                    end
                end
            end)
            lastPlayerFrame = playerFrame
            self.assignments.players.scroll.items[name] = playerFrame
            visiblePlayers = visiblePlayers + 1
        end
    end
    self.assignments.players.scroll.content:SetHeight(23 * visiblePlayers)

    if self.selectedEncounterID == nil then
        return
    elseif SRTData.GetAssignmentDefaults()[self.selectedEncounterID] == nil then
        self.assignments.encounter.title:SetText("No defaults available yet...")
        self.assignments.encounter.scroll:Hide()
        return
    else
        self.assignments.encounter.title:SetText("")
        self.assignments.encounter.scroll:Show()
    end
    
    self.selectedRoster.encounters = self.selectedRoster.encounters or {}
    local encounterAssignments = self.selectedRoster.encounters[self.selectedEncounterID] or SRTData.GetAssignmentDefaults()[self.selectedEncounterID]
    for _, item in pairs(self.assignments.encounter.scroll.items) do item:Hide() end
    DevTool:AddData(encounterAssignments, "encounterAssignments")
    local lastAbilityFrame = nil
    for bossAbilityIndex, bossAbility in ipairs(encounterAssignments) do
        -- Create frame for boss ability assignment groups
        local abilityFrameID = string.format("%d-%d", self.selectedEncounterID, bossAbilityIndex)
        local abilityFrame = self.assignments.encounter.scroll.items[abilityFrameID] or FrameBuilder.CreateBossAbilityAssignmentsFrame(self.assignments.encounter.scroll.content, bossAbility.metadata.name, bossAbilityIndex, 260, self:GetPlayerFont(), 14)
        if lastAbilityFrame then
            abilityFrame:SetPoint("TOPLEFT", lastAbilityFrame, "BOTTOMLEFT", 0, -3)
        else
            abilityFrame:SetPoint("TOPLEFT", self.assignments.encounter.scroll.content, "TOPLEFT", 5, 0)
        end
        abilityFrame:Show()

        -- Create known frames for current assignment groups and inner assignments
        for _, group in pairs(abilityFrame.groups) do group:Hide() end
        abilityFrame.groups = {}
        local previousGroup = nil
        for groupIndex, group in ipairs(encounterAssignments[bossAbilityIndex].assignments) do
            local groupFrame = FrameBuilder.CreateAssignmentGroupFrame(abilityFrame, self:GetAssignmentGroupHeight() + 3)
            FrameBuilder.UpdateAssignmentGroupFrame(groupFrame, "uuid-empty", groupIndex, self:GetAppearance().playerFontSize, self:GetAppearance().iconSize)
            
            groupFrame:ClearAllPoints()
            if previousGroup then
                groupFrame:SetPoint("TOPLEFT", previousGroup, "BOTTOMLEFT", 0, 0)
                groupFrame:SetPoint("TOPRIGHT", previousGroup, "BOTTOMRIGHT", 0, 0)
            else
                groupFrame:SetPoint("TOPLEFT", abilityFrame, "TOPLEFT", 0, -16)
                groupFrame:SetPoint("TOPRIGHT", abilityFrame, "TOPRIGHT", 0, -16)
            end

            for _, cd in pairs(groupFrame.assignments) do
                cd:Hide()
            end
            for assignmentIndex, assignment in ipairs(group) do
                local assignmentFrame = groupFrame.assignments[assignmentIndex] or FrameBuilder.CreateAssignmentFrame(groupFrame, assignmentIndex, self:GetPlayerFont(), self:GetAppearance().playerFontSize, self:GetAppearance().iconSize)
                FrameBuilder.UpdateAssignmentFrame(assignmentFrame, assignment)
                
                assignmentFrame:ClearAllPoints()
                if assignmentIndex > 1 then
                    assignmentFrame:SetPoint("BOTTOMLEFT", groupFrame, "BOTTOM")
                    assignmentFrame:SetPoint("TOPRIGHT", -10, 0)
                else
                    assignmentFrame:SetPoint("BOTTOMLEFT", 10, 0)
                    assignmentFrame:SetPoint("TOPRIGHT", groupFrame, "TOP", 0, 0)
                end

                assignmentFrame.groupIndex = groupIndex
                groupFrame.assignments[assignmentIndex] = assignmentFrame
            end

            abilityFrame.groups[groupIndex] = groupFrame
            previousGroup = groupFrame
        end
        abilityFrame.Update()

        self.assignments.encounter.scroll.items[abilityFrameID] = abilityFrame
        lastAbilityFrame = abilityFrame
    end
end

function RosterBuilder:GetAssignmentGroupHeight()
    local playerFontSize = self:GetAppearance().playerFontSize
    local iconSize = self:GetAppearance().iconSize
    return (playerFontSize > iconSize and playerFontSize or iconSize) + 7
end

function RosterBuilder:Update()
    SRTWindow.Update(self)

    self.assignments.bossSelector.items = {}
    SwiftdawnRaidTools:BossEncountersInit()
    for encounterID, name in pairs(SwiftdawnRaidTools:BossEncountersGetAll()) do
        local item = {
            name = name,
            encounterID = encounterID,
            onClick = function (row)
                self.selectedEncounterID = row.item.encounterID
                self:UpdateAppearance()
            end
        }
        table.insert(self.assignments.bossSelector.items, item)
    end
    self.assignments.bossSelector.selectedName = self.selectedEncounterID and SwiftdawnRaidTools:BossEncountersGetAll()[self.selectedEncounterID] or "Select encounter..."
    self.assignments.bossSelector.Update()
end

local lastUpdatedGuildMembers = 0
local guildMembers = {}
function RosterBuilder:GetGuildMembers()
    if GetTime() - lastUpdatedGuildMembers < 5 then
        return guildMembers
    end
    guildMembers = {}
    local numTotalGuildMembers, _, _ = GetNumGuildMembers()
    for index = 1, numTotalGuildMembers, 1 do
        local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile, isSoREligible, standingID = GetGuildRosterInfo(index)
        if level == 85 then
            table.insert(guildMembers, { name=name, rank=rank, rankIndex=rankIndex, level=level, class=class, zone=zone, note=note, officernote=officernote, online=online, status=status, classFileName=classFileName, achievementPoints=achievementPoints, achievementRank=achievementRank, isMobile=isMobile, isSoREligible=isSoREligible, standingID=standingID })
        end
    end
    table.sort(guildMembers, function (a, b)
        if a.online ~= b.online then
            return a.online
        elseif a.standing ~= b.standing then
            return a.standing > b.standing
        elseif a.rankIndex ~= b.rankIndex then
            return a.rankIndex < b.rankIndex
        else
            return a.name < b.name
        end
    end)
    return guildMembers
end

---@return FontFile
function RosterBuilder:GetHeaderFontType()
    ---@class FontFile
    return SharedMedia:Fetch("font", self:GetAppearance().headerFontType)
end

---@return FontFile
function RosterBuilder:GetPlayerFont()
    ---@class FontFile
    return SharedMedia:Fetch("font", self:GetAppearance().playerFontType)
end

function RosterBuilder:UpdatePopupMenu()
    if InCombatLockdown() then
        return
    end

    self.popupMenu.Update({
        { name = "Configuration", onClick = function() Settings.OpenToCategory("Swiftdawn Raid Tools") end, isSetting = true },
        {},
        { name = self:GetProfile().locked and "Unlock Window" or "Lock Window", onClick = function() self:ToggleLock() end, isSetting = true },
        { name = "Close Window", onClick = function() self:CloseWindow() end, isSetting = true },
        {},
        { name = "Close", onClick = nil, isSetting = true },
    })
end