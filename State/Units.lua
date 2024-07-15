local SwiftdawnRaidTools = SwiftdawnRaidTools

local deadCache = {}

function SwiftdawnRaidTools:UnitsSetDead(destGUID)
    deadCache[destGUID] = true
end

function SwiftdawnRaidTools:UnitsIsDead(destGUID)
    if deadCache[destGUID] then
        return true
    end

    return false
end

function SwiftdawnRaidTools:UnitsClearDead(destGUID)
    deadCache[destGUID] = nil
end

function SwiftdawnRaidTools:UnitsResetDeadCache()
    deadCache = {}
end
