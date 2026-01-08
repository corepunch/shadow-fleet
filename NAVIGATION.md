# Arrow Key Navigation Implementation

This document describes the arrow key navigation feature added to Shadow Fleet.

## Overview

The game now supports arrow key navigation for the main menu, replacing the previous numeric input system. Users can now use ↑↓ arrow keys to navigate through menu options and press Enter to confirm their selection.

## Changes Made

### 1. New Keyboard Input Module (`terminal/input.lua`)

A new module was created to handle raw keyboard input, including arrow keys:

**Features:**
- Reads individual key presses without requiring Enter
- Detects arrow keys (UP, DOWN, LEFT, RIGHT)
- Handles Enter, ESC, and character keys
- Supports both arrow key and numeric (1-8) input for convenience
- Efficiently manages terminal raw mode (set once, not per-key)

**Key Functions:**
- `input.set_raw_mode()` - Set terminal to raw mode (call once before main loop)
- `input.restore_mode()` - Restore terminal to normal mode (call on exit)
- `input.read_key()` - Reads a single keypress and returns a key code (no stty overhead)
- `input.wait_for_enter()` - Waits for Enter key press
- `input.keys` - Table of key constants (UP, DOWN, ENTER, Q, etc.)

**Performance:**
- Terminal raw mode is set **once** before the main loop, not on every keypress
- Eliminates per-key process spawn overhead
- Provides immediate, lag-free input response

### 2. Enhanced UI Widget (`ui/init.lua`)

Added a new widget function for rendering menu items with highlight support:

**New Function:**
- `widgets.menu_item_highlighted(row, number, text, is_selected)` - Renders a menu item with visual highlighting when selected
  - Displays a `>` marker for selected items
  - Uses blue background for highlighted items
  - Uses bright yellow/white text for better visibility

### 3. Updated Main Game Loop (`main.lua`)

Modified the main game loop to support arrow key navigation:

**Changes:**
- Calls `input.set_raw_mode()` once before the main loop starts
- Uses `xpcall` with error handler to ensure `input.restore_mode()` is always called
- Added `selected_index` variable to track current menu selection
- Updated `render_dashboard()` to accept and display the selected menu item
- Modified `sections.quick_actions()` to render items with highlighting
- Replaced `io.read()` with `input.read_key()` for keyboard input
- Added arrow key handling (UP/DOWN to navigate, ENTER to select)
- Maintains backward compatibility with numeric keys (1-8)
- Updated menu header text to indicate arrow key usage
- Temporarily restores normal mode for submenu interactions

### 4. New Test Suite (`tests/test_navigation.lua`)

Added comprehensive tests for the navigation system:

**Tests:**
- Input module loading and function existence
- Key constant definitions
- Menu rendering with different selections
- Highlighted menu item widget functionality

## Usage

### For Players

**Navigation:**
1. Use ↑ (Up Arrow) to move to the previous menu item
2. Use ↓ (Down Arrow) to move to the next menu item
3. Press Enter to select the highlighted option
4. Press 'q' to quit the game
5. (Optional) Still works with numeric keys 1-8 for direct selection

**Visual Feedback:**
- Selected menu items are highlighted with:
  - A `>` marker on the left
  - Blue background
  - Bright yellow/white text

### For Developers

**Using the Input Module:**
```lua
local input = require("terminal.input")

-- Set raw mode ONCE before your main loop
input.set_raw_mode()

-- Use xpcall to ensure terminal is restored on error
local function main_loop()
    while true do
        local key = input.read_key()  -- No overhead, reads immediately
        if key == input.keys.UP then
            -- Handle up arrow
        elseif key == input.keys.DOWN then
            -- Handle down arrow
        elseif key == input.keys.ENTER then
            -- Handle enter
        elseif key == input.keys.Q then
            break
        end
    end
end

local function error_handler(err)
    input.restore_mode()  -- Always restore terminal
    return debug.traceback(err, 2)
end

xpcall(main_loop, error_handler)
input.restore_mode()  -- Restore on normal exit
```

**Using the Highlighted Menu Widget:**
```lua
local widgets = require("ui")

-- Render menu items with item 3 highlighted
for i = 1, 8 do
    widgets.menu_item_highlighted(row, i, "Menu Item " .. i, i == 3)
    row = row + 1
end
```

## Technical Details

### Terminal Raw Mode

The input module uses `stty` to set the terminal to raw mode. **Critical performance improvement:**
- Raw mode is set **once** before the main loop (not per-keypress)
- Eliminates process spawn overhead on every key read
- Provides immediate, lag-free input response
- Uses `xpcall` to ensure terminal is always restored on exit

This allows:
- Reading single characters without waiting for Enter
- Detecting arrow key escape sequences
- Immediate response to user input

**Note:** For submenu interactions that require line-based input, the code temporarily restores normal mode and re-enables raw mode after.

### Arrow Key Detection

Arrow keys send ANSI escape sequences:
- Up: `\27[A`
- Down: `\27[B`
- Right: `\27[C`
- Left: `\27[D`

The input module properly detects these sequences and returns user-friendly key codes.

### Menu Selection Wrapping

The menu selection wraps around:
- Pressing ↑ on the first item moves to the last item
- Pressing ↓ on the last item moves to the first item

This provides a smooth, circular navigation experience.

## Testing

Run all tests including the new navigation tests:
```bash
make test
```

Or run just the navigation tests:
```bash
lua5.3 tests/test_navigation.lua
```

## Future Enhancements

Possible improvements for the navigation system:
- Add support for Page Up/Page Down for faster navigation
- Add support for Home/End keys to jump to first/last item
- Add visual scroll indicators for long menus
- Support horizontal navigation for multi-column menus
- Add keyboard shortcuts (e.g., 'f' for Fleet)
