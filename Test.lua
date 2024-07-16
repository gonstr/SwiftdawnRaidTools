local SwiftdawnRaidTools = SwiftdawnRaidTools

function SwiftdawnRaidTools:InternalTestStart()
    self.TEST = true

    self:OverviewUpdateSpells()

    self:ENCOUNTER_START(nil, 1035)

    -- C_Timer.After(3, function()
    --     SwiftdawnRaidTools:CHAT_MSG_RAID_BOSS_EMOTE(nil, "test 123 432")
    -- end)

    -- C_Timer.After(5, function()
    --     SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Dableach", nil, nil, 51052)
    -- end)

    -- C_Timer.After(5, function()
    --     SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Anticipâte", nil, nil, 31821)
    -- end)

    -- C_Timer.After(3, function()
    --     SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Boss", nil, nil, 93059)
    -- end)

    -- C_Timer.After(10, function()
    --     SwiftdawnRaidTools:CHAT_MSG_RAID_BOSS_EMOTE(nil, "test 123 432")
    -- end)

    -- C_Timer.After(22, function()
    --     self:SpellsResetCache()
    --     self:OverviewUpdateSpells()
    --     self:RaidAssignmentsUpdateGroups()
    -- end)

    -- C_Timer.After(30, function()
    --     SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Boss", nil, nil, 93059)
    -- end)

    -- C_Timer.After(32, function()
    --     SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Elí", nil, nil, 31821)
    -- end)

    -- C_Timer.After(40, function()
    --     SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Boss", nil, nil, 93059)
    -- end)

    -- C_Timer.After(42, function()
    --     SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Solfernus", nil, nil, 51052)
    -- end)
end

function SwiftdawnRaidTools:InternalTestEnd()
    self.TEST = false

    self:ENCOUNTER_END(nil, 1035)
end
