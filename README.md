# shadow-fleet
A text based strategy game about Russian Shadow Fleet

## Project Structure

The codebase is organized into logical folders following the Model-View-Presenter (MVP) pattern:

- **`game/`** - Model layer: Pure business logic (game state, world data, turn processing)
- **`presenters/`** - Presenter layer: UI interaction and coordination
- **`ui/`** - View layer: Reusable UI widgets and components
- **`display.lua`** - View layer: Screen rendering functions
- **`terminal.lua`** - Terminal I/O abstraction (raw mode, formatted output)
- **`commands.lua`** - Command registry system
- **`keymap.lua`** - Hotkey to command mappings
- **`main.lua`** - Application entry point and game loop

**See [CODE_ORGANIZATION.md](CODE_ORGANIZATION.md) for complete architecture documentation including design patterns, data flow, and inspirations.**

## Components

For detailed architecture documentation, see [CODE_ORGANIZATION.md](CODE_ORGANIZATION.md).

### Game State (`game/`)
Pure business logic with no UI dependencies.

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

**Controls:**
- Use hotkeys to navigate menu options (aligned with Ports of Call):
  - **S** - Stop Action (port operations: repair, refuel, charter, load, unload)
  - **G** - Globe (navigation and route planning)
  - **O** - Office (statistics, news, market info, fleet overview)
  - **B** - Ship Broker (buy and sell ships)
  - **E** - Evade tactics (shadow fleet operations)
  - **T** - end Turn
  - **?** - Help
- Press the corresponding hotkey for submenu options
- Press **X** to go back from a submenu
- Press **Q** to quit

**Run demos:**
```bash
lua5.3 terminal_demo.lua
lua5.3 game_ui_example.lua
```

**Run tests:**
```bash
make test
```

## Features

- **Hotkey Navigation** - Quick BBS Door-style navigation using hotkeys (S/G/O/B/E/T/?) aligned with Ports of Call conventions
- **Simple Interface** - Sequential text output with colored formatting
- **Terminal Framework** - Comprehensive ANSI terminal control
- **Widget System** - Reusable UI components for building interfaces
- **Threat System** - Detailed threat tracking with risk calculation based on multiple threat types
  - 6 threat types: NATO Patrol, Satellite Surveillance, AIS Scrutiny, Coast Guard, Port Inspection, Sanctions Enforcement
  - Risk levels (None/Low/Medium/High) calculated from active threats
  - Ships display both risk level and specific threats for better decision-making
