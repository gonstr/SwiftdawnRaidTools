local insert = table.insert

local SwiftdawnRaidTools = SwiftdawnRaidTools

-- seconds
local SYNC_WAIT_TIME = 60

local lastSyncTime = 0
local syncTimer = nil

local clientVersions = {}

local function PerformSync()
    local data = {
        encountersId = SRTData.GetActiveRosterID(),
        encounters = SRTData.GetActiveRoster().encounters
    }
    Log.debug("Sending raid sync")
    SwiftdawnRaidTools:SendRaidMessage("SYNC", data, SwiftdawnRaidTools.PREFIX_SYNC, "BULK", function(_, sent, total)
        local progressData = {
            encountersId = data.encountersId,
            progress = sent / total * 100,
        }
        SwiftdawnRaidTools.encountersProgress = progressData.progress
        SwiftdawnRaidTools:SendRaidMessage("SYNC_PROG", progressData, SwiftdawnRaidTools.PREFIX_SYNC_PROGRESS)
    end)
end

function SwiftdawnRaidTools:SyncSchedule()
    if IsEncounterInProgress() or not Utils:IsPlayerRaidLeader() then
        Log.info("Not syncing, you are not the raid leader, or encounter is in progress")
        return
    end
    if syncTimer then
        syncTimer:Cancel()
        syncTimer = nil
    end
    local timeSinceLastSync = GetTime() - lastSyncTime
    local waitTime = math.max(0, SYNC_WAIT_TIME - timeSinceLastSync)
    Log.debug("Scheduling raid sync in", waitTime, "seconds")
    syncTimer = C_Timer.NewTimer(waitTime, function()
        lastSyncTime = GetTime()
        PerformSync()
    end)
end

function SwiftdawnRaidTools:SyncNow()
    if IsEncounterInProgress() or not Utils:IsPlayerRaidLeader() then
        Log.info("Not syncing, you are not the raid leader, or encounter is in progress")
        return
    end
    if syncTimer then
        syncTimer:Cancel()
        syncTimer = nil
    end
    PerformSync()
end

function SwiftdawnRaidTools:SyncReqVersions()
    self:SendRaidMessage("SYNC_REQ_VERSIONS", self.PREFIX_SYNC)
end

function SwiftdawnRaidTools:SyncSendVersion()
    -- Send empty message
    self:SendRaidMessage()
end

function SwiftdawnRaidTools:SyncSendStatus()
    if IsEncounterInProgress() or not IsInRaid() or Utils:IsPlayerRaidLeader() then
        return
    end

    local data = {
        encountersId = SRTData.GetActiveRosterID(),
    }

    self:SendRaidMessage("SYNC_STATUS", data, self.PREFIX_SYNC)
end

function SwiftdawnRaidTools:SyncHandleStatus(data)
    if IsEncounterInProgress() or not Utils:IsPlayerRaidLeader() then
        return
    end

    if SRTData.GetActiveRosterID() ~= data.encountersId then
        self:SyncSchedule()
    end
end

function SwiftdawnRaidTools:SyncSetClientVersion(player, version)
    clientVersions[player] = version
end

function SwiftdawnRaidTools:SyncGetClientVersions()
    local versions = {}

    for player, version in pairs(clientVersions) do
        if not versions[version] then
            versions[version] = {}
        end

        insert(versions[version], player)
    end

    return versions
end
