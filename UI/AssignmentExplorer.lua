local SwiftdawnRaidTools = SwiftdawnRaidTools
local SharedMedia = LibStub("LibSharedMedia-3.0")

local WINDOW_WIDTH = 600

local State = {
    ONLY_ENCOUNTER = 1,
    SHOW_PLAYER = 2,
    SHOW_ROSTER = 3
}

--- Assignment Explorer window class object
---@class AssignmentExplorer:SRTWindow
AssignmentExplorer = setmetatable({
    state = State.ONLY_ENCOUNTER,
    lastState = State.ONLY_ENCOUNTER,
    selectedEncounterID = 1025,
    selectedPlayer= {},
    viewRosterPlayer = false,
    selectedRosterPlayer= {},
    encounter = {},
    player = {},
    roster = {},
}, SRTWindow)
AssignmentExplorer.__index = AssignmentExplorer

---@return AssignmentExplorer
function AssignmentExplorer:New(height)
    local obj = SRTWindow.New(self, "Assignments", height, WINDOW_WIDTH, nil, nil, WINDOW_WIDTH, WINDOW_WIDTH)
    ---@cast obj AssignmentExplorer
    self.__index = self
    return obj
end

function AssignmentExplorer:Initialize()
    SRTWindow.Initialize(self)
    SwiftdawnRaidTools:BossEncountersInit()
    -- Setup header
    self.headerText:SetText("Assignments Explorer")
    -- Setup encounter pane
    self.encounterPane = CreateFrame("Frame", "SRT_Assignments_EncounterPane", self.main)
    self.encounterPane:SetClipsChildren(true)
    self.encounterPane:SetPoint("TOPLEFT", self.main, "TOPLEFT", 10, -5)
    self.encounterPane:SetPoint("TOPRIGHT", self.main, "TOP", -5, -5)
    self.encounterPane:SetPoint("BOTTOMLEFT", self.main, "BOTTOMLEFT", 10, 5)
    self.encounterPane:SetPoint("BOTTOMRIGHT", self.main, "BOTTOM", -5, 5)

    self.encounter.selector = self.encounter.selector or FrameBuilder.CreateSelector(self.encounterPane, {}, 285, self:GetHeaderFontType(), 14, "Maloriak")
    self.encounter.selector:SetPoint("TOPLEFT", self.encounterPane, "TOPLEFT", 0, -5)
    self.encounter.selector.selectedName = "Maloriak"
    self.encounter.bossAbilities = self.encounter.bossAbilities or {}
    -- Setup player pane
    self.selectedPlayerPane = CreateFrame("Frame", "SRT_Assignments_SelectedPlayerPane", self.main)
    self.selectedPlayerPane:SetClipsChildren(true)
    self.selectedPlayerPane:SetPoint("TOPLEFT", self.main, "TOP", 5, -5)
    self.selectedPlayerPane:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", -10, -5)
    self.selectedPlayerPane:SetPoint("BOTTOMLEFT", self.main, "BOTTOM", 5, 5)
    self.selectedPlayerPane:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", -10, 5)
    self.player.name = self.player.name or self.selectedPlayerPane:CreateFontString("SRT_AssignmentExplorer_PlayerPane_Name", "OVERLAY", "GameFontNormalLarge")
    self.player.name:SetPoint("TOPLEFT", self.selectedPlayerPane, "TOPLEFT", 0, -5)
    self.player.name:SetTextColor(1, 1, 1, 0.8)
    self.player.cooldowns = self.player.cooldowns or {}

    local colorRed = { r=0.8, g=0.3, b=0.3, a=0.8 }
    local colorRedHighlight = { r=1, g=0.3, b=0.3, a=1 }
    local colorGreen = { r=0.3, g=0.8, b=0.3, a=0.8 }
    local colorGreenHighlight = { r=0.3, g=1, b=0.3, a=1 }
    local colorGray = { r=0.3, g=0.3, b=0.3, a=0.8 }
    local colorGrayHighlight = { r=0.8, g=0.8, b=0.8, a=1 }

    self.replaceButton = FrameBuilder.CreateButton(self.selectedPlayerPane, 75, 25, "Replace", SRTColor.Red, SRTColor.RedHighlight)
    self.replaceButton:SetPoint("BOTTOMLEFT", self.selectedPlayerPane, "BOTTOMLEFT", 0, 5)
    self.replaceButton:SetScript("OnMouseUp", function (_, button)
        if button == "LeftButton" then
            self.lastState = State.SHOW_PLAYER
            self.state = State.SHOW_ROSTER
            self.viewRosterPlayer = false
            self.selectedRosterPlayer.selectedID = nil
            self.applyBuffChangesButton.color = SRTColor.Gray
            self.applyBuffChangesButton.colorHightlight = SRTColor.Gray
            self.applyBuffChangesButton:SetScript("OnMouseUp", nil)
            FrameBuilder.UpdateButton(self.applyBuffChangesButton)
            self:UpdateAppearance()
        end
    end)
    self.applyBuffChangesButton = FrameBuilder.CreateButton(self.selectedPlayerPane, 75, 25, "Apply", SRTColor.Gray, SRTColor.Gray)
    self.applyBuffChangesButton:SetPoint("BOTTOMRIGHT", self.selectedPlayerPane, "BOTTOMRIGHT", 0, 5)
    self.cancelBuffChangesButton = FrameBuilder.CreateButton(self.selectedPlayerPane, 75, 25, "Cancel", SRTColor.Red, SRTColor.RedHighlight)
    self.cancelBuffChangesButton:SetPoint("RIGHT", self.applyBuffChangesButton, "LEFT", -5, 0)
    self.cancelBuffChangesButton:SetScript("OnMouseUp", function (_, button)
        if button == "LeftButton" then
            self.lastState = State.SHOW_PLAYER
            self.state = State.ONLY_ENCOUNTER
            self:UpdateAppearance()
        end
    end)
    self.selectedPlayerPane:Hide()
    -- Setup roster pane
    self.rosterPane = CreateFrame("Frame", "SRT_Assignments_RosterPane", self.main)
    self.rosterPane:SetClipsChildren(true)
    self.rosterPane:SetPoint("TOPLEFT", self.main, "TOP", 5, -5)
    self.rosterPane:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", -10, -5)
    self.rosterPane:SetPoint("BOTTOMLEFT", self.main, "BOTTOM", 5, 5)
    self.rosterPane:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", -10, 5)
    self.rosterPane.roster = {}
    self.rosterBackButton = FrameBuilder.CreateButton(self.rosterPane, 75, 25, "Back", SRTColor.Red, SRTColor.RedHighlight)
    self.rosterBackButton:SetPoint("BOTTOMLEFT", self.rosterPane, "BOTTOMLEFT", 0, 5)
    self.rosterBackButton:SetScript("OnMouseUp", function (_, button)
        if button == "LeftButton" then
            self.lastState = State.SHOW_PLAYER
            self.state = State.SHOW_PLAYER
            self:UpdateAppearance()
        end
    end)
    self.rosterPane:Hide()
    -- Update appearance
    self:UpdateAppearance()
end

function AssignmentExplorer:GetHeaderFontType()
    return SharedMedia:Fetch("font", self:GetAppearance().headerFontType)
end

---@return FontFile
function AssignmentExplorer:GetPlayerFontType()
    ---@class FontFile
    return SharedMedia:Fetch("font", self:GetAppearance().playerFontType)
end

function AssignmentExplorer:GetAssignmentGroupHeight()
    local playerFontSize = self:GetAppearance().playerFontSize
    local iconSize = self:GetAppearance().iconSize
    return (playerFontSize > iconSize and playerFontSize or iconSize) + 7
end

function AssignmentExplorer:UpdateAppearance()
    SRTWindow.UpdateAppearance(self)

    self:UpdateEncounterPane()
    self:UpdateSelectedPlayerPane()
    self:UpdateRosterPane()
end

function AssignmentExplorer:Update()
    SRTWindow.Update(self)
    self.encounter.selector.selectedName = self:GetEncounterName(self.selectedEncounterID)
    FrameBuilder.UpdateSelector(self.encounter.selector)
end

function AssignmentExplorer:UpdateEncounterPane()
    local encounterItems = {}
    local encounters = SwiftdawnRaidTools:BossEncountersGetAll()
    for encounterID, _ in pairs(self:GetEncounters()) do
        local item = {
            name = encounters[encounterID],
            encounterID = encounterID,
            onClick = function (row)
                self.selectedEncounterID = row.item.encounterID
                self:UpdateAppearance()
            end
        }
        table.insert(encounterItems, item)
    end
    self.encounter.selector.items = encounterItems
    FrameBuilder.UpdateSelector(self.encounter.selector)

    local encounterAssignments = self:GetEncounters()[self.selectedEncounterID]
    if not encounterAssignments then
        return
    end

    local previousAbility
    for bossAbilityIndex, bossAbility in ipairs(encounterAssignments) do
        local bossAbilityFrame = self.encounter.bossAbilities[bossAbilityIndex] or CreateFrame("Frame", nil, self.encounterPane)
        if previousAbility then
            bossAbilityFrame:SetPoint("TOPLEFT", previousAbility, "BOTTOMLEFT", 0, 0)
            bossAbilityFrame:SetPoint("TOPRIGHT", previousAbility, "BOTTOMRIGHT", 0, 0)
        else
            bossAbilityFrame:SetPoint("TOPLEFT", self.encounter.selector, "BOTTOMLEFT", 10, -7)
            bossAbilityFrame:SetPoint("TOPRIGHT", self.encounter.selector, "BOTTOMLEFT", 190, -7)
        end
        local bossAbilityFrameHeight = 7

        bossAbilityFrame.name = bossAbilityFrame.name or bossAbilityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        bossAbilityFrame.name:SetPoint("TOPLEFT", bossAbilityFrame, "TOPLEFT", 0, 0)
        bossAbilityFrame.name:SetText(bossAbility.metadata.name)
        bossAbilityFrame.name:SetFont(self:GetHeaderFontType(), 12)
        bossAbilityFrame.name:SetTextColor(1, 1, 1, 0.8)
        self:SetDefaultFontStyle(bossAbilityFrame.name)
        bossAbilityFrameHeight = bossAbilityFrameHeight + 12

        bossAbilityFrame.bossSelectionFrame = bossAbilityFrame.bossSelectionFrame or {}

        -- bossAbilityFrame.triggers = bossAbilityFrame.triggers or {}
        -- local previousTrigger = nil
        -- for triggerIndex, trigger in ipairs(bossAbility.triggers) do
        --     local triggerFrame = bossAbilityFrame.triggers[triggerIndex] or self:CreateTriggerFrame(bossAbilityFrame)
        --     if trigger.type == "SPELL_CAST" then
        --         local name, rank, icon, castTime, minRange, maxRange, spellID, originalIcon = GetSpellInfo(trigger.spell_id)
        --         triggerFrame.text:SetText("When Boss casts " .. name)
        --     elseif trigger.type == "RAID_BOSS_EMOTE" then
        --         triggerFrame.text:SetText("When Boss emote includes '" .. trigger.text .. "'")
        --     elseif trigger.type == "UNIT_HEALTH" then
        --         triggerFrame.text:SetText("When Boss health drops below " .. tostring(trigger.pct_lt))
        --     else
        --         triggerFrame.text:SetText("When type: " .. trigger.type)
        --     end
        --     if not previousTrigger then
        --         triggerFrame:SetPoint("TOPLEFT", 10, -16)
        --         triggerFrame:SetPoint("TOPRIGHT", 10, -16)
        --     else
        --         triggerFrame:SetPoint("TOPLEFT", previousTrigger, "BOTTOMLEFT", 0, 0)
        --         triggerFrame:SetPoint("TOPRIGHT", previousTrigger, "BOTTOMRIGHT", 0, 0)
        --     end
        --     bossAbilityFrameHeight = bossAbilityFrameHeight + triggerFrame:GetHeight()
        --     bossAbilityFrame.triggers[triggerIndex] = triggerFrame
        --     previousTrigger = triggerFrame
        -- end

        bossAbilityFrame.groups = bossAbilityFrame.groups or {}
        for groupIndex, groupFrame in ipairs(bossAbilityFrame.groups) do
            groupFrame:Hide()
        end
        local previousGroup = nil
        for groupIndex, group in ipairs(bossAbility.assignments) do
            local groupFrame = bossAbilityFrame.groups[groupIndex] or FrameBuilder.CreateAssignmentGroupFrame(bossAbilityFrame, self:GetAssignmentGroupHeight() + 3)
            FrameBuilder.UpdateAssignmentGroupFrame(groupFrame, previousGroup, group, bossAbility.uuid, groupIndex, self:GetPlayerFontType(), self:GetAppearance().playerFontSize, self:GetAppearance().iconSize)

            -- Set OnClick for each assignment
            for _, assignmentFrame in pairs(groupFrame.assignments) do
                assignmentFrame:SetScript("OnMouseUp", function (frame, button)
                    if button == "LeftButton" then
                        self.lastState = State.ONLY_ENCOUNTER
                        self.state = State.SHOW_PLAYER
                        self.viewRosterPlayer = false
                        self.selectedPlayer = {
                            name = frame.assignment.player,
                            class = SwiftdawnRaidTools:SpellsGetClass(frame.assignment.spell_id),
                            selectedID = frame.assignment.spell_id
                        }
                        self:UpdateAppearance()
                    end
                end)
            end

            bossAbilityFrameHeight = bossAbilityFrameHeight + groupFrame:GetHeight()
            bossAbilityFrame.groups[groupIndex] = groupFrame

            previousGroup = groupFrame
        end

        bossAbilityFrameHeight = bossAbilityFrameHeight + 7
        bossAbilityFrame:SetHeight(bossAbilityFrameHeight)

        self.encounter.bossAbilities[bossAbilityIndex] = bossAbilityFrame
        previousAbility = bossAbilityFrame
    end
end

function AssignmentExplorer:UpdateSelectedPlayerPane()
    if self.lastState == State.SHOW_ROSTER then
        self.replaceButton.text:SetText("Back")
    else
        self.replaceButton.text:SetText("Replace")
    end

    if self.state == State.SHOW_PLAYER then
        self.selectedPlayerPane:Show()
    else
        self.selectedPlayerPane:Hide()
        return
    end

    if self.viewRosterPlayer then
        self.player.name:SetText(self.selectedRosterPlayer.name)
    else
        self.player.name:SetText(self.selectedPlayer.name)
    end
    self.player.name:SetFont(self:GetHeaderFontType(), 14)
    
    local iconSize = self:GetAppearance().iconSize * 3

    for _, spellFrame in pairs(self.player.cooldowns) do
        spellFrame:Hide()
    end
    local lastSpellFrame

    local classSpells
    local selectedID
    if self.viewRosterPlayer then
        classSpells = SwiftdawnRaidTools:SpellsGetClassSpells(self.selectedRosterPlayer.class)
        selectedID = self.selectedRosterPlayer.selectedID
    else
        classSpells = SwiftdawnRaidTools:SpellsGetClassSpells(self.selectedPlayer.class)
        selectedID = self.selectedPlayer.selectedID
    end
    for _, spellID in pairs(classSpells) do
        local spellFrame = self.player.cooldowns[spellID] or FrameBuilder.CreateLargeSpellFrame(self.selectedPlayerPane)
        FrameBuilder.UpdateLargeSpellFrame(spellFrame, spellID, self:GetPlayerFontType(), self:GetAppearance().playerFontSize, iconSize)
        spellFrame:SetScript("OnEnter", function () spellFrame:SetBackdropColor(1, 1, 1, 0.4) end)
        spellFrame:SetScript("OnLeave", function (frame) if frame.spellID ~= selectedID then spellFrame:SetBackdropColor(0, 0, 0, 0) end end)
        spellFrame:SetScript("OnMouseDown", function (sf, button)
            if button == "LeftButton" then
                if self.viewRosterPlayer then 
                    self.selectedRosterPlayer.selectedID = sf.spellID
                    self.applyBuffChangesButton.color = SRTColor.Green
                    self.applyBuffChangesButton.colorHightlight = SRTColor.GreenHighlight
                    self.applyBuffChangesButton:SetScript("OnMouseUp", function (_, button)
                        if button == "LeftButton" then
                            self.lastState = State.SHOW_ROSTER
                            self.state = State.SHOW_PLAYER
                            self:UpdateAppearance()
                        end
                    end)
                    FrameBuilder.UpdateButton(self.applyBuffChangesButton)
                    self:UpdateAppearance()
                end
            end
        end)
        if lastSpellFrame then
            spellFrame:SetPoint("TOPLEFT", lastSpellFrame, "BOTTOMLEFT", 0, -7)
            spellFrame:SetPoint("TOPRIGHT", lastSpellFrame, "BOTTOMRIGHT", 0, -7)
        else
            spellFrame:SetPoint("TOPLEFT", self.player.name, "BOTTOMLEFT", 5, -7)
            spellFrame:SetPoint("TOPRIGHT", self.player.name, "BOTTOMLEFT", 280, -7)
        end
        if spellID == selectedID then
            spellFrame:SetBackdropColor(1, 1, 1, 0.4)
        end
        self.player.cooldowns[spellID] = spellFrame
        lastSpellFrame = spellFrame
    end
    
end

function AssignmentExplorer:UpdateRosterPane()
    if self.state == State.SHOW_ROSTER then
        self.rosterPane:Show()
    else
        self.rosterPane:Hide()
        return
    end

    self.rosterPane.title = self.rosterPane.title or self.rosterPane:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.rosterPane.title:SetText("Available Players")
    self.rosterPane.title:SetPoint("TOPLEFT", self.rosterPane, "TOPLEFT", 0, -5)
    self.rosterPane.title:SetFont(self:GetHeaderFontType(), 14)
    self.rosterPane.title:SetHeight(self.rosterPane.title:GetStringHeight())
    self.rosterPane.title:SetTextColor(1, 1, 1, 0.8)
    self.rosterPane.guildTitle = self.rosterPane.guildTitle or self.rosterPane:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.rosterPane.guildTitle:SetText("Swiftdawn")
    self.rosterPane.guildTitle:SetPoint("TOPLEFT", self.rosterPane.title, "BOTTOMLEFT", 10, -7)
    self.rosterPane.guildTitle:SetFont(self:GetHeaderFontType(), 13)
    self.rosterPane.guildTitle:SetHeight(self.rosterPane.guildTitle:GetStringHeight())
    self.rosterPane.guildTitle:SetTextColor(1, 1, 1, 0.8)

    self.rosterPane.roster = self.rosterPane.roster or {}
    
    local lastPlayerFrame = nil
    for _, player in ipairs(self:GetOnlineGuildMembers()) do
        local playerFrame = self.rosterPane.roster[player.name] or FrameBuilder.CreatePlayerFrame(self.rosterPane, player.name, player.classFileName,
            self.rosterPane:GetWidth(), self:GetAssignmentGroupHeight(), self:GetPlayerFontType(), self:GetAppearance().playerFontSize, self:GetAppearance().iconSize + 2)

        if not lastPlayerFrame then
            playerFrame:SetPoint("TOPLEFT", self.rosterPane.guildTitle, "BOTTOMLEFT", 0, -7)
        else
            playerFrame:SetPoint("TOPLEFT", lastPlayerFrame, "BOTTOMLEFT", 0, -5)
        end

        playerFrame:SetScript("OnEnter", function () playerFrame:SetBackdropColor(1, 1, 1, 0.4) end)
        playerFrame:SetScript("OnLeave", function () playerFrame:SetBackdropColor(0, 0, 0, 0) end)

        playerFrame:SetScript("OnMouseUp", function (_, button)
            if button == "LeftButton" then
                self.lastState = State.SHOW_ROSTER
                self.state = State.SHOW_PLAYER
                self.viewRosterPlayer = true
                self.selectedRosterPlayer = {
                    name = strsplit("-", player.name),
                    class = player.classFileName,
                    selectedID = nil
                }
                self:UpdateAppearance()
            end
        end)

        self.rosterPane.roster[player.name] = playerFrame
        lastPlayerFrame = playerFrame
    end
end

local lastUpdatedOnlineGuildMembers = 0
local guildMembers = {}
function AssignmentExplorer:GetOnlineGuildMembers()
    if GetTime() - lastUpdatedOnlineGuildMembers < 5 then
        return
    end
    guildMembers = {}
    local numTotalGuildMembers, numOnlineGuildMembers, numOnlineAndMobileMembers = GetNumGuildMembers()
    for index = 1, numTotalGuildMembers, 1 do
        local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile, isSoREligible, standingID = GetGuildRosterInfo(index)
        if online and level == 85 then
            table.insert(guildMembers, { name = name, class = class, classFileName = classFileName })
        end
    end
    return guildMembers
end

function AssignmentExplorer:CreateTriggerFrame(bossAbilityFrame)
    local triggerFrame = CreateFrame("Frame", nil, bossAbilityFrame, "BackdropTemplate")
    triggerFrame:SetHeight(self:GetAssignmentGroupHeight())
    triggerFrame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 16,
    })
    triggerFrame:SetBackdropColor(0, 0, 0, 0)
    triggerFrame.text = triggerFrame.text or triggerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    triggerFrame.text:SetAllPoints()
    triggerFrame.text:SetFont(self:GetTitleFontType(), self:GetAppearance().titleFontSize)
    self:SetDefaultFontStyle(triggerFrame.text)
    return triggerFrame
end

function AssignmentExplorer:GetEncounters()
    return SRT_Profile().data.encounters
end

function AssignmentExplorer:GetEncounterName(encounterID)
    SwiftdawnRaidTools:BossEncountersInit()
   return SwiftdawnRaidTools:BossEncountersGetAll()[encounterID]
end

function AssignmentExplorer:SetDefaultFontStyle(fontString)
    fontString:SetShadowOffset(1, -1)
    fontString:SetShadowColor(0, 0, 0, 1)
    fontString:SetJustifyH("LEFT")
    fontString:SetHeight(fontString:GetStringHeight())
end
