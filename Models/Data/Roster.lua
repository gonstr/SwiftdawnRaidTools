---@class Roster
Roster = {}
Roster.__index = Roster

---@return Roster
function Roster:New()
    ---@class Roster
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = "Roster"
    obj.lastUpdated = time()
    obj.players = {}
    obj.encounters = {}
    return obj
end

function Roster.MarkUpdated(roster)
    roster.lastUpdated = time()
    Log.debug("Roster "..roster.id.." updated at "..Roster.GetLastUpdatedTimestamp(roster))
end

function Roster.GetLastUpdated(roster)
    return roster.lastUpdated or 0
end

function Roster.GetLastUpdatedTimestamp(roster)
    return date("%d-%m-%Y %H:%M:%S", Roster.GetLastUpdated(roster))
end

---@param player Player
function Roster.AddPlayer(roster, player)
    roster.players[player.name] = player
end

function Roster.Parse(raw, name, lastUpdated)
    local roster = Roster:New()
    roster.name = name or "Roster"
    roster.encounters = raw
    roster.lastUpdated = lastUpdated or time()
    for _, encounter in pairs(roster.encounters) do
        for _, ability in pairs(encounter) do
            for _, group in pairs(ability.assignments) do
                for _, assignment in pairs(group) do
                    Roster.AddPlayer(roster, Player:New(assignment.player, SRTData.GetClassBySpellID(assignment.spell_id)))
                end
            end
        end
    end
    return roster
end