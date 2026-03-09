-- ============================================
-- GearGuardian - Enchant Suggestions Module
-- ============================================

local GG = GearGuardian
if not GG then return end

-- ============================================
-- ENCHANT SUGGESTIONS DATABASE
-- ============================================

-- Enchant suggestions by slot and spec type
local ENCHANT_SUGGESTIONS = {
    -- Head (slot 1)
    [1] = {
        physical = {
            "Glyph of Ferocity (34 AP, 16 hit) - Cenarion Expedition Revered",
            "Glyph of Power (35 spell damage/healing) - Sha'tar Revered",
            "Arcanum of Protection (12 dodge, 17 def) - Keepers of Time Revered"
        },
        melee = {
            "Glyph of Ferocity (34 AP, 16 hit) - Cenarion Expedition Revered",
            "Arcanum of Protection (12 dodge, 17 def) - Keepers of Time Revered"
        },
        caster = {
            "Glyph of Power (35 spell damage/healing) - Sha'tar Revered",
            "Arcanum of Protection (12 dodge, 17 def) - Keepers of Time Revered"
        },
        healing = {
            "Glyph of Power (35 spell damage/healing) - Sha'tar Revered",
            "Arcanum of Protection (12 dodge, 17 def) - Keepers of Time Revered"
        },
        tank = {
            "Arcanum of Protection (12 dodge, 17 def) - Keepers of Time Revered",
            "Glyph of Power (35 spell damage/healing) - Sha'tar Revered"
        }
    },

    -- Shoulders (slot 3)
    [3] = {
        physical = {
            "Greater Inscription of the Blade (15 crit, 20 AP) - Aldor Exalted",
            "Greater Inscription of Warding (15 dodge, 10 def) - Aldor Exalted",
            "Greater Inscription of Vengeance (15 crit, 20 AP) - Scryer Exalted"
        },
        caster = {
            "Greater Inscription of the Orb (12 spell damage, 15 crit) - Scryer Exalted",
            "Greater Inscription of Discipline (18 healing, 10 mp5) - Aldor Exalted",
            "Greater Inscription of Faith (18 healing, 10 mp5) - Scryer Exalted"
        },
        healing = {
            "Greater Inscription of Discipline (18 healing, 10 mp5) - Aldor Exalted",
            "Greater Inscription of Faith (18 healing, 10 mp5) - Scryer Exalted"
        },
        tank = {
            "Greater Inscription of Warding (15 dodge, 10 def) - Aldor Exalted",
            "Greater Inscription of the Blade (15 crit, 20 AP) - Aldor Exalted"
        }
    },

    -- Chest (slot 5)
    [5] = {
        physical = {
            "Exceptional Stats (+6 all stats) - Enchanter 345",
            "Exceptional Health (+150 HP) - Enchanter 300"
        },
        caster = {
            "Exceptional Stats (+6 all stats) - Enchanter 345",
            "Major Spirit (+15 spirit) - Enchanter 325"
        },
        healing = {
            "Exceptional Stats (+6 all stats) - Enchanter 345",
            "Major Spirit (+15 spirit) - Enchanter 325"
        },
        tank = {
            "Exceptional Health (+150 HP) - Enchanter 300",
            "Major Resilience (+15 resilience) - Enchanter 325"
        }
    },

    -- Legs (slot 7)
    [7] = {
        physical = {
            "Nethercobra Leg Armor (50 AP, 12 crit) - Leatherworker 365",
            "Clefthide Leg Armor (30 stam, 10 agi) - Leatherworker 335"
        },
        caster = {
            "Runic Spellthread (35 healing, 20 stam) - Tailor 375",
            "Silver Spellthread (35 spell damage, 20 stam) - Tailor 375"
        },
        tank = {
            "Clefthide Leg Armor (30 stam, 10 agi) - Leatherworker 335"
        }
    },

    -- Back/Cloak (slot 15)
    [15] = {
        physical = {
            "Greater Agility (+12 agi) - Enchanter 300",
            "Major Armor (+120 armor) - Enchanter 320"
        },
        caster = {
            "Subtlety (reduce threat 2%) - Enchanter 300",
            "Major Resistance (+7 all resist) - Enchanter 280"
        },
        healing = {
            "Subtlety (reduce threat 2%) - Enchanter 300",
            "Major Resistance (+7 all resist) - Enchanter 280"
        },
        tank = {
            "Major Armor (+120 armor) - Enchanter 320",
            "Dodge (+12 dodge) - Enchanter 300"
        }
    },

    -- Main Hand/Weapons (slot 16)
    [16] = {
        melee = {
            "Mongoose (120 agi, 2% haste proc) - Enchanter 375",
            "Executioner (+ crit proc, 120 AP proc) - Exalted Consortium",
            "Major Striking (+7 weapon damage) - Enchanter 340"
        },
        caster = {
            "Major Spellpower (+40 spell damage) - Enchanter 340",
            "Soulfrost (+54 frost/shadow damage) - Enchanter 375",
            "Sunfire (+50 arcane/fire damage) - Enchanter 375"
        },
        healing = {
            "Major Healing (+81 healing) - Enchanter 340"
        },
        tank = {
            "Mongoose (120 agi, 2% haste proc) - Enchanter 375",
            "Major Striking (+7 weapon damage) - Enchanter 340"
        }
    },

    -- Feet (slot 8)
    [8] = {
        physical = {
            "Cat's Swiftness (+6 agi, minor run speed) - Enchanter 360",
            "Dexterity (+12 agi) - Enchanter 340",
            "Surefooted (+5 hit, +5% snare resist) - Enchanter 370"
        },
        caster = {
            "Vitality (+4 mp5) - Enchanter 305",
            "Boar's Speed (+9 stam, minor run speed) - Enchanter 360"
        },
        healing = {
            "Vitality (+4 mp5) - Enchanter 305",
            "Boar's Speed (+9 stam, minor run speed) - Enchanter 360"
        },
        tank = {
            "Boar's Speed (+9 stam, minor run speed) - Enchanter 360",
            "Fortitude (+12 stam) - Enchanter 320"
        }
    },

    -- Wrists (slot 9)
    [9] = {
        physical = {
            "Brawn (+12 str) - Enchanter 360",
            "Major Strength (+9 str) - Enchanter 340",
            "Assault (+12 AP) - Enchanter 300"
        },
        caster = {
            "Spellpower (+15 spell damage) - Enchanter 360",
            "Major Intellect (+12 int) - Enchanter 300"
        },
        healing = {
            "Major Healing (+24 healing) - Enchanter 350"
        },
        tank = {
            "Brawn (+12 str) - Enchanter 360",
            "Major Defense (+12 defense) - Enchanter 340"
        }
    },

    -- Hands/Gloves (slot 10)
    [10] = {
        physical = {
            "Superior Agility (+15 agi) - Enchanter 370",
            "Assault (+26 AP) - Enchanter 370",
            "Blasting (+10 gun/xbow damage) - Engineer 335"
        },
        caster = {
            "Major Spellpower (+20 spell damage) - Enchanter 360",
            "Major Healing (+35 healing) - Enchanter 360"
        },
        healing = {
            "Major Healing (+35 healing) - Enchanter 360",
            "Major Spellpower (+20 spell damage) - Enchanter 360"
        },
        tank = {
            "Superior Agility (+15 agi) - Enchanter 370",
            "Major Strength (+15 str) - Enchanter 340"
        }
    }
}

-- Determine spec category for enchant suggestions
local function GetSpecCategory()
    local class, spec
    if GG.GetPlayerSpec then
        class, spec = GG.GetPlayerSpec()
    else
        class = select(2, UnitClass("player"))
        spec = "Unknown"
    end

    -- Tanks
    if class == "WARRIOR" and spec == "Protection" then return "tank" end
    if class == "PALADIN" and spec == "Protection" then return "tank" end
    if class == "DRUID" and spec == "Feral" then return "tank" end

    -- Healers
    if class == "PRIEST" and (spec == "Holy" or spec == "Discipline") then return "healing" end
    if class == "PALADIN" and spec == "Holy" then return "healing" end
    if class == "SHAMAN" and spec == "Restoration" then return "healing" end
    if class == "DRUID" and spec == "Restoration" then return "healing" end

    -- Casters
    if class == "MAGE" then return "caster" end
    if class == "WARLOCK" then return "caster" end
    if class == "PRIEST" and spec == "Shadow" then return "caster" end
    if class == "SHAMAN" and spec == "Elemental" then return "caster" end
    if class == "DRUID" and spec == "Balance" then return "caster" end

    -- Physical DPS
    if class == "WARRIOR" then return "physical" end
    if class == "ROGUE" then return "melee" end
    if class == "HUNTER" then return "physical" end
    if class == "PALADIN" and spec == "Retribution" then return "physical" end
    if class == "SHAMAN" and spec == "Enhancement" then return "melee" end

    -- Default fallback
    return "physical"
end

-- Get enchant suggestions for a slot
function GG.GetEnchantSuggestions(slotID)
    if not ENCHANT_SUGGESTIONS[slotID] then return nil end

    local category = GetSpecCategory()
    local suggestions = ENCHANT_SUGGESTIONS[slotID]

    -- Try specific category first
    if suggestions[category] then
        return suggestions[category]
    end

    -- Try alternate categories
    if category == "melee" and suggestions["physical"] then
        return suggestions["physical"]
    end

    if category == "healing" and suggestions["caster"] then
        return suggestions["caster"]
    end

    -- Fall back to "all" category
    if suggestions["all"] then
        return suggestions["all"]
    end

    -- Return first available category
    for _, list in pairs(suggestions) do
        return list
    end

    return nil
end

-- Hook into tooltip to show enchant suggestions
local function OnTooltipSetItem(tooltip)
    if not GG.GetConfig("enchantSuggestions") then return end

    local _, itemLink = tooltip:GetItem()
    if not itemLink then return end

    -- Only show suggestions on YOUR character panel, not on inspect targets
    local owner = tooltip:GetOwner()
    if not owner then return end

    -- Check if tooltip is from player's character frame
    local isPlayerTooltip = false
    if owner == CharacterFrame or owner == PaperDollFrame then
        isPlayerTooltip = true
    end

    -- Also check if owner is a character slot frame (CharacterHeadSlot, etc.)
    if owner:GetName() and string.find(owner:GetName(), "^Character") then
        isPlayerTooltip = true
    end

    -- Don't show suggestions on inspect frame or other tooltips
    if not isPlayerTooltip then return end

    -- Get slot info
    local _, _, _, _, _, _, _, _, equipSlot = GetItemInfo(itemLink)
    if not equipSlot then return end

    -- Determine slot ID
    local slotID = nil
    if equipSlot == "INVTYPE_HEAD" then slotID = 1
    elseif equipSlot == "INVTYPE_SHOULDER" then slotID = 3
    elseif equipSlot == "INVTYPE_CHEST" or equipSlot == "INVTYPE_ROBE" then slotID = 5
    elseif equipSlot == "INVTYPE_LEGS" then slotID = 7
    elseif equipSlot == "INVTYPE_FEET" then slotID = 8
    elseif equipSlot == "INVTYPE_WRIST" then slotID = 9
    elseif equipSlot == "INVTYPE_HAND" then slotID = 10
    elseif equipSlot == "INVTYPE_CLOAK" then slotID = 15
    elseif equipSlot == "INVTYPE_WEAPON" or equipSlot == "INVTYPE_2HWEAPON" or
           equipSlot == "INVTYPE_WEAPONMAINHAND" then slotID = 16
    end

    if not slotID then return end

    -- Check if item should have enchant and doesn't
    if not GG.ShouldHaveEnchant(slotID) then return end

    -- Check if already enchanted (for equipped items)
    -- For now, we'll show suggestions for all items that can be enchanted
    -- You can add logic here to hide if already enchanted

    -- Get suggestions
    local suggestions = GG.GetEnchantSuggestions(slotID)
    if not suggestions then return end

    -- Add to tooltip
    tooltip:AddLine(" ")
    tooltip:AddLine("|cffFFAA00Enchant Suggestions:|r")

    for i, suggestion in ipairs(suggestions) do
        if i <= 3 then -- Show max 3 suggestions
            tooltip:AddLine("|cff88FF88• " .. suggestion .. "|r", 1, 1, 1, true)
        end
    end
end

-- Hook tooltips
GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ItemRefTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ShoppingTooltip1:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ShoppingTooltip2:HookScript("OnTooltipSetItem", OnTooltipSetItem)
