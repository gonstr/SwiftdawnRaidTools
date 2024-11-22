BossEncounters = {
    isInitialized = false,
    bossInfo = {}
}

function BossEncounters:Initialize()
    if BossEncounters.isInitialized then
        return
    end

    local currTier = EJ_GetCurrentTier()

    local numTiers = EJ_GetNumTiers()

    for tierIndex = 1, numTiers do
        EJ_SelectTier(tierIndex)

        local instance_index = 1
        local instance_id = EJ_GetInstanceByIndex(instance_index, true)

        while instance_id do
            BossEncounters.isInitialized = true

            EJ_SelectInstance(instance_id)
            local instance_name, _, _, _, _, _, dungeonAreaMapID = EJ_GetInstanceInfo(instance_id)

            local ej_index = 1
            local boss, _, _, _, _, _, encounter_id = EJ_GetEncounterInfoByIndex(ej_index, instance_id)

            while boss do
                BossEncounters.bossInfo[encounter_id] = boss

                ej_index = ej_index + 1
                boss, _, _, _, _, _, encounter_id = EJ_GetEncounterInfoByIndex(ej_index, instance_id)
            end

            instance_index = instance_index + 1
            instance_id = EJ_GetInstanceByIndex(instance_index, true)
        end
    end

    EJ_SelectTier(currTier)

    -- Add bosses not in the encounter journal until discovered
    BossEncounters.bossInfo[1082] = "Sinestra"
    BossEncounters.bossInfo[1083] = "Sinestra"
    BossEncounters.bossInfo[42001] = "The Test Boss"
end

function BossEncounters:BossEncountersGetAll()
    return BossEncounters.bossInfo
end

function BossEncounters:GetNameByID(encounterID)
    return BossEncounters.bossInfo[encounterID]
end
