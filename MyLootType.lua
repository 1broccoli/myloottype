-- Create the dropdown menu for loot method
local function CreateLootMethodDropdown(parent)
    local lootMethodDropdown = CreateFrame("Frame", "LootMethodDropdown", parent, "UIDropDownMenuTemplate")
    lootMethodDropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -50)
	lootMethodDropdown:SetScale(.7)
    -- Make the dropdown moveable
    lootMethodDropdown:SetMovable(true)
    lootMethodDropdown:EnableMouse(true)
    lootMethodDropdown:RegisterForDrag("LeftButton")
    lootMethodDropdown:SetScript("OnDragStart", lootMethodDropdown.StartMoving)
    lootMethodDropdown:SetScript("OnDragStop", lootMethodDropdown.StopMovingOrSizing)

    -- Loot methods and descriptions
    local lootMethodOptions = {
		{ text = "Free-for-All", value = "freeforall" },
		{ text = "Round Robin", value = "roundrobin" },
		{ text = "Master Looter", value = "master" },
        { text = "Group Loot", value = "group" },
        { text = "Need Before Greed", value = "needbeforegreed" },
        
    }

    -- Set the loot method based on the dropdown selection
    local function SetLootMethodFromDropdown(self, arg1, arg2, checked)
        if arg1 == "master" then
            local currentTarget = UnitName("target")
            local masterLooter = currentTarget or UnitName("player") -- Default to addon user if no target
            SetLootMethod(arg1, masterLooter)
            print("Master Looter set to: " .. masterLooter)

            -- Update dropdown text to "ML (playername)"
            UIDropDownMenu_SetText(lootMethodDropdown, "ML (" .. masterLooter .. ")")
        else
            SetLootMethod(arg1)
            UIDropDownMenu_SetText(lootMethodDropdown, arg2.text) -- Default to selected loot method text
        end
    end

    -- Initialize the dropdown with loot methods
    local function InitializeLootMethodDropdown(self, level, menuList)
        for _, option in ipairs(lootMethodOptions) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.text
            info.arg1 = option.value
            info.arg2 = option
            info.func = SetLootMethodFromDropdown
            info.checked = (GetLootMethod() == option.value)
            UIDropDownMenu_AddButton(info)
        end
    end

    -- Set up the dropdown menu
    UIDropDownMenu_Initialize(lootMethodDropdown, InitializeLootMethodDropdown)
    UIDropDownMenu_SetWidth(lootMethodDropdown, 140)

    -- Set the initial dropdown text to the current loot method
    local lootMethod, masterLooterPartyID = GetLootMethod()
    local initialMethodText = lootMethodOptions[1].text -- Default text if no match
    for _, option in ipairs(lootMethodOptions) do
        if option.value == lootMethod then
            initialMethodText = option.text
            break
        end
    end

    -- If the current method is Master Looter, show "ML (playername)"
    if lootMethod == "master" and masterLooterPartyID then
        local masterLooterName = UnitName("party" .. masterLooterPartyID) or UnitName("player")
        UIDropDownMenu_SetText(lootMethodDropdown, "ML (" .. masterLooterName .. ")")
    else
        UIDropDownMenu_SetText(lootMethodDropdown, initialMethodText)
    end

    -- Return the dropdown frame for further customization
    return lootMethodDropdown
end

-- Create the dropdown UI elements on the player's frame (or any parent frame as needed)
local lootMethodDropdown = CreateLootMethodDropdown(parentFrame)

-- Hook to update the loot method when it changes
hooksecurefunc("SetLootMethod", function(method, masterLooter)
    local dropdown = LootMethodDropdown
    if dropdown then
        if method == "master" and masterLooter then
            local masterLooterName = UnitName(masterLooter) or UnitName("player")
            UIDropDownMenu_SetText(dropdown, "ML (" .. masterLooterName .. ")")
        else
            local lootMethodOptions = {
                ["group"] = "Group Loot",
                ["needbeforegreed"] = "Need Before Greed",
                ["freeforall"] = "Free-for-All",
                ["roundrobin"] = "Round Robin",
                ["master"] = "Master Looter",
            }
            local methodText = lootMethodOptions[method] or "Unknown"
            UIDropDownMenu_SetText(dropdown, methodText)
        end
    end
end)

-- Create the dropdown menu
local function CreateLootDropdown(parent)
    local lootDropdown = CreateFrame("Frame", "LootQualityDropdown", parent, "UIDropDownMenuTemplate")
    lootDropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
	lootMethodDropdown:SetScale(.7)
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

-- Function to adjust the scale of the Loot Method dropdown
local function SetLootMethodDropdownScale(scale)
    -- Ensure the scale is within the valid range (1 to 10)
    if scale < 1 then
        scale = 1
    elseif scale > 10 then
        scale = 10
    end

    -- Map the scale (1 to 10) to the actual size (0.1 to 1.0)
    local adjustedScale = (scale - 1) * 0.09 + 0.1  -- Map scale 1->0.1, 10->1.0

    -- Set the scale for Loot Method dropdown
    lootMethodDropdown:SetScale(adjustedScale)
    print("Loot Method Dropdown scale set to: " .. adjustedScale)
end

-- Function to adjust the scale of the Loot Quality dropdown
local function SetLootQualityDropdownScale(scale)
    -- Ensure the scale is within the valid range (1 to 10)
    if scale < 1 then
        scale = 1
    elseif scale > 10 then
        scale = 10
    end

    -- Map the scale (1 to 10) to the actual size (0.1 to 1.0)
    local adjustedScale = (scale - 1) * 0.09 + 0.1  -- Map scale 1->0.1, 10->1.0

    -- Set the scale for Loot Quality dropdown
    lootDropdown:SetScale(adjustedScale)
    print("Loot Quality Dropdown scale set to: " .. adjustedScale)
end

-- Shortened Command to change the scale of Loot Method Dropdown
SLASH_MYLOOTMS1 = "/mylootms"
SlashCmdList["MYLOOTMS"] = function(msg)
    local scale = tonumber(msg)
    if scale then
        SetLootMethodDropdownScale(scale)
    else
        print("Please enter a valid scale value (1 to 10).")
    end
end

-- Shortened Command to change the scale of Loot Quality Dropdown
SLASH_MYLOOTQS1 = "/mylootqs"
SlashCmdList["MYLOOTQS"] = function(msg)
    local scale = tonumber(msg)
    if scale then
        SetLootQualityDropdownScale(scale)
    else
        print("Please enter a valid scale value (1 to 10).")
    end
end