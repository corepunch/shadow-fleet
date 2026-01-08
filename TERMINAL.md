# Terminal Framework for Shadow Fleet

A comprehensive Lua module providing cursor control, color management, and screen manipulation functions for text-based terminal games.

## Features

- ✓ **Screen Clearing**: Multiple options for clearing screen, lines, or portions
- ✓ **Cursor Positioning**: Move cursor anywhere on screen with precise control
- ✓ **Color Support**: 32 predefined colors (16 foreground + 16 background)
- ✓ **Color Schemes**: Pre-configured color combinations for common UI elements
- ✓ **Text Styles**: Bold, italic, underline, and more
- ✓ **Drawing Utilities**: Box drawing and fill functions
- ✓ **Module Design**: All functions returned as a table for easy `require()`

## Installation

Simply place `terminal.lua` in your project directory and require it:

```lua
local terminal = require("terminal")
```

## Quick Start

```lua
local terminal = require("terminal")

-- Initialize terminal for game mode
terminal.init()

-- Clear screen and write colored text
terminal.clear()
terminal.write_at(1, 1, "Shadow Fleet", "fg_bright_yellow", "bg_blue")
terminal.write_at(3, 1, "Status: Active", "fg_green")

-- Draw a UI box
terminal.draw_box(5, 5, 40, 10, "fg_cyan", "bg_black")

-- When done, cleanup
terminal.cleanup()
```

## API Reference

### Screen Operations

- `terminal.clear()` - Clear entire screen
- `terminal.clear_to_bottom()` - Clear from cursor to end of screen
- `terminal.clear_to_top()` - Clear from cursor to start of screen
- `terminal.clear_line()` - Clear current line
- `terminal.init()` - Initialize terminal (clear, hide cursor, reset colors)
- `terminal.cleanup()` - Restore normal terminal mode

### Cursor Movement

- `terminal.move_to(row, col)` - Move cursor to specific position (1-indexed)
- `terminal.home()` - Move cursor to home position (1,1)
- `terminal.move_up(n)` - Move cursor up n lines
- `terminal.move_down(n)` - Move cursor down n lines
- `terminal.move_forward(n)` - Move cursor forward n columns
- `terminal.move_backward(n)` - Move cursor backward n columns
- `terminal.save_cursor()` - Save current cursor position
- `terminal.restore_cursor()` - Restore saved cursor position
- `terminal.hide_cursor()` - Hide cursor
- `terminal.show_cursor()` - Show cursor

### Color Functions

- `terminal.set_fg(color)` - Set foreground color
- `terminal.set_bg(color)` - Set background color
- `terminal.set_colors(fg, bg)` - Set both foreground and background
- `terminal.reset()` - Reset all colors and styles
- `terminal.apply_scheme(scheme_name)` - Apply a predefined color scheme

### Writing Text

- `terminal.write_at(row, col, text, fg, bg)` - Write text at position with optional colors
- `terminal.write_colored(text, fg, bg)` - Write colored text at current position

### Drawing Functions

- `terminal.draw_box(row, col, width, height, fg, bg)` - Draw a box with borders
- `terminal.fill_box(row, col, width, height, char, fg, bg)` - Draw a filled box

### Utility Functions

- `terminal.get_size()` - Get terminal dimensions (returns width, height)
- `terminal.enable_alt_screen()` - Enable alternate screen buffer
- `terminal.disable_alt_screen()` - Disable alternate screen buffer
- `terminal.set_style(style)` - Set text style (bold, underline, etc.)

## Predefined Colors

### Foreground Colors (fg_*)
- Standard: `fg_black`, `fg_red`, `fg_green`, `fg_yellow`, `fg_blue`, `fg_magenta`, `fg_cyan`, `fg_white`
- Bright: `fg_bright_black`, `fg_bright_red`, `fg_bright_green`, `fg_bright_yellow`, `fg_bright_blue`, `fg_bright_magenta`, `fg_bright_cyan`, `fg_bright_white`

### Background Colors (bg_*)
- Standard: `bg_black`, `bg_red`, `bg_green`, `bg_yellow`, `bg_blue`, `bg_magenta`, `bg_cyan`, `bg_white`
- Bright: `bg_bright_black`, `bg_bright_red`, `bg_bright_green`, `bg_bright_yellow`, `bg_bright_blue`, `bg_bright_magenta`, `bg_bright_cyan`, `bg_bright_white`

## Color Schemes

Pre-configured color combinations accessible via `terminal.schemes`:

- `default` - White on black
- `title` - Bright yellow on blue
- `error` - Bright red on black
- `success` - Bright green on black
- `warning` - Bright yellow on black
- `info` - Bright cyan on black
- `highlight` - Black on white
- `menu` - White on blue
- `menu_selected` - Yellow on blue
- `ocean` - Bright white on blue
- `danger` - White on red

Example:
```lua
terminal.apply_scheme("title")
io.write("This is a title")
terminal.reset()
```

## Text Styles

Available in `terminal.styles`:
- `reset` - Reset all styles
- `bold` - Bold text
- `dim` - Dimmed text
- `italic` - Italic text
- `underline` - Underlined text
- `blink` - Blinking text
- `reverse` - Reverse video
- `hidden` - Hidden text
- `strikethrough` - Strikethrough text

## Example Usage

### Basic Game UI
```lua
local terminal = require("terminal")

terminal.init()

-- Title bar
terminal.fill_box(1, 1, 80, 1, " ", "fg_bright_yellow", "bg_blue")
terminal.write_at(1, 30, "SHADOW FLEET", "fg_bright_yellow", "bg_blue")

-- Game area
terminal.draw_box(3, 2, 78, 18, "fg_cyan", "bg_black")

-- Ships
terminal.write_at(8, 10, "⚓ Tanker 'Aurora'", "fg_green")
terminal.write_at(10, 20, "⚓ Cargo Ship 'Neva'", "fg_green")

-- Status bar
terminal.fill_box(21, 1, 80, 1, " ", "fg_white", "bg_blue")
terminal.write_at(21, 2, "Status: Active", "fg_white", "bg_blue")

-- Cleanup when done
terminal.cleanup()
```

### Menu System
```lua
local terminal = require("terminal")

local function draw_menu(selected)
    terminal.clear()
    terminal.write_at(1, 1, "Main Menu", "fg_bright_white", "bg_blue")
    
    local options = {"Start Game", "Load Game", "Options", "Quit"}
    for i, option in ipairs(options) do
        if i == selected then
            terminal.write_at(i + 2, 5, option, "fg_yellow", "bg_blue")
        else
            terminal.write_at(i + 2, 5, option, "fg_white", "bg_black")
        end
    end
end
```

## Running the Demo

A comprehensive demo is provided in `terminal_demo.lua`:

```bash
lua5.3 terminal_demo.lua
```

Or make it executable and run:
```bash
chmod +x terminal_demo.lua
./terminal_demo.lua
```

## Testing

Run the test suite to verify functionality:

```bash
lua5.3 test_terminal.lua
```

## Compatibility

- Requires Lua 5.1 or higher
- Works on Unix/Linux/macOS terminals that support ANSI escape codes
- May have limited functionality on Windows Command Prompt (use Windows Terminal or similar)

## License

Part of the Shadow Fleet project. See LICENSE file for details.
