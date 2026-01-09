# BBS Door Navigation Implementation

This document describes the BBS Door-style hotkey navigation feature in Shadow Fleet.

## Overview

The game now uses a simple BBS Door-style interface with hotkey navigation, replacing the previous arrow key navigation system. Users can use single-character hotkeys to navigate through menu options without needing arrow keys or Enter confirmation.

## Changes Made

### 1. Simplified Main Loop (`main.lua`)

The main game loop has been completely refactored for BBS Door-style interaction:

**Features:**
- Simple sequential text output using `io.write()` at cursor position
- Hotkey-based navigation (single character input)
- No cursor positioning or screen updates for menu selection
- Clean, readable output format
- Standard line-based input with `io.read()`

**Key Changes:**
- Removed arrow key detection and raw mode terminal handling
- Removed menu highlighting and visual selection feedback
- Simplified to use regular `io.read()` for input
- Uses color-coded text output with ANSI escape sequences
- Menu options displayed with hotkey indicators: `(F) Fleet`

### 2. Removed Terminal Input Module (`terminal/input.lua`)

The specialized input module for arrow key detection has been removed:

**Removed Features:**
- Raw terminal mode handling
- Arrow key escape sequence detection
- `read_key()` function for character-by-character input
- `set_raw_mode()` and `restore_mode()` functions

**Reason:** No longer needed with simple hotkey navigation using standard `io.read()`

### 3. Simplified UI Widgets (`ui/init.lua`)

Removed the highlighted menu item widget:

**Removed Function:**
- `widgets.menu_item_highlighted()` - No longer needed without menu highlighting

**Retained Functions:**
- All other widgets remain functional (separator, title, section headers, etc.)

### 4. Updated Test Suite (`tests/test_navigation.lua`)

Updated tests to reflect the new navigation system:

**Tests:**
- Widgets module loading and function existence
- Basic menu item rendering
- BBS Door navigation system validation

## Usage

### For Players

**Main Menu Navigation:**
1. Type **F** for Fleet management
2. Type **R** for Route planning
3. Type **T** for Trade operations
4. Type **E** for Evade tactics
5. Type **V** for eVents
6. Type **M** for Market operations
7. Type **S** for Status information
8. Type **?** for Help
9. Type **Q** to quit the game

**Submenu Navigation:**
- Use the hotkey shown in parentheses for each submenu option
- Type **B** to go back to the main menu
- Type **Q** to return to the main menu

**Visual Feedback:**
- Menu options are displayed with hotkey indicators: `(F) Fleet`
- Colored text highlights important information
- Sequential output makes it easy to read the current state

### For Developers

**Using the Simplified Navigation:**
```lua
local term = require("terminal")

-- Initialize terminal
term.init()

-- Write colored text at cursor position
term.set_fg("fg_bright_yellow")
io.write("Enter command: ")
term.reset()

-- Read user input (standard line-based input)
local choice = io.read()
if choice then
    choice = choice:upper()
    -- Process choice...
end

-- Cleanup
term.cleanup()
```

**Menu Structure:**
```lua
local menu_structure = {
    F = {
        name = "Fleet",
        submenus = {
            V = "View",
            Y = "Buy",
            U = "Upgrade",
            S = "Scrap"
        }
    },
    -- ... more menu items
}
```

## Technical Details

### BBS Door Style

The BBS Door approach is characterized by:
- Sequential text output (top to bottom)
- Simple hotkey navigation (single character commands)
- No cursor positioning for menu updates
- Clean, readable interface with colored text
- Standard line-based input using `io.read()`

This provides:
- Simpler code that's easier to maintain
- Better compatibility with different terminal types
- Familiar interface for users of classic BBS systems
- No need for complex input handling or screen refreshes

### Color Output

The game uses ANSI escape sequences for colored text output:
- Important values highlighted in appropriate colors
- Status information color-coded by severity
- Menu options clearly distinguished

### Input Handling

Input is handled using standard Lua `io.read()`:
- Reads a complete line of input
- Converts to uppercase for case-insensitive commands
- Validates against available menu options
- Handles EOF gracefully

## Testing

Run all tests including the new navigation tests:
```bash
make test
```

Or run just the navigation tests:
```bash
lua5.3 tests/test_navigation.lua
```

## Benefits of BBS Door Style

**Simplicity:**
- Less code to maintain
- Easier to understand and modify
- No complex terminal mode handling

**Compatibility:**
- Works with any terminal that supports basic input/output
- No special terminal capabilities required beyond ANSI colors
- More robust across different platforms

**Usability:**
- Fast navigation with single-key commands
- Clear visual layout with sequential output
- Familiar to users of classic BBS systems
- Easy to add new menu options

## Migration from Arrow Key Navigation

**What Changed:**
- Replaced arrow key navigation with hotkey commands
- Removed menu highlighting and selection visual feedback
- Simplified from cursor-based updates to sequential output
- Changed from raw terminal mode to standard line-based input

**What Stayed the Same:**
- Game state management
- Fleet, market, and event information display
- Color-coded output for important information
- Overall game structure and features
