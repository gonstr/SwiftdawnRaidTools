local SwiftdawnRaidTools = SwiftdawnRaidTools
local SharedMedia = LibStub("LibSharedMedia-3.0")

local WINDOW_WIDTH = 600

local State = {
    ROSTER = 1,
    SAVED_ROSTERS = 2,
    AVAILABLE_PLAYERS = 3
}

--- Roster Explorer window class object
---@class RosterExplorer:SRTWindow
RosterExplorer = setmetatable({
    state = State.ROSTER,
    lastState = State.ROSTER
}, SRTWindow)
RosterExplorer.__index = RosterExplorer

---@return RosterExplorer
function RosterExplorer:New(height)
    local obj = SRTWindow.New(self, "RosterExplorer", height, WINDOW_WIDTH, nil, nil, WINDOW_WIDTH, WINDOW_WIDTH)
    ---@cast obj RosterExplorer
    self.__index = self
    return obj
end

function RosterExplorer:Initialize()
    SRTWindow.Initialize(self)
    -- Update appearance
    self:UpdateAppearance()
end

function RosterExplorer:UpdateAppearance()
    SRTWindow.UpdateAppearance(self)

    self:UpdateRosterPane()
    self:UpdateSavedRostersPane()
    self:UpdateAvailablePlayersPane()
end

function RosterExplorer:UpdateRosterPane()
end

function RosterExplorer:UpdateSavedRostersPane()
end

function RosterExplorer:UpdateAvailablePlayersPane()
end

function RosterExplorer:Update()
    SRTWindow.Update(self)
end

---@return FontFile
function RosterExplorer:GetHeaderFontType()
    ---@class FontFile
    return SharedMedia:Fetch("font", self:GetAppearance().headerFontType)
end

---@return FontFile
function RosterExplorer:GetPlayerFontType()
    ---@class FontFile
    return SharedMedia:Fetch("font", self:GetAppearance().playerFontType)
end
