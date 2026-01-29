--[[
    GearGuardian - LibClassicInspector Helpers
    Functions for working with LibClassicInspector library
]]--

local GG = GearGuardian
local CI = GG.CI

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Get item level from item link
function GG.GetItemLevel(itemLink)
    if not itemLink then return nil end
    local name, link, quality, iLevel = GetItemInfo(itemLink)
    if not name then
        -- Item data not cached yet, request it
        local itemString = string.match(itemLink, "item[%-?%d:]+")
        if itemString then
            local itemID = string.match(itemString, "item:(%d+)")
            if itemID then
                C_Item.RequestLoadItemDataByID(tonumber(itemID))
            end
        end
        return nil
    end
    return iLevel
end

-- ============================================
-- LIBCLASSICINSPECTOR HELPERS
-- ============================================

-- Get item link using direct inspect API (has enchant data!)
function GG.GetItemLinkByGUID(guid, slotID, debugInfo)
    if not guid or not slotID then return nil end

    -- For player, use standard API
    if guid == UnitGUID("player") then
        return GetInventoryItemLink("player", slotID)
    end

    -- For inspected players, try multiple methods to get unit with enchant data
    local possibleUnits = {}

    -- Method 1: inspectedUnit variable (if available)
    if GG.inspectedUnit then
        table.insert(possibleUnits, GG.inspectedUnit)
    end

    -- Method 2: InspectFrame.unit (TBC)
    if InspectFrame and InspectFrame.unit then
        table.insert(possibleUnits, InspectFrame.unit)
    end

    -- Method 3: Try "target" if it matches GUID
    if UnitExists("target") and UnitGUID("target") == guid then
        table.insert(possibleUnits, "target")
    end

    -- Try each possible unit
    for _, unit in ipairs(possibleUnits) do
        if UnitExists(unit) and UnitGUID(unit) == guid then
            local directLink = GetInventoryItemLink(unit, slotID)
            if directLink then
                if debugInfo then
                    debugInfo.source = "DirectAPI"
                    debugInfo.unit = unit
                end
                return directLink
            end
        end
    end

    -- Debug info about what went wrong
    if debugInfo then
        debugInfo.source = "LibCI"
        debugInfo.triedUnits = #possibleUnits
        debugInfo.noDirectAccess = true
    end

    -- Fallback: Use LibClassicInspector (no enchant data, but has basic item info)
    local itemMixin = CI:GetInventoryItemMixin(guid, slotID)
    if not itemMixin then return nil end

    if itemMixin:IsItemDataCached() then
        return itemMixin:GetItemLink()
    end

    -- Request load if not cached
    local itemID = itemMixin:GetItemID()
    if itemID then
        C_Item.RequestLoadItemDataByID(itemID)
    end

    return nil
end
