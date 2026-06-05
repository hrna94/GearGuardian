--[[
    GearGuardian - Temporary Enchant Detection Module
    Uses GetWeaponEnchantInfo() for sharpening stones, wizard oil, etc.
]]--

local GG = GearGuardian
if not GG then return end

-- ============================================
-- TEMPORARY ENCHANT DETECTION
-- ============================================

-- Cache for temp enchant checks
GG.tempEnchantCache = {}

-- Clear temp enchant cache (called on equipment change)
function GG.ClearTempEnchantCache()
    GG.tempEnchantCache = {}
end

-- Get temporary enchant info for a weapon slot
-- Returns: { hasEnchant, name, charges, expiration } or nil
function GG.GetTempEnchantInfo(slotID)
    -- Only check weapon slots
    if slotID ~= 16 and slotID ~= 17 and slotID ~= 18 then
        return nil
    end

    -- Check cache
    local cacheKey = "player:" .. slotID
    local cached = GG.tempEnchantCache[cacheKey]
    if cached and (GetTime() - cached.timestamp) < 10 then
        return cached.info
    end

    -- GetWeaponEnchantInfo returns:
    -- hasMainHand, mainHandExpiration, mainHandCharges, mainHandEnchantID,
    -- hasOffHand, offHandExpiration, offHandCharges, offHandEnchantID
    local hasMH, mhExp, mhCharges, mhID, hasOH, ohExp, ohCharges, ohID = GetWeaponEnchantInfo()

    local info = nil

    if slotID == 16 then
        -- Main hand
        if hasMH and mhID and mhID > 0 then
            local enchantName = GetSpellInfo(mhID)
            if not enchantName then
                -- Fallback: try to get from spell link
                local spellLink = GetSpellLink(mhID)
                if spellLink then
                    enchantName = GetItemInfo(spellLink) or "Unknown Enchant"
                end
            end
            info = {
                hasEnchant = true,
                name = enchantName or "Temporary Enchant",
                charges = mhCharges or 0,
                expiration = mhExp or 0,
                enchantID = mhID
            }
        else
            info = { hasEnchant = false }
        end
    elseif slotID == 17 then
        -- Off hand / shield
        if hasOH and ohID and ohID > 0 then
            local enchantName = GetSpellInfo(ohID)
            if not enchantName then
                local spellLink = GetSpellLink(ohID)
                if spellLink then
                    enchantName = GetItemInfo(spellLink) or "Unknown Enchant"
                end
            end
            info = {
                hasEnchant = true,
                name = enchantName or "Temporary Enchant",
                charges = ohCharges or 0,
                expiration = ohExp or 0,
                enchantID = ohID
            }
        else
            info = { hasEnchant = false }
        end
    elseif slotID == 18 then
        -- Ranged - not supported by GetWeaponEnchantInfo in TBC
        info = { hasEnchant = false, note = "Ranged temp enchants not available" }
    end

    GG.tempEnchantCache[cacheKey] = { info = info, timestamp = GetTime() }
    return info
end

-- Check if weapon should have a temp enchant warning
-- Used in borders.lua to show warning icon
function GG.ShouldWarnTempEnchant(slotID)
    if not GG.GetConfig("tempEnchant") then return false end

    -- Only warn on weapon slots
    if slotID ~= 16 and slotID ~= 17 then return false end

    -- Only warn for player (not inspect targets - GetWeaponEnchantInfo only works on player)
    local itemLink = GetInventoryItemLink("player", slotID)
    if not itemLink then return false end

    local info = GG.GetTempEnchantInfo(slotID)
    if info and info.hasEnchant then return false end

    -- Item exists, slot should have temp enchant, but doesn't
    return true
end

-- Get display text for temp enchant in tooltip
function GG.GetTempEnchantTooltip(slotID)
    local info = GG.GetTempEnchantInfo(slotID)
    if not info then return nil end

    if info.hasEnchant then
        local timeText = ""
        if info.expiration and info.expiration > 0 then
            local minutes = math.floor(info.expiration / 60000)
            local seconds = math.floor((info.expiration % 60000) / 1000)
            timeText = string.format(" (%d:%02d)", minutes, seconds)
        end

        local chargeText = ""
        if info.charges and info.charges > 0 then
            chargeText = string.format(" [%d charges]", info.charges)
        end

        return string.format("|cff00ff00Temp: %s|r%s%s", info.name, timeText, chargeText)
    else
        return "|cffff8800No temp enchant|r"
    end
end
