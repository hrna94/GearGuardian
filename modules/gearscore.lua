-- ============================================
-- GearGuardian - GearScore Calculation Module
-- ============================================

local GG = GearGuardian
if not GG then return end

-- ============================================
-- GEARSCORE CALCULATION
-- ============================================

-- GearScore slot modifiers (TBC values)
local GS_SlotModifiers = {
    [1] = 1.0000,   -- Head
    [2] = 0.5625,   -- Neck
    [3] = 0.7500,   -- Shoulder
    [5] = 1.0000,   -- Chest
    [6] = 0.7500,   -- Waist
    [7] = 1.0000,   -- Legs
    [8] = 0.7500,   -- Feet
    [9] = 0.5625,   -- Wrist
    [10] = 0.7500,  -- Hands
    [11] = 0.5625,  -- Finger 1
    [12] = 0.5625,  -- Finger 2
    [13] = 0.5625,  -- Trinket 1
    [14] = 0.5625,  -- Trinket 2
    [15] = 0.5625,  -- Back
    [16] = 2.0000,  -- Main Hand (2H weapon)
    [17] = 1.0000,  -- Off Hand
    [18] = 0.3164,  -- Ranged
}

-- GearScore formula tables for TBC
local GS_Formula = {
    ["A"] = { -- Item level > 120
        [4] = { ["A"] = 91.4500, ["B"] = 0.6500 },  -- Epic
        [3] = { ["A"] = 81.3750, ["B"] = 0.8125 },  -- Rare
        [2] = { ["A"] = 73.0000, ["B"] = 1.0000 }   -- Uncommon
    },
    ["B"] = { -- Item level <= 120
        [4] = { ["A"] = 26.0000, ["B"] = 1.2000 },
        [3] = { ["A"] = 0.7500, ["B"] = 1.8000 },
        [2] = { ["A"] = 8.0000, ["B"] = 2.0000 },
        [1] = { ["A"] = 0.0000, ["B"] = 2.2500 }
    }
}

-- Calculate GearScore for a single item (made global for optimization)
function GG.GetItemGearScore(itemLink)
    if not itemLink then return 0 end

    local _, _, itemRarity, itemLevel, _, _, _, _, equipSlot = GetItemInfo(itemLink)

    if not itemRarity or not itemLevel or not equipSlot then
        return 0
    end

    -- Get slot ID from equip slot
    local slotID = nil
    if equipSlot == "INVTYPE_HEAD" then slotID = 1
    elseif equipSlot == "INVTYPE_NECK" then slotID = 2
    elseif equipSlot == "INVTYPE_SHOULDER" then slotID = 3
    elseif equipSlot == "INVTYPE_CHEST" or equipSlot == "INVTYPE_ROBE" then slotID = 5
    elseif equipSlot == "INVTYPE_WAIST" then slotID = 6
    elseif equipSlot == "INVTYPE_LEGS" then slotID = 7
    elseif equipSlot == "INVTYPE_FEET" then slotID = 8
    elseif equipSlot == "INVTYPE_WRIST" then slotID = 9
    elseif equipSlot == "INVTYPE_HAND" then slotID = 10
    elseif equipSlot == "INVTYPE_FINGER" then slotID = 11
    elseif equipSlot == "INVTYPE_TRINKET" then slotID = 13
    elseif equipSlot == "INVTYPE_CLOAK" then slotID = 15
    elseif equipSlot == "INVTYPE_2HWEAPON" or equipSlot == "INVTYPE_WEAPONMAINHAND" or equipSlot == "INVTYPE_WEAPON" then slotID = 16
    elseif equipSlot == "INVTYPE_WEAPONOFFHAND" or equipSlot == "INVTYPE_SHIELD" or equipSlot == "INVTYPE_HOLDABLE" then slotID = 17
    elseif equipSlot == "INVTYPE_RANGED" or equipSlot == "INVTYPE_RANGEDRIGHT" or equipSlot == "INVTYPE_THROWN" or equipSlot == "INVTYPE_RELIC" then slotID = 18
    end

    if not slotID or not GS_SlotModifiers[slotID] then
        return 0
    end

    -- Quality scale
    local qualityScale = 1
    if itemRarity == 5 then  -- Legendary
        qualityScale = 1.3
        itemRarity = 4
    elseif itemRarity == 1 or itemRarity == 0 then  -- Common/Poor
        qualityScale = 0.005
        itemRarity = 2
    end

    -- Select formula table
    local table = itemLevel > 120 and GS_Formula["A"] or GS_Formula["B"]

    if itemRarity >= 2 and itemRarity <= 4 and table[itemRarity] then
        local scale = 1.8618
        local gearScore = math.floor(
            ((itemLevel - table[itemRarity].A) / table[itemRarity].B) *
            GS_SlotModifiers[slotID] *
            scale *
            qualityScale
        )

        if gearScore < 0 then
            gearScore = 0
        end

        return gearScore
    end

    return 0
end

-- Calculate total GearScore for a unit using LibClassicInspector
function GG.CalculateGearScore(guid)
    if not guid then return 0 end

    local totalScore = 0
    local itemCount = 0

    -- All equipment slots
    local slots = {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}

    for _, slotID in ipairs(slots) do
        local itemLink = GG.GetItemLinkByGUID(guid, slotID)
        if itemLink then
            local score = GG.GetItemGearScore(itemLink)
            totalScore = totalScore + score
            itemCount = itemCount + 1
        end
    end

    return math.floor(totalScore)
end

-- Get color for GearScore (TBC bracket: 400 per tier)
function GG.GetGearScoreColor(score)
    local bracket = 400

    if score >= bracket * 5 then  -- 2000+ Legendary
        return 0.94, 0.47, 0
    elseif score >= bracket * 4 then  -- 1600-2000 Epic
        return 0.69, 0.28, 0.97
    elseif score >= bracket * 3 then  -- 1200-1600 Superior
        return 0, 0.50, 1
    elseif score >= bracket * 2 then  -- 800-1200 Rare
        return 0.12, 1, 0
    elseif score >= bracket then  -- 400-800 Uncommon
        return 1, 1, 1
    else  -- <400 Poor
        return 0.55, 0.55, 0.55
    end
end
