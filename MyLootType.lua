-- Create the dropdown menu
local function CreateLootDropdown(parent)
    local lootDropdown = CreateFrame("Frame", "LootQualityDropdown", parent, "UIDropDownMenuTemplate")
    lootDropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)

    -- Make the dropdown moveable
    lootDropdown:SetMovable(true)
    lootDropdown:EnableMouse(true)
    lootDropdown:RegisterForDrag("LeftButton")
    lootDropdown:SetScript("OnDragStart", lootDropdown.StartMoving)
    lootDropdown:SetScript("OnDragStop", lootDropdown.StopMovingOrSizing)

    -- Populate the dropdown with loot qualities
    local lootQualityOptions = {
        { text = "Poor", value = LE_ITEM_QUALITY_POOR, color = "|cFF808080" },  -- Gray
        { text = "Common", value = LE_ITEM_QUALITY_COMMON, color = "|cFFFFFFFF" },  -- White
        { text = "Uncommon", value = LE_ITEM_QUALITY_UNCOMMON, color = "|cFF00FF00" },  -- Green
        { text = "Rare", value = LE_ITEM_QUALITY_RARE, color = "|cFF0070FF" },  -- Blue
        { text = "Epic", value = LE_ITEM_QUALITY_EPIC, color = "|cFF9B30FF" },  -- Purple
        { text = "Legendary", value = LE_ITEM_QUALITY_LEGENDARY, color = "|cFFFF8000" },  -- Orange
        { text = "Artifact", value = LE_ITEM_QUALITY_ARTIFACT, color = "|cFFE6CC80" },  -- Yellowish for Artifact
    }

    -- Set the initial loot threshold based on the current threshold
    local function SetLootThresholdFromDropdown(self, arg1, arg2, checked)
        SetLootThreshold(arg1)  -- Set the loot threshold to the selected value
        UIDropDownMenu_SetText(lootDropdown, arg2.color .. arg2.text .. "|r")  -- Update the dropdown text color
    end

    -- Initialize the dropdown with the available loot qualities
    local function InitializeLootDropdown(self, level, menuList)
        for _, option in ipairs(lootQualityOptions) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.color .. option.text .. "|r"  -- Add color code to text
            info.arg1 = option.value
            info.arg2 = option
            info.func = SetLootThresholdFromDropdown
            info.checked = option.value == GetLootThreshold()

            UIDropDownMenu_AddButton(info)
        end
    end

    -- Set up the dropdown menu
    UIDropDownMenu_Initialize(lootDropdown, InitializeLootDropdown)
    UIDropDownMenu_SetWidth(lootDropdown, 90)

    -- Set initial dropdown text
    local initialThreshold = GetLootThreshold()

    -- Ensure the initial threshold is valid, else set to a default value (e.g., Common)
    local initialLootOption = lootQualityOptions[initialThreshold] or lootQualityOptions[LE_ITEM_QUALITY_COMMON]
    UIDropDownMenu_SetText(lootDropdown, initialLootOption.color .. initialLootOption.text .. "|r")

    -- Return the dropdown frame for potential further customization
    return lootDropdown
end

-- Create the dropdown UI element on the player's frame (or any parent frame as needed)
local parentFrame = UIParent  -- Or specify another parent frame as needed
local lootDropdown = CreateLootDropdown(parentFrame)

-- Hook to update the dropdown when the loot threshold changes (automatically)
hooksecurefunc("SetLootThreshold", function(newThreshold)
    local dropdown = LootQualityDropdown  -- Get the dropdown we created
    if dropdown then
        -- Update the text to show the new loot quality color and name
        local lootQualityOptions = {
            [LE_ITEM_QUALITY_POOR] = { text = "Poor", color = "|cFF808080" },  -- Gray
            [LE_ITEM_QUALITY_COMMON] = { text = "Common", color = "|cFFFFFFFF" },  -- White
            [LE_ITEM_QUALITY_UNCOMMON] = { text = "Uncommon", color = "|cFF00FF00" },  -- Green
            [LE_ITEM_QUALITY_RARE] = { text = "Rare", color = "|cFF0070FF" },  -- Blue
            [LE_ITEM_QUALITY_EPIC] = { text = "Epic", color = "|cFF9B30FF" },  -- Purple
            [LE_ITEM_QUALITY_LEGENDARY] = { text = "Legendary", color = "|cFFFF8000" },  -- Orange
            [LE_ITEM_QUALITY_ARTIFACT] = { text = "Artifact", color = "|cFFE6CC80" },  -- Yellowish for Artifact
        }

        local currentLootQuality = lootQualityOptions[newThreshold] or lootQualityOptions[LE_ITEM_QUALITY_COMMON]
        UIDropDownMenu_SetText(dropdown, currentLootQuality.color .. currentLootQuality.text .. "|r")  -- Update text with color
    end
end)

-- Timer to check and update the dropdown text if the loot threshold is changed by other means
local updateLootThresholdTimer = nil
local function UpdateLootThresholdDropdown()
    local currentThreshold = GetLootThreshold()
    local dropdown = LootQualityDropdown
    if dropdown then
        local lootQualityOptions = {
            [LE_ITEM_QUALITY_POOR] = {text = "Poor", color = "|cFF808080"},  -- Gray
            [LE_ITEM_QUALITY_COMMON] = {text = "Common", color = "|cFFFFFFFF"},  -- White
            [LE_ITEM_QUALITY_UNCOMMON] = {text = "Uncommon", color = "|cFF00FF00"},  -- Green
            [LE_ITEM_QUALITY_RARE] = {text = "Rare", color = "|cFF0070FF"},  -- Blue
            [LE_ITEM_QUALITY_EPIC] = {text = "Epic", color = "|cFF9B30FF"},  -- Purple
            [LE_ITEM_QUALITY_LEGENDARY] = {text = "Legendary", color = "|cFFFF8000"},  -- Orange
            [LE_ITEM_QUALITY_ARTIFACT] = {text = "Artifact", color = "|cFFE6CC80"},  -- Yellowish for Artifact
        }

        -- Check if the current threshold has changed, and update if necessary
        local currentLootQuality = lootQualityOptions[currentThreshold] or lootQualityOptions[LE_ITEM_QUALITY_COMMON]
        UIDropDownMenu_SetText(dropdown, currentLootQuality.color .. currentLootQuality.text .. "|r")  -- Update dropdown text to current threshold color
    end
end

-- Create a timer to update the dropdown text every 0.5 seconds
if not updateLootThresholdTimer then
    updateLootThresholdTimer = C_Timer.NewTicker(0.5, UpdateLootThresholdDropdown)
end

-- Slash command to toggle visibility of the dropdown
SLASH_MLQ1 = "/mlt"
SlashCmdList["mlt"] = function()
    if lootDropdown:IsShown() then
        lootDropdown:Hide()  -- Hide the dropdown
    else
        lootDropdown:Show()  -- Show the dropdown
    end
end
