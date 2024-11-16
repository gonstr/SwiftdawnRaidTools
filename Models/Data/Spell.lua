---@class Spell
Spell = {}
Spell.__index = Spell

---@return Spell
---@param name string
---@param cooldown number
---@param duration number
---@param info table?
function Spell:New(id, name, cooldown, duration, info)
    ---@class Spell
    local obj = setmetatable({}, self)
    self.__index = self
    obj.id = id
    obj.name = name
    obj.cooldown = cooldown
    obj.duration = duration
    obj.info = info
    return obj
end