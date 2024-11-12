local SwiftdawnRaidTools = SwiftdawnRaidTools
local SharedMedia = LibStub("LibSharedMedia-3.0")

---@class SRTOverview:SRTWindow
SRTOverview = setmetatable({
    bossAbilities = {},
    assignmentGroups = {}
}, SRTWindow)
SRTOverview.__index = SRTOverview

---@return SRTOverview
function SRTOverview:New(height, width)
    local obj = SRTWindow.New(self, "Overview", height, width)
    ---@cast obj SRTOverview
    self.__index = self
    return obj
end

function SRTOverview:Initialize()
    SRTWindow.Initialize(self)
    self:UpdateAppearance()
end

function SRTOverview:GetBossAbilityHeight()
    local headerFontSize = self:GetAppearance().headerFontSize
    return headerFontSize + 7
end

function SRTOverview:GetAssignmentGroupHeight()
    local playerFontSize = self:GetAppearance().playerFontSize
    local iconSize = self:GetAppearance().iconSize
    return (playerFontSize > iconSize and playerFontSize or iconSize) + 7
end

function SRTOverview:GetPlayerNameFont()
    return SharedMedia:Fetch("font", self:GetAppearance().playerFontType)
end

function SRTOverview:UpdateAppearance()
    SRTWindow.UpdateAppearance(self)
    local headerFontSize = self:GetAppearance().headerFontSize
    local playerFontSize = self:GetAppearance().playerFontSize
    local iconSize = self:GetAppearance().iconSize

    for _, frame in pairs(self.popupListItems) do
        frame.text:SetFont(self:GetHeaderFont(), 10)
    end

    for _, bossAbilityFrame in pairs(self.bossAbilities) do
        bossAbilityFrame.name:SetFont(self:GetHeaderFont(), headerFontSize)
        -- bossAbilityFrame:SetHeight(self:GetBossAbilityHeight())
    end

    for _, assignmentGroupFrame in pairs(self.assignmentGroups) do
        assignmentGroupFrame:SetHeight(self:GetAssignmentGroupHeight())
        for _, assignmentFrame in pairs(assignmentGroupFrame.assignments) do
            assignmentFrame.text:SetFont(self:GetPlayerNameFont(), playerFontSize)
            assignmentFrame.iconFrame:SetSize(iconSize, iconSize)
            assignmentFrame.text:SetPoint("LEFT", assignmentFrame.iconFrame, "CENTER", iconSize/2+4, -1)
        end
    end

    self:UpdateMain()
end

function SRTOverview:Resize()
    local encounters = SwiftdawnRaidTools:GetEncounters()
    local totalHeight = 0
    for _, encounter in pairs(encounters) do
        -- Overview Header
        local height = self.header:GetHeight()
        if encounter then
            for _, part in ipairs(encounter) do
                if part.type == "RAID_ASSIGNMENTS" then
                    height = height + 30
                    for _ in ipairs(part.assignments) do
                        height = height + self:GetAssignmentGroupHeight() + 3
                    end
                end
            end
        end
        if height > totalHeight then
            totalHeight = height
        end
    end
    self.container:SetHeight(math.max(MIN_HEIGHT, totalHeight))
end

function SRTOverview:Update()
    SRTWindow.Update(self)

    local encounters = SwiftdawnRaidTools:GetEncounters()
    local selectedEncounterIdFound = false
    for encounterId, _ in pairs(encounters) do
        if self:GetProfile().selectedEncounterId == encounterId then
            selectedEncounterIdFound = true
        end
    end
    if not selectedEncounterIdFound then
        local encounterIndexes = {}
        for encounterId in pairs(SwiftdawnRaidTools:GetEncounters()) do
            table.insert(encounterIndexes, encounterId)
        end
        table.sort(encounterIndexes)
        self:GetProfile().selectedEncounterId = encounterIndexes[1]
    end

    self:UpdateHeaderText()
    self:UpdateMain()
    self:UpdateSpells()
end

function SRTOverview:UpdateHeaderText()
    local encounters = SwiftdawnRaidTools:GetEncounters()

    local encountersExists = false

    for _ in pairs(encounters) do
        encountersExists = true
        break
    end

    self.headerText:SetAlpha(1)

    if encountersExists then
        self.headerText:SetText(SwiftdawnRaidTools:BossEncountersGetAll()[self:GetProfile().selectedEncounterId])
    else
        if SRT_Profile().data.encountersProgress then
            self.headerText:SetText("Loading Assignments... |cFFFFFFFF" .. string.format("%.1f", SRT_Profile().data.encountersProgress) .. "%|r")
        else
            self.headerText:SetText("SRT |cFFFFFFFF" .. tostring(SwiftdawnRaidTools.VERSION) .. "|r")
            self.headerText:SetAlpha(0.8)
        end
    end
end

function SRTOverview:SelectEncounter(encounterId)
    self:GetProfile().selectedEncounterId = encounterId
    self:Update()
end

function SRTOverview:UpdatePopupMenu()
    if InCombatLockdown() then
        return
    end

    -- Update list items
    for _, item in pairs(self.popupListItems) do
        item:Hide()
    end

    local encounterIndexes = {}
    for encounterId in pairs(SwiftdawnRaidTools:GetEncounters()) do
        table.insert(encounterIndexes, encounterId)
    end
    table.sort(encounterIndexes)

    local index = 1
    for _, encounterId in ipairs(encounterIndexes) do
        local selectFunc = function() self:SelectEncounter(encounterId) end
        self:ShowPopupListItem(index, SwiftdawnRaidTools:BossEncountersGetAll()[encounterId], false, selectFunc)
        index = index + 1
    end

    local encounterListItems = index > 1

    local toggleAnchorsFunc = function()
        SRT_Profile().notifications.locked = not SRT_Profile().notifications.locked
    end
    
    local anchorsText = "Hide Anchors"
    if SRT_Profile().notifications.locked then anchorsText = "Show Anchors" end
    self:ShowPopupListItem(index, anchorsText, true, toggleAnchorsFunc, 0, encounterListItems)

    index = index + 1

    local lockFunc = function()
        self:ToggleLock()
        LibStub("AceConfigRegistry-3.0"):NotifyChange("SwiftdawnRaidTools")
    end
    local lockedText = "Lock Overview"
    if self:GetProfile().locked then lockedText = "Unlock Overview" end
    self:ShowPopupListItem(index, lockedText, true, lockFunc, 0, encounterListItems)

    index = index + 1

    local configurationFunc = function() Settings.OpenToCategory("Swiftdawn Raid Tools") end
    self:ShowPopupListItem(index, "Configuration", true, configurationFunc, encounterListItems and 10 or 0, false)

    index = index + 1

    local yOfs = self:ShowPopupListItem(index, "Close", true, nil, encounterListItems and 10 or 0, true)

    local popupHeight = math.abs(yOfs) + 30

    -- Update popup size
    self.popupMenu:SetHeight(popupHeight)
end

function SRTOverview:UpdateMain()
    for _, bossAbilityFrame in pairs(self.bossAbilities) do
        bossAbilityFrame:Hide()
    end

    for _, group in pairs(self.assignmentGroups) do
        group:Hide()
    end

    local selectedEncounterId = self:GetProfile().selectedEncounterId
    local encounter = SwiftdawnRaidTools:GetEncounters()[selectedEncounterId]

    if encounter then

        local previousAbility
        for bossAbilityIndex, bossAbility in ipairs(encounter) do
            local bossAbilityFrame = self.bossAbilities[bossAbilityIndex] or CreateFrame("Frame", nil, self.main)
            if previousAbility then
                bossAbilityFrame:SetPoint("TOPLEFT", previousAbility, "BOTTOMLEFT", 0, 0)
                bossAbilityFrame:SetPoint("TOPRIGHT", previousAbility, "BOTTOMRIGHT", 0, 0)
            else
                bossAbilityFrame:SetPoint("TOPLEFT", self.header, "BOTTOMLEFT", 10, -7)
                bossAbilityFrame:SetPoint("TOPRIGHT", self.header, "BOTTOMRIGHT", -10, -7)
            end
            local bossAbilityFrameHeight = 7
    
            bossAbilityFrame.name = bossAbilityFrame.name or bossAbilityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            bossAbilityFrame.name:SetPoint("TOPLEFT", bossAbilityFrame, "TOPLEFT", 0, 0)
            bossAbilityFrame.name:SetText(bossAbility.metadata.name)
            bossAbilityFrame.name:SetFont(self:GetHeaderFont(), self:GetAppearance().headerFontSize)
            bossAbilityFrame.name:SetTextColor(1, 1, 1, 0.8)
            bossAbilityFrameHeight = bossAbilityFrameHeight + self:GetAppearance().headerFontSize

            bossAbilityFrame.groups = bossAbilityFrame.groups or {}
            for _, groupFrame in ipairs(bossAbilityFrame.groups) do
                groupFrame:Hide()
            end
            local previousGroup = nil
            for groupIndex, group in ipairs(bossAbility.assignments) do
                local groupFrame = bossAbilityFrame.groups[groupIndex] or FrameBuilder.CreateAssignmentGroupFrame(bossAbilityFrame, self:GetAssignmentGroupHeight() + 3)
                FrameBuilder.UpdateAssignmentGroupFrame(groupFrame, previousGroup, group, bossAbility.uuid, groupIndex, self:GetPlayerNameFont(), self:GetAppearance().playerFontSize, self:GetAppearance().iconSize)
    
                bossAbilityFrameHeight = bossAbilityFrameHeight + groupFrame:GetHeight()
                bossAbilityFrame.groups[groupIndex] = groupFrame
    
                previousGroup = groupFrame
            end
    
            bossAbilityFrameHeight = bossAbilityFrameHeight + 7
            bossAbilityFrame:SetHeight(bossAbilityFrameHeight)

            bossAbilityFrame:Show()
    
            self.bossAbilities[bossAbilityIndex] = bossAbilityFrame
            previousAbility = bossAbilityFrame
        end
    end

    self:Resize()
end

function SRTOverview:UpdateActiveGroups()
    for _, groupFrame in ipairs(self.assignmentGroups) do
        local selectedEncounterId = self:GetProfile().selectedEncounterId
        local encounter = SwiftdawnRaidTools:GetEncounters()[selectedEncounterId]

        if encounter then
            for _, part in ipairs(encounter) do
                if part.uuid == groupFrame.uuid then
                    local activeGroups = SwiftdawnRaidTools:GroupsGetActive(groupFrame.uuid)

                    if activeGroups and #activeGroups > 0 then
                        for _, index in ipairs(activeGroups) do
                            if index == groupFrame.index then
                                groupFrame:SetBackdropColor(1, 1, 1, 0.6)
                            else
                                groupFrame:SetBackdropColor(0, 0, 0, 0)
                            end
                        end
                    else
                        groupFrame:SetBackdropColor(0, 0, 0, 0)
                    end

                    break
                end
            end
        end
    end    
end

function SRTOverview:UpdateSpells()
    for _, groupFrame in pairs(self.assignmentGroups) do
        for _, assignmentFrame in pairs(groupFrame.assignments) do
            if SwiftdawnRaidTools:SpellsIsSpellActive(assignmentFrame.player, assignmentFrame.spellId) then
                local castTimestamp = SwiftdawnRaidTools:SpellsGetCastTimestamp(assignmentFrame.player, assignmentFrame.spellId)
                local spell = SwiftdawnRaidTools:SpellsGetSpell(assignmentFrame.spellId)

                if castTimestamp and spell then
                    assignmentFrame.cooldownFrame:SetCooldown(castTimestamp, spell.duration)
                end

                assignmentFrame:SetAlpha(1)
            else
                if SwiftdawnRaidTools:SpellsIsSpellReady(assignmentFrame.player, assignmentFrame.spellId) then
                    assignmentFrame:SetAlpha(1)
                else
                    assignmentFrame:SetAlpha(0.4)
                end
            end
        end
    end
end
