local SwiftdawnRaidTools = SwiftdawnRaidTools
local SharedMedia = LibStub("LibSharedMedia-3.0")

local WINDOW_WIDTH = 600

local State = {
    ROSTER_AND_INFO = 1,
    ROSTER_AND_AVAILABLE_PLAYERS = 2,
    SAVED_ROSTERS = 3
}

--- Roster Explorer window class object
---@class RosterExplorer:SRTWindow
RosterExplorer = setmetatable({
    state = State.ROSTER_AND_INFO,
    lastState = State.ROSTER_AND_INFO,
    roster = {},
    availablePlayers = {
        guild = {
            players = {}
        }
    }
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
    -- Unset clipping to show filter menu out the side
    self.container:SetClipsChildren(false)

    -- Set header text
    self.headerText:SetText("Roster Explorer")

    -- Create roster pane
    self.content = CreateFrame("Frame", "SRTRoster_Content", self.main)
    self.content:SetClipsChildren(false)
    self.content:SetPoint("TOPLEFT", self.main, "TOPLEFT", 10, -5)
    self.content:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", -10, -5)
    self.content:SetPoint("BOTTOMLEFT", self.main, "BOTTOMLEFT", 10, 5)
    self.content:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", -10, 5)

    -- Create scroll cutoff pane 
    self.scrollCuttoffPane = CreateFrame("Frame", "SRTRoster_ScrollCutoff", self.content)
    self.scrollCuttoffPane:SetClipsChildren(true)
    self.scrollCuttoffPane:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -28)
    self.scrollCuttoffPane:SetPoint("TOPRIGHT", self.content, "TOPRIGHT", 0, -28)
    self.scrollCuttoffPane:SetPoint("BOTTOMLEFT", self.content, "BOTTOMLEFT", 0, 35)
    self.scrollCuttoffPane:SetPoint("BOTTOMRIGHT", self.content, "BOTTOMRIGHT", 0, 35)

    -- Create scrolling roster content
    self.rosterPane = CreateFrame("Frame", "SRTRoster_RosterPane", self.content)
    self.rosterPane:SetClipsChildren(false)
    self.rosterPane:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, 0)
    self.rosterPane:SetPoint("TOPRIGHT", self.content, "TOP", -5, 0)
    self.rosterPane:SetPoint("BOTTOMLEFT", self.content, "BOTTOMLEFT", 0, 0)
    self.rosterPane:SetPoint("BOTTOMRIGHT", self.content, "BOTTOM", -5, 0)
    
    -- Setup roster info pane
    self.rosterInfoPane = CreateFrame("Frame", "SRTRoster_RosterInfo", self.content)
    self.rosterInfoPane:SetClipsChildren(false)
    self.rosterInfoPane:SetPoint("TOPLEFT", self.content, "TOP", 5, 0)
    self.rosterInfoPane:SetPoint("TOPRIGHT", self.content, "TOPRIGHT", 0, 0)
    self.rosterInfoPane:SetPoint("BOTTOMLEFT", self.content, "BOTTOM", 5, 0)
    self.rosterInfoPane:SetPoint("BOTTOMRIGHT", self.content, "BOTTOMRIGHT", 0, 0)

    -- Create available players pane
    self.availablePlayersPane = CreateFrame("Frame", "SRTRoster_AvailablePlayers", self.content)
    self.availablePlayersPane:SetClipsChildren(false)
    self.availablePlayersPane:SetPoint("TOPLEFT", self.content, "TOP", 5, 0)
    self.availablePlayersPane:SetPoint("TOPRIGHT", self.content, "TOPRIGHT", 0, 0)
    self.availablePlayersPane:SetPoint("BOTTOMLEFT", self.content, "BOTTOM", 5, 0)
    self.availablePlayersPane:SetPoint("BOTTOMRIGHT", self.content, "BOTTOMRIGHT", 0, 0)

    -- Fill in left side
    self.rosterTitle = self.rosterPane:CreateFontString("SRTRoster_RosterPane_Title", "OVERLAY", "GameFontNormal")
    self.rosterTitle:SetPoint("TOPLEFT", self.rosterPane, "TOPLEFT", 5 , -5)
    self.rosterTitle:SetText("Roster")
    self.rosterTitle:SetFont(self:GetHeaderFont(), 16)
    self.rosterTitle:SetTextColor(1, 1, 1, 0.8)
    self.rosterScrollFrame = CreateFrame("ScrollFrame", "SRTRoster_RosterPane_Scroll", self.rosterPane, "UIPanelScrollFrameTemplate")
    self.rosterScrollFrame:SetClipsChildren(false)
    self.rosterScrollFrame:SetPoint("TOPLEFT", self.rosterPane, "TOPLEFT", 0, -28)
    self.rosterScrollFrame:SetPoint("TOPRIGHT", self.rosterPane, "TOPRIGHT", 0, -28)
    self.rosterScrollFrame:SetPoint("BOTTOMLEFT", self.rosterPane, "BOTTOMLEFT", 0, 35)
    self.rosterScrollFrame:SetPoint("BOTTOMRIGHT", self.rosterPane, "BOTTOMRIGHT", 0, 35)
    self.rosterScrollFrame.ScrollBar:SetValueStep(20)  -- Set scrolling speed per scroll step
    self.rosterScrollFrame.ScrollBar:SetMinMaxValues(0, 400)  -- Set based on content height - frame height
    self.rosterScrollContentFrame = CreateFrame("Frame", "SRTRoster_RosterPane_ScrollContent", self.rosterScrollFrame)
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

    -- Fill in right side info panel
    self.rosterInfoPaneAddButton = FrameBuilder.CreateButton(self.rosterInfoPane, 85, 25, "Add Players", SRTColor.Green, SRTColor.GreenHighlight)
    self.rosterInfoPaneAddButton:SetPoint("BOTTOMRIGHT", self.rosterInfoPane, "BOTTOMRIGHT", -5, 5)
    self.rosterInfoPaneAddButton:SetScript("OnMouseDown", function (button)
        self.state = State.ROSTER_AND_AVAILABLE_PLAYERS
        self:UpdateAppearance()
    end)
    self.rosterInfoPaneLoadButton = FrameBuilder.CreateButton(self.rosterInfoPane, 85, 25, "Load Roster", SRTColor.Green, SRTColor.GreenHighlight)
    self.rosterInfoPaneLoadButton:SetPoint("RIGHT", self.rosterInfoPaneAddButton, "LEFT", -10, 0)
    self.rosterInfoPaneLoadButton:SetScript("OnMouseDown", function (button)
        self.state = State.SAVED_ROSTERS
        self:UpdateAppearance()
    end)

    -- Fill in right side available players panel
    self.availablePlayersTitle = self.availablePlayersPane:CreateFontString("SRTRoster_AvailablePlayers_Title", "OVERLAY", "GameFontNormal")
    self.availablePlayersTitle:SetPoint("TOPLEFT", self.availablePlayersPane, "TOPLEFT", 5 , -5)
    self.availablePlayersTitle:SetText("Available Players")
    self.availablePlayersTitle:SetFont(self:GetHeaderFont(), 16)
    self.availablePlayersTitle:SetTextColor(1, 1, 1, 0.8)
    self.availablePlayersFilterButton = CreateFrame("Button", "SRTRoster_AvailablePlayers_Filter", self.availablePlayersPane, "BackdropTemplate")
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

    -- Create scrolling roster content
    self.availablePlayersScrollFrame = CreateFrame("ScrollFrame", "SRTRoster_AvailablePlayers_Scroll", self.availablePlayersPane, "UIPanelScrollFrameTemplate")
    self.availablePlayersScrollFrame:SetClipsChildren(false)
    self.availablePlayersScrollFrame:SetPoint("TOPLEFT", self.availablePlayersPane, "TOPLEFT", 0, -28)
    self.availablePlayersScrollFrame:SetPoint("TOPRIGHT", self.availablePlayersPane, "TOPRIGHT", 0, -28)
    self.availablePlayersScrollFrame:SetPoint("BOTTOMLEFT", self.availablePlayersPane, "BOTTOMLEFT", 0, 35)
    self.availablePlayersScrollFrame:SetPoint("BOTTOMRIGHT", self.availablePlayersPane, "BOTTOMRIGHT", 0, 35)
    self.availablePlayersScrollFrame.ScrollBar:SetValueStep(20)  -- Set scrolling speed per scroll step
    self.availablePlayersScrollFrame.ScrollBar:SetMinMaxValues(0, 400)  -- Set based on content height - frame height
    self.availablePlayersScrollContentFrame = CreateFrame("Frame", "SRTRoster_AvailablePlayers_ScrollContent", self.availablePlayersScrollFrame)
    self.availablePlayersScrollContentFrame:SetClipsChildren(false)
    self.availablePlayersScrollContentFrame:SetSize(500, 8000)  -- Set the size of the content frame (height is larger for scrolling)
    self.availablePlayersScrollContentFrame:SetPoint("TOPLEFT")
    self.availablePlayersScrollContentFrame:SetPoint("TOPRIGHT")
    self.availablePlayersScrollFrame:SetScrollChild(self.availablePlayersScrollContentFrame)
    
    self.availablePlayersScrollBar = _G["SRTRoster_AvailablePlayers_ScrollScrollBar"]
    self.availablePlayersScrollBar.scrollStep = 23*3  -- Change this value to adjust the scroll amount per tick
    self.availablePlayersScrollBar:SetPoint("TOPRIGHT", self.availablePlayersScrollFrame, "TOPRIGHT", -12, 0)
    self.availablePlayersScrollBar:SetPoint("BOTTOMRIGHT", self.availablePlayersScrollFrame, "BOTTOMRIGHT", -12, 0)
    self.availablePlayersScrollBar.ScrollUpButton:SetAlpha(0)
    self.availablePlayersScrollBar.ScrollDownButton:SetAlpha(0)
    local thumbTexture = self.availablePlayersScrollBar:GetThumbTexture()
    thumbTexture:SetColorTexture(0, 0, 0, 0.8)  -- RGBA (0, 0, 0, 1) sets it to solid black
    thumbTexture:SetWidth(5)  -- Customize the size as needed
    self.availablePlayersScrollBar:Show()

    -- Create buttons
    self.availablePlayersPaneReturn = FrameBuilder.CreateButton(self.availablePlayersPane, 75, 25, "Return", SRTColor.Red, SRTColor.RedHighlight)
    self.availablePlayersPaneReturn:SetPoint("BOTTOMRIGHT", self.content, "BOTTOMRIGHT", -5, 5)
    self.availablePlayersPaneReturn:SetScript("OnMouseDown", function (button)
        self.state = State.ROSTER_AND_INFO
        self:UpdateAppearance()
    end)


    -- Create saved roster pane
    self.savedRosterPane = CreateFrame("Frame", "SRTRoster_Saved", self.main)
    self.savedRosterPane:SetClipsChildren(false)
    self.savedRosterPane:SetAllPoints()
    -- Create saved roster left pane
    self.savedRosterPaneLeft = CreateFrame("Frame", "SRTRoster_SavedLeft", self.savedRosterPane)
    self.savedRosterPaneLeft:SetClipsChildren(false)
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
    self.savedRosterPaneRight:SetClipsChildren(false)
    self.savedRosterPaneRight:SetPoint("TOPLEFT", self.savedRosterPane, "TOP", 5, 0)
    self.savedRosterPaneRight:SetPoint("TOPRIGHT", self.savedRosterPane, "TOPRIGHT", 0, 0)
    self.savedRosterPaneRight:SetPoint("BOTTOMLEFT", self.savedRosterPane, "BOTTOM", 5, 0)
    self.savedRosterPaneRight:SetPoint("BOTTOMRIGHT", self.savedRosterPane, "BOTTOMRIGHT", 0, 0)
    -- Create buttons
    self.savedRosterPaneRightCancel = FrameBuilder.CreateButton(self.savedRosterPaneRight, 75, 25, "Cancel", SRTColor.Red, SRTColor.RedHighlight)
    self.savedRosterPaneRightCancel:SetPoint("BOTTOMRIGHT", self.content, "BOTTOMRIGHT", -5, 5)
    self.savedRosterPaneRightCancel:SetScript("OnMouseDown", function (button)
        self.state = State.ROSTER_AND_INFO
        self:UpdateAppearance()
    end)
    self.savedRosterPaneRightDelete = FrameBuilder.CreateButton(self.savedRosterPaneRight, 75, 25, "Delete", SRTColor.Red, SRTColor.RedHighlight)
    self.savedRosterPaneRightDelete:SetPoint("RIGHT", self.savedRosterPaneRightCancel, "LEFT", -10, 0)
    self.savedRosterPaneRightDelete:SetScript("OnMouseDown", function (button)
        self.state = State.ROSTER_AND_INFO
        self:UpdateAppearance()
    end)
    self.savedRosterPaneRightLoad = FrameBuilder.CreateButton(self.savedRosterPaneRight, 75, 25, "Load", SRTColor.Red, SRTColor.RedHighlight)
    self.savedRosterPaneRightLoad:SetPoint("RIGHT", self.savedRosterPaneRightDelete, "LEFT", -10, 0)
    self.savedRosterPaneRightLoad:SetScript("OnMouseDown", function (button)
        self.state = State.ROSTER_AND_INFO
        self:UpdateAppearance()
    end)
    -- Update appearance
    self:UpdateAppearance()
end

function RosterExplorer:UpdateAppearance()
    SRTWindow.UpdateAppearance(self)

    self:UpdateRosterPane()
    self:UpdateRosterInfoPane()
    self:UpdateAvailablePlayersPane()
    self:UpdateSavedRostersPane()
end

function RosterExplorer:UpdateRosterPane()
    if self.state == State.ROSTER_AND_INFO or self.state == State.ROSTER_AND_AVAILABLE_PLAYERS then
        self.content:Show()
    else
        self.content:Hide()
        for _, player in pairs(self.roster) do
            player.frame:Hide()
        end
        return
    end

    local lastPlayerFrame
    local visiblePlayers = 0
    for name, rosteredPlayer in pairs(self.roster) do
        local playerFrame = rosteredPlayer.frame or FrameBuilder.CreatePlayerFrame(self.scrollCuttoffPane, rosteredPlayer.info.name, rosteredPlayer.info.classFileName, 260, 20, self:GetPlayerFontType(), self:GetAppearance().playerFontSize, 14)
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
            -- Cleverly connect my child to my parent
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

function RosterExplorer:UpdateRosterInfoPane()
    if self.state == State.ROSTER_AND_INFO then
        self.rosterInfoPane:Show()
    else
        self.rosterInfoPane:Hide()
        return
    end
end

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
            local playerFrame = self.availablePlayers.guild.players[guildMember.name].frame or FrameBuilder.CreatePlayerFrame(self.scrollCuttoffPane, guildMember.name, guildMember.classFileName, 260, 20, self:GetPlayerFontType(), self:GetAppearance().playerFontSize, 14)
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

function RosterExplorer:UpdateSavedRostersPane()
    if self.state == State.SAVED_ROSTERS then
        self.savedRosterPane:Show()
    else
        self.savedRosterPane:Hide()
        return
    end
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
