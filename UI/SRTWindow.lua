local SharedMedia = LibStub("LibSharedMedia-3.0")
MIN_WIDTH = 100
MIN_HEIGHT = 100

SRTWindow = {
    name = "",
    container = nil,
    popup = nil,
    header = nil,
    headerText = nil,
    headerButton = nil,
    main = nil,
    resizeButton = nil
}

SRTWindow.__index = SRTWindow

function SRTWindow.New(obj, name, height, width)
    local o = obj or {}
    setmetatable(o, SRTWindow)
    o.name = name
    o.height = height
    o.width = width
    return o
end

function SRTWindow:GetProfile()
    return SRT_Profile()[self.name]
end

function SRTWindow:GetAppearance()
    return self:GetProfile().appearance
end

function SRTWindow:GetTitleFont()
    SharedMedia:Fetch("font", self:GetAppearance().titleFontType)
end

function SRTWindow:Initialize()
    self.container = CreateFrame("Frame", "SRT_"..self.name, UIParent, "BackdropTemplate")
    self.popupMenu = CreateFrame("Frame", "SRT_"..self.name.."_Popup", UIParent, "BackdropTemplate")
    self.header = CreateFrame("Frame", "SRT_"..self.name.."_Header", self.container, "BackdropTemplate")
    self.headerText = self.header:CreateFontString("SRT_"..self.name.."_HeaderTitle", "OVERLAY", "GameFontNormalLarge")
    self.menuButton = CreateFrame("SRT_"..self.name.."_MenuButton", nil, self.header)
    self.main = CreateFrame("Frame", "SRT_"..self.name.."_Main", self.container)
    self.resizeButton = CreateFrame("Button", nil, self.container)

    self:SetupContainerFrame()
    self:SetupPopupMenu()
    self:SetupHeader()
    self:SetupResizeButton()

    self:UpdateAppearance()
end

function SRTWindow:SetupContainerFrame()
    self.container:SetSize(self.height, self.width)
    self.container:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })
    self.container:SetBackdropColor(0, 0, 0, self:GetAppearance().backgroundOpacity)
    self.container:SetMovable(true)
    self.container:EnableMouse(true)
    self.container:SetUserPlaced(true)
    self.container:SetClampedToScreen(true)
    self.container:RegisterForDrag("LeftButton")
    self.container:SetScript("OnDragStart", function(_)
        self.container:StartMoving()
        self.container:SetScript("OnUpdate", function()  -- Continuously update the frame size
            self:GetProfile().anchorX = tonumber(string.format("%.2f", self.container:GetLeft()))
            self:GetProfile().anchorY = tonumber(string.format("%.2f", self.container:GetTop() - GetScreenHeight()))
            LibStub("AceConfigRegistry-3.0"):NotifyChange("SwiftdawnRaidTools Appearance")
            self:UpdateAppearance()
        end)
    end)
    self.container:SetScript("OnDragStop", function(_)
        self.container:StopMovingOrSizing()
        self.container:SetScript("OnUpdate", nil)
    end)
    self.container:SetScale(self:GetAppearance().scale)
    self.container:SetClipsChildren(true)
    self.container:SetResizable(true)
    self.container:SetPoint("TOPLEFT", UIParent, "TOPLEFT", self:GetProfile().anchorX, self:GetProfile().anchorY)
end

function SRTWindow:SetupPopupMenu()
    self.popupMenu:SetClampedToScreen(true)
    self.popupMenu:SetSize(200, 50)
    self.popupMenu:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = {
            left = 2,
            right = 2,
            top = 2,
            bottom = 2,
        },
    })
    self.popupMenu:SetBackdropColor(0, 0, 0, 1)
    self.popupMenu:SetFrameStrata("DIALOG")
    self.popupMenu:Hide() -- Start hidden
end

function SRTWindow:SetupHeader()
    local titleFontSize = self:GetAppearance().titleFontSize
    local showPopup = function()
        if not SRT_IsTesting() and (InCombatLockdown() or SwiftdawnRaidTools:RaidAssignmentsInEncounter()) then
            return
        end
        self:UpdatePopupMenu()
        self.popupMenu:SetPoint("TOPLEFT", self.menuButton, "TOPLEFT", 0, 0)
        self.popupMenu:Show()
    end
    self.header:SetPoint("TOPLEFT", 0, 0)
    self.header:SetPoint("TOPRIGHT", 0, 0)
    self.header:SetMovable(true)
    self.header:EnableMouse(true)
    self.header:RegisterForDrag("LeftButton")
    self.header:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 16,
    })
    self.header:SetBackdropColor(0, 0, 0, self:GetAppearance().titleBarOpacity)
    self.header:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            showPopup()
        end
    end)
    self.header:SetScript("OnDragStart", function(_)
        self.container:StartMoving()
        self.container:SetScript("OnUpdate", function()  -- Continuously update the frame size
            self:GetProfile().anchorX = tonumber(string.format("%.2f", self.container:GetLeft()))
            self:GetProfile().anchorY = tonumber(string.format("%.2f", self.container:GetTop() - GetScreenHeight()))
            LibStub("AceConfigRegistry-3.0"):NotifyChange("SwiftdawnRaidTools Appearance")
            self:UpdateAppearance()
        end)
    end)
    self.header:SetScript("OnDragStop", function(_)
        self.container:StopMovingOrSizing()
        self.container:SetScript("OnUpdate", nil)
    end)

    self.header:SetScript("OnEnter", function()
        self.header:SetBackdropColor(0, 0, 0, 1)
        self.menuButton:SetAlpha(1)
    end)
    self.header:SetScript("OnLeave", function()
        self.header:SetBackdropColor(0, 0, 0, self:GetAppearance().titleBarOpacity)
        self.menuButton:SetAlpha(self:GetAppearance().titleBarOpacity)
    end)
    self.headerText:SetFont(self:AppearanceGetOverviewTitleFontType(), titleFontSize)
    self.headerText:SetPoint("LEFT", self.header, "LEFT", 10, 0)
    self.headerText:SetShadowOffset(1, -1)
    self.headerText:SetShadowColor(0, 0, 0, 1)
    self.headerText:SetJustifyH("LEFT")
    self.headerText:SetWordWrap(false)
    self.menuButton:SetSize(titleFontSize, titleFontSize)
    self.menuButton:SetPoint("RIGHT", self.header, "RIGHT", -3, 0)
    self.menuButton:SetNormalTexture("Gamepad_Ltr_Menu_32")
    self.menuButton:SetHighlightTexture("Gamepad_Ltr_Menu_32")
    self.menuButton:SetPushedTexture("Gamepad_Ltr_Menu_32")
    self.menuButton:SetAlpha(self:GetAppearance().titleBarOpacity)
    self.menuButton:SetScript("OnEnter", function()
        self.header:SetBackdropColor(0, 0, 0, 1)
        self.menuButton:SetAlpha(1)
    end)
    self.menuButton:SetScript("OnLeave", function()
        self.header:SetBackdropColor(0, 0, 0, self:GetAppearance().titleBarOpacity)
        self.menuButton:SetAlpha(self:GetAppearance().titleBarOpacity)
    end)
    self.menuButton:SetScript("OnClick", function()
        showPopup()
    end)
    self.menuButton:RegisterForClicks("AnyDown", "AnyUp")
end

function SRTWindow:SetupResizeButton()
    self.resizeButton:SetSize(12, 12)
    self.resizeButton:SetPoint("BOTTOMRIGHT")
    local resizeTexture = self.resizeButton:CreateTexture(nil, "BACKGROUND")
    resizeTexture:SetAllPoints(resizeButton)
    resizeTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up") -- Use a default WoW texture for resize
    self.resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    self.resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    self.resizeButton:SetAlpha(0)
    self.resizeButton:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            self.container:StartSizing("BOTTOMRIGHT")  -- Start resizing from bottom-right corner
            self.container:SetScript("OnUpdate", function()  -- Continuously update the frame size
                self:UpdateAppearance()
            end)

        end
    end)
    self.resizeButton:SetScript("OnEnter", function()
        resizeButton:SetAlpha(1)
    end)
    self.resizeButton:SetScript("OnLeave", function()
        resizeButton:SetAlpha(0)
    end)
    self.resizeButton:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            self.container:StopMovingOrSizing()  -- Stop the resizing action
            self.container:SetScript("OnUpdate", nil)  -- Stop updating frame size
        end
    end)
    self.container:SetScript("OnSizeChanged", function(_, width, height)
        if width < MIN_WIDTH then width = MIN_WIDTH end
        if height < MIN_HEIGHT then height = MIN_HEIGHT end
        self.container:SetSize(width, height)
    end)
end

function SRTWindow:UpdateAppearance()
    local titleFontSize = self:GetAppearance().titleFontSize
    self.container:SetScale(self:GetAppearance().scale)
    self.headerText:SetFont(self:GetTitleFont(), titleFontSize)
    local headerHeight = titleFontSize + 8
    self.header:SetHeight(headerHeight)
    local headerWidth = self.header:GetWidth()
    self.headerText:SetWidth(headerWidth - 10 - titleFontSize)
    self.main:SetPoint("TOPLEFT", 0, -headerHeight)
    self.main:SetPoint("TOPRIGHT", 0, -headerHeight)
    self.headerButton:SetSize(titleFontSize, titleFontSize)
    self.headerButton:SetAlpha(self:GetAppearance().titleBarOpacity)
    self.header:SetBackdropColor(0, 0, 0, self:GetAppearance().titleBarOpacity)
    local r, g, b = self.container:GetBackdropColor()
    self.overviewFrame:SetBackdropColor(r, g, b, self:GetAppearance().backgroundOpacity)
end

function SRTWindow:UpdatePopupMenu()

end

return SRTWindow