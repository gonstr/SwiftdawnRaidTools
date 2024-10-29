---@class Class
Class = {}
Class.__index = Class

---@return Class
---@param name string
---@param fileName string
function Class:New(name, fileName)
    ---@class Class
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.fileName = fileName
    return obj
end