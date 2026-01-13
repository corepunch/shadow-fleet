# Shadow Fleet - Code Organization and Architecture

## Overview

Shadow Fleet is a text-based strategy game built entirely in Lua 5.3 with no external dependencies. The codebase follows a carefully structured architecture inspired by proven design patterns and classic games, resulting in a maintainable, testable, and extensible system.

This document explains:
- How the code is organized into modules
- The architectural patterns used
- The inspirations behind each design decision
- How data flows through the system

---

## Architectural Inspirations

The Shadow Fleet codebase draws inspiration from multiple sources, combining proven patterns from web frameworks, game design classics, and Lua best practices:

### 1. **Ports of Call** (1986) - Game Design & Navigation
- **Hotkey-based navigation**: Single-character commands for rapid interaction (S/G/O/B/E/T/?)
- **Event-driven action screens**: Ships arriving at ports trigger automatic action screens
- **Ship trading mechanics**: Managing a fleet, plotting routes, buying/selling vessels
- **Port operations**: Repair, refuel, load/unload cargo workflows

**Impact on Shadow Fleet:**
- Menu structure closely mirrors Ports of Call's navigation system
- Action screens appear automatically when ships arrive at destinations
- Ship management and trading mechanics follow similar patterns
- Focus on economic simulation with fleet management

### 2. **Trade Wars 2002** (1984) - BBS Door Interface
- **Sequential text output**: Top-to-bottom rendering without cursor manipulation
- **Minimal screen refreshes**: Write once, read input, move forward
- **Simple line-based input**: Standard `io.read()` for command processing
- **ANSI color coding**: Strategic use of colors for information hierarchy

**Impact on Shadow Fleet:**
- Terminal-based UI with sequential output (no complex cursor positioning)
- BBS Door-style hotkey navigation throughout
- Colored text for visual hierarchy without graphics
- Fast, keyboard-driven interaction

### 3. **CakePHP** - Model-View-Presenter (MVP) Pattern
- **Separation of concerns**: Business logic, presentation, and user interaction isolated
- **Testable model layer**: Pure functions without UI dependencies
- **Presenter coordination**: Handles user interaction and orchestrates model/view
- **View layer passivity**: Views receive data and render, never mutate state

**Impact on Shadow Fleet:**
- `game/` directory contains pure business logic (Model)
- `ui/` and `display.lua` handle rendering (View)
- `presenters/` and `commands_init.lua` manage interaction (Presenter)
- Fully testable without terminal/UI mocking

### 4. **Lua Best Practices** (Kong, Neovim, LuaJIT)
- **Module pattern**: Each file exports a table of functions
- **Local-first**: Use `local` for everything except exports
- **Table.concat for string building**: Efficient string concatenation
- **Assert for validation**: Clean precondition checking
- **LDoc-style documentation**: Structured comments for modules and functions

**Impact on Shadow Fleet:**
- Consistent module export pattern across all files
- Efficient string building in display code
- Clean validation with descriptive error messages
- Well-documented public APIs

---

## Directory Structure

```
shadow-fleet/
├── game/                  # Model Layer - Pure business logic
│   ├── init.lua          # Game state initialization and core functions
│   ├── world.lua         # World data (ports, routes, threats)
│   ├── turn.lua          # Turn processing and time advancement
│   └── routes_model.lua  # Route and cargo business logic
│
├── presenters/            # Presenter Layer - UI interaction & coordination
│   └── routes.lua        # Route/cargo UI workflows
│
├── ui/                    # View Layer - Reusable UI components
│   └── init.lua          # Widgets (tables, separators, formatters)
│
├── tests/                 # Test suite
│   ├── test_routes_model.lua      # Model layer tests (no UI)
│   ├── test_widgets.lua           # Widget rendering tests
│   ├── test_navigation.lua        # Navigation system tests
│   └── ...                        # Other test files
│
├── terminal.lua           # Terminal I/O abstraction
├── display.lua            # View Layer - Screen rendering
├── menu.lua              # Menu generation from keymaps
├── commands.lua          # Command registry system
├── commands_init.lua     # Command registration & presenter coordination
├── keymap.lua            # Hotkey to command mappings
├── command_labels.lua    # Display labels for commands
├── main.lua              # Application entry point & game loop
│
├── Makefile              # Build and test automation
└── .github/
    └── workflows/
        └── ci.yml        # Continuous integration
```

---

## Architectural Layers

The codebase follows the **Model-View-Presenter (MVP)** pattern with clear separation of concerns:

### Model Layer (`game/`)

**Purpose**: Pure business logic with zero UI dependencies

**Characteristics**:
- ✅ No terminal/UI function parameters (no `echo_fn`, `read_char`)
- ✅ Pure functions and state transformations
- ✅ All business rules and calculations
- ✅ Fully testable without mocking

**Modules**:

#### `game/init.lua` - Game State Management
- `gamestate.new()` - Creates fresh game state with initial resources
- `gamestate.get_available_upgrades()` - Calculates available ship upgrades
- `gamestate.apply_upgrade()` - Applies upgrade effects to ships
- Helper functions for stats, descriptions, and formatting

**Example**:
```lua
local gamestate = require("game")
local game = gamestate.new()  -- Fresh game state
local upgrades = gamestate.get_available_upgrades(game, ship)
```

#### `game/world.lua` - World Data and Threat System
- Port definitions (export/import/STS locations)
- Route data with distances and threat information
- Threat type definitions with risk contributions
- `world.calculate_risk_from_threats()` - Risk level calculation
- `world.format_risk_with_threats()` - Display formatting

**Threat System**:
```lua
-- 6 threat types with risk contributions
world.threats = {
    nato_patrol = { name = "NATO Patrol", risk_contribution = 1 },
    satellite = { name = "Satellite Surveillance", risk_contribution = 1 },
    ais_scrutiny = { name = "AIS Scrutiny", risk_contribution = 1 },
    coast_guard = { name = "Coast Guard", risk_contribution = 1 },
    port_inspection = { name = "Port Inspection", risk_contribution = 1 },
    sanctions = { name = "Sanctions Enforcement", risk_contribution = 1 }
}

-- Risk levels: 0 = none, 1-2 = low, 3-4 = medium, 5+ = high
```

#### `game/turn.lua` - Turn Processing Logic
- Ship movement simulation
- Fuel/hull degradation
- Time advancement (days → weeks → years)
- Market price fluctuations
- Heat decay over time

#### `game/routes_model.lua` - Route and Cargo Business Logic
- `routes_model.get_ships_for_loading()` - Filter ships available for cargo
- `routes_model.calculate_cargo_cost()` - Cost calculation
- `routes_model.validate_cargo_load()` - Business rule validation
- `routes_model.load_cargo()` - State mutation for cargo operations
- Pure business logic, no UI concerns

**Example**:
```lua
local routes_model = require("game.routes_model")
local available = routes_model.get_ships_for_loading(game)
local cost = routes_model.calculate_cargo_cost(amount, price_per_barrel)
local valid, err = routes_model.validate_cargo_load(ship, amount, cost, rubles)
if valid then
    routes_model.load_cargo(game, ship, amount, cost)
end
```

### View Layer (`ui/`, `display.lua`)

**Purpose**: Rendering and display logic

**Characteristics**:
- ✅ Receives data and output functions
- ✅ No direct state mutation
- ✅ Renders information only
- ✅ Reusable components

**Modules**:

#### `ui/init.lua` - Reusable UI Widgets
Widget library for building text-based interfaces:
- `widgets.separator()` - Horizontal dividers
- `widgets.title()` - Centered titles
- `widgets.table_generator()` - Formatted data tables
- `widgets.format_number()` - Thousands separator (1,000,000)
- `widgets.format_hull_fuel()` - Ship status display
- `widgets.format_ship_info()` - Compact ship information
- `widgets.format_risk_level()` - Color-coded risk display

**Example**:
```lua
local widgets = require("ui")
widgets.separator(80)
widgets.title("FLEET STATUS", 80)
widgets.table_generator(columns, game.fleet, {
    title = "--- FLEET STATUS ---",
    output_fn = echo_fn
})
```

#### `display.lua` - Screen Rendering
High-level screen rendering functions:
- `display.header()` - Game header and title
- `display.status()` - Money, date, heat meter
- `display.fleet_status()` - Fleet table rendering
- `display.market_snapshot()` - Current prices
- `display.active_events()` - Pending dilemmas

**Example**:
```lua
local display = require("display")
display.header(echo_fn)
display.status(game, echo_fn)
display.fleet_status(game, echo_fn)
```

### Presenter Layer (`presenters/`, `commands_init.lua`)

**Purpose**: User interaction and coordination between Model and View

**Characteristics**:
- ✅ Handles user input/output
- ✅ Delegates to Model for business logic
- ✅ Coordinates between View and Model
- ✅ Contains UI flow control

**Modules**:

#### `presenters/routes.lua` - Route and Cargo UI Workflows
Manages user interaction for route and cargo operations:
- `routes_presenter.plot_route()` - Interactive route plotting
- `routes_presenter.load_cargo()` - Cargo loading workflow
- `routes_presenter.sell_cargo()` - Cargo selling workflow

**Data Flow Example**:
```lua
function routes_presenter.load_cargo(game, echo_fn, read_char, read_line)
    -- 1. Get data from Model
    local available_ships = routes_model.get_ships_for_loading(game)
    
    -- 2. Present to user (View concern)
    echo_fn("Select ship to load:\n\n")
    for i, entry in ipairs(available_ships) do
        echo_fn(string.format("(%d) %s\n", i, entry.ship.name))
    end
    
    -- 3. Get user input
    local choice = read_char()
    local amount = tonumber(read_line())
    
    -- 4. Validate using Model
    local cost = routes_model.calculate_cargo_cost(amount, port.oil_price)
    local valid, err = routes_model.validate_cargo_load(ship, amount, cost, game.rubles)
    
    -- 5. Execute using Model
    if valid then
        routes_model.load_cargo(game, ship, amount, cost)
    else
        echo_fn("Error: " .. err .. "\n")
    end
end
```

#### `commands_init.lua` - Command Registration
Registers all commands and coordinates presenters:
- Maps command IDs to handler functions
- Wires up presenters with dependencies
- Handles context switching
- Manages upgrade and action screen flows

---

## Core System Modules

### Terminal I/O (`terminal.lua`)

**Purpose**: Low-level terminal control abstraction

**Functions**:
- `terminal.set_raw_mode()` - Enable single-character input
- `terminal.restore_normal_mode()` - Return to line-based input
- `terminal.read_char()` - Read single character without Enter
- `terminal.read_line()` - Read full line of input
- `terminal.echo()` - Write formatted output with proper line endings

**Pattern**: Manages raw mode state internally, always restores on cleanup

**Example**:
```lua
local terminal = require("terminal")

-- Read single character (automatically handles raw mode)
local char = terminal.read_char()

-- Always restore normal mode on exit
terminal.restore_normal_mode()
```

### Command System (`commands.lua`, `keymap.lua`)

**Purpose**: Decoupled command registry with rebindable hotkeys

**Architecture**:
1. **Command IDs**: String identifiers (e.g., `"menu.open_fleet"`)
2. **Handlers**: Functions registered to command IDs
3. **Keymaps**: Map hotkeys to command IDs per context
4. **Command Labels**: Display names for echoing user input

**Flow**:
```
User presses 'F'
    ↓
keymap.main["F"] → "menu.open_fleet"
    ↓
commands.run("menu.open_fleet", game, "main")
    ↓
Registered handler executes
    ↓
Returns { change_context = "fleet" }
```

**Example**:
```lua
-- commands.lua
commands.register("menu.open_fleet", function(game, ctx)
    return { change_context = "fleet" }
end)

-- keymap.lua
keymap.main = {
    F = "menu.open_fleet",
    -- ... more mappings
}

-- command_labels.lua
command_labels["menu.open_fleet"] = "FLEET"
```

### Menu System (`menu.lua`)

**Purpose**: Automatic menu generation from keymaps

**Features**:
- Generates formatted menus from keymap definitions
- Sorts commands alphabetically by hotkey
- Supports boxed or simple menu styles
- Automatically includes Help (?) and Quit (Q)

**Example**:
```lua
local menu = require("menu")

-- Print menu from keymap
menu.print_from_keymap("MAIN MENU", keymap.main, echo_fn)

-- Output:
-- --- MAIN MENU ---
-- (B) Ship Broker
-- (E) Evade
-- (G) Globe
-- (O) Office
-- (S) Stop Action
-- (T) End Turn
-- (?) Help
```

---

## Data Flow Through the System

### Complete Request Flow

```
1. User Input
   ↓
2. Main Loop (main.lua)
   ↓
3. Keymap Lookup (keymap.lua)
   ↓
4. Command Execution (commands.lua)
   ↓
5. Presenter Coordination (presenters/routes.lua)
   ↓
6. Model Query (game/routes_model.lua)
   ↓
7. View Rendering (ui/init.lua, display.lua)
   ↓
8. Terminal Output (terminal.lua)
```

### Example: Loading Cargo

**Step by step**:

1. **User Input**: Player presses `L` in action screen
2. **Keymap**: `keymap.port["L"] → "port.load_cargo"`
3. **Command**: `commands.run("port.load_cargo")` executes
4. **Presenter**: `routes_presenter.load_cargo()` takes over
5. **Model Query**: `routes_model.get_ships_for_loading(game)` returns available ships
6. **View**: `echo_fn()` displays ship selection menu
7. **User Input**: Player selects ship and enters amount
8. **Model Validation**: `routes_model.validate_cargo_load()` checks business rules
9. **Model Mutation**: `routes_model.load_cargo()` updates game state
10. **View**: `echo_fn()` displays confirmation message

### Context Switching

The game uses a context system for different screens:
- **main**: Main dashboard
- **broker**: Ship broker menu
- **port**: Stop action menu (port operations)
- **office**: Office menu (statistics and info)
- **globe**: Globe menu (navigation)
- **evade**: Evade tactics menu

**Context Flow**:
```lua
-- Start at main context
current_context = "main"

-- User presses 'B' for broker
command returns { change_context = "broker" }

-- Now in broker context, different keymap active
keymap.broker["V"] = "broker.view_ships"

-- User presses 'X' to go back
command returns { change_context = "main" }
```

---

## Coding Conventions

### Module Pattern

All Lua modules follow this pattern:

```lua
-- Module Name - Brief description
-- Additional context if needed

local module_name = {}

function module_name.public_function(params)
    -- Implementation
end

local function private_function(params)
    -- Internal helper
end

return module_name
```

### File Headers

**Executable files** (main.lua, test files):
```lua
#!/usr/bin/env lua5.3

-- Module Name - Brief description
```

**Module files** (game/init.lua, ui/init.lua):
```lua
-- Module Name - Brief description

local module_name = {}
```

### Variable and Function Naming

- **Functions**: `snake_case` (e.g., `calculate_risk_level`)
- **Variables**: `snake_case` (e.g., `available_ships`)
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `MAX_HEAT`)
- **Module names**: `snake_case` matching file names

### String Building

Use table.concat for multiple string pieces:

```lua
-- Good: Efficient with table.concat
local parts = {}
for i, ship in ipairs(fleet) do
    table.insert(parts, string.format("(%d) %s\n", i, ship.name))
end
echo(table.concat(parts))

-- Avoid: Multiple sequential echo calls
for i, ship in ipairs(fleet) do
    echo(string.format("(%d) %s\n", i, ship.name))
end
```

### Default Parameters

Use `param = param or default` pattern:

```lua
function widgets.separator(width)
    width = width or 120
    -- ...
end
```

### Validation

Use assertions for preconditions:

```lua
function commands.register(id, handler)
    assert(type(id) == "string", "Command ID must be a string")
    assert(type(handler) == "function", "Command handler must be a function")
    registry[id] = handler
end
```

---

## Testing Architecture

### Pure Model Testing

Model layer can be tested without any UI:

```lua
#!/usr/bin/env lua5.3
-- Test Routes Model

local routes_model = require("game.routes_model")
local gamestate = require("game")

local game = gamestate.new()

-- Test pure business logic
local cost = routes_model.calculate_cargo_cost(500, 70)
assert(cost == 35000000, "Cost calculation incorrect")
print("✓ Cost calculation works")

-- Test validation logic
local valid, err = routes_model.validate_cargo_load(ship, 0, cost, game.rubles)
assert(not valid, "Should reject zero amount")
assert(err == "Invalid amount", "Wrong error message")
print("✓ Validation works")
```

No mocking required because the Model has zero UI dependencies.

### Widget Testing

Widget tests verify rendering output:

```lua
#!/usr/bin/env lua5.3
-- Test UI Widgets

local widgets = require("ui")

-- Test number formatting
local formatted = widgets.format_number(1000000)
assert(formatted == "1,000,000", "Number formatting failed")
print("✓ Number formatting works")
```

### Running Tests

```bash
make test              # Run all tests
lua5.3 tests/test_routes_model.lua   # Run specific test
```

---

## Terminal and Color System

### Color Usage Conventions

Colors convey information semantically:

- **Yellow/Bright Yellow**: Prices, currency values
- **Cyan**: Ship names, identifiers
- **Green**: Good status (high hull/fuel, low heat)
- **Yellow**: Warning status (medium levels)
- **Red**: Critical status (low hull/fuel, high heat, danger)
- **White**: Default text

### BBS Door Style Output

The game uses sequential output without cursor repositioning:

**Characteristics**:
- Write from top to bottom only
- No cursor movement after writing
- Use ANSI colors for visual hierarchy
- Clear screen between major screen changes
- Standard line-based input with `io.read()`

**Example**:
```lua
-- Write sequential output
echo("\n")  -- Spacing
echo("--- FLEET STATUS ---\n")
widgets.table_generator(columns, ships, { output_fn = echo })
echo("\nEnter command: ")

-- Read input (line-based, not raw character)
local choice = read_line()
```

---

## Benefits of This Architecture

### 1. Testability
- Model layer fully testable without UI
- No terminal mocking required
- Fast test execution
- Clear test boundaries

### 2. Maintainability
- Clear responsibility boundaries
- Changes to UI don't affect business logic
- Business rules centralized and reusable
- Easy to understand data flow

### 3. Extensibility
- New commands easy to add via registry
- Hotkeys rebindable through keymaps
- New widgets composable from existing ones
- Model functions reusable across presenters

### 4. Simplicity
- Sequential output easier than cursor management
- Standard input handling (no raw mode complexity)
- Minimal external dependencies (pure Lua)
- Clear module boundaries

---

## Migration Path

The codebase has evolved from a monolithic structure to the current MVP architecture:

### Before (Monolithic)
```lua
-- Everything in main.lua
function load_cargo(game)
    -- UI rendering
    print("Select ship:")
    
    -- Business logic
    if ship.status == "Docked" then
        -- State mutation
        ship.cargo = amount
        game.rubles = game.rubles - cost
    end
end
```

### After (MVP Pattern)
```lua
-- Model: game/routes_model.lua
function routes_model.load_cargo(game, ship, amount, cost)
    ship.cargo_amount = amount
    game.rubles = game.rubles - cost
end

-- Presenter: presenters/routes.lua
function routes_presenter.load_cargo(game, echo_fn, read_char, read_line)
    local ships = routes_model.get_ships_for_loading(game)
    echo_fn("Select ship:\n")
    -- ... handle UI flow ...
    routes_model.load_cargo(game, ship, amount, cost)
end
```

**Key improvements**:
- Business logic testable independently
- UI can change without affecting logic
- Model functions reusable
- Clear separation of concerns

---

## Key Design Principles

1. **Separation of Concerns**: Model, View, Presenter kept distinct
2. **Pure Functions**: Model layer has no side effects beyond state mutation
3. **Sequential Output**: No complex cursor management, write top-to-bottom
4. **Hotkey Navigation**: Fast BBS Door-style interaction
5. **No External Dependencies**: Pure Lua standard library only
6. **Testability First**: Architecture enables testing without mocking
7. **Clear Module Boundaries**: Each file has a single, clear responsibility

---

## Summary

Shadow Fleet's architecture combines:
- **Classic game design** (Ports of Call, Trade Wars 2002) for UX
- **Modern web patterns** (MVP from CakePHP) for code organization
- **Lua best practices** (Kong, Neovim) for implementation
- **Pure Lua** (no dependencies) for simplicity and portability

The result is a maintainable, testable, and extensible codebase that's easy to understand and modify while providing a fast, keyboard-driven gaming experience.

**Core Architecture**: Model-View-Presenter
**Core Style**: BBS Door text interface
**Core Language**: Pure Lua 5.3 (no external dependencies)
**Core Inspiration**: Classic games meet modern architecture

---

## Further Reading

- **MVP_ARCHITECTURE.md** - Detailed MVP implementation guide
- **NAVIGATION.md** - BBS Door navigation system details
- **REFACTORING.md** - Code quality improvements and metrics
- **GAME_DESIGN.md** - Game mechanics and design decisions
- **GAMEPLAY.md** - Player guide and feature documentation
