local SwiftdawnRaidTools = SwiftdawnRaidTools

local MIN_HEIGHT = 200

function SwiftdawnRaidTools:OverviewInit()
    local overviewTitleFontSize = self.db.profile.options.appearance.overviewTitleFontSize
    local container = CreateFrame("Frame", "SwiftdawnRaidToolsOverview", UIParent, "BackdropTemplate")
    container:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    container:SetSize(200, MIN_HEIGHT)
    container:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })
    container:SetBackdropColor(0, 0, 0, self.db.profile.options.appearance.overviewBackgroundOpacity)
    container:SetMovable(true)
    container:EnableMouse(true)
    container:SetUserPlaced(true)
    container:SetClampedToScreen(true)
    container:RegisterForDrag("LeftButton")
    container:SetScript("OnDragStart", function(self) self:StartMoving() end)
    container:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    container:SetScale(self.db.profile.options.appearance.overviewScale)
    container:SetClipsChildren(true)

    local popup = CreateFrame("Frame", "SwiftdawnRaidToolsOverviewPopup", UIParent, "BackdropTemplate")
    popup:SetClampedToScreen(true)
    popup:SetSize(200, 50)
    popup:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = {
            left = 2,
            right = 2,
            top = 2,
            bottom = 2,
        },
    })
    popup:SetBackdropColor(0, 0, 0, 1)
    popup:SetFrameStrata("DIALOG")
    
    popup:Hide() -- Start hidden

    local function showPopup()
        if not self.TEST and (InCombatLockdown() or SwiftdawnRaidTools:RaidAssignmentsInEncounter()) then
            return
        end

        SwiftdawnRaidTools:OverviewUpdatePopup()

        local scale = UIParent:GetEffectiveScale()
        local x, y = GetCursorPosition()
        x, y = x / scale, y / scale

        popup:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", x, y)

        popup:Show()
    end

    local header = CreateFrame("Frame", "SwiftdawnRaidToolsOverviewHeader", container, "BackdropTemplate")
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)
    header:EnableMouse(true)
    header:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 16,
    })
    header:SetBackdropColor(0, 0, 0, self.db.profile.options.appearance.overviewTitleBarOpacity)
    header:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and container:IsMouseEnabled() then
            self:GetParent():StartMoving()
        elseif button == "RightButton" then
            showPopup()
        end
    end)

    header:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self:GetParent():StopMovingOrSizing()
        end
    end)
    header:SetScript("OnEnter", function()
        SwiftdawnRaidTools.overviewHeader:SetBackdropColor(0, 0, 0, 1)
        SwiftdawnRaidTools.overviewHeaderButton:SetAlpha(1)
    end)
    header:SetScript("OnLeave", function()
        SwiftdawnRaidTools.overviewHeader:SetBackdropColor(0, 0, 0, SwiftdawnRaidTools.db.profile.options.appearance.overviewTitleBarOpacity)
        SwiftdawnRaidTools.overviewHeaderButton:SetAlpha(SwiftdawnRaidTools.db.profile.options.appearance.overviewTitleBarOpacity)
    end)

    local headerText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    headerText:SetFont(self:AppearanceGetOverviewTitleFontType(), overviewTitleFontSize)
    headerText:SetPoint("LEFT", header, "LEFT", 10, 0)
    headerText:SetShadowOffset(1, -1)
    headerText:SetShadowColor(0, 0, 0, 1)
    headerText:SetJustifyH("LEFT")
    headerText:SetWordWrap(false)

    local headerButton = CreateFrame("Button", nil, header)
    headerButton:SetSize(overviewTitleFontSize, overviewTitleFontSize)
    headerButton:SetPoint("RIGHT", header, "RIGHT", -3, 0)
    headerButton:SetNormalTexture("Gamepad_Ltr_Menu_32")
    headerButton:SetHighlightTexture("Gamepad_Ltr_Menu_32")
    headerButton:SetPushedTexture("Gamepad_Ltr_Menu_32")
    headerButton:SetAlpha(self.db.profile.options.appearance.overviewTitleBarOpacity)
    headerButton:SetScript("OnEnter", function()
        SwiftdawnRaidTools.overviewHeader:SetBackdropColor(0, 0, 0, 1)
        SwiftdawnRaidTools.overviewHeaderButton:SetAlpha(1)
    end)
    headerButton:SetScript("OnLeave", function()
        SwiftdawnRaidTools.overviewHeader:SetBackdropColor(0, 0, 0, SwiftdawnRaidTools.db.profile.options.appearance.overviewTitleBarOpacity)
        SwiftdawnRaidTools.overviewHeaderButton:SetAlpha(SwiftdawnRaidTools.db.profile.options.appearance.overviewTitleBarOpacity)
    end)

    headerButton:SetScript("OnClick", function()
        showPopup()
    end)
    headerButton:RegisterForClicks("AnyDown", "AnyUp")

    local main = CreateFrame("Frame", "SwiftdawnRaidToolsOverviewMain", container, "BackdropTemplate")
    main:SetPoint("BOTTOMLEFT", 0, 0)
    main:SetPoint("BOTTOMRIGHT", 0, 0)

    self.overviewFrame = container
    self.overviewPopup = popup
    self.overviewPopupListItems = {}
    self.overviewHeader = header
    self.overviewHeaderButton = headerButton
    self.overviewHeaderText = headerText
    self.overviewMain = main
    self.overviewBossAbilities = {}
    self.overviewAssignmentGroups = {}

    self:OverviewUpdateAppearance()
end

local function GetBossAbilityHeight()
    local overviewHeaderFontSize = SwiftdawnRaidTools.db.profile.options.appearance.overviewHeaderFontSize
    return overviewHeaderFontSize + 7
end

local function GetAssignmentGroupHeight()
    local overviewPlayerFontSize = SwiftdawnRaidTools.db.profile.options.appearance.overviewPlayerFontSize
    local iconSize = SwiftdawnRaidTools.db.profile.options.appearance.overviewIconSize
    return (overviewPlayerFontSize > iconSize and overviewPlayerFontSize or iconSize) + 7
end

function SwiftdawnRaidTools:OverviewUpdateAppearance()
    local overviewTitleFontSize = self.db.profile.options.appearance.overviewTitleFontSize
    local overviewHeaderFontSize = self.db.profile.options.appearance.overviewHeaderFontSize
    local overviewPlayerFontSize = self.db.profile.options.appearance.overviewPlayerFontSize
    local iconSize = SwiftdawnRaidTools.db.profile.options.appearance.overviewIconSize

    self.overviewFrame:SetScale(self.db.profile.options.appearance.overviewScale)
    self.overviewHeaderText:SetFont(self:AppearanceGetOverviewTitleFontType(), overviewTitleFontSize)
    local headerHeight = overviewTitleFontSize + 8
    self.overviewHeader:SetHeight(headerHeight)

    local headerWidth = self.overviewFrame:GetWidth()
    self.overviewHeaderText:SetWidth(headerWidth - 10 - overviewTitleFontSize)

    self.overviewMain:SetPoint("TOPLEFT", 0, -headerHeight)
    self.overviewMain:SetPoint("TOPRIGHT", 0, -headerHeight)
    self.overviewHeaderButton:SetSize(overviewTitleFontSize, overviewTitleFontSize)
    self.overviewHeaderButton:SetAlpha(self.db.profile.options.appearance.overviewTitleBarOpacity)

    self.overviewHeader:SetBackdropColor(0, 0, 0, self.db.profile.options.appearance.overviewTitleBarOpacity)
    local r, g, b = self.overviewFrame:GetBackdropColor()
    self.overviewFrame:SetBackdropColor(r, g, b, self.db.profile.options.appearance.overviewBackgroundOpacity)

    for _, frame in pairs(self.overviewPopupListItems) do
        frame.text:SetFont(self:AppearanceGetOverviewBossAbilityFontType(), 10)
    end

    for _, bossAbilityFrame in pairs(self.overviewBossAbilities) do
        bossAbilityFrame.text:SetFont(self:AppearanceGetOverviewBossAbilityFontType(), overviewHeaderFontSize)
        bossAbilityFrame:SetHeight(GetBossAbilityHeight())
    end

    for _, assignmentGroupFrame in pairs(self.overviewAssignmentGroups) do
        assignmentGroupFrame:SetHeight(GetAssignmentGroupHeight())
        for _, assignmentFrame in pairs(assignmentGroupFrame.assignments) do
            assignmentFrame.text:SetFont(self:AppearanceGetOverviewPlayerFontType(), overviewPlayerFontSize)
            assignmentFrame.iconFrame:SetSize(iconSize, iconSize)
            assignmentFrame.text:SetPoint("LEFT", assignmentFrame.iconFrame, "CENTER", iconSize/2+4, -1)
        end
    end

end

function SwiftdawnRaidTools:OverviewResize()
    local encounters = self:GetEncounters()

    local maxHeight = 0

    for _, encounter in pairs(encounters) do
        -- Overview Header
        local height = 20

        if encounter then
            for _, part in ipairs(encounter) do
                if part.type == "RAID_ASSIGNMENTS" then
                    height = height + 30
                    for _ in ipairs(part.assignments) do
                        height = height + 20
                    end
                end
            end
        end

        if height > maxHeight then
            maxHeight = height
        end
    end

    self.overviewFrame:SetHeight(math.max(MIN_HEIGHT, maxHeight))
end

function SwiftdawnRaidTools:OverviewUpdate()
    local encounters = self:GetEncounters()

    local show = self.db.profile.overview.show
    
    if not show then
        self.overviewFrame:Hide()
        return
    end

    local selectedEncounterIdFound = false

    for encounterId, _ in pairs(encounters) do
        if self.db.profile.overview.selectedEncounterId == encounterId then
            selectedEncounterIdFound = true
        end
    end

    if not selectedEncounterIdFound then
        local encounterIndexes = {}
        for encounterId in pairs(self:GetEncounters()) do
            table.insert(encounterIndexes, encounterId)
        end
        table.sort(encounterIndexes)

        self.db.profile.overview.selectedEncounterId = encounterIndexes[1]
    end

    self:OverviewUpdateHeaderText()
    self:OverviewUpdateMain()
    self:OverviewUpdateSpells()
    self:OverviewUpdateLocked()
    self.overviewFrame:Show()
end

function SwiftdawnRaidTools:OverviewUpdateLocked()
    self.overviewFrame:EnableMouse(not self.db.profile.overview.locked)
end

function SwiftdawnRaidTools:OverviewUpdateHeaderText()
    local encounters = self:GetEncounters()

    local encountersExists = false

    for _ in pairs(encounters) do
        encountersExists = true
        break
    end

    self.overviewHeaderText:SetAlpha(1)

    if encountersExists then
        self.overviewHeaderText:SetText(self:BossEncountersGetAll()[self.db.profile.overview.selectedEncounterId])
    else
        if self.db.profile.data.encountersProgress then
            self.overviewHeaderText:SetText("Loading Assignments... |cFFFFFFFF" .. string.format("%.1f", self.db.profile.data.encountersProgress) .. "%|r")
        else
            self.overviewHeaderText:SetText("SRT |cFFFFFFFF" .. self.VERSION .. "|r")
            self.overviewHeaderText:SetAlpha(0.8)
        end
    end
end

local function createPopupListItem(popupFrame, text, onClick)
    local item = CreateFrame("Frame", nil, popupFrame, "BackdropTemplate")
    item.highlight = item:CreateTexture(nil, "HIGHLIGHT")

    item:SetHeight(20)
    item:EnableMouse(true)
    item:SetScript("OnEnter", function() item.highlight:Show() end)
    item:SetScript("OnLeave", function() item.highlight:Hide() end)
    item:EnableMouse(true)
    item:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            if item.onClick then item.onClick() end
            popupFrame:Hide()
        end
    end)

    item.highlight:SetPoint("TOPLEFT", 10, 0)
    item.highlight:SetPoint("BOTTOMRIGHT", -10, 0)
    item.highlight:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
    item.highlight:SetBlendMode("ADD")
    item.highlight:SetAlpha(0.5)
    item.highlight:Hide()

    item.text = item:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    item.text:SetFont(SwiftdawnRaidTools:AppearanceGetOverviewPlayerFontType(), SwiftdawnRaidTools.db.profile.options.appearance.overviewPlayerFontSize)
    item.text:SetTextColor(1, 1, 1)
    item.text:SetPoint("BOTTOMLEFT", 15, 5)
    item.text:SetText(text)

    item.onClick = onClick

    return item
end

function SwiftdawnRaidTools:OverviewShowPopupListItem(index, text, setting, onClick, accExtraOffset, extraOffset)
    if not self.overviewPopupListItems[index] then
        self.overviewPopupListItems[index] = createPopupListItem(self.overviewPopup)
    end

    local item = self.overviewPopupListItems[index]

    local yOfs = -10 - (20 * (index -1))

    if accExtraOffset then
        yOfs = yOfs - accExtraOffset
    end

    if extraOffset then
        yOfs = yOfs - 10
    end

    if setting then
        item.text:SetTextColor(1, 1, 1, 1)
    else
        item.text:SetTextColor(1, 0.8235, 0)
    end

    item:SetPoint("TOPLEFT", 0, yOfs)
    item:SetPoint("TOPRIGHT", 0, yOfs)

    item.text:SetText(text)
    item.onClick = onClick

    item:Show()

    return yOfs
end

function SwiftdawnRaidTools:OverviewSelectEncounter(encounterId)
    self.db.profile.overview.selectedEncounterId = encounterId
    self:OverviewUpdate()
end

function SwiftdawnRaidTools:OverviewToggleLock()
    self.db.profile.overview.locked = not self.db.profile.overview.locked
    self:OverviewUpdateLocked()
end

function SwiftdawnRaidTools:OverviewUpdatePopup()
    if InCombatLockdown() then
        return
    end

    -- Update list items
    for _, item in pairs(self.overviewPopupListItems) do
        item:Hide()
    end

    local encounterIndexes = {}
    for encounterId in pairs(self:GetEncounters()) do
        table.insert(encounterIndexes, encounterId)
    end
    table.sort(encounterIndexes)

    local index = 1
    for _, encounterId in ipairs(encounterIndexes) do
        local selectFunc = function() self:OverviewSelectEncounter(encounterId) end
        self:OverviewShowPopupListItem(index, self:BossEncountersGetAll()[encounterId], false, selectFunc)
        index = index + 1
    end

    local encounterListItems = index > 1

    local toggleAnchorsFunc = function()
        self:NotificationsToggleFrameLock()
    end
    
    local anchorsText = "Hide Anchors"
    if self:NotificationsIsFrameLocked() then anchorsText = "Show Anchors" end
    self:OverviewShowPopupListItem(index, anchorsText, true, toggleAnchorsFunc, 0, encounterListItems)

    index = index + 1

    local lockFunc = function() self:OverviewToggleLock() end
    local lockedText = "Lock Overview"
    if self.db.profile.overview.locked then lockedText = "Unlock Overview" end
    self:OverviewShowPopupListItem(index, lockedText, true, lockFunc, 0, encounterListItems)

    index = index + 1

    local configurationFunc = function() InterfaceOptionsFrame_OpenToCategory("Swiftdawn Raid Tools") end
    self:OverviewShowPopupListItem(index, "Configuration", true, configurationFunc, encounterListItems and 10 or 0, false)

    index = index + 1

    local yOfs = self:OverviewShowPopupListItem(index, "Close", true, nil, encounterListItems and 10 or 0, true)

    local popupHeight = math.abs(yOfs) + 30

    -- Update popup size
    self.overviewPopup:SetHeight(popupHeight)
end

local function createBossAbilityFrame(mainFrame, prevFrame)
    local bossAbilityFrame = CreateFrame("Frame", nil, mainFrame)
    bossAbilityFrame:SetHeight(GetBossAbilityHeight())

    -- Anchor to main frame or previous row if it exists
    if prevFrame then
        bossAbilityFrame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0)
        bossAbilityFrame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0)
    else
        bossAbilityFrame:SetPoint("TOPLEFT", 0)
        bossAbilityFrame:SetPoint("TOPRIGHT", 0)
    end

    bossAbilityFrame.text = bossAbilityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bossAbilityFrame.text:SetFont(SwiftdawnRaidTools:AppearanceGetOverviewBossAbilityFontType(), SwiftdawnRaidTools.db.profile.options.appearance.overviewHeaderFontSize)
    bossAbilityFrame.text:SetTextColor(1, 1, 1, 0.8)
    bossAbilityFrame.text:SetPoint("LEFT", 10, 0)

    return bossAbilityFrame
end

local function updateBossAbilityFrame(bossAbilityFrame, prevFrame, name)
    bossAbilityFrame:Show()

    bossAbilityFrame:ClearAllPoints()

    if prevFrame then
        bossAbilityFrame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, -7)
        bossAbilityFrame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0, -7)
    else
        bossAbilityFrame:SetPoint("TOPLEFT", 0, -4)
        bossAbilityFrame:SetPoint("TOPRIGHT", 0, -4)
    end

    bossAbilityFrame.text:SetText(name)
end

local function createAssignmentGroupFrame(mainFrame, prevFrame, i)
    local assignmentGroupFrame = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    assignmentGroupFrame:SetHeight(GetAssignmentGroupHeight())
    assignmentGroupFrame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })

    -- Anchor to main frame or previous row if it exists
    if i > 1 then
        assignmentGroupFrame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0)
        assignmentGroupFrame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0)
    else
        assignmentGroupFrame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, -4)
        assignmentGroupFrame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0, -4)
    end

    assignmentGroupFrame.assignments = {}

    return assignmentGroupFrame
end

local function createAssignmentFrame(parentFrame)
    local assignmentFrame = CreateFrame("Frame", nil, parentFrame)

    assignmentFrame.iconFrame = CreateFrame("Frame", nil, assignmentFrame, "BackdropTemplate")
    local iconSize = SwiftdawnRaidTools.db.profile.options.appearance.overviewIconSize
    assignmentFrame.iconFrame:SetSize(iconSize, iconSize)
    assignmentFrame.iconFrame:SetPoint("LEFT", 10, 0)

    assignmentFrame.cooldownFrame = CreateFrame("Cooldown", nil, assignmentFrame.iconFrame, "CooldownFrameTemplate")
    assignmentFrame.cooldownFrame:SetAllPoints()

    assignmentFrame.iconFrame.cooldown = assignmentFrame.cooldownFrame

    assignmentFrame.icon = assignmentFrame.iconFrame:CreateTexture(nil, "ARTWORK")
    assignmentFrame.icon:SetAllPoints()
    assignmentFrame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    assignmentFrame.text = assignmentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    assignmentFrame.text:SetFont(SwiftdawnRaidTools:AppearanceGetOverviewTitleFontType(), SwiftdawnRaidTools.db.profile.options.appearance.overviewTitleFontSize)
    assignmentFrame.text:SetTextColor(1, 1, 1, 1)
    assignmentFrame.text:SetPoint("LEFT", assignmentFrame.iconFrame, "CENTER", iconSize/2+4, -1)

    return assignmentFrame
end

local function updateAssignmentFrame(assignmentFrame, assignment, index, total)
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

local function updateAssignmentGroupFrame(groupFrame, prevFrame, group, uuid, index)
    groupFrame:Show()

    groupFrame.uuid = uuid
    groupFrame.index = index

    groupFrame:SetBackdropColor(0, 0, 0, 0)

    groupFrame:ClearAllPoints()

    if prevFrame then
        groupFrame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, 0)
        groupFrame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0, 0)
    else
        groupFrame:SetPoint("TOPLEFT", 0, -4)
        groupFrame:SetPoint("TOPRIGHT", 0, -4)
    end

    for _, cd in pairs(groupFrame.assignments) do
        cd:Hide()
    end

    for i, assignment in ipairs(group) do
        if not groupFrame.assignments[i] then
            groupFrame.assignments[i] = createAssignmentFrame(groupFrame)
        end

        updateAssignmentFrame(groupFrame.assignments[i], assignment, i, #group)
    end
end

function SwiftdawnRaidTools:OverviewUpdateMain()
    for _, bossAbilityFrame in pairs(self.overviewBossAbilities) do
        bossAbilityFrame:Hide()
    end

    for _, group in pairs(self.overviewAssignmentGroups) do
        group:Hide()
    end

    local selectedEncounterId = self.db.profile.overview.selectedEncounterId
    local encounter = self:GetEncounters()[selectedEncounterId]

    if encounter then
        local headerIndex = 1
        local groupIndex = 1
        local prevFrame = nil
        for _, part in pairs(encounter) do
            if part.type == "RAID_ASSIGNMENTS" then
                -- Update header
                if not self.overviewBossAbilities[headerIndex] then
                    self.overviewBossAbilities[headerIndex] = createBossAbilityFrame(self.overviewMain)
                end
    
                local bossAbilityFrame = self.overviewBossAbilities[headerIndex]

                local headerText

                if part.metadata.spell_id then
                    local name = GetSpellInfo(part.metadata.spell_id)
                    headerText = name
                else
                    headerText = part.metadata.name
                end

                updateBossAbilityFrame(bossAbilityFrame, prevFrame, headerText)
                
                prevFrame = bossAbilityFrame
                headerIndex = headerIndex + 1

                -- Update assignment groups
                for i, group in ipairs(part.assignments) do
                    if not self.overviewAssignmentGroups[groupIndex] then
                        self.overviewAssignmentGroups[groupIndex] = createAssignmentGroupFrame(self.overviewMain, prevFrame, groupIndex)
                    end

                    local groupFrame = self.overviewAssignmentGroups[groupIndex]

                    updateAssignmentGroupFrame(groupFrame, prevFrame, group, part.uuid, i)

                    prevFrame = groupFrame
                    groupIndex = groupIndex + 1
                end
            end
        end
    end

    self:OverviewResize()
end

function SwiftdawnRaidTools:OverviewUpdateActiveGroups()
    for _, groupFrame in ipairs(self.overviewAssignmentGroups) do
        local selectedEncounterId = self.db.profile.overview.selectedEncounterId
        local encounter = self:GetEncounters()[selectedEncounterId]

        if encounter then
            for _, part in ipairs(encounter) do
                if part.uuid == groupFrame.uuid then
                    local activeGroups = self:GroupsGetActive(groupFrame.uuid)

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

function SwiftdawnRaidTools:OverviewUpdateSpells()
    for _, groupFrame in pairs(self.overviewAssignmentGroups) do
        for _, assignmentFrame in pairs(groupFrame.assignments) do
            if self:SpellsIsSpellActive(assignmentFrame.player, assignmentFrame.spellId) then
                local castTimestamp = self:SpellsGetCastTimestamp(assignmentFrame.player, assignmentFrame.spellId)
                local spell = self:SpellsGetSpell(assignmentFrame.spellId)

                if castTimestamp and spell then
                    assignmentFrame.cooldownFrame:SetCooldown(castTimestamp, spell.duration)
                end

                assignmentFrame:SetAlpha(1)
            else
                if self:SpellsIsSpellReady(assignmentFrame.player, assignmentFrame.spellId) then
                    assignmentFrame:SetAlpha(1)
                else
                    assignmentFrame:SetAlpha(0.4)
                end
            end
        end
    end
end
