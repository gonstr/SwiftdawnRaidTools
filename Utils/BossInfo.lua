BossInfo = {
    initialized = false,
    instances = {}
}

function BossInfo.Initialize()
    if BossInfo.initialized then
        return
    end

    local currTier = EJ_GetCurrentTier()
    local numTiers = EJ_GetNumTiers()
    for tierIndex = 1, numTiers do
        EJ_SelectTier(tierIndex)
        local instance_index = 1
        while true do
            local instanceID, instanceName, instanceDescription, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, instanceLink, shouldDisplayDifficulty, mapID = EJ_GetInstanceByIndex(instance_index, true)
            if instanceID then
                EJ_SelectInstance(instanceID)
                local instanceInfo = {
                    name = instanceName,
                    description = instanceDescription,
                    encounters = {},
                    dungeonAreaMapID = dungeonAreaMapID,
                    link = instanceLink,
                    shouldDisplayDifficulty = shouldDisplayDifficulty,
                    mapID = mapID
                }
                local encounter_index = 1
                while true do
                    local encounterName, encounterDescription, journalEncounterID, rootSectionID, encounterLink, journalInstanceID, dungeonEncounterID, _ = EJ_GetEncounterInfoByIndex(encounter_index, instanceID)
                    if encounterName then
                        instanceInfo.encounters[dungeonEncounterID] = {
                            name = encounterName,
                            description = encounterDescription,
                            journalEncounterID = journalEncounterID,
                            rootSectionID = rootSectionID,
                            link = encounterLink,
                            journalInstanceID = journalInstanceID,
                            dungeonEncounterID = dungeonEncounterID
                        }
                    else
                        break
                    end
                    encounter_index = encounter_index + 1
                end
                BossInfo.instances[instanceID] = instanceInfo
            else
                break
            end
            instance_index = instance_index + 1
        end
    end

    EJ_SelectTier(currTier)
    BossInfo.initialized = true
end