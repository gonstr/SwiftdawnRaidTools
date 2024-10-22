local SwiftdawnRaidTools = SwiftdawnRaidTools
local SharedMedia = LibStub("LibSharedMedia-3.0")
local AceGUI = LibStub("AceGUI-3.0")

SRTAssignments = setmetatable({
    encounterFrames = {}
}, SRTWindow)
SRTAssignments.__index = SRTAssignments

function SRTAssignments:New(height, width)
    local o = SRTWindow.New(self, "Assignments", height, width)
    self.__index = self
    return o
end

function SRTAssignments:Initialize()
    SRTWindow.Initialize(self)
    self.headerText:SetText("Assignments Explorer")
    local encounterFrame = CreateFrame("Frame", "SRT_Encounter_"..tostring(encounterID), self.main)
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

    local selectedEncounterID = 1025
    local encounterAssignments = self:GetEncounters()[selectedEncounterID]

    local encounterName = self.main:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    encounterName:SetPoint("TOPLEFT", self.main, "TOPLEFT", 10, -5)
    encounterName:SetText(self:GetEncounterName(selectedEncounterID))
    encounterName:SetFont(self:GetHeaderFontType(), 14)
    self:SetDefaultFontStyle(encounterName)

    local previousAbility

    for _, bossAbility in ipairs(encounterAssignments) do
        local bossAbilityFrame = CreateFrame("Frame", nil, self.main)
        if previousAbility then
            bossAbilityFrame:SetPoint("TOPLEFT", previousAbility, "BOTTOMLEFT", 0, 0)
            bossAbilityFrame:SetPoint("TOPRIGHT", previousAbility, "BOTTOMRIGHT", 0, 0)
        else
            bossAbilityFrame:SetPoint("TOPLEFT", encounterName, "BOTTOMLEFT", 10, -7)
            bossAbilityFrame:SetPoint("TOPRIGHT", encounterName, "BOTTOMLEFT", 190, -7)
        end
        local bossAbilityFrameHeight = 7

        local bossAbilityName = bossAbilityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        bossAbilityName:SetPoint("TOPLEFT", bossAbilityFrame, "TOPLEFT", 0, 0)
        bossAbilityName:SetText(bossAbility.metadata.name)
        bossAbilityName:SetFont(self:GetHeaderFontType(), 12)
        bossAbilityName:SetTextColor(1, 1, 1, 0.8)
        self:SetDefaultFontStyle(bossAbilityName)
        bossAbilityFrameHeight = bossAbilityFrameHeight + 12

        local previousGroup = nil
        for groupIndex, group in ipairs(bossAbility.assignments) do
            local groupFrame = self:CreateGroupFrame(bossAbilityFrame, previousGroup)
            self:UpdateGroupFrame(groupFrame, previousGroup, group, bossAbility.uuid, groupIndex)
            groupFrame:SetHeight(self:GetAssignmentGroupHeight() + 3)
            bossAbilityFrameHeight = bossAbilityFrameHeight + groupFrame:GetHeight()
            previousGroup = groupFrame
        end

        bossAbilityFrameHeight = bossAbilityFrameHeight + 7
        bossAbilityFrame:SetHeight(bossAbilityFrameHeight)
        previousAbility = bossAbilityFrame
    end
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
        if not groupFrame.assignments[i] then
            groupFrame.assignments[i] = self:CreateAssignmentFrame(groupFrame)
        end
        self:UpdateAssignmentFrame(groupFrame.assignments[i], assignment, i, #group)
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
    if total > 1 then
        if index > 1 then
            assignmentFrame:SetPoint("BOTTOMLEFT", assignmentFrame:GetParent(), "BOTTOM")
            assignmentFrame:SetPoint("TOPRIGHT", 0, 0)
        else
            assignmentFrame:SetPoint("BOTTOMLEFT")
            assignmentFrame:SetPoint("TOPRIGHT", assignmentFrame:GetParent(), "TOP", 0, 0)
        end
    else
        assignmentFrame:SetPoint("BOTTOMLEFT")
        assignmentFrame:SetPoint("TOPRIGHT", 0, 0)
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
