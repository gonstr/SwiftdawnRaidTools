local SharedMedia = LibStub("LibSharedMedia-3.0")

---@class LogItem
LogItem = {
    showExtra = false
}
LogItem.__index = LogItem

---@return LogItem
function LogItem:New(data)
    ---@class LogItem
    local obj = {}
    setmetatable(obj, LogItem)
    obj.triggerType = data.triggerType
    obj.assignmentId = data.uuid
    obj.activeGroups = data.activeGroups
    obj.countdown = data.countdown
    obj.delay = data.delay
    obj.context = data.context
    return obj
end

function LogItem:GetString()
    local line

    if self.triggerType == "ENCOUNTER_START" then
        line = "Encounter with " .. self.context.encounterName .. " has started"
        return line
    elseif self.triggerType == "SPELL_CAST" then
        line = self.context.source_name .. " is casting " .. self.context.spell_name
        if self.context.dest_name ~= nil then
            line = line  .. " on " .. self.context.dest_name
        end
        return line
    elseif self.triggerType == "SPELL_AURA" then
        line = self.context.source_name .. " has applied aura " .. self.context.spell_name
        if self.context.dest_name ~= nil then
            line = line  .. " on " .. self.context.dest_name
        end
        return line
    elseif self.triggerType == "RAID_BOSS_EMOTE" then
        return "Boss emotes '" .. self.context.text .. "'"
    else
        return self.triggerType
    end
end

function LogItem:GetExtraString()
    return string.format(
            "type: %s\nassignment: %s\nactiveGroups: %s\ncountdown: %d\ndelay: %d\ncontext: %s",
            tostring(self.triggerType), tostring(self.assignmentId), Utils:TableToString(self.activeGroups), tostring(self.countdown), tostring(self.delay), SwiftdawnRaidTools.Utils:TableToString(self.context))
end

function LogItem:getLogFontType()
    return SharedMedia:Fetch("font", SRT_Profile().debuglog.appearance.logFontType)
end

function LogItem:CreateFrame(parentFrame)
    self.frame = CreateFrame("Frame", "LogLine", parentFrame)
    self.frame:SetClipsChildren(true)
    self.timestamp = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.timestamp:SetShadowOffset(1, -1)
    self.timestamp:SetShadowColor(0, 0, 0, 1)
    self.timestamp:SetJustifyH("LEFT")
    self.timestamp:SetWordWrap(false)
    self.timestamp:SetText(Utils:Timestamp(true) .. ": ")
    self.timestamp:SetTextColor(1, 1, 1)
    self.timestamp:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
    self.text = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.text:SetShadowOffset(1, -1)
    self.text:SetShadowColor(0, 0, 0, 1)
    self.text:SetJustifyH("LEFT")
    self.text:SetWordWrap(false)
    self.text:SetText(self:GetString())
    self.text:SetPoint("LEFT", self.timestamp, "RIGHT", 0, 0)
    self.extraText = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.extraText:SetShadowOffset(1, -1)
    self.extraText:SetShadowColor(0, 0, 0, 1)
    self.extraText:SetJustifyH("LEFT")
    self.extraText:SetWordWrap(true)
    self.extraText:SetText(self:GetExtraString())
    self.extraText:SetTextColor(0.80, 0.80, 0.80)
    self.extraText:SetPoint("TOPLEFT", self.timestamp, "BOTTOMLEFT", 5, -3)
    self.extraText:Hide()
    self.frame:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            self.showExtra = not self.showExtra
            self:UpdateAppearance()
        end
    end)
    self:UpdateAppearance()
end

function LogItem:UpdateAppearance()
    local logFontSize = SRT_Profile().debuglog.appearance.logFontSize
    self.frame:SetWidth(self.frame:GetParent():GetWidth() - 10)
    self.timestamp:SetFont(self:getLogFontType(), logFontSize)
    self.timestamp:SetWidth(self.timestamp:GetStringWidth())
    self.text:SetFont(self:getLogFontType(), logFontSize)
    self.text:SetWidth(self.frame:GetWidth() - self.timestamp:GetStringWidth() - 2)
    self.extraText:SetFont(self:getLogFontType(), logFontSize)
    self.extraText:SetWidth(self.frame:GetWidth() - 5)
    self.extraText:SetHeight(self.extraText:GetStringHeight())
    if self.showExtra then
        self.extraText:Show()
        self.frame:SetHeight(logFontSize + 3 + self.extraText:GetHeight())
    else
        self.extraText:Hide()
        self.frame:SetHeight(logFontSize + 3)
    end
end

function LogItem:DeleteFrame()
    self.frame:Hide()
    self.frame:ClearAllPoints()
    self.frame:SetScript("OnMouseDown", nil)
    self.frame = nil
    self.timestamp:Hide()
    self.timestamp:ClearAllPoints()
    self.timestamp = nil
    self.text:Hide()
    self.text:ClearAllPoints()
    self.text = nil
    self.extraText:Hide()
    self.extraText:ClearAllPoints()
    self.extraText = nil
end

return LogItem