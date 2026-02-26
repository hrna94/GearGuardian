-- ============================================
-- GearGuardian - Meta Gem Requirement Check Module
-- ============================================

local GG = GearGuardian
if not GG then return end

-- ============================================
-- GEM COLOR DETECTION
-- ============================================

-- Gem color IDs from item socket info
local GEM_COLORS = {
    META = 1,
    RED = 2,
    YELLOW = 3,
    BLUE = 4,
    PRISMATIC = 14  -- Matches all colors
}

-- Meta gem requirements database (itemID -> requirement string)
-- Format: "2red 2blue" or "3blue 1red" etc.
GG.META_GEM_REQUIREMENTS = {
    -- T4/T5 meta gems
    [25893] = "2blue",  -- Mystical Skyfire Diamond
    [25894] = "2red",   -- Swift Skyfire Diamond
    [25895] = "2red 2blue",  -- Powerful Earthstorm Diamond
    [25896] = "2blue 1yellow",  -- Bracing Earthstorm Diamond
    [25897] = "2red 2yellow",  -- Insightful Earthstorm Diamond
    [25898] = "2red",  -- Brutal Earthstorm Diamond
    [25899] = "2yellow 1red",  -- Destructive Skyfire Diamond
    [25890] = "2blue 1yellow",  -- Tenacious Earthstorm Diamond
    [32409] = "2blue 2red 2yellow",  -- Relentless Earthstorm Diamond
    [25901] = "2blue 1yellow",  -- Eternal Earthstorm Diamond

    -- T6/Sunwell meta gems
    [32410] = "2blue",  -- Thundering Skyfire Diamond
    [35503] = "2blue 1red",  -- Ember Skyfire Diamond
    [32640] = "3blue",  -- Powerful Earthstorm Diamond (new version)
    [32641] = "2red",  -- Chaotic Skyfire Diamond
}

-- Parse meta gem requirements string
-- "2red 2blue" -> {red = 2, blue = 2}
local function ParseRequirements(reqString)
    if not reqString then return {} end

    local requirements = {}

    -- Match patterns like "2red", "3blue", "1yellow"
    for count, color in string.gmatch(reqString, "(%d+)(%a+)") do
        requirements[color] = tonumber(count)
    end

    return requirements
end

-- Helper function to determine gem color from gem ID
local function GetGemColor(gemID)
    if not gemID or gemID == 0 then return nil end

    local gemName = GetItemInfo(gemID)
    if not gemName then return nil end

    local lowerName = string.lower(gemName)

    -- Meta gems
    if string.find(lowerName, "diamond") then
        return "meta"
    end

    -- Primary colors (check for gem type names)
    if string.find(lowerName, "ruby") or string.find(lowerName, "living ruby") or
       string.find(lowerName, "crimson spinel") or string.find(lowerName, "blood garnet") then
        return "red"
    end

    if string.find(lowerName, "topaz") or string.find(lowerName, "dawnstone") or
       string.find(lowerName, "noble topaz") or string.find(lowerName, "golden draenite") then
        return "yellow"
    end

    if string.find(lowerName, "sapphire") or string.find(lowerName, "star of elune") or
       string.find(lowerName, "empyrean sapphire") or string.find(lowerName, "azure moonstone") then
        return "blue"
    end

    -- Hybrid colors
    if string.find(lowerName, "amber") or string.find(lowerName, "pyrestone") or
       string.find(lowerName, "noble topaz") or string.find(lowerName, "inscribed") then
        return "orange"  -- red + yellow
    end

    if string.find(lowerName, "amethyst") or string.find(lowerName, "nightseye") or
       string.find(lowerName, "royal") then
        return "purple"  -- red + blue
    end

    if string.find(lowerName, "jade") or string.find(lowerName, "tourmaline") or
       string.find(lowerName, "seaspray emerald") or string.find(lowerName, "talasite") then
        return "green"  -- yellow + blue
    end

    -- Prismatic
    if string.find(lowerName, "prismatic") then
        return "prismatic"
    end

    return nil
end

-- Count gems by color for a player
function GG.CountGems(guid)
    if not guid then return nil end

    local gemCounts = {
        red = 0,
        yellow = 0,
        blue = 0,
        meta = 0,
        prismatic = 0,
        orange = 0,  -- red + yellow
        purple = 0,  -- red + blue
        green = 0    -- yellow + blue
    }

    -- Slots that can have sockets
    local slots = {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}

    for _, slotID in ipairs(slots) do
        local itemLink = GG.GetItemLinkByGUID(guid, slotID)

        if itemLink then
            -- Parse gems from itemLink (reuse logic from gems.lua)
            local _, _, itemString = string.find(itemLink, "|Hitem:([^|]+)|h")

            if itemString then
                -- Split by colons
                local parts = {}
                local pos = 1
                for match in string.gmatch(itemString .. ":", "([^:]*):") do
                    table.insert(parts, match)
                end

                -- Gem IDs are at positions 3-6
                for i = 3, 6 do
                    local gemID = tonumber(parts[i])
                    if gemID and gemID > 0 then
                        local color = GetGemColor(gemID)
                        if color then
                            if color == "meta" then
                                gemCounts.meta = gemCounts.meta + 1
                            elseif color == "red" then
                                gemCounts.red = gemCounts.red + 1
                            elseif color == "yellow" then
                                gemCounts.yellow = gemCounts.yellow + 1
                            elseif color == "blue" then
                                gemCounts.blue = gemCounts.blue + 1
                            elseif color == "orange" then
                                gemCounts.orange = gemCounts.orange + 1
                                gemCounts.red = gemCounts.red + 1
                                gemCounts.yellow = gemCounts.yellow + 1
                            elseif color == "purple" then
                                gemCounts.purple = gemCounts.purple + 1
                                gemCounts.red = gemCounts.red + 1
                                gemCounts.blue = gemCounts.blue + 1
                            elseif color == "green" then
                                gemCounts.green = gemCounts.green + 1
                                gemCounts.yellow = gemCounts.yellow + 1
                                gemCounts.blue = gemCounts.blue + 1
                            elseif color == "prismatic" then
                                gemCounts.prismatic = gemCounts.prismatic + 1
                                gemCounts.red = gemCounts.red + 1
                                gemCounts.yellow = gemCounts.yellow + 1
                                gemCounts.blue = gemCounts.blue + 1
                            end
                        end
                    end
                end
            end
        end
    end

    return gemCounts
end

-- Get meta gem item ID from head slot
function GG.GetMetaGemID(guid)
    if not guid then return nil end

    -- Meta gems are only in head slot (slot 1)
    local itemLink = GG.GetItemLinkByGUID(guid, 1)

    if not itemLink then return nil end

    -- Parse item link to extract gem IDs
    -- Format: |Hitem:itemID:enchantID:gem1:gem2:gem3:...|h[name]|h
    local _, _, itemString = string.find(itemLink, "|H(.+)|h")
    if not itemString then return nil end

    local parts = {}
    for part in string.gmatch(itemString, "[^:]+") do
        table.insert(parts, part)
    end

    -- Gem slots start at index 3 (after item: and enchant)
    -- Meta gem is usually first socket
    for i = 3, #parts do
        if parts[i] and parts[i] ~= "" and parts[i] ~= "0" then
            local gemID = tonumber(parts[i])

            -- Check if this gem is a meta gem
            if gemID and GG.META_GEM_REQUIREMENTS[gemID] then
                return gemID
            end
        end
    end

    return nil
end

-- Check if meta gem requirements are met
function GG.CheckMetaGemRequirements(guid)
    if not guid then return nil, nil end

    local metaGemID = GG.GetMetaGemID(guid)
    if not metaGemID then
        return nil, "No meta gem found"
    end

    local requirements = GG.META_GEM_REQUIREMENTS[metaGemID]
    if not requirements then
        return true, "Unknown meta gem (no requirements)"
    end

    local reqTable = ParseRequirements(requirements)
    local gemCounts = GG.CountGems(guid)

    if not gemCounts then
        return nil, "Failed to count gems"
    end

    -- Check each requirement
    local missingGems = {}

    for color, required in pairs(reqTable) do
        local actual = gemCounts[color] or 0

        if actual < required then
            local missing = required - actual
            table.insert(missingGems, string.format("%d %s", missing, color))
        end
    end

    if #missingGems > 0 then
        local missingText = table.concat(missingGems, ", ")
        return false, "Missing: " .. missingText
    end

    return true, "Requirements met"
end

-- Add meta gem warning to item
function GG.ShowMetaGemWarning(slotFrame, slotID, guid)
    if not GG.GetConfig("metaGemCheck") then return end
    if slotID ~= 1 then return end  -- Only check head slot

    -- Remove existing warning
    if slotFrame.metaWarning then
        slotFrame.metaWarning:Hide()
        slotFrame.metaWarning = nil
    end

    local metaActive, message = GG.CheckMetaGemRequirements(guid)

    if metaActive == false then
        -- Create warning icon
        local warning = slotFrame:CreateTexture(nil, "OVERLAY")
        warning:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
        warning:SetSize(20, 20)
        warning:SetPoint("BOTTOMRIGHT", slotFrame, "BOTTOMRIGHT", 2, -2)
        slotFrame.metaWarning = warning

        -- Tooltip
        slotFrame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine("|cffFFFF00Meta Gem Inactive!|r")
            GameTooltip:AddLine("|cffFF0000" .. message .. "|r")
            GameTooltip:Show()
        end)

        slotFrame:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    end
end
