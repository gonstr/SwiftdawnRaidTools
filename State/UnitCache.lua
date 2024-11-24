UnitCache = {
    dead = {}
}

function UnitCache:SetDead(unitGUID)
    UnitCache.dead[unitGUID] = true
end

function UnitCache:IsDead(unitGUID)
    if UnitCache.dead[unitGUID] then
        return true
    end

    return false
end

function UnitCache:SetAlive(unitGUID)
    UnitCache.dead[unitGUID] = nil
end

function UnitCache:ResetDeadCache()
    UnitCache.dead = {}
end
