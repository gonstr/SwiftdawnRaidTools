local SwiftdawnRaidTools = SwiftdawnRaidTools

local random = math.random

function SwiftdawnRaidTools:GenerateUUID()
    local chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    local base = #chars
    local id = ''

    for i = 1, 8 do
        local rand = math.random(base)
        id = id .. chars:sub(rand, rand)
    end
        
    return id
end

local fallbackColor = { r = 0, g = 0, b = 0 }

function SwiftdawnRaidTools:GetSpellColor(spellId)
    local spell = self:SpellsGetSpell(spellId)

    if not spell then
        return fallbackColor
    end

    return self:GetClassColor(spell.class)
end

function SwiftdawnRaidTools:GetClassColor(class)
    local color = RAID_CLASS_COLORS[class]

    if not color then
        return fallbackColor
    end

    return color
end

function SwiftdawnRaidTools:IsFriendlyRaidMemberOrPlayer(guid)
    if UnitGUID("player") == guid then
        return true
    end

    for i = 1, GetNumGroupMembers() do
        local raidUnit = "raid" .. i

        if UnitGUID(raidUnit) == guid then
            return true
        end
    end

    return false
end

function SwiftdawnRaidTools:CreateFadeOut(frame, onFinished)
    local fadeOutGroup = frame:CreateAnimationGroup()

    local fadeOut = fadeOutGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.1)
    fadeOut:SetSmoothing("OUT")

    fadeOutGroup:SetScript("OnFinished", function(self)
        if onFinished then onFinished() end
        self:GetParent():Hide()
    end)

    return fadeOutGroup
end

function SwiftdawnRaidTools:ShallowCopy(table)
    if not table then return nil end

    local copy = {}

    for k, v in pairs(table) do
        copy[k] = v
    end
    
    return copy
end

function SwiftdawnRaidTools:StringEllipsis(str, len)
    if string.len(str) > len + 3 then
        return str:sub(1, len) .. "..."
    end

    return str
end

function SwiftdawnRaidTools:StringJoin(strings, delimiter)
    delimiter = delimiter or ", "

    local result = ""

    for i, str in ipairs(strings) do
        result = result .. str

        if i < #strings then
            result = result .. delimiter
        end
    end

    return result
end

function SwiftdawnRaidTools:IsPlayerRaidLeader()
    return IsInRaid() and UnitIsGroupLeader("player")
end

function SwiftdawnRaidTools:GetRaidAssignmentPart(uuid)
    local encounters = self.db.profile.data.encounters

    if encounters then
        for _, encounter in pairs(encounters) do
            for _, part in pairs(encounter) do
                if part.uuid == uuid then
                    return part
                end
            end
        end
    end
end

function SwiftdawnRaidTools:IsPlayerInAssignments(assignments)
    local inAssignments = false
    
    for _, group in ipairs(assignments) do
        for _, assignment in ipairs(group) do
            if assignment.player == UnitName("player") then
                inAssignments = true
                break
            end
        end
    end

    return inAssignments
end

function SwiftdawnRaidTools:IsPlayerInActiveGroup(part)
    local inActiveGroup = false

    local encounters = self.db.profile.data.encounters

    local activeGroups = self:GroupsGetActive(uuid)

    if activeGroups then
        for _, groupIndex in ipairs(activeGroups) do
            local group = part.assignments[groupIndex]
            if group then
                for _, assignment in ipairs(group) do
                    if assignment.player == UnitName("player") then
                        inActiveGroup = true
                        break
                    end
                end
            end

            if inActiveGroup then break end
        end
    end

    return inActiveGroup
end

function isPlayerInAssignments(encounter, activeGroups, uuid)
    local result = false

    if encounter then            
        for _, part in pairs(encounter) do
            if part.uuid == uuid then
                if activeGroups then
                    for _, groupIndex in ipairs(activeGroups) do
                        local group = part.assignments[groupIndex]
                        if group then
                            for _, assignment in ipairs(group) do
                                if assignment.player == UnitName("player") then
                                    result = true
                                    break
                                end
                            end
                        end

                        if result then break end
                    end
                end
            end

            if result then break end
        end
    end

    return result
end
