# Shadow Fleet - MVP Architecture

## Overview

The codebase follows the **Model-View-Presenter (MVP)** pattern to separate concerns and improve testability.

## Architecture Layers

### Model Layer (Pure Business Logic)

**Location**: `game/` directory

**Modules**:
- `game/init.lua` - Game state definition and management
- `game/world.lua` - Port and route data, threat definitions and risk calculations
- `game/turn.lua` - Turn processing logic
- `game/routes_model.lua` - Route and cargo business logic

**Characteristics**:
- ✅ No UI dependencies (no `echo_fn`, `read_char`, etc.)
- ✅ Pure functions and state transformations
- ✅ Fully testable without terminal/UI
- ✅ Contains all business rules and calculations

**Threat System** (`game/world.lua`):
The threat system provides detailed risk assessment:
```lua
-- Threat definitions with risk contributions
world.threats = {
    nato_patrol = {
        name = "NATO Patrol",
        risk_contribution = 1,
        description = "Active NATO naval patrols in area"
    },
    -- ... more threats
}

-- Calculate risk level from active threats
function world.calculate_risk_from_threats(threats)
    -- Sums risk contributions and maps to risk levels
    -- 0 = none, 1-2 = low, 3-4 = medium, 5+ = high
end

-- Format threats for display
function world.format_risk_with_threats(risk_id, threats)
    -- Shows risk level with specific threat names
end
```

**Example** (`game/routes_model.lua`):
```lua
-- Pure business logic - no UI
function routes_model.calculate_cargo_cost(amount, price_per_barrel)
    return amount * 1000 * price_per_barrel
end

function routes_model.validate_cargo_load(ship, amount, cost, rubles)
    if not amount or amount <= 0 then
        return false, "Invalid amount"
    end
    -- More validation logic...
    return true, nil
end
```

### View Layer (Display/Rendering)

**Location**: `display.lua`, `ui/` directory

**Modules**:
- `ui/init.lua` - Reusable UI widgets
- `display.lua` - Dashboard and screen rendering

**Characteristics**:
- ✅ Receives data and output functions
- ✅ No direct state mutation
- ✅ Renders information only

**Example** (`display.lua`):
```lua
function display.fleet_status(game, echo_fn)
    -- Receives game state and renders it
    -- Does not modify game state
    widgets.table_generator(columns, game.fleet, {
        title = "--- FLEET STATUS ---",
        output_fn = echo_fn
    })
end
```

### Presenter Layer (UI Interaction & Coordination)

**Location**: `presenters/` directory, `commands_init.lua`

**Modules**:
- `presenters/routes.lua` - **NEW** Route and cargo UI interaction
- `commands_init.lua` - Command registration and coordination

**Characteristics**:
- ✅ Handles user input/output
- ✅ Delegates to Model for business logic
- ✅ Coordinates between View and Model
- ✅ Contains UI flow control

**Example** (`presenters/routes.lua`):
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
    
    -- 4. Validate using Model
    local valid, err = routes_model.validate_cargo_load(...)
    
    -- 5. Execute using Model
    if valid then
        routes_model.load_cargo(game, ship, amount, cost)
    end
end
```

## Data Flow

```
User Input
    ↓
Presenter (presenters/routes.lua)
    ↓ (queries)
Model (game/routes_model.lua)
    ↓ (returns data)
Presenter
    ↓ (formats for display)
View (ui/init.lua, display.lua)
    ↓
Terminal Output
```

## Benefits of MVP Pattern

### 1. **Testability**
- Model layer can be tested without UI
- See `tests/test_routes_model.lua` for pure logic tests
- No need for terminal mocking

### 2. **Separation of Concerns**
- Business logic isolated in Model
- UI interaction isolated in Presenter
- Display logic isolated in View

### 3. **Maintainability**
- Changes to UI don't affect business logic
- Business rules centralized and reusable
- Clear responsibility boundaries

### 4. **Reusability**
- Model functions can be used by multiple presenters
- Different UIs can use same Model layer
- Business logic is platform-independent

## Migration from Old Pattern

### Before (Mixed Concerns)

```lua
-- game/routes.lua (OLD - DEPRECATED)
function routes.load_cargo(game, echo_fn, read_char, read_line)
    -- UI rendering mixed with business logic
    echo_fn("Select ship:\n")
    local ships = {}
    for i, ship in ipairs(game.fleet) do
        if ship.status == "Docked" then  -- Business logic
            table.insert(ships, ship)
            echo_fn(string.format("(%d) %s\n", i, ship.name))  -- UI
        end
    end
    
    local cost = amount * 1000 * port.oil_price  -- Business logic
    game.rubles = game.rubles - cost  -- State mutation
end
```

### After (MVP Pattern)

```lua
-- game/routes_model.lua (NEW - Model Layer)
function routes_model.get_ships_for_loading(game)
    local ships = {}
    for i, ship in ipairs(game.fleet) do
        if ship.status == "Docked" then
            local port = world.get_port(ship.origin_id)
            if port and port.type == "export" then
                table.insert(ships, {index = i, ship = ship, port = port})
            end
        end
    end
    return ships
end

function routes_model.calculate_cargo_cost(amount, price_per_barrel)
    return amount * 1000 * price_per_barrel
end

function routes_model.load_cargo(game, ship, amount, cost)
    ship.cargo_amount = (ship.cargo_amount or 0) + amount
    ship.cargo_type = "Crude"
    game.rubles = game.rubles - cost
end

-- presenters/routes.lua (NEW - Presenter Layer)
function routes_presenter.load_cargo(game, echo_fn, read_char, read_line)
    -- Get data from Model
    local available_ships = routes_model.get_ships_for_loading(game)
    
    -- Present to user
    echo_fn("Select ship to load:\n\n")
    for i, entry in ipairs(available_ships) do
        echo_fn(string.format("(%d) %s\n", i, entry.ship.name))
    end
    
    -- Get input and validate
    local choice = read_char()
    local amount = tonumber(read_line())
    local cost = routes_model.calculate_cargo_cost(amount, port.oil_price)
    
    -- Execute via Model
    routes_model.load_cargo(game, ship, amount, cost)
end
```

## Testing

### Model Layer Tests
```bash
lua5.3 tests/test_routes_model.lua
```

Tests pure business logic without any UI dependencies.

### Integration Tests
Run full test suite:
```bash
make test
```

## File Structure

```
shadow-fleet/
├── game/               # Model Layer
│   ├── init.lua       # Game state
│   ├── world.lua      # World data
│   ├── turn.lua       # Turn processing
│   └── routes_model.lua  # Route/cargo business logic (NEW)
├── presenters/        # Presenter Layer (NEW)
│   └── routes.lua     # Route/cargo UI interaction
├── ui/                # View Layer
│   └── init.lua       # UI widgets
├── display.lua        # View Layer (screen rendering)
├── commands_init.lua  # Presenter coordination
└── main.lua           # Application entry point
```

## Summary

The MVP pattern is **fully implemented** across the codebase:
- ✅ **Model**: Pure business logic (`game/routes_model.lua`, `game/world.lua`, `game/turn.lua`, `game/init.lua`)
- ✅ **View**: Display/rendering (`ui/`, `display.lua`)
- ✅ **Presenter**: UI interaction (`presenters/routes.lua`, `commands_init.lua`)

This architecture provides:
- **Complete separation of concerns**: Game logic, UI rendering, and user interaction are isolated
- **Testability**: Model layer can be tested without UI dependencies
- **Maintainability**: Clear responsibility boundaries between layers
- **Reusability**: Business logic can be reused across different UIs

All deprecated files have been removed. The codebase now fully adheres to the MVP pattern inspired by CakePHP's architecture.
