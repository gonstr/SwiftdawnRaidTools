---@class SRTSpell
SRTSpell = {}
SRTSpell.__index = SRTSpell

---@return SRTSpell
---@param name string
---@param cooldown number
---@param duration number
---@param info table?
function SRTSpell:New(id, name, cooldown, duration, info)
    ---@class SRTSpell
    local obj = setmetatable({}, self)
    self.__index = self
    obj.id = id
    obj.name = name
    obj.cooldown = cooldown
    obj.duration = duration
    obj.info = info
    return obj
end