-- ============================================
-- GearGuardian - Average Item Level Module
-- ============================================

local GG = GearGuardian
if not GG then return end

-- ============================================
-- AVERAGE ILEVEL CALCULATION
-- ============================================

-- Calculate average item level for a unit (supports GUID via LibClassicInspector)
function GG.CalculateAverageItemLevel(guid)
    if not guid then return 0 end

    -- Slots that count for average iLevel (excluding shirt, tabard)
    local slotsForAverage = {
        1,  -- Head
        2,  -- Neck
        3,  -- Shoulder
        5,  -- Chest
        6,  -- Waist
        7,  -- Legs
        8,  -- Feet
        9,  -- Wrist
        10, -- Hands
        11, -- Finger 1
        12, -- Finger 2
        13, -- Trinket 1
        14, -- Trinket 2
        15, -- Back
        16, -- Main Hand
        17, -- Off Hand
        18  -- Ranged
    }

    local totalILevel = 0
    local itemCount = 0

    for _, slotID in ipairs(slotsForAverage) do
        local itemLink = GG.GetItemLinkByGUID(guid, slotID)
        if itemLink then
            local iLevel = GG.GetItemLevel(itemLink)
            if iLevel and iLevel > 0 then
                totalILevel = totalILevel + iLevel
                itemCount = itemCount + 1
            end
        end
    end

    if itemCount == 0 then
        return 0
    end

    return math.floor(totalILevel / itemCount + 0.5)
end

-- Create or update average iLevel display on character frame
GG.avgILevelFrame = nil

function GG.UpdateAverageILevelDisplay()
    if not GG.GetConfig("averageILevel") then
        if GG.avgILevelFrame then
            GG.avgILevelFrame:Hide()
        end
        return
    end

    if not CharacterFrame or not CharacterFrame:IsShown() then
        return
    end

    -- Create frame if it doesn't exist
    if not GG.avgILevelFrame then
        GG.avgILevelFrame = CreateFrame("Frame", "GGAvgILevelFrame", PaperDollFrame)
        GG.avgILevelFrame:SetSize(120, 16)
        GG.avgILevelFrame:SetPoint("TOP", PaperDollFrame, "TOP", 0, -55)

        local bg = GG.avgILevelFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0.8)

        -- GearScore text
        local gsLabel = GG.avgILevelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        gsLabel:SetPoint("CENTER", GG.avgILevelFrame, "CENTER", -35, 0)
        gsLabel:SetText("GS:")
        gsLabel:SetFont("Fonts\\FRIZQT__.TTF", 10)
        GG.avgILevelFrame.gsLabel = gsLabel

        local gsValue = GG.avgILevelFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        gsValue:SetPoint("LEFT", gsLabel, "RIGHT", 2, 0)
        gsValue:SetFont("Fonts\\FRIZQT__.TTF", 10)
        GG.avgILevelFrame.gsValue = gsValue

        -- iLvl text
        local label = GG.avgILevelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("LEFT", gsValue, "RIGHT", 5, 0)
        label:SetText("iLvl:")
        label:SetFont("Fonts\\FRIZQT__.TTF", 10)
        GG.avgILevelFrame.label = label

        local value = GG.avgILevelFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        value:SetPoint("LEFT", label, "RIGHT", 2, 0)
        value:SetFont("Fonts\\FRIZQT__.TTF", 10)
        GG.avgILevelFrame.value = value
    end

    -- Calculate and display
    local playerGUID = UnitGUID("player")
    local gearScore = GG.CalculateGearScore(playerGUID)
    local avgILevel = GG.CalculateAverageItemLevel(playerGUID)

    -- Display GearScore
    GG.avgILevelFrame.gsValue:SetText(gearScore)
    local r, g, b = GG.GetGearScoreColor(gearScore)
    GG.avgILevelFrame.gsValue:SetTextColor(r, g, b)

    -- Display iLevel
    GG.avgILevelFrame.value:SetText(avgILevel)
    if avgILevel >= 140 then
        GG.avgILevelFrame.value:SetTextColor(1, 0.5, 0) -- Orange (epic tier)
    elseif avgILevel >= 115 then
        GG.avgILevelFrame.value:SetTextColor(0.64, 0.21, 0.93) -- Purple (epic)
    elseif avgILevel >= 90 then
        GG.avgILevelFrame.value:SetTextColor(0, 0.44, 0.87) -- Blue (rare)
    else
        GG.avgILevelFrame.value:SetTextColor(0, 1, 0) -- Green
    end

    GG.avgILevelFrame:Show()
end

-- Create or update average iLevel display on inspect frame
GG.inspectAvgILevelFrame = nil

function GG.UpdateInspectAverageILevelDisplay()
    if not GG.GetConfig("averageILevel") then
        if GG.inspectAvgILevelFrame then
            GG.inspectAvgILevelFrame:Hide()
        end
        return
    end

    -- Use inspectedUnit or fallback to "target"
    local unitToInspect = GG.inspectedUnit or "target"

    if not unitToInspect then
        if GG.inspectAvgILevelFrame then
            GG.inspectAvgILevelFrame:Hide()
        end
        return
    end

    -- Store for use below
    local currentInspectedUnit = unitToInspect
    local currentInspectedGUID = UnitGUID(unitToInspect)

    -- Create frame if it doesn't exist
    if not GG.inspectAvgILevelFrame then
        -- Try to find the right parent frame
        local parentFrame = InspectPaperDollFrame or InspectFrame
        if not parentFrame then
            -- Try again later
            C_Timer.After(0.5, GG.UpdateInspectAverageILevelDisplay)
            return
        end

        GG.inspectAvgILevelFrame = CreateFrame("Frame", "GGInspectAvgILevelFrame", UIParent)
        GG.inspectAvgILevelFrame:SetSize(120, 16)
        GG.inspectAvgILevelFrame:SetFrameStrata("HIGH")
        GG.inspectAvgILevelFrame:SetFrameLevel(100)

        local bg = GG.inspectAvgILevelFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0.8)

        -- GearScore text
        local gsLabel = GG.inspectAvgILevelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        gsLabel:SetPoint("CENTER", GG.inspectAvgILevelFrame, "CENTER", -35, 0)
        gsLabel:SetText("GS:")
        gsLabel:SetFont("Fonts\\FRIZQT__.TTF", 10)
        GG.inspectAvgILevelFrame.gsLabel = gsLabel

        local gsValue = GG.inspectAvgILevelFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        gsValue:SetPoint("LEFT", gsLabel, "RIGHT", 2, 0)
        gsValue:SetFont("Fonts\\FRIZQT__.TTF", 10)
        GG.inspectAvgILevelFrame.gsValue = gsValue

        -- iLvl text
        local label = GG.inspectAvgILevelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("LEFT", gsValue, "RIGHT", 5, 0)
        label:SetText("iLvl:")
        label:SetFont("Fonts\\FRIZQT__.TTF", 10)
        GG.inspectAvgILevelFrame.label = label

        local value = GG.inspectAvgILevelFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        value:SetPoint("LEFT", label, "RIGHT", 2, 0)
        value:SetFont("Fonts\\FRIZQT__.TTF", 10)
        GG.inspectAvgILevelFrame.value = value
    end

    -- Position relative to inspect frame
    local parentFrame = InspectPaperDollFrame or InspectFrame

    if parentFrame and parentFrame:IsShown() then
        GG.inspectAvgILevelFrame:ClearAllPoints()
        GG.inspectAvgILevelFrame:SetPoint("TOP", parentFrame, "TOP", 0, -40)
        GG.inspectAvgILevelFrame:SetParent(parentFrame)

        -- Calculate and display
        local gearScore = GG.CalculateGearScore(currentInspectedGUID)
        local avgILevel = GG.CalculateAverageItemLevel(currentInspectedGUID)

        if (gearScore and gearScore > 0) or (avgILevel and avgILevel > 0) then
            -- Display GearScore
            GG.inspectAvgILevelFrame.gsValue:SetText(gearScore or 0)
            local r, g, b = GG.GetGearScoreColor(gearScore or 0)
            GG.inspectAvgILevelFrame.gsValue:SetTextColor(r, g, b)

            -- Display iLevel
            GG.inspectAvgILevelFrame.value:SetText(avgILevel or 0)
            if avgILevel >= 140 then
                GG.inspectAvgILevelFrame.value:SetTextColor(1, 0.5, 0)
            elseif avgILevel >= 115 then
                GG.inspectAvgILevelFrame.value:SetTextColor(0.64, 0.21, 0.93)
            elseif avgILevel >= 90 then
                GG.inspectAvgILevelFrame.value:SetTextColor(0, 0.44, 0.87)
            else
                GG.inspectAvgILevelFrame.value:SetTextColor(0, 1, 0)
            end

            GG.inspectAvgILevelFrame:Show()
        else
            GG.inspectAvgILevelFrame:Hide()
        end
    else
        GG.inspectAvgILevelFrame:Hide()
    end
end
