local SharedMedia = LibStub("LibSharedMedia-3.0")

LogItem = {
    cause = {},
    effect = {},
    showExtra = false
}
LogItem.__index = LogItem

function LogItem:New(cause, ...)
    local obj = {}
    setmetatable(obj, LogItem)
    obj.db = SwiftdawnRaidTools.db.profile
    obj.cause = cause
    obj.causeArgs = ...
    return obj
end

function LogItem:SetEffect(trigger, context, countdown)
    self.effectTrigger = trigger
    self.context = context
    self.countdown = countdown
end

function LogItem:GetString()
    local line
    if self.cause == "SPELL_CAST_START" then
        line = self.context.source_name .. " is casting " .. self.context.spell_name
        if self.context.dest_name ~= nil then
            line = line  .. " on " .. self.effect.context.dest_name
        end
        return line
    elseif self.cause == "SPELL_CAST_SUCCESS" then
        line = self.context.source_name .. " is finished casting " .. self.context.spell_name
        if self.context.dest_name ~= nil then
            line = line  .. " on " .. self.context.dest_name
        end
        return line
    elseif self.cause == "SPELL_AURA_APPLIED" then
        line = self.context.source_name .. " has applied aura " .. self.context.spell_name
        if self.context.dest_name ~= nil then
            line = line  .. " on " .. self.context.dest_name
        end
        return line
    elseif self.cause == "RAID_BOSS_EMOTE" then
        return "Boss emotes '" .. self.causeArgs .. "'"
    else
        return self.cause .. " => " .. self.causeArgs
    end
end

function LogItem:GetExtraString()
    DevTool:AddData(self, "LogItem")
    local causeArgsString = TableToString(self.context)
    return string.format("%s: %s", self.cause, causeArgsString)
end

function LogItem:getLogFontType(db)
    return SharedMedia:Fetch("font", db.debugLog.appearance.logFontType)
end

function LogItem:CreateFrame(parentFrame, db)
    self.frame = CreateFrame("Frame", "LogLine", parentFrame)
    self.frame:SetClipsChildren(true)
    self.timestamp = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.timestamp:SetShadowOffset(1, -1)
    self.timestamp:SetShadowColor(0, 0, 0, 1)
    self.timestamp:SetJustifyH("LEFT")
    self.timestamp:SetWordWrap(false)
    self.timestamp:SetText(GetTimestamp() .. ": ")
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
    self.extraText:SetTextColor(0.7, 0.7, 0.7)
    self.extraText:SetPoint("TOPLEFT", self.timestamp, "BOTTOMLEFT", 5, -3)
    self.extraText:Hide()
    self.frame:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            self.showExtra = not self.showExtra
            self:UpdateAppearance(db)
        end
    end)
    self:UpdateAppearance(db)
end

function LogItem:UpdateAppearance(db)
    local logFontSize = db.debugLog.appearance.logFontSize
    self.frame:SetWidth(self.frame:GetParent():GetWidth() - 10)
    self.timestamp:SetFont(self:getLogFontType(db), logFontSize)
    self.timestamp:SetWidth(self.timestamp:GetStringWidth())
    self.text:SetFont(self:getLogFontType(db), logFontSize)
    self.text:SetWidth(self.frame:GetWidth() - self.timestamp:GetStringWidth() - 2)
    self.extraText:SetFont(self:getLogFontType(db), logFontSize)
    self.extraText:SetWidth(self.frame:GetWidth() - 5)
    self.extraText:SetHeight(self.extraText:GetStringHeight())
    if self.showExtra then
        self.extraText:Show()
        self.frame:SetHeight(logFontSize + 3 + self.extraText:GetHeight())
    else
        self.extraText:Hide()
        self.frame:SetHeight(logFontSize)
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