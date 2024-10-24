local SwiftdawnRaidTools = SwiftdawnRaidTools
local SharedMedia = LibStub("LibSharedMedia-3.0")

--- Customizable player frame for assignments and selection
---@class SRTPlayerFrame
SRTPlayerFrame = {
    cooldowns = {},
    selectedSpellID = 0,
}
SRTPlayerFrame.__index = SRTPlayerFrame

Style = {
    SINGLE_BUFF_LEFT = 1,
    ALL_BUFFS_RIGHT = 2
}

---@return SRTPlayerFrame
function SRTPlayerFrame:New(player, style, iconSize, font, fontSize)
    ---@class SRTPlayerFrame
    local obj = setmetatable({}, self)
    self.__index = self
    obj.player = player
    obj.style = style
    obj.iconSize = iconSize
    -- Setup container
    obj.container = CreateFrame("Frame", nil, nil, "BackdropTemplate")
    obj.container:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })
    obj.container:SetBackdropColor(0, 0, 0, 0)
    -- Setup buff icon
    -- Setup player name
    obj.playerText = obj.container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    obj.playerText:SetFont(SharedMedia:Fetch("font", font), fontSize)
    obj.playerText:SetTextColor(1, 1, 1, 1)
    obj.playerText:SetShadowOffset(1, -1)
    obj.playerText:SetShadowColor(0, 0, 0, 1)
    obj.playerText:SetJustifyH("LEFT")
    obj.playerText:SetHeight(fontSize)
    obj.playerText:SetText(player)
    return obj
end

---@return table|BackdropTemplate|Frame
function SRTPlayerFrame:CreateCooldown(spellID)
    if self.cooldowns[spellID] ~= nil then
        return self.cooldowns[spellID]
    end
    local cooldownFrame = CreateFrame("Frame", nil, self.container, "BackdropTemplate")
    cooldownFrame.spellID = spellID
    cooldownFrame:SetSize(self.iconSize, self.iconSize)
    cooldownFrame:SetPoint("LEFT", 0, 0)
    cooldownFrame.texture = cooldownFrame:CreateTexture(nil, "ARTWORK")
    cooldownFrame.texture:SetAllPoints()
    cooldownFrame.texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    local _, _, icon = GetSpellInfo(spellID)
    cooldownFrame.texture:SetTexture(icon)
    cooldownFrame.cooldown = CreateFrame("Cooldown", nil, cooldownFrame, "CooldownFrameTemplate")
    cooldownFrame.cooldown:SetAllPoints()
    self.cooldowns[spellID] = cooldownFrame
    return cooldownFrame
end

function SRTPlayerFrame:UpdateAppearance()
    self.container:Show()
    self.playerText:SetText(self.player)
    if #self.cooldowns == 0 then
        -- TODO: Maybe fix some rendering here if cooldowns were removed
        return
    end
    if self.style == Style.SINGLE_BUFF_LEFT then
        -- Hide all cooldown icons
        -- Grab selected cooldown and show icon
        local cooldown = self.cooldowns[self.selectedSpellID]
        cooldown:Show()
        -- Anchor to the left of the container
        cooldown:ClearAllPoints()
        cooldown:SetPoint("LEFT", self.container, "LEFT", 4, 0)
        -- Anchor player name to the right of the icon
        self.playerText:ClearAllPoints()
        self.playerText:SetPoint("LEFT", cooldown, "RIGHT", 4, 0)
    elseif self.style == Style.ALL_BUFFS_RIGHT then
        -- Anchor player name to the left of the container
        self.playerText:ClearAllPoints()
        self.playerText:SetPoint("LEFT", self.container, "LEFT", 4, 0)
        -- Anchor cooldowns in a row to the right of the player name
        local lastCooldown
        for _, cooldown in pairs(self.cooldowns) do
            cooldown:Show()
            cooldown:ClearAllPoints()
            if not lastCooldown then
                cooldown:SetPoint("LEFT", self.playerText, "RIGHT", 4, 0)
            else
                cooldown:SetPoint("LEFT", lastCooldown, "RIGHT", 4, 0)
            end
            lastCooldown = cooldown
        end
    end
end

--- Fake Frame methods!

function SRTPlayerFrame:SetMouseClickEnabled(...)
    self.container:SetMouseClickEnabled(...)
end

function SRTPlayerFrame:SetScript(...)
    self.container:SetScript(...)
end

function SRTPlayerFrame:Show()
    self.container:Show()
end

function SRTPlayerFrame:Hide()
    self.container:Hide()
end

function SRTPlayerFrame:ClearAllPoints()
    self.container:ClearAllPoints()
end

function SRTPlayerFrame:SetPoint(...)
    self.container:SetPoint(...)
end

