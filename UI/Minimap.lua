local SwiftdawnRaidTools = SwiftdawnRaidTools

local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local LDI = LibStub:GetLibrary("LibDBIcon-1.0")

function SwiftdawnRaidTools:MinimapInit()
    local broker = LDB:NewDataObject("SwiftdawnRaidTools", {
        type = "data source",
        text = "SwiftdawnRaidTools",
        icon = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\swiftdawn.png",
        OnClick = function(self, button)
            if button == "LeftButton" then
                Settings.OpenToCategory("Swiftdawn Raid Tools")
            else
                if IsShiftKeyDown() then
                    SwiftdawnRaidTools:NotificationsToggleFrameLock()
                else
                    SwiftdawnRaidTools.db.profile.overview.show = not SwiftdawnRaidTools.db.profile.overview.show
                    SwiftdawnRaidTools:OverviewUpdate()
                end
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("Swiftdawn Raid Tools")
            tooltip:AddLine("|cFFFFFFFFleft click|r to open configuration")
            tooltip:AddLine("|cFFFFFFFFright click|r to toggle overview visibility")
            tooltip:AddLine("|cFFFFFFFFshift + right click|r to show/hide anchors")
        end,
    })
    
    LDI:Register("SwiftdawnRaidTools", broker, self.db.profile.minimap)
end
