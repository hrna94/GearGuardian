--[[
    GearGuardian - Configuration System
    Handles SavedVariables and addon settings
]]--

local GG = GearGuardian

-- ============================================
-- CONFIGURATION SYSTEM
-- ============================================

-- Default configuration
GG.defaultConfig = {
    enabled = true,
    features = {
        qualityBorders = true,      -- Colored borders on items
        itemLevel = true,           -- Show item level numbers
        comparison = true,          -- Show stat comparison in tooltips
        averageILevel = true,       -- Show average iLevel on character frame
        bagHighlight = false,       -- Highlight upgrades in bags (DISABLED - TBC bag API issues)
        enchantCheck = true,        -- Check for missing enchants
        gemCheck = true,            -- Check for empty gem sockets
        setBonusTracking = false,   -- Show tier set bonuses (future)
        dualSpecSupport = false     -- Support for dual spec (future)
    }
}

-- Initialize saved variables
function GG.InitializeConfig()
    if not GearGuardianDB then
        GearGuardianDB = {}
    end

    -- Merge with defaults
    if not GearGuardianDB.config then
        GearGuardianDB.config = GG.defaultConfig
    else
        -- Add any missing keys from defaults
        for key, value in pairs(GG.defaultConfig) do
            if GearGuardianDB.config[key] == nil then
                GearGuardianDB.config[key] = value
            end
        end

        -- Add missing feature keys
        if GearGuardianDB.config.features then
            for key, value in pairs(GG.defaultConfig.features) do
                if GearGuardianDB.config.features[key] == nil then
                    GearGuardianDB.config.features[key] = value
                end
            end
        else
            GearGuardianDB.config.features = GG.defaultConfig.features
        end
    end
end

-- Get config value
function GG.GetConfig(feature)
    if not GearGuardianDB or not GearGuardianDB.config then
        return GG.defaultConfig.features[feature]
    end
    return GearGuardianDB.config.features[feature]
end

-- Set config value
function GG.SetConfig(feature, value)
    if not GearGuardianDB or not GearGuardianDB.config then
        GG.InitializeConfig()
    end
    GearGuardianDB.config.features[feature] = value
end

-- All character frame slots
GG.characterSlots = {
    "CharacterHeadSlot",
    "CharacterNeckSlot",
    "CharacterShoulderSlot",
    "CharacterBackSlot",
    "CharacterChestSlot",
    "CharacterShirtSlot",
    "CharacterTabardSlot",
    "CharacterWristSlot",
    "CharacterHandsSlot",
    "CharacterWaistSlot",
    "CharacterLegsSlot",
    "CharacterFeetSlot",
    "CharacterFinger0Slot",
    "CharacterFinger1Slot",
    "CharacterTrinket0Slot",
    "CharacterTrinket1Slot",
    "CharacterMainHandSlot",
    "CharacterSecondaryHandSlot",
    "CharacterRangedSlot",
}
