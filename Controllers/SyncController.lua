local SwiftdawnRaidTools = SwiftdawnRaidTools

-- seconds
local SYNC_WAIT_TIME = 60

SyncController = {
    lastSyncTime = 0,
    ---@class FunctionContainer
    syncTimer = nil,
    clientVersions = {}
}

local function performSync()
    local data = {
        encountersId = SRTData.GetActiveRosterID(),
        encounters = SRTData.GetActiveRoster().encounters
    }
    Log.debug("Sending raid sync", data)
    SwiftdawnRaidTools:SendRaidMessage("SYNC", data, SwiftdawnRaidTools.PREFIX_SYNC, "BULK", function(_, sent, total)
        local progressData = {
            encountersId = data.encountersId,
            progress = sent / total * 100,
        }
        SwiftdawnRaidTools.encountersProgress = progressData.progress
        SwiftdawnRaidTools:SendRaidMessage("SYNC_PROG", progressData, SwiftdawnRaidTools.PREFIX_SYNC_PROGRESS)
    end)
end

function SyncController:ScheduleAssignmentsSync()
    if IsEncounterInProgress() then
        Log.info("Not scheduling sync. Encounter is in progress")
        return
    end
    if not Utils:IsPlayerRaidLeader() then
        Log.info("Not scheduling sync. You are not the raid leader")
        return
    end
    if SyncController.syncTimer then
        SyncController.syncTimer:Cancel()
        SyncController.syncTimer = nil
    end
    local timeSinceLastSync = GetTime() - SyncController.lastSyncTime
    local waitTime = math.max(0, SYNC_WAIT_TIME - timeSinceLastSync)
    Log.debug("Scheduling raid sync in "..waitTime.." seconds")
    SyncController.syncTimer = C_Timer.NewTimer(waitTime, function()
        SyncController.lastSyncTime = GetTime()
        performSync()
    end)
end

function SyncController:SyncAssignmentsNow()
    if IsEncounterInProgress() then
        Log.info("Not syncing now. Encounter is in progress")
        return
    end
    if not Utils:IsPlayerRaidLeader() then
        Log.info("Not syncing now. You are not the raid leader")
        return
    end
    if SyncController.syncTimer then
        SyncController.syncTimer:Cancel()
        SyncController.syncTimer = nil
    end
    performSync()
end

function SyncController:RequestVersions()
    SwiftdawnRaidTools:SendRaidMessage("SYNC_REQ_VERSIONS", SwiftdawnRaidTools.PREFIX_SYNC)
end

function SyncController:SendVersion()
    -- Send empty message; the version field will be filled
    SwiftdawnRaidTools:SendRaidMessage()
end

function SyncController:SendStatus()
    if IsEncounterInProgress() or not IsInRaid() or Utils:IsPlayerRaidLeader() then
        return
    end
    local data = {
        encountersId = SRTData.GetActiveRosterID(),
    }
    SwiftdawnRaidTools:SendRaidMessage("SYNC_STATUS", data, SwiftdawnRaidTools.PREFIX_SYNC)
end

function SyncController:HandleStatus(data)
    if IsEncounterInProgress() or not Utils:IsPlayerRaidLeader() then
        return
    end
    if SRTData.GetActiveRosterID() ~= data.encountersId then
        SyncController:ScheduleAssignmentsSync()
    end
end

function SyncController:SetClientVersion(player, version)
    SyncController.clientVersions[player] = version
end

function SyncController:GetClientVersions()
    local versions = {}
    for player, version in pairs(SyncController.clientVersions) do
        if not versions[version] then
            versions[version] = {}
        end

        table.insert(versions[version], player)
    end
    return versions
end
