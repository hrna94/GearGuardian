-- ============================================
-- GearGuardian - Average Item Level Module
-- ============================================

local GG = GearGuardian
if not GG then return end

-- ============================================
-- AVERAGE ILEVEL CALCULATION
-- ============================================

-- OPTIMIZED: Calculate both GearScore and average iLevel in single iteration
-- This reduces API calls by ~50% compared to calling both functions separately
function GG.CalculateGearScoreAndItemLevel(guid)
    if not guid then return 0, 0 end

    local slots = {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}

    local totalScore = 0
    local totalILevel = 0
    local itemCount = 0

    for _, slotID in ipairs(slots) do
        local itemLink = GG.GetItemLinkByGUID(guid, slotID)
        if itemLink then
            -- Get both GearScore and iLevel in one iteration
            local score = GG.GetItemGearScore(itemLink)
            local iLevel = GG.GetItemLevel(itemLink)

            if score and score > 0 then
                totalScore = totalScore + score
            end

            if iLevel and iLevel > 0 then
                totalILevel = totalILevel + iLevel
                itemCount = itemCount + 1
            end
        end
    end

    local avgILevel = itemCount > 0 and math.floor(totalILevel / itemCount + 0.5) or 0

    return math.floor(totalScore), avgILevel
end

-- Calculate average item level for a unit (supports GUID via LibClassicInspector)
-- NOTE: For best performance, use GG.CalculateGearScoreAndItemLevel() if you need both values
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
GG.gsFrame = nil
GG.iLevelFrame = nil

function GG.UpdateAverageILevelDisplay()
    if not GG.GetConfig("averageILevel") then
        if GG.gsFrame then
            GG.gsFrame:Hide()
        end
        if GG.iLevelFrame then
            GG.iLevelFrame:Hide()
        end
        return
    end

    if not CharacterFrame or not CharacterFrame:IsShown() then
        return
    end

    -- Create GearScore frame (bottom right corner)
    if not GG.gsFrame then
        GG.gsFrame = CreateFrame("Frame", "GGGearScoreFrame", PaperDollFrame)
        GG.gsFrame:SetSize(50, 14)
        GG.gsFrame:SetPoint("BOTTOMLEFT", PaperDollFrame, "BOTTOMRIGHT", -84, 95)
        GG.gsFrame:SetFrameStrata("HIGH")
        GG.gsFrame:SetFrameLevel(200)

        local bg = GG.gsFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0.8)

        local gsLabel = GG.gsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        gsLabel:SetPoint("LEFT", GG.gsFrame, "LEFT", 2, 0)
        gsLabel:SetText("GS:")
        gsLabel:SetFont("Fonts\\FRIZQT__.TTF", 9)
        GG.gsFrame.gsLabel = gsLabel

        local gsValue = GG.gsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        gsValue:SetPoint("LEFT", gsLabel, "RIGHT", 2, 0)
        gsValue:SetFont("Fonts\\FRIZQT__.TTF", 9)
        GG.gsFrame.gsValue = gsValue
    end

    -- Create iLevel frame (directly below GearScore frame, no gap)
    if not GG.iLevelFrame then
        GG.iLevelFrame = CreateFrame("Frame", "GGILevelFrame", PaperDollFrame)
        GG.iLevelFrame:SetSize(50, 14)
        GG.iLevelFrame:SetPoint("TOP", GG.gsFrame, "BOTTOM", 0, 0)
        GG.iLevelFrame:SetFrameStrata("HIGH")
        GG.iLevelFrame:SetFrameLevel(200)

        local bg = GG.iLevelFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0.8)

        local label = GG.iLevelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("LEFT", GG.iLevelFrame, "LEFT", 2, 0)
        label:SetText("iLvl:")
        label:SetFont("Fonts\\FRIZQT__.TTF", 9)
        GG.iLevelFrame.label = label

        local value = GG.iLevelFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        value:SetPoint("LEFT", label, "RIGHT", 2, 0)
        value:SetFont("Fonts\\FRIZQT__.TTF", 9)
        GG.iLevelFrame.value = value
    end

    -- Calculate and display (OPTIMIZED: single iteration for both values)
    local playerGUID = UnitGUID("player")
    local gearScore, avgILevel = GG.CalculateGearScoreAndItemLevel(playerGUID)

    -- Display GearScore
    GG.gsFrame.gsValue:SetText(gearScore)
    local r, g, b = GG.GetGearScoreColor(gearScore)
    GG.gsFrame.gsValue:SetTextColor(r, g, b)

    -- Display iLevel
    GG.iLevelFrame.value:SetText(avgILevel)
    if avgILevel >= 140 then
        GG.iLevelFrame.value:SetTextColor(1, 0.5, 0) -- Orange (epic tier)
    elseif avgILevel >= 115 then
        GG.iLevelFrame.value:SetTextColor(0.64, 0.21, 0.93) -- Purple (epic)
    elseif avgILevel >= 90 then
        GG.iLevelFrame.value:SetTextColor(0, 0.44, 0.87) -- Blue (rare)
    else
        GG.iLevelFrame.value:SetTextColor(0, 1, 0) -- Green
    end

    GG.gsFrame:Show()
    GG.iLevelFrame:Show()
end

-- Create or update average iLevel display on inspect frame
GG.inspectGSFrame = nil
GG.inspectILevelFrame = nil

function GG.UpdateInspectAverageILevelDisplay()
    if not GG.GetConfig("averageILevel") then
        if GG.inspectGSFrame then
            GG.inspectGSFrame:Hide()
        end
        if GG.inspectILevelFrame then
            GG.inspectILevelFrame:Hide()
        end
        return
    end

    -- Use inspectedUnit or fallback to "target"
    local unitToInspect = GG.inspectedUnit or "target"

    if not unitToInspect then
        if GG.inspectGSFrame then
            GG.inspectGSFrame:Hide()
        end
        if GG.inspectILevelFrame then
            GG.inspectILevelFrame:Hide()
        end
        return
    end

    -- Store for use below
    local currentInspectedUnit = unitToInspect
    local currentInspectedGUID = UnitGUID(unitToInspect)

    -- Try to find the right parent frame
    local parentFrame = InspectPaperDollFrame or InspectFrame
    if not parentFrame then
        -- OPTIMIZED: Removed redundant timer, handled by ScheduleInspectUpdate in borders.lua
        return
    end

    -- Create GearScore frame (left side, near feet)
    if not GG.inspectGSFrame then
        GG.inspectGSFrame = CreateFrame("Frame", "GGInspectGearScoreFrame", UIParent)
        GG.inspectGSFrame:SetSize(50, 14)
        GG.inspectGSFrame:SetFrameStrata("HIGH")
        GG.inspectGSFrame:SetFrameLevel(100)

        local bg = GG.inspectGSFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0.8)

        local gsLabel = GG.inspectGSFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        gsLabel:SetPoint("LEFT", GG.inspectGSFrame, "LEFT", 2, 0)
        gsLabel:SetText("GS:")
        gsLabel:SetFont("Fonts\\FRIZQT__.TTF", 9)
        GG.inspectGSFrame.gsLabel = gsLabel

        local gsValue = GG.inspectGSFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        gsValue:SetPoint("LEFT", gsLabel, "RIGHT", 2, 0)
        gsValue:SetFont("Fonts\\FRIZQT__.TTF", 9)
        GG.inspectGSFrame.gsValue = gsValue
    end

    -- Create iLevel frame (right side, near feet)
    if not GG.inspectILevelFrame then
        GG.inspectILevelFrame = CreateFrame("Frame", "GGInspectILevelFrame", UIParent)
        GG.inspectILevelFrame:SetSize(50, 14)
        GG.inspectILevelFrame:SetFrameStrata("HIGH")
        GG.inspectILevelFrame:SetFrameLevel(100)

        local bg = GG.inspectILevelFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0.8)

        local label = GG.inspectILevelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("LEFT", GG.inspectILevelFrame, "LEFT", 2, 0)
        label:SetText("iLvl:")
        label:SetFont("Fonts\\FRIZQT__.TTF", 9)
        GG.inspectILevelFrame.label = label

        local value = GG.inspectILevelFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        value:SetPoint("LEFT", label, "RIGHT", 2, 0)
        value:SetFont("Fonts\\FRIZQT__.TTF", 9)
        GG.inspectILevelFrame.value = value
    end

    -- Position relative to inspect frame
    if parentFrame and parentFrame:IsShown() then
        -- Position on bottom right corner of inspect frame
        GG.inspectGSFrame:ClearAllPoints()
        GG.inspectGSFrame:SetPoint("BOTTOMLEFT", parentFrame, "BOTTOMRIGHT", -54, 15)
        GG.inspectGSFrame:SetParent(parentFrame)

        GG.inspectILevelFrame:ClearAllPoints()
        GG.inspectILevelFrame:SetPoint("TOP", GG.inspectGSFrame, "BOTTOM", 0, 0)
        GG.inspectILevelFrame:SetParent(parentFrame)

        -- Calculate and display (OPTIMIZED: single iteration for both values)
        local gearScore, avgILevel = GG.CalculateGearScoreAndItemLevel(currentInspectedGUID)

        if (gearScore and gearScore > 0) or (avgILevel and avgILevel > 0) then
            -- Display GearScore
            GG.inspectGSFrame.gsValue:SetText(gearScore or 0)
            local r, g, b = GG.GetGearScoreColor(gearScore or 0)
            GG.inspectGSFrame.gsValue:SetTextColor(r, g, b)

            -- Display iLevel
            GG.inspectILevelFrame.value:SetText(avgILevel or 0)
            if avgILevel >= 140 then
                GG.inspectILevelFrame.value:SetTextColor(1, 0.5, 0)
            elseif avgILevel >= 115 then
                GG.inspectILevelFrame.value:SetTextColor(0.64, 0.21, 0.93)
            elseif avgILevel >= 90 then
                GG.inspectILevelFrame.value:SetTextColor(0, 0.44, 0.87)
            else
                GG.inspectILevelFrame.value:SetTextColor(0, 1, 0)
            end

            GG.inspectGSFrame:Show()
            GG.inspectILevelFrame:Show()
        else
            GG.inspectGSFrame:Hide()
            GG.inspectILevelFrame:Hide()
        end
    else
        GG.inspectGSFrame:Hide()
        GG.inspectILevelFrame:Hide()
    end
end
