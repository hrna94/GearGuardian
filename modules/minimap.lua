-- ============================================
-- GearGuardian - Minimap Button Module
-- ============================================

local GG = GearGuardian
if not GG then return end

-- ============================================
-- MINIMAP BUTTON
-- ============================================

local minimapButton = nil
local isDragging = false

-- Create minimap button
function GG.CreateMinimapButton()
    if minimapButton then return end

    -- Create button
    minimapButton = CreateFrame("Button", "GGMinimapButton", Minimap)
    minimapButton:SetSize(32, 32)
    minimapButton:SetFrameStrata("MEDIUM")
    minimapButton:SetFrameLevel(8)
    minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    minimapButton:RegisterForDrag("LeftButton")
    minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    -- Icon
    local icon = minimapButton:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", 0, 1)
    icon:SetTexture("Interface\\Addons\\GearGuardian\\icon")
    minimapButton.icon = icon

    -- Border
    local border = minimapButton:CreateTexture(nil, "OVERLAY")
    border:SetSize(52, 52)
    border:SetPoint("TOPLEFT")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    minimapButton.border = border

    -- Tooltip
    minimapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("|cff00ff00GearGuardian|r")
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cffffffffLeft Click:|r Open config panel")
        GameTooltip:AddLine("|cffffffffRight Click:|r Quick menu")
        GameTooltip:AddLine("|cffffffffDrag:|r Move button")
        GameTooltip:Show()
    end)

    minimapButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Click handlers
    minimapButton:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            -- Toggle config panel
            if GG.configFrame:IsShown() then
                GG.configFrame:Hide()
            else
                GG.configFrame:Show()
            end
        elseif button == "RightButton" then
            -- Show context menu
            GG.ShowMinimapMenu()
        end
    end)

    -- Drag handlers
    minimapButton:SetScript("OnDragStart", function(self)
        isDragging = true
        self:LockHighlight()
    end)

    minimapButton:SetScript("OnDragStop", function(self)
        isDragging = false
        self:UnlockHighlight()
        GG.SaveMinimapPosition()
    end)

    minimapButton:SetScript("OnUpdate", function(self)
        if isDragging then
            GG.UpdateMinimapButtonPosition()
        end
    end)

    -- Position button
    GG.RestoreMinimapPosition()

    print("|cff00ff00GearGuardian:|r Minimap button created. Right-click for options.")
end

-- Update minimap button position while dragging
function GG.UpdateMinimapButtonPosition()
    if not minimapButton then return end

    local mx, my = Minimap:GetCenter()
    local px, py = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()

    px, py = px / scale, py / scale

    local angle = math.atan2(py - my, px - mx)
    local x = math.cos(angle) * 80
    local y = math.sin(angle) * 80

    minimapButton:ClearAllPoints()
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- Save minimap button position
function GG.SaveMinimapPosition()
    if not minimapButton then return end

    local mx, my = Minimap:GetCenter()
    local bx, by = minimapButton:GetCenter()

    if not mx or not my or not bx or not by then return end

    local angle = math.atan2(by - my, bx - mx)

    if not GearGuardianDB.minimap then
        GearGuardianDB.minimap = {}
    end

    GearGuardianDB.minimap.angle = angle
end

-- Restore minimap button position
function GG.RestoreMinimapPosition()
    if not minimapButton then return end

    local angle = 0

    if GearGuardianDB and GearGuardianDB.minimap and GearGuardianDB.minimap.angle then
        angle = GearGuardianDB.minimap.angle
    end

    local x = math.cos(angle) * 80
    local y = math.sin(angle) * 80

    minimapButton:ClearAllPoints()
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- Show minimap context menu
function GG.ShowMinimapMenu()
    if not GG.minimapMenu then
        GG.minimapMenu = CreateFrame("Frame", "GGMinimapMenu", UIParent, "UIDropDownMenuTemplate")
    end

    -- Initialize dropdown menu
    UIDropDownMenu_Initialize(GG.minimapMenu, function(self, level)
        local info = UIDropDownMenu_CreateInfo()

        if level == 1 then
            -- Title
            info.text = "GearGuardian"
            info.isTitle = true
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)

            -- Open Config
            info = UIDropDownMenu_CreateInfo()
            info.text = "Open Config"
            info.func = function()
                GG.configFrame:Show()
            end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)

            -- Export Gear
            info = UIDropDownMenu_CreateInfo()
            info.text = "Export Gear"
            info.func = function()
                GG.ExportGear("player")
            end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)

            -- Reset Frame Positions
            info = UIDropDownMenu_CreateInfo()
            info.text = "Reset Frame Positions"
            info.func = function()
                GG.ResetFramePositions()
            end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)

            -- Spacer
            info = UIDropDownMenu_CreateInfo()
            info.text = " "
            info.isTitle = true
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)

            -- Toggle Features submenu
            info = UIDropDownMenu_CreateInfo()
            info.text = "Toggle Features"
            info.hasArrow = true
            info.notCheckable = true
            info.value = "features"
            UIDropDownMenu_AddButton(info, level)

            -- Spacer
            info = UIDropDownMenu_CreateInfo()
            info.text = " "
            info.isTitle = true
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)

            -- Hide Minimap Button
            info = UIDropDownMenu_CreateInfo()
            info.text = "Hide Minimap Button"
            info.func = function()
                if not GearGuardianDB.minimap then
                    GearGuardianDB.minimap = {}
                end
                GearGuardianDB.minimap.hide = true
                if minimapButton then
                    minimapButton:Hide()
                end
                print("|cff00ff00GearGuardian:|r Minimap button hidden. Use |cffFFFF00/gg minimap|r to show it again.")
            end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)

            -- Close
            info = UIDropDownMenu_CreateInfo()
            info.text = "Close"
            info.func = function() end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)

        elseif level == 2 and UIDROPDOWNMENU_MENU_VALUE == "features" then
            -- Quality Borders
            info.text = "Quality Borders"
            info.func = function()
                GearGuardianDB.config.features.qualityBorders = not GearGuardianDB.config.features.qualityBorders
                GG.UpdateAllSlots()
            end
            info.checked = GearGuardianDB.config.features.qualityBorders
            info.keepShownOnClick = true
            UIDropDownMenu_AddButton(info, level)

            -- Item Level Display
            info = UIDropDownMenu_CreateInfo()
            info.text = "Item Level Display"
            info.func = function()
                GearGuardianDB.config.features.itemLevel = not GearGuardianDB.config.features.itemLevel
                GG.UpdateAllSlots()
            end
            info.checked = GearGuardianDB.config.features.itemLevel
            info.keepShownOnClick = true
            UIDropDownMenu_AddButton(info, level)

            -- GearScore Display
            info = UIDropDownMenu_CreateInfo()
            info.text = "GearScore Display"
            info.func = function()
                GearGuardianDB.config.features.averageILevel = not GearGuardianDB.config.features.averageILevel
                GG.UpdateAverageILevelDisplay()
            end
            info.checked = GearGuardianDB.config.features.averageILevel
            info.keepShownOnClick = true
            UIDropDownMenu_AddButton(info, level)

            -- Enchant Check
            info = UIDropDownMenu_CreateInfo()
            info.text = "Enchant Check"
            info.func = function()
                GearGuardianDB.config.features.enchantCheck = not GearGuardianDB.config.features.enchantCheck
                GG.UpdateAllSlots()
            end
            info.checked = GearGuardianDB.config.features.enchantCheck
            info.keepShownOnClick = true
            UIDropDownMenu_AddButton(info, level)

            -- Gem Check
            info = UIDropDownMenu_CreateInfo()
            info.text = "Gem Socket Check"
            info.func = function()
                GearGuardianDB.config.features.gemCheck = not GearGuardianDB.config.features.gemCheck
                GG.UpdateAllSlots()
            end
            info.checked = GearGuardianDB.config.features.gemCheck
            info.keepShownOnClick = true
            UIDropDownMenu_AddButton(info, level)
        end
    end, "MENU")

    ToggleDropDownMenu(1, nil, GG.minimapMenu, "cursor", 0, 0)
end

-- Toggle minimap button visibility
function GG.ToggleMinimapButton()
    if not GearGuardianDB.minimap then
        GearGuardianDB.minimap = {}
    end

    GearGuardianDB.minimap.hide = not GearGuardianDB.minimap.hide

    if GearGuardianDB.minimap.hide then
        if minimapButton then
            minimapButton:Hide()
        end
        print("|cff00ff00GearGuardian:|r Minimap button hidden.")
    else
        if not minimapButton then
            GG.CreateMinimapButton()
        else
            minimapButton:Show()
        end
        print("|cff00ff00GearGuardian:|r Minimap button shown.")
    end
end

-- Initialize minimap button
function GG.InitMinimapButton()
    -- Check if button should be hidden
    if GearGuardianDB and GearGuardianDB.minimap and GearGuardianDB.minimap.hide then
        return
    end

    GG.CreateMinimapButton()
end
