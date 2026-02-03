--[[
    GearGuardian - Core Initialization
    Author: Sluck
    Version: 2.3
]]--

-- Create addon namespace
local addonName = "GearGuardian"
GearGuardian = GearGuardian or {}
local GG = GearGuardian

-- ============================================
-- LIBRARY INITIALIZATION
-- ============================================

assert(LibStub, "GearGuardian requires LibStub")
assert(LibStub:GetLibrary("LibClassicInspector", true), "GearGuardian requires LibClassicInspector")

GG.CI = LibStub("LibClassicInspector")

-- ============================================
-- SHARED VARIABLES
-- ============================================

GG.addonName = addonName
GG.version = "2.3"
GG.inspectedUnit = nil  -- Track current inspected unit

-- Spec check interval (in seconds)
GG.SPEC_CHECK_INTERVAL = 1.0  -- Check spec at most once per second
GG.lastSpecCheck = 0
GG.cachedClass = nil
GG.cachedSpec = nil
