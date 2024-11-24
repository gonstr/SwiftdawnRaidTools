local SwiftdawnRaidTools = SwiftdawnRaidTools
Log = {}

function Log.info(message, ...)
    SwiftdawnRaidTools:Print(message, ...)
end

function Log.debug(message, ...)
    if SRT_IsDebugging() then
        SwiftdawnRaidTools:Print("[DEBUG] "..message, ...)
    end
    SwiftdawnRaidTools.debugLog:AddItem(message, ...)
end