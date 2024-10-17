LogItem = {
    cause = {},
    effect = {},
}

function LogItem:New(cause, ...)
    o = {}
    setmetatable(o, self)
    self.__index = self
    o.cause = cause
    o.causeArgs = ...
    return o
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

return LogItem