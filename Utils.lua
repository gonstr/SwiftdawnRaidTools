local SwiftdawnRaidTools = SwiftdawnRaidTools

local random = math.random

local SharedMedia = LibStub("LibSharedMedia-3.0")

function SwiftdawnRaidTools:GenerateUUID()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'

    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 15) or (random(8, 11))
        return string.format('%x', v)
    end)
end

function SwiftdawnRaidTools:IsArray(table)
    local i = 0

    for _ in pairs(table) do
        i = i + 1
        if table[i] == nil then return false end
    end

    return true
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

function SwiftdawnRaidTools:ShallowClone(table)
    if not table then return nil end

    local copy = {}

    for k, v in pairs(table) do
        copy[k] = v
    end
    
    return copy
end

function SwiftdawnRaidTools:DeepClone(orig)
    local orig_type = type(orig)
    local copy

    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[self:DeepClone(orig_key)] = self:DeepClone(orig_value)
        end
        setmetatable(copy, self:DeepClone(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
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

-- StringInterpolate("%(key)s is %(val).2f%" , { key = "concentration", val = 56.2795 }) -> "Concentration is 56.27%"
function SwiftdawnRaidTools:StringInterpolate(str, tab)
    return (str:gsub('%%%((%a%w*)%)([-0-9%.]*[cdeEfgGiouxXsq])', function(k, fmt) return tab[k] and ("%"..fmt):format(tab[k]) or '%('..k..')'..fmt end))
end

function SwiftdawnRaidTools:IsPlayerRaidLeader()
    return IsInRaid() and UnitIsGroupLeader("player")
end

function SwiftdawnRaidTools:GetRaidAssignmentPart(uuid)
    local encounters = self:GetEncounters()

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
    for _, group in ipairs(assignments) do
        for _, assignment in ipairs(group) do
            if assignment.player == UnitName("player") then
                return true
            end
        end
    end

    return false
end

function SwiftdawnRaidTools:IsPlayerInActiveGroup(part)
    local activeGroups = self:GroupsGetActive(part.uuid)

    if activeGroups then
        for _, groupIndex in ipairs(activeGroups) do
            local group = part.assignments[groupIndex]
            if group then
                for _, assignment in ipairs(group) do
                    if assignment.player == UnitName("player") then
                        return true
                    end
                end
            end
        end
    end

    return false
end

function SwiftdawnRaidTools:AppearanceGetFont()
    return SharedMedia:Fetch("font", self.db.profile.options.appearance.font)
end
