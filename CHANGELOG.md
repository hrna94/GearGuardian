# GearGuardian Changelog

## Version 2.5 (2026-02-11)

### Bug Fix: Draggable Frame Position Corruption

**Fixed:**
- Fixed iLevel frame disappearing or appearing at wrong position after drag in v2.4
- Root cause: position was saved relative to GS frame but restored relative to parent frame (coordinate mismatch)
- Both GS and iLevel frames are now fully independent — each saves and restores position relative to its own parent frame
- Both frames can now be dragged separately without affecting each other

**New Command:**
- `/gg reset` — resets GS and iLevel frames to their default positions immediately (no UI reload needed)
- Recommended for users upgrading from v2.4 who have corrupted frame positions

---

## Version 2.4 (2026-02-06)

### New Feature: Draggable GS & iLevel Displays

**Drag and Drop Functionality:**
- GS and iLevel frames can now be repositioned via Shift+Click drag and drop
- Works on both Character frame and Inspect frame
- Position is saved per-frame (charGS, charILevel, inspectGS, inspectILevel)
- Positions are stored in SavedVariables and persist between sessions
- Tooltip shows "Shift+Click to drag" on hover

**Technical Improvements:**
- Frames use relative positioning to parent frame (not absolute screen position)
- Automatically follow parent frame when it moves (e.g., when inspect opens)
- Dynamic frame level adjustment for inspect frames to stay above 3D character model
- Frames remain interactive even when positioned over character models

**Frame Level Optimization:**
- Inspect frames use TOOLTIP strata with dynamic frame level calculation
- Ensures frames are always clickable and draggable regardless of position
- Fixed issue where frames became non-interactive when placed over 3D models

---

## Version 2.3 (2026-02-03)

### Major Performance Optimization Update

**Cache System Implementation:**
- Intelligent cache for item stats parsing (reduces tooltip scans by ~70%)
- Cache for enchant/gem checking (reduces tooltip scans by ~80%)
- Item usability cache for class/armor validation
- Automatic cache invalidation on equipment/talent changes
- 30-second cache duration with smart cleanup

**Optimized Calculations:**
- Combined GearScore + iLevel calculation in single iteration
- Reduced API calls by ~50% (from 35 to 17 per calculation)
- Extended spec cache from 1s to 300s (5 minutes)
- Added PLAYER_TALENT_UPDATE event for spec cache invalidation
- Removed duplicate GetItemInfo calls in borders.lua

**Timer Optimization:**
- Intelligent debouncing pattern for inspect updates
- Reduced from 5-7 overlapping timers to single smart timer
- Eliminated redundant updates (from 8-10 to 1-2 per inspect)
- Removed unnecessary 2-second delay on frame close
- ~85% reduction in inspect flow operations

**New Features:**
- Item usability validation (class restrictions + armor type)
- Tooltip shows "Not usable by your class" for invalid items
- Prevents misleading upgrade indicators for unusable gear
- Validates Plate/Mail/Leather/Cloth restrictions by class

**UI Improvements:**
- Repositioned GS/iLvl displays to bottom-right corner
- Separated into vertical frames for cleaner layout
- Reduced frame size (50x14) and font size for compact design
- No gap between GS and iLvl frames

**Overall Performance:**
- ~60-70% faster in typical usage
- ~85% faster inspect flow
- ~75% faster tooltip hover
- Memory impact: +2-3 KB (negligible)

---

## Version 2.2 (2026-01-29)

### Major Code Refactoring

**Complete Code Restructuring:**
- Split monolithic 2500+ line file into professional modular structure
- Organized into `core/`, `modules/`, and `ui/` directories
- Improved code organization, readability, and maintainability
- Implemented professional namespace pattern (`GG.FunctionName`)
- Each module has clear, single responsibility

**New File Structure:**
```
core/
  ├── init.lua          - Namespace and library initialization
  ├── helpers.lua       - Helper functions (GetItemLevel, LibClassicInspector)
  └── config.lua        - Configuration system

modules/
  ├── enchants.lua      - Enchant and gem checking
  ├── gearscore.lua     - GearScore calculation
  ├── itemlevel.lua     - Item level calculation and display
  ├── comparison.lua    - Stat weights and item comparison
  └── borders.lua       - Quality borders and slot updates

ui/
  ├── config-panel.lua  - Configuration GUI
  └── tooltips.lua      - Tooltip integration

GearGuardian.lua        - Main file with events and slash commands
```

### Bug Fixes
- Fixed inspect frame not showing quality borders on target's items
- Fixed missing warning icons (⚠️) for enchants/gems on inspected players
- Fixed item level display not appearing on inspected player's items
- Fixed GearScore and average iLevel not displaying on inspect frame
- Fixed missing function exports causing Lua errors on load
- Fixed spec check interval initialization errors
- Fixed GetItemLevel function not being accessible globally

### Technical Improvements
- Better error handling for item data not yet cached
- Proper initialization sequence for inspect frame
- Fixed character frame hooks for player slots
- Added safety checks for nil values in comparisons
- Improved code loading efficiency through modular structure
- Better separation of concerns for easier debugging
- All version 2.1 features preserved and working correctly

---

## Version 2.1 (2025-01-28)

### Major Update: LibClassicInspector Integration & GearScore

**Revolutionary Features:**
- **Universal GearScore & iLvl Display**: Hover over ANY player to see their stats!
  - No need to open inspect frame - just hover your mouse
  - Works everywhere: world, raids, battlegrounds, anywhere!
  - GearScore and Average iLvl appear instantly in tooltips
  - Color-coded based on quality tiers (gray/white/green/blue/purple/orange)
  - Uses TBC-appropriate calculation formulas (400 points per tier)

**LibClassicInspector Integration:**
- Integrated advanced inspection library for reliable player data
- Automatic data caching for instant, responsive tooltips
- Smart inspect requests when data isn't available
- GUID-based lookups for better performance and reliability
- Proper library initialization and callbacks

**Enhanced Inspect Frame:**
- Shows warning icons on inspected players' missing enchants
- Visual indicators for empty gem sockets on inspected targets
- Full LibClassicInspector integration for reliable data
- Works seamlessly with existing enchant/gem checking

**GearScore System:**
- Professional GearScore calculation and display
- Displayed on character frame and inspect frame
- Proper item level scaling for TBC (handles items from level 1-164)
- Slot-specific modifiers (2H weapons = 2.0x, trinkets = 0.5625x, etc.)
- Quality scaling (Legendary, Epic, Rare, Uncommon)
- Formula adjustments for items above/below level 120

**Visual Improvements:**
- Added addon logo (displays in addon list)
- Warning icons changed from red X to yellow triangle with exclamation mark
- Better icon positioning (top-left corner of items)
- Optimized icon size (16x16) for better visibility
- GearScore + iLvl display centered on character/inspect frames

**Configuration Panel Overhaul:**
- Professional new UI design with organized sections
- Scrollable content area for better layout
- Categorized features:
  - Visual Features (Quality Borders, Item Level, GearScore)
  - Inspection & Warnings (Enchant Check)
  - Tooltips & Comparison
  - Advanced Features (Coming Soon items)
- Each feature has clear name and description
- Removed corner decorations for cleaner look
- Mouse wheel scrolling support
- Real-time setting changes (no UI reload needed)

### Bug Fixes
- Fixed enchant detection for inspected players (now uses direct API with enchant data)
- Fixed tooltip warnings to correctly identify player vs. inspected items
- Removed bag highlight debug commands (feature not yet implemented)

### Technical Improvements
- All functions now use GUID-based lookups instead of unit names
- Direct GetInventoryItemLink() API for enchant detection on inspect
- Multi-method unit detection for reliable inspect data
- Proper itemLink parsing that preserves empty fields
- Better error handling and fallback mechanisms

---

## Version 2.0 (2025-01-28)

### Initial Release
- Quality borders around equipped items
- Item level display on gear
- Spec-based gear comparison
- Average item level calculation and display
- Enchant checking with visual warnings
- Gem socket monitoring
- Full inspect frame integration
- Configurable features via `/gg` command
- Support for all TBC enchants (Head, Shoulders, Legs, Chest, Cloak, Weapons, etc.)
