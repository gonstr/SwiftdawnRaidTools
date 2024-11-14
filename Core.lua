SwiftdawnRaidTools = LibStub("AceAddon-3.0"):NewAddon("SwiftdawnRaidTools", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")

SwiftdawnRaidTools.DEBUG = false
SwiftdawnRaidTools.TEST = false

SwiftdawnRaidTools.PREFIX_SYNC = "SRT-S"
SwiftdawnRaidTools.PREFIX_SYNC_PROGRESS = "SRT-SP"
SwiftdawnRaidTools.PREFIX_MAIN = "SRT-M"

SwiftdawnRaidTools.VERSION = C_AddOns.GetAddOnMetadata("SwiftdawnRaidTools", "Version")
SwiftdawnRaidTools.IS_DEV = SwiftdawnRaidTools.VERSION == '\@project-version\@'

-- AceDB defaults
SwiftdawnRaidTools.defaults = {
    profile = {
        options = {
            import = "",
        },
        data = {
            encountersProgress = nil,
            encountersId = nil,
            encounters = {}
        },
        minimap = {},
        notifications = {
            showOnlyOwnNotifications = false,
            locked = true,
            mute = false,
            anchorX = GetScreenWidth()/2,
            anchorY = -(GetScreenHeight()/2) + 200,
            appearance = {
                scale = 1.2,
                headerFontType = "Friz Quadrata TT",
                headerFontSize = 14,
                playerFontType = "Friz Quadrata TT",
                playerFontSize = 12,
                countdownFontType = "Friz Quadrata TT",
                countdownFontSize = 12,
                backgroundOpacity = 0.9,
                iconSize = 16
            }
        },
        overview = {
            anchorX = 0,
            anchorY = 0,
            selectedEncounterId = nil,
            locked = false,
            show = true,
            appearance = {
                scale = 1.0,
                titleFontType = "Friz Quadrata TT",
                titleFontSize = 10,
                headerFontType = "Friz Quadrata TT",
                headerFontSize = 10,
                playerFontType = "Friz Quadrata TT",
                playerFontSize = 10,
                titleBarOpacity = 0.8,
                backgroundOpacity = 0.4,
                iconSize = 14
            }
        },
        debuglog = {
            anchorX = 0,
            anchorY = -(GetScreenHeight()/2),
            locked = false,
            show = false,
            scrollToBottom = true,
            appearance = {
                scale = 1.0,
                titleFontType = "Friz Quadrata TT",
                titleFontSize = 10,
                logFontType = "Friz Quadrata TT",
                logFontSize = 10,
                titleBarOpacity = 0.8,
                backgroundOpacity = 0.4,
                iconSize = 14
            }
        }
    },
}

function SwiftdawnRaidTools:OnInitialize()
    self:DBInit() 
    self:OptionsInit()
    self:MinimapInit()

    self.overview = SRTOverview:New(300, 180)
    self.overview:Initialize()

    self:NotificationsInit()

    self.debugLog = SRTDebugLog:New(100, 400)
    self.debugLog:Initialize()

    self:RegisterComm(self.PREFIX_SYNC)
    self:RegisterComm(self.PREFIX_SYNC_PROGRESS)
    self:RegisterComm(self.PREFIX_MAIN)
end

function SwiftdawnRaidTools:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ZONE_CHANGED")
    self:RegisterEvent("ENCOUNTER_START")
    self:RegisterEvent("ENCOUNTER_END")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
    self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
    self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")

    self:RegisterMessage("SRT_WA_EVENT")

    self:RegisterChatCommand("srt", "ChatHandleCommand")
end

function SwiftdawnRaidTools:OnDisable()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("ZONE_CHANGED")
    self:UnregisterEvent("ENCOUNTER_START")
    self:UnregisterEvent("ENCOUNTER_END")
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:UnregisterEvent("UNIT_HEALTH")
    self:UnregisterEvent("GROUP_ROSTER_UPDATE")
    self:UnregisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
    self:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
    self:UnregisterEvent("CHAT_MSG_MONSTER_EMOTE")

    self:UnregisterMessage("SRT_WA_EVENT")

    self:UnregisterChatCommand("srt")
end

function SwiftdawnRaidTools:DBInit()
    self.db = LibStub("AceDB-3.0"):New("SwiftdawnRaidTools", self.defaults)
end

function SwiftdawnRaidTools:PLAYER_ENTERING_WORLD(_, isInitialLogin, isReloadingUi)
    if isInitialLogin or isReloadingUi then
        self:BossEncountersInit()
        self:SyncSendStatus()
        self:SyncSchedule()
    end

    self.overview:Update()
    self.debugLog:Update()
end

function SwiftdawnRaidTools:SendRaidMessage(event, data, prefix, prio, callbackFn)
    if self.DEBUG then self:Print("Sending RAID message") end

    local payload = {
        v = self.VERSION,
        e = event,
        d = data,
    }

    if not prefix then
        prefix = self.PREFIX_MAIN
    end

    if not prio then
        prio = "NORMAL"
    end

    -- "Send" message directly to self
    self:HandleMessagePayload(payload)

    -- Send to raid
    if IsInRaid() then
        self:SendCommMessage(prefix, self:Serialize(payload), "RAID", nil, prio, callbackFn)
    end
end

function SwiftdawnRaidTools:OnCommReceived(prefix, message, _, sender)
    if sender == UnitName("player") then
        return
    end

    if prefix == self.PREFIX_MAIN or prefix == self.PREFIX_SYNC or prefix == self.PREFIX_SYNC_PROGRESS then
        local ok, payload = self:Deserialize(message)

        if ok then
            self:SyncSetClientVersion(sender, payload.v)
            self:HandleMessagePayload(payload, sender)
        end
    end
end

function SwiftdawnRaidTools:HandleMessagePayload(payload, sender)
    if payload.e == "SYNC_REQ_VERSIONS" then
        if self.DEBUG then self:Print("Received message SYNC_REQ_VERSIONS:", sender) end
        self:SyncSendVersion()
    elseif payload.e == "SYNC_STATUS" then
        if self.DEBUG then self:Print("Received message SYNC_STATUS:", sender) end
        self:SyncHandleStatus(payload.d)
    elseif payload.e == "SYNC_PROG" then
        if payload.d.encountersId ~= self.db.profile.data.encountersId then
            if self.DEBUG then self:Print("Received message SYNC_PROG:", sender, payload.d.progress) end
            self.db.profile.data.encountersProgress = payload.d.progress
            self.db.profile.data.encountersId = nil
            self.db.profile.data.encounters = {}
            self.overview:Update()
        end
    elseif payload.e == "SYNC" then
        if self.DEBUG then self:Print("Received message SYNC") end
        self.db.profile.data.encountersProgress = nil
        self.db.profile.data.encountersId = payload.d.encountersId
        self.db.profile.data.encounters = payload.d.encounters
        self.overview:Update()
    elseif payload.e == "ACT_GRPS" then
        if self.DEBUG then self:Print("Received message ACT_GRPS") end
        self:GroupsSetAllActive(payload.d)
        self.overview:UpdateActiveGroups()
    elseif payload.e == "TRIGGER" then
        if self.DEBUG then self:Print("Received message TRIGGER") end
        self.debugLog:AddItem(LogItem:New(payload.d))
        self:GroupsSetActive(payload.d.uuid, payload.d.activeGroups)
        self:NotificationsShowRaidAssignment(payload.d.uuid, payload.d.context, payload.d.delay, payload.d.countdown)
        self:NotificationsUpdateSpells()
    end
end

function SwiftdawnRaidTools:SRT_WA_EVENT(_, event, ...)
    if event == "WA_NUMEN_TIMER" then
        local key, countdown = ...
        self:RaidAssignmentsHandleFojjiNumenTimer(key, countdown)
    end
end

function SwiftdawnRaidTools:ENCOUNTER_START(_, encounterID, encounterName, ...)
    self:TestModeEnd()
    self.overview:SelectEncounter(encounterID)
    self:RaidAssignmentsStartEncounter(encounterID, encounterName)
end

function SwiftdawnRaidTools:ENCOUNTER_END(_, ...)
    self:RaidAssignmentsEndEncounter()
    self:SpellsResetCache()
    self:UnitsResetDeadCache()
    self.overview:UpdateSpells()
    self:NotificationsUpdateSpells()
end

function SwiftdawnRaidTools:ZONE_CHANGED()
    self:TestModeEnd()
    self:RaidAssignmentsEndEncounter()
    self.overview:UpdateSpells()
    self:NotificationsUpdateSpells()
end

function SwiftdawnRaidTools:UNIT_HEALTH(_, unitId, ...)
    local guid = UnitGUID(unitId)

    if self:UnitsIsDead(guid) and UnitHealth(unitId) > 0 and not UnitIsGhost(unitId) then
        if self.DEBUG then self:Print("Handling cached unit coming back to life") end
        self:UnitsClearDead(guid)
        self:RaidAssignmentsUpdateGroups()
        self.overview:UpdateSpells()
        self:NotificationsUpdateSpells()
    end

    self:RaidAssignmentsHandleUnitHealth(unitId)
end

function SwiftdawnRaidTools:GROUP_ROSTER_UPDATE()
    self.overview:UpdateSpells()
    self:NotificationsUpdateSpells()

    if IsInRaid() and not self.sentRaidSync then
        self.sentRaidSync = true
        self:SyncSendStatus()
    else
        self.sentRaidSync = false
    end
end

function SwiftdawnRaidTools:COMBAT_LOG_EVENT_UNFILTERED()
    local _, subEvent, _, _, sourceName, _, _, destGUID, destName, _, _, spellId = CombatLogGetCurrentEventInfo()
    self:HandleCombatLog(subEvent, sourceName, destGUID, destName, spellId)
end

function SwiftdawnRaidTools:CHAT_MSG_RAID_BOSS_EMOTE(_, text)
    self:RaidAssignmentsHandleRaidBossEmote(text)
end

function SwiftdawnRaidTools:CHAT_MSG_MONSTER_EMOTE(_, text, ...)
    self:RaidAssignmentsHandleRaidBossEmote(text)
end

function SwiftdawnRaidTools:CHAT_MSG_MONSTER_YELL(_, text, ...)
    self:RaidAssignmentsHandleRaidBossEmote(text)
end

function SwiftdawnRaidTools:HandleCombatLog(subEvent, sourceName, destGUID, destName, spellId)
    if subEvent == "SPELL_CAST_START" then
        self:RaidAssignmentsHandleSpellCast(subEvent, spellId, sourceName, destName)
    elseif subEvent == "SPELL_CAST_SUCCESS" then
        self:SpellsCacheCast(sourceName, spellId, function()
            self:RaidAssignmentsUpdateGroups()
            self.overview:UpdateSpells()
            self:NotificationsUpdateSpells()
        end)
        self:RaidAssignmentsHandleSpellCast(subEvent, spellId, sourceName, destName)
    elseif subEvent == "SPELL_AURA_APPLIED" or subEvent =="SPELL_AURA_REMOVED" then
        self:RaidAssignmentsHandleSpellAura(subEvent, spellId, sourceName, destName)
    elseif subEvent == "UNIT_DIED" then
        if self:IsFriendlyRaidMemberOrPlayer(destGUID) then
            self:UnitsSetDead(destGUID)
            self:RaidAssignmentsUpdateGroups()
            self.overview:UpdateSpells()
            self:NotificationsUpdateSpells()
        end
    end
end
