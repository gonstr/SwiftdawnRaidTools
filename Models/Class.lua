---@class Class
Class = {}
Class.__index = Class

---@return Class
---@param name string
function Class:New(name)
    ---@class Class
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    return obj
end