local SwiftdawnRaidTools = SwiftdawnRaidTools

FrameBuilder = {}
FrameBuilder.__index = FrameBuilder

---@return table|BackdropTemplate|Frame
---@param parentFrame Frame
---@param playerName string
---@param classFileName string
---@param width integer
---@param height integer
---@param font FontFile
---@param fontSize integer
---@param iconSize integer
function FrameBuilder.CreatePlayerFrame(parentFrame, playerName, classFileName, width, height, font, fontSize, iconSize)
    local playerFrame = CreateFrame("Frame", parentFrame:GetName() .. "_" .. playerName, parentFrame, "BackdropTemplate")
    playerFrame:SetSize(width, height)
    playerFrame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 16,
    })
    playerFrame:SetBackdropColor(0, 0, 0, 0)

    playerFrame.name = playerFrame.name or playerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    playerFrame.name:SetPoint("LEFT", playerFrame, "LEFT", 5, 0)
    playerFrame.name:SetFont(font, fontSize)
    playerFrame.name:SetText(strsplit("-", playerName))

    playerFrame.spells = playerFrame.spells or {}
    local color
    for i, spellID in ipairs(SwiftdawnRaidTools:SpellsGetClassSpells(classFileName)) do
        color = SwiftdawnRaidTools:GetSpellColor(spellID)
        local _, _, icon, _, _, _, _, _ = GetSpellInfo(spellID)
        local iconFrame = playerFrame.spells[i] or CreateFrame("Frame", nil, playerFrame)
        iconFrame:SetSize(iconSize, iconSize)
        if i == 1 then
            iconFrame:SetPoint("LEFT", playerFrame.name, "RIGHT", 7, 0)
        else
            iconFrame:SetPoint("LEFT", playerFrame.spells[i-1], "RIGHT", 7, 0)
        end
        iconFrame.icon = iconFrame.icon or iconFrame:CreateTexture(nil, "ARTWORK")
        iconFrame.icon:SetAllPoints()
        iconFrame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        iconFrame.icon:SetTexture(icon)
        playerFrame.spells[i] = iconFrame
    end
    color = color or { r = 1, g = 1, b = 1 }
    playerFrame.name:SetTextColor(color.r, color.g, color.b)

    playerFrame:SetScript("OnEnter", function () playerFrame:SetBackdropColor(1, 1, 1, 0.4) end)
    playerFrame:SetScript("OnLeave", function () playerFrame:SetBackdropColor(0, 0, 0, 0) end)

    return playerFrame
end

---@return table|BackdropTemplate|Frame
---@param parentFrame Frame
---@param height integer
function FrameBuilder.CreateAssignmentGroupFrame(parentFrame, height)
    local groupFrame = CreateFrame("Frame", nil, parentFrame, "BackdropTemplate")
    groupFrame:SetHeight(height)
    groupFrame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 16,
    })
    groupFrame:SetBackdropColor(0, 0, 0, 0)
    groupFrame.assignments = {}
    return groupFrame
end

---@param groupFrame table|BackdropTemplate|Frame
---@param prevFrame? Frame
---@param group table
---@param uuid string
---@param index integer
---@param font FontFile
---@param fontSize integer
---@param iconSize integer
function FrameBuilder.UpdateAssignmentGroupFrame(groupFrame, prevFrame, group, uuid, index, font, fontSize, iconSize)
    groupFrame:Show()
    groupFrame.uuid = uuid
    groupFrame.index = index
    groupFrame:ClearAllPoints()
    if prevFrame then
        groupFrame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, 0)
        groupFrame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0, 0)
    else
        groupFrame:SetPoint("TOPLEFT", groupFrame:GetParent(), "TOPLEFT", 0, -16)
        groupFrame:SetPoint("TOPRIGHT", groupFrame:GetParent(), "TOPRIGHT", 0, -16)
    end
    for _, cd in pairs(groupFrame.assignments) do
        cd:Hide()
    end
    for assignmentIndex, assignment in ipairs(group) do
        local assignmentFrame = groupFrame.assignments[assignmentIndex] or FrameBuilder.CreateAssignmentFrame(groupFrame, font, fontSize, iconSize)
        FrameBuilder.UpdateAssignmentFrame(assignmentFrame, assignment, assignmentIndex)
        assignmentFrame.groupIndex = index
        groupFrame.assignments[assignmentIndex] = assignmentFrame
    end
end

---@return table|BackdropTemplate|Frame
---@param parentFrame table|BackdropTemplate|Frame
---@param font any
---@param fontSize integer
---@param iconSize integer
function FrameBuilder.CreateAssignmentFrame(parentFrame, font, fontSize, iconSize)
    local assignmentFrame = CreateFrame("Frame", nil, parentFrame, "BackdropTemplate")
    assignmentFrame.iconFrame = CreateFrame("Frame", nil, assignmentFrame, "BackdropTemplate")
    assignmentFrame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 16,
    })
    assignmentFrame:SetBackdropColor(0, 0, 0, 0)
    assignmentFrame:SetScript("OnEnter", function() assignmentFrame:SetBackdropColor(1, 1, 1, 0.4) end)
    assignmentFrame:SetScript("OnLeave", function() assignmentFrame:SetBackdropColor(0, 0, 0, 0) end)
    assignmentFrame:SetMouseClickEnabled(true)
    assignmentFrame.iconFrame:SetSize(iconSize, iconSize)
    assignmentFrame.iconFrame:SetPoint("LEFT", 5, 0)
    assignmentFrame.cooldownFrame = CreateFrame("Cooldown", nil, assignmentFrame.iconFrame, "CooldownFrameTemplate")
    assignmentFrame.cooldownFrame:SetAllPoints()
    assignmentFrame.iconFrame.cooldown = assignmentFrame.cooldownFrame
    assignmentFrame.icon = assignmentFrame.iconFrame:CreateTexture(nil, "ARTWORK")
    assignmentFrame.icon:SetAllPoints()
    assignmentFrame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    assignmentFrame.text = assignmentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    assignmentFrame.text:SetFont(font, fontSize)
    assignmentFrame.text:SetTextColor(1, 1, 1, 1)
    assignmentFrame.text:SetPoint("LEFT", assignmentFrame.iconFrame, "CENTER", iconSize/2+4, -1)
    return assignmentFrame
end

---@param assignmentFrame table|BackdropTemplate|Frame
---@param assignment table
---@param assignmentIndex integer
function FrameBuilder.UpdateAssignmentFrame(assignmentFrame, assignment, assignmentIndex)
    assignmentFrame:Show()
    assignmentFrame.assignment = assignment
    assignmentFrame.player = assignment.player
    assignmentFrame.spellId = assignment.spell_id
    local _, _, icon = GetSpellInfo(assignment.spell_id)
    assignmentFrame.icon:SetTexture(icon)
    assignmentFrame.text:SetText(assignment.player)
    local color = SwiftdawnRaidTools:GetSpellColor(assignment.spell_id)
    assignmentFrame.text:SetTextColor(color.r, color.g, color.b)
    assignmentFrame.cooldownFrame:Clear()
    assignmentFrame:ClearAllPoints()
    if assignmentIndex > 1 then
        assignmentFrame:SetPoint("BOTTOMLEFT", assignmentFrame:GetParent(), "BOTTOM")
        assignmentFrame:SetPoint("TOPRIGHT", 0, 0)
    else
        assignmentFrame:SetPoint("BOTTOMLEFT")
        assignmentFrame:SetPoint("TOPRIGHT", assignmentFrame:GetParent(), "TOP", 0, 0)
    end
end

---@return table|BackdropTemplate|Frame
function FrameBuilder.CreateLargeSpellFrame(parentFrame)
    local spellFrame = CreateFrame("Frame", nil, parentFrame, "BackdropTemplate")
    spellFrame.iconFrame = CreateFrame("Frame", nil, spellFrame)
    spellFrame.iconFrame:SetPoint("TOPLEFT", 10, -5)
    spellFrame.icon = spellFrame.iconFrame:CreateTexture(nil, "ARTWORK")
    spellFrame.icon:SetAllPoints()
    spellFrame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    spellFrame.name = spellFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    spellFrame.name:SetTextColor(1, 1, 1, 1)
    spellFrame.name:SetPoint("TOPLEFT", spellFrame.iconFrame, "TOPRIGHT", 7, -1)

    spellFrame.castTimeText = spellFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    spellFrame.castTimeText:SetTextColor(1, 1, 1, 1)
    spellFrame.castTimeText:SetPoint("TOPLEFT", spellFrame.name, "BOTTOMLEFT", 0, -3)

    spellFrame.rangeText = spellFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    spellFrame.rangeText:SetTextColor(1, 1, 1, 1)
    spellFrame.rangeText:SetPoint("TOPLEFT", spellFrame.castTimeText, "BOTTOMLEFT", 0, -3)

    spellFrame.descriptionText = spellFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    spellFrame.descriptionText:SetTextColor(1, 1, 1, 1)
    spellFrame.descriptionText:SetPoint("TOPLEFT", spellFrame.rangeText, "BOTTOMLEFT", 0, -3)
    return spellFrame
end

function FrameBuilder.UpdateLargeSpellFrame(spellFrame, spellID, font, fontSize, iconSize)
    local name, rank, icon, castTime, minRange, maxRange, spellID, originalIcon = GetSpellInfo(spellID)
    spellFrame:Show()
    spellFrame.spellID = spellID
    spellFrame.iconFrame:SetSize(iconSize, iconSize)
    spellFrame.icon:SetTexture(icon)
    spellFrame.name:SetFont(font, fontSize+2)
    spellFrame.name:SetText(name)
    spellFrame.castTimeText:SetFont(font, fontSize)
    spellFrame.castTimeText:SetText(string.format("Cast time: %ds", castTime/1000))
    spellFrame.rangeText:SetFont(font, fontSize)
    spellFrame.rangeText:SetText(string.format("Range: %d to %d yards", minRange, maxRange))
    local description = GetSpellDescription(spellID)
    spellFrame.descriptionText:SetFont(font, fontSize)
    spellFrame.descriptionText:SetText(string.format("%s", description))
    spellFrame.descriptionText:SetWidth(280 - iconSize - 27)
    spellFrame.descriptionText:SetJustifyH("LEFT")
    spellFrame.descriptionText:SetHeight(spellFrame.descriptionText:GetStringHeight())
    local textHeight = 5 + 1 + spellFrame.name:GetStringHeight() + 3 + spellFrame.castTimeText:GetStringHeight() + 3 + spellFrame.rangeText:GetStringHeight() + 3 + spellFrame.descriptionText:GetStringHeight() + 10
    local height = iconSize > textHeight and iconSize+10 or textHeight
    spellFrame:SetHeight(height)
    spellFrame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = spellFrame:GetHeight(),
    })
    spellFrame:SetBackdropColor(0, 0, 0, 0)
end

---@return table|BackdropTemplate|Frame
function FrameBuilder.CreateButton(parentFrame, width, height, text, color, colorHightlight)
    local button = CreateFrame("Frame", "SRT_AssignmentExplorer_ReplaceButton", parentFrame, "BackdropTemplate")
    button.width = width
    button.height = height
    button.displayText = text
    button.color = color
    button.colorHightlight = colorHightlight
    button:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 25,
    })
    button:SetScript("OnLeave", function(b) b:SetBackdropColor(button.color.r, button.color.g, button.color.b, button.color.a) end)
    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.text:SetAllPoints()
    button.text:SetTextColor(1, 1, 1, 1)
    FrameBuilder.UpdateButton(button)
    return button
end

function FrameBuilder.UpdateButton(button)
    button:SetScript("OnEnter", function(b) b:SetBackdropColor(button.colorHightlight.r, button.colorHightlight.g, button.colorHightlight.b, button.colorHightlight.a) end)
    button:SetBackdropColor(button.color.r, button.color.g, button.color.b, button.color.a)
    button:SetWidth(button.width)
    button:SetHeight(button.height)
    button.text:SetText(button.displayText)
end

---@return table|BackdropTemplate|Frame
function FrameBuilder.CreateSelector(parentFrame, items, width, font, fontSize, selectedName)
    local selector = CreateFrame("Frame", "SRT_DropdownClosed", parentFrame, "BackdropTemplate")
    selector:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 16,
    })
    selector:SetBackdropColor(0, 0, 0, 0)
    selector:SetSize(width, fontSize+2)
    selector.selectedName = selectedName
    selector.items = items
    selector.font = font
    selector.fontSize = fontSize
    selector.text = selector:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    selector.text:SetPoint("LEFT", selector, "LEFT", 5, 0)
    selector.text:SetFont(selector.font, selector.fontSize)
    selector.text:SetText(selectedName)
    selector.text:SetTextColor(1, 1, 1, 0.8)
    selector.text:SetJustifyH("LEFT")
    selector.button = CreateFrame("Button", "SRT_DropdownButton", selector)
    selector.button:SetSize(selector.fontSize*1.4, selector.fontSize*1.4)
    selector.button:SetPoint("RIGHT", selector, "RIGHT", -3, 0)
    selector.button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    selector.button:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    selector.button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    selector.button:SetAlpha(0.8)
    selector.button:SetScript("OnEnter", function(b) b:SetAlpha(1) end)
    selector.button:SetScript("OnLeave", function(b) b:SetAlpha(0.8) end)
    selector.button:SetScript("OnClick", function(b) 
        if selector.dropdown:IsShown() then
            selector.dropdown:Hide()
            -- selector:SetBackdropColor(0, 0, 0, 0)
        else
            selector.dropdown:Show()
            -- selector:SetBackdropColor(0, 0, 0, 0.5)
        end
    end)
    selector.dropdown = CreateFrame("Frame", "SRT_DropdownOpen", parentFrame, "BackdropTemplate")
    selector.dropdown:SetPoint("TOPLEFT", selector, "BOTTOMLEFT", 5, -5)
    selector.dropdown:SetPoint("TOPRIGHT", selector, "BOTTOMRIGHT", -10, -5)
    selector.dropdown:SetFrameStrata("DIALOG")
    selector.dropdown:Hide()
    FrameBuilder.UpdateSelector(selector)
    return selector
end

function FrameBuilder.UpdateSelector(selector)
    selector.text:SetText(selector.selectedName)
    selector.dropdown:SetHeight(#selector.items * (14+4))
    selector.dropdown:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = selector.dropdown:GetHeight(),
    })
    selector.dropdown:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    selector.dropdown.rows = selector.dropdown.rows or {}
    local lastRow
    for rowIndex, item in ipairs(selector.items) do
        local row = selector.dropdown.rows[rowIndex] or CreateFrame("Frame", nil, selector.dropdown, "BackdropTemplate")
        row:SetSize(selector:GetWidth(), 18)
        if lastRow then
            row:SetPoint("TOPLEFT", lastRow, "BOTTOMLEFT", 0, 0)
            row:SetPoint("TOPRIGHT", lastRow, "BOTTOMRIGHT", 0, 0)
        else
            row:SetPoint("TOPLEFT", selector.dropdown, "TOPLEFT", 0, 0)
            row:SetPoint("TOPRIGHT", selector.dropdown, "TOPRIGHT", 0, 0)
        end
        row:SetBackdrop({
            bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
            tile = true,
            tileSize = 16,
        })
        row:SetBackdropColor(0, 0, 0, 0)
        row:SetScript("OnEnter", function(r) r:SetBackdropColor(0.8, 0.5, 0.3, 1) end)
        row:SetScript("OnLeave", function(r) r:SetBackdropColor(0, 0, 0, 0) end)
        row:SetScript("OnMouseDown", function (r)
            selector.dropdown:Hide()
            selector.selectedName = item.name
            item.onClick(r)
        end)
        row.item = item
        row.text = row.text or row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.text:SetPoint("LEFT", row, "LEFT", 10, 0)
        row.text:SetFont(selector.font, selector.fontSize)
        row.text:SetText(item.name)
        row.text:SetTextColor(1, 1, 1, 0.8)
        row.text:SetJustifyH("LEFT")
        selector.dropdown.rows[rowIndex] = row
        lastRow = row
    end
end

---@return table|Frame|BackdropTemplate
function FrameBuilder.CreateFilterMenu(parentFrame, structure, font, updateFunction, depth)
    if not depth then depth = 1 end
    local popup = CreateFrame("Frame", nil, parentFrame, "BackdropTemplate")
    popup:SetFrameStrata("DIALOG")
    popup:SetWidth(120)
    popup:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 240,
    })
    popup:SetBackdropColor(0, 0, 0, 0.5)

    local lastItem
    local count = 0
    popup.items = {}
    for name, structure in OrderedPairs(structure) do
        popup.items[name] = FrameBuilder.CreateFilterMenuItem(popup, lastItem, name, structure, font, updateFunction, depth)
        lastItem = popup.items[name]
        count = count + 1
    end

    if depth == 1 then
        popup.items.close = CreateFrame("Frame", nil, popup, "BackdropTemplate")
        popup.items.close:SetHeight(18)
        popup.items.close:SetPoint("TOPLEFT", lastItem, "BOTTOMLEFT")
        popup.items.close:SetPoint("TOPRIGHT", lastItem, "BOTTOMRIGHT")
        popup.items.close.text = popup.items.close:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        popup.items.close.text:SetText("Close")
        popup.items.close.text:SetFont(font, 12)
        popup.items.close.text:SetPoint("TOPLEFT", 3, -3)
        popup.items.close:SetScript("OnEnter", function ()
            for _, otherItem in pairs(popup.items) do
                if otherItem.popup then
                    otherItem.popup:Hide()
                end
            end
        end)
        popup.items.close:SetScript("OnMouseDown", function (_, button)
            if button == "LeftButton" then popup:Hide() end
        end)
        count = count + 1
    end

    popup:SetHeight(18 * count)

    return popup
end

---@return table|Frame|BackdropTemplate
function FrameBuilder.CreateFilterMenuItem(popupFrame, previousItem, name, structure, font, updateFunction, depth)
    local item = CreateFrame("Frame", nil, popupFrame, "BackdropTemplate")
    item:SetHeight(18)
    if previousItem then
        item:SetPoint("TOPLEFT", previousItem, "BOTTOMLEFT")
        item:SetPoint("TOPRIGHT", previousItem, "BOTTOMRIGHT")
    else
        item:SetPoint("TOPLEFT")
        item:SetPoint("TOPRIGHT")
    end
    item.text = item:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    item.text:SetText(name)
    item.text:SetFont(font, 12)
    item.text:SetPoint("TOPLEFT", 3, -3)
    if type(structure) == "boolean" then
        item.value = structure
        item.icon = CreateFrame("Button", nil, item, "BackdropTemplate")
        item.icon:SetPoint("TOPRIGHT", item, "TOPRIGHT", -3, -3)
        item.icon:SetSize(12, 12)
        item.icon.texture = item.icon:CreateTexture(nil, "OVERLAY")
        if item.value then
            item.icon.texture:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
        else
            item.icon.texture:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
        end
        item.icon.texture:SetAllPoints()
        item:SetScript("OnEnter", function ()
            for _, otherItem in pairs(popupFrame.items) do
                if otherItem.popup then
                    otherItem.popup:Hide()
                end
            end
        end)
        item:SetScript("OnMouseDown", function (_, button)
            if button == "LeftButton" then
                item.value = not item.value
                FrameBuilder.UpdateFilterMenu(popupFrame)
                updateFunction()
            end
        end)
    elseif type(structure) == "table" then
        item.arrow = item:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        item.arrow:SetText(">")
        item.arrow:SetFont(font, 12)
        item.arrow:SetPoint("TOPRIGHT", -3, -3)

        item.popup = FrameBuilder.CreateFilterMenu(item, structure, font, updateFunction, depth+1)
        item.popup:SetPoint("TOPLEFT", item, "TOPRIGHT", 0, 0)
        item.popup:Hide()
        item:SetScript("OnEnter", function ()
            for _, otherItem in pairs(popupFrame.items) do
                if otherItem.popup then
                    otherItem.popup:Hide()
                end
            end
            item.popup:Show()
        end)
    end
    return item
end

function FrameBuilder.UpdateFilterMenu(popup)
    for _, item in pairs(popup.items) do
        if item.icon then
            -- option
            if item.value then
                item.icon.texture:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
            else
                item.icon.texture:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
            end
        elseif item.popup then
            -- menu
            FrameBuilder.UpdateFilterMenu(item.popup)
        end
    end
end
