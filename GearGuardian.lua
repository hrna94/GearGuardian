--[[
    GearGuardian
    Author: Sluck
    Version: 2.4

    Copyright (c) 2025 Sluck. All Rights Reserved.

    This addon and all its contents are protected by copyright law.
    You may use this addon for personal use only.
    Redistribution, modification, or commercial use is prohibited without explicit permission.
--]]

local addonName = "GearGuardian"
local GG = GearGuardian
if not GG then
    error("GearGuardian namespace not found. Make sure core modules are loaded first.")
    return
end

-- ============================================
-- SLASH COMMANDS
-- ============================================

SLASH_GEARGUARDIAN1 = "/gg"
SLASH_GEARGUARDIAN2 = "/gearguardian"

SlashCmdList["GEARGUARDIAN"] = function(msg)
    msg = string.lower(msg or "")

    if msg == "" or msg == "config" or msg == "options" then
        -- Toggle config panel
        if GG.configFrame:IsShown() then
            GG.configFrame:Hide()
        else
            GG.configFrame:Show()
        end
    elseif msg == "toggle" then
        if not GearGuardianDB or not GearGuardianDB.config then
            print("|cffff0000GearGuardian:|r Config not loaded yet")
            return
        end
        GearGuardianDB.config.enabled = not GearGuardianDB.config.enabled
        print("|cff00ff00GearGuardian:|r " .. (GearGuardianDB.config.enabled and "Enabled" or "Disabled"))
        GG.UpdateAllSlots()
    elseif msg == "debug" or msg == "test" then
        -- Debug enchant/gem check
        print("|cff00ff00GearGuardian Debug:|r Checking equipped items...")
        print("Enchant Check: " .. (GG.GetConfig("enchantCheck") and "ON" or "OFF"))
        print("Gem Check: " .. (GG.GetConfig("gemCheck") and "ON" or "OFF"))

        local slotNames = {
            [1] = "Head", [2] = "Neck", [3] = "Shoulder", [5] = "Chest",
            [6] = "Waist", [7] = "Legs", [8] = "Feet", [9] = "Wrist",
            [10] = "Hands", [15] = "Back", [16] = "Main Hand", [17] = "Off Hand"
        }

        for slotID, slotName in pairs(slotNames) do
            local itemLink = GetInventoryItemLink("player", slotID)
            if itemLink then
                local itemName = GetItemInfo(itemLink)
                local shouldCheck = GG.ShouldHaveEnchant(slotID)

                -- Get enchantID from link for comparison
                local enchantIDFromLink = GG.GetEnchantIDFromLink(itemLink)

                -- Test with debug mode
                local hasEnchantTooltip = GG.HasEnchant(slotID, true, nil) -- Debug ON for player
                local emptySockets = GG.GetEmptySocketCount(slotID)

                print(string.format("%s: %s | EnchID:%d | Tooltip:%s | Check:%s | Empty:%d",
                    slotName, itemName or "Unknown",
                    enchantIDFromLink,
                    hasEnchantTooltip and "Y" or "N",
                    shouldCheck and "Y" or "N",
                    emptySockets))
            end
        end
    elseif msg == "debuginspect" or msg == "di" then
        -- Debug for inspected target
        if not GG.inspectedUnit then
            print("|cffff0000No inspected target!|r Use /inspect on someone first.")
            return
        end

        local inspectedGUID = UnitGUID(GG.inspectedUnit)
        if not inspectedGUID then
            print("|cffff0000No GUID for inspected target!|r")
            return
        end

        local CI = LibStub("LibClassicInspector")
        local _, invTime = CI:GetLastCacheTime(inspectedGUID)
        print("|cff00ff00GearGuardian Inspect Debug:|r " .. (UnitName(GG.inspectedUnit) or "Unknown"))
        print("GUID: " .. inspectedGUID)
        print("Cache time: " .. (invTime or 0))

        if invTime == 0 then
            print("|cffff0000No cached data! Wait a moment and try again.|r")
            return
        end

        local slotNames = {
            [1] = "Head", [2] = "Neck", [3] = "Shoulder", [5] = "Chest",
            [6] = "Waist", [7] = "Legs", [8] = "Feet", [9] = "Wrist",
            [10] = "Hands", [15] = "Back", [16] = "Main Hand", [17] = "Off Hand"
        }

        for slotID, slotName in pairs(slotNames) do
            local debugInfo = {}
            local itemLink = GG.GetItemLinkByGUID(inspectedGUID, slotID, debugInfo)
            if itemLink then
                local itemName = GetItemInfo(itemLink)
                local shouldCheck = GG.ShouldHaveEnchant(slotID)

                -- Show RAW itemLink for first 2 items to debug format
                if slotID == 16 or slotID == 7 then -- Main Hand or Legs
                    print("|cffFFFF00" .. slotName .. " RAW:|r")
                    print("  Source: " .. (debugInfo.source or "unknown"))
                    if debugInfo.unit then
                        print("  Unit: " .. debugInfo.unit)
                    end
                    if debugInfo.noUnit then
                        print("  ERROR: inspectedUnit is nil!")
                    end
                    if debugInfo.guidMismatch then
                        print("  ERROR: GUID mismatch!")
                        print("    Inspected: " .. (debugInfo.inspectedGUID or "nil"))
                        print("    Requested: " .. (debugInfo.requestedGUID or "nil"))
                    end
                    if debugInfo.directFailed then
                        print("  WARNING: GetInventoryItemLink returned nil")
                    end
                    print("  Link: " .. itemLink)

                    -- Extract item string
                    local _, _, itemString = string.find(itemLink, "|H(.+)|h")
                    if itemString then
                        print("  String: " .. itemString)

                        -- Show first 10 parts
                        local parts = {}
                        local currentPos = 1
                        local colonPos = string.find(itemString, ":", currentPos)
                        local partNum = 1

                        while colonPos and partNum <= 10 do
                            local part = string.sub(itemString, currentPos, colonPos - 1)
                            print(string.format("  [%d]='%s'", partNum, part))
                            partNum = partNum + 1
                            currentPos = colonPos + 1
                            colonPos = string.find(itemString, ":", currentPos)
                        end
                    end
                end

                -- Parse itemLink to show enchant info
                local enchantID = GG.GetEnchantIDFromLink(itemLink)
                local hasEnchant = GG.HasEnchant(slotID, false, inspectedGUID)
                local emptySockets = GG.GetEmptySocketCount(slotID, inspectedGUID)

                local color = "ffffff"
                if shouldCheck and not hasEnchant then
                    color = "ff0000" -- Red if should check but no enchant
                elseif hasEnchant then
                    color = "00ff00" -- Green if has enchant
                end

                print(string.format("|cff%s%s:|r %s | Ench:%d | Has:%s | Empty:%d | Show:%s",
                    color,
                    slotName,
                    itemName or "Unknown",
                    enchantID,
                    hasEnchant and "Y" or "N",
                    emptySockets,
                    (shouldCheck and not hasEnchant) and "WARNING" or "OK"))
            end
        end
    else
        print("|cff00ff00GearGuardian Commands:|r")
        print("/gg or /gg config - Open configuration panel")
        print("/gg toggle - Toggle addon on/off")
        print("/gg debug - Debug enchant/gem checking (yourself)")
        print("/gg debuginspect - Debug inspect target enchants")
    end
end

-- ============================================
-- INITIALIZATION
-- ============================================

-- Initialize on addon loaded
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
initFrame:RegisterEvent("PLAYER_TALENT_UPDATE")

local initialized = false

initFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        GG.InitializeConfig()
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        -- Clear caches when equipment changes (OPTIMIZATION)
        if GG.ClearStatsCache then
            GG.ClearStatsCache()
        end
        if GG.ClearEnchantGemCache then
            GG.ClearEnchantGemCache()
        end
    elseif event == "PLAYER_TALENT_UPDATE" then
        -- Clear spec cache when talents change (OPTIMIZATION)
        if GG.ClearSpecCache then
            GG.ClearSpecCache()
        end
    elseif event == "PLAYER_ENTERING_WORLD" and not initialized then
        initialized = true

        -- Initialize character frame hooks
        if CharacterFrame then
            CharacterFrame:HookScript("OnShow", function()
                GG.UpdateAllSlots()
                GG.UpdateAverageILevelDisplay()
            end)
        end

        -- Initialize inspect frame (delayed to ensure frames are loaded)
        C_Timer.After(1, function()
            GG.SetupInspectFrame()
        end)

        print("|cff00ff00GearGuardian v2.4|r loaded! Type |cffFFFF00/gg|r for options.")
    end
end)
