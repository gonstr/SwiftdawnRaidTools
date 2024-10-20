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

    self:OverviewUpdateSpells()

    self:ENCOUNTER_START(nil, 1082)

    C_Timer.NewTimer(20, function()
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

    self:GroupsReset()
    self:SpellsResetCache()
    self:UnitsResetDeadCache()
    self:OverviewUpdate()

    self:OverviewSelectEncounter(42001)
    self:RaidAssignmentsStartEncounter(42001, "The Boss")

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
        SwiftdawnRaidTools:RAID_BOSS_EMOTE(nil, "I will breathe fire on you!")
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

        self:RaidAssignmentsEndEncounter()
        self:SpellsResetCache()
        self:UnitsResetDeadCache()
        self:OverviewUpdate()
    end
end

function SwiftdawnRaidTools:GetEncounters()
    if self.TEST then
        return {
            [42001] = {
                {
                    ["assignments"] = {
                        {
                            {
                                ["spell_id"] = 740,
                                ["type"] = "SPELL",
                                ["player"] = "Aeolyne",
                            }, -- [1]
                            {
                                ["spell_id"] = 62618,
                                ["type"] = "SPELL",
                                ["player"] = "Kondec",
                            }, -- [2]
                        }, -- [1]
                    },
                    ["type"] = "RAID_ASSIGNMENTS",
                    ["version"] = 1,
                    ["encounter"] = 42001,
                    ["triggers"] = {
                        {
                            ["spell_id"] = 81572,
                            ["type"] = "SPELL_AURA",
                        }, -- [1]
                        {
                            ['type'] = "ENCOUNTER_START",
                            ['delay'] = 5,
                            ['countdown'] = 3
                        }
                    },
                    ["uuid"] = "437efe45-3fe2-4dd2-85a9-0e0b51689f69",
                    ["metadata"] = {
                        ["name"] = "Spell Aura Trigger Test",
                    },
                }, -- [1]  Spell Aura Phase
                {
                    ["assignments"] = {
                        {
                            {
                                ["spell_id"] = 31821,
                                ["type"] = "SPELL",
                                ["player"] = "Anticipâte",
                            }, -- [1]
                        }, -- [1]
                    },
                    ["type"] = "RAID_ASSIGNMENTS",
                    ["version"] = 1,
                    ["untriggers"] = {
                        {
                            ["type"] = "RAID_BOSS_EMOTE",
                            ["text"] = "I will spill water on you!",
                        }, -- [1]
                    },
                    ["encounter"] = 42001,
                    ["triggers"] = {
                        {
                            ["countdown"] = 3,
                            ["type"] = "RAID_BOSS_EMOTE",
                            ["delay"] = 1,
                            ["text"] = "I will breathe fire on you!",
                        }, -- [1]
                    },
                    ["uuid"] = "5450a7eb-cb42-4719-ba6d-e8a7ecca8f98",
                    ["metadata"] = {
                        ["name"] = "Raid Boss Emote Test",
                    },
                }, -- [2]  Raid Boss Emote Phase
                {
                    ["assignments"] = {
                        {
                            {
                                ["spell_id"] = 740,
                                ["type"] = "SPELL",
                                ["player"] = "Clutex",
                            }, -- [1]
                            {
                                ["spell_id"] = 31821,
                                ["type"] = "SPELL",
                                ["player"] = "Elí",
                            }, -- [2]
                        }, -- [1]
                        {
                            {
                                ["spell_id"] = 64843,
                                ["type"] = "SPELL",
                                ["player"] = "Managobrr",
                            }, -- [1]
                            {
                                ["spell_id"] = 31821,
                                ["type"] = "SPELL",
                                ["player"] = "Anticipâte",
                            }, -- [2]
                        }, -- [2]
                    },
                    ["type"] = "RAID_ASSIGNMENTS",
                    ["version"] = 1,
                    ["encounter"] = 1023,
                    ["triggers"] = {
                        {
                            ["spell_id"] = 88853,
                            ["type"] = "SPELL_CAST",
                        }, -- [1]
                    },
                    ["uuid"] = "e8b42653-abbe-418d-b675-6d323d8d78c8",
                    ["metadata"] = {
                        ["name"] = "Spell Cast Test",
                    },
                }, -- [3]  Spell Cast Phase
                --{
                --    ["assignments"] = {
                --        {
                --            {
                --                ["spell_id"] = 64843,
                --                ["type"] = "SPELL",
                --                ["player"] = "Kondec",
                --            }, -- [1]
                --            {
                --                ["spell_id"] = 98008,
                --                ["type"] = "SPELL",
                --                ["player"] = "Venmir",
                --            }, -- [2]
                --        }, -- [1]
                --        {
                --            {
                --                ["spell_id"] = 740,
                --                ["type"] = "SPELL",
                --                ["player"] = "Aeolyne",
                --            }, -- [1]
                --            {
                --                ["spell_id"] = 740,
                --                ["type"] = "SPELL",
                --                ["player"] = "Crawlern",
                --            }, -- [2]
                --        }, -- [2]
                --    },
                --    ["type"] = "RAID_ASSIGNMENTS",
                --    ["version"] = 1,
                --    ["encounter"] = 1023,
                --    ["triggers"] = {
                --        {
                --            ["spell_id"] = 82848,
                --            ["type"] = "SPELL_CAST",
                --            ["conditions"] = {
                --                {
                --                    ["pct_lt"] = 25,
                --                    ["type"] = "UNIT_HEALTH",
                --                    ["unit"] = "boss1",
                --                }, -- [1]
                --            },
                --        }, -- [1]
                --    },
                --    ["uuid"] = "765b0f4c-141a-4286-b97f-24390a8001c5",
                --    ["metadata"] = {
                --        ["name"] = "Conditional Spell Cast Test",
                --    },
                --}, -- [4]  Conditional Spell Cast Phase
                --{
                --    ["assignments"] = {
                --        {
                --            {
                --                ["spell_id"] = 64843,
                --                ["type"] = "SPELL",
                --                ["player"] = "Kondec",
                --            }, -- [1]
                --        }, -- [1]
                --        {
                --            {
                --                ["spell_id"] = 740,
                --                ["type"] = "SPELL",
                --                ["player"] = "Aeolyne",
                --            }, -- [1]
                --        }, -- [2]
                --    },
                --    ["type"] = "RAID_ASSIGNMENTS",
                --    ["version"] = 1,
                --    ["encounter"] = 42001,
                --    ["triggers"] = {
                --        {
                --            ["pct_lt"] = 70,
                --            ["type"] = "UNIT_HEALTH",
                --            ["unit"] = "boss1",
                --        }, -- [1]
                --        {
                --            ["pct_lt"] = 70,
                --            ["type"] = "UNIT_HEALTH",
                --            ["delay"] = 10,
                --            ["unit"] = "boss1",
                --        }, -- [2]
                --    },
                --    ["uuid"] = "b5aeb9ec-9f2a-4f03-b5bf-764ac5cec091",
                --    ["metadata"] = {
                --        ["name"] = "Unit Health Test",
                --    },
                --}, -- [5]  Unit Health Phase
            }
        }
    else
        return self.db.profile.data.encounters
    end
end
