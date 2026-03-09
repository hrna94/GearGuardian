-- ============================================
-- GearGuardian - Version Check Module
-- ============================================

local GG = GearGuardian
if not GG then return end

-- ============================================
-- VERSION CHECKING & UPDATE NOTIFICATIONS
-- ============================================

local ADDON_PREFIX = "GearGuardian"
local versionCheckFrame = CreateFrame("Frame")
local hasShownNotification = false
local newestVersion = GG.version
local newestVersionPlayer = nil

-- Register addon message prefix
C_ChatInfo.RegisterAddonMessagePrefix(ADDON_PREFIX)

-- Parse version string to comparable number
-- "2.7" -> 207, "2.10" -> 210, "3.0" -> 300
local function ParseVersion(versionString)
    if not versionString then return 0 end

    local major, minor = string.match(versionString, "(%d+)%.(%d+)")
    if not major or not minor then return 0 end

    return tonumber(major) * 100 + tonumber(minor)
end

-- Compare two version strings
-- Returns: 1 if v1 > v2, -1 if v1 < v2, 0 if equal
local function CompareVersions(v1, v2)
    local n1 = ParseVersion(v1)
    local n2 = ParseVersion(v2)

    if n1 > n2 then return 1 end
    if n1 < n2 then return -1 end
    return 0
end

-- Broadcast our version to group/raid/guild
local function BroadcastVersion()
    local channel = nil

    if IsInRaid() then
        channel = "RAID"
    elseif IsInGroup() then
        channel = "PARTY"
    elseif IsInGuild() then
        channel = "GUILD"
    end

    if channel then
        C_ChatInfo.SendAddonMessage(ADDON_PREFIX, "VERSION:" .. GG.version, channel)
    end
end

-- Handle incoming version messages
local function OnAddonMessage(prefix, message, channel, sender)
    if prefix ~= ADDON_PREFIX then return end
    if sender == UnitName("player") then return end -- Ignore our own messages

    local versionString = string.match(message, "VERSION:(.+)")
    if not versionString then return end

    -- Compare with our version
    local comparison = CompareVersions(versionString, GG.version)

    if comparison > 0 then
        -- Found newer version
        if CompareVersions(versionString, newestVersion) > 0 then
            newestVersion = versionString
            newestVersionPlayer = sender
        end

        -- Show notification once per session
        if not hasShownNotification then
            hasShownNotification = true

            print("|cffFFFF00==============================================|r")
            print("|cffFFAA00GearGuardian Update Available!|r")
            print("|cffFFFFFFYou have version |cffFF0000" .. GG.version .. "|r")
            print("|cffFFFFFFNewest version: |cff00FF00" .. versionString .. "|r (used by " .. sender .. ")")
            print("|cffFFFFFFDownload the latest version for new features and bug fixes!|r")
            print("|cffFFFF00==============================================|r")
        end
    end
end

-- Event handler
versionCheckFrame:RegisterEvent("CHAT_MSG_ADDON")
versionCheckFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
versionCheckFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

versionCheckFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "CHAT_MSG_ADDON" then
        local prefix, message, channel, sender = ...
        OnAddonMessage(prefix, message, channel, sender)
    elseif event == "GROUP_ROSTER_UPDATE" then
        -- Broadcast when group changes
        C_Timer.After(2, BroadcastVersion)
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Broadcast when entering world
        C_Timer.After(5, BroadcastVersion)
    end
end)

-- Manual version check command
function GG.CheckVersion()
    hasShownNotification = false -- Reset flag to allow re-check
    newestVersion = GG.version
    newestVersionPlayer = nil

    print("|cff00ff00GearGuardian:|r Broadcasting version check...")
    print("|cff00ff00Your version:|r " .. GG.version)

    BroadcastVersion()

    C_Timer.After(3, function()
        if newestVersionPlayer then
            print("|cffFFAA00Newer version found:|r " .. newestVersion .. " (used by " .. newestVersionPlayer .. ")")
        else
            print("|cff00ff00You have the latest version!|r")
        end
    end)
end
