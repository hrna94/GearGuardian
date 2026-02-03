-- ============================================
-- GearGuardian - Enchant and Gem Checking Module
-- ============================================

local GG = GearGuardian
if not GG then return end

-- ============================================
-- ENCHANT AND GEM CHECKING
-- ============================================

-- Create reusable tooltip for scanning (must be created early)
local scanTooltip = CreateFrame("GameTooltip", "ItemComparisonScanTooltip", nil, "GameTooltipTemplate")
scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")

-- ============================================
-- CACHE SYSTEM FOR PERFORMANCE
-- ============================================

-- Cache for enchant/gem checks (reduces tooltip scanning by ~80%)
GG.enchantGemCache = {}

-- Clear enchant/gem cache (called on equipment change)
function GG.ClearEnchantGemCache()
    GG.enchantGemCache = {}
end

-- Parse enchant ID from itemLink (TBC format)
-- Format: |Hitem:itemID:enchantID:suffixID:uniqueID:gem1:gem2:gem3:gem4:level|h[ItemName]|h
local function GetEnchantIDFromLink(itemLink)
    if not itemLink then return 0 end

    -- Extract the item string from the link
    local _, _, itemString = string.find(itemLink, "|H(.+)|h")
    if not itemString then return 0 end

    -- Split by colons INCLUDING empty strings
    local parts = {}
    local currentPos = 1
    local colonPos = string.find(itemString, ":", currentPos)

    while colonPos do
        -- Add part before colon (can be empty string)
        table.insert(parts, string.sub(itemString, currentPos, colonPos - 1))
        currentPos = colonPos + 1
        colonPos = string.find(itemString, ":", currentPos)
    end
    -- Add last part
    table.insert(parts, string.sub(itemString, currentPos))

    -- parts[1] = "item"
    -- parts[2] = itemID
    -- parts[3] = enchantID (can be empty string if no enchant)
    if parts[3] and parts[3] ~= "" then
        local enchantID = tonumber(parts[3])
        return enchantID or 0
    end

    return 0
end

-- Parse gem IDs from itemLink (TBC format)
local function GetGemIDsFromLink(itemLink)
    if not itemLink then return {} end

    local _, _, itemString = string.find(itemLink, "|H(.+)|h")
    if not itemString then return {} end

    -- Split by colons INCLUDING empty strings
    local parts = {}
    local currentPos = 1
    local colonPos = string.find(itemString, ":", currentPos)

    while colonPos do
        table.insert(parts, string.sub(itemString, currentPos, colonPos - 1))
        currentPos = colonPos + 1
        colonPos = string.find(itemString, ":", currentPos)
    end
    table.insert(parts, string.sub(itemString, currentPos))

    -- parts[6] to parts[9] are gem slots (empty string if no gem)
    local gems = {}
    for i = 6, 9 do
        if parts[i] and parts[i] ~= "" then
            local gemID = tonumber(parts[i])
            table.insert(gems, gemID or 0)
        end
    end

    return gems
end

-- Count empty sockets by checking if item has socket bonus but gems are 0
local function CountEmptySocketsFromLink(itemLink)
    if not itemLink then return 0 end

    -- Get item info to check if it has sockets
    local itemID = GG.GetItemInfoFromHyperlink(itemLink)
    if not itemID then return 0 end

    -- Parse gem IDs
    local gems = GetGemIDsFromLink(itemLink)

    -- Count empty slots (0 means empty)
    local emptyCount = 0
    for _, gemID in ipairs(gems) do
        if gemID == 0 then
            emptyCount = emptyCount + 1
        end
    end

    return emptyCount
end

-- Check if item has enchant (supports inspected players via itemLink parsing)
function GG.HasEnchant(slotID, debugMode, guid)
    if not scanTooltip then return true end -- If can't check, assume it has enchant

    -- Check cache first (skip cache in debug mode)
    if not debugMode then
        local cacheKey = (guid or "player") .. ":" .. slotID
        local cached = GG.enchantGemCache[cacheKey]
        if cached and cached.hasEnchant ~= nil and (GetTime() - cached.timestamp) < (GG.CACHE_DURATION or 30) then
            return cached.hasEnchant
        end
    end

    -- For inspected players, parse enchant ID from itemLink
    if guid and guid ~= UnitGUID("player") then
        local itemLink = GG.GetItemLinkByGUID(guid, slotID)
        if not itemLink then return true end -- No item link, assume has enchant

        local enchantID = GetEnchantIDFromLink(itemLink)
        local hasEnchant = enchantID > 0

        if debugMode then
            print("HasEnchant debug for slot " .. slotID .. " (inspected player):")
            print("  ItemLink: " .. itemLink)
            print("  EnchantID: " .. (enchantID or 0))
            print("  Result: " .. (hasEnchant and "HAS ENCHANT" or "NO ENCHANT"))
        end

        -- Store in cache
        if not debugMode then
            local cacheKey = guid .. ":" .. slotID
            GG.enchantGemCache[cacheKey] = {
                hasEnchant = hasEnchant,
                timestamp = GetTime()
            }
        end

        return hasEnchant
    end

    -- For player, use tooltip scanning (more reliable for detecting enchant names)
    scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    scanTooltip:ClearLines()
    scanTooltip:SetInventoryItem("player", slotID)

    local foundEnchant = false
    local debugInfo = {}

    -- Look for enchant text (must be specific patterns, not just any green text)
    for i = 1, scanTooltip:NumLines() do
        local line = _G["ItemComparisonScanTooltipTextLeft" .. i]
        if line then
            local text = line:GetText()
            if text then
                if debugMode then
                    local r, g, b = line:GetTextColor()
                    table.insert(debugInfo, string.format("  Line %d: %s (R:%.2f G:%.2f B:%.2f)", i, text, r or 0, g or 0, b or 0))
                end

                -- Check for enchant-specific patterns only
                -- Pattern 1: "Enchanted: <enchant name>"
                if text:match("^Enchanted: ") then
                    foundEnchant = true
                    if debugMode then
                        table.insert(debugInfo, "    -> Matched pattern: Enchanted:")
                    end
                end

                -- Pattern 2: Specific weapon enchants
                if text:find("Mongoose") or text:find("Executioner") or text:find("Spellsurge") or
                   text:find("Soulfrost") or text:find("Sunfire") or text:find("Battlemaster") or
                   text:find("Spellpower") or text:find("Healing Power") or text:find("Major Striking") or
                   text:find("Potency") or text:find("Savagery") or text:find("Major Intellect") then
                    -- Only count as enchant if it's NOT part of item name or equip effect
                    if not text:find("Equip:") and not text:find("Increases") and i > 3 then
                        foundEnchant = true
                        if debugMode then
                            table.insert(debugInfo, "    -> Matched weapon enchant keyword")
                        end
                    end
                end

                -- Pattern 3: Armor enchants
                if text:find("Stats %+") or text:find("Boar's Speed") or text:find("Vitality") or
                   text:find("Cat's Swiftness") or text:find("Surefooted") or text:find("Strength %+") or
                   text:find("Agility %+") or text:find("Brawn") or text:find("Assault") or
                   text:find("Stealth") or text:find("Subtlety") then
                    if not text:find("Equip:") and not text:find("Increases") and i > 3 then
                        foundEnchant = true
                        if debugMode then
                            table.insert(debugInfo, "    -> Matched armor enchant keyword")
                        end
                    end
                end

                -- Pattern 4: Scope for ranged weapons
                if text:find("Scope") and slotID == 18 then
                    foundEnchant = true
                    if debugMode then
                        table.insert(debugInfo, "    -> Matched scope")
                    end
                end

                -- Pattern 5: Head enchants (Arcanum)
                if (text:find("Arcanum") or text:find("Glyph of")) and slotID == 1 then
                    if not text:find("Equip:") and i > 3 then
                        foundEnchant = true
                        if debugMode then
                            table.insert(debugInfo, "    -> Matched head enchant (Arcanum)")
                        end
                    end
                end

                -- Pattern 6: Shoulder enchants (Inscription)
                if (text:find("Inscription of") or text:find("Greater Inscription")) and slotID == 3 then
                    if not text:find("Equip:") and i > 3 then
                        foundEnchant = true
                        if debugMode then
                            table.insert(debugInfo, "    -> Matched shoulder enchant (Inscription)")
                        end
                    end
                end

                -- Pattern 7: Leg armor patches
                if (text:find("Nethercobra") or text:find("Clefthide") or text:find("Nethercleft") or
                    text:find("Cobrahide") or text:find("Runic Spellthread") or text:find("Silver Spellthread") or
                    text:find("Golden Spellthread") or text:find("Mystic Spellthread")) and slotID == 7 then
                    if not text:find("Equip:") and i > 3 then
                        foundEnchant = true
                        if debugMode then
                            table.insert(debugInfo, "    -> Matched leg armor patch")
                        end
                    end
                end
            end
        end
    end

    if debugMode and #debugInfo > 0 then
        print("HasEnchant debug for slot " .. slotID .. ":")
        for _, line in ipairs(debugInfo) do
            print(line)
        end
        print("  Result: " .. (foundEnchant and "HAS ENCHANT" or "NO ENCHANT"))
    end

    -- Store in cache
    if not debugMode then
        local cacheKey = (guid or "player") .. ":" .. slotID
        GG.enchantGemCache[cacheKey] = {
            hasEnchant = foundEnchant,
            timestamp = GetTime()
        }
    end

    return foundEnchant
end

-- Check if item has empty gem sockets (supports inspected players via tooltip)
function GG.GetEmptySocketCount(slotID, guid)
    if not scanTooltip then return 0 end

    -- Check cache first
    local cacheKey = (guid or "player") .. ":" .. slotID .. ":sockets"
    local cached = GG.enchantGemCache[cacheKey]
    if cached and cached.emptyCount ~= nil and (GetTime() - cached.timestamp) < (GG.CACHE_DURATION or 30) then
        return cached.emptyCount
    end

    scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    scanTooltip:ClearLines()

    -- For inspected players, use hyperlink; for player use inventory
    if guid and guid ~= UnitGUID("player") then
        local itemLink = GG.GetItemLinkByGUID(guid, slotID)
        if not itemLink then return 0 end
        scanTooltip:SetHyperlink(itemLink)
    else
        scanTooltip:SetInventoryItem("player", slotID)
    end

    local emptyCount = 0
    local hasSocketBonus = false

    for i = 1, scanTooltip:NumLines() do
        local line = _G["ItemComparisonScanTooltipTextLeft" .. i]
        if line then
            local text = line:GetText()
            if text then
                -- First check if item has socket bonus (means it has sockets)
                if text:find("Socket Bonus:") then
                    hasSocketBonus = true
                end

                -- Check for socket types (Red/Yellow/Blue/Meta Socket)
                if text:find("Socket") and (text:find("Red") or text:find("Yellow") or
                   text:find("Blue") or text:find("Meta")) then

                    -- Socket is filled if next line contains a gem name
                    local nextLine = _G["ItemComparisonScanTooltipTextLeft" .. (i + 1)]
                    if nextLine then
                        local nextText = nextLine:GetText()
                        local r, g, b = nextLine:GetTextColor()

                        -- Gems are usually shown with colored text
                        -- If next line is empty or is another socket, then this socket is empty
                        if not nextText or nextText == "" or
                           nextText:find("Socket") or nextText:find("Socket Bonus") then
                            emptyCount = emptyCount + 1
                        end
                    else
                        -- No next line means empty socket
                        emptyCount = emptyCount + 1
                    end
                end
            end
        end
    end

    -- Store in cache
    local cacheKey = (guid or "player") .. ":" .. slotID .. ":sockets"
    GG.enchantGemCache[cacheKey] = {
        emptyCount = emptyCount,
        timestamp = GetTime()
    }

    return emptyCount
end

-- Slots that should typically have enchants in TBC
local enchantableSlots = {
    1,  -- Head - Arcanum (Cenarion Expedition, Sha'tar, etc.)
    3,  -- Shoulder - Inscription (Aldor/Scryer reputation)
    5,  -- Chest - Exceptional Stats, Exceptional Health, etc.
    7,  -- Legs - Leg armor (Nethercobra, Clefthide, etc.)
    15, -- Back/Cloak - Subtlety, Greater Agility, etc.
    16, -- Main Hand - Mongoose, Executioner, Spellsurge, etc.
    17, -- Off Hand (shields and weapons) - various
    8,  -- Feet - Boar's Speed, Vitality, etc.
    9,  -- Wrist - Brawn, Spellpower, etc.
    10  -- Hands - Glove enchants
}

-- Check if slot should be enchanted
function GG.ShouldHaveEnchant(slotID)
    -- Check common enchantable slots
    if slotID == 16 then -- Main hand - always check
        return true
    end

    if slotID == 17 then -- Off hand - check if it's weapon or shield
        local itemLink = GetInventoryItemLink("player", slotID)
        if itemLink then
            local _, _, _, _, _, _, _, _, equipSlot = GetItemInfo(itemLink)
            if equipSlot == "INVTYPE_SHIELD" or equipSlot == "INVTYPE_WEAPON" or
               equipSlot == "INVTYPE_WEAPONOFFHAND" then
                return true
            end
        end
    end

    if slotID == 1 then -- Head - Arcanum enchants
        return true
    end

    if slotID == 3 then -- Shoulder - Inscription enchants
        return true
    end

    if slotID == 5 then -- Chest - common enchant
        return true
    end

    if slotID == 7 then -- Legs - Leg armor patches
        return true
    end

    if slotID == 15 then -- Cloak - common enchant
        return true
    end

    if slotID == 8 or slotID == 9 or slotID == 10 then -- Feet, Wrist, Hands
        return true
    end

    return false
end

-- Export helper function for debug commands
GG.GetEnchantIDFromLink = GetEnchantIDFromLink
