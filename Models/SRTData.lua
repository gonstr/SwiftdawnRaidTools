local SwiftdawnRaidTools = SwiftdawnRaidTools
local defaultAssignments = {
    [1197] = {
        [1] = {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Smoldering Devastation",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 99052,
                    ["type"] = "SPELL_CAST",
                    ["throttle"] = 7,
                },
            },
        },
        [2] = {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Ember Flare",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 99859,
                    ["type"] = "SPELL_CAST",
                    ["conditions"] = {
                        {
                            ["pct_lt"] = 55,
                            ["type"] = "UNIT_HEALTH",
                            ["unit"] = "boss1",
                        },
                    },
                },
            },
        },
    },
    [1204] = {
        [1] = {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Concussive Stomp",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 102306,
                    ["type"] = "SPELL_CAST",
                    ["throttle"] = 7,
                },
            },
        },
        [2] = {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Phase 2",
            },
            ["triggers"] = {
                {
                    ["pct_lt"] = 25,
                    ["type"] = "UNIT_HEALTH",
                    ["unit"] = "boss1",
                },
                {
                    ["pct_lt"] = 25,
                    ["type"] = "UNIT_HEALTH",
                    ["delay"] = 10,
                    ["unit"] = "boss1",
                },
                {
                    ["pct_lt"] = 25,
                    ["type"] = "UNIT_HEALTH",
                    ["delay"] = 20,
                    ["unit"] = "boss1",
                },
                {
                    ["pct_lt"] = 25,
                    ["type"] = "UNIT_HEALTH",
                    ["delay"] = 30,
                    ["unit"] = "boss1",
                },
                {
                    ["pct_lt"] = 25,
                    ["type"] = "UNIT_HEALTH",
                    ["delay"] = 40,
                    ["unit"] = "boss1",
                },
                {
                    ["pct_lt"] = 25,
                    ["type"] = "UNIT_HEALTH",
                    ["delay"] = 50,
                    ["unit"] = "boss1",
                },
            },
        },
    },
    [1205] = {
        [1] = {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Ignited",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 99922,
                    ["type"] = "SPELL_CAST",
                },
                {
                    ["spell_id"] = 99922,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 10,
                },
                {
                    ["spell_id"] = 99922,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 20,
                },
                {
                    ["spell_id"] = 99922,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 30,
                },
                {
                    ["spell_id"] = 99922,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 40,
                },
                {
                    ["spell_id"] = 99922,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 50,
                },
            },
        },
        [2] = {
            ["assignments"] = {
                {
                    {
                        ["spell_id"] = 51052,
                        ["type"] = "SPELL",
                        ["player"] = "Oldmanbush",
                    },
                },
            },
            ["metadata"] = {
                ["name"] = "Knockback",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 99757,
                    ["type"] = "SPELL_CAST",
                },
                {
                    ["spell_id"] = 99756,
                    ["type"] = "SPELL_CAST",
                },
            },
        },
    },
    [1203] = {
        [1] = {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "P1 Traps",
                ["notification"] = "Trap Explosion Soon...",
            },
            ["triggers"] = {
                {
                    ["countdown"] = 5,
                    ["type"] = "ENCOUNTER_START",
                    ["delay"] = 30,
                },
                {
                    ["countdown"] = 5,
                    ["type"] = "ENCOUNTER_START",
                    ["delay"] = 50,
                },
            },
        },
        [2] = {
            ["assignments"] = {},
            ["untriggers"] = {
                {
                    ["spell_id"] = 98175,
                    ["type"] = "SPELL_CAST",
                },
            },
            ["metadata"] = {
                ["name"] = "P2 Traps",
                ["notification"] = "Trap Explosion Soon...",
            },
            ["triggers"] = {
                {
                    ["countdown"] = 5,
                    ["type"] = "SPELL_CAST",
                    ["spell_id"] = 100171,
                    ["conditions"] = {
                        {
                            ["type"] = "UNIT_HEALTH",
                            ["pct_gt"] = 50,
                            ["unit"] = "boss1",
                        },
                    },
                    ["delay"] = 15,
                },
            },
        },
        [3] = {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Seeds",
                ["notification"] = "Seed Explosion Soon...",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 98495,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 7,
                    ["countdown"] = 3,
                },
            },
        },
    },
    [1029] = {
        [1] = {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Phase 2",
            },
            ["triggers"] = {
                {
                    ["pct_lt"] = 20,
                    ["type"] = "UNIT_HEALTH",
                    ["unit"] = "boss1",
                },
                {
                    ["pct_lt"] = 20,
                    ["type"] = "UNIT_HEALTH",
                    ["delay"] = 10,
                    ["unit"] = "boss1",
                },
            },
        },
    },
    [1026] = {
        [1] = {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Electrocute/Crackle",
            },
            ["triggers"] = {
                {
                    ["countdown"] = 5,
                    ["type"] = "RAID_BOSS_EMOTE",
                    ["text"] = "The air crackles with electricity!",
                },
            },
        },
    },
    [1023] = {
        [1] = {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Heal to full for P2!",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 82848,
                    ["type"] = "SPELL_CAST",
                    ["conditions"] = {
                        {
                            ["pct_lt"] = 25,
                            ["type"] = "UNIT_HEALTH",
                            ["unit"] = "boss1",
                        },
                    },
                },
            },
        },
    },
    [1025] = {
        [1] = {
            ["assignments"] = {},
            ["untriggers"] = {
                {
                    ["spell_id"] = 77991,
                    ["type"] = "SPELL_CAST",
                },
                {
                    ["text"] = "blue||r vial into the cauldron!",
                    ["type"] = "RAID_BOSS_EMOTE",
                },
                {
                    ["text"] = "green||r vial into the cauldron!",
                    ["type"] = "RAID_BOSS_EMOTE",
                },
                {
                    ["text"] = "dark||r vial into the cauldron!",
                    ["type"] = "RAID_BOSS_EMOTE",
                },
            },
            ["metadata"] = {
                ["name"] = "Scorching Blast",
            },
            ["triggers"] = {
                {
                    ["countdown"] = 3,
                    ["type"] = "RAID_BOSS_EMOTE",
                    ["delay"] = 19,
                    ["text"] = "red||r vial into the cauldron!",
                },
                {
                    ["spell_id"] = 77679,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 7,
                    ["countdown"] = 3,
                },
            },
        },
    },
}

--- Database class for Swiftdawn Raid Tools
---@class SRTData
SRTData = {
    players = {},
    rosters = {},
    classes = {},
    spells = {},
    buffs = {}
}
SRTData.__index = SRTData

---@private
---@return SRTData
function SRTData:New()
    local obj = {}
    setmetatable(obj, SRTData)
    return obj
end

---@class SRTData
local srtDataSingleton

---@return SRTData
function SRTData.Get()
    if srtDataSingleton then
        return srtDataSingleton
    else
        srtDataSingleton = SRTData:New()
        srtDataSingleton:Initialize()
        srtDataSingleton:LoadData()
        return srtDataSingleton
    end
end

function SRTData:Initialize()
    SRT_Global().srt_data = SRT_Global().srt_data or{
        pool = {},
        players = {},
        rosters = {}, 
        classes = {},
        specs = {},
        spells = {},
        buffs = {}
    }
    -- Preseed our database with static information
    self.classes = {
        DeathKnight = Class:New("Death Knight", "DEATHKNIGHT"),
        Druid = Class:New("Druid", "DRUID"),
        Hunter = Class:New("Hunter", "HUNTER"),
        Mage = Class:New("Mage", "MAGE"),
        Paladin = Class:New("Paladin", "PALADIN"),
        Priest = Class:New("Priest", "PRIEST"),
        Rogue = Class:New("Rogue", "ROGUE"),
        Shaman = Class:New("Shaman", "SHAMAN"),
        Warlock = Class:New("Warlock", "WARLOCK"),
        Warrior = Class:New("Warrior", "WARRIOR")
    }
    self.specs = {
        Blood = Spec:New("Blood", self.classes.DeathKnight),
        FrostDK = Spec:New("Frost", self.classes.DeathKnight),
        Unholy = Spec:New("Unholy", self.classes.DeathKnight),
        Balance = Spec:New("Balance", self.classes.Druid),
        Feral = Spec:New("Feral", self.classes.Druid),
        Guardian = Spec:New("Guardian", self.classes.Druid),
        RestorationDruid = Spec:New("Restoration", self.classes.Druid),
        BeastMaster = Spec:New("Beast Master", self.classes.Hunter),
        Marksmanship = Spec:New("Marksmanship", self.classes.Hunter),
        Survival = Spec:New("Survival", self.classes.Hunter),
        Arcane = Spec:New("Arcane", self.classes.Mage),
        FrostMage = Spec:New("Frost", self.classes.Mage),
        Fire = Spec:New("Fire", self.classes.Mage),
        HolyPaladin = Spec:New("HolyPaladin", self.classes.Paladin),
        ProtectionPaladin = Spec:New("Protection", self.classes.Paladin),
        Retribution = Spec:New("Retribution", self.classes.Paladin),
        Discipline = Spec:New("Discipline", self.classes.Priest),
        HolyPriest = Spec:New("Holy", self.classes.Priest),
        Shadow = Spec:New("Shadow", self.classes.Priest),
        Assassin = Spec:New("Assassin", self.classes.Rogue),
        Combat = Spec:New("Combat", self.classes.Rogue),
        Subtility = Spec:New("Subtility", self.classes.Rogue),
        Elemental = Spec:New("Elemental", self.classes.Shaman),
        Enhancement = Spec:New("Enhancement", self.classes.Shaman),
        RestorationShaman = Spec:New("Restoration", self.classes.Shaman),
        Affliction = Spec:New("Affliction", self.classes.Warlock),
        Demonology = Spec:New("Demonology", self.classes.Warlock),
        Destruction = Spec:New("Destruction", self.classes.Warlock),
        Arms = Spec:New("Arms", self.classes.Warrior),
        Fury = Spec:New("Fury", self.classes.Warrior),
        ProtectionWarrior = Spec:New("Protection", self.classes.Warrior),
    }
    self.buffs = {
    }
end

function SRTData:LoadData()
    local data = SRT_Global().srt_data
    self.players = data.players
    self.rosters = data.rosters
    self.defaultAssignments = defaultAssignments
end

---Add player to pool; will not overwrite!
---@param name string
---@param class Class
---@param spec? Spec
function SRTData.AddPlayerToPool(name, class, spec)
    local data = SRTData.Get()
    if not data.players[name] then
        data.players[name] = Player:New(name, class, spec)
    end
end

---Retrieve player object from player pool
---@param name string
---@return Player?
function SRTData.GetPlayerFromPool(name)
    local data = SRTData.Get()
    return data.players[name]
end

function SRTData.GetRosters()
    local data = SRTData.Get()
    return data.rosters
end

function SRTData.GetClass(className)
    local data = SRTData.Get()
    for name, class in pairs(data.classes) do
        if name == className or class.name == className or class.fileName == className then
            return class
        end
    end
end

---Create new roster
---@return Roster
function SRTData.CreateNewRoster()
    local data = SRTData.Get()
    local newRoster = Roster:New()
    data.rosters[newRoster.id] = newRoster
    return newRoster
end

function SRTData.RemoveRoster(rosterID)
    local data = SRTData.Get()
    data.rosters[rosterID] = nil
end

---Set spec for player in pool
---@param name string
---@param spec Spec
function SRTData.SetPlayerSpec(name, spec)
    local data = SRTData.Get()
    if not data.players[name] then
        print("Unable to set spec for "..name..". Player not in SRTData player pool yet!")
        return
    end
    data.players[name].spec = spec
end

function SRTData.GetAssignmentDefaults()
    local data = SRTData.Get()
    return SwiftdawnRaidTools:DeepClone(data.defaultAssignments)
end