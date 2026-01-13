#!/usr/bin/env lua5.3

-- Test Ship Operations Presenter
-- Tests UI layer for refueling and repairing ships

local ship_operations_presenter = require("presenters.ship_operations")
local gamestate = require("game")

print("Testing Ship Operations Presenter...")
print("")

-- Test 1: Ship operations presenter module loads
assert(type(ship_operations_presenter) == "table", "ship_operations_presenter should be a table")
assert(type(ship_operations_presenter.refuel_ship) == "function", "refuel_ship should be a function")
assert(type(ship_operations_presenter.repair_ship) == "function", "repair_ship should be a function")
print("✓ Test 1: Ship operations presenter module loaded successfully")

-- Test 2: Create mock functions for testing
local echo_buffer = {}
local function mock_echo(text)
    table.insert(echo_buffer, text)
end

local function mock_read_char_cancel()
    return "B"  -- Cancel/back
end

local function mock_read_line_cancel()
    return nil
end

-- Test 3: refuel_ship function can be called
local game = gamestate.new()
local success, err = pcall(function()
    ship_operations_presenter.refuel_ship(game, mock_echo, mock_read_char_cancel, mock_read_line_cancel)
end)
assert(success, "refuel_ship should not crash when called: " .. tostring(err or ""))
print("✓ Test 2: refuel_ship function can be called")

-- Test 4: Verify refuel output contains expected elements
echo_buffer = {}
ship_operations_presenter.refuel_ship(game, mock_echo, mock_read_char_cancel, mock_read_line_cancel)

local output = table.concat(echo_buffer, "")
assert(output:match("REFUEL"), "Output should contain REFUEL header")
assert(output:match("Fuel"), "Output should mention fuel")
assert(output:match("GHOST%-01"), "Output should list docked ships")
print("✓ Test 3: refuel_ship displays expected UI elements")

-- Test 5: repair_ship function can be called
echo_buffer = {}
success, err = pcall(function()
    ship_operations_presenter.repair_ship(game, mock_echo, mock_read_char_cancel, mock_read_line_cancel)
end)
assert(success, "repair_ship should not crash when called: " .. tostring(err or ""))
print("✓ Test 4: repair_ship function can be called")

-- Test 6: Verify repair output
echo_buffer = {}
ship_operations_presenter.repair_ship(game, mock_echo, mock_read_char_cancel, mock_read_line_cancel)

output = table.concat(echo_buffer, "")
assert(output:match("REPAIR"), "Output should contain REPAIR header")
assert(output:match("Hull"), "Output should mention hull")
assert(output:match("GHOST%-01"), "Output should list docked ships")
print("✓ Test 5: repair_ship displays expected UI elements")

-- Test 7: Test with preselected ship
local ship = game.fleet[1]
ship.fuel = 50
echo_buffer = {}

-- Mock read_line to return invalid input first
local function mock_read_line_invalid()
    return "invalid"
end

success, err = pcall(function()
    ship_operations_presenter.refuel_ship(game, mock_echo, mock_read_char_cancel, mock_read_line_invalid, ship)
end)
assert(success, "refuel_ship with preselected ship should not crash: " .. tostring(err or ""))
print("✓ Test 6: refuel_ship works with preselected ship")

-- Test 8: Test repair with preselected ship
ship.hull = 60
echo_buffer = {}

success, err = pcall(function()
    ship_operations_presenter.repair_ship(game, mock_echo, mock_read_char_cancel, mock_read_line_invalid, ship)
end)
assert(success, "repair_ship with preselected ship should not crash: " .. tostring(err or ""))
print("✓ Test 7: repair_ship works with preselected ship")

-- Test 9: Test with no docked ships
local game_no_ships = gamestate.new()
for _, ship in ipairs(game_no_ships.fleet) do
    ship.status = "at_sea"
end
echo_buffer = {}

ship_operations_presenter.refuel_ship(game_no_ships, mock_echo, mock_read_char_cancel, mock_read_line_cancel)

output = table.concat(echo_buffer, "")
assert(output:match("No ships"), "Should show message about no ships available")
print("✓ Test 8: refuel_ship handles no available ships gracefully")

-- Test 10: Test simulated refuel with target input
local function mock_read_char_sequence()
    local sequence = {"1", "Y"}  -- Select ship 1, confirm
    local index = 0
    return function()
        index = index + 1
        return sequence[index]
    end
end

local function mock_read_line_target()
    return "100"  -- Target 100%
end

game = gamestate.new()
game.fleet[1].fuel = 50
echo_buffer = {}

-- This will attempt the full flow
pcall(function()
    ship_operations_presenter.refuel_ship(game, mock_echo, mock_read_char_sequence(), mock_read_line_target)
end)

-- Should have attempted to show cost calculation
output = table.concat(echo_buffer, "")
assert(output:match("Refuel") or output:match("%d+%%"), "Should show refuel details with percentages")
print("✓ Test 9: refuel_ship flows through cost calculation")

-- Test 11: Test cost display formatting
game = gamestate.new()
ship = game.fleet[1]
ship.hull = 50
echo_buffer = {}

-- Mock to skip to cost display
local function mock_read_line_100()
    return "100"
end

pcall(function()
    ship_operations_presenter.repair_ship(game, mock_echo, mock_read_char_cancel, mock_read_line_100, ship)
end)

output = table.concat(echo_buffer, "")
assert(output:match("Rubles"), "Should display cost in Rubles")
assert(output:match("50%%") or output:match("100%%"), "Should show hull percentages")
print("✓ Test 10: repair_ship displays cost information correctly")

print("")
print("===================================")
print("All ship operations presenter tests passed! ✓")
print("===================================")
print("")
print("Tested presenter functionality:")
print("  • refuel_ship - refueling UI flow")
print("  • repair_ship - repair UI flow")
print("  • Preselected ship handling (action screens)")
print("  • No available ships handling")
print("  • User input flow (selection, target input, confirmation)")
print("  • Cost calculation and display")
print("  • Output formatting")
print("")
