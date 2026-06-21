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
        qualityBorders = true,
        itemLevel = true,
        comparison = true,
        averageILevel = true,
        bagHighlight = false,
        enchantCheck = true,
        gemCheck = true,
        socketBonus = false,
        enchantSuggestions = true,
        tempEnchant = false,
        metaGemCheck = false,
        inspectSummary = true,
        enchantSources = true,
        colorCustomization = false,
        setBonusTracking = false,
        dualSpecSupport = false
    }
}

GG.defaultColors = {
    gsBackground = {0, 0, 0, 0.8},
    iLevelBackground = {0, 0, 0, 0.8},
    gsLabel = {1, 1, 1},
    iLevelLabel = {1, 1, 1},
}

function GG.GetCustomColor(key)
    if not GG.GetConfig("colorCustomization") then
        return GG.defaultColors[key]
    end
    if GearGuardianDB and GearGuardianDB.colors and GearGuardianDB.colors[key] then
        return GearGuardianDB.colors[key]
    end
    return GG.defaultColors[key]
end

function GG.SetCustomColor(key, r, g, b, a)
    if not GearGuardianDB then GearGuardianDB = {} end
    if not GearGuardianDB.colors then GearGuardianDB.colors = {} end
    GearGuardianDB.colors[key] = {r, g, b, a or 1}
end

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

