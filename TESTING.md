# Testing Guide for Shadow Fleet

## Overview

This guide explains the testing architecture and best practices for Shadow Fleet. The codebase now includes comprehensive testing infrastructure to support automated testing, mocking, and edge case validation.

## Testing Architecture

Shadow Fleet uses a layered testing approach that mirrors the MVP (Model-View-Presenter) architecture:

### Test Categories

1. **Infrastructure Tests** - Test the testing infrastructure itself
2. **Unit Tests** - Test individual modules in isolation
3. **Edge Case Tests** - Test boundary conditions and error handling
4. **Integration Tests** - Test presenter flows and full gameplay

### Test Organization

```
tests/
├── mocks/                    # Mock implementations
│   └── io.lua               # Mock I/O utilities
├── test_config.lua          # Configuration module tests
├── test_io_abstraction.lua  # I/O abstraction tests
├── test_mock_io.lua         # Mock utilities tests
├── test_mock_demo.lua       # Mock usage demonstration
├── test_edge_cases.lua      # Edge case and boundary tests
├── test_*.lua               # Existing unit and integration tests
└── ...
```

## New Testing Infrastructure

### 1. I/O Abstraction Layer

The I/O abstraction layer enables mocking of input/output for automated testing.

#### `ui/output.lua` - Output Abstraction

```lua
local ui_output = require("ui.output")

-- Normal usage (writes to terminal)
ui_output.write("Hello, World!\n")

-- For testing - set a mock function
local captured = {}
ui_output.set_output_fn(function(text)
    table.insert(captured, text)
end)

-- Now output is captured instead of written to terminal
ui_output.write("Test output")
-- captured[1] == "Test output"

-- Reset to default
ui_output.reset()
```

#### `ui/input.lua` - Input Abstraction

```lua
local ui_input = require("ui.input")

-- Normal usage (reads from terminal)
local char = ui_input.read_char()
local line = ui_input.read_line()

-- For testing - provide mock functions
ui_input.set_read_char_fn(function()
    return "A"  -- Return pre-scripted input
end)

ui_input.set_read_line_fn(function()
    return "Test input"
end)

-- Now input comes from mock functions
local char = ui_input.read_char()  -- Returns "A"
local line = ui_input.read_line()  -- Returns "Test input"

-- Reset to default
ui_input.reset()
```

### 2. Configuration Module

The configuration module centralizes all configurable parameters.

#### `config.lua` - Centralized Configuration

```lua
local config = require("config")

-- Access configuration values directly
local width = config.ui.default_width  -- 120
local initial_rubles = config.game.initial_rubles  -- 5000000

-- Or use dot-notation getter
local width = config.get("ui.default_width")

-- Modify for testing
config.set("game.initial_rubles", 1000000)
-- Run tests with modified config
config.set("game.initial_rubles", 5000000)  -- Restore
```

**Configuration sections:**
- `config.ui` - UI parameters (widths, decimals, etc.)
- `config.game` - Game parameters (initial values, limits, etc.)
- `config.costs` - Cost parameters (repair, refuel, etc.)
- `config.colors` - ANSI color codes

### 3. Mock I/O Utilities

The mock I/O utilities provide a complete testing harness for presenter functions.

#### `tests/mocks/io.lua` - Mock Utilities

**Create mock output with capture:**
```lua
local mock_io = require("tests.mocks.io")

local mock_output, captured = mock_io.create_output()
mock_output("Hello")
mock_output("World")
-- captured[1] == "Hello"
-- captured[2] == "World"
```

**Create mock input:**
```lua
-- Mock character input
local mock_read_char = mock_io.create_read_char({"A", "B", "C"})
mock_read_char()  -- Returns "A"
mock_read_char()  -- Returns "B"
mock_read_char()  -- Returns "C"
mock_read_char()  -- Returns nil (EOF)

-- Mock line input
local mock_read_line = mock_io.create_read_line({"Line 1", "Line 2"})
mock_read_line()  -- Returns "Line 1"
mock_read_line()  -- Returns "Line 2"
```

**Create complete environment:**
```lua
-- Create environment with pre-scripted input
local env = mock_io.create_environment(
    {"1", "Y"},           -- Character inputs
    {"100", "Test line"}  -- Line inputs
)

-- Use in your presenter function
my_presenter(game, env.output_fn, env.read_char, env.read_line)

-- Verify output
mock_io.assert_output_contains(env.captured, "Expected text")
mock_io.assert_output_not_contains(env.captured, "Unexpected text")
```

**Assertion helpers:**
```lua
-- Assert output contains text
mock_io.assert_output_contains(captured, "Success")

-- Assert output does not contain text
mock_io.assert_output_not_contains(captured, "Error")

-- Get full output as string
local full = mock_io.get_full_output(captured)

-- Clear captured output
mock_io.clear_output(captured)
```

## Writing Tests

### Unit Test Pattern

Unit tests focus on pure business logic without UI dependencies.

```lua
#!/usr/bin/env lua5.3
-- Test Module Name

local my_module = require("my_module")

print("Testing Module Name...")
print("")

-- Test 1: Basic functionality
print("=== Test 1: Description ===")
local result = my_module.calculate_something(10)
assert(result == 20, "Should calculate correctly")
print("✓ Test passed")

print("")
print("===================================")
print("All tests passed! ✓")
print("===================================")
```

### Edge Case Test Pattern

Edge case tests verify boundary conditions and error handling.

```lua
#!/usr/bin/env lua5.3
-- Test Edge Cases

local my_module = require("my_module")

print("Testing Edge Cases...")

-- Test with zero
local valid, err = my_module.validate(0)
assert(not valid, "Should reject zero")
assert(err == "Invalid input", "Should have error message")

-- Test with nil
valid, err = my_module.validate(nil)
assert(not valid, "Should reject nil")

-- Test with maximum value
valid, err = my_module.validate(999999)
assert(valid, "Should accept maximum value")
```

### Integration Test with Mocks

Integration tests verify presenter flows using mock I/O.

```lua
#!/usr/bin/env lua5.3
-- Test Presenter Integration

local mock_io = require("tests.mocks.io")
local presenter = require("presenters.my_presenter")
local gamestate = require("game")

print("Testing Presenter Integration...")

-- Setup
local game = gamestate.new()

-- Test successful flow
print("=== Test 1: Successful Flow ===")
local env = mock_io.create_environment(
    {"1", "Y"},      -- User selects option 1, confirms
    {"100"}          -- User enters 100
)

presenter.my_action(game, env.output_fn, env.read_char, env.read_line)

-- Verify
mock_io.assert_output_contains(env.captured, "Success")
print("✓ Successful flow works")

-- Test cancellation
print("")
print("=== Test 2: User Cancels ===")
env = mock_io.create_environment({"B"}, {})

presenter.my_action(game, env.output_fn, env.read_char, env.read_line)

mock_io.assert_output_contains(env.captured, "Cancelled")
print("✓ Cancellation works")
```

## Running Tests

### Run All Tests
```bash
make test
```

### Run Specific Test Categories
```bash
make test-infrastructure  # Infrastructure tests
make test-unit           # Unit tests
make test-edge           # Edge case tests
make test-integration    # Integration tests
```

### Run Specific Test File
```bash
make test-file FILE=test_widgets
make test-file FILE=test_edge_cases
```

### Run Individual Test Directly
```bash
lua5.3 tests/test_config.lua
lua5.3 tests/test_edge_cases.lua
```

## Best Practices

### 1. Test Pure Logic First

Always test business logic (Model layer) without UI dependencies:

```lua
-- Good: Tests pure business logic
local cost = routes_model.calculate_cargo_cost(100, 60)
assert(cost == 6000000, "Cost should be correct")
```

### 2. Use Descriptive Assertions

Provide clear error messages:

```lua
-- Good: Clear error message
assert(result == expected, 
    string.format("Expected %d but got %d", expected, result))

-- Avoid: No context
assert(result == expected)
```

### 3. Test Edge Cases

Always test boundary conditions:

```lua
-- Zero values
assert(not validate(0), "Should reject zero")

-- Nil values
assert(not validate(nil), "Should reject nil")

-- Maximum values
assert(validate(MAX_VALUE), "Should accept maximum")

-- Empty collections
assert(#get_ships({}) == 0, "Should handle empty fleet")
```

### 4. Test Error Paths

Don't just test success cases:

```lua
-- Success case
local valid, err = validate_purchase(ship, 1000000)
assert(valid, "Should accept valid purchase")

-- Insufficient funds
valid, err = validate_purchase(ship, 999999999)
assert(not valid, "Should reject insufficient funds")
assert(err:find("Insufficient"), "Should have error message")
```

### 5. Use Mocks for Presenter Tests

Test presenter flows without manual interaction:

```lua
local env = mock_io.create_environment(
    {"1"},     -- Pre-scripted character input
    {"100"}    -- Pre-scripted line input
)

presenter_function(game, env.output_fn, env.read_char, env.read_line)

mock_io.assert_output_contains(env.captured, "Expected output")
```

### 6. Clean Up After Tests

Restore state when modifying configuration:

```lua
-- Save original
local original = config.game.initial_rubles

-- Modify for test
config.set("game.initial_rubles", 1000000)
-- ... run tests ...

-- Restore
config.set("game.initial_rubles", original)
```

## Continuous Integration

Tests are automatically run on:
- Pull requests
- Pushes to main/master branches

See `.github/workflows/ci.yml` for CI configuration.

## Examples

### Example 1: Testing with Mock I/O

See `tests/test_mock_demo.lua` for a complete demonstration of:
- Setting up mock I/O environment
- Testing presenter functions
- Verifying output
- Testing various input scenarios

### Example 2: Edge Case Testing

See `tests/test_edge_cases.lua` for examples of:
- Empty fleet scenarios
- Invalid inputs (zero, negative, nil)
- Insufficient funds
- Boundary values
- Invalid indices

### Example 3: Configuration Usage

See `tests/test_config.lua` for examples of:
- Accessing configuration values
- Modifying config for testing
- Using get/set methods

## Summary

The new testing infrastructure provides:

✅ **I/O Abstraction** - Mock input/output for automated testing
✅ **Configuration Module** - Centralized, testable parameters
✅ **Mock Utilities** - Complete testing harness for presenters
✅ **Edge Case Tests** - Comprehensive boundary condition coverage
✅ **Selective Testing** - Run specific test categories via Makefile

This enables:
- Fast, automated testing
- No manual interaction required
- Complete UI flow testing
- Easy edge case validation
- Confidence in code changes
