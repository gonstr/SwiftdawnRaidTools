local SwiftdawnRaidTools = SwiftdawnRaidTools
Log = {}

function Log.info(message, ...)
    SwiftdawnRaidTools:Print(message, ...)
end

function Log.debug(message, ...)
    if SwiftdawnRaidTools:IsDebugging() then
        SwiftdawnRaidTools:Print("[DEBUG] "..message, ...)
    end
end