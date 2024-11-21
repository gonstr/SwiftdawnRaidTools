local insert = table.insert

local SwiftdawnRaidTools = SwiftdawnRaidTools

local timers = {}

local function cancelTimers()
    for i, timer in ipairs(timers) do
        timer:Cancel()
        timers[i] = nil
    end
end

function SwiftdawnRaidTools:InternalTestStart()
    self.TEST = true

    self.overview:UpdateSpells()

    self:ENCOUNTER_START(nil, 1082)

    C_Timer.NewTimer(10, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Sinestra", nil, nil, 90125)
    end)

    -- C_Timer.NewTimer(40, function()
    --     SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Sinestra", nil, nil, 90125)
    -- end)
end

function SwiftdawnRaidTools:InternalTestEnd()
    self.TEST = false

    self:ENCOUNTER_END(nil, 1082)
end

function SwiftdawnRaidTools:TestModeEnabled()
    return self.TEST and true or false
end

function SwiftdawnRaidTools:TestModeToggle()
    if self.TEST then
        self:TestModeEnd()
    else
        self:TestModeStart()
    end
end

function SwiftdawnRaidTools:TestModeStart()
    self.TEST = true

    cancelTimers()

    Groups:Reset()
    SpellCache:Reset()
    UnitCache:ResetDeadCache()

    self.overview:SelectEncounter(42001)
    AssignmentsController:StartEncounter(42001, "The Boss")

    -- Phase 1

    insert(timers, C_Timer.NewTimer(10, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_AURA_APPLIED", "The Boss", nil, nil, 81572)
    end))

    insert(timers, C_Timer.NewTimer(11, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Aeolyne", nil, nil, 740)
    end))

    insert(timers, C_Timer.NewTimer(11.5, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Kondec", nil, nil, 62618)
    end))

    insert(timers, C_Timer.NewTimer(12, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Aeolyne", nil, nil, 740)
    end))

    insert(timers, C_Timer.NewTimer(12.5, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Kondec", nil, nil, 62618)
    end))

    -- Phase 2

    insert(timers, C_Timer.NewTimer(17, function()
        SwiftdawnRaidTools:CHAT_MSG_RAID_BOSS_EMOTE(nil, "I will breathe fire on you!")
    end))

    insert(timers, C_Timer.NewTimer(18.5, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Anticipâte", nil, nil, 31821)
    end))

    insert(timers, C_Timer.NewTimer(19.5, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Anticipâte", nil, nil, 31821)
    end))

    -- Phase 3

    insert(timers, C_Timer.NewTimer(24, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "The Boss", nil, nil, 88853)
    end))

    insert(timers, C_Timer.NewTimer(29, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "The Boss", nil, nil, 88853)
    end))

    -- End of Test

    insert(timers, C_Timer.NewTimer(40, function()
        SwiftdawnRaidTools:TestModeEnd()
    end))
end

function SwiftdawnRaidTools:TestModeEnd()
    if self.TEST then
        self.TEST = false

        cancelTimers()

        AssignmentsController:EndEncounter()
        SpellCache:Reset()
        UnitCache:ResetDeadCache()
        self.overview:Update()
    end
end
