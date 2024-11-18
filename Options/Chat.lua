local SwiftdawnRaidTools = SwiftdawnRaidTools

local reqVersionsTimer = nil

function SwiftdawnRaidTools:ChatHandleCommand(input)
    if not input or input:trim() == "" then
        Log.info("Usage: /srt [config,show,hide,versions]")
    else
        local trimmed = input:trim()
        
        if trimmed == "config" then
            Settings.OpenToCategory("Swiftdawn Raid Tools")
        elseif trimmed == "show" or trimmed == "hide" then
            self.db.profile.overview.show = trimmed == "show" and true or false
            self.overview:Update()
        elseif trimmed == "versions" then
            if not reqVersionsTimer then
                SyncController:RequestVersions()

                Log.info("Requesting versions...")
                reqVersionsTimer = C_Timer.NewTimer(10, function()
                    reqVersionsTimer = nil

                    for version, players in pairs(SyncController:GetClientVersions()) do
                        if not version then
                            version = "Unknown"
                        end

                        Log.info(version .. ": " .. Utils:StringJoin(players))
                    end
                end)
            end
        elseif trimmed == "debug" then
            self.DEBUG = not self.DEBUG
            Log.info("debug", self.DEBUG)
        elseif trimmed == "teststart" then
            self:InternalTestStart()
        elseif trimmed == "testend" then
            self:InternalTestEnd()
        elseif trimmed == "stringfind" then
            local str = "throws a |cff6699FFred|r vial into the cauldron!"
            local match = "red|r vial into the cauldron!"
            Log.info(str:find(match))
        end
    end
end
