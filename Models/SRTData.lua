--- Database class for Swiftdawn Raid Tools
---@class SRTData
SRTData = {
    pool = {},
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
        DeathKnight = Class:New("Death Knight"),
        Druid = Class:New("Druid"),
        Hunter = Class:New("Hunter"),
        Mage = Class:New("Mage"),
        Paladin = Class:New("Paladin"),
        Priest = Class:New("Priest"),
        Rogue = Class:New("Rogue"),
        Shaman = Class:New("Shaman"),
        Warlock = Class:New("Warlock"),
        Warrior = Class:New("Warrior")
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
    self.pool = data.pool
    self.players = data.players
    self.rosters = data.rosters
end

---@param name string
---@param class? string
---@param spec? string
function SRTData:AddPlayer(name, class, spec)
    if not self.pool[name] then
        self.pool[name] = Player:New(name, class, spec)
    end
end
