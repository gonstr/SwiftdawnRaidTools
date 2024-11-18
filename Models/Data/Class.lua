---@class Class
Class = {}
Class.__index = Class

---@return Class
---@param name string
---@param fileName string
---@param spells table
function Class:New(name, fileName, spells)
    ---@class Class
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.fileName = fileName
    obj.spells = spells
    return obj
end

function Class:GetColor()
    return RAID_CLASS_COLORS[self.fileName]
end