local SwiftdawnRaidTools = SwiftdawnRaidTools
local SharedMedia = LibStub("LibSharedMedia-3.0")

local WINDOW_WIDTH = 600

local State = {
    ROSTER = 1,
    SAVED_ROSTERS = 2,
    AVAILABLE_PLAYERS = 3
}

--- Roster Explorer window class object
---@class RosterExplorer:SRTWindow
RosterExplorer = setmetatable({
    state = State.ROSTER,
    lastState = State.ROSTER,
}, SRTWindow)
RosterExplorer.__index = RosterExplorer

local availablePlayerFilterDefaults = {
    Class = {
        ["Death Knight"] = true,
        Druid = true,
        Hunter = true,
        Mage = true,
        Paladin = true,
        Priest = true,
        Rogue = true,
        Shaman = true,
        Warlock = true,
        Warrior = true
    },
    ["Guild Rank"] = {
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

function RosterExplorer:Initialize()
    SRTWindow.Initialize(self)
    -- Set header text
    self.headerText:SetText("Roster Explorer")
    -- Create roster pane
    self.rosterPane = CreateFrame("Frame", "SRTRoster_Roster", self.main)
    self.rosterPane:SetClipsChildren(true)
    self.rosterPane:SetPoint("TOPLEFT", self.main, "TOPLEFT", 10, -5)
    self.rosterPane:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", -10, -5)
    self.rosterPane:SetPoint("BOTTOMLEFT", self.main, "BOTTOMLEFT", 10, 5)
    self.rosterPane:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", -10, 5)
    -- Create roster pane left side
    self.rosterPaneLeft = CreateFrame("Frame", "SRTRoster_RosterLeft", self.rosterPane)
    self.rosterPaneLeft:SetClipsChildren(false)
    self.rosterPaneLeft:SetPoint("TOPLEFT", self.rosterPane, "TOPLEFT", 0, -0)
    self.rosterPaneLeft:SetPoint("TOPRIGHT", self.rosterPane, "TOP", -5, 0)
    self.rosterPaneLeft:SetPoint("BOTTOMLEFT", self.rosterPane, "BOTTOMLEFT", 0, 0)
    self.rosterPaneLeft:SetPoint("BOTTOMRIGHT", self.rosterPane, "BOTTOM", -5, 0)
    -- Create header for left pane
    self.rosterTitle = self.rosterPaneLeft:CreateFontString("SRTRoster_RosterTitle", "OVERLAY", "GameFontNormal")
    self.rosterTitle:SetPoint("TOPLEFT", self.rosterPaneLeft, "TOPLEFT", 5 , -5)
    self.rosterTitle:SetText("Roster (0)")
    self.rosterTitle:SetFont(self:GetHeaderFont(), 16)
    self.rosterTitle:SetTextColor(1, 1, 1, 0.8)
    -- Create scrolling roster content
    self.rosterScrollFrame = CreateFrame("ScrollFrame", "SRTRoster_RosterLeft_Scroll", self.rosterPaneLeft, "UIPanelScrollFrameTemplate")
    self.rosterScrollFrame:SetPoint("TOPLEFT", self.rosterPaneLeft, "TOPLEFT", 0, -28)
    self.rosterScrollFrame:SetPoint("TOPRIGHT", self.rosterPaneLeft, "TOPRIGHT", 0, -28)
    self.rosterScrollFrame:SetPoint("BOTTOMLEFT", self.rosterPaneLeft, "BOTTOMLEFT", 0, 5)
    self.rosterScrollFrame:SetPoint("BOTTOMRIGHT", self.rosterPaneLeft, "BOTTOMRIGHT", 0, 5)
    self.rosterScrollFrame.ScrollBar:SetValueStep(20)  -- Set scrolling speed per scroll step
    self.rosterScrollFrame.ScrollBar:SetMinMaxValues(0, 400)  -- Set based on content height - frame height
    self.rosterScrollContentFrame = CreateFrame("Frame", "SRTRoster_Roster_ScrollContent", self.rosterScrollFrame)
    self.rosterScrollContentFrame:SetSize(500, 8000)  -- Set the size of the content frame (height is larger for scrolling)
    self.rosterScrollContentFrame:SetPoint("TOPLEFT")
    self.rosterScrollContentFrame:SetPoint("TOPRIGHT")
    self.rosterScrollFrame:SetScrollChild(self.rosterScrollContentFrame)

    self.rosterScrollBar = _G["SRTRoster_RosterLeft_ScrollScrollBar"]
    self.rosterScrollBar.scrollStep = 23*3  -- Change this value to adjust the scroll amount per tick
    self.rosterScrollBar:SetPoint("TOPRIGHT", self.rosterScrollFrame, "TOPRIGHT", -12, 0)
    self.rosterScrollBar:SetPoint("BOTTOMRIGHT", self.rosterScrollFrame, "BOTTOMRIGHT", -12, 0)
    self.rosterScrollBar.ScrollUpButton:SetAlpha(0)
    self.rosterScrollBar.ScrollDownButton:SetAlpha(0)
    local thumbTexture = self.rosterScrollBar:GetThumbTexture()
    thumbTexture:SetColorTexture(0, 0, 0, 0.8)  -- RGBA (0, 0, 0, 1) sets it to solid black
    thumbTexture:SetWidth(5)  -- Customize the size as needed
    self.rosterScrollBar:Show()
    -- Setup roster pane right side
    self.rosterPaneRight = CreateFrame("Frame", "SRTRoster_RosterRight", self.rosterPane)
    self.rosterPaneRight:SetClipsChildren(true)
    self.rosterPaneRight:SetPoint("TOPLEFT", self.rosterPane, "TOP", 5, 0)
    self.rosterPaneRight:SetPoint("TOPRIGHT", self.rosterPane, "TOPRIGHT", 0, 0)
    self.rosterPaneRight:SetPoint("BOTTOMLEFT", self.rosterPane, "BOTTOM", 5, 0)
    self.rosterPaneRight:SetPoint("BOTTOMRIGHT", self.rosterPane, "BOTTOMRIGHT", 0, 0)
    -- Create buttons
    self.rosterPaneRightAddButton = FrameBuilder.CreateButton(self.rosterPaneRight, 85, 25, "Add Player", SRTColor.Green, SRTColor.GreenHighlight)
    self.rosterPaneRightAddButton:SetPoint("BOTTOMRIGHT", self.rosterPaneRight, "BOTTOMRIGHT", -5, 5)
    self.rosterPaneRightAddButton:SetScript("OnMouseDown", function (button)
        self.state = State.AVAILABLE_PLAYERS
        self:UpdateAppearance()
    end)
    self.rosterPaneRightLoadButton = FrameBuilder.CreateButton(self.rosterPaneRight, 85, 25, "Load Roster", SRTColor.Green, SRTColor.GreenHighlight)
    self.rosterPaneRightLoadButton:SetPoint("RIGHT", self.rosterPaneRightAddButton, "LEFT", -10, 0)
    self.rosterPaneRightLoadButton:SetScript("OnMouseDown", function (button)
        self.state = State.SAVED_ROSTERS
        self:UpdateAppearance()
    end)
    -- Create saved roster pane
    self.savedRosterPane = CreateFrame("Frame", "SRTRoster_Saved", self.main)
    self.savedRosterPane:SetClipsChildren(true)
    self.savedRosterPane:SetPoint("TOPLEFT", self.main, "TOPLEFT", 10, -5)
    self.savedRosterPane:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", -10, -5)
    self.savedRosterPane:SetPoint("BOTTOMLEFT", self.main, "BOTTOMLEFT", 10, 5)
    self.savedRosterPane:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", -10, 5)
    -- Create saved roster left pane
    self.savedRosterPaneLeft = CreateFrame("Frame", "SRTRoster_SavedLeft", self.savedRosterPane)
    self.savedRosterPaneLeft:SetClipsChildren(true)
    self.savedRosterPaneLeft:SetPoint("TOPLEFT", self.savedRosterPane, "TOPLEFT", 0, -0)
    self.savedRosterPaneLeft:SetPoint("TOPRIGHT", self.savedRosterPane, "TOP", -5, 0)
    self.savedRosterPaneLeft:SetPoint("BOTTOMLEFT", self.savedRosterPane, "BOTTOMLEFT", 0, 0)
    self.savedRosterPaneLeft:SetPoint("BOTTOMRIGHT", self.savedRosterPane, "BOTTOM", -5, 0)
    -- Create header for left pane
    self.savedRosterTitle = self.savedRosterPaneLeft:CreateFontString("SRTRoster_SavedLeft_Title", "OVERLAY", "GameFontNormal")
    self.savedRosterTitle:SetPoint("TOPLEFT", self.savedRosterPaneLeft, "TOPLEFT", 5 , -5)
    self.savedRosterTitle:SetText("Saved Rosters")
    self.savedRosterTitle:SetFont(self:GetHeaderFont(), 16)
    self.savedRosterTitle:SetTextColor(1, 1, 1, 0.8)
    -- Create saved roster right pane
    self.savedRosterPaneRight = CreateFrame("Frame", "SRTRoster_SavedRight", self.savedRosterPane)
    self.savedRosterPaneRight:SetClipsChildren(true)
    self.savedRosterPaneRight:SetPoint("TOPLEFT", self.savedRosterPane, "TOP", 5, 0)
    self.savedRosterPaneRight:SetPoint("TOPRIGHT", self.savedRosterPane, "TOPRIGHT", 0, 0)
    self.savedRosterPaneRight:SetPoint("BOTTOMLEFT", self.savedRosterPane, "BOTTOM", 5, 0)
    self.savedRosterPaneRight:SetPoint("BOTTOMRIGHT", self.savedRosterPane, "BOTTOMRIGHT", 0, 0)
    -- Create buttons
    self.savedRosterPaneRightCancel = FrameBuilder.CreateButton(self.savedRosterPaneRight, 75, 25, "Cancel", SRTColor.Red, SRTColor.RedHighlight)
    self.savedRosterPaneRightCancel:SetPoint("BOTTOMRIGHT", self.savedRosterPaneRight, "BOTTOMRIGHT", -5, 5)
    self.savedRosterPaneRightCancel:SetScript("OnMouseDown", function (button)
        self.state = State.ROSTER
        self:UpdateAppearance()
    end)
    self.savedRosterPaneRightDelete = FrameBuilder.CreateButton(self.savedRosterPaneRight, 75, 25, "Delete", SRTColor.Red, SRTColor.RedHighlight)
    self.savedRosterPaneRightDelete:SetPoint("RIGHT", self.savedRosterPaneRightCancel, "LEFT", -10, 0)
    self.savedRosterPaneRightDelete:SetScript("OnMouseDown", function (button)
        self.state = State.ROSTER
        self:UpdateAppearance()
    end)
    self.savedRosterPaneRightLoad = FrameBuilder.CreateButton(self.savedRosterPaneRight, 75, 25, "Load", SRTColor.Red, SRTColor.RedHighlight)
    self.savedRosterPaneRightLoad:SetPoint("RIGHT", self.savedRosterPaneRightDelete, "LEFT", -10, 0)
    self.savedRosterPaneRightLoad:SetScript("OnMouseDown", function (button)
        self.state = State.ROSTER
        self:UpdateAppearance()
    end)
    -- Create available players pane
    self.availablePlayersPane = CreateFrame("Frame", "SRTRoster_AvailablePlayers", self.main)
    self.availablePlayersPane:SetClipsChildren(true)
    self.availablePlayersPane:SetPoint("TOPLEFT", self.main, "TOPLEFT", 10, -5)
    self.availablePlayersPane:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", -10, -5)
    self.availablePlayersPane:SetPoint("BOTTOMLEFT", self.main, "BOTTOMLEFT", 10, 5)
    self.availablePlayersPane:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", -10, 5)
    -- Create available players left pane
    self.availablePlayersPaneLeft = CreateFrame("Frame", "SRTRoster_AvailablePlayersLeft", self.availablePlayersPane)
    -- self.availablePlayersPaneLeft:SetClipsChildren(true)
    self.availablePlayersPaneLeft:SetPoint("TOPLEFT", self.availablePlayersPane, "TOPLEFT", 0, -0)
    self.availablePlayersPaneLeft:SetPoint("TOPRIGHT", self.availablePlayersPane, "TOP", -5, 0)
    self.availablePlayersPaneLeft:SetPoint("BOTTOMLEFT", self.availablePlayersPane, "BOTTOMLEFT", 0, 0)
    self.availablePlayersPaneLeft:SetPoint("BOTTOMRIGHT", self.availablePlayersPane, "BOTTOM", -5, 0)
    -- Create header for left pane
    self.availablePlayersTitle = self.availablePlayersPaneLeft:CreateFontString("SRTRoster_AvailablePlayersLeft_Title", "OVERLAY", "GameFontNormal")
    self.availablePlayersTitle:SetPoint("TOPLEFT", self.availablePlayersPaneLeft, "TOPLEFT", 5 , -5)
    self.availablePlayersTitle:SetText("Available Players")
    self.availablePlayersTitle:SetFont(self:GetHeaderFont(), 16)
    self.availablePlayersTitle:SetTextColor(1, 1, 1, 0.8)
    self.availablePlayersFilterButton = CreateFrame("Button", "SRTRoster_AvailablePlayersLeft_Filter", self.availablePlayersPaneLeft, "BackdropTemplate")
    self.availablePlayersFilterButton.texture = self.availablePlayersFilterButton:CreateTexture(nil, "BACKGROUND")
    self.availablePlayersFilterButton.texture:SetTexture("Interface\\Addons\\SwiftdawnRaidTools\\Media\\filter_white_64x64.tga")
    self.availablePlayersFilterButton.texture:SetAllPoints()
    self.availablePlayersFilterButton.texture:SetAlpha(0.8)
    self.availablePlayersFilterButton:SetSize(18, 18)
    self.availablePlayersFilterButton:SetPoint("TOPRIGHT", self.availablePlayersPaneLeft, "TOPRIGHT", -5, -5)

    local updateFunction = function ()
        self:UpdateAvailablePlayersPane()
    end
    self.availablePlayersFilterPopup = FrameBuilder.CreateFilterMenu(self.availablePlayersFilterButton, availablePlayerFilterDefaults, self:GetPlayerFontType(), updateFunction)
    self.availablePlayersFilterPopup:SetPoint("TOPLEFT", self.availablePlayersFilterButton, "BOTTOMLEFT", 0, -3)
    self.availablePlayersFilterPopup:Hide()
    self.availablePlayersFilterButton:SetScript("OnClick", function ()
        if self.availablePlayersFilterPopup:IsShown() then self.availablePlayersFilterPopup:Hide() else self.availablePlayersFilterPopup:Show() end
    end)

    -- Create scrolling roster content
    self.availablePlayersScrollFrame = CreateFrame("ScrollFrame", "SRTRoster_AvailablePlayersLeft_Scroll", self.availablePlayersPaneLeft, "UIPanelScrollFrameTemplate")
    self.availablePlayersScrollFrame:SetPoint("TOPLEFT", self.availablePlayersPaneLeft, "TOPLEFT", 0, -28)
    self.availablePlayersScrollFrame:SetPoint("TOPRIGHT", self.availablePlayersPaneLeft, "TOPRIGHT", 0, -28)
    self.availablePlayersScrollFrame:SetPoint("BOTTOMLEFT", self.availablePlayersPaneLeft, "BOTTOMLEFT", 0, 5)
    self.availablePlayersScrollFrame:SetPoint("BOTTOMRIGHT", self.availablePlayersPaneLeft, "BOTTOMRIGHT", 0, 5)
    self.availablePlayersScrollFrame.ScrollBar:SetValueStep(20)  -- Set scrolling speed per scroll step
    self.availablePlayersScrollFrame.ScrollBar:SetMinMaxValues(0, 400)  -- Set based on content height - frame height
    self.availablePlayersScrollContentFrame = CreateFrame("Frame", "SRTRoster_AvailablePlayersLeft_ScrollContent", self.availablePlayersScrollFrame)
    self.availablePlayersScrollContentFrame:SetSize(500, 8000)  -- Set the size of the content frame (height is larger for scrolling)
    self.availablePlayersScrollContentFrame:SetPoint("TOPLEFT")
    self.availablePlayersScrollContentFrame:SetPoint("TOPRIGHT")
    self.availablePlayersScrollFrame:SetScrollChild(self.availablePlayersScrollContentFrame)
    
    self.availablePlayersScrollBar = _G["SRTRoster_AvailablePlayersLeft_ScrollScrollBar"]
    self.availablePlayersScrollBar.scrollStep = 23*3  -- Change this value to adjust the scroll amount per tick
    self.availablePlayersScrollBar:SetPoint("TOPRIGHT", self.availablePlayersScrollFrame, "TOPRIGHT", -12, 0)
    self.availablePlayersScrollBar:SetPoint("BOTTOMRIGHT", self.availablePlayersScrollFrame, "BOTTOMRIGHT", -12, 0)
    self.availablePlayersScrollBar.ScrollUpButton:SetAlpha(0)
    self.availablePlayersScrollBar.ScrollDownButton:SetAlpha(0)
    local thumbTexture = self.availablePlayersScrollBar:GetThumbTexture()
    thumbTexture:SetColorTexture(0, 0, 0, 0.8)  -- RGBA (0, 0, 0, 1) sets it to solid black
    thumbTexture:SetWidth(5)  -- Customize the size as needed
    self.availablePlayersScrollBar:Show()

    -- Create available players right pane
    self.availablePlayersPaneRight = CreateFrame("Frame", "SRTRoster_AvailablePlayersRight", self.availablePlayersPane)
    self.availablePlayersPaneRight:SetClipsChildren(true)
    self.availablePlayersPaneRight:SetPoint("TOPLEFT", self.availablePlayersPane, "TOP", 5, 0)
    self.availablePlayersPaneRight:SetPoint("TOPRIGHT", self.availablePlayersPane, "TOPRIGHT", 0, 0)
    self.availablePlayersPaneRight:SetPoint("BOTTOMLEFT", self.availablePlayersPane, "BOTTOM", 5, 0)
    self.availablePlayersPaneRight:SetPoint("BOTTOMRIGHT", self.availablePlayersPane, "BOTTOMRIGHT", 0, 0)
    -- Create buttons
    self.availablePlayersPaneRightCancel = FrameBuilder.CreateButton(self.availablePlayersPaneRight, 75, 25, "Cancel", SRTColor.Red, SRTColor.RedHighlight)
    self.availablePlayersPaneRightCancel:SetPoint("BOTTOMRIGHT", self.availablePlayersPaneRight, "BOTTOMRIGHT", -5, 5)
    self.availablePlayersPaneRightCancel:SetScript("OnMouseDown", function (button)
        self.state = State.ROSTER
        self:UpdateAppearance()
    end)
    self.availablePlayersPaneRightAdd = FrameBuilder.CreateButton(self.availablePlayersPaneRight, 75, 25, "Add", SRTColor.Green, SRTColor.GreenHighlight)
    self.availablePlayersPaneRightAdd:SetPoint("RIGHT", self.availablePlayersPaneRightCancel, "LEFT", -10, 0)
    self.availablePlayersPaneRightAdd:Hide()
    -- Update appearance
    self:UpdateAppearance()
end

function RosterExplorer:UpdateAppearance()
    SRTWindow.UpdateAppearance(self)

    self:UpdateRosterPane()
    self:UpdateSavedRostersPane()
    self:UpdateAvailablePlayersPane()
end

function RosterExplorer:UpdateRosterPane()
    if self.state == State.ROSTER then
        self.rosterPane:Show()
    else
        self.rosterPane:Hide()
        return
    end

    self.roster = self.roster or {}
    self.rosterTitle:SetText(string.format("Roster (%d)", #self.roster))

    local lastPlayerFrame
    local visiblePlayers = 0
    for _, rosteredPlayer in pairs(self.roster) do
        local playerFrame = rosteredPlayer.frame or FrameBuilder.CreatePlayerFrame(self.rosterScrollContentFrame, rosteredPlayer.info.name, rosteredPlayer.info.classFileName, 260, 20, self:GetPlayerFontType(), self:GetAppearance().playerFontSize, 14)
        playerFrame.info = rosteredPlayer.info
        if lastPlayerFrame then
            playerFrame:SetPoint("TOPLEFT", lastPlayerFrame, "BOTTOMLEFT", 0, -3)
        else
            playerFrame:SetPoint("TOPLEFT", self.rosterScrollContentFrame, "TOPLEFT", 10, 0)
        end
        playerFrame:SetMovable(true)
        playerFrame:EnableMouse(true)
        playerFrame:RegisterForDrag("LeftButton")
        playerFrame:SetScript("OnDragStart", function(_)
            local _, myParent = playerFrame:GetPoint(1)
            playerFrame:ClearAllPoints()
            local child = self:FindConnectedRosterPlayer(playerFrame)
            if child then
                if child.frame:GetName() == self.rosterScrollContentFrame:GetName() then
                    child.frame:SetPoint("TOPLEFT", myParent, "TOPLEFT", 10, 0)
                else
                    child.frame:SetPoint("TOPLEFT", myParent, "BOTTOMLEFT", 0, -3)
                end
            end
            playerFrame:StartMoving()
        end)
        playerFrame:SetScript("OnDragStop", function(_)
            playerFrame:StopMovingOrSizing()
            local firstPlayer = self:FindFirstRosterPlayer()
            if firstPlayer then
                firstPlayer.frame:SetPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 0, -3)
            end
            playerFrame:SetPoint("TOPLEFT", self.rosterScrollContentFrame, "TOPLEFT", 10, 0)
        end)

        rosteredPlayer.frame = playerFrame
        visiblePlayers = visiblePlayers + 1
        lastPlayerFrame = playerFrame
    end
    self.rosterScrollContentFrame:SetHeight(23 * visiblePlayers)
end

function RosterExplorer:FindConnectedRosterPlayer(playerFrame)
    for otherName, other in pairs(self.roster) do
        if otherName ~= playerFrame.info.name then
            local _, otherParent = other.frame:GetPoint(1)
            if otherParent:GetName() == playerFrame:GetName() then
                return other
            end
        end
    end
    return nil
end

function RosterExplorer:FindFirstRosterPlayer()
    for name, player in pairs(self.roster) do
        local _, parent = player.frame:GetPoint(1)
        if parent and parent:GetName() == self.rosterScrollContentFrame:GetName() then
            return player
        end
    end
end

function RosterExplorer:UpdateSavedRostersPane()
    if self.state == State.SAVED_ROSTERS then
        self.savedRosterPane:Show()
    else
        self.savedRosterPane:Hide()
        return
    end
end

function RosterExplorer:UpdateAvailablePlayersPane()
    if self.state == State.AVAILABLE_PLAYERS then
        self.availablePlayersPane:Show()
    else
        self.availablePlayersPane:Hide()
        return
    end

    self.availablePlayers = self.availablePlayers or {}
    self.availablePlayers.guild = self.availablePlayers.guild or {}
    self.availablePlayers.guild.name = "Swiftdawn"
    self.availablePlayers.guild.players = self.availablePlayers.guild.players or {}
    for _, player in pairs(self.availablePlayers.guild.players) do player:Hide() end
    local visiblePlayers = 0
    local lastPlayerFrame
    for _, guildMember in pairs(self:GetGuildMembers()) do
        if self:ShouldShowPlayer(guildMember) then
            local playerFrame = self.availablePlayers.guild.players[guildMember.name] or FrameBuilder.CreatePlayerFrame(self.availablePlayersScrollContentFrame, guildMember.name, guildMember.classFileName, 260, 20, self:GetPlayerFontType(), self:GetAppearance().playerFontSize, 14)
            playerFrame.info = guildMember
            if lastPlayerFrame then
                playerFrame:SetPoint("TOPLEFT", lastPlayerFrame, "BOTTOMLEFT", 0, -3)
            else
                playerFrame:SetPoint("TOPLEFT", self.availablePlayersScrollContentFrame, "TOPLEFT", 10, 0)
            end
            playerFrame:SetScript("OnMouseDown", function (pf)
                self.availablePlayersPane.selected = pf.info
                self:UpdateAvailablePlayersPane()
            end)
            playerFrame:Show()
            visiblePlayers = visiblePlayers + 1
            self.availablePlayers.guild.players[guildMember.name] = playerFrame
            lastPlayerFrame = playerFrame
        end
    end
    -- Set the size of the content frame (height is larger for scrolling)
    -- DevTool:AddData(self.availablePlayers.guild.players, "availablePlayers.guild.players")
    self.availablePlayersScrollContentFrame:SetHeight(23 * visiblePlayers)

    if self.availablePlayersPane.selected then
        -- Name
        self.availablePlayersPaneRight.nameTitle = self.availablePlayersPaneRight.nameTitle or self.availablePlayersPaneRight:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.availablePlayersPaneRight.nameTitle:SetPoint("TOPLEFT", self.availablePlayersPaneRight, "TOPLEFT", 5 , -5)
        self.availablePlayersPaneRight.nameTitle:SetText(strsplit("-", self.availablePlayersPane.selected.name))
        self.availablePlayersPaneRight.nameTitle:SetFont(self:GetHeaderFont(), 16)
        local color = SwiftdawnRaidTools:GetClassColor(self.availablePlayersPane.selected.classFileName)
        self.availablePlayersPaneRight.nameTitle:SetTextColor(color.r, color.g, color.b, 0.8)
        -- Class
        self.availablePlayersPaneRight.classTitle = self.availablePlayersPaneRight.classTitle or self.availablePlayersPaneRight:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.availablePlayersPaneRight.classTitle:SetPoint("TOPLEFT", self.availablePlayersPaneRight, "TOPLEFT", 10 , -29)
        self.availablePlayersPaneRight.classTitle:SetText(self.availablePlayersPane.selected.class)
        self.availablePlayersPaneRight.classTitle:SetFont(self:GetHeaderFont(), 14)
        self.availablePlayersPaneRight.classTitle:SetTextColor(1, 1, 1, 0.8)
        -- Add button
        self.availablePlayersPaneRightAdd:SetScript("OnMouseDown", function (button)
            self.roster[self.availablePlayersPane.selected.name] = { info = self.availablePlayersPane.selected }
            self.state = State.ROSTER
            self:UpdateAppearance()
        end)
        self.availablePlayersPaneRightAdd:Show()
    else
        -- Add button
        self.availablePlayersPaneRightAdd:Hide()
    end
end

function RosterExplorer:ShouldShowPlayer(guildMember)
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

function RosterExplorer:Update()
    SRTWindow.Update(self)
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

    local configurationFunc = function() InterfaceOptionsFrame_OpenToCategory("Swiftdawn Raid Tools") end
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
