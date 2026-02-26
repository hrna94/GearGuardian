-- ============================================
-- GearGuardian - Quality Borders and Slot Updates Module
-- ============================================

local GG = GearGuardian
if not GG then return end

-- ============================================
-- QUALITY BORDERS AND SLOT UPDATE FUNCTIONS
-- ============================================

-- All character frame slots
local characterSlots = {
    "CharacterHeadSlot",
    "CharacterNeckSlot",
    "CharacterShoulderSlot",
    "CharacterBackSlot",
    "CharacterChestSlot",
    "CharacterShirtSlot",
    "CharacterTabardSlot",
    "CharacterWristSlot",
    "CharacterHandsSlot",
    "CharacterWaistSlot",
    "CharacterLegsSlot",
    "CharacterFeetSlot",
    "CharacterFinger0Slot",
    "CharacterFinger1Slot",
    "CharacterTrinket0Slot",
    "CharacterTrinket1Slot",
    "CharacterMainHandSlot",
    "CharacterSecondaryHandSlot",
    "CharacterRangedSlot",
}

-- Function to create or update slot border
local function UpdateSlotBorder(slotFrame)
    if not slotFrame then return end

    -- Get slot ID
    local slotID = slotFrame:GetID()
    local itemLink = GetInventoryItemLink("player", slotID)

    -- Create border texture if it doesn't exist
    if not slotFrame.qualityBorder then
        slotFrame.qualityBorder = slotFrame:CreateTexture(nil, "OVERLAY")
        slotFrame.qualityBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        slotFrame.qualityBorder:SetBlendMode("ADD")
        slotFrame.qualityBorder:SetWidth(slotFrame:GetWidth() * 1.8)
        slotFrame.qualityBorder:SetHeight(slotFrame:GetHeight() * 1.8)
        slotFrame.qualityBorder:SetPoint("CENTER", slotFrame, "CENTER", 0, 0)
    end

    -- Item level text
    if not slotFrame.iLevelText then
        slotFrame.iLevelText = slotFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
        slotFrame.iLevelText:SetPoint("BOTTOMRIGHT", slotFrame, "BOTTOMRIGHT", -2, 2)
        slotFrame.iLevelText:SetTextColor(1, 1, 0.5, 1)
    end

    -- Warning icon for missing enchants/gems
    if not slotFrame.warningIcon then
        slotFrame.warningIcon = slotFrame:CreateTexture(nil, "OVERLAY", nil, 7)
        -- Yellow warning triangle with exclamation mark
        slotFrame.warningIcon:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
        slotFrame.warningIcon:SetSize(16, 16)
        slotFrame.warningIcon:SetPoint("TOPLEFT", slotFrame, "TOPLEFT", 2, -2)
        slotFrame.warningIcon:SetVertexColor(1, 1, 1, 1) -- Keep original yellow color
    end

    -- If item is in slot, set color by quality and item level
    if itemLink then
        -- OPTIMIZED: Get both quality and iLevel in one call
        local _, _, quality, iLevel = GetItemInfo(itemLink)

        -- Quality borders (check config)
        if GG.GetConfig("qualityBorders") and quality and quality > 1 then
            local r, g, b = GetItemQualityColor(quality)
            slotFrame.qualityBorder:SetVertexColor(r, g, b, 1)
            slotFrame.qualityBorder:Show()
        else
            slotFrame.qualityBorder:Hide()
        end

        -- Item level display (check config)
        if GG.GetConfig("itemLevel") and iLevel then
            slotFrame.iLevelText:SetText(iLevel)
            slotFrame.iLevelText:Show()
        else
            slotFrame.iLevelText:Hide()
        end

        -- Check for missing enchants and empty sockets
        local showWarning = false

        if GG.GetConfig("enchantCheck") and GG.ShouldHaveEnchant(slotID) then
            if not GG.HasEnchant(slotID) then
                showWarning = true
            end
        end

        if GG.GetConfig("gemCheck") and not showWarning then
            local emptySocketCount = GG.GetEmptySocketCount(slotID)
            if emptySocketCount > 0 then
                showWarning = true
            end
        end

        -- Check meta gem requirements (only for head slot)
        if GG.GetConfig("metaGemCheck") and not showWarning and slotID == 1 then
            local metaActive = GG.CheckMetaGemRequirements(UnitGUID("player"))
            if metaActive == false then
                showWarning = true
            end
        end

        if showWarning then
            slotFrame.warningIcon:Show()
        else
            slotFrame.warningIcon:Hide()
        end
    else
        slotFrame.qualityBorder:Hide()
        slotFrame.iLevelText:Hide()
        slotFrame.warningIcon:Hide()
    end
end

-- Function to update all slots
function GG.UpdateAllSlots()
    for _, slotName in ipairs(characterSlots) do
        local slotFrame = _G[slotName]
        if slotFrame then
            UpdateSlotBorder(slotFrame)
        end
    end
end

-- Function to update inspect slot
function GG.UpdateInspectSlot(slotFrame)
    if not slotFrame then return end
    if not GG.inspectedUnit then return end

    local slotID = slotFrame:GetID()
    local inspectedGUID = UnitGUID(GG.inspectedUnit)
    local itemLink = inspectedGUID and GG.GetItemLinkByGUID(inspectedGUID, slotID) or nil

    if not slotFrame.qualityBorder then
        slotFrame.qualityBorder = slotFrame:CreateTexture(nil, "OVERLAY")
        slotFrame.qualityBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        slotFrame.qualityBorder:SetBlendMode("ADD")
        slotFrame.qualityBorder:SetWidth(slotFrame:GetWidth() * 1.8)
        slotFrame.qualityBorder:SetHeight(slotFrame:GetHeight() * 1.8)
        slotFrame.qualityBorder:SetPoint("CENTER", slotFrame, "CENTER", 0, 0)
    end

    -- Item level text for inspect frame
    if not slotFrame.iLevelText then
        slotFrame.iLevelText = slotFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
        slotFrame.iLevelText:SetPoint("BOTTOMRIGHT", slotFrame, "BOTTOMRIGHT", -2, 2)
        slotFrame.iLevelText:SetTextColor(1, 1, 0.5, 1)
    end

    -- Warning icon for missing enchants/gems on inspect frame
    if not slotFrame.warningIcon then
        slotFrame.warningIcon = slotFrame:CreateTexture(nil, "OVERLAY", nil, 7)
        slotFrame.warningIcon:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
        slotFrame.warningIcon:SetSize(16, 16)
        slotFrame.warningIcon:SetPoint("TOPLEFT", slotFrame, "TOPLEFT", 2, -2)
        slotFrame.warningIcon:SetVertexColor(1, 1, 1, 1)
    end

    if itemLink then
        local _, _, quality = GetItemInfo(itemLink)
        local iLevel = GG.GetItemLevel(itemLink)

        -- Quality borders (check config)
        if GG.GetConfig("qualityBorders") and quality and quality > 1 then
            local r, g, b = GetItemQualityColor(quality)
            slotFrame.qualityBorder:SetVertexColor(r, g, b, 1)
            slotFrame.qualityBorder:Show()
        else
            slotFrame.qualityBorder:Hide()
        end

        -- Item level display (check config)
        if GG.GetConfig("itemLevel") and iLevel then
            slotFrame.iLevelText:SetText(iLevel)
            slotFrame.iLevelText:Show()
        else
            slotFrame.iLevelText:Hide()
        end

        -- Check for missing enchants and empty sockets on inspected target
        local showWarning = false

        if inspectedGUID and GG.GetConfig("enchantCheck") and GG.ShouldHaveEnchant(slotID) then
            -- Check if we have cached data
            local _, invTime = GG.CI:GetLastCacheTime(inspectedGUID)
            if invTime > 0 then -- Only check if we have inspect data
                local hasEnch = GG.HasEnchant(slotID, false, inspectedGUID)
                if not hasEnch then
                    showWarning = true
                end
            end
        end

        if inspectedGUID and GG.GetConfig("gemCheck") and not showWarning then
            local _, invTime = GG.CI:GetLastCacheTime(inspectedGUID)
            -- Wait at least 1.5s after cache to ensure gem data is complete
            if invTime > 0 and (GetTime() - invTime) > 1.5 then
                local emptySocketCount = GG.GetEmptySocketCount(slotID, inspectedGUID)
                if emptySocketCount > 0 then
                    showWarning = true
                end
            end
        end

        if showWarning then
            slotFrame.warningIcon:Show()
        else
            slotFrame.warningIcon:Hide()
        end
    else
        slotFrame.qualityBorder:Hide()
        slotFrame.iLevelText:Hide()
        slotFrame.warningIcon:Hide()
    end
end

-- Setup inspect frame hooks
function GG.SetupInspectFrame()
    local inspectSlots = {
        "InspectHeadSlot",
        "InspectNeckSlot",
        "InspectShoulderSlot",
        "InspectBackSlot",
        "InspectChestSlot",
        "InspectShirtSlot",
        "InspectTabardSlot",
        "InspectWristSlot",
        "InspectHandsSlot",
        "InspectWaistSlot",
        "InspectLegsSlot",
        "InspectFeetSlot",
        "InspectFinger0Slot",
        "InspectFinger1Slot",
        "InspectTrinket0Slot",
        "InspectTrinket1Slot",
        "InspectMainHandSlot",
        "InspectSecondaryHandSlot",
        "InspectRangedSlot",
    }

    local function UpdateAllInspectSlots()
        for _, slotName in ipairs(inspectSlots) do
            local slotFrame = _G[slotName]
            if slotFrame then
                GG.UpdateInspectSlot(slotFrame)
            end
        end
    end

    -- OPTIMIZATION: Scheduled timer for inspect updates (prevents duplicate updates)
    local inspectUpdateTimer = nil

    -- Schedule inspect update with debouncing (cancels previous timer)
    local function ScheduleInspectUpdate(delay)
        -- Cancel previous timer if exists
        if inspectUpdateTimer then
            inspectUpdateTimer:Cancel()
        end

        -- Schedule new update
        inspectUpdateTimer = C_Timer.NewTimer(delay or 0.8, function()
            UpdateAllInspectSlots()
            GG.UpdateInspectAverageILevelDisplay()
            inspectUpdateTimer = nil
        end)
    end

    -- Register events for inspect frame
    local inspectEventFrame = CreateFrame("Frame")
    inspectEventFrame:RegisterEvent("INSPECT_READY")
    inspectEventFrame:SetScript("OnEvent", function(self, event, guid)
        if event == "INSPECT_READY" then
            local targetUnit = InspectFrame and InspectFrame.unit or "target"
            GG.inspectedUnit = targetUnit

            -- OPTIMIZED: Single scheduled update instead of multiple timers
            if not GG.inspectedUnit then
                GG.inspectedUnit = targetUnit
            end
            -- Initial update with longer delay to allow LibClassicInspector to cache data
            ScheduleInspectUpdate(2.0)

            -- Second update after additional delay to catch late-loading gem data
            C_Timer.After(4.0, function()
                if GG.inspectedUnit then
                    UpdateAllInspectSlots()
                    GG.UpdateInspectAverageILevelDisplay()
                end
            end)
        end
    end)

    -- Hook NotifyInspect to store unit
    hooksecurefunc("NotifyInspect", function(unit)
        GG.inspectedUnit = unit
    end)

    -- Hook InspectFrame if it exists
    if InspectFrame then
        InspectFrame:HookScript("OnShow", function(self)
            GG.inspectedUnit = self.unit or "target"
            -- OPTIMIZED: Single scheduled update with longer delay for gem data
            ScheduleInspectUpdate(2.0)

            -- Second update to catch late-loading gem data
            C_Timer.After(4.0, function()
                if GG.inspectedUnit then
                    UpdateAllInspectSlots()
                    GG.UpdateInspectAverageILevelDisplay()
                end
            end)
        end)

        InspectFrame:HookScript("OnHide", function()
            -- OPTIMIZED: Immediate cleanup, no unnecessary delay
            GG.inspectedUnit = nil
            if inspectUpdateTimer then
                inspectUpdateTimer:Cancel()
                inspectUpdateTimer = nil
            end
            if GG.inspectGSFrame then
                GG.inspectGSFrame:Hide()
            end
            if GG.inspectILevelFrame then
                GG.inspectILevelFrame:Hide()
            end
        end)
    end

    -- Fallback hook for PaperDollFrame if it exists
    if InspectPaperDollFrame then
        InspectPaperDollFrame:HookScript("OnShow", function()
            if not GG.inspectedUnit then
                GG.inspectedUnit = "target"
            end
            -- OPTIMIZED: Single scheduled update
            ScheduleInspectUpdate(0.8)
        end)

        InspectPaperDollFrame:HookScript("OnHide", function()
            -- Cleanup frames
            if GG.inspectGSFrame then
                GG.inspectGSFrame:Hide()
            end
            if GG.inspectILevelFrame then
                GG.inspectILevelFrame:Hide()
            end
        end)
    end
end
