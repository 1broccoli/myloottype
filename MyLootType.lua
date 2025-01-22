-- Saved variables
MyLootSettings = MyLootSettings or {
    lootMethodScale = 70,
    lootQualityScale = 70,
    lootMethodFramePos = { x = 10, y = -50 },
    lootQualityFramePos = { x = 10, y = -90 },
    myLootFramePos = { x = 0, y = 0 },
}

-- Create the event frame
local eventFrame = CreateFrame("Frame")

-- Function to refresh the loot frames
local function RefreshLootFrames()
    local lootMethod, masterLooterIndex = GetLootMethod()
    local lootThreshold = GetLootThreshold()

    -- Update loot method frame
    if lootMethodFrame then
        local label = lootMethodFrame.label
        if lootMethod == "master" then
            local masterLooterName
            if masterLooterIndex and masterLooterIndex > 0 then
                if IsInRaid() then
                    masterLooterName = UnitName("raid" .. masterLooterIndex)
                else
                    masterLooterName = UnitName("party" .. masterLooterIndex)
                end
            end
            if masterLooterName then
                label:SetText("ML (" .. masterLooterName .. ")")
            else
                C_Timer.After(0.1, function()
                    local updatedMasterLooterName
                    if masterLooterIndex and masterLooterIndex > 0 then
                        if IsInRaid() then
                            updatedMasterLooterName = UnitName("raid" .. masterLooterIndex)
                        else
                            updatedMasterLooterName = UnitName("party" .. masterLooterIndex)
                        end
                    end
                    updatedMasterLooterName = updatedMasterLooterName or "Unknown"
                    label:SetText("ML (" .. updatedMasterLooterName .. ")")
                end)
            end
        else
            local lootMethodOptions = {
                ["group"] = "Group Loot",
                ["needbeforegreed"] = "Need Before Greed",
                ["freeforall"] = "Free-for-All",
                ["roundrobin"] = "Round Robin",
                ["master"] = "Master Looter",
            }
            local methodText = lootMethodOptions[lootMethod] or "Unknown"
            label:SetText(methodText)
        end
    end

    -- Update loot quality frame
    if lootQualityFrame then
        local label = lootQualityFrame.label
        local lootQualityOptions = {
            [LE_ITEM_QUALITY_POOR] = { text = "|cFF808080Poor|r" },
            [LE_ITEM_QUALITY_COMMON] = { text = "|cFFFFFFFFCommon|r" },
            [LE_ITEM_QUALITY_UNCOMMON] = { text = "|cFF00FF00Uncommon|r" },
            [LE_ITEM_QUALITY_RARE] = { text = "|cFF0070FFRare|r" },
            [LE_ITEM_QUALITY_EPIC] = { text = "|cFF9B30FFEpic|r" },
            [LE_ITEM_QUALITY_LEGENDARY] = { text = "|cFFFF8000Legendary|r" },
            [LE_ITEM_QUALITY_ARTIFACT] = { text = "|cFFE6CC80Artifact|r" },
        }
        local currentLootQuality = lootQualityOptions[lootThreshold] or lootQualityOptions[LE_ITEM_QUALITY_COMMON]
        label:SetText(currentLootQuality.text)
    end
end

-- Create the selection frame for loot method
local function CreateLootMethodSelectionFrame(parent)
    local frame = CreateFrame("Frame", "LootMethodSelectionFrame", parent, "BackdropTemplate")
    frame:SetSize(160, 30)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", MyLootSettings.lootMethodFramePos.x, MyLootSettings.lootMethodFramePos.y)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.8)
    frame:SetBackdropBorderColor(0, 0, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        MyLootSettings.lootMethodFramePos.x = x
        MyLootSettings.lootMethodFramePos.y = y
        if MyLootSettings.framesAnchored and lootQualityFrame then
            lootQualityFrame:SetPoint("TOPLEFT", lootMethodFrame, "BOTTOMLEFT", 0, -10)
        end
    end)

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("CENTER")
    label:SetText("Select Loot Method")
    frame.label = label

    local lootMethodOptions = {
        { text = "Free-for-All", value = "freeforall" },
        { text = "Round Robin", value = "roundrobin" },
        { text = "Master Looter", value = "master" },
        { text = "Group Loot", value = "group" },
        { text = "Need Before Greed", value = "needbeforegreed" },
    }

    local function SetLootMethodFromSelection(self, arg1, arg2)
        if arg1 == "master" then
            local currentTarget = UnitName("target")
            local masterLooter = currentTarget or UnitName("player")
            SetLootMethod(arg1, masterLooter)

            label:SetText("ML (" .. masterLooter .. ")")
        else
            SetLootMethod(arg1)
            label:SetText(arg2.text)
        end
    end

    frame:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if not IsInGroup() then
                print("|cFFFF0000UNABLE TO CHANGE NOT IN PARTY OR RAID.|r")
                return
            end
            if LootMethodOptionsFrame and LootMethodOptionsFrame:IsShown() then
                LootMethodOptionsFrame:Hide()
            else
                if LootMethodOptionsFrame then
                    LootMethodOptionsFrame:Show()
                else
                    if LootQualityOptionsFrame and LootQualityOptionsFrame:IsShown() then
                        LootQualityOptionsFrame:Hide()
                    end
                    local optionsFrame = CreateFrame("Frame", "LootMethodOptionsFrame", UIParent, "BackdropTemplate")
                    optionsFrame:SetSize(200, #lootMethodOptions * 20 + 20)
                    optionsFrame:SetPoint("CENTER")
                    optionsFrame:SetBackdrop({
                        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                        tile = true, tileSize = 16, edgeSize = 16,
                        insets = { left = 4, right = 4, top = 4, bottom = 4 }
                    })
                    optionsFrame:SetBackdropColor(0, 0, 0, 0.8)
                    optionsFrame:SetBackdropBorderColor(0, 0, 0)
                    optionsFrame:SetMovable(true)
                    optionsFrame:EnableMouse(true)
                    optionsFrame:RegisterForDrag("LeftButton")
                    optionsFrame:SetScript("OnDragStart", optionsFrame.StartMoving)
                    optionsFrame:SetScript("OnDragStop", optionsFrame.StopMovingOrSizing)

                    local closeTexture = optionsFrame:CreateTexture(nil, "OVERLAY")
                    closeTexture:SetTexture("Interface\\AddOns\\MyLootType\\close.png")
                    closeTexture:SetSize(20, 20)
                    closeTexture:SetPoint("TOPRIGHT", optionsFrame, "TOPRIGHT", -5, -5)
                    closeTexture:EnableMouse(true)

                    closeTexture:SetScript("OnEnter", function()
                        closeTexture:SetVertexColor(1, 0, 0) -- Red color on highlight
                    end)
                    closeTexture:SetScript("OnLeave", function()
                        closeTexture:SetVertexColor(1, 1, 1) -- Reset to white color
                    end)
                    closeTexture:SetScript("OnMouseDown", function()
                        closeTexture:SetVertexColor(0.5, 0, 0) -- Darker red on press
                    end)
                    closeTexture:SetScript("OnMouseUp", function()
                        closeTexture:SetVertexColor(1, 0, 0) -- Red color on release
                        optionsFrame:Hide()
                    end)

                    for i, option in ipairs(lootMethodOptions) do
                        local optionText = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                        optionText:SetTextColor(1, 1, 1) -- White color on highlight
                        optionText:SetPoint("TOP", optionsFrame, "TOP", 0, -10 - (i - 1) * 20)
                        optionText:SetText(option.text)
                        optionText:SetScript("OnMouseDown", function()
                            SetLootMethodFromSelection(nil, option.value, option)
                            optionsFrame:Hide()
                        end)
                        optionText:SetScript("OnEnter", function()
                            optionText:SetShadowColor(0, 1, 1, 1) -- Cyan shadow color
                            optionText:SetShadowOffset(1, -1) -- Add shadow with thicker offset
                        end)
                        optionText:SetScript("OnLeave", function()
                            optionText:SetTextColor(1, 1, 1) -- Reset color
                            optionText:SetShadowOffset(0, 0) -- Remove shadow
                        end)
                    end
                end
            end
        end
    end)

    return frame
end

-- Create the selection frame for loot quality
local function CreateLootQualitySelectionFrame(parent)
    local frame = CreateFrame("Frame", "LootQualitySelectionFrame", parent, "BackdropTemplate")
    frame:SetSize(160, 30)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", MyLootSettings.lootQualityFramePos.x, MyLootSettings.lootQualityFramePos.y)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.8)
    frame:SetBackdropBorderColor(0, 0, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        MyLootSettings.lootQualityFramePos.x = x
        MyLootSettings.lootQualityFramePos.y = y
    end)

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("CENTER")
    label:SetText("Select Loot Quality")
    frame.label = label

    local lootQualityOptions = {
        { text = "|cFF808080Poor|r", value = LE_ITEM_QUALITY_POOR },
        { text = "|cFFFFFFFFCommon|r", value = LE_ITEM_QUALITY_COMMON },
        { text = "|cFF00FF00Uncommon|r", value = LE_ITEM_QUALITY_UNCOMMON },
        { text = "|cFF0070FFRare|r", value = LE_ITEM_QUALITY_RARE },
        { text = "|cFF9B30FFEpic|r", value = LE_ITEM_QUALITY_EPIC },
        { text = "|cFFFF8000Legendary|r", value = LE_ITEM_QUALITY_LEGENDARY },
        { text = "|cFFE6CC80Artifact|r", value = LE_ITEM_QUALITY_ARTIFACT },
    }

    local function SetLootQualityFromSelection(self, arg1, arg2)
        SetLootThreshold(arg1)
        label:SetText(arg2.text)
    end

    frame:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if not IsInGroup() then
                print("|cFFFF0000UNABLE TO CHANGE NOT IN PARTY OR RAID.|r")
                return
            end
            if LootQualityOptionsFrame and LootQualityOptionsFrame:IsShown() then
                LootQualityOptionsFrame:Hide()
            else
                if LootQualityOptionsFrame then
                    LootQualityOptionsFrame:Show()
                else
                    if LootMethodOptionsFrame and LootMethodOptionsFrame:IsShown() then
                        LootMethodOptionsFrame:Hide()
                    end
                    local optionsFrame = CreateFrame("Frame", "LootQualityOptionsFrame", UIParent, "BackdropTemplate")
                    optionsFrame:SetSize(200, #lootQualityOptions * 20 + 20)
                    optionsFrame:SetPoint("CENTER")
                    optionsFrame:SetBackdrop({
                        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                        tile = true, tileSize = 16, edgeSize = 16,
                        insets = { left = 4, right = 4, top = 4, bottom = 4 }
                    })
                    optionsFrame:SetBackdropColor(0, 0, 0, 0.8)
                    optionsFrame:SetBackdropBorderColor(0, 0, 0)
                    optionsFrame:SetMovable(true)
                    optionsFrame:EnableMouse(true)
                    optionsFrame:RegisterForDrag("LeftButton")
                    optionsFrame:SetScript("OnDragStart", optionsFrame.StartMoving)
                    optionsFrame:SetScript("OnDragStop", optionsFrame.StopMovingOrSizing)

                    local closeTexture = optionsFrame:CreateTexture(nil, "OVERLAY")
                    closeTexture:SetTexture("Interface\\AddOns\\MyLootType\\close.png")
                    closeTexture:SetSize(20, 20)
                    closeTexture:SetPoint("TOPRIGHT", optionsFrame, "TOPRIGHT", -5, -5)
                    closeTexture:EnableMouse(true)

                    closeTexture:SetScript("OnEnter", function()
                        closeTexture:SetVertexColor(1, 0, 0) -- Red color on highlight
                    end)
                    closeTexture:SetScript("OnLeave", function()
                        closeTexture:SetVertexColor(1, 1, 1) -- Reset to white color
                    end)
                    closeTexture:SetScript("OnMouseDown", function()
                        closeTexture:SetVertexColor(0.5, 0, 0) -- Darker red on press
                    end)
                    closeTexture:SetScript("OnMouseUp", function()
                        closeTexture:SetVertexColor(1, 0, 0) -- Red color on release
                        optionsFrame:Hide()
                    end)

                    for i, option in ipairs(lootQualityOptions) do
                        local optionText = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                        optionText:SetPoint("TOP", optionsFrame, "TOP", 0, -10 - (i - 1) * 20)
                        optionText:SetText(option.text)
                        optionText:SetScript("OnMouseDown", function()
                            SetLootQualityFromSelection(nil, option.value, option)
                            optionsFrame:Hide()
                        end)
                        optionText:SetScript("OnEnter", function()
                            optionText:SetShadowColor(1, 1, 1, 1) -- White shadow color
                            optionText:SetShadowOffset(1, -1) -- Add shadow with thicker offset
                        end)
                        optionText:SetScript("OnLeave", function()
                            optionText:SetTextColor(1, 1, 1) -- Reset color
                            optionText:SetShadowOffset(0, 0) -- Remove shadow
                        end)
                    end
                end
            end
        end
    end)
    return frame
end

-- Create the selection frames on the player's frame (or any parent frame as needed)
local parentFrame = UIParent
local lootMethodFrame = CreateLootMethodSelectionFrame(parentFrame)
local lootQualityFrame = CreateLootQualitySelectionFrame(parentFrame)

-- Hook to update the loot method when it changes
hooksecurefunc("SetLootMethod", function(method, masterLooter)
    local frame = LootMethodSelectionFrame
    if frame then
        local label = frame.label
        if method == "master" and masterLooter then
            local masterLooterName = UnitName(masterLooter) or masterLooter
            label:SetText("ML (" .. masterLooterName .. ")")
        else
            local lootMethodOptions = {
                ["group"] = "Group Loot",
                ["needbeforegreed"] = "Need Before Greed",
                ["freeforall"] = "Free-for-All",
                ["roundrobin"] = "Round Robin",
                ["master"] = "Master Looter",
            }
            local methodText = lootMethodOptions[method] or "Unknown"
            label:SetText(methodText)
        end
    end
end)

-- Hook to update the loot quality when it changes
hooksecurefunc("SetLootThreshold", function(newThreshold)
    local frame = LootQualitySelectionFrame
    if frame then
        local label = frame.label
        local lootQualityOptions = {
            [LE_ITEM_QUALITY_POOR] = { text = "|cFF808080Poor|r" },
            [LE_ITEM_QUALITY_COMMON] = { text = "|cFFFFFFFFCommon|r" },
            [LE_ITEM_QUALITY_UNCOMMON] = { text = "|cFF00FF00Uncommon|r" },
            [LE_ITEM_QUALITY_RARE] = { text = "|cFF0070FFRare|r" },
            [LE_ITEM_QUALITY_EPIC] = { text = "|cFF9B30FFEpic|r" },
            [LE_ITEM_QUALITY_LEGENDARY] = { text = "|cFFFF8000Legendary|r" },
            [LE_ITEM_QUALITY_ARTIFACT] = { text = "|cFFE6CC80Artifact|r" },
        }
        local currentLootQuality = lootQualityOptions[newThreshold] or lootQualityOptions[LE_ITEM_QUALITY_COMMON]
        label:SetText(currentLootQuality.text)
    end
end)

-- Function to adjust the scale of the Loot Method frame
local function SetLootMethodFrameScale(scale)
    -- Ensure the scale is within the valid range (20 to 100)
    if scale < 20 then
        scale = 20
    elseif scale > 100 then
        scale = 100
    end

    -- Map the scale (20 to 100) to the actual size (0.2 to 1.0)
    local adjustedScale = (scale - 20) * 0.01 + 0.2  -- Map scale 20->0.2, 100->1.0

    -- Set the scale for Loot Method frame
    lootMethodFrame:SetScale(adjustedScale)
    MyLootSettings.lootMethodScale = scale
end

-- Function to adjust the scale of the Loot Quality frame
local function SetLootQualityFrameScale(scale)
    -- Ensure the scale is within the valid range (20 to 100)
    if scale < 20 then
        scale = 20
    elseif scale > 100 then
        scale = 100
    end

    -- Map the scale (20 to 100) to the actual size (0.2 to 1.0)
    local adjustedScale = (scale - 20) * 0.01 + 0.2  -- Map scale 20->0.2, 100->1.0

    -- Set the scale for Loot Quality frame
    lootQualityFrame:SetScale(adjustedScale)
    MyLootSettings.lootQualityScale = scale
end

-- Create a frame for the sliders
local myLootFrame = CreateFrame("Frame", "MyLootFrame", UIParent, "BackdropTemplate")
myLootFrame:SetSize(220, 150)
myLootFrame:SetPoint("CENTER", MyLootSettings.myLootFramePos.x, MyLootSettings.myLootFramePos.y)
myLootFrame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
myLootFrame:SetBackdropColor(0, 0, 0, 1)
myLootFrame:SetBackdropBorderColor(0, 0, 0, 1)
myLootFrame:SetMovable(true)
myLootFrame:EnableMouse(true)
myLootFrame:RegisterForDrag("LeftButton")
myLootFrame:SetScript("OnDragStart", myLootFrame.StartMoving)
myLootFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    MyLootSettings.myLootFramePos.x = x
    MyLootSettings.myLootFramePos.y = y
end)
myLootFrame:Hide()
-- Add a title to the frame
local title = myLootFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", myLootFrame, "TOP", 0, -10)
title:SetText("My Loot Settings")
title:SetTextColor(1, 0.5, 0) -- Set the text color to orange (RGB: 1, 0.5, 0)
-- Add a close texture to the frame
local closeTexture = myLootFrame:CreateTexture(nil, "OVERLAY")
closeTexture:SetTexture("Interface\\AddOns\\MyLootType\\close.png")
closeTexture:SetSize(20, 20)
closeTexture:SetPoint("TOPRIGHT", myLootFrame, "TOPRIGHT", -5, -5)
closeTexture:EnableMouse(true)

-- Change color on highlight
closeTexture:SetScript("OnEnter", function()
    closeTexture:SetVertexColor(1, 0, 0) -- Red color on highlight
end)
closeTexture:SetScript("OnLeave", function()
    closeTexture:SetVertexColor(1, 1, 1) -- Reset to white color
end)

-- Change color on press
closeTexture:SetScript("OnMouseDown", function()
    closeTexture:SetVertexColor(0.5, 0, 0) -- Darker red on press
end)
closeTexture:SetScript("OnMouseUp", function()
    closeTexture:SetVertexColor(1, 0, 0) -- Red color on release
    myLootFrame:Hide()
end)

-- Create a slider for Loot Method frame scale
local lootMethodSlider = CreateFrame("Slider", "LootMethodSlider", myLootFrame, "OptionsSliderTemplate")
lootMethodSlider:SetPoint("TOP", myLootFrame, "TOP", 0, -55)
lootMethodSlider:SetMinMaxValues(20, 100)
lootMethodSlider:SetValueStep(1)
lootMethodSlider:SetValue(MyLootSettings.lootMethodScale) -- Default value
LootMethodSliderText:SetText("Loot Method Scale")
LootMethodSliderLow:SetText("20")
LootMethodSliderHigh:SetText("100")

-- Create a font string to display the current value of the Loot Method slider
local lootMethodValueText = myLootFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
lootMethodValueText:SetPoint("TOP", lootMethodSlider, "BOTTOM", 0, -5)
lootMethodValueText:SetText(tostring(lootMethodSlider:GetValue()))

lootMethodSlider:SetScript("OnValueChanged", function(self, value)
    SetLootMethodFrameScale(math.floor(value + 0.5))
    lootMethodValueText:SetText(tostring(math.floor(value + 0.5)))
end)

-- Create a slider for Loot Quality frame scale
local lootQualitySlider = CreateFrame("Slider", "LootQualitySlider", myLootFrame, "OptionsSliderTemplate")
lootQualitySlider:SetPoint("TOP", lootMethodValueText, "BOTTOM", 0, -20)
lootQualitySlider:SetMinMaxValues(20, 100)
lootQualitySlider:SetValueStep(1)
lootQualitySlider:SetValue(MyLootSettings.lootQualityScale) -- Default value
LootQualitySliderText:SetText("Loot Quality Scale")
LootQualitySliderLow:SetText("20")
LootQualitySliderHigh:SetText("100")

-- Create a font string to display the current value of the Loot Quality slider
local lootQualityValueText = myLootFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
lootQualityValueText:SetPoint("TOP", lootQualitySlider, "BOTTOM", 0, -5)
lootQualityValueText:SetText(tostring(lootQualitySlider:GetValue()))

lootQualitySlider:SetScript("OnValueChanged", function(self, value)
    SetLootQualityFrameScale(math.floor(value + 0.5))
    lootQualityValueText:SetText(tostring(math.floor(value + 0.5)))
end)

-- Slash command to show the frame
SLASH_MYLOOT1 = "/myloot"
SlashCmdList["MYLOOT"] = function()
    if myLootFrame:IsShown() then
        myLootFrame:Hide()
    else
        myLootFrame:Show()
    end
end

-- Event handler for ADDON_LOADED to load settings
local function OnAddonLoaded(self, event, addonName)
    if addonName == "MyLootType" then
        -- Load settings from saved variables
        MyLootSettings = MyLootSettings or {
            lootMethodScale = 70,
            lootQualityScale = 70,
            lootMethodFramePos = { x = 10, y = -50 },
            lootQualityFramePos = { x = 10, y = -90 },
            myLootFramePos = { x = 0, y = 0 },
        }
        -- Apply saved settings
        SetLootMethodFrameScale(MyLootSettings.lootMethodScale)
        SetLootQualityFrameScale(MyLootSettings.lootQualityScale)
        lootMethodFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", MyLootSettings.lootMethodFramePos.x, MyLootSettings.lootMethodFramePos.y)
        lootQualityFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", MyLootSettings.lootQualityFramePos.x, MyLootSettings.lootQualityFramePos.y)
        myLootFrame:SetPoint("CENTER", MyLootSettings.myLootFramePos.x, MyLootSettings.myLootFramePos.y)

        -- Register events
        eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        eventFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")

        -- Initial refresh when the addon is loaded
        RefreshLootFrames()
    end
end

-- Event handler for PLAYER_LOGOUT to save settings
local function OnPlayerLogout(self, event)
    -- Save settings to saved variables
    MyLootSettings.lootMethodScale = lootMethodSlider:GetValue()
    MyLootSettings.lootQualityScale = lootQualitySlider:GetValue()
    local point, _, _, x, y = lootMethodFrame:GetPoint()
    MyLootSettings.lootMethodFramePos.x = x
    MyLootSettings.lootMethodFramePos.y = y
    point, _, _, x, y = lootQualityFrame:GetPoint()
    MyLootSettings.lootQualityFramePos.x = x
    MyLootSettings.lootQualityFramePos.y = y
    point, _, _, x, y = myLootFrame:GetPoint()
    MyLootSettings.myLootFramePos.x = x
    MyLootSettings.myLootFramePos.y = y

    -- Unregister events
    eventFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:UnregisterEvent("PARTY_LOOT_METHOD_CHANGED")
end

-- Event handler for PLAYER_ENTERING_WORLD to set the text for loot threshold and loot method
local function OnPlayerEnteringWorld(self, event)
    RefreshLootFrames()
end

-- Register event handlers
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "GROUP_ROSTER_UPDATE" or event == "PARTY_LOOT_METHOD_CHANGED" then
        RefreshLootFrames()
    elseif event == "ADDON_LOADED" then
        OnAddonLoaded(self, event, ...)
    elseif event == "PLAYER_LOGOUT" then
        OnPlayerLogout(self, event, ...)
    elseif event == "PLAYER_ENTERING_WORLD" then
        OnPlayerEnteringWorld(self, event, ...)
    end
end)

-- Hook the frames to show and refresh the loot threshold and loot quality type based on the game's current settings
local function RefreshLootFrames()
    local lootMethod, masterLooter = GetLootMethod()
    local lootThreshold = GetLootThreshold()

    -- Update loot method frame
    if lootMethodFrame then
        local label = lootMethodFrame.label
        if lootMethod == "master" then
            local masterLooterName = masterLooter and UnitName(masterLooter) or UnitName("player")
            if not masterLooterName then
                masterLooterName = "Unknown"
            end
            label:SetText("ML (" .. masterLooterName .. ")")
        else
            local lootMethodOptions = {
                ["group"] = "Group Loot",
                ["needbeforegreed"] = "Need Before Greed",
                ["freeforall"] = "Free-for-All",
                ["roundrobin"] = "Round Robin",
                ["master"] = "Master Looter",
            }
            local methodText = lootMethodOptions[lootMethod] or "Unknown"
            label:SetText(methodText)
        end
    end

    -- Update loot quality frame
    if lootQualityFrame then
        local label = lootQualityFrame.label
        local lootQualityOptions = {
            [LE_ITEM_QUALITY_POOR] = { text = "|cFF808080Poor|r" },
            [LE_ITEM_QUALITY_COMMON] = { text = "|cFFFFFFFFCommon|r" },
            [LE_ITEM_QUALITY_UNCOMMON] = { text = "|cFF00FF00Uncommon|r" },
            [LE_ITEM_QUALITY_RARE] = { text = "|cFF0070FFRare|r" },
            [LE_ITEM_QUALITY_EPIC] = { text = "|cFF9B30FFEpic|r" },
            [LE_ITEM_QUALITY_LEGENDARY] = { text = "|cFFFF8000Legendary|r" },
            [LE_ITEM_QUALITY_ARTIFACT] = { text = "|cFFE6CC80Artifact|r" },
        }
        local currentLootQuality = lootQualityOptions[lootThreshold] or lootQualityOptions[LE_ITEM_QUALITY_COMMON]
        label:SetText(currentLootQuality.text)
    end
end

-- Hook the function to the events that change loot method and threshold
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "GROUP_ROSTER_UPDATE" or event == "PARTY_LOOT_METHOD_CHANGED" then
        RefreshLootFrames()
    elseif event == "ADDON_LOADED" then
        OnAddonLoaded(self, event, ...)
    elseif event == "PLAYER_LOGOUT" then
        OnPlayerLogout(self, event, ...)
    elseif event == "PLAYER_ENTERING_WORLD" then
        OnPlayerEnteringWorld(self, event, ...)
    end
end)

-- Initial refresh when the addon is loaded
RefreshLootFrames()

-- Create a repeating timer to refresh loot frames every second
C_Timer.NewTicker(1, function()
    RefreshLootFrames()
end)