# shadow-fleet
A text based strategy game about Russian Shadow Fleet

## Project Structure

The codebase is organized into logical folders:

- **`terminal/`** - Terminal framework for cursor control and color management
- **`ui/`** - UI widgets and components for building text-based interfaces  
- **`game/`** - Game state management and logic
- **`main.lua`** - Main game entry point
- **Demo files** - `terminal_demo.lua`, `game_ui_example.lua` for examples

## Components

### Terminal Framework (`terminal/`)
A comprehensive cursor control and color management library for building text-based UIs.

Features:
- Screen clearing and cursor positioning
- 32 predefined colors (16 foreground + 16 background)
- Predefined color schemes for common UI elements
- Box drawing and text styling
- Full ANSI escape code support

See [TERMINAL.md](TERMINAL.md) for complete documentation.

**Quick Start:**
```lua
local terminal = require("terminal")
terminal.init()
terminal.write_at(1, 1, "Shadow Fleet", "fg_bright_yellow", "bg_blue")
terminal.cleanup()
```

### UI Widgets (`ui/`)
Reusable UI components for terminal-based interfaces.

**Quick Start:**
```lua
local widgets = require("ui")
widgets.separator(1, 80)
widgets.title(2, "MY TITLE", 80)
```

### Game State (`game/`)
Central game state management.

**Quick Start:**
```lua
local gamestate = require("game")
local game = gamestate.new()
```

## Running the Game

**Run the main game:**
```bash
lua5.3 main.lua
```

**Run demos:**
```bash
lua5.3 terminal_demo.lua
lua5.3 game_ui_example.lua
```

**Run tests:**
```bash
make test
```
