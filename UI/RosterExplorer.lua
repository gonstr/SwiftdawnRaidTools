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
    lastState = State.ROSTER
}, SRTWindow)
RosterExplorer.__index = RosterExplorer

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
    self.rosterPane = CreateFrame("Frame", nil, self.main)
    self.rosterPane:SetClipsChildren(true)
    self.rosterPane:SetPoint("TOPLEFT", self.main, "TOPLEFT", 10, -5)
    self.rosterPane:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", -10, -5)
    self.rosterPane:SetPoint("BOTTOMLEFT", self.main, "BOTTOMLEFT", 10, 5)
    self.rosterPane:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", -10, 5)
    -- Create roster pane left side
    self.rosterPaneLeft = CreateFrame("Frame", nil, self.rosterPane)
    self.rosterPaneLeft:SetClipsChildren(true)
    self.rosterPaneLeft:SetPoint("TOPLEFT", self.rosterPane, "TOPLEFT", 0, -0)
    self.rosterPaneLeft:SetPoint("TOPRIGHT", self.rosterPane, "TOP", -5, 0)
    self.rosterPaneLeft:SetPoint("BOTTOMLEFT", self.rosterPane, "BOTTOMLEFT", 0, 0)
    self.rosterPaneLeft:SetPoint("BOTTOMRIGHT", self.rosterPane, "BOTTOM", -5, 0)
    -- Create header for left pane
    self.rosterTitle = self.rosterPaneLeft:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.rosterTitle:SetPoint("TOPLEFT", self.rosterPaneLeft, "TOPLEFT", 5 , -5)
    self.rosterTitle:SetText("Roster")
    self.rosterTitle:SetFont(self:GetHeaderFont(), 16)
    self.rosterTitle:SetTextColor(1, 1, 1, 0.8)
    -- Create scrolling roster content
    self.rosterScrollFrame = CreateFrame("ScrollFrame", nil, self.rosterPaneLeft, "UIPanelScrollFrameTemplate")
    self.rosterScrollFrame:SetPoint("TOPLEFT", self.rosterPaneLeft, "TOPLEFT", 0, -21)
    self.rosterScrollFrame:SetPoint("TOPRIGHT", self.rosterPaneLeft, "TOPRIGHT", 0, -21)
    self.rosterScrollFrame:SetPoint("BOTTOMLEFT", self.rosterPaneLeft, "BOTTOMLEFT", 0, 5)
    self.rosterScrollFrame:SetPoint("BOTTOMRIGHT", self.rosterPaneLeft, "BOTTOMRIGHT", 0, 5)
    self.rosterScrollContentFrame = CreateFrame("Frame", nil, self.rosterScrollFrame)
    self.rosterScrollContentFrame:SetSize(self.rosterPaneLeft:GetWidth(), 800)  -- Set the size of the content frame (height is larger for scrolling)
    self.rosterScrollContentFrame:SetPoint("TOPLEFT")
    self.rosterScrollContentFrame:SetPoint("TOPRIGHT")
    self.rosterScrollFrame:SetScrollChild(self.rosterScrollContentFrame)
    -- Setup roster pane right side
    self.rosterPaneRight = CreateFrame("Frame", nil, self.rosterPane)
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
    self.savedRosterPane = CreateFrame("Frame", nil, self.main)
    self.savedRosterPane:SetClipsChildren(true)
    self.savedRosterPane:SetPoint("TOPLEFT", self.main, "TOPLEFT", 10, -5)
    self.savedRosterPane:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", -10, -5)
    self.savedRosterPane:SetPoint("BOTTOMLEFT", self.main, "BOTTOMLEFT", 10, 5)
    self.savedRosterPane:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", -10, 5)
    -- Create saved roster left pane
    self.savedRosterPaneLeft = CreateFrame("Frame", nil, self.savedRosterPane)
    self.savedRosterPaneLeft:SetClipsChildren(true)
    self.savedRosterPaneLeft:SetPoint("TOPLEFT", self.savedRosterPane, "TOPLEFT", 0, -0)
    self.savedRosterPaneLeft:SetPoint("TOPRIGHT", self.savedRosterPane, "TOP", -5, 0)
    self.savedRosterPaneLeft:SetPoint("BOTTOMLEFT", self.savedRosterPane, "BOTTOMLEFT", 0, 0)
    self.savedRosterPaneLeft:SetPoint("BOTTOMRIGHT", self.savedRosterPane, "BOTTOM", -5, 0)
    -- Create header for left pane
    self.rosterTitle = self.savedRosterPaneLeft:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.rosterTitle:SetPoint("TOPLEFT", self.savedRosterPaneLeft, "TOPLEFT", 5 , -5)
    self.rosterTitle:SetText("Saved Rosters")
    self.rosterTitle:SetFont(self:GetHeaderFont(), 16)
    self.rosterTitle:SetTextColor(1, 1, 1, 0.8)
    -- Create saved roster right pane
    self.savedRosterPaneRight = CreateFrame("Frame", nil, self.savedRosterPane)
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
    self.availablePlayersPane = CreateFrame("Frame", nil, self.main)
    self.availablePlayersPane:SetClipsChildren(true)
    self.availablePlayersPane:SetPoint("TOPLEFT", self.main, "TOPLEFT", 10, -5)
    self.availablePlayersPane:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", -10, -5)
    self.availablePlayersPane:SetPoint("BOTTOMLEFT", self.main, "BOTTOMLEFT", 10, 5)
    self.availablePlayersPane:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", -10, 5)
    -- Create available players left pane
    self.availablePlayersPaneLeft = CreateFrame("Frame", nil, self.availablePlayersPane)
    self.availablePlayersPaneLeft:SetClipsChildren(true)
    self.availablePlayersPaneLeft:SetPoint("TOPLEFT", self.availablePlayersPane, "TOPLEFT", 0, -0)
    self.availablePlayersPaneLeft:SetPoint("TOPRIGHT", self.availablePlayersPane, "TOP", -5, 0)
    self.availablePlayersPaneLeft:SetPoint("BOTTOMLEFT", self.availablePlayersPane, "BOTTOMLEFT", 0, 0)
    self.availablePlayersPaneLeft:SetPoint("BOTTOMRIGHT", self.availablePlayersPane, "BOTTOM", -5, 0)
    -- Create header for left pane
    self.availablePlayersTitle = self.availablePlayersPaneLeft:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.availablePlayersTitle:SetPoint("TOPLEFT", self.availablePlayersPaneLeft, "TOPLEFT", 5 , -5)
    self.availablePlayersTitle:SetText("Available Players")
    self.availablePlayersTitle:SetFont(self:GetHeaderFont(), 16)
    self.availablePlayersTitle:SetTextColor(1, 1, 1, 0.8)
    -- Create scrolling roster content
    self.availablePlayersScrollFrame = CreateFrame("ScrollFrame", "availablePlayersScrollFrame", self.availablePlayersPaneLeft, "UIPanelScrollFrameTemplate")
    self.availablePlayersScrollFrame:SetPoint("TOPLEFT", self.availablePlayersPaneLeft, "TOPLEFT", 0, -21)
    self.availablePlayersScrollFrame:SetPoint("TOPRIGHT", self.availablePlayersPaneLeft, "TOPRIGHT", 0, -21)
    self.availablePlayersScrollFrame:SetPoint("BOTTOMLEFT", self.availablePlayersPaneLeft, "BOTTOMLEFT", 0, 5)
    self.availablePlayersScrollFrame:SetPoint("BOTTOMRIGHT", self.availablePlayersPaneLeft, "BOTTOMRIGHT", 0, 5)
    self.availablePlayersScrollFrame.ScrollBar:SetValueStep(20)  -- Set scrolling speed per scroll step
    self.availablePlayersScrollFrame.ScrollBar:SetMinMaxValues(0, 400)  -- Set based on content height - frame height

    self.availablePlayersScrollContentFrame = CreateFrame("Frame", nil, self.availablePlayersScrollFrame)
    -- self.availablePlayersScrollContentFrame:SetSize(self.availablePlayersPaneLeft:GetWidth(), 8000)  -- Set the size of the content frame (height is larger for scrolling)
    self.availablePlayersScrollContentFrame:SetPoint("TOPLEFT")
    self.availablePlayersScrollContentFrame:SetPoint("TOPRIGHT")
    self.availablePlayersScrollFrame:SetScrollChild(self.availablePlayersScrollContentFrame)
    -- Create available players right pane
    self.availablePlayersPaneRight = CreateFrame("Frame", nil, self.availablePlayersPane)
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
    local lastPlayerFrame
    for _, guildMember in pairs(self:GetGuildMembers()) do
        local playerFrame = self.availablePlayers.guild.players[guildMember.name] or FrameBuilder.CreatePlayerFrame(self.availablePlayersScrollContentFrame, guildMember.name, guildMember.class, 280, 20, self:GetPlayerFontType(), self:GetAppearance().playerFontSize, 14)
        playerFrame.info = guildMember
        if lastPlayerFrame then
            playerFrame:SetPoint("TOPLEFT", lastPlayerFrame, "BOTTOMLEFT", 0, -3)
        else
            playerFrame:SetPoint("TOPLEFT", self.availablePlayersTitle, "BOTTOMLEFT", 0, -7)
        end
        self.availablePlayers.guild.players[guildMember.name] = playerFrame

        playerFrame:SetScript("OnMouseDown", function (pf)
            self.availablePlayersPane.selectedName = pf.info.name
            self.availablePlayersPane.selectedClass = pf.info.class
            self:UpdateAvailablePlayersPane()
        end)

        lastPlayerFrame = playerFrame
    end
    -- Set the size of the content frame (height is larger for scrolling)
    self.availablePlayersScrollContentFrame:SetHeight(7 + (20 + 3) * #self.availablePlayers.guild.players)

    if self.availablePlayersPane.selectedName then
        self.availablePlayersPaneRight.nameTitle = self.availablePlayersPaneRight.nameTitle or self.availablePlayersPaneRight:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.availablePlayersPaneRight.nameTitle:SetPoint("TOPLEFT", self.availablePlayersPaneRight, "TOPLEFT", 5 , -5)
        self.availablePlayersPaneRight.nameTitle:SetText(strsplit("-", self.availablePlayersPane.selectedName))
        self.availablePlayersPaneRight.nameTitle:SetFont(self:GetHeaderFont(), 16)
        local color = SwiftdawnRaidTools:GetClassColor(self.availablePlayersPane.selectedClass)
        self.availablePlayersPaneRight.nameTitle:SetTextColor(color.r, color.g, color.b, 0.8)
    end
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
            table.insert(guildMembers, { name = name, class = classFileName, rank = rankIndex })
        end
    end
    table.sort(guildMembers, function (a, b)
        if a.rank ~= b.rank then
            return a.rank < b.rank
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
