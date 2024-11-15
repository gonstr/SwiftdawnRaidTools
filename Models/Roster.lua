local SwiftdawnRaidTools = SwiftdawnRaidTools

---@class Roster
Roster = {}
Roster.__index = Roster

local function timestamp()
    local currentTimestamp = time()
    ---@class string
    return date("%H:%M:%S %d-%m-%Y", currentTimestamp)
end

---@return Roster
function Roster:New()
    ---@class Roster
    local obj = setmetatable({}, self)
    self.__index = self
    obj.id = SwiftdawnRaidTools:GenerateUUID()
    obj.name = nil
    obj.timestamp = timestamp()
    obj.players = {}
    obj.encounters = {}
    return obj
end

function Roster.GetName(roster)
    if roster.name then
        return roster.name
    else
        return "Roster"
    end
end

function Roster.GetTimestamp(roster)
    return roster.timestamp
end

---@param player Player
function Roster.AddPlayer(roster, player)
    roster.players[player.name] = player
end