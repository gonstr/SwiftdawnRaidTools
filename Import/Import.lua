local SwiftdawnRaidTools = SwiftdawnRaidTools
local insert = table.insert

function SwiftdawnRaidTools:ImportYAML(str)
    if str == nil or string.len(str) == 0 then
        return false
    end

    local ok, result = SwiftdawnRaidTools.YAML.evalm(str)

    if not ok then
        return false, "Error in document " .. result .. ": Failed to parse YAML."
    end

    for i, part in ipairs(result) do
        if type(part) ~= "table" then
            return false, "Error in document " .. i .. ": Invalid import."
        end
    end

    for i, part in ipairs(result) do
        local ok, result = SwiftdawnRaidTools:ValidationValidateImport(part)

        if not ok then
            return false, "Error in document " .. i .. ": " .. result
        end
    end

    for _, part in ipairs(result) do
        part.uuid = SwiftdawnRaidTools:GenerateUUID()
    end

    return true, result
end

function SwiftdawnRaidTools:ImportCreateEncountersData(import)
    local result = {}

    for _, part in ipairs(import) do
        if not result[part.encounter] then
            result[part.encounter] = {}
        end

        insert(result[part.encounter], part)
    end

    local uuid = self:GenerateUUID()

    return result, uuid
end
