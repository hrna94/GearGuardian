--[[
    GearGuardian - Core Initialization
    Author: Sluck
    Version: 2.9
]]--

-- Create addon namespace
local addonName = "GearGuardian"
GearGuardian = GearGuardian or {}
local GG = GearGuardian

-- ============================================
-- LIBRARY INITIALIZATION
-- ============================================

assert(LibStub, "GearGuardian requires LibStub")
assert(LibStub:GetLibrary("LibClassicInspector", true), "GearGuardian requires LibClassicInspector")

GG.CI = LibStub("LibClassicInspector")

-- ============================================
-- SHARED VARIABLES
-- ============================================

GG.addonName = addonName
GG.version = "2.9"
GG.inspectedUnit = nil  -- Track current inspected unit

-- Spec check interval (in seconds) - 5 minutes, spec rarely changes
GG.SPEC_CHECK_INTERVAL = 300
GG.lastSpecCheck = 0
GG.cachedClass = nil
GG.cachedSpec = nil

-- ============================================
-- SHARED SCAN TOOLTIP (used by all modules)
-- ============================================

GG.sharedScanTooltip = CreateFrame("GameTooltip", "GGSharedScanTooltip", nil, "GameTooltipTemplate")
GG.sharedScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")

-- ============================================
-- SHARED ITEM LINK PARSER
-- Splits itemString preserving empty fields.
-- Returns parts where: [1]=itemID, [2]=enchantID, [3-6]=gems, [7+]=other
-- ============================================

function GG.ParseItemString(itemLink)
    if not itemLink then return nil end
    local _, _, itemString = string.find(itemLink, "|Hitem:([^|]+)|h")
    if not itemString then return nil end

    local parts = {}
    for match in string.gmatch(itemString .. ":", "([^:]*):") do
        table.insert(parts, match)
    end
    return parts
end

-- Extract gem IDs from an itemLink (indices 3-6 in parts array)
function GG.GetGemsFromLink(itemLink)
    local parts = GG.ParseItemString(itemLink)
    if not parts then return {} end

    local gems = {}
    for i = 3, 6 do
        if parts[i] and parts[i] ~= "" and parts[i] ~= "0" then
            local gemID = tonumber(parts[i])
            if gemID and gemID > 0 then
                table.insert(gems, gemID)
            end
        end
    end
    return gems
end
