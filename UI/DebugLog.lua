local MAX_SCROLLBACK = 500

---@class SRTDebugLog:SRTWindow
SRTDebugLog = setmetatable({
    logItems = {}
}, SRTWindow)
SRTDebugLog.__index = SRTDebugLog

---@return SRTDebugLog
function SRTDebugLog:New(height, width)
    local obj = SRTWindow.New(self, "DebugLog", height, width)
    ---@cast obj SRTDebugLog
    self.__index = self
    return obj
end

function SRTDebugLog:Initialize()
    SRTWindow.Initialize(self)
    self.headerText:SetText("Debug Log")

    -- Create the scroll frame
    local logFontSize = self:GetAppearance().logFontSize
    self.scrollFrame = CreateFrame("ScrollFrame", "SRT_"..self.name.."_ScrollFrame", self.main, "UIPanelScrollFrameTemplate")
    --scrollFrame:SetSize(500, MIN_HEIGHT)  -- Set the size of the scroll frame
    self.scrollFrame:SetPoint("TOPLEFT", self.main, "TOPLEFT", 0, 0)
    self.scrollFrame:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", 0, 0)
    self.scrollFrame:SetPoint("BOTTOMLEFT", self.main, "BOTTOMLEFT", 0, 5)
    self.scrollFrame:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", 0, 5)

    self.scrollBar = _G[self.scrollFrame:GetName() .. "ScrollBar"]
    self.scrollBar.scrollStep = logFontSize  -- Change this value to adjust the scroll amount per tick
    -- Create a content frame to hold the text
    self.scrollContentFrame = CreateFrame("Frame", "SRT_"..self.name.."_ContentFrame", self.scrollFrame)
    self.scrollContentFrame:SetSize(500, MIN_HEIGHT)  -- Set the size of the content frame (height is larger for scrolling)
    self.scrollContentFrame:SetPoint("TOPLEFT")
    self.scrollContentFrame:SetPoint("TOPRIGHT")

    -- Set the content frame as the scroll frame's scroll child
    self.scrollFrame:SetScrollChild(self.scrollContentFrame)

    self.menuButton:SetScript("OnClick", function()
        if not SRT_IsTesting() and InCombatLockdown() then
            return
        end
        self:UpdatePopupMenu()
        self.popupMenu:Show()
    end)

    self:UpdateAppearance()
end

function SRTDebugLog:ScrollToBottom()
    local logFontSize = self:GetAppearance().logFontSize
    self.scrollBar:SetValue(15 + #self.logItems * (logFontSize + 3))
end

--- Add a log statement to the debug log
---@param logItem LogItem
function SRTDebugLog:AddItem(logItem)
    logItem:CreateFrame(self.scrollContentFrame)
    -- fix connection points for new and old lines
    if #self.logItems == 0 then
        -- no other lines, so connect to top
        logItem.frame:SetPoint("TOPLEFT", self.scrollContentFrame, "TOPLEFT", 5, -3)
    else
        if #self.logItems > MAX_SCROLLBACK then
            -- too many lines; remove first line in log
            local removedItem = table.remove(self.logItems, 1)
            removedItem:DeleteFrame()
            -- connect new first line to top
            self.logItems[1].frame:SetPoint("TOPLEFT", self.scrollContentFrame, "TOPLEFT", 5, -3)
        end
        -- connect to last line in log
        logItem.frame:SetPoint("TOPLEFT", self.logItems[#self.logItems].frame, "BOTTOMLEFT", 0, -3)
    end
    -- add line to the list
    self.logItems[#self.logItems +1] = logItem
    if self:GetProfile().scrollToBottom then
        self:ScrollToBottom()
    end
end

function SRTDebugLog:UpdateAppearance()
    local logFontSize = self:GetAppearance().logFontSize
    self.scrollContentFrame:SetHeight(15 + #self.logItems * (logFontSize + 3) + 5)
    for _, item in ipairs(self.logItems) do
        item:UpdateAppearance()
    end
    self.scrollBar.scrollStep = logFontSize * 2
    SRTWindow.UpdateAppearance(self)
end

function SRTDebugLog:UpdateAutoScroll()
    if self:GetProfile().scrollToBottom then
        self:ScrollToBottom()
    end
end

function SRTDebugLog:ToggleAutoScroll()
    self:GetProfile().scrollToBottom = not self:GetProfile().scrollToBottom
    self:UpdateAutoScroll()
end

function SRTDebugLog:ClearWindow()
    for i, _ in ipairs(self.logItems) do
        self.logItems[i]:DeleteFrame()
    end
    self.logItems = {}
    self:UpdateAppearance()
end

function SRTDebugLog:UpdatePopupMenu()
    if InCombatLockdown() then
        return
    end

    self.popupMenu.Update({
        { name = "Clear Log", onClick = function() self:ClearWindow() end },
        { name = self:GetProfile().scrollToBottom and "Don't autoscroll" or "Autoscroll", onClick = function() self:ToggleAutoScroll() end },
        {},
        { name = self:GetProfile().locked and "Unlock Window" or "Lock Window", onClick = function() self:ToggleLock() end, isSetting = true },
        { name = "Close Window", onClick = function() self:CloseWindow() end, isSetting = true },
        { name = "Configuration", onClick = function() Settings.OpenToCategory("Swiftdawn Raid Tools") end, isSetting = true },
        {},
        { name = "Close", onClick = nil, isSetting = true },
    })
end