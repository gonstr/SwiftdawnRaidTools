local SwiftdawnRaidTools = SwiftdawnRaidTools

local reqVersionsTimer = nil

function SwiftdawnRaidTools:ChatHandleCommand(input)
    if not input or input:trim() == "" then
        self:Print("Usage: /srt [config,show,hide,versions]")
    else
        local trimmed = input:trim()
        
        if trimmed == "config" then
            InterfaceOptionsFrame_OpenToCategory("Swiftdawn Raid Tools")
        elseif trimmed == "show" or trimmed == "hide" then
            self.db.profile.overview.show = trimmed == "show" and true or false
            self:OverviewUpdate()
        elseif trimmed == "versions" then
            if not reqVersionsTimer then
                self:SyncReqVersions()

                self:Print("Requesting versions...")
                reqVersionsTimer = C_Timer.NewTimer(10, function()
                    reqVersionsTimer = nil

                    for version, players in pairs(self:SyncGetClientVersions()) do
                        if not version then
                            version = "Unknown"
                        end

                        self:Print(version .. ": " .. self:StringJoin(players))
                    end
                end)
            end
        elseif trimmed == "debug" then
            self.DEBUG = not self.DEBUG
            self:Print("debug", self.DEBUG)
        elseif trimmed == "teststart" then
            self:InternalTestStart()
        elseif trimmed == "testend" then
            self:InternalTestEnd()
        elseif trimmed == "stringfind" then
            local str = "throws a |cff6699FFred|r vial into the cauldron!"
            local match = "red|r vial into the cauldron!"
            self:Print(str:find(match))
        end
    end
end
