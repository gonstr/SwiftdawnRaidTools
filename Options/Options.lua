local SwiftdawnRaidTools = SwiftdawnRaidTools
local insert = table.insert

local SharedMedia = LibStub("LibSharedMedia-3.0")
local AceGUI = LibStub("AceGUI-3.0")

do
    local Type = "ImportMultiLineEditBox"
    local Version = 1

    local function Constructor()
        local widget = AceGUI:Create("MultiLineEditBox")
        widget.button:Disable()

        -- Error label
        -- TODO: Improve this.
        -- This error label is floating beneth the windows.
        -- Only works if there's nothing below the input.
        local errorLabel = widget.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        errorLabel:SetPoint("TOPLEFT", widget.frame, "BOTTOMLEFT", 0, -2)
        errorLabel:SetPoint("TOPRIGHT", widget.frame, "BOTTOMRIGHT", 0, -2)
        errorLabel:SetHeight(20)
        errorLabel:SetJustifyH("LEFT")
        errorLabel:SetJustifyV("TOP")
        errorLabel:SetTextColor(1, 0, 0) -- Red
        errorLabel:SetText("")
        widget.errorLabel = errorLabel

        function widget:Validate()
            local text = self:GetText()

            if text then
                text = text:trim()
            end
            
            if not text or text == "" then
                return true
            end

            local ok, result = SwiftdawnRaidTools:ImportYAML(text)

            if not ok then
                self.errorLabel:SetText(result)
                return false
            end

            self.errorLabel:SetText("")
            return true
        end

        -- Validate on text changed
        widget.editBox:HookScript("OnTextChanged", function(_, userInput)
            if userInput then
                if widget:Validate() then
                    widget.button:Enable()
                else
                    widget.button:Disable()
                end
            end
        end)

        return widget
    end

    AceGUI:RegisterWidgetType(Type, Constructor, Version)
end

local mainOptions = {
    name = "Swiftdawn Raid Tools " .. SwiftdawnRaidTools.VERSION,
    type = "group",
    args =  {
        buttonGroup = {
            type = "group",
            inline = true,
            name = "",
            order = 1,
            args = {
                toggleOverview = {
                    type = "execute",
                    name = "Toggle Overview",
                    desc = "Toggle Overview visiblity.",
                    func = function()
                        SwiftdawnRaidTools.db.profile.overview.show = not SwiftdawnRaidTools.db.profile.overview.show
                        SwiftdawnRaidTools:OverviewUpdate()
                    end,
                    order = 1,
                },
                toggleAnchors = {
                    type = "execute",
                    name = "Toggle Anchors",
                    desc = "Toggle Anchors Visibility.",
                    func = function()
                        SwiftdawnRaidTools:NotificationsToggleFrameLock()
                    end,
                    order = 2,
                },
                toggleTestMode = {
                    type = "execute",
                    name = "Toggle Test Mode",
                    desc = "Toggle Test Mode on and off.",
                    func = function()
                        if not InCombatLockdown() then
                            SwiftdawnRaidTools:TestModeToggle()
                        end
                    end,
                    order = 3,
                },
            },
        },
    },
}

local notificationOptions = {
    name = "Notifications",
    type = "group",
    args =  {
        showOnlyOwnNotificationsCheckbox = {
            type = "toggle",
            name = "Limit Notifications",
            desc = "Only show Raid Notifications that apply to You.",
            width = "full",
            order = 1,
            get = function() return SwiftdawnRaidTools.db.profile.options.notifications.showOnlyOwnNotifications end,
            set = function(_, value) SwiftdawnRaidTools.db.profile.options.notifications.showOnlyOwnNotifications = value end,
        },
        showOnlyOwnNotificationsDescription = {
            type = "description",
            name = "Only show Raid Notifications that apply to you.",
            order = 2,
        },
        separator1 = {
            type = "description",
            name = " ",
            order = 3,
        },
        muteCheckbox = {
            type = "toggle",
            name = "Mute Sounds",
            desc = "Mute all Raid Notification Sounds.",
            width = "full",
            order = 4,
            get = function() return SwiftdawnRaidTools.db.profile.options.notifications.mute end,
            set = function(_, value) SwiftdawnRaidTools.db.profile.options.notifications.mute = value end,
        },
        muteDescription = {
            type = "description",
            name = "Mute all Raid Notification Sounds.",
            order = 5,
        },
    },
}

local appearanceOptions = {
    name = "Appearance",
    type = "group",
    args =  {
        toggleTestMode = {
            type = "execute",
            name = "Toggle Test Mode",
            desc = "Toggle Test Mode to see example Raid Assignments and Notifications.",
            func = function()
                if not InCombatLockdown() then
                    SwiftdawnRaidTools:TestModeToggle()
                end
            end,
            order = 1,
        },
        separator0 = {
            type = "description",
            name = " ",
            width = "full",
            order = 10,
        },
        overviewOptionsDescription = {
            type = "description",
            name = "Overview",
            width = "full",
            fontSize = "large",
            order = 11,
        },
        overviewScaleDescription = {
            type = "description",
            name = "Scale",
            width = "normal",
            order = 12,
        },
        overviewScale = {
            type = "range",
            min = 0.6,
            max = 1.4,
            isPercent = true,
            name = "",
            desc = "Set the Overview UI Scale.",
            width = "double",
            order = 13,
            get = function() return SwiftdawnRaidTools.db.profile.options.appearance.overviewScale end,
            set = function(_, value)
                SwiftdawnRaidTools.db.profile.options.appearance.overviewScale = value

                SwiftdawnRaidTools:OverviewUpdateAppearance()
            end,
        },
        overviewTitleFontDescription = {
            type = "description",
            name = "Encounter Name",
            width = "normal",
            order = 21,
        },
        overviewTitleFontType = {
            type = "select",
            name = "",
            desc = "Set the font used in the overview title",
            values = SharedMedia:HashTable("font"),
            dialogControl = "LSM30_Font",
            width = "normal",
            order = 22,
            get = function() return SwiftdawnRaidTools.db.profile.options.appearance.overviewTitleFontType end,
            set = function(_, value)
                SwiftdawnRaidTools.db.profile.options.appearance.overviewTitleFontType = value

                SwiftdawnRaidTools:OverviewUpdateAppearance()
                SwiftdawnRaidTools:NotificationsUpdateAppearance()
            end,
        },
        overviewTitleFontSize = {
            type = "range",
            name = "",
            desc = "Set the font size used in the overview title",
            min = 8,
            max = 26,
            step = 1,
            width = "normal",
            order = 23,
            get = function() return SwiftdawnRaidTools.db.profile.options.appearance.overviewTitleFontSize end,
            set = function(self, key, value)
                SwiftdawnRaidTools.db.profile.options.appearance.overviewTitleFontSize = key

                SwiftdawnRaidTools:OverviewUpdateAppearance()
                SwiftdawnRaidTools:NotificationsUpdateAppearance()
            end,
        },
        overviewHeaderFontDescription = {
            type = "description",
            name = "Boss Ability",
            width = "normal",
            order = 31,
        },
        overviewHeaderFontType = {
            type = "select",
            name = "",
            desc = "Set the font used in the overview header",
            values = SharedMedia:HashTable("font"),
            dialogControl = "LSM30_Font",
            width = "normal",
            order = 32,
            get = function() return SwiftdawnRaidTools.db.profile.options.appearance.overviewHeaderFontType end,
            set = function(_, value)
                SwiftdawnRaidTools.db.profile.options.appearance.overviewHeaderFontType = value

                SwiftdawnRaidTools:OverviewUpdateAppearance()
                SwiftdawnRaidTools:NotificationsUpdateAppearance()
            end,
        },
        overviewHeaderFontSize = {
            type = "range",
            name = "",
            desc = "Set the font sze used in the overview header",
            min = 8,
            max = 26,
            step = 1,
            width = "normal",
            order = 33,
            get = function() return SwiftdawnRaidTools.db.profile.options.appearance.overviewHeaderFontSize end,
            set = function(self, key, value)
                SwiftdawnRaidTools.db.profile.options.appearance.overviewHeaderFontSize = key

                SwiftdawnRaidTools:OverviewUpdateAppearance()
                SwiftdawnRaidTools:NotificationsUpdateAppearance()
            end,
        },
        overviewPlayerFontDescription = {
            type = "description",
            name = "Player Names",
            width = "normal",
            order = 41,
        },
        overviewPlayerFontType = {
            type = "select",
            name = "",
            desc = "Set the font used in the overview player name",
            values = SharedMedia:HashTable("font"),
            dialogControl = "LSM30_Font",
            width = "normal",
            order = 42,
            get = function() return SwiftdawnRaidTools.db.profile.options.appearance.overviewPlayerFontType end,
            set = function(_, value)
                SwiftdawnRaidTools.db.profile.options.appearance.overviewPlayerFontType = value

                SwiftdawnRaidTools:OverviewUpdateAppearance()
                SwiftdawnRaidTools:NotificationsUpdateAppearance()
            end,
        },
        overviewPlayerFontSize = {
            type = "range",
            name = "",
            desc = "Set the font size used in the overview player name",
            min = 8,
            max = 26,
            step = 1,
            width = "normal",
            order = 43,
            get = function() return SwiftdawnRaidTools.db.profile.options.appearance.overviewPlayerFontSize end,
            set = function(self, key, value)
                SwiftdawnRaidTools.db.profile.options.appearance.overviewPlayerFontSize = key

                SwiftdawnRaidTools:OverviewUpdateAppearance()
                SwiftdawnRaidTools:NotificationsUpdateAppearance()
            end,
        },
        overviewIconSizeDescription = {
            type = "description",
            name = "Icon Size",
            width = "normal",
            order = 51,
        },
        overviewIconSize = {
            type = "range",
            min = 12,
            max = 32,
            step = 1,
            name = "",
            desc = "Set the ability icon size.",
            width = "double",
            order = 52,
            get = function() return SwiftdawnRaidTools.db.profile.options.appearance.overviewIconSize end,
            set = function(_, value)
                SwiftdawnRaidTools.db.profile.options.appearance.overviewIconSize = value

                SwiftdawnRaidTools:OverviewUpdateAppearance()
            end,
        },
        overviewBackgroundOpacityDescription = {
            type = "description",
            name = "Background Opacity",
            width = "normal",
            order = 53,
        },
        overviewBackgroundOpacity = {
            type = "range",
            min = 0,
            max = 1,
            isPercent = true,
            name = "",
            desc = "Set the Overview Background Opacity.",
            width = "double",
            order = 54,
            get = function() return SwiftdawnRaidTools.db.profile.options.appearance.overviewBackgroundOpacity end,
            set = function(_, value)
                SwiftdawnRaidTools.db.profile.options.appearance.overviewBackgroundOpacity = value

                SwiftdawnRaidTools:OverviewUpdateAppearance()
            end,
        },
        separator3 = {
            type = "description",
            name = " ",
            width = "full",
            order = 55,
        },
        notificationsOptionsDescription = {
            type = "description",
            name = "Notifications",
            width = "full",
            fontSize = "large",
            order = 56,
        },
        separator4 = {
            type = "description",
            name = " ",
            width = "full",
            order = 60,
        },
        notificationsScaleDescription = {
            type = "description",
            name = "Scale",
            width = "normal",
            order = 61,
        },
        notificationsScale = {
            type = "range",
            min = 0.6,
            max = 1.4,
            isPercent = true,
            name = "",
            desc = "Set the Notifications UI Scale.",
            width = "double",
            order = 62,
            get = function() return SwiftdawnRaidTools.db.profile.options.appearance.notificationsScale end,
            set = function(_, value)
                SwiftdawnRaidTools.db.profile.options.appearance.notificationsScale = value

                SwiftdawnRaidTools:NotificationsUpdateAppearance()
            end,
        },
        notificationsHeaderFontDescription = {
            type = "description",
            name = "Boss Ability",
            width = "normal",
            order = 71,
        },
        notificationsHeaderFontType = {
            type = "select",
            name = "",
            desc = "Sets the font used in notification header",
            values = SharedMedia:HashTable("font"),
            dialogControl = "LSM30_Font",
            width = "normal",
            order = 72,
            get = function() return SwiftdawnRaidTools.db.profile.options.appearance.notificationsHeaderFontType end,
            set = function(_, value)
                SwiftdawnRaidTools.db.profile.options.appearance.notificationsHeaderFontType = value

                SwiftdawnRaidTools:OverviewUpdateAppearance()
                SwiftdawnRaidTools:NotificationsUpdateAppearance()
            end,
        },
        notificationsHeaderFontSize = {
            type = "range",
            name = "",
            desc = "Sets the font size used in notification header",
            min = 8,
            max = 26,
            step = 1,
            width = "normal",
            order = 73,
            get = function() return SwiftdawnRaidTools.db.profile.options.appearance.notificationsHeaderFontSize end,
            set = function(self, key, value)
                SwiftdawnRaidTools.db.profile.options.appearance.notificationsHeaderFontSize = key

                SwiftdawnRaidTools:OverviewUpdateAppearance()
                SwiftdawnRaidTools:NotificationsUpdateAppearance()
            end,
        },
        notificationsPlayerFontDescription = {
            type = "description",
            name = "Player Names",
            width = "normal",
            order = 81,
        },
        notificationsPlayerFontType = {
            type = "select",
            name = "",
            desc = "Set the Font used in Notifications.",
            values = SharedMedia:HashTable("font"),
            dialogControl = "LSM30_Font",
            width = "normal",
            order = 82,
            get = function() return SwiftdawnRaidTools.db.profile.options.appearance.notificationsPlayerFontType end,
            set = function(_, value)
                SwiftdawnRaidTools.db.profile.options.appearance.notificationsPlayerFontType = value

                SwiftdawnRaidTools:OverviewUpdateAppearance()
                SwiftdawnRaidTools:NotificationsUpdateAppearance()
            end,
        },
        notificationsPlayerFontSize = {
            type = "range",
            name = "",
            desc = "Set the Font Size used in Notifications.",
            min = 8,
            max = 26,
            step = 1,
            width = "normal",
            order = 83,
            get = function() return SwiftdawnRaidTools.db.profile.options.appearance.notificationsPlayerFontSize end,
            set = function(self, key, value)
                SwiftdawnRaidTools.db.profile.options.appearance.notificationsPlayerFontSize = key

                SwiftdawnRaidTools:OverviewUpdateAppearance()
                SwiftdawnRaidTools:NotificationsUpdateAppearance()
            end,
        },
        notificationsIconSizeDescription = {
            type = "description",
            name = "Icon Size",
            width = "normal",
            order = 91,
        },
        notificationsIconSize = {
            type = "range",
            min = 12,
            max = 32,
            step = 1,
            name = "",
            desc = "Set the notification icon size",
            width = "double",
            order = 92,
            get = function() return SwiftdawnRaidTools.db.profile.options.appearance.notificationsIconSize end,
            set = function(_, value)
                SwiftdawnRaidTools.db.profile.options.appearance.notificationsIconSize = value

                SwiftdawnRaidTools:NotificationsUpdateAppearance()
            end,
        },
        notificationsBackgroundOpacityDescription = {
            type = "description",
            name = "Background Opacity",
            width = "normal",
            order = 93,
        },
        notificationsBackgroundOpacity = {
            type = "range",
            min = 0,
            max = 1,
            isPercent = true,
            name = "",
            desc = "Set the Notifications Background Opacity.",
            width = "double",
            order = 94,
            get = function() return SwiftdawnRaidTools.db.profile.options.appearance.notificationsBackgroundOpacity end,
            set = function(_, value)
                SwiftdawnRaidTools.db.profile.options.appearance.notificationsBackgroundOpacity = value

                SwiftdawnRaidTools:NotificationsUpdateAppearance()
            end,
        },
    },
}

local notificationOptions = {
    name = "Notifications",
    type = "group",
    args =  {
        showOnlyOwnNotificationsCheckbox = {
            type = "toggle",
            name = "Limit Notifications",
            desc = "Only show Raid Notifications that apply to You.",
            width = "full",
            order = 1,
            get = function() return SwiftdawnRaidTools.db.profile.options.notifications.showOnlyOwnNotifications end,
            set = function(_, value) SwiftdawnRaidTools.db.profile.options.notifications.showOnlyOwnNotifications = value end,
        },
        showOnlyOwnNotificationsDescription = {
            type = "description",
            name = "Only show Raid Notifications that apply to you.",
            order = 2,
        },
        separator = {
            type = "description",
            name = " ",
            order = 3,
        },
        muteCheckbox = {
            type = "toggle",
            name = "Mute Sounds",
            desc = "Mute all Raid Notification Sounds.",
            width = "full",
            order = 4,
            get = function() return SwiftdawnRaidTools.db.profile.options.notifications.mute end,
            set = function(_, value)SwiftdawnRaidTools.db.profile.options.notifications.mute = value end,
        },
        muteDescription = {
            type = "description",
            name = "Mute all Raid Notification Sounds.",
            order = 5,
        },
    },
}

local fojjiIntegrationOptions = {
    name = "Fojji Integration (Experimental)",
    type = "group",
    args = {
        weakAuraText = {
            type = "description",
            name = "Fojji Integration require the use of a Helper WeakAura. This WeakAura is only required if you are the Raid Leader and configure assignments that are activated by Fojji timers.",
            order = 1,
        },
        separator = {
            type = "description",
            name = " ",
            order = 2,
        },
        weakAurasNotInstalledError = {
            type = "description",
            fontSize = "medium",
            name = "|cffff0000WeakAuras is not installed.|r",
            order = 3,
            hidden = function() return SwiftdawnRaidTools:WeakAurasIsInstalled() end
        },
        helperWeakAuraInstalledMessage = {
            type = "description",
            fontSize = "medium",
            name = "|cff00ff00Swiftdawn Raid Tools Helper WeakAura Installed.|r",
            order = 4,
            hidden = function() return not SwiftdawnRaidTools:WeakaurasIsHelperInstalled() end
        },
        installWeakAuraButton = {
            type = "execute",
            name = "Install WeakAura",
            desc = "Install the Swiftdawn Raid Tools Helper WeakAura.",
            func = function() SwiftdawnRaidTools:WeakAurasInstallHelper(function()
                LibStub("AceConfigRegistry-3.0"):NotifyChange("SwiftdawnRaidTools Fojji Integration")
            end) end,
            order = 5,
            hidden = function() return not SwiftdawnRaidTools:WeakAurasIsInstalled() or SwiftdawnRaidTools:WeakaurasIsHelperInstalled() end
        },
    },
}

local importDescription = [[
Paste your raid assignments and other import data below. The import should be valid YAML.

For the full Import API spec, visit https://github.com/gonstr/SwiftdawnRaidTools.
]]

local importOptions = {
    name = "Import",
    type = "group",
    args = {
        description = {
            type = "description",
            name = importDescription,
            fontSize = "medium",
            order = 1,
        },
        import = {
            type = "input",
            name = "Import",
            desc = "Paste your import data here.",
            multiline = 25,
            width = "full",
            dialogControl = "ImportMultiLineEditBox",
            order = 2,
            get = function() return SwiftdawnRaidTools.db.profile.options.import end,
            set = function(_, val)
                if val then
                    val = val:trim()
                end

                SwiftdawnRaidTools:TestModeEnd()

                SwiftdawnRaidTools.db.profile.options.import = val

                SwiftdawnRaidTools.db.profile.data.encounters = {}
                SwiftdawnRaidTools.db.profile.data.encountersId = nil

                if val ~= nil and val ~= "" then
                    local _, result = SwiftdawnRaidTools:ImportYAML(val)
                    local encounters, encountersId = SwiftdawnRaidTools:ImportCreateEncountersData(result)

                    SwiftdawnRaidTools.db.profile.data.encountersId = encountersId
                    SwiftdawnRaidTools.db.profile.data.encounters = encounters
                end

                SwiftdawnRaidTools:SyncSchedule()
                SwiftdawnRaidTools:OverviewUpdate()
            end,
        },
    },
}

function SwiftdawnRaidTools:OptionsInit()
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SwiftdawnRaidTools", mainOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SwiftdawnRaidTools", "Swiftdawn Raid Tools")


    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SwiftdawnRaidTools Appearance", appearanceOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SwiftdawnRaidTools Appearance", "Appearance", "Swiftdawn Raid Tools")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SwiftdawnRaidTools Notifications", notificationOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SwiftdawnRaidTools Notifications", "Notifications", "Swiftdawn Raid Tools")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SwiftdawnRaidTools Fojji Integration", fojjiIntegrationOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SwiftdawnRaidTools Fojji Integration", "Fojji Integration", "Swiftdawn Raid Tools")
    
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SwiftdawnRaidTools Import", importOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SwiftdawnRaidTools Import", "Import", "Swiftdawn Raid Tools")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SwiftdawnRaidTools Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SwiftdawnRaidTools Profiles", "Profiles", "Swiftdawn Raid Tools")
end

function SwiftdawnRaidTools:ToggleFrameLock(lock) end

function SwiftdawnRaidTools:OnConfigChanged()
    SwiftdawnRaidTools:UpdatePartyFramesVisibility(self.db.profile.hideBlizPartyFrame)
    SwiftdawnRaidTools:UpdateArenaFramesVisibility(self.db.profile.hideBlizArenaFrame)
    SwiftdawnRaidTools:UpdateAuraDurationsVisibility()
end

SwiftdawnRaidTools:RegisterChatCommand("art", function()
    LibStub("AceConfigDialog-3.0"):Open("SwiftdawnRaidTools")
end)
