# GearGuardian

**Version 2.8** - Your Ultimate TBC Classic Gear Management Companion

![GearGuardian](screenshot.png)

## Features

### 🌟 Universal GearScore & Item Level Display
- **Hover over ANY player** to see their GearScore and Average Item Level instantly
- No need to open inspect frame - just hover your mouse
- Works everywhere: world, raids, battlegrounds, dungeons
- Color-coded display for easy reading
- Shift+Click to drag and reposition GS/iLevel frames — positions saved between sessions

### 🛡️ Enchant & Gem Monitoring
- Yellow warning icons (⚠️) on items missing enchants or containing empty gem sockets
- Works on **YOUR character AND inspected targets**
- Perfect for raid leaders checking team readiness
- Detects all TBC enchants (Head, Shoulders, Legs, Chest, Weapons, etc.)

### ⭐ Socket Bonus Indicator (NEW in v2.8)
- Warning icon (⚠️) when socket bonus is inactive on items with gem sockets
- Tooltip shows the socket bonus text and which gem colors are missing
- Supports all TBC socket types: red, yellow, blue, meta, and prismatic
- Hybrid gems (orange/purple/green) correctly count toward multiple colors

### 🔧 Temporary Enchant Detection (NEW in v2.8)
- Detects sharpening stones, wizard oil, mana oil on weapons
- Shows remaining charges and expiration time in tooltip
- Warning icon for weapons without temp enchant
- Uses `GetWeaponEnchantInfo()` API

### 🔮 Enchant Suggestions
- Hover over any enchantable item to see spec-appropriate enchant recommendations
- Resto Shaman gets healing enchants, Warrior tank gets defense enchants — smart, not generic
- Shows up to 3 options per slot with source info (reputation/profession requirements)
- Works on Head, Shoulders, Chest, Legs, Back, Weapons, Boots, Bracers, Gloves

### 📊 GearScore System
- Professional GearScore calculation for TBC Classic
- Color-coded tiers: gray/white/green/blue/purple/orange
- Displayed on character frame and inspect frame
- Uses TBC-appropriate formulas (400 points per tier)
- Draggable frames — Shift+Click to reposition, saved between sessions
- Works on both character and inspect frames

### 🔍 Full Inspect Frame Integration
When you inspect another player, you see:
- ✓ Their GearScore and Average Item Level (draggable!)
- ✓ Missing enchants (yellow ⚠️ icons)
- ✓ Empty gem sockets (yellow ⚠️ icons)
- ✓ Socket bonus inactive warnings (yellow ⚠️ icons)
- ✓ Item quality borders on all their gear
- ✓ Item levels on each piece

### ⚔️ Intelligent Gear Comparison
- Automatically detects your specialization
- Custom stat weights for each class/spec
- Color-coded comparison tooltips (green for upgrade, red for downgrade)

### 📤 Export Gear String
- `/gg export` copies a formatted text summary with GearScore, iLvl, and issues
- Perfect for recruitment applications, Discord sharing, or guild requirement checks

### 🗺️ Minimap Button
- Quick access button on your minimap
- Left-click opens config panel, right-click shows quick toggle menu
- Draggable anywhere around the minimap edge

### 🎨 Quality Borders
- Colored glowing borders around equipped items based on quality
- Works on character frame and inspect frame

### 📋 Version Check
- `/gg version` broadcasts to party/raid/guild to check for outdated versions
- Automatic notification when a groupmate is running a newer version

## Installation

1. Download the latest release
2. Extract the `GearGuardian` folder to your `World of Warcraft\_classic_\Interface\AddOns\` directory
3. Restart WoW or type `/reload` in-game

## Usage

### Commands
- `/gg` or `/gg config` — Open configuration panel
- `/gg toggle` — Enable/disable addon
- `/gg reset` — Reset frame positions to defaults
- `/gg export` — Export your gear to text (for sharing)
- `/gg minimap` — Toggle minimap button on/off
- `/gg version` — Check for addon updates
- `/gg showconfig` — Show current feature settings

### Minimap Button
- Left-click: Open config panel
- Right-click: Quick menu with feature toggles
- Drag to reposition around minimap

### Configuration
Open the configuration panel with `/gg` to customize:
- Quality Borders
- Item Level Display
- Gear Comparison
- GearScore & Average iLevel Display
- Enchant Check
- Gem Check
- **Socket Bonus Indicator** (NEW!)
- **Temporary Enchant Check** (NEW!)
- Enchant Suggestions in Tooltips

## Technical Details

### Modular Code Structure
```
GearGuardian/
├── core/
│   ├── init.lua               - Namespace and library initialization
│   ├── helpers.lua            - Helper functions
│   └── config.lua             - Configuration system
├── modules/
│   ├── borders.lua            - Quality borders and slot updates
│   ├── itemlevel.lua          - Item level calculation and display
│   ├── enchants.lua           - Enchant checking and detection
│   ├── gems.lua               - Gem socket detection
│   ├── gearscore.lua          - GearScore calculation
│   ├── comparison.lua         - Stat weights and item comparison
│   ├── socketbonus.lua        - Socket bonus indicator (NEW v2.8)
│   ├── tempenchants.lua       - Temporary enchant detection (NEW v2.8)
│   ├── export.lua             - Gear export to text
│   ├── minimap.lua            - Minimap button
│   ├── metagems.lua           - Meta gem requirement check
│   ├── versioncheck.lua       - Version check via addon messages
│   └── enchantsuggestions.lua - Enchant suggestions in tooltips
├── ui/
│   ├── config-panel.lua       - Configuration GUI
│   └── tooltips.lua           - Tooltip integration
├── Libs/                      - Required libraries
│   ├── LibStub
│   ├── CallbackHandler-1.0
│   ├── LibDetours-1.0
│   └── LibClassicInspector
├── GearGuardian.lua           - Main file with events and slash commands
└── GearGuardian.toc           - TOC file
```

### Dependencies
- LibStub
- CallbackHandler-1.0
- LibDetours-1.0
- LibClassicInspector

All dependencies are included in the addon.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for the full changelog.

### Version 2.8 (2026-06-05)
- **NEW:** Socket Bonus Indicator — warning when socket bonus is inactive
- **NEW:** Temporary Enchant Detection — sharpening stones, wizard oil via GetWeaponEnchantInfo()
- **FIXED:** GetItemInfoFromHyperlink() not existing (Lua error)
- **FIXED:** Config panel referencing non-existent frame names
- **FIXED:** Gem parsing wrong indices (6-9 → 4-7, correct TBC format)
- **FIXED:** Division by zero in tooltip comparison
- **FIXED:** Meta gem warning overwriting slot OnEnter/OnLeave scripts
- **REMOVED:** Reference to non-existent UpdateAllBagSlots()

### Version 2.7 (2026-03-09)
- Added Enchant Suggestions — hover over items to see spec-appropriate enchant recommendations
- Added Version Check system — auto-notifies when a groupmate has a newer version (`/gg version`)
- Enchant Suggestions toggle added to configuration panel

### Version 2.6 (2026-02-26)
- Added Export Gear String (`/gg export`)
- Added Minimap Button — quick access with left/right-click menus
- Added Meta Gem Requirement Check
- Gem Socket Check confirmed functional in TBC

### Version 2.5 (2026-02-11)
- Fixed iLevel frame disappearing or misplaced after drag
- GS and iLevel frames are now fully independent
- Added `/gg reset` command

### Version 2.4 (2026-02-06)
- Added draggable GS & iLevel displays (Shift+Click to drag)
- Positions saved per-frame and persist between sessions

### Version 2.3 (2026-02-03)
- Major performance optimization — intelligent cache system (70-80% faster)
- Item usability validation (class/armor restrictions)

### Version 2.2 (2026-01-29)
- Complete code refactoring into modular structure
- Fixed inspect frame quality borders, warnings, item level, GS

### Version 2.1 (2025-01-28)
- Added LibClassicInspector integration
- Universal GearScore & iLvl tooltips
- Enhanced inspect frame with enchant/gem warnings

### Version 2.0 (2025-01-28)
- Initial release
- Quality borders, item level display
- Spec-based gear comparison
- Enchant and gem checking

## Perfect For

- Raid leaders checking if members are enchanted/gemmed
- Guild officers enforcing gear standards
- Recruiters evaluating applicants' gear quality and GearScore
- PvPers ensuring arena partners are optimized
- Anyone who wants to track their own gear

## Author

Created by **Sluck**

## License

Copyright (c) 2025-2026 Sluck. All Rights Reserved.

This addon and all its contents are protected by copyright law.
You may use this addon for personal use only.
Redistribution, modification, or commercial use is prohibited without explicit permission.

## Support

If you encounter any issues or have suggestions, please open an issue on GitHub:
https://github.com/hrna94/GearGuardian/issues
