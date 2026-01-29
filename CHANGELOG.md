# GearGuardian Changelog

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
