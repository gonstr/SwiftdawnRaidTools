---@class Roster
Roster = {}
Roster.__index = Roster

local function uuid_v4()
    local random = math.random
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    
    -- Replace 'x' and 'y' in the template with random hex digits.
    local uuid = template:gsub('[xy]', function (c)
        local v = (c == 'x') and random(0, 15) or random(8, 11)
        return string.format('%x', v)
    end)
    
    return uuid
end

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
    obj.id = uuid_v4()
    obj.name = nil
    obj.timestamp = timestamp()
    obj.players = {}
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