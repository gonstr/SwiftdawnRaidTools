local insert = table.insert

local SwiftdawnRaidTools = SwiftdawnRaidTools

-- seconds
local SYNC_WAIT_TIME = 60

local lastSyncTime = 0
local syncTimer = nil

local clientVersions = {}

function SwiftdawnRaidTools:SyncSchedule()
    if IsEncounterInProgress() or not self:IsPlayerRaidLeader() then
        return
    end

    if syncTimer then
        syncTimer:Cancel()
        syncTimer = nil
    end

    local timeSinceLastSync = GetTime() - lastSyncTime
    local waitTime = math.max(0, SYNC_WAIT_TIME - timeSinceLastSync)

    if self.DEBUG then self:Print("Scheduling raid sync in", waitTime, "seconds") end

    syncTimer = C_Timer.NewTimer(waitTime, function()
        lastSyncTime = GetTime()

        local data = {

            encountersId = self.db.profile.data.encountersId,
            encounters = self.db.profile.data.encounters
        }

        if self.DEBUG then self:Print("Sending raid sync") end

        SwiftdawnRaidTools:SendRaidMessage("SYNC", data, self.PREFIX_SYNC, "BULK", function(_, sent, total)
            local progressData = {
                encountersId = data.encountersId,
                progress = sent / total * 100,
            }

            SwiftdawnRaidTools:SendRaidMessage("SYNC_PROG", progressData, self.PREFIX_SYNC_PROGRESS)
        end)
    end)
end

function SwiftdawnRaidTools:SyncReqVersions()
    self:SendRaidMessage("SYNC_REQ_VERSIONS", self.PREFIX_SYNC)
end

function SwiftdawnRaidTools:SyncSendVersion()
    -- Send empty message
    self:SendRaidMessage()
end

function SwiftdawnRaidTools:SyncSendStatus()
    if IsEncounterInProgress() or not IsInRaid() or self:IsPlayerRaidLeader() then
        return
    end

    local data = {
        encountersId = self.db.profile.data.encountersId,
    }

    self:SendRaidMessage("SYNC_STATUS", data, self.PREFIX_SYNC)
end

function SwiftdawnRaidTools:SyncHandleStatus(data)
    if IsEncounterInProgress() or not self:IsPlayerRaidLeader() then
        return
    end

    if self.db.profile.data.encountersId ~= data.encountersId then
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
