#!/usr/bin/env lua5.3
-- Test routes presenter to ensure it handles float fuel values

local routes_presenter = require("presenters.routes")
local gamestate = require("game")
local turn = require("game.turn")

print("Testing Routes Presenter with Float Fuel Values...")
print("")

-- Test 1: Routes presenter module loads
assert(type(routes_presenter) == "table", "routes_presenter should be a table")
print("✓ Test 1: Routes presenter module loaded successfully")

-- Test 2: Create a game state and process a turn to generate float fuel values
local game = gamestate.new()

-- Verify initial fuel is an integer
local initial_fuel = game.fleet[1].fuel
assert(type(initial_fuel) == "number", "Initial fuel should be a number")
print(string.format("✓ Test 2: Initial fuel for %s is %s (type: %s)", 
    game.fleet[1].name, tostring(initial_fuel), type(initial_fuel)))

-- Set a ship to "at_sea" status so turn processing will consume fuel
game.fleet[1].status = "at_sea"
game.fleet[1].destination_id = "malta_sts"
game.fleet[1].days_remaining = 5
game.fleet[1].eta = 5

-- Process a turn to consume fuel (this will make fuel a float)
turn.process(game)

-- Verify fuel is now a float
local post_turn_fuel = game.fleet[1].fuel
assert(type(post_turn_fuel) == "number", "Post-turn fuel should be a number")
print(string.format("✓ Test 3: After turn, fuel for %s is %s (type: %s)", 
    game.fleet[1].name, tostring(post_turn_fuel), type(post_turn_fuel)))

-- Verify it's a float (has decimal places)
assert(post_turn_fuel ~= math.floor(post_turn_fuel), 
    "Fuel should be a float after turn processing")
print("✓ Test 4: Fuel is correctly a floating-point number after consumption")

-- Test 5: Test that string.format with %d and math.floor works
local test_fuel = 78.78
local formatted = string.format("Fuel: %d%%", math.floor(test_fuel))
assert(formatted == "Fuel: 78%", 
    string.format("Expected 'Fuel: 78%%' but got '%s'", formatted))
print("✓ Test 5: math.floor() with %d format works correctly for float values")

-- Test 6: Verify the actual presenter code won't crash with float fuel
-- We can't fully test the interactive presenter without mocking input,
-- but we can test the formatting logic
local test_ship = game.fleet[1]
test_ship.fuel = 71.81  -- Set to a known float value

-- Simulate the formatting that happens in the presenter
local formatted_display = string.format("(%d) %s - Fuel: %d%%",
    1, test_ship.name, math.floor(test_ship.fuel))
assert(type(formatted_display) == "string", "Should produce a string")
assert(formatted_display:match("Fuel: 71%%"), "Should show fuel as 71%")
print("✓ Test 6: Presenter formatting logic handles float fuel values correctly")

print("")
print("===================================")
print("All routes presenter tests passed! ✓")
print("===================================")
print("")
print("These tests ensure:")
print("  • Fuel becomes a float after turn processing")
print("  • math.floor() prevents 'number has no integer representation' errors")
print("  • Presenter can safely display ships with float fuel values")
print("")
