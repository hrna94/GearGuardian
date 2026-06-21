-- ============================================
-- GearGuardian - Gem Socket Check Module
-- ============================================

local GG = GearGuardian
if not GG then return end

-- ============================================
-- GEM SOCKET DETECTION
-- ============================================

local scanTooltip = GG.sharedScanTooltip or CreateFrame("GameTooltip", "GGSharedScanTooltip", nil, "GameTooltipTemplate")

-- Cache for gem socket checks (performance optimization)
GG.gemSocketCache = GG.gemSocketCache or {}

local ParseGemsFromLink = GG.GetGemsFromLink

-- Count total sockets from tooltip
local function CountSocketsFromTooltip(itemLink)
    if not itemLink then return 0 end

    scanTooltip:ClearLines()
    scanTooltip:SetHyperlink(itemLink)

    local socketCount = 0

    for i = 1, scanTooltip:NumLines() do
        local line = _G["GGSharedScanTooltipTextLeft" .. i]
        if line then
            local text = line:GetText()
            if text then
                -- Look for socket lines: "Red Socket", "Blue Socket", etc.
                local lowerText = string.lower(text)
                if string.find(lowerText, "socket") then
                    if string.find(lowerText, "red") or
                       string.find(lowerText, "yellow") or
                       string.find(lowerText, "blue") or
                       string.find(lowerText, "meta") or
                       string.find(lowerText, "prismatic") then
                        socketCount = socketCount + 1
                    end
                end
            end
        end
    end

    return socketCount
end

-- Get empty socket count for a slot
function GG.GetEmptySocketCount(slotID, guid)
    guid = guid or UnitGUID("player")
    if not guid then return 0 end

    -- Check cache first
    local cacheKey = guid .. ":" .. slotID
    local cached = GG.gemSocketCache[cacheKey]
    if cached and (GetTime() - cached.timestamp) < 30 then
        return cached.emptyCount
    end

    -- Get item link
    local itemLink
    if guid == UnitGUID("player") then
        itemLink = GetInventoryItemLink("player", slotID)
    else
        itemLink = GG.GetItemLinkByGUID(guid, slotID)
    end

    if not itemLink then
        GG.gemSocketCache[cacheKey] = { emptyCount = 0, timestamp = GetTime() }
        return 0
    end

    -- For inspected players, check if data is ready
    if guid ~= UnitGUID("player") then
        local _, invTime = GG.CI:GetLastCacheTime(guid)
        if invTime == 0 or (GetTime() - invTime) < 2.0 then
            -- Data not ready yet, don't show false warnings
            return 0
        end
    end

    -- Parse gems from itemLink
    local gems = ParseGemsFromLink(itemLink)
    local filledCount = #gems

    -- Count total sockets from tooltip
    local totalCount = CountSocketsFromTooltip(itemLink)

    -- Calculate empty sockets
    local emptyCount = totalCount - filledCount
    if emptyCount < 0 then emptyCount = 0 end

    -- Debug: If item has sockets but no gems in link, and it's an inspected player,
    -- the data might be incomplete
    if guid ~= UnitGUID("player") and totalCount > 0 and filledCount == 0 then
        -- Double-check cache age
        local _, invTime = GG.CI:GetLastCacheTime(guid)
        if invTime > 0 and (GetTime() - invTime) < 3.0 then
            -- Still too fresh, return 0 to avoid false positive
            return 0
        end
    end

    -- Cache result
    GG.gemSocketCache[cacheKey] = {
        emptyCount = emptyCount,
        timestamp = GetTime()
    }

    return emptyCount
end

-- Clear gem socket cache
function GG.ClearGemCache()
    GG.gemSocketCache = {}
end

-- Debug: Print gem info for a slot
function GG.DebugGemInfo(slotID, guid)
    guid = guid or UnitGUID("player")
    local itemLink = guid == UnitGUID("player") and GetInventoryItemLink("player", slotID) or GG.GetItemLinkByGUID(guid, slotID)

    if not itemLink then
        print("No item in slot " .. slotID)
        return
    end

    local itemName = GetItemInfo(itemLink)
    print("|cff00ff00=== Gem Debug: " .. (itemName or "Unknown") .. " ===|r")

    -- Parse itemLink
    local gems = ParseGemsFromLink(itemLink)
    print("Gems found in itemLink: " .. #gems)
    for i, gemID in ipairs(gems) do
        local gemName = GetItemInfo(gemID)
        print("  Gem " .. i .. ": " .. gemID .. " (" .. (gemName or "Unknown") .. ")")
    end

    -- Count sockets from tooltip
    local totalSockets = CountSocketsFromTooltip(itemLink)
    print("Total sockets from tooltip: " .. totalSockets)

    -- Calculate empty
    local empty = totalSockets - #gems
    print("Empty sockets: " .. math.max(0, empty))

    -- Show raw itemLink (escaped so it shows the full string)
    local escapedLink = string.gsub(itemLink, "|", "||")
    print("Raw itemLink: " .. escapedLink)

    local parts = GG.ParseItemString(itemLink)
    if parts then
        print("ItemLink parts (first 15):")
        for i = 1, math.min(15, #parts) do
            local part = parts[i]
            if part == "" then
                print("  [" .. i .. "] = (empty)")
            else
                print("  [" .. i .. "] = '" .. part .. "'")
            end
        end
        print("Gem slots should be at indices 3-6")
    end
end
