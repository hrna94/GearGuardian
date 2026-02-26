--[[
    GearGuardian - Tooltip Integration
    Author: Sluck
    Version: 2.6

    Copyright (c) 2025 Sluck. All Rights Reserved.
--]]

local GG = GearGuardian
if not GG then return end

local CI = LibStub("LibClassicInspector")

-- ============================================
-- TOOLTIP INTEGRATION
-- ============================================

-- Hook tooltip for comparison
local function OnTooltipSetItem(tooltip)
    local _, itemLink = tooltip:GetItem()
    if not itemLink then return end

    -- Check if item is usable by player first
    local isUsable, reason = GG.IsItemUsableByPlayer(itemLink)
    if not isUsable then
        tooltip:AddLine(" ")
        tooltip:AddLine("|cffff5555Not usable by your class|r")
        tooltip:Show()
        return
    end

    local class, spec = GG.GetPlayerSpec()

    if not GG.StatWeights[class] or not GG.StatWeights[class][spec] then
        return
    end

    local weights = GG.StatWeights[class][spec]

    -- Find which slot the item belongs to
    local itemName, _, _, _, _, _, _, _, equipSlot = GetItemInfo(itemLink)
    if not equipSlot or equipSlot == "" then
        return
    end

    -- Mapping slot names to inventory slots
    local slotMap = {
        INVTYPE_HEAD = 1,
        INVTYPE_NECK = 2,
        INVTYPE_SHOULDER = 3,
        INVTYPE_BODY = 4,
        INVTYPE_CHEST = 5,
        INVTYPE_ROBE = 5,
        INVTYPE_WAIST = 6,
        INVTYPE_LEGS = 7,
        INVTYPE_FEET = 8,
        INVTYPE_WRIST = 9,
        INVTYPE_HAND = 10,
        INVTYPE_FINGER = {11, 12},
        INVTYPE_TRINKET = {13, 14},
        INVTYPE_CLOAK = 15,
        INVTYPE_WEAPON = 16,
        INVTYPE_SHIELD = 17,
        INVTYPE_2HWEAPON = 16,
        INVTYPE_WEAPONMAINHAND = 16,
        INVTYPE_WEAPONOFFHAND = 17,
        INVTYPE_HOLDABLE = 17,
        INVTYPE_RANGED = 18,
        INVTYPE_RANGEDRIGHT = 18,
        INVTYPE_THROWN = 18,
    }

    local slotID = slotMap[equipSlot]
    if not slotID then return end

    -- For slots where you can have 2 items (rings, trinkets)
    local slotsToCheck = {}
    if type(slotID) == "table" then
        slotsToCheck = slotID
    else
        table.insert(slotsToCheck, slotID)
    end

    -- Parse stats of the new item
    local newItemStats = GG.ParseItemStats(itemLink)
    local newItemScore = GG.CalculateItemScore(newItemStats, weights)
    local newItemLevel = GG.GetItemLevel(itemLink)

    -- Slot names for display
    local slotNames = {
        [11] = "Ring 1",
        [12] = "Ring 2",
        [13] = "Trinket 1",
        [14] = "Trinket 2",
        [16] = "Main Hand",
        [17] = "Off Hand"
    }

    -- Check if this is a dual-slot item (rings, trinkets)
    local isDualSlot = type(slotID) == "table"

    tooltip:AddLine(" ")
    tooltip:AddLine("|cffffff00Comparison for " .. spec .. " " .. class .. ":|r")

    if isDualSlot then
        -- Compare with both slots separately
        local hasAnyItem = false

        for _, slot in ipairs(slotsToCheck) do
            local equippedLink = GetInventoryItemLink("player", slot)
            local slotName = slotNames[slot] or "Slot " .. slot

            if equippedLink then
                hasAnyItem = true
                local equippedStats = GG.ParseItemStats(equippedLink)
                local equippedScore = GG.CalculateItemScore(equippedStats, weights)
                local equippedLevel = GG.GetItemLevel(equippedLink) or 0

                local scoreDiff = newItemScore - equippedScore
                local iLevelDiff = (newItemLevel or 0) - equippedLevel

                -- Show comparison for this slot
                if scoreDiff > 0 then
                    tooltip:AddLine(string.format("%s: |cff00ff00+%.1f score (%.1f%%)|r", slotName, scoreDiff, (scoreDiff/equippedScore)*100), 1, 1, 1)
                elseif scoreDiff < 0 then
                    tooltip:AddLine(string.format("%s: |cffff0000%.1f score (%.1f%%)|r", slotName, scoreDiff, (scoreDiff/equippedScore)*100), 1, 1, 1)
                else
                    tooltip:AddLine(string.format("%s: |cffffff00Same score|r", slotName), 1, 1, 1)
                end

                if iLevelDiff ~= 0 then
                    local color = iLevelDiff > 0 and "|cff00ff00" or "|cffff0000"
                    tooltip:AddLine(string.format("  %siLevel: %s%d|r", color, iLevelDiff > 0 and "+" or "", iLevelDiff), 0.8, 0.8, 0.8)
                end
            else
                -- Empty slot
                if newItemScore > 0 then
                    tooltip:AddLine(string.format("%s: |cff00ff00Empty slot - %.1f score|r", slotName, newItemScore), 1, 1, 1)
                end
            end
        end

        -- Show new item score summary
        if hasAnyItem and newItemScore > 0 then
            tooltip:AddLine(string.format("New item score: %.1f", newItemScore), 0.7, 0.7, 0.7)
        end
    else
        -- Single slot comparison (original logic)
        local equippedLink = GetInventoryItemLink("player", slotsToCheck[1])

        if equippedLink then
            local equippedStats = GG.ParseItemStats(equippedLink)
            local equippedScore = GG.CalculateItemScore(equippedStats, weights)
            local equippedLevel = GG.GetItemLevel(equippedLink) or 0

            local scoreDiff = newItemScore - equippedScore
            local iLevelDiff = (newItemLevel or 0) - equippedLevel

            if scoreDiff > 0 then
                tooltip:AddLine(string.format("|cff00ff00UPGRADE: +%.1f score (%.1f%%)|r", scoreDiff, (scoreDiff/equippedScore)*100), 1, 1, 1)
            elseif scoreDiff < 0 then
                tooltip:AddLine(string.format("|cffff0000DOWNGRADE: %.1f score (%.1f%%)|r", scoreDiff, (scoreDiff/equippedScore)*100), 1, 1, 1)
            else
                tooltip:AddLine("|cffffff00SAME score|r", 1, 1, 1)
            end

            if iLevelDiff ~= 0 then
                local color = iLevelDiff > 0 and "|cff00ff00" or "|cffff0000"
                tooltip:AddLine(color .. "iLevel: " .. (iLevelDiff > 0 and "+" or "") .. iLevelDiff .. "|r", 1, 1, 1)
            end

            if newItemScore > 0 then
                tooltip:AddLine(string.format("New: %.1f | Current: %.1f", newItemScore, equippedScore), 0.7, 0.7, 0.7)
            end
        else
            -- No item equipped
            if newItemScore > 0 then
                tooltip:AddLine(string.format("|cff00ff00%.1f score|r", newItemScore), 1, 1, 1)
            end
        end
    end

    -- Add enchant/gem information if checking equipped items
    if (GG.GetConfig("enchantCheck") or GG.GetConfig("gemCheck")) then
        -- Find which slot this item would go into
        local slotID = slotMap[equipSlot]
        local slotsToCheck = {}

        if type(slotID) == "table" then
            slotsToCheck = slotID
        elseif slotID then
            table.insert(slotsToCheck, slotID)
        end

        -- Check equipped items for enchants/gems
        -- Determine which unit we're checking (player or inspected target)
        local checkUnit = "player"
        local checkGUID = UnitGUID("player")

        -- Check if we're hovering over an inspected player's item
        if InspectFrame and InspectFrame:IsShown() then
            -- Try to get inspected unit
            local inspUnit = nil
            if InspectFrame.unit then
                inspUnit = InspectFrame.unit
            elseif UnitExists("target") then
                inspUnit = "target"
            end

            if inspUnit and UnitExists(inspUnit) then
                -- Check if tooltip item matches inspected unit's equipment
                for _, slot in ipairs(slotsToCheck) do
                    local inspectedLink = GetInventoryItemLink(inspUnit, slot)
                    if inspectedLink and inspectedLink == itemLink then
                        checkUnit = inspUnit
                        checkGUID = UnitGUID(inspUnit)
                        break
                    end
                end
            end
        end

        -- Now check the appropriate unit
        for _, slot in ipairs(slotsToCheck) do
            local equippedLink = GetInventoryItemLink(checkUnit, slot)
            if equippedLink then
                local warnings = {}

                if GG.GetConfig("enchantCheck") and GG.ShouldHaveEnchant(slot) then
                    local hasEnch = GG.HasEnchant(slot, false, checkGUID)
                    if not hasEnch then
                        table.insert(warnings, "|cffff0000Missing enchant|r")
                    end
                end

                if GG.GetConfig("gemCheck") then
                    local emptyCount = GG.GetEmptySocketCount(slot, checkGUID)
                    if emptyCount > 0 then
                        table.insert(warnings, string.format("|cffff0000%d empty socket(s)|r", emptyCount))
                    end
                end

                if #warnings > 0 then
                    tooltip:AddLine(" ")
                    tooltip:AddLine("Equipped item warnings:", 1, 0.5, 0.5)
                    for _, warning in ipairs(warnings) do
                        tooltip:AddLine("  " .. warning, 1, 1, 1)
                    end
                end

                break -- Only show for first equipped item in dual slots
            end
        end
    end

    tooltip:Show()
end

-- Hook tooltips with config check
local function SafeOnTooltipSetItem(tooltip)
    if GG.GetConfig("comparison") then
        OnTooltipSetItem(tooltip)
    end
end

GameTooltip:HookScript("OnTooltipSetItem", SafeOnTooltipSetItem)
ItemRefTooltip:HookScript("OnTooltipSetItem", SafeOnTooltipSetItem)
ShoppingTooltip1:HookScript("OnTooltipSetItem", SafeOnTooltipSetItem)
ShoppingTooltip2:HookScript("OnTooltipSetItem", SafeOnTooltipSetItem)

-- Callback when LibClassicInspector has data ready
local function OnInspectReady(guid)
    local _, ttUnit = GameTooltip:GetUnit()
    if ttUnit and UnitGUID(ttUnit) == guid then
        GameTooltip:SetUnit(ttUnit)
    end
end

-- Register callback
CI.RegisterCallback("GearGuardian", "INVENTORY_READY", OnInspectReady)

-- Hook GameTooltip to show GearScore and iLvl
GameTooltip:HookScript("OnTooltipSetUnit", function(self)
    if not GG.GetConfig("averageILevel") then return end

    local _, unit = self:GetUnit()
    if not unit or not UnitIsPlayer(unit) then return end

    local guid = UnitGUID(unit)
    if not guid then return end

    -- Calculate GearScore and iLvl
    -- LibClassicInspector will automatically request data when needed
    local gearScore = GG.CalculateGearScore(guid)
    local avgILevel = GG.CalculateAverageItemLevel(guid)

    if gearScore > 0 or avgILevel > 0 then
        -- Add a blank line for spacing
        self:AddLine(" ")

        -- Add GearScore line with color
        if gearScore > 0 then
            local r, g, b = GG.GetGearScoreColor(gearScore)
            self:AddDoubleLine("GearScore:", gearScore, 1, 1, 1, r, g, b)
        end

        -- Add average item level line
        if avgILevel > 0 then
            local r, g, b = 1, 1, 1
            if avgILevel >= 140 then
                r, g, b = 1, 0.5, 0  -- Orange for high iLvl
            elseif avgILevel >= 115 then
                r, g, b = 0.69, 0.28, 0.97  -- Purple for epic
            elseif avgILevel >= 90 then
                r, g, b = 0, 0.50, 1  -- Blue for rare
            end
            self:AddDoubleLine("Avg Item Level:", avgILevel, 1, 1, 1, r, g, b)
        end
    end
end)

-- Export to namespace
GG.OnTooltipSetItem = OnTooltipSetItem
GG.SafeOnTooltipSetItem = SafeOnTooltipSetItem
GG.OnInspectReady = OnInspectReady
