local SwiftdawnRaidTools = SwiftdawnRaidTools

--- key = "unitId:spellId", Value = cast timestamp
local spellCastCache = {}

function SwiftdawnRaidTools:SpellsResetCache()
    spellCastCache = {}
end

function SwiftdawnRaidTools:SpellsIsSpellReady(unit, spellId, timestamp)
    if not self.TEST then
        if UnitIsDeadOrGhost(unit) then
            return false
        end

        if not UnitIsPlayer(unit) and not UnitInRaid(unit) then
            return false
        end
    end

    timestamp = timestamp or GetTime()

    local key = unit .. ":" .. spellId

    local cachedCastTimestamp = spellCastCache[key]

    if not cachedCastTimestamp then
        return true
    end

    if timestamp < cachedCastTimestamp + SRTData.GetSpellByID(spellId).cooldown then
        return false
    end

    return true
end

function SwiftdawnRaidTools:SpellsIsSpellActive(unit, spellId, timestamp)
    if not self.TEST then
        if UnitIsDeadOrGhost(unit) then
            return false
        end

        if not UnitIsPlayer(unit) and not UnitInRaid(unit) then
            return false
        end
    end

    local timestamp = timestamp or GetTime()

    local key = unit .. ":" .. spellId

    local cachedCastTimestamp = spellCastCache[key]

    if not cachedCastTimestamp then
        return false
    end

    if timestamp < cachedCastTimestamp + SRTData.GetSpellByID(spellId).duration then
        return true
    end

    return false
end

function SwiftdawnRaidTools:SpellsGetCastTimestamp(unit, spellId)
    local key = unit .. ":" .. spellId

    return spellCastCache[key]
end

function SwiftdawnRaidTools:SpellsCacheCast(unit, spellId, updateFunc)
    if not self.TEST then
        if not UnitIsPlayer(unit) and not UnitInRaid(unit) then
            return
        end
    end

    local spell = SRTData.GetSpellByID(spellId)
    if spell then
        local key = unit .. ":" .. spellId

        spellCastCache[key] = GetTime()

        updateFunc()

        if spell.duration > 5 then
            C_Timer.After(spell.duration - 5, updateFunc)
        end

        C_Timer.After(spell.duration, updateFunc)
        C_Timer.After(spell.cooldown, updateFunc)
    end
end