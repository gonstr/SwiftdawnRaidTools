local SwiftdawnRaidTools = SwiftdawnRaidTools

-- Key: UUID, value = assignment group index
local activeGroups = {}

function SwiftdawnRaidTools:GroupsSetActive(uuid, groups)
    activeGroups[uuid] = groups
end

function SwiftdawnRaidTools:GroupsGetActive(uuid)
    return activeGroups[uuid]
end

function SwiftdawnRaidTools:GroupsGetAllActive()
    return activeGroups
end

function SwiftdawnRaidTools:GroupsSetAllActive(groups)
    activeGroups = groups
end

function SwiftdawnRaidTools:GroupsReset()
    activeGroups = {}
end
