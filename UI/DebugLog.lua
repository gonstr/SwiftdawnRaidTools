local SwiftdawnRaidTools = SwiftdawnRaidTools

local MIN_HEIGHT = 200

function SwiftdawnRaidTools:DebugLogInit()
    local debugLogTitleFontSize = self.db.profile.options.appearance.overviewTitleFontSize
    local debugLogPlayerFontSize = self.db.profile.options.appearance.overviewPlayerFontSize
    local container = CreateFrame("Frame", "SwiftdawnRaidToolsDebugLog", UIParent, "BackdropTemplate")
    container:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    container:SetSize(400, MIN_HEIGHT)
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

    local popup = CreateFrame("Frame", "SwiftdawnRaidToolsDebugLogPopup", UIParent, "BackdropTemplate")
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

        SwiftdawnRaidTools:DebugLogUpdatePopup()

        local scale = UIParent:GetEffectiveScale()
        local x, y = GetCursorPosition()
        x, y = x / scale, y / scale

        popup:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", x, y)

        popup:Show()
    end

    local header = CreateFrame("Frame", "SwiftdawnRaidToolsDebugLogHeader", container, "BackdropTemplate")
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
        SwiftdawnRaidTools.debugLogHeader:SetBackdropColor(0, 0, 0, 1)
        SwiftdawnRaidTools.debugLogHeaderButton:SetAlpha(1)
    end)
    header:SetScript("OnLeave", function()
        SwiftdawnRaidTools.debugLogHeader:SetBackdropColor(0, 0, 0, SwiftdawnRaidTools.db.profile.options.appearance.overviewTitleBarOpacity)
        SwiftdawnRaidTools.debugLogHeaderButton:SetAlpha(SwiftdawnRaidTools.db.profile.options.appearance.overviewTitleBarOpacity)
    end)

    local headerText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    headerText:SetFont(self:AppearanceGetOverviewTitleFontType(), debugLogTitleFontSize)
    headerText:SetPoint("LEFT", header, "LEFT", 10, 0)
    headerText:SetShadowOffset(1, -1)
    headerText:SetShadowColor(0, 0, 0, 1)
    headerText:SetJustifyH("LEFT")
    headerText:SetWordWrap(false)
    headerText:SetText("Debug Log")

    local headerButton = CreateFrame("Button", nil, header)
    headerButton:SetSize(debugLogTitleFontSize, debugLogTitleFontSize)
    headerButton:SetPoint("RIGHT", header, "RIGHT", -3, 0)
    headerButton:SetNormalTexture("Gamepad_Ltr_Menu_32")
    headerButton:SetHighlightTexture("Gamepad_Ltr_Menu_32")
    headerButton:SetPushedTexture("Gamepad_Ltr_Menu_32")
    headerButton:SetAlpha(self.db.profile.options.appearance.overviewTitleBarOpacity)
    headerButton:SetScript("OnEnter", function()
        SwiftdawnRaidTools.debugLogHeader:SetBackdropColor(0, 0, 0, 1)
        SwiftdawnRaidTools.debugLogHeaderButton:SetAlpha(1)
    end)
    headerButton:SetScript("OnLeave", function()
        SwiftdawnRaidTools.debugLogHeader:SetBackdropColor(0, 0, 0, SwiftdawnRaidTools.db.profile.options.appearance.overviewTitleBarOpacity)
        SwiftdawnRaidTools.debugLogHeaderButton:SetAlpha(SwiftdawnRaidTools.db.profile.options.appearance.overviewTitleBarOpacity)
    end)

    headerButton:SetScript("OnClick", function()
        showPopup()
    end)
    headerButton:RegisterForClicks("AnyDown", "AnyUp")

    local main = CreateFrame("Frame", "SwiftdawnRaidToolsDebugLogMain", container, "BackdropTemplate")
    main:SetPoint("BOTTOMLEFT", 0, 0)
    main:SetPoint("BOTTOMRIGHT", 0, 0)

    -- Create the scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", "MyScrollFrame", main, "UIPanelScrollFrameTemplate")
    --scrollFrame:SetSize(500, MIN_HEIGHT)  -- Set the size of the scroll frame
    scrollFrame:SetPoint("TOPLEFT", main, "TOPLEFT", 0, 0)
    scrollFrame:SetPoint("TOPRIGHT", main, "TOPRIGHT", 0, 0)
    scrollFrame:SetPoint("BOTTOMLEFT", main, "BOTTOMLEFT", 0, 5)
    scrollFrame:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", 0, 5)

    local scrollBar = _G[scrollFrame:GetName() .. "ScrollBar"]
    scrollBar.scrollStep = debugLogPlayerFontSize  -- Change this value to adjust the scroll amount per tick
    -- Create a content frame to hold the text
    local contentFrame = CreateFrame("Frame", "MyContentFrame", scrollFrame)
    contentFrame:SetSize(500, MIN_HEIGHT)  -- Set the size of the content frame (height is larger for scrolling)
    contentFrame:SetPoint("TOPLEFT")
    contentFrame:SetPoint("TOPRIGHT")

    -- Set the content frame as the scroll frame's scroll child
    scrollFrame:SetScrollChild(contentFrame)

    self.debugLogFrame = container
    self.debugLogPopup = popup
    self.debugLogPopupListItems = {}
    self.debugLogHeader = header
    self.debugLogHeaderButton = headerButton
    self.debugLogHeaderText = headerText
    self.debugLogMain = main
    self.debugLogBossAbilities = {}
    self.debugLogAssignmentGroups = {}

    self.debugLogScrollFrame = scrollFrame
    self.debugLogScrollContentFrame = contentFrame

    self.debugLogLines = {}

    self:DebugLogUpdateAppearance()
end

function SwiftdawnRaidTools:DebugLogAddLine(text)
    local line = self.debugLogScrollContentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    local debugLogPlayerFontSize = self.db.profile.options.appearance.overviewPlayerFontSize
    line:SetFont(self:AppearanceGetOverviewPlayerFontType(), debugLogPlayerFontSize)
    if #self.debugLogLines == 0 then
        line:SetPoint("TOPLEFT", self.debugLogScrollContentFrame, "TOPLEFT", 10, -3)
    else
        line:SetPoint("TOPLEFT", self.debugLogLines[#self.debugLogLines], "BOTTOMLEFT", 0, -3)
    end
    line:SetShadowOffset(1, -1)
    line:SetShadowColor(0, 0, 0, 1)
    line:SetJustifyH("LEFT")
    line:SetWordWrap(false)
    line:SetText(#self.debugLogLines+1 .. ": " .. text)
    self.debugLogLines[#self.debugLogLines+1] = line

    local scrollBar = _G[self.debugLogScrollFrame:GetName() .. "ScrollBar"]
    scrollBar:SetValue(15 + #self.debugLogLines * (debugLogPlayerFontSize + 3))
end

function SwiftdawnRaidTools:DebugLogUpdateAppearance()
    local debugLogTitleFontSize = self.db.profile.options.appearance.overviewTitleFontSize
    --local debugLogHeaderFontSize = self.db.profile.options.appearance.overviewHeaderFontSize
    local debugLogPlayerFontSize = self.db.profile.options.appearance.overviewPlayerFontSize
    --local iconSize = SwiftdawnRaidTools.db.profile.options.appearance.overviewIconSize

    self.debugLogFrame:SetScale(self.db.profile.options.appearance.overviewScale)
    self.debugLogHeaderText:SetFont(self:AppearanceGetOverviewTitleFontType(), debugLogTitleFontSize)
    local headerHeight = debugLogTitleFontSize + 8
    self.debugLogHeader:SetHeight(headerHeight)

    local headerWidth = self.debugLogFrame:GetWidth()
    self.debugLogHeaderText:SetWidth(headerWidth - 10 - debugLogTitleFontSize)

    self.debugLogScrollContentFrame:SetHeight(15 + #self.debugLogLines * (debugLogPlayerFontSize + 3))
    for _, line in ipairs(self.debugLogLines) do
        line:SetWidth(headerWidth - 10)
        line:SetFont(self:AppearanceGetOverviewPlayerFontType(), debugLogPlayerFontSize)
    end
    local scrollBar = _G[self.debugLogScrollFrame:GetName() .. "ScrollBar"]
    scrollBar.scrollStep = debugLogPlayerFontSize * 2

    self.debugLogMain:SetPoint("TOPLEFT", 0, -headerHeight)
    self.debugLogMain:SetPoint("TOPRIGHT", 0, -headerHeight)
    self.debugLogHeaderButton:SetSize(debugLogTitleFontSize, debugLogTitleFontSize)
    self.debugLogHeaderButton:SetAlpha(self.db.profile.options.appearance.overviewTitleBarOpacity)

    self.debugLogHeader:SetBackdropColor(0, 0, 0, self.db.profile.options.appearance.overviewTitleBarOpacity)
    local r, g, b = self.overviewFrame:GetBackdropColor()
    self.debugLogFrame:SetBackdropColor(r, g, b, self.db.profile.options.appearance.overviewBackgroundOpacity)
end

function SwiftdawnRaidTools:DebugLogUpdate()
    --if not self.DEBUG then
    --    self.debugLog:Hide()
    --    return
    --end

    --local selectedEncounterIdFound = false
    --
    --for encounterId, _ in pairs(encounters) do
    --    if self.db.profile.overview.selectedEncounterId == encounterId then
    --        selectedEncounterIdFound = true
    --    end
    --end
    --
    --if not selectedEncounterIdFound then
    --    local encounterIndexes = {}
    --    for encounterId in pairs(self:GetEncounters()) do
    --        table.insert(encounterIndexes, encounterId)
    --    end
    --    table.sort(encounterIndexes)
    --
    --    self.db.profile.overview.selectedEncounterId = encounterIndexes[1]
    --end

    --self:OverviewUpdateHeaderText()
    --self:OverviewUpdateMain()
    --self:OverviewUpdateSpells()
    self:DebugLogUpdateLocked()
    self.debugLogFrame:Show()
end

function SwiftdawnRaidTools:DebugLogUpdateLocked()
    self.debugLogFrame:EnableMouse(not self.db.profile.debugLog.locked)
end

function SwiftdawnRaidTools:DebugLogToggleLock()
    self.db.profile.debugLog.locked = not self.db.profile.debugLog.locked
    self:DebugLogUpdateLocked()
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

function SwiftdawnRaidTools:DebugLogShowPopupListItem(index, text, setting, onClick, accExtraOffset, extraOffset)
    if not self.debugLogPopupListItems[index] then
        self.debugLogPopupListItems[index] = createPopupListItem(self.debugLogPopup)
    end
    local item = self.debugLogPopupListItems[index]
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

function SwiftdawnRaidTools:DebugLogUpdatePopup()
    if InCombatLockdown() then
        return
    end

    local index = 1

    local lockFunc = function() self:DebugLogToggleLock() end

    local lockedText = self.db.profile.debugLog.locked and "Unlock Debug Log" or "Lock Debug Log"
    self:DebugLogShowPopupListItem(index, lockedText, true, lockFunc, 0, false)

    index = index + 1

    local configurationFunc = function() InterfaceOptionsFrame_OpenToCategory("Swiftdawn Raid Tools") end
    self:DebugLogShowPopupListItem(index, "Configuration", true, configurationFunc, 0, false)

    index = index + 1

    local yOfs = self:DebugLogShowPopupListItem(index, "Close", true, nil, 0, true)

    local popupHeight = math.abs(yOfs) + 30

    -- Update popup size
    self.debugLogPopup:SetHeight(popupHeight)
end