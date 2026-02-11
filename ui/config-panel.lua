--[[
    GearGuardian - Configuration Panel UI
    Author: Sluck
    Version: 2.5

    Copyright (c) 2025 Sluck. All Rights Reserved.
--]]

local GG = GearGuardian
if not GG then return end

-- ============================================
-- CONFIGURATION UI
-- ============================================

-- Create config frame with TBC compatibility
local configFrame = CreateFrame("Frame", "GearGuardianConfigFrame", UIParent)
configFrame.name = "GearGuardian"
configFrame:SetFrameStrata("DIALOG")
configFrame:SetSize(580, 520)
configFrame:SetPoint("CENTER")
configFrame:EnableMouse(true)
configFrame:SetMovable(true)
configFrame:RegisterForDrag("LeftButton")
configFrame:SetScript("OnDragStart", configFrame.StartMoving)
configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)

-- Background with gradient
local bg = configFrame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(0.05, 0.05, 0.1, 0.95)

-- Simple border
local border = configFrame:CreateTexture(nil, "BORDER")
border:SetColorTexture(0.3, 0.3, 0.4, 1)
border:SetAllPoints()

local innerBg = configFrame:CreateTexture(nil, "BORDER", nil, 1)
innerBg:SetColorTexture(0.05, 0.05, 0.1, 0.95)
innerBg:SetPoint("TOPLEFT", 2, -2)
innerBg:SetPoint("BOTTOMRIGHT", -2, 2)

-- Header background
local headerBg = configFrame:CreateTexture(nil, "ARTWORK")
headerBg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
headerBg:SetSize(580, 64)
headerBg:SetPoint("TOP", 0, 12)

configFrame:Hide()

-- Close button
local closeButton = CreateFrame("Button", nil, configFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", -2, -2)

-- Title
local title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, 0)
title:SetText("|cffFFD700GearGuardian|r")
title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")

-- Version text (next to title)
local version = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
version:SetPoint("LEFT", title, "RIGHT", 5, -2)
version:SetText("|cff888888V. 2.5|r")

-- Description
local desc = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
desc:SetPoint("TOPLEFT", 40, -80)
desc:SetText("|cffFFD700Configure addon features|r")
desc:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")

-- Create ScrollFrame for content
local scrollFrame = CreateFrame("ScrollFrame", nil, configFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", -15, -15)
scrollFrame:SetPoint("BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -30, 65)

-- Enable mouse wheel scrolling
scrollFrame:EnableMouseWheel(true)
scrollFrame:SetScript("OnMouseWheel", function(self, delta)
    local current = self:GetVerticalScroll()
    local maxScroll = self:GetVerticalScrollRange()
    local newScroll = math.max(0, math.min(maxScroll, current - (delta * 20)))
    self:SetVerticalScroll(newScroll)
end)

-- ScrollChild (content container)
local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetSize(520, 600) -- Height will accommodate all content
scrollFrame:SetScrollChild(scrollChild)

-- Checkboxes
local checkboxes = {}
local featureLabels = {
    qualityBorders = "Quality Borders",
    itemLevel = "Item Level Display",
    comparison = "Stat Comparison",
    averageILevel = "GearScore & Average iLevel Display",
    enchantCheck = "Enchant Check Warnings",
    gemCheck = "Gem Socket Warnings (Coming soon)",
    bagHighlight = "Bag Upgrade Highlighting (Coming soon)",
    setBonusTracking = "Set Bonus Tracking (Coming soon)",
    dualSpecSupport = "Dual Spec Support (Coming soon)"
}

local featureDescriptions = {
    qualityBorders = "Colored borders around equipped items",
    itemLevel = "Show item level numbers on gear",
    comparison = "Compare items in tooltips for your spec",
    averageILevel = "Display GS + iLvl on character & inspect frames",
    enchantCheck = "Yellow warning icon for missing enchants",
    gemCheck = "Yellow warning icon for empty sockets",
    bagHighlight = "Highlight better gear upgrades in your bags",
    setBonusTracking = "Track and display tier set bonuses",
    dualSpecSupport = "Show comparison for both talent specs"
}

-- Helper function to create section headers
local function CreateSectionHeader(text, yPos)
    local header = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOPLEFT", 10, yPos)
    header:SetText("|cff00CCFF" .. text .. "|r")
    header:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

    -- Separator line
    local line = scrollChild:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(0, 0.8, 1, 0.3)
    line:SetSize(500, 1)
    line:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -3)

    return header
end

local function CreateCheckbox(featureName, label, desc, yOffset, anchorPoint)
    local checkbox = CreateFrame("CheckButton", "GGCheckbox" .. featureName, scrollChild, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", anchorPoint or scrollChild, "TOPLEFT", 20, yOffset)
    checkbox:SetSize(24, 24)

    -- Feature name (bold)
    local text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", checkbox, "RIGHT", 8, 2)
    text:SetText(label)
    text:SetJustifyH("LEFT")
    text:SetWidth(450)
    text:SetFont("Fonts\\FRIZQT__.TTF", 11)

    -- Description (smaller, gray)
    local descText = checkbox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    descText:SetPoint("TOPLEFT", checkbox, "RIGHT", 8, -10)
    descText:SetText("|cffAAAAAA" .. desc .. "|r")
    descText:SetJustifyH("LEFT")
    descText:SetWidth(450)
    descText:SetFont("Fonts\\FRIZQT__.TTF", 9)

    -- Disable checkboxes for "Coming soon" features
    local isComingSoon = string.find(label, "Coming soon")
    if isComingSoon then
        checkbox:Disable()
        text:SetTextColor(0.5, 0.5, 0.5)
    end

    checkbox:SetScript("OnClick", function(self)
        if isComingSoon then return end

        GG.SetConfig(featureName, self:GetChecked())

        -- Apply changes immediately
        if featureName == "qualityBorders" or featureName == "itemLevel" or
           featureName == "enchantCheck" or featureName == "gemCheck" then
            GG.UpdateAllSlots()
        end

        if featureName == "averageILevel" then
            if self:GetChecked() then
                GG.UpdateAverageILevelDisplay()
            else
                if GG.avgILevelFrame then GG.avgILevelFrame:Hide() end
                if GG.inspectAvgILevelFrame then GG.inspectAvgILevelFrame:Hide() end
            end
        end

        if featureName == "bagHighlight" then
            GG.UpdateAllBagSlots()
        end

        print("|cff00ff00GearGuardian:|r " .. (self:GetChecked() and "Enabled" or "Disabled") .. " - " .. label)
    end)

    checkboxes[featureName] = checkbox
    return checkbox
end

-- Create sections with headers
local currentY = -10

-- VISUAL FEATURES
CreateSectionHeader("Visual Features", currentY)
currentY = currentY - 28

CreateCheckbox("qualityBorders", featureLabels.qualityBorders, featureDescriptions.qualityBorders, currentY)
currentY = currentY - 35
CreateCheckbox("itemLevel", featureLabels.itemLevel, featureDescriptions.itemLevel, currentY)
currentY = currentY - 35
CreateCheckbox("averageILevel", featureLabels.averageILevel, featureDescriptions.averageILevel, currentY)
currentY = currentY - 45

-- INSPECTION & WARNINGS
CreateSectionHeader("Inspection & Warnings", currentY)
currentY = currentY - 28

CreateCheckbox("enchantCheck", featureLabels.enchantCheck, featureDescriptions.enchantCheck, currentY)
currentY = currentY - 45

-- TOOLTIPS & COMPARISON
CreateSectionHeader("Tooltips & Comparison", currentY)
currentY = currentY - 28

CreateCheckbox("comparison", featureLabels.comparison, featureDescriptions.comparison, currentY)
currentY = currentY - 45

-- ADVANCED (Coming Soon)
CreateSectionHeader("Advanced Features", currentY)
currentY = currentY - 28

CreateCheckbox("bagHighlight", featureLabels.bagHighlight, featureDescriptions.bagHighlight, currentY)
currentY = currentY - 35
CreateCheckbox("gemCheck", featureLabels.gemCheck, featureDescriptions.gemCheck, currentY)
currentY = currentY - 35
CreateCheckbox("setBonusTracking", featureLabels.setBonusTracking, featureDescriptions.setBonusTracking, currentY)
currentY = currentY - 35
CreateCheckbox("dualSpecSupport", featureLabels.dualSpecSupport, featureDescriptions.dualSpecSupport, currentY)

-- Info text at bottom
local infoText = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
infoText:SetPoint("BOTTOM", configFrame, "BOTTOM", 0, 45)
infoText:SetText("|cff88FF88Changes apply immediately - no UI reload needed|r")
infoText:SetWidth(540)
infoText:SetJustifyH("CENTER")

-- Author credit
local authorText = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
authorText:SetPoint("BOTTOM", configFrame, "BOTTOM", 0, 32)
authorText:SetText("|cff888888Created by |cffFFD700Sluck|r")
authorText:SetFont("Fonts\\FRIZQT__.TTF", 10)

-- Reload button
local loadButton = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
loadButton:SetSize(100, 25)
loadButton:SetPoint("BOTTOM", configFrame, "BOTTOM", 0, 8)
loadButton:SetText("Reload UI")
loadButton:SetScript("OnClick", function()
    ReloadUI()
end)

-- Function to refresh checkboxes from saved config
local function RefreshConfigUI()
    for featureName, checkbox in pairs(checkboxes) do
        checkbox:SetChecked(GG.GetConfig(featureName))
    end
end

-- Show event
configFrame:SetScript("OnShow", function()
    RefreshConfigUI()
end)

-- ESC key closes the frame
table.insert(UISpecialFrames, "GearGuardianConfigFrame")

-- Register with Blizzard interface options (TBC compatible)
if InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(configFrame)
end

-- Export to namespace
GG.configFrame = configFrame
GG.RefreshConfigUI = RefreshConfigUI
