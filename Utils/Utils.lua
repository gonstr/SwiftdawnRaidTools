local SwiftdawnRaidTools = SwiftdawnRaidTools

-- Make sure guild roster data is loaded
GuildRoster()

function SRT_Global()
    return SwiftdawnRaidTools.db.global
end

function SRT_Profile()
    return SwiftdawnRaidTools.db.profile
end

function SRT_IsTesting()
    return SwiftdawnRaidTools.TEST
end

Utils = {}

-- Function to get the name of a guild rank by index
function Utils:GetGuildRankNameByIndex(rankIndex)
    if rankIndex < 0 or rankIndex >= GuildControlGetNumRanks() then
        Log.info("Invalid rank index")
        return nil
    end
    return GuildControlGetRankName(rankIndex)
end

function Utils:IsFriendlyRaidMemberOrPlayer(guid)
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

function Utils:IsPlayerRaidLeader()
    return IsInRaid() and UnitIsGroupLeader("player")
end

function Utils:GetRaidAssignmentPart(uuid)
    local encounters = SRTData.GetActiveEncounters()
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

function Utils:IsPlayerInAssignments(assignments)
    for _, group in ipairs(assignments) do
        for _, assignment in ipairs(group) do
            if assignment.player == UnitName("player") then
                return true
            end
        end
    end
    return false
end

function Utils:IsPlayerInActiveGroup(part)
    local activeGroups = Groups:GetActive(part.uuid)
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

function Utils:Timestamp(withMilliseconds)
    local currentTimestamp = time()
    if withMilliseconds then
        local seconds = math.floor(currentTimestamp)
        local milliseconds = math.floor((currentTimestamp - seconds) * 1000)
        ---@class string
        return string.format("%s.%03d", date("%H:%M:%S"), milliseconds)
    else
        ---@class string
        return date("%d-%m-%Y %H:%M:%S", currentTimestamp)
    end
end

function Utils:GetWeirdScale()
    -- WEIRD FUNKYNESS!
    local uiScale = UIParent:GetEffectiveScale()
    local weirdScale = ((1 - uiScale) / 2) + uiScale
    local renderScale = tonumber(GetCVar("renderScale"))
    return weirdScale * renderScale
end

function Utils:OrderedPairs(tbl)
    local __genOrderedIndex = function( t )
        local orderedIndex = {}
        for key in pairs(t) do
            if string.sub(key, 1, 1) ~= "_"  then
                table.insert(orderedIndex, key)
            end
        end
        table.sort( orderedIndex )
        return orderedIndex
    end

    local orderedNext = function(t, state)
        -- Equivalent of the next function, but returns the keys in the alphabetic
        -- order. We use a temporary ordered key table that is stored in the
        -- table being iterated.
        local key = nil
        --Log.info("orderedNext: state = "..tostring(state) )
        if state == nil then
            -- the first time, generate the index
            t.__orderedIndex = __genOrderedIndex( t )
            key = t.__orderedIndex[1]
        else
            -- fetch the next value
            for i = 1, #t.__orderedIndex do
                if t.__orderedIndex[i] == state then
                    key = t.__orderedIndex[i+1]
                end
            end
        end
        if key then
            return key, t[key]
        end
        -- no more value to return, cleanup
        t.__orderedIndex = nil
        return
    end

    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, tbl, nil
end

function Utils:TableToString(tbl, indent, seen)
    if type(tbl) == "string" then
        return tbl
    elseif tbl == nil then
        return "nil"
    end
    indent = indent or 0
    seen = seen or {}
    local result = "{\n"
    local indentStr = string.rep("  ", indent)
    -- Detect cyclic references
    if seen[tbl] then
        return indentStr .. "[Cyclic Reference]"
    end
    seen[tbl] = true
    for k, v in pairs(tbl) do
        result = result .. indentStr .. "  [" .. tostring(k) .. "] = "

        if type(v) == "table" then
            result = result .. Utils:TableToString(v, indent + 1, seen) .. ",\n"
        elseif type(v) == "string" then
            result = result .. '"' .. v .. '",\n'
        elseif type(v) == "function" or type(v) == "userdata" then
            result = result .. "[Unsupported Type: " .. type(v) .. "],\n"
        else
            result = result .. tostring(v) .. ",\n"
        end
    end
    result = result .. indentStr .. "}"
    return result
end

function Utils:ShallowClone(table)
    if not table then return table end
    local copy = {}
    for k, v in pairs(table) do
        copy[k] = v
    end
    return copy
end

function Utils:DeepClone(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Utils:DeepClone(orig_key)] = Utils:DeepClone(orig_value)
        end
        setmetatable(copy, Utils:DeepClone(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function Utils:StringEllipsis(str, len)
    if string.len(str) > len + 3 then
        return str:sub(1, len) .. "..."
    end
    return str
end

function Utils:StringJoin(strings, delimiter)
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

-- Returns a boolean indicating if the string was fully intepolated and the interpolated string
-- Example use:
-- StringInterpolate("%(key)s is %(val).2f%" , { key = "concentration", val = 56.2795 }) -> "Concentration is 56.27%"
function Utils:StringInterpolate(str, ctx)
    local stringFullyInterpolated = true
    local result = str:gsub('%%%(([%a%w_]*)%)([-0-9%.]*[cdeEfgGiouxXsq])', function(k, fmt)
        if not ctx[k] then
            stringFullyInterpolated = false
        end

        return ctx[k] and ("%" .. fmt):format(ctx[k]) or '%(' .. k .. ')' .. fmt
    end)
    return stringFullyInterpolated, result
end

function Utils:CreateFadeOut(frame, onFinished)
    local fadeOutGroup = frame:CreateAnimationGroup()
    local fadeOut = fadeOutGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.3)
    fadeOut:SetSmoothing("OUT")
    fadeOutGroup:SetScript("OnFinished", function(self)
        if onFinished then onFinished() end
        self:GetParent():Hide()
    end)
    return fadeOutGroup
end

function Utils:GenerateUUID()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 15) or (math.random(8, 11))
        return string.format('%x', v)
    end)
end

function Utils:IsArray(table)
    local i = 0
    for _ in pairs(table) do
        i = i + 1
        if table[i] == nil then return false end
    end
    return true
end

local SharedMedia = LibStub("LibSharedMedia-3.0")

function SwiftdawnRaidTools:AppearancePopupFontType()
    return SharedMedia:Fetch("font", "Friz Quadrata TT")
end

function SwiftdawnRaidTools:AppearanceGetOverviewTitleFontType()
    return SharedMedia:Fetch("font", self.db.profile.overview.appearance.titleFontType)
end

function SwiftdawnRaidTools:AppearanceGetOverviewBossAbilityFontType()
    return SharedMedia:Fetch("font", self.db.profile.overview.appearance.headerFontType)
end

function SwiftdawnRaidTools:AppearanceGetOverviewPlayerFontType()
    return SharedMedia:Fetch("font", self.db.profile.overview.appearance.playerFontType)
end

function SwiftdawnRaidTools:AppearanceGetNotificationsBossAbilityFontType()
    return SharedMedia:Fetch("font", self.db.profile.notifications.appearance.headerFontType)
end

function SwiftdawnRaidTools:AppearanceGetNotificationsBossAbilityFontSize()
    return self.db.profile.notifications.appearance.headerFontSize
end

function SwiftdawnRaidTools:AppearanceGetNotificationsCountdownFontType()
    return SharedMedia:Fetch("font", self.db.profile.notifications.appearance.countdownFontType)
end

function SwiftdawnRaidTools:AppearanceGetNotificationsCountdownFontSize()
    return self.db.profile.notifications.appearance.countdownFontSize
end

function SwiftdawnRaidTools:AppearanceGetNotificationsPlayerFontType()
    return SharedMedia:Fetch("font", self.db.profile.notifications.appearance.playerFontType)
end

function SwiftdawnRaidTools:AppearanceGetNotificationsPlayerFontSize()
    return self.db.profile.notifications.appearance.playerFontSize
end

function SwiftdawnRaidTools:AppearanceGetNotificationsPlayerIconSize()
    return self.db.profile.notifications.appearance.iconSize
end

function SwiftdawnRaidTools:AppearanceGetNotificationsHeaderHeight()
    local bossAbilityFontSize = SwiftdawnRaidTools:AppearanceGetNotificationsBossAbilityFontSize()
    local countdownFontSize = SwiftdawnRaidTools:AppearanceGetNotificationsCountdownFontSize()
    local padding = 7
    return (bossAbilityFontSize > countdownFontSize and bossAbilityFontSize or countdownFontSize) + padding
end

function SwiftdawnRaidTools:AppearanceGetNotificationsAssignmentHeight()
    local playerFontSize = SwiftdawnRaidTools:AppearanceGetNotificationsPlayerFontSize()
    local iconSize = SwiftdawnRaidTools:AppearanceGetNotificationsPlayerIconSize()
    return playerFontSize > iconSize and playerFontSize or iconSize
end

function SwiftdawnRaidTools:AppearanceGetNotificationsContentHeight()
    local assignmentHeight = SwiftdawnRaidTools:AppearanceGetNotificationsAssignmentHeight()
    local padding = 17
    return assignmentHeight + padding
end