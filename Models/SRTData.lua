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
    [1032] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Blackout",
                ["notification"] = "Blackout > %(dest_name)s",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 86788,
                    ["type"] = "SPELL_AURA",
                }, -- [1]
            },
        }, -- [1]
    },
    [1025] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Acid Nova",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 78225,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [1]
        {
            ["assignments"] = {},
            ["untriggers"] = {
                {
                    ["spell_id"] = 77991,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
                {
                    ["text"] = "blue||r vial into the cauldron!",
                    ["type"] = "RAID_BOSS_EMOTE",
                }, -- [2]
                {
                    ["text"] = "green||r vial into the cauldron!",
                    ["type"] = "RAID_BOSS_EMOTE",
                }, -- [3]
                {
                    ["text"] = "dark||r vial into the cauldron!",
                    ["type"] = "RAID_BOSS_EMOTE",
                }, -- [4]
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
                }, -- [1]
                {
                    ["spell_id"] = 77679,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 7,
                    ["countdown"] = 3,
                }, -- [2]
            },
        }, -- [2]
    },
    [1029] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Empowered Shadows",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 81572,
                    ["type"] = "SPELL_AURA",
                }, -- [1]
            },
        }, -- [1]
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Phase 2",
            },
            ["triggers"] = {
                {
                    ["pct_lt"] = 20,
                    ["type"] = "UNIT_HEALTH",
                    ["unit"] = "boss1",
                }, -- [1]
                {
                    ["pct_lt"] = 20,
                    ["type"] = "UNIT_HEALTH",
                    ["delay"] = 10,
                    ["unit"] = "boss1",
                }, -- [2]
                {
                    ["pct_lt"] = 20,
                    ["type"] = "UNIT_HEALTH",
                    ["delay"] = 20,
                    ["unit"] = "boss1",
                }, -- [3]
                {
                    ["pct_lt"] = 20,
                    ["type"] = "UNIT_HEALTH",
                    ["delay"] = 30,
                    ["unit"] = "boss1",
                }, -- [4]
                {
                    ["pct_lt"] = 20,
                    ["type"] = "UNIT_HEALTH",
                    ["delay"] = 40,
                    ["unit"] = "boss1",
                }, -- [5]
                {
                    ["pct_lt"] = 20,
                    ["type"] = "UNIT_HEALTH",
                    ["delay"] = 50,
                    ["unit"] = "boss1",
                }, -- [6]
            },
        }, -- [2]
    },
    [1023] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Systems Failure",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 88853,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [1]
        {
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
                        }, -- [1]
                    },
                }, -- [1]
            },
        }, -- [2]
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Phase 2",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 82934,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
                {
                    ["spell_id"] = 82934,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 10,
                }, -- [2]
                {
                    ["spell_id"] = 82934,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 20,
                }, -- [3]
                {
                    ["spell_id"] = 82934,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 30,
                }, -- [4]
                {
                    ["spell_id"] = 82934,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 40,
                }, -- [5]
                {
                    ["spell_id"] = 82934,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 50,
                }, -- [6]
            },
        }, -- [3]
    },
    [1026] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Electrocute/Crackle",
            },
            ["triggers"] = {
                {
                    ["countdown"] = 5,
                    ["type"] = "RAID_BOSS_EMOTE",
                    ["text"] = "The air crackles with electricity!",
                }, -- [1]
            },
        }, -- [1]
    },
    [1030] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Proto Breath",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 83707,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [1]
    },
    [1034] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Acid Rain",
                ["notification"] = "Acid Rain - %(unit_name)s %(health_pct).0f%",
            },
            ["triggers"] = {
                {
                    ["pct_lt"] = 80,
                    ["type"] = "UNIT_HEALTH",
                    ["unit"] = "boss1",
                }, -- [1]
                {
                    ["pct_lt"] = 70,
                    ["type"] = "UNIT_HEALTH",
                    ["unit"] = "boss1",
                }, -- [2]
                {
                    ["pct_lt"] = 60,
                    ["type"] = "UNIT_HEALTH",
                    ["unit"] = "boss1",
                }, -- [3]
                {
                    ["pct_lt"] = 50,
                    ["type"] = "UNIT_HEALTH",
                    ["unit"] = "boss1",
                }, -- [4]
                {
                    ["pct_lt"] = 40,
                    ["type"] = "UNIT_HEALTH",
                    ["unit"] = "boss1",
                }, -- [5]
                {
                    ["pct_lt"] = 30,
                    ["type"] = "UNIT_HEALTH",
                    ["unit"] = "boss1",
                }, -- [6]
                {
                    ["pct_lt"] = 20,
                    ["type"] = "UNIT_HEALTH",
                    ["unit"] = "boss1",
                }, -- [7]
            },
        }, -- [1]
    },
    [1027] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Incineration",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 79023,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [1]
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Grip of Death",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 91849,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [2]
    },
    [1035] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Sleet Storm",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 84644,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [1]
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Storm Shield",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 93059,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [2]
    },
    [1022] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Searing Flames",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 77840,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [1]
    },
    [1024] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Lava Spew",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 77690,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [1]
    },
    [1028] = {
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Aegis Flames",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 82631,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [1]
        {
            ["assignments"] = {},
            ["metadata"] = {
                ["name"] = "Lava Seeds",
            },
            ["triggers"] = {
                {
                    ["spell_id"] = 84913,
                    ["type"] = "SPELL_CAST",
                }, -- [1]
            },
        }, -- [2]
    },
    [1082] = {
        {
            ["assignments"] = {},
            ["untriggers"] = {
                {
                    ["spell_id"] = 87299,
                    ["type"] = "SPELL_AURA",
                }, -- [1]
            },
            ["metadata"] = {
                ["name"] = "Flame Breath",
            },
            ["triggers"] = {
                {
                    ["countdown"] = 3,
                    ["type"] = "ENCOUNTER_START",
                    ["delay"] = 18,
                }, -- [1]
                {
                    ["countdown"] = 3,
                    ["type"] = "RAID_BOSS_EMOTE",
                    ["delay"] = 18,
                    ["text"] = "Enough! Drawing upon this source will set us back months.",
                }, -- [2]
                {
                    ["spell_id"] = 90125,
                    ["type"] = "SPELL_CAST",
                    ["delay"] = 18,
                    ["countdown"] = 3,
                }, -- [3]
            },
        }, -- [1]
    },
}

--- Database class for Swiftdawn Raid Tools
---@class SRTData
SRTData = {
    players = {},
    rosters = {},
    classes = {},
    spells = {}
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
        DevTool:AddData(srtDataSingleton, "SRTData")
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
    self.spells = {
        -- Death Knight
        IceboundFortitude = Spell:New(48792, "Icebound Fortitude", 60 * 3, 12),
        VampiricBlood = Spell:New(55233, "Vampiric Blood", 60 * 1, 10),
        AntiMagicZone = Spell:New(51052, "Anti-Magic Zone", 60 * 2, 10),
        -- Druid
        Innervate = Spell:New(29166, "Innervate", 60 * 3, 10),
        Barkskin = Spell:New(22812, "Barkskin", 60 * 1, 12),
        SurvivalInstincts = Spell:New(61336, "Survival Instincts", 60 * 3, 12),
        FrenziedRegeneration = Spell:New(22842, "Frenzied Regeneration", 60 * 3, 20),
        Tranquility = Spell:New(740, "Tranquility", 60 * 8, 8),
        StampedingRoar = Spell:New(77764, "Stampeding Roar", 60 * 2, 8),
        -- Paladin
        DivineProtection = Spell:New(498, "Divine Protection", 60 * 1, 10),
        GuardianOfAncientKings = Spell:New(86659, "Guardian of Ancient Kings", 0, 12),
        ArdentDefender = Spell:New(31850, "Ardent Defender", 60 * 3, 10),
        HandOfSalvation = Spell:New(1038, "Hand of Salvation", 60 * 2, 10),
        HandOfProtection = Spell:New(1022, "Hand of Protection", 60 * 5, 10),
        AuraMastery = Spell:New(31821, "Aura Mastery", 60 * 2, 6),
        HandOfSacrifice = Spell:New(6940, "Hand of Sacrifice", 60 * 2, 12),
        DivineGuardian = Spell:New(70940, "Divine Guardian", 60 * 3, 6),
        -- Priest
        HymnOfHope = Spell:New(64901, "Hymn of Hope", 60 * 6, 8),
        DivineHymn = Spell:New(64843, "Divine Hymn", 60 * 8, 8),
        PainSuppression = Spell:New(33206, "Pain Suppression", 60 * 3, 8),
        PowerWordBarrier = Spell:New(62618, "Power Word: Barrier", 60 * 3, 10),
        -- Shaman
        ManaTideTotem = Spell:New(16190, "Mana Tide Totem", 60 * 3, 12),
        SpiritLinkTotem = Spell:New(98008, "Spirit Link Totem", 60 * 3, 6),
        -- Warrior
        ShieldWall = Spell:New(871, "Shield Wall", 60 * 5, 12),
        LastStand = Spell:New(12975, "Last Stand", 60 * 3, 0),
        EnragedRegeneration = Spell:New(55694, "Enraged Regeneration", 60 * 3, 10),
        RallyingCry = Spell:New(97462, "Rallying Cry", 60 * 3, 10),
    }
    self.classes = {
        DeathKnight = Class:New("Death Knight", "DEATHKNIGHT", {
            self.spells.IceboundFortitude,
            self.spells.VampiricBlood,
            self.spells.AntiMagicZone,
        }),
        Druid = Class:New("Druid", "DRUID", {
            self.spells.Innervate,
            self.spells.Barkskin,
            self.spells.SurvivalInstincts,
            self.spells.FrenziedRegeneration,
            self.spells.Tranquility,
            self.spells.StampedingRoar,
        }),
        Hunter = Class:New("Hunter", "HUNTER", {}),
        Mage = Class:New("Mage", "MAGE", {}),
        Paladin = Class:New("Paladin", "PALADIN", {
            self.spells.DivineProtection,
            self.spells.GuardianOfAncientKings,
            self.spells.ArdentDefender,
            self.spells.HandOfSalvation,
            self.spells.HandOfProtection,
            self.spells.AuraMastery,
            self.spells.HandOfSacrifice,
            self.spells.DivineGuardian,
        }),
        Priest = Class:New("Priest", "PRIEST", {
            self.spells.HymnOfHope,
            self.spells.DivineHymn,
            self.spells.PainSuppression,
            self.spells.PowerWordBarrier,
        }),
        Rogue = Class:New("Rogue", "ROGUE", {}),
        Shaman = Class:New("Shaman", "SHAMAN", {
            self.spells.ManaTideTotem,
            self.spells.SpiritLinkTotem,
        }),
        Warlock = Class:New("Warlock", "WARLOCK", {}),
        Warrior = Class:New("Warrior", "WARRIOR", {
            self.spells.ShieldWall,
            self.spells.LastStand,
            self.spells.EnragedRegeneration,
            self.spells.RallyingCry,
        })
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

---Retrieve spell object by it's in-game ID
---@param spellID number
---@return Spell?
function SRTData.GetSpellByID(spellID)
    local data = SRTData.Get()
    for _, spell in pairs(data.spells) do
        if spell.id == spellID then
            return spell
        end
    end
    return nil
end

---comment
---@param spellID number
---@return ColorMixin_RCC
function SRTData.GetClassColorBySpellID(spellID)
    local data = SRTData.Get()
    for _, class in pairs(data.classes) do
        for _, spell in pairs(class.spells) do
            if spell.id == spellID then
                return class:GetColor()
            end
        end
    end
    return { r = 0, g = 0, b = 0, colorStr = "ffffffff" }
end

---comment
---@param spellID number
---@return Class?
function SRTData.GetClassBySpellID(spellID)
    local data = SRTData.Get()
    for _, class in pairs(data.classes) do
        for _, spell in pairs(class.spells) do
            if spell.id == spellID then
                return class
            end
        end
    end
    return nil
end