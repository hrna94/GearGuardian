-- ============================================
-- GearGuardian - Item Comparison System Module
-- ============================================

local GG = GearGuardian
if not GG then return end

-- ============================================
-- ITEM COMPARISON SYSTEM
-- ============================================

-- Stat weights for different class/spec combinations
GG.StatWeights = {
    -- Warrior
    WARRIOR = {
        Arms = { AP = 1.0, Crit = 1.2, Hit = 1.5, ArP = 1.1, Str = 2.0, Agi = 0.5, Haste = 0.8 },
        Fury = { AP = 1.0, Crit = 1.3, Hit = 1.5, ArP = 1.2, Str = 2.0, Agi = 0.5, Haste = 0.9 },
        Protection = { Sta = 1.0, Def = 1.5, Dodge = 1.2, Parry = 1.1, BlockValue = 0.8, Str = 0.5 }
    },
    -- Paladin
    PALADIN = {
        Holy = { Healing = 1.0, Int = 0.8, MP5 = 1.2, Crit = 0.6, Haste = 0.7, Spi = 0.5 },
        Protection = { Sta = 1.0, Def = 1.5, Dodge = 1.2, Parry = 1.1, BlockValue = 1.3, Str = 0.5 },
        Retribution = { AP = 1.0, Crit = 1.2, Hit = 1.5, Str = 2.0, Haste = 0.9, ArP = 1.0 }
    },
    -- Hunter
    HUNTER = {
        BeastMastery = { AP = 1.0, RAP = 1.2, Crit = 1.3, Hit = 1.5, Agi = 2.0, ArP = 1.1, Haste = 0.8 },
        Marksmanship = { AP = 1.0, RAP = 1.2, Crit = 1.4, Hit = 1.5, Agi = 2.0, ArP = 1.2, Haste = 0.9 },
        Survival = { AP = 1.0, RAP = 1.2, Crit = 1.3, Hit = 1.5, Agi = 2.0, ArP = 1.3, Haste = 0.8 }
    },
    -- Rogue
    ROGUE = {
        Assassination = { AP = 1.0, Crit = 1.3, Hit = 1.5, Agi = 2.0, ArP = 1.1, Haste = 0.9 },
        Combat = { AP = 1.0, Crit = 1.2, Hit = 1.5, Agi = 2.0, ArP = 1.2, Haste = 1.0 },
        Subtlety = { AP = 1.0, Crit = 1.3, Hit = 1.5, Agi = 2.0, ArP = 1.0, Haste = 0.8 }
    },
    -- Priest
    PRIEST = {
        Discipline = { Healing = 1.0, SpellPower = 0.7, Int = 0.8, MP5 = 1.1, Crit = 0.6, Haste = 0.8, Spi = 0.9 },
        Holy = { Healing = 1.0, SpellPower = 0.7, Int = 0.8, MP5 = 1.0, Crit = 0.7, Haste = 0.9, Spi = 1.0 },
        Shadow = { SpellPower = 1.0, Hit = 1.5, Crit = 1.2, Haste = 1.1, Spi = 0.6, Int = 0.7 }
    },
    -- Shaman
    SHAMAN = {
        Elemental = { SpellPower = 1.0, Hit = 1.5, Crit = 1.2, Haste = 1.0, Int = 0.7 },
        Enhancement = { AP = 1.0, Hit = 1.5, Crit = 1.2, Agi = 1.5, Str = 1.3, Haste = 1.0, ArP = 1.0 },
        Restoration = { Healing = 1.0, Int = 0.8, MP5 = 1.2, Crit = 0.6, Haste = 0.8 }
    },
    -- Mage
    MAGE = {
        Arcane = { SpellPower = 1.0, Hit = 1.5, Crit = 1.1, Haste = 1.2, Int = 0.8 },
        Fire = { SpellPower = 1.0, Hit = 1.5, Crit = 1.3, Haste = 1.0, Int = 0.7 },
        Frost = { SpellPower = 1.0, Hit = 1.5, Crit = 1.2, Haste = 1.1, Int = 0.7 }
    },
    -- Warlock
    WARLOCK = {
        Affliction = { SpellPower = 1.0, Hit = 1.5, Crit = 1.1, Haste = 1.0, Spi = 0.8, Int = 0.7 },
        Demonology = { SpellPower = 1.0, Hit = 1.5, Crit = 1.1, Haste = 1.0, Sta = 0.3, Int = 0.7 },
        Destruction = { SpellPower = 1.0, Hit = 1.5, Crit = 1.3, Haste = 1.1, Int = 0.7 }
    },
    -- Druid
    DRUID = {
        Balance = { SpellPower = 1.0, Hit = 1.5, Crit = 1.2, Haste = 1.0, Int = 0.7 },
        Feral = { AP = 1.0, Crit = 1.2, Hit = 1.5, Agi = 2.0, ArP = 1.1, Str = 1.5 },
        Restoration = { Healing = 1.0, Int = 0.8, MP5 = 1.1, Spi = 0.9, Haste = 0.7 }
    }
}

-- Create reusable tooltip for scanning (if not already created)
local scanTooltip = _G["ItemComparisonScanTooltip"] or CreateFrame("GameTooltip", "ItemComparisonScanTooltip", nil, "GameTooltipTemplate")
scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")

-- Parse item stats (scanTooltip is already created at the top of the file)
function GG.ParseItemStats(itemLink)
    if not itemLink then return {} end
    if not scanTooltip then return {} end

    local stats = {}
    scanTooltip:ClearLines()
    scanTooltip:SetHyperlink(itemLink)

    for i = 1, scanTooltip:NumLines() do
        local line = _G["ItemComparisonScanTooltipTextLeft" .. i]
        if line then
            local text = line:GetText()
            if text then
                -- Attack Power
                local ap = text:match("Increases attack power by (%d+)")
                if ap then stats.AP = (stats.AP or 0) + tonumber(ap) end

                -- Ranged Attack Power
                local rap = text:match("Increases ranged attack power by (%d+)")
                if rap then stats.RAP = (stats.RAP or 0) + tonumber(rap) end

                -- Spell Damage/Power
                local sp = text:match("Increases damage done by magical spells and effects by up to (%d+)")
                if sp then stats.SpellPower = (stats.SpellPower or 0) + tonumber(sp) end

                -- Healing
                local heal = text:match("Increases healing done by up to (%d+)")
                if heal then stats.Healing = (stats.Healing or 0) + tonumber(heal) end

                -- Hit Rating
                local hit = text:match("Improves hit rating by (%d+)")
                if hit then stats.Hit = (stats.Hit or 0) + tonumber(hit) end

                -- Crit Rating
                local crit = text:match("Improves critical strike rating by (%d+)")
                if crit then stats.Crit = (stats.Crit or 0) + tonumber(crit) end

                -- Haste Rating
                local haste = text:match("Improves haste rating by (%d+)")
                if haste then stats.Haste = (stats.Haste or 0) + tonumber(haste) end

                -- Armor Penetration
                local arp = text:match("Improves armor penetration rating by (%d+)")
                if arp then stats.ArP = (stats.ArP or 0) + tonumber(arp) end

                -- Defense
                local def = text:match("Increased Defense %+(%d+)")
                if def then stats.Def = (stats.Def or 0) + tonumber(def) end

                -- Dodge
                local dodge = text:match("Increases your dodge rating by (%d+)")
                if dodge then stats.Dodge = (stats.Dodge or 0) + tonumber(dodge) end

                -- Parry
                local parry = text:match("Increases your parry rating by (%d+)")
                if parry then stats.Parry = (stats.Parry or 0) + tonumber(parry) end

                -- Stats from +X pattern
                local str = text:match("%+(%d+) Strength")
                if str then stats.Str = (stats.Str or 0) + tonumber(str) end

                local agi = text:match("%+(%d+) Agility")
                if agi then stats.Agi = (stats.Agi or 0) + tonumber(agi) end

                local sta = text:match("%+(%d+) Stamina")
                if sta then stats.Sta = (stats.Sta or 0) + tonumber(sta) end

                local int = text:match("%+(%d+) Intellect")
                if int then stats.Int = (stats.Int or 0) + tonumber(int) end

                local spi = text:match("%+(%d+) Spirit")
                if spi then stats.Spi = (stats.Spi or 0) + tonumber(spi) end

                -- MP5
                local mp5 = text:match("Restores (%d+) mana per 5 sec")
                if mp5 then stats.MP5 = (stats.MP5 or 0) + tonumber(mp5) end
            end
        end
    end

    return stats
end

-- Calculate item score based on stat weights
function GG.CalculateItemScore(stats, weights)
    if not stats or not weights then return 0 end

    local score = 0
    for stat, value in pairs(stats) do
        if weights[stat] then
            score = score + (value * weights[stat])
        end
    end

    return score
end

-- Get player specialization
function GG.GetPlayerSpec()
    local currentTime = GetTime()

    -- Initialize variables if needed
    if not GG.lastSpecCheck then GG.lastSpecCheck = 0 end
    if not GG.SPEC_CHECK_INTERVAL then GG.SPEC_CHECK_INTERVAL = 1.0 end

    -- Return cached value if still valid
    if GG.cachedClass and GG.cachedSpec and ((currentTime - GG.lastSpecCheck) < GG.SPEC_CHECK_INTERVAL) then
        return GG.cachedClass, GG.cachedSpec
    end

    local class = select(2, UnitClass("player"))
    local maxPoints = 0
    local specIndex = 1

    -- For TBC (2.x), we need to count talents manually
    for tabIndex = 1, GetNumTalentTabs() do
        local name, iconTexture, pointsSpent = GetTalentTabInfo(tabIndex)

        -- TBC fix: manually count talent points in this tab
        local tabPoints = 0
        local numTalents = GetNumTalents(tabIndex)

        for talentIndex = 1, numTalents do
            local nameTalent, icon, tier, column, rank, maxRank = GetTalentInfo(tabIndex, talentIndex)
            if rank then
                tabPoints = tabPoints + rank
            end
        end

        if tabPoints > maxPoints then
            maxPoints = tabPoints
            specIndex = tabIndex
        end
    end

    -- Map class and tab index to spec names
    local specNames = {
        WARRIOR = {"Arms", "Fury", "Protection"},
        PALADIN = {"Holy", "Protection", "Retribution"},
        HUNTER = {"BeastMastery", "Marksmanship", "Survival"},
        ROGUE = {"Assassination", "Combat", "Subtlety"},
        PRIEST = {"Discipline", "Holy", "Shadow"},
        SHAMAN = {"Elemental", "Enhancement", "Restoration"},
        MAGE = {"Arcane", "Fire", "Frost"},
        WARLOCK = {"Affliction", "Demonology", "Destruction"},
        DRUID = {"Balance", "Feral", "Restoration"}
    }

    if specNames[class] and specNames[class][specIndex] then
        GG.cachedClass = class
        GG.cachedSpec = specNames[class][specIndex]
        GG.lastSpecCheck = currentTime
        return GG.cachedClass, GG.cachedSpec
    end

    return class, "Unknown"
end

-- Comparison function used by other modules
function GG.CompareItems(newItemLink, equippedItemLink, class, spec)
    if not GG.StatWeights[class] or not GG.StatWeights[class][spec] then
        return nil
    end

    local weights = GG.StatWeights[class][spec]

    local newStats = GG.ParseItemStats(newItemLink)
    local newScore = GG.CalculateItemScore(newStats, weights)

    local equippedStats = GG.ParseItemStats(equippedItemLink)
    local equippedScore = GG.CalculateItemScore(equippedStats, weights)

    return newScore - equippedScore
end
