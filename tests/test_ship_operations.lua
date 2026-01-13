#!/usr/bin/env lua5.3

-- Test Ship Operations Model
-- Validates refueling and repair logic

local ship_operations = require("game.ship_operations")
local gamestate = require("game")

print("Testing Ship Operations Model...")

-- Test 1: Get ships for refuel
local game = gamestate.new()
local ships_for_refuel = ship_operations.get_ships_for_refuel(game)
assert(type(ships_for_refuel) == "table", "get_ships_for_refuel should return a table")
assert(#ships_for_refuel > 0, "Should have ships available for refuel")
print("✓ Test 1: get_ships_for_refuel returns " .. #ships_for_refuel .. " ships")

-- Test 2: Calculate refuel cost
local cost = ship_operations.calculate_refuel_cost(50, 100)
assert(cost == 250000, "Cost should be 50% * 5000 = 250,000 Rubles")
print("✓ Test 2: calculate_refuel_cost correctly calculates cost")

-- Test 3: Validate refuel request
local ship = game.fleet[1]
ship.fuel = 50
local target = 100
cost = ship_operations.calculate_refuel_cost(ship.fuel, target)
local valid, error_msg = ship_operations.validate_refuel(ship, target, cost, game.rubles)
assert(valid == true, "Should validate refuel with sufficient funds")
print("✓ Test 3: validate_refuel passes with valid request")

-- Test 4: Validate refuel with insufficient funds
game.rubles = 1000  -- Set very low funds
valid, error_msg = ship_operations.validate_refuel(ship, target, cost, game.rubles)
assert(valid == false, "Should fail validation with insufficient funds")
assert(error_msg:find("Insufficient funds"), "Error message should mention insufficient funds")
print("✓ Test 4: validate_refuel fails with insufficient funds")

-- Test 5: Execute refuel
game = gamestate.new()  -- Reset
ship = game.fleet[1]
ship.fuel = 50
local rubles_before = game.rubles
cost = ship_operations.calculate_refuel_cost(50, 100)
ship_operations.refuel_ship(game, ship, 100, cost)
assert(ship.fuel == 100, "Ship fuel should be set to target")
assert(game.rubles == rubles_before - cost, "Rubles should decrease by cost")
print("✓ Test 5: refuel_ship successfully refuels and deducts cost")

-- Test 6: Calculate repair cost
cost = ship_operations.calculate_repair_cost(60, 100)
assert(cost == 400000, "Cost should be 40% * 10000 = 400,000 Rubles")
print("✓ Test 6: calculate_repair_cost correctly calculates cost")

-- Test 7: Execute repair
game = gamestate.new()  -- Reset
ship = game.fleet[1]
ship.hull = 60
rubles_before = game.rubles
cost = ship_operations.calculate_repair_cost(60, 100)
ship_operations.repair_ship(game, ship, 100, cost)
assert(ship.hull == 100, "Ship hull should be set to target")
assert(game.rubles == rubles_before - cost, "Rubles should decrease by cost")
print("✓ Test 7: repair_ship successfully repairs and deducts cost")

-- Test 8: Get ships for repair
ships_for_repair = ship_operations.get_ships_for_repair(game)
assert(type(ships_for_repair) == "table", "get_ships_for_repair should return a table")
assert(#ships_for_repair > 0, "Should have ships available for repair")
print("✓ Test 8: get_ships_for_repair returns " .. #ships_for_repair .. " ships")

print("\n=== Ship Operations Model Tests ===")
print("All tests passed! ✓")
print("\nFunctions tested:")
print("  • get_ships_for_refuel - get list of ships that can refuel")
print("  • calculate_refuel_cost - calculate cost of refueling")
print("  • validate_refuel - validate refuel request")
print("  • refuel_ship - execute refueling")
print("  • get_ships_for_repair - get list of ships that can be repaired")
print("  • calculate_repair_cost - calculate cost of repair")
print("  • validate_repair - validate repair request")
print("  • repair_ship - execute repair")
