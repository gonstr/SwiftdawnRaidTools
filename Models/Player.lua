---@class Player
Player = {}
Player.__index = Player

---@return Player
---@param name string
---@param class? Class
---@param spec? Spec
function Player:New(name, class, spec)
    ---@class Player
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.class = class
    obj.specs = {
        spec
    }
    return obj
end

function Player:SetClass(class)
    self.class = class
end

function Player:AddSpec(spec)
    table.insert(self.specs, spec)
end
