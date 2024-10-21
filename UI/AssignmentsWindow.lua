local SwiftdawnRaidTools = SwiftdawnRaidTools
local SharedMedia = LibStub("LibSharedMedia-3.0")

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

function SRTAssignments:UpdateAppearance()
    SRTWindow.UpdateAppearance(self)
    local previousEncounterFrame
    for encounterID, bossAbilities in pairs(self:GetEncounters()) do
        local encounterFrame = self:CreateEncounterFrame(encounterID, bossAbilities, previousEncounterFrame)
        self.encounterFrames[encounterID] = encounterFrame
        previousEncounterFrame = encounterFrame
    end
    DevTool:AddData(self, "assignmentsWindow")
end

function SRTAssignments:GetEncounters()
    return SRT_Profile().data.encounters
end

function SRTAssignments:CreateEncounterFrame(encounterID, bossAbilities, previousEncounterFrame)
    DevTool:AddData(encounterID, "encounterID")
    DevTool:AddData(bossAbilities, "bossAbilities")
    local encounterFrame = CreateFrame("Frame", "SRT_Encounter_"..tostring(encounterID), self.main)
    if previousEncounterFrame == nil then
        encounterFrame:SetPoint("TOPLEFT", self.main, "TOPLEFT", 5, 0)
        encounterFrame:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", -5, 0)
    else
        encounterFrame:SetPoint("TOPLEFT", previousEncounterFrame, "BOTTOMLEFT", 0, -3)
        encounterFrame:SetPoint("TOPRIGHT", previousEncounterFrame, "BOTTOMRIGHT", 0, -3)
    end
    encounterFrame.title = encounterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    encounterFrame.title:SetPoint("TOPLEFT", encounterFrame, "TOPLEFT", 0, -3)
    encounterFrame.title:SetText("EncounterID: "..tostring(encounterID))
    encounterFrame.title:SetFont(self:GetHeaderFontType(), 12)
    encounterFrame.title:SetHeight(encounterFrame.title:GetStringHeight())
    local bossAbilitiesHeight = 0
    encounterFrame.bossAbilities = {}
    for bossAbilityIndex, bossAbility in ipairs(bossAbilities) do
        local bossAbilityHeight = 0
        local bossAbilityFrame = CreateFrame("Frame", string.format("SRT_BossAbility_%d_%d", encounterID, bossAbilityIndex), encounterFrame)
        bossAbilityFrame:SetWidth(self.width)
        if #encounterFrame.bossAbilities == 0 then
            bossAbilityFrame:SetPoint("TOPLEFT", encounterFrame.title, "BOTTOMLEFT", 0, -3)
        else
            bossAbilityFrame:SetPoint("TOPLEFT", encounterFrame.bossAbilities[bossAbilityIndex-1], "BOTTOMLEFT", 0, -3)
        end
        DevTool:AddData(bossAbility, "bossAbility")
        bossAbilityFrame.title = encounterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        bossAbilityFrame.title:SetPoint("TOPLEFT", bossAbilityFrame, "TOPLEFT", 0, -3)
        bossAbilityFrame.title:SetText("- "..bossAbility.metadata.name)
        bossAbilityFrame.title:SetFont(self:GetHeaderFontType(), 12)
        bossAbilityHeight = bossAbilityHeight + bossAbilityFrame.title:GetStringHeight()
        bossAbilityFrame.assignments = encounterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        bossAbilityFrame.assignments:SetPoint("TOPLEFT", bossAbilityFrame.title, "BOTTOMLEFT")
        bossAbilityFrame.assignments:SetJustifyH("LEFT")
        bossAbilityFrame.assignments:SetWordWrap(true)
        local assignmentsTextString = "  - Assignments:\n"
        for assignmentGroupIndex, assignmentGroup in ipairs(bossAbility.assignments) do
            DevTool:AddData(assignmentGroup, "assignmentGroup")
            assignmentsTextString = assignmentsTextString .. "    Group "..tostring(assignmentGroupIndex).."\n"
            for _, assignment in ipairs(assignmentGroup) do
                DevTool:AddData(assignment, "assignment")
                assignmentsTextString = assignmentsTextString .. string.format("      %s %s %d", assignment.player, assignment.type, assignment.spell_id).."\n"
            end
        end
        bossAbilityFrame.assignments:SetText(assignmentsTextString)
        bossAbilityFrame.assignments:SetFont(self:GetPlayerFontType(), 10)
        bossAbilityFrame.assignments:SetHeight(bossAbilityFrame.assignments:GetStringHeight())
        bossAbilityHeight = bossAbilityHeight + bossAbilityFrame.assignments:GetHeight()
        bossAbilityFrame.triggers = encounterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        bossAbilityFrame.triggers:SetPoint("TOPLEFT", bossAbilityFrame.assignments, "BOTTOMLEFT", 0, -3)
        bossAbilityFrame.triggers:SetJustifyH("LEFT")
        bossAbilityFrame.triggers:SetWordWrap(true)
        local triggerTextString = "  - Triggers:\n"
        for _, trigger in ipairs(bossAbility.triggers) do
            DevTool:AddData(trigger, "trigger")
            triggerTextString = triggerTextString .. string.format("    %s\n", trigger.type)
        end
        bossAbilityFrame.triggers:SetText(triggerTextString)
        bossAbilityFrame.triggers:SetFont(self:GetPlayerFontType(), 10)
        bossAbilityFrame.triggers:SetHeight(bossAbilityFrame.triggers:GetStringHeight())
        bossAbilityHeight = bossAbilityHeight + bossAbilityFrame.triggers:GetHeight()
        bossAbilityFrame:SetHeight(bossAbilityHeight)
        bossAbilitiesHeight = bossAbilitiesHeight + bossAbilityHeight
        table.insert(encounterFrame.bossAbilities, bossAbilityIndex, bossAbilityFrame)
    end
    encounterFrame:SetHeight(encounterFrame.title:GetStringHeight() + bossAbilitiesHeight)
    return encounterFrame
end