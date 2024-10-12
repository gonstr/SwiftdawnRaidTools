local insert = table.insert

local SwiftdawnRaidTools = SwiftdawnRaidTools

local SONAR_SOUND_FILE = "Interface\\AddOns\\SwiftdawnRaidTools\\Media\\PowerAuras_Sounds_Sonar.mp3"

function SwiftdawnRaidTools:NotificationsInit()
    local container = CreateFrame("Frame", "SwiftdawnRaidToolsNotification", UIParent, "BackdropTemplate")
    container:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
    container:SetMovable(true)
    container:SetUserPlaced(true)
    container:SetClampedToScreen(true)
    container:RegisterForDrag("LeftButton")
    container:SetScript("OnDragStart", function(self) self:StartMoving() end)
    container:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    container:SetSize(250, 50)
    container:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })
    container:SetBackdropColor(0, 0, 0, 0)

    container.frameLockText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    container.frameLockText:SetTextColor(1, 1, 1, 0.4)
    container.frameLockText:SetPoint("CENTER", 0, 0)
    container.frameLockText:SetText("SRT Notifications Anchor")
    container.frameLockText:Hide()

    local header = CreateFrame("Frame", "SwiftdawnRaidToolsNotificationHeader", container, "BackdropTemplate")
    header:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, 0)
    header:SetBackdrop({
        bgFile = "Interface\\Cooldown\\LoC-ShadowBG"
    })
    header:SetBackdropColor(0, 0, 0, self.db.profile.options.appearance.notificationsBackgroundOpacity)
    header.text = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header.text:SetTextColor(1, 1, 1, 1)
    header.text:SetPoint("RIGHT", -90, -1)
    header.countdown = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header.countdown:SetTextColor(1, 1, 1, 1)
    header.countdown:SetPoint("LEFT", header, "CENTER", 40, -1)

    header:Hide()

    local content = CreateFrame("Frame", "SwiftdawnRaidToolsNotificationContent", container, "BackdropTemplate")

    content:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
    content:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, 0)
    content:SetBackdrop({
        bgFile = "Interface\\Cooldown\\LoC-ShadowBG"
    })
    content:SetBackdropColor(0, 0, 0, self.db.profile.options.appearance.notificationsBackgroundOpacity)
    content:Hide()

    local extraInfo = CreateFrame("Frame", nil, container, "BackdropTemplate")
    extraInfo:SetHeight(30)
    extraInfo:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })
    extraInfo:SetBackdropColor(0, 0, 0, 0.6)
    extraInfo.text = extraInfo:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    extraInfo.text:SetFont("Fonts\\ARIALN.TTF", 12)
    extraInfo.text:SetTextColor(1, 1, 1, 0.8)
    extraInfo.text:SetPoint("BOTTOMLEFT", 32, 8)
    extraInfo.text:SetWidth(200)
    extraInfo.text:SetJustifyH("LEFT")
    extraInfo.text:SetJustifyV("TOP")
    extraInfo.text:SetWordWrap(true)

    extraInfo:Hide()

    self.notificationFrameFadeOut = SwiftdawnRaidTools:CreateFadeOut(content, function()
        SwiftdawnRaidTools.notificationHeaderFrame:Hide()
        SwiftdawnRaidTools.notificationContentFrame:Hide()
    end)

    self.notificationShowId = ""

    self.notificationRaidAssignmentGroups = {}
    self.notificationsCountdown = 0
    self.notificationsCountdownFade = 2

    self.notificationFrame = container
    self.notificationHeaderFrame = header
    self.notificationContentFrame = content
    self.notificationExtraInfoFrame = extraInfo

    self:NotificationsUpdateAppearance()
end

function SwiftdawnRaidTools:NotificationsUpdateAppearance()
    local headerFontSize = self.db.profile.options.appearance.notificationsHeaderFontSize
    local countdownFontSize = self.db.profile.options.appearance.notificationsCountdownFontSize
    local playerFontSize = self.db.profile.options.appearance.notificationsPlayerFontSize
    local iconSize = self.db.profile.options.appearance.notificationsIconSize
    local headerHeight = headerFontSize > countdownFontSize and headerFontSize or countdownFontSize
    local contentHeight = playerFontSize > iconSize and playerFontSize or iconSize

    self.notificationFrame:SetScale(self.db.profile.options.appearance.notificationsScale)
    self.notificationFrame.frameLockText:SetFont(self:AppearanceGetNotificationsHeaderFontType(), headerFontSize)

    self.notificationHeaderFrame:SetHeight(headerHeight)
    self.notificationHeaderFrame:SetPoint("BOTTOMLEFT", self.notificationFrame, "TOPLEFT", 0, headerHeight)
    self.notificationHeaderFrame:SetPoint("BOTTOMRIGHT", self.notificationFrame, "TOPRIGHT", 0, headerHeight)
    self.notificationHeaderFrame.text:SetFont(self:AppearanceGetNotificationsHeaderFontType(), headerFontSize)
    self.notificationHeaderFrame.countdown:SetFont(self:AppearanceGetNotificationsCountdownFontType(), countdownFontSize)

    self.notificationContentFrame:SetHeight(contentHeight+14)
    self.notificationContentFrame:SetPoint("BOTTOMLEFT", self.notificationHeaderFrame, "BOTTOMLEFT", 0, -(contentHeight+14))
    self.notificationContentFrame:SetPoint("BOTTOMRIGHT", self.notificationHeaderFrame, "BOTTOMRIGHT", 0, -(contentHeight+14))
    local r, g, b = self.notificationContentFrame:GetBackdropColor()
    self.notificationContentFrame:SetBackdropColor(r, g, b, self.db.profile.options.appearance.notificationsBackgroundOpacity)

    for _, groupFrame in pairs(self.notificationRaidAssignmentGroups) do
        for _, assignmentFrame in pairs(groupFrame.assignments) do
            assignmentFrame.text:SetFont(self:AppearanceGetNotificationsPlayerFontType(), playerFontSize)
            assignmentFrame.iconFrame:SetSize(iconSize, iconSize)
            assignmentFrame.text:SetPoint("CENTER", assignmentFrame, "CENTER", iconSize/2, 0)
        end
    end
end

function SwiftdawnRaidTools:NotificationsToggleFrameLock(lock)
    if lock or self.notificationFrame:IsMouseEnabled() then
        self.notificationFrame:EnableMouse(false)
        self.notificationFrame:SetBackdropColor(0, 0, 0, 0)
        self.notificationFrame.frameLockText:Hide()
    else
        self.notificationFrame:EnableMouse(true)
        self.notificationFrame:SetBackdropColor(0, 0, 0, 0.6)
        self.notificationFrame.frameLockText:Show()
        self.notificationHeaderFrame:Hide()
        self.notificationContentFrame:Hide()
    end
end

function SwiftdawnRaidTools:NotificationsIsFrameLocked()
    return not self.notificationFrame:IsMouseEnabled()
end

function SwiftdawnRaidTools:NotificationsUpdateHeader(text)
    self.notificationHeaderFrame.text:SetText(self:StringEllipsis(text, 32))
end

local function createNotificationGroup(contentFrame, assignmentCount)
    local groupFrame = CreateFrame("Frame", nil, contentFrame, "BackdropTemplate")

    local playerFontSize = SwiftdawnRaidTools.db.profile.options.appearance.notificationsPlayerFontSize
    local iconSize = SwiftdawnRaidTools.db.profile.options.appearance.notificationsIconSize
    local contentHeight = playerFontSize > iconSize and playerFontSize or iconSize
    groupFrame:SetSize(120*assignmentCount+10, contentHeight)

    groupFrame.assignments = {}

    return groupFrame
end

local function createNotificationGroupAssignment(groupFrame)
    local assignmentFrame = CreateFrame("Frame", nil, groupFrame, "BackdropTemplate")
    local playerFontSize = SwiftdawnRaidTools.db.profile.options.appearance.notificationsPlayerFontSize
    local iconSize = SwiftdawnRaidTools.db.profile.options.appearance.notificationsIconSize
    local contentHeight = playerFontSize > iconSize and playerFontSize or iconSize
    assignmentFrame:SetSize(120, contentHeight)
    assignmentFrame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })
    assignmentFrame:SetBackdropColor(1, 1, 1, 1)

    assignmentFrame.text = assignmentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    assignmentFrame.text:SetFont(SwiftdawnRaidTools:AppearanceGetNotificationsHeaderFontType(), SwiftdawnRaidTools.db.profile.options.appearance.notificationsHeaderFontSize)
    assignmentFrame.text:SetTextColor(1, 1, 1, 1)
    assignmentFrame.text:SetPoint("CENTER", assignmentFrame, "CENTER", iconSize/2, 0)

    assignmentFrame.iconFrame = CreateFrame("Frame", nil, assignmentFrame, "BackdropTemplate")
    local iconSize = SwiftdawnRaidTools.db.profile.options.appearance.notificationsIconSize
    assignmentFrame.iconFrame:SetSize(iconSize, iconSize)
    assignmentFrame.iconFrame:SetPoint("RIGHT", assignmentFrame.text, "LEFT", -4, 0)

    assignmentFrame.cooldownFrame = CreateFrame("Cooldown", nil, assignmentFrame.iconFrame, "CooldownFrameTemplate")
    assignmentFrame.cooldownFrame:SetAllPoints()

    assignmentFrame.iconFrame.cooldown = assignmentFrame.cooldownFrame

    assignmentFrame.icon = assignmentFrame.iconFrame:CreateTexture(nil, "ARTWORK")
    assignmentFrame.icon:SetAllPoints()
    assignmentFrame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    return assignmentFrame
end

local function updateNotificationGroupAssignment(assignmentFrame, assignment, index, total)
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

    if total == 1 then
        assignmentFrame:SetPoint("TOPLEFT", assignmentFrame:GetParent(), "TOP", -60, 0)
        assignmentFrame:SetPoint("TOPRIGHT", assignmentFrame:GetParent(), "TOP", 60, 0)
    else
        local offset = (index - 1) * 120 + 4
        assignmentFrame:SetPoint("TOPLEFT", assignmentFrame:GetParent(), "TOPLEFT", offset, 0)
        assignmentFrame:SetPoint("BOTTOMLEFT", assignmentFrame:GetParent(), "BOTTOMLEFT", offset, 0)
    end
end

local function updateNotificationGroup(groupFrame, previousGroupFrame, group, uuid, index)
    groupFrame:Show()

    groupFrame.uuid = uuid
    groupFrame.index = index

    if previousGroupFrame == nil then
        groupFrame:SetPoint("TOPLEFT", SwiftdawnRaidTools.notificationContentFrame, "TOPLEFT", 0, -10)
        groupFrame:SetPoint("TOPRIGHT", SwiftdawnRaidTools.notificationContentFrame, "TOPRIGHT", 0, -10)
    else
        groupFrame:SetPoint("TOPLEFT", previousGroupFrame, "BOTTOMLEFT", 0, -4)
        groupFrame:SetPoint("TOPRIGHT", previousGroupFrame, "BOTTOMRIGHT", 0, -4)
    end

    for _, cd in pairs(groupFrame.assignments) do
        cd:Hide()
    end
    
    for i, assignment in ipairs(group) do
        if not groupFrame.assignments[i] then
            groupFrame.assignments[i] = createNotificationGroupAssignment(groupFrame)
        end

        updateNotificationGroupAssignment(groupFrame.assignments[i], assignment, i, #group)
    end
end

local function updateExtraInfo(frame, prevFrame, assignments, activeGroups)
    -- Use BETCH_MATCH recursivly to create list of follow ups. This list might not be
    -- the correct order in which assignments will be selected but its the best
    -- estimation we can do.
    local groups = {}

    local assignmentsClone = SwiftdawnRaidTools:ShallowClone(assignments)

    local bestMatchIndex = SwiftdawnRaidTools:RaidAssignmentsSelectBestMatchIndex(assignmentsClone)
    if bestMatchIndex then assignmentsClone[bestMatchIndex] = nil end

    while bestMatchIndex do
        insert(groups, bestMatchIndex)

        bestMatchIndex = SwiftdawnRaidTools:RaidAssignmentsSelectBestMatchIndex(assignmentsClone)
        if bestMatchIndex then assignmentsClone[bestMatchIndex] = nil end
    end

    for _, index in ipairs(activeGroups) do
        for i, group in ipairs(groups) do
            if group == index then
                groups[i] = nil
            end
        end
    end

    local playersKeySet = {}

    for _, index in pairs(groups) do
        local group = assignments[index]

        if group then
            for _, assignment in ipairs(group) do
                if assignment.type == "SPELL" and SwiftdawnRaidTools:SpellsIsSpellReady(assignment.player, assignment.spell_id) then
                    insert(playersKeySet, assignment.player)
                end
            end
        end
    end

    local players={}

    for _, player in pairs(playersKeySet) do
        insert(players, player)
    end

    if #players > 0 then
        frame:Show()

        frame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, 0)
        frame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0, 0)

        frame.text:SetText("→ " .. SwiftdawnRaidTools:StringJoin(players) .. " follow up.")

        frame:SetHeight(frame.text:GetStringHeight() + 10)
    end
end

local function fadeCountdown(_, elapsed)
    SwiftdawnRaidTools.notificationsCountdownFade = SwiftdawnRaidTools.notificationsCountdownFade - elapsed
    if SwiftdawnRaidTools.notificationsCountdownFade > 0 then
        local opacity = SwiftdawnRaidTools.notificationsCountdownFade / 2
        SwiftdawnRaidTools.notificationHeaderFrame.countdown:SetTextColor(1, 0, 0, opacity)
    else
        SwiftdawnRaidTools.notificationHeaderFrame.countdown:Hide()
        SwiftdawnRaidTools.notificationHeaderFrame.countdown:SetTextColor(1, 1, 1, 1)
        SwiftdawnRaidTools.notificationContentFrame:SetScript("OnUpdate", nil)
    end
end

local function updateCountdown(_, elapsed)
    SwiftdawnRaidTools.notificationsCountdown = SwiftdawnRaidTools.notificationsCountdown - elapsed

    if SwiftdawnRaidTools.notificationsCountdown > 0 then
        SwiftdawnRaidTools.notificationHeaderFrame.countdown:SetText(string.format("%.1fs", SwiftdawnRaidTools.notificationsCountdown))
    else
        SwiftdawnRaidTools.notificationHeaderFrame.countdown:SetText("NOW")
        SwiftdawnRaidTools.notificationHeaderFrame.countdown:SetTextColor(1, 0, 0, 1)
        SwiftdawnRaidTools.notificationsCountdownFade = 2
        SwiftdawnRaidTools.notificationContentFrame:SetScript("OnUpdate", fadeCountdown)
    end
end

function SwiftdawnRaidTools:NotificationsShowRaidAssignment(uuid, context, delay, countdown)
    local selectedEncounterId = self.db.profile.overview.selectedEncounterId
    local encounter = self:GetEncounters()[selectedEncounterId]

    if not self.TEST then
        if self.db.profile.options.notifications.showOnlyOwnNotifications then
            local part = self:GetRaidAssignmentPart(uuid)

            if part and not self:IsPlayerInActiveGroup(part) then
                return
            end
        end
    end

    self.notificationExtraInfoFrame:Hide()

    for _, group in pairs(self.notificationRaidAssignmentGroups) do
        group:Hide()
    end

    if encounter then            
        local groupIndex = 1
        local previousGroupFrame
        for _, part in pairs(encounter) do
            if part.type == "RAID_ASSIGNMENTS" and part.uuid == uuid then
                local activeGroups = self:GroupsGetActive(uuid)

                if not activeGroups or #activeGroups == 0 then
                    return
                end
                
                self:NotificationsToggleFrameLock(true)
    
                self.notificationFrameFadeOut:Stop()
                self.notificationHeaderFrame:Show()
                self.notificationContentFrame:Show()
            
                if not self.db.profile.options.notifications.mute then
                    PlaySoundFile(SONAR_SOUND_FILE, "Master")
                end

                -- Update header
                local headerText = part.metadata.name

                if part.metadata.notification then
                    local ok, result = self:StringInterpolate(part.metadata.notification, context)
                    if ok then
                        headerText = result
                    end
                end

                self:NotificationsUpdateHeader(headerText)

                if countdown > 0 then
                    self.notificationsCountdown = countdown
                    self.notificationHeaderFrame.countdown:Show()
                    self.notificationFrame:SetScript("OnUpdate", updateCountdown)
                end

                local showId = self:GenerateUUID()
                self.notificationShowId = showId

                C_Timer.After(8 + countdown, function()
                    if showId == self.notificationShowId then
                        SwiftdawnRaidTools.notificationFrameFadeOut:Play()
                    end
                end)

                -- Update groups
                for _, index in ipairs(activeGroups) do
                    local assignmentCount = #part.assignments[index]

                    if not self.notificationRaidAssignmentGroups[groupIndex] then
                        self.notificationRaidAssignmentGroups[groupIndex] = createNotificationGroup(self.notificationContentFrame, assignmentCount)
                    end

                    local groupFrame = self.notificationRaidAssignmentGroups[groupIndex]

                    updateNotificationGroup(groupFrame, previousGroupFrame, part.assignments[index], part.uuid, i)

                    previousGroupFrame = groupFrame
                    groupIndex = groupIndex + 1
                end

                break
            end
        end
    end
end

function SwiftdawnRaidTools:NotificationsUpdateSpells()
    for _, groupFrame in pairs(self.notificationRaidAssignmentGroups) do
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
