local insert = table.insert

local SwiftdawnRaidTools = SwiftdawnRaidTools

local SONAR_SOUND_FILE = "Interface\\AddOns\\SwiftdawnRaidTools\\Media\\PowerAuras_Sounds_Sonar.mp3"

function SwiftdawnRaidTools:NotificationsInit()
    local container = CreateFrame("Frame", "SwiftdawnRaidToolsNotification", UIParent, "BackdropTemplate")
    container:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
    container:SetSize(250, 50)
    container:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })
    container:SetBackdropColor(0, 0, 0, 0)
    container:SetMovable(true)
    container:SetUserPlaced(true)
    container:SetClampedToScreen(true)
    container:RegisterForDrag("LeftButton")
    container:SetScript("OnDragStart", function(self) self:StartMoving() end)
    container:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    container:SetScale(self.db.profile.options.appearance.notificationsScale)

    container.frameLockText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    container.frameLockText:SetFont(self:AppearanceGetFont(), 14)
    container.frameLockText:SetTextColor(1, 1, 1, 0.4)
    container.frameLockText:SetPoint("CENTER", 0, 0)
    container.frameLockText:SetText("SRT Notifications Anchor")
    container.frameLockText:Hide()

    local content = CreateFrame("Frame", nil, container, "BackdropTemplate")
    content:SetBackdrop({
        bgFile = "Interface\\Cooldown\\LoC-ShadowBG"
    })
    content:SetBackdropColor(0, 0, 0, self.db.profile.options.appearance.overviewBackgroundOpacity)
    content:SetAllPoints()

    content.header = CreateFrame("Frame", nil, content)
    content.header:SetHeight(20)

    content.header:SetPoint("TOPLEFT", 20, 0)
    content.header:SetPoint("TOPRIGHT", -20, 0)

    content.header.text = content.header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    content.header.text:SetFont(self:AppearanceGetFont(), 10)
    content.header.text:SetTextColor(1, 1, 1, 1)
    content.header.text:SetPoint("BOTTOMLEFT", 10, 5)

    content.header.countdown = content.header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    content.header.countdown:SetFont(self:AppearanceGetFont(), 10)
    content.header.countdown:SetTextColor(1, 1, 1, 1)
    content.header.countdown:SetPoint("BOTTOMRIGHT", -10, 5)
    content.header.countdown:Hide()

    content:Hide()

    local extraInfo = CreateFrame("Frame", nil, content, "BackdropTemplate")
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
        SwiftdawnRaidTools.notificationContentFrame:Hide()
    end)

    self.notificationShowId = ""

    self.notificationRaidAssignmentGroups = {}
    self.notificationsCountdown = 0

    self.notificationFrame = container
    self.notificationContentFrame = content
    self.notificationExtraInfoFrame = extraInfo
end

function SwiftdawnRaidTools:NotificationsUpdateAppearance()
    self.notificationFrame:SetScale(self.db.profile.options.appearance.notificationsScale)

    local r, g, b = self.notificationContentFrame:GetBackdropColor()
    self.notificationContentFrame:SetBackdropColor(r, g, b, self.db.profile.options.appearance.notificationsBackgroundOpacity)

    self.notificationFrame.frameLockText:SetFont(self:AppearanceGetFont(), 14)
    self.notificationContentFrame.header.text:SetFont(self:AppearanceGetFont(), 10)
    self.notificationContentFrame.header.countdown:SetFont(self:AppearanceGetFont(), 10)

    for _, group in pairs(self.notificationRaidAssignmentGroups) do
        for _, frame in pairs(group.assignments) do
            frame.text:SetFont(self:AppearanceGetFont(), 10)
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
        self.notificationContentFrame:Hide()
    end
end

function SwiftdawnRaidTools:NotificationsIsFrameLocked()
    return not self.notificationFrame:IsMouseEnabled()
end

function SwiftdawnRaidTools:NotificationsUpdateHeader(text)
    self.notificationContentFrame.header.text:SetText(self:StringEllipsis(text, 32))
end

local function createNotificationGroup(mainFrame, prevFrame)
    local frame = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    frame:SetHeight(30)

    frame.assignments = {}

    return frame
end

local function createNotificationGroupAssignment(parentFrame)
    local frame = CreateFrame("Frame", nil, parentFrame)

    frame.iconFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.iconFrame:SetSize(16, 16)
    frame.iconFrame:SetPoint("BOTTOMLEFT", 10, 6)

    frame.cooldownFrame = CreateFrame("Cooldown", nil, frame.iconFrame, "CooldownFrameTemplate")
    frame.cooldownFrame:SetAllPoints()

    frame.iconFrame.cooldown = frame.cooldownFrame

    frame.icon = frame.iconFrame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints()
    frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.text:SetFont(SwiftdawnRaidTools:AppearanceGetFont(), 12)
    frame.text:SetTextColor(1, 1, 1, 1)
    frame.text:SetPoint("BOTTOMLEFT", 32, 8)

    return frame
end

local function updateNotificationGroupAssignment(frame, assignment, index, total)
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

local function updateNotificationGroup(frame, prevFrame, group, uuid, index)
    frame:Show()

    frame.uuid = uuid
    frame.index = index

    frame:ClearAllPoints()
    
    frame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, 0)
    frame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0, 0)

    for _, cd in pairs(frame.assignments) do
        cd:Hide()
    end
    
    for i, assignment in ipairs(group) do
        if not frame.assignments[i] then
            frame.assignments[i] = createNotificationGroupAssignment(frame)
        end

        updateNotificationGroupAssignment(frame.assignments[i], assignment, i, #group)
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

local function updateCountdown(_, elapsed)
    SwiftdawnRaidTools.notificationsCountdown = SwiftdawnRaidTools.notificationsCountdown - elapsed

    if SwiftdawnRaidTools.notificationsCountdown > 0 then
        SwiftdawnRaidTools.notificationContentFrame.header.countdown:SetText(string.format("%.1fs", SwiftdawnRaidTools.notificationsCountdown))
    else
        SwiftdawnRaidTools.notificationContentFrame.header.countdown:SetText("0")
        SwiftdawnRaidTools.notificationContentFrame:SetScript("OnUpdate", nil)
        SwiftdawnRaidTools.notificationContentFrame.header.countdown:Hide()
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
        local prevFrame = self.notificationContentFrame.header
        for _, part in pairs(encounter) do
            if part.type == "RAID_ASSIGNMENTS" and part.uuid == uuid then
                local activeGroups = self:GroupsGetActive(uuid)

                if not activeGroups or #activeGroups == 0 then
                    return
                end
                
                self:NotificationsToggleFrameLock(true)
    
                self.notificationFrameFadeOut:Stop()
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
                    self.notificationContentFrame.header.countdown:Show()
                    self.notificationContentFrame:SetScript("OnUpdate", updateCountdown)
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
                    if not self.notificationRaidAssignmentGroups[groupIndex] then
                        self.notificationRaidAssignmentGroups[groupIndex] = createNotificationGroup(self.notificationContentFrame)
                    end

                    local frame = self.notificationRaidAssignmentGroups[groupIndex]

                    updateNotificationGroup(frame, prevFrame, part.assignments[index], part.uuid, i)

                    prevFrame = frame
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
