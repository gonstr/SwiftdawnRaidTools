local SwiftdawnRaidTools = SwiftdawnRaidTools
local SharedMedia = LibStub("LibSharedMedia-3.0")

local WINDOW_WIDTH = 600

local State = {
    LOAD_OR_CREATE_ROSTER = 1,
    ROSTER_AND_AVAILABLE_PLAYERS = 2,
    LOAD_ROSTER = 3,
    ROSTER_AND_ROLE_BUCKETS = 4
}

--- Roster Explorer window class object
---@class RosterExplorer:SRTWindow
RosterExplorer = setmetatable({
    state = State.LOAD_OR_CREATE_ROSTER,
    lastState = State.LOAD_OR_CREATE_ROSTER,
    roster = {},
    availablePlayers = {
        guild = {
            players = {}
        }
    }
}, SRTWindow)
RosterExplorer.__index = RosterExplorer

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
        [0] = true,
        [1] = true,
        [2] = true,
        [3] = true,
        [4] = true,
        [5] = true,
        [6] = true,
        [7] = true,
        [8] = true,
        [9] = true,
        [10] = true,
        [11] = true
    },
    ["Online only"] = false,
}

---@return RosterExplorer
function RosterExplorer:New(height)
    local obj = SRTWindow.New(self, "RosterExplorer", height, WINDOW_WIDTH, nil, nil, WINDOW_WIDTH, WINDOW_WIDTH)
    ---@cast obj RosterExplorer
    self.__index = self
    return obj
end

function RosterExplorer:SetToLeftSide(child, parent)
    child:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    child:SetPoint("TOPRIGHT", parent, "TOP", -5, 0)
    child:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
    child:SetPoint("BOTTOMRIGHT", parent, "BOTTOM", -5, 0)
end

function RosterExplorer:SetToRightSide(child, parent)
    child:SetPoint("TOPLEFT", parent, "TOP", 5, 0)
    child:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    child:SetPoint("BOTTOMLEFT", parent, "BOTTOM", 5, 0)
    child:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
end

function RosterExplorer:InitializeLoadRosterPane()
    self.loadRosterPane = CreateFrame("Frame", "SRTRoster_Load", self.content)
    self.loadRosterPane:SetClipsChildren(false)
    self:SetToLeftSide(self.loadRosterPane, self.content)
    self.loadRosterTitle = self.loadRosterPane:CreateFontString(self.loadRosterPane:GetName().."_Title", "OVERLAY", "GameFontNormal")
    self.loadRosterTitle:SetPoint("TOPLEFT", self.loadRosterPane, "TOPLEFT", 5 , -5)
    self.loadRosterTitle:SetText("Roster")
    self.loadRosterTitle:SetFont(self:GetHeaderFont(), 16)
    self.loadRosterTitle:SetTextColor(1, 1, 1, 0.8)
    self.loadRosterScrollFrame = CreateFrame("ScrollFrame", self.loadRosterPane:GetName().."_Scroll", self.loadRosterPane, "UIPanelScrollFrameTemplate")
    self.loadRosterScrollFrame:SetClipsChildren(false)
    self.loadRosterScrollFrame:SetPoint("TOPLEFT", self.loadRosterPane, "TOPLEFT", 0, -28)
    self.loadRosterScrollFrame:SetPoint("TOPRIGHT", self.loadRosterPane, "TOPRIGHT", 0, -28)
    self.loadRosterScrollFrame:SetPoint("BOTTOMLEFT", self.loadRosterPane, "BOTTOMLEFT", 0, 35)
    self.loadRosterScrollFrame:SetPoint("BOTTOMRIGHT", self.loadRosterPane, "BOTTOMRIGHT", 0, 35)
    self.loadRosterScrollFrame.ScrollBar:SetValueStep(20)  -- Set scrolling speed per scroll step
    self.loadRosterScrollFrame.ScrollBar:SetMinMaxValues(0, 400)  -- Set based on content height - frame height
    self.loadRosterScrollContentFrame = CreateFrame("Frame", self.loadRosterPane:GetName().."_ScrollContent", self.loadRosterScrollFrame)
    self.loadRosterScrollContentFrame:SetSize(500, 8000)  -- Set the size of the content frame (height is larger for scrolling)
    self.loadRosterScrollContentFrame:SetPoint("TOPLEFT")
    self.loadRosterScrollContentFrame:SetPoint("TOPRIGHT")
    self.loadRosterScrollFrame:SetScrollChild(self.loadRosterScrollContentFrame)
    self.loadRosterScrollBar = _G[self.loadRosterScrollFrame:GetName().."ScrollBar"]
    self.loadRosterScrollBar.scrollStep = 23*3  -- Change this value to adjust the scroll amount per tick
    self.loadRosterScrollBar:SetPoint("TOPRIGHT", self.loadRosterScrollFrame, "TOPRIGHT", -12, 0)
    self.loadRosterScrollBar:SetPoint("BOTTOMRIGHT", self.loadRosterScrollFrame, "BOTTOMRIGHT", -12, 0)
    self.loadRosterScrollBar.ScrollUpButton:SetAlpha(0)
    self.loadRosterScrollBar.ScrollDownButton:SetAlpha(0)
    local thumbTexture = self.loadRosterScrollBar:GetThumbTexture()
    thumbTexture:SetColorTexture(0, 0, 0, 0.8)  -- RGBA (0, 0, 0, 1) sets it to solid black
    thumbTexture:SetWidth(5)  -- Customize the size as needed
    self.loadRosterScrollBar:Show()
end

function RosterExplorer:InitializeSelectedRosterInfoPane()
    self.selectedRosterInfoPane = CreateFrame("Frame", "SRTRoster_SelectedInfo", self.content)
    self.selectedRosterInfoPane:SetClipsChildren(false)
    self:SetToRightSide(self.selectedRosterInfoPane, self.content)
    self.selectedRosterInfoTitle = self.selectedRosterInfoPane:CreateFontString(self.selectedRosterInfoPane:GetName().."_Title", "OVERLAY", "GameFontNormal")
    self.selectedRosterInfoTitle:SetPoint("TOPLEFT", self.selectedRosterInfoPane, "TOPLEFT", 5 , -5)
    self.selectedRosterInfoTitle:SetText("Selected Player Info")
    self.selectedRosterInfoTitle:SetFont(self:GetHeaderFont(), 16)
    self.selectedRosterInfoTitle:SetTextColor(1, 1, 1, 0.8)
    self.selectedRosterInfoScrollFrame = CreateFrame("ScrollFrame", self.selectedRosterInfoPane:GetName().."_Scroll", self.selectedRosterInfoPane, "UIPanelScrollFrameTemplate")
    self.selectedRosterInfoScrollFrame:SetClipsChildren(false)
    self.selectedRosterInfoScrollFrame:SetPoint("TOPLEFT", self.selectedRosterInfoPane, "TOPLEFT", 0, -28)
    self.selectedRosterInfoScrollFrame:SetPoint("TOPRIGHT", self.selectedRosterInfoPane, "TOPRIGHT", 0, -28)
    self.selectedRosterInfoScrollFrame:SetPoint("BOTTOMLEFT", self.selectedRosterInfoPane, "BOTTOMLEFT", 0, 35)
    self.selectedRosterInfoScrollFrame:SetPoint("BOTTOMRIGHT", self.selectedRosterInfoPane, "BOTTOMRIGHT", 0, 35)
    self.selectedRosterInfoScrollFrame.ScrollBar:SetValueStep(20)  -- Set scrolling speed per scroll step
    self.selectedRosterInfoScrollFrame.ScrollBar:SetMinMaxValues(0, 400)  -- Set based on content height - frame height
    self.selectedRosterInfoScrollContentFrame = CreateFrame("Frame", self.selectedRosterInfoPane:GetName().."_ScrollContent", self.selectedRosterInfoScrollFrame)
    self.selectedRosterInfoScrollContentFrame:SetSize(500, 8000)  -- Set the size of the content frame (height is larger for scrolling)
    self.selectedRosterInfoScrollContentFrame:SetPoint("TOPLEFT")
    self.selectedRosterInfoScrollContentFrame:SetPoint("TOPRIGHT")
    self.selectedRosterInfoScrollFrame:SetScrollChild(self.selectedRosterInfoScrollContentFrame)
    self.selectedRosterInfoScrollBar = _G[self.selectedRosterInfoScrollFrame:GetName().."ScrollBar"]
    self.selectedRosterInfoScrollBar.scrollStep = 23*3  -- Change this value to adjust the scroll amount per tick
    self.selectedRosterInfoScrollBar:SetPoint("TOPRIGHT", self.selectedRosterInfoScrollFrame, "TOPRIGHT", -12, 0)
    self.selectedRosterInfoScrollBar:SetPoint("BOTTOMRIGHT", self.selectedRosterInfoScrollFrame, "BOTTOMRIGHT", -12, 0)
    self.selectedRosterInfoScrollBar.ScrollUpButton:SetAlpha(0)
    self.selectedRosterInfoScrollBar.ScrollDownButton:SetAlpha(0)
    local thumbTexture = self.selectedRosterInfoScrollBar:GetThumbTexture()
    thumbTexture:SetColorTexture(0, 0, 0, 0.8)  -- RGBA (0, 0, 0, 1) sets it to solid black
    thumbTexture:SetWidth(5)  -- Customize the size as needed
    self.selectedRosterInfoScrollBar:Show()

    -- Create buttons
    self.buttonCreateNewRoster = FrameBuilder.CreateButton(self.selectedRosterInfoPane, 95, 25, "Create New", SRTColor.Green, SRTColor.GreenHighlight)
    self.buttonCreateNewRoster:SetPoint("BOTTOMRIGHT", self.content, "BOTTOMRIGHT", -5, 5)
    self.buttonCreateNewRoster:SetScript("OnMouseDown", function (button)
        -- TODO: Empty roster and start fresh one
        self.state = State.ROSTER_AND_AVAILABLE_PLAYERS
        self:UpdateAppearance()
    end)
    self.buttonLoadRoster = FrameBuilder.CreateButton(self.selectedRosterInfoPane, 95, 25, "Load", SRTColor.Gray, SRTColor.Gray)
    self.buttonLoadRoster:SetPoint("RIGHT", self.buttonCreateNewRoster, "LEFT", -5, 0)
    self.buttonLoadRoster:SetScript("OnMouseDown", function (button)
        -- TODO: Actually load whatever is selected, if something is selected!
        self.state = State.ROSTER_AND_AVAILABLE_PLAYERS
        self:UpdateAppearance()
    end)
end

function RosterExplorer:InitializeRosterPane()
    self.rosterPane = CreateFrame("Frame", "SRTRoster_RosterPane", self.content)
    self.rosterPane:SetClipsChildren(false)
    self:SetToLeftSide(self.rosterPane, self.content)
    self.rosterTitle = self.rosterPane:CreateFontString(self.rosterPane:GetName().."_Title", "OVERLAY", "GameFontNormal")
    self.rosterTitle:SetPoint("TOPLEFT", self.rosterPane, "TOPLEFT", 5 , -5)
    self.rosterTitle:SetText("Roster")
    self.rosterTitle:SetFont(self:GetHeaderFont(), 16)
    self.rosterTitle:SetTextColor(1, 1, 1, 0.8)
    self.rosterScrollFrame = CreateFrame("ScrollFrame", self.rosterPane:GetName().."_Scroll", self.rosterPane, "UIPanelScrollFrameTemplate")
    self.rosterScrollFrame:SetClipsChildren(false)
    self.rosterScrollFrame:SetPoint("TOPLEFT", self.rosterPane, "TOPLEFT", 0, -28)
    self.rosterScrollFrame:SetPoint("TOPRIGHT", self.rosterPane, "TOPRIGHT", 0, -28)
    self.rosterScrollFrame:SetPoint("BOTTOMLEFT", self.rosterPane, "BOTTOMLEFT", 0, 35)
    self.rosterScrollFrame:SetPoint("BOTTOMRIGHT", self.rosterPane, "BOTTOMRIGHT", 0, 35)
    self.rosterScrollFrame.ScrollBar:SetValueStep(20)  -- Set scrolling speed per scroll step
    self.rosterScrollFrame.ScrollBar:SetMinMaxValues(0, 400)  -- Set based on content height - frame height
    self.rosterScrollContentFrame = CreateFrame("Frame", self.rosterPane:GetName().."_ScrollContent", self.rosterScrollFrame)
    self.rosterScrollContentFrame:SetSize(500, 8000)  -- Set the size of the content frame (height is larger for scrolling)
    self.rosterScrollContentFrame:SetPoint("TOPLEFT")
    self.rosterScrollContentFrame:SetPoint("TOPRIGHT")
    self.rosterScrollFrame:SetScrollChild(self.rosterScrollContentFrame)
    self.rosterScrollBar = _G[self.rosterScrollFrame:GetName().."ScrollBar"]
    self.rosterScrollBar.scrollStep = 23*3  -- Change this value to adjust the scroll amount per tick
    self.rosterScrollBar:SetPoint("TOPRIGHT", self.rosterScrollFrame, "TOPRIGHT", -12, 0)
    self.rosterScrollBar:SetPoint("BOTTOMRIGHT", self.rosterScrollFrame, "BOTTOMRIGHT", -12, 0)
    self.rosterScrollBar.ScrollUpButton:SetAlpha(0)
    self.rosterScrollBar.ScrollDownButton:SetAlpha(0)
    local thumbTexture = self.rosterScrollBar:GetThumbTexture()
    thumbTexture:SetColorTexture(0, 0, 0, 0.8)  -- RGBA (0, 0, 0, 1) sets it to solid black
    thumbTexture:SetWidth(5)  -- Customize the size as needed
    self.rosterScrollBar:Show()
    self.buttonBackToLoad = FrameBuilder.CreateButton(self.rosterPane, 95, 25, "Back", SRTColor.Red, SRTColor.RedHighlight)
    self.buttonBackToLoad:SetPoint("BOTTOMLEFT", self.content, "BOTTOMLEFT", 5, 5)
    self.buttonBackToLoad:SetScript("OnMouseDown", function (button)
        -- TODO: Actually load whatever is selected, if something is selected!
        self.state = State.LOAD_OR_CREATE_ROSTER
        self:UpdateAppearance()
    end)
end

function RosterExplorer:InitializeAvailablePlayersPane()
    self.availablePlayersPane = CreateFrame("Frame", "SRTRoster_AvailablePlayers", self.content)
    self.availablePlayersPane:SetClipsChildren(false)
    self:SetToRightSide(self.availablePlayersPane, self.content)
    self.availablePlayersTitle = self.availablePlayersPane:CreateFontString(self.availablePlayersPane:GetName().."_Title", "OVERLAY", "GameFontNormal")
    self.availablePlayersTitle:SetPoint("TOPLEFT", self.availablePlayersPane, "TOPLEFT", 5 , -5)
    self.availablePlayersTitle:SetText("Available Players")
    self.availablePlayersTitle:SetFont(self:GetHeaderFont(), 16)
    self.availablePlayersTitle:SetTextColor(1, 1, 1, 0.8)
    self.availablePlayersFilterButton = CreateFrame("Button", self.availablePlayersPane:GetName().."_Filter", self.availablePlayersPane, "BackdropTemplate")
    self.availablePlayersFilterButton.texture = self.availablePlayersFilterButton:CreateTexture(nil, "BACKGROUND")
    self.availablePlayersFilterButton.texture:SetTexture("Interface\\Addons\\SwiftdawnRaidTools\\Media\\filter_white_64x64.tga")
    self.availablePlayersFilterButton.texture:SetAllPoints()
    self.availablePlayersFilterButton.texture:SetAlpha(0.8)
    self.availablePlayersFilterButton:SetSize(16, 16)
    self.availablePlayersFilterButton:SetPoint("TOPRIGHT", self.content, "TOPRIGHT", -5, -5)
    self.availablePlayersFilterPopup = FrameBuilder.CreateFilterMenu(self.availablePlayersFilterButton, availablePlayerFilterDefaults, self:GetPlayerFontType(), function() self:UpdateAvailablePlayersPane() end)
    self.availablePlayersFilterPopup:SetPoint("TOPLEFT", self.availablePlayersFilterButton, "BOTTOMLEFT", 0, -3)
    self.availablePlayersFilterPopup:Hide()
    self.availablePlayersFilterButton:SetScript("OnClick", function ()
        if self.availablePlayersFilterPopup:IsShown() then self.availablePlayersFilterPopup:Hide() else self.availablePlayersFilterPopup:Show() end
    end)
    self.availablePlayersScrollFrame = CreateFrame("ScrollFrame", self.availablePlayersPane:GetName().."_Scroll", self.availablePlayersPane, "UIPanelScrollFrameTemplate")
    self.availablePlayersScrollFrame:SetClipsChildren(false)
    self.availablePlayersScrollFrame:SetPoint("TOPLEFT", self.availablePlayersPane, "TOPLEFT", 0, -28)
    self.availablePlayersScrollFrame:SetPoint("TOPRIGHT", self.availablePlayersPane, "TOPRIGHT", 0, -28)
    self.availablePlayersScrollFrame:SetPoint("BOTTOMLEFT", self.availablePlayersPane, "BOTTOMLEFT", 0, 35)
    self.availablePlayersScrollFrame:SetPoint("BOTTOMRIGHT", self.availablePlayersPane, "BOTTOMRIGHT", 0, 35)
    self.availablePlayersScrollFrame.ScrollBar:SetValueStep(20)  -- Set scrolling speed per scroll step
    self.availablePlayersScrollFrame.ScrollBar:SetMinMaxValues(0, 400)  -- Set based on content height - frame height
    self.availablePlayersScrollContentFrame = CreateFrame("Frame", self.availablePlayersPane:GetName().."_ScrollContent", self.availablePlayersScrollFrame)
    self.availablePlayersScrollContentFrame:SetClipsChildren(false)
    self.availablePlayersScrollContentFrame:SetSize(500, 8000)  -- Set the size of the content frame (height is larger for scrolling)
    self.availablePlayersScrollContentFrame:SetPoint("TOPLEFT")
    self.availablePlayersScrollContentFrame:SetPoint("TOPRIGHT")
    self.availablePlayersScrollFrame:SetScrollChild(self.availablePlayersScrollContentFrame)
    self.availablePlayersScrollBar = _G[self.availablePlayersScrollFrame:GetName().."ScrollBar"]
    self.availablePlayersScrollBar.scrollStep = 23*3  -- Change this value to adjust the scroll amount per tick
    self.availablePlayersScrollBar:SetPoint("TOPRIGHT", self.availablePlayersScrollFrame, "TOPRIGHT", -12, 0)
    self.availablePlayersScrollBar:SetPoint("BOTTOMRIGHT", self.availablePlayersScrollFrame, "BOTTOMRIGHT", -12, 0)
    self.availablePlayersScrollBar.ScrollUpButton:SetAlpha(0)
    self.availablePlayersScrollBar.ScrollDownButton:SetAlpha(0)
    local thumbTexture = self.availablePlayersScrollBar:GetThumbTexture()
    thumbTexture:SetColorTexture(0, 0, 0, 0.8)  -- RGBA (0, 0, 0, 1) sets it to solid black
    thumbTexture:SetWidth(5)  -- Customize the size as needed
    self.availablePlayersScrollBar:Show()
    self.buttonAssignRoles = FrameBuilder.CreateButton(self.availablePlayersPane, 95, 25, "Assign Roles", SRTColor.Green, SRTColor.GreenHighlight)
    self.buttonAssignRoles:SetPoint("BOTTOMRIGHT", self.content, "BOTTOMRIGHT", -5, 5)
    self.buttonAssignRoles:SetScript("OnMouseDown", function (button)
        -- TODO: Actually load whatever is selected, if something is selected!
        self.state = State.ROSTER_AND_ROLE_BUCKETS
        self:UpdateAppearance()
    end)
end

function RosterExplorer:InitializeRoleBucketsPane()
    self.roleBucketsPane = CreateFrame("Frame", "SRTRoster_SelectedInfo", self.content)
    self.roleBucketsPane:SetClipsChildren(false)
    self:SetToRightSide(self.roleBucketsPane, self.content)
    self.roleBucketsTitle = self.roleBucketsPane:CreateFontString(self.roleBucketsPane:GetName().."_Title", "OVERLAY", "GameFontNormal")
    self.roleBucketsTitle:SetPoint("TOPLEFT", self.roleBucketsPane, "TOPLEFT", 5 , -5)
    self.roleBucketsTitle:SetText("Role Buckets")
    self.roleBucketsTitle:SetFont(self:GetHeaderFont(), 16)
    self.roleBucketsTitle:SetTextColor(1, 1, 1, 0.8)

    -- Create buttons
    self.buttonRaidAssignments = FrameBuilder.CreateButton(self.roleBucketsPane, 95, 25, "Assignments", SRTColor.Green, SRTColor.GreenHighlight)
    self.buttonRaidAssignments:SetPoint("BOTTOMRIGHT", self.content, "BOTTOMRIGHT", -5, 5)
    self.buttonRaidAssignments:SetScript("OnMouseDown", function (button)
        -- TODO: Empty roster and start fresh one
        self.state = State.LOAD_OR_CREATE_ROSTER
        self:UpdateAppearance()
    end)
end

function RosterExplorer:Initialize()
    SRTWindow.Initialize(self)
    -- Unset clipping to show filter menu out the side
    self.container:SetClipsChildren(false)

    -- Set header text
    self.headerText:SetText("Roster Explorer")

    -- Create content pane
    self.content = CreateFrame("Frame", "SRTRoster_Content", self.main)
    self.content:SetClipsChildren(false)
    self.content:SetPoint("TOPLEFT", self.main, "TOPLEFT", 10, -5)
    self.content:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", -10, -5)
    self.content:SetPoint("BOTTOMLEFT", self.main, "BOTTOMLEFT", 10, 5)
    self.content:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", -10, 5)

    -- Create possible left/right panes
    self:InitializeLoadRosterPane()
    self:InitializeSelectedRosterInfoPane()
    self:InitializeRosterPane()
    self:InitializeAvailablePlayersPane()
    self:InitializeRoleBucketsPane()

    -- Update appearance
    self:UpdateAppearance()
end

function RosterExplorer:UpdateAppearance()
    SRTWindow.UpdateAppearance(self)

    self:UpdateLoadRosterPane()
    self:UpdateSelectedSavedRosterPane()
    self:UpdateRosterPane()
    self:UpdateAvailablePlayersPane()
    self:UpdateRoleBucketsPane()
end

--- Update left side of Load or Create state
function RosterExplorer:UpdateLoadRosterPane()
    if self.state == State.LOAD_OR_CREATE_ROSTER then
        self.loadRosterPane:Show()
    else
        self.loadRosterPane:Hide()
        return
    end

    self.loadRosterTitle:SetText("Saved Rosters")
end

--- Update right side of Load and Create state 
function RosterExplorer:UpdateSelectedSavedRosterPane()
    if self.state == State.LOAD_OR_CREATE_ROSTER then
        self.selectedRosterInfoPane:Show()
    else
        self.selectedRosterInfoPane:Hide()
        return
    end
    self.selectedRosterInfoTitle:SetText("Selected Roster Info")
end

--- Update roster; used in Create Roster and Select Role states
function RosterExplorer:UpdateRosterPane()
    if self.state == State.ROSTER_AND_AVAILABLE_PLAYERS or self.state == State.ROSTER_AND_ROLE_BUCKETS then
        self.rosterPane:Show()
    else
        self.rosterPane:Hide()
        for _, player in pairs(self.roster) do
            player.frame:Hide()
        end
        return
    end

    local lastPlayerFrame
    local visiblePlayers = 0
    for name, rosteredPlayer in pairs(self.roster) do
        local playerFrame = rosteredPlayer.frame or FrameBuilder.CreatePlayerFrame(self.rosterScrollContentFrame, rosteredPlayer.info.name, rosteredPlayer.info.classFileName, 260, 20, self:GetPlayerFontType(), self:GetAppearance().playerFontSize, 14)
        playerFrame.info = rosteredPlayer.info
        if lastPlayerFrame then
            playerFrame:SetPoint("TOPLEFT", lastPlayerFrame, "BOTTOMLEFT", 0, -3)
        else
            playerFrame:SetPoint("TOPLEFT", self.rosterScrollContentFrame, "TOPLEFT", 10, 0)
        end
        playerFrame:Show()
        playerFrame:SetMovable(true)
        playerFrame:EnableMouse(true)
        playerFrame:RegisterForDrag("LeftButton")
        playerFrame:SetScript("OnDragStart", function(_)
            -- Mark as picked up (may not be required)
            self.pickedUp = playerFrame.info.name
            -- Change parent to content to avoid cutoff
            playerFrame:SetParent(self.content)
            -- Cleverly connect next row to previous row
            local _, myParent = playerFrame:GetPoint(1)
            local child = self:FindScrollChild(playerFrame, self.roster)
            if child then
                if child.frame:GetName() == self.rosterScrollContentFrame:GetName() then
                    child.frame:SetPoint("TOPLEFT", myParent, "TOPLEFT", 10, 0)
                else
                    child.frame:SetPoint("TOPLEFT", myParent, "BOTTOMLEFT", 0, -3)
                end
            end
            -- Disconnect
            playerFrame:ClearAllPoints()
            -- Move!
            playerFrame:StartMoving()
        end)
        playerFrame:SetScript("OnDragStop", function(_)
            -- Mark as dropped
            self.pickedUp = nil
            -- Change parent back to scrollpane
            playerFrame:SetParent(self.rosterScrollContentFrame)
            -- Stop moving
            playerFrame:StopMovingOrSizing()
            -- Check if over other pane
            local x, y = GetCursorPosition()
            local overAvailablePlayers = self:IsOverAvailablePlayers(x, y)
            if overAvailablePlayers then
                -- Remove from roster
                self.roster[rosteredPlayer.info.name] = nil
                self:UpdateRosterPane()
                self:UpdateAvailablePlayersPane()
                playerFrame:Hide()
            else
                local firstPlayer = self:FindFirstInScroll(self.roster, self.rosterScrollContentFrame)
                if firstPlayer then
                    firstPlayer.frame:SetPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 0, -3)
                end
                playerFrame:SetPoint("TOPLEFT", self.rosterScrollContentFrame, "TOPLEFT", 10, 0)
            end
        end)

        rosteredPlayer.frame = playerFrame
        self.roster[name] = rosteredPlayer
        visiblePlayers = visiblePlayers + 1
        lastPlayerFrame = playerFrame
    end

    self.rosterTitle:SetText(string.format("Roster (%d)", visiblePlayers))
    self.rosterScrollContentFrame:SetHeight(23 * visiblePlayers)
end

--- Update available players; used in create roster state
function RosterExplorer:UpdateAvailablePlayersPane()
    if self.state == State.ROSTER_AND_AVAILABLE_PLAYERS then
        self.availablePlayersPane:Show()
    else
        self.availablePlayersPane:Hide()
        for _, player in pairs(self.availablePlayers.guild.players) do
            player.frame:Hide()
        end
        return
    end

    for _, player in pairs(self.availablePlayers.guild.players) do player.frame:Hide() end
    local visiblePlayers = 0
    local lastPlayerFrame
    for _, guildMember in pairs(self:GetGuildMembers()) do
        if self:ShouldShowPlayer(guildMember) then
            if not self.availablePlayers.guild.players[guildMember.name] then 
                self.availablePlayers.guild.players[guildMember.name] = {}
            end
            local playerFrame = self.availablePlayers.guild.players[guildMember.name].frame or FrameBuilder.CreatePlayerFrame(self.availablePlayersScrollContentFrame, guildMember.name, guildMember.classFileName, 260, 20, self:GetPlayerFontType(), self:GetAppearance().playerFontSize, 14)
            playerFrame.info = guildMember
            if lastPlayerFrame then
                playerFrame:SetPoint("TOPLEFT", lastPlayerFrame, "BOTTOMLEFT", 0, -3)
            else
                playerFrame:SetPoint("TOPLEFT", self.availablePlayersScrollContentFrame, "TOPLEFT", 10, 0)
            end
            playerFrame:SetMovable(true)
            playerFrame:EnableMouse(true)
            playerFrame:RegisterForDrag("LeftButton")
            playerFrame:SetScript("OnDragStart", function(_)
                -- Mark as picked up (may not be required)
                self.pickedUp = playerFrame.info.name
                -- Change parent to content to avoid cutoff
                playerFrame:SetParent(self.content)
                -- Cleverly connect my child to my parent
                local _, myParent = playerFrame:GetPoint(1)
                local child = self:FindScrollChild(playerFrame, self.availablePlayers.guild.players)
                if child then
                    if child.frame:GetName() == self.availablePlayersScrollContentFrame:GetName() then
                        child.frame:SetPoint("TOPLEFT", myParent, "TOPLEFT", 10, 0)
                    else
                        child.frame:SetPoint("TOPLEFT", myParent, "BOTTOMLEFT", 0, -3)
                    end
                end
                -- Disconnect
                playerFrame:ClearAllPoints()
                -- Move!
                playerFrame:StartMoving()
            end)
            playerFrame:SetScript("OnDragStop", function(_)
                self.pickedUp = nil
                -- Change parent back to scrollpane
                playerFrame:SetParent(self.availablePlayersScrollContentFrame)
                playerFrame:StopMovingOrSizing()
                local x, y = GetCursorPosition()
                local overRoster = self:IsOverRoster(x, y)
                if overRoster then
                    self.roster[guildMember.name] = { info = guildMember }
                    playerFrame:Hide()
                    self:UpdateRosterPane()
                else
                    local firstPlayer = self:FindFirstInScroll(self.availablePlayers.guild.players, self.availablePlayersScrollContentFrame)
                    if firstPlayer then
                        firstPlayer.frame:SetPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 0, -3)
                    end
                    playerFrame:SetPoint("TOPLEFT", self.availablePlayersScrollContentFrame, "TOPLEFT", 10, 0)
                    playerFrame:Show()
                end

            end)
            playerFrame:Show()
            visiblePlayers = visiblePlayers + 1
            self.availablePlayers.guild.players[guildMember.name].frame = playerFrame
            lastPlayerFrame = playerFrame
        end
    end
    self.availablePlayersTitle:SetText(string.format("Available Players (%d)", visiblePlayers))
    self.availablePlayersScrollContentFrame:SetHeight(23 * visiblePlayers)
end

--- Update right side of Load and Create state 
function RosterExplorer:UpdateRoleBucketsPane()
    if self.state == State.ROSTER_AND_ROLE_BUCKETS then
        self.roleBucketsPane:Show()
    else
        self.roleBucketsPane:Hide()
        return
    end
    self.roleBucketsTitle:SetText("Role Buckets")
end

function RosterExplorer:Update()
    SRTWindow.Update(self)
end

function RosterExplorer:IsOverRoster(x, y)
    local scale = UIParent:GetScale()
    local left = self.rosterScrollFrame:GetLeft() * scale
    local right = self.rosterScrollFrame:GetRight() * scale
    local top = self.rosterScrollFrame:GetTop() * scale
    local bottom = self.rosterScrollFrame:GetBottom() * scale

    if left < x and right > x and top > y and bottom < y then
        return true
    else
        return false
    end
end

function RosterExplorer:IsOverAvailablePlayers(x, y)
    local scale = UIParent:GetScale()
    local left = self.availablePlayersScrollFrame:GetLeft() * scale
    local right = self.availablePlayersScrollFrame:GetRight() * scale
    local top = self.availablePlayersScrollFrame:GetTop() * scale
    local bottom = self.availablePlayersScrollFrame:GetBottom() * scale

    if left < x and right > x and top > y and bottom < y then
        return true
    else
        return false
    end
end

function RosterExplorer:FindFirstInScroll(list, scrollFrame)
    for name, playerFrame in pairs(list) do
        local _, parentFrame = playerFrame.frame:GetPoint(1)
        if parentFrame and parentFrame:GetName() == scrollFrame:GetName() then
            return playerFrame
        end
    end
end

function RosterExplorer:FindScrollChild(playerFrame, list)
    for otherName, other in pairs(list) do
        if otherName ~= playerFrame.info.name then
            local _, otherParent = other.frame:GetPoint(1)
            if otherParent and otherParent:GetName() == playerFrame:GetName() then
                return other
            end
        end
    end
    return nil
end

function RosterExplorer:ShouldShowPlayer(guildMember)
    if self.pickedUp == guildMember.name then
        return false
    end
    if self.roster[guildMember.name] then
        return false
    end
    if not self.availablePlayersFilterPopup.items.Class.popup.items[guildMember.class].value then
        return false
    end
    if not self.availablePlayersFilterPopup.items["Guild Rank"].popup.items[guildMember.rankIndex].value then
        return false
    end
    if self.availablePlayersFilterPopup.items["Online only"].value then
        return guildMember.online
    end
    return true
end

local lastUpdatedGuildMembers = 0
local guildMembers = {}
function RosterExplorer:GetGuildMembers()
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
function RosterExplorer:GetHeaderFontType()
    ---@class FontFile
    return SharedMedia:Fetch("font", self:GetAppearance().headerFontType)
end

---@return FontFile
function RosterExplorer:GetPlayerFontType()
    ---@class FontFile
    return SharedMedia:Fetch("font", self:GetAppearance().playerFontType)
end

function RosterExplorer:UpdatePopupMenu()
    local index = 1

    local lockFunc = function()
        self:ToggleLock()
        LibStub("AceConfigRegistry-3.0"):NotifyChange("SwiftdawnRaidTools")
    end
    local lockedText = "Lock Roster Explorer"
    if self:GetProfile().locked then lockedText = "Unlock Roster Explorer" end
    self:ShowPopupListItem(index, lockedText, true, lockFunc, 0, false)

    index = index + 1

    local configurationFunc = function() Settings.OpenToCategory("Swiftdawn Raid Tools") end
    self:ShowPopupListItem(index, "Configuration", true, configurationFunc, 0, false)

    index = index + 1

    local closeFunc = function ()
        self.container:Hide()
        self:GetProfile().show = false
    end
    self:ShowPopupListItem(index, "Close Explorer", true, closeFunc, 0, false)

    index = index + 1

    local yOfs = self:ShowPopupListItem(index, "Close", true, nil, 0, true)

    local popupHeight = math.abs(yOfs) + 30

    -- Update popup size
    self.popupMenu:SetHeight(popupHeight)
end
