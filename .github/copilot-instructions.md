# Shadow Fleet - GitHub Copilot Instructions

## Project Overview

Shadow Fleet is a text-based strategy game about managing a shadow fleet of oil tankers evading sanctions. The game uses a BBS Door-style interface with hotkey navigation and is written entirely in Lua 5.3.

**Theme**: Russian Shadow Fleet operations managing oil tankers under sanctions
**Style**: Terminal-based, sequential text output with ANSI color support
**Interface**: BBS Door-style hotkey navigation (single-character commands)

## Technology Stack

- **Language**: Lua 5.3
- **Interface**: Terminal-based with ANSI escape sequences
- **No external dependencies**: Pure Lua standard library
- **Platform**: Unix-like systems (uses `stty` for terminal control)

## Project Structure

```
shadow-fleet/
├── game/           # Game state management and logic
│   └── init.lua    # Central game state module
├── ui/             # UI widgets and components
│   └── init.lua    # Reusable text-based UI widgets
├── tests/          # Test files
│   ├── test_widgets.lua     # UI widget tests
│   └── test_navigation.lua  # Navigation tests
├── main.lua        # Main game entry point
├── Makefile        # Build and test commands
└── .github/
    └── workflows/
        └── ci.yml  # CI configuration
```

### Module Organization

- **`game/init.lua`** - Exports a `gamestate` module with game state initialization and helper functions
- **`ui/init.lua`** - Exports a `widgets` module with reusable UI components
- **`main.lua`** - Main game loop with BBS Door-style hotkey navigation

## Coding Conventions

### File Headers

Executable Lua files (main.lua, test files):
```lua
#!/usr/bin/env lua5.3

-- Module Name - Brief description
-- Additional context if needed
```

Module files (game/init.lua, ui/init.lua):
```lua
-- Module Name - Brief description
-- Additional context if needed

local module_name = {}
```

### Comments

- Use `--` for single-line comments
- Add inline comments to explain complex logic or important context
- Section headers use `-- Section Name` format
- Prefer descriptive variable names over excessive comments

### Code Style

- **Indentation**: 4 spaces (no tabs)
- **Local variables**: Use `local` for all variables and functions unless they need to be exported
- **Module pattern**: Return a table of functions from module files
- **Function naming**: Use `snake_case` for all functions and variables
- **Constants**: Use uppercase with underscores (e.g., `MAX_HEAT`)
- **String quotes**: Use double quotes for strings
- **Default parameters**: Use `param = param or default_value` pattern

### Module Export Pattern

```lua
local module_name = {}

function module_name.function_name(params)
    -- implementation
end

return module_name
```

### UI Widget Pattern

All widgets in `ui/init.lua`:
- Accept parameters with sensible defaults
- Use `io.write()` for output (not `print()`)
- Call `io.flush()` after writing
- Default width is 120 characters where applicable

Example:
```lua
function widgets.widget_name(param, width)
    width = width or 120
    io.write(formatted_output)
    io.flush()
end
```

## Testing

### Test Structure

- Tests are in the `tests/` directory
- Test files are named `test_*.lua`
- Tests use simple assertions with descriptive error messages
- Use `assert(condition, "Error message")` for validation
- Print progress with `✓` checkmarks for passed tests

### Running Tests

```bash
make test           # Run all tests
lua5.3 tests/test_widgets.lua     # Run specific test
```

### Test Pattern

```lua
#!/usr/bin/env lua5.3
-- Test description

local module = require("module_name")

print("Testing Module Name...")

-- Test 1: Description
assert(type(module) == "table", "module should be a table")
print("✓ Test 1: Description")

-- More tests...

print("All tests passed! ✓")
```

## Game Architecture

### Game State

The game state is managed by the `gamestate` module:
- **Immutable initialization**: `gamestate.new()` returns a fresh game state table
- **State structure**: Contains player resources, fleet data, market info, and events
- **Helper functions**: Provide calculated values (stats, descriptions, colors)

### UI Rendering

- **Sequential output**: Write from top to bottom, no cursor repositioning
- **Color coding**: Use ANSI escape sequences for visual hierarchy
- **Width standard**: Default to 120 characters for consistency
- **Separator pattern**: Use `widgets.separator()` to divide sections

### Navigation System

- **BBS Door style**: Single-character hotkey commands (F/R/T/E/V/M/S/?/Q/B)
- **Input handling**: Use `io.read()` for line-based input, convert to uppercase
- **Raw mode**: Use `stty raw -echo` for single-character input when needed
- **EOF handling**: Always check for `nil` return from `io.read()`

## Color Conventions

Colors are referenced as strings (e.g., `"fg_bright_yellow"`):
- **Yellow/Bright Yellow**: Prices, currency values
- **Cyan**: Ship names, identifiers
- **Green**: Good status (high hull/fuel percentages, low heat)
- **Yellow**: Warning status (medium hull/fuel, medium heat)
- **Red**: Critical status (low hull/fuel, high heat, danger)
- **White**: Default text

## Important Patterns

### Terminal Control

```lua
-- Raw mode for single-character input
os.execute("stty raw -echo 2>/dev/null")
local char = io.read(1)
os.execute("stty sane 2>/dev/null")  -- Always restore!

-- Line endings in raw mode
text:gsub("\r?\n", "\r\n")  -- Convert \n to \r\n
```

### Number Formatting

Use `widgets.format_number()` for displaying large numbers with thousands separators:
```lua
widgets.format_number(1000000)  -- Returns "1,000,000"
```

### Menu Structure

Main menu hotkeys:
- **F** - Fleet (View/Buy/Upgrade/Scrap)
- **R** - Route (Plot Ghost Path/Load Cargo)
- **T** - Trade (Sell/Launder Oil)
- **E** - Evade (Spoof AIS/Flag Swap/Bribe)
- **V** - Events (Resolve Pending Dilemmas)
- **M** - Market (Check Prices/Speculate/Auction Dive)
- **S** - Status (Quick Recap/News Refresh)
- **?** - Help (Command Details)
- **Q** - Quit

Submenu common hotkeys:
- **B** - Back to main menu
- Various single-letter commands for submenu actions

Display format: `(F) Fleet` - hotkey in parentheses followed by menu name

## Build and Run Commands

```bash
# Run the game
lua5.3 main.lua

# Run tests
make test

# Clean generated files
make clean
```

## CI/CD

- **GitHub Actions**: `.github/workflows/ci.yml`
- **Triggers**: Pull requests and pushes to main/master
- **Jobs**: Install Lua 5.3 and run `make test`

## Key Design Principles

1. **Simplicity**: Keep code simple and maintainable, avoid over-engineering
2. **Sequential output**: No complex cursor management, just write top-to-bottom
3. **Pure Lua**: No external dependencies, use standard library only
4. **Clear separation**: Game state, UI widgets, and main loop are separate concerns
5. **Terminal compatibility**: Works with any terminal supporting basic ANSI colors
6. **Testability**: All modules can be loaded and tested independently

## Common Tasks

### Adding a New Widget

1. Add function to `ui/init.lua` following the widget pattern
2. Add to `required_functions` list in `tests/test_widgets.lua`
3. Test manually and with automated tests

### Adding Game State Data

1. Add to the table returned by `gamestate.new()`
2. Add helper functions if calculations are needed
3. Consider color coding for UI display

### Adding a Menu Option

1. Choose an available hotkey letter
2. Add to main menu display in `main.lua`
3. Add case handler in input processing
4. Create submenu structure if needed

## Notes for AI Assistants

- This is a **text-based game**, not a graphical application
- Focus on **terminal output** and **keyboard input**
- Maintain the **BBS Door aesthetic** - simple, sequential, hotkey-driven
- **No external libraries** - keep it pure Lua
- **Test changes** with `make test` before finalizing
- The game theme is serious (sanctions evasion) but code should remain clean and professional
