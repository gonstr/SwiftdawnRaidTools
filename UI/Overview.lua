local SwiftdawnRaidTools = SwiftdawnRaidTools

local MIN_HEIGHT = 200

function SwiftdawnRaidTools:OverviewInit()
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
        if InCombatLockdown() or SwiftdawnRaidTools:RaidAssignmentsInEncounter() then
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
    header:SetHeight(20)
    header:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 16,
    })
    header:SetBackdropColor(0, 0, 0, 0.8)
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

    local headerText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    headerText:SetFont(self:AppearanceGetFont(), 10)
    headerText:SetPoint("TOPLEFT", 10, -5)
    headerText:SetShadowOffset(1, -1)
    headerText:SetShadowColor(0, 0, 0, 1)

    local headerButton = CreateFrame("Button", nil, header)
    headerButton:SetSize(14, 14)
    headerButton:SetPoint("TOPRIGHT", -10, -3)
    headerButton:SetNormalTexture("Gamepad_Ltr_Menu_32")
    headerButton:SetHighlightTexture("Gamepad_Ltr_Menu_32")
    headerButton:SetPushedTexture("Gamepad_Ltr_Menu_32")

    headerButton:SetScript("OnClick", function()
        showPopup()
    end)
    headerButton:RegisterForClicks("AnyDown", "AnyUp")

    local main = CreateFrame("Frame", "SwiftdawnRaidToolsOvervieMain", container, "BackdropTemplate")
    main:SetPoint("TOPLEFT", 0, -20)
    main:SetPoint("TOPRIGHT", 0, -20)
    main:SetPoint("BOTTOMLEFT", 0, 0)
    main:SetPoint("BOTTOMRIGHT", 0, 0)

    self.overviewFrame = container
    self.overviewPopup = popup
    self.overviewPopupListItems = {}
    self.overviewHeader = header
    self.overviewHeaderButton = headerButton
    self.overviewHeaderText = headerText
    self.overviewMain = main
    self.overviewMainHeaders = {}
    self.overviewMainRaidAssignmentGroups = {}

    self:OverviewUpdateAppearance()
end

function SwiftdawnRaidTools:OverviewUpdateAppearance()
    self.overviewFrame:SetScale(self.db.profile.options.appearance.overviewScale)

    self.overviewHeaderText:SetFont(self:AppearanceGetFont(), 10)

    local r, g, b = self.overviewFrame:GetBackdropColor()
    self.overviewFrame:SetBackdropColor(r, g, b, self.db.profile.options.appearance.overviewBackgroundOpacity)

    for _, frame in pairs(self.overviewPopupListItems) do
        frame.text:SetFont(self:AppearanceGetFont(), 10)
    end

    for _, frame in pairs(self.overviewMainHeaders) do
        frame.text:SetFont(self:AppearanceGetFont(), 10)
    end

    for _, group in pairs(self.overviewMainRaidAssignmentGroups) do
        for _, frame in pairs(group.assignments) do
            frame.text:SetFont(self:AppearanceGetFont(), 10)
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

    local highlight
    item:SetHeight(20)
    item:EnableMouse(true)
    item:SetScript("OnEnter", function() highlight:Show() end)
    item:SetScript("OnLeave", function() highlight:Hide() end)
    item:EnableMouse(true)
    item:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            if item.onClick then item.onClick() end
            popupFrame:Hide()
        end
    end)
    
    highlight = item:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetPoint("TOPLEFT", 10, 0)
    highlight:SetPoint("BOTTOMRIGHT", -10, 0)
    highlight:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
    highlight:SetBlendMode("ADD")
    highlight:SetAlpha(0.5)
    highlight:Hide()

    item.text = item:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    item.text:SetFont(SwiftdawnRaidTools:AppearanceGetFont(), 10)
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

local function createOverviewMainHeader(mainFrame, prevFrame)
    local frame = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    frame:SetHeight(20)

    -- Anchor to main frame or previous row if it exists
    if prevFrame then
        frame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0)
        frame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0)
    else
        frame:SetPoint("TOPLEFT", 0)
        frame:SetPoint("TOPRIGHT", 0)
    end

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.text:SetFont(SwiftdawnRaidTools:AppearanceGetFont(), 10)
    frame.text:SetTextColor(0.8, 0.8, 0.8, 1)
    frame.text:SetPoint("BOTTOMLEFT", 10, 5)

    return frame
end

local function updateOverviewMainHeader(frame, prevFrame, name)
    frame:Show()

    frame:ClearAllPoints()

    if prevFrame then
        frame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, -8)
        frame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0, -8)
    else
        frame:SetPoint("TOPLEFT", 0)
        frame:SetPoint("TOPRIGHT", 0)
    end

    frame.text:SetText(name)
end

local function createOverviewMainGroup(mainFrame, prevFrame)
    local frame = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    frame:SetHeight(20)
    frame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })

    frame.assignments = {}

    return frame
end

local function createOverviewMainGroupAssignment(parentFrame)
    local frame = CreateFrame("Frame", nil, parentFrame)

    frame.iconFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.iconFrame:SetSize(14, 14)
    frame.iconFrame:SetPoint("BOTTOMLEFT", 10, 2.5)

    frame.cooldownFrame = CreateFrame("Cooldown", nil, frame.iconFrame, "CooldownFrameTemplate")
    frame.cooldownFrame:SetAllPoints()

    frame.iconFrame.cooldown = frame.cooldownFrame

    frame.icon = frame.iconFrame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints()
    frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.text:SetFont(SwiftdawnRaidTools:AppearanceGetFont(), 10)
    frame.text:SetTextColor(1, 1, 1, 1)
    frame.text:SetPoint("BOTTOMLEFT", 28, 4.5)

    return frame
end

local function updateOverviewMainGroupAssignment(frame, assignment, index, total)
    frame:Show()

    frame.player = assignment.player
    frame.spellId = assignment.spell_id

    local _, _, icon = GetSpellInfo(assignment.spell_id)

    frame.icon:SetTexture(icon)
    frame.text:SetText(assignment.player)

    local color = SwiftdawnRaidTools:GetSpellColor(assignment.spell_id)

    frame.text:SetTextColor(color.r, color.g, color.b)

    frame.cooldownFrame:Clear()

    frame:ClearAllPoints()

    if total > 1 then
        if index > 1 then
            frame:SetPoint("BOTTOMLEFT", frame:GetParent(), "BOTTOM")
            frame:SetPoint("TOPRIGHT")
        else
            frame:SetPoint("BOTTOMLEFT")
            frame:SetPoint("TOPRIGHT", frame:GetParent(), "TOP")
        end
    else
        frame:SetPoint("BOTTOMLEFT")
        frame:SetPoint("TOPRIGHT")
    end
end

local function updateOverviewMainGroup(frame, prevFrame, group, uuid, index)
    frame:Show()

    frame.uuid = uuid
    frame.index = index

    frame:SetBackdropColor(0, 0, 0, 0)

    frame:ClearAllPoints()
    
    if prevFrame then
        frame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, 0)
        frame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0, 0)
    else
        frame:SetPoint("TOPLEFT", 0)
        frame:SetPoint("TOPRIGHT", 0)
    end

    for _, cd in pairs(frame.assignments) do
        cd:Hide()
    end
    
    for i, assignment in ipairs(group) do
        if not frame.assignments[i] then
            frame.assignments[i] = createOverviewMainGroupAssignment(frame)
        end

        updateOverviewMainGroupAssignment(frame.assignments[i], assignment, i, #group)
    end
end

function SwiftdawnRaidTools:OverviewUpdateMain()
    for _, header in pairs(self.overviewMainHeaders) do
        header:Hide()
    end

    for _, group in pairs(self.overviewMainRaidAssignmentGroups) do
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
                if not self.overviewMainHeaders[headerIndex] then
                    self.overviewMainHeaders[headerIndex] = createOverviewMainHeader(self.overviewMain)
                end
    
                local frame = self.overviewMainHeaders[headerIndex]

                local headerText

                if part.metadata.spell_id then
                    local name = GetSpellInfo(part.metadata.spell_id)
                    headerText = name
                else
                    headerText = part.metadata.name
                end

                updateOverviewMainHeader(frame, prevFrame, headerText)
                
                prevFrame = frame
                headerIndex = headerIndex + 1

                -- Update assignment groups
                for i, group in ipairs(part.assignments) do
                    if not self.overviewMainRaidAssignmentGroups[groupIndex] then
                        self.overviewMainRaidAssignmentGroups[groupIndex] = createOverviewMainGroup(self.overviewMain)
                    end

                    local frame = self.overviewMainRaidAssignmentGroups[groupIndex]

                    updateOverviewMainGroup(frame, prevFrame, group, part.uuid, i)

                    prevFrame = frame
                    groupIndex = groupIndex + 1
                end
            end
        end
    end

    self:OverviewResize()
end

function SwiftdawnRaidTools:OverviewUpdateActiveGroups()
    for _, groupFrame in ipairs(self.overviewMainRaidAssignmentGroups) do
        local selectedEncounterId = self.db.profile.overview.selectedEncounterId
        local encounter = self:GetEncounters()[selectedEncounterId]


        if encounter then
            for _, part in ipairs(encounter) do
                if part.uuid == groupFrame.uuid then
                    local activeGroups = self:GroupsGetActive(groupFrame.uuid)

                    if activeGroups then
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
    for _, groupFrame in pairs(self.overviewMainRaidAssignmentGroups) do
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
