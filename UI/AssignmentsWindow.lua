local SwiftdawnRaidTools = SwiftdawnRaidTools
local SharedMedia = LibStub("LibSharedMedia-3.0")

local State = {
    ONLY_ENCOUNTER = 1,
    SHOW_PLAYER = 2,
    SHOW_ROSTER = 3
}

--- Assignment Explorer window class object
---@class SRTAssignments:SRTWindow
SRTAssignments = setmetatable({
    state = State.ONLY_ENCOUNTER,
    selectedEncounterID = 1025,
    selectedPlayer= {},
    selectedPlayerName = "",
    selectedPlayerSpellID = 0,
    encounter = {},
    player = {},
    roster = {},
}, SRTWindow)
SRTAssignments.__index = SRTAssignments

---@return SRTAssignments
function SRTAssignments:New(height, width)
    local obj = SRTWindow.New(self, "Assignments", height, width)
    ---@cast obj SRTAssignments
    self.__index = self
    return obj
end

function SRTAssignments:Initialize()
    SRTWindow.Initialize(self)
    self.headerText:SetText("Assignments Explorer")
    self.encounterPane = CreateFrame("Frame", "SRT_Assignments_EncounterPane", self.main)
    self.encounterPane:SetClipsChildren(true)
    self.selectedPlayerPane = CreateFrame("Frame", "SRT_Assignments_SelectedPlayerPane", self.main)
    self.selectedPlayerPane:SetClipsChildren(true)
    self.selectedPlayerPane:Hide()
    self.rosterPane = CreateFrame("Frame", "SRT_Assignments_RosterPane", self.main)
    self.rosterPane:SetClipsChildren(true)
    self.rosterPane:Hide()
    self:UpdateAppearance()
end

function SRTAssignments:GetHeaderFontType()
    return SharedMedia:Fetch("font", self:GetAppearance().headerFontType)
end

function SRTAssignments:GetPlayerFontType()
    return SharedMedia:Fetch("font", self:GetAppearance().playerFontType)
end

function SRTAssignments:GetAssignmentGroupHeight()
    local playerFontSize = self:GetAppearance().playerFontSize
    local iconSize = self:GetAppearance().iconSize
    return (playerFontSize > iconSize and playerFontSize or iconSize) + 7
end

function SRTAssignments:UpdateAppearance()
    SRTWindow.UpdateAppearance(self)

    self:UpdateEncounterPane()
    self:UpdateSelectedPlayerPane()
    self:UpdateRosterPane()
end

function SRTAssignments:UpdateEncounterPane()
    self.encounterPane:SetPoint("TOPLEFT", self.main, "TOPLEFT", 10, -5)
    self.encounterPane:SetPoint("TOPRIGHT", self.main, "TOP", -5, -5)
    self.encounterPane:SetPoint("BOTTOMLEFT", self.main, "BOTTOMLEFT", 10, 5)
    self.encounterPane:SetPoint("BOTTOMRIGHT", self.main, "BOTTOM", -5, 5)

    local encounterAssignments = self:GetEncounters()[self.selectedEncounterID]

    self.encounter.name = self.encounter.name or self.main:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.encounter.name:SetPoint("TOPLEFT", self.encounterPane, "TOPLEFT", 0, -5)
    self.encounter.name:SetTextColor(1, 1, 1, 0.8)
    self.encounter.name:SetText(self:GetEncounterName(self.selectedEncounterID))
    self.encounter.name:SetFont(self:GetHeaderFontType(), 14)
    self:SetDefaultFontStyle(self.encounter.name)

    self.encounter.bossAbilities = self.encounter.bossAbilities or {}
    local previousAbility
    for bossAbilityIndex, bossAbility in ipairs(encounterAssignments) do
        local bossAbilityFrame = self.encounter.bossAbilities[bossAbilityIndex] or CreateFrame("Frame", nil, self.encounterPane)
        if previousAbility then
            bossAbilityFrame:SetPoint("TOPLEFT", previousAbility, "BOTTOMLEFT", 0, 0)
            bossAbilityFrame:SetPoint("TOPRIGHT", previousAbility, "BOTTOMRIGHT", 0, 0)
        else
            bossAbilityFrame:SetPoint("TOPLEFT", self.encounter.name, "BOTTOMLEFT", 10, -7)
            bossAbilityFrame:SetPoint("TOPRIGHT", self.encounter.name, "BOTTOMLEFT", 190, -7)
        end
        local bossAbilityFrameHeight = 7

        bossAbilityFrame.name = bossAbilityFrame.name or bossAbilityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        bossAbilityFrame.name:SetPoint("TOPLEFT", bossAbilityFrame, "TOPLEFT", 0, 0)
        bossAbilityFrame.name:SetText(bossAbility.metadata.name)
        bossAbilityFrame.name:SetFont(self:GetHeaderFontType(), 12)
        bossAbilityFrame.name:SetTextColor(1, 1, 1, 0.8)
        self:SetDefaultFontStyle(bossAbilityFrame.name)
        bossAbilityFrameHeight = bossAbilityFrameHeight + 12

        bossAbilityFrame.groups = bossAbilityFrame.groups or {}
        local previousGroup = nil
        for groupIndex, group in ipairs(bossAbility.assignments) do
            local groupFrame = bossAbilityFrame.groups[groupIndex] or self:CreateGroupFrame(bossAbilityFrame, previousGroup)
            self:UpdateGroupFrame(groupFrame, previousGroup, group, bossAbility.uuid, groupIndex)
            groupFrame:SetHeight(self:GetAssignmentGroupHeight() + 3)
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

function SRTAssignments:UpdateSelectedPlayerPane()
    if self.state == State.SHOW_PLAYER then
        self.selectedPlayerPane:Show()
    else
        self.selectedPlayerPane:Hide()
    end

    self.selectedPlayerPane:SetPoint("TOPLEFT", self.main, "TOP", 5, -5)
    self.selectedPlayerPane:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", -10, -5)
    self.selectedPlayerPane:SetPoint("BOTTOMLEFT", self.main, "BOTTOM", 5, 5)
    self.selectedPlayerPane:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", -10, 5)
    
    self.player.name = self.player.name or self.selectedPlayerPane:CreateFontString("SRT_AssignmentExplorer_PlayerPane_Name", "OVERLAY", "GameFontNormalLarge")
    self.player.name:SetPoint("TOPLEFT", self.selectedPlayerPane, "TOPLEFT", 0, -5)
    self.player.name:SetTextColor(1, 1, 1, 0.8)
    self.player.name:SetText(self.selectedPlayer.name)
    self.player.name:SetFont(self:GetHeaderFontType(), 14)
    self:SetDefaultFontStyle(self.player.name)
    
    local iconSize = self:GetAppearance().iconSize + 2

    self.player.cooldowns = self.player.cooldowns or {}
    DevTool:AddData(self.selectedPlayer, "selectedPlayer")
    local name, rank, icon, castTime, minRange, maxRange, spellID, originalIcon = GetSpellInfo(self.selectedPlayer.spellID)
    -- DevTool:AddData({ name=name, rank=rank, icon=icon, castTime=castTime, minRange=minRange, maxRange=maxRange, spellID=spellID, originalIcon=originalIcon }, "selectedPlayerSpell_" .. self.selectedPlayer.name)

    local cooldownFrame = self.player.cooldowns[1] or CreateFrame("Frame", nil, self.selectedPlayerPane, "BackdropTemplate")
    cooldownFrame:SetPoint("TOPLEFT", self.player.name, "BOTTOMLEFT", 5, -5)
    cooldownFrame:SetPoint("TOPRIGHT", self.player.name, "BOTTOMLEFT", 190, -5)
    cooldownFrame.iconFrame = cooldownFrame.iconFrame or CreateFrame("Frame", nil, cooldownFrame)
    cooldownFrame.iconFrame:SetSize(iconSize, iconSize)
    cooldownFrame.iconFrame:SetPoint("TOPLEFT", 10, 0)
    cooldownFrame.icon = cooldownFrame.icon or cooldownFrame.iconFrame:CreateTexture(nil, "ARTWORK")
    cooldownFrame.icon:SetAllPoints()
    cooldownFrame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    cooldownFrame.icon:SetTexture(icon)
    cooldownFrame.text = cooldownFrame.text or cooldownFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    cooldownFrame.text:SetFont(self:GetPlayerFontType(), self:GetAppearance().playerFontSize)
    cooldownFrame.text:SetTextColor(1, 1, 1, 1)
    cooldownFrame.text:SetPoint("LEFT", cooldownFrame.iconFrame, "RIGHT", 4, -1)
    cooldownFrame.text:SetText(name)
    self:SetDefaultFontStyle(cooldownFrame.text)
    cooldownFrame.extraText = cooldownFrame.extraText or cooldownFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cooldownFrame.extraText:SetFont(self:GetPlayerFontType(), self:GetAppearance().playerFontSize)
    cooldownFrame.extraText:SetTextColor(1, 1, 1, 1)
    cooldownFrame.extraText:SetPoint("TOPLEFT", cooldownFrame.iconFrame, "BOTTOMLEFT", 4, -3)
    cooldownFrame.extraText:SetText(string.format("Cast time: %ds\nRange: %d to %d yards", castTime, minRange, maxRange))
    cooldownFrame.extraText:SetHeight(cooldownFrame.extraText:GetStringHeight())
    cooldownFrame.extraText:SetWidth(180)
    self:SetDefaultFontStyle(cooldownFrame.extraText)
    cooldownFrame:SetHeight(iconSize + 4 + cooldownFrame.text:GetHeight() + 4 + cooldownFrame.extraText:GetHeight() + 4)

    self.player.cooldowns[1] = cooldownFrame
end

function SRTAssignments:UpdateRosterPane()
    self.rosterPane:SetPoint("TOPLEFT", self.main, "TOP", 5, -5)
    self.rosterPane:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", -10, -5)
    self.rosterPane:SetPoint("BOTTOMLEFT", self.main, "BOTTOM", 5, 5)
    self.rosterPane:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", -10, 5)
end

function SRTAssignments:CreateGroupFrame(bossAbilityFrame, previousFrame)
    local groupFrame = CreateFrame("Frame", nil, bossAbilityFrame, "BackdropTemplate")
    groupFrame:SetHeight(self:GetAssignmentGroupHeight())
    groupFrame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })
    groupFrame.assignments = {}
    return groupFrame
end

function SRTAssignments:UpdateGroupFrame(groupFrame, prevFrame, group, uuid, index)
    groupFrame:Show()
    groupFrame.uuid = uuid
    groupFrame.index = index
    groupFrame:SetBackdropColor(0, 0, 0, 0)
    groupFrame:ClearAllPoints()
    if prevFrame then
        groupFrame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, 0)
        groupFrame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0, 0)
    else
        groupFrame:SetPoint("TOPLEFT", 0, -16)
        groupFrame:SetPoint("TOPRIGHT", 0, -16)
    end
    for _, cd in pairs(groupFrame.assignments) do
        cd:Hide()
    end
    for i, assignment in ipairs(group) do
        local assignmentFrame = groupFrame.assignments[i] or self:CreateAssignmentFrame(groupFrame)
        self:UpdateAssignmentFrame(assignmentFrame, assignment, i, #group)
        groupFrame.assignments[i] = assignmentFrame
    end
end

function SRTAssignments:CreateAssignmentFrame(groupFrame)
    local assignmentFrame = CreateFrame("Frame", nil, groupFrame, "BackdropTemplate")
    assignmentFrame.iconFrame = CreateFrame("Frame", nil, assignmentFrame, "BackdropTemplate")
    assignmentFrame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })
    assignmentFrame:SetBackdropColor(0, 0, 0, 0)
    assignmentFrame:SetScript("OnEnter", function() assignmentFrame:SetBackdropColor(1, 1, 1, 0.4) end)
    assignmentFrame:SetScript("OnLeave", function() assignmentFrame:SetBackdropColor(0, 0, 0, 0) end)
    assignmentFrame:SetMouseClickEnabled(true)
    assignmentFrame:SetScript("OnMouseUp", function (_, button)
        if button == "LeftButton" then
            self.state = State.SHOW_PLAYER
            self.selectedPlayer = {
                name = assignmentFrame.player,
                spellID = assignmentFrame.spellId
            }
            self:UpdateAppearance()
        end
    end)
    local iconSize = self:GetAppearance().iconSize
    assignmentFrame.iconFrame:SetSize(iconSize, iconSize)
    assignmentFrame.iconFrame:SetPoint("LEFT", 10, 0)
    assignmentFrame.cooldownFrame = CreateFrame("Cooldown", nil, assignmentFrame.iconFrame, "CooldownFrameTemplate")
    assignmentFrame.cooldownFrame:SetAllPoints()
    assignmentFrame.iconFrame.cooldown = assignmentFrame.cooldownFrame
    assignmentFrame.icon = assignmentFrame.iconFrame:CreateTexture(nil, "ARTWORK")
    assignmentFrame.icon:SetAllPoints()
    assignmentFrame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    assignmentFrame.text = assignmentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    assignmentFrame.text:SetFont(self:GetTitleFontType(), self:GetAppearance().titleFontSize)
    assignmentFrame.text:SetTextColor(1, 1, 1, 1)
    assignmentFrame.text:SetPoint("LEFT", assignmentFrame.iconFrame, "CENTER", iconSize/2+4, -1)
    self:SetDefaultFontStyle(assignmentFrame.text)
    return assignmentFrame
end

function SRTAssignments:UpdateAssignmentFrame(assignmentFrame, assignment, index, total)
    assignmentFrame:Show()
    assignmentFrame.player = assignment.player
    assignmentFrame.spellId = assignment.spell_id
    local _, _, icon = GetSpellInfo(assignment.spell_id)
    assignmentFrame.icon:SetTexture(icon)
    assignmentFrame.text:SetText(assignment.player)
    local color = SwiftdawnRaidTools:GetSpellColor(assignment.spell_id)
    assignmentFrame.text:SetTextColor(color.r, color.g, color.b)
    assignmentFrame.cooldownFrame:Clear()
    assignmentFrame:ClearAllPoints()
    if index > 1 then
        assignmentFrame:SetPoint("BOTTOMLEFT", assignmentFrame:GetParent(), "BOTTOM")
        assignmentFrame:SetPoint("TOPRIGHT", 0, 0)
    else
        assignmentFrame:SetPoint("BOTTOMLEFT")
        assignmentFrame:SetPoint("TOPRIGHT", assignmentFrame:GetParent(), "TOP", 0, 0)
    end
end

function SRTAssignments:GetEncounters()
    return SRT_Profile().data.encounters
end

function SRTAssignments:GetEncounterName(encounterID)
    SwiftdawnRaidTools:BossEncountersInit()
   return SwiftdawnRaidTools:BossEncountersGetAll()[encounterID]
end

function SRTAssignments:SetDefaultFontStyle(fontString)
    fontString:SetShadowOffset(1, -1)
    fontString:SetShadowColor(0, 0, 0, 1)
    fontString:SetJustifyH("LEFT")
    fontString:SetHeight(fontString:GetStringHeight())
end
