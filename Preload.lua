SwiftdawnRaidTools = LibStub("AceAddon-3.0"):NewAddon("SwiftdawnRaidTools", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")

SwiftdawnRaidTools.DEBUG = false
SwiftdawnRaidTools.TEST = false

SwiftdawnRaidTools.PREFIX_SYNC = "SRT-S"
SwiftdawnRaidTools.PREFIX_SYNC_PROGRESS = "SRT-SP"
SwiftdawnRaidTools.PREFIX_MAIN = "SRT-M"

SwiftdawnRaidTools.VERSION = GetAddOnMetadata("SwiftdawnRaidTools", "Version")
SwiftdawnRaidTools.IS_DEV = SwiftdawnRaidTools.VERSION == '\@project-version\@'

-- AceDB defaults
SwiftdawnRaidTools.defaults = {
    profile = {
        options = {
            import = "",
        },
        data = {
            encountersProgress = nil,
            encountersId = nil,
            encounters = {}
        },
        minimap = {},
        notifications = {
            showOnlyOwnNotifications = false,
            mute = false,
            anchorX = GetScreenWidth()/2,
            anchorY = -(GetScreenHeight()/2) + 200,
            appearance = {
                scale = 1.2,
                headerFontType = "Friz Quadrata TT",
                headerFontSize = 10,
                playerFontType = "Friz Quadrata TT",
                playerFontSize = 10,
                countdownFontType = "Friz Quadrata TT",
                countdownFontSize = 10,
                backgroundOpacity = 0.9,
                iconSize = 16
            }
        },
        overview = {
            anchorX = 0,
            anchorY = 0,
            selectedEncounterId = nil,
            locked = false,
            show = true,
            appearance = {
                scale = 1.0,
                titleFontType = "Friz Quadrata TT",
                titleFontSize = 10,
                headerFontType = "Friz Quadrata TT",
                headerFontSize = 10,
                playerFontType = "Friz Quadrata TT",
                playerFontSize = 10,
                titleBarOpacity = 0.8,
                backgroundOpacity = 0.4,
                iconSize = 14
            }
        },
        debuglog = {
            anchorX = 0,
            anchorY = -(GetScreenHeight()/2),
            locked = false,
            show = false,
            scrollToBottom = true,
            appearance = {
                scale = 1.0,
                titleFontType = "Friz Quadrata TT",
                titleFontSize = 10,
                logFontType = "Friz Quadrata TT",
                logFontSize = 10,
                titleBarOpacity = 0.8,
                backgroundOpacity = 0.4,
                iconSize = 14
            }
        }
    },
}