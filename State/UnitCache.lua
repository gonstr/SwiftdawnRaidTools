local SwiftdawnRaidTools = SwiftdawnRaidTools

UnitCache = {
    dead = {}
}

local deadCache = {}

function UnitCache:SetDead(destGUID)
    UnitCache.dead[destGUID] = true
end

function UnitCache:IsDead(destGUID)
    if UnitCache.dead[destGUID] then
        return true
    end

    return false
end

function UnitCache:SetAlive(destGUID)
    UnitCache.dead[destGUID] = nil
end

function UnitCache:ResetDeadCache()
    UnitCache.dead = {}
end
