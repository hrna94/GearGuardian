-- ============================================
-- GearGuardian - Meta Gem Requirement Check Module
-- ============================================

local GG = GearGuardian
if not GG then return end

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

    local slots = {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}

    for _, slotID in ipairs(slots) do
        local itemLink = GG.GetItemLinkByGUID(guid, slotID)

        if itemLink then
            local gems = GG.GetGemsFromLink(itemLink)
            for _, gemID in ipairs(gems) do
                local color = GG.GetGemColor(gemID)
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

    return gemCounts
end

function GG.GetMetaGemID(guid)
    if not guid then return nil end

    local itemLink = GG.GetItemLinkByGUID(guid, 1)
    if not itemLink then return nil end

    local gems = GG.GetGemsFromLink(itemLink)
    for _, gemID in ipairs(gems) do
        if GG.META_GEM_REQUIREMENTS[gemID] then
            return gemID
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

function GG.ShowMetaGemWarning(slotFrame, slotID, guid)
    if not GG.GetConfig("metaGemCheck") then return end
    if slotID ~= 1 then return end

    if slotFrame.metaWarning then
        slotFrame.metaWarning:Hide()
        slotFrame.metaWarning = nil
    end

    local metaActive, message = GG.CheckMetaGemRequirements(guid)

    if metaActive == false then
        local warning = slotFrame:CreateTexture(nil, "OVERLAY")
        warning:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
        warning:SetSize(20, 20)
        warning:SetPoint("BOTTOMRIGHT", slotFrame, "BOTTOMRIGHT", 2, -2)
        slotFrame.metaWarning = warning

        if not slotFrame._metaHooked then
            local originalOnEnter = slotFrame:GetScript("OnEnter")
            local originalOnLeave = slotFrame:GetScript("OnLeave")

            slotFrame:SetScript("OnEnter", function(self, ...)
                if originalOnEnter then originalOnEnter(self, ...) end
                if self._metaMessage then
                    GameTooltip:AddLine("|cffFFFF00Meta Gem Inactive!|r")
                    GameTooltip:AddLine("|cffFF0000" .. self._metaMessage .. "|r")
                    GameTooltip:Show()
                end
            end)

            slotFrame:SetScript("OnLeave", function(self, ...)
                if originalOnLeave then originalOnLeave(self, ...) end
                GameTooltip:Hide()
            end)

            slotFrame._metaHooked = true
        end

        slotFrame._metaMessage = message
    else
        slotFrame._metaMessage = nil
    end
end
