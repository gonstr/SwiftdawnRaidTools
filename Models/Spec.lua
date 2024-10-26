---@class Spec
Spec = {}
Spec.__index = Spec

---@return Spec
---@param name string
---@param class Class
function Spec:New(name, class)
    ---@class Spec
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.class = class
    return obj
end