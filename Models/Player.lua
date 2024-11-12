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
    obj.info = {}
    return obj
end

---@param class Class
function Player.SetClass(player, class)
    player.class = class
end

---@param spec Spec
function Player.AddSpec(player, spec)
    table.insert(player.specs, spec)
end
