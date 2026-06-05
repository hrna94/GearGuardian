--[[
    GearGuardian - Socket Bonus Indicator Module
    Checks if socket bonuses are active and displays warnings
]]--

local GG = GearGuardian
if not GG then return end

-- ============================================
-- SOCKET BONUS DETECTION
-- ============================================

local scanTooltip = CreateFrame("GameTooltip", "GGSocketBonusTooltip", nil, "GameTooltipTemplate")
scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")

-- Cache for socket bonus checks
GG.socketBonusCache = GG.socketBonusCache or {}

-- Parse socket bonus from item tooltip
-- Returns: { bonusText, isActive, requiredColors } or nil
function GG.GetSocketBonusInfo(itemLink)
    if not itemLink then return nil end

    -- Check cache
    local cached = GG.socketBonusCache[itemLink]
    if cached and (GetTime() - cached.timestamp) < 30 then
        return cached.info
    end

    scanTooltip:ClearLines()
    scanTooltip:SetHyperlink(itemLink)

    local bonusText = nil
    local requiredColors = {}

    -- Scan tooltip for socket bonus line
    for i = 1, scanTooltip:NumLines() do
        local line = _G["GGSocketBonusTooltipTextLeft" .. i]
        if line then
            local text = line:GetText()
            if text then
                -- Socket bonus lines typically start with "Socket Bonus:"
                local bonusMatch = text:match("^Socket Bonus: (.+)$")
                if bonusMatch then
                    bonusText = bonusMatch

                    -- Parse required colors from socket lines above
                    -- Look for colored socket requirements
                    for j = 1, i - 1 do
                        local socketLine = _G["GGSocketBonusTooltipTextLeft" .. j]
                        if socketLine then
                            local socketText = socketLine:GetText()
                            if socketText then
                                local lowerText = string.lower(socketText)
                                if string.find(lowerText, "socket") then
                                    if string.find(lowerText, "red") then
                                        requiredColors.red = (requiredColors.red or 0) + 1
                                    elseif string.find(lowerText, "yellow") then
                                        requiredColors.yellow = (requiredColors.yellow or 0) + 1
                                    elseif string.find(lowerText, "blue") then
                                        requiredColors.blue = (requiredColors.blue or 0) + 1
                                    elseif string.find(lowerText, "meta") then
                                        requiredColors.meta = (requiredColors.meta or 0) + 1
                                    end
                                end
                            end
                        end
                    end
                    break
                end
            end
        end
    end

    if not bonusText then
        GG.socketBonusCache[itemLink] = { info = nil, timestamp = GetTime() }
        return nil
    end

    -- Check if bonus is active by comparing with gems in itemLink
    local isActive = GG.IsSocketBonusActive(itemLink, requiredColors)

    local info = {
        bonusText = bonusText,
        isActive = isActive,
        requiredColors = requiredColors
    }

    GG.socketBonusCache[itemLink] = { info = info, timestamp = GetTime() }
    return info
end

-- Check if socket bonus is currently active for an item
function GG.IsSocketBonusActive(itemLink, requiredColors)
    if not itemLink or not requiredColors then return false end

    -- Parse gems from itemLink
    local _, _, itemString = string.find(itemLink, "|Hitem:([^|]+)|h")
    if not itemString then return false end

    local parts = {}
    for match in string.gmatch(itemString .. ":", "([^:]*):") do
        table.insert(parts, match)
    end

    -- Count gem colors from filled sockets (indices 4-7)
    local gemColors = { red = 0, yellow = 0, blue = 0, meta = 0 }
    local filledCount = 0

    for i = 4, 7 do
        if parts[i] and parts[i] ~= "" and parts[i] ~= "0" then
            local gemID = tonumber(parts[i])
            if gemID and gemID > 0 then
                filledCount = filledCount + 1
                local color = GG.GetGemColor(gemID)
                if color then
                    if color == "red" then gemColors.red = gemColors.red + 1
                    elseif color == "yellow" then gemColors.yellow = gemColors.yellow + 1
                    elseif color == "blue" then gemColors.blue = gemColors.blue + 1
                    elseif color == "meta" then gemColors.meta = gemColors.meta + 1
                    elseif color == "orange" then -- red + yellow
                        gemColors.red = gemColors.red + 1
                        gemColors.yellow = gemColors.yellow + 1
                    elseif color == "purple" then -- red + blue
                        gemColors.red = gemColors.red + 1
                        gemColors.blue = gemColors.blue + 1
                    elseif color == "green" then -- yellow + blue
                        gemColors.yellow = gemColors.yellow + 1
                        gemColors.blue = gemColors.blue + 1
                    elseif color == "prismatic" then -- all colors
                        gemColors.red = gemColors.red + 1
                        gemColors.yellow = gemColors.yellow + 1
                        gemColors.blue = gemColors.blue + 1
                    end
                end
            end
        end
    end

    -- Check if all required colors are met
    for color, count in pairs(requiredColors) do
        if (gemColors[color] or 0) < count then
            return false
        end
    end

    -- Also verify all sockets are filled
    local totalSockets = 0
    for _, count in pairs(requiredColors) do
        totalSockets = totalSockets + count
    end

    return filledCount >= totalSockets
end

-- Helper: determine gem color from gem ID (reuse from metagems.lua logic)
function GG.GetGemColor(gemID)
    if not gemID or gemID == 0 then return nil end

    local gemName = GetItemInfo(gemID)
    if not gemName then return nil end

    local lowerName = string.lower(gemName)

    if string.find(lowerName, "diamond") then return "meta" end

    if string.find(lowerName, "ruby") or string.find(lowerName, "crimson spinel") or
       string.find(lowerName, "blood garnet") or string.find(lowerName, "living ruby") then
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

    if string.find(lowerName, "amber") or string.find(lowerName, "pyrestone") then
        return "orange"
    end

    if string.find(lowerName, "amethyst") or string.find(lowerName, "nightseye") or
       string.find(lowerName, "royal") then
        return "purple"
    end

    if string.find(lowerName, "jade") or string.find(lowerName, "tourmaline") or
       string.find(lowerName, "seaspray emerald") or string.find(lowerName, "talasite") then
        return "green"
    end

    if string.find(lowerName, "prismatic") then return "prismatic" end

    return nil
end

-- Clear socket bonus cache
function GG.ClearSocketBonusCache()
    GG.socketBonusCache = {}
end

-- Check if slot should show socket bonus warning
function GG.CheckSocketBonusWarning(slotID, guid)
    if not GG.GetConfig("socketBonus") then return nil end

    guid = guid or UnitGUID("player")
    if not guid then return nil end

    local itemLink
    if guid == UnitGUID("player") then
        itemLink = GetInventoryItemLink("player", slotID)
    else
        itemLink = GG.GetItemLinkByGUID(guid, slotID)
    end

    if not itemLink then return nil end

    local bonusInfo = GG.GetSocketBonusInfo(itemLink)
    if not bonusInfo then return nil end

    -- Only warn if bonus is inactive
    if bonusInfo.isActive then return nil end

    return bonusInfo
end
