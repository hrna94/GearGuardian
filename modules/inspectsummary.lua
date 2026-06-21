--[[
    GearGuardian - Inspect Quick Summary Panel
    Shows a compact gear readiness overview when inspecting another player
]]--

local GG = GearGuardian
if not GG then return end

GG.inspectSummaryFrame = nil

local SLOT_NAMES = {
    [1] = "Head", [2] = "Neck", [3] = "Shoulder", [5] = "Chest",
    [6] = "Waist", [7] = "Legs", [8] = "Feet", [9] = "Wrist",
    [10] = "Hands", [15] = "Back", [16] = "Main Hand", [17] = "Off Hand",
    [18] = "Ranged"
}

local ENCHANTABLE_SLOTS = {1, 3, 5, 7, 8, 9, 10, 15, 16, 17}

local function GetColorForPercent(pct)
    if pct >= 100 then return "|cff00FF00"
    elseif pct >= 75 then return "|cffFFFF00"
    elseif pct >= 50 then return "|cffFFA500"
    else return "|cffFF0000"
    end
end

local function BuildSummary(guid)
    if not guid then return nil end

    local enchantedCount = 0
    local enchantTotal = 0
    local missingEnchants = {}

    local gemmedCount = 0
    local gemTotal = 0
    local missingGems = {}

    local socketBonusActive = 0
    local socketBonusTotal = 0

    for _, slotID in ipairs(ENCHANTABLE_SLOTS) do
        local itemLink = GG.GetItemLinkByGUID(guid, slotID)
        if itemLink then
            if GG.ShouldHaveEnchant(slotID) then
                enchantTotal = enchantTotal + 1
                if GG.HasEnchant(slotID, false, guid) then
                    enchantedCount = enchantedCount + 1
                else
                    table.insert(missingEnchants, SLOT_NAMES[slotID] or ("Slot " .. slotID))
                end
            end

            local emptySockets = GG.GetEmptySocketCount(slotID, guid)
            local gems = GG.GetGemsFromLink(itemLink)
            local filledSockets = #gems
            local totalSockets = filledSockets + emptySockets

            if totalSockets > 0 then
                gemTotal = gemTotal + totalSockets
                gemmedCount = gemmedCount + filledSockets
                if emptySockets > 0 then
                    table.insert(missingGems, (SLOT_NAMES[slotID] or ("Slot " .. slotID)) .. " (" .. emptySockets .. ")")
                end
            end

            local bonusInfo = GG.GetSocketBonusInfo(itemLink)
            if bonusInfo then
                socketBonusTotal = socketBonusTotal + 1
                if bonusInfo.isActive then
                    socketBonusActive = socketBonusActive + 1
                end
            end
        end
    end

    local gearScore, avgILevel = GG.CalculateGearScoreAndItemLevel(guid)

    return {
        enchantedCount = enchantedCount,
        enchantTotal = enchantTotal,
        missingEnchants = missingEnchants,
        gemmedCount = gemmedCount,
        gemTotal = gemTotal,
        missingGems = missingGems,
        socketBonusActive = socketBonusActive,
        socketBonusTotal = socketBonusTotal,
        gearScore = gearScore,
        avgILevel = avgILevel
    }
end

function GG.UpdateInspectSummary()
    if not GG.GetConfig("inspectSummary") then
        if GG.inspectSummaryFrame then GG.inspectSummaryFrame:Hide() end
        return
    end

    local parentFrame = InspectFrame or InspectPaperDollFrame
    if not parentFrame or not parentFrame:IsShown() then
        if GG.inspectSummaryFrame then GG.inspectSummaryFrame:Hide() end
        return
    end

    local guid = GG.inspectedUnit and UnitGUID(GG.inspectedUnit)
    if not guid then return end

    local summary = BuildSummary(guid)
    if not summary then return end

    if not GG.inspectSummaryFrame then
        GG.inspectSummaryFrame = CreateFrame("Frame", "GGInspectSummaryFrame", parentFrame)
        GG.inspectSummaryFrame:SetFrameStrata("HIGH")
        GG.inspectSummaryFrame:SetFrameLevel(300)
        GG.inspectSummaryFrame:SetSize(340, 80)

        local bg = GG.inspectSummaryFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0.85)

        local border = GG.inspectSummaryFrame:CreateTexture(nil, "BORDER")
        border:SetColorTexture(0.3, 0.3, 0.4, 0.8)
        border:SetAllPoints()

        local inner = GG.inspectSummaryFrame:CreateTexture(nil, "BORDER", nil, 1)
        inner:SetColorTexture(0, 0, 0, 0.85)
        inner:SetPoint("TOPLEFT", 1, -1)
        inner:SetPoint("BOTTOMRIGHT", -1, 1)

        GG.inspectSummaryFrame.text = GG.inspectSummaryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        GG.inspectSummaryFrame.text:SetPoint("TOPLEFT", 6, -6)
        GG.inspectSummaryFrame.text:SetJustifyH("LEFT")
        GG.inspectSummaryFrame.text:SetWidth(328)
        GG.inspectSummaryFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 10)
    end

    GG.inspectSummaryFrame:ClearAllPoints()
    GG.inspectSummaryFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 60, -5)
    GG.inspectSummaryFrame:SetParent(parentFrame)

    local lines = {}

    local enchPct = summary.enchantTotal > 0 and math.floor(summary.enchantedCount / summary.enchantTotal * 100) or 100
    local enchColor = GetColorForPercent(enchPct)
    local enchLine = string.format("%sEnchants: %d/%d|r", enchColor, summary.enchantedCount, summary.enchantTotal)
    if #summary.missingEnchants > 0 then
        enchLine = enchLine .. "  |cffFF6666x " .. table.concat(summary.missingEnchants, ", ") .. "|r"
    end
    table.insert(lines, enchLine)

    local gemPct = summary.gemTotal > 0 and math.floor(summary.gemmedCount / summary.gemTotal * 100) or 100
    local gemColor = GetColorForPercent(gemPct)
    local gemLine = string.format("%sGems: %d/%d|r", gemColor, summary.gemmedCount, summary.gemTotal)
    if #summary.missingGems > 0 then
        gemLine = gemLine .. "  |cffFF6666x " .. table.concat(summary.missingGems, ", ") .. "|r"
    end
    table.insert(lines, gemLine)

    if summary.socketBonusTotal > 0 then
        local sbPct = math.floor(summary.socketBonusActive / summary.socketBonusTotal * 100)
        local sbColor = GetColorForPercent(sbPct)
        table.insert(lines, string.format("%sSocket Bonus: %d/%d active|r", sbColor, summary.socketBonusActive, summary.socketBonusTotal))
    end

    local gsLine = string.format("|cffFFFF00GearScore: %d|r  |cffAAAAAAiLvl: %d|r", summary.gearScore, summary.avgILevel)
    table.insert(lines, gsLine)

    GG.inspectSummaryFrame.text:SetText(table.concat(lines, "\n"))
    GG.inspectSummaryFrame:SetHeight(16 + #lines * 14)
    GG.inspectSummaryFrame:Show()
end

function GG.HideInspectSummary()
    if GG.inspectSummaryFrame then
        GG.inspectSummaryFrame:Hide()
    end
end
